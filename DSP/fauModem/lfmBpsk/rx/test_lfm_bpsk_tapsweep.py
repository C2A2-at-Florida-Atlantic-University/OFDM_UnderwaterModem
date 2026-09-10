"""
Self-test 6: tap_sweep.py must find the full grid's winner, on compact
AND sparse channels, for far fewer decodes.

The sparse case is the one that matters. Coarse-then-fine assumes a
smooth single-peaked surface; a channel with a distant isolated echo has
a cliff instead (nothing below K_fb = echo delay helps at all), and a
blind coarse pass can straddle it and see only the floor. The point of
measuring the last arrival and flooring K_fb from it is to make that
impossible, so this test checks the sparse channel specifically.

Checks:
  1. Per channel, sweep_taps() scores within TOL_DB of the exhaustive
     grid's best, using far fewer runs.
  2. On the sparse channel, the K_fb floor must actually exclude the
     dead region -- if it does not, the guard is not doing its job even
     if the answer happens to come out right.
  3. decode_packet's K_2/K_fb overrides must not leak: the module-level
     P.K_2/P.K_fb are unchanged after a sweep.
"""
import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX
import lfm_bpsk_frame as F
import tap_sweep

TOL_DB = 0.10          # ~2x the 0.056 dB packet-to-packet spread on hardware
SNR_WIDE = 7.8         # gives ~20.8 dB pdsnr, matching the measured tank


def chan(kind):
    if kind == "single":
        return np.array([1.0 + 0j])
    if kind == "compact":                     # tank-like, echoes close in
        d1, d2 = int(round(3.0 * P.sps)), int(round(5.5 * P.sps))
        h = np.zeros(d2 + 1, dtype=np.complex128); h[0] = 1.0
        h[d1] += 0.55 * np.exp(1j * 0.35)
        h[d2] += 0.42 * np.exp(1j * (np.pi - 0.2))
        return h
    if kind == "sparse":                      # direct + one distant bounce
        d = int(round(40.0 * P.sps))
        h = np.zeros(d + 1, dtype=np.complex128)
        h[0] = 1.0; h[d] = 0.7 * np.exp(1j * 2.1)
        return h
    raise ValueError(kind)


def cap(h, fid, seed, snr=SNR_WIDE):
    rng = np.random.default_rng(seed)
    tx = TX.build_packet_waveform(fid)["packet"].astype(np.complex128)
    rx = np.convolve(tx, h)[:len(tx) + len(h) - 1]
    npw = np.mean(np.abs(tx) ** 2) / (10 ** (snr / 10))
    rx = rx + np.sqrt(npw / 2) * (rng.standard_normal(len(rx))
                                  + 1j * rng.standard_normal(len(rx)))
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    return np.concatenate([rx, np.zeros(pad, dtype=np.complex128)])


K2_BEFORE, KFB_BEFORE, NR_BEFORE = P.K_2, P.K_fb, P.no_repass
fails = []

print(f"tolerance {TOL_DB:.2f} dB (hardware packet-to-packet spread is 0.056 dB)")
print()
print(f"{'channel':>9}{'pkt':>4}  {'full grid':>14}{'dB':>7}{'runs':>6}   "
      f"{'sweep_taps':>14}{'dB':>7}{'runs':>6}{'penalty':>9}{'floor':>7}")

for kind in ("single", "compact", "sparse"):
    h = chan(kind)
    for fid in (0, 3):
        c = cap(h, fid, 6000 + fid)
        full = tap_sweep.sweep_full(c, 0)
        fast = tap_sweep.sweep_taps(c, 0)
        pen = full["best_score"] - fast["best_score"]
        print(f"{kind:>9}{fid:>4}  {str(full['best']):>14}{full['best_score']:>7.2f}"
              f"{full['n_runs']:>6}   {str(fast['best']):>14}"
              f"{fast['best_score']:>7.2f}{fast['n_runs']:>6}{pen:>+9.2f}"
              f"{fast['kfb_floor']:>7}")
        if pen > TOL_DB:
            fails.append(f"{kind} pkt{fid}: sweep_taps was {pen:.2f} dB worse "
                         f"than the full grid ({fast['best']} vs {full['best']})")
        if fast["n_runs"] >= full["n_runs"]:
            fails.append(f"{kind} pkt{fid}: sweep_taps used {fast['n_runs']} runs, "
                         f"not fewer than the grid's {full['n_runs']}")

# --- 2. the floor must exclude the dead region on the sparse channel ---
c = cap(chan("sparse"), 0, 7777)
s = tap_sweep.sweep_taps(c, 0, verbose=True)
print(f"\nsparse channel: last arrival measured at {s['max_delay_sym']:.2f} sym, "
      f"K_fb floor {s['kfb_floor']}")
print(f"  dropped K_fb candidates : {s['kfb_dropped']}")
print(f"  smallest K_fb tried     : {min(k[1] for k in s['scores'])}")
# The echo is at 40 symbols, so anything below ~40 is on the dead side.
if s["max_delay_sym"] < 30:
    fails.append(f"max delay measured {s['max_delay_sym']:.1f} sym on a channel "
                 f"with a 40-symbol echo -- the measurement is not finding it")
# The floor sits below the cliff on purpose (the optimum is AT the cliff),
# so what matters is that the DEAD region is mostly gone, not that nothing
# below 40 is tried. On a 40-symbol echo, K_fb 16-32 are useless.
if any(k[1] <= 32 for k in s["scores"]):
    fails.append(f"sweep tried K_fb={sorted({k[1] for k in s['scores']})}, which "
                 f"includes the dead region below the cliff -- the floor is not "
                 f"excluding it")
if not any(k[1] == 40 for k in s["scores"]):
    fails.append(f"sweep never tried K_fb=40, the true optimum for a 40-symbol "
                 f"echo -- the floor has excluded the answer")

# --- 3. no global leakage ---
print(f"\nP.K_2/P.K_fb/P.no_repass after sweeping: "
      f"{P.K_2}/{P.K_fb}/{P.no_repass} (were {K2_BEFORE}/{KFB_BEFORE}/{NR_BEFORE})")
if (P.K_2, P.K_fb, P.no_repass) != (K2_BEFORE, KFB_BEFORE, NR_BEFORE):
    fails.append("sweeping mutated the module-level tap settings -- the "
                 "per-call overrides are leaking")


# --- 4. the delay measurement must not track the noise floor -----------
#
# The first version thresholded only at peak-20 dB. On real hardware
# (2026-09-03) the noise floor sat above that line, so "the last bin above
# threshold" was wherever noise happened to poke up -- it reported a
# 40+ symbol arrival on a channel measured at 0.32 symbols of spread, and
# forced the sweep to 40 feedback taps with no echo present. Synthetic
# tests missed it because they were too clean, so this one sweeps SNR
# explicitly: the measurement must be flat, not grow as noise rises.
print()
print("last-arrival measurement vs SNR (must not grow with noise):")
print(f"  {'SNR':>6}" + "".join(f"{n:>14}" for n in ("single", "compact", "sparse")))
meas = {k: [] for k in ("single", "compact", "sparse")}
for snr in (20.0, 12.0, 7.8, 4.0, 0.0):
    row = ""
    for kind in ("single", "compact", "sparse"):
        v = tap_sweep.measure_max_delay_sym(cap(chan(kind), 0, 4200, snr), 0)
        meas[kind].append(v)
        row += f"{v:>14.2f}"
    print(f"  {snr:>6.1f}{row}")
for kind, vs in meas.items():
    spread = max(vs) - min(vs)
    if spread > 2.0:
        fails.append(f"{kind}: measured last arrival moved {spread:.1f} sym "
                     f"across a 20 dB SNR sweep ({min(vs):.1f}..{max(vs):.1f}) "
                     f"-- it is tracking the noise floor, not the channel")
# and the absolute values have to be right, not merely stable
if meas["single"][2] > 6.0:
    fails.append(f"single-path channel reported a {meas['single'][2]:.1f} sym "
                 f"last arrival; only the probe width (~2.4 sym) should show")
if not 30.0 <= meas["sparse"][2] <= 50.0:
    fails.append(f"sparse channel (40 sym echo) reported "
                 f"{meas['sparse'][2]:.1f} sym")
if tap_sweep.suggest_kfb_floor(meas["single"][2]) != 0:
    fails.append("single-path channel produced a nonzero K_fb floor -- the "
                 "sweep would be denied the small feedback lengths it needs")


# --- 5. the significance guard ----------------------------------------
#
# The sweep must not switch on differences smaller than the noise. On a
# single-path channel the top ten candidates span 0.104 dB against a
# 0.056 dB hardware packet spread, and the params default already scores
# within 0.03 dB of the true best -- so there is nothing to win and the
# right action is to leave it alone. The first real run switched anyway,
# to a geometry 0.17 dB WORSE than the default. See MIN_GAIN_DB.
import lfm_bpsk_common as _C

def _stream(h, n=6, seed=555):
    rng = np.random.default_rng(seed)
    seq = []
    for f in range(n):
        tx = TX.build_packet_waveform(f)["packet"].astype(np.complex128)
        seq.append(np.convolve(tx, h)[:len(tx)])
    rx = np.concatenate(seq)
    npw = np.mean(np.abs(rx) ** 2) / (10 ** (SNR_WIDE / 10))
    return rx + np.sqrt(npw / 2) * (rng.standard_normal(len(rx))
                                     + 1j * rng.standard_normal(len(rx)))

print("significance guard (must keep the default when there is nothing to win):")
print(f"  {'channel':>9}{'candidate':>12}{'gain dB':>10}{'adopted':>9}"
      f"{'used':>12}{'pdsnr change':>14}")
for kind, want in (("single", False), ("sparse", True)):
    rx = _stream(chan(kind))
    base = _C.analyze_capture(rx, verbose=False, sample_ppm=0.0)
    swept = _C.analyze_capture(rx, verbose=False, sample_ppm=0.0, sweep_taps=3)
    sw = swept["sweep"]
    print(f"  {kind:>9}{str(sw['candidate']):>12}{sw['gain_db']:>10.3f}"
          f"{str(sw['improved']):>9}{str(sw['best']):>12}"
          f"{swept['pdsnr_db'] - base['pdsnr_db']:>+14.2f}")
    if sw["improved"] != want:
        fails.append(f"{kind}: sweep improved={sw['improved']}, expected {want} "
                     f"(gain {sw['gain_db']:+.3f} dB vs threshold "
                     f"{sw['min_gain_db']:.2f})")
    if not want and swept["pdsnr_db"] < base["pdsnr_db"] - 0.05:
        fails.append(f"{kind}: sweeping made PDSNR WORSE by "
                     f"{base['pdsnr_db'] - swept['pdsnr_db']:.2f} dB -- the "
                     f"guard is not protecting the default")
    if want and swept["pdsnr_db"] < base["pdsnr_db"] + 1.0:
        fails.append(f"{kind}: sweeping gained only "
                     f"{swept['pdsnr_db'] - base['pdsnr_db']:+.2f} dB on a "
                     f"channel the default cannot equalise")

print()
if fails:
    print("RESULT: FAIL")
    for f in fails:
        print(f"  - {f}")
    raise SystemExit(1)
print("RESULT: PASS -- cheap sweep matches the exhaustive grid on compact and\n"
      "        sparse channels, and the K_fb floor keeps the search off the cliff.")
