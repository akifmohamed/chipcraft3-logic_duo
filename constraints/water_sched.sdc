#-----------------------------------------------------------------------------
# constraints.sdc  —  Team LOGIC DUO  —  ChipCraft 3.0
# Target: 100 MHz (10 ns).  If your PS/lab brief says a different clock,
# ONLY change the -period value below.
#-----------------------------------------------------------------------------

# ---- main clock ----
create_clock -name core_clk -period 10 [get_ports clk]
set_clock_uncertainty 0.15 [get_clocks core_clk]
set_clock_transition  0.10 [get_clocks core_clk]

# ---- input / output delays (board-level margins) ----
set_input_delay  2.0 -clock core_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 2.0 -clock core_clk [all_outputs]

# reset is asynchronous -> do not time it against the clock
set_false_path -from [get_ports rst_n]

# ---- design rule constraints ----
set_max_fanout     20  [current_design]
set_max_transition 0.5 [current_design]
set_load           0.03 [all_outputs]

# ---- optional (uncomment and fix the cell name to match your library!) ----
# set_driving_cell -lib_cell INVX1 [remove_from_collection [all_inputs] [get_ports clk]]
