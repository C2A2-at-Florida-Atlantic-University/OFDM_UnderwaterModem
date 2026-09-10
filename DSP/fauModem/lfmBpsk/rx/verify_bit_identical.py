"""
verify_bit_identical.py -- prove a change to lfm_bpsk_rx.py did not alter
a single decoded value.

This is the harness OPTIMIZATION.md's "Verification" section describes,
committed so it can be re-run rather than reconstructed. It loads a
REFERENCE copy of lfm_bpsk_rx.py alongside the working one, decodes the
same synthetic multipath+AWGN capture through both, and compares every
field the two return dicts have in common -- **exactly**, not with a
tolerance. Fields present only in the new version are reported as
additions rather than failures, which is what makes it usable for
read-only telemetry commits as well as speed commits.

Exact comparison is the whole point. `np.allclose` would hide precisely
the class of bug worth catching here: a reordered accumulation or an
FFT-for-direct-convolution swap that shifts the last few ulps and then
flips a marginal bit decision on some other capture.

Usage
-----
    python verify_bit_identical.py                    # vs git HEAD
    python verify_bit_identical.py --ref lfm_bpsk_rx.py.orig
    python verify_bit_identical.py --ref-git HEAD~3
    python verify_bit_identical.py --frames 40 --snr 18

Exits 0 if every shared field matches, 1 otherwise.
"""

import argparse
import importlib.util
import os
import subprocess
import sys
import tempfile

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_tx as TX

HERE = os.path.dirname(os.path.abspath(__file__))
TARGET = "lfm_bpsk_rx.py"


def _load_module(path: str, name: str):
    """Import a .py file under an arbitrary module name, so two versions of
    the same file can be live in one interpreter."""
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


def _ref_from_git(rev: str) -> str:
    """Write <rev>:rx/lfm_bpsk_rx.py to a temp file and return its path."""
    repo = subprocess.check_output(
        ["git", "-C", HERE, "rev-parse", "--show-toplevel"],
        text=True).strip()
    rel = os.path.relpath(os.path.join(HERE, TARGET), repo).replace(os.sep, "/")
    blob = subprocess.check_output(
        ["git", "-C", repo, "show", f"{rev}:{rel}"])
    fd, path = tempfile.mkstemp(prefix=f"ref_{rev.replace('~','_')}_",
                                suffix=".py")
    with os.fdopen(fd, "wb") as f:
        f.write(blob)
    return path


def _channel(seed: int, snr_db: float):
    """Two-tap multipath at 3.0 and 5.5 symbols -- the delays
    test_lfm_bpsk_multipath.py establishes from the real tank captures."""
    d1 = int(round(3.0 * P.sps))
    d2 = int(round(5.5 * P.sps))
    h = np.zeros(d2 + 1, dtype=np.complex128)
    h[0] = 1.0
    h[d1] += 0.55 * np.exp(1j * 0.35)
    h[d2] += 0.42 * np.exp(1j * (np.pi - 0.2))
    return h, d2, np.random.default_rng(seed)


def _make_capture(h, d2, rng, snr_db: float, frame_id: int) -> np.ndarray:
    tx_wave = TX.build_packet_waveform(frame_id)["packet"].astype(np.complex128)
    rx = np.convolve(tx_wave, h)[:len(tx_wave) + d2]
    sig_pwr = np.mean(np.abs(tx_wave) ** 2)
    noise_pwr = sig_pwr / (10 ** (snr_db / 10))
    rx = rx + np.sqrt(noise_pwr / 2) * (rng.standard_normal(len(rx))
                                        + 1j * rng.standard_normal(len(rx)))
    pad = P.DEC_DELAY_MAX * P.sps + P.span * P.sps
    return np.concatenate([rx, np.zeros(pad, dtype=np.complex128)])


def _identical(a, b) -> bool:
    """Exact equality, NaN-aware. No tolerance anywhere."""
    if isinstance(a, np.ndarray) or isinstance(b, np.ndarray):
        a, b = np.asarray(a), np.asarray(b)
        if a.shape != b.shape or a.dtype != b.dtype:
            return False
        # equal_nan only applies to inexact dtypes.
        if a.dtype.kind in "fc":
            return np.array_equal(a, b, equal_nan=True)
        return np.array_equal(a, b)
    if isinstance(a, float) and isinstance(b, float):
        if np.isnan(a) and np.isnan(b):
            return True
    return type(a) is type(b) and a == b


def _describe(v) -> str:
    if isinstance(v, np.ndarray):
        return f"ndarray{v.shape} {v.dtype}"
    return f"{type(v).__name__}"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--ref", metavar="PATH",
                   help="Reference copy of lfm_bpsk_rx.py to compare against")
    g.add_argument("--ref-git", metavar="REV", default="HEAD",
                   help="Compare against this git revision (default HEAD)")
    ap.add_argument("--frames", type=int, default=20,
                    help="Number of packets to decode through both (default 20)")
    ap.add_argument("--snr", type=float, default=22.0,
                    help="AWGN SNR in dB (default 22)")
    ap.add_argument("--seed", type=int, default=12345)
    ap.add_argument("--ppm", type=float, default=0.0,
                    help="sample_ppm passed to decode_packet (default 0)")
    args = ap.parse_args()

    tmp = None
    if args.ref:
        ref_path = args.ref if os.path.isabs(args.ref) else os.path.join(HERE, args.ref)
    else:
        ref_path = tmp = _ref_from_git(args.ref_git)

    print(f"new : {os.path.join(HERE, TARGET)}")
    print(f"ref : {ref_path}" + (f"  (git {args.ref_git})" if tmp else ""))
    print(f"channel: 2-tap multipath at 3.0/5.5 sym, SNR={args.snr}dB, "
          f"{args.frames} packets, ppm={args.ppm}")
    print()

    try:
        ref = _load_module(ref_path, "_rx_ref")
        new = _load_module(os.path.join(HERE, TARGET), "_rx_new")

        h, d2, rng = _channel(args.seed, args.snr)
        n_cmp = 0
        added, missing, mismatched = set(), set(), {}
        skipped = 0

        for fid in range(args.frames):
            cap = _make_capture(h, d2, rng, args.snr, fid)
            d_ref = ref.decode_packet(cap, lfm_start=0, sample_ppm=args.ppm)
            d_new = new.decode_packet(cap, lfm_start=0, sample_ppm=args.ppm)

            if not (d_ref.get("ok") and d_new.get("ok")):
                if d_ref.get("ok") != d_new.get("ok"):
                    mismatched["ok"] = (d_ref.get("ok"), d_new.get("ok"))
                skipped += 1
                continue

            added |= set(d_new) - set(d_ref)
            missing |= set(d_ref) - set(d_new)
            for k in sorted(set(d_ref) & set(d_new)):
                n_cmp += 1
                if not _identical(d_ref[k], d_new[k]):
                    if k not in mismatched:
                        mismatched[k] = (d_ref[k], d_new[k])

        shared = sorted(set(d_ref) & set(d_new)) if n_cmp else []
        print(f"compared {len(shared)} field(s) x {args.frames - skipped} packet(s) "
              f"= {n_cmp} comparisons"
              + (f"   ({skipped} packet(s) skipped)" if skipped else ""))
        if shared:
            print("  " + ", ".join(shared))

        if added:
            print(f"\nNEW fields (not in reference, not a failure): "
                  f"{', '.join(sorted(added))}")
        if missing:
            print(f"\nREMOVED fields: {', '.join(sorted(missing))}")

        if mismatched:
            print(f"\nFAIL -- {len(mismatched)} field(s) differ:")
            for k, (a, b) in mismatched.items():
                print(f"  {k:20s} ref={_describe(a)}  new={_describe(b)}")
                if not isinstance(a, np.ndarray):
                    print(f"  {'':20s} ref={a!r}")
                    print(f"  {'':20s} new={b!r}")
            return 1

        if missing:
            print("\nFAIL -- fields were removed from the return dict")
            return 1

        print("\nPASS -- every shared field is bit-identical")
        return 0
    finally:
        if tmp and os.path.exists(tmp):
            os.remove(tmp)


if __name__ == "__main__":
    raise SystemExit(main())
