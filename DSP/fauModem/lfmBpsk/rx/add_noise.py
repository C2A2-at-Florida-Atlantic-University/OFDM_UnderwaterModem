"""
add_noise.py -- write a copy of a real capture with calibrated AWGN added,
so the per-packet metrics can be validated across an SNR range the link
itself never produces.

Why this and not a transmit-level sweep
---------------------------------------
Nothing on the RX changes SNR: signal and noise arrive at the hydrophone
already mixed, so the VGA scales both equally. Measured on hardware
2026-09-02 -- 30 dB of VGA change moved best_eye by -26.6 dB and pdsnr_db
by 1 dB, non-monotonically. A transmit-level sweep does change SNR, but
needs a TX restart per point and gives only approximate control.

Adding noise to a stored capture gives EXACT known SNR at every point,
sweeps past the failure point, costs no board time, and is repeatable.
What it does NOT do is exercise the real analog chain at low signal
level -- so use it to calibrate metric thresholds, then confirm the
thresholds on a real TX-level sweep.

SNR convention
--------------
`--snr` is the SNR of the OUTPUT capture, in dB, measured in the captured
band. The input capture already contains channel noise, so the noise
added is only what is needed to reach the target:

    N_add = S/snr_target - N_already_present

If the target is at or above the capture's existing SNR the run refuses
rather than silently doing nothing -- you cannot add negative noise.

The existing SNR is estimated from the guard interval between packets:
that stretch carries no transmitted signal, so its power IS the noise
floor. Signal power is taken from the LFM+payload span. Both are measured
per packet and pooled.

Usage
-----
    python add_noise.py lfm_iq_rx_capture_u32.bin --snr 12
    python add_noise.py lfm_iq_rx_capture_u32.bin --snr 12 --out cap_snr12.bin
    python add_noise.py lfm_iq_rx_capture_u32.bin --measure-only

Then feed the result straight to the analyser:

    sudo python -u lfm_rx_iq_sg_capture_frame_ids.py --tx-frames 6 \
        --analyze-only cap_snr12.bin --raw-out cap_snr12.bin
"""

import argparse
import os

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_rx as RX
from dma_rx_sg_16m import unpack_q15

Q15 = 32767.0


def pack_q15(re: np.ndarray, im: np.ndarray):
    """Inverse of unpack_q15. Returns (words, n_clipped)."""
    ri = np.rint(re * Q15)
    ii = np.rint(im * Q15)
    n_clip = int(np.sum((np.abs(ri) > Q15) | (np.abs(ii) > Q15)))
    ri = np.clip(ri, -32768, 32767).astype(np.int16)
    ii = np.clip(ii, -32768, 32767).astype(np.int16)
    words = (ri.astype(np.uint16).astype(np.uint32)
             | (ii.astype(np.uint16).astype(np.uint32) << 16))
    return words, n_clip


def measure(rx: np.ndarray, starts):
    """Pooled signal power (LFM+payload) and noise power (guard interval).

    The guard is N_guard samples of silence between the LFM chirp and the
    BPSK payload, so its power is the noise floor -- no transmitted
    signal is present there. Trim both ends of the guard to keep the
    chirp's and payload's filter tails out of the measurement.
    """
    trim = P.span * P.sps          # 192 samples, the RRC tail length
    sig_sq = sig_n = noi_sq = noi_n = 0.0
    used = 0
    for s in starts:
        g0, g1 = s + P.N_lfm + trim, s + P.N_lfm + P.N_guard - trim
        p0, p1 = s + P.N_lfm + P.N_guard, s + P.N_lfm + P.N_guard + P.N_syms_total * P.sps
        if g1 <= g0 or p1 > len(rx):
            continue
        g, p = rx[g0:g1], rx[p0:p1]
        noi_sq += float(np.sum(np.abs(g) ** 2)); noi_n += len(g)
        sig_sq += float(np.sum(np.abs(p) ** 2)); sig_n += len(p)
        used += 1
    if not used:
        raise SystemExit("no complete packet found to measure from")
    n_pwr = noi_sq / noi_n
    tot_pwr = sig_sq / sig_n           # signal + noise
    s_pwr = max(tot_pwr - n_pwr, 1e-30)
    return s_pwr, n_pwr, used


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("capture")
    ap.add_argument("--snr", type=float, default=None, metavar="DB",
                    help="target SNR of the output capture, in dB")
    ap.add_argument("--out", default=None,
                    help="output .bin (default cap_snr<SNR>.bin next to the input)")
    ap.add_argument("--measure-only", action="store_true",
                    help="report the capture's existing SNR and exit")
    ap.add_argument("--seed", type=int, default=0,
                    help="AWGN seed, so a run is reproducible (default 0)")
    args = ap.parse_args()

    words = np.fromfile(args.capture, dtype=np.uint32)
    re, im = unpack_q15(words)
    rx = re + 1j * im
    del words, re, im

    starts = RX.detect_lfm_packets(rx)
    s_pwr, n_pwr, used = measure(rx, starts)
    snr_in = 10 * np.log10(s_pwr / n_pwr)

    print(f"input      : {args.capture}  ({len(rx)} samples)")
    print(f"packets    : {len(starts)} detected, {used} used for the measurement")
    print(f"signal pwr : {s_pwr:.6e}   (payload span, noise removed)")
    print(f"noise pwr  : {n_pwr:.6e}   (guard interval)")
    print(f"SNR in     : {snr_in:.2f} dB")

    if args.measure_only or args.snr is None:
        if args.snr is None and not args.measure_only:
            print("\n(no --snr given; nothing written)")
        return 0

    target = 10 ** (args.snr / 10)
    n_needed = s_pwr / target
    n_add = n_needed - n_pwr
    if n_add <= 0:
        raise SystemExit(
            f"\ncannot reach {args.snr:.2f} dB: the capture is already at "
            f"{snr_in:.2f} dB and noise cannot be subtracted. "
            f"Pick a target below {snr_in:.2f} dB.")

    rng = np.random.default_rng(args.seed)
    sigma = np.sqrt(n_add / 2.0)       # per component, so total power = n_add
    rx = rx + sigma * (rng.standard_normal(len(rx))
                       + 1j * rng.standard_normal(len(rx)))

    out = args.out or os.path.join(
        os.path.dirname(os.path.abspath(args.capture)),
        f"cap_snr{args.snr:g}.bin")
    w, n_clip = pack_q15(rx.real, rx.imag)
    w.tofile(out)

    print(f"\nnoise added: {10*np.log10(n_add/n_pwr):+.2f} dB relative to the "
          f"existing floor")
    print(f"SNR out    : {10*np.log10(s_pwr/n_needed):.2f} dB (target {args.snr:.2f})")
    if n_clip:
        print(f"WARNING    : {n_clip} sample(s) clipped at q15 full scale "
              f"({100*n_clip/len(rx):.4f}%) -- the added noise pushed them "
              f"past +/-1. Results below this SNR will be distorted, not "
              f"just noisy.")
    print(f"wrote      : {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
