"""
qpsk_params.py
==============
Shared system parameters for the QPSK Underwater Acoustic Transceiver.
Sibling to bpsk_params.py -- SAME frame geometry (two-half preamble, CP
length, pilot length, symbol counts per block, block count), reusing
bpsk_params directly for everything that is not payload-modulation-
specific: Fc/Fs/sps/rolloff/RRC design, CP/multipath sizing, the
two-half preamble PN sequence, and the pilot PN sequence.

Preamble and pilot stay real BPSK-modulated on purpose, unchanged from
bpsk_params.py -- they are sync/channel-estimation references, not
payload, so there is no reason to re-modulate them, exactly like the
LFM+QPSK port kept its LFM sounding burst and (there) chose a QPSK
training sequence only because that port's RX algorithm needed one
(see lfm_qpsk_rx.py's docstring). Keeping the pilot real here means
fine_cfo()/phase_track() in qpsk_rx.py need NO changes at all: a real
PILOT_SYM is its own conjugate, so `rx_pilot * P.PILOT_SYM` (bpsk_rx.py's
existing formula) is already correct and does not need the conj() fix
lfm_qpsk_rx.py needed for its genuinely-complex training sequence.

Design choice (confirmed with the user, 2026-08-31): keep Ndata=256
DATA SYMBOLS per block unchanged from the BPSK port, so the two frames
occupy identical on-air duration -- but since QPSK carries 2 bits/symbol,
each block's payload is 512 bits instead of BPSK's 256 (2048 total vs
1024), the same "match frame duration, not bit count" choice already
made for the LFM+QPSK port's N_data.

QPSK bit-to-symbol mapping matches lfm_qpsk_frame.py's qpsk_map()
exactly (Gray-coded, independent I/Q rails) so the codebase uses ONE
QPSK convention throughout: bit[2k]->I, bit[2k+1]->Q,
sym = (I + 1j*Q) / sqrt(2). Kept as its own copy here (not imported from
lfm_qpsk_frame.py) so this CP-FDE port has no dependency on the LFM port.
"""

import sys
import numpy as np

import bpsk_params as _base_params

# ----------------------------------------------------------------------
# Re-exported, UNCHANGED from bpsk_params -- none of this is payload-
# modulation-specific (carrier/sample-rate design, CP/multipath sizing,
# preamble/pilot sync references, RRC filter, frame geometry).
# ----------------------------------------------------------------------
Fc          = _base_params.Fc
Fs          = _base_params.Fs
rolloff     = _base_params.rolloff
sps         = _base_params.sps
SpanRRC     = _base_params.SpanRRC
Rs          = _base_params.Rs
BW          = _base_params.BW
RRC_DELAY   = _base_params.RRC_DELAY
RRC         = _base_params.RRC

delaySpread_ms = _base_params.delaySpread_ms
CP_sym      = _base_params.CP_sym
CP_samp     = _base_params.CP_samp

CFO_START_HZ = _base_params.CFO_START_HZ
CFO_END_HZ   = _base_params.CFO_END_HZ

Nhalf         = _base_params.Nhalf
Npreamble     = _base_params.Npreamble
HALF_PREAMBLE = _base_params.HALF_PREAMBLE
PREAMBLE_SYM  = _base_params.PREAMBLE_SYM

Npilot     = _base_params.Npilot
PILOT_SYM  = _base_params.PILOT_SYM

Ndata       = _base_params.Ndata          # 256 -- SYMBOL count/block, unchanged
Ndata_guard = _base_params.Ndata_guard
Ndata_tx    = _base_params.Ndata_tx
Nblocks     = _base_params.Nblocks

dataBlockLen = _base_params.dataBlockLen
FRAME_SYMS   = _base_params.FRAME_SYMS

# ----------------------------------------------------------------------
# QPSK-specific additions.
# ----------------------------------------------------------------------
bps_sym          = 2                        # QPSK: 2 bits/symbol
Ndata_bits       = Ndata * bps_sym          # 512 payload bits / block
Ndata_bits_total = Ndata_bits * Nblocks     # 2048 payload bits / frame

# Known complex guard symbol -- QPSK analogue of BPSK's real -1 guard.
# Under qpsk_map()'s convention this is bits (1,1): I=1-2*1=-1, Q=-1.
GUARD_SYM = complex(-1.0, -1.0) / np.sqrt(2.0)


def qpsk_map(bits: np.ndarray) -> np.ndarray:
    """
    Gray-coded QPSK bit-to-symbol mapper, identical convention to
    lfm_qpsk_frame.py's qpsk_map():
        bit[2k]   -> I of symbol k   (I = 1 - 2*b1)
        bit[2k+1] -> Q of symbol k   (Q = 1 - 2*b2)
        sym[k] = (I + 1j*Q) / sqrt(2)
    """
    bits = np.asarray(bits)
    assert len(bits) % 2 == 0, "Bit count must be even for QPSK mapping"
    b1 = bits[0::2].astype(np.float64)   # I rail
    b2 = bits[1::2].astype(np.float64)   # Q rail
    I = 1.0 - 2.0 * b1
    Q = 1.0 - 2.0 * b2
    return (I + 1j * Q) / np.sqrt(2.0)


def qpsk_demap_hard(syms: np.ndarray) -> np.ndarray:
    """
    Independent hard decision on each rail, inverse of qpsk_map() for the
    noiseless case: I<0 -> b1=1, Q<0 -> b2=1, interleaved bit[2k]/bit[2k+1].
    """
    syms = np.asarray(syms)
    b1 = (np.real(syms) < 0).astype(np.uint8)
    b2 = (np.imag(syms) < 0).astype(np.uint8)
    bits = np.empty(2 * len(syms), dtype=np.uint8)
    bits[0::2] = b1
    bits[1::2] = b2
    return bits


def summary() -> str:
    T_half = Nhalf * sps / Fs
    return (
        f"Symbol rate      : {Rs:.2f} sym/s\n"
        f"Occupied BW      : {BW:.2f} Hz\n"
        f"CP_sym           : {CP_sym}  ({CP_samp} samp)\n"
        f"Preamble (2x{Nhalf}): {Npreamble} sym  (+-{1/(2*T_half):.1f} Hz coarse-CFO range)\n"
        f"Block layout     : [CP({CP_sym})|Pilot({Npilot})|CP({CP_sym})|"
        f"Guard({Ndata_guard})|Data({Ndata})]  = {dataBlockLen} sym  x {Nblocks} blocks\n"
        f"Frame symbols    : {FRAME_SYMS}\n"
        f"bps_sym          : {bps_sym}\n"
        f"Ndata_bits/block : {Ndata_bits}\n"
        f"Ndata_bits_total : {Ndata_bits_total}\n"
        f"Guard symbol     : {GUARD_SYM:.4f}  (angle={np.angle(GUARD_SYM):+.4f} rad)"
    )


def reconfigure_fs(new_fs: int):
    """
    Update Fs and all derived module-level constants in place, delegating
    to bpsk_params.reconfigure_fs (the shared base module) first and then
    re-syncing this module's re-exported copies -- mirrors
    lfm_qpsk_params.reconfigure_fs's pattern. sps/rolloff/Ndata/Nblocks/
    Ndata_bits(_total) are unaffected (bit/symbol counts, not
    sample-rate-derived); PREAMBLE_SYM/PILOT_SYM/RRC are unaffected too
    (they only depend on sps/rolloff/SpanRRC/Nhalf/Npilot, not Fs).
    """
    _base_params.reconfigure_fs(new_fs)
    m = sys.modules[__name__]
    m.Fs           = _base_params.Fs
    m.Rs           = _base_params.Rs
    m.BW           = _base_params.BW
    m.CP_sym       = _base_params.CP_sym
    m.CP_samp      = _base_params.CP_samp
    m.dataBlockLen = _base_params.dataBlockLen
    m.FRAME_SYMS   = _base_params.FRAME_SYMS


if __name__ == "__main__":
    print(summary())
