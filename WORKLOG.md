# WORKLOG — Team LOGIC DUO
_Engineering diary. Judges love this story — fill it during the 24 h!_

| Time | What we did | Result |
|---|---|---|
| H0 | PS analysis: Smart Water Distribution Scheduler | 6 objectives mapped to RTL blocks |
| H0 | Interface freeze + full RTL draft (`water_sched.v`) | 4-zone, priority+emergency arbiter, skip-to-fit |
| H0 | Self-checking TB (7 test groups) written | T1 reset · T2 single · T3 priority · T4 emergency · T5 insufficient · T6 skip-to-fit · T7 soak |
| H0 | Pre-lab simulation (Icarus Verilog) | 6 bugs found & fixed |
| H0 | Final regression | **ALL TESTS PASSED** (0 one-hot conflicts, counters exact) |
| H0.5 | Round-0 presentation (idea stage) | `docs/Round0_LOGIC_DUO.pptx` |
| H0.5 | Repo structure + GitHub setup | sources / tb / constraints / scripts / docs / results |
| H1 | **Round 1 (RTL & Verification):** corner-case suite T8–T12 added (reset mid-serve · priority tie · pump off · pump dies mid-flush · all-emergency back-to-back) | 12/12 groups PASS |
| H1 | RTL hygiene: separate loop vars for comb/seq blocks (race-free) | clean lint |
| H1 | Verification plan + coverage matrix (all 6 PS objectives mapped to tests) | `docs/VERIFICATION.md` |
| H1 | Report-ready waveform plots (overview + emergency + insufficient zooms) | `results/sim/*.png` |
| H1.5 | DIY manual (step-by-step, type-it-yourself with answer keys) | `docs/MANUAL.md` |
| H2 | **Jury challenge on skip-to-fit** → answer: never-dropped queue + physics + work-conserving + made policy CONFIGURABLE (`STRICT_PRIO` parameter) + T13 proof | 13/13 groups PASS |
| H-lab (25 Sep) | Official VCS regression on dsplab122 (VCS W-2024.09-SP2-4) | **PASS** — dump proves errors=0, onehot_bad=0 |
| H-lab | Independent VCD audit tool `scripts/analyze_vcd.py` + wave PNGs from the LAB dump | 8/8 checks PASS · `results/sim/wave_*.png` |
| H-lab | DC attempt #1 failed → root cause: **space in lab DB folder name** split `search_path` (Tcl list) → target lib never found | fixed: `lappend` + pre-flight guards in `dc_synth.tcl` |
| H-lab | Repo rebuilt to the promised structure; VCS build junk gitignored | rtl/ tb/ constraints/ scripts/ docs/ results/ |

## Optimization story (fill during Rounds 2–3!)
| Round | Action | WNS | Area | Power |
|---|---|---|---|---|
| v1 | first DC compile | | | |
| v2 | | | | |

## Issues found in pre-sim (good war stories for the review!)
1. TB bug: request line held high → zone re-served in a loop (fixed: drop req on ack)
2. TB bug: counters read 1 clock before DONE state finished (fixed: extra settle clock)
3. Design bug: `insufficient` flag cleared when another zone got served (fixed: live status = "any zone stuck without water")
4. DC bug (lab, 25 Sep): the SAED32 DB folder name contains a SPACE → `set search_path "$search_path <path>"` split into two bogus entries → target `.db` never found → compile ran blind (confirmed: UID-3/UIO-3/OPT-1312 in lab log; the `"$search_path $DBDIR"` sed variant has the same bug). Fixed: `lappend` + corner auto-pick + linked-lib & compile-return guards; also caught a stale `water_sched.db` in CWD shadowing `link`. Lesson: `command.log` has no stdout — always `|& tee` a real log.
