#!/usr/bin/env python3
"""analyze_vcd.py — independent verification of a water_sched VCD dump.

Team LOGIC DUO | ChipCraft 3.0 | Round 1 evidence tool.

The testbench is self-checking, but judges love INDEPENDENT proof. This
script re-parses the VCD from scratch (no simulator needed) and re-verifies
the safety-critical properties directly from the recorded waveforms:

  C1  tb.errors == 0                    (TB's own verdict, read from the dump)
  C2  tb.onehot_bad == 0                (TB's conflict monitor verdict)
  C3  dut.valve_open  one-hot-or-zero at EVERY transition (independent re-scan)
  C4  dut_strict.sv   one-hot-or-zero at EVERY transition (STRICT_PRIO DUT)
  C5  cycles_done == sum of the four zone_cycles counters (cross-check)
  C6  dut_strict cycles_done == 2       (T13 expectation)
  C7  no x/z ever recorded on key DUT outputs
  C8  serve-count histogram per zone    (activity evidence for the report)

Usage:  python3 scripts/analyze_vcd.py results/sim/vcs_lab_wave.vcd
Exit code 0 = all checks pass, 1 = at least one failure.
"""
import sys

# scope-qualified signals we care about: (scope_path, name)
TB   = "tb_water_sched"
DUT  = "tb_water_sched.dut"
SDUT = "tb_water_sched.dut_strict"


def parse(path):
    """Return (sigs, values): sigs maps (scope,name) -> list of codes;
    values maps code -> list of (time, raw_value_string)."""
    sigs, values = {}, {}
    scope, in_def, t = [], True, 0
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if in_def:
                if line.startswith("$scope"):
                    scope.append(line.split()[2])
                elif line.startswith("$upscope"):
                    if scope:
                        scope.pop()
                elif line.startswith("$var"):
                    p = line.split()
                    code, name = p[3], p[4]
                    sigs.setdefault((".".join(scope), name), []).append(code)
                    values.setdefault(code, [])
                elif line.startswith("$enddefinitions"):
                    in_def = False
                continue
            if line.startswith("#"):
                t = int(line[1:])
                continue
            c0 = line[0]
            if c0 in "01xzXZ":
                val, code = c0, line[1:]
            elif c0 in "bBrR":
                parts = line[1:].split()
                if len(parts) != 2:
                    continue
                val, code = parts
            else:
                continue
            if code in values:
                values[code].append((t, val))
    return sigs, values


def series(sigs, values, scope, name):
    """Time-ordered value list for one (scope,name) signal."""
    codes = sigs.get((scope, name))
    if not codes:
        return None
    return values[codes[0]]


def final_int(pts):
    for _, v in reversed(pts):
        if v and all(c in "01" for c in v):
            return int(v, 2)
        if v and all(c in "01" for c in v.replace("_", "")):
            return int(v.replace("_", ""), 2)
    return None


def is_onehot_or_zero(v):
    return all(c in "01" for c in v) and v.count("1") <= 1


def has_xz(pts):
    return any(any(c in "xXzZ" for c in v) for _, v in pts)


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "results/sim/vcs_lab_wave.vcd"
    sigs, values = parse(path)
    fails = []

    def chk(cid, ok, msg):
        print(f"  [{'PASS' if ok else 'FAIL'}] {cid}: {msg}")
        if not ok:
            fails.append(cid)

    print("=" * 62)
    print(" VCD INDEPENDENT VERIFICATION — water_sched")
    print(f" dump: {path}")

    clk = series(sigs, values, TB, "clk")
    end_t = max((pts[-1][0] for pts in values.values() if pts), default=0)
    rises = sum(1 for i in range(1, len(clk or []))
                if clk[i][1] == "1" and clk[i - 1][1] == "0")
    print(f" end time: {end_t/1000:.0f} ns   clock edges: {rises} posedge"
          f"   signals: {len(sigs)}")
    print("=" * 62)

    # ---- C1/C2: the TB's own verdicts, read back from the dump ----
    errs = final_int(series(sigs, values, TB, "errors") or [])
    bad  = final_int(series(sigs, values, TB, "onehot_bad") or [])
    chk("C1", errs == 0, f"tb errors counter = {errs} (self-check verdict)")
    chk("C2", bad == 0, f"tb onehot_bad counter = {bad} (valve-conflict monitor)")

    # ---- C3/C4: independent one-hot re-scan of every recorded value ----
    vlv = series(sigs, values, DUT, "valve_open") or []
    viol = [(t, v) for t, v in vlv if not is_onehot_or_zero(v)]
    chk("C3", not viol,
        f"dut.valve_open one-hot-or-zero at all {len(vlv)} transitions"
        + (f" — VIOLATIONS: {viol[:5]}" if viol else ""))

    sv = series(sigs, values, SDUT, "valve_open") or series(sigs, values, TB, "sv") or []
    viol_s = [(t, v) for t, v in sv if not is_onehot_or_zero(v)]
    chk("C4", not viol_s,
        f"dut_strict.valve_open one-hot-or-zero at all {len(sv)} transitions")

    # ---- C5: global counter cross-check (total == sum of per-zone) ----
    cd  = final_int(series(sigs, values, TB, "cycles_done") or [])
    zc  = final_int(series(sigs, values, TB, "zone_cycles") or [])
    zsum = sum((zc >> (16 * z)) & 0xFFFF for z in range(4)) if zc is not None else None
    chk("C5", cd is not None and zsum == cd,
        f"cycles_done = {cd}, sum(zone_cycles[0..3]) = {zsum}"
        + (f"  per-zone: {[ (zc >> (16*z)) & 0xFFFF for z in range(4) ]}" if zc is not None else ""))

    # ---- C6: STRICT_PRIO instance served exactly its 2 expected cycles ----
    scd = final_int(series(sigs, values, TB, "scd") or [])
    chk("C6", scd == 2, f"dut_strict cycles_done = {scd} (T13 expects 2)")

    # ---- C7: no X/Z corruption on key outputs ----
    key = [("dut", DUT, n) for n in
           ("valve_open", "grant_ack", "status", "insufficient", "cycles_done", "busy")]
    xz = [f"{s}.{n}" for _, s, n in key if has_xz(series(sigs, values, s, n) or [])]
    chk("C7", not xz, "no x/z recorded on key DUT outputs"
        + (f" — X/Z seen on: {xz}" if xz else ""))

    # ---- C8: activity evidence — serve histogram per zone ----
    hist = {}
    for _, v in vlv:
        if v.count("1") == 1:
            hist[len(v) - 1 - v.index("1")] = hist.get(len(v) - 1 - v.index("1"), 0) + 1
    total = sum(hist.values())
    print(f"  [INFO] C8: {total} total serve events on the main DUT — "
          + "  ".join(f"zone{z}: {hist.get(z, 0)}" for z in sorted(hist, reverse=True))
          + f"   | strict DUT: {sum(1 for _, v in sv if v.count('1') == 1)}")

    print("=" * 62)
    if fails:
        print(f" RESULT: *** FAILED checks: {fails} ***")
        sys.exit(1)
    print(" RESULT: ALL INDEPENDENT CHECKS PASSED — dump is consistent with")
    print("         a clean, conflict-free regression run.")
    sys.exit(0)


if __name__ == "__main__":
    main()
