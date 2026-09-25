# ROUND-2 EXPLAINER — what we submit and how we got the numbers

> Team LOGIC DUO · water_sched @ SAED 32 nm · DC W-2024.09-SP5-3 (sd13, 25 Sep 22:10 IST)

## 1. What we submit (all in results/synth/)

| File | What it proves |
|---|---|
| water_sched_netlist.v | gate-level netlist — fully mapped (0 GTECH cells) |
| water_sched_out.sdc | the timing constraints that were applied |
| timing.rpt | WNS +5.71 ns MET, 0 violating paths @ 100 MHz |
| area.rpt | 1758.68 um2 total cell area |
| power.rpt | 160.8 uW total (74.8 dynamic + 86.0 leakage) |
| qor.rpt | summary: 0 hold violations, 0 DRC violations |
| violations.rpt | "This design has no violated constraints." |
| check_design.rpt | clean (only benign LINT-1 dangling cells) |
| cells_used.rpt | which SAED32 cells the design maps to |
| dc.log | full tool transcript — reproducible proof of the whole run |

## 2. The flow we ran (simple words)

verified RTL -> read + elaborate -> link to SAED32 worst-case library
-> apply SDC (100 MHz + margins + design rules)
-> compile_ultra (map to gates + optimize PPA)
-> optimize_netlist -area (convergence pass)
-> reports + netlist + SDC + ddc

1. RTL was already proven — 13/13 self-checking test groups, lab VCS dump,
   independent 8/8 VCD audit (Round 1 evidence in results/sim/).
2. Library choice = honest sign-off corner: saed32rvt_ss0p95v125c — slow
   silicon, 0.95 V, 125 C (the PDK ships no tt corner). Meeting 10 ns THERE
   means real silicon at normal conditions is even faster.
3. Constraints (SDC): 10 ns clock, 0.15 uncertainty + 0.10 transition,
   2.0 ns IO delays, async reset false-pathed, max_fanout 20,
   max_transition 0.5 ns, 0.03 pF output load.
4. compile_ultra mapped at ultra-high effort with dynamic + leakage power
   optimization ON and a realistic 2500 um2 area budget.
5. Iterations v1 -> v2:
   v1   first mapped compile (set_max_area 0 minimize-idiom)
   v1.1 realistic set_max_area 2500 -> constraints report fully clean
   v2   extra optimize_netlist -area pass -> area 1760.71 -> 1758.68 um2,
        power moved +0.2%, timing identical -> DESIGN CONVERGED.

## 3. The optimization story (numbers straight from dc.log)

| Knob | Effect | Before -> After |
|---|---|---|
| compile_ultra mapping passes | area | 1934.5 -> 1760.7 um2 (-9%) |
| set_leakage_optimization true | leakage power | 142.1 -> 86.1 uW (-39%) |
| set_dynamic_optimization true | dynamic power | -> 74.3 uW |
| constant-register removal (auto) | FF count | 124 -> 122 (state_reg[2], timer_reg[15] proven constant) |
| realistic set_max_area 2500 | constraints report | "1 violated" -> "no violated constraints" |
| optimize_netlist -area (v2) | convergence proof | 1760.71 -> 1758.68 um2, PPA stable within 0.2% |

Final: WNS +5.71 ns, TNS 0, 0 violating paths, 0 hold violations,
0 DRC violations, 1758.68 um2, 160.8 uW — at the worst-case corner.

## 4. Judge Q&A

Q: Why the ss/0.95V/125C corner instead of typical?
A: No tt corner in the PDK; ss@0.95V/125C is worst-case-at-nominal.
   Meeting timing there is a stronger claim.

Q: What is your critical path?
A: 26 logic levels, 2.09 ns delay through the demand-compare/priority
   arbiter into the state registers — against a 10 ns budget (+5.71 slack).

Q: Why does check_design show 8 warnings?
A: All LINT-1 "cell does not drive nets" — leftovers after DC removed two
   proven-constant registers. No latches, no multi-driven nets.

Q: Is the netlist really mapped?
A: Yes — grep -c GTECH water_sched_netlist.v returns 0; cells_used.rpt
   lists real SAED32 cells (DFFX1, AO21X1, ...).

Q: How do we know the netlist behaves like the RTL?
A: The RTL passed 13/13 self-checking tests; the netlist keeps the identical
   port interface, and netlist+SDC are ready for gate-level sim + ICC2.

Q: Did you try to optimize further?
A: Yes — v2 ran an extra optimize_netlist -area pass. Area moved -0.12%,
   power +0.2%, timing identical: the design was already converged.

## 5. 30-second verbal pitch (memorize this)

"We synthesized our verified water-scheduler RTL with Design Compiler at the
worst-case SAED32 corner — slow process, 0.95 volts, 125 degrees. With
compile_ultra, leakage and dynamic power optimization on, we cut area 9%
and leakage 39% during optimization, and DC even removed two flip-flops it
proved constant. An extra area pass confirmed convergence. Final numbers:
timing met with +5.71 ns slack at 100 MHz, 1759 square microns, 161
microwatts total, and zero violated constraints — timing, hold, fanout,
transition, capacitance, all clean."
