"""
Frame parameters for the ported Popoto-style LFM + PRBS + QPSK / NLMS-DFE
receiver. Sibling port to lfm_bpsk_params.py -- same real-baseband FAU
hardware convention, same LFM/guard/training design, but the payload
symbols now carry 2 bits/symbol (Gray-coded QPSK: independent I/Q rails)
instead of BPSK's 1 bit/symbol.

Ported from (Popoto reference, uploaded 2026-08-31):
    lfmQpskPopotoTx330.m
    lfmQpskPopotoRx330_nlms.m

Design choices for this port (mirrors lfm_bpsk_params.py's, confirmed
with the user):
  - New parallel files, existing BPSK port and block-based pipeline both
    untouched.
  - N_data is a SYMBOL count (200 QPSK symbols), matching the BPSK port's
    N_data=200 exactly so the two payload sections occupy the same
    on-air duration -- but since each QPSK symbol carries 2 bits, the
    payload is 400 bits instead of BPSK's 200. (The Popoto QPSK10240
    benchmark itself uses a much shorter 76-symbol/152-bit payload; this
    port instead matches the FAU BPSK port's frame geometry per the
    user's explicit request, not Popoto's benchmark size.)
  - Same LFM chirp, guard interval, and N_train=1024 training length as
    the BPSK port -- N_syms_total is unchanged at 1224 symbols, so the
    two ports' packets have identical duration and the same LFM-based
    multi-packet detection/timing code applies unmodified.
  - Coherent QPSK (no differential encoding): the pilot preamble lets RX
    resolve the FULL complex channel (magnitude + all 4 phase quadrants)
    directly, so -- unlike a differential scheme -- no extra bit-level
    decoding stage is needed at RX; bits come straight from per-symbol
    I/Q hard decisions (see lfm_qpsk_rx.py Stage 11).
  - NLMS-DFE tap counts (K_2=72, K_fb=24) are Popoto's OWN fine-swept
    values for their QPSK channel (validated 0.5/1 ft, see the uploaded
    lfmQpskPopotoRx330_nlms.m header) -- carried over as the starting
    point here, same as lfm_bpsk_params.py carried over Popoto's BPSK
    K_2=48/K_fb=20. Still UNVALIDATED for FAU's actual channel/hardware;
    re-sweep against real captures once this port can run on hardware.
  - TX amplitude: build_packet_waveform() in lfm_qpsk_tx.py normalizes
    the LFM and QPSK sections INDEPENDENTLY (each to unit peak), from
    day one -- carrying forward the lesson learned on the BPSK port
    (2026-08-28/31): a single packet-wide peak normalization lets the
    constant-envelope LFM chirp set the whole packet's scale and leaves
    the pulse-shaped payload transmitted well below full scale. See
    lfm_bpsk_tx.py's build_packet_waveform() docstring for the full
    writeup of that issue.

Popoto QPSK10240 benchmark numbers, for comparison (Fs=102400, Fc=33000,
Rs=5120, sps=20, rolloff=0.25, span=10, T_lfm=0.1s, BW=6400Hz -> T*BW=640,
T_guard=0.05s, N_train=1024, N_syms=76 (152 bits), K_2=72, K_fb=24).
"""

import numpy as np

import bpsk_params as _base_params  # reuse the existing RRC/sps/Fs/Fc design

# ----------------------------------------------------------------------
# Carrier / sampling -- reuse the existing FAU board's validated values,
# identical to lfm_bpsk_params.py.
# ----------------------------------------------------------------------
Fs      = _base_params.Fs        # 400_000 Hz
Fc      = _base_params.Fc        # 120_000 Hz
sps     = _base_params.sps       # 24 samples/symbol
rolloff = _base_params.rolloff   # 0.2
Rs      = Fs / sps               # 16_666.67 sym/s
BW      = Rs * (1 + rolloff)     # 20_000 Hz occupied bandwidth
span    = _base_params.SpanRRC   # 8 (RRC span, symbols)

# ----------------------------------------------------------------------
# LFM sounding burst -- identical design to lfm_bpsk_params.py (real
# lowpass sweep, no carrier; see that module's docstring for the full
# rationale). Kept as its own copy here (not imported) so this port
# stays self-contained/parallel, matching the existing convention.
# ----------------------------------------------------------------------
f1      = 500.0                           # Hz -- ASSUMPTION, see lfm_bpsk_params.py
f2      = BW                              # 20_000 Hz -- ASSUMPTION, see lfm_bpsk_params.py
TBW_TARGET = 640.0
T_lfm   = TBW_TARGET / (f2 - f1)          # ~0.0328 s
N_lfm   = int(round(Fs * T_lfm))          # ~13_120 samples
lfm_tukey_alpha = 0.1                     # taper fraction, matches Popoto

# ----------------------------------------------------------------------
# Guard interval -- identical to lfm_bpsk_params.py.
# ----------------------------------------------------------------------
N_guard = _base_params.CP_samp            # 4200 samples = 10.5 ms
T_guard = N_guard / Fs

# ----------------------------------------------------------------------
# QPSK training + data payload.
#
# bps_sym=2 (Gray-coded QPSK: bit 2k -> I rail, bit 2k+1 -> Q rail of
# symbol k, matching qpsk_map()'s convention in lfm_qpsk_frame.py).
# N_train/N_data are SYMBOL counts; N_bits_train/N_bits are the derived
# bit counts (2x the symbol counts).
# ----------------------------------------------------------------------
bps_sym = 2                               # QPSK: 2 bits/symbol
N_train = 1024                            # known training symbols (unchanged from BPSK port)
N_data  = 200                             # payload data symbols (unchanged from BPSK port)
N_syms_total = N_train + N_data           # 1224 -- same packet duration as the BPSK port

N_bits_train = N_train * bps_sym          # 2048 training bits
N_data_bits  = N_data * bps_sym           # 400 payload bits

TRAIN_SEED = 42                           # fixed seed, matches Popoto exactly

# Frame-ID marker embedded at the start of the data payload's BIT stream
# (first 32 bits = first 16 QPSK symbols), reusing the existing A5 5A
# id ~id convention from common_frame_ids.py.
MARKER_BYTES = 4
MARKER_BITS  = MARKER_BYTES * 8           # 32 bits
assert N_data_bits >= MARKER_BITS, "N_data too short to hold the frame-ID marker"

# ----------------------------------------------------------------------
# NLMS-DFE equalizer defaults -- Popoto's own fine-swept QPSK values
# (see module docstring). STARTING POINT ONLY -- MUST be re-swept
# against real FAU captures once this port can be run on hardware.
# ----------------------------------------------------------------------
K_2  = 72          # feedforward taps, T/2-spaced
K_fb = 24           # decision-feedback taps
DEC_DELAY_MAX = 80  # lookahead margin (symbols) reserved past frame end
w_norm_max = 1.1
gain_cap   = 0.2
no_repass  = 3


def reconfigure_fs(new_fs: int):
    """
    Update Fs and all derived module-level constants in place, mirroring
    lfm_bpsk_params.reconfigure_fs / bpsk_params.reconfigure_fs. Call this
    BEFORE building any packets when using a non-default --sampling-rate.
    sps/rolloff/span/N_train/N_data/K_2/K_fb are unchanged; f1 stays fixed
    (500 Hz) but f2=BW (and therefore T_lfm/N_lfm) and N_guard (which
    tracks the base module's CP_samp) move with Fs.
    """
    import sys
    _base_params.reconfigure_fs(new_fs)  # update the shared base module first
    m = sys.modules[__name__]
    m.Fs = _base_params.Fs
    m.Rs = m.Fs / sps
    m.BW = m.Rs * (1 + rolloff)
    m.f2 = m.BW
    m.T_lfm = TBW_TARGET / (m.f2 - f1)
    m.N_lfm = int(round(m.Fs * m.T_lfm))
    m.N_guard = _base_params.CP_samp
    m.T_guard = m.N_guard / m.Fs


def summary() -> str:
    return (
        f"Fs={Fs:.0f} Fc={Fc:.0f} (label only, not mixed in software) "
        f"Rs={Rs:.2f} sps={sps} BW={BW:.0f} rolloff={rolloff} span={span}\n"
        f"LFM (baseband sweep): T_lfm={T_lfm*1e3:.1f}ms N_lfm={N_lfm} "
        f"f1={f1:.0f} f2={f2:.0f} (T*(f2-f1)={T_lfm*(f2-f1):.0f})\n"
        f"Guard: T_guard={T_guard*1e3:.2f}ms N_guard={N_guard}\n"
        f"Frame: bps_sym={bps_sym} N_train={N_train} N_data={N_data} "
        f"N_syms_total={N_syms_total} N_data_bits={N_data_bits}\n"
        f"NLMS-DFE defaults: K_2={K_2} K_fb={K_fb} (UNVALIDATED for this channel)"
    )


if __name__ == "__main__":
    print(summary())
