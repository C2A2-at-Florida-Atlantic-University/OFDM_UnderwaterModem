"""
RX-only AXI DMA scatter-gather helper for the external-loopback RX board.

This module only touches the S2MM channel. ALL DMA memory - buffers AND the
descriptor ring - lives inside the device-tree reserved window
0x1F000000-0x1FFFFFFF (16 MiB; the only region actually carved out of kernel
RAM on this board). The ring must NOT sit outside it: it formerly lived at
0x1D010000, which is unreserved, so the kernel cached pages (e.g. libc) there
and the descriptor writes overwrote them -> board-wide segfaults.

  S2MM buffers : 0x1F000000, 15 MiB   (bottom of the reserved window)
  S2MM BD ring : 0x1FF00000, 64 KiB   (top 1 MiB of the reserved window)

The DMA is programmed once in cyclic SG mode. Completed S2MM buffers are
appended to a raw uint32 file while the DMA continues around the ring.
"""

import mmap
import os
import struct
import time

import numpy as np


AXI_DMA_BASE = 0x40400000
AXI_DMA_SIZE = 0x10000

FRAME_LEN_GPIO_BASE = 0x41200000
FRAME_LEN_GPIO_SIZE = 0x10000
TLAST_RESET_GPIO_BASE = 0x41210000
TLAST_RESET_GPIO_SIZE = 0x10000

# DDS Compiler programmable phase increment (NCO frequency control).
#   Phase_inc_reg_tdata  GPIO -> dds_compiler s_axis_config_tdata[27:0] (PINC)
#   Phase_inc_reg_tvalid GPIO -> dds_compiler s_axis_config_tvalid (bit 0)
# Addresses/clock/phase-width match the TX side (see scripts/tx/bpsk_dma.py).
DDS_PINC_GPIO_BASE = 0x42200000
DDS_PINC_GPIO_SIZE = 0x10000
DDS_TVALID_GPIO_BASE = 0x42210000
DDS_TVALID_GPIO_SIZE = 0x10000
DDS_CLK_HZ = 100_000_000        # DDS aclk (DDS_Clock_Rate = 100 MHz)
DDS_PHASE_WIDTH = 28            # DDS Phase_Width (PINC bit width)

# CIC Decimation rate control
#   decimation_gpio[15:0] → decimator_config_0 RTL → cic_compiler_adc_I/Q s_axis_config
#   The RTL block handles tready/tvalid handshaking automatically.
CIC_INPUT_RATE_HZ = 10_000_000   # ADC sample rate into the CIC
DECIM_GPIO_BASE   = 0x41240000   # decimation_gpio driving decimator_config_0 RTL
DECIM_GPIO_SIZE   = 0x10000

# Keep BOTH the buffers and the descriptor ring inside the reserved 16 MiB
# window (0x1F000000-0x1FFFFFFF). The ring formerly sat at 0x1D010000, which is
# NOT reserved on this board, so the kernel cached pages (e.g. libc) there and
# the SG engine / descriptor writes overwrote them -> board-wide segfaults.
# Layout: buffers fill the bottom 15 MiB, the 64 KiB ring sits in the top 1 MiB.
#   buffers : 0x1F000000 .. 0x1FEFFFFF   (15 MiB cap; 6 x 2 MiB uses 12 MiB)
#   ring    : 0x1FF00000 .. 0x1FF0FFFF   (64 KiB)
# NOTE: the bitstream's SG (M_AXI_SG) fence MUST reach 0x1FF00000 - fence SG to
# 0x1F000000/16M (same window as S2MM) or run unfenced; an SG fence of
# 0x1D000000/16M will DMADecErr on the relocated ring.
S2MM_BUF_PHYS = 0x1F000000
S2MM_BD_PHYS = 0x1FF00000                      # ring in top 1 MiB of reserved window
BD_RING_SIZE = 0x10000                         # 64 KiB
S2MM_BUF_SIZE = S2MM_BD_PHYS - S2MM_BUF_PHYS    # 0xF00000 (15 MiB): buffers end where the ring begins

_GPIO_DATA = 0x00
_GPIO_TRI = 0x04

_S2MM_DMACR = 0x30
_S2MM_DMASR = 0x34
_S2MM_CURDESC = 0x38
_S2MM_CURDESC_MSB = 0x3C
_S2MM_TAILDESC = 0x40
_S2MM_TAILDESC_MSB = 0x44

_DMACR_RS = 1 << 0
_DMACR_CYCLIC_BD = 1 << 4
# DMASR error bits. Bits 4-6 are the data-path errors (DMAIntErr/DMASlvErr/
# DMADecErr); bits 8-10 are the scatter-gather descriptor-fetch errors
# (SGIntErr/SGSlvErr/SGDecErr). The SG bits MUST be in the mask: the faults
# observed on this board are SGSlvErr (bit 9) / SGDecErr (bit 10). Without
# them the poll loop never sees the error and just spins to the 20 s
# poll_timeout; with them, the fault is caught on the next poll (~1 ms) so we
# can dump the engine state at the actual fault instant (see _dump_s2mm_fault).
_DMASR_DATA_ERRS = (1 << 4) | (1 << 5) | (1 << 6)
_DMASR_SG_ERRS = (1 << 8) | (1 << 9) | (1 << 10)
_DMASR_ERRS = _DMASR_DATA_ERRS | _DMASR_SG_ERRS
_DMASR_HALTED = 1 << 0   # DMASR bit 0: engine halted (Run/Stop cleared + drained)

# (bit, name) for decoding DMASR in fault dumps - most-informative bits only.
_DMASR_BIT_NAMES = [
    (0, "Halted"), (1, "Idle"), (3, "SGIncld"),
    (4, "DMAIntErr"), (5, "DMASlvErr"), (6, "DMADecErr"),
    (8, "SGIntErr"), (9, "SGSlvErr"), (10, "SGDecErr"),
    (12, "IOC_Irq"), (13, "Dly_Irq"), (14, "Err_Irq"),
]

# Zynq PS System Level Control Registers (SLCR) - used to hard-reset the
# FPGA fabric's peripheral reset domain (see _ps_fabric_reset() below) rather
# than relying on the AXI DMA's own DMACR soft-reset bit.
_SLCR_BASE = 0xF8000000
_SLCR_SIZE = 0x1000
_SLCR_UNLOCK = 0x8
_SLCR_LOCK = 0x4
_SLCR_FPGA_RST_CTRL = 0x240
_SLCR_UNLOCK_KEY = 0xDF0D
_SLCR_LOCK_KEY = 0x767B
_FPGA_RST0_BIT = 1 << 0   # drives FCLK_RESET0_N (see SDUAM.bd)

_BD_BYTES = 0x40
_BD_NXTDESC = 0x00
_BD_NXTDESC_MSB = 0x04
_BD_BUFADDR = 0x08
_BD_BUFADDR_MSB = 0x0C
_BD_CONTROL = 0x18
_BD_STATUS = 0x1C

_BD_LEN_MASK = (1 << 26) - 1
_BD_STS_COMPLETE = 1 << 31
_BD_STS_RXEOF = 1 << 26
_BD_STS_RXSOF = 1 << 27


def _reg_rd(mm, off):
    mm.seek(off)
    return struct.unpack("<I", mm.read(4))[0]


def _reg_wr(mm, off, val):
    mm.seek(off)
    mm.write(struct.pack("<I", int(val) & 0xFFFFFFFF))


def _flush(mm):
    try:
        mm.flush()
    except OSError:
        pass


def nco_freq_to_pinc(freq_hz: float) -> int:
    """Convert a desired NCO output frequency (Hz) to a DDS phase increment.

        PINC = round(freq_hz / DDS_CLK_HZ * 2**DDS_PHASE_WIDTH)

    Masked to DDS_PHASE_WIDTH bits, so frequencies wrap modulo DDS_CLK_HZ.
    """
    pinc = int(round(freq_hz / DDS_CLK_HZ * (1 << DDS_PHASE_WIDTH)))
    return pinc & ((1 << DDS_PHASE_WIDTH) - 1)


def pinc_to_nco_freq(pinc: int) -> float:
    """Inverse of nco_freq_to_pinc — actual frequency for a programmed PINC."""
    return (pinc & ((1 << DDS_PHASE_WIDTH) - 1)) * DDS_CLK_HZ / (1 << DDS_PHASE_WIDTH)


def set_nco_frequency(freq_hz: float) -> float:
    """Program the DDS Compiler NCO output frequency via the phase-increment GPIOs.

    Writes the computed PINC to Phase_inc_reg_tdata, then pulses
    Phase_inc_reg_tvalid (0->1->0) so the DDS config AXI-Stream latches the new
    phase increment exactly once. Returns the actual programmed frequency (Hz).
    """
    pinc = nco_freq_to_pinc(freq_hz)
    actual = pinc_to_nco_freq(pinc)

    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
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
            _flush(pinc_gpio)
            _flush(tvalid_gpio)

            time.sleep(0.001)
            _reg_wr(tvalid_gpio, _GPIO_DATA, 0x1)
            _flush(tvalid_gpio)
            time.sleep(0.001)
            _reg_wr(tvalid_gpio, _GPIO_DATA, 0x0)
            _flush(tvalid_gpio)
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


def configure_cic_decimation(Fs_hz: int) -> int:
    """
    Configure both CIC decimator channels so their output rate equals Fs_hz.

        decim_factor = CIC_INPUT_RATE_HZ / Fs_hz   (must divide evenly, range 4–65535)

    Writes decim_factor to the decimation_gpio at 0x41240000.  The
    decimator_config_0 RTL block in the FPGA detects the new value,
    waits for s_axis_config_tready, and strobes tvalid automatically.
    Call this BEFORE starting DMA. Returns the decimation factor.
    """
    if CIC_INPUT_RATE_HZ % Fs_hz != 0:
        raise ValueError(
            f"Fs_hz={Fs_hz} does not divide {CIC_INPUT_RATE_HZ} evenly — "
            f"decimation factor must be an integer")
    decim_factor = CIC_INPUT_RATE_HZ // Fs_hz
    if not (4 <= decim_factor <= 65535):
        raise ValueError(
            f"Decimation factor {decim_factor} is out of the valid range [4, 65535]")

    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
    try:
        gpio = mmap.mmap(fd, DECIM_GPIO_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE,
                         offset=DECIM_GPIO_BASE)
        try:
            _reg_wr(gpio, _GPIO_TRI,  0x0000)          # 16-bit output
            _reg_wr(gpio, _GPIO_DATA, decim_factor & 0xFFFF)
            _flush(gpio)
            time.sleep(0.001)
        finally:
            gpio.close()
    finally:
        os.close(fd)

    print(f"[cic] requested decim_factor={decim_factor}")
    print(f"[cic] Fs={Fs_hz/1e3:.1f} kSPS → decim_factor={decim_factor} "
          f"→ input={CIC_INPUT_RATE_HZ/1e6:.0f} MSPS")
    print(f"[cic] settling 1.0 s before ADC enable ...")
    time.sleep(1.0)
    return decim_factor


def pack_q15(real_samples: np.ndarray, imag_samples: np.ndarray) -> np.ndarray:
    def _cvt(x):
        return (np.clip(np.round(x * 32767.0), -32768, 32767)
                .astype(np.int16).view(np.uint16).astype(np.uint32))

    return _cvt(real_samples) | (_cvt(imag_samples) << 16)


def unpack_q15(words: np.ndarray):
    re = (words & 0xFFFF).astype(np.int16).astype(np.float64) / 32767.0
    im = ((words >> 16) & 0xFFFF).astype(np.int16).astype(np.float64) / 32767.0
    return re, im


def unpack_int32(words: np.ndarray) -> np.ndarray:
    return words.view(np.int32).astype(np.float64)


def configure_tlast_frame_len(frame_len_words: int):
    frame_len_words = int(frame_len_words)
    if frame_len_words <= 0:
        raise ValueError("frame_len_words must be > 0")

    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
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
            _flush(frame_gpio)
            _flush(reset_gpio)
            time.sleep(0.001)
            _reg_wr(reset_gpio, _GPIO_DATA, 0x1)
            _flush(reset_gpio)
            time.sleep(0.001)
            print(f"[tlast] frame_len GPIO : {_reg_rd(frame_gpio, _GPIO_DATA)} words")
            print(f"[tlast] reset_n GPIO   : {_reg_rd(reset_gpio, _GPIO_DATA) & 1}")
        finally:
            reset_gpio.close()
            frame_gpio.close()
    finally:
        os.close(fd)


def _s2mm_stop(regs, timeout: float = 1.0) -> bool:
    """Cleanly halt the S2MM channel BEFORE any reset, so no AXI transaction
    is left orphaned on the PS HP port at teardown.

    The capture runs in cyclic mode, so the engine never stops on its own -
    at the end of a capture it is almost always mid-burst writing ADC data to
    DDR over HP0. Previously teardown just asserted a reset on top of that
    in-flight burst, severing the transaction; because FCLK_RESET0_N resets
    only the PL (the DMA master) and not the PS-side HP/AFI port, that orphaned
    transaction stayed counted against the port. One leaked per rep, and after
    ~30 reps the port's outstanding-transaction tracking saturated and started
    rejecting the SG engine's own descriptor fetches (SGSlvErr/SGDecErr) in
    escalating bursts - clearable only by a full power cycle (which resets the
    PS AFI). See the investigation notes / commit message.

    Clearing the Run/Stop bit tells the engine to finish its current transfer
    and halt; DMASR.Halted (bit 0) then reads 1. Meanwhile the ADC stream is
    held off cleanly by tready backpressure on the datapath (verified in
    axis_iq_concat_tlast). Only once Halted is observed (in-flight burst
    drained) is it safe to reset. Returns True if it halted within `timeout`,
    False otherwise (caller still proceeds to reset, but logs it)."""
    dmacr = _reg_rd(regs, _S2MM_DMACR)
    _reg_wr(regs, _S2MM_DMACR, dmacr & ~_DMACR_RS)   # clear Run/Stop -> halt request
    deadline = time.time() + timeout
    while time.time() < deadline:
        if _reg_rd(regs, _S2MM_DMASR) & _DMASR_HALTED:
            return True
        time.sleep(0.001)
    return False


def _ps_fabric_reset(hold_seconds: float = 0.02, settle_seconds: float = 0.1):
    """Hard-reset the FPGA fabric's peripheral reset domain via the Zynq PS
    SLCR FPGA_RST_CTRL register (asserts/de-asserts FCLK_RESET0_N), instead
    of the AXI DMA's own DMACR soft-reset bit.

    Per SDUAM.bd, axi_dma_0/axi_resetn is wired to rst_ps7_0_100M's
    peripheral_aresetn output, and that IP's ext_reset_in comes from
    processing_system7_0/FCLK_RESET0_N - a signal the DMA's own AXI-Lite
    DMACR soft-reset bit never touches. When the S2MM SG engine wedges hard
    enough that the soft reset can't clear it (observed as a lingering
    SGDecErr/SGSlvErr that no longer even completes register polls), toggling
    FCLK_RESET0_N here is the only way to actually clear axi_dma_0/axi_resetn
    short of a full power cycle.

    This same net also reaches axi_gpio_ADCstatus, axi_mem_intercon,
    ps7_0_axi_periph, LTC2171_to_AXIS_M_0, frame_len, tlast_gen_reset,
    adc_iq_mixer_0, Phase_inc_reg_tvalid/tdata, and decimation_gpio - i.e.
    this resets ALL of those, not just the DMA. Callers MUST reprogram the
    NCO frequency, CIC decimation, and tlast frame length after calling this
    (see program_s2mm_capture(), which does so every time it runs).

    settle_seconds is an ADDITIONAL wait after de-asserting the reset (on
    top of hold_seconds), before this function returns control to the
    caller. clk_wiz_0 is reset by this same net (see SDUAM.bd) and needs
    time to re-lock before it's safe to issue more AXI transactions to
    anything clocked from it; a hang observed immediately after this reset
    completed - with no error ever raised, just silence - is consistent
    with too short a gap here rather than a genuine DMA fault.
    """
    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
    try:
        slcr = mmap.mmap(fd, _SLCR_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE, offset=_SLCR_BASE)
        try:
            _reg_wr(slcr, _SLCR_UNLOCK, _SLCR_UNLOCK_KEY)
            ctrl = _reg_rd(slcr, _SLCR_FPGA_RST_CTRL)
            _reg_wr(slcr, _SLCR_FPGA_RST_CTRL, ctrl | _FPGA_RST0_BIT)   # assert
            time.sleep(hold_seconds)
            ctrl = _reg_rd(slcr, _SLCR_FPGA_RST_CTRL)
            _reg_wr(slcr, _SLCR_FPGA_RST_CTRL, ctrl & ~_FPGA_RST0_BIT)  # de-assert
            _reg_wr(slcr, _SLCR_LOCK, _SLCR_LOCK_KEY)
        finally:
            slcr.close()
    finally:
        os.close(fd)
    time.sleep(settle_seconds)   # let clk_wiz_0 (and the rest of this reset
                                 # domain) fully re-lock before returning


def _bd_off(index):
    return int(index) * _BD_BYTES


def _write_bd(bd_mem, index, next_phys, buf_phys, nbytes):
    if nbytes <= 0:
        raise ValueError("BD length must be > 0")
    if nbytes > _BD_LEN_MASK:
        raise ValueError(f"BD length {nbytes} exceeds {_BD_LEN_MASK} bytes")

    off = _bd_off(index)
    bd_mem.seek(off)
    bd_mem.write(b"\x00" * _BD_BYTES)
    _reg_wr(bd_mem, off + _BD_NXTDESC, next_phys & 0xFFFFFFFF)
    _reg_wr(bd_mem, off + _BD_NXTDESC_MSB, next_phys >> 32)
    _reg_wr(bd_mem, off + _BD_BUFADDR, buf_phys & 0xFFFFFFFF)
    _reg_wr(bd_mem, off + _BD_BUFADDR_MSB, buf_phys >> 32)
    _reg_wr(bd_mem, off + _BD_CONTROL, int(nbytes))
    _reg_wr(bd_mem, off + _BD_STATUS, 0)


def _write_s2mm_ring(bd_mem, buffer_nbytes, n_buffers):
    if n_buffers <= 0:
        raise ValueError("n_buffers must be > 0")
    if n_buffers + 1 > BD_RING_SIZE // _BD_BYTES:
        raise ValueError("S2MM BD ring is too small")
    if buffer_nbytes * n_buffers > S2MM_BUF_SIZE:
        raise ValueError(
            f"S2MM buffers need {buffer_nbytes * n_buffers} B, "
            f"but reserved RX window is {S2MM_BUF_SIZE} B")

    for i in range(n_buffers):
        next_phys = S2MM_BD_PHYS + ((i + 1) % n_buffers) * _BD_BYTES
        _write_bd(
            bd_mem,
            i,
            next_phys=next_phys,
            buf_phys=S2MM_BUF_PHYS + i * buffer_nbytes,
            nbytes=buffer_nbytes,
        )

    tail_sentinel = S2MM_BD_PHYS + n_buffers * _BD_BYTES
    _flush(bd_mem)
    return tail_sentinel


def _bd_control_status(bd_mem, index):
    off = _bd_off(index)
    return (_reg_rd(bd_mem, off + _BD_CONTROL),
            _reg_rd(bd_mem, off + _BD_STATUS))


def _clear_bd_status(bd_mem, index):
    _reg_wr(bd_mem, _bd_off(index) + _BD_STATUS, 0)
    _flush(bd_mem)


def _dump_s2mm(regs, bd_mem, n_buffers):
    first_ctrl, first_sts = _bd_control_status(bd_mem, 0)
    last_ctrl, last_sts = _bd_control_status(bd_mem, n_buffers - 1)
    print(f"[s2mm] DMACR          0x{_reg_rd(regs, _S2MM_DMACR):08X}")
    print(f"[s2mm] DMASR          0x{_reg_rd(regs, _S2MM_DMASR):08X}")
    print(f"[s2mm] CURDESC        0x{_reg_rd(regs, _S2MM_CURDESC):08X}")
    print(f"[s2mm] TAILDESC       0x{_reg_rd(regs, _S2MM_TAILDESC):08X}")
    print(f"[s2mm] BD[0] ctrl/sts 0x{first_ctrl:08X} / 0x{first_sts:08X}")
    print(f"[s2mm] BD[{n_buffers - 1}] ctrl/sts 0x{last_ctrl:08X} / 0x{last_sts:08X}")


def _decode_dmasr(sr):
    """Human-readable list of the DMASR bits that are set."""
    names = [name for bit, name in _DMASR_BIT_NAMES if sr & (1 << bit)]
    return " ".join(names) if names else "(none)"


def _dump_s2mm_fault(regs, bd_mem, n_buffers, bd_idx, reason):
    """Dump the full S2MM/SG engine state at the instant a fault is detected,
    to pin down the SGDecErr/SGSlvErr root cause. The engine is halted here,
    so the state is frozen and safe to read. Two questions this answers:

      1. Where is CURDESC actually pointing? SGDecErr means the SG engine
         fetched a descriptor from an address that decodes to nothing. If
         CURDESC is OUTSIDE the ring / misaligned, the engine's next-descriptor
         pointer got corrupted and we can see the bad value. If CURDESC is a
         valid ring slot, the pointer is fine and the DECERR is on the bus /
         interconnect side, not a corrupted descriptor.
      2. Are the ring's own NXTDESC / BUFADDR fields still intact? Every slot
         is checked against the reserved BD-ring and buffer windows; BAD_NXT /
         BAD_BUF flags mark any that drifted out of range.
    """
    ring_lo = S2MM_BD_PHYS
    ring_hi = S2MM_BD_PHYS + n_buffers * _BD_BYTES        # one past last slot
    buf_lo = S2MM_BUF_PHYS
    buf_hi = S2MM_BUF_PHYS + S2MM_BUF_SIZE

    dmacr = _reg_rd(regs, _S2MM_DMACR)
    dmasr = _reg_rd(regs, _S2MM_DMASR)
    curdesc = _reg_rd(regs, _S2MM_CURDESC)
    curdesc_msb = _reg_rd(regs, _S2MM_CURDESC_MSB)
    taildesc = _reg_rd(regs, _S2MM_TAILDESC)
    taildesc_msb = _reg_rd(regs, _S2MM_TAILDESC_MSB)

    print("=" * 68)
    print(f"[fault] S2MM/SG engine state dump - {reason}")
    print(f"[fault] software was polling bd_idx={bd_idx}")
    print(f"[fault] DMACR    = 0x{dmacr:08X}")
    print(f"[fault] DMASR    = 0x{dmasr:08X}  [{_decode_dmasr(dmasr)}]")
    print(f"[fault] CURDESC  = 0x{curdesc_msb:08X}_{curdesc:08X}")
    print(f"[fault] TAILDESC = 0x{taildesc_msb:08X}_{taildesc:08X}")
    print(f"[fault] ring     = 0x{ring_lo:08X}..0x{ring_hi:08X} "
          f"({n_buffers} slots x 0x{_BD_BYTES:X} B)")
    cur_in_ring = (curdesc_msb == 0 and ring_lo <= curdesc < ring_hi
                   and (curdesc - ring_lo) % _BD_BYTES == 0)
    print(f"[fault] CURDESC valid ring slot   : {cur_in_ring}"
          f"{'' if cur_in_ring else '   <-- OUT OF RING / MISALIGNED = bad fetch addr'}")
    print("-" * 68)
    for i in range(n_buffers):
        off = _bd_off(i)
        nxt = _reg_rd(bd_mem, off + _BD_NXTDESC)
        nxt_msb = _reg_rd(bd_mem, off + _BD_NXTDESC_MSB)
        buf = _reg_rd(bd_mem, off + _BD_BUFADDR)
        buf_msb = _reg_rd(bd_mem, off + _BD_BUFADDR_MSB)
        ctrl = _reg_rd(bd_mem, off + _BD_CONTROL)
        sts = _reg_rd(bd_mem, off + _BD_STATUS)
        addr = ring_lo + off
        nxt_ok = (nxt_msb == 0 and ring_lo <= nxt < ring_hi
                  and (nxt - ring_lo) % _BD_BYTES == 0)
        buf_ok = (buf_msb == 0 and buf_lo <= buf < buf_hi)
        flags = []
        if curdesc == addr and curdesc_msb == 0:
            flags.append("<==CURDESC")
        if not nxt_ok:
            flags.append("BAD_NXT")
        if not buf_ok:
            flags.append("BAD_BUF")
        marker = ("   " + " ".join(flags)) if flags else ""
        print(f"[fault] BD[{i}] @0x{addr:08X} "
              f"NXT=0x{nxt_msb:08X}_{nxt:08X} "
              f"BUF=0x{buf_msb:08X}_{buf:08X} "
              f"CTRL=0x{ctrl:08X} STS=0x{sts:08X}{marker}")
    print("=" * 68)


# ---------------------------------------------------------------------------
# Ring-integrity watchdog
# ---------------------------------------------------------------------------
# The DMA must never change a descriptor's NXTDESC/BUFADDR/CONTROL - only its
# STATUS. So we snapshot the exact values the code programs, then re-read the
# ring frequently during the capture and report the FIRST field that diverges,
# with when (baseline vs mid-capture vs at a BD boundary) and whether the new
# value looks like IQ sample data (data path wrote it) or an address (pointer
# cascade). This localizes the corruption instead of only seeing the aftermath.

_RING_FIELDS = (
    ("NXT", _BD_NXTDESC), ("NXT_MSB", _BD_NXTDESC_MSB),
    ("BUF", _BD_BUFADDR), ("BUF_MSB", _BD_BUFADDR_MSB),
    ("CTRL", _BD_CONTROL),
)


def _expected_ring(rx_buffer_nbytes, n_buffers):
    """The exact NXTDESC/BUFADDR/CONTROL values _write_s2mm_ring() programs."""
    exp = {}
    for i in range(n_buffers):
        nxt = S2MM_BD_PHYS + ((i + 1) % n_buffers) * _BD_BYTES
        buf = S2MM_BUF_PHYS + i * rx_buffer_nbytes
        exp[i] = {
            "NXT": nxt & 0xFFFFFFFF, "NXT_MSB": nxt >> 32,
            "BUF": buf & 0xFFFFFFFF, "BUF_MSB": buf >> 32,
            "CTRL": int(rx_buffer_nbytes),
        }
    return exp


def _verify_ring(bd_mem, exp, n_buffers):
    """Return [(index, field, expected, actual), ...] for every ring field that
    no longer matches what was programmed. Empty = ring still intact."""
    bad = []
    for i in range(n_buffers):
        off = _bd_off(i)
        for name, foff in _RING_FIELDS:
            actual = _reg_rd(bd_mem, off + foff)
            if actual != exp[i][name]:
                bad.append((i, name, exp[i][name], actual))
    return bad


def _looks_like_iq(val):
    """True if a 32-bit word looks like packed Q15 I/Q (both 16-bit halves are
    small-magnitude as signed int16) rather than a DDR address."""
    def small(h):
        return h < 0x0800 or h > 0xF800   # near zero as signed int16
    return small((val >> 16) & 0xFFFF) and small(val & 0xFFFF)


def _report_ring_corruption(bad, completed_bds, bd_idx, where):
    print("!" * 68)
    print(f"[corrupt] descriptor ring diverged from programmed values - {where}")
    print(f"[corrupt]   after {completed_bds} BD completions, polling bd_idx={bd_idx}")
    for (i, name, e, a) in bad:
        hint = ("IQ sample data" if _looks_like_iq(a) else "address/value")
        print(f"[corrupt]   BD[{i}].{name}: programmed 0x{e:08X} -> now "
              f"0x{a:08X}  (looks like {hint})")
    print("!" * 68)


def program_s2mm_capture(raw_out: str, rx_buffer_words: int,
                         n_rx_buffers: int = 6, passes: int = 2,
                         poll_timeout: float = 20.0,
                         stop_dma: bool = True,
                         decim_fs_hz: int = None,
                         nco_freq_hz: float = None) -> dict:
    rx_buffer_words = int(rx_buffer_words)
    rx_buffer_nbytes = rx_buffer_words * 4
    total_buffers = int(n_rx_buffers) * int(passes)

    if rx_buffer_words <= 0:
        raise ValueError("rx_buffer_words must be > 0")
    if rx_buffer_nbytes * n_rx_buffers > S2MM_BUF_SIZE:
        raise ValueError(
            f"RX ring needs {rx_buffer_nbytes * n_rx_buffers} B, "
            f"but reserved RX window is {S2MM_BUF_SIZE} B")

    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
    try:
        regs = mmap.mmap(fd, AXI_DMA_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE,
                         offset=AXI_DMA_BASE)
        s2mm_bd = mmap.mmap(fd, BD_RING_SIZE, mmap.MAP_SHARED,
                            mmap.PROT_READ | mmap.PROT_WRITE,
                            offset=S2MM_BD_PHYS)
        rx_buf = mmap.mmap(fd, S2MM_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=S2MM_BUF_PHYS)
        try:
            # Clean-halt first so a prior invocation that crashed/exited with
            # the cyclic engine still running doesn't get its in-flight burst
            # severed by the reset below (see _s2mm_stop()).
            if not _s2mm_stop(regs):
                print("[dma] WARNING: S2MM did not halt before startup reset "
                      f"(DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X})")
            # Hard-reset the whole peripheral fabric domain (DMA + NCO + CIC
            # decimation + tlast/frame-length + mixer - see SDUAM.bd) via the
            # PS SLCR instead of the DMA's own DMACR soft-reset bit, which
            # doesn't clear a wedged SG engine (see _ps_fabric_reset()).
            _ps_fabric_reset()
            print(f"[dma] PS fabric reset OK   DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X}")
            _reg_wr(regs, _S2MM_DMASR, 0xFFFFFFFF)

            # Everything below was just wiped by the fabric reset - reprogram
            # it all before touching the DMA control registers.
            if nco_freq_hz is not None:
                set_nco_frequency(nco_freq_hz)
            configure_tlast_frame_len(rx_buffer_words)
            if decim_fs_hz is not None:
                configure_cic_decimation(decim_fs_hz)

            s2mm_tail = _write_s2mm_ring(s2mm_bd, rx_buffer_nbytes, n_rx_buffers)

            # Settling delay between each DMA register write - CURDESC must
            # land before DMACR enables the channel, and the channel must
            # actually be enabled before TAILDESC kicks the SG engine into
            # fetching, or the engine can start acting on a ring it hasn't
            # fully seen yet.
            _reg_wr(regs, _S2MM_CURDESC, S2MM_BD_PHYS & 0xFFFFFFFF)
            _reg_wr(regs, _S2MM_CURDESC_MSB, S2MM_BD_PHYS >> 32)
            time.sleep(0.001)
            _reg_wr(regs, _S2MM_DMACR, _DMACR_RS | _DMACR_CYCLIC_BD)
            time.sleep(0.001)
            _reg_wr(regs, _S2MM_TAILDESC, s2mm_tail & 0xFFFFFFFF)
            _reg_wr(regs, _S2MM_TAILDESC_MSB, s2mm_tail >> 32)
            time.sleep(0.001)

            print("[dma] S2MM programmed once")
            print(f"[rx]  Buffers          : {n_rx_buffers}")
            print(f"[rx]  Passes           : {passes}")
            print(f"[rx]  Buffer words     : {rx_buffer_words}")
            print(f"[rx]  Buffer bytes     : {rx_buffer_nbytes}")
            print(f"[rx]  Total buffers    : {total_buffers}")
            print(f"[rx]  Expected bytes   : {total_buffers * rx_buffer_nbytes}")
            print(f"[rx]  S2MM tail sent   : 0x{s2mm_tail:08X}")
            _dump_s2mm(regs, s2mm_bd, n_rx_buffers)

            # Ring-integrity baseline. If the ring is ALREADY wrong here - right
            # after we wrote and armed it, before the DMA has moved any data -
            # then the descriptor memory read back doesn't match what we wrote:
            # a stale / incoherent read, NOT a runtime corruption. If it's clean
            # here but diverges later, the corruption is a runtime write.
            exp_ring = _expected_ring(rx_buffer_nbytes, n_rx_buffers)
            base_bad = _verify_ring(s2mm_bd, exp_ring, n_rx_buffers)
            if base_bad:
                _report_ring_corruption(
                    base_bad, 0, 0,
                    "BASELINE: already wrong right after arm "
                    "(stale/incoherent descriptor read, not a runtime write)")
            else:
                print("[verify] ring intact after arm (matches programmed values)")
            ring_corrupt_reported = bool(base_bad)
            last_verify = time.time()

            captured = 0
            completed_bds = 0
            malformed_packets = 0
            acquisition_drops = 0
            stream_drops = 0
            packet_parts = []
            bd_idx = 0
            t_last = time.time()

            with open(raw_out, "wb") as out:
                while captured < total_buffers:
                    sr = _reg_rd(regs, _S2MM_DMASR)
                    if sr & _DMASR_ERRS:
                        _dump_s2mm_fault(regs, s2mm_bd, n_rx_buffers, bd_idx,
                                         f"DMASR error 0x{sr:08X} "
                                         f"[{_decode_dmasr(sr)}]")
                        raise RuntimeError(
                            f"S2MM DMA error DMASR=0x{sr:08X} "
                            f"[{_decode_dmasr(sr)}]")

                    _, status = _bd_control_status(s2mm_bd, bd_idx)
                    if status & _BD_STS_COMPLETE:
                        actual = status & _BD_LEN_MASK
                        sof = bool(status & _BD_STS_RXSOF)
                        eof = bool(status & _BD_STS_RXEOF)
                        completed_bds += 1

                        rx_buf.seek(bd_idx * rx_buffer_nbytes)
                        payload = rx_buf.read(actual)

                        if sof:
                            packet_parts = []
                        packet_parts.append(payload)

                        print(f"[rx]  BD done {completed_bds:04d} "
                              f"bd={bd_idx} status=0x{status:08X} "
                              f"actual={actual} B "
                              f"{'SOF' if sof else '---'} "
                              f"{'EOF' if eof else '---'}")

                        if eof:
                            packet = b"".join(packet_parts)
                            packet_parts = []
                            if len(packet) == rx_buffer_nbytes:
                                out.write(packet)
                                out.flush()
                                captured += 1
                                print(f"[file] Appended {captured}/{total_buffers} "
                                      f"buffers ({captured * rx_buffer_nbytes} B)")
                            else:
                                malformed_packets += 1
                                if captured == 0:
                                    acquisition_drops += 1
                                    drop_kind = "acquisition"
                                else:
                                    stream_drops += 1
                                    drop_kind = "stream"
                                print(f"[rx]  Dropped malformed packet "
                                      f"{malformed_packets} ({drop_kind}): "
                                      f"{len(packet)} B "
                                      f"(expected {rx_buffer_nbytes} B)")

                        _clear_bd_status(s2mm_bd, bd_idx)
                        bd_idx = (bd_idx + 1) % n_rx_buffers
                        t_last = time.time()
                        # Watchdog: catch the first descriptor corruption at the
                        # moment a BD completes (localizes it to this boundary).
                        if not ring_corrupt_reported:
                            bad = _verify_ring(s2mm_bd, exp_ring, n_rx_buffers)
                            if bad:
                                ring_corrupt_reported = True
                                _report_ring_corruption(
                                    bad, completed_bds, bd_idx,
                                    f"detected right after BD #{completed_bds} completed")
                            last_verify = t_last
                    else:
                        now = time.time()
                        # Watchdog: also check mid-transfer (a 2 MiB buffer can
                        # take seconds to fill) so we catch corruption that
                        # happens between BD completions, not just at boundaries.
                        if not ring_corrupt_reported and now - last_verify > 0.25:
                            last_verify = now
                            bad = _verify_ring(s2mm_bd, exp_ring, n_rx_buffers)
                            if bad:
                                ring_corrupt_reported = True
                                _report_ring_corruption(
                                    bad, completed_bds, bd_idx,
                                    "detected mid-wait (during a buffer transfer, "
                                    "between BD completions)")
                        if time.time() - t_last > poll_timeout:
                            _dump_s2mm_fault(regs, s2mm_bd, n_rx_buffers, bd_idx,
                                             f"poll timeout on BD {bd_idx} "
                                             f"(no error bit; DMASR=0x{sr:08X} "
                                             f"[{_decode_dmasr(sr)}])")
                            raise RuntimeError(
                                f"Timeout waiting for S2MM BD {bd_idx}; "
                                f"status=0x{status:08X} DMASR=0x{sr:08X} "
                                f"[{_decode_dmasr(sr)}]")
                        time.sleep(0.001)

            return dict(
                raw_out=raw_out,
                captured_buffers=captured,
                completed_bds=completed_bds,
                malformed_packets=malformed_packets,
                acquisition_drops=acquisition_drops,
                stream_drops=stream_drops,
                rx_buffer_words=rx_buffer_words,
                rx_buffer_nbytes=rx_buffer_nbytes,
                s2mm_dmasr=_reg_rd(regs, _S2MM_DMASR),
            )
        finally:
            if stop_dma:
                try:
                    # Clean-halt (drain in-flight AXI burst) BEFORE resetting,
                    # so no transaction is orphaned on the PS HP port. This is
                    # the fix for the per-rep leak that accumulated until the
                    # port wedged and only a power cycle cleared it. See
                    # _s2mm_stop().
                    if _s2mm_stop(regs):
                        print("[dma] S2MM halted cleanly (drained) before reset")
                    else:
                        print("[dma] WARNING: S2MM did not halt before teardown "
                              f"reset (DMASR=0x{_reg_rd(regs, _S2MM_DMASR):08X}); "
                              "an AXI transaction may have been orphaned")
                    _ps_fabric_reset()
                    print("[dma] S2MM stopped (PS fabric reset) after capture")
                except Exception as exc:
                    print(f"[dma] WARNING: S2MM stop/reset after capture failed: {exc}")
            rx_buf.close()
            s2mm_bd.close()
            regs.close()
    finally:
        os.close(fd)
