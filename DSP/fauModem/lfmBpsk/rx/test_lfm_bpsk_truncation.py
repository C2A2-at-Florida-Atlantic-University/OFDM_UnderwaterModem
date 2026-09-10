"""
Self-test 5: the partly-captured-packet guard.

Reproduces the condition seen on the 134-packet hardware capture of
2026-09-02, where the final packet was 78 samples (3.2 symbols) short and
contributed 4 errors -- the entire reported BER of 1.49e-04, on a link
that was otherwise error-free across 133 packets.

Root cause is structural, not a fault: a capture is a whole number of DMA
buffers (12 x 2 MiB = 6,291,456 samples) and a packet is 46,696 samples,
so 6,291,456 / 46,696 = 134.7 packets. The last one is ALWAYS a fragment.
analyze_capture() then pads with zeros so decision_delay has lookahead,
the fragment decodes against those zeros, and it is reported as readable
with a real BER.

Two checks:
  1. A capture cut mid-packet must have that packet SKIPPED, not scored,
     and the surviving packets must give exactly the same errors as the
     same capture cut at a packet boundary.
  2. Cutting at a boundary must skip nothing -- the guard must not reject
     complete packets.
"""
import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX
import lfm_bpsk_common as C

N_FRAMES = 5
# The TRANSMITTED length, not a re-derivation: build_packet_waveform()
# appends span*sps = 192 samples of RRC flush that the symbol-count
# formula (N_lfm + N_guard + N_syms_total*sps = 46,704) does not include.
PKT = len(TX.build_packet_waveform(0)["packet"])

print(f"packet = {PKT} samples ({PKT / P.Fs * 1e3:.1f} ms), "
      f"{N_FRAMES} frames back-to-back")
print(f"  (symbol-count formula would say "
      f"{P.N_lfm + P.N_guard + P.N_syms_total * P.sps}, short by "
      f"{PKT - (P.N_lfm + P.N_guard + P.N_syms_total * P.sps)} -- RRC flush tail)")
print()

# Back-to-back cyclic stream, the way the hardware TX actually sends --
# no inter-frame silence, so packet n+1 starts exactly PKT samples after
# packet n. build_multi_frame_capture() inserts extra silence and would
# not reproduce the boundary condition being tested.
cap_full = np.concatenate(
    [np.asarray(TX.build_packet_waveform(f)["packet"], dtype=np.complex128)
     for f in range(N_FRAMES)])
print(f"full stream           : {len(cap_full)} samples "
      f"(= {len(cap_full) / PKT:.0f} x PKT)")

fails = []

# --- 1. cut mid-packet -------------------------------------------------
SHORT_BY = 78          # exactly the hardware shortfall
cut = cap_full[:len(cap_full) - SHORT_BY]
ana_cut = C.analyze_capture(cut, verbose=False, sample_ppm=0.0)

print(f"\ncut {SHORT_BY} samples early ({SHORT_BY / P.sps:.1f} symbols):")
print(f"  detected              : {ana_cut['n_packets_detected']}")
print(f"  skipped (truncated)   : {ana_cut['n_truncated']}")
print(f"  scored                : {ana_cut['n_scored']}")
print(f"  errors                : {ana_cut['total_err']} / {ana_cut['total_bits']}")

if ana_cut["n_truncated"] != 1:
    fails.append(f"expected exactly 1 truncated packet, got "
                 f"{ana_cut['n_truncated']}")
tr = [r for r in ana_cut["results"] if r.get("truncated")]
if tr:
    print(f"  reason                : {tr[0]['reason']}")
    if tr[0]["capture_idx"] != ana_cut["n_packets_detected"] - 1:
        fails.append("the truncated packet should be the LAST one")

# --- 2. cut exactly at a packet boundary -------------------------------
whole = cap_full[:(len(cap_full) // PKT) * PKT]
ana_whole = C.analyze_capture(whole, verbose=False, sample_ppm=0.0)
print(f"\ncut at a packet boundary:")
print(f"  detected              : {ana_whole['n_packets_detected']}")
print(f"  skipped (truncated)   : {ana_whole['n_truncated']}")
print(f"  scored                : {ana_whole['n_scored']}")
print(f"  errors                : {ana_whole['total_err']} / {ana_whole['total_bits']}")

if ana_whole["n_truncated"] != 0:
    fails.append(f"the guard rejected {ana_whole['n_truncated']} COMPLETE "
                 f"packet(s) -- it must only reject fragments")

# --- 3. the surviving packets must be scored identically ---------------
def scored(ana):
    return {(r["lfm_start"], r["n_err"]) for r in ana["results"]
            if r.get("readable")}

common = {s for s, _ in scored(ana_cut)} & {s for s, _ in scored(ana_whole)}
a = {s: e for s, e in scored(ana_cut) if s in common}
b = {s: e for s, e in scored(ana_whole) if s in common}
print(f"\npackets scored in both  : {len(common)}")
if a != b:
    diff = {s: (a[s], b[s]) for s in a if a[s] != b[s]}
    fails.append(f"errors differ on packets present in both cuts: {diff}")
else:
    print("  same error count on every one : ok")

if ana_cut["total_err"] != 0:
    fails.append(f"after skipping the fragment, a clean synthetic stream "
                 f"should give 0 errors, got {ana_cut['total_err']}")

print()
if fails:
    print("RESULT: FAIL")
    for f in fails:
        print(f"  - {f}")
    raise SystemExit(1)
print("RESULT: PASS -- fragments are skipped, complete packets are not, "
      "and\n        scoring is unchanged on every packet that survives.")
