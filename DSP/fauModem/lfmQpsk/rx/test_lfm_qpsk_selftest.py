"""
Self-test 1: noiseless, no-channel round trip. Builds a multi-frame
LFM+QPSK capture with lfm_qpsk_tx, feeds it straight back into
lfm_qpsk_common.analyze_capture with NO channel impairment at all, and
checks the decode is bit-exact. Mirrors test_lfm_bpsk_selftest.py exactly
(200 symbols/frame is the same as BPSK; the bit count is 400/frame here
since each symbol carries 2 bits).
"""
import numpy as np

import lfm_qpsk_tx as TX
import lfm_qpsk_common as C
import lfm_qpsk_params as P

FRAME_IDS = list(range(6))

cap = TX.build_multi_frame_capture(FRAME_IDS)
waveform = cap["capture"]
print(f"Built {len(FRAME_IDS)}-frame noiseless capture: {len(waveform)} samples "
      f"({len(waveform)/P.Fs*1e3:.1f} ms)")
print()

ana = C.analyze_capture(waveform, verbose=True)

print()
expected_bits = len(FRAME_IDS) * P.N_data_bits
ok = (ana["n_packets_detected"] == len(FRAME_IDS)) and (ana["total_err"] == 0) and (ana["total_bits"] == expected_bits)
print(f"RESULT: {'PASS' if ok else 'FAIL'} -- "
      f"detected {ana['n_packets_detected']}/{len(FRAME_IDS)} packets, "
      f"{ana['total_err']} bit errors / {ana['total_bits']} bits")
