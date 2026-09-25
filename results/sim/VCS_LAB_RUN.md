# Official VCS regression — lab run, independently verified

> **Run:** Synopsys VCS `W-2024.09-SP2-4_Full64`, Fri 25 Sep 2026 06:27 IST,
> KARE DSPSD lab workstation (`dsplab122.ece.kalasalingam.ac.in`)
> **Dump:** `vcs_lab_wave.vcd` (this folder) — `$dumpvars(0, tb_water_sched)`,
> full hierarchy, 1 ps resolution, 5546 ns ≈ 555 clock cycles @ 100 MHz.
> **Verdict tool:** `../../scripts/analyze_vcd.py` (pure-Python, no simulator)
> **Raw verdict:** `vcd_analysis.txt` in this folder.

## Result: **PASS** — 8/8 independent checks

| # | Check (re-derived from the dump, not from the console) | Result |
|---|---|---|
| C1 | TB self-check verdict: `tb.errors` final value | **0** ✔ |
| C2 | TB valve-conflict monitor: `tb.onehot_bad` final value | **0** ✔ |
| C3 | `dut.valve_open` one-hot-or-zero at **every** recorded transition (83) | ✔ |
| C4 | `dut_strict.valve_open` (STRICT_PRIO instance) one-hot-or-zero (5) | ✔ |
| C5 | Counter integrity: `cycles_done = 9 == Σ zone_cycles` (`z0:2 z1:2 z2:3 z3:2`) | ✔ |
| C6 | STRICT_PRIO instance served exactly its 2 expected cycles (T13) | ✔ |
| C7 | No `x`/`z` ever recorded on valve_open / grant_ack / status / insufficient / cycles_done / busy | ✔ |
| C8 | Activity evidence: **41 serve events** on main DUT (z3:11, z2:11, z1:10, z0:9) + 2 on strict DUT | ✔ |

## Why `cycles_done = 9` and not 41

Test **T8 deliberately asserts async reset in the middle of a serve**, which
clears the counters.  The 41 valve-open pulses span the whole regression
(T2–T7 soak **before** the reset, plus T9–T12 **after** it).  The 9 counted
cycles are exactly the post-reset serves: T9 tie-break (4) + T10 pump-off
recovery (1) + T11 mid-flush pump loss (1) + T12 all-emergency back-to-back
(3) — and the per-zone split `2+2+3+2` matches that expectation perfectly.
This is the strongest single piece of evidence that the RTL counters behave
exactly as specified under reset, starvation and emergency traffic.

## Waveforms (report / slide ready)

| File | What it shows |
|---|---|
| `wave_overview.png` | full regression: demand traffic, one-hot valves, soak randomness, T8 reset at ≈4.8 µs |
| `wave_emergency.png` | zoom: EMERGENCY zone 3 pre-empts the queue (`grant_ack[3]`) |
| `wave_insufficient.png` | zoom: `insufficient` rises, FSM holds WAIT, **no valve opens** |

Regenerate at any time:

```bash
python3 scripts/plot_wave.py   results/sim/vcs_lab_wave.vcd results/sim
python3 scripts/analyze_vcd.py results/sim/vcs_lab_wave.vcd
```
