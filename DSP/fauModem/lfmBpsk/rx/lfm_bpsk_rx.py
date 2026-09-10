"""
RX chain for the LFM + PRBS + BPSK port. Ported stage-for-stage from
lfmBpskPopotoRx330_N152_nlms.m (Stages 1-13), adapted to FAU's real-
baseband convention (no Fc mixing) and to a Python complex-capture input
(unpack_q15 gives real+imag from hardware quadrature sampling, even though
TX only ever wrote a real/imag=0 baseband waveform -- matches how
bpsk_rx.py's rx_frontend already treats captures).

FIDELITY NOTE: the MATLAB source is 1-indexed; this port keeps symbol/
sample indices computed exactly as the .m file does and only converts to
0-indexed Python at the point of array access (see _m1/_mslice below),
specifically to avoid introducing off-by-one deviations from the
validated reference -- see lfm_bpsk_params.py's docstring on why RLS
diverged in this project when its implementation drifted from spec.

RLS is intentionally NOT implemented here yet: the reference RLS file
carries an explicit caveat that it diverged on real BPSK captures via a
decision-feedback error cascade and was never validated on real data for
coherent BPSK. NLMS is the validated, recommended path; add RLS only
after that caveat can be investigated on FAU's own real captures.
"""

import math

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_frame as F


# ----------------------------------------------------------------------
# 1-indexed (MATLAB-style) access helpers -- see FIDELITY NOTE above.
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
    """
    Shared overlap-save iterator: yields (out_pos, n_take, valid) blocks
    such that valid[:n_take] is the next n_take samples of the causal
    linear convolution conv(x, h)[:len(x)] -- numerically the same as
    np.convolve(x, h)[:len(x)], but computed one FFT block at a time so
    memory per block is bounded by block_size regardless of len(x).

    A single-shot whole-capture FFT was tried first (mirroring bpsk_rx.py's
    _fft_correlate() helper, which replaces scipy.signal.correlate the
    same way since scipy isn't available on the RX board). It's numerically
    fine, but at this capture's length (~6.3M complex samples) the
    next-power-of-2 FFT size is ~8.4M, and several ~128MiB arrays that
    size need to be alive at once. The multichannel_7010 RX board only has
    ~490MB of usable, swap-less RAM, and that approach OOM-killed the RX
    process outright (confirmed on real hardware, 2026-08-27) -- worse
    than the original direct-np.convolve version, which was merely slow
    and never crashed. Overlap-save keeps every FFT-sized temporary at
    block_size (a few MiB here) independent of capture length, which is
    what actually fits in that budget.
    """
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
    """
    Causal FIR filter via block-wise (overlap-save) FFT, output truncated
    to len(x). O(N log block_size) instead of O(len(x)*len(h)); see
    _overlap_save_blocks() for why block-wise processing (vs. one
    whole-capture FFT) is required on this hardware's RAM budget.
    """
    out = np.empty(len(x), dtype=np.complex128)
    for out_pos, n_take, valid in _overlap_save_blocks(h, x, block_size):
        out[out_pos: out_pos + n_take] = valid[:n_take]
    return out


# Block length for the Stage-5 CFO phase-ramp fit. Two constraints pull
# against each other: unwrap needs the phase step between adjacent blocks
# below pi, so |CFO| < Rs/(2*BLOCK); and the coherent sum WITHIN a block
# decoheres once the rotation across it approaches a cycle, which wants
# BLOCK small. Measured estimator error on the 2-tap synthetic channel at
# 18 dB (peak position given):
#
#   BLOCK   alias limit   err @360Hz   err @550Hz   err @800Hz
#       4       2083 Hz     -0.02 Hz     -0.04 Hz     -0.05 Hz
#       8       1042 Hz     -0.02 Hz     -0.06 Hz    -18.16 Hz
#      16        521 Hz     -0.05 Hz   -791.69 Hz  -1042.33 Hz
#      64        130 Hz   -280.77 Hz   -520.87 Hz   -795.66 Hz
#
# Real hardware CFO is 360-550 Hz (measured 2026-09-01, see the same
# constant in lfm_qpsk_rx.py), so 8 covers it with ~2x headroom. Drop to
# 4 if hardware ever exceeds ~700 Hz.
_CFO_BLOCK_LEN = 8


def _cfo_from_block_phasors(pre_mf: np.ndarray, train_syms: np.ndarray,
                            block_len: int = None) -> float:
    """
    Estimate the residual carrier offset (Hz) from the phase progression
    across short coherent blocks of the training sequence.

    Replaces a per-symbol phase unwrap:

        phi = np.unwrap(np.angle(pre_mf * train_syms))
        slope = np.polyfit(np.arange(N_train), phi, 1)[0]

    which was unusable. One symbol carries too little signal to measure a
    phase from, so at realistic SNR noise pushes samples past +/-pi,
    np.unwrap reads that as a wrap and adds 2*pi permanently to every
    later sample -- 100-160 such false jumps at 5-10 Hz offset, measured.
    The line is then fitted to a random staircase. It returned -65 Hz on
    a packet with ZERO offset, and -29.7 Hz on one with +10 Hz.

    Summing BLOCK symbols coherently first (train_syms is real +-1, so
    multiplying by it strips the data modulation) gives each phase point
    ~9 dB more signal and leaves only N_train/BLOCK points to unwrap
    instead of N_train. The fit is weighted by block magnitude so blocks
    that landed in a fade count less.

    Measured mean |error| at 10 Hz over 8 noise seeds: 37.55 Hz for the
    per-symbol version, 0.02 Hz for this one. Accurate at zero offset
    too (0.007 Hz), so it is safe to call unconditionally.

    Returns 0.0 when there is nothing to fit (fewer than 2 blocks, or an
    all-zero training window).
    """
    if block_len is None:
        block_len = _CFO_BLOCK_LEN
    n_blk = len(train_syms) // block_len
    if n_blk < 2:
        return 0.0
    n_use = n_blk * block_len
    prod = (pre_mf[:n_use] * train_syms[:n_use]).reshape(n_blk, block_len)
    phasors = prod.sum(axis=1)
    w = np.abs(phasors)
    if not np.any(w > 0):
        return 0.0
    phase = np.unwrap(np.angle(phasors))
    # Block START index, matching the QPSK port. Using the block centre
    # instead would shift only the fit's intercept, not its slope.
    idx = np.arange(n_blk) * block_len
    slope = np.polyfit(idx, phase, 1, w=w)[0]
    return float(slope * P.Rs / (2 * np.pi))


# ----------------------------------------------------------------------
# STAGE 2: LFM matched-filter packet detection (multi-packet capable).
# ----------------------------------------------------------------------
def lfm_matched_filter(rx_raw: np.ndarray, block_size: int = 1 << 18) -> np.ndarray:
    """
    |matched-filter output|^2 against the known LFM reference, computed
    block-by-block straight into a REAL-valued result -- the complex
    matched-filter output itself is never materialized as a full-capture
    array (packet detection only ever needs its squared magnitude), which
    halves the size of the single biggest array this stage would
    otherwise need. Combined with the block-wise FFT in
    _overlap_save_blocks(), this is what actually fits the RX board's
    ~490MB swap-less RAM budget for a multi-million-sample capture
    (confirmed on real hardware, 2026-08-27 -- see that function's
    docstring for the OOM this replaces).
    """
    lfm = P_lfm_ref()
    h = lfm[::-1]  # real-valued -> conj() is a no-op, matches Popoto
    # Avoid a redundant full-capture copy when rx_raw is already
    # complex128 -- astype() always copies by default, and at ~100MB per
    # copy that matters on the RX board's tight, swap-less RAM budget.
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
        import lfm_bpsk_tx as TX
        _LFM_REF_CACHE = TX.generate_lfm()
    return _LFM_REF_CACHE


# Channel-impulse-response window taken around each LFM correlation peak
# for the delay-spread estimate. Reaches back a little before the direct
# arrival (early multipath, and the probe's own leading skirt) and forward
# across the guard interval, which is what the CP was sized to cover.
_CIR_PRE = 8 * P.sps
_CIR_POST = P.N_guard

# Bins below this fraction of the peak are treated as noise and excluded
# from the second moment. Without a floor, the millions of noise-only bins
# in the window dominate sum(p*(t-tbar)^2) and tau_rms just reports the
# window width. -20 dB is the usual convention for RMS delay spread.
_CIR_FLOOR = 10 ** (-20 / 10.0)


def _tau_rms_from_cir(cir_pwr: np.ndarray, peak_off: int) -> float:
    """
    RMS delay spread, in SAMPLES, from one |matched-filter|^2 window.

    cir_pwr is the correlator power around a detection; peak_off is the
    peak's index within it. Standard second moment of the power-delay
    profile:

        tau_bar = sum(p*t) / sum(p)
        tau_rms = sqrt( sum(p*(t - tau_bar)^2) / sum(p) )

    The estimate is inflated by the probe's own resolution -- the LFM
    sweeps f2-f1 Hz, so it cannot resolve arrivals closer than ~1/(f2-f1)
    and its autocorrelation has that width even on a single-path channel.
    Subtract that in quadrature to deconvolve; see tau_rms_probe_samples().

    Returns 0.0 if nothing clears the noise floor.
    """
    p = np.asarray(cir_pwr, dtype=np.float64)
    if p.size == 0:
        return 0.0
    pk = p.max()
    if pk <= 0:
        return 0.0
    # Median of the window is the noise level (the CIR occupies a small
    # fraction of it), so removing it stops noise biasing the moments.
    p = p - np.median(p)
    p[p < pk * _CIR_FLOOR] = 0.0
    tot = p.sum()
    if tot <= 0:
        return 0.0
    t = np.arange(p.size, dtype=np.float64) - peak_off
    tau_bar = float((p * t).sum() / tot)
    var = float((p * (t - tau_bar) ** 2).sum() / tot)
    return float(np.sqrt(max(var, 0.0)))


def tau_rms_probe_samples() -> float:
    """
    The delay spread this LFM probe reports on a single-path channel --
    i.e. the floor of the measurement, set by the chirp's own bandwidth.
    Measure it once on a clean synthetic packet and subtract it in
    quadrature: tau_true = sqrt(max(tau_meas^2 - tau_probe^2, 0)).
    """
    lfm = P_lfm_ref().astype(np.complex128)
    ac = np.abs(np.convolve(lfm, np.conj(lfm[::-1]))) ** 2
    return _tau_rms_from_cir(ac, int(np.argmax(ac)))


def detect_lfm_packets(rx_raw: np.ndarray, min_peak_ratio: float = 500.0,
                        min_spacing: int = None, with_tau: bool = False):
    """
    Find all LFM packet starts in a (possibly multi-frame) capture.

    Returns a list of 0-indexed sample offsets where each detected LFM
    burst starts (peak_idx - N_lfm + 1 in Popoto's 1-indexed convention).

    with_tau=True instead returns (lfm_starts, tau_rms_samples), the
    per-packet RMS delay spread measured from the correlator envelope
    around each peak. Default False keeps the original return type, since
    every existing caller iterates the list directly.
    """
    if min_spacing is None:
        min_spacing = P.N_lfm + P.N_guard + P.N_syms_total * P.sps // 2

    mf_power = lfm_matched_filter(rx_raw)
    noise_floor = np.median(mf_power) + 1e-30
    threshold = noise_floor * min_peak_ratio

    above = mf_power > threshold
    if not np.any(above):
        return ([], []) if with_tau else []

    # Greedy peak-picking: take the global max within each min_spacing
    # window, remove it and its neighborhood, repeat.
    # (np.where(above, mf_power, -1.0) in place of a copy()+np.isin()
    # mask -- the isin/arange approach materializes a couple of extra
    # full-capture-length index arrays that this hardware's RAM budget
    # can't spare; see _overlap_save_blocks()'s docstring for context.)
    peaks = []
    remaining = np.where(above, mf_power, -1.0)
    del above
    # mf_power (one float64 per capture sample, ~50 MB for 6.3M samples on
    # a board with ~490 MB and no swap) is normally freed right here. When
    # the delay spread is wanted it has to stay alive through peak-picking
    # instead, because `remaining` gets blanked to -1 around each peak --
    # destroying the very envelope tau_rms needs. Keeping it costs no
    # extra peak memory: the np.where above already had both arrays alive
    # at once, so this only delays the free, it does not add an
    # allocation. Each window copied out is a few thousand samples.
    cir = None if not with_tau else {}
    while True:
        peak_idx = int(np.argmax(remaining))
        if remaining[peak_idx] <= threshold:
            break
        peaks.append(peak_idx)
        if with_tau:
            lo = max(0, peak_idx - _CIR_PRE)
            hi = min(len(mf_power), peak_idx + _CIR_POST)
            cir[peak_idx] = (mf_power[lo:hi].copy(), peak_idx - lo)
        lo = max(0, peak_idx - min_spacing)
        hi = min(len(remaining), peak_idx + min_spacing)
        remaining[lo:hi] = -1
    del mf_power

    peaks.sort()
    # peak_idx (0-indexed) corresponds to MATLAB's peak_idx (1-indexed
    # sample where the LFM tail aligns); lfm_start (0-indexed) = peak_idx - N_lfm + 1
    kept = [p for p in peaks if p - P.N_lfm + 1 >= 0]
    lfm_starts = [p - P.N_lfm + 1 for p in kept]
    if not with_tau:
        return lfm_starts
    taus = [_tau_rms_from_cir(*cir[p]) if p in cir else 0.0 for p in kept]
    return lfm_starts, taus


# ----------------------------------------------------------------------
# Per-packet NLMS-DFE decode (Stages 3-13).
# ----------------------------------------------------------------------
def decode_packet(rx_raw: np.ndarray, lfm_start: int, sample_ppm: float = 0.0,
                  verbose: bool = False, K_2: int = None, K_fb: int = None,
                  no_repass: int = None) -> dict:
    """
    Decode one packet starting at lfm_start (0-indexed sample offset of
    the LFM burst's first sample within rx_raw). Returns a dict with the
    decoded bits, per-symbol equalizer output, and diagnostics.

    sample_ppm corrects for the TX/RX sample-clock mismatch between two
    independent, free-running board crystals -- see Stage 4 below. 0.0
    (default) reproduces the original fixed-P.sps extraction exactly.

    K_2 / K_fb / no_repass override the equalizer geometry for this call
    only, leaving lfm_bpsk_params untouched. None (default) reads the
    module values, which reproduces the original behaviour exactly -- so
    with all three left alone this function is bit-identical to before
    they existed (checked by verify_bit_identical.py). They exist so
    tap_sweep.py can score candidates without mutating global state,
    which would otherwise leak between packets and make a sweep depend
    on the order it ran in.
    """
    K_2 = P.K_2 if K_2 is None else int(K_2)
    K_fb = P.K_fb if K_fb is None else int(K_fb)
    no_repass = P.no_repass if no_repass is None else int(no_repass)
    if K_2 < 2 or K_fb < 0 or no_repass < 0:
        raise ValueError(f"invalid equalizer geometry: K_2={K_2}, "
                         f"K_fb={K_fb}, no_repass={no_repass}")

    train_syms = F.train_syms()  # (N_train,) float64, {-1,+1}

    # --- Stage 3: extract BPSK segment, no carrier mixing (real baseband) ---
    rrc_delay = P.span * P.sps // 2
    bpsk_start_raw = lfm_start + P.N_lfm + P.N_guard  # 0-indexed
    seg_end = min(len(rx_raw), bpsk_start_raw + (P.N_syms_total + P.DEC_DELAY_MAX) * P.sps + rrc_delay)
    rx_bpsk_seg = rx_raw[bpsk_start_raw: seg_end]
    if len(rx_bpsk_seg) < P.N_train * P.sps:
        return dict(ok=False, reason="capture too short past LFM+guard for this packet")

    rx_bb = rx_bpsk_seg.astype(np.complex128) if np.iscomplexobj(rx_raw) else rx_bpsk_seg.astype(np.complex128)

    flush_rx = np.zeros(P.span * P.sps, dtype=np.complex128)
    mf_bpsk = _fir_filter(_base_rrc(), np.concatenate([rx_bb, flush_rx]))
    mf_bpsk = mf_bpsk[P.span * P.sps // 2:]

    # --- Stage 3b: coarse symbol-rate correlation against training ---
    mf_ds_coarse = mf_bpsk[::P.sps]
    pwr = np.mean(np.abs(mf_ds_coarse) ** 2)
    if pwr > 0:
        mf_ds_coarse = mf_ds_coarse / np.sqrt(pwr)

    template_rev = train_syms[::-1].astype(np.complex128)
    xc_conv = np.abs(np.convolve(mf_ds_coarse, template_rev, mode="full"))
    lo = P.N_train - 1
    hi = lo + len(mf_ds_coarse)
    xc_valid = xc_conv[lo:hi]
    if len(xc_valid) == 0:
        return dict(ok=False, reason="capture too short for coarse xcorr")
    peak_sym0 = int(np.argmax(xc_valid))  # 0-indexed
    xcorr_peak = xc_valid[peak_sym0] / P.N_train
    peak_sym = peak_sym0 + 1  # MATLAB 1-indexed, matches n_start/etc formulas below

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
        if t_end_try > len(mf_bpsk):
            continue
        seg = _mslice(mf_bpsk, t0_try, t_end_try, P.sps)[:N_scan]
        eye_val = np.abs(np.vdot(pre_short, seg)) / N_scan
        if eye_val > best_eye:
            best_eye = eye_val
            best_t0 = t0_try

    # --- Stage 4: T/2 fractionally-spaced extraction ---
    # sps_eff is the TRUE samples/symbol as actually received: nominal
    # P.sps corrected by sample_ppm, the sample-clock offset between the
    # TX and RX boards' independent, free-running crystals. Left
    # uncorrected, this drift accumulates across the packet's ~1224
    # symbols and shows up as elevated BER even on an otherwise clean
    # channel -- confirmed as a real contributor on cross-board captures,
    # 2026-08-28. Everything downstream of this stage (CFO/rotation/DFE)
    # works purely on mf_ds_fse's discrete symbol index, so correcting the
    # sampling grid once here is sufficient.
    sps_eff = P.sps * (1.0 + float(sample_ppm) * 1e-6)
    sps_fse_eff = sps_eff / 2.0
    mf_t0 = best_t0
    t_end_base = mf_t0 + (P.N_syms_total - 1) * sps_eff
    if t_end_base > len(mf_bpsk):
        return dict(ok=False, reason="capture too short to contain full BPSK frame")
    n_extra_avail = int(np.floor((len(mf_bpsk) - t_end_base) / sps_eff))
    n_margin = min(P.DEC_DELAY_MAX, max(n_extra_avail, 0))
    decision_delay = K_2 // 4
    if decision_delay > n_margin:
        return dict(ok=False, reason=(
            f"decision_delay={decision_delay} exceeds available lookahead "
            f"margin ({n_margin} symbols)"))

    # Fractional-sample (linear-interpolation) extraction at the ppm-
    # corrected T/2 spacing -- mirrors bpsk_rx.py's downsample(), the same
    # technique the older block-based pipeline already uses for its own
    # --sample-ppm correction. At sample_ppm=0.0 every position lands
    # exactly on an integer sample, so this is numerically identical to
    # the plain _mslice(mf_bpsk, mf_t0, t_end, sps_fse) it replaces (see
    # correctness check in decode_packet's caller-side tests).
    n_fse = 2 * (P.N_syms_total + n_margin) - 1
    fse_positions = (mf_t0 - 1) + np.arange(n_fse, dtype=np.float64) * sps_fse_eff
    src_idx = np.arange(len(mf_bpsk), dtype=np.float64)
    mf_ds_fse = (np.interp(fse_positions, src_idx, mf_bpsk.real)
                 + 1j * np.interp(fse_positions, src_idx, mf_bpsk.imag))
    mf_ds = mf_ds_fse[::2]

    ss = max(1, round(0.1 * P.N_syms_total * 2))
    pwr = np.mean(np.abs(mf_ds_fse[ss - 1:]) ** 2)
    if pwr > 0:
        mf_ds_fse = mf_ds_fse / np.sqrt(pwr)
        mf_ds = mf_ds / np.sqrt(pwr)

    # --- Stage 5: iterative CFO (linear phase-ramp) estimation ---
    n_sym_vec = np.arange(len(mf_ds))
    n_fse_vec = np.arange(len(mf_ds_fse)) / 2.0
    CFO_total = 0.0
    direct_corr_pre = np.abs(np.vdot(train_syms, mf_ds[:P.N_train])) / P.N_train
    if xcorr_peak <= 0.5:
        for _ in range(3):
            CFO_est = _cfo_from_block_phasors(mf_ds[:P.N_train], train_syms)
            mf_ds = mf_ds * np.exp(-1j * 2 * np.pi * CFO_est / P.Rs * n_sym_vec)
            mf_ds_fse = mf_ds_fse * np.exp(-1j * 2 * np.pi * CFO_est / P.Rs * n_fse_vec)
            CFO_total += CFO_est
            if abs(CFO_est) < 0.1:
                break

    # Same correlation as direct_corr_pre, re-measured after the loop. The
    # pair is a self-check on Stage 5 itself: removing a real frequency
    # offset must make the training sequence correlate BETTER, so
    # direct_corr_post < direct_corr_pre means the CFO estimate was wrong
    # and this stage actively degraded the packet. Recomputed
    # unconditionally (not just when the loop ran) so the two are always
    # comparable -- when xcorr_peak > 0.5 the loop is skipped and the two
    # are identical by construction, which is itself the correct answer.
    direct_corr_post = np.abs(np.vdot(train_syms, mf_ds[:P.N_train])) / P.N_train

    # --- Stage 6: constellation rotation + sign resolve ---
    pre_win = mf_ds[:P.N_train] * train_syms
    xy = np.stack([pre_win.real, pre_win.imag], axis=1)
    cov = xy.T @ xy
    eigvals, eigvecs = np.linalg.eigh(cov)
    dom_vec = eigvecs[:, np.argmax(eigvals)]
    rot_angle = np.arctan2(dom_vec[1], dom_vec[0])
    mf_ds = mf_ds * np.exp(-1j * rot_angle)
    mf_ds_fse = mf_ds_fse * np.exp(-1j * rot_angle)

    agree = np.sum(np.sign(mf_ds[:P.N_train].real) == train_syms)
    if agree < P.N_train / 2:
        mf_ds = -mf_ds
        mf_ds_fse = -mf_ds_fse
        agree = P.N_train - agree
        rot_angle += np.pi

    # --- Stage 7: batch-LS DFE init over the training region ---
    # K_2 / K_fb / no_repass are resolved at the top of this function --
    # per-call overrides, defaulting to the module values.
    decided_syms = np.zeros(P.N_syms_total, dtype=np.complex128)
    decided_syms[:P.N_train] = train_syms

    n_start = max(int(np.ceil(K_2 / 2)), K_fb + decision_delay)
    n_end = P.N_train - 1
    n_rows = n_end - n_start + 1
    if n_rows <= 0:
        return dict(ok=False, reason="training region too short for chosen K_2/K_fb")

    # Vectorised build of the batch-LS design matrices. Each row is a
    # REVERSED sliding window: as k advances by 1, the feedforward window's
    # end advances by 2 (T/2 spacing) and the feedback window's by 1. The
    # original per-row loop ran n_rows (=992) times per packet -- 131,936
    # interpreter trips over the whole capture -- purely to copy data; no
    # per-row arithmetic was involved. Gathering with descending index
    # matrices does the reversal by construction and produces the same
    # bytes, so X_pre/Fb_pre/d_pre and everything downstream of them
    # (Z_pre, the solve, wc) are bit-identical.
    j  = np.arange(n_rows)
    nk = n_start + j
    m_ = nk - decision_delay + 1

    # Guard the gathers: fancy indexing wraps silently on negative indices
    # instead of raising, and Fb's first start lands exactly on 0 for the
    # default K_fb/decision_delay -- so this is tight, not decorative.
    assert 2 * nk[0] - K_2 + 1 >= 0, "K_2 too large for the feedforward gather"
    assert 2 * nk[-1] < len(mf_ds_fse), "mf_ds_fse too short for the feedforward gather"
    assert m_[0] - K_fb - 1 >= 0, "K_fb/decision_delay too large for the feedback gather"

    X_pre = mf_ds_fse[(2 * nk)[:, None] - np.arange(K_2)[None, :]]
    if K_fb > 0:
        Fb_pre = decided_syms[(m_ - 2)[:, None] - np.arange(K_fb)[None, :]]
    else:
        Fb_pre = np.zeros((n_rows, 0), dtype=np.complex128)
    d_pre = train_syms[m_ - 1].astype(np.complex128)

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
    ber_train = np.mean(np.sign(pred_train.real) != np.sign(d_pre.real))

    # --- Stage 8/9: joint DD-PLL + NLMS-DFE, with repass ---
    alpha_pll_pre, beta_pll_pre = 0.05, 0.005
    alpha_pll_data, beta_pll_data = 0.015, 0.0005
    gamma_soft = 2.0
    eff_gain_cap = P.gain_cap * 38 / (K_2 + K_fb)

    # ── Hoisted loop constants ────────────────────────────────────────────
    # Everything below is loop-invariant; profiling showed the per-symbol
    # loops spending 20% of total runtime inside np.linalg.norm's dispatch
    # chain and 6% inside _mslice, for arithmetic that is a handful of ops
    # on 68-element vectors.
    K_z      = K_2 + K_fb
    _wmax    = float(P.w_norm_max)
    _ts      = train_syms.tolist()      # Python floats: far cheaper to index
    # Inlined _mslice bounds. Both windows are reversed contiguous slices;
    # n_start >= ceil(K_2/2) and n_start >= K_fb + decision_delay guarantee
    # both stop indices stay >= 0 for every m the loops visit, so _mslice's
    # negative-stop branch is unreachable here. Asserted rather than assumed.
    assert (n_start + 1) - K_fb - 2 >= 0,         "K_fb/decision_delay too large to inline the feedback slice"
    assert 2 * (n_start + 1 + decision_delay) + 1 - K_2 - 1 >= 0,         "K_2 too large to inline the feedforward slice"

    _train_state = []

    def _run_training():
        """
        The 3 warm-up sweeps over the TRAINING region, computed ONCE.

        This result is bit-identical on every run_pass() call: nonlocal_wc
        restarts from wc_init, theta/freq_off restart at 0, and the only
        feedback the training loop reads is decided_syms[:N_train], which is
        train_syms and which the repass loop never writes (it only touches
        indices >= N_train). The original code recomputed all of it on each
        of the 1 + no_repass passes -- ~94% of every pass, and by far the
        largest single cost in the receiver.

        Returns (wc, theta, freq_off, eq_out) as of the end of training.
        """
        if _train_state:
            return _train_state[0]

        wc_l     = wc_init.copy()
        theta    = 0.0
        freq_off = 0.0
        eq_out   = np.zeros(P.N_syms_total, dtype=np.complex128)
        fb_src   = decided_syms          # training region == train_syms
        z_win    = np.empty(K_z, dtype=np.complex128)
        zf       = z_win[K_2:]

        for _warmup in range(3):
            for m in range(n_start + 1, P.N_train + 1):
                idx_end = (m + decision_delay) * 2 + 1
                z_win[:K_2] = mf_ds_fse[idx_end - 1: idx_end - K_2 - 1: -1]
                if K_fb > 0:
                    np.negative(fb_src[m - 2: m - K_fb - 2: -1], out=zf)

                y = complex(np.vdot(wc_l, z_win)) * complex(
                    math.cos(theta), -math.sin(theta))          # * exp(-1j*theta)
                if m <= P.N_syms_total:
                    eq_out[m - 1] = y

                d = _ts[m - 1]
                e_phi = (y * d).imag                            # d real -> conj(d) == d
                freq_off += beta_pll_pre * e_phi
                theta    += alpha_pll_pre * e_phi + freq_off

                err_eq = (d - y) * complex(
                    math.cos(theta), math.sin(theta))           # * exp(+1j*theta)

                raw_gain = eff_gain_cap / (np.vdot(z_win, z_win).real + 1e-3)
                wc_l += (raw_gain * err_eq.conjugate()) * z_win

                # np.linalg.norm(wc_l), open-coded: numpy computes exactly
                # sqrt(re.dot(re) + im.dot(im)) for a 1-D complex array, so
                # this is bit-identical, minus ~200us/call of dispatch.
                wn = math.sqrt(np.dot(wc_l.real, wc_l.real)
                               + np.dot(wc_l.imag, wc_l.imag))
                if wn > _wmax:
                    wc_l *= _wmax / wn

        _train_state.append((wc_l, theta, freq_off, eq_out))
        return _train_state[0]

    def run_pass(fb_source_for_data):
        """
        One equalizer pass. The training warm-up is shared via
        _run_training(); only the timing-dependent DATA loop runs per pass.
        Output is identical to the original monolithic version.
        """
        wc_t, theta, freq_off, eq_t = _run_training()
        wc_l          = wc_t.copy()
        eq_out        = eq_t.copy()
        local_decided = decided_syms.copy()
        z_win         = np.empty(K_z, dtype=np.complex128)
        zf            = z_win[K_2:]

        for m in range(P.N_train + 1, P.N_syms_total + 1):
            idx_end = (m + decision_delay) * 2 + 1
            z_win[:K_2] = mf_ds_fse[idx_end - 1: idx_end - K_2 - 1: -1]
            if K_fb > 0:
                np.negative(fb_source_for_data[m - 2: m - K_fb - 2: -1], out=zf)

            y = complex(np.vdot(wc_l, z_win)) * complex(
                math.cos(theta), -math.sin(theta))
            eq_out[m - 1] = y

            yr = y.real
            d_hard = math.copysign(1.0, yr) if yr != 0 else 1.0
            soft_val = math.tanh(gamma_soft * yr)
            if abs(yr) < 0.15:
                soft_val = 0.0
            local_decided[m - 1] = soft_val
            d = d_hard

            e_phi = (y * d).imag
            freq_off += beta_pll_data * e_phi
            theta    += alpha_pll_data * e_phi + freq_off

            err_eq = (d - y) * complex(math.cos(theta), math.sin(theta))

            raw_gain = eff_gain_cap / (np.vdot(z_win, z_win).real + 1e-3)
            wc_l += (raw_gain * err_eq.conjugate()) * z_win

            wn = math.sqrt(np.dot(wc_l.real, wc_l.real)
                           + np.dot(wc_l.imag, wc_l.imag))
            if wn > _wmax:
                wc_l *= _wmax / wn

        return eq_out, local_decided

    eq_out, decided_syms = run_pass(decided_syms)
    data_out_s8 = eq_out[P.N_train:]
    bits_hat_s8 = (data_out_s8.real > 0).astype(np.uint8)

    for _k in range(no_repass):
        decided_prev = decided_syms.copy()
        for idx2 in range(P.N_train, P.N_syms_total):
            val = decided_prev[idx2].real
            val = 0.0 if abs(val) < 0.15 else np.sign(val)
            decided_prev[idx2] = val
        eq_out, decided_syms = run_pass(decided_prev)

    data_out = eq_out[P.N_train:]
    bits_hat = (data_out.real > 0).astype(np.uint8)

    # No-equalizer baseline decision, for comparison: just slice the
    # matched-filter output after CFO correction + global rotation
    # (Stage 6), with no ISI cancellation at all. Useful to quantify what
    # the DFE is actually buying on a given channel.
    bits_naive = (mf_ds[P.N_train:P.N_train + P.N_data].real > 0).astype(np.uint8)

    # Decision-directed post-DFE SNR: distance from the equalized data
    # symbols to the nearest ideal +/-1, with no reference bits involved.
    # This is the metric the sweep scripts sort on, and it is deliberately
    # NOT the same as analyze_capture()'s pdsnr_db: that one measures EVM
    # against the KNOWN payload (F.data_syms), so it needs the reference
    # and is lab-only. This one is blind, so it is the candidate objective
    # for field use where the payload is unknown -- whether the two rank
    # configurations the same way is the open question the metrics log
    # exists to answer.
    #
    # Real rail only (eq_data = data_out.real), matching the MATLAB
    # Stage-12b definition: BPSK never carries information on the
    # imaginary rail, so its noise is not part of this figure either.
    # Scale-invariant, because sign() tracks whatever amplitude the
    # equalizer converged to.
    eq_data = data_out.real
    noise_eq = float(np.mean((eq_data - np.sign(eq_data)) ** 2))
    snr_eq_db = -10.0 * np.log10(max(noise_eq, 1e-12))  # floor avoids log(0)

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
        best_eye=best_eye,
        direct_corr_pre=direct_corr_pre,
        direct_corr_post=direct_corr_post,
        CFO_total=CFO_total,
        rot_angle=rot_angle,
        agree=int(agree),
        best_t0=best_t0,
        snr_eq_db=snr_eq_db,
        sample_ppm=float(sample_ppm),
        bits_hat_s8=bits_hat_s8,
    )


_RRC_CACHE = None


def _base_rrc():
    global _RRC_CACHE
    if _RRC_CACHE is None:
        import bpsk_params as _bp
        _RRC_CACHE = _bp.RRC
    return _RRC_CACHE
