open_lib water_sched_lib
open_block water_sched
source $env(HOME)/ref/tech/saed32nm_ant_1p9m.tcl
file mkdir results/pnr
redirect results/pnr/antenna_rules.rpt { report_antenna_rules }
puts "ANT-RULES: [get_antenna_rule_names]"
set r1 [catch { redirect results/pnr/antenna_check.rpt { check_antenna -verbose } }]
set r2 [catch { signoff_calculate_hier_antenna_property }]
set r3 [catch { redirect -append results/pnr/antenna_check.rpt { report_antenna -all_violations } }]
puts "ANT-RESULTS r1=$r1 r2=$r2 r3=$r3"
exit
