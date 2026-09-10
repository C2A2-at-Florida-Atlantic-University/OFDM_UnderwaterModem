"""
TX chain for the LFM + PRBS + QPSK port (see lfm_qpsk_params.py's docstring
for the design decisions this follows). Ported from lfmQpskPopotoTx330.m,
adapted to FAU's real-baseband-with-hardware-NCO convention: unlike the
MATLAB reference (which mixes QPSK symbols up to a software carrier,
Fc=33kHz, and transmits a real passband WAV for Popoto's own hardware),
this port transmits the QPSK symbols as a COMPLEX baseband waveform and
lets the FPGA's DDS Compiler NCO (bpsk_dma.set_nco_frequency(), Fc=120kHz)
do the upconversion in hardware -- exactly the same division of labor the
BPSK port already uses, except BPSK's symbols were real (Q=0 on the DAC)
while QPSK's are genuinely complex, so BOTH DAC channels carry signal here.

Packet layout (complex, baseband, samples at Fs):
    [ LFM chirp (N_lfm, real, imag=0) | guard silence (N_guard) |
      RRC-shaped QPSK (train+data, complex) ]

Multi-packet captures concatenate several such packets (one per frame_id),
each independently LFM-synced at RX -- see lfm_qpsk_common.py.
"""

import numpy as np

import lfm_qpsk_params as P
import bpsk_params as _base_params
import lfm_qpsk_frame as F

try:
    from dma_rx_sg_16m import pack_q15
    _HAS_DMA = True
except Exception:
    _HAS_DMA = False


def _fir_filter(h: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Causal FIR filter, output truncated to len(x). Works for complex x
    and real h (ordinary elementwise convolution), matching bpsk_tx.py's
    helper and lfm_bpsk_tx.py's equivalent."""
    return np.convolve(x, h)[:len(x)]


def generate_lfm() -> np.ndarray:
    """
    Real linear-chirp sounding burst, Tukey-tapered, unit peak amplitude.
    Baseband sweep from P.f1 to P.f2 over P.T_lfm seconds. Identical
    design to lfm_bpsk_tx.py's generate_lfm() (kept as its own copy here,
    not imported, so this port stays self-contained/parallel).
    """
    n = np.arange(P.N_lfm)
    t = n / P.Fs
    k = (P.f2 - P.f1) / P.T_lfm
    phase = 2 * np.pi * (P.f1 * t + 0.5 * k * t ** 2)
    lfm_raw = np.cos(phase)

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
    Upsample + RRC pulse-shape a COMPLEX QPSK symbol sequence, reusing the
    existing system's RRC filter (bpsk_params.RRC, same rolloff/span/sps)
    so this stays compatible with the current matched-filter/RX chain.
    Appends SpanRRC zero symbols so the filter tail fully drains, matching
    lfm_bpsk_tx.py's pulse_shape_symbols()/bpsk_tx.py's pulse_shape()
    convention exactly -- generalized here to complex input/output.
    """
    guard = _base_params.SpanRRC
    sym_padded = np.concatenate([syms, np.zeros(guard, dtype=np.complex128)])
    up = np.zeros(len(sym_padded) * P.sps, dtype=np.complex128)
    up[::P.sps] = sym_padded
    return _fir_filter(_base_params.RRC, up)


_PAYLOAD_GAIN_CACHE = None


def _default_payload_gain() -> float:
    """
    Gain applied to the RRC-shaped QPSK section, AFTER its own unit-peak
    normalisation, so its RMS envelope matches the LFM chirp's RMS
    envelope.

    Independent peak normalisation (both sections at unit MODULUS) fixed
    the original problem -- see the "peak-normalised INDEPENDENTLY"
    history below -- but equal PEAKS still leave QPSK visibly smaller on
    a scope: the LFM chirp is constant-envelope (nearly every sample
    near its peak), while the RRC-pulse-shaped QPSK payload dips toward
    zero at symbol transitions, so it has a much higher peak-to-average
    ratio. Confirmed on hardware, 2026-09-01: with both sections peak-
    normalised to modulus 1.0, LFM's RMS/peak=0.68 vs QPSK's 0.54 -- a
    ~1.26x (+2 dB) RMS gap that reads as a visible size difference on
    scope even though the true peaks already match.

    This computes that ratio once from the reference (frame_id=0)
    waveforms and caches it -- the ratio is ~identical across frame_ids
    (QPSK's RMS varies by <0.1% frame-to-frame; the training preamble
    dominates and is fixed) so one cached scalar is applied to every
    packet built.
    """
    global _PAYLOAD_GAIN_CACHE
    if _PAYLOAD_GAIN_CACHE is None:
        lfm_rms = float(np.sqrt(np.mean(generate_lfm() ** 2)))
        ref_shaped = pulse_shape_symbols(F.packet_syms(0))
        ref_shaped = ref_shaped / (np.max(np.abs(ref_shaped)) + 1e-12)
        qpsk_rms = float(np.sqrt(np.mean(np.abs(ref_shaped) ** 2)))
        _PAYLOAD_GAIN_CACHE = lfm_rms / qpsk_rms
    return _PAYLOAD_GAIN_CACHE


def build_packet_waveform(frame_id: int, payload_gain: float = None) -> dict:
    """
    Assemble one full [LFM | guard | RRC-shaped QPSK] packet for frame_id.

    LFM and the RRC-shaped QPSK section are peak-normalised INDEPENDENTLY
    (each to unit peak COMPLEX MODULUS) rather than as one combined
    peak-normalised packet -- carrying forward the fix already applied to
    the BPSK port (see lfm_bpsk_tx.py's build_packet_waveform() docstring,
    2026-08-28/31): a single packet-wide peak normalization lets the
    constant-envelope LFM chirp set the whole packet's scale and leaves
    the pulse-shaped payload transmitted well below full scale. Doing this
    from the start here avoids re-discovering that issue on QPSK captures.

    On top of that, the QPSK section is then scaled by `payload_gain`
    (default: `_default_payload_gain()`, an RMS-matching factor -- see
    its docstring) and re-clipped to unit modulus (phase-preserving, via
    `_clip_complex_mag`) so its typical/RMS amplitude visually matches
    the LFM chirp's on a scope, not just its rare peak samples. This
    clips only the QPSK section's own highest-magnitude samples (a small
    fraction -- see `payload_clipped_frac` below); LFM is untouched.

    Returns dict with:
      lfm         : (N_lfm,) the LFM burst alone (real; also useful as the
                    RX matched-filter reference)
      qpsk_shaped : (N_syms_total+span)*sps RRC-shaped QPSK waveform alone
                    (complex), peak-normalised then RMS-matched to LFM
                    (see payload_gain above), modulus clipped to <=1.0
      packet      : full concatenated COMPLEX waveform (neither section
                    can exceed modulus 1.0, so no further normalisation
                    is needed)
      lfm_start   : sample index of LFM start within `packet` (always 0)
      qpsk_start  : sample index where the QPSK RRC-shaped section starts
                    within `packet`
      payload_gain         : the RMS-matching gain actually applied
      payload_clipped_frac : fraction of QPSK-section samples whose
                             modulus exceeded 1.0 after payload_gain and
                             were clipped (rare -- see docstring above)
    """
    lfm = generate_lfm().astype(np.complex128)  # real values, complex dtype (imag=0)
    guard = np.zeros(P.N_guard, dtype=np.complex128)
    syms = F.packet_syms(frame_id)
    qpsk_shaped = pulse_shape_symbols(syms)
    qpsk_shaped = qpsk_shaped / (np.max(np.abs(qpsk_shaped)) + 1e-12)

    if payload_gain is None:
        payload_gain = _default_payload_gain()
    qpsk_shaped = qpsk_shaped * payload_gain
    n_clipped = int(np.sum(np.abs(qpsk_shaped) > 1.0))
    payload_clipped_frac = n_clipped / max(len(qpsk_shaped), 1)
    qpsk_shaped = _clip_complex_mag(qpsk_shaped, 1.0)

    packet = np.concatenate([lfm, guard, qpsk_shaped])

    return dict(
        lfm=lfm,
        qpsk_shaped=qpsk_shaped,
        packet=packet,
        lfm_start=0,
        qpsk_start=P.N_lfm + P.N_guard,
        frame_id=frame_id,
        payload_gain=payload_gain,
        payload_clipped_frac=payload_clipped_frac,
    )


def build_multi_frame_capture(frame_ids, inter_frame_silence: int = None) -> dict:
    """
    Concatenate several independently-LFM-synced packets into one capture,
    matching lfm_bpsk_tx.py's build_multi_frame_capture() exactly (each
    packet independently normalised, inter_frame_silence defaults to
    P.N_guard samples between packets).
    """
    if inter_frame_silence is None:
        inter_frame_silence = P.N_guard

    pieces = []
    frame_meta = []
    cursor = 0
    for i, fid in enumerate(frame_ids):
        pkt = build_packet_waveform(fid)
        if i > 0:
            sil = np.zeros(inter_frame_silence, dtype=np.complex128)
            pieces.append(sil)
            cursor += len(sil)
        frame_meta.append(dict(
            frame_id=fid,
            packet_start=cursor,
            lfm_start=cursor + pkt["lfm_start"],
            qpsk_start=cursor + pkt["qpsk_start"],
            packet_len=len(pkt["packet"]),
        ))
        pieces.append(pkt["packet"])
        cursor += len(pkt["packet"])

    capture = np.concatenate(pieces)
    return dict(capture=capture, frame_meta=frame_meta, frame_ids=list(frame_ids))


def _clip_complex_mag(x: np.ndarray, limit: float = 1.0) -> np.ndarray:
    """
    Clip a complex waveform's MODULUS to `limit`, preserving phase --
    unlike np.clip() applied to real/imag independently, this doesn't
    distort the QPSK constellation's phase when it clips (a real/imag
    box-clip would bend a sample's phase toward the nearest axis instead
    of just capping its magnitude).
    """
    mag = np.abs(x)
    over = mag > limit
    if not np.any(over):
        return x
    out = x.copy()
    out[over] = x[over] / mag[over] * limit
    return out


def pack_for_dma(waveform: np.ndarray) -> np.ndarray:
    """
    Complex baseband -> Q15 uint32 DMA words. Unlike lfm_bpsk_tx.py's
    pack_for_dma() (which zeroes the imaginary/Q channel because BPSK
    symbols are real), QPSK genuinely needs both DAC channels: I=real(w),
    Q=imag(w), so the hardware NCO can do a proper complex upconversion.
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    return pack_q15(waveform.real, waveform.imag)


def build_cyclic_tx_packet(n_frames: int, id_cycle: int, tx_scale: float = 1.0,
                            quiet_tx: bool = False, return_metadata: bool = False):
    """
    Build a cyclic SG MM2S TX packet of n_frames physical LFM+QPSK frames,
    cycling frame_id through range(id_cycle). Mirrors
    lfm_bpsk_tx.build_cyclic_tx_packet()'s call pattern (tx_words,
    frame_words, frame_bits, meta) exactly.

    tx_scale is applied AFTER each packet is independently peak-normalised
    to unit modulus, matching the existing --tx-scale semantics (1.0 =
    full-scale Q15, no clipping; >1 deliberately clips for more average
    power given QPSK/RRC's PAPR). Clipping here caps each sample's
    COMPLEX MODULUS (see _clip_complex_mag), preserving phase.
    """
    frame_ids = [i % id_cycle for i in range(n_frames)]

    pkt0 = build_packet_waveform(0)
    frame_words = len(pkt0["packet"])  # constant across frame_ids
    payload_gain = pkt0["payload_gain"]

    pieces = []
    n_clipped = 0
    n_total = 0
    payload_clipped_frac_sum = 0.0
    for fid in frame_ids:
        pkt = build_packet_waveform(fid, payload_gain=payload_gain)
        payload_clipped_frac_sum += pkt["payload_clipped_frac"]
        wave = pkt["packet"] * tx_scale
        n_clipped += int(np.sum(np.abs(wave) > 1.0))
        n_total += len(wave)
        wave = _clip_complex_mag(wave, 1.0)
        pieces.append(wave)

    capture = np.concatenate(pieces)
    tx_words = pack_for_dma(capture)

    frame_bits = P.N_data_bits  # payload bits/frame (excludes the training preamble)
    payload_clipped_frac = payload_clipped_frac_sum / max(len(frame_ids), 1)

    if not quiet_tx:
        print("=== LFM+QPSK TX PACKET ===")
        print(f"  Frame ID cycle          : {id_cycle}")
        print(f"  Physical frames/packet  : {n_frames}")
        print(f"  Words / physical frame  : {frame_words}")
        print(f"  TX packet words         : {len(tx_words)}")
        print(f"  Payload gain (RMS-match): {payload_gain:.4f}  "
              f"(clipped {100.0 * payload_clipped_frac:.3f}% of QPSK-section "
              f"samples -- see build_packet_waveform() docstring)")
        print(f"  TX scale                : {tx_scale:g}")
        print(f"  Clipped samples (total) : {100.0 * n_clipped / max(n_total, 1):.2f} %")

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
        payload_gain=payload_gain,
        payload_clipped_frac=payload_clipped_frac,
    )
    return tx_words, frame_words, frame_bits, meta


if __name__ == "__main__":
    print(P.summary())
    print()
    pkt = build_packet_waveform(0)
    print(f"Single packet: {len(pkt['packet'])} samples "
          f"({len(pkt['packet'])/P.Fs*1e3:.1f} ms)  "
          f"lfm_start={pkt['lfm_start']} qpsk_start={pkt['qpsk_start']}")

    cap = build_multi_frame_capture(list(range(6)))
    print(f"6-frame capture: {len(cap['capture'])} samples "
          f"({len(cap['capture'])/P.Fs*1e3:.1f} ms)")
    for m in cap["frame_meta"]:
        print(f"  frame_id={m['frame_id']}  packet_start={m['packet_start']}  "
              f"lfm_start={m['lfm_start']}  qpsk_start={m['qpsk_start']}")
