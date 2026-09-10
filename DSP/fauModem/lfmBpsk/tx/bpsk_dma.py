"""
bpsk_dma.py
===========
AXI DMA helpers for PetaLinux — /dev/mem + mmap, no PYNQ.

Mirrors axi_dma_tx.c and axi_dma_rx.c:
  • Maps AXI DMA registers at AXI_DMA_BASE via /dev/mem
  • Maps TX (MM2S) buffer at MM2S_BUF_PHYS  (1 MB)
  • Maps RX (S2MM) buffer at S2MM_BUF_PHYS  (1 MB)
  • Resets channels, programs address + length, polls IOC_IRQ, W1C-clears status.

Physical addresses must match the Vivado Address Editor for your design.
"""

import mmap
import errno
import os
import signal
import struct
import time

import numpy as np

# ── Physical addresses (match Vivado Address Editor) ─────────────────────────
AXI_DMA_BASE      = 0x40400000
AXI_DMA_SIZE      = 0x10000
FRAME_LEN_GPIO_BASE = 0x41200000   # frame_len GPIO driving axis_tlast_gen.frame_len
FRAME_LEN_GPIO_SIZE = 0x10000
TLAST_RESET_GPIO_BASE = 0x41210000 # reset GPIO driving axis_tlast_gen.aresetn
TLAST_RESET_GPIO_SIZE = 0x10000
MUX_GPIO_BASE     = 0x41220000   # dma_dds_select GPIO: 0=DMA source, 1=DDS source
MUX_GPIO_SIZE     = 0x10000
# DDS Compiler programmable phase increment (NCO frequency control)
#   Phase_inc_reg_tdata  GPIO → dds_compiler_1 s_axis_config_tdata[27:0] (PINC)
#   Phase_inc_reg_tvalid GPIO → dds_compiler_1 s_axis_config_tvalid (bit 0)
DDS_PINC_GPIO_BASE   = 0x42200000   # Phase_inc_reg_tdata  GPIO
DDS_PINC_GPIO_SIZE   = 0x10000
DDS_TVALID_GPIO_BASE = 0x42210000   # Phase_inc_reg_tvalid GPIO
DDS_TVALID_GPIO_SIZE = 0x10000
DDS_CLK_HZ           = 100_000_000  # dds_compiler_1 aclk (DDS_Clock_Rate = 100 MHz)
DDS_PHASE_WIDTH      = 28           # dds_compiler_1 Phase_Width (PINC bit width)
# CIC Interpolation rate control
#   interpolator_gpio[15:0] → interpolator_config_0 RTL → cic_compiler_I/Q s_axis_config
#   The RTL block handles tready/tvalid handshaking automatically.
CIC_OUTPUT_RATE_HZ = 10_000_000   # FPGA DAC clock after CIC upsample
INTERP_GPIO_BASE   = 0x41240000   # interpolator_gpio driving interpolator_config_0 RTL
INTERP_GPIO_SIZE   = 0x10000
MM2S_BUF_PHYS     = 0x1E000000   # 16 MB reserved DDR window
S2MM_BUF_PHYS     = 0x1F000000   # 16 MB reserved DDR window
DMA_BUF_SIZE      = 16 << 20     # 16 MB each
AXI_DMA_MAX_BYTES = 1 << 26      # Vivado c_sg_length_width = 26

# ── MM2S register offsets (Xilinx PG021) ─────────────────────────────────────
_MM2S_DMACR  = 0x00
_MM2S_DMASR  = 0x04
_MM2S_SA     = 0x18
_MM2S_SA_MSB = 0x1C
_MM2S_LENGTH = 0x28

# ── S2MM register offsets ─────────────────────────────────────────────────────
_S2MM_DMACR  = 0x30
_S2MM_DMASR  = 0x34
_S2MM_DA     = 0x48
_S2MM_DA_MSB = 0x4C
_S2MM_LENGTH = 0x58

# ── Bit masks ─────────────────────────────────────────────────────────────────
_DMACR_RS    = 1 << 0
_DMACR_RESET = 1 << 2
_DMASR_ERRS  = (1 << 4) | (1 << 5) | (1 << 6)   # DMA/SLV/DEC error
_DMASR_IOC   = 1 << 12

_POLL_TIMEOUT = 30.0  # seconds; 16 MB streams take about 10.5 s at 400 kSPS
_GPIO_DATA = 0x00
_GPIO_TRI  = 0x04


# ── Register helpers ──────────────────────────────────────────────────────────

def _reg_rd(mm, off):
    mm.seek(off)
    return struct.unpack('<I', mm.read(4))[0]


def _reg_wr(mm, off, val):
    mm.seek(off)
    mm.write(struct.pack('<I', int(val) & 0xFFFFFFFF))


def _mmap_flush(mm):
    try:
        mm.flush()
    except OSError as exc:
        if exc.errno != errno.EINVAL:
            raise


def select_dma_source():
    """
    Force the input mux to use AXI DMA MM2S instead of the internal DDS source.
    The Vivado mux uses sel=0 for DMA and sel=1 for DDS.
    """
    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        gpio = mmap.mmap(fd, MUX_GPIO_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE,
                         offset=MUX_GPIO_BASE)
        try:
            _reg_wr(gpio, _GPIO_TRI, 0x0)
            _reg_wr(gpio, _GPIO_DATA, 0x0)
        finally:
            gpio.close()
    finally:
        os.close(fd)


def nco_freq_to_pinc(freq_hz: float) -> int:
    """
    Convert a desired NCO output frequency (Hz) to a DDS phase increment.

        PINC = round(freq_hz / DDS_CLK_HZ * 2**DDS_PHASE_WIDTH)

    The result is masked to DDS_PHASE_WIDTH bits, so frequencies wrap modulo
    DDS_CLK_HZ (negative frequencies are represented by their 2's-complement
    phase increment, matching the DDS Compiler convention).
    """
    pinc = int(round(freq_hz / DDS_CLK_HZ * (1 << DDS_PHASE_WIDTH)))
    return pinc & ((1 << DDS_PHASE_WIDTH) - 1)


def pinc_to_nco_freq(pinc: int) -> float:
    """Inverse of nco_freq_to_pinc — actual frequency for a programmed PINC."""
    return (pinc & ((1 << DDS_PHASE_WIDTH) - 1)) * DDS_CLK_HZ / (1 << DDS_PHASE_WIDTH)


def set_nco_frequency(freq_hz: float) -> float:
    """
    Program the DDS Compiler NCO output frequency via the phase-increment GPIOs.

    Writes the computed PINC to Phase_inc_reg_tdata, then pulses
    Phase_inc_reg_tvalid (0→1→0) so the DDS config AXI-Stream latches the new
    phase increment exactly once.

    Returns the actual programmed frequency (Hz), which differs from the
    request by at most one frequency-resolution step (DDS_CLK_HZ / 2**28).
    """
    pinc = nco_freq_to_pinc(freq_hz)
    actual = pinc_to_nco_freq(pinc)

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        pinc_gpio = mmap.mmap(fd, DDS_PINC_GPIO_SIZE, mmap.MAP_SHARED,
                              mmap.PROT_READ | mmap.PROT_WRITE,
                              offset=DDS_PINC_GPIO_BASE)
        tvalid_gpio = mmap.mmap(fd, DDS_TVALID_GPIO_SIZE, mmap.MAP_SHARED,
                                mmap.PROT_READ | mmap.PROT_WRITE,
                                offset=DDS_TVALID_GPIO_BASE)
        try:
            # Both GPIOs drive outputs only.
            _reg_wr(pinc_gpio, _GPIO_TRI, 0x0)
            _reg_wr(tvalid_gpio, _GPIO_TRI, 0x0)

            # Present the phase increment, then strobe tvalid.
            _reg_wr(tvalid_gpio, _GPIO_DATA, 0x0)
            _reg_wr(pinc_gpio, _GPIO_DATA, pinc)
            _mmap_flush(pinc_gpio)
            _mmap_flush(tvalid_gpio)

            time.sleep(0.001)
            _reg_wr(tvalid_gpio, _GPIO_DATA, 0x1)
            _mmap_flush(tvalid_gpio)
            time.sleep(0.001)
            _reg_wr(tvalid_gpio, _GPIO_DATA, 0x0)
            _mmap_flush(tvalid_gpio)
        finally:
            tvalid_gpio.close()
            pinc_gpio.close()
    finally:
        os.close(fd)

    print(f"[nco] requested {freq_hz:.3f} Hz")
    print(f"[nco] PINC       {pinc} (0x{pinc:07X}, {DDS_PHASE_WIDTH}-bit)")
    print(f"[nco] actual     {actual:.3f} Hz "
          f"(resolution {DDS_CLK_HZ / (1 << DDS_PHASE_WIDTH):.4f} Hz)")
    return actual


def set_cic_interpolation(Fs_hz: int) -> int:
    """
    Configure both CIC interpolator channels (I and Q) so their output rate
    equals CIC_OUTPUT_RATE_HZ (10 MSPS).

        interp_factor = 10_000_000 / Fs_hz   (must divide evenly, range 4–65535)

    Writes interp_factor to the interpolator_gpio at 0x41240000.  The
    interpolator_config_0 RTL block in the FPGA detects the new value,
    waits for s_axis_config_tready, and strobes tvalid automatically.
    Returns the interpolation factor written.
    """
    if CIC_OUTPUT_RATE_HZ % Fs_hz != 0:
        raise ValueError(
            f"Fs_hz={Fs_hz} does not divide {CIC_OUTPUT_RATE_HZ} evenly — "
            f"interpolation factor must be an integer")
    interp_factor = CIC_OUTPUT_RATE_HZ // Fs_hz
    if not (4 <= interp_factor <= 65535):
        raise ValueError(
            f"Interpolation factor {interp_factor} is out of the valid range [4, 65535]")

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        gpio = mmap.mmap(fd, INTERP_GPIO_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE,
                         offset=INTERP_GPIO_BASE)
        try:
            _reg_wr(gpio, _GPIO_TRI,  0x0000)          # 16-bit output
            _reg_wr(gpio, _GPIO_DATA, interp_factor & 0xFFFF)
            _mmap_flush(gpio)
            time.sleep(0.001)
        finally:
            gpio.close()
    finally:
        os.close(fd)

    print(f"[cic] requested interp_factor={interp_factor}")
    print(f"[cic] Fs={Fs_hz/1e3:.1f} kSPS → interp_factor={interp_factor} "
          f"→ output={CIC_OUTPUT_RATE_HZ/1e6:.0f} MSPS")
    print(f"[cic] settling 1.0 s before DMA start ...")
    time.sleep(1.0)
    return interp_factor


# ── MM2S (TX) channel ─────────────────────────────────────────────────────────

def configure_tlast_frame_len(frame_len_words: int):
    """
    Program the dynamic TLAST generator frame length.

    The reset GPIO is wired directly to axis_tlast_gen.aresetn, so reset is
    asserted by writing 0 and deasserted by writing 1. The RTL captures
    frame_len only while reset is asserted.
    """
    frame_len_words = int(frame_len_words)
    if frame_len_words <= 0:
        raise ValueError("frame_len_words must be > 0")

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        frame_gpio = mmap.mmap(fd, FRAME_LEN_GPIO_SIZE, mmap.MAP_SHARED,
                               mmap.PROT_READ | mmap.PROT_WRITE,
                               offset=FRAME_LEN_GPIO_BASE)
        reset_gpio = mmap.mmap(fd, TLAST_RESET_GPIO_SIZE, mmap.MAP_SHARED,
                               mmap.PROT_READ | mmap.PROT_WRITE,
                               offset=TLAST_RESET_GPIO_BASE)
        try:
            _reg_wr(frame_gpio, _GPIO_TRI, 0x0)
            _reg_wr(reset_gpio, _GPIO_TRI, 0x0)

            _reg_wr(reset_gpio, _GPIO_DATA, 0x0)
            _reg_wr(frame_gpio, _GPIO_DATA, frame_len_words)
            _mmap_flush(frame_gpio)
            _mmap_flush(reset_gpio)

            time.sleep(0.001)
            _reg_wr(reset_gpio, _GPIO_DATA, 0x1)
            _mmap_flush(reset_gpio)
            time.sleep(0.001)

            read_len = _reg_rd(frame_gpio, _GPIO_DATA)
            read_rst = _reg_rd(reset_gpio, _GPIO_DATA) & 0x1
            print(f"[tlast] frame_len GPIO : {read_len} words")
            print(f"[tlast] reset_n GPIO   : {read_rst}")
        finally:
            reset_gpio.close()
            frame_gpio.close()
    finally:
        os.close(fd)


def _mm2s_reset(regs):
    _reg_wr(regs, _MM2S_DMACR, _DMACR_RESET)
    for _ in range(1000):
        if not (_reg_rd(regs, _MM2S_DMACR) & _DMACR_RESET):
            return
        time.sleep(0.001)
    raise RuntimeError("MM2S reset timeout")


def _mm2s_start(regs, src_phys, nbytes):
    _reg_wr(regs, _MM2S_SA,     src_phys & 0xFFFFFFFF)
    _reg_wr(regs, _MM2S_SA_MSB, src_phys >> 32)
    _reg_wr(regs, _MM2S_DMACR,  _DMACR_RS)
    _reg_wr(regs, _MM2S_LENGTH, nbytes)


def _mm2s_poll_done(regs):
    t0 = time.time()
    while time.time() - t0 < _POLL_TIMEOUT:
        sr = _reg_rd(regs, _MM2S_DMASR)
        if sr & _DMASR_ERRS:
            raise RuntimeError(f"MM2S DMA error — DMASR=0x{sr:08X}")
        if sr & _DMASR_IOC:
            _reg_wr(regs, _MM2S_DMASR, sr)   # W1C — clear IOC bit
            return
        time.sleep(10e-6)
    raise RuntimeError(
        f"MM2S poll timeout — DMASR=0x{_reg_rd(regs, _MM2S_DMASR):08X}")


# ── S2MM (RX) channel ─────────────────────────────────────────────────────────

def _s2mm_reset(regs):
    _reg_wr(regs, _S2MM_DMACR, _DMACR_RESET)
    for _ in range(1000):
        if not (_reg_rd(regs, _S2MM_DMACR) & _DMACR_RESET):
            return
        time.sleep(0.001)
    raise RuntimeError("S2MM reset timeout")


def _s2mm_start(regs, dst_phys, nbytes):
    _reg_wr(regs, _S2MM_DA,     dst_phys & 0xFFFFFFFF)
    _reg_wr(regs, _S2MM_DA_MSB, dst_phys >> 32)
    _reg_wr(regs, _S2MM_DMACR,  _DMACR_RS)
    _reg_wr(regs, _S2MM_LENGTH, nbytes)


def _s2mm_poll_done(regs):
    t0 = time.time()
    while time.time() - t0 < _POLL_TIMEOUT:
        sr = _reg_rd(regs, _S2MM_DMASR)
        if sr & _DMASR_ERRS:
            raise RuntimeError(f"S2MM DMA error — DMASR=0x{sr:08X}")
        if sr & _DMASR_IOC:
            _reg_wr(regs, _S2MM_DMASR, sr)   # W1C
            return
        time.sleep(10e-6)
    raise RuntimeError(
        f"S2MM poll timeout — DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X}")


# ── Q15 pack / unpack ─────────────────────────────────────────────────────────

def pack_q15(real_samples: np.ndarray,
             imag_samples: np.ndarray) -> np.ndarray:
    """
    Pack real + imaginary float64 [-1,1] into uint32 Q15 words.
      Bits [15: 0]  → real  (signed Q15)
      Bits [31:16]  → imag  (signed Q15)
    """
    def _cvt(x):
        return (np.clip(np.round(x * 32767.0), -32768, 32767)
                .astype(np.int16).view(np.uint16).astype(np.uint32))
    return _cvt(real_samples) | (_cvt(imag_samples) << 16)


def unpack_q15(words: np.ndarray):
    """
    Unpack uint32 Q15 words → (rx_real, rx_imag) as float64 arrays.
    """
    re = (words        & 0xFFFF).astype(np.int16).astype(np.float64) / 32767.0
    im = ((words >> 16) & 0xFFFF).astype(np.int16).astype(np.float64) / 32767.0
    return re, im


def unpack_int32(words: np.ndarray) -> np.ndarray:
    """
    Unpack uint32 DMA words as signed int32 → float64.
    Used when the FIR/ADC output occupies the full 32-bit word.
    """
    return words.view(np.int32).astype(np.float64)


# ── Public API ────────────────────────────────────────────────────────────────

def dma_send(words: np.ndarray):
    """
    Write packed uint32 words into the MM2S buffer and transmit continuously
    in a loop until Ctrl+C (SIGINT) or SIGTERM.

    The buffer is written once; only the DMA transfer is repeated each iteration.

    Parameters
    ----------
    words : uint32 ndarray  (must fit in DMA_BUF_SIZE = 16 MB)
    """
    nbytes = len(words) * 4
    if nbytes > DMA_BUF_SIZE:
        raise ValueError(
            f"Payload {nbytes} B exceeds DMA TX buffer {DMA_BUF_SIZE} B")

    # Signal handler — set flag to exit loop cleanly (mirrors C sig_handler)
    running = [True]
    def _stop(sig, frame): running[0] = False
    signal.signal(signal.SIGINT,  _stop)
    signal.signal(signal.SIGTERM, _stop)

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        regs   = mmap.mmap(fd, AXI_DMA_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=AXI_DMA_BASE)
        tx_buf = mmap.mmap(fd, DMA_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=MM2S_BUF_PHYS)
        try:
            # Write payload once — it stays in the buffer for every iteration
            tx_buf.seek(0)
            tx_buf.write(words.astype(np.uint32).tobytes())
            _mmap_flush(tx_buf)

            _mm2s_reset(regs)
            print(f"[dma] MM2S reset OK  (DMASR=0x{_reg_rd(regs, _MM2S_DMASR):08X})")
            print(f"[dma] TX buf phys    0x{MM2S_BUF_PHYS:08X}")
            print(f"[dma] Transfer size  {len(words)} words ({nbytes/1024:.1f} kB)")
            print(f"[dma] Transmitting non-stop — press Ctrl+C to stop")

            loop_count  = 0
            total_bytes = 0
            t_start     = time.time()

            while running[0]:
                _mm2s_start(regs, MM2S_BUF_PHYS, nbytes)
                _mm2s_poll_done(regs)

                loop_count  += 1
                total_bytes += nbytes

                if loop_count % 100 == 0:
                    elapsed = time.time() - t_start
                    mbps = total_bytes / elapsed / 1e6 if elapsed > 0 else 0.0
                    print(f"[dma] iter={loop_count:<8}  "
                          f"total={total_bytes/1e6:.1f} MB  "
                          f"{mbps:.2f} MB/s")

        finally:
            tx_buf.close()
            regs.close()
    finally:
        os.close(fd)

    elapsed = time.time() - t_start
    mbps = total_bytes / elapsed / 1e6 if elapsed > 0 else 0.0
    print(f"\n[dma] Stopped: {loop_count} iterations, "
          f"{total_bytes/1e6:.2f} MB total, {mbps:.2f} MB/s avg")


def dma_loopback(words: np.ndarray) -> np.ndarray:
    """
    Single-shot internal loopback: write words to the MM2S buffer, arm S2MM,
    start MM2S, poll both channels for completion, return received words.

    S2MM is armed before MM2S so no samples are dropped at the head.

    Parameters
    ----------
    words : uint32 ndarray  (must fit in DMA_BUF_SIZE = 16 MB)

    Returns
    -------
    rx_words : uint32 ndarray, same length as words
    """
    nbytes = len(words) * 4
    if nbytes > DMA_BUF_SIZE:
        raise ValueError(
            f"Payload {nbytes} B exceeds DMA buffer {DMA_BUF_SIZE} B")

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        regs   = mmap.mmap(fd, AXI_DMA_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=AXI_DMA_BASE)
        tx_buf = mmap.mmap(fd, DMA_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=MM2S_BUF_PHYS)
        rx_buf = mmap.mmap(fd, DMA_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=S2MM_BUF_PHYS)
        try:
            tx_buf.seek(0)
            tx_buf.write(words.astype(np.uint32).tobytes())
            _mmap_flush(tx_buf)

            # Poison RX buffer so stale data is detectable
            rx_buf.seek(0)
            rx_buf.write(b'\xAA' * nbytes)
            _mmap_flush(rx_buf)

            _mm2s_reset(regs)
            _s2mm_reset(regs)
            print(f"[dma] MM2S reset OK  (DMASR=0x{_reg_rd(regs, _MM2S_DMASR):08X})")
            print(f"[dma] S2MM reset OK  (DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X})")
            print(f"[dma] Loopback: {len(words)} words ({nbytes/1024:.1f} kB)")

            # Arm receiver before transmitter so no head samples are lost
            _s2mm_start(regs, S2MM_BUF_PHYS, nbytes)
            _mm2s_start(regs, MM2S_BUF_PHYS, nbytes)

            _mm2s_poll_done(regs)
            print("[dma] MM2S done")
            _s2mm_poll_done(regs)
            print("[dma] S2MM done")

            rx_buf.seek(0)
            return np.frombuffer(rx_buf.read(nbytes), dtype=np.uint32).copy()

        finally:
            rx_buf.close()
            tx_buf.close()
            regs.close()
    finally:
        os.close(fd)


def dma_recv(n_words: int) -> np.ndarray:
    """
    Arm the S2MM channel and receive n_words uint32 words from hardware.
    Handles multiple transfers automatically when n_words × 4 > AXI_DMA_MAX_BYTES.

    Returns
    -------
    words : uint32 ndarray, length n_words
    """
    max_words = min(DMA_BUF_SIZE, AXI_DMA_MAX_BYTES) // 4

    fd = os.open('/dev/mem', os.O_RDWR | os.O_SYNC)
    try:
        regs   = mmap.mmap(fd, AXI_DMA_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=AXI_DMA_BASE)
        rx_buf = mmap.mmap(fd, DMA_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=S2MM_BUF_PHYS)
        try:
            _s2mm_reset(regs)
            print(f"[dma] S2MM reset OK  (DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X})")
            print(f"[dma] S2MM expecting {n_words} words …")

            all_words = []
            remaining = n_words
            xfer_idx  = 0

            while remaining > 0:
                this_words = min(remaining, max_words)
                this_bytes = this_words * 4

                # Poison buffer to detect stale data (matches C reference)
                rx_buf.seek(0)
                rx_buf.write(b'\xAA' * this_bytes)
                _mmap_flush(rx_buf)

                print(f"[dma] Xfer #{xfer_idx}: arming S2MM for "
                      f"{this_words} words ({this_bytes/1024:.1f} kB)")
                _s2mm_start(regs, S2MM_BUF_PHYS, this_bytes)
                _s2mm_poll_done(regs)

                rx_buf.seek(0)
                chunk = np.frombuffer(rx_buf.read(this_bytes),
                                      dtype=np.uint32).copy()
                all_words.append(chunk)

                remaining -= this_words
                xfer_idx  += 1
                print(f"[dma] Received {this_words} words "
                      f"(total {n_words - remaining}/{n_words})")

            return np.concatenate(all_words)
        finally:
            rx_buf.close()
            regs.close()
    finally:
        os.close(fd)
