"""
RX chain for the LFM + PRBS + QPSK port. Ported stage-for-stage from
lfmQpskPopotoRx330_nlms.m, adapted to FAU's real-baseband convention (no
Fc mixing -- the hardware NCO already downconverts to complex baseband
before capture, exactly like lfm_bpsk_rx.py; see that module's docstring)
and to a Python complex-capture input.

Differences vs lfm_bpsk_rx.py beyond the obvious (complex symbols, 2
bits/symbol) -- called out explicitly since they are real algorithmic
changes, not just find/replace:

  - Stage 5 (CFO): phi = angle(pre_mf * conj(train_syms)), NOT
    pre_mf * train_syms. BPSK's train_syms are real +-1 (their own
    conjugate), so the two forms happened to coincide there; QPSK's
    train_syms are genuinely complex, so the conj() is required -- this
    matches lfmQpskPopotoRx330_nlms.m's Stage 5 exactly.
  - Stage 6 (phase/quadrant resolution): QPSK's known pilot symbols are
    complex (not just +-1), so a single pilot-averaged cross term
    (h_est = mean(mf_ds[:N_train] * conj(train_syms))) resolves the FULL
    complex channel -- all 4 quadrants -- directly. No BPSK-style
    PCA-dominant-axis + 2-fold sign-flip step is needed or done.
  - Stage 8/9 (decision/soft-value): d_hard is a 4-point complex hard
    decision (sign of each rail, scaled by 1/sqrt(2)); the soft-decision
    tanh has an extra sqrt(2) factor vs BPSK's (tanh(gamma_soft*sqrt(2)*
    real(y)), not tanh(gamma_soft*real(y))) since QPSK's rails sit at
    +-1/sqrt(2) rather than +-1 -- matches lfmQpskPopotoRx330_nlms.m's
    Stage 8/9 exactly. Erasure (|component|<0.15 -> 0) is applied to the
    I and Q rails independently.

FIDELITY NOTE: the MATLAB source is 1-indexed; this port keeps symbol/
sample indices computed exactly as the .m file does and only converts to
0-indexed Python at the point of array access (see _m1/_mslice below),
matching lfm_bpsk_rx.py's approach for the same reason (avoid off-by-one
drift from the validated reference).

RLS is intentionally NOT implemented here, same rationale as
lfm_bpsk_rx.py: NLMS is the validated, recommended path.
"""

import numpy as np

import lfm_qpsk_params as P
import lfm_qpsk_frame as F


# ----------------------------------------------------------------------
# 1-indexed (MATLAB-style) access helpers -- identical to lfm_bpsk_rx.py.
# ----------------------------------------------------------------------
def _m1(arr, idx1):
    """Single-element MATLAB-style 1-indexed get: arr(idx1)."""
    return arr[int(idx1) - 1]


def _mslice(arr, start1, end1, step1=1):
    """MATLAB-style a(start1:step1:end1), inclusive both ends."""
    start1 = int(start1); end1 = int(end1); step1 = int(step1)
    if step1 > 0:
        return arr[start1 - 1: end1: step1]
    stop_py = end1 - 2
    if stop_py < 0:
        return arr[start1 - 1::step1]
    return arr[start1 - 1: stop_py: step1]


def _fir_filter(h, x):
    return np.convolve(x, h)[:len(x)]


def _slice_zero_padded(x: np.ndarray, start: int, length: int) -> np.ndarray:
    """x[start:start+length], zero-padded at either end as needed, WITHOUT
    ever copying/padding the full array -- only the requested window."""
    Nx = len(x)
    end = start + length
    lo = max(start, 0)
    hi = min(end, Nx)
    if lo >= hi:
        return np.zeros(length, dtype=x.dtype)
    core = x[lo:hi]
    left_pad = lo - start
    right_pad = length - left_pad - len(core)
    if left_pad == 0 and right_pad == 0:
        return core
    return np.concatenate([np.zeros(left_pad, dtype=x.dtype), core,
                            np.zeros(right_pad, dtype=x.dtype)])


def _overlap_save_blocks(h: np.ndarray, x: np.ndarray, block_size: int):
    """Shared overlap-save iterator -- identical to lfm_bpsk_rx.py's; see
    that module's docstring for why block-wise FFT filtering (bounded
    memory per block) is required on the RX board's RAM budget."""
    Nx, M = len(x), len(h)
    if Nx == 0:
        return
    Nfft = max(1 << (M - 1).bit_length(), int(block_size))
    step = Nfft - (M - 1)
    if step <= 0:
        Nfft = 1 << (2 * M - 1).bit_length()
        step = Nfft - (M - 1)

    H = np.fft.fft(h, Nfft)
    out_pos = 0
    while out_pos < Nx:
        block = _slice_zero_padded(x, out_pos - (M - 1), Nfft)
        Y = np.fft.ifft(np.fft.fft(block, Nfft) * H)
        valid = Y[M - 1: M - 1 + step]
        n_take = min(step, Nx - out_pos)
        yield out_pos, n_take, valid
        out_pos += n_take


def _fir_filter_fft(h: np.ndarray, x: np.ndarray,
                    block_size: int = 1 << 18) -> np.ndarray:
    """Causal FIR filter via block-wise (overlap-save) FFT -- identical to
    lfm_bpsk_rx.py's; unused by decode_packet directly (kept for parity /
    future large-capture use), same as the BPSK port."""
    out = np.empty(len(x), dtype=np.complex128)
    for out_pos, n_take, valid in _overlap_save_blocks(h, x, block_size):
        out[out_pos: out_pos + n_take] = valid[:n_take]
    return out


# ----------------------------------------------------------------------
# STAGE 2: LFM matched-filter packet detection (multi-packet capable).
# Modulation-agnostic -- identical to lfm_bpsk_rx.py's, just referencing
# lfm_qpsk_params/lfm_qpsk_tx.
# ----------------------------------------------------------------------
def lfm_matched_filter(rx_raw: np.ndarray, block_size: int = 1 << 18) -> np.ndarray:
    lfm = P_lfm_ref()
    h = lfm[::-1]  # real-valued -> conj() is a no-op, matches Popoto
    already_c128 = np.iscomplexobj(rx_raw) and rx_raw.dtype == np.complex128
    x = rx_raw if already_c128 else rx_raw.astype(np.complex128)

    mf_power = np.empty(len(x), dtype=np.float64)
    for out_pos, n_take, valid in _overlap_save_blocks(h, x, block_size):
        v = valid[:n_take]
        mf_power[out_pos: out_pos + n_take] = v.real ** 2 + v.imag ** 2
    return mf_power


_LFM_REF_CACHE = None


def P_lfm_ref():
    global _LFM_REF_CACHE
    if _LFM_REF_CACHE is None:
        import lfm_qpsk_tx as TX
        _LFM_REF_CACHE = TX.generate_lfm()
    return _LFM_REF_CACHE


def detect_lfm_packets(rx_raw: np.ndarray, min_peak_ratio: float = 500.0,
                        min_spacing: int = None) -> list:
    """
    Find all LFM packet starts in a (possibly multi-frame) capture.
    Identical logic to lfm_bpsk_rx.py's detect_lfm_packets(), just using
    QPSK's own per-frame sample count (min_spacing) since N_syms_total is
    the same 1224 but bps_sym differs -- min_spacing only depends on
    sample counts, not bits/symbol, so this comes out numerically
    identical to the BPSK port's default for the same N_syms_total/sps.
    """
    if min_spacing is None:
        min_spacing = P.N_lfm + P.N_guard + P.N_syms_total * P.sps // 2

    mf_power = lfm_matched_filter(rx_raw)
    noise_floor = np.median(mf_power) + 1e-30
    threshold = noise_floor * min_peak_ratio

    above = mf_power > threshold
    if not np.any(above):
        return []

    peaks = []
    remaining = np.where(above, mf_power, -1.0)
    del above, mf_power
    while True:
        peak_idx = int(np.argmax(remaining))
        if remaining[peak_idx] <= threshold:
            break
        peaks.append(peak_idx)
        lo = max(0, peak_idx - min_spacing)
        hi = min(len(remaining), peak_idx + min_spacing)
        remaining[lo:hi] = -1

    peaks.sort()
    lfm_starts = [p - P.N_lfm + 1 for p in peaks if p - P.N_lfm + 1 >= 0]
    return lfm_starts


# ----------------------------------------------------------------------
# Per-packet NLMS-DFE decode (Stages 3-13, matching lfmQpskPopotoRx330_
# nlms.m's stage numbering -- Stage 1's software mix-down is skipped, same
# as the BPSK port, since the capture is already complex baseband).
# ----------------------------------------------------------------------
_COARSE_BLOCK_LEN = 8   # Stage 3b coherent-block length, see decode_packet()'s
                        # Stage 3b comment. Module-level so it can be tuned/
                        # swept without editing the function. The coarse-CFO
                        # unwrap below only works if consecutive blocks'
                        # phase step is < pi, i.e. |CFO| < Rs/(2*BLOCK_LEN);
                        # real hardware measured ~360-550 Hz (2026-09-01),
                        # so BLOCK_LEN=32 (alias limit ~260 Hz) is NOT
                        # sufficient -- BLOCK_LEN=8 (alias limit ~1042 Hz)
                        # is needed for headroom.


def decode_packet(rx_raw: np.ndarray, lfm_start: int, sample_ppm: float = 0.0,
                  verbose: bool = False) -> dict:
    """
    Decode one packet starting at lfm_start (0-indexed sample offset of
    the LFM burst's first sample within rx_raw). Returns a dict with the
    decoded bits, per-symbol equalizer output, and diagnostics -- same
    shape as lfm_bpsk_rx.decode_packet()'s return dict (so
    lfm_qpsk_common.analyze_capture() can mirror lfm_bpsk_common.py's
    structure), generalized to complex data_out/eq_out.

    sample_ppm corrects for the TX/RX sample-clock mismatch, same
    convention as the BPSK port -- see lfm_bpsk_rx.py's Stage 4 comment.
    """
    train_syms = F.train_syms()  # (N_train,) complex128

    # --- Stage 3: extract QPSK segment, no carrier mixing (real baseband) ---
    rrc_delay = P.span * P.sps // 2
    qpsk_start_raw = lfm_start + P.N_lfm + P.N_guard  # 0-indexed
    seg_end = min(len(rx_raw), qpsk_start_raw + (P.N_syms_total + P.DEC_DELAY_MAX) * P.sps + rrc_delay)
    rx_qpsk_seg = rx_raw[qpsk_start_raw: seg_end]
    if len(rx_qpsk_seg) < P.N_train * P.sps:
        return dict(ok=False, reason="capture too short past LFM+guard for this packet")

    rx_bb = rx_qpsk_seg.astype(np.complex128)

    flush_rx = np.zeros(P.span * P.sps, dtype=np.complex128)
    mf_qpsk = _fir_filter(_base_rrc(), np.concatenate([rx_bb, flush_rx]))
    mf_qpsk = mf_qpsk[P.span * P.sps // 2:]

    # --- Stage 3b: coarse symbol-rate correlation against training ---
    # CFO-tolerant, non-coherent BLOCK correlation -- NOT a single
    # N_train=1024-symbol fully-coherent correlation (what the original
    # port here, and lfm_bpsk_rx.py's equivalent, both did). A single
    # 1024-symbol coherent sum is only robust to a few tens of Hz of CFO
    # before the phase rotation across the window destructively
    # interferes with itself and erases the true peak; confirmed failing
    # on real two-board hardware captures 2026-09-01 (every packet
    # mis-syncing to a bogus late position and then failing downstream
    # with "capture too short to contain full QPSK frame"), and
    # reproduced synthetically here starting around CFO~50 Hz -- well
    # within the range two independent boards' free-running crystals can
    # produce. Splitting the training sequence into BLOCK_LEN-symbol
    # chunks, correlating each chunk COHERENTLY (short enough that
    # realistic CFO barely rotates the phase within one chunk), then
    # combining chunks NON-coherently (summing magnitudes, so each
    # chunk's own uncorrected inter-chunk phase doesn't cancel) is the
    # standard fix for this (same idea as GNSS acquisition's coherent/
    # non-coherent integration split). This also fixes a separate,
    # previously-latent indexing bug: the old `hi = lo + len(mf_ds_coarse)`
    # let the argmax search wander into the correlation's PARTIAL-overlap
    # tail (where the template hangs off the end of the array), not just
    # the legitimately fully-overlapping region -- harmless when the true
    # peak dominates (as in every synthetic zero-CFO test so far), but a
    # ready source of spurious out-of-bounds peaks once CFO had already
    # weakened the true one. `valid_len` below is the correctly-bounded
    # (Na - N_train + 1) fully-overlapping region only.
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

    peak_sym0 = int(np.argmax(score))  # 0-indexed
    xcorr_peak = score[peak_sym0] / P.N_train  # same normalisation convention
                                                # as the old fully-coherent
                                                # metric: ~1.0 at a perfect,
                                                # zero-CFO match
    peak_sym = peak_sym0 + 1  # MATLAB 1-indexed, matches n_start/etc formulas below

    # --- Coarse CFO estimate, from the SAME block correlations above ---
    # Real two-board hardware captures showed CFO of several HUNDRED Hz
    # (2026-09-01) -- large enough that even the sub-sample "eye" scan
    # just below (a 128-symbol COHERENT dot product) decorrelates on its
    # own and can pick the wrong sub-sample offset, and large enough that
    # Stage 5's fine per-symbol iterative estimate (a small-signal
    # refinement, not designed to acquire hundreds of Hz from scratch)
    # cannot reliably converge either. This block's own per-block complex
    # correlation VALUES (not just their magnitudes, already used for
    # timing above) at the winning lag give a robust, coarse, block-
    # granular CFO estimate: unwrap + linear-fit the phase across block
    # index (BLOCK_LEN-symbol steps are short enough that CFO up to
    # Rs/(2*BLOCK_LEN) -- roughly 1 kHz at the default BLOCK_LEN=8 --
    # cannot alias the unwrap between consecutive blocks). Applied here
    # to de-rotate mf_qpsk BEFORE the eye scan and Stage 4, so everything
    # downstream only has to deal with the small residual Stage 5 is
    # actually designed for.
    block_phasors = block_c[:, peak_sym0]
    block_w = np.abs(block_phasors)
    if np.sum(block_w) > 0 and n_blocks >= 2:
        block_phase = np.unwrap(np.angle(block_phasors))
        block_sym0 = np.arange(n_blocks) * BLOCK_LEN  # each block's start, in symbols
        coeffs_coarse = np.polyfit(block_sym0, block_phase, 1, w=block_w)
        cfo_coarse_hz = float(coeffs_coarse[0] * P.Rs / (2 * np.pi))
    else:
        cfo_coarse_hz = 0.0
    if cfo_coarse_hz != 0.0:
        t_mf = np.arange(len(mf_qpsk)) / P.Fs
        mf_qpsk = mf_qpsk * np.exp(-1j * 2 * np.pi * cfo_coarse_hz * t_mf)

    # --- Sub-sample scan (matches Popoto's Stage 3 fine search) ---
    N_scan = 128
    pre_short = train_syms[:N_scan]
    best_eye = 0.0
    best_t0 = (peak_sym - 1) * P.sps + 1  # 1-indexed
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

    # --- Stage 4: T/2 fractionally-spaced extraction ---
    sps_eff = P.sps * (1.0 + float(sample_ppm) * 1e-6)
    sps_fse_eff = sps_eff / 2.0
    mf_t0 = best_t0
    t_end_base = mf_t0 + (P.N_syms_total - 1) * sps_eff
    if t_end_base > len(mf_qpsk):
        return dict(ok=False, reason="capture too short to contain full QPSK frame")
    n_extra_avail = int(np.floor((len(mf_qpsk) - t_end_base) / sps_eff))
    n_margin = min(P.DEC_DELAY_MAX, max(n_extra_avail, 0))
    decision_delay = P.K_2 // 4
    if decision_delay > n_margin:
        return dict(ok=False, reason=(
            f"decision_delay={decision_delay} exceeds available lookahead "
            f"margin ({n_margin} symbols)"))

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

    # --- Stage 5: iterative CFO (linear phase-ramp) estimation ---
    # NOTE conj(train_syms) here -- required for genuinely complex pilots
    # (see module docstring); BPSK's real +-1 pilots made this a no-op.
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

    # --- Stage 6: pilot-aided absolute phase / quadrant resolution ---
    # QPSK's pilots are genuinely complex, so a single pilot-averaged
    # cross term resolves ALL 4 quadrants directly -- no BPSK-style
    # PCA + 2-fold sign-flip is needed (see module docstring).
    h_est = np.mean(mf_ds[:P.N_train] * np.conj(train_syms))
    rot_angle = float(np.angle(h_est))
    mf_ds = mf_ds * np.exp(-1j * rot_angle)
    mf_ds_fse = mf_ds_fse * np.exp(-1j * rot_angle)

    # Diagnostic: hard-decide the preamble post-rotation and count
    # correctly-decided BITS against the known training bits (both I/Q
    # rails) -- a QPSK-appropriate analogue of the BPSK port's polarity
    # "agree" count, kept under the same field name for return-dict
    # parity with lfm_bpsk_rx.decode_packet().
    pre_syms = mf_ds[:P.N_train]
    b1_chk = (pre_syms.real < 0).astype(np.uint8)
    b2_chk = (pre_syms.imag < 0).astype(np.uint8)
    pre_bits_hat = np.empty(2 * P.N_train, dtype=np.uint8)
    pre_bits_hat[0::2] = b1_chk
    pre_bits_hat[1::2] = b2_chk
    agree = int(np.sum(pre_bits_hat == F.train_bits()))

    # --- Stage 7: batch-LS DFE init over the training region (T/2 FSE) ---
    K_2, K_fb = P.K_2, P.K_fb
    decided_syms = np.zeros(P.N_syms_total, dtype=np.complex128)
    decided_syms[:P.N_train] = train_syms

    n_start = max(int(np.ceil(K_2 / 2)), K_fb + decision_delay)
    n_end = P.N_train - 1
    n_rows = n_end - n_start + 1
    if n_rows <= 0:
        return dict(ok=False, reason="training region too short for chosen K_2/K_fb")

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
    wc = np.linalg.solve(A_pre, Z_pre.conj().T @ d_pre)
    wc_init = wc.copy()

    pred_train = Z_pre @ wc
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
    SQRT2 = np.sqrt(2.0)

    def run_pass(fb_source_for_data):
        nonlocal_wc = wc_init.copy()
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

                y_raw = np.vdot(nonlocal_wc, z_win)
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
                nonlocal_wc = nonlocal_wc + raw_gain * np.conj(err_eq) * z_win
                wn = np.linalg.norm(nonlocal_wc)
                if wn > P.w_norm_max:
                    nonlocal_wc = nonlocal_wc * (P.w_norm_max / wn)

        for m in range(P.N_train + 1, P.N_syms_total + 1):
            n = m + decision_delay
            idx_end = n * 2 + 1
            x_win = _mslice(mf_ds_fse, idx_end, idx_end - K_2 + 1, -1)
            fb_win = _mslice(fb_source_for_data, m - 1, m - K_fb, -1) if K_fb > 0 else np.zeros(0, dtype=np.complex128)
            z_win = np.concatenate([x_win, -fb_win])

            y_raw = np.vdot(nonlocal_wc, z_win)
            y = y_raw * np.exp(-1j * theta)
            eq_out[m - 1] = y

            # QPSK 4-point hard decision (each rail independently signed,
            # scaled to the +-1/sqrt(2) constellation).
            d_hard = complex(np.sign(y.real), np.sign(y.imag)) / SQRT2

            # Soft decision: note the extra sqrt(2) factor vs BPSK's
            # tanh(gamma_soft*y.real) -- QPSK's rails sit at +-1/sqrt(2),
            # not +-1, so the tanh needs it to saturate at the same input
            # excursion (matches lfmQpskPopotoRx330_nlms.m Stage 8/9).
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
            nonlocal_wc = nonlocal_wc + raw_gain * np.conj(err_eq) * z_win
            wn = np.linalg.norm(nonlocal_wc)
            if wn > P.w_norm_max:
                nonlocal_wc = nonlocal_wc * (P.w_norm_max / wn)

        return eq_out, local_decided

    def _bits_from_syms(syms):
        b1 = (syms.real < 0).astype(np.uint8)
        b2 = (syms.imag < 0).astype(np.uint8)
        bits = np.empty(2 * len(syms), dtype=np.uint8)
        bits[0::2] = b1
        bits[1::2] = b2
        return bits

    eq_out, decided_syms = run_pass(decided_syms)
    data_out_s8 = eq_out[P.N_train:]
    bits_hat_s8 = _bits_from_syms(data_out_s8)

    for _k in range(P.no_repass):
        decided_prev = decided_syms.copy()
        for idx2 in range(P.N_train, P.N_syms_total):
            val = decided_prev[idx2]
            r_val = val.real
            i_val = val.imag
            r_val = 0.0 if abs(r_val) < 0.15 else np.sign(r_val) / SQRT2
            i_val = 0.0 if abs(i_val) < 0.15 else np.sign(i_val) / SQRT2
            decided_prev[idx2] = complex(r_val, i_val)
        eq_out, decided_syms = run_pass(decided_prev)

    data_out = eq_out[P.N_train:]
    bits_hat = _bits_from_syms(data_out)

    # No-equalizer baseline decision, for comparison: just slice the
    # matched-filter output after CFO correction + global rotation
    # (Stage 6), with no ISI cancellation at all.
    bits_naive = _bits_from_syms(mf_ds[P.N_train:P.N_train + P.N_data])

    return dict(
        ok=True,
        bits_hat=bits_hat,
        bits_naive=bits_naive,
        eq_out=eq_out,
        data_out=data_out,
        mf_ds=mf_ds,
        wc=wc,
        ber_train=ber_train,
        xcorr_peak=xcorr_peak,
        direct_corr_pre=direct_corr_pre,
        direct_corr_post=direct_corr_post,
        CFO_total=cfo_coarse_hz + CFO_total,
        cfo_coarse_hz=cfo_coarse_hz,
        cfo_fine_hz=CFO_total,
        rot_angle=rot_angle,
        agree=agree,
        best_t0=best_t0,
        bits_hat_s8=bits_hat_s8,
    )


_RRC_CACHE = None


def _base_rrc():
    global _RRC_CACHE
    if _RRC_CACHE is None:
        import bpsk_params as _bp
        _RRC_CACHE = _bp.RRC
    return _RRC_CACHE
