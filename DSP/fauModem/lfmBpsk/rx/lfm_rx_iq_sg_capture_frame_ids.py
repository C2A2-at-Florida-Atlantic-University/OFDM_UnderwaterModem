"""
External-loopback RX script for SG-enabled S2MM cyclic capture --
LFM + PRBS + BPSK / NLMS-DFE frame format.

Revised from rx_iq_sg_capture_frame_ids.py: demodulation now calls
lfm_bpsk_common.analyze_capture() (LFM matched-filter packet detection +
per-packet NLMS-DFE decode, see lfm_bpsk_rx.py) instead of
common_frame_ids.analyze_capture()'s old CP/pilot/block-marker frame
analysis. The hardware driver calls (dma_rx_sg_16m.program_s2mm_capture,
unpack_q15) are UNCHANGED -- they only need a raw uint32 capture file and
buffer/decimation/NCO settings, none of which cares what the captured
frame's internal structure is. This mirrors the TX-side revision in
lfm_tx_iq_sg_cyclic_frame_ids.py exactly.

Dropped vs. the original: every flag tied to the old frame's fixed-offset,
block-marker/CP-timed sync scheme -- --rx-format (legacy int32), --equalizer,
--guard-phase-correct, --pilot-reg, --analytic-input, --start-adjust-samples/
--start-sweep, --frame-offset-words/--auto-frame-offset/--nominal-sync-start/
--offset-probe-frames, --track-preamble and its search/lock-tolerance/radius
flags, --adaptive-timing* and --fractional-timing*, --timing-score,
--block-marker-timing*, --block-marker-polarity, --block-cp-timing*,
--timing-lock*, --plain-counter, --legacy-single-marker. None of these have
a meaning for the new frame: it is captured as complex q15 I/Q always, and
each physical frame is found independently by LFM matched-filter
correlation (lfm_bpsk_rx.detect_lfm_packets) rather than by a fixed offset
or adaptive timing search -- there is no "sync word position" to sweep or
lock onto, and no per-block CP/pilot/marker structure to time against.

--sample-ppm IS back, though: two independent boards (this port's actual
use case -- see lfm_tx_iq_sg_cyclic_frame_ids.py run against a different
board as TX, 2026-08-28) never share a clock, and that offset is a real
BER contributor within a ~1224-symbol packet even on an otherwise clean
channel. Unlike the old pipeline's version (a separate preamble-probing
pass, common_frame_ids.estimate_sample_clock_ppm()), this one is free:
every detected LFM burst is already an independent, self-syncing timing
reference, so the offset is estimated directly from the spacing between
detections already made for packet detection (see
lfm_bpsk_common.estimate_sample_ppm()) and applied per-packet in
lfm_bpsk_rx.decode_packet()'s Stage 4 via fractional-sample
interpolation, matching bpsk_rx.py's own downsample(). Auto-estimated and
applied by default; --sample-ppm overrides with an explicit value,
--no-ppm-correct disables correction entirely (forces 0.0, i.e. the
original behavior).
"""

import argparse
import csv

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX
import lfm_bpsk_rx as RX
import lfm_bpsk_common as C
import metrics_log
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
          and ana["total_bits"] == n_frames * P.N_data)
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
    link actually was. Confirmed against the 2026-09 tank sweep: a
    134/134-readable, 0-bit-error, PDSNR-36dB run whose capture happened
    to start on frame_id 5 was reported "Frame ID continuity: FAIL" under
    the old logic and "PASS" under this one -- same data, same decode,
    only the comparison's anchor changed.
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
        description="IQ RX-only S2MM SG capture/analyze, LFM+PRBS+BPSK frame-ID payloads")
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
                        help="Per-packet analysis CSV (overwritten each run)")
    parser.add_argument("--sweep-taps", type=int, default=0, metavar="N",
                        help="Sweep the NLMS-DFE geometry (K_2/K_fb) on the "
                             "first N complete packets and decode the whole "
                             "capture with the majority winner. 0 (default) "
                             "uses lfm_bpsk_params unchanged. 3 is the "
                             "measured sweet spot. Costs ~4 min per probe "
                             "packet on the board and CHANGES the decoded "
                             "bits, so it is opt-in. See tap_sweep.py.")
    parser.add_argument("--metrics-log", default="lfm_iq_rx_metrics.jsonl",
                        metavar="PATH",
                        help="Append-only per-packet metrics log (JSON Lines). "
                             "Unlike --report this accumulates across runs and "
                             "stamps each row with the run's config, so metrics "
                             "from many sessions can be analysed together. "
                             "Pass '' to disable. Inspect with: "
                             "python metrics_log.py <PATH>")
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
                             "lfm_bpsk_common.estimate_sample_ppm). Pass an explicit "
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

    # --sampling-rate: validate and update lfm_bpsk_params (which also
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

    print("=== EXTERNAL LOOPBACK IQ RX CONFIG (LFM+PRBS+BPSK) ===")
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
    print("  Payload mode       : A5 5A id ~id marker + PRNG data (see lfm_bpsk_frame.py)")
    print(f"  Marker score max   : {args.marker_score_max}")
    if args.no_ppm_correct:
        print("  Sample-clock ppm   : correction disabled")
    elif args.sample_ppm is not None:
        print(f"  Sample-clock ppm   : {args.sample_ppm:+.3f} ppm (fixed, --sample-ppm)")
    else:
        print("  Sample-clock ppm   : auto-estimate from LFM packet spacing")
    print(f"  Frame layout       : LFM({P.N_lfm}) + guard({P.N_guard}) + "
          f"RRC-shaped(train={P.N_train}+data={P.N_data} sym)")

    if not args.quiet_tx:
        pkt0 = TX.build_packet_waveform(0)
        frame_words = len(pkt0["packet"])
        print("\n=== RX EXPECTED STREAM ===")
        print(f"  Payload bits / frame    : {P.N_data}")
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
        # would just get wiped (matches rx_iq_sg_capture_frame_ids.py).
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
        sweep_taps=args.sweep_taps,
    )
    cont = check_frame_continuity(ana["results"], args.tx_frames)
    write_report_csv(args.report, ana["results"])

    # Append-only metrics log. Read-only with respect to decoding -- it
    # records what analyze_capture() already returned and feeds nothing
    # back. decim_factor/Fs are captured here rather than derived later
    # because --sampling-rate can change them per run.
    metrics_log.append(
        args.metrics_log,
        ana["results"],
        context=metrics_log.make_context(
            capture_file=args.raw_out,
            Fs=float(P.Fs),
            sps=int(P.sps),
            decim_factor=decim_factor,
            nco_hz=None if args.no_program_nco else args.nco,
            tx_frames=args.tx_frames,
            id_space=args.id_space,
            marker_score_max=args.marker_score_max,
            K_2=int(P.K_2),
            K_fb=int(P.K_fb),
            no_repass=int(P.no_repass),
            sweep_taps=args.sweep_taps,
            ppm_mode=("disabled" if args.no_ppm_correct
                      else "user" if args.sample_ppm is not None else "auto"),
            capture_sample_ppm=ana.get("sample_ppm"),
        ),
        verbose=not args.quiet_rx,
    )

    print("\n=== EXTERNAL LOOPBACK RX SUMMARY ===")
    print(f"  Raw file              : {args.raw_out}")
    print(f"  Report                : {args.report}")
    if args.metrics_log:
        print(f"  Metrics log           : {args.metrics_log} (append-only)")
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
