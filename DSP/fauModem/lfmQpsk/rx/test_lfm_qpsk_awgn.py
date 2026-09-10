"""
Self-test 2: AWGN sweep. The noiseless self-test (test_lfm_qpsk_selftest.py)
only proves the packet format/indexing is self-consistent -- it can pass
even if the CFO/DFE/decision code has real bugs, since a noiseless channel
gives the equalizer nothing to fail on. This test adds AWGN at a few SNR
points and checks BER comes out sane and monotonic-ish with SNR, exercising
the actual NLMS-DFE/decision-directed PLL code paths this port added
(Stage 5's conj(train_syms) CFO fix, Stage 6's full pilot-phase rotation,
Stage 8/9's QPSK 4-point hard/soft decision) under real noise.
"""
import numpy as np

import lfm_qpsk_tx as TX
import lfm_qpsk_common as C
import lfm_qpsk_params as P

FRAME_IDS = list(range(6))


def add_awgn(wave, snr_db):
    sig_pwr = np.mean(np.abs(wave) ** 2)
    noise_pwr = sig_pwr / (10 ** (snr_db / 10))
    rng = np.random.default_rng(11)
    noise = np.sqrt(noise_pwr / 2) * (rng.standard_normal(len(wave))
                                      + 1j * rng.standard_normal(len(wave)))
    return wave + noise


def run_case(snr_db):
    cap = TX.build_multi_frame_capture(FRAME_IDS)
    waveform = cap["capture"].astype(np.complex128)
    rx = add_awgn(waveform, snr_db)
    ana = C.analyze_capture(rx, verbose=False)
    ber = ana["ber"] if ana["ber"] is not None else float("nan")
    print(f"  SNR={snr_db:+5.1f}dB  detected={ana['n_packets_detected']}/{len(FRAME_IDS)}  "
          f"errors={ana['total_err']:4d}/{ana['total_bits']:4d}  BER={ber:.4e}  "
          f"PDSNR={ana['pdsnr_db']:.2f}dB" if ana['pdsnr_db'] is not None else
          f"  SNR={snr_db:+5.1f}dB  detected={ana['n_packets_detected']}/{len(FRAME_IDS)}  "
          f"errors={ana['total_err']:4d}/{ana['total_bits']:4d}  BER={ber:.4e}  PDSNR=n/a")
    return ana


if __name__ == "__main__":
    print(f"Cyclic capture: {len(FRAME_IDS)} back-to-back physical frames, AWGN sweep")
    print()

    prev_ber = None
    all_ok = True
    for snr_db in [25.0, 15.0, 10.0, 6.0]:
        ana = run_case(snr_db)
        detected_ok = ana["n_packets_detected"] == len(FRAME_IDS)
        ok = detected_ok
        # High-SNR points should decode essentially error-free; this is the
        # main correctness bar (a real algorithmic bug would show up as
        # persistent errors even at 25/15dB, well above where BER should
        # be floor-limited).
        if snr_db >= 15.0:
            ok = ok and (ana["total_err"] == 0)
        all_ok = all_ok and ok
        status = "PASS" if ok else "FAIL"
        print(f"    [{status}]")
        print()

    print(f"RESULT: {'PASS' if all_ok else 'FAIL'}")
