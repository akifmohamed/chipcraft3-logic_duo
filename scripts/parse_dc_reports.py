#!/usr/bin/env python3
"""parse_dc_reports.py — pull the headline PPA numbers out of DC reports.

Team LOGIC DUO | ChipCraft 3.0 | Rounds 2-3 bookkeeping tool.

Usage:  python3 scripts/parse_dc_reports.py [results/synth]

Reads (whatever exists): timing.rpt, qor.rpt, area.rpt, power.rpt,
cells_used.rpt and prints
  * a human summary (WNS/TNS, area, dynamic+leakage power, top cells), and
  * a paste-ready WORKLOG "Optimization story" row:   | vN | action | WNS | Area | Power |

Tolerant by design: DC report cosmetics change between versions, so every
number is optional -- missing fields print as n/a instead of crashing.
"""
import os
import re
import sys


def read(d, name):
    p = os.path.join(d, name)
    if not os.path.exists(p):
        return ""
    with open(p, errors="replace") as f:
        return f.read()


def wns_tns(timing, qor):
    """Worst negative slack = min over all 'slack (...)' lines in timing.rpt."""
    slacks = [float(m) for m in
              re.findall(r'^\s*slack\s+\([^)]*\)\s+(-?[\d.]+)', timing, re.M)]
    wns = min(slacks) if slacks else None
    tns = None
    m = re.search(r'TNS[^-\d]*(-?[\d.]+)', qor)          # qor summary table
    if m:
        tns = float(m.group(1))
    if wns is None:                                       # fall back to qor
        m = re.search(r'WNS[^-\d]*(-?[\d.]+)', qor)
        if m:
            wns = float(m.group(1))
    return wns, tns


def area(area_rpt):
    m = re.search(r'Total cell area:\s*([\d.]+)', area_rpt)
    cell = float(m.group(1)) if m else None
    m = re.search(r'^Total area:\s*([\d.]+)', area_rpt, re.M)
    tot = float(m.group(1)) if m else None
    return cell, tot


def power(power_rpt):
    def grab(label):
        m = re.search(label + r'\s*=\s*([\d.]+)\s*([a-zA-Z]+)', power_rpt)
        return (float(m.group(1)), m.group(2)) if m else (None, None)
    dyn, ud = grab(r'Total Dynamic Power')
    leak, ul = grab(r'Cell Leakage Power')
    tot, ut = grab(r'Total Power')
    return (dyn, ud), (leak, ul), (tot, ut)


def top_cells(ref_rpt, n=5):
    rows = []
    for line in ref_rpt.splitlines():
        p = line.split()
        if len(p) >= 5 and p[-2].isdigit():
            rows.append((p[0], int(p[-2])))
    rows.sort(key=lambda r: -r[1])
    return rows[:n]


def main():
    d = sys.argv[1] if len(sys.argv) > 1 else "results/synth"
    timing = read(d, "timing.rpt")
    qor = read(d, "qor.rpt")
    area_r = read(d, "area.rpt")
    pow_r = read(d, "power.rpt")
    ref_r = read(d, "cells_used.rpt")
    if not any((timing, qor, area_r, pow_r)):
        print(f"No DC reports found in {d}/ -- copy timing/area/power/qor.rpt "
              "from the lab first.")
        sys.exit(1)

    wns, tns = wns_tns(timing, qor)
    cell_a, tot_a = area(area_r)
    (dyn, ud), (leak, ul), (tot, ut) = power(pow_r)
    cells = top_cells(ref_r)

    print("=" * 60)
    print(" DC PPA SUMMARY")
    print("=" * 60)
    print(f" WNS : {wns if wns is not None else 'n/a'} ns"
          f"   ({'MET' if wns is not None and wns >= 0 else 'VIOLATED' if wns is not None else '?'})"
          f"   TNS: {tns if tns is not None else 'n/a'}")
    print(f" Area: cell {cell_a if cell_a is not None else 'n/a'} um^2"
          f"   total {tot_a if tot_a is not None else 'n/a'} um^2")
    print(f" Power: dynamic {dyn if dyn is not None else 'n/a'} {ud}"
          f"   leakage {leak if leak is not None else 'n/a'} {ul}"
          f"   total {tot if tot is not None else 'n/a'} {ut}")
    if cells:
        print(" Top cells:", ", ".join(f"{c} x{n}" for c, n in cells))
    print("=" * 60)

    def f(v, u=""):
        return f"{v}{u}" if v is not None else "n/a"
    pstr = f"{tot} {ut}" if tot is not None else (
        f"{dyn} {ud}" if dyn is not None else "n/a")
    print("\nPaste-ready WORKLOG row (Optimization story table):")
    print(f"| v? | <action> | {f(wns, ' ns')} | {f(cell_a, ' um^2')} | {pstr} |")


if __name__ == "__main__":
    main()
