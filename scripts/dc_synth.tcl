#=====================================================================
# dc_synth.tcl  —  RTL -> gate-level netlist with Synopsys Design Compiler
# Team LOGIC DUO | ChipCraft 3.0
# HOW TO RUN (on the lab machine):   dc_shell -f dc_synth.tcl | tee dc.log
#=====================================================================

#---------------------------------------------------------------------
# 0) EDIT THESE for your lab (ask the lab incharge / see the sample project)
#---------------------------------------------------------------------
set TOP        "water_sched"
set RTL_FILES  "rtl/water_sched.v"
set SDC_FILE   "constraints/water_sched.sdc"
set OUT        "results/synth"

# --- library setup: SAED 32nm from the lab sample project (dsplab122) ---
# BUGFIX 2026-09-25: the lab folder name contains a SPACE
# ("...001 modified/...").  The old one-liner
#     set search_path "$search_path <path-with-space>"
# made Tcl split it into TWO bogus list entries, so the .db was never found
# and link/compile ran without the target library.  lappend keeps it as ONE
# list element.  (Even better on the lab machine: rename the folder without
# the space, then update LAB_DB_DIR.)
set LAB_DB_DIR "/home/govardhini5049/Downloads/pd_scripts-20250304T122158Z-001 modified/pd_scripts-20250304T122158Z-001/pd_scripts/ref/DBs"
lappend search_path $LAB_DB_DIR
set target_library "saed32rvt_dlvl_ff0p95v125c_i1p16v.db"
set link_library   "* $target_library"

# ---- fail LOUDLY and early instead of silently compiling garbage ----------
if {![file exists $RTL_FILES]} {
    echo "ERROR: '$RTL_FILES' not found -- run dc_shell from the REPO ROOT:"
    echo "       dc_shell -f scripts/dc_synth.tcl |& tee results/synth/dc.log"
    exit 1
}
if {![file exists [file join $LAB_DB_DIR $target_library]]} {
    echo "ERROR: target library NOT FOUND at:"
    echo "       [file join $LAB_DB_DIR $target_library]"
    echo "       -> ls that DBs folder on this machine and fix LAB_DB_DIR /"
    echo "          target_library above (the exact .db filename matters)."
    exit 1
}
echo ">>> target library OK: [file join $LAB_DB_DIR $target_library]"

file mkdir $OUT
define_design_lib WORK -path ./work

#---------------------------------------------------------------------
# 1) read RTL
#---------------------------------------------------------------------
analyze -format verilog $RTL_FILES
elaborate $TOP
current_design $TOP
link
uniquify

check_design > $OUT/check_design.rpt
# READ THIS REPORT! look for: unmapped refs, latches, multi-driven nets

#---------------------------------------------------------------------
# 2) constraints
#---------------------------------------------------------------------
source $SDC_FILE
report_clock  > $OUT/clocks.rpt

#---------------------------------------------------------------------
# 3) synthesis / optimization  (PPA = Power Performance Area)
#---------------------------------------------------------------------
# area goal: push area down
set_max_area 0

# power switches (cheap wins for the 30% "synthesis quality" score)
set_dynamic_optimization true
if {[shell_is_in_topographical_mode]} {
    # topo mode only
}
set_leakage_optimization true

# map + optimize
compile_ultra

# if timing still failing (negative slack), try:
#   compile_ultra -retime
# if area too big, try:
#   compile_ultra -no_autoungroup  (keep hierarchy -> smaller in some cases)
#   optimize_netlist -area

#---------------------------------------------------------------------
# 4) reports  (these files go in your SUBMISSION - all 4!)
#---------------------------------------------------------------------
report_timing  -max_paths 20           > $OUT/timing.rpt
report_area    -hierarchy              > $OUT/area.rpt
report_power                            > $OUT/power.rpt
report_qor                              > $OUT/qor.rpt
report_constraint -all_violators        > $OUT/violations.rpt
report_reference                        > $OUT/cells_used.rpt

#---------------------------------------------------------------------
# 5) write outputs
#---------------------------------------------------------------------
write -hierarchy -format verilog -output $OUT/${TOP}_netlist.v
write_sdc  $OUT/${TOP}_out.sdc
write -format ddc -hierarchy -output $OUT/${TOP}.ddc

echo ">>> DONE. Check $OUT/timing.rpt -> need WNS >= 0 (no negative slack)"
exit
