"""
bpsk_tx.py
==========
BPSK â€“ TRANSMITTER  (baseband only, numpy-only, no scipy)
==========================================================
Produces a baseband waveform file ``tx_frame.npz`` at Fs = 400 kSPS.
No upconversion to a carrier â€” output is the RRC pulse-shaped baseband signal.

Frame layout (symbol domain)
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Preamble (96 sym â€” two identical 48-sym PN halves, no CP)
  Ã— 4 blocks of:  [CP(175) | Pilot(512) | CP(175) | Data(256)]

Usage
â”€â”€â”€â”€â”€
  python bpsk_tx.py                        # saves tx_frame.npz + prints info
  python bpsk_tx.py --play                 # also plays audio (requires sounddevice)
  python bpsk_tx.py --plot                 # show diagnostic plots
  python bpsk_tx.py --dma                  # pack & send via MM2S DMA (PYNQ)
  python bpsk_tx.py --dma-loopback         # send MM2S + recv S2MM + run RX (PYNQ)
  python bpsk_tx.py --dma-loopback --plot  # loopback + diagnostic plots
"""

import argparse
import numpy as np
import bpsk_params as P

# â”€â”€ optional imports (hardware / plotting) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
try:
    import sounddevice as sd
    _HAS_SD = True
except Exception:
    _HAS_SD = False

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


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  TRANSMITTER PIPELINE
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def _add_cp(block: np.ndarray) -> np.ndarray:
    """
    Prepend a Cyclic Prefix (CP) to a symbol block.

    Input
    -----
    block : (N,) float64 â€” array of BPSK symbols {-1.0, +1.0}

    Output
    ------
    (N + CP_sym,) float64 â€” same block with its last CP_sym (=175) symbols
                            copied and placed at the front

    What it does
    ------------
    Copies the last 175 symbols of 'block' to the beginning, creating a guard
    interval.  At the receiver, these duplicate symbols absorb multipath echoes
    so each block looks like a clean, circular convolution â€” no inter-block
    interference bleeds in.
    """
    return np.concatenate([block[-P.CP_sym:], block])


def build_frame(data_bits: np.ndarray) -> np.ndarray:
    """
    Convert raw data bits into a complete BPSK transmission frame.

    Input
    -----
    data_bits : (1024,) uint8 â€” flat array of {0, 1} bits
                (Ndata Ã— Nblocks = 256 Ã— 4 = 1024 bits)

    Output
    ------
    tx_frame : (4568,) float64 â€” full symbol frame of {-1.0, +1.0}
               Layout: Preamble(96) + 4 Ã— [CP+Pilot(687) + CP+Data(431)]
               Total: 96 + 4 Ã— 1118 = 4568 symbols

    What it does
    ------------
    Step 1 â€” BPSK map: converts each bit to a symbol (0 â†’ -1.0, 1 â†’ +1.0).
    Step 2 â€” Preamble: prepends 96 known PN symbols (two identical 48-sym halves,
             no CP).  The receiver cross-correlates against this to detect and
             time-align the incoming frame.
    Step 3 â€” Data blocks: appends 4 blocks, each structured as:
               [CP(175) + Pilot(512)] = 687 sym â€” known pilot the RX uses to
                                                   estimate the channel distortion
               [CP(175) + Data(256)]  = 431 sym â€” actual payload symbols to decode
    """
    assert len(data_bits) == P.Ndata * P.Nblocks, \
        f"Expected {P.Ndata * P.Nblocks} data bits, got {len(data_bits)}"

    # Step 1: BPSK mapping â€” convert each bit to a constellation point
    # bit 0 â†’ -1.0  (BPSK "low"),  bit 1 â†’ +1.0  (BPSK "high")
    data_sym = 2 * data_bits.astype(np.float64) - 1

    # Step 2: Start the frame with the preamble
    # Two identical 48-symbol PN sequences (total 96 sym), no cyclic prefix.
    # The RX uses this known pattern to detect the frame and synchronise timing.
    frame = list(P.PREAMBLE_SYM)

    # Step 3: Append 4 data blocks.  Each block has the structure:
    #   [CP(175) + Pilot(512)] = 687 sym  -> known pilot for channel estimation
    #   [CP(175) + Guard(1) + Data(256)] -> guard absorbs block-edge weakness
    # The Cyclic Prefix (CP) is the last CP_sym symbols of the block copied to
    # the front â€” it absorbs multipath echoes so the RX sees a clean block edge.
    for b in range(P.Nblocks):
        d_block = data_sym[b * P.Ndata : (b + 1) * P.Ndata]   # 256 BPSK symbols for block b
        guard = -np.ones(P.Ndata_guard, dtype=np.float64)
        d_block_tx = np.concatenate([guard, d_block])
        frame.extend(_add_cp(P.PILOT_SYM))   # CP + Pilot:  RX uses pilot to estimate channel distortion
        frame.extend(_add_cp(d_block_tx))     # CP + Guard + Data: guard is discarded at RX

    tx_frame = np.array(frame, dtype=np.float64)
    assert len(tx_frame) == P.FRAME_SYMS, \
        f"Frame length mismatch: {len(tx_frame)} vs {P.FRAME_SYMS}"
    return tx_frame


def _fir_filter(h: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Apply a causal FIR filter to signal x using coefficients h.

    Input
    -----
    h : (M,) float64 â€” FIR filter taps (e.g. RRC coefficients, length = SpanRRCÃ—sps+1 = 193)
    x : (N,) float64 â€” input signal to filter (upsampled symbol sequence)

    Output
    ------
    (N,) float64 â€” filtered output, same length as x.
                   The first M-1 samples contain the filter start-up transient.

    What it does
    ------------
    Computes the full linear convolution of x with h (length N+M-1), then
    truncates back to length N.  This replicates the causal behaviour of
    scipy.signal.lfilter(h, 1, x) without requiring scipy.
    """
    return np.convolve(x, h)[:len(x)]


def pulse_shape(sym: np.ndarray) -> np.ndarray:
    """
    Upsample a BPSK symbol sequence and apply RRC pulse shaping.

    Input
    -----
    sym : (4568,) float64 â€” symbol frame of {-1.0, +1.0} from build_frame()

    Output
    ------
    (109824,) float64 â€” pulse-shaped baseband waveform at Fs = 400 kSPS
                        N = (FRAME_SYMS + SpanRRC) Ã— sps = (4568 + 8) Ã— 24 = 109 824 samples

    What it does
    ------------
    Step 1 â€” Guard: appends SpanRRC (=8) zero symbols to the end so the RRC
             filter tail fully drains and does not truncate the last symbols.
    Step 2 â€” Upsample: creates a zero-filled array at the output sample rate
             (Fs = 400 kSPS) and places each symbol at every sps-th (24th) index.
             This raises the rate from Rs â‰ˆ 16.7 kSPS â†’ Fs = 400 kSPS.
    Step 3 â€” RRC filter: convolves the upsampled signal with the RRC taps to
             band-limit it to BW = 20 kHz, removing inter-symbol interference.
    """
    guard      = P.SpanRRC
    sym_padded = np.concatenate([sym, np.zeros(guard)])
    up         = np.zeros(len(sym_padded) * P.sps, dtype=np.float64)
    up[::P.sps] = sym_padded
    return _fir_filter(P.RRC, up)


def transmit(data_bits: np.ndarray, verbose: bool = True) -> dict:
    """
    Run the complete baseband TX chain from bits to a ready-to-send waveform.

    Input
    -----
    data_bits : (1024,) uint8 â€” flat {0,1} bit array (Ndata Ã— Nblocks = 256 Ã— 4)
    verbose   : bool          â€” print frame/sample/timing summary (default: True)

    Output
    ------
    dict with keys:
      'data_bits' : (1024,)   uint8   â€” original input bits, passed through unchanged
      'tx_frame'  : (4568,)   float64 â€” BPSK symbol frame {-1.0, +1.0}
      'tx_shaped' : (109824,) float64 â€” pulse-shaped waveform before peak normalisation
      'tx_pb'     : (109824,) float64 â€” final Â±1 normalised baseband waveform (send this)
      'frame_dur' : float             â€” total frame duration in seconds (â‰ˆ 0.274 s)

    What it does
    ------------
    Step 1 â€” Frame assembly (build_frame):
             Maps bits to Â±1 BPSK symbols, then wraps them in the full frame:
             preamble + 4 blocks of [CP+Pilot | CP+Data].
    Step 2 â€” Pulse shaping (pulse_shape):
             Upsamples by sps=24 and applies the RRC FIR filter to produce a
             band-limited waveform at Fs = 400 kSPS.
    Step 3 â€” Normalisation:
             Divides by the peak amplitude so tx_pb lies in [-1, +1], using the
             DAC's full dynamic range without any clipping.
    """
    # Step 1: Frame assembly
    # Map bits to Â±1 BPSK symbols, then wrap them in the full frame structure:
    # [Preamble(96)] + 4 Ã— [CP+Pilot(687) | CP+Data(431)] = FRAME_SYMS symbols total.
    tx_frame  = build_frame(data_bits)

    # Step 2: Pulse shaping
    # Upsample: insert (sps-1) zeros between each symbol to raise the sample rate.
    # Apply RRC (Root Raised Cosine) FIR filter to band-limit the signal and remove
    # inter-symbol interference. Guard zeros appended so the filter tail fully drains.
    tx_shaped = pulse_shape(tx_frame)

    # Step 3: Normalise
    # Scale the waveform so its peak is exactly Â±1.
    # This ensures the DAC uses its full dynamic range without clipping.
    tx_out    = tx_shaped / (np.max(np.abs(tx_shaped)) + 1e-12)   # â†’ tx_pb (ready to send)

    frame_dur = len(tx_shaped) / P.Fs

    if verbose:
        print("=== TX INFO ===")
        print(f"  Data bits      : {len(data_bits)}")
        print(f"  Frame symbols  : {len(tx_frame)}")
        print(f"  TX samples     : {len(tx_out)}")
        print(f"  Duration       : {frame_dur*1e3:.2f} ms")
        print(f"  Sample rate    : {P.Fs/1e3:.0f} kSPS  (baseband)")
        print(f"  CP length      : {P.CP_sym} sym  ({P.CP_samp} samp)")
        print(f"  Npilot         : {P.Npilot}  |  Payload data : {P.Ndata}")
        print(f"  Data guard     : {P.Ndata_guard} sym/block  "
              f"|  TX data section : {P.Ndata_tx} sym/block")

    return dict(
        data_bits = data_bits,
        tx_frame  = tx_frame,
        tx_shaped = tx_shaped,
        tx_pb     = tx_out,       # kept as 'tx_pb' so save/DMA helpers are unchanged
        frame_dur = frame_dur,
    )


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  SAVE / PLAY / PLOT HELPERS
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def save(result: dict, path: str = "tx_frame.npz"):
    """
    Save the TX waveform and system parameters to a compressed .npz file.

    Input
    -----
    result : dict â€” output of transmit(); must contain 'tx_pb' and 'data_bits'
    path   : str  â€” destination file path (default: 'tx_frame.npz')

    Output
    ------
    None â€” writes a .npz archive to disk containing:
      tx_pb, data_bits, Fs, sps, CP_sym, Npilot

    What it does
    ------------
    Serialises the baseband waveform and the original data bits so the RX script
    can load them later for offline BER analysis or waveform-level comparison.
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
    print(f"\n  Saved â†’ {path}")


def play(tx_pb: np.ndarray):
    """
    Play the baseband waveform through the system's default audio output.

    Input
    -----
    tx_pb : (N,) float64 â€” normalised Â±1 baseband waveform (output of transmit())

    Output
    ------
    None â€” streams audio in real time; blocks until playback completes

    What it does
    ------------
    Casts the waveform to float32 and plays it via sounddevice at Fs = 400 kSPS.
    Used for bench testing with an audio DAC when the FPGA is not available.
    Prints a warning and returns immediately if sounddevice is not installed.
    """
    if not _HAS_SD:
        print("  [WARN] sounddevice not installed â€” cannot play audio.")
        return
    print(f"\n  Playing {len(tx_pb)/P.Fs*1e3:.1f} ms via sounddevice â€¦")
    sd.play(tx_pb.astype(np.float32), samplerate=int(P.Fs))
    sd.wait()


def plot_tx(result: dict):
    """
    Display four diagnostic plots of the TX signal.

    Input
    -----
    result : dict â€” output of transmit(); must contain 'tx_pb' and 'tx_frame'

    Output
    ------
    None â€” opens a 2Ã—2 matplotlib figure with:
      [0,0] Symbol frame     â€” first 500 symbols as a step plot {-1, +1}
      [0,1] Time domain      â€” first 3 ms of the RRC-shaped baseband waveform
      [1,0] Spectrum         â€” magnitude (dB) from 0 to Fs/2 = 200 kHz
      [1,1] Eye diagram      â€” 50 overlaid 2-symbol traces from the preamble region

    What it does
    ------------
    Extracts tx_pb and tx_frame from the result dict and renders all four plots
    in one figure for quick visual inspection of symbol quality, spectral occupancy,
    and ISI (eye opening).  Prints a warning and returns if matplotlib is not installed.
    """
    if not _HAS_PLT:
        print("  [WARN] matplotlib not installed â€” cannot plot.")
        return

    tx_out   = result["tx_pb"]
    tx_frame = result["tx_frame"]

    fig, axes = plt.subplots(2, 2, figsize=(13, 8))
    fig.suptitle(
        f"BPSK TX (baseband) â€” Fs={P.Fs/1e3:.0f} kSPS, "
        f"sps={P.sps}, RRC rolloff={P.rolloff}",
        fontsize=11,
    )

    # 1. Symbol frame (first 500 symbols)
    ax = axes[0, 0]
    n_show = min(500, len(tx_frame))
    ax.step(np.arange(n_show), tx_frame[:n_show], where="mid", linewidth=0.7)
    ax.set_title("TX Symbol Frame (first 500 sym)")
    ax.set_xlabel("Symbol index")
    ax.set_ylabel("Amplitude")
    ax.grid(True)

    # 2. Baseband time-domain (first 3 ms)
    ax    = axes[0, 1]
    n_3ms = min(int(3e-3 * P.Fs), len(tx_out))
    t_ms  = np.arange(n_3ms) / P.Fs * 1e3
    ax.plot(t_ms, tx_out[:n_3ms], linewidth=0.5)
    ax.set_title("TX Baseband â€” first 3 ms")
    ax.set_xlabel("Time (ms)")
    ax.set_ylabel("Amplitude")
    ax.grid(True)

    # 3. Baseband spectrum (0 to Fs/2)
    ax   = axes[1, 0]
    NFFT = 16384
    f    = np.fft.rfftfreq(NFFT, d=1/P.Fs) / 1e3
    spec = 20 * np.log10(np.abs(np.fft.rfft(tx_out[:NFFT], NFFT)) + 1e-12)
    ax.plot(f, spec, linewidth=0.7)
    ax.axvline(P.Rs/2e3, color='r', linestyle='--',
               label=f'Rs/2={P.Rs/2e3:.1f} kHz')
    ax.set_title("TX Baseband Spectrum")
    ax.set_xlabel("Frequency (kHz)")
    ax.set_ylabel("Magnitude (dB)")
    ax.legend(); ax.grid(True)

    # 4. RRC eye diagram (last 200 symbols of preamble region)
    ax     = axes[1, 1]
    eye_sym = 2
    eye_samp = eye_sym * P.sps
    offset   = P.Npreamble * P.sps
    n_traces = 50
    for i in range(n_traces):
        s = offset + i * P.sps
        if s + eye_samp > len(tx_out):
            break
        ax.plot(np.arange(eye_samp) / P.sps, tx_out[s:s+eye_samp],
                'b', alpha=0.2, linewidth=0.5)
    ax.set_title("Eye Diagram (RRC output, preamble region)")
    ax.set_xlabel("Symbol period")
    ax.set_ylabel("Amplitude")
    ax.grid(True)

    plt.tight_layout()
    plt.show()


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  DMA HELPERS  (PYNQ / Zynq)
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def pack_for_dma(tx_out: np.ndarray) -> np.ndarray:
    """
    Convert the normalised baseband waveform into packed Q15 uint32 DMA words.

    Input
    -----
    tx_out : (N,) float64 â€” normalised Â±1 baseband waveform (tx_pb from transmit())

    Output
    ------
    (N,) uint32 â€” one 32-bit word per sample, packed as:
      Bits [15: 0] â†’ Real part in Q15 format  (float Ã— 32767, signed 16-bit)
      Bits [31:16] â†’ Imaginary part = 0        (real baseband, no carrier)

    What it does
    ------------
    Creates a zero imaginary array, then calls bpsk_dma.pack_q15() which scales
    each float sample to the Q15 range [-32768, 32767] and packs Re and Im into
    one uint32 per sample.  The FPGA DMA engine expects this interleaved format.
    Raises RuntimeError if bpsk_dma.py is not available.
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    imag_zero = np.zeros_like(tx_out)
    words = _dma.pack_q15(tx_out, imag_zero)
    print(f"  DMA words packed  : {len(words)}  ({len(words)*4/1024:.1f} kB, uint32)")
    print(f"  Word layout       : Bits[15:0]=Re(Q15)  Bits[31:16]=Im(Q15)=0")
    return words


def dma_send(tx_out: np.ndarray):
    """
    Pack the baseband waveform and stream it continuously to the FPGA via MM2S DMA.

    Input
    -----
    tx_out : (N,) float64 â€” normalised Â±1 baseband waveform (tx_pb from transmit())

    Output
    ------
    None â€” runs until Ctrl+C (SIGINT) or SIGTERM is received

    What it does
    ------------
    Calls pack_for_dma() to convert float64 samples â†’ Q15 uint32 words, then
    passes the word buffer to bpsk_dma.dma_send() which:
      1. Writes the Q15 words into the DDR TX buffer once (MM2S_BUF_PHYS).
      2. Enters a loop: kicks the AXI DMA controller â†’ waits for IOC interrupt
         â†’ kicks again â€” continuously replaying the same buffer to the DAC.
      3. Exits cleanly when Ctrl+C or SIGTERM is received, printing throughput.
    Raises RuntimeError if bpsk_dma.py is not available.
    """
    if not _HAS_DMA:
        raise RuntimeError("DMA helpers are unavailable in this RX folder")
    words = pack_for_dma(tx_out)
    _dma.dma_send(words)


# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
#  MAIN
# â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

def main():
    parser = argparse.ArgumentParser(description="BPSK Transmitter (baseband)")
    parser.add_argument("--play", action="store_true", help="Play via sounddevice")
    parser.add_argument("--plot", action="store_true", help="Show diagnostic plots")
    parser.add_argument("--seed", type=int, default=0,  help="RNG seed for data bits")
    parser.add_argument("--out",  default="tx_frame.npz", help="Output .npz path")
    parser.add_argument("--dma",  action="store_true",
                        help="Pack waveform and send via MM2S DMA (/dev/mem)")
    args = parser.parse_args()

    # Random data bits
    rng       = np.random.default_rng(seed=args.seed)
    data_bits = rng.integers(0, 2, size=P.Ndata * P.Nblocks).astype(np.uint8)

    # Run TX chain
    result = transmit(data_bits)

    # Save waveform
    save(result, path=args.out)

    # Optional: play via sounddevice
    if args.play:
        play(result["tx_pb"])

    # Optional: send via MM2S DMA
    if args.dma:
        dma_send(result["tx_pb"])

    # Optional: TX diagnostic plots
    if args.plot:
        plot_tx(result)


if __name__ == "__main__":
    main()
