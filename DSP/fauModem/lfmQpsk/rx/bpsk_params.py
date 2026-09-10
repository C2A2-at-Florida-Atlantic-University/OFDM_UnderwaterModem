"""
bpsk_params.py
==============
Shared system parameters for the BPSK Underwater Acoustic Transceiver.
Both bpsk_tx.py and bpsk_rx.py import from this file to stay in sync.

System:  Fc = 120 kHz | Fs = 400 kHz | BW ≈ 20 kHz
         RRC rolloff = 0.2 | sps = 24 | SpanRRC = 8

Changes vs the 60-µs version
──────────────────────────────
  • delaySpread = 10 ms  →  CP_sym = 175  (was 3)
    CP must cover the full multipath tail: ceil((4000 + 2×96) / 24) = 175 sym.
  • Npilot = 512  (was 32)
    Npilot / CP_sym ≈ 2.9× gives healthy LS-estimation SNR at the longer CP.
  • Npreamble now uses TWO IDENTICAL HALVES of Nhalf=48 symbols each (96 total).
    The half-preamble structure is exploited by:
      – Coarse CFO  : inter-half phase rotation  →  ±Rs/(2) ≈ ±173 Hz range
      – Sync        : pair-peak cross-correlation →  robust under high ISI noise
  • Doppler model  : linearly ramping CFO, CFO_START_HZ → CFO_END_HZ over frame.
  • Block layout per block:  [CP(175) | Pilot(512) | CP(175) | Data(256)]
    dataBlockLen = 2*CP_sym + Npilot + Ndata = 1118 symbols.
"""

import numpy as np

# ── RF / sample-rate ─────────────────────────────────────────────────────────
Fc      = 120_000       # Carrier frequency (Hz)
Fs      = 400_000       # Sample rate (Hz)
rolloff = 0.2           # RRC roll-off factor
sps     = 24            # Samples per symbol
SpanRRC = 8             # RRC filter span (symbols)

# Derived
Rs        = Fs / sps                    # Symbol rate  ≈ 16 666.7 sym/s
BW        = Rs * (1 + rolloff)          # Occupied BW  = 20 000 Hz
RRC_DELAY = SpanRRC * sps // 2         # RRC group delay (samples)  = 96

# ── Channel / cyclic-prefix design ───────────────────────────────────────────
delaySpread_ms   = 10                                        # delay spread (ms)
delaySpread_samp = round(delaySpread_ms * 1e-3 * Fs)        # 4 000 samples

# Effective channel span = multipath + both RRC filter tails
chanSamp = delaySpread_samp + 2 * RRC_DELAY                 # 4 192 samples
chanSym  = int(np.ceil(chanSamp / sps))                     # 175 symbols
CP_sym   = chanSym                                          # CP length (sym)
CP_samp  = CP_sym * sps                                     # CP length (samp)

# ── Doppler / CFO model ───────────────────────────────────────────────────────
# A linearly ramping CFO models a source moving with slowly changing speed.
# TX embeds the ramp; RX must estimate and remove it.
CFO_START_HZ = 100.0    # CFO at frame start (Hz)
CFO_END_HZ   = 140.0    # CFO at frame end   (Hz)

# ── Preamble — two identical halves, NO cyclic prefix ────────────────────────
# Each half has Nhalf = 48 symbols.
# Coarse-CFO unambiguous range  =  ±1 / (2 · T_half)  ≈  ±173 Hz.
Nhalf     = 48
Npreamble = 2 * Nhalf    # 96 total preamble symbols

# ── Data-block parameters ─────────────────────────────────────────────────────
Npilot      = 512    # Pilot symbols per block
Ndata       = 256    # Payload data symbols per block
Ndata_guard = 1      # Leading non-payload guard symbol before each data block
Ndata_tx    = Ndata + Ndata_guard
Nblocks     = 4      # Number of data blocks

# Each block:  [CP(175) | Pilot(512) | CP(175) | Data(256)]
dataBlockLen = 2 * CP_sym + Npilot + Ndata_tx       # 1 119 symbols
FRAME_SYMS   = Npreamble + Nblocks * dataBlockLen   # 96 + 4×1118 = 4 568

# ── Known sequences (fixed seeds → identical in TX and RX) ───────────────────
def _lfsr_pn(poly_taps: list, state: list, n: int) -> np.ndarray:
    """Minimal Fibonacci LFSR — replicates MATLAB comm.PNSequence x^6+x+1."""
    reg = list(state)           # 6-bit register, all-ones init
    bits = []
    for _ in range(n):
        out = reg[-1]
        fb  = reg[-1] ^ reg[0]  # taps: x^6 + x + 1  (positions 6,1,0)
        reg = [fb] + reg[:-1]
        bits.append(out)
    return np.array(bits, dtype=np.int8)

# Half-preamble PN sequence: 48 ±1 symbols
_pn_half      = _lfsr_pn([6, 1, 0], [1]*6, Nhalf)
HALF_PREAMBLE = (2 * _pn_half - 1).astype(np.float64)
PREAMBLE_SYM  = np.concatenate([HALF_PREAMBLE, HALF_PREAMBLE])

# Pilot symbols (fixed random seed → reproducible across TX & RX)
_rng       = np.random.default_rng(seed=42)
PILOT_SYM  = (2 * _rng.integers(0, 2, size=Npilot) - 1).astype(np.float64)

# ── RRC filter ────────────────────────────────────────────────────────────────
def rrc_filter(rolloff: float, span: int, sps: int) -> np.ndarray:
    """
    Root-raised-cosine FIR coefficients (equivalent to MATLAB rcosdesign(...,'sqrt')).
    Length = span*sps + 1  (odd, symmetric).
    """
    N   = span * sps
    t   = np.arange(-N // 2, N // 2 + 1) / sps     # normalised time
    h   = np.zeros(len(t))
    for i, ti in enumerate(t):
        if ti == 0:
            h[i] = (1 + rolloff * (4/np.pi - 1))
        elif abs(ti) == 1 / (4 * rolloff):
            h[i] = (rolloff / np.sqrt(2)) * (
                (1 + 2/np.pi) * np.sin(np.pi / (4*rolloff))
                + (1 - 2/np.pi) * np.cos(np.pi / (4*rolloff))
            )
        else:
            num = np.sin(np.pi*ti*(1-rolloff)) + 4*rolloff*ti*np.cos(np.pi*ti*(1+rolloff))
            den = np.pi * ti * (1 - (4*rolloff*ti)**2)
            h[i] = num / den
    h /= np.sqrt(np.sum(h**2))     # unit energy normalisation
    return h

RRC = rrc_filter(rolloff, SpanRRC, sps)

# ── Convenience print ─────────────────────────────────────────────────────────
if __name__ == "__main__":
    T_half = Nhalf * sps / Fs
    print(f"Symbol rate      : {Rs:.2f} sym/s")
    print(f"Occupied BW      : {BW:.2f} Hz")
    print(f"Delay spread     : {delaySpread_ms} ms  →  {delaySpread_samp} samp  →  {delaySpread_samp/sps:.1f} sym")
    print(f"RRC group delay  : {RRC_DELAY} samp  ({RRC_DELAY/sps:.0f} sym)")
    print(f"chanSym (CP_sym) : {CP_sym}  ({CP_samp} samp)")
    print(f"Npilot/CP_sym    : {Npilot/CP_sym:.1f}×")
    print(f"Preamble (2×{Nhalf}): {Npreamble} sym  (±{1/(2*T_half):.1f} Hz coarse-CFO range)")
    print(f"Block layout     : [CP({CP_sym})|Pilot({Npilot})|CP({CP_sym})|Guard({Ndata_guard})|Data({Ndata})]  = {dataBlockLen} sym")
    print(f"Frame symbols    : {FRAME_SYMS}")
    print(f"Frame samples    : {FRAME_SYMS * sps}  (before RRC tail)")
    print(f"CFO model        : {CFO_START_HZ} → {CFO_END_HZ} Hz (ramping)")


# Runtime sample-rate override -------------------------------------------------
def reconfigure_fs(new_fs: int):
    """
    Update Fs and all derived module-level constants in place.
    Call this before transmit() / receive() when using a non-default sample rate.
    sps, rolloff, Npilot, Ndata, Nblocks, and the RRC filter are unchanged.
    """
    import sys
    m = sys.modules[__name__]
    m.Fs               = int(new_fs)
    m.Rs               = m.Fs / sps
    m.BW               = m.Rs * (1 + rolloff)
    m.delaySpread_samp = round(delaySpread_ms * 1e-3 * m.Fs)
    m.chanSamp         = m.delaySpread_samp + 2 * RRC_DELAY
    m.chanSym          = int(np.ceil(m.chanSamp / sps))
    m.CP_sym           = m.chanSym
    m.CP_samp          = m.CP_sym * sps
    m.dataBlockLen     = 2 * m.CP_sym + Npilot + Ndata_tx
    m.FRAME_SYMS       = Npreamble + Nblocks * m.dataBlockLen
