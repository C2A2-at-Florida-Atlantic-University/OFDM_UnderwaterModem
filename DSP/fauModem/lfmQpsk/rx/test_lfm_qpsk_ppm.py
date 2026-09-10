"""
Self-test (Task: sample-clock ppm correction): validates
lfm_qpsk_common.estimate_sample_ppm() + lfm_qpsk_rx.decode_packet()'s
sample_ppm-corrected Stage 4 extraction against a synthetic capture with a
KNOWN, injected TX/RX sample-clock offset -- the same kind of mismatch two
independent, free-running board crystals produce (confirmed as a real BER
contributor on cross-board hardware captures, 2026-08-28). Sibling to
test_lfm_bpsk_ppm.py -- identical harness (estimate_sample_ppm() is
byte-for-byte the same algorithm, modulation-agnostic), swapped to the
QPSK TX/common modules and P.N_data_bits (400 bits/frame vs BPSK's
P.N_data=200).

Unlike test_lfm_qpsk_selftest.py's build_multi_frame_capture() (which
inserts extra inter-frame silence, not representative of the real cyclic
TX stream), this builds a back-to-back capture matching
lfm_qpsk_tx.build_cyclic_tx_packet()'s convention exactly, since ppm
estimation depends on frame-to-frame spacing matching that convention.
"""
import numpy as np

import lfm_qpsk_params as P
import lfm_qpsk_tx as TX
import lfm_qpsk_common as C

FRAME_IDS = [i % 6 for i in range(18)]  # matches the real hardware run (18 phys frames)


def build_cyclic_waveform(frame_ids):
    """Back-to-back physical frames, no inter-frame silence -- mirrors
    lfm_qpsk_tx.build_cyclic_tx_packet()'s layout exactly."""
    pieces = [TX.build_packet_waveform(fid)["packet"] for fid in frame_ids]
    return np.concatenate(pieces)


def inject_sample_ppm(wave, ppm):
    """
    Resample `wave` (built at the nominal TX clock) as if an RX ADC
    running `ppm` parts-per-million faster/slower had captured it: over
    the same physical duration, a faster RX clock produces MORE samples
    than TX assumed, and vice versa.
    """
    if ppm == 0.0:
        return wave.copy()
    N = len(wave)
    ratio = 1.0 + ppm * 1e-6
    N_rx = int(round(N * ratio))
    src_idx = np.arange(N, dtype=np.float64)
    rx_positions = np.arange(N_rx, dtype=np.float64) / ratio
    is_complex = np.iscomplexobj(wave)
    real = np.interp(rx_positions, src_idx, wave.real if is_complex else wave,
                     left=0.0, right=0.0)
    if is_complex:
        imag = np.interp(rx_positions, src_idx, wave.imag, left=0.0, right=0.0)
        return real + 1j * imag
    return real


def add_awgn(wave, snr_db):
    sig_pwr = np.mean(np.abs(wave) ** 2)
    noise_pwr = sig_pwr / (10 ** (snr_db / 10))
    rng = np.random.default_rng(11)
    if np.iscomplexobj(wave):
        noise = np.sqrt(noise_pwr / 2) * (rng.standard_normal(len(wave))
                                          + 1j * rng.standard_normal(len(wave)))
    else:
        noise = np.sqrt(noise_pwr) * rng.standard_normal(len(wave))
    return wave + noise


def run_case(ppm_inject, snr_db):
    ideal = build_cyclic_waveform(FRAME_IDS).astype(np.complex128)
    captured = inject_sample_ppm(ideal, ppm_inject)
    captured = add_awgn(captured, snr_db)

    ana_uncorrected = C.analyze_capture(captured, sample_ppm=0.0, verbose=False)
    ana_corrected = C.analyze_capture(captured, sample_ppm=None, verbose=False)

    ppm_est = ana_corrected["sample_ppm"]
    ber_unc = ana_uncorrected["ber"] if ana_uncorrected["ber"] is not None else float("nan")
    ber_cor = ana_corrected["ber"] if ana_corrected["ber"] is not None else float("nan")
    print(f"  injected={ppm_inject:+7.1f}ppm  estimated={ppm_est:+7.1f}ppm  "
          f"BER uncorrected={ber_unc:.4e}  BER corrected={ber_cor:.4e}  "
          f"errs {ana_uncorrected['total_err']:4d} -> {ana_corrected['total_err']:4d}")
    return ppm_est, ana_uncorrected, ana_corrected


if __name__ == "__main__":
    print(f"Cyclic capture: {len(FRAME_IDS)} back-to-back physical frames, "
          f"id_cycle=6, SNR sweep with injected sample-clock ppm")
    print()

    all_ok = True
    for ppm_inject, snr_db in [(0.0, 20.0), (25.0, 20.0), (60.0, 20.0), (120.0, 20.0)]:
        ppm_est, unc, cor = run_case(ppm_inject, snr_db)
        ppm_err = abs(ppm_est - ppm_inject)
        est_ok = ppm_err < 3.0  # generous tolerance for detection-peak jitter
        improved_or_already_clean = (cor["total_err"] <= unc["total_err"])
        ok = est_ok and improved_or_already_clean
        all_ok = all_ok and ok
        status = "PASS" if ok else "FAIL"
        print(f"    [{status}] ppm estimate error={ppm_err:.2f}ppm "
              f"(tolerance 3.0)  corrected errs <= uncorrected: "
              f"{improved_or_already_clean}")
        print()

    print(f"RESULT: {'PASS' if all_ok else 'FAIL'}")
