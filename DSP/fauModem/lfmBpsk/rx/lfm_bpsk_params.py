"""
Frame parameters for the ported Popoto-style LFM + PRBS + BPSK / NLMS-DFE
receiver. This is a NEW, self-contained frame format -- it does not reuse
bpsk_params.py's block/CP/pilot structure (see bpsk_rx.py's phase_track()
/ direct_extract() for that older design). Kept as parallel files so the
existing, working block-based pipeline stays available as a baseline.

Ported from (Popoto reference, validated in-tank):
    lfmBpskPopotoTx330_N152.m
    lfmBpskPopotoRx330_N152_nlms.m   (recommended -- see RLS caveat below)
    lfmBpskPopotoRx330_N152_rls.m    (documented as diverging on real BPSK
                                       captures via decision-feedback error
                                       cascade; never validated on real data
                                       for coherent BPSK. Kept only as an
                                       explicitly experimental path.)

Design choices for this port (confirmed with the user):
  - New parallel files, existing pipeline untouched.
  - Multiple LFM+BPSK packets per capture (frame-ID marker embedded in the
    payload), matching the existing multi-frame capture workflow.
  - Training/data bit generation matches Popoto's actual implementation:
    a fixed-seed PRNG for the training sequence (reproducible, known to
    RX) and a per-frame PRNG (seeded from frame_id, so RX can regenerate
    the reference without a side channel) for the data payload -- NOT a
    true LFSR/maximal-length PRBS, despite the project's "PRBS" name.
  - LFM chirp sized to match Popoto's time-bandwidth product (T*BW ~= 640)
    rather than its absolute duration, scaled to FAU's much wider (20 kHz
    vs 6.4 kHz) occupied bandwidth: this keeps a comparable processing
    gain/robustness margin while spending far less per-packet overhead
    (~33 ms vs Popoto's 100 ms, because FAU's higher symbol rate needs
    less time to sweep proportionally the same T*BW).
  - Carrier handling: bpsk_rx.py states outright "No downconversion from a
    carrier -- input is already baseband", and build_frame()/pulse_shape()
    in bpsk_tx.py never mix by Fc=120kHz anywhere -- the existing FAU
    TX/RX chain is real-baseband PAM end to end (Fc appears only as a
    label in bpsk_params.py's docstring, not as an operation in code).
    Confirmed with the user: this port follows the SAME convention (no
    software Fc mixing), so the new packet is compatible with the
    existing DAC/ADC/DMA hardware chain as-is. Consequently the LFM chirp
    is also a real LOWPASS sweep (not a passband sweep around Fc) --
    ASSUMPTION FLAGGED FOR CONFIRMATION: f1/f2 below are chosen to occupy
    roughly the same real bandwidth the BPSK payload already uses
    (~20 kHz), just offset off DC to keep the chirp itself clean. This
    is a genuine design choice with no hardware documentation behind it
    yet -- confirm/adjust against whatever the DAC/transducer chain can
    actually pass before transmitting for real.

Popoto reference numbers, for comparison (Fs=102400, Fc=33000, Rs=5120,
sps=20, rolloff=0.25, span=10, T_lfm=0.1s, BW=6400Hz -> T*BW=640,
T_guard=0.05s, N_train=1024, N_syms=152).
"""

import numpy as np

import bpsk_params as _base_params  # reuse the existing RRC/sps/Fs/Fc design

# ----------------------------------------------------------------------
# Carrier / sampling -- reuse the existing FAU board's validated values.
# ----------------------------------------------------------------------
Fs      = _base_params.Fs        # 400_000 Hz
Fc      = _base_params.Fc        # 120_000 Hz
sps     = _base_params.sps       # 24 samples/symbol
rolloff = _base_params.rolloff   # 0.2
Rs      = Fs / sps               # 16_666.67 sym/s
BW      = Rs * (1 + rolloff)     # 20_000 Hz occupied bandwidth
span    = _base_params.SpanRRC   # 8 (RRC span, symbols)

# ----------------------------------------------------------------------
# LFM sounding burst -- real LOWPASS sweep (no carrier, see note above).
# f1/f2 chosen to span roughly the same ~20kHz real bandwidth the BPSK
# payload already occupies, offset off DC. Sized to match Popoto's
# time-bandwidth product (T_lfm * (f2-f1) ~= 640) rather than its
# absolute 0.1s duration -- FAU's chirp bandwidth is wider than
# Popoto's 6.4kHz, so the same TBW is reached in proportionally less
# time.
# ----------------------------------------------------------------------
f1      = 500.0                           # Hz -- ASSUMPTION, see header
f2      = BW                              # 20_000 Hz -- ASSUMPTION, see header
TBW_TARGET = 640.0
T_lfm   = TBW_TARGET / (f2 - f1)          # ~0.0328 s
N_lfm   = int(round(Fs * T_lfm))          # ~13_120 samples
lfm_tukey_alpha = 0.1                     # taper fraction, matches Popoto

# ----------------------------------------------------------------------
# Guard interval -- let LFM-burst multipath die out before BPSK starts.
# Reuses the existing system's own already-vetted 10.5 ms multipath
# budget (bpsk_params.CP_samp = CP_sym * sps) rather than picking a new
# number; this is a one-time per-packet guard, not a per-block CP.
# ----------------------------------------------------------------------
N_guard = _base_params.CP_samp            # 4200 samples = 10.5 ms
T_guard = N_guard / Fs

# ----------------------------------------------------------------------
# BPSK training + data payload.
# ----------------------------------------------------------------------
N_train = 1024                            # known training symbols
N_data  = 200                             # payload data symbols
N_syms_total = N_train + N_data           # 1224

TRAIN_SEED = 42                           # fixed seed, matches Popoto exactly

# Frame-ID marker embedded at the start of the data payload (reuses the
# existing A5 5A id ~id convention from common_frame_ids.py so the same
# marker-hamming decode/BER-bookkeeping style still applies).
MARKER_BYTES = 4
MARKER_BITS  = MARKER_BYTES * 8           # 32 bits
assert N_data >= MARKER_BITS // 1, "N_data too short to hold the frame-ID marker"

# ----------------------------------------------------------------------
# NLMS-DFE equalizer defaults -- STARTING POINT ONLY. Popoto's K_2=48/
# K_fb=20 were swept and confirmed for its own 33kHz/102.4kSa/s channel;
# they are carried over here as a reasonable initial guess (similar
# order of magnitude relative to symbol rate) but MUST be re-swept
# against real FAU captures once this port can be run on hardware.
# ----------------------------------------------------------------------
K_2  = 48          # feedforward taps, T/2-spaced
K_fb = 20           # decision-feedback taps
DEC_DELAY_MAX = 80  # lookahead margin (symbols) reserved past frame end
w_norm_max = 1.1
gain_cap   = 0.2
no_repass  = 3


def reconfigure_fs(new_fs: int):
    """
    Update Fs and all derived module-level constants in place, mirroring
    bpsk_params.reconfigure_fs. Call this BEFORE building any packets when
    using a non-default --sampling-rate. sps/rolloff/span/N_train/N_data/
    K_2/K_fb are unchanged; f1 stays fixed (500 Hz) but f2=BW (and
    therefore T_lfm/N_lfm) and N_guard (which tracks the base module's
    CP_samp) move with Fs.
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
        f"Frame: N_train={N_train} N_data={N_data} N_syms_total={N_syms_total}\n"
        f"NLMS-DFE defaults: K_2={K_2} K_fb={K_fb} (UNVALIDATED for this channel)"
    )


if __name__ == "__main__":
    print(summary())
