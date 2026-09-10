"""
qpsk_tx.py
==========
QPSK -- TRANSMITTER  (baseband only, numpy-only, no scipy)
============================================================
Produces a complex baseband waveform file ``tx_frame.npz`` at Fs = 400 kSPS.
No upconversion to a carrier -- output is the RRC pulse-shaped baseband
signal; the FPGA's DDS Compiler NCO (bpsk_dma.set_nco_frequency(),
Fc=120kHz) does the upconversion in hardware, same division of labor as
bpsk_tx.py.

Sibling to bpsk_tx.py -- SAME frame layout and geometry (preamble, CP,
pilot, block count, symbol counts per block are all unchanged; see
qpsk_params.py's docstring for why). The only real differences:
  - build_frame()'s bit-to-symbol map is Gray-coded QPSK (2 bits/symbol,
    complex) instead of BPSK's 1 bit/symbol real +-1 map.
  - The data guard symbol is a known COMPLEX point (qpsk_params.GUARD_SYM)
    instead of BPSK's real -1.
  - pack_for_dma() sends BOTH DAC channels (I=real, Q=imag) instead of
    zeroing Q, since QPSK's waveform is genuinely complex -- same fix
    already applied in lfm_qpsk_tx.py's pack_for_dma().
  - No --play / sounddevice support: a single real audio channel cannot
    represent a genuinely complex QPSK baseband waveform without a
    quadrature downconverter, so playback is dropped here rather than
    silently playing only one rail. (lfm_qpsk_tx.py made the same choice
    -- it never had a --play path either.)

Frame layout (symbol domain) -- IDENTICAL to bpsk_tx.py's:
  Preamble (96 sym -- two identical 48-sym PN halves, no CP)
  x 4 blocks of:  [CP(175) | Pilot(512) | CP(175) | Guard(1)+Data(256)]

Usage
-----
  python qpsk_tx.py                        # saves tx_frame.npz + prints info
  python qpsk_tx.py --plot                 # show diagnostic plots
  python qpsk_tx.py --dma                  # pack & send via MM2S DMA (PYNQ)
  python qpsk_tx.py --dma-loopback         # send MM2S + recv S2MM + run RX (PYNQ)
  python qpsk_tx.py --dma-loopback --plot  # loopback + diagnostic plots
"""

import argparse
import numpy as np
import qpsk_params as P

try:
    import matplotlib.pyplot as plt
    _HAS_PLT = True
except ImportError:
    _HAS_PLT = False

try:
    import bpsk_dma as _dma
    _HAS_DMA = True
except ImportError:
    _HAS_DMA = False


# ══════════════════════════════════════════════════════════════════════
#  TRANSMITTER PIPELINE
# ══════════════════════════════════════════════════════════════════════

def _add_cp(block: np.ndarray) -> np.ndarray:
    """
    Prepend a Cyclic Prefix (CP) to a symbol block. Identical to
    bpsk_tx.py's _add_cp() -- works the same whether block is real
    (the preamble/pilot sections) or complex (the QPSK data section).

    Input
    -----
    block : (N,) ndarray -- real or complex symbols

    Output
    ------
    (N + CP_sym,) ndarray -- same block with its last CP_sym (=175)
                             symbols copied and placed at the front
    """
    return np.concatenate([block[-P.CP_sym:], block])


def build_frame(data_bits: np.ndarray) -> np.ndarray:
    """
    Convert raw data bits into a complete QPSK transmission frame.

    Input
    -----
    data_bits : (2048,) uint8 -- flat array of {0, 1} bits
                (Ndata_bits x Nblocks = 512 x 4 = 2048 bits)

    Output
    ------
    tx_frame : (4568,) complex128 -- full symbol frame
               Layout: Preamble(96) + 4 x [CP+Pilot(687) + CP+Data(431)]
               Total: 96 + 4 x 1118 = 4568 symbols -- SAME symbol count
               as bpsk_tx.py's build_frame(), since Ndata (256 symbols/
               block) is unchanged; only each symbol now carries 2 bits.

    What it does
    ------------
    Step 1 -- QPSK map: converts every 2 bits to one complex symbol via
             qpsk_params.qpsk_map() (Gray-coded, independent I/Q rails).
    Step 2 -- Preamble: prepends 96 known PN symbols (two identical
             48-sym halves, no CP) -- same real BPSK-modulated preamble
             as bpsk_tx.py's, unchanged (sync reference, not payload).
    Step 3 -- Data blocks: appends 4 blocks, each structured as:
               [CP(175) + Pilot(512)] = 687 sym -- known REAL pilot
                                                    (unchanged, see
                                                    qpsk_params.py)
               [CP(175) + Guard(1) + Data(256)] = 431 sym -- QPSK payload
                                                    symbols to decode
    """
    assert len(data_bits) == P.Ndata_bits_total, \
        f"Expected {P.Ndata_bits_total} data bits, got {len(data_bits)}"

    # Step 1: QPSK mapping -- 2 bits -> 1 complex symbol, Gray-coded.
    # Mapping the whole flat bit array at once and then slicing per-block
    # symbol ranges below is equivalent to slicing bits per block first:
    # qpsk_map() pairs bits[0::2]/bits[1::2] elementwise with no overlap
    # across the pairing, so block b's Ndata_bits-bit slice always maps
    # to exactly its Ndata-symbol slice.
    data_sym = P.qpsk_map(data_bits)   # (1024,) complex128

    # Step 2: Start the frame with the preamble (real, unchanged).
    frame = list(P.PREAMBLE_SYM)

    # Step 3: Append 4 data blocks, same structure as bpsk_tx.py's:
    #   [CP(175) + Pilot(512)] = 687 sym  -> known pilot for channel estimation
    #   [CP(175) + Guard(1) + Data(256)] -> guard absorbs block-edge weakness
    for b in range(P.Nblocks):
        d_block = data_sym[b * P.Ndata : (b + 1) * P.Ndata]   # 256 QPSK symbols for block b
        guard = np.full(P.Ndata_guard, P.GUARD_SYM, dtype=np.complex128)
        d_block_tx = np.concatenate([guard, d_block])
        frame.extend(_add_cp(P.PILOT_SYM))    # CP + Pilot (real)
        frame.extend(_add_cp(d_block_tx))     # CP + Guard + Data (complex)

    tx_frame = np.array(frame, dtype=np.complex128)
    assert len(tx_frame) == P.FRAME_SYMS, \
        f"Frame length mismatch: {len(tx_frame)} vs {P.FRAME_SYMS}"
    return tx_frame


def _fir_filter(h: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Apply a causal FIR filter to signal x using coefficients h. Identical
    to bpsk_tx.py's -- np.convolve works for complex x with real h
    unchanged (ordinary elementwise convolution).
    """
    return np.convolve(x, h)[:len(x)]


def pulse_shape(sym: np.ndarray) -> np.ndarray:
    """
    Upsample a QPSK symbol sequence and apply RRC pulse shaping.

    Input
    -----
    sym : (4568,) complex128 -- symbol frame from build_frame()

    Output
    ------
    (109824,) complex128 -- pulse-shaped baseband waveform at Fs=400 kSPS
                            N = (FRAME_SYMS + SpanRRC) x sps, same length
                            as bpsk_tx.py's (109 824 samples)

    What it does
    ------------
    Same three steps as bpsk_tx.py's pulse_shape() -- guard zeros, then
    upsample, then RRC filter -- generalized to a complex symbol/sample
    dtype throughout (only the dtype of the intermediate arrays changes;
    the algorithm is identical).
    """
    guard      = P.SpanRRC
    sym_padded = np.concatenate([sym, np.zeros(guard, dtype=np.complex128)])
    up         = np.zeros(len(sym_padded) * P.sps, dtype=np.complex128)
    up[::P.sps] = sym_padded
    return _fir_filter(P.RRC, up)


def transmit(data_bits: np.ndarray, verbose: bool = True) -> dict:
    """
    Run the complete baseband TX chain from bits to a ready-to-send waveform.

    Input
    -----
    data_bits : (2048,) uint8 -- flat {0,1} bit array
                (Ndata_bits x Nblocks = 512 x 4)
    verbose   : bool -- print frame/sample/timing summary (default: True)

    Output
    ------
    dict with keys:
      'data_bits' : (2048,)   uint8      -- original input bits, unchanged
      'tx_frame'  : (4568,)   complex128 -- QPSK symbol frame
      'tx_shaped' : (109824,) complex128 -- pulse-shaped waveform before
                                            peak normalisation
      'tx_pb'     : (109824,) complex128 -- final unit-peak-MODULUS
                                            normalised baseband waveform
                                            (send this)
      'frame_dur' : float -- total frame duration in seconds (same as
                             bpsk_tx.py's, ~0.274 s -- symbol count and
                             sample rate are both unchanged)
    """
    # Step 1: Frame assembly
    tx_frame  = build_frame(data_bits)

    # Step 2: Pulse shaping
    tx_shaped = pulse_shape(tx_frame)

    # Step 3: Normalise -- scale by the peak COMPLEX MODULUS so |tx_pb|
    # never exceeds 1, the QPSK analogue of bpsk_tx.py's peak-|amplitude|
    # normalisation (real +-1 there, so abs() was already the modulus).
    tx_out    = tx_shaped / (np.max(np.abs(tx_shaped)) + 1e-12)   # -> tx_pb

    frame_dur = len(tx_shaped) / P.Fs

    if verbose:
        print("=== TX INFO ===")
        print(f"  Data bits      : {len(data_bits)}  ({P.bps_sym} bits/sym)")
        print(f"  Frame symbols  : {len(tx_frame)}")
        print(f"  TX samples     : {len(tx_out)}")
        print(f"  Duration       : {frame_dur*1e3:.2f} ms")
        print(f"  Sample rate    : {P.Fs/1e3:.0f} kSPS  (baseband)")
        print(f"  CP length      : {P.CP_sym} sym  ({P.CP_samp} samp)")
        print(f"  Npilot         : {P.Npilot}  |  Payload data : {P.Ndata} sym "
              f"({P.Ndata_bits} bits)")
        print(f"  Data guard     : {P.Ndata_guard} sym/block  "
              f"|  TX data section : {P.Ndata_tx} sym/block")

    return dict(
        data_bits = data_bits,
        tx_frame  = tx_frame,
        tx_shaped = tx_shaped,
        tx_pb     = tx_out,       # kept as 'tx_pb' so save/DMA helpers are unchanged
        frame_dur = frame_dur,
    )


# ══════════════════════════════════════════════════════════════════════
#  SAVE / PLOT HELPERS
# ══════════════════════════════════════════════════════════════════════

def save(result: dict, path: str = "tx_frame.npz"):
    """
    Save the TX waveform and system parameters to a compressed .npz file.
    Identical to bpsk_tx.py's save() -- np.savez handles the now-complex
    tx_pb array with no change needed.
    """
    np.savez(
        path,
        tx_pb     = result["tx_pb"],
        data_bits = result["data_bits"],   # ground truth for BER at RX
        Fs        = P.Fs,
        sps       = P.sps,
        CP_sym    = P.CP_sym,
        Npilot    = P.Npilot,
    )
    print(f"\n  Saved -> {path}")


def plot_tx(result: dict):
    """
    Display four diagnostic plots of the TX signal. Identical structure
    to bpsk_tx.py's plot_tx() -- the constellation-relevant panels
    (symbol frame, eye diagram) already work unchanged for complex
    values since they plot np.real()/step() over the raw array.
    """
    if not _HAS_PLT:
        print("  [WARN] matplotlib not installed -- cannot plot.")
        return

    tx_out   = result["tx_pb"]
    tx_frame = result["tx_frame"]

    fig, axes = plt.subplots(2, 2, figsize=(13, 8))
    fig.suptitle(
        f"QPSK TX (baseband) -- Fs={P.Fs/1e3:.0f} kSPS, "
        f"sps={P.sps}, RRC rolloff={P.rolloff}",
        fontsize=11,
    )

    # 1. Symbol frame (first 500 symbols, real + imag rails)
    ax = axes[0, 0]
    n_show = min(500, len(tx_frame))
    ax.step(np.arange(n_show), np.real(tx_frame[:n_show]), where="mid",
            linewidth=0.7, label="I")
    ax.step(np.arange(n_show), np.imag(tx_frame[:n_show]), where="mid",
            linewidth=0.7, label="Q")
    ax.set_title("TX Symbol Frame (first 500 sym)")
    ax.set_xlabel("Symbol index")
    ax.set_ylabel("Amplitude")
    ax.legend(); ax.grid(True)

    # 2. Baseband time-domain (first 3 ms, real + imag)
    ax    = axes[0, 1]
    n_3ms = min(int(3e-3 * P.Fs), len(tx_out))
    t_ms  = np.arange(n_3ms) / P.Fs * 1e3
    ax.plot(t_ms, np.real(tx_out[:n_3ms]), linewidth=0.5, label="I")
    ax.plot(t_ms, np.imag(tx_out[:n_3ms]), linewidth=0.5, label="Q")
    ax.set_title("TX Baseband -- first 3 ms")
    ax.set_xlabel("Time (ms)")
    ax.set_ylabel("Amplitude")
    ax.legend(); ax.grid(True)

    # 3. Baseband spectrum (0 to Fs/2) -- complex FFT, not rfft, since
    # the QPSK baseband spectrum is not conjugate-symmetric in general.
    ax   = axes[1, 0]
    NFFT = 16384
    f    = np.fft.fftshift(np.fft.fftfreq(NFFT, d=1/P.Fs)) / 1e3
    spec = 20 * np.log10(np.abs(np.fft.fftshift(
        np.fft.fft(tx_out[:NFFT], NFFT))) + 1e-12)
    ax.plot(f, spec, linewidth=0.7)
    ax.axvline(P.Rs/2e3, color='r', linestyle='--',
               label=f'Rs/2={P.Rs/2e3:.1f} kHz')
    ax.axvline(-P.Rs/2e3, color='r', linestyle='--')
    ax.set_title("TX Baseband Spectrum")
    ax.set_xlabel("Frequency (kHz)")
    ax.set_ylabel("Magnitude (dB)")
    ax.legend(); ax.grid(True)

    # 4. QPSK constellation, RRC output (preamble region, one sample/sym)
    ax     = axes[1, 1]
    offset = P.Npreamble * P.sps
    n_syms = 200
    pts    = tx_out[offset: offset + n_syms * P.sps: P.sps]
    ax.plot(np.real(pts), np.imag(pts), 'b.', markersize=4)
    ax.set_title("Constellation (RRC output, preamble region)")
    ax.set_xlabel("I"); ax.set_ylabel("Q")
    ax.grid(True); ax.axis("equal")

    plt.tight_layout()
    plt.show()


# ══════════════════════════════════════════════════════════════════════
#  DMA HELPERS  (PYNQ / Zynq)
# ══════════════════════════════════════════════════════════════════════

def pack_for_dma(tx_out: np.ndarray) -> np.ndarray:
    """
    Convert the normalised complex baseband waveform into packed Q15
    uint32 DMA words.

    Input
    -----
    tx_out : (N,) complex128 -- unit-peak-modulus baseband waveform
                                (tx_pb from transmit())

    Output
    ------
    (N,) uint32 -- one 32-bit word per sample, packed as:
      Bits [15: 0] -> Real (I) part in Q15 format
      Bits [31:16] -> Imag (Q) part in Q15 format

    What it does
    ------------
    Unlike bpsk_tx.py's pack_for_dma() (which zeroes the imaginary
    channel because BPSK's waveform is real), QPSK genuinely needs BOTH
    DAC channels -- I=real(tx_out), Q=imag(tx_out) -- so the hardware
    NCO can do a proper complex upconversion. Same fix already applied
    in lfm_qpsk_tx.py's pack_for_dma(). Raises RuntimeError if
    bpsk_dma.py is not available.
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    words = _dma.pack_q15(np.real(tx_out), np.imag(tx_out))
    print(f"  DMA words packed  : {len(words)}  ({len(words)*4/1024:.1f} kB, uint32)")
    print(f"  Word layout       : Bits[15:0]=Re(I,Q15)  Bits[31:16]=Im(Q,Q15)")
    return words


def dma_send(tx_out: np.ndarray):
    """
    Pack the baseband waveform and stream it continuously to the FPGA via
    MM2S DMA. Identical control flow to bpsk_tx.py's dma_send() -- only
    pack_for_dma()'s I/Q channel mapping differs.
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    words = pack_for_dma(tx_out)
    _dma.dma_send(words)


# ══════════════════════════════════════════════════════════════════════
#  MAIN
# ══════════════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(description="QPSK Transmitter (baseband)")
    parser.add_argument("--plot", action="store_true", help="Show diagnostic plots")
    parser.add_argument("--seed", type=int, default=0,  help="RNG seed for data bits")
    parser.add_argument("--out",  default="tx_frame.npz", help="Output .npz path")
    parser.add_argument("--dma",  action="store_true",
                        help="Pack waveform and send via MM2S DMA (/dev/mem)")
    args = parser.parse_args()

    # Random data bits
    rng       = np.random.default_rng(seed=args.seed)
    data_bits = rng.integers(0, 2, size=P.Ndata_bits_total).astype(np.uint8)

    # Run TX chain
    result = transmit(data_bits)

    # Save waveform
    save(result, path=args.out)

    # Optional: send via MM2S DMA
    if args.dma:
        dma_send(result["tx_pb"])

    # Optional: TX diagnostic plots
    if args.plot:
        plot_tx(result)


if __name__ == "__main__":
    main()
