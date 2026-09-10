"""
TX chain for the LFM + PRBS + BPSK port (see lfm_bpsk_params.py's docstring
for the design decisions this follows). Ported from lfmBpskPopotoTx330_N152.m,
adapted to FAU's real-baseband (no software carrier mixing) convention.

Packet layout (real, baseband, samples at Fs):
    [ LFM chirp (N_lfm) | guard silence (N_guard) | RRC-shaped BPSK (train+data) ]

Multi-packet captures concatenate several such packets (one per frame_id),
each independently LFM-synced at RX -- see lfm_bpsk_common.py.
"""

import numpy as np

import lfm_bpsk_params as P
import bpsk_params as _base_params
import lfm_bpsk_frame as F

try:
    from dma_rx_sg_16m import pack_q15
    _HAS_DMA = True
except Exception:
    _HAS_DMA = False


def _fir_filter(h: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Causal FIR filter, output truncated to len(x). Matches bpsk_tx.py's helper."""
    return np.convolve(x, h)[:len(x)]


def generate_lfm() -> np.ndarray:
    """
    Real linear-chirp sounding burst, Tukey-tapered, unit peak amplitude.
    Baseband sweep from P.f1 to P.f2 over P.T_lfm seconds (see
    lfm_bpsk_params.py's header for why this is lowpass, not around Fc).
    """
    n = np.arange(P.N_lfm)
    t = n / P.Fs
    # Linear chirp: instantaneous frequency f(t) = f1 + (f2-f1)*t/T_lfm
    k = (P.f2 - P.f1) / P.T_lfm
    phase = 2 * np.pi * (P.f1 * t + 0.5 * k * t ** 2)
    lfm_raw = np.cos(phase)

    # Tukey window (matches Popoto's tukeywin(N, 0.1))
    win = _tukey_window(P.N_lfm, P.lfm_tukey_alpha)
    lfm = lfm_raw * win
    lfm = lfm / (np.max(np.abs(lfm)) + 1e-12)
    return lfm


def _tukey_window(n: int, alpha: float) -> np.ndarray:
    if alpha <= 0:
        return np.ones(n)
    if alpha >= 1:
        return np.hanning(n)
    x = np.linspace(0, 1, n)
    w = np.ones(n)
    edge = alpha / 2
    left = x < edge
    right = x > 1 - edge
    w[left] = 0.5 * (1 + np.cos(np.pi * (2 * x[left] / alpha - 1)))
    w[right] = 0.5 * (1 + np.cos(np.pi * (2 * x[right] / alpha - 2 / alpha + 1)))
    return w


def pulse_shape_symbols(syms: np.ndarray) -> np.ndarray:
    """
    Upsample + RRC pulse-shape a BPSK symbol sequence, reusing the existing
    system's RRC filter (bpsk_params.RRC, same rolloff/span/sps) so this
    stays compatible with the current matched-filter/RX chain. Appends
    SpanRRC zero symbols so the filter tail fully drains, matching
    bpsk_tx.pulse_shape()'s convention exactly.
    """
    guard = _base_params.SpanRRC
    sym_padded = np.concatenate([syms, np.zeros(guard)])
    up = np.zeros(len(sym_padded) * P.sps, dtype=np.float64)
    up[::P.sps] = sym_padded
    return _fir_filter(_base_params.RRC, up)


def build_packet_waveform(frame_id: int) -> dict:
    """
    Assemble one full [LFM | guard | RRC-shaped BPSK] packet for frame_id.

    LFM and the RRC-shaped BPSK section are peak-normalised INDEPENDENTLY
    (each to unit peak) rather than as one combined peak-normalised
    packet. The chirp is constant-envelope (Tukey-tapered), so its peak
    sits close to its own RMS; the RRC-shaped BPSK train has real PAPR
    from pulse shaping, so its raw peak (pre-normalisation) is only
    ~0.38x the chirp's -- a single packet-wide peak-normalisation lets
    the chirp set the whole packet's scale and leaves BPSK transmitted
    ~8-10dB below full scale (visibly confirmed on a real TX scope
    capture, 2026-08-28: LFM bursts read noticeably taller than the
    BPSK section between them). Independent normalisation puts BPSK -- the
    section that actually carries the payload -- at full DAC/PA scale
    like LFM, instead of leaving it under-driven. Safe to do: RX detects
    LFM via matched-filter xcorr against its own noise floor
    (detect_lfm_packets) and normalises the BPSK segment's own power
    before decoding (decode_packet's Stage 4 pwr-normalise) -- neither
    assumes a fixed LFM/BPSK amplitude ratio.

    Returns dict with:
      lfm         : (N_lfm,) the LFM burst alone (also useful as the RX
                    matched-filter reference)
      bpsk_shaped : (N_syms_total+span)*sps RRC-shaped BPSK waveform alone,
                    independently peak-normalised to unit peak
      packet      : full concatenated real waveform (each section unit-peak
                    on its own; the concatenation itself needs no further
                    normalisation since neither section can exceed 1.0)
      lfm_start   : sample index of LFM start within `packet` (always 0)
      bpsk_start  : sample index where the BPSK RRC-shaped section starts
                    within `packet`
    """
    lfm = generate_lfm()
    guard = np.zeros(P.N_guard, dtype=np.float64)
    syms = F.packet_syms(frame_id)
    bpsk_shaped = pulse_shape_symbols(syms)
    bpsk_shaped = bpsk_shaped / (np.max(np.abs(bpsk_shaped)) + 1e-12)

    packet = np.concatenate([lfm, guard, bpsk_shaped])

    return dict(
        lfm=lfm,
        bpsk_shaped=bpsk_shaped,
        packet=packet,
        lfm_start=0,
        bpsk_start=P.N_lfm + P.N_guard,
        frame_id=frame_id,
    )


def build_multi_frame_capture(frame_ids, inter_frame_silence: int = None) -> dict:
    """
    Concatenate several independently-LFM-synced packets into one capture,
    matching the existing multi-frame testing workflow. Each packet is
    peak-normalised on its own before concatenation (matches transmitting
    the same packet, replayed, rather than one waveform peak-normalised
    as a whole).

    inter_frame_silence defaults to P.N_guard samples of silence between
    packets (in addition to each packet's own trailing RRC flush), giving
    the LFM matched filter at RX a clean, isolated peak for each frame.
    """
    if inter_frame_silence is None:
        inter_frame_silence = P.N_guard

    pieces = []
    frame_meta = []
    cursor = 0
    for i, fid in enumerate(frame_ids):
        pkt = build_packet_waveform(fid)
        if i > 0:
            sil = np.zeros(inter_frame_silence, dtype=np.float64)
            pieces.append(sil)
            cursor += len(sil)
        frame_meta.append(dict(
            frame_id=fid,
            packet_start=cursor,
            lfm_start=cursor + pkt["lfm_start"],
            bpsk_start=cursor + pkt["bpsk_start"],
            packet_len=len(pkt["packet"]),
        ))
        pieces.append(pkt["packet"])
        cursor += len(pkt["packet"])

    capture = np.concatenate(pieces)
    return dict(capture=capture, frame_meta=frame_meta, frame_ids=list(frame_ids))


def pack_for_dma(waveform: np.ndarray) -> np.ndarray:
    """Real baseband -> Q15 uint32 DMA words (imag=0), matching bpsk_tx.pack_for_dma."""
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    imag_zero = np.zeros_like(waveform)
    return pack_q15(waveform, imag_zero)


def build_cyclic_tx_packet(n_frames: int, id_cycle: int, tx_scale: float = 1.0,
                            quiet_tx: bool = False, return_metadata: bool = False):
    """
    Build a cyclic SG MM2S TX packet of n_frames physical LFM+BPSK frames,
    cycling frame_id through range(id_cycle), for tx_iq_sg_cyclic style
    scripts. Mirrors the old frame_ids_tx.build_tx_packet() call pattern
    (tx_words, frame_words, frame_bits, meta) so the hardware driver
    calls (bpsk_dma / dma_tx_sg_16m) in the surrounding script don't need
    to change.

    Every physical frame has the SAME word length (LFM+guard+BPSK symbol
    counts don't depend on frame_id, only the data payload's content
    does) -- so frame_words is a single constant, as start_cyclic_mm2s
    expects. No extra inter-frame silence is inserted beyond each
    packet's own leading LFM+guard, matching how the existing frame
    format also relies on preamble/LFM detection alone for separation,
    not on an artificial gap.

    tx_scale is applied AFTER each packet is independently peak-
    normalised to +-1, matching the existing --tx-scale semantics
    (1.0 = full-scale Q15, no clipping; >1 deliberately clips for more
    average power given BPSK/RRC's PAPR).
    """
    frame_ids = [i % id_cycle for i in range(n_frames)]

    pkt0 = build_packet_waveform(0)
    frame_words = len(pkt0["packet"])  # constant across frame_ids

    pieces = []
    n_clipped = 0
    n_total = 0
    for fid in frame_ids:
        pkt = build_packet_waveform(fid)
        wave = pkt["packet"] * tx_scale
        n_clipped += int(np.sum(np.abs(wave) > 1.0))
        n_total += len(wave)
        wave = np.clip(wave, -1.0, 1.0)
        pieces.append(wave)

    capture = np.concatenate(pieces)
    tx_words = pack_for_dma(capture)

    frame_bits = P.N_data  # payload bits/frame (excludes the training preamble)

    if not quiet_tx:
        print("=== LFM+BPSK TX PACKET ===")
        print(f"  Frame ID cycle          : {id_cycle}")
        print(f"  Physical frames/packet  : {n_frames}")
        print(f"  Words / physical frame  : {frame_words}")
        print(f"  TX packet words         : {len(tx_words)}")
        print(f"  TX scale                : {tx_scale:g}")
        print(f"  Clipped samples         : {100.0 * n_clipped / max(n_total, 1):.2f} %")

    if not return_metadata:
        return tx_words, frame_words, frame_bits, None

    import zlib
    packet_bytes = tx_words.tobytes()
    packet_crc32 = zlib.crc32(packet_bytes)
    frame_crc32 = []
    for i in range(n_frames):
        start = i * frame_words
        stop = start + frame_words
        frame_crc32.append(zlib.crc32(tx_words[start:stop].tobytes()))

    meta = dict(
        frame_ids=frame_ids,
        packet_crc32=packet_crc32,
        frame_crc32=frame_crc32,
        first_words=[int(w) for w in tx_words[:8]],
        last_words=[int(w) for w in tx_words[-8:]],
        tx_scale=tx_scale,
        clipped_frac=n_clipped / max(n_total, 1),
    )
    return tx_words, frame_words, frame_bits, meta


if __name__ == "__main__":
    print(P.summary())
    print()
    pkt = build_packet_waveform(0)
    print(f"Single packet: {len(pkt['packet'])} samples "
          f"({len(pkt['packet'])/P.Fs*1e3:.1f} ms)  "
          f"lfm_start={pkt['lfm_start']} bpsk_start={pkt['bpsk_start']}")

    cap = build_multi_frame_capture(list(range(6)))
    print(f"6-frame capture: {len(cap['capture'])} samples "
          f"({len(cap['capture'])/P.Fs*1e3:.1f} ms)")
    for m in cap["frame_meta"]:
        print(f"  frame_id={m['frame_id']}  packet_start={m['packet_start']}  "
              f"lfm_start={m['lfm_start']}  bpsk_start={m['bpsk_start']}")
