"""
lfm_bpsk_sweep_fine.py -- exhaustive NLMS-DFE equalizer parameter sweep
(K_2, K_fb, no_repass) for the FAU LFM+PRBS+BPSK port, run against a REAL
captured .bin file (e.g. lfm_iq_rx_capture_u32.bin, the file produced by
lfm_rx_iq_sg_capture_frame_ids.py / consumed by
lfm_bpsk_common.analyze_capture()).

Python counterpart of the uploaded lfmBpskPopotoRx330_nlms_sweepFine.m:
each (K_2, K_fb) combo in the grid is checked at TWO no_repass values with
UNSTABLE flagged whenever they disagree on error count -- same
stability-gating philosophy as every sweep in the Popoto project this is
ported from.

THIS IS THE LAB/REFERENCE SWEEP, NOT THE IN-RECEIVER ONE. It walks the
full grid (9 x 10 x 2 = 180 decodes by default) and scores on actual bit
errors against the known payload, which only works when the payload is
known -- i.e. offline, against a capture whose frame_ids you can
regenerate. For an on-board, reference-free search that costs a fraction
of this, see tap_sweep.py (sweep_taps/sweep_capture): it scores on
snr_eq_db instead of bit errors, places its grid using the measured
channel delay instead of walking blind, and was validated AGAINST this
script's exhaustive grid (see sweep_integration's report, Sec. 6-8) --
this script is the ground truth it was checked against, not a replacement
for it.

REVISION (2026-09-03): previously this script duplicated decode_packet()'s
Stages 3-9 inline (an "acquire once, sweep the equalizer" design, needed
because the production decode_packet() only ever read K_2/K_fb/no_repass
from lfm_bpsk_params). decode_packet() now accepts K_2/K_fb/no_repass as
per-call overrides directly (added alongside the Stage-5 CFO fix and the
in-receiver tap search -- see lfm_bpsk_rx.py's docstring), so this script
now just calls it once per grid point instead of maintaining a second,
increasingly out-of-sync copy of the equalizer. Two direct benefits: this
sweep is now automatically bit-identical to production decoding (nothing
to drift), and it picked up decode_packet()'s own Stage-7 vectorization
and training-pass caching for free, which measured faster than the old
duplicated Python loop here even with Stage 3-6 re-run per grid point.

HOW TO USE:
  1. python lfm_bpsk_sweep_fine.py --capture lfm_iq_rx_capture_u32.bin
     (defaults to the FIRST LFM packet detected in the file; point at a
     different one in the same capture with --packet-idx N)
  2. Edit --k2-list / --kfb-list / --no-repass-pair, or the DEFAULT_*
     constants below (copied straight from the uploaded MATLAB script's
     grid), to taste.
  3. Run. Each row printed is one (K_2, K_fb) combo; the summary table
     at the end is sorted best-BER-first (ties broken by higher post-DFE
     SNR), with a stability flag (OK / UNSTABLE) per row.
  4. Once you've picked a winner, set K_2/K_fb in lfm_bpsk_params.py.

CAVEAT (same as every sweep in the Popoto project this is ported from):
this runs against ONE packet from ONE capture. Treat the output as "this
REGION of (K_2, K_fb) is solid for this channel/range", and re-check the
winner against another capture at the same range/carrier before treating
it as a validated default -- not a substitute for it.
"""

import argparse

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_frame as F
import lfm_bpsk_tx as TX
import lfm_bpsk_rx as RX
from lfm_bpsk_common import identify_frame_id, estimate_sample_ppm

# Straight from the uploaded lfmBpskPopotoRx330_nlms_sweepFine.m's own
# grid -- it brackets this port's own K_2=48/K_fb=20 default (see
# lfm_bpsk_params.py) the same way that MATLAB grid bracketed its
# placeholder K_2=48/K_fb=24. Also the grid tap_sweep.py's own
# DEFAULT_K2_LIST/DEFAULT_KFB_LIST were set to, so a full-grid run here is
# directly comparable to a tap_sweep.sweep_full() run.
DEFAULT_K2_LIST = [32, 40, 48, 56, 64, 72, 80, 88, 96]
DEFAULT_KFB_LIST = [16, 20, 24, 28, 32, 36, 40, 44, 48, 52]
DEFAULT_NO_REPASS_PAIR = (3, 5)


def _load_capture(path: str) -> np.ndarray:
    from dma_rx_sg_16m import unpack_q15
    words = np.fromfile(path, dtype=np.uint32)
    re, im = unpack_q15(words)
    rx_raw = re + 1j * im  # BPSK is real-valued and self-conjugate -- no
                           # I/Q sign-convention ambiguity to worry about
                           # here, unlike the QPSK port's history.
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    rx_raw = np.concatenate([rx_raw, np.zeros(pad, dtype=rx_raw.dtype)])
    return rx_raw


def sweep_fine(capture_path: str, k2_list=None, kfb_list=None,
               no_repass_pair=DEFAULT_NO_REPASS_PAIR, packet_idx: int = 0,
               sample_ppm: float = None, marker_score_max: int = 8,
               plot_out: str = None) -> dict:
    k2_list = list(k2_list) if k2_list else list(DEFAULT_K2_LIST)
    kfb_list = list(kfb_list) if kfb_list else list(DEFAULT_KFB_LIST)

    rx_raw = _load_capture(capture_path)
    lfm_starts = RX.detect_lfm_packets(rx_raw)
    print(f"Detected {len(lfm_starts)} LFM packet(s) in capture ({len(rx_raw)} samples)")
    if packet_idx >= len(lfm_starts):
        raise SystemExit(f"--packet-idx {packet_idx} out of range (only "
                          f"{len(lfm_starts)} packet(s) detected)")
    lfm_start = lfm_starts[packet_idx]
    print(f"Sweeping packet {packet_idx}: lfm_start={lfm_start}")

    if sample_ppm is None:
        frame_words_nominal = len(TX.build_packet_waveform(0)["packet"])
        sample_ppm, ppm_diag = estimate_sample_ppm(lfm_starts, frame_words_nominal)
        if ppm_diag.get("ok"):
            print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm "
                  f"(auto-estimated from {ppm_diag.get('n_gaps_used', 0)} gap(s))")
        else:
            print(f"[ppm] Sample-clock offset : +0.000 ppm (not estimated -- "
                  f"{ppm_diag.get('reason')})")
            sample_ppm = 0.0
    else:
        print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm (user-specified)")

    # One baseline decode at the params-file default, purely to print the
    # acquisition diagnostics up front (xcorr_peak/best_eye/CFO/agree) --
    # every grid point below re-runs its own Stages 3-6 internally via
    # decode_packet(), there is no shared "acquire once" state anymore
    # (see module docstring).
    baseline = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm)
    if not baseline.get("ok"):
        raise SystemExit(f"Acquisition FAILED at the default K_2/K_fb: "
                          f"{baseline.get('reason')}")
    print(f"Coarse xcorr peak = {baseline['xcorr_peak']:.4f} "
          f"{'(OK)' if baseline['xcorr_peak'] > 0.3 else '(LOW)'}   "
          f"best_eye={baseline['best_eye']:.4f}")
    print(f"CFO total={baseline['CFO_total']:+.3f}Hz  "
          f"direct_corr pre/post={baseline['direct_corr_pre']:.4f}/"
          f"{baseline['direct_corr_post']:.4f}  "
          f"agreement={baseline['agree']}/{P.N_train}")

    print(f"\n===== Starting fine sweep: {len(k2_list)} x {len(kfb_list)} = "
          f"{len(k2_list) * len(kfb_list)} combos, each checked at "
          f"no_repass={no_repass_pair[0]} and {no_repass_pair[1]} =====")

    rows = []
    best_score = np.inf
    best_row = None
    best_data_out = None

    for K_2 in k2_list:
        for K_fb in kfb_list:
            res_a = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm,
                                      K_2=K_2, K_fb=K_fb, no_repass=no_repass_pair[0])
            res_b = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm,
                                      K_2=K_2, K_fb=K_fb, no_repass=no_repass_pair[1])
            if not (res_a.get("ok") and res_b.get("ok")):
                reason = res_a.get("reason") or res_b.get("reason")
                print(f"K_2={K_2} K_fb={K_fb} FAILED: {reason}")
                continue

            n_err = {}
            for tag, res in (("a", res_a), ("b", res_b)):
                frame_id, marker_score = identify_frame_id(res["bits_hat"])
                readable = marker_score <= marker_score_max
                if readable:
                    ref_bits = F.data_bits(frame_id)
                    n_err[tag] = int(np.sum(res["bits_hat"] != ref_bits))
                else:
                    # Unreadable (marker didn't match any frame_id): treat
                    # as a full-error combo for sorting/stability purposes
                    # -- keeps unreadable combos below every readable one
                    # instead of silently dropping them.
                    n_err[tag] = P.N_data
                res["frame_id"] = frame_id if readable else None
                res["marker_score"] = marker_score
                res["readable"] = readable

            n_err_a, n_err_b = n_err["a"], n_err["b"]
            ber_a = n_err_a / P.N_data
            ber_b = n_err_b / P.N_data
            stable = (n_err_a == n_err_b)

            print(f"K_2={K_2:3d}  K_fb={K_fb:2d}  ->  "
                  f"BER@{no_repass_pair[0]}={ber_a:.5f} ({n_err_a})  "
                  f"BER@{no_repass_pair[1]}={ber_b:.5f} ({n_err_b})  "
                  f"train_BER={res_a['ber_train']:.5f}  SNR={res_a['snr_eq_db']:+.1f}dB  "
                  f"{'OK' if stable else 'UNSTABLE'}")

            row = dict(K_2=K_2, K_fb=K_fb, ber_a=ber_a, n_err_a=n_err_a,
                       ber_b=ber_b, n_err_b=n_err_b, stable=stable,
                       snr_eq_db=res_a["snr_eq_db"], train_ber=res_a["ber_train"])
            rows.append(row)

            worst_errors = max(n_err_a, n_err_b)
            score = worst_errors - 0.5 * stable - 1e-3 * res_a["snr_eq_db"]
            if score < best_score:
                best_score = score
                best_row = row
                best_data_out = res_a["data_out"]

    print("\n===== Fine sweep summary =====")
    print(f"{'K_2':>6} {'K_fb':>6} {'BER@' + str(no_repass_pair[0]):>10} "
          f"{'err@' + str(no_repass_pair[0]):>10} {'BER@' + str(no_repass_pair[1]):>10} "
          f"{'err@' + str(no_repass_pair[1]):>10} {'stable':>10} {'SNR(dB)':>10}")
    sorted_rows = sorted(rows, key=lambda r: (max(r["n_err_a"], r["n_err_b"]),
                                               0 if r["stable"] else 1,
                                               -r["snr_eq_db"]))
    for r in sorted_rows:
        print(f"{r['K_2']:6d} {r['K_fb']:6d} {r['ber_a']:10.5f} {r['n_err_a']:10d} "
              f"{r['ber_b']:10.5f} {r['n_err_b']:10d} "
              f"{'OK' if r['stable'] else 'UNSTABLE':>10} {r['snr_eq_db']:10.1f}")

    if best_row is not None:
        print(f"\nBest config: K_2={best_row['K_2']}  K_fb={best_row['K_fb']}  ->  "
              f"BER@{no_repass_pair[0]}={best_row['ber_a']:.5f} ({best_row['n_err_a']})  "
              f"BER@{no_repass_pair[1]}={best_row['ber_b']:.5f} ({best_row['n_err_b']})  "
              f"{'OK' if best_row['stable'] else 'UNSTABLE'}  SNR={best_row['snr_eq_db']:+.1f}dB")
        print("Set K_2/K_fb in lfm_bpsk_params.py to this winner for the full pipeline.")
        print("Remember: re-check this winner against another capture at this "
              "range/carrier before treating it as a validated default. For a "
              "cheap in-receiver version of this same search, see tap_sweep.py.")

        if plot_out:
            import matplotlib
            matplotlib.use("Agg")
            import matplotlib.pyplot as plt
            plt.figure(figsize=(5, 5))
            plt.plot(best_data_out.real, best_data_out.imag, '.')
            plt.title(f"Best config constellation: K_2={best_row['K_2']} "
                      f"K_fb={best_row['K_fb']} (no_repass={no_repass_pair[0]}), "
                      f"BER={best_row['ber_a']:.5f} ({best_row['n_err_a']} errors)")
            plt.xlabel("I"); plt.ylabel("Q")
            plt.axis("equal"); plt.grid(True)
            plt.savefig(plot_out, dpi=150, bbox_inches="tight")
            plt.close()
            print(f"Constellation plot saved to {plot_out}")
    else:
        print("\nNo config completed successfully -- check --k2-list / DEC_DELAY_MAX.")

    return dict(rows=rows, best_row=best_row, baseline=baseline)


def _parse_int_list(s: str):
    return [int(x) for x in s.split(",") if x.strip()]


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--capture", required=True, help="Path to lfm_iq_rx_capture_u32*.bin")
    ap.add_argument("--packet-idx", type=int, default=0,
                     help="Which detected LFM packet in the capture to sweep on (default 0)")
    ap.add_argument("--sample-ppm", type=float, default=None,
                     help="Override the auto-estimated sample-clock ppm")
    ap.add_argument("--k2-list", type=_parse_int_list, default=None,
                     help=f"Comma-separated K_2 grid (default {DEFAULT_K2_LIST})")
    ap.add_argument("--kfb-list", type=_parse_int_list, default=None,
                     help=f"Comma-separated K_fb grid (default {DEFAULT_KFB_LIST})")
    ap.add_argument("--no-repass-pair", type=_parse_int_list, default=None,
                     help=f"Two no_repass values to check for stability (default {list(DEFAULT_NO_REPASS_PAIR)})")
    ap.add_argument("--marker-score-max", type=int, default=8,
                     help="Max Hamming distance to accept a frame_id match as readable (default 8)")
    ap.add_argument("--plot", metavar="PNG_PATH", default=None,
                     help="Save the best config's data constellation to this PNG path")
    args = ap.parse_args()

    no_repass_pair = tuple(args.no_repass_pair) if args.no_repass_pair else DEFAULT_NO_REPASS_PAIR
    if len(no_repass_pair) != 2:
        raise SystemExit("--no-repass-pair needs exactly two values")

    sweep_fine(args.capture, k2_list=args.k2_list, kfb_list=args.kfb_list,
               no_repass_pair=no_repass_pair, packet_idx=args.packet_idx,
               sample_ppm=args.sample_ppm, marker_score_max=args.marker_score_max,
               plot_out=args.plot)


if __name__ == "__main__":
    main()
