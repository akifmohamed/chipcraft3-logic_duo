# results/synth — Design Compiler evidence

## Status (25 Sep 2026): attempt #1 ran, run was **not usable** — bug found & fixed

* **Run:** `dc_shell` W-2024.09-SP5-3, Fri 25 Sep 2026 07:02 IST,
  workstation `dsplab122.ece.kalasalingam.ac.in`, script `scripts/dc_synth.tcl`.
* **Transcript:** `dc_shell_command.log` (this folder).
  ⚠️ dc_shell's `command.log` records only the *commands executed*, **not**
  their stdout — timing/area/power numbers are NOT in it. The report files
  (`timing.rpt`, `area.rpt`, `power.rpt`, `qor.rpt`, `violations.rpt`,
  `cells_used.rpt`, `check_design.rpt`, netlist, `.ddc`) are written to
  `results/synth/` **on the lab machine** and still need to be copied here.

## Root cause of the failed attempt — **confirmed by the 07:02 lab log**

The lab library folder name contains a **space**:

```
/home/govardhini5049/Downloads/pd_scripts-20250304T122158Z-001 modified/pd_scripts-20250304T122158Z-001/pd_scripts/ref/DBs
```

`ls` sees `saed32rvt_dlvl_ff0p95v125c_i1p16v.db` in it, but DC printed
`Warning: Can't read link_library file ... (UID-3)`,
`Error: Could not read the following target libraries (UIO-3)` and
`Error: No target library found (OPT-1312)` — because
`set search_path "$search_path <path-with-space>"` (and the lab-side sed
variant `"$search_path $DBDIR"`) let Tcl split the path into two bogus list
entries.  Fixes now in `scripts/dc_synth.tcl`:

* `lappend search_path $LAB_DB_DIR` (keeps the spaced path as ONE element),
* corner **auto-pick** via `glob` (tt/typ 25C preferred, else any saed32rvt*.db),
* pre-flight guards: RTL present, `.db` present, **no stale `water_sched.db`
  in CWD** (the 07:02 log shows `link` loading it as the design source!),
* post-`link` guard: SAED lib really linked (`get_libs *saed32*`),
* `compile_ultra` return-code guard: a failed compile no longer writes an
  unmapped GTECH netlist (the 07:02 run's `water_sched_netlist.v` had
  `VO-12: unmapped components` — **do not submit it**).

## Next lab run — checklist

```bash
cd <repo root>
dc_shell -f scripts/dc_synth.tcl |& tee results/synth/dc.log     # full stdout this time!
```

1. Watch for the `>>> target library OK` banner (proof search_path works).
2. `grep -E "WNS|slack" results/synth/timing.rpt` — need **WNS ≥ 0** @ 10 ns.
3. Copy back to this folder (git): `dc.log`, `timing.rpt`, `area.rpt`,
   `power.rpt`, `qor.rpt`, `violations.rpt`, `cells_used.rpt`,
   `check_design.rpt`, `clocks.rpt`, `water_sched_netlist.v`, `water_sched_out.sdc`.
4. Fill the **Optimization story** table in `WORKLOG.md` (v1 row) and the
   README results table with the real numbers.
5. Then optimize round (v2): compare `report_qor` before/after; candidates
   already commented in `dc_synth.tcl` (`-retime`, `-no_autoungroup`,
   `optimize_netlist -area`).

## Still needed from the lab (for Round 3 / ICC2)

`icc2_pnr.tcl` placeholders `TECH_FILE` / `NDM_LIBS` — copy the exact paths
from the lab's sample project (same `pd_scripts` bundle usually ships
`ref/ndm/` + a tech file `.tf`).
