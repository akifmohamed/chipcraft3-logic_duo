# 💧 Smart Water Distribution Scheduler

> **ChipCraft 3.0 — RTL to Physical Design Hackathon** (24 h)
> Team **LOGIC DUO** · Government College of Engineering, Srirangam
> Flow: `Verilog RTL → VCS/Verdi → Design Compiler → PPA → Netlist → ICC2 Layout` (SAED 32 nm)

## 📋 Problem (in 2 lines)
Design a controller that schedules water to multiple zones based on **demand,
priority and available supply**. It serves the most urgent zone first, opens
only **one valve at a time**, and never wastes water when supply is short.

**6 objectives:** zone demand tracking · priority assignment · conflict-free
valves · emergency priority · cycle tracking · insufficient-supply handling.

## 🧠 Architecture

```
 zone_req[], zone_prio[], zone_demand[]        supply_avail, supply_valid
        │                                              │
        ▼                                              ▼
 ┌──────────────┐   eligible (fits supply)   ┌──────────────────┐
 │ DEMAND TRACK │───────────────────────────▶│ PRIORITY ARBITER │
 └──────────────┘                            │ (emerg = prio 3) │
                                             └────────┬─────────┘
                                                      │ one-hot pick
                          ┌───────────────────────────▼──────────┐
                          │  FSM: IDLE → SERVE → DONE / WAIT     │
                          │  skip-to-fit · serve timer           │
                          └───┬───────────────┬──────────────┬───┘
                              ▼               ▼              ▼
                       valve_open[3:0]   grant_ack[3:0]   status[2:0]
                       (one-hot safe)    (serve complete)  + insufficient
                                              │
                                       cycles_done[31:0]
                                       zone_cycles[63:0]
```

**Our innovation — "Skip-to-Fit":** if the highest-priority zone's demand
exceeds available water, we serve a smaller zone that *fits* instead of
stalling the whole city, while a live `insufficient` flag reports the shortage.

## 📁 Repository layout
```
├── README.md              ← you are here
├── WORKLOG.md             ← engineering diary (optimization story for judges)
├── rtl/                   ← SOURCES: synthesizable Verilog
│   └── water_sched.v
├── tb/                    ← self-checking testbench (7 test groups)
│   └── water_sched_tb.v
├── constraints/           ← SDC timing constraints (100 MHz)
│   └── water_sched.sdc
├── scripts/               ← tool flows
│   ├── run_sim.sh         ← simulation (iverilog pre-check / VCS official)
│   ├── dc_synth.tcl       ← Synopsys Design Compiler
│   ├── icc2_pnr.tcl       ← Synopsys ICC2 (floorplan→route→GDS)
│   ├── plot_wave.py       ← VCD → report-ready waveform PNGs
│   ├── analyze_vcd.py     ← independent VCD audit (no simulator needed)
│   └── make_ppt.py        ← Round-0 deck generator
├── docs/                  ← PS, battle guide, cheat sheet, presentation
└── results/               ← ALL outputs & reports (see results/README.md)
    ├── sim/               ← sim logs + waveforms
    ├── synth/             ← DC: netlist + timing/area/power/QoR reports
    └── pnr/               ← ICC2: layout + final reports
```

## 🚀 Quick start
```bash
# functional pre-check (works on any machine)
./scripts/run_sim.sh

# official flow (KARE lab workstations)
vcs -full64 -sverilog -debug_access+all rtl/water_sched.v tb/water_sched_tb.v -o simv && ./simv
dc_shell   -f scripts/dc_synth.tcl |& tee results/synth/dc.log
icc2_shell -f scripts/icc2_pnr.tcl | tee results/pnr/icc2.log

# evidence tools (any machine)
python3 scripts/plot_wave.py   results/sim/vcs_lab_wave.vcd results/sim
python3 scripts/analyze_vcd.py results/sim/vcs_lab_wave.vcd   # exit 0 = PASS
```

## ✅ Results
| Stage | Result | Where |
|---|---|---|
| RTL + TB (pre-sim) | **ALL TESTS PASSED** (13/13 groups, 0 one-hot conflicts) | `results/sim/`, `docs/VERIFICATION.md` |
| Corner-case suite | reset mid-serve · priority tie · pump off · mid-flush pump loss · all-emergency · STRICT_PRIO mode | `docs/VERIFICATION.md` |
| **VCS simulation (lab, 25 Sep)** | **PASS** — `errors=0`, `onehot_bad=0`, 41 serves, independent 8/8 VCD audit | `results/sim/VCS_LAB_RUN.md` |
| Waveforms (from lab VCS dump) | overview + emergency + insufficient zooms | `results/sim/wave_*.png` |
| DC synthesis (PPA) | **compile_ultra OK** (25 Sep, attempt #4) @ saed32rvt_ss0p95v125c, 10 ns — WNS +5.71 ns MET, 1758.68 um2, 160.8 uW, netlist+reports uploaded | `results/synth/` |
| ICC2 layout | _at lab_ | `results/pnr/` |

## 🎯 Key values
| Item | Value |
|---|---|
| Zones / priority | NZONES = 4 · 0=Low, 1=Med, 2=High, **3=Emergency** |
| Water units | DATA_W = 8 (0–255) |
| Serve window | SERVE_CYCLES = 16 clocks |
| Clock target | 100 MHz (10 ns), SAED 32 nm |
| Status codes | 0 IDLE · 1 SERVE · 2 WAIT · 3 DONE |

## 👥 Team
- Akif Mohamed J
- Nandikha M

_Made for ChipCraft 3.0 · IEEE EDS / SSCS / IETE · KARE University_
