"""
lfm_qpsk_sweep_fine.py -- NLMS-DFE equalizer parameter sweep (K_2, K_fb,
no_repass) for the FAU LFM+PRBS+QPSK port, run against a REAL captured
.bin file (e.g. lfm_iq_rx_capture_u32.bin, the file produced by
lfm_rx_iq_sg_capture_qpsk_frame_ids.py / consumed by
lfm_qpsk_common.analyze_capture()).

Python counterpart of the Popoto MATLAB fine-sweep pattern (see the
uploaded lfmBpskPopotoRx330_nlms_sweepFine.m, and its QPSK sibling
lfmQpskPopotoRx330_nlms_sweepFine.m referenced in that file's header):
acquisition -- packet detection, timing/CFO sync, phase/quadrant
rotation (decode_packet()'s Stages 3-6) -- is run ONCE on the chosen
packet and reused for every (K_2, K_fb) combo in the grid; each combo is
checked at TWO no_repass values with UNSTABLE flagged whenever they
disagree on error count, same stability-gating philosophy as every sweep
in the Popoto project this is ported from.

This is a STANDALONE script, not a modification of lfm_qpsk_rx.py's
decode_packet() -- same design choice the Popoto MATLAB sweeps made
(separate *_sweepFine.m files; the main, hardware-validated RX script is
left untouched). Stages 3-6 below reuse decode_packet()'s own helper
functions verbatim (_mslice/_m1/_fir_filter/_base_rrc/_COARSE_BLOCK_LEN,
detect_lfm_packets, imported from lfm_qpsk_rx rather than re-implemented)
so the acquisition this sweeps against is exactly what production
decoding would produce. The one real difference: Stage 4's lookahead
margin is sized for the WORST-CASE (largest) K_2 in the sweep grid
instead of a single fixed P.K_2, so one acquisition pass gives every
combo in the grid a valid decision-feedback window -- mirrors the MATLAB
script's max_decision_delay / DEC_DELAY_MAX bookkeeping exactly.

HOW TO USE:
  1. python lfm_qpsk_sweep_fine.py --capture lfm_iq_rx_capture_u32.bin
     (defaults to the FIRST LFM packet detected in the file; point at a
     different one in the same capture with --packet-idx N)
  2. Edit --k2-list / --kfb-list / --no-repass-pair, or the DEFAULT_*
     constants below, to taste.
  3. Run. Each row printed is one (K_2, K_fb) combo; the summary table
     at the end is sorted best-BER-first (ties broken by higher post-DFE
     SNR), with a stability flag (OK / UNSTABLE) per row.
  4. Once you've picked a winner, set K_2/K_fb in lfm_qpsk_params.py.

CAVEAT (same as every sweep in the Popoto project this is ported from):
this runs against ONE packet from ONE capture. Treat the output as "this
REGION of (K_2, K_fb) is solid for this channel/range", and re-check the
winner against another capture at the same range/carrier before treating
it as a validated default -- not a substitute for it.

NOTE on I/Q convention: this script loads real hardware captures the
same way lfm_qpsk_common.py's analyze_capture() currently does
(rx_raw = re + 1j*im, no conjugate) -- correct for captures taken AFTER
the adc_iq_mixer.v RTL fix (Q = -real*sin). If you're sweeping a capture
taken BEFORE that fix, flip _load_capture()'s sign to `re - 1j*im` (see
lfm_qpsk_common.py's history comment for the full story of that bug).
"""

import argparse

import numpy as np

import lfm_qpsk_params as P
import lfm_qpsk_frame as F
import lfm_qpsk_tx as TX
from lfm_qpsk_rx import (
    _mslice, _m1, _fir_filter, _base_rrc, _COARSE_BLOCK_LEN,
    detect_lfm_packets,
)
from lfm_qpsk_common import identify_frame_id, estimate_sample_ppm

SQRT2 = np.sqrt(2.0)

# Brackets Popoto's own fine-swept QPSK starting point (K_2=72, K_fb=24,
# see lfm_qpsk_params.py's docstring) the same way the uploaded BPSK
# sweep brackets its own default -- widen/re-center after the first real
# run, same as every sweep in this project.
DEFAULT_K2_LIST = [40, 48, 56, 64, 72, 80, 88, 96, 104]
DEFAULT_KFB_LIST = [8, 12, 16, 20, 24, 28, 32, 36, 40, 44]
DEFAULT_NO_REPASS_PAIR = (3, 5)


def _load_capture(path: str) -> np.ndarray:
    from dma_rx_sg_16m import unpack_q15
    words = np.fromfile(path, dtype=np.uint32)
    re, im = unpack_q15(words)
    rx_raw = re + 1j * im  # see module docstring's I/Q-convention note
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    rx_raw = np.concatenate([rx_raw, np.zeros(pad, dtype=rx_raw.dtype)])
    return rx_raw


# ----------------------------------------------------------------------
# Acquisition -- Stages 3-6 of lfm_qpsk_rx.decode_packet(), copy-
# identical except the Stage-4 lookahead margin is sized for max_K_2
# (the largest K_2 in the sweep grid) rather than a single P.K_2.
# ----------------------------------------------------------------------
def _acquire_packet(rx_raw: np.ndarray, lfm_start: int, sample_ppm: float,
                     max_K_2: int, verbose: bool = True) -> dict:
    train_syms = F.train_syms()

    # --- Stage 3: extract QPSK segment, no carrier mixing ---
    rrc_delay = P.span * P.sps // 2
    qpsk_start_raw = lfm_start + P.N_lfm + P.N_guard
    seg_end = min(len(rx_raw), qpsk_start_raw + (P.N_syms_total + P.DEC_DELAY_MAX) * P.sps + rrc_delay)
    rx_qpsk_seg = rx_raw[qpsk_start_raw: seg_end]
    if len(rx_qpsk_seg) < P.N_train * P.sps:
        return dict(ok=False, reason="capture too short past LFM+guard for this packet")

    rx_bb = rx_qpsk_seg.astype(np.complex128)
    flush_rx = np.zeros(P.span * P.sps, dtype=np.complex128)
    mf_qpsk = _fir_filter(_base_rrc(), np.concatenate([rx_bb, flush_rx]))
    mf_qpsk = mf_qpsk[P.span * P.sps // 2:]

    # --- Stage 3b: CFO-tolerant non-coherent block correlation ---
    mf_ds_coarse = mf_qpsk[::P.sps]
    pwr = np.mean(np.abs(mf_ds_coarse) ** 2)
    if pwr > 0:
        mf_ds_coarse = mf_ds_coarse / np.sqrt(pwr)

    BLOCK_LEN = _COARSE_BLOCK_LEN
    assert P.N_train % BLOCK_LEN == 0, "N_train must be a multiple of BLOCK_LEN"
    n_blocks = P.N_train // BLOCK_LEN
    Na = len(mf_ds_coarse)
    valid_len = Na - P.N_train + 1
    if valid_len <= 0:
        return dict(ok=False, reason="capture too short for coarse xcorr")

    score = np.zeros(valid_len, dtype=np.float64)
    block_c = np.empty((n_blocks, valid_len), dtype=np.complex128)
    for k in range(n_blocks):
        blk_rev = np.conj(train_syms[k * BLOCK_LEN:(k + 1) * BLOCK_LEN][::-1])
        c_k = np.convolve(mf_ds_coarse, blk_rev, mode="full")
        start = (k + 1) * BLOCK_LEN - 1
        block_c[k] = c_k[start:start + valid_len]
        score += np.abs(block_c[k])

    peak_sym0 = int(np.argmax(score))
    xcorr_peak = score[peak_sym0] / P.N_train
    peak_sym = peak_sym0 + 1

    block_phasors = block_c[:, peak_sym0]
    block_w = np.abs(block_phasors)
    if np.sum(block_w) > 0 and n_blocks >= 2:
        block_phase = np.unwrap(np.angle(block_phasors))
        block_sym0 = np.arange(n_blocks) * BLOCK_LEN
        coeffs_coarse = np.polyfit(block_sym0, block_phase, 1, w=block_w)
        cfo_coarse_hz = float(coeffs_coarse[0] * P.Rs / (2 * np.pi))
    else:
        cfo_coarse_hz = 0.0
    if cfo_coarse_hz != 0.0:
        t_mf = np.arange(len(mf_qpsk)) / P.Fs
        mf_qpsk = mf_qpsk * np.exp(-1j * 2 * np.pi * cfo_coarse_hz * t_mf)

    if verbose:
        print(f"Coarse xcorr peak = {xcorr_peak:.4f} "
              f"{'(OK)' if xcorr_peak > 0.3 else '(LOW)'}   "
              f"coarse CFO = {cfo_coarse_hz:+.2f} Hz")

    # --- Sub-sample scan ---
    N_scan = 128
    pre_short = train_syms[:N_scan]
    best_eye = 0.0
    best_t0 = (peak_sym - 1) * P.sps + 1
    for d in range(-P.sps, P.sps + 1, 4):
        t0_try = (peak_sym - 1) * P.sps + 1 + d
        if t0_try < 1:
            continue
        t_end_try = t0_try + (N_scan - 1) * P.sps
        if t_end_try > len(mf_qpsk):
            continue
        seg = _mslice(mf_qpsk, t0_try, t_end_try, P.sps)[:N_scan]
        eye_val = np.abs(np.vdot(pre_short, seg)) / N_scan
        if eye_val > best_eye:
            best_eye = eye_val
            best_t0 = t0_try
    if verbose:
        print(f"Sub-sample scan: best t0 = {best_t0}, eye = {best_eye:.4f}")

    # --- Stage 4: T/2 FSE extraction, margin sized for max_K_2 ---
    sps_eff = P.sps * (1.0 + float(sample_ppm) * 1e-6)
    sps_fse_eff = sps_eff / 2.0
    mf_t0 = best_t0
    t_end_base = mf_t0 + (P.N_syms_total - 1) * sps_eff
    if t_end_base > len(mf_qpsk):
        return dict(ok=False, reason="capture too short to contain full QPSK frame")
    n_extra_avail = int(np.floor((len(mf_qpsk) - t_end_base) / sps_eff))
    n_margin = min(P.DEC_DELAY_MAX, max(n_extra_avail, 0))
    max_decision_delay = max_K_2 // 4
    if max_decision_delay > n_margin:
        return dict(ok=False, reason=(
            f"max K_2 in sweep grid ({max_K_2}) needs decision_delay="
            f"{max_decision_delay}, exceeds available lookahead margin "
            f"({n_margin} symbols) -- lower --k2-list or raise "
            f"P.DEC_DELAY_MAX"))

    n_fse = 2 * (P.N_syms_total + n_margin) - 1
    fse_positions = (mf_t0 - 1) + np.arange(n_fse, dtype=np.float64) * sps_fse_eff
    src_idx = np.arange(len(mf_qpsk), dtype=np.float64)
    mf_ds_fse = (np.interp(fse_positions, src_idx, mf_qpsk.real)
                 + 1j * np.interp(fse_positions, src_idx, mf_qpsk.imag))
    mf_ds = mf_ds_fse[::2]

    ss = max(1, round(0.1 * P.N_syms_total * 2))
    pwr = np.mean(np.abs(mf_ds_fse[ss - 1:]) ** 2)
    if pwr > 0:
        mf_ds_fse = mf_ds_fse / np.sqrt(pwr)
        mf_ds = mf_ds / np.sqrt(pwr)

    # --- Stage 5: iterative CFO (linear phase-ramp) refinement ---
    n_sym_vec = np.arange(len(mf_ds))
    n_fse_vec = np.arange(len(mf_ds_fse)) / 2.0
    CFO_total = 0.0
    direct_corr_pre = np.abs(np.vdot(train_syms, mf_ds[:P.N_train])) / P.N_train
    if xcorr_peak <= 0.5:
        for _ in range(3):
            pre_mf = mf_ds[:P.N_train]
            phi = np.unwrap(np.angle(pre_mf * np.conj(train_syms)))
            coeffs = np.polyfit(np.arange(P.N_train), phi, 1)
            CFO_est = coeffs[0] * P.Rs / (2 * np.pi)
            mf_ds = mf_ds * np.exp(-1j * 2 * np.pi * CFO_est / P.Rs * n_sym_vec)
            mf_ds_fse = mf_ds_fse * np.exp(-1j * 2 * np.pi * CFO_est / P.Rs * n_fse_vec)
            CFO_total += CFO_est
            if abs(CFO_est) < 0.1:
                break
    direct_corr_post = np.abs(np.vdot(train_syms, mf_ds[:P.N_train])) / P.N_train
    if verbose:
        print(f"Direct preamble correlation: pre-CFO={direct_corr_pre:.4f}  "
              f"post-CFO={direct_corr_post:.4f}  fine CFO total={CFO_total:+.3f}Hz")

    # --- Stage 6: pilot-aided absolute phase / quadrant resolution ---
    h_est = np.mean(mf_ds[:P.N_train] * np.conj(train_syms))
    rot_angle = float(np.angle(h_est))
    mf_ds = mf_ds * np.exp(-1j * rot_angle)
    mf_ds_fse = mf_ds_fse * np.exp(-1j * rot_angle)

    pre_syms = mf_ds[:P.N_train]
    b1_chk = (pre_syms.real < 0).astype(np.uint8)
    b2_chk = (pre_syms.imag < 0).astype(np.uint8)
    pre_bits_hat = np.empty(2 * P.N_train, dtype=np.uint8)
    pre_bits_hat[0::2] = b1_chk
    pre_bits_hat[1::2] = b2_chk
    agree = int(np.sum(pre_bits_hat == F.train_bits()))
    if verbose:
        ok_str = 'OK' if agree > 0.7 * P.N_bits_train else 'POOR'
        print(f"Constellation rotation: {np.degrees(rot_angle):+.1f}deg  "
              f"agreement={agree}/{P.N_bits_train} ({ok_str})")

    return dict(ok=True, mf_ds=mf_ds, mf_ds_fse=mf_ds_fse, train_syms=train_syms,
                xcorr_peak=xcorr_peak, n_margin=n_margin, best_t0=best_t0,
                cfo_coarse_hz=cfo_coarse_hz, cfo_fine_hz=CFO_total, agree=agree)


def _bits_from_syms(syms: np.ndarray) -> np.ndarray:
    b1 = (syms.real < 0).astype(np.uint8)
    b2 = (syms.imag < 0).astype(np.uint8)
    bits = np.empty(2 * len(syms), dtype=np.uint8)
    bits[0::2] = b1
    bits[1::2] = b2
    return bits


# ----------------------------------------------------------------------
# Equalization -- Stages 7-9 of decode_packet(), parameterized on
# K_2/K_fb/no_repass instead of reading them from lfm_qpsk_params.
# ----------------------------------------------------------------------
def _run_equalizer(mf_ds_fse: np.ndarray, mf_ds: np.ndarray, train_syms: np.ndarray,
                    K_2: int, K_fb: int, no_repass: int) -> dict:
    decision_delay = K_2 // 4
    decided_syms = np.zeros(P.N_syms_total, dtype=np.complex128)
    decided_syms[:P.N_train] = train_syms

    n_start = max(int(np.ceil(K_2 / 2)), K_fb + decision_delay)
    n_end = P.N_train - 1
    n_rows = n_end - n_start + 1
    if n_rows <= 0:
        return dict(ok=False, reason="training region too short for this K_2/K_fb")

    # --- Stage 7: batch-LS DFE init ---
    X_pre = np.zeros((n_rows, K_2), dtype=np.complex128)
    Fb_pre = np.zeros((n_rows, K_fb), dtype=np.complex128)
    d_pre = np.zeros(n_rows, dtype=np.complex128)
    for k in range(1, n_rows + 1):
        nk = n_start + k - 1
        m = nk - decision_delay + 1
        idx_end = nk * 2 + 1
        idx_start = idx_end - K_2 + 1
        X_pre[k - 1, :] = _mslice(mf_ds_fse, idx_end, idx_start, -1)
        if K_fb > 0:
            Fb_pre[k - 1, :] = _mslice(decided_syms, m - 1, m - K_fb, -1)
        d_pre[k - 1] = _m1(train_syms, m)

    Z_pre = np.concatenate([X_pre, -Fb_pre], axis=1) if K_fb > 0 else X_pre
    pwr_Z = np.mean(np.sum(np.abs(Z_pre) ** 2, axis=0))
    reg_vector = np.concatenate([
        0.05 * pwr_Z * np.ones(K_2),
        0.001 * pwr_Z * np.ones(K_fb),
    ])
    A_pre = Z_pre.conj().T @ Z_pre + np.diag(reg_vector)
    wc_init = np.linalg.solve(A_pre, Z_pre.conj().T @ d_pre)

    pred_train = Z_pre @ wc_init
    b1_train = pred_train.real < 0
    b2_train = pred_train.imag < 0
    b1_ref = d_pre.real < 0
    b2_ref = d_pre.imag < 0
    ber_train = float(np.mean(np.concatenate([b1_train != b1_ref, b2_train != b2_ref])))

    # --- Stage 8/9: joint DD-PLL + NLMS-DFE, with repass ---
    alpha_pll_pre, beta_pll_pre = 0.05, 0.005
    alpha_pll_data, beta_pll_data = 0.015, 0.0005
    gamma_soft = 2.0
    eff_gain_cap = P.gain_cap * 38 / (K_2 + K_fb)

    def run_pass(fb_source_for_data):
        wc = wc_init.copy()
        theta = 0.0
        freq_off = 0.0
        eq_out = np.zeros(P.N_syms_total, dtype=np.complex128)
        local_decided = decided_syms.copy()

        for _warmup in range(3):
            for m in range(n_start + 1, P.N_train + 1):
                n = m + decision_delay
                idx_end = n * 2 + 1
                x_win = _mslice(mf_ds_fse, idx_end, idx_end - K_2 + 1, -1)
                fb_win = _mslice(local_decided, m - 1, m - K_fb, -1) if K_fb > 0 else np.zeros(0, dtype=np.complex128)
                z_win = np.concatenate([x_win, -fb_win])

                y_raw = np.vdot(wc, z_win)
                y = y_raw * np.exp(-1j * theta)
                if m <= P.N_syms_total:
                    eq_out[m - 1] = y

                d = _m1(train_syms, m)
                e_phi = (y * np.conj(d)).imag
                freq_off += beta_pll_pre * e_phi
                theta += alpha_pll_pre * e_phi + freq_off

                err_slice = d - y
                err_eq = err_slice * np.exp(1j * theta)
                raw_gain = eff_gain_cap / (np.real(np.vdot(z_win, z_win)) + 1e-3)
                wc = wc + raw_gain * np.conj(err_eq) * z_win
                wn = np.linalg.norm(wc)
                if wn > P.w_norm_max:
                    wc = wc * (P.w_norm_max / wn)

        for m in range(P.N_train + 1, P.N_syms_total + 1):
            n = m + decision_delay
            idx_end = n * 2 + 1
            x_win = _mslice(mf_ds_fse, idx_end, idx_end - K_2 + 1, -1)
            fb_win = _mslice(fb_source_for_data, m - 1, m - K_fb, -1) if K_fb > 0 else np.zeros(0, dtype=np.complex128)
            z_win = np.concatenate([x_win, -fb_win])

            y_raw = np.vdot(wc, z_win)
            y = y_raw * np.exp(-1j * theta)
            eq_out[m - 1] = y

            d_hard = complex(np.sign(y.real), np.sign(y.imag)) / SQRT2
            real_soft = np.tanh(gamma_soft * SQRT2 * y.real)
            imag_soft = np.tanh(gamma_soft * SQRT2 * y.imag)
            if abs(y.real) < 0.15:
                real_soft = 0.0
            if abs(y.imag) < 0.15:
                imag_soft = 0.0
            soft_val = complex(real_soft, imag_soft) / SQRT2
            local_decided[m - 1] = soft_val
            d = d_hard

            e_phi = (y * np.conj(d)).imag
            freq_off += beta_pll_data * e_phi
            theta += alpha_pll_data * e_phi + freq_off

            err_slice = d - y
            err_eq = err_slice * np.exp(1j * theta)
            raw_gain = eff_gain_cap / (np.real(np.vdot(z_win, z_win)) + 1e-3)
            wc = wc + raw_gain * np.conj(err_eq) * z_win
            wn = np.linalg.norm(wc)
            if wn > P.w_norm_max:
                wc = wc * (P.w_norm_max / wn)

        return eq_out, local_decided

    eq_out, decided_syms = run_pass(decided_syms)
    for _k in range(no_repass):
        decided_prev = decided_syms.copy()
        for idx2 in range(P.N_train, P.N_syms_total):
            val = decided_prev[idx2]
            r_val = 0.0 if abs(val.real) < 0.15 else np.sign(val.real) / SQRT2
            i_val = 0.0 if abs(val.imag) < 0.15 else np.sign(val.imag) / SQRT2
            decided_prev[idx2] = complex(r_val, i_val)
        eq_out, decided_syms = run_pass(decided_prev)

    data_out = eq_out[P.N_train:]
    bits_hat = _bits_from_syms(data_out)

    hard = np.sign(data_out.real) / SQRT2 + 1j * np.sign(data_out.imag) / SQRT2
    noise_eq = float(np.mean(np.abs(data_out - hard) ** 2))
    snr_eq_db = -10.0 * np.log10(max(noise_eq, 1e-12))

    return dict(ok=True, bits_hat=bits_hat, data_out=data_out, ber_train=ber_train,
                snr_eq_db=snr_eq_db)


def sweep_fine(capture_path: str, k2_list=None, kfb_list=None,
               no_repass_pair=DEFAULT_NO_REPASS_PAIR, packet_idx: int = 0,
               sample_ppm: float = None, marker_score_max: int = 8,
               plot_out: str = None) -> dict:
    k2_list = list(k2_list) if k2_list else list(DEFAULT_K2_LIST)
    kfb_list = list(kfb_list) if kfb_list else list(DEFAULT_KFB_LIST)

    rx_raw = _load_capture(capture_path)
    lfm_starts = detect_lfm_packets(rx_raw)
    print(f"Detected {len(lfm_starts)} LFM packet(s) in capture ({len(rx_raw)} samples)")
    if packet_idx >= len(lfm_starts):
        raise SystemExit(f"--packet-idx {packet_idx} out of range (only "
                          f"{len(lfm_starts)} packet(s) detected)")
    lfm_start = lfm_starts[packet_idx]
    print(f"Sweeping packet {packet_idx}: lfm_start={lfm_start}")

    if sample_ppm is None:
        frame_words_nominal = len(TX.build_packet_waveform(0)["packet"])
        sample_ppm, ppm_diag = estimate_sample_ppm(lfm_starts, frame_words_nominal)
        if ppm_diag.get("ok"):
            print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm "
                  f"(auto-estimated from {ppm_diag.get('n_gaps_used', 0)} gap(s))")
        else:
            print(f"[ppm] Sample-clock offset : +0.000 ppm (not estimated -- "
                  f"{ppm_diag.get('reason')})")
            sample_ppm = 0.0
    else:
        print(f"[ppm] Sample-clock offset : {sample_ppm:+.3f} ppm (user-specified)")

    acq = _acquire_packet(rx_raw, lfm_start, sample_ppm, max_K_2=max(k2_list))
    if not acq.get("ok"):
        raise SystemExit(f"Acquisition FAILED: {acq.get('reason')}")

    mf_ds_fse, mf_ds, train_syms = acq["mf_ds_fse"], acq["mf_ds"], acq["train_syms"]
    n_margin = acq["n_margin"]

    print(f"\n===== Starting fine sweep: {len(k2_list)} x {len(kfb_list)} = "
          f"{len(k2_list) * len(kfb_list)} combos, each checked at "
          f"no_repass={no_repass_pair[0]} and {no_repass_pair[1]} =====")

    rows = []
    best_score = np.inf
    best_row = None
    best_data_out = None

    for K_2 in k2_list:
        decision_delay_try = K_2 // 4
        if decision_delay_try > n_margin:
            print(f"Skipping K_2={K_2}: decision_delay={decision_delay_try} "
                  f"exceeds margin={n_margin}")
            continue
        for K_fb in kfb_list:
            try:
                res_a = _run_equalizer(mf_ds_fse, mf_ds, train_syms, K_2, K_fb, no_repass_pair[0])
                res_b = _run_equalizer(mf_ds_fse, mf_ds, train_syms, K_2, K_fb, no_repass_pair[1])
            except Exception as err:  # noqa: BLE001 -- mirrors MATLAB's try/catch per-combo
                print(f"K_2={K_2} K_fb={K_fb} FAILED: {err}")
                continue
            if not (res_a.get("ok") and res_b.get("ok")):
                reason = res_a.get("reason") or res_b.get("reason")
                print(f"K_2={K_2} K_fb={K_fb} FAILED: {reason}")
                continue

            n_err = {}
            for tag, res in (("a", res_a), ("b", res_b)):
                frame_id, marker_score = identify_frame_id(res["bits_hat"])
                readable = marker_score <= marker_score_max
                if readable:
                    ref_bits = F.data_bits(frame_id)
                    n_err[tag] = int(np.sum(res["bits_hat"] != ref_bits))
                else:
                    # Unreadable (marker didn't match any frame_id): treat
                    # as a full-error combo for sorting/stability purposes,
                    # same spirit as the MATLAB sweep's implicit assumption
                    # that a decode either works or is clearly the worst
                    # case -- this keeps unreadable combos below every
                    # readable one instead of silently dropping them.
                    n_err[tag] = P.N_data_bits
                res["frame_id"] = frame_id if readable else None
                res["marker_score"] = marker_score
                res["readable"] = readable

            n_err_a, n_err_b = n_err["a"], n_err["b"]
            ber_a = n_err_a / P.N_data_bits
            ber_b = n_err_b / P.N_data_bits
            stable = (n_err_a == n_err_b)

            print(f"K_2={K_2:3d}  K_fb={K_fb:2d}  ->  "
                  f"BER@{no_repass_pair[0]}={ber_a:.5f} ({n_err_a})  "
                  f"BER@{no_repass_pair[1]}={ber_b:.5f} ({n_err_b})  "
                  f"train_BER={res_a['ber_train']:.5f}  SNR={res_a['snr_eq_db']:+.1f}dB  "
                  f"{'OK' if stable else 'UNSTABLE'}")

            row = dict(K_2=K_2, K_fb=K_fb, ber_a=ber_a, n_err_a=n_err_a,
                       ber_b=ber_b, n_err_b=n_err_b, stable=stable,
                       snr_eq_db=res_a["snr_eq_db"], train_ber=res_a["ber_train"])
            rows.append(row)

            worst_errors = max(n_err_a, n_err_b)
            score = worst_errors - 0.5 * stable - 1e-3 * res_a["snr_eq_db"]
            if score < best_score:
                best_score = score
                best_row = row
                best_data_out = res_a["data_out"]

    print("\n===== Fine sweep summary =====")
    print(f"{'K_2':>6} {'K_fb':>6} {'BER@' + str(no_repass_pair[0]):>10} "
          f"{'err@' + str(no_repass_pair[0]):>10} {'BER@' + str(no_repass_pair[1]):>10} "
          f"{'err@' + str(no_repass_pair[1]):>10} {'stable':>10} {'SNR(dB)':>10}")
    sorted_rows = sorted(rows, key=lambda r: (max(r["n_err_a"], r["n_err_b"]),
                                               0 if r["stable"] else 1,
                                               -r["snr_eq_db"]))
    for r in sorted_rows:
        print(f"{r['K_2']:6d} {r['K_fb']:6d} {r['ber_a']:10.5f} {r['n_err_a']:10d} "
              f"{r['ber_b']:10.5f} {r['n_err_b']:10d} "
              f"{'OK' if r['stable'] else 'UNSTABLE':>10} {r['snr_eq_db']:10.1f}")

    if best_row is not None:
        print(f"\nBest config: K_2={best_row['K_2']}  K_fb={best_row['K_fb']}  ->  "
              f"BER@{no_repass_pair[0]}={best_row['ber_a']:.5f} ({best_row['n_err_a']})  "
              f"BER@{no_repass_pair[1]}={best_row['ber_b']:.5f} ({best_row['n_err_b']})  "
              f"{'OK' if best_row['stable'] else 'UNSTABLE'}  SNR={best_row['snr_eq_db']:+.1f}dB")
        print("Set K_2/K_fb in lfm_qpsk_params.py to this winner for the full pipeline.")
        print("Remember: re-check this winner against another capture at this "
              "range/carrier before treating it as a validated default.")

        if plot_out:
            import matplotlib
            matplotlib.use("Agg")
            import matplotlib.pyplot as plt
            plt.figure(figsize=(5, 5))
            plt.plot(best_data_out.real, best_data_out.imag, '.')
            plt.title(f"Best config constellation: K_2={best_row['K_2']} "
                      f"K_fb={best_row['K_fb']} (no_repass={no_repass_pair[0]}), "
                      f"BER={best_row['ber_a']:.5f} ({best_row['n_err_a']} errors)")
            plt.xlabel("I"); plt.ylabel("Q")
            plt.axis("equal"); plt.grid(True)
            plt.savefig(plot_out, dpi=150, bbox_inches="tight")
            plt.close()
            print(f"Constellation plot saved to {plot_out}")
    else:
        print("\nNo config completed successfully -- check --k2-list / DEC_DELAY_MAX.")

    return dict(rows=rows, best_row=best_row, acq=acq)


def _parse_int_list(s: str):
    return [int(x) for x in s.split(",") if x.strip()]


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                  formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--capture", required=True, help="Path to lfm_iq_rx_capture_u32*.bin")
    ap.add_argument("--packet-idx", type=int, default=0,
                     help="Which detected LFM packet in the capture to sweep on (default 0)")
    ap.add_argument("--sample-ppm", type=float, default=None,
                     help="Override the auto-estimated sample-clock ppm")
    ap.add_argument("--k2-list", type=_parse_int_list, default=None,
                     help=f"Comma-separated K_2 grid (default {DEFAULT_K2_LIST})")
    ap.add_argument("--kfb-list", type=_parse_int_list, default=None,
                     help=f"Comma-separated K_fb grid (default {DEFAULT_KFB_LIST})")
    ap.add_argument("--no-repass-pair", type=_parse_int_list, default=None,
                     help=f"Two no_repass values to check for stability (default {list(DEFAULT_NO_REPASS_PAIR)})")
    ap.add_argument("--marker-score-max", type=int, default=8,
                     help="Max Hamming distance to accept a frame_id match as readable (default 8)")
    ap.add_argument("--plot", metavar="PNG_PATH", default=None,
                     help="Save the best config's data constellation to this PNG path")
    args = ap.parse_args()

    no_repass_pair = tuple(args.no_repass_pair) if args.no_repass_pair else DEFAULT_NO_REPASS_PAIR
    if len(no_repass_pair) != 2:
        raise SystemExit("--no-repass-pair needs exactly two values")

    sweep_fine(args.capture, k2_list=args.k2_list, kfb_list=args.kfb_list,
               no_repass_pair=no_repass_pair, packet_idx=args.packet_idx,
               sample_ppm=args.sample_ppm, marker_score_max=args.marker_score_max,
               plot_out=args.plot)


if __name__ == "__main__":
    main()
