#=====================================================================
# dc_synth.tcl  —  RTL -> gate-level netlist with Synopsys Design Compiler
# Team LOGIC DUO | ChipCraft 3.0
# HOW TO RUN (on the lab machine):   dc_shell -f scripts/dc_synth.tcl |& tee results/synth/dc.log
#=====================================================================

#---------------------------------------------------------------------
# 0) EDIT THESE for your lab (ask the lab incharge / see the sample project)
#---------------------------------------------------------------------
set TOP        "water_sched"
set RTL_FILES  "rtl/water_sched.v"
set SDC_FILE   "constraints/water_sched.sdc"
set OUT        "results/synth"

# --- library setup: SAED 32nm from the lab sample project (dsplab122) ---
# BUGFIX 2026-09-25 (confirmed by lab log 07:02): the lab folder name contains
# a SPACE ("...001 modified/...").  `set search_path "$search_path <path>"`
# (and the sed-based "$search_path $DBDIR" variant!) let Tcl split it into TWO
# bogus list entries, so the .db -- although visible to `ls` -- was never
# found:  UID-3 / UIO-3 / OPT-1312.  lappend keeps it as ONE list element.
set LAB_DB_DIR "/home/govardhini5049/Downloads/pd_scripts-20250304T122158Z-001 modified/pd_scripts-20250304T122158Z-001/pd_scripts/ref/DBs"
lappend search_path $LAB_DB_DIR

# --- corner auto-pick + library HEALTH PROBE -------------------------------
# The 07:50 lab run proved search_path is now correct (braced list entry) and
# the file exists, yet DC still said UID-3 -> the .db FILE ITSELF is unreadable
# (corrupted download / git-lfs stub / html / empty / directory / perms).
# So we no longer trust names: every candidate is probed (dir? empty? perm?
# stub? gzip? liberty?) and the first HEALTHY one wins.  .lib and .gz fallbacks
# are included -- DC reads plain liberty and gzip natively (alib cache).
proc probe_lib {path} {
    if {[file isdirectory $path]}   { return bad-dir }
    if {[file size $path] == 0}     { return bad-empty }
    if {[catch {set fh [open $path r]} err]} { return bad-perm }
    fconfigure $fh -translation binary
    set head [read $fh 96]; close $fh
    if {[string length $head] < 4} { return bad-empty }
    scan [string index $head 0] %c c0
    scan [string index $head 1] %c c1
    if {$c0 == 31 && $c1 == 139}    { return ok-gzip }
    if {[regexp {^library\s*\(} $head]} { return ok-liberty }
    set low [string tolower $head]
    if {[string match *git-lfs* $low] || [string match {*<html*} $low]
        || [string match {*<!doctype*} $low]} { return bad-stub }
    return unknown
}

set target_library ""
set probe_kind   ""
foreach pat {*saed32rvt*tt*25c* *saed32rvt*typ*25c* *saed32rvt*25c* *saed32rvt*} {
    foreach ext {.db .lib .db.gz .lib.gz} {
        foreach c [lsort [glob -nocomplain -directory $LAB_DB_DIR -- ${pat}${ext}]] {
            set k [probe_lib $c]
            if {[string match ok-* $k] || $k eq "unknown"} {
                set target_library [file tail $c]
                set probe_kind $k
                break
            }
        }
        if {$target_library ne ""} break
    }
    if {$target_library ne ""} break
}
if {$target_library eq ""} {
    echo "ERROR: no readable SAED32 library in $LAB_DB_DIR -- probe results:"
    foreach c [lsort [glob -nocomplain -directory $LAB_DB_DIR -- *]] {
        echo "    [probe_lib $c]   $c"
    }
    echo "    -> ask the lab incharge for the real SAED32 .db/.lib, or re-unpack"
    echo "       the PDK zip (git-lfs/html stubs mean a broken download)."
    exit 1
}
set link_library "* $target_library"
set dbpath [file join $LAB_DB_DIR $target_library]
echo ">>> CHOSEN CORNER: $target_library  (probe: $probe_kind, [file size $dbpath] bytes)"
if {$probe_kind ne "ok-gzip"} {
    set fh [open $dbpath r]; fconfigure $fh -translation binary
    set head [read $fh 48]; close $fh
    echo ">>> lib head: [string map [list \n \\n \t \\t] $head]"
}

# ---- fail LOUDLY and early instead of silently compiling garbage ----------
if {![file exists $RTL_FILES]} {
    echo "ERROR: '$RTL_FILES' not found -- run dc_shell from the REPO ROOT:"
    echo "       dc_shell -f scripts/dc_synth.tcl |& tee results/synth/dc.log"
    exit 1
}

file mkdir $OUT
define_design_lib WORK -path ./work

#---------------------------------------------------------------------
# 1) read RTL
#---------------------------------------------------------------------
analyze -format verilog $RTL_FILES
elaborate $TOP
current_design $TOP
link

# guard: did the SAED target library ACTUALLY link? (UID-3/UIO-3 proof check)
set nlib 0
catch {set nlib [sizeof_collection [get_libs *saed32*]]}
if {$nlib == 0} {
    echo "ERROR: no SAED32 library linked -- search_path/target_library wrong?"
    exit 1
}
echo ">>> SAED32 library linked OK ($nlib lib(s))"
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
set cu_ok [compile_ultra]
if {!$cu_ok} {
    echo "ERROR: compile_ultra FAILED (look for OPT-/UIO- errors above)."
    echo "       NOT writing netlist/reports -- fix the library first."
    exit 1
}
echo ">>> compile_ultra OK"

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
