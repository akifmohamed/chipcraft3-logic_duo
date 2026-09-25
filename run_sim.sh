#!/bin/bash
#=====================================================================
# run_sim.sh — Team LOGIC DUO · ChipCraft 3.0
#   ./scripts/run_sim.sh        -> pre-check with Icarus Verilog (any PC)
#   ./scripts/run_sim.sh vcs    -> official sim with Synopsys VCS (lab)
#   ./scripts/run_sim.sh dump   -> pre-check + save waveform to results/sim
#=====================================================================
set -e
cd "$(dirname "$0")/.."

MODE="${1:-sim}"

case "$MODE" in
  vcs)
    echo ">>> VCS official simulation"
    vcs -full64 -sverilog -debug_access+all \
        rtl/water_sched.v tb/water_sched_tb.v -o simv
    ./simv | tee results/sim/vcs_log.txt
    ;;
  dump)
    echo ">>> Icarus pre-check + waveform"
    iverilog -g2005 -o sim.out rtl/water_sched.v tb/water_sched_tb.v
    ./sim.out +dump | tee results/sim/sim_log.txt
    mv -f water_sched.vcd results/sim/wave.vcd 2>/dev/null || true
    echo ">>> waveform: results/sim/wave.vcd  (open with GTKWave)"
    ;;
  *)
    echo ">>> Icarus pre-check"
    iverilog -g2005 -o sim.out rtl/water_sched.v tb/water_sched_tb.v
    ./sim.out | tee results/sim/sim_log.txt
    ;;
esac
