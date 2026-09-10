"""
Self-test 1 (Task 5): noiseless, no-channel round trip. Builds a
multi-frame LFM+BPSK capture with lfm_bpsk_tx, feeds it straight back
into lfm_bpsk_common.analyze_capture with NO channel impairment at all,
and checks the decode is bit-exact. If this fails, the port has a real
bug -- nothing about a real channel is involved yet.
"""
import numpy as np

import lfm_bpsk_tx as TX
import lfm_bpsk_common as C

FRAME_IDS = list(range(6))

cap = TX.build_multi_frame_capture(FRAME_IDS)
waveform = cap["capture"]
print(f"Built {len(FRAME_IDS)}-frame noiseless capture: {len(waveform)} samples "
      f"({len(waveform)/ (400000) *1e3:.1f} ms)")
print()

ana = C.analyze_capture(waveform, verbose=True)

print()
ok = (ana["n_packets_detected"] == len(FRAME_IDS)) and (ana["total_err"] == 0) and (ana["total_bits"] == len(FRAME_IDS) * 200)
print(f"RESULT: {'PASS' if ok else 'FAIL'} -- "
      f"detected {ana['n_packets_detected']}/{len(FRAME_IDS)} packets, "
      f"{ana['total_err']} bit errors / {ana['total_bits']} bits")
