"""
bpsk_rx.py
==========
BPSK â€“ RECEIVER  (baseband only, numpy-only, no scipy)
=======================================================
Processes a captured baseband waveform at Fs = 400 kSPS and recovers data bits.
No downconversion from a carrier â€” input is already baseband.

Input sources (in order of priority)
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  1. ``--in  rx_capture.npz``   : array saved by hardware logger
  2. ``--loopback tx_frame.npz``: use TX waveform directly (simulation mode)
  3. ``--record``               : capture from microphone via sounddevice

Receiver pipeline
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  A. RRC matched filter    (no mixing â€” input is baseband)
  B. Preamble sync         (pair-peak xcorr on the two-half preamble)
  C. Coarse CFO            (inter-half phase rotation)
  D. Symbol timing         (downsample at sps)
  E. Fine CFO              (per-block pilot phase-slope fit; quadratic correction)
  F. Per-block phase track (weighted mean channel phase, unwrapped + interpolated)
  G. CP-FDE MMSE           (per-block LS channel est. + MMSE equalisation)
  H. BPSK hard detection & BER computation

Usage
â”€â”€â”€â”€â”€
  python bpsk_rx.py --loopback tx_frame.npz --plot        # self-test
  python bpsk_rx.py --in rx_capture.npz --plot            # from captured file
  python bpsk_rx.py --record --duration 0.5 --plot        # live capture
  python bpsk_rx.py --dma --n-samples 109824 --plot       # receive via S2MM DMA (PYNQ)
"""

import argparse
import numpy as np
import bpsk_params as P

try:
    import sounddevice as sd
    _HAS_SD = True
except Exception:
    _HAS_SD = False

try:
    import matplotlib.pyplot as plt
    _HAS_PLT = True
except Exception:
    _HAS_PLT = False

try:
    import bpsk_dma as _dma
    _HAS_DMA = True
except ImportError:
    _HAS_DMA = False


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  NUMPY REPLACEMENTS FOR SCIPY
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def _fir_filter(h: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Causal FIR filter â€” replaces scipy.signal.lfilter(h, 1, x).
    Works for both real and complex x.
    Returns same length as x.
    """
    return np.convolve(x, h)[:len(x)]


def _fft_correlate(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """
    Full cross-correlation via FFT â€” replaces scipy.signal.correlate(a, b, mode='full').
    Output length = len(a) + len(b) - 1, identical indexing to scipy.
    """
    Na, Nb = len(a), len(b)
    N    = Na + Nb - 1
    Nfft = 1 << (N - 1).bit_length()          # next power-of-2 >= N
    C    = np.fft.ifft(np.fft.fft(a, Nfft) * np.conj(np.fft.fft(b, Nfft)))
    # Rearrange circular â†’ linear lags to match scipy 'full' indexing
    result = np.empty(N, dtype=C.dtype)
    if Nb > 1:
        result[:Nb - 1] = C[Nfft - (Nb - 1):]   # negative lags
    result[Nb - 1:]     = C[:Na]                  # zero + positive lags
    return result


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP A â€” RRC MATCHED FILTER  (baseband input, no mixing)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def analytic_signal(x: np.ndarray) -> np.ndarray:
    """Return the FFT Hilbert analytic signal for a real-valued input."""
    x = np.asarray(x)
    if np.iscomplexobj(x):
        return x.astype(complex)

    n = len(x)
    if n == 0:
        return x.astype(complex)

    X = np.fft.fft(x.astype(np.float64))
    h = np.zeros(n, dtype=np.float64)
    if n % 2 == 0:
        h[0] = 1.0
        h[n // 2] = 1.0
        h[1:n // 2] = 2.0
    else:
        h[0] = 1.0
        h[1:(n + 1) // 2] = 2.0
    return np.fft.ifft(X * h)


def matched_filter(rx_pb: np.ndarray, analytic_input: bool = False) -> np.ndarray:
    """
    Apply RRC matched filter to the baseband input.
    Input is real baseband at Fs; cast to complex for the rest of the pipeline.

    Returns
    -------
    rx_mf : complex baseband signal after matched filter
    """
    if analytic_input:
        rx_bb = analytic_signal(rx_pb)
    else:
        rx_bb = rx_pb.astype(complex)
    return _fir_filter(P.RRC, rx_bb)


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP B â€” PREAMBLE SYNCHRONISATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def _make_half_ref() -> np.ndarray:
    """RRC-shaped half-preamble reference (48 symbols, identical to TX)."""
    half_up = np.zeros(P.Nhalf * P.sps, dtype=np.float64)
    half_up[::P.sps] = P.HALF_PREAMBLE
    return _fir_filter(P.RRC, half_up)


def sync(rx_mf: np.ndarray) -> tuple:
    """
    Pair-peak cross-correlation with the known RRC-shaped HALF-preamble.

    Returns
    -------
    startSamp   : optimal first-sample index for symbol-rate downsampling
    xcorr_power : full sliding |xcorr| array (for diagnostics)
    """
    half_sh  = _make_half_ref()
    halfSamp = P.Nhalf * P.sps
    Lsh      = len(half_sh)

    xc = np.abs(_fft_correlate(rx_mf, half_sh))

    threshold = 0.5 * xc.max()
    cands     = np.where(xc > threshold)[0]

    max_idx  = int(np.argmax(xc))
    best_sum = -1.0
    for c in cands:
        c2 = c + halfSamp
        if c2 < len(xc):
            s = xc[c] + xc[c2]
            if s > best_sum:
                best_sum = s
                max_idx  = c2

    pre_payload = max_idx - (Lsh - 1) - halfSamp + P.RRC_DELAY
    startSamp   = max(0, pre_payload)

    return startSamp, xc


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP C â€” COARSE CFO ESTIMATION & CORRECTION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def coarse_cfo(rx_mf: np.ndarray, startSamp: int) -> tuple:
    """
    Estimate coarse CFO from the phase rotation between the two preamble halves.

    Returns
    -------
    cfo_hz       : coarse CFO estimate (Hz)
    rx_corrected : CFO-corrected version of the full rx_mf signal
    """
    startSamp = int(round(startSamp))
    halfSamp = P.Nhalf * P.sps
    T_half   = halfSamp / P.Fs

    end_needed = startSamp + 2 * halfSamp
    if end_needed > len(rx_mf):
        rx_mf = np.concatenate([rx_mf,
                                 np.zeros(end_needed - len(rx_mf), dtype=complex)])

    half1  = rx_mf[startSamp           : startSamp + halfSamp]
    half2  = rx_mf[startSamp + halfSamp: startSamp + 2 * halfSamp]
    ph     = np.angle(np.sum(np.conj(half1) * half2))
    cfo_hz = ph / (2 * np.pi * T_half)

    t_full       = np.arange(len(rx_mf)) / P.Fs
    rx_corrected = rx_mf * np.exp(-1j * 2 * np.pi * cfo_hz * t_full)

    return cfo_hz, rx_corrected


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP D â€” SYMBOL TIMING / DOWNSAMPLE
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def downsample(rx_corr: np.ndarray, startSamp: float,
               sps_eff: float = None) -> np.ndarray:
    """
    Downsample at symbol rate starting at startSamp.

    startSamp may be fractional. Fractional timing is handled with linear
    interpolation, which lets the external-loopback analyzer search sub-sample
    timing phases instead of being limited to integer ADC samples.

    Returns
    -------
    rx_sym : (FRAME_SYMS,) complex symbol-rate array (zero-padded if short)
    """
    if sps_eff is None:
        sps_eff = P.sps
    positions = float(startSamp) + np.arange(P.FRAME_SYMS) * float(sps_eff)
    src = np.arange(len(rx_corr), dtype=np.float64)

    real = np.interp(positions, src, np.real(rx_corr), left=0.0, right=0.0)
    imag = np.interp(positions, src, np.imag(rx_corr), left=0.0, right=0.0)
    return real + 1j * imag


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP E â€” FINE CFO ESTIMATION & CORRECTION (quadratic / ramp-aware)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def fine_cfo(rx_sym: np.ndarray, startSamp: int,
             sps_eff: float = None) -> tuple:
    """
    Pilot-assisted residual CFO estimation with quadratic phase correction.

    Returns
    -------
    fine_hz     : residual CFO at t=0  (Hz)
    rx_fine     : quadratic-phase-corrected symbol-rate signal
    pilotMidT   : absolute time of each pilot block midpoint (s)
    withinCFO   : per-block residual CFO estimates (Hz)
    p_fit       : polyfit coefficients [rate(Hz/s), offset(Hz)]
    """
    if sps_eff is None:
        sps_eff = P.sps
    rs_eff = P.Fs / float(sps_eff)
    withinCFO = np.zeros(P.Nblocks)
    pilotMidT = np.zeros(P.Nblocks)

    for b in range(P.Nblocks):
        ps       = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        rx_pilot = rx_sym[ps : ps + P.Npilot]

        r   = rx_pilot * P.PILOT_SYM
        ph  = np.unwrap(np.angle(r))
        c   = np.polyfit(np.arange(P.Npilot), ph, 1)
        withinCFO[b] = c[0] / (2 * np.pi) * rs_eff

        pilotMidT[b] = (startSamp + (ps + P.Npilot / 2) * float(sps_eff)) / P.Fs

    p_fit   = np.polyfit(pilotMidT, withinCFO, 1)
    fine_hz = p_fit[1]

    tSym_abs   = (startSamp + np.arange(P.FRAME_SYMS) * float(sps_eff)) / P.Fs
    fine_phase = 2 * np.pi * (fine_hz * tSym_abs
                               + 0.5 * p_fit[0] * tSym_abs**2)
    rx_fine    = rx_sym * np.exp(-1j * fine_phase)

    return fine_hz, rx_fine, pilotMidT, withinCFO, p_fit


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP F â€” PER-BLOCK CHANNEL PHASE TRACKING
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def phase_track(rx_fine: np.ndarray, withinCFO: np.ndarray,
                pilotMidT: np.ndarray, p_fit: np.ndarray,
                pilot_reg: float = 0.0) -> tuple:
    """
    Estimate and remove residual constant channel phase per block.

    Returns
    -------
    rx_track   : phase-corrected symbol-rate signal  (input to FDE)
    H_eq       : (Npilot, Nblocks) refined freq-domain channel estimates
    blockPhase : (Nblocks,) unwrapped residual channel phases (rad)
    """
    TX_pilot_f = np.fft.fft(P.PILOT_SYM, P.Npilot)
    TX_pilot_pow = np.abs(TX_pilot_f) ** 2
    pilot_reg_abs = float(pilot_reg) * float(np.mean(TX_pilot_pow))
    H_raw      = np.zeros((P.Npilot, P.Nblocks), dtype=complex)
    blockPhase = np.zeros(P.Nblocks)

    for b in range(P.Nblocks):
        ps       = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        rx_pilot = rx_fine[ps : ps + P.Npilot]

        residCFO_b  = withinCFO[b] - np.polyval(p_fit, pilotMidT[b])
        nVec        = np.arange(P.Npilot)
        pilot_corr  = rx_pilot * np.exp(-1j * 2*np.pi * residCFO_b / P.Rs * nVec)

        H_raw[:, b]   = (
            np.fft.fft(pilot_corr, P.Npilot)
            * np.conj(TX_pilot_f)
            / (TX_pilot_pow + pilot_reg_abs + 1e-30)
        )
        w             = np.abs(H_raw[:, b])
        blockPhase[b] = np.angle(np.sum(w * H_raw[:, b]) / (np.sum(w) + 1e-30))

    blockPhase = np.unwrap(blockPhase)

    extrap = (blockPhase[-1] + (blockPhase[-1] - blockPhase[-2])
              if P.Nblocks > 1 else blockPhase[-1])
    bpExt = np.append(blockPhase, extrap)

    rx_track = rx_fine.copy()
    H_eq     = np.zeros((P.Npilot, P.Nblocks), dtype=complex)

    for b in range(P.Nblocks):
        ps = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        ds = ps + P.Npilot + P.CP_sym

        ph_pilot = bpExt[b]
        # Use the current block's pilot phase for the following data section.
        # Interpolating toward the next block's pilot lets a weak/noisy future
        # pilot corrupt the current block and creates block-local failures.
        ph_data  = bpExt[b]

        rx_track[ps : ps + P.Npilot] = \
            rx_fine[ps : ps + P.Npilot] * np.exp(-1j * ph_pilot)

        ph_ramp = np.linspace(ph_pilot, ph_data, P.Ndata_tx)
        rx_track[ds : ds + P.Ndata_tx] = \
            rx_fine[ds : ds + P.Ndata_tx] * np.exp(-1j * ph_ramp)

        residCFO_b  = withinCFO[b] - np.polyval(p_fit, pilotMidT[b])
        nVec        = np.arange(P.Npilot)
        pilot_corr2 = rx_track[ps : ps + P.Npilot] * \
                      np.exp(-1j * 2*np.pi * residCFO_b / P.Rs * nVec)
        H_eq[:, b]  = (
            np.fft.fft(pilot_corr2, P.Npilot)
            * np.conj(TX_pilot_f)
            / (TX_pilot_pow + pilot_reg_abs + 1e-30)
        )

    return rx_track, H_eq, blockPhase


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP G â€” CP-FDE MMSE EQUALISATION
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def fde_equalize(rx_track: np.ndarray, H_eq: np.ndarray,
                 snr_db: float = 20.0,
                 guard_phase_correct: bool = False) -> tuple:
    """
    Per-block MMSE equalisation using the refined channel estimates H_eq.

    Returns
    -------
    rx_data_all : (Nblocks Ã— Ndata,) complex equalised data symbols
    h_est_last  : freq-domain channel estimate from the last block (diagnostics)
    """
    noise_var   = 10 ** (-snr_db / 10)
    rx_data_all = []
    h_est_last  = None

    xi = np.arange(P.Npilot)
    xq = np.linspace(0, P.Npilot - 1, P.Ndata_tx)

    for b in range(P.Nblocks):
        H_data = (np.interp(xq, xi, np.real(H_eq[:, b]))
                  + 1j * np.interp(xq, xi, np.imag(H_eq[:, b])))

        ds      = P.Npreamble + b * P.dataBlockLen + P.CP_sym + P.Npilot + P.CP_sym
        rx_data = rx_track[ds : ds + P.Ndata_tx]

        D_rx   = np.fft.fft(rx_data, P.Ndata_tx)
        W      = np.conj(H_data) / (np.abs(H_data)**2 + noise_var)
        eq_sym = np.fft.ifft(D_rx * W, P.Ndata_tx)
        if guard_phase_correct and P.Ndata_guard > 0 and abs(eq_sym[0]) > 1e-12:
            # The first data-section symbol is a known -1 guard. Use it to
            # remove residual per-block BPSK phase/sign ambiguity before
            # discarding the guard and making hard decisions.
            eq_sym = eq_sym * np.exp(1j * (np.pi - np.angle(eq_sym[0])))

        rx_data_all.append(eq_sym[P.Ndata_guard:])
        h_est_last = H_eq[:, b]

    return np.concatenate(rx_data_all), h_est_last


def direct_extract(rx_track: np.ndarray,
                   guard_phase_correct: bool = False) -> tuple:
    """
    Extract data symbols directly after matched filtering and phase tracking.

    This bypasses CP-FDE. It is useful for the real external-loopback path where
    the channel is mostly flat and the FFT equalizer can over-correct blocks.
    """
    rx_data_all = []

    for b in range(P.Nblocks):
        ds = P.Npreamble + b * P.dataBlockLen + P.CP_sym + P.Npilot + P.CP_sym
        rx_data = rx_track[ds : ds + P.Ndata_tx]
        if guard_phase_correct and P.Ndata_guard > 0 and abs(rx_data[0]) > 1e-12:
            rx_data = rx_data * np.exp(1j * (np.pi - np.angle(rx_data[0])))
        rx_data_all.append(rx_data[P.Ndata_guard:])

    return np.concatenate(rx_data_all), None


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  STEP H â€” DETECTION & BER
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def detect(rx_data: np.ndarray, data_bits_ref=None):
    """
    Hard-decision BPSK detection (threshold = 0 on real part).

    Returns
    -------
    rx_bits : detected bits {0, 1}
    ber     : BER  (None if no reference)
    n_err   : error count  (None if no reference)
    """
    rx_bits = (np.real(rx_data) > 0).astype(np.uint8)

    if data_bits_ref is not None:
        n     = min(len(rx_bits), len(data_bits_ref))
        n_err = int(np.sum(rx_bits[:n] != data_bits_ref[:n]))
        ber   = n_err / n
    else:
        n_err = None
        ber   = None

    return rx_bits, ber, n_err


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  FULL RECEIVER
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def _data_start_samp(sync_startSamp: int, start_adjust_samp: float) -> float:
    """Timing-adjusted downsample start, matching the original receive()."""
    data_startSamp = float(sync_startSamp)
    if start_adjust_samp:
        data_startSamp = max(0.0, data_startSamp + float(start_adjust_samp))
    return data_startSamp


def rx_frontend(rx_pb: np.ndarray,
                sync_start_override: int = None,
                analytic_input: bool = False,
                sample_ppm: float = 0.0,
                compute_xcorr: bool = True) -> dict:
    """
    Timing-independent receiver front-end: steps A (matched filter),
    B (preamble sync) and C (coarse CFO).

    These stages do NOT depend on ``start_adjust_samp``, so a caller that
    sweeps timing hypotheses over one captured frame can run this once and
    feed the result to :func:`rx_backend` for every candidate. That is the
    whole point of the split: the original ``receive()`` recomputed the
    expensive matched-filter convolution and sync FFT for every timing
    candidate even though their output is identical across candidates.

    ``compute_xcorr`` controls whether the sync cross-correlation is run when
    ``sync_start_override`` is given. The correlation is only needed for the
    diagnostic ``xcorr_pow`` array (preamble-confidence / local-peak search);
    when the sync sample is already known and no diagnostics are needed, skip
    it. With no override the correlation is always required to find the sync.
    """
    # A. RRC matched filter (no mixing â€” already baseband)
    rx_mf = matched_filter(rx_pb, analytic_input=analytic_input)

    # B. Synchronise (pair-peak on half-preamble)
    if sync_start_override is None:
        startSamp, xcorr_pow = sync(rx_mf)
    else:
        startSamp = max(0, int(sync_start_override))
        xcorr_pow = sync(rx_mf)[1] if compute_xcorr else None
    sync_startSamp = startSamp

    # C. Coarse CFO (inter-half phase rotation)
    # Estimate CFO from the actual preamble location. The start adjustment is
    # a data-symbol timing correction and must not move the preamble halves.
    coarse_hz, rx_coarse = coarse_cfo(rx_mf, sync_startSamp)

    sps_eff = P.sps * (1.0 + float(sample_ppm) * 1e-6)

    return dict(
        rx_mf          = rx_mf,
        xcorr_pow      = xcorr_pow,
        sync_startSamp = sync_startSamp,
        startSamp      = startSamp,
        coarse_hz      = coarse_hz,
        rx_coarse      = rx_coarse,
        sps_eff        = sps_eff,
        analytic_input = analytic_input,
        sample_ppm     = sample_ppm,
    )


def rx_backend(front: dict, data_bits_ref=None,
               snr_db: float = 20.0, verbose: bool = False,
               start_adjust_samp: float = 0,
               equalizer: str = "fde",
               guard_phase_correct: bool = False,
               pilot_reg: float = 0.0) -> dict:
    """
    Timing-dependent receiver back-end: steps D (downsample) through
    H (detection), reusing a front-end computed by :func:`rx_frontend`.

    The returned dict is identical in shape and values to what the original
    monolithic ``receive()`` produced for the same inputs, so it is a drop-in
    replacement for callers that only vary ``start_adjust_samp``.
    """
    rx_coarse      = front["rx_coarse"]
    sps_eff        = front["sps_eff"]
    sync_startSamp = front["sync_startSamp"]
    coarse_hz      = front["coarse_hz"]

    data_startSamp = _data_start_samp(sync_startSamp, start_adjust_samp)

    # D. Symbol-rate downsample
    rx_sym = downsample(rx_coarse, data_startSamp, sps_eff=sps_eff)

    # E. Fine CFO (quadratic correction)
    fine_hz, rx_fine, pilotMidT, withinCFO, p_fit = fine_cfo(
        rx_sym, data_startSamp,
        sps_eff=sps_eff)

    # F. Per-block phase tracking
    rx_track, H_eq, blockPhase = phase_track(
        rx_fine, withinCFO, pilotMidT, p_fit,
        pilot_reg=pilot_reg)

    # G. Data extraction / equalisation
    if equalizer == "fde":
        rx_data, h_est = fde_equalize(
            rx_track, H_eq,
            snr_db=snr_db,
            guard_phase_correct=guard_phase_correct)
    elif equalizer == "direct":
        rx_data, h_est = direct_extract(
            rx_track,
            guard_phase_correct=guard_phase_correct)
    else:
        raise ValueError(f"unknown equalizer: {equalizer}")

    # H. Detection & BER
    rx_bits, ber, n_err = detect(rx_data, data_bits_ref)

    if verbose:
        print("\n=== RX INFO ===")
        print(f"  startSamp (sample)   : {data_startSamp:.3f}")
        if start_adjust_samp:
            print(f"  sync startSamp       : {sync_startSamp}  "
                  f"(adjust {float(start_adjust_samp):+.3f} samp)")
        print(f"  Coarse CFO est.      : {coarse_hz:.2f} Hz")
        print(f"  Fine CFO offset      : {fine_hz:.4f} Hz")
        print(f"  Fine CFO rate        : {p_fit[0]:.2f} Hz/s")
        print(f"  Within-block CFO     : " + "  ".join(f"{v:.2f}" for v in withinCFO) + " Hz")
        print(f"  Equalizer            : {equalizer}")
        print(f"  Guard phase correct  : {'on' if guard_phase_correct else 'off'}")
        print(f"  Pilot regularization : {pilot_reg:.4g}")
        print(f"  Analytic input       : {'on' if front['analytic_input'] else 'off'}")
        print(f"  Sample ppm           : {front['sample_ppm']:+.3f}")
        if ber is not None:
            print(f"  Bit errors           : {n_err}")
            print(f"  BER                  : {ber:.4e}")
        else:
            print("  (No reference bits â€” BER not computed)")

    return dict(
        rx_mf       = front["rx_mf"],
        sync_startSamp = sync_startSamp,
        start_adjust_samp = start_adjust_samp,
        startSamp   = front["startSamp"],
        xcorr_pow   = front["xcorr_pow"],
        coarse_hz   = coarse_hz,
        rx_coarse   = rx_coarse,
        rx_sym      = rx_sym,
        fine_hz     = fine_hz,
        pilotMidT   = pilotMidT,
        withinCFO   = withinCFO,
        p_fit       = p_fit,
        rx_fine     = rx_fine,
        rx_track    = rx_track,
        H_eq        = H_eq,
        blockPhase  = blockPhase,
        rx_data     = rx_data,
        h_est       = h_est,
        equalizer   = equalizer,
        guard_phase_correct = guard_phase_correct,
        pilot_reg   = pilot_reg,
        analytic_input = front["analytic_input"],
        sample_ppm  = front["sample_ppm"],
        rx_bits     = rx_bits,
        ber         = ber,
        n_err       = n_err,
    )


def rx_backend_batch(front: dict, adjusts,
                     snr_db: float = 20.0,
                     equalizer: str = "fde",
                     guard_phase_correct: bool = False,
                     pilot_reg: float = 0.0) -> dict:
    """
    Vectorized back-end: evaluate MANY timing candidates for one frame at once.

    ``adjusts`` is an iterable of ``start_adjust_samp`` values. Every stage
    D->H is computed across all candidates with a leading batch axis, so the
    per-candidate Python/numpy call overhead in the timing search collapses
    into a handful of array ops.

    Returns
    -------
    dict with:
      rx_bits  : (Ncand, Nblocks*Ndata) uint8 hard decisions
      rx_track : (Ncand, FRAME_SYMS) complex phase-tracked symbols
                 (consumed by the caller's CP-timing score)
      rx_data  : (Ncand, Nblocks*Ndata) complex pre-hard-decision equalised
                 data symbols (the raw ingredient for EVM/SNR measurement)
      data_startSamp : (Ncand,) float downsample start actually used

    The result for candidate ``i`` is intended to be bit-for-bit identical to
    ``rx_backend(front, start_adjust_samp=adjusts[i], ...)`` for its rx_bits
    and rx_track. Every operation below mirrors the scalar back-end; only the
    leading candidate axis is added. (Validated by diffing the per-frame CSV
    report against the scalar version.)
    """
    rx_coarse = front["rx_coarse"]
    sps_eff   = float(front["sps_eff"])
    sync_startSamp = front["sync_startSamp"]

    adjusts = [float(a) for a in adjusts]
    Nc = len(adjusts)
    FS = P.FRAME_SYMS
    s = np.array([_data_start_samp(sync_startSamp, a) for a in adjusts],
                 dtype=np.float64)                              # (Nc,)

    # D. Symbol-rate downsample (fractional -> linear interp), batched.
    src = np.arange(len(rx_coarse), dtype=np.float64)
    idx = np.arange(FS)
    positions = s[:, None] + idx[None, :] * sps_eff            # (Nc, FS)
    flat = positions.ravel()
    real = np.interp(flat, src, np.real(rx_coarse), left=0.0, right=0.0)
    imag = np.interp(flat, src, np.imag(rx_coarse), left=0.0, right=0.0)
    rx_sym = (real + 1j * imag).reshape(Nc, FS)

    # E. Fine CFO (quadratic correction), batched.
    rs_eff = P.Fs / sps_eff
    withinCFO = np.zeros((Nc, P.Nblocks))
    pilotMidT = np.zeros((Nc, P.Nblocks))
    nP = np.arange(P.Npilot)
    for b in range(P.Nblocks):
        ps = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        rx_pilot = rx_sym[:, ps:ps + P.Npilot]                 # (Nc, Npilot)
        r  = rx_pilot * P.PILOT_SYM
        ph = np.unwrap(np.angle(r), axis=1)
        # polyfit deg-1 over the shared abscissa nP for every candidate at once
        # (np.polyfit accepts a 2-D y: one column per candidate).
        coeffs = np.polyfit(nP, ph.T, 1)                       # (2, Nc)
        withinCFO[:, b] = coeffs[0] / (2 * np.pi) * rs_eff
        pilotMidT[:, b] = (s + (ps + P.Npilot / 2) * sps_eff) / P.Fs

    # Per-candidate linear fit of within-block CFO vs pilot time. The abscissa
    # differs per candidate, so this small (Nblocks-point) fit is looped.
    p_fit = np.empty((Nc, 2))
    for i in range(Nc):
        p_fit[i] = np.polyfit(pilotMidT[i], withinCFO[i], 1)
    fine_hz = p_fit[:, 1]

    tSym_abs = (s[:, None] + idx[None, :] * sps_eff) / P.Fs    # (Nc, FS)
    fine_phase = 2 * np.pi * (fine_hz[:, None] * tSym_abs
                              + 0.5 * p_fit[:, 0][:, None] * tSym_abs ** 2)
    rx_fine = rx_sym * np.exp(-1j * fine_phase)

    # F. Per-block phase tracking, batched.
    TX_pilot_f   = np.fft.fft(P.PILOT_SYM, P.Npilot)
    TX_pilot_pow = np.abs(TX_pilot_f) ** 2
    pilot_reg_abs = float(pilot_reg) * float(np.mean(TX_pilot_pow))
    blockPhase = np.zeros((Nc, P.Nblocks))
    nVec = np.arange(P.Npilot)
    # polyval(p_fit, x) for a deg-1 fit == p_fit[:,0]*x + p_fit[:,1]
    resid = withinCFO - (p_fit[:, 0:1] * pilotMidT + p_fit[:, 1:2])   # (Nc, Nblocks)
    for b in range(P.Nblocks):
        ps = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        rx_pilot = rx_fine[:, ps:ps + P.Npilot]
        rot = np.exp(-1j * 2 * np.pi * (resid[:, b:b + 1] / P.Rs) * nVec[None, :])
        pilot_corr = rx_pilot * rot
        H_raw = (np.fft.fft(pilot_corr, P.Npilot, axis=1)
                 * np.conj(TX_pilot_f)
                 / (TX_pilot_pow + pilot_reg_abs + 1e-30))
        w = np.abs(H_raw)
        blockPhase[:, b] = np.angle(
            np.sum(w * H_raw, axis=1) / (np.sum(w, axis=1) + 1e-30))
    blockPhase = np.unwrap(blockPhase, axis=1)

    if P.Nblocks > 1:
        extrap = blockPhase[:, -1] + (blockPhase[:, -1] - blockPhase[:, -2])
    else:
        extrap = blockPhase[:, -1]
    bpExt = np.concatenate([blockPhase, extrap[:, None]], axis=1)

    rx_track = rx_fine.copy()
    H_eq = np.zeros((Nc, P.Npilot, P.Nblocks), dtype=complex)
    for b in range(P.Nblocks):
        ps = P.Npreamble + b * P.dataBlockLen + P.CP_sym
        ds = ps + P.Npilot + P.CP_sym
        ph_pilot = bpExt[:, b]
        # ph_data == ph_pilot (current-block phase held across the data
        # section, matching the scalar back-end), so the ramp is constant.
        ph_ramp = np.linspace(ph_pilot, ph_pilot, P.Ndata_tx, axis=1)
        rx_track[:, ps:ps + P.Npilot] = (
            rx_fine[:, ps:ps + P.Npilot] * np.exp(-1j * ph_pilot)[:, None])
        rx_track[:, ds:ds + P.Ndata_tx] = (
            rx_fine[:, ds:ds + P.Ndata_tx] * np.exp(-1j * ph_ramp))

        rot2 = np.exp(-1j * 2 * np.pi * (resid[:, b:b + 1] / P.Rs) * nVec[None, :])
        pilot_corr2 = rx_track[:, ps:ps + P.Npilot] * rot2
        H_eq[:, :, b] = (np.fft.fft(pilot_corr2, P.Npilot, axis=1)
                         * np.conj(TX_pilot_f)
                         / (TX_pilot_pow + pilot_reg_abs + 1e-30))

    # G. Data extraction / equalisation, batched.
    if equalizer == "direct":
        blocks = []
        for b in range(P.Nblocks):
            ds = P.Npreamble + b * P.dataBlockLen + P.CP_sym + P.Npilot + P.CP_sym
            rx_data = rx_track[:, ds:ds + P.Ndata_tx]
            if guard_phase_correct and P.Ndata_guard > 0:
                first = rx_data[:, 0]
                mask = np.abs(first) > 1e-12
                factor = np.where(
                    mask, np.exp(1j * (np.pi - np.angle(first))), 1.0 + 0j)
                rx_data = rx_data * factor[:, None]
            blocks.append(rx_data[:, P.Ndata_guard:])
        rx_data_all = np.concatenate(blocks, axis=1)
    elif equalizer == "fde":
        noise_var = 10 ** (-snr_db / 10)
        xi = np.arange(P.Npilot)
        xq = np.linspace(0, P.Npilot - 1, P.Ndata_tx)
        # Fixed-grid linear interpolation weights (identical to np.interp for
        # this xi/xq): clamp the base index so the top query hits the last bin.
        k = np.clip(np.floor(xq).astype(np.intp), 0, P.Npilot - 2)
        frac = xq - k                                          # (Ndata_tx,)
        blocks = []
        for b in range(P.Nblocks):
            Hb = H_eq[:, :, b]                                 # (Nc, Npilot)
            H_data = Hb[:, k] + (Hb[:, k + 1] - Hb[:, k]) * frac[None, :]
            ds = P.Npreamble + b * P.dataBlockLen + P.CP_sym + P.Npilot + P.CP_sym
            rx_data = rx_track[:, ds:ds + P.Ndata_tx]
            D_rx = np.fft.fft(rx_data, P.Ndata_tx, axis=1)
            W = np.conj(H_data) / (np.abs(H_data) ** 2 + noise_var)
            eq_sym = np.fft.ifft(D_rx * W, P.Ndata_tx, axis=1)
            if guard_phase_correct and P.Ndata_guard > 0:
                first = eq_sym[:, 0]
                mask = np.abs(first) > 1e-12
                factor = np.where(
                    mask, np.exp(1j * (np.pi - np.angle(first))), 1.0 + 0j)
                eq_sym = eq_sym * factor[:, None]
            blocks.append(eq_sym[:, P.Ndata_guard:])
        rx_data_all = np.concatenate(blocks, axis=1)
    else:
        raise ValueError(f"unknown equalizer: {equalizer}")

    # H. Hard detection.
    rx_bits = (np.real(rx_data_all) > 0).astype(np.uint8)

    return dict(
        rx_bits        = rx_bits,
        rx_track       = rx_track,
        rx_data        = rx_data_all,
        data_startSamp = s,
    )


def receive(rx_pb: np.ndarray, data_bits_ref=None,
            snr_db: float = 20.0, verbose: bool = True,
            start_adjust_samp: float = 0,
            sync_start_override: int = None,
            equalizer: str = "fde",
            guard_phase_correct: bool = False,
            pilot_reg: float = 0.0,
            analytic_input: bool = False,
            sample_ppm: float = 0.0) -> dict:
    """
    Run the complete RX chain A â†’ H and return a results dict.

    This is now a thin wrapper over :func:`rx_frontend` + :func:`rx_backend`;
    its inputs, outputs and printed diagnostics are unchanged. Multi-candidate
    timing searches should call the two helpers directly so the front-end runs
    once per frame instead of once per candidate.

    Parameters
    ----------
    rx_pb         : passband waveform at Fs (real ADC samples or complex I/Q)
    data_bits_ref : (optional) transmitted bits {0,1} for BER measurement
    snr_db        : assumed SNR for MMSE regularisation
    verbose       : print RX info (disabled by default for multi-frame use)
    start_adjust_samp
                  : signed sample offset applied after sync
    sync_start_override
                  : optional known sync sample. Used by continuous-capture
                    analysis after it has already locked the local preamble.
    """
    # compute_xcorr=True preserves the original behaviour of always returning
    # a populated xcorr_pow, even when a sync override is supplied.
    front = rx_frontend(
        rx_pb,
        sync_start_override=sync_start_override,
        analytic_input=analytic_input,
        sample_ppm=sample_ppm,
        compute_xcorr=True,
    )
    return rx_backend(
        front,
        data_bits_ref=data_bits_ref,
        snr_db=snr_db,
        verbose=verbose,
        start_adjust_samp=start_adjust_samp,
        equalizer=equalizer,
        guard_phase_correct=guard_phase_correct,
        pilot_reg=pilot_reg,
    )


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  PLOTS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def plot_rx(res: dict):
    if not _HAS_PLT:
        print("  [WARN] matplotlib not installed â€” cannot plot.")
        return

    ber_str = f"{res['ber']:.2e}" if res['ber'] is not None else "N/A"
    fig, axes = plt.subplots(3, 2, figsize=(13, 11))
    fig.suptitle(
        f"BPSK RX â€” 10 ms delay spread | Fc={P.Fc/1e3:.0f} kHz  "
        f"Fs={P.Fs/1e3:.0f} kHz  sps={P.sps}\n"
        f"coarseCFO={res['coarse_hz']:.1f} Hz  "
        f"fineCFO offset={res['fine_hz']:.3f} Hz  "
        f"rate={res['p_fit'][0]:.1f} Hz/s  BER={ber_str}",
        fontsize=10,
    )

    # 1. Sync cross-correlation
    ax = axes[0, 0]
    xc = res["xcorr_pow"]
    n_show = min(len(xc), len(res["rx_mf"]) + 5000)
    ax.plot(xc[:n_show], linewidth=0.5)
    ax.set_title("Sync: Half-Preamble Sliding Cross-Correlation")
    ax.set_xlabel("Sample"); ax.set_ylabel("|Correlation|")
    ax.grid(True)

    # 2. Phase before / after coarse CFO
    ax  = axes[0, 1]
    ss  = int(round(res["startSamp"]))
    n   = min(800, len(res["rx_mf"]) - ss)
    ax.plot(np.unwrap(np.angle(res["rx_mf"][ss:ss+n])),     'r', label='Before', linewidth=0.7)
    ax.plot(np.unwrap(np.angle(res["rx_coarse"][ss:ss+n])), 'b', label='After',  linewidth=0.7)
    ax.set_title(f"Phase: Before/After Coarse CFO ({res['coarse_hz']:.1f} Hz)")
    ax.set_xlabel("Sample"); ax.set_ylabel("Phase (rad)")
    ax.legend(); ax.grid(True)

    # 3. Fine CFO: within-block estimates vs linear fit
    ax = axes[1, 0]
    ax.plot(res["pilotMidT"]*1e3, res["withinCFO"],  'bo-', label='Per-block est.', markersize=6)
    ax.plot(res["pilotMidT"]*1e3,
            np.polyval(res["p_fit"], res["pilotMidT"]), 'r--', label='Linear fit', linewidth=1.5)
    ax.set_title(f"Fine CFO per Block  (rate={res['p_fit'][0]:.1f} Hz/s)")
    ax.set_xlabel("Pilot midpoint (ms)"); ax.set_ylabel("Residual CFO (Hz)")
    ax.legend(); ax.grid(True)

    # 4. Channel estimate magnitude (last block, Npilot bins)
    ax = axes[1, 1]
    f_ax = np.arange(P.Npilot) * P.Rs / P.Npilot / 1e3
    ax.plot(f_ax, 20*np.log10(np.abs(res["h_est"]) + 1e-30), linewidth=0.7)
    ax.set_title("FDE: |HÌƒ_est| â€” Last Block (Npilot freq bins)")
    ax.set_xlabel("Frequency (kHz)"); ax.set_ylabel("Magnitude (dB)")
    ax.grid(True)

    # 5. Constellation before FDE (last block)
    ax      = axes[2, 0]
    ds_last = (P.Npreamble + (P.Nblocks-1)*P.dataBlockLen
               + P.CP_sym + P.Npilot + P.CP_sym)
    raw_last = res["rx_fine"][ds_last : ds_last + P.Ndata_tx]
    ax.plot(np.real(raw_last), np.imag(raw_last), 'b.', markersize=3)
    ax.set_title("Constellation: Before FDE (last block)")
    ax.set_xlabel("I"); ax.set_ylabel("Q")
    ax.grid(True); ax.axis("equal")

    # 6. Constellation after FDE (last block)
    ax = axes[2, 1]
    eq_last = res["rx_data"][(P.Nblocks-1)*P.Ndata : P.Nblocks*P.Ndata]
    ax.plot(np.real(eq_last), np.imag(eq_last), 'g.', markersize=3)
    ax.set_title("Constellation: After FDE (last block)")
    ax.set_xlabel("I"); ax.set_ylabel("Q")
    ax.grid(True); ax.axis("equal")

    plt.tight_layout()
    plt.show()


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  DMA RECEIVE  (PYNQ / Zynq)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def dma_receive(n_samples: int,
                data_bits_ref=None, snr_db: float = 20.0) -> dict:
    """
    Arm S2MM DMA via /dev/mem, receive n_samples words, unpack Q15,
    and run the full RX pipeline.

    Parameters
    ----------
    n_samples     : number of 32-bit words to receive
    data_bits_ref : (optional) reference bits for BER computation
    snr_db        : SNR assumption for MMSE equaliser (dB)

    Returns
    -------
    dict with keys: rx_words, rx_real, rx_imag, rx_result
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")

    rx_words         = _dma.dma_recv(n_samples)
    rx_real, rx_imag = _dma.unpack_q15(rx_words)

    print(f"[DMA] Received {len(rx_words)} words â€” running RX pipeline â€¦")
    rx_result = receive(rx_real, data_bits_ref=data_bits_ref, snr_db=snr_db)

    return dict(
        rx_words  = rx_words,
        rx_real   = rx_real,
        rx_imag   = rx_imag,
        rx_result = rx_result,
    )


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  INPUT LOADERS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def load_from_file(path: str) -> tuple:
    """Load waveform from .npz produced by bpsk_tx.py or a hardware logger."""
    data     = np.load(path)
    rx_pb    = data["tx_pb"] if "tx_pb" in data else data["rx_pb"]
    ref_bits = data["data_bits"].astype(int) if "data_bits" in data else None
    return rx_pb.astype(np.float64), ref_bits


def record_from_mic(duration_s: float) -> np.ndarray:
    if not _HAS_SD:
        raise RuntimeError("sounddevice not installed â€” cannot record.")
    print(f"  Recording {duration_s:.2f} s @ {P.Fs/1e3:.0f} kHz â€¦")
    audio = sd.rec(int(duration_s * P.Fs), samplerate=int(P.Fs),
                   channels=1, dtype="float32")
    sd.wait()
    return audio[:, 0].astype(np.float64)


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  MAIN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def main():
    parser = argparse.ArgumentParser(description="BPSK UW Receiver")
    grp = parser.add_mutually_exclusive_group(required=True)
    grp.add_argument("--in",       dest="infile",   help="Path to rx_capture.npz")
    grp.add_argument("--loopback", dest="loopback", help="tx_frame.npz (self-test)")
    grp.add_argument("--record",   action="store_true", help="Capture via microphone")
    grp.add_argument("--dma",      action="store_true",
                     help="Receive samples from S2MM DMA (/dev/mem)")
    parser.add_argument("--duration",  type=float, default=0.5,
                        help="Recording duration in seconds (--record only)")
    parser.add_argument("--n-samples", type=int,   default=None,
                        help="Number of 32-bit words to receive (--dma); "
                             "defaults to (FRAME_SYMS + SpanRRC) Ã— sps")
    parser.add_argument("--ref-bits",  default=None,
                        help="Path to .npz with data_bits array for BER (--dma)")
    parser.add_argument("--frame-len-words", type=int, default=None,
                        help="TLAST generator frame length in 32-bit words for --dma (default: --n-samples)")
    parser.add_argument("--skip-tlast-config", action="store_true",
                        help="Do not program the TLAST frame_len/reset GPIOs before --dma")
    parser.add_argument("--snr",  type=float, default=20.0,
                        help="SNR assumption for MMSE equaliser (dB)")
    parser.add_argument("--plot", action="store_true", help="Show diagnostic plots")
    args = parser.parse_args()

    ref_bits = None

    if args.dma:
        n_samp = args.n_samples or (P.FRAME_SYMS + P.SpanRRC) * P.sps
        frame_len_words = (args.frame_len_words if args.frame_len_words is not None
                           else n_samp)
        if frame_len_words <= 0:
            parser.error("--frame-len-words must be > 0")

        if args.ref_bits:
            ref_bits = np.load(args.ref_bits)["data_bits"].astype(int)

        if not args.skip_tlast_config:
            _dma.configure_tlast_frame_len(frame_len_words)
        dma_res = dma_receive(n_samp, data_bits_ref=ref_bits, snr_db=args.snr)
        if args.plot:
            plot_rx(dma_res["rx_result"])

    else:
        if args.loopback:
            rx_pb, ref_bits = load_from_file(args.loopback)
            print(f"  Loopback mode â€” loaded from {args.loopback}")
        elif args.infile:
            rx_pb, ref_bits = load_from_file(args.infile)
            print(f"  Loaded capture from {args.infile}")
        else:
            rx_pb = record_from_mic(args.duration)

        res = receive(rx_pb, data_bits_ref=ref_bits, snr_db=args.snr)

        if args.plot:
            plot_rx(res)


if __name__ == "__main__":
    main()
