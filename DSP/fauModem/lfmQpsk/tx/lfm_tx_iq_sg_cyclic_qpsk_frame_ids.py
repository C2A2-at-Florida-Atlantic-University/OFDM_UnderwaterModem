"""
External-loopback TX script for SG-enabled MM2S cyclic transmit --
LFM + PRBS + QPSK / NLMS-DFE frame format. Sibling to
lfm_tx_iq_sg_cyclic_frame_ids.py -- identical hardware-driver call
pattern, swapped to the QPSK packet builder.

The one real hardware difference vs the BPSK script: BPSK's waveform is
real (Q=0 on the DAC), so pack_for_dma() there zeroes the imaginary
channel. QPSK's waveform is genuinely complex, so BOTH DAC channels
carry signal here -- lfm_qpsk_tx.pack_for_dma() packs I=real(waveform),
Q=imag(waveform), and the hardware NCO (bpsk_dma.set_nco_frequency())
does a proper complex upconversion to Fc, same as before.
"""

import argparse
from collections import Counter

import lfm_qpsk_params as P
from bpsk_dma import select_dma_source, set_nco_frequency, set_cic_interpolation
from dma_tx_sg_16m import MM2S_BUF_SIZE, start_cyclic_mm2s
import lfm_qpsk_tx as TX


def print_packet_verify(meta, frame_words, packet_frames, id_cycle):
    ids = meta["frame_ids"]
    counts = Counter(ids)
    expected = [i % id_cycle for i in range(packet_frames)]
    if ids != expected:
        raise RuntimeError("TX software verify failed: frame ID sequence mismatch")

    print("\n=== TX SOFTWARE VERIFY ===")
    print("  Frame ID sequence       : PASS")
    print("  Frame ID counts         : " +
          ", ".join(f"{fid}:{counts[fid]}" for fid in sorted(counts)))
    print(f"  Packet CRC32            : 0x{meta['packet_crc32']:08X}")
    print("  First 8 words           : " +
          " ".join(f"{w:08X}" for w in meta["first_words"]))
    print("  Last 8 words            : " +
          " ".join(f"{w:08X}" for w in meta["last_words"]))

    shown = min(packet_frames, 24)
    print(f"  Per-frame CRC32         : first {shown}/{packet_frames}")
    for i in range(shown):
        print(f"    frame {i:03d} id={ids[i]:03d} "
              f"word={i * frame_words:08d} "
              f"crc=0x{meta['frame_crc32'][i]:08X}")
    if shown < packet_frames:
        print(f"    ... {packet_frames - shown} more frame CRCs omitted")


def main():
    parser = argparse.ArgumentParser(
        description="Cyclic SG MM2S TX packet, LFM+PRBS+QPSK frame-ID payloads")
    parser.add_argument("--tx-frames", type=int, default=6,
                        help="Number of frame IDs in the repeated payload pattern")
    parser.add_argument("--packet-frames", type=int, default=36,
                        help="Number of physical LFM+QPSK frames in the cyclic DMA packet")
    parser.add_argument("--quiet-tx", action="store_true",
                        help="Suppress detailed TX print")
    parser.add_argument("--no-select-dma-source", action="store_true",
                        help="Do not write the optional DMA/DDS source mux GPIO")
    parser.add_argument("--nco", type=float, default=120000.0, metavar="FREQ_HZ",
                        help="Update the DDS Compiler NCO output frequency (Hz) "
                             "via the phase-increment GPIOs. Default: 120000 Hz. "
                             "Use --no-program-nco to leave the current DDS setting untouched.")
    parser.add_argument("--no-program-nco", action="store_true",
                        help="Leave DDS/NCO frequency unchanged instead of programming --nco")
    parser.add_argument("--dry-run", action="store_true",
                        help="Build and size the TX packet, but do not start DMA")
    parser.add_argument("--no-software-verify", action="store_true",
                        help="Skip TX packet software verification prints")
    parser.add_argument("--exit-after-start", action="store_true",
                        help="Program cyclic DMA once, leave it running, and exit")
    parser.add_argument("--sampling-rate", type=int, default=None, metavar="FS_HZ",
                        help="Baseband TX sample rate in Hz (e.g. 500000). "
                             "Must divide 10 000 000 evenly. Default: 400 000. "
                             "Programs the CIC interpolation factor automatically.")
    parser.add_argument("--tx-scale", type=float, default=1.0, metavar="SCALE",
                        help="Linear scale applied to each packet's peak-"
                             "normalised waveform before Q15 packing. Default "
                             "1.0 already puts the peak at full-scale Q15, so "
                             ">1 trades deliberate clipping for RMS; <1 backs "
                             "the DAC drive off.")
    args = parser.parse_args()

    if args.tx_frames <= 0:
        parser.error("--tx-frames must be > 0")
    if args.packet_frames <= 0:
        parser.error("--packet-frames must be > 0")
    if not args.no_program_nco and args.nco is not None and args.nco < 0:
        parser.error("--nco frequency must be >= 0 Hz")
    if args.tx_scale <= 0.0:
        parser.error("--tx-scale must be > 0")

    _CIC_OUT = 10_000_000
    Fs_hz = int(args.sampling_rate) if args.sampling_rate is not None else int(P.Fs)
    if _CIC_OUT % Fs_hz != 0:
        parser.error(
            f"--sampling-rate {Fs_hz} does not divide {_CIC_OUT} evenly. "
            f"Valid examples: 2500000, 2000000, 1250000, 1000000, "
            f"500000, 400000, 250000, 200000.")
    interp_factor = _CIC_OUT // Fs_hz
    if not (4 <= interp_factor <= 65535):
        parser.error(
            f"--sampling-rate {Fs_hz} gives interpolation factor "
            f"{interp_factor}, which is outside the CIC valid range [4, 65535].")
    if Fs_hz != int(P.Fs):
        P.reconfigure_fs(Fs_hz)

    print("=== EXTERNAL LOOPBACK IQ TX CONFIG (LFM+PRBS+QPSK) ===")
    print("  TX mode          : MM2S scatter-gather cyclic IQ DAC")
    print(f"  TX frame IDs     : 0..{args.tx_frames - 1}, repeated")
    print(f"  Packet frames    : {args.packet_frames}")
    print(f"  Reserved TX mem  : {MM2S_BUF_SIZE} B")
    print("  TX IQ mapping    : I=real(LFM+QPSK), Q=imag(LFM+QPSK)  [complex, unlike the BPSK port]")
    print(f"  TX scale         : {args.tx_scale:g}"
          f"{' (on top of the QPSK section RMS-match, see below)' if args.tx_scale == 1.0 else ''}")
    print(f"  Sample rate      : {P.Fs/1e3:.1f} kSPS  "
          f"(sps={P.sps}, interp_factor={interp_factor})")
    print(f"  Frame layout     : LFM({P.N_lfm}) + guard({P.N_guard}) + "
          f"RRC-shaped(train={P.N_train}+data={P.N_data} sym, "
          f"{P.bps_sym} bits/sym -> {P.N_data_bits} payload bits)")
    print(f"  Payload mode     : A5 5A id ~id marker + PRNG data (see lfm_qpsk_frame.py)")

    tx_words, frame_words, frame_bits, meta = TX.build_cyclic_tx_packet(
        n_frames=args.packet_frames,
        id_cycle=args.tx_frames,
        tx_scale=args.tx_scale,
        quiet_tx=args.quiet_tx,
        return_metadata=True,
    )
    tx_bytes = len(tx_words) * 4
    if tx_bytes > MM2S_BUF_SIZE:
        raise ValueError(
            f"TX packet is {tx_bytes} B, but reserved TX buffer is {MM2S_BUF_SIZE} B")

    print("\n=== TX PACKET ===")
    print(f"  Payload bits / frame    : {frame_bits}")
    print(f"  Words / physical frame  : {frame_words}")
    print(f"  Frame ID cycle          : {args.tx_frames}")
    print(f"  Physical frames/packet  : {args.packet_frames}")
    print(f"  TX packet words         : {len(tx_words)}")
    print(f"  TX packet bytes         : {tx_bytes}")
    print(f"  TX packet duration      : {len(tx_words) / P.Fs:.3f} s")
    print(f"  Reserved headroom       : {MM2S_BUF_SIZE - tx_bytes} B")
    print(f"  TX scale                : {meta['tx_scale']:g}")
    print(f"  Clipped samples         : {meta['clipped_frac'] * 100:.2f} %")

    if not args.no_software_verify:
        print_packet_verify(meta, frame_words, args.packet_frames, args.tx_frames)

    if args.dry_run:
        print("\n[dma] Dry run only; DMA not started")
        return

    if not args.no_program_nco and args.nco is not None:
        print("\n=== UPDATE NCO FREQUENCY ===")
        set_nco_frequency(args.nco)

    print("\n=== UPDATE CIC INTERPOLATION ===")
    set_cic_interpolation(Fs_hz)

    if not args.no_select_dma_source:
        try:
            select_dma_source()
            print("[mux] DMA source selected")
        except Exception as exc:
            print(f"[mux] WARNING: could not select DMA source: {exc}")

    print("\n=== START CYCLIC TX ===")
    start_cyclic_mm2s(
        tx_words,
        monitor=not args.exit_after_start,
        reset_on_exit=not args.exit_after_start,
        frame_words=frame_words,
    )


if __name__ == "__main__":
    main()
