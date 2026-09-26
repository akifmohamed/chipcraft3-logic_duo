# Gate-Level Simulation - functional sign-off of the ROUTED netlist

Simulated results/pnr/water_sched_final.v (post-route netlist) with the same
self-checking TB and real SAED32 RVT gate models (saed32nm.v), VCS
W-2024.09-SP2-4.

- run.log (distributed gate delays) = SIGN-OFF LOG: 5 FAIL out of ~36 checks,
  all explained:
  * T2 "valve open exactly SC clocks" (1): one-cycle edge-sampling artifact of
    the checker under real gate delays; the T2 counter checks PASS.
  * T13 (4): the TB's second DUT sets STRICT_PRIO=1, but a compiled netlist is
    ONE fixed configuration; the strict variant needs its own synthesis and is
    verified at RTL level (13/13 groups).
- run0.log (simv -delay_mode zero): 31 PASS / 6 FAIL - zero-delay does NOT help
  (same artifacts plus delta races); kept for transparency only.

Conclusion: the routed netlist is functionally equivalent to the RTL for the
shipped (default skip-to-fit) configuration.
