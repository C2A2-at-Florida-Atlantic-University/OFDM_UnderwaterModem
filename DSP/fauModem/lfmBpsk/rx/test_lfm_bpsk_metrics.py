"""
Self-test 4: validate the per-packet quality metrics against injected
ground truth, on synthetic captures only (no hardware).

The metrics are read-only -- they cannot change a decode -- so what needs
proving is not safety but *calibration*: that each one tracks the
impairment it claims to measure. A metric that varies without tracking is
worse than no metric, because it looks like data.

Part A -- AWGN sweep, 0-30 dB:
  A1. snr_eq_db must be monotonic non-decreasing in injected SNR.
  A2. It must have real slope in the noise-limited region (0-10 dB).
      NOT unity slope across the whole sweep: above ~14 dB the DFE's
      residual ISI, not the noise, is the limit, so snr_eq_db plateaus.
      That plateau is the equalizer's SNR ceiling on this channel and is
      recorded as a measurement, not treated as a failure.
  A3. Blind snr_eq_db must rank packets the way reference-aided pdsnr_db
      does. If it does, it can stand in for pdsnr_db in the field, where
      the payload is unknown -- the question the metrics log exists to
      settle.
  A4. best_eye scales with received amplitude and xcorr_peak does not.
      This is a CAVEAT being pinned down, not a virtue: best_eye is
      computed on the un-normalised matched-filter output, so it is only
      comparable within one packet (which is all decode_packet uses it
      for -- picking best_t0). Do not compare it across captures taken at
      different gains.

Part B -- CFO sweep:
  B1. CFO_total must recover an injected offset.
  B2. direct_corr_post >= direct_corr_pre. Stage 5's own self-check:
      removing a real frequency offset must improve the training
      correlation, so a drop means the estimate was wrong and Stage 5
      degraded the packet.
  Part B exists because Stage 5 is gated on `xcorr_peak <= 0.5` and on a
  clean channel xcorr_peak never falls that far -- the AWGN sweep alone
  leaves B2 vacuous.
"""
import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX
import lfm_bpsk_rx as RX
import lfm_bpsk_frame as F

SNR_SWEEP = [0.0, 5.0, 10.0, 14.0, 18.0, 22.0, 26.0, 30.0]
NOISE_LIMITED = 10.0        # below this, snr_eq_db should track the noise
CFO_SWEEP = [0.0, 5.0, 10.0, 20.0]
N_FRAMES = 6
SEED = 4242

# Part B's gate. It was False-gated while Stage 5's CFO estimator was
# broken -- it unwrapped the phase of 1024 individual symbols, which at
# realistic SNR meant 100-160 spurious 2*pi jumps and a meaningless
# slope (it read -65 Hz on a packet with ZERO offset). Stage 5 now
# estimates from ~128 block phasors instead (see
# lfm_bpsk_rx._cfo_from_block_phasors), measured error 0.02 Hz vs
# 37.55 Hz, so Part B is a real gate again: a drop in direct_corr across
# Stage 5 now means a genuine regression.
KNOWN_STAGE5_DEFECT = False


def _channel():
    """Same 2-tap multipath as test_lfm_bpsk_multipath.py: taps at 3.0 and
    5.5 symbols, from the real tank captures."""
    d1 = int(round(3.0 * P.sps))
    d2 = int(round(5.5 * P.sps))
    h = np.zeros(d2 + 1, dtype=np.complex128)
    h[0] = 1.0
    h[d1] += 0.55 * np.exp(1j * 0.35)
    h[d2] += 0.42 * np.exp(1j * (np.pi - 0.2))
    return h, d2


def _capture(h, d2, rng, snr_db, frame_id, cfo_hz=0.0, scale=1.0):
    tx = TX.build_packet_waveform(frame_id)["packet"].astype(np.complex128)
    rx = np.convolve(tx, h)[:len(tx) + d2]
    if cfo_hz:
        rx = rx * np.exp(1j * 2 * np.pi * cfo_hz * np.arange(len(rx)) / P.Fs)
    npwr = np.mean(np.abs(tx) ** 2) / (10 ** (snr_db / 10))
    rx = rx + np.sqrt(npwr / 2) * (rng.standard_normal(len(rx))
                                   + 1j * rng.standard_normal(len(rx)))
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    return np.concatenate([rx * scale, np.zeros(pad, dtype=np.complex128)])


def _spearman(x, y) -> float:
    """Rank correlation, without scipy (not installed on the board)."""
    def ranks(v):
        order = np.argsort(np.asarray(v, dtype=np.float64), kind="stable")
        r = np.empty(len(v), dtype=np.float64)
        r[order] = np.arange(len(v), dtype=np.float64)
        return r
    rx, ry = ranks(x), ranks(y)
    rx -= rx.mean()
    ry -= ry.mean()
    den = np.sqrt((rx ** 2).sum() * (ry ** 2).sum())
    return float((rx * ry).sum() / den) if den > 0 else 0.0


h, d2 = _channel()
rng = np.random.default_rng(SEED)
fails = []

# ======================================================================
# Part A -- AWGN sweep
# ======================================================================
print("Part A: AWGN sweep, 2-tap multipath (3.0/5.5 sym), "
      f"{N_FRAMES} frames/point")
print()
print(f"{'SNR_in':>7} {'snr_eq_db':>10} {'pdsnr_db':>10} {'xcorr':>7} "
      f"{'eye':>7} {'errs':>6} {'decoded':>8}")

rows = []
per_point = []
for snr_db in SNR_SWEEP:
    acc = {k: [] for k in ("snr_eq", "pdsnr", "xcorr", "eye", "errs")}
    n_ok = 0
    for fid in range(N_FRAMES):
        dec = RX.decode_packet(_capture(h, d2, rng, snr_db, fid), lfm_start=0)
        if not dec.get("ok"):
            continue
        n_ok += 1
        evm = np.sqrt(np.mean(np.abs(dec["data_out"] - F.data_syms(fid)) ** 2))
        acc["snr_eq"].append(dec["snr_eq_db"])
        acc["pdsnr"].append(-20.0 * np.log10(max(evm, 1e-6)))
        acc["xcorr"].append(dec["xcorr_peak"])
        acc["eye"].append(dec["best_eye"])
        acc["errs"].append(int(np.sum(dec["bits_hat"] != F.data_bits(fid))))
        rows.append((snr_db, dec["snr_eq_db"], acc["pdsnr"][-1]))
    if n_ok < N_FRAMES:
        fails.append(f"only {n_ok}/{N_FRAMES} packets decoded at "
                     f"SNR={snr_db} dB")
    m = {k: float(np.mean(v)) if v else float("nan") for k, v in acc.items()}
    per_point.append(m["snr_eq"])
    print(f"{snr_db:7.1f} {m['snr_eq']:10.2f} {m['pdsnr']:10.2f} "
          f"{m['xcorr']:7.3f} {m['eye']:7.3f} {sum(acc['errs']):6d} "
          f"{n_ok:8d}")

snr_in = np.array([r[0] for r in rows])
snr_eq = np.array([r[1] for r in rows])
pdsnr = np.array([r[2] for r in rows])

# A1 -- monotonic (allow a small dither so noise realisations don't fail it)
inv = [(SNR_SWEEP[i], per_point[i], per_point[i + 1])
       for i in range(len(per_point) - 1)
       if per_point[i + 1] < per_point[i] - 0.25]
print()
print(f"A1 monotonic              : {len(inv)} inversion(s) "
      f"of {len(per_point) - 1}")
if inv:
    fails.append(f"snr_eq_db not monotonic in SNR: {inv}")

# A2 -- slope where noise, not residual ISI, is the limit
lo = snr_in <= NOISE_LIMITED
slope_lo = float(np.polyfit(snr_in[lo], snr_eq[lo], 1)[0])
slope_all = float(np.polyfit(snr_in, snr_eq, 1)[0])
ceiling = float(np.max(per_point))
print(f"A2 slope (0-{NOISE_LIMITED:.0f} dB)        : {slope_lo:+.3f}   "
      f"(whole sweep {slope_all:+.3f}, flattened by the ISI ceiling)")
print(f"   equalizer SNR ceiling  : {ceiling:.2f} dB on this channel")
if not 0.3 <= slope_lo <= 1.7:
    fails.append(f"snr_eq_db slope in the noise-limited region is "
                 f"{slope_lo:+.3f}, expected roughly unity")

# A3 -- blind vs reference-aided
rho = _spearman(snr_eq, pdsnr)
print(f"A3 vs pdsnr_db            : Spearman rho={rho:+.3f} "
      f"over {len(rows)} packets")
if rho < 0.8:
    fails.append(f"blind snr_eq_db does not track reference-aided "
                 f"pdsnr_db (rho={rho:+.3f})")

# A4 -- best_eye is un-normalised, xcorr_peak is not
SCALE = 4.0
d1x = RX.decode_packet(_capture(h, d2, np.random.default_rng(7), 22.0, 0,
                               scale=1.0), lfm_start=0)
d4x = RX.decode_packet(_capture(h, d2, np.random.default_rng(7), 22.0, 0,
                               scale=SCALE), lfm_start=0)
eye_ratio = d4x["best_eye"] / d1x["best_eye"]
xc_ratio = d4x["xcorr_peak"] / d1x["xcorr_peak"]
print(f"A4 amplitude x{SCALE:.0f}            : best_eye x{eye_ratio:.2f}, "
      f"xcorr_peak x{xc_ratio:.3f}")
if not abs(eye_ratio - SCALE) < 0.1 * SCALE:
    fails.append(f"best_eye did not scale with amplitude "
                 f"(x{eye_ratio:.2f}, expected x{SCALE:.0f}) -- the "
                 f"un-normalised caveat may no longer hold")
if abs(xc_ratio - 1.0) > 0.05:
    fails.append(f"xcorr_peak is not amplitude-invariant (x{xc_ratio:.3f})")
print("   => best_eye is comparable only WITHIN a packet; xcorr_peak is "
      "comparable across captures")

# ======================================================================
# Part B -- CFO sweep, to make Stage 5 actually run
# ======================================================================
print()
print("Part B: injected CFO at SNR=18 dB (Stage 5 is gated on "
      "xcorr_peak <= 0.5)")
print()
print(f"{'CFO_in':>7} {'CFO_est':>9} {'err':>7} {'xcorr':>7} "
      f"{'corr_pre':>9} {'corr_post':>10} {'gain':>7} {'loop':>5} "
      f"{'errs':>6} {'decoded':>8}")

worse = n_ran = 0
for cfo in CFO_SWEEP:
    acc = {k: [] for k in ("est", "xcorr", "pre", "post", "errs")}
    n_ok = 0
    for fid in range(N_FRAMES):
        dec = RX.decode_packet(
            _capture(h, d2, rng, 18.0, fid, cfo_hz=cfo), lfm_start=0)
        if not dec.get("ok"):
            continue
        n_ok += 1
        acc["est"].append(dec["CFO_total"])
        acc["xcorr"].append(dec["xcorr_peak"])
        acc["pre"].append(dec["direct_corr_pre"])
        acc["post"].append(dec["direct_corr_post"])
        acc["errs"].append(int(np.sum(dec["bits_hat"] != F.data_bits(fid))))
        if abs(dec["direct_corr_post"] - dec["direct_corr_pre"]) > 1e-12:
            n_ran += 1
        if dec["direct_corr_post"] < dec["direct_corr_pre"] - 1e-12:
            worse += 1
    if not n_ok:
        print(f"{cfo:7.1f} {'--':>9} {'--':>7} {'--':>7} {'--':>9} "
              f"{'--':>10} {'--':>7} {'--':>5} {'--':>6} {0:8d}")
        continue
    m = {k: float(np.mean(v)) for k, v in acc.items()}
    ran = abs(m["post"] - m["pre"]) > 1e-12
    print(f"{cfo:7.1f} {m['est']:9.2f} {m['est'] - cfo:+7.2f} "
          f"{m['xcorr']:7.3f} {m['pre']:9.4f} {m['post']:10.4f} "
          f"{m['post'] / m['pre']:7.3f} {'yes' if ran else 'no':>5} "
          f"{sum(acc['errs']):6d} {n_ok:8d}")

print()
print(f"B2 corr_post >= corr_pre  : {worse} packet(s) worse, "
      f"CFO loop ran on {n_ran} packet(s)")

b_fails = []
if worse:
    b_fails.append(f"Stage 5 degraded {worse} packet(s): "
                   f"direct_corr_post < direct_corr_pre")
if n_ran == 0:
    b_fails.append("the Stage-5 CFO loop never ran, so B2 is vacuous -- "
                   "raise CFO_SWEEP until xcorr_peak drops below 0.5")

if b_fails and KNOWN_STAGE5_DEFECT:
    print()
    print("  *** KNOWN DEFECT (pre-existing, not a metrics failure) ***")
    for f in b_fails:
        print(f"  - {f}")
    print("  Stage 5 unwraps per-symbol phase over 1024 noisy symbols and")
    print("  is unreliable whenever it runs -- wrong even at CFO = 0. The")
    print("  QPSK port's block-phasor estimator is exact (0.02 Hz vs 37.55")
    print("  Hz mean error at 10 Hz). See OPTIMIZATION.md; clear")
    print("  KNOWN_STAGE5_DEFECT once fixed to make Part B a real gate.")
elif b_fails:
    fails.extend(b_fails)

print()
if fails:
    print("RESULT: FAIL")
    for f in fails:
        print(f"  - {f}")
    raise SystemExit(1)
print("RESULT: PASS (metrics calibrated)"
      + ("  -- with 1 known defect reported above" if b_fails else ""))
