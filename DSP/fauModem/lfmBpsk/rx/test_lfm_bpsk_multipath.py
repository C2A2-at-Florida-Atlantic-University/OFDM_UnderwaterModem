"""
Self-test 2 (Task 6): synthetic multipath, comparing the ported NLMS-DFE
against a no-equalizer baseline (matched-filter + CFO/rotation only, the
closest analog to what the CURRENT FAU receiver's per-block phase-only
correction achieves). Taps are sized to the delay/order-of-magnitude
established from the REAL tank captures (near-field coupling + possible
surface/bottom bounce, roughly 1.7-6 symbol periods of delay -- see the
block2 local-bit-148/211 investigation), not arbitrary values.
"""
import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX
import lfm_bpsk_rx as RX
import lfm_bpsk_frame as F

rng = np.random.default_rng(12345)

# Two discrete multipath taps, delays chosen in the 1.7-6.3 symbol range
# found in the real captures (samples = symbols * sps):
d1 = int(round(3.0 * P.sps))   # ~3 symbols
d2 = int(round(5.5 * P.sps))   # ~5.5 symbols
a1, a2 = 0.55, 0.42
# Opposite-sign phase on the two taps, echoing the surface/pressure-release
# (phase-inverting) vs. bottom (non-inverting) reflection discussion.
phi1, phi2 = 0.35, np.pi - 0.2

h = np.zeros(d2 + 1, dtype=np.complex128)
h[0] = 1.0
h[d1] += a1 * np.exp(1j * phi1)
h[d2] += a2 * np.exp(1j * phi2)

SNR_DB = 22.0
N_FRAMES = 20
FRAME_IDS = list(range(N_FRAMES))

print(f"Synthetic multipath channel: taps at 0, {d1} samp ({d1/P.sps:.2f} sym, "
      f"a={a1}, phi={phi1:.2f}), {d2} samp ({d2/P.sps:.2f} sym, a={a2}, "
      f"phi={phi2:.2f})  SNR={SNR_DB}dB  N_FRAMES={N_FRAMES}")
print()

err_dfe = 0
err_naive = 0
n_bits_total = 0
n_ok = 0

for fid in FRAME_IDS:
    pkt = TX.build_packet_waveform(fid)
    tx_wave = pkt["packet"].astype(np.complex128)

    rx_wave = np.convolve(tx_wave, h)[:len(tx_wave) + d2]
    # AWGN at the requested SNR relative to the direct-path signal power.
    sig_pwr = np.mean(np.abs(tx_wave) ** 2)
    noise_pwr = sig_pwr / (10 ** (SNR_DB / 10))
    noise = np.sqrt(noise_pwr / 2) * (rng.standard_normal(len(rx_wave)) + 1j * rng.standard_normal(len(rx_wave)))
    rx_wave = rx_wave + noise

    # Pad for decision-delay lookahead margin, matching lfm_bpsk_common.
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    rx_wave = np.concatenate([rx_wave, np.zeros(pad, dtype=np.complex128)])

    dec = RX.decode_packet(rx_wave, lfm_start=0)
    if not dec.get("ok"):
        print(f"  frame {fid}: FAILED -- {dec.get('reason')}")
        continue

    ref_bits = F.data_bits(fid)
    e_dfe = int(np.sum(dec["bits_hat"] != ref_bits))
    e_naive = int(np.sum(dec["bits_naive"] != ref_bits))
    err_dfe += e_dfe
    err_naive += e_naive
    n_bits_total += P.N_data
    n_ok += 1
    print(f"  frame {fid}: no-eq errors={e_naive:3d}/{P.N_data}  "
          f"NLMS-DFE errors={e_dfe:3d}/{P.N_data}")

print()
if n_bits_total > 0:
    ber_naive = err_naive / n_bits_total
    ber_dfe = err_dfe / n_bits_total
    print(f"No-equalizer baseline : {err_naive} / {n_bits_total} = {ber_naive:.4e}")
    print(f"NLMS-DFE (ported)     : {err_dfe} / {n_bits_total} = {ber_dfe:.4e}")
    if err_dfe < err_naive:
        print(f"\nRESULT: DFE reduced errors ({err_naive} -> {err_dfe}) on this synthetic "
              f"multipath channel.")
    elif err_dfe == err_naive:
        print(f"\nRESULT: DFE made no difference on this synthetic channel/SNR "
              f"({err_naive} errors either way).")
    else:
        print(f"\nRESULT: DFE did WORSE than the no-equalizer baseline "
              f"({err_naive} -> {err_dfe}) -- needs investigation before trusting this port.")
else:
    print("RESULT: no frames decoded successfully -- cannot compare.")
