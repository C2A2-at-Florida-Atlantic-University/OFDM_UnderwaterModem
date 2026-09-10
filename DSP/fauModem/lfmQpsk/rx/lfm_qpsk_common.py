"""
Capture-level analysis for the LFM+PRBS+QPSK port -- the analyze_capture()
equivalent for this frame format, mirroring lfm_bpsk_common.py exactly
(same detect-every-packet / identify-frame_id / per-frame BER approach),
generalized from 1 bit/symbol to 2 bits/symbol payloads.
"""

import numpy as np

import lfm_qpsk_params as P
import lfm_qpsk_frame as F
import lfm_qpsk_rx as RX
import lfm_qpsk_tx as TX
from common_frame_ids import block_marker_hamming


def identify_frame_id(bits_hat: np.ndarray, n_ids: int = 256) -> tuple:
    """
    Best-matching frame_id for a decoded N_data_bits (400-bit) payload,
    via Hamming distance on the 32-bit A5 5A id ~id marker at the start
    of the payload (block_idx=0, so this is agnostic to payload length --
    identical call to lfm_bpsk_common.py's).
    """
    scores = [block_marker_hamming(bits_hat, fid, block_idx=0) for fid in range(n_ids)]
    best = int(np.argmin(scores))
    return best, int(scores[best])


def estimate_sample_ppm(lfm_starts, frame_words_nominal: int) -> tuple:
    """
    Estimate the RX/TX sample-clock offset (ppm) from the spacing between
    consecutive detected LFM packet starts. Modulation-agnostic -- this
    is byte-for-byte the same algorithm as lfm_bpsk_common.py's, since it
    only depends on sample-domain spacing, not on bits/symbol.
    """
    starts = np.asarray(lfm_starts, dtype=np.float64)
    if len(starts) < 2:
        return 0.0, dict(ok=False, reason="fewer than 2 detections")

    deltas = np.diff(starts)
    k_gaps = np.round(deltas / float(frame_words_nominal))
    valid = k_gaps >= 1
    if not np.any(valid):
        return 0.0, dict(ok=False, reason="no usable inter-packet gaps")

    total_samples = float(np.sum(deltas[valid]))
    total_frames = float(np.sum(k_gaps[valid]))
    measured_samples_per_frame = total_samples / total_frames
    ppm = (measured_samples_per_frame / float(frame_words_nominal) - 1.0) * 1e6

    MAX_PLAUSIBLE_PPM = 1000.0
    if abs(ppm) > MAX_PLAUSIBLE_PPM:
        return 0.0, dict(ok=False, reason=(
            f"implausible ppm estimate ({ppm:+.1f}); inter-packet spacing "
            f"likely doesn't match back-to-back cyclic frames (e.g. extra "
            f"inter-frame silence in a synthetic capture) rather than a "
            f"real clock offset -- skipping correction"),
            measured_samples_per_frame=measured_samples_per_frame)

    diag = dict(ok=True, n_gaps_used=int(np.sum(valid)), n_gaps_total=len(deltas),
                measured_samples_per_frame=measured_samples_per_frame,
                frame_words_nominal=int(frame_words_nominal))
    return float(ppm), diag


def analyze_capture(raw_path_or_array, n_ids: int = 256, marker_score_max: int = 8,
                     verbose: bool = True, sample_ppm: float = None) -> dict:
    """
    Detect and decode every LFM+QPSK packet in a raw capture. Mirrors
    lfm_bpsk_common.analyze_capture() field-for-field (n_bits per readable
    frame is P.N_data_bits=400 here vs BPSK's P.N_data=200; PDSNR/EVM is
    computed the same way, generalized to complex data_out/ideal syms).
    """
    if isinstance(raw_path_or_array, str):
        from dma_rx_sg_16m import unpack_q15
        words = np.fromfile(raw_path_or_array, dtype=np.uint32)
        re, im = unpack_q15(words)
        # HISTORICAL NOTE (2026-09-01): real two-board hardware captures
        # (M20 TX / M10 RX) were briefly found to be the COMPLEX CONJUGATE
        # of what the rest of this pipeline (train_syms()/qpsk_map())
        # expects -- Q sign-inverted relative to I -- traced to
        # adc_iq_mixer.v computing Q = real*sin instead of Q = -real*sin.
        # Real-valued signals (LFM, and the sibling BPSK port) are their
        # own conjugate, so this was invisible to LFM detection and BPSK
        # while breaking QPSK outright; a temporary `rx_raw = re - 1j*im`
        # workaround was used here in the meantime. The RTL has since been
        # fixed at the source (adc_iq_mixer.v now correctly computes
        # Q = -real*sin), so the hardware capture now already matches the
        # software's I/Q convention and no compensating conjugate is
        # needed here. Left as a note in case any board is ever running a
        # pre-fix bitstream: if QPSK captures from such a board come back
        # unreadable again with xcorr_peak~0.36, this is the first thing
        # to check.
        rx_raw = re + 1j * im
        del words, re, im
    else:
        rx_raw = raw_path_or_array

    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    dtype = rx_raw.dtype
    rx_raw = np.concatenate([rx_raw, np.zeros(pad, dtype=dtype)])

    lfm_starts = RX.detect_lfm_packets(rx_raw)
    if verbose:
        print(f"Detected {len(lfm_starts)} LFM packet(s) in capture "
              f"({len(rx_raw)} samples)")

    if sample_ppm is None:
        frame_words_nominal = len(TX.build_packet_waveform(0)["packet"])
        ppm_est, ppm_diag = estimate_sample_ppm(lfm_starts, frame_words_nominal)
        sample_ppm = ppm_est
    else:
        sample_ppm = float(sample_ppm)
        ppm_diag = dict(ok=True, reason="user-specified")
    if verbose:
        if ppm_diag.get("ok") and "n_gaps_used" in ppm_diag:
            print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm  "
                  f"({ppm_diag['n_gaps_used']}/{ppm_diag['n_gaps_total']} "
                  f"inter-packet gaps used)")
        elif ppm_diag.get("ok"):
            print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm (user-specified)")
        else:
            print(f"[ppm] Sample-clock offset : +0.000 ppm (not estimated -- "
                  f"{ppm_diag.get('reason')})")

    results = []
    total_err = 0
    total_bits = 0
    total_evm_sq = 0.0
    total_evm_n = 0
    for i, lfm_start in enumerate(lfm_starts):
        dec = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm)
        if not dec.get("ok"):
            results.append(dict(capture_idx=i, lfm_start=lfm_start, ok=False,
                                 reason=dec.get("reason")))
            if verbose:
                print(f"  [{i}] lfm_start={lfm_start}: FAILED -- {dec.get('reason')}")
            continue

        frame_id, marker_score = identify_frame_id(dec["bits_hat"], n_ids=n_ids)
        readable = marker_score <= marker_score_max
        if readable:
            ref_bits = F.data_bits(frame_id)
            n_err = int(np.sum(dec["bits_hat"] != ref_bits))
            # PDSNR (post-detection SNR): reference-aided EVM measured on the
            # NLMS-DFE's equalized data symbols against the ideal QPSK
            # constellation implied by the now-known reference bits. Same
            # definition as lfm_bpsk_common.py's, generalized to complex.
            ideal = F.data_syms(frame_id)
            evm_vec = dec["data_out"] - ideal
            evm_sq = float(np.sum(np.abs(evm_vec) ** 2))
            evm_rms = float(np.sqrt(evm_sq / len(evm_vec)))
            pdsnr_db = -20.0 * np.log10(max(evm_rms, 1e-6))
            total_evm_sq += evm_sq
            total_evm_n += len(evm_vec)
        else:
            ref_bits = None
            n_err = None
            pdsnr_db = None

        row = dict(
            capture_idx=i, lfm_start=lfm_start, ok=True,
            frame_id=frame_id if readable else None,
            marker_score=marker_score, readable=readable,
            n_err=n_err, n_bits=P.N_data_bits if readable else None,
            xcorr_peak=dec["xcorr_peak"], CFO_total=dec["CFO_total"],
            ber_train=dec["ber_train"], agree=dec["agree"],
            pdsnr_db=pdsnr_db,
        )
        results.append(row)
        if readable:
            total_err += n_err
            total_bits += P.N_data_bits
        if verbose:
            ber_str = f"{n_err}/{P.N_data_bits}" if readable else "UNREADABLE"
            pdsnr_str = f"{pdsnr_db:.2f}dB" if readable else "n/a"
            print(f"  [{i}] lfm_start={lfm_start}: frame_id={frame_id if readable else '?'} "
                  f"marker_score={marker_score} errors={ber_str} "
                  f"xcorr_peak={dec['xcorr_peak']:.3f} CFO={dec['CFO_total']:+.2f}Hz "
                  f"train_BER={dec['ber_train']:.4f} PDSNR={pdsnr_str}")

    ber = (total_err / total_bits) if total_bits > 0 else None
    pdsnr_db_pooled = (
        -20.0 * np.log10(max(np.sqrt(total_evm_sq / total_evm_n), 1e-6))
        if total_evm_n > 0 else None
    )
    if verbose:
        if ber is not None:
            print(f"\nTotal: {total_err} errors / {total_bits} bits  BER={ber:.4e}  "
                  f"PDSNR={pdsnr_db_pooled:.2f}dB")
        else:
            print("\nNo readable frames.")

    return dict(results=results, total_err=total_err, total_bits=total_bits, ber=ber,
                n_packets_detected=len(lfm_starts), pdsnr_db=pdsnr_db_pooled,
                sample_ppm=sample_ppm, ppm_diag=ppm_diag)