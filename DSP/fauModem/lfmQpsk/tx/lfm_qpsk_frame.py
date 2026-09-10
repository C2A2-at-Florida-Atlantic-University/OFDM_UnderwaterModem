"""
Shared, deterministic frame-content generators for the LFM+PRBS+QPSK port.
Sibling to lfm_bpsk_frame.py -- same fixed-seed-training / per-frame-seeded-
payload design, generalized from 1 bit/symbol (BPSK, real +-1) to 2
bits/symbol (Gray-coded QPSK, complex (+-1+-1j)/sqrt(2)).

Both lfm_qpsk_tx.py and lfm_qpsk_rx.py/lfm_qpsk_common.py import from here
so TX and RX always agree on the training sequence and on what each
frame_id's data payload should contain (needed for BER scoring), without
any side-channel.
"""

import numpy as np

import lfm_qpsk_params as P
from common_frame_ids import block_marker_bytes  # reuse the existing A5 5A id ~id convention


def qpsk_map(bits: np.ndarray) -> np.ndarray:
    """
    Gray-coded QPSK bit-to-symbol mapper, matching the Popoto MATLAB
    convention exactly: two independent BPSK rails on I and Q.
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


def train_bits() -> np.ndarray:
    """Fixed-seed {0,1} training bits -- identical every call, TX and RX alike.
    N_bits_train = N_train*bps_sym = 2048 bits -> 1024 QPSK symbols."""
    rng = np.random.default_rng(P.TRAIN_SEED)
    return rng.integers(0, 2, size=P.N_bits_train).astype(np.uint8)


def train_syms() -> np.ndarray:
    return qpsk_map(train_bits())


def data_bits(frame_id: int) -> np.ndarray:
    """
    400-bit data payload for a given frame_id: first 32 bits are the
    existing A5 5A id ~id marker (so RX can identify which frame this is
    and cross-check with block_marker_hamming-style scoring), remaining
    368 bits are a frame_id-seeded PRNG payload -- deterministic and
    reproducible by RX without needing the bits sent out-of-band.
    """
    marker = np.unpackbits(block_marker_bytes(int(frame_id)), bitorder="big")
    n_rest = P.N_data_bits - len(marker)
    assert n_rest >= 0, "N_data_bits too short to hold the frame-ID marker"
    rng = np.random.default_rng(1_000_003 + int(frame_id))  # frame_id-seeded, distinct from TRAIN_SEED
    rest = rng.integers(0, 2, size=n_rest).astype(np.uint8)
    return np.concatenate([marker, rest])


def data_syms(frame_id: int) -> np.ndarray:
    """200 complex QPSK data symbols for a given frame_id."""
    return qpsk_map(data_bits(frame_id))


def packet_syms(frame_id: int) -> np.ndarray:
    """Full N_syms_total = N_train + N_data complex symbol sequence for one packet."""
    return np.concatenate([train_syms(), data_syms(frame_id)])
