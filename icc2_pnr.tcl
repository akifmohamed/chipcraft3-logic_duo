#####################################################################
# icc2_pnr.tcl — Place & Route with Synopsys ICC2 (floorplan -> route)
# Team LOGIC DUO | ChipCraft 3.0
# HOW TO RUN (on the lab machine):  icc2_shell -f icc2_pnr.tcl | tee icc2.log
# NOTE: paths below are EXAMPLES — copy the tech setup from the lab's
#       sample project given by the incharge (NDM/TF files for SAED32).
#####################################################################

#------------------- EDIT THESE (lab will give exact paths) ----------
set TOP        "water_sched"
set NETLIST    "../results/synth/${TOP}_netlist.v"
set SDC        "../results/synth/${TOP}_out.sdc"
set OUT_Q      "../results/pnr"

set TECH_FILE  "/path/to/saed32/tech/techfile.tf"     ;# ask lab
set NDM_LIBS   "/path/to/saed32/ndm/saed32nm.ndm"     ;# ask lab

file mkdir $OUT_Q

#------------------- 1) create library & read design ------------------
create_lib -technology $TECH_FILE -ref_libs $NDM_LIBS ${TOP}_lib

read_verilog $NETLIST
link_block
current_block $TOP

read_sdc $SDC            ;# same constraints as synthesis

#------------------- 2) floorplan -------------------------------------
# small design -> small core. start tight, grow if routing is congested
initialize_floorplan -core_offset {5 5 5 5} -core_size {80 80}

# pins: let the tool place IOs (or use set_io_pin_constraint later)
place_pins -self

#------------------- 3) placement -------------------------------------
place_opt
report_timing > $OUT_Q/timing_after_place.rpt
report_congestion > $OUT_Q/congestion_after_place.rpt

#------------------- 4) clock tree synthesis --------------------------
# one clock, small fanout design -> simple CTS
create_clock_tree_spec
clock_opt
report_clock_timing -type skew > $OUT_Q/clock_skew.rpt

#------------------- 5) routing ---------------------------------------
route_opt
check_legality > $OUT_Q/legality.rpt

#------------------- 6) final reports & outputs -----------------------
report_timing  -max_paths 20  > $OUT_Q/timing_final.rpt
report_area                    > $OUT_Q/area_final.rpt
report_power                   > $OUT_Q/power_final.rpt
report_qor                     > $OUT_Q/qor_final.rpt
report_design -physical        > $OUT_Q/design_physical.rpt

# final netlist + layout
write_verilog -hierarchy -output $OUT_Q/${TOP}_final.v
write_gds     -output $OUT_Q/${TOP}.gds
save_block
save_lib

echo ">>> PnR DONE. Open layout:  icc2_gui  -> File>Open Block"
exit
