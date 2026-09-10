"""
Shared, deterministic frame-content generators for the LFM+PRBS+BPSK port.
Both lfm_bpsk_tx.py and lfm_bpsk_rx.py/lfm_bpsk_common.py import from here
so TX and RX always agree on the training sequence and on what each
frame_id's data payload should contain (needed for BER scoring), without
any side-channel.

Matches Popoto's actual bit-generation approach (confirmed with the user):
a fixed-seed PRNG for the training sequence, and a per-frame PRNG for the
data payload -- NOT a true LFSR/maximal-length PRBS.
"""

import numpy as np

import lfm_bpsk_params as P
from common_frame_ids import block_marker_bytes  # reuse the existing A5 5A id ~id convention


def train_bits() -> np.ndarray:
    """Fixed-seed {0,1} training bits -- identical every call, TX and RX alike."""
    rng = np.random.default_rng(P.TRAIN_SEED)
    return rng.integers(0, 2, size=P.N_train).astype(np.uint8)


def train_syms() -> np.ndarray:
    return (2 * train_bits().astype(np.float64) - 1)


def data_bits(frame_id: int) -> np.ndarray:
    """
    200-bit data payload for a given frame_id: first 32 bits are the
    existing A5 5A id ~id marker (so RX can identify which frame this is
    and cross-check with block_marker_hamming-style scoring), remaining
    168 bits are a frame_id-seeded PRNG payload -- deterministic and
    reproducible by RX without needing the bits sent out-of-band.
    """
    marker = np.unpackbits(block_marker_bytes(int(frame_id)), bitorder="big")
    n_rest = P.N_data - len(marker)
    assert n_rest >= 0, "N_data too short to hold the frame-ID marker"
    rng = np.random.default_rng(1_000_003 + int(frame_id))  # frame_id-seeded, distinct from TRAIN_SEED
    rest = rng.integers(0, 2, size=n_rest).astype(np.uint8)
    return np.concatenate([marker, rest])


def data_syms(frame_id: int) -> np.ndarray:
    return (2 * data_bits(frame_id).astype(np.float64) - 1)


def packet_syms(frame_id: int) -> np.ndarray:
    """Full N_syms_total = N_train + N_data symbol sequence for one packet."""
    return np.concatenate([train_syms(), data_syms(frame_id)])
