"""
TX-only AXI DMA scatter-gather helper for cyclic MM2S transmit.

This is for the TX design with AXI DMA configured as:
  C_INCLUDE_SG   = 1
  C_INCLUDE_MM2S = 1
  C_INCLUDE_S2MM = 0

The helper writes one packet into the 16 MB reserved TX buffer, builds a
circular MM2S BD ring, enables cyclic BD mode, and starts the DMA once.
"""

import mmap
import os
import signal
import struct
import time

import numpy as np


AXI_DMA_BASE = 0x40400000
AXI_DMA_SIZE = 0x10000

MM2S_BD_PHYS = 0x1D000000
BD_RING_SIZE = 0x10000
MM2S_BUF_PHYS = 0x1E000000
MM2S_BUF_SIZE = 16 << 20

SG_SEGMENT_BYTES = 64 << 10

_MM2S_DMACR = 0x00
_MM2S_DMASR = 0x04
_MM2S_CURDESC = 0x08
_MM2S_CURDESC_MSB = 0x0C
_MM2S_TAILDESC = 0x10
_MM2S_TAILDESC_MSB = 0x14

_DMACR_RS = 1 << 0
_DMACR_RESET = 1 << 2
_DMACR_CYCLIC_BD = 1 << 4
_DMASR_ERRS = (1 << 4) | (1 << 5) | (1 << 6)

_BD_BYTES = 0x40
_BD_NXTDESC = 0x00
_BD_NXTDESC_MSB = 0x04
_BD_BUFADDR = 0x08
_BD_BUFADDR_MSB = 0x0C
_BD_CONTROL = 0x18
_BD_STATUS = 0x1C

_BD_CTRL_TXEOF = 1 << 26
_BD_CTRL_TXSOF = 1 << 27
_BD_LEN_MASK = (1 << 26) - 1


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


def _mm2s_reset(regs):
    _reg_wr(regs, _MM2S_DMACR, _DMACR_RESET)
    for _ in range(1000):
        if not (_reg_rd(regs, _MM2S_DMACR) & _DMACR_RESET):
            return
        time.sleep(0.001)
    raise RuntimeError("MM2S reset timeout")


def _bd_off(index):
    return int(index) * _BD_BYTES


def _write_bd(bd_mem, index, next_phys, buf_phys, nbytes,
              tx_sof=False, tx_eof=False):
    if nbytes <= 0:
        raise ValueError("BD length must be > 0")
    if nbytes > _BD_LEN_MASK:
        raise ValueError(f"BD length {nbytes} exceeds {_BD_LEN_MASK} bytes")

    control = int(nbytes)
    if tx_sof:
        control |= _BD_CTRL_TXSOF
    if tx_eof:
        control |= _BD_CTRL_TXEOF

    off = _bd_off(index)
    bd_mem.seek(off)
    bd_mem.write(b"\x00" * _BD_BYTES)
    _reg_wr(bd_mem, off + _BD_NXTDESC, next_phys & 0xFFFFFFFF)
    _reg_wr(bd_mem, off + _BD_NXTDESC_MSB, next_phys >> 32)
    _reg_wr(bd_mem, off + _BD_BUFADDR, buf_phys & 0xFFFFFFFF)
    _reg_wr(bd_mem, off + _BD_BUFADDR_MSB, buf_phys >> 32)
    _reg_wr(bd_mem, off + _BD_CONTROL, control)
    _reg_wr(bd_mem, off + _BD_STATUS, 0)


def _build_mm2s_segments(packet_nbytes, frame_nbytes=None):
    segments = []
    offset = 0

    if frame_nbytes is None:
        while offset < packet_nbytes:
            this_bytes = min(SG_SEGMENT_BYTES, packet_nbytes - offset)
            segments.append(dict(
                offset=offset,
                nbytes=this_bytes,
                tx_sof=(offset == 0),
                tx_eof=(offset + this_bytes == packet_nbytes),
            ))
            offset += this_bytes
        return segments

    frame_nbytes = int(frame_nbytes)
    if frame_nbytes <= 0:
        raise ValueError("frame_nbytes must be > 0")
    if packet_nbytes % frame_nbytes:
        raise ValueError(
            f"TX packet {packet_nbytes} B is not an integer number of "
            f"{frame_nbytes} B frames")

    while offset < packet_nbytes:
        frame_start = offset
        frame_remaining = frame_nbytes
        first_in_frame = True
        while frame_remaining > 0:
            this_bytes = min(SG_SEGMENT_BYTES, frame_remaining)
            segments.append(dict(
                offset=offset,
                nbytes=this_bytes,
                tx_sof=first_in_frame,
                tx_eof=(frame_remaining == this_bytes),
            ))
            offset += this_bytes
            frame_remaining -= this_bytes
            first_in_frame = False

        if offset - frame_start != frame_nbytes:
            raise RuntimeError("internal frame segmentation error")

    return segments


def _write_mm2s_ring(bd_mem, packet_nbytes, frame_nbytes=None):
    segments = _build_mm2s_segments(packet_nbytes, frame_nbytes=frame_nbytes)
    n_desc = len(segments)
    if n_desc <= 0:
        raise ValueError("TX packet is empty")
    if n_desc + 1 > BD_RING_SIZE // _BD_BYTES:
        raise ValueError("MM2S BD ring is too small")

    for i, segment in enumerate(segments):
        next_phys = MM2S_BD_PHYS + ((i + 1) % n_desc) * _BD_BYTES
        _write_bd(
            bd_mem,
            i,
            next_phys=next_phys,
            buf_phys=MM2S_BUF_PHYS + segment["offset"],
            nbytes=segment["nbytes"],
            tx_sof=segment["tx_sof"],
            tx_eof=segment["tx_eof"],
        )

    tail_sentinel = MM2S_BD_PHYS + n_desc * _BD_BYTES
    _flush(bd_mem)
    return n_desc, tail_sentinel, segments


def _verify_mm2s_ring(bd_mem, segments):
    n_desc = len(segments)
    total = 0
    sof_count = 0
    eof_count = 0
    for i, segment in enumerate(segments):
        off = _bd_off(i)
        next_desc = _reg_rd(bd_mem, off + _BD_NXTDESC)
        buf_addr = _reg_rd(bd_mem, off + _BD_BUFADDR)
        control = _reg_rd(bd_mem, off + _BD_CONTROL)
        status = _reg_rd(bd_mem, off + _BD_STATUS)

        expected_next = MM2S_BD_PHYS + ((i + 1) % n_desc) * _BD_BYTES
        expected_buf = MM2S_BUF_PHYS + segment["offset"]
        length = control & _BD_LEN_MASK
        expected_len = int(segment["nbytes"])
        expected_sof = bool(segment["tx_sof"])
        expected_eof = bool(segment["tx_eof"])
        got_sof = bool(control & _BD_CTRL_TXSOF)
        got_eof = bool(control & _BD_CTRL_TXEOF)

        if next_desc != expected_next:
            raise RuntimeError(
                f"MM2S BD {i} next mismatch: "
                f"0x{next_desc:08X} != 0x{expected_next:08X}")
        if buf_addr != expected_buf:
            raise RuntimeError(
                f"MM2S BD {i} buffer mismatch: "
                f"0x{buf_addr:08X} != 0x{expected_buf:08X}")
        if length != expected_len:
            raise RuntimeError(
                f"MM2S BD {i} length mismatch: {length} != {expected_len}")
        if got_sof != expected_sof or got_eof != expected_eof:
            raise RuntimeError(
                f"MM2S BD {i} SOF/EOF mismatch: "
                f"got {int(got_sof)}/{int(got_eof)}, "
                f"expected {int(expected_sof)}/{int(expected_eof)}")
        if status != 0:
            raise RuntimeError(
                f"MM2S BD {i} status not clear before start: 0x{status:08X}")

        sof_count += int(got_sof)
        eof_count += int(got_eof)
        total += length

    return dict(total_bytes=total, sof_count=sof_count, eof_count=eof_count)

def _bd_control_status(bd_mem, index):
    off = _bd_off(index)
    return (_reg_rd(bd_mem, off + _BD_CONTROL),
            _reg_rd(bd_mem, off + _BD_STATUS))


def _dump_mm2s(regs, bd_mem, n_desc):
    first_ctrl, first_sts = _bd_control_status(bd_mem, 0)
    last_ctrl, last_sts = _bd_control_status(bd_mem, n_desc - 1)
    print(f"[mm2s] DMACR          0x{_reg_rd(regs, _MM2S_DMACR):08X}")
    print(f"[mm2s] DMASR          0x{_reg_rd(regs, _MM2S_DMASR):08X}")
    print(f"[mm2s] CURDESC        0x{_reg_rd(regs, _MM2S_CURDESC):08X}")
    print(f"[mm2s] TAILDESC       0x{_reg_rd(regs, _MM2S_TAILDESC):08X}")
    print(f"[mm2s] BD[0] ctrl/sts 0x{first_ctrl:08X} / 0x{first_sts:08X}")
    print(f"[mm2s] BD[{n_desc - 1}] ctrl/sts 0x{last_ctrl:08X} / 0x{last_sts:08X}")


def start_cyclic_mm2s(tx_words: np.ndarray, monitor: bool = True,
                      reset_on_exit: bool = True,
                      frame_words: int = None) -> dict:
    tx_words = tx_words.astype(np.uint32, copy=False)
    tx_nbytes = len(tx_words) * 4
    frame_nbytes = None if frame_words is None else int(frame_words) * 4
    if tx_nbytes <= 0:
        raise ValueError("TX packet is empty")
    if tx_nbytes > MM2S_BUF_SIZE:
        raise ValueError(
            f"TX packet {tx_nbytes} B exceeds reserved TX buffer {MM2S_BUF_SIZE} B")


    fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)
    running = [True]

    def _stop(_signum, _frame):
        running[0] = False

    old_int = signal.signal(signal.SIGINT, _stop)
    old_term = signal.signal(signal.SIGTERM, _stop)
    try:
        regs = mmap.mmap(fd, AXI_DMA_SIZE, mmap.MAP_SHARED,
                         mmap.PROT_READ | mmap.PROT_WRITE,
                         offset=AXI_DMA_BASE)
        mm2s_bd = mmap.mmap(fd, BD_RING_SIZE, mmap.MAP_SHARED,
                            mmap.PROT_READ | mmap.PROT_WRITE,
                            offset=MM2S_BD_PHYS)
        tx_buf = mmap.mmap(fd, MM2S_BUF_SIZE, mmap.MAP_SHARED,
                           mmap.PROT_READ | mmap.PROT_WRITE,
                           offset=MM2S_BUF_PHYS)
        try:
            tx_buf.seek(0)
            tx_buf.write(tx_words.tobytes())
            _flush(tx_buf)
            tx_buf.seek(0)
            check = np.frombuffer(tx_buf.read(tx_nbytes), dtype=np.uint32).copy()
            bad = np.flatnonzero(check != tx_words)
            if len(bad):
                i = int(bad[0])
                raise RuntimeError(
                    f"TX buffer verify failed at {i}: "
                    f"0x{int(check[i]):08X} != 0x{int(tx_words[i]):08X}")
            print(f"[dma] TX buffer verify : PASS ({len(tx_words)} words)")

            n_desc, tail, segments = _write_mm2s_ring(
                mm2s_bd,
                tx_nbytes,
                frame_nbytes=frame_nbytes,
            )
            bd_check = _verify_mm2s_ring(mm2s_bd, segments)
            print(f"[dma] MM2S BD verify   : PASS ({n_desc} descriptors)")

            _mm2s_reset(regs)
            print(f"[dma] MM2S reset OK   DMASR=0x{_reg_rd(regs, _MM2S_DMASR):08X}")
            _reg_wr(regs, _MM2S_DMASR, 0xFFFFFFFF)

            _reg_wr(regs, _MM2S_CURDESC, MM2S_BD_PHYS & 0xFFFFFFFF)
            _reg_wr(regs, _MM2S_CURDESC_MSB, MM2S_BD_PHYS >> 32)
            _reg_wr(regs, _MM2S_DMACR, _DMACR_RS | _DMACR_CYCLIC_BD)
            _reg_wr(regs, _MM2S_TAILDESC, tail & 0xFFFFFFFF)
            _reg_wr(regs, _MM2S_TAILDESC_MSB, tail >> 32)

            print("[dma] MM2S cyclic SG programmed once")
            print(f"[tx]  Packet words     : {len(tx_words)}")
            print(f"[tx]  Packet bytes     : {tx_nbytes}")
            print(f"[tx]  MM2S BD count    : {n_desc}")
            print(f"[tx]  MM2S SOF/EOF     : "
                  f"{bd_check['sof_count']} / {bd_check['eof_count']}")
            if frame_words is not None:
                print(f"[tx]  SG frame words   : {int(frame_words)}")
            print(f"[tx]  MM2S tail sent   : 0x{tail:08X}")
            print(f"[tx]  TX buffer phys   : 0x{MM2S_BUF_PHYS:08X}")
            print(f"[tx]  BD ring phys     : 0x{MM2S_BD_PHYS:08X}")
            _dump_mm2s(regs, mm2s_bd, n_desc)

            if monitor:
                print("[dma] Running cyclic TX. Press Ctrl+C to stop/reset.")
                while running[0]:
                    sr = _reg_rd(regs, _MM2S_DMASR)
                    if sr & _DMASR_ERRS:
                        raise RuntimeError(f"MM2S DMA error DMASR=0x{sr:08X}")
                    time.sleep(0.5)
            else:
                print("[dma] Leaving cyclic TX running and exiting")

            return dict(
                tx_words=len(tx_words),
                tx_nbytes=tx_nbytes,
                mm2s_desc=n_desc,
                mm2s_sof=bd_check["sof_count"],
                mm2s_eof=bd_check["eof_count"],
                mm2s_dmasr=_reg_rd(regs, _MM2S_DMASR),
            )
        finally:
            if reset_on_exit and monitor:
                try:
                    _mm2s_reset(regs)
                    print("[dma] MM2S stopped/reset")
                except Exception as exc:
                    print(f"[dma] WARNING: MM2S reset failed: {exc}")
            tx_buf.close()
            mm2s_bd.close()
            regs.close()
    finally:
        signal.signal(signal.SIGINT, old_int)
        signal.signal(signal.SIGTERM, old_term)
        os.close(fd)
