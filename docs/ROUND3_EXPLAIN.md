# Round 3 - Physical Design (Place & Route) with Synopsys ICC2

**Team LOGIC DUO** - ChipCraft 3.0 - PS#32 "Smart Water Distribution Scheduler"
Tool: **IC Compiler II X-2025.06-SP1** | PDK: **SAED 32nm 1p9m (9 metals), RVT** | Host: sd13

## 1. Flow (scripts/icc2_pnr.tcl - single pass, ~1 min)
| Step | Command | Purpose |
|---|---|---|
| Library | create_lib (saed32nm_1p9m.tf + saed32_rvt.ndm) | RVT ref lib matches the DC netlist (_RVT cells) |
| Import | read_verilog + link_block | DC gate-level netlist (548 inst) |
| Constraints | read_sdc (water_sched_out.sdc) | same 100 MHz SDC as synthesis |
| Parasitics | read_parasitic_tech (Cmin/Cmax TLU+ + layermap) + set_parasitic_parameters | real wire RC for place/route/timing |
| Floorplan | initialize_floorplan -core_utilization 0.5 | core ~59 x 58 um |
| Pins | place_pins -self | 164 I/O pins |
| Placement | place_opt | placement + timing/drive optimization |
| CTS | clock_opt | automatic clock tree (skew 0.03 ns) |
| Routing | route_auto + route_opt | all 626 nets routed, post-route timing opt |
| Checks | check_legality | PASSED |
| Outputs | write_gds + write_verilog + reports | GDSII + post-route netlist + reports |

## 2. Results (post-route, 10 ns clock)
| Metric | Value |
|---|---|
| WNS (worst group in2reg) | **+3.07 ns MET** |
| Slack reg2out / reg2reg | +6.73 / +5.04 ns |
| TNS / violating paths / hold | 0 / 0 / 0 |
| Max tran / cap violations | 0 |
| Clock skew / latency | 0.03 ns / 0.10-0.12 ns |
| Leaf cells | 557 (122 FF, 435 comb) |
| Cell area | 1794.26 um2 |
| Total net length | 8011 um |
| Legality | PASSED |

Same critical path as synthesis: supply_avail[1] -> ... -> win_r_reg[0] (arbiter
priority chain). DC said +5.71 ns with ideal wires; after real wire RC (TLU+
Cmax), CTS latency and propagated clock, ICC2 says +3.07 ns - still MET.

## 3. Deliverables (results/pnr/)
water_sched.gds (GDSII layout) | water_sched_final.v (post-route netlist) |
timing_final.rpt | qor_final.rpt | power_final.rpt | design_physical.rpt |
legality.rpt | clock_skew.rpt | congestion_after_place.rpt |
timing_after_place.rpt | icc2.log (full transcript)

## 4. Debug war stories (all fixed in-session)
1. NEX-018 "No corner has valid parasitic" - place_opt refuses to run without
   wire RC -> added set_parasitic_parameters.
2. "cant find parasitic spec" no matter which TLU+ file we pointed at - root
   cause: -early_spec/-late_spec want the NAME of a registered parasitic model,
   not a file path. Fix: read_parasitic_tech -tlup ... -layermap
   saed32nm_tf_itf_tluplus.map -name saed32_cmin/cmax, then use those names.
3. create_clock_tree_spec -> "unknown command": legacy ICC1. ICC2 builds the
   clock tree automatically inside clock_opt.
4. write_gds takes the filename as a positional arg; write_verilog needs
   -hierarchy all and no -output flag.

## 5. Judge Q&A
- Why RVT NDM? The DC netlist cells are all _RVT (AND2X1_RVT ...), so the
  physical library must match.
- Why did slack drop 5.71 -> 3.07? Synthesis assumes ideal wires; P&R adds real
  wire RC, CTS latency and propagated clock. Still MET with ~31% margin.
- Corners? The lab NDM ships one timing view (default); DC sign-off at
  ss/0.95 V/125 C remains the conservative sign-off, P&R is physical realization.
