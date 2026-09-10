"""
Capture-level analysis for the LFM+PRBS+BPSK port -- the analyze_capture()
equivalent for this new frame format. Detects every LFM packet in a raw
capture, decodes each with lfm_bpsk_rx.decode_packet, identifies its
frame_id from the embedded marker, and reports per-frame BER against the
deterministically-regenerated reference bits (lfm_bpsk_frame.data_bits).
"""

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_frame as F
import lfm_bpsk_rx as RX
import lfm_bpsk_tx as TX
from common_frame_ids import block_marker_hamming


def identify_frame_id(bits_hat: np.ndarray, n_ids: int = 256) -> tuple:
    """
    Best-matching frame_id for a decoded 200-bit payload, via Hamming
    distance on the 32-bit A5 5A id ~id marker (reuses the existing
    block_marker_hamming scorer). Returns (frame_id, marker_score).
    """
    scores = [block_marker_hamming(bits_hat, fid, block_idx=0) for fid in range(n_ids)]
    best = int(np.argmin(scores))
    return best, int(scores[best])


def estimate_sample_ppm(lfm_starts, frame_words_nominal: int) -> tuple:
    """
    Estimate the RX/TX sample-clock offset (ppm) from the spacing between
    consecutive detected LFM packet starts.

    The TX and RX boards each run off their own free-running crystal, so
    the RX ADC's actual sample rate is never exactly the TX DAC's nominal
    rate -- the same problem the older block-based pipeline's
    --sample-ppm / estimate_sample_clock_ppm() (common_frame_ids.py)
    exists to correct, confirmed as a real BER contributor on cross-board
    captures (2026-08-28). Measured natively here instead of via a
    separate probing pass: every detected LFM burst is already an
    independent, self-syncing timing reference.

    Method: pool the sample-domain gaps between consecutive detections,
    rounding each gap to the nearest integer multiple of the nominal
    per-frame sample count (frame_words_nominal) so an occasional missed
    detection (a 2x-or-more gap) doesn't skew the estimate, then compare
    the pooled measured samples/frame to the nominal:

        ppm = (measured_samples_per_frame / frame_words_nominal - 1) * 1e6

    Returns (ppm_estimate, diagnostics_dict). ppm_estimate is 0.0 and
    diagnostics_dict["ok"] is False when there are too few detections or
    no usable gaps to estimate from (caller should decode with ppm=0.0,
    i.e. the original uncorrected behavior).
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

    # Sanity guard: this estimator assumes back-to-back cyclic frames with
    # no gap beyond each frame's own LFM+guard (matches
    # lfm_bpsk_tx.build_cyclic_tx_packet(), i.e. the real hardware TX/RX
    # workflow this exists for). A capture built a different way -- e.g.
    # the self-test/multipath-test helper build_multi_frame_capture(),
    # which inserts extra inter-frame silence -- has a genuinely different
    # nominal spacing, and comparing it to frame_words_nominal produces a
    # wildly implausible ppm (tens of thousands) rather than a real
    # crystal offset (real ones are single- to low-double-digit ppm even
    # for cheap crystals). Applying a bogus correction actively breaks
    # decode (confirmed: corrupted the self-test outright, 2026-08-28)
    # rather than doing nothing, so refuse instead of guessing.
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
                     verbose: bool = True, sample_ppm: float = None,
                     sweep_taps: int = 0) -> dict:
    """
    Detect and decode every LFM+BPSK packet in a raw capture.

    sweep_taps: 0 (default) decodes with the K_2/K_fb in lfm_bpsk_params,
        exactly as before. A positive N sweeps the equalizer geometry on
        the first N packets (see tap_sweep.sweep_capture) and decodes the
        whole capture with the majority winner. 3 is the measured sweet
        spot -- the vote stops moving there. Off by default because it
        adds ~4 minutes per probe packet on the RX board and changes the
        decoded bits, so it must be asked for.

    raw_path_or_array: path to a .bin file of complex baseband samples
        (as produced by unpack_q15 on the existing DMA capture format),
        or an already-loaded complex128 ndarray.
    marker_score_max: a decoded packet whose best marker Hamming score
        exceeds this is treated as unreadable (frame_id unknown) rather
        than silently mis-assigned.
    sample_ppm: TX/RX sample-clock offset correction (ppm) applied to
        every packet's Stage-4 symbol extraction (see
        lfm_bpsk_rx.decode_packet). None (default) auto-estimates it from
        the spacing between detected LFM packet starts via
        estimate_sample_ppm(); pass an explicit float to override that
        estimate, or 0.0 to force the original uncorrected behavior.
    """
    if isinstance(raw_path_or_array, str):
        from dma_rx_sg_16m import unpack_q15
        words = np.fromfile(raw_path_or_array, dtype=np.uint32)
        re, im = unpack_q15(words)
        rx_raw = re + 1j * im
        # words/re/im are never needed again -- on the RX board's tight,
        # swap-less RAM budget, leaving a ~125MB (for a 25MB capture)
        # leftover copy of the raw file alive for the rest of this
        # function (through every detect+decode call) is real pressure
        # this capture size can't spare. Confirmed contributing to an
        # OOM kill on real hardware, 2026-08-27.
        del words, re, im
    else:
        rx_raw = raw_path_or_array

    # Real captures (and the last packet of a synthetic multi-frame test)
    # are often trimmed tight to the end of the last transmitted packet,
    # leaving no lookahead margin for decision_delay to read past the
    # frame end. Pad with trailing silence, matching Popoto's RX scripts
    # exactly (DEC_DELAY_MAX*sps + span*sps samples).
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    dtype = rx_raw.dtype
    # Length of REAL captured signal, before the padding is appended. A
    # packet whose payload runs past this point was only partly captured,
    # and decoding it means decoding zeros -- see the truncation guard
    # below. Recorded here because this is the only place that knows the
    # difference; decode_packet() sees one array and cannot tell padding
    # from signal.
    n_real = len(rx_raw)
    rx_raw = np.concatenate([rx_raw, np.zeros(pad, dtype=dtype)])

    # with_tau also returns the RMS delay spread measured from the LFM
    # correlator envelope around each peak -- the correlator is already
    # computed for detection, so the only extra cost is keeping a few
    # thousand samples around each peak instead of discarding the lot.
    lfm_starts, tau_rms_samp = RX.detect_lfm_packets(rx_raw, with_tau=True)
    tau_probe = RX.tau_rms_probe_samples()
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

    # Optional equalizer-geometry sweep. Probes the first N packets and
    # commits to the majority winner for the whole capture; see
    # tap_sweep.sweep_capture for why N=3 and what the ~0.34 dB it gives
    # up against per-packet tuning buys back. sweep_k2/sweep_kfb stay None
    # when disabled, and decode_packet then reads lfm_bpsk_params as
    # always -- so sweep_taps=0 is bit-identical to before this existed.
    sweep_k2 = sweep_kfb = None
    sweep_info = None
    if sweep_taps:
        import tap_sweep as _TS
        # Probe complete packets only. The last one is normally a fragment
        # (see the truncation guard below) and sweeping it would fit the
        # geometry to zero padding.
        pkt_samples_probe = len(TX.build_packet_waveform(0)["packet"])
        probe_starts = [s for s in lfm_starts
                        if s + pkt_samples_probe <= n_real]
        sweep_info = _TS.sweep_capture(rx_raw, probe_starts,
                                        sample_ppm=sample_ppm,
                                        n_probe=int(sweep_taps),
                                        verbose=verbose)
        if sweep_info.get("best"):
            sweep_k2, sweep_kfb = sweep_info["K_2"], sweep_info["K_fb"]
            if verbose:
                print(f"[sweep] decoding this capture with K_2={sweep_k2}, "
                      f"K_fb={sweep_kfb} "
                      f"(params default {P.K_2}/{P.K_fb})"
                      + ("" if sweep_info["unanimous"] else
                         "  -- vote was SPLIT, the channel may be changing"))

    results = []
    total_err = 0
    total_bits = 0
    total_evm_sq = 0.0
    total_evm_n = 0
    # Per-packet feedback 1: reject partly-captured packets.
    #
    # A capture is a whole number of DMA buffers, not a whole number of
    # packets, so the last detected packet is usually a fragment. Its
    # missing tail is then supplied by the zero padding above, and the
    # packet decodes "successfully" against zeros -- reported as readable,
    # with a real BER, which silently poisons the capture-wide figure by
    # one packet every single run.
    #
    # Observed on the 134-packet hardware capture of 2026-09-02: packets
    # 0-132 gave 0 errors, while packet 133 was 78 samples (3.2 symbols)
    # short and contributed 4 errors -- the entire reported
    # BER=1.49e-04. It also showed xcorr_peak=1.0134, i.e. ABOVE 1.0,
    # because the trailing zeros deflate the power estimate the
    # correlation is normalised by. A normalised correlation cannot
    # legitimately exceed 1, so that is a second, independent signature
    # of the same problem (checked separately below).
    #
    # This is an exact test, not a threshold: either the whole
    # transmitted packet was captured or it was not. Packets that pass
    # are decoded exactly as before -- decode_packet() is untouched.
    #
    # Use the TRANSMITTED waveform length, not a re-derivation from the
    # symbol counts. N_lfm + N_guard + N_syms_total*sps gives 46,704 but
    # build_packet_waveform() emits 46,896: it appends span*sps = 192
    # samples of RRC flush tail. Re-deriving the number silently
    # under-measures every packet by 192 samples and lets fragments
    # through. This is the same constant estimate_sample_ppm() already
    # treats as authoritative (frame_words_nominal).
    pkt_samples = len(TX.build_packet_waveform(0)["packet"])
    for i, lfm_start in enumerate(lfm_starts):
        payload_end = lfm_start + pkt_samples
        if payload_end > n_real:
            short = payload_end - n_real
            reason = (f"truncated: payload needs sample {payload_end} but the "
                      f"capture holds {n_real} -- short by {short} samples "
                      f"({short / P.sps:.1f} symbols)")
            results.append(dict(capture_idx=i, lfm_start=lfm_start, ok=False,
                                 truncated=True, reason=reason))
            if verbose:
                print(f"  [{i}] lfm_start={lfm_start}: SKIPPED -- {reason}")
            continue

        dec = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm,
                                K_2=sweep_k2, K_fb=sweep_kfb)
        if not dec.get("ok"):
            results.append(dict(capture_idx=i, lfm_start=lfm_start, ok=False,
                                 reason=dec.get("reason")))
            if verbose:
                print(f"  [{i}] lfm_start={lfm_start}: FAILED -- {dec.get('reason')}")
            continue

        # Corroborating check, independent of the length arithmetic above:
        # xcorr_peak is a correlation normalised by the segment's own
        # power, so > 1.0 means that power estimate was wrong -- trailing
        # zeros are the known cause, but a dropped DMA buffer mid-packet
        # would do it too. Flagged rather than rejected, since the packet
        # may still decode correctly and the length test is the
        # authoritative one.
        norm_suspect = dec["xcorr_peak"] > 1.0
        if norm_suspect and verbose:
            print(f"  [{i}] WARNING xcorr_peak={dec['xcorr_peak']:.4f} > 1.0 "
                  f"-- power normalisation is off, samples may be missing")

        frame_id, marker_score = identify_frame_id(dec["bits_hat"], n_ids=n_ids)
        readable = marker_score <= marker_score_max
        if readable:
            ref_bits = F.data_bits(frame_id)
            n_err = int(np.sum(dec["bits_hat"] != ref_bits))
            # PDSNR (post-detection SNR): reference-aided EVM measured on the
            # NLMS-DFE's equalized data symbols (post-detection/post-
            # equalization, pre-hard-decision -- dec["data_out"]) against the
            # ideal +/-1 BPSK constellation implied by the now-known
            # reference bits. Same definition the older block-based pipeline
            # uses for its per-frame snr_db (common_frame_ids.py) -- a
            # genuine receiver-quality measurement, computed alongside the
            # existing fields and never feeding bit/timing decisions.
            ideal = F.data_syms(frame_id)
            evm_vec = dec["data_out"] - ideal
            evm_sq = float(np.sum(np.abs(evm_vec) ** 2))
            evm_rms = float(np.sqrt(evm_sq / len(evm_vec)))
            pdsnr_db = -20.0 * np.log10(max(evm_rms, 1e-6))  # floor avoids log(0)
            total_evm_sq += evm_sq
            total_evm_n += len(evm_vec)
        else:
            ref_bits = None
            n_err = None
            pdsnr_db = None

        # rot_angle / best_t0 / direct_corr_pre are already computed and
        # returned by decode_packet(), they just were not reaching the
        # per-packet row. Purely additive -- write_report_csv() uses
        # extrasaction="ignore", so the existing --report CSV keeps its
        # original 14 columns while metrics_log.py records everything.
        # sample_ppm is echoed per row because it is a per-CAPTURE estimate
        # applied to every packet: a row has to carry the correction it was
        # decoded under to be interpretable on its own later.
        row = dict(
            capture_idx=i, lfm_start=lfm_start, ok=True,
            frame_id=frame_id if readable else None,
            marker_score=marker_score, readable=readable,
            n_err=n_err, n_bits=P.N_data if readable else None,
            xcorr_peak=dec["xcorr_peak"], CFO_total=dec["CFO_total"],
            ber_train=dec["ber_train"], agree=dec["agree"],
            pdsnr_db=pdsnr_db,
            rot_angle=dec["rot_angle"], best_t0=dec["best_t0"],
            direct_corr_pre=dec["direct_corr_pre"],
            sample_ppm=sample_ppm,
            best_eye=dec["best_eye"],
            direct_corr_post=dec["direct_corr_post"],
            # cfo_gain > 1 means Stage 5 improved the training correlation.
            # Precomputed here so the log carries the comparison rather
            # than requiring both columns to be divided after the fact.
            cfo_gain=(dec["direct_corr_post"] / dec["direct_corr_pre"]
                      if dec["direct_corr_pre"] > 0 else None),
            # Blind (reference-free) post-DFE SNR -- see decode_packet().
            # pdsnr_db above is the reference-aided sibling; logging both
            # is what lets us find out whether the blind one can stand in
            # for it in the field.
            snr_eq_db=dec["snr_eq_db"],
            # Which geometry actually decoded this packet -- the swept
            # winner when sweeping, otherwise the params default.
            K_2=P.K_2 if sweep_k2 is None else sweep_k2,
            K_fb=P.K_fb if sweep_kfb is None else sweep_kfb,
            swept=bool(sweep_taps),
            # The sweep's own reasoning, stamped on every row so a log
            # line explains WHY these taps were used. Without this the
            # only way to tell a noise-driven K_fb floor from a real one
            # was to infer it from the chosen geometry -- which is how the
            # 2026-09-03 noise bug went unnoticed until the tap choice
            # looked wrong. Per-capture values, repeated per row, same as
            # capture_sample_ppm.
            sweep_max_delay_sym=(None if sweep_info is None
                                 else sweep_info["probes"][0]["max_delay_sym"]),
            sweep_kfb_floor=(None if sweep_info is None
                             else sweep_info["probes"][0]["kfb_floor"]),
            sweep_unanimous=(None if sweep_info is None
                             else sweep_info["unanimous"]),
            sweep_n_probe=(None if sweep_info is None
                           else sweep_info["n_probe"]),
            # Whether the sweep actually CHANGED anything, and by how
            # much. improved=False means it found nothing that beat the
            # default by more than noise and kept the default -- which is
            # the expected answer on a channel with no multipath, and
            # needs to be visible so a run that did nothing is not
            # mistaken for one that tuned something.
            sweep_candidate=(None if sweep_info is None
                             else list(sweep_info["candidate"])),
            sweep_gain_db=(None if sweep_info is None
                           else sweep_info["gain_db"]),
            sweep_improved=(None if sweep_info is None
                            else sweep_info["improved"]),
            truncated=False,
            norm_suspect=norm_suspect,
            # RMS delay spread from the LFM correlator envelope. Reported
            # both as measured and deconvolved: the probe's own
            # resolution (~1/(f2-f1)) inflates the raw figure even on a
            # single-path channel, so subtract it in quadrature. Symbols
            # is the useful unit -- it is what sizes CP, K_2 and K_fb.
            tau_rms_samp=tau_rms_samp[i],
            tau_rms_sym=tau_rms_samp[i] / P.sps,
            tau_rms_ms=tau_rms_samp[i] / P.Fs * 1e3,
            tau_rms_sym_deconv=(
                np.sqrt(max(tau_rms_samp[i] ** 2 - tau_probe ** 2, 0.0))
                / P.sps),
        )
        results.append(row)
        if readable:
            total_err += n_err
            total_bits += P.N_data
        if verbose:
            ber_str = f"{n_err}/{P.N_data}" if readable else "UNREADABLE"
            pdsnr_str = f"{pdsnr_db:.2f}dB" if readable else "n/a"
            print(f"  [{i}] lfm_start={lfm_start}: frame_id={frame_id if readable else '?'} "
                  f"marker_score={marker_score} errors={ber_str} "
                  f"xcorr_peak={dec['xcorr_peak']:.3f} CFO={dec['CFO_total']:+.2f}Hz "
                  f"train_BER={dec['ber_train']:.4f} PDSNR={pdsnr_str}")

    ber = (total_err / total_bits) if total_bits > 0 else None
    # Pool EVM across all readable packets before taking the log (matches
    # how total_err/total_bits pools BER instead of averaging per-frame),
    # giving one capture-wide PDSNR figure alongside the per-packet ones.
    pdsnr_db_pooled = (
        -20.0 * np.log10(max(np.sqrt(total_evm_sq / total_evm_n), 1e-6))
        if total_evm_n > 0 else None
    )
    n_truncated = sum(1 for r in results if r.get("truncated"))
    n_norm_suspect = sum(1 for r in results if r.get("norm_suspect"))
    if verbose:
        if ber is not None:
            print(f"\nTotal: {total_err} errors / {total_bits} bits  BER={ber:.4e}  "
                  f"PDSNR={pdsnr_db_pooled:.2f}dB")
        else:
            print("\nNo readable frames.")
        if n_truncated:
            print(f"Skipped {n_truncated} partly-captured packet(s) -- the "
                  f"capture is a whole number of DMA buffers, not of packets, "
                  f"so a fragment at the end is normal.")
        if n_norm_suspect:
            print(f"WARNING: {n_norm_suspect} decoded packet(s) had "
                  f"xcorr_peak > 1.0 (power normalisation off).")

    return dict(results=results, total_err=total_err, total_bits=total_bits, ber=ber,
                n_packets_detected=len(lfm_starts), pdsnr_db=pdsnr_db_pooled,
                sample_ppm=sample_ppm, ppm_diag=ppm_diag,
                n_truncated=n_truncated, n_norm_suspect=n_norm_suspect,
                sweep=sweep_info,
                n_scored=sum(1 for r in results if r.get("readable")))
