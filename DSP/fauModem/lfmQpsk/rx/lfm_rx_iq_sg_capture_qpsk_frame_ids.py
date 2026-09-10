"""
External-loopback RX script for SG-enabled S2MM cyclic capture --
LFM + PRBS + QPSK / NLMS-DFE frame format. Sibling to
lfm_rx_iq_sg_capture_frame_ids.py -- identical hardware-driver call
pattern (dma_rx_sg_16m.program_s2mm_capture / unpack_q15 don't care what
modulation is in the captured samples), swapped to the QPSK demodulation
chain (lfm_qpsk_common.analyze_capture(), see lfm_qpsk_rx.py).

This is the missing piece to actually run a QPSK capture on hardware: it
produces the raw uint32 capture file and the "=== DEMODULATE CAPTURE
FILE ===" / "=== EXTERNAL LOOPBACK RX SUMMARY ===" report, same as the
BPSK script, but against lfm_qpsk_frame.py's 2-bit/symbol payload
(P.N_data_bits=400 vs BPSK's P.N_data=200).

--sample-ppm auto-estimation/correction carries over unchanged from the
BPSK script -- lfm_qpsk_common.estimate_sample_ppm() is byte-for-byte the
same algorithm (sample-domain LFM-detection spacing only, modulation-
agnostic), applied per-packet in lfm_qpsk_rx.py's Stage 4 the same way.

Dropped vs. the original (same list as lfm_rx_iq_sg_capture_frame_ids.py
vs. rx_iq_sg_capture_frame_ids.py): every flag tied to the old frame's
fixed-offset, block-marker/CP-timed sync scheme. None of these have a
meaning for the new frame here either.
"""

import argparse
import csv

import lfm_qpsk_params as P
import lfm_qpsk_tx as TX
import lfm_qpsk_rx as RX
import lfm_qpsk_common as C
from common_frame_ids import parse_size_bytes
from dma_rx_sg_16m import S2MM_BUF_SIZE, program_s2mm_capture


def run_self_test(args):
    n_frames = max(2, int(args.tx_frames))
    frame_ids = list(range(n_frames))

    print("=== RX SCRIPT SELF-TEST ===")
    print(f"  Test frame IDs      : 0..{n_frames - 1}")
    print("  Channel             : noiseless, no-channel round trip")

    cap = TX.build_multi_frame_capture(frame_ids)
    waveform = cap["capture"]
    print(f"  Built capture       : {len(waveform)} samples "
          f"({len(waveform) / P.Fs * 1e3:.1f} ms)")

    # build_multi_frame_capture() inserts extra inter-frame silence (unlike
    # the real hardware's back-to-back cyclic TX stream), so ppm
    # auto-estimation isn't meaningful here -- this is a noiseless,
    # zero-ppm sanity check by construction.
    ana = C.analyze_capture(waveform, marker_score_max=args.marker_score_max,
                            verbose=not args.quiet_rx, sample_ppm=0.0)

    ok = (ana["n_packets_detected"] == n_frames
          and ana["total_err"] == 0
          and ana["total_bits"] == n_frames * P.N_data_bits)
    status = "PASS" if ok else "FAIL"
    pdsnr = ana.get("pdsnr_db")
    pdsnr_str = f"{pdsnr:.2f}dB" if pdsnr is not None else "n/a"
    print(f"[self] {status}  packets={ana['n_packets_detected']}/{n_frames}  "
          f"errs={ana['total_err']}/{ana['total_bits']}  PDSNR={pdsnr_str}")
    if not ok:
        raise RuntimeError("RX script self-test failed")
    print("[self] Result          : PASS")


def check_frame_continuity(results, id_cycle: int):
    """
    Expected frame_id sequence for the repeated id_cycle pattern, checked
    against the readable, time-ordered detections. Any unreadable/failed
    packet breaks strict continuity (reported, not silently skipped).

    Anchored to the FIRST readable packet's own frame_id, not assumed to
    be 0. A capture starts wherever the operator happened to start it
    against the TX's free-running cyclic loop, so the first detected
    packet can legitimately be any id in 0..id_cycle-1 -- the previous
    version built `expected` as [0, 1, 2, ...] unconditionally, which
    only matched a capture that happened to start exactly on frame_id 0
    and reported FAIL on every other capture regardless of how clean the
    link actually was. Same bug and same fix as the BPSK driver's copy of
    this function (lfm_rx_iq_sg_capture_frame_ids.py, 2026-09-03):
    confirmed against a 2026-09 tank run (two-board pairing, M10 UART
    down) that detected 134 packets, 133 readable with 0 bit errors and
    17.75dB PDSNR, whose capture happened to start on frame_id 3 -- FAIL
    under the old logic, PASS under this one, same data, same decode.
    """
    all_readable = all(r.get("ok") and r.get("readable") for r in results)
    actual = [(r.get("frame_id") if r.get("ok") and r.get("readable") else None)
              for r in results]
    first = next((v for v in actual if v is not None), None)
    expected = ([None] * len(actual) if first is None else
                [(first + i) % id_cycle for i in range(len(actual))])
    sequence_ok = all_readable and actual == expected
    return dict(sequence_ok=sequence_ok, all_readable=all_readable,
                expected=expected, actual=actual)


def write_report_csv(path: str, results):
    fields = ["capture_idx", "lfm_start", "ok", "frame_id", "marker_score",
              "readable", "n_err", "n_bits", "xcorr_peak", "CFO_total",
              "ber_train", "agree", "pdsnr_db", "reason"]
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        for row in results:
            w.writerow(row)


def main():
    parser = argparse.ArgumentParser(
        description="IQ RX-only S2MM SG capture/analyze, LFM+PRBS+QPSK frame-ID payloads")
    parser.add_argument("--tx-frames", type=int, default=6,
                        help="Number of unique TX frame IDs in the remote repeated packet")
    parser.add_argument("--rx-buffers", type=int, default=6,
                        help="Number of S2MM buffers in the cyclic ring")
    parser.add_argument("--rx-buffer-bytes", default="2MiB",
                        help="Bytes per S2MM buffer, e.g. 2MiB")
    parser.add_argument("--passes", type=int, default=2,
                        help="Number of times to copy the S2MM ring")
    parser.add_argument("--raw-out", default="lfm_iq_rx_capture_u32.bin",
                        help="Raw appended S2MM capture file")
    parser.add_argument("--report", default="lfm_iq_rx_report.csv",
                        help="Per-packet analysis CSV")
    parser.add_argument("--marker-score-max", type=int, default=8,
                        help="Max Hamming score on the A5 5A id ~id marker before "
                             "a decoded packet is treated as unreadable (frame_id "
                             "unknown) rather than mis-assigned")
    parser.add_argument("--id-space", type=int, default=256, metavar="N_IDS",
                        help="Number of candidate frame_ids to score the marker "
                             "against when identifying a decoded packet")
    parser.add_argument("--sample-ppm", type=float, default=None, metavar="PPM",
                        help="RX/TX sample-clock offset correction (ppm), e.g. from "
                             "TX and RX being two different boards with independent "
                             "crystals. Default: auto-estimate from the spacing "
                             "between detected LFM packet starts (see "
                             "lfm_qpsk_common.estimate_sample_ppm). Pass an explicit "
                             "value to override the estimate.")
    parser.add_argument("--no-ppm-correct", action="store_true",
                        help="Disable sample-clock ppm correction entirely (forces "
                             "0.0 regardless of --sample-ppm or auto-estimation)")
    parser.add_argument("--poll-timeout", type=float, default=20.0,
                        help="Seconds to wait for each S2MM BD completion")
    parser.add_argument("--quiet-tx", action="store_true",
                        help="Suppress local reference TX print")
    parser.add_argument("--quiet-rx", action="store_true",
                        help="Suppress detailed RX print per detected packet")
    parser.add_argument("--keep-dma-running", action="store_true",
                        help="Leave S2MM running after the requested capture")
    parser.add_argument("--nco", type=float, default=120000.0, metavar="FREQ_HZ",
                        help="Update the DDS Compiler NCO output frequency (Hz) "
                             "via the phase-increment GPIOs before capture. Default: 120000 Hz. "
                             "Use --no-program-nco to leave the current DDS setting untouched.")
    parser.add_argument("--no-program-nco", action="store_true",
                        help="Leave DDS/NCO frequency unchanged instead of programming --nco")
    parser.add_argument("--capture-only", action="store_true",
                        help="Capture raw S2MM buffers to --raw-out, then exit before demodulation")
    parser.add_argument("--analyze-only", default=None,
                        help="Skip DMA and analyze an existing raw uint32 capture file")
    parser.add_argument("--self-test", action="store_true",
                        help="Run a noiseless synthetic round-trip RX check and exit before DMA")
    parser.add_argument("--sampling-rate", type=int, default=None, metavar="FS_HZ",
                        help="Baseband RX sample rate in Hz (e.g. 500000). "
                             "ADC input is always 10 MSPS; this sets the CIC decimation "
                             "factor (decim = 10_000_000 / FS_HZ) and the demodulator "
                             "sample rate. Must divide 10 000 000 evenly. Default: 400 000.")
    args = parser.parse_args()

    if args.tx_frames <= 0:
        parser.error("--tx-frames must be > 0")
    if args.rx_buffers <= 0:
        parser.error("--rx-buffers must be > 0")
    if args.passes <= 0:
        parser.error("--passes must be > 0")
    if args.capture_only and args.analyze_only:
        parser.error("--capture-only cannot be used with --analyze-only")
    if not args.no_program_nco and args.nco is not None and args.nco < 0:
        parser.error("--nco frequency must be >= 0 Hz")
    if args.marker_score_max < 0:
        parser.error("--marker-score-max must be >= 0")
    if args.id_space <= 0:
        parser.error("--id-space must be > 0")
    args.effective_sample_ppm = 0.0 if args.no_ppm_correct else args.sample_ppm
    try:
        args.rx_buffer_bytes = parse_size_bytes(args.rx_buffer_bytes)
    except ValueError as exc:
        parser.error(f"invalid --rx-buffer-bytes: {exc}")
    if args.rx_buffer_bytes <= 0:
        parser.error("--rx-buffer-bytes must be > 0")
    if args.rx_buffer_bytes % 4:
        parser.error("--rx-buffer-bytes must be a multiple of 4 bytes")
    if args.rx_buffer_bytes * args.rx_buffers > S2MM_BUF_SIZE:
        parser.error(
            f"RX ring needs {args.rx_buffer_bytes * args.rx_buffers} B, "
            f"but reserved S2MM memory is {S2MM_BUF_SIZE} B")
    args.rx_buffer_words = args.rx_buffer_bytes // 4

    if args.self_test:
        run_self_test(args)
        return

    # --sampling-rate: validate and update lfm_qpsk_params (which also
    # updates the shared bpsk_params module) for this run.
    _CIC_IN = 10_000_000
    Fs_hz = int(args.sampling_rate) if args.sampling_rate is not None else int(P.Fs)
    if _CIC_IN % Fs_hz != 0:
        parser.error(
            f"--sampling-rate {Fs_hz} does not divide {_CIC_IN} evenly. "
            f"Valid examples: 2500000, 2000000, 1250000, 1000000, "
            f"500000, 400000, 250000, 200000.")
    decim_factor = _CIC_IN // Fs_hz
    if not (4 <= decim_factor <= 65535):
        parser.error(
            f"--sampling-rate {Fs_hz} gives decimation factor "
            f"{decim_factor}, which is outside the CIC valid range [4, 65535].")
    if Fs_hz != int(P.Fs):
        P.reconfigure_fs(Fs_hz)

    print("=== EXTERNAL LOOPBACK IQ RX CONFIG (LFM+PRBS+QPSK) ===")
    print("  RX mode            : S2MM scatter-gather cyclic IQ ADC")
    print("  RX sample format   : q15 complex I/Q (packed {Q,I})")
    print(f"  Sample rate        : {P.Fs/1e3:.1f} kSPS  "
          f"(sps={P.sps}, decim_factor={decim_factor})")
    print(f"  Expected TX IDs    : 0..{args.tx_frames - 1}, repeated")
    print(f"  S2MM ring buffers  : {args.rx_buffers}")
    print(f"  S2MM buffer bytes  : {args.rx_buffer_bytes}")
    print(f"  Capture passes     : {args.passes}")
    print(f"  Captured buffers   : {args.rx_buffers * args.passes}")
    print(f"  Reserved RX mem    : {S2MM_BUF_SIZE} B")
    print("  Payload mode       : A5 5A id ~id marker + PRNG data (see lfm_qpsk_frame.py)")
    print(f"  Marker score max   : {args.marker_score_max}")
    if args.no_ppm_correct:
        print("  Sample-clock ppm   : correction disabled")
    elif args.sample_ppm is not None:
        print(f"  Sample-clock ppm   : {args.sample_ppm:+.3f} ppm (fixed, --sample-ppm)")
    else:
        print("  Sample-clock ppm   : auto-estimate from LFM packet spacing")
    print(f"  Frame layout       : LFM({P.N_lfm}) + guard({P.N_guard}) + "
          f"RRC-shaped(train={P.N_train}+data={P.N_data} sym, "
          f"{P.bps_sym} bits/sym -> {P.N_data_bits} payload bits)")

    if not args.quiet_tx:
        pkt0 = TX.build_packet_waveform(0)
        frame_words = len(pkt0["packet"])
        print("\n=== RX EXPECTED STREAM ===")
        print(f"  Payload bits / frame    : {P.N_data_bits}")
        print(f"  Words / physical frame  : {frame_words}")
        print(f"  Physical frame duration : {frame_words / P.Fs:.3f} s")

    expected_raw_words = args.rx_buffers * args.passes * args.rx_buffer_words
    print(f"  Expected raw words      : {expected_raw_words}")
    print(f"  Expected raw bytes      : {expected_raw_words * 4}")

    cap = None
    if args.analyze_only:
        args.raw_out = args.analyze_only
        print("\n=== DMA CAPTURE ===")
        print(f"[dma] Skipped; analyzing existing file {args.raw_out}")
    else:
        # NCO and CIC decimation are programmed inside program_s2mm_capture(),
        # AFTER its PS fabric reset -- that reset clears the NCO/CIC/frame-
        # length config along with the DMA itself, so setting them here first
        # would just get wiped (matches lfm_rx_iq_sg_capture_frame_ids.py).
        nco_freq_hz = (args.nco if (not args.no_program_nco
                                    and args.nco is not None) else None)
        print("\n=== DMA CAPTURE ===")
        cap = program_s2mm_capture(
            raw_out=args.raw_out,
            rx_buffer_words=args.rx_buffer_words,
            n_rx_buffers=args.rx_buffers,
            passes=args.passes,
            poll_timeout=args.poll_timeout,
            stop_dma=not args.keep_dma_running,
            decim_fs_hz=Fs_hz,
            nco_freq_hz=nco_freq_hz,
        )

    if args.capture_only:
        print("\n=== CAPTURE ONLY SUMMARY ===")
        print(f"  Raw file              : {args.raw_out}")
        print(f"  Expected raw words    : {expected_raw_words}")
        print(f"  Expected raw bytes    : {expected_raw_words * 4}")
        if cap is not None:
            print(f"  Completed S2MM BDs    : {cap['completed_bds']}")
            print(f"  Acquisition drops     : {cap.get('acquisition_drops', cap.get('malformed_packets', 0))}")
            print(f"  Stream drops          : {cap.get('stream_drops', 0)}")
        print("  Demodulation          : skipped")
        return

    print("\n=== DEMODULATE CAPTURE FILE (LFM matched-filter + NLMS-DFE) ===")
    ana = C.analyze_capture(
        args.raw_out,
        n_ids=args.id_space,
        marker_score_max=args.marker_score_max,
        verbose=not args.quiet_rx,
        sample_ppm=args.effective_sample_ppm,
    )
    cont = check_frame_continuity(ana["results"], args.tx_frames)
    write_report_csv(args.report, ana["results"])

    print("\n=== EXTERNAL LOOPBACK RX SUMMARY ===")
    print(f"  Raw file              : {args.raw_out}")
    print(f"  Report                : {args.report}")
    if cap is not None:
        print(f"  Completed S2MM BDs    : {cap['completed_bds']}")
        print(f"  Acquisition drops     : {cap.get('acquisition_drops', cap.get('malformed_packets', 0))}")
        print(f"  Stream drops          : {cap.get('stream_drops', 0)}")
    ppm_diag = ana.get("ppm_diag", {})
    if args.no_ppm_correct:
        print("  Sample-clock ppm      : correction disabled (--no-ppm-correct)")
    elif ppm_diag.get("ok") and "n_gaps_used" in ppm_diag:
        print(f"  Sample-clock ppm      : {ana['sample_ppm']:+.3f} ppm  "
              f"(auto, {ppm_diag['n_gaps_used']}/{ppm_diag['n_gaps_total']} gaps used)")
    elif ppm_diag.get("ok"):
        print(f"  Sample-clock ppm      : {ana['sample_ppm']:+.3f} ppm (--sample-ppm)")
    else:
        print(f"  Sample-clock ppm      : +0.000 ppm (not estimated -- "
              f"{ppm_diag.get('reason', 'unknown')})")
    print(f"  Packets detected      : {ana['n_packets_detected']}")
    ids_str = ",".join(str(x) if x is not None else "?" for x in cont["actual"])
    print(f"  Frame ID sequence     : {ids_str}")
    print("                         (?=unreadable/failed packet)")
    print(f"  All packets readable  : {'PASS' if cont['all_readable'] else 'FAIL'}")
    print(f"  Frame ID continuity   : {'PASS' if cont['sequence_ok'] else 'FAIL'}")
    if ana["ber"] is not None:
        print(f"  Bit errors            : {ana['total_err']} / {ana['total_bits']}")
        print(f"  BER                   : {ana['ber']:.4e}")
        print(f"  Payload BER           : {'PASS' if ana['total_err'] == 0 else 'FAIL'}")
        pdsnr = ana.get("pdsnr_db")
        print(f"  Post-detection SNR    : {pdsnr:.2f} dB"
              if pdsnr is not None else "  Post-detection SNR    : n/a")
        print("                         (reference-aided EVM on the NLMS-DFE's "
              "equalized data symbols, pooled across all readable packets; "
              "per-packet values are in the report CSV)")
    else:
        print("  Bit errors            : n/a (no readable packets)")


if __name__ == "__main__":
    main()
