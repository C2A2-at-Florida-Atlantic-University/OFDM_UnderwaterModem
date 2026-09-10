"""
metrics_log.py -- append-only per-packet metrics log (JSON Lines).

Why this exists alongside the existing --report CSV
---------------------------------------------------
`lfm_rx_iq_sg_capture_frame_ids.write_report_csv()` already writes a
per-packet CSV, and it stays exactly as it is -- it is the human-readable
artifact for one run. This module adds a *second*, machine-readable log
with three properties the CSV deliberately does not have:

  1. **Self-describing.** The CSV has a fixed 14-column `fields` list, so
     every new metric means editing the writer and invalidating older
     files. JSONL rows carry their own keys, so adding a metric is a
     one-line change and old rows stay readable.
  2. **Append-only.** The CSV is opened `"w"` and overwritten each run.
     This log appends, so metrics accumulate across sessions -- which is
     the whole point: the interesting questions (does xcorr_peak predict
     decode success? does the best K_2/K_fb move with range?) need many
     packets from many runs, not one capture.
  3. **Carries run context.** A row on its own is unattributable -- a
     packet that decoded at 14 dB PDSNR is meaningless without the NCO,
     decimation, sampling rate and range that produced it. Every row is
     stamped with the run's config so the file is analysable standalone.

Read it back with pandas:

    import pandas as pd
    df = pd.read_json("lfm_iq_rx_metrics.jsonl", lines=True)

Or from the command line:

    python metrics_log.py lfm_iq_rx_metrics.jsonl

STRICTLY READ-ONLY with respect to decoding. Nothing here feeds a bit,
timing, or tap decision -- it only records what decode_packet() and
analyze_capture() already computed. Logging failures are warned about and
swallowed (see append()): a full disk or a bad path must never take down
a receiver that is otherwise working.
"""

import json
import math
import os
import sys
import time

import numpy as np

# Sentinel: this value cannot be represented in JSON and should be omitted
# from the row entirely rather than written as null (a dropped array and a
# genuinely-null metric are different things and shouldn't look alike).
_DROP = object()

# Keys that are large arrays rather than metrics. Dropped by name as well
# as by type so the intent is visible in one place -- decode_packet()
# returns eq_out/mf_ds/wc/data_out and the bit vectors, none of which
# belong in a metrics line.
ARRAY_KEYS = frozenset({
    "eq_out", "mf_ds", "mf_ds_fse", "data_out", "wc",
    "bits_hat", "bits_hat_s8", "bits_naive", "ref_bits",
})

MAX_DEPTH = 3


def _sanitize(value, depth: int = 0):
    """Coerce one value to something json.dumps() can write, or _DROP.

    numpy scalars become Python scalars, numpy arrays are dropped, and
    non-finite floats become None -- json.dumps() would otherwise emit
    bare NaN/Infinity, which is valid JavaScript but not valid JSON and
    fails to parse in pandas and most other readers.
    """
    if value is None or isinstance(value, str):
        return value

    # bool before int: Python's bool is an int subclass, and np.bool_ is
    # neither np.integer nor a Python bool.
    if isinstance(value, (bool, np.bool_)):
        return bool(value)

    if isinstance(value, np.ndarray):
        # 0-d arrays are scalars wearing an array's clothes; keep them.
        if value.ndim == 0:
            return _sanitize(value.item(), depth)
        return _DROP

    if isinstance(value, np.generic):          # np.float64, np.int64, ...
        return _sanitize(value.item(), depth)

    if isinstance(value, int):
        return value

    if isinstance(value, float):
        return value if math.isfinite(value) else None

    if isinstance(value, complex):
        # Lossless and JSON-safe. Nothing in the current rows is complex,
        # but rot_angle-adjacent fields could become so.
        re_, im_ = _sanitize(value.real, depth), _sanitize(value.imag, depth)
        return [re_, im_]

    if depth >= MAX_DEPTH:
        return _DROP

    if isinstance(value, dict):
        out = {}
        for k, v in value.items():
            s = _sanitize(v, depth + 1)
            if s is not _DROP:
                out[str(k)] = s
        return out

    if isinstance(value, (list, tuple)):
        out = []
        for v in value:
            s = _sanitize(v, depth + 1)
            if s is _DROP:
                return _DROP        # a partial list is worse than no list
            out.append(s)
        return out

    return _DROP


def sanitize_row(row: dict) -> dict:
    """One packet's result dict -> a flat, JSON-safe metrics dict."""
    out = {}
    for k, v in row.items():
        if k in ARRAY_KEYS:
            continue
        s = _sanitize(v)
        if s is not _DROP:
            out[k] = s
    return out


def make_context(**kwargs) -> dict:
    """Run-level fields stamped onto every row of this run.

    run_id/run_time are generated here so all rows from one invocation
    share them -- that is what lets you separate runs in a file that
    several runs have appended to.
    """
    ctx = dict(
        run_id=f"{time.strftime('%Y%m%dT%H%M%S')}-{os.getpid()}",
        run_time=time.strftime("%Y-%m-%d %H:%M:%S"),
    )
    ctx.update({k: v for k, v in kwargs.items() if v is not None})
    return sanitize_row(ctx)


def append(path: str, rows, context: dict = None, verbose: bool = True) -> int:
    """Append one JSON object per row. Returns the number of rows written.

    Never raises: a logging failure is reported and swallowed so it
    cannot take down a decode run. Context keys are written first and
    are overridden by same-named row keys, so a per-packet sample_ppm
    beats a run-level one.
    """
    if not path:
        return 0
    ctx = context or {}
    n = 0
    try:
        with open(path, "a", encoding="utf-8") as f:
            for row in rows:
                rec = dict(ctx)
                rec.update(sanitize_row(row))
                f.write(json.dumps(rec, allow_nan=False) + "\n")
                n += 1
    except Exception as exc:                                   # noqa: BLE001
        print(f"[metrics] WARNING: could not write {path}: {exc}")
        return n
    if verbose:
        print(f"[metrics] Appended {n} packet row(s) to {path}")
    return n


def read(path: str) -> list:
    """Load a JSONL metrics file back as a list of dicts, skipping any
    truncated final line (a run killed mid-write leaves one)."""
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                print("[metrics] WARNING: skipping malformed line")
    return rows


def _summary(path: str) -> None:
    rows = read(path)
    if not rows:
        print(f"{path}: empty")
        return
    runs = sorted({r.get("run_id", "?") for r in rows})
    keys = sorted({k for r in rows for k in r})
    print(f"{path}: {len(rows)} rows, {len(runs)} run(s), {len(keys)} keys")
    print(f"  runs: {', '.join(runs)}")
    print(f"  keys: {', '.join(keys)}")

    cols = ["capture_idx", "frame_id", "marker_score", "n_err",
            "xcorr_peak", "best_eye", "CFO_total", "ber_train",
            "agree", "pdsnr_db", "rot_angle"]
    cols = [c for c in cols if any(c in r for r in rows)]
    print()
    print("  " + "".join(f"{c:>13}" for c in cols))
    for r in rows[:20]:
        cells = []
        for c in cols:
            v = r.get(c)
            if isinstance(v, float):
                cells.append(f"{v:13.4f}")
            elif v is None:
                cells.append(f"{'-':>13}")
            else:
                cells.append(f"{v:>13}")
        print("  " + "".join(cells))
    if len(rows) > 20:
        print(f"  ... {len(rows) - 20} more")

    print()
    for c in cols:
        vals = [r[c] for r in rows
                if isinstance(r.get(c), (int, float))
                and not isinstance(r.get(c), bool)]
        if vals:
            print(f"  {c:<14} n={len(vals):4d}  min={min(vals):+11.4f}  "
                  f"mean={sum(vals)/len(vals):+11.4f}  max={max(vals):+11.4f}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: python {os.path.basename(__file__)} <metrics.jsonl>")
        raise SystemExit(2)
    _summary(sys.argv[1])
