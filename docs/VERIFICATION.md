# VERIFICATION PLAN & RESULTS — water_sched (PS #32)

> Team LOGIC DUO · ChipCraft 3.0 · Round 1 (RTL Design & Verification)
> DUT: `rtl/water_sched.v` · TB: `tb/water_sched_tb.v` (self-checking, 13 groups)
> Evidence: `results/sim/` (lab VCS dump + independent audit + waveforms)

## 1. Strategy

1. **Self-checking TB** — every check increments `errors`; a continuous
   `always @(posedge clk)` monitor increments `onehot_bad` on any valve
   conflict.  The TB prints `ALL TESTS PASSED` only when both are zero.
2. **Two DUT instances in one regression** — the default *skip-to-fit*
   policy (`STRICT_PRIO=0`, 4 zones) **and** the strict-priority policy
   (`STRICT_PRIO=1`, 2 zones), so the jury-question behaviour is proven by
   simulation, not by argument.
3. **Independent post-run audit** — `scripts/analyze_vcd.py` re-derives the
   verdicts straight from the VCD (no simulator, no TB trust): one-hot scan of
   every transition, counter cross-checks, x/z scan, serve histograms.
4. **Deterministic + randomized stimulus** — directed corner cases plus a
   300-iteration randomized soak (requests, pump valid, supply level all
   jittered) with request-drop-on-ack zone model.

## 2. PS objectives → RTL block → tests → evidence

| # | PS objective | RTL block | Tests | Evidence |
|---|---|---|---|---|
| 1 | Zone demand tracking | demand/eligibility compare (`demand <= supply_avail`) | T2, T5, T6, T7 | C5, C8 |
| 2 | Priority assignment | priority arbiter (2-bit prio, index tie-break) | T3, T9, T12 | serve order checks |
| 3 | Conflict-free valves (one at a time) | one-hot valve decoder + FSM single-serve | T2, T7 + monitor | C2, C3, C4 |
| 4 | Emergency priority (prio 3 pre-empts) | arbiter top rank | T4, T6, T12 | `wave_emergency.png` |
| 5 | Cycle tracking | `cycles_done`, `zone_cycles[]` | T2, T3, T7 cross-check | C5 (9 == 2+2+3+2) |
| 6 | Insufficient-supply handling | `insufficient` flag + ST_WAIT, skip-to-fit | T5, T6, T10, T11 | `wave_insufficient.png` |

## 3. Test group matrix (13 groups, all self-checking)

| Group | Scenario | Key assertions |
|---|---|---|
| T1 | Reset values | valves 0, counters 0, flag clear, status IDLE |
| T2 | Single-zone serve | valve one-hot, open **exactly** SERVE_CYCLES clocks, counters +1 |
| T3 | Priority order z2>z1>z0 | serve order, wrong-winner detector inside `serve_and_clear` |
| T4 | Emergency jumps queue | z3 acked before z2 |
| T5 | Supply < demand | flag set, status WAIT, **no valve**, clears after refill+serve |
| T6 | Skip-to-fit | oversized emergency waits, smaller zone served first, flag stays live |
| T7 | 300-iter random soak | `onehot_bad==0`, `cycles_done == Σ zone_cycles` |
| T8 | Async reset **mid-serve** | valves forced closed, counters cleared, clean restart |
| T9 | Priority tie | lowest zone index wins, all 4 served in index order |
| T10 | Pump OFF before serve | flag + WAIT, no valve; served after pump restart |
| T11 | Pump dies **mid-flush** | started serve always completes (valve safety) |
| T12 | All zones EMERGENCY, back-to-back | index order within same prio, no dropped grants |
| T13 | `STRICT_PRIO=1` (2nd DUT) | stuck HIGH zone blocks lower zone; after refill HIGH served **first**, then LOW; exactly 2 cycles |

Continuous monitors (run for the whole regression, both DUTs):
* `onehot_bad` — >1 valve bit high at any posedge after reset.
* wrong-winner check inside `serve_and_clear` — any unexpected `grant_ack`.
* watchdog 500 µs — hangs fail loudly instead of silently passing.

## 4. Results

| Run | Tool | Result |
|---|---|---|
| Pre-lab regression | Icarus Verilog (`scripts/run_sim.sh`) | 13/13 groups PASS |
| **Official lab run** | **VCS W-2024.09-SP2-4** (25 Sep 2026) | **PASS** — `errors=0`, `onehot_bad=0` (`results/sim/VCS_LAB_RUN.md`) |
| Independent VCD audit | `scripts/analyze_vcd.py` | **8/8 checks PASS** (`results/sim/vcd_analysis.txt`) |
| Serve activity | dump histogram | 41 serves main DUT (z3:11 z2:11 z1:10 z0:9), 2 strict DUT |

## 5. Reproduce

```bash
scripts/run_sim.sh            # quick pre-check (Icarus, any machine)
scripts/run_sim.sh dump       # + waveform -> results/sim/wave.vcd
scripts/run_sim.sh vcs        # official flow (lab): VCS log -> results/sim/vcs_log.txt
python3 scripts/plot_wave.py   results/sim/vcs_lab_wave.vcd results/sim
python3 scripts/analyze_vcd.py results/sim/vcs_lab_wave.vcd   # exit 0 = pass
```

## 6. Known TB gotchas we hit (war stories for the review)

1. Request line held high re-served a zone in a loop → zone model drops `req` on `ack`.
2. Counters read one clock before ST_DONE finished → extra settle clock in `serve_and_clear`.
3. `insufficient` cleared when an unrelated zone was served → flag is now live status
   ("any zone stuck without water"), asserted in T6 after the small zone is served.
4. `($random % 200)` can be **negative** and wrap into huge demands → unsigned
   `{$random} % 200` in the soak.
