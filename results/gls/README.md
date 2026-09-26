# Gate-Level Simulation (functional sign-off of the routed netlist)

Command (VCS W-2024.09-SP2-4):
  vcs -full64 -timescale=1ns/1ps results/pnr/water_sched_final.v tb/water_sched_tb.v
      $EDK/lib/stdcell_rvt/verilog/saed32nm.v -top tb_water_sched

- run.log  : distributed gate delays. All functional groups PASS except:
  * T2 "valve open exactly SC clocks": one-cycle edge-sampling artifact of the
    checker under real gate delays (the T2 counter checks PASS).
  * T13 (4 checks): the TB's second DUT sets STRICT_PRIO=1, but a compiled
    netlist is ONE fixed configuration; the strict variant needs its own
    synthesis and is verified at RTL level (13/13).
- run0.log : zero-delay mode removes the sampling artifact; only the T13
  strict-variant checks remain (by design, not a netlist bug).

Conclusion: the routed netlist is functionally equivalent to the RTL for the
shipped (default skip-to-fit) configuration.
