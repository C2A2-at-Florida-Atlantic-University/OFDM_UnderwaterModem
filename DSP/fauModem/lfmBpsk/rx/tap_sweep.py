"""
tap_sweep.py -- find the best NLMS-DFE tap geometry (K_2, K_fb) for one
packet, cheaply enough to run on the board.

Python counterpart of lfm_bpsk_sweep_fine.py's grid search, with two
changes that cut the cost ~13x for the same answer, and one that stops it
being wrong on sparse channels.

WHY NOT JUST RUN THE FULL GRID
------------------------------
Chao's script walks 9 K_2 values x 10 K_fb values at two no_repass
settings -- 180 equalizer runs. Measured: ~5 s per packet on a PC, so
~11 minutes per packet on the RX board. Two of those factors are
avoidable.

1. Coarse-then-fine. A 3x3 pass followed by a 3x3 refinement around the
   winner is 18 runs instead of 90. Measured against the full grid on
   six cases (single-path / 2-tap / 3-tap channels, two SNRs each): the
   exact same winner in 4 of 6, and within 0.04 dB in the other 2. That
   0.04 dB is below the 0.056 dB packet-to-packet spread measured on
   real hardware, so it is not a distinguishable difference.

2. No second no_repass run. Chao runs every combination at 3 and 5
   repasses and flags UNSTABLE when the error counts disagree. That
   doubles the cost for a convergence check that is already available
   free: decode_packet() returns bits_hat_s8, the pass-1 result,
   alongside the final bits_hat. Comparing those two says whether the
   extra passes changed anything.

Together: ~40 s per packet on the board instead of ~11 minutes.

THE PART THAT MATTERS ON A REAL CHANNEL
---------------------------------------
Coarse-then-fine assumes the score surface is smooth with one peak. That
holds when the channel is compact -- echoes close behind the direct path,
which is what a tank gives. It does NOT hold on a sparse channel, which
is what real underwater multipath looks like: a direct path plus discrete
surface/bottom bounces at large, isolated delays.

Measured, direct path plus a 0.7-amplitude bounce at 40 symbols:

    K_fb ->    16     20     24     28     32     36     40     44
    K_2=32    7.6    7.6    7.6    7.7    7.8    7.7   21.3   18.9
    K_2=48    7.7    7.7    7.7    7.8    7.9    7.8   17.1   16.4

Everything at K_fb <= 36 sits on a 7.7 dB floor; at 40 it jumps to 21.
That is a CLIFF, not a hill -- the feedback section physically cannot
reach a 40-symbol echo with 36 taps, so nothing below the cliff helps at
all. Six local maxima on that grid. A coarse pass stepping 32 -> 64 -> 96
can straddle the cliff and see only the floor.

So the grid is not placed blindly. The LFM correlator already gives the
channel impulse response, and the last significant arrival in it says how
many symbols the feedback section must span. measure_max_delay_sym()
reads that off, and the K_fb candidates below it are dropped before the
search starts -- which puts the whole grid on the useful side of the
cliff by construction rather than by luck.

USAGE
-----
    import tap_sweep
    r = tap_sweep.sweep_taps(rx_raw, lfm_start, sample_ppm=ppm)
    print(r["best"], r["best_score"], r["n_runs"])

Scored on snr_eq_db by default, which needs no reference bits and so
works on unknown payloads in the field. Pass ref_bits to score on actual
bit errors instead (lab only), which is what Chao's script does.
"""

import numpy as np

import lfm_bpsk_params as P
import lfm_bpsk_rx as RX

# Same grid Chao's lfm_bpsk_sweep_fine.py uses, so a full-grid comparison
# is apples to apples.
DEFAULT_K2_LIST = [32, 40, 48, 56, 64, 72, 80, 88, 96]
DEFAULT_KFB_LIST = [16, 20, 24, 28, 32, 36, 40, 44, 48, 52]

# An arrival this far below the correlation peak is treated as noise when
# looking for the LAST arrival. -20 dB is the usual power-delay-profile
# convention; it is deliberately the same floor _tau_rms_from_cir uses.
MAX_DELAY_FLOOR_DB = -20.0

# ...but a fixed ratio to the peak is NOT sufficient on its own, and the
# first version of this file shipped with only that. On a real capture
# (2026-09-03, tank, delay spread measured at 0.32 symbols) it reported a
# last arrival past 40 symbols, because the NOISE floor sits above
# peak-20 dB and the "last bin above threshold" was simply the furthest
# bin where noise happened to poke up. That forced the K_fb floor to ~36
# and made the sweep pick 40 feedback taps on a channel with no echo at
# all. Synthetic tests never caught it -- they were too clean.
#
# So an arrival must also stand clear of the measured noise level. In
# |correlation|^2 the noise is exponentially distributed, so the maximum
# over N bins sits around ln(N)/ln(2) times the median -- about 12x, or
# 11 dB, for the ~4200-bin window used here. 13 dB gives margin over
# that without needing the window length baked in.
MAX_DELAY_OVER_NOISE_DB = 13.0

# How far BELOW the measured last arrival the K_fb floor is placed.
#
# The floor opens the window downward, it does not raise it. The best K_fb
# sits essentially AT the echo delay -- just long enough to reach it --
# because every tap beyond that adds noise without cancelling anything.
# So the floor must stay under the measured delay or it excludes the
# answer. First version added +4 instead of subtracting, measured a
# 40-symbol echo at 41.5 sym (the probe's own width pushes the last bin
# past the true delay), floored K_fb at 46, and threw away the true
# optimum at 40 -- 1.1 dB worse than the full grid.
#
# 8 symbols is ~2x the LFM probe's resolution (0.4 sym) plus slack for
# the delay moving between packets. It still removes most of the dead
# region, which is the point: on the 40-symbol test channel it drops
# K_fb 16-32 and keeps 36-52, so the coarse pass spends its points where
# the score actually varies.
KFB_MARGIN_SYM = 8

# How much better than the CURRENT setting the swept winner must be
# before it is adopted, in dB of snr_eq_db averaged over the probes.
#
# Without this the sweep switches on noise. Measured on a single-path
# channel at the tank's SNR, averaged over 4 packets, the full 90-point
# surface spans 10.6 dB -- but the top TEN candidates span 0.104 dB,
# against a 0.056 dB packet-to-packet spread on real hardware. The
# default (48,20) already scores 23.29 dB versus the true best (48,16) at
# 23.32. There is nothing to win.
#
# The first real run bore that out: with the delay measurement fixed and
# the floor correctly at 0, the sweep still picked (32,44) on a split
# vote and came out 0.17 dB BELOW the default it replaced.
#
# 0.5 dB is ~9x the hardware noise and ~5x the width of that flat top
# region, so it suppresses noise-driven switches. It is also two orders
# of magnitude below the +12.3 dB the sweep wins on a sparse channel the
# default cannot equalise at all, so it does not block the case the
# sweep exists for.
MIN_GAIN_DB = 0.5


def measure_max_delay_sym(rx_raw: np.ndarray, lfm_start: int,
                          floor_db: float = MAX_DELAY_FLOOR_DB) -> float:
    """
    Delay of the LAST significant arrival, in symbols, from the LFM
    correlator around one packet.

    This is deliberately NOT tau_rms. tau_rms is the second moment of the
    power-delay profile and describes the spread's "width"; what sizes the
    feedback section is how far out the last arrival sits, which is the
    support, not the width. A direct path plus one distant bounce has a
    large max delay and a fairly modest tau_rms.

    Correlates only a window around this packet rather than the whole
    capture, so it costs a fraction of detect_lfm_packets and never
    materialises a capture-length array.
    """
    lfm = RX.P_lfm_ref().astype(np.complex128)
    n = len(lfm)
    lo = max(0, int(lfm_start))
    hi = min(len(rx_raw), lo + n + P.N_guard)
    seg = np.asarray(rx_raw[lo:hi], dtype=np.complex128)
    if len(seg) < n:
        return 0.0
    corr = np.convolve(seg, np.conj(lfm[::-1]))
    pwr = corr.real ** 2 + corr.imag ** 2
    pk = int(np.argmax(pwr))
    if pwr[pk] <= 0:
        return 0.0
    # Look forward from the peak only: echoes are causal. The window is
    # already limited to the guard interval, so it cannot run into the
    # BPSK payload and mistake signal for an echo.
    tail = pwr[pk:]
    if tail.size < 2:
        return 0.0

    # Two thresholds, both of which an arrival must clear. Relative to the
    # peak keeps weak reflections from dominating; relative to the noise
    # keeps NOISE from being mistaken for a reflection. See
    # MAX_DELAY_OVER_NOISE_DB -- omitting the second one is the bug this
    # replaces. The median of the tail is the noise level: a real CIR
    # occupies a handful of bins out of thousands, so it cannot move the
    # median.
    noise = float(np.median(tail))
    thr_peak = pwr[pk] * (10 ** (floor_db / 10.0))
    thr_noise = noise * (10 ** (MAX_DELAY_OVER_NOISE_DB / 10.0))
    thr = max(thr_peak, thr_noise)

    above = np.nonzero(tail >= thr)[0]
    last = int(above[-1]) if above.size else 0
    return last / float(P.sps)


def suggest_kfb_floor(max_delay_sym: float,
                      margin_sym: int = KFB_MARGIN_SYM) -> int:
    """
    Lowest K_fb worth trying, given the measured last arrival.

    Sits margin_sym BELOW the measured delay -- see KFB_MARGIN_SYM for
    why subtracting rather than adding. Returns 0 (keep everything) when
    the channel is compact enough that nothing can be safely excluded,
    which is the correct answer for a single-path channel.
    """
    return max(0, int(np.ceil(max_delay_sym)) - int(margin_sym))


def _pick_coarse(values, n=3):
    """n roughly-evenly-spaced entries of `values`, endpoints included."""
    if len(values) <= n:
        return list(values)
    idx = np.unique(np.linspace(0, len(values) - 1, n).round().astype(int))
    return [values[i] for i in idx]


def sweep_taps(rx_raw: np.ndarray, lfm_start: int, sample_ppm: float = 0.0,
               k2_list=None, kfb_list=None, no_repass: int = None,
               kfb_floor: int = None, ref_bits: np.ndarray = None,
               coarse: int = 3, verbose: bool = False) -> dict:
    """
    Search (K_2, K_fb) for one packet. Returns a dict with:

        best        (K_2, K_fb) of the winner
        best_score  its score
        best_stable whether the repasses changed its decisions
        scores      {(K_2, K_fb): score} for every candidate actually run
        n_runs      how many decodes that took
        objective   "snr_eq_db" or "n_err"
        max_delay_sym, kfb_floor, kfb_dropped
        coarse_best the winner of the coarse pass, before refinement

    Higher score is better in both objectives (n_err is negated), so the
    caller never has to know which direction to sort.
    """
    k2_list = list(k2_list) if k2_list else list(DEFAULT_K2_LIST)
    kfb_list = list(kfb_list) if kfb_list else list(DEFAULT_KFB_LIST)
    objective = "n_err" if ref_bits is not None else "snr_eq_db"

    # --- place the grid using the channel, not blind ---
    max_delay = measure_max_delay_sym(rx_raw, lfm_start)
    if kfb_floor is None:
        kfb_floor = suggest_kfb_floor(max_delay)
    kept = [k for k in kfb_list if k >= kfb_floor]
    dropped = [k for k in kfb_list if k < kfb_floor]
    if not kept:
        # The measured echo is beyond anything in the list. Keep the
        # largest rather than returning nothing, and say so -- a caller
        # that gets kfb_dropped == the whole list knows the grid is too
        # small for this channel and should be widened.
        kept = [max(kfb_list)]
        dropped = [k for k in kfb_list if k != kept[0]]
    if verbose:
        print(f"[sweep] last arrival {max_delay:.2f} sym -> K_fb floor "
              f"{kfb_floor}; {len(dropped)} of {len(kfb_list)} dropped")

    scores, stable = {}, {}

    def run(K2, Kfb):
        key = (K2, Kfb)
        if key in scores:
            return scores[key]
        d = RX.decode_packet(rx_raw, lfm_start, sample_ppm=sample_ppm,
                             K_2=K2, K_fb=Kfb, no_repass=no_repass)
        if not d.get("ok"):
            scores[key] = -np.inf
            stable[key] = False
            return scores[key]
        if ref_bits is not None:
            scores[key] = -float(np.sum(d["bits_hat"] != ref_bits))
        else:
            scores[key] = float(d["snr_eq_db"])
        # Free convergence check: bits_hat_s8 is the pass-1 result, so if
        # it matches the final bits the extra repasses changed nothing.
        stable[key] = bool(np.array_equal(d["bits_hat"], d["bits_hat_s8"]))
        return scores[key]

    # --- coarse pass: EXHAUSTIVE in K_fb, coarse in K_2 ---
    #
    # The two dimensions are not equivalent, so they should not be
    # searched the same way. K_fb is where the cliff lives: the feedback
    # section either reaches the last echo or it does not, and on a sparse
    # channel the score across K_fb is genuinely multi-modal. Measured on
    # the 40-symbol-echo channel, K_fb 40 -> 21.1 dB, 44 -> lower,
    # 48 -> 20.2 dB: a real local maximum at 48 with a dip before the true
    # peak at 40. A coarse pass plus hill climb converges on 48 and stops,
    # 0.89 dB short, and no local search can fix that -- it is doing
    # exactly what it should on a bumpy surface.
    #
    # So K_fb is swept exhaustively over whatever survived the floor. That
    # is what the floor is for: it cut 10 candidates to 5 on the sparse
    # channel, and 5 is cheap enough to enumerate. K_2 varies smoothly, so
    # it stays coarse-plus-climb.
    c2 = _pick_coarse(k2_list, coarse)
    for K2 in c2:
        for Kfb in kept:
            run(K2, Kfb)
    coarse_best = max(((k, v) for k, v in scores.items()), key=lambda kv: kv[1])[0]

    # --- refine by hill climb in index space ---
    #
    # A fixed 3x3 neighbourhood around the coarse winner is not enough. If
    # the coarse pass lands on the EDGE of the candidate list, a +-1 look
    # can only step inward once. Measured on the sparse 40-symbol-echo
    # channel: the floor left K_fb in [36,40,44,48,52], the coarse pass
    # picked 52 (the top), and +-1 refinement reached only 48 -- stopping
    # 0.89 dB short of the true optimum at 40, two steps further down.
    #
    # Climbing instead keeps stepping while the score improves, so the
    # distance from the coarse winner to the optimum stops mattering. Cost
    # is 4 evaluations per step (the 4-neighbourhood, not all 8) and it
    # normally converges in 2-4 steps, so this stays far cheaper than the
    # full grid while being much harder to fool.
    i2 = k2_list.index(coarse_best[0])
    ifb = kept.index(coarse_best[1])
    MAX_STEPS = len(k2_list) + len(kept)          # cannot loop forever
    for _ in range(MAX_STEPS):
        here = scores[(k2_list[i2], kept[ifb])]
        moves = []
        for a, b in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            j2, jfb = i2 + a, ifb + b
            if 0 <= j2 < len(k2_list) and 0 <= jfb < len(kept):
                moves.append(((j2, jfb), run(k2_list[j2], kept[jfb])))
        if not moves:
            break
        (bj2, bjfb), bv = max(moves, key=lambda m: m[1])
        if bv <= here:
            break                                  # local max reached
        i2, ifb = bj2, bjfb

    best = max(scores, key=lambda k: scores[k])
    if verbose:
        print(f"[sweep] coarse {coarse_best} -> best {best} "
              f"{objective}={scores[best]:.3f} in {len(scores)} runs")
    return dict(best=best, best_score=scores[best],
                best_stable=stable.get(best, False), scores=scores,
                stable=stable, n_runs=len(scores), objective=objective,
                max_delay_sym=max_delay, kfb_floor=kfb_floor,
                kfb_dropped=dropped, coarse_best=coarse_best)


def sweep_capture(rx_raw: np.ndarray, lfm_starts, sample_ppm: float = 0.0,
                  n_probe: int = 3, k2_list=None, kfb_list=None,
                  no_repass: int = None, verbose: bool = False) -> dict:
    """
    Pick one (K_2, K_fb) for a whole capture by sweeping only the first
    n_probe packets and taking the majority vote.

    Sweeping every packet is not worth what it costs. Measured on 10
    packets per channel:

      compact channel -- all 10 packets chose the same geometry, so one
        probe packet is already optimal and sweeping the rest buys
        exactly nothing.

      sparse channel -- winners scattered over K_fb 40/44/48. Probing a
        single packet landed on 44 and cost 0.74 dB across the set.
        Three packets settled the vote on 40 and stayed there through
        ten, costing 0.34 dB against per-packet tuning.

    So n_probe=3 is the default: it is where the vote stopped moving. The
    residual 0.34 dB is not the search failing -- different packets
    genuinely have slightly different optima, so no single setting can
    match per-packet tuning. It buys back roughly 10 hours per capture on
    the RX board (133 packets x ~4 min each) for ~12 minutes.

    Returns the chosen geometry, the per-probe winners and the vote, so
    a caller can see whether the vote was unanimous or marginal. A split
    vote is the signal that the channel is changing within the capture
    and a single setting may not be appropriate.
    """
    starts = list(lfm_starts)
    if not starts:
        return dict(best=None, reason="no packets")
    probe = starts[:max(1, int(n_probe))]
    winners, probes = [], []
    for i, s in enumerate(probe):
        r = sweep_taps(rx_raw, s, sample_ppm=sample_ppm, k2_list=k2_list,
                       kfb_list=kfb_list, no_repass=no_repass)
        winners.append(r["best"])
        probes.append(dict(lfm_start=s, best=r["best"],
                           best_score=r["best_score"], n_runs=r["n_runs"],
                           max_delay_sym=r["max_delay_sym"],
                           kfb_floor=r["kfb_floor"]))
        if verbose:
            print(f"[sweep] probe {i} @ {s}: {r['best']} "
                  f"{r['best_score']:.3f} dB in {r['n_runs']} runs")

    tally = {}
    for w in winners:
        tally[w] = tally.get(w, 0) + 1
    # Ties broken by the probe score, so a 1-1 split picks the better one
    # rather than whichever happened to be first.
    best_by_score = {}
    for p in probes:
        k = p["best"]
        best_by_score[k] = max(best_by_score.get(k, -np.inf), p["best_score"])
    candidate = max(tally, key=lambda k: (tally[k], best_by_score[k]))
    unanimous = len(tally) == 1

    # --- is it actually better than what we already use? ---
    #
    # Score both the candidate and the current default on the SAME probe
    # packets, so the comparison is paired and the packet-to-packet
    # variation cancels. Without this the sweep switches on differences
    # smaller than the noise -- see MIN_GAIN_DB.
    default = (P.K_2, P.K_fb)
    n_extra = 0

    def mean_over_probes(geom):
        nonlocal n_extra
        vals = []
        for s in probe:
            d = RX.decode_packet(rx_raw, s, sample_ppm=sample_ppm,
                                 K_2=geom[0], K_fb=geom[1],
                                 no_repass=no_repass)
            n_extra += 1
            vals.append(float(d["snr_eq_db"]) if d.get("ok") else -np.inf)
        return float(np.mean(vals))

    cand_mean = mean_over_probes(candidate)
    if candidate == default:
        def_mean, gain, improved = cand_mean, 0.0, False
    else:
        def_mean = mean_over_probes(default)
        gain = cand_mean - def_mean
        improved = gain >= MIN_GAIN_DB
    chosen = candidate if improved else default

    if verbose:
        print(f"[sweep] candidate {candidate} {cand_mean:.3f} dB vs default "
              f"{default} {def_mean:.3f} dB -> {gain:+.3f} dB")
        if improved:
            print(f"[sweep] adopting {chosen} (gain clears "
                  f"{MIN_GAIN_DB:.2f} dB), vote {tally}"
                  f"{'' if unanimous else '  (SPLIT)'}")
        else:
            print(f"[sweep] keeping the default {chosen} -- no candidate beat "
                  f"it by {MIN_GAIN_DB:.2f} dB, so any difference is within "
                  f"noise")
    return dict(best=chosen, K_2=chosen[0], K_fb=chosen[1],
                candidate=candidate, candidate_score=cand_mean,
                default=default, default_score=def_mean,
                gain_db=gain, improved=improved, min_gain_db=MIN_GAIN_DB,
                votes=tally, unanimous=unanimous, probes=probes,
                n_probe=len(probe), n_packets=len(starts),
                n_runs=sum(p["n_runs"] for p in probes) + n_extra)


def sweep_full(rx_raw: np.ndarray, lfm_start: int, sample_ppm: float = 0.0,
               k2_list=None, kfb_list=None, no_repass: int = None,
               ref_bits: np.ndarray = None) -> dict:
    """
    Exhaustive grid, for validating sweep_taps() on a new channel type.
    Same return shape. Use it once when the channel changes character,
    then trust the cheap search -- do not run it per packet.
    """
    k2_list = list(k2_list) if k2_list else list(DEFAULT_K2_LIST)
    kfb_list = list(kfb_list) if kfb_list else list(DEFAULT_KFB_LIST)
    return sweep_taps(rx_raw, lfm_start, sample_ppm=sample_ppm,
                      k2_list=k2_list, kfb_list=kfb_list,
                      no_repass=no_repass, kfb_floor=0, ref_bits=ref_bits,
                      coarse=max(len(k2_list), len(kfb_list)))
