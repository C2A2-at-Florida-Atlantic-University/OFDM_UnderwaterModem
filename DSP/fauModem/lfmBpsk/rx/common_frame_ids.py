"""
Shared frame-ID payload generation and capture analysis for external loopback.
"""

import numpy as np


import bpsk_params as P
from bpsk_tx import transmit
from bpsk_rx import receive, rx_frontend, rx_backend, rx_backend_batch
from dma_rx_sg_16m import pack_q15, unpack_int32, unpack_q15


def block_marker_bytes(frame_id: int) -> np.ndarray:
    return np.array([
        0xA5,
        0x5A,
        frame_id & 0xFF,
        (~frame_id) & 0xFF,
    ], dtype=np.uint8)


def block_marker_bits(frame_id: int) -> np.ndarray:
    return np.unpackbits(block_marker_bytes(frame_id), bitorder="big")


def make_payload_bits(frame_id: int, plain_counter: bool = False,
                      per_block_markers: bool = True) -> np.ndarray:
    frame_bits = P.Ndata * P.Nblocks
    n_bytes = (frame_bits + 7) // 8
    payload = np.arange(n_bytes, dtype=np.uint8)

    if not plain_counter:
        marker = block_marker_bytes(frame_id)
        if per_block_markers:
            block_bytes = P.Ndata // 8
            for block_idx in range(P.Nblocks):
                off = block_idx * block_bytes
                payload[off:off + len(marker)] = marker
        else:
            payload[:len(marker)] = marker

    return np.unpackbits(payload, bitorder="big")[:frame_bits]


def build_reference_bits(n_frames: int, plain_counter: bool = False,
                         per_block_markers: bool = True):
    return [
        make_payload_bits(
            frame_id,
            plain_counter=plain_counter,
            per_block_markers=per_block_markers,
        )
        for frame_id in range(int(n_frames))
    ]


def build_tx_packet(n_frames: int, plain_counter: bool = False,
                    quiet_tx: bool = False,
                    per_block_markers: bool = True):
    frame_bits = P.Ndata * P.Nblocks
    ref_bits_by_frame = []
    words_by_frame = []
    frame_words = None

    for frame_id in range(int(n_frames)):
        bits = make_payload_bits(
            frame_id,
            plain_counter=plain_counter,
            per_block_markers=per_block_markers,
        )
        ref_bits_by_frame.append(bits)
        tx_result = transmit(bits, verbose=(frame_id == 0 and not quiet_tx))
        tx_pb = tx_result["tx_pb"]
        words = pack_q15(tx_pb, np.zeros_like(tx_pb))
        words_by_frame.append(words)

        if frame_words is None:
            frame_words = len(words)
        elif frame_words != len(words):
            raise RuntimeError("TX frame length changed between frames")

    tx_words = np.concatenate(words_by_frame).astype(np.uint32, copy=False)
    return tx_words, frame_words, ref_bits_by_frame, frame_bits


def build_synthetic_capture(n_frames: int, rx_format: str = "int32",
                            plain_counter: bool = False,
                            per_block_markers: bool = True,
                            quiet_tx: bool = True):
    """
    Build a synthetic raw capture in the same uint32 file format RX analyzes.

    rx_format="q15" matches the IQ ADC packed format: one complex sample per word.
    rx_format="int32" is kept only for legacy real-only captures: one signed real
    sample per 32-bit word.
    """
    frame_bits = P.Ndata * P.Nblocks
    ref_bits_by_frame = []
    words_by_frame = []
    frame_words = None

    for frame_id in range(int(n_frames)):
        bits = make_payload_bits(
            frame_id,
            plain_counter=plain_counter,
            per_block_markers=per_block_markers,
        )
        ref_bits_by_frame.append(bits)
        tx_result = transmit(bits, verbose=(frame_id == 0 and not quiet_tx))
        tx_pb = tx_result["tx_pb"]

        if rx_format == "q15":
            words = pack_q15(tx_pb, np.zeros_like(tx_pb))
        elif rx_format == "int32":
            words = np.clip(
                np.round(tx_pb * 32767.0),
                -2147483648,
                2147483647,
            ).astype(np.int32).view(np.uint32)
        else:
            raise ValueError(f"unsupported synthetic rx_format: {rx_format}")

        words_by_frame.append(words)
        if frame_words is None:
            frame_words = len(words)
        elif frame_words != len(words):
            raise RuntimeError("synthetic frame length changed between frames")

    rx_words = np.concatenate(words_by_frame).astype(np.uint32, copy=False)
    return rx_words, frame_words, ref_bits_by_frame, frame_bits


def bits_to_bytes(bits: np.ndarray) -> np.ndarray:
    n = (len(bits) // 8) * 8
    if n <= 0:
        return np.array([], dtype=np.uint8)
    return np.packbits(bits[:n].astype(np.uint8), bitorder="big")


def byte_hamming(a: int, b: int) -> int:
    return bin((int(a) ^ int(b)) & 0xFF).count("1")


def decode_marker_id(rx_bytes: np.ndarray, n_ids: int) -> tuple:
    """
    Decode the explicit frame marker: A5 5A id ~id.

    Returns (marker_id, marker_exact, id_pair_exact). marker_id is accepted
    when the ID byte and inverse-ID byte are self-consistent, even if the
    fixed A5 5A marker prefix has bit errors. This keeps frame-ID continuity
    separate from marker/header corruption diagnostics.
    """
    if len(rx_bytes) < 4:
        return None, False, False

    b0, b1, b2, b3 = [int(v) & 0xFF for v in rx_bytes[:4]]
    marker_prefix_ok = (b0 == 0xA5 and b1 == 0x5A)
    id_pair_exact = ((b2 ^ b3) == 0xFF) and (b2 < int(n_ids))
    if not id_pair_exact:
        return None, False, False

    marker_id = b2
    marker_exact = marker_prefix_ok and b3 == ((~marker_id) & 0xFF)
    return marker_id, marker_exact, True


def marker_hamming_score(rx_bytes: np.ndarray, frame_id: int) -> int:
    if len(rx_bytes) < 4:
        return 32
    ref = [0xA5, 0x5A, frame_id & 0xFF, (~frame_id) & 0xFF]
    return sum(byte_hamming(int(rx_bytes[i]), ref[i]) for i in range(4))


def best_marker_score(rx_bytes: np.ndarray, n_ids: int) -> tuple:
    scores = [marker_hamming_score(rx_bytes, i) for i in range(int(n_ids))]
    frame_id = int(np.argmin(scores))
    return frame_id, int(scores[frame_id])


def block_error_counts(rx_bits: np.ndarray, ref_bits: np.ndarray) -> list:
    """Return bit errors in each BPSK data block."""
    counts = []
    for block_idx in range(P.Nblocks):
        start = block_idx * P.Ndata
        stop = start + P.Ndata
        counts.append(int(np.sum(rx_bits[start:stop] != ref_bits[start:stop])))
    return counts


def reference_aided_block_polarity(rx_bits: np.ndarray,
                                   ref_bits: np.ndarray) -> dict:
    """
    Diagnostic correction for 180-degree BPSK ambiguity per data block.

    This uses the known reference bits, so it is not a blind receiver decision.
    It is useful here because the external-loopback test already has the TX
    payload and needs to separate DMA/continuity faults from demodulator sign
    ambiguity at block boundaries.
    """
    corrected = rx_bits.copy()
    raw_counts = []
    corrected_counts = []
    flipped_blocks = []

    for block_idx in range(P.Nblocks):
        start = block_idx * P.Ndata
        stop = start + P.Ndata
        raw_block = rx_bits[start:stop]
        ref_block = ref_bits[start:stop]
        raw_err = int(np.sum(raw_block != ref_block))
        inv_err = int(np.sum((1 - raw_block) != ref_block))

        raw_counts.append(raw_err)
        if inv_err < raw_err:
            corrected[start:stop] = 1 - raw_block
            corrected_counts.append(inv_err)
            flipped_blocks.append(block_idx)
        else:
            corrected_counts.append(raw_err)

    return dict(
        bits=corrected,
        raw_counts=raw_counts,
        corrected_counts=corrected_counts,
        raw_err=int(sum(raw_counts)),
        corrected_err=int(sum(corrected_counts)),
        flipped_blocks=flipped_blocks,
    )


def block_marker_hamming(rx_bits: np.ndarray, frame_id: int,
                         block_idx: int) -> int:
    marker = block_marker_bits(frame_id)
    start = int(block_idx) * P.Ndata
    stop = start + len(marker)
    if stop > len(rx_bits):
        return len(marker)
    return int(np.sum(rx_bits[start:stop] != marker))


def block_marker_total_hamming(rx_bits: np.ndarray, frame_id: int,
                               per_block_markers: bool = True) -> int:
    n_blocks = P.Nblocks if per_block_markers else 1
    return int(sum(
        block_marker_hamming(rx_bits, frame_id, block_idx)
        for block_idx in range(n_blocks)
    ))


def best_block_marker_score(rx_bits: np.ndarray, n_ids: int,
                            per_block_markers: bool = True) -> tuple:
    scores = [
        block_marker_total_hamming(
            rx_bits, frame_id, per_block_markers=per_block_markers)
        for frame_id in range(int(n_ids))
    ]
    frame_id = int(np.argmin(scores))
    return frame_id, int(scores[frame_id])


def block_marker_id_confident(score: int, per_block_markers: bool = True) -> bool:
    """
    Decide whether the repeated block marker is good enough to carry frame ID.

    Each marker is 32 known bits. With per-block markers enabled, the same
    marker appears in all four data blocks, so a small number of bit errors
    should not hide the decoded frame ID.
    """
    n_blocks = P.Nblocks if per_block_markers else 1
    return int(score) <= max(4, 4 * n_blocks)


def apply_block_marker_polarity(rx_bits: np.ndarray, frame_id: int,
                                per_block_markers: bool = True) -> dict:
    """
    Blind block-polarity correction using only known block marker bits.

    This is not a payload-reference BER correction. It only checks the local
    marker inserted at the start of each data block.
    """
    corrected = rx_bits.copy()
    marker_err = []
    flipped_blocks = []
    n_blocks = P.Nblocks if per_block_markers else 1

    for block_idx in range(n_blocks):
        start = block_idx * P.Ndata
        stop = start + P.Ndata
        raw_block = corrected[start:stop]
        raw_err = block_marker_hamming(corrected, frame_id, block_idx)

        inv_bits = corrected.copy()
        inv_bits[start:stop] = 1 - raw_block
        inv_err = block_marker_hamming(inv_bits, frame_id, block_idx)

        if inv_err < raw_err:
            corrected[start:stop] = 1 - raw_block
            marker_err.append(inv_err)
            flipped_blocks.append(block_idx)
        else:
            marker_err.append(raw_err)

    return dict(
        bits=corrected,
        marker_err=marker_err,
        marker_err_total=int(sum(marker_err)),
        flipped_blocks=flipped_blocks,
    )


def adaptive_adjust_values(base_adjust: int, span: int, step: int) -> list:
    span = max(0, int(span))
    step = max(1, int(step))
    vals = list(range(int(base_adjust) - span, int(base_adjust) + span + 1, step))
    if int(base_adjust) not in vals:
        vals.append(int(base_adjust))
    return sorted(set(vals), key=lambda v: (abs(v - int(base_adjust)), v))


def fractional_adjust_values(center_adjust: float, span: float, step: float) -> list:
    span = max(0.0, float(span))
    step = max(1e-6, float(step))
    n_steps = int(np.floor((2.0 * span) / step + 0.5))
    start = float(center_adjust) - span
    vals = [start + i * step for i in range(n_steps + 1)]
    vals.append(float(center_adjust))
    rounded = sorted(set(round(v, 6) for v in vals),
                     key=lambda v: (abs(v - float(center_adjust)), v))
    return rounded


def parse_size_bytes(spec: str) -> int:
    text = str(spec).strip().lower()
    mult = 1
    for suffix, value in (
        ("gib", 1024 ** 3),
        ("gb", 1024 ** 3),
        ("mib", 1024 ** 2),
        ("mb", 1024 ** 2),
        ("kib", 1024),
        ("kb", 1024),
    ):
        if text.endswith(suffix):
            mult = value
            text = text[:-len(suffix)]
            break
    return int(float(text) * mult)


def parse_sweep(spec: str):
    parts = [int(p) for p in str(spec).split(":")]
    if len(parts) not in (2, 3):
        raise ValueError("sweep must be START:STOP[:STEP]")
    start, stop = parts[0], parts[1]
    step = parts[2] if len(parts) == 3 else 1
    if step == 0:
        raise ValueError("sweep step must not be 0")
    if (stop - start) * step < 0:
        raise ValueError("sweep step sign does not move toward stop")
    return list(range(start, stop + (1 if step > 0 else -1), step))


def estimate_frame_offset_words(raw_path: str, frame_words: int, args,
                                nominal_sync_start: int = 228,
                                probe_frames: int = 3) -> int:
    """
    Estimate where the first complete BPSK frame starts in a continuous file.

    For aligned captures the RX sync point is usually at nominal_sync_start.
    If RX started in the middle of a continuously running TX stream, the sync
    peak moves later by the number of samples from file start to the next frame.
    """
    probe_words = int(frame_words) * max(2, int(probe_frames))
    words = np.fromfile(raw_path, dtype=np.uint32, count=probe_words)
    if len(words) < int(frame_words):
        raise RuntimeError("capture file is too short to estimate frame offset")

    if args.rx_format == "q15":
        rx_real, rx_imag = unpack_q15(words)
        rx_real = rx_real + 1j * rx_imag
    else:
        rx_real = unpack_int32(words)

    res = receive(
        rx_real,
        data_bits_ref=None,
        snr_db=args.snr,
        verbose=False,
        start_adjust_samp=0,
        equalizer=getattr(args, "equalizer", "direct"),
        guard_phase_correct=bool(getattr(args, "guard_phase_correct", False)),
        pilot_reg=float(getattr(args, "pilot_reg", 0.0)),
        analytic_input=bool(getattr(args, "analytic_input", False)),
        sample_ppm=float(getattr(args, "sample_ppm", 0.0)),
    )
    sync_start = int(res["sync_startSamp"])
    return (sync_start - int(nominal_sync_start)) % int(frame_words)


def preamble_confidence(rx_result: dict) -> tuple:
    xcorr = np.asarray(rx_result["xcorr_pow"])
    peak = float(np.max(xcorr)) if len(xcorr) else 0.0
    floor = float(np.median(xcorr)) if len(xcorr) else 0.0
    ratio = peak / (floor + 1e-30)
    return peak, floor, ratio


def local_preamble_from_xcorr(rx_result: dict, expected_sync: int,
                              local_radius: int) -> tuple:
    """
    Pick the best preamble peak near the expected boundary.

    The normal RX sync returns the strongest peak in the full search window.
    For continuous captures that can be the next frame's preamble. This helper
    instead asks whether a valid local two-half preamble exists near the
    expected frame.

    The preamble is two identical halves. A single-peak search is ambiguous:
    the first-half peak is exactly Nhalf*sps samples before the second-half
    peak, so choosing the largest local peak can shift the frame by one
    preamble half. Score the pair and return the second-half peak, matching
    bpsk_rx.sync().
    """
    xcorr = np.asarray(rx_result["xcorr_pow"])
    floor = float(np.median(xcorr)) if len(xcorr) else 0.0
    if len(xcorr) == 0:
        return int(expected_sync), 0.0, floor, 0.0

    half_samp = P.Nhalf * P.sps
    shaped_len = half_samp
    expected_second_peak = (
        int(expected_sync)
        + (shaped_len - 1)
        + half_samp
        - int(P.RRC_DELAY)
    )

    lo = max(half_samp, expected_second_peak - int(local_radius))
    hi = min(len(xcorr), expected_second_peak + int(local_radius) + 1)
    if hi <= lo:
        return int(expected_sync), 0.0, floor, 0.0

    c2 = np.arange(lo, hi, dtype=np.int64)
    pair_score = xcorr[c2 - half_samp] + xcorr[c2]
    peak_idx = int(c2[int(np.argmax(pair_score))])
    peak = float(pair_score[int(np.argmax(pair_score))])
    detected_sync = (
        peak_idx
        - (shaped_len - 1)
        - half_samp
        + int(P.RRC_DELAY)
    )
    ratio = peak / (floor + 1e-30)
    return int(detected_sync), peak, floor, ratio


def analyze_capture(raw_path: str, frame_words: int, ref_bits_by_frame,
                    args, expected_raw_words=None,
                    print_frames: bool = True,
                    write_report: bool = True) -> dict:
    frame_offset_words = int(getattr(args, "frame_offset_words", 0))
    if frame_offset_words < 0:
        raise ValueError("frame_offset_words must be >= 0")

    frame_bits = len(ref_bits_by_frame[0])
    words = np.fromfile(raw_path, dtype=np.uint32)
    available_words = max(0, len(words) - frame_offset_words)
    full_frames = available_words // frame_words
    max_frames = getattr(args, "max_frames", None)
    if max_frames is not None and max_frames > 0:
        full_frames = min(full_frames, int(max_frames))

    if expected_raw_words is None:
        expected_raw_words = len(words)
    expected_after_offset = max(0, int(expected_raw_words) - frame_offset_words)
    expected_full_frames = expected_after_offset // frame_words
    trailing_words = available_words - full_frames * frame_words

    if args.rx_format == "q15":
        rx_real, rx_imag = unpack_q15(words)
        rx_real = rx_real + 1j * rx_imag
    else:
        rx_real = unpack_int32(words)

    track_preamble = bool(getattr(args, "track_preamble", True))
    per_block_markers = (
        not bool(getattr(args, "plain_counter", False))
        and not bool(getattr(args, "legacy_single_marker", False))
    )
    track_radius = int(getattr(args, "track_search_words", 4096))
    if track_radius < 0:
        raise ValueError("track_search_words must be >= 0")
    preamble_min_ratio = float(getattr(args, "preamble_min_ratio", 6.0))
    preamble_lock_tolerance = int(getattr(args, "preamble_lock_tolerance", 384))
    if preamble_lock_tolerance < 0:
        raise ValueError("preamble_lock_tolerance must be >= 0")
    preamble_local_radius = int(getattr(
        args, "preamble_local_radius", preamble_lock_tolerance))
    if preamble_local_radius < 0:
        raise ValueError("preamble_local_radius must be >= 0")

    total_err = 0
    total_err_block_polarity = 0
    total_bits = 0
    total_evm_sq = 0.0
    total_evm_n = 0
    marker_exact_ok = 0
    frame_id_exact_ok = 0
    block_marker_id_ok = 0
    block_marker_score_total = 0
    marker_prefix_exact_ok = 0
    inv_id_exact_ok = 0
    marker_prefix_bit_errors_total = 0
    frame_id_bit_errors_total = 0
    inv_id_bit_errors_total = 0
    decoded_ids = []
    frame_timeline = []
    frame_ber_timeline = []
    frame_ber_block_polarity_timeline = []
    block_polarity_flips_total = 0
    block_marker_polarity_flips_total = 0
    sequence_anchor_idx = None
    sequence_anchor_id = None
    marker_sequence_ok = True
    rows = []
    skipped_no_preamble = 0
    frame_rms_values = []
    frame_err_values = []
    timing_lock_enabled = bool(getattr(args, "timing_lock", True))
    timing_lock_min_frames = int(getattr(args, "timing_lock_frames", 4))
    timing_lock_max_errors = int(getattr(args, "timing_lock_max_errors", 0))
    timing_lock_span = float(getattr(args, "timing_lock_span", 1.0))
    timing_lock_adjust = None
    timing_lock_candidates = []

    next_frame_start = frame_offset_words

    for capture_idx in range(full_frames):
        predicted_start = next_frame_start if track_preamble else (
            frame_offset_words + capture_idx * frame_words)

        if track_preamble:
            window_start = max(0, predicted_start - track_radius)
            word_stop = min(len(rx_real), predicted_start + frame_words + track_radius)
            if word_stop <= window_start:
                break
            rx_search = rx_real[window_start:word_stop]
        else:
            window_start = predicted_start
            word_stop = predicted_start + frame_words
            if word_stop > len(rx_real):
                break
            rx_search = rx_real[window_start:word_stop]

        if word_stop > len(rx_real):
            break

        sync_result = receive(
            rx_search,
            data_bits_ref=None,
            snr_db=args.snr,
            verbose=getattr(args, "verbose_rx_pipeline", False),
            start_adjust_samp=0,
            equalizer=getattr(args, "equalizer", "direct"),
            guard_phase_correct=bool(getattr(args, "guard_phase_correct", False)),
            pilot_reg=float(getattr(args, "pilot_reg", 0.0)),
            analytic_input=bool(getattr(args, "analytic_input", False)),
            sample_ppm=float(getattr(args, "sample_ppm", 0.0)),
        )
        wide_peak, wide_floor, wide_ratio = preamble_confidence(sync_result)
        if track_preamble:
            nominal_sync = int(getattr(args, "nominal_sync_start", 228))
            expected_sync = int(predicted_start - window_start + nominal_sync)
            wide_detected_sync = int(sync_result["sync_startSamp"])
            wide_sync_error = wide_detected_sync - expected_sync
            detected_sync, sync_peak, sync_floor, sync_ratio = (
                local_preamble_from_xcorr(
                    sync_result, expected_sync, preamble_local_radius))
            sync_error = detected_sync - expected_sync
            preamble_locked = abs(sync_error) <= preamble_lock_tolerance
            if preamble_locked:
                word_start = int(window_start + detected_sync - nominal_sync)
                word_start = max(0, word_start)
                next_frame_start = word_start + frame_words
            else:
                word_start = predicted_start
                next_frame_start = predicted_start + frame_words
        else:
            word_start = predicted_start
            expected_sync = int(getattr(args, "nominal_sync_start", 228))
            detected_sync = int(sync_result["sync_startSamp"])
            wide_detected_sync = detected_sync
            wide_sync_error = detected_sync - expected_sync
            sync_peak, sync_floor, sync_ratio = wide_peak, wide_floor, wide_ratio
            sync_error = detected_sync - expected_sync
            preamble_locked = True

        raw_probe = rx_real[word_start:min(len(rx_real), word_start + frame_words)]
        raw_rms = float(np.sqrt(np.mean(np.abs(raw_probe) ** 2))) if len(raw_probe) else 0.0
        raw_peak = float(np.max(np.abs(raw_probe))) if len(raw_probe) else 0.0

        if sync_ratio < preamble_min_ratio or not preamble_locked:
            skipped_no_preamble += 1
            frame_timeline.append("M")
            frame_ber_timeline.append(1.0)
            frame_ber_block_polarity_timeline.append(1.0)
            frame_rms_values.append(raw_rms)
            frame_err_values.append(frame_bits)
            rows.append((
                capture_idx,
                word_start,
                detected_sync,
                f"{sync_ratio:.3f}",
                f"{sync_peak:.6g}",
                -1,
                frame_bits,
                frame_bits,
                1.0,
                0.0,
                "NO_PREAMBLE",
                False,
                False,
                False,
                False,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                "",
                -1,
                -1,
                -1,
                False,
                "",
                "",
                f"{raw_rms:.6g}",
                f"{raw_peak:.6g}",
                frame_bits,
                1.0,
                "",
                "",
                "",
            ))
            if print_frames:
                print(f"[ana] Frame {capture_idx:05d} word={word_start} "
                      f"preamble=MISS sync_ratio={sync_ratio:.2f} "
                      f"sync_err={sync_error:+d} "
                      f"wide_sync_err={wide_sync_error:+d} "
                      f"(min ratio {preamble_min_ratio:.2f})")
            continue

        frame_stop = word_start + frame_words
        if frame_stop > len(rx_real):
            break
        tail_context = int(getattr(
            args, "rx_tail_context_samples", 2 * int(P.RRC_DELAY)))
        tail_context = max(0, tail_context)
        rx_frame = rx_real[word_start:min(len(rx_real), frame_stop + tail_context)]
        raw_rms = float(np.sqrt(np.mean(np.abs(rx_frame) ** 2)))
        raw_peak = float(np.max(np.abs(rx_frame))) if len(rx_frame) else 0.0
        frame_sync_override = (
            int(getattr(args, "nominal_sync_start", 228))
            if track_preamble else None
        )

        # Timing-independent front-end (matched filter + sync + coarse CFO)
        # computed ONCE per frame and reused across every timing candidate.
        # This is the main optimization: the original code re-ran these
        # expensive stages inside each evaluate_adjust() call. compute_xcorr
        # is False because the per-candidate path never reads xcorr_pow (the
        # wide preamble search above already used it); when there is no sync
        # override rx_frontend still computes the correlation it needs to
        # locate the preamble.
        frame_front = rx_frontend(
            rx_frame,
            sync_start_override=frame_sync_override,
            analytic_input=bool(getattr(args, "analytic_input", False)),
            sample_ppm=float(getattr(args, "sample_ppm", 0.0)),
            compute_xcorr=False,
        )

        expected_marker_id = None
        if sequence_anchor_idx is not None:
            expected_marker_id = (
                sequence_anchor_id
                + capture_idx
                - sequence_anchor_idx
            ) % len(ref_bits_by_frame)

        base_adjust = (
            float(timing_lock_adjust)
            if timing_lock_adjust is not None
            else float(args.start_adjust_samples)
        )
        if timing_lock_adjust is not None:
            if timing_lock_span > 0:
                adjust_values = fractional_adjust_values(
                    base_adjust,
                    timing_lock_span,
                    float(getattr(args, "fractional_timing_step", 0.25)),
                )
            else:
                adjust_values = [base_adjust]
        elif bool(getattr(args, "adaptive_timing", True)):
            adjust_values = adaptive_adjust_values(
                int(round(base_adjust)),
                int(getattr(args, "adaptive_timing_span", 6)),
                int(getattr(args, "adaptive_timing_step", 1)),
            )
        else:
            adjust_values = [base_adjust]

        best_candidate = None
        candidate_list = []

        # Per-frame demod cache: adjust (rounded) -> (rx_bits, rx_track, rx_data).
        # The timing-independent front-end is shared; the timing-dependent
        # back-end is computed for many candidates at once by rx_backend_batch
        # and results are memoized so each unique adjust is demodulated once.
        # rx_data (pre-hard-decision equalised symbols) rides along for the EVM
        # SNR measurement; it does not affect bit/timing selection.
        _demod_cache = {}

        def _ensure_demod(adjusts):
            missing = []
            seen = set()
            for a in adjusts:
                key = round(float(a), 6)
                if key not in _demod_cache and key not in seen:
                    seen.add(key)
                    missing.append(float(a))
            if not missing:
                return
            batch = rx_backend_batch(
                frame_front,
                missing,
                snr_db=args.snr,
                equalizer=getattr(args, "equalizer", "direct"),
                guard_phase_correct=bool(getattr(args, "guard_phase_correct", False)),
                pilot_reg=float(getattr(args, "pilot_reg", 0.0)),
            )
            batch_bits = batch["rx_bits"]
            batch_track = batch["rx_track"]
            batch_data = batch["rx_data"]
            for i, a in enumerate(missing):
                _demod_cache[round(float(a), 6)] = (
                    batch_bits[i], batch_track[i], batch_data[i])

        def evaluate_adjust(selected_adjust):
            # Reuse the per-frame front-end and the batched back-end results;
            # only the cheap Python scoring runs per candidate here.
            _ensure_demod([selected_adjust])
            rx_bits_full, rx_track, rx_data_full = _demod_cache[
                round(float(selected_adjust), 6)]
            # rx_result carries only rx_track: the sole field the caller reads
            # from a candidate's result (the CP-timing score).
            rx_result = {"rx_track": rx_track}
            rx_bits = rx_bits_full[:frame_bits].astype(np.uint8)
            rx_data = rx_data_full[:frame_bits]
            rx_bytes = bits_to_bytes(rx_bits)

            errs_by_id = [
                int(np.sum(rx_bits != ref_bits_by_frame[i]))
                for i in range(len(ref_bits_by_frame))
            ]
            best_match_id = int(np.argmin(errs_by_id))
            marker_id, marker_exact_from_header, marker_id_self_consistent = (
                decode_marker_id(rx_bytes, len(ref_bits_by_frame))
            )

            if args.plain_counter:
                marker_score = 0
                score_payload_err = min(errs_by_id)
                marker_penalty = 0
            elif expected_marker_id is not None:
                if per_block_markers:
                    marker_score = block_marker_total_hamming(
                        rx_bits, expected_marker_id, per_block_markers=True)
                    marker_score_id = expected_marker_id
                else:
                    marker_score = marker_hamming_score(
                        rx_bytes, expected_marker_id)
                    marker_score_id = expected_marker_id
                score_payload_err = errs_by_id[expected_marker_id]
                marker_penalty = 0 if marker_score == 0 else 1
            else:
                if per_block_markers:
                    marker_score_id, marker_score = best_block_marker_score(
                        rx_bits, len(ref_bits_by_frame), per_block_markers=True)
                else:
                    marker_score_id, marker_score = best_marker_score(
                        rx_bytes, len(ref_bits_by_frame))
                score_payload_err = errs_by_id[marker_score_id]
                marker_penalty = 0 if marker_score == 0 else 1

            timing_score_mode = str(getattr(args, "timing_score", "payload"))
            if timing_score_mode == "payload":
                score = (
                    score_payload_err,
                    min(errs_by_id),
                    marker_score,
                    marker_penalty,
                    abs(float(selected_adjust) - base_adjust),
                )
            elif timing_score_mode == "marker":
                score = (
                    marker_score,
                    marker_penalty,
                    abs(float(selected_adjust) - base_adjust),
                    score_payload_err,
                )
            else:
                raise ValueError(f"unknown timing_score: {timing_score_mode}")
            return dict(
                score=score,
                selected_adjust=float(selected_adjust),
                rx_result=rx_result,
                rx_bits=rx_bits,
                rx_data=rx_data,
                rx_bytes=rx_bytes,
                errs_by_id=errs_by_id,
                best_match_id=best_match_id,
                marker_id=marker_id,
                marker_exact_from_header=marker_exact_from_header,
                marker_id_self_consistent=marker_id_self_consistent,
                marker_score=marker_score,
                marker_score_id=marker_score_id if not args.plain_counter else best_match_id,
            )

        _ensure_demod(adjust_values)
        for selected_adjust in adjust_values:
            candidate = evaluate_adjust(selected_adjust)
            candidate_list.append(candidate)
            if best_candidate is None or candidate["score"] < best_candidate["score"]:
                best_candidate = candidate

        if (bool(getattr(args, "fractional_timing", True))
                and best_candidate is not None):
            frac_values = fractional_adjust_values(
                best_candidate["selected_adjust"],
                float(getattr(args, "fractional_timing_span", 1.0)),
                float(getattr(args, "fractional_timing_step", 0.25)),
            )
            tried = set(round(float(v), 6) for v in adjust_values)
            _ensure_demod([v for v in frac_values
                           if round(float(v), 6) not in tried])
            for selected_adjust in frac_values:
                if round(float(selected_adjust), 6) in tried:
                    continue
                candidate = evaluate_adjust(selected_adjust)
                candidate_list.append(candidate)
                if candidate["score"] < best_candidate["score"]:
                    best_candidate = candidate

        block_cp_timing = (
            bool(getattr(args, "block_cp_timing", True))
            and getattr(args, "equalizer", "direct") == "direct"
            and len(candidate_list) > 1
        )

        def cp_score(candidate, block_idx):
            x = candidate["rx_result"]["rx_track"]
            ds = (P.Npreamble + block_idx * P.dataBlockLen
                  + P.CP_sym + P.Npilot + P.CP_sym)
            if ds - P.CP_sym < 0 or ds + P.Ndata_tx > len(x):
                return -np.inf
            cp = x[ds - P.CP_sym:ds]
            data_section = x[ds:ds + P.Ndata_tx]
            tail = data_section[-P.CP_sym:]
            return float(abs(np.vdot(cp, tail))
                         / (np.linalg.norm(cp) * np.linalg.norm(tail) + 1e-30))

        if block_cp_timing and bool(getattr(args, "fractional_timing", True)):
            tried = set(round(float(c["selected_adjust"]), 6)
                        for c in candidate_list)
            frac_span = float(getattr(args, "fractional_timing_span", 1.0))
            frac_step = float(getattr(args, "fractional_timing_step", 0.25))
            cp_min = float(getattr(args, "block_cp_timing_min", -12.0))
            cp_max = float(getattr(args, "block_cp_timing_max", 12.0))
            cp_candidates = [
                c for c in candidate_list
                if cp_min <= float(c["selected_adjust"]) <= cp_max
            ] or candidate_list
            first_cp_block = int(getattr(args, "block_cp_timing_first_block", 1))
            first_cp_block = min(max(0, first_cp_block), P.Nblocks)
            for block_idx in range(first_cp_block, P.Nblocks):
                best_block = max(cp_candidates,
                                 key=lambda c, b=block_idx: cp_score(c, b))
                for selected_adjust in fractional_adjust_values(
                        best_block["selected_adjust"], frac_span, frac_step):
                    if not (cp_min <= float(selected_adjust) <= cp_max):
                        continue
                    key = round(float(selected_adjust), 6)
                    if key in tried:
                        continue
                    tried.add(key)
                    candidate = evaluate_adjust(selected_adjust)
                    candidate_list.append(candidate)
                    if candidate["score"] < best_candidate["score"]:
                        best_candidate = candidate

        selected_adjust = best_candidate["selected_adjust"]
        rx_result = best_candidate["rx_result"]
        rx_bits = best_candidate["rx_bits"]
        rx_data = best_candidate["rx_data"]
        rx_bytes = best_candidate["rx_bytes"]
        errs_by_id = best_candidate["errs_by_id"]
        best_match_id = best_candidate["best_match_id"]
        marker_id = best_candidate["marker_id"]
        marker_exact_from_header = best_candidate["marker_exact_from_header"]
        marker_id_self_consistent = best_candidate["marker_id_self_consistent"]
        marker_score = best_candidate["marker_score"]
        marker_score_id = best_candidate.get("marker_score_id", best_match_id)

        if block_cp_timing:
            combined_bits = rx_bits.copy()
            cp_min = float(getattr(args, "block_cp_timing_min", -12.0))
            cp_max = float(getattr(args, "block_cp_timing_max", 12.0))
            cp_candidates = [
                c for c in candidate_list
                if cp_min <= float(c["selected_adjust"]) <= cp_max
            ] or candidate_list
            first_cp_block = int(getattr(args, "block_cp_timing_first_block", 1))
            first_cp_block = min(max(0, first_cp_block), P.Nblocks)

            for block_idx in range(first_cp_block, P.Nblocks):
                best_block = max(cp_candidates,
                                 key=lambda c, b=block_idx: cp_score(c, b))
                start = block_idx * P.Ndata
                stop = start + P.Ndata
                combined_bits[start:stop] = best_block["rx_bits"][start:stop]

            rx_bits = combined_bits
            rx_bytes = bits_to_bytes(rx_bits)
            errs_by_id = [
                int(np.sum(rx_bits != ref_bits_by_frame[i]))
                for i in range(len(ref_bits_by_frame))
            ]
            best_match_id = int(np.argmin(errs_by_id))
            marker_id, marker_exact_from_header, marker_id_self_consistent = (
                decode_marker_id(rx_bytes, len(ref_bits_by_frame))
            )
            if args.plain_counter:
                marker_score = 0
            elif expected_marker_id is not None:
                if per_block_markers:
                    marker_score = block_marker_total_hamming(
                        rx_bits, expected_marker_id, per_block_markers=True)
                    marker_score_id = expected_marker_id
                else:
                    marker_score = marker_hamming_score(
                        rx_bytes, expected_marker_id)
                    marker_score_id = expected_marker_id
            else:
                if per_block_markers:
                    marker_score_id, marker_score = best_block_marker_score(
                        rx_bits, len(ref_bits_by_frame), per_block_markers=True)
                else:
                    marker_score_id, marker_score = best_marker_score(
                        rx_bytes, len(ref_bits_by_frame))
            best_candidate["marker_score_id"] = marker_score_id if not args.plain_counter else best_match_id

        block_marker_id = None
        block_marker_score = None
        if per_block_markers and not args.plain_counter:
            block_marker_id, block_marker_score = best_block_marker_score(
                rx_bits, len(ref_bits_by_frame), per_block_markers=True)
            marker_score_id = block_marker_id
            marker_score = block_marker_score

        readable_marker_id = (
            marker_id is not None
            and marker_id_self_consistent
            and marker_id < len(ref_bits_by_frame)
        )
        readable_block_marker_id = (
            block_marker_id is not None
            and block_marker_id < len(ref_bits_by_frame)
            and block_marker_id_confident(
                block_marker_score, per_block_markers=True)
        )
        decoded_marker_id = (
            block_marker_id if readable_block_marker_id
            else marker_id if readable_marker_id
            else None
        )

        if decoded_marker_id is not None and sequence_anchor_idx is None:
            sequence_anchor_idx = capture_idx
            sequence_anchor_id = decoded_marker_id

        if sequence_anchor_idx is not None:
            expected_marker_id = (
                sequence_anchor_id
                + capture_idx
                - sequence_anchor_idx
            ) % len(ref_bits_by_frame)

        if (decoded_marker_id is not None
                and expected_marker_id is not None
                and not per_block_markers):
            if decoded_marker_id != expected_marker_id:
                marker_sequence_ok = False

        frame_id = (
            expected_marker_id if expected_marker_id is not None
            else decoded_marker_id if decoded_marker_id is not None
            else marker_score_id
        )

        if (per_block_markers
                and bool(getattr(args, "block_marker_timing", True))
                and len(candidate_list) > 1):
            combined_bits = rx_bits.copy()
            first_marker_block = int(getattr(
                args, "block_marker_timing_first_block", 1))
            first_marker_block = min(max(0, first_marker_block), P.Nblocks)
            for block_idx in range(first_marker_block, P.Nblocks):
                best_block = min(
                    candidate_list,
                    key=lambda c, b=block_idx: (
                        block_marker_hamming(c["rx_bits"], frame_id, b),
                        abs(float(c["selected_adjust"]) - base_adjust),
                    ),
                )
                start = block_idx * P.Ndata
                stop = start + P.Ndata
                combined_bits[start:stop] = best_block["rx_bits"][start:stop]
            rx_bits = combined_bits
            rx_bytes = bits_to_bytes(rx_bits)
            block_marker_id, block_marker_score = best_block_marker_score(
                rx_bits, len(ref_bits_by_frame), per_block_markers=True)
            marker_score_id = block_marker_id
            marker_score = block_marker_score

        block_marker_polarity = None
        if (per_block_markers
                and bool(getattr(args, "block_marker_polarity", True))):
            block_marker_polarity = apply_block_marker_polarity(
                rx_bits, frame_id, per_block_markers=True)
            rx_bits = block_marker_polarity["bits"]
            rx_bytes = bits_to_bytes(rx_bits)
            block_marker_id, block_marker_score = best_block_marker_score(
                rx_bits, len(ref_bits_by_frame), per_block_markers=True)
            marker_score_id = block_marker_id
            marker_score = block_marker_score

        if per_block_markers and not args.plain_counter:
            readable_block_marker_id = (
                block_marker_id is not None
                and block_marker_id < len(ref_bits_by_frame)
                and block_marker_id_confident(
                    block_marker_score, per_block_markers=True)
            )
            if readable_block_marker_id:
                if sequence_anchor_idx is None or sequence_anchor_idx == capture_idx:
                    sequence_anchor_idx = capture_idx
                    sequence_anchor_id = block_marker_id
                expected_marker_id = (
                    sequence_anchor_id
                    + capture_idx
                    - sequence_anchor_idx
                ) % len(ref_bits_by_frame)
                if block_marker_id != expected_marker_id:
                    marker_sequence_ok = False
                frame_id = expected_marker_id

        block_marker_id_exact_match = False
        block_marker_flip_text = ""
        block_marker_err_text = ""
        if per_block_markers and not args.plain_counter:
            block_marker_id_exact_match = (
                readable_block_marker_id
                and block_marker_id == frame_id
            )
            if block_marker_id_exact_match:
                block_marker_id_ok += 1
            block_marker_score_total += int(
                block_marker_score if block_marker_score is not None else frame_bits)
            if block_marker_polarity is not None:
                block_marker_flip_text = ".".join(
                    str(v) for v in block_marker_polarity["flipped_blocks"])
                block_marker_err_text = ".".join(
                    str(v) for v in block_marker_polarity["marker_err"])
                block_marker_polarity_flips_total += len(
                    block_marker_polarity["flipped_blocks"])

        ref_bits = ref_bits_by_frame[frame_id]
        err = int(np.sum(rx_bits != ref_bits))
        block_polarity = reference_aided_block_polarity(rx_bits, ref_bits)
        err_block_polarity = int(block_polarity["corrected_err"])
        block_flip_text = ".".join(str(v) for v in block_polarity["flipped_blocks"])
        raw_block_err_text = ".".join(str(v) for v in block_polarity["raw_counts"])
        corrected_block_err_text = ".".join(
            str(v) for v in block_polarity["corrected_counts"])

        # EVM-based SNR: compare the pre-hard-decision equalised symbols against
        # the ideal +/-1 BPSK constellation implied by the known reference bits.
        # This is a genuine receiver-quality measurement; it is computed strictly
        # alongside the existing fields and never feeds bit/timing selection.
        ideal   = 2.0 * ref_bits.astype(np.float64) - 1.0
        evm_vec = rx_data - ideal
        evm_rms = float(np.sqrt(np.mean(np.abs(evm_vec) ** 2)))
        snr_db  = -20.0 * np.log10(max(evm_rms, 1e-6))   # floor avoids log(0); caps ~120 dB

        total_err += err
        total_err_block_polarity += err_block_polarity
        total_bits += frame_bits
        # Pool the squared error across frames before taking the log, the same
        # way total_err/total_bits pools instead of averaging per-frame BER.
        total_evm_sq += float(np.sum(np.abs(evm_vec) ** 2))
        total_evm_n += len(evm_vec)
        block_polarity_flips_total += len(block_polarity["flipped_blocks"])
        frame_rms_values.append(raw_rms)
        frame_err_values.append(err)

        ref_bytes = bits_to_bytes(ref_bits)
        bad_bytes = np.flatnonzero(rx_bytes != ref_bytes)
        first_bad = int(bad_bytes[0]) if len(bad_bytes) else -1

        if args.plain_counter:
            marker = "plain"
            marker_match = True
            marker_prefix_exact_match = True
            frame_id_exact_match = True
            inv_id_exact_match = True
            header_bit_errors = 0
            marker_prefix_bit_errors = 0
            frame_id_bit_errors = 0
            inv_id_bit_errors = 0
        else:
            marker_bytes = rx_bytes[:4]
            marker = " ".join(f"{int(v):02X}" for v in marker_bytes)
            marker_prefix_exact_match = (
                len(marker_bytes) >= 2
                and int(marker_bytes[0]) == 0xA5
                and int(marker_bytes[1]) == 0x5A
            )
            frame_id_exact_match = (
                len(marker_bytes) >= 3
                and int(marker_bytes[2]) == (frame_id & 0xFF)
            )
            inv_id_exact_match = (
                len(marker_bytes) >= 4
                and int(marker_bytes[3]) == ((~frame_id) & 0xFF)
            )
            marker_match = (
                len(marker_bytes) >= 4
                and marker_prefix_exact_match
                and frame_id_exact_match
                and inv_id_exact_match
            )
            header_ref = [0xA5, 0x5A, frame_id & 0xFF, (~frame_id) & 0xFF]
            marker_prefix_bit_errors = sum(
                byte_hamming(int(marker_bytes[i]), header_ref[i])
                for i in range(min(len(marker_bytes), 2))
            )
            frame_id_bit_errors = (
                byte_hamming(int(marker_bytes[2]), header_ref[2])
                if len(marker_bytes) >= 3 else 8
            )
            inv_id_bit_errors = (
                byte_hamming(int(marker_bytes[3]), header_ref[3])
                if len(marker_bytes) >= 4 else 8
            )
            header_bit_errors = sum(
                byte_hamming(int(marker_bytes[i]), header_ref[i])
                for i in range(min(len(marker_bytes), 4))
            )

        if args.plain_counter:
            decoded_id = frame_id
        elif per_block_markers and block_marker_id_confident(
                marker_score, per_block_markers=True):
            decoded_id = frame_id
        else:
            decoded_id = frame_id if frame_id_exact_match else None
        decoded_ids.append(decoded_id)
        frame_timeline.append(decoded_id if decoded_id is not None else "?")
        frame_ber_timeline.append(err / frame_bits)
        frame_ber_block_polarity_timeline.append(err_block_polarity / frame_bits)

        if marker_match:
            marker_exact_ok += 1
        if marker_prefix_exact_match:
            marker_prefix_exact_ok += 1
        if frame_id_exact_match:
            frame_id_exact_ok += 1
        if inv_id_exact_match:
            inv_id_exact_ok += 1
        marker_prefix_bit_errors_total += marker_prefix_bit_errors
        frame_id_bit_errors_total += frame_id_bit_errors
        inv_id_bit_errors_total += inv_id_bit_errors

        if (timing_lock_enabled
                and timing_lock_adjust is None
                and marker_match
                and err <= timing_lock_max_errors):
            timing_lock_candidates.append(float(selected_adjust))
            if len(timing_lock_candidates) >= timing_lock_min_frames:
                timing_lock_adjust = float(np.median(timing_lock_candidates))
                if print_frames:
                    print(f"[ana] Timing locked at {timing_lock_adjust:+.2f} "
                          f"samples from {len(timing_lock_candidates)} "
                          f"clean frame(s)")

        rows.append((
            capture_idx,
            word_start,
            detected_sync,
            f"{sync_ratio:.3f}",
            f"{sync_peak:.6g}",
            frame_id,
            min(errs_by_id),
            err,
            err / frame_bits,
            snr_db,
            marker,
            marker_match,
            marker_prefix_exact_match,
            frame_id_exact_match,
            inv_id_exact_match,
            header_bit_errors,
            marker_prefix_bit_errors,
            frame_id_bit_errors,
            inv_id_bit_errors,
            len(bad_bytes),
            first_bad,
            selected_adjust,
            marker_score,
            block_marker_id if block_marker_id is not None else -1,
            block_marker_score if block_marker_score is not None else -1,
            block_marker_id_exact_match,
            block_marker_err_text,
            block_marker_flip_text,
            f"{raw_rms:.6g}",
            f"{raw_peak:.6g}",
            err_block_polarity,
            err_block_polarity / frame_bits,
            block_flip_text,
            raw_block_err_text,
            corrected_block_err_text,
        ))
        if print_frames:
            print(f"[ana] Frame {capture_idx:05d} word={word_start} "
                  f"preamble=OK sync_ratio={sync_ratio:.1f} "
                  f"sync_err={sync_error:+d} "
                  f"wide_sync_err={wide_sync_error:+d} "
                f"adj={selected_adjust:+.2f} "
                f"decoded_id="
                f"{decoded_id if decoded_id is not None else '?'} "
                f"expected_id="
                f"{expected_marker_id if expected_marker_id is not None else '?'} "
                f"errs={err:4d}/{frame_bits} "
                f"corr_errs={err_block_polarity:4d}/{frame_bits} "
                f"ber={err / frame_bits:.4e} "
                f"corr_ber={err_block_polarity / frame_bits:.4e} "
                f"blk_raw={raw_block_err_text} "
                f"blk_corr={corrected_block_err_text} "
                f"blk_flip={block_flip_text if block_flip_text else '-'} "
                f"rms={raw_rms:.3g} "
                f"marker={marker} "
                f"m_score={marker_score} "
                f"bm_id={block_marker_id if block_marker_id is not None else '-'} "
                f"bm_score={block_marker_score if block_marker_score is not None else '-'} "
                f"bm_flip={block_marker_flip_text if block_marker_flip_text else '-'} "
                f"best_id={best_match_id} "
                f"id={'OK' if frame_id_exact_match else 'BITERR'} "
                f"prefix={'OK' if marker_prefix_exact_match else 'BITERR'} "
                f"inv_id={'OK' if inv_id_exact_match else 'BITERR'} "
                f"marker={'OK' if marker_match else 'BITERR'}")

    if write_report:
        with open(args.report, "w") as f:
            f.write("capture_idx,word_start,sync_start,sync_ratio,sync_peak,"
                    "decoded_frame_id,best_id_errors,"
                    "bit_errors,ber,snr_db,marker,marker_exact_ok,"
                    "marker_prefix_exact_ok,frame_id_exact_ok,inv_id_exact_ok,"
                    "header_bit_errors,marker_prefix_bit_errors,"
                    "frame_id_bit_errors,inv_id_bit_errors,"
                    "byte_mismatches,first_bad_byte,rx_start_adjust,marker_score,"
                    "block_marker_id,block_marker_score,block_marker_id_ok,"
                    "block_marker_errors,block_marker_flipped_blocks,"
                    "raw_rms,raw_peak,"
                    "block_polarity_bit_errors,block_polarity_ber,"
                    "block_polarity_flipped_blocks,"
                    "block_raw_errors,block_corrected_errors\n")
            for row in rows:
                f.write(",".join(str(x) for x in row) + "\n")

    file_complete = len(words) == int(expected_raw_words)
    marker_exact_complete = (
        marker_exact_ok == len(decoded_ids)
        and len(decoded_ids) == expected_full_frames
    )
    frame_id_complete = (
        marker_sequence_ok
        and sequence_anchor_idx is not None
        and len(decoded_ids) == expected_full_frames
    )
    ber = total_err / total_bits if total_bits else 1.0
    ber_block_polarity = (
        total_err_block_polarity / total_bits if total_bits else 1.0
    )
    if len(frame_rms_values) >= 2 and len(set(frame_err_values)) > 1:
        amp_ber_corr = float(np.corrcoef(frame_rms_values, frame_err_values)[0, 1])
    else:
        amp_ber_corr = 0.0

    return dict(
        raw_words=len(words),
        expected_words=int(expected_raw_words),
        file_complete=file_complete,
        frame_offset_words=frame_offset_words,
        analyzed_frames=len(decoded_ids),
        expected_full_frames=expected_full_frames,
        trailing_words=trailing_words,
        skipped_no_preamble=skipped_no_preamble,
        marker_exact_ok=marker_exact_ok,
        marker_exact_complete=marker_exact_complete,
        frame_id_exact_ok=frame_id_exact_ok,
        block_marker_id_ok=block_marker_id_ok,
        block_marker_score_total=block_marker_score_total,
        marker_prefix_exact_ok=marker_prefix_exact_ok,
        inv_id_exact_ok=inv_id_exact_ok,
        marker_prefix_bit_errors=marker_prefix_bit_errors_total,
        frame_id_bit_errors=frame_id_bit_errors_total,
        inv_id_bit_errors=inv_id_bit_errors_total,
        decoded_ids=decoded_ids,
        frame_timeline=frame_timeline,
        frame_ber_timeline=frame_ber_timeline,
        frame_ber_block_polarity_timeline=frame_ber_block_polarity_timeline,
        timing_lock_adjust=timing_lock_adjust,
        timing_lock_frames=len(timing_lock_candidates),
        marker_sequence_ok=marker_sequence_ok,
        frame_id_complete=frame_id_complete,
        total_err=total_err,
        total_err_block_polarity=total_err_block_polarity,
        total_bits=total_bits,
        total_evm_sq=total_evm_sq,
        total_evm_n=total_evm_n,
        ber=ber,
        ber_block_polarity=ber_block_polarity,
        block_polarity_flips=block_polarity_flips_total,
        block_marker_polarity_flips=block_marker_polarity_flips_total,
        amp_ber_corr=amp_ber_corr,
        report=args.report,
    )
