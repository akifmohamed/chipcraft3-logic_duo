#####################################################################
# icc2_pnr.tcl — Place & Route with Synopsys ICC2 (floorplan -> GDS)
# Team LOGIC DUO | ChipCraft 3.0 | Round 3
# HOW TO RUN (from repo root):
#   icc2_shell -f scripts/icc2_pnr.tcl |& tee results/pnr/icc2.log
#####################################################################
set TOP       "water_sched"
set NETLIST   "results/synth/${TOP}_netlist.v"
set SDC       "results/synth/${TOP}_out.sdc"
set OUT_Q     "results/pnr"

# SAED32 setup (lab pd_scripts bundle — same family as our DC library)
set TECH_FILE "$env(HOME)/ref/tech/saed32nm_1p9m.tf"
set NDM_LIBS  "$env(HOME)/ref/CLIBs/saed32_rvt.ndm"
set TLU_MIN   "$env(HOME)/SAED32nm_EDK_08_2025/SAED32_EDK/references/orca/icc/ref/tlup/saed32nm_1p9m_Cmin.tluplus"
set TLU_MAX   "$env(HOME)/SAED32nm_EDK_08_2025/SAED32_EDK/references/orca/icc/ref/tlup/saed32nm_1p9m_Cmax.tluplus"
set MAP_FILE  "$env(HOME)/SAED32nm_EDK_08_2025/SAED32_EDK/references/orca/icc/ref/tlup/saed32nm_tf_itf_tluplus.map"

file mkdir $OUT_Q
catch {sh rm -rf ${TOP}_lib}   ;# fresh library each run

#------------------- 1) library + design ------------------------------
create_lib -technology $TECH_FILE -ref_libs $NDM_LIBS ${TOP}_lib
read_parasitic_tech -tlup $TLU_MIN -layermap $MAP_FILE -name saed32_cmin
read_parasitic_tech -tlup $TLU_MAX -layermap $MAP_FILE -name saed32_cmax
read_verilog $NETLIST
link_block
current_block $TOP
read_sdc $SDC

#------------------- 1b) wire RC models (fixes NEX-018) ---------------
set_parasitic_parameters -corners {default} \
    -early_spec saed32_cmin \
    -late_spec  saed32_cmax

#------------------- 2) floorplan -------------------------------------
initialize_floorplan -core_utilization 0.5 -core_offset {5 5 5 5}
place_pins -self

#------------------- 3) placement -------------------------------------
place_opt
report_timing    > $OUT_Q/timing_after_place.rpt
report_congestion > $OUT_Q/congestion_after_place.rpt

#------------------- 4) clock tree synthesis --------------------------
clock_opt
report_clock_timing -type skew > $OUT_Q/clock_skew.rpt

#------------------- 5) routing ---------------------------------------
route_auto
route_opt
check_legality > $OUT_Q/legality.rpt

#------------------- 6) final reports + layout ------------------------
report_timing -max_paths 20 > $OUT_Q/timing_final.rpt
report_qor                  > $OUT_Q/qor_final.rpt
report_design -physical     > $OUT_Q/design_physical.rpt
catch { report_power        > $OUT_Q/power_final.rpt }
catch { write_gds $OUT_Q/${TOP}.gds }

write_verilog -hierarchy all $OUT_Q/${TOP}_final.v
save_block
save_lib

echo ">>> PnR DONE. Layout in results/pnr/"
exit
