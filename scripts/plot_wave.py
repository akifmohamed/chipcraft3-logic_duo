#!/usr/bin/env python3
"""plot_wave.py — turn a VCD into report/slides-ready PNGs.

Usage:  python3 scripts/plot_wave.py results/sim/wave.vcd results/sim
Writes: wave_overview.png      — whole regression
        wave_emergency.png     — zoom on first EMERGENCY serve (grant_ack[3])
        wave_insufficient.png  — zoom on first insufficient flag rise
"""
import sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

WANT = ["zone_req", "valve_open", "grant_ack", "status",
        "insufficient", "supply_valid", "supply_avail", "cycles_done"]
LABELS = {"zone_req": "zone_req[3:0]", "valve_open": "valve_open[3:0]",
          "grant_ack": "grant_ack[3:0]", "status": "status[2:0]",
          "insufficient": "insufficient", "supply_valid": "supply_valid",
          "supply_avail": "supply_avail[7:0]", "cycles_done": "cycles_done"}


def parse_vcd(path):
    series = {}
    code2 = {}
    t = 0
    scope = []
    in_defs = True
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            if in_defs:
                if line.startswith("$scope"):
                    scope.append(line.split()[2])
                elif line.startswith("$upscope"):
                    if scope:
                        scope.pop()
                elif line.startswith("$var"):
                    p = line.split()
                    width, code, name = int(p[2]), p[3], p[4]
                    if scope == ["tb_water_sched"] and name in WANT:
                        code2[code] = (name, width)
                        series.setdefault(name, [])
                elif line.startswith("$enddefinitions"):
                    in_defs = False
                continue
            if line.startswith("#"):
                t = int(line[1:])
            elif line.startswith("b"):
                val, code = line[1:].split()
                if code in code2:
                    name, _ = code2[code]
                    v = -1 if val[0] in "xXzZ" else int(val, 2)
                    series[name].append((t, v))
            elif line[0] in "01xXzZ":
                v, code = line[0], line[1:]
                if code in code2:
                    name, _ = code2[code]
                    series[name].append((t, 1 if v == "1" else 0))
    return series


def draw(series, t0, t1, title, out):
    rows = [s for s in WANT if series.get(s)]
    fig, axes = plt.subplots(len(rows), 1, sharex=True,
                             figsize=(13, 1.05 * len(rows) + 1.2))
    if len(rows) == 1:
        axes = [axes]
    for ax, sig in zip(axes, rows):
        ts = [p[0] / 1000.0 for p in series[sig]]   # ps -> ns
        vs = [p[1] for p in series[sig]]
        ax.step(ts, vs, where="post", color="#009688", linewidth=1.4)
        ax.set_ylabel(LABELS[sig], fontsize=9, rotation=0, labelpad=90, ha="left")
        ax.grid(True, linestyle=":", alpha=0.5)
        ax.set_ylim(-0.6, max(3, max(vs) * 1.15 + 0.5))
    axes[-1].set_xlim(t0 / 1000.0, t1 / 1000.0)
    axes[-1].set_xlabel("time [ns]", fontsize=9)
    fig.suptitle(title, fontsize=13, fontweight="bold", color="#0f2041")
    fig.tight_layout(rect=[0.12, 0, 1, 0.97])
    fig.savefig(out, dpi=130)
    plt.close(fig)
    print("saved", out)


def main():
    vcd, outdir = sys.argv[1], sys.argv[2]
    s = parse_vcd(vcd)
    tmax = max((pts[-1][0] for pts in s.values() if pts), default=1)

    draw(s, 0, tmax, "water_sched — full regression overview",
         f"{outdir}/wave_overview.png")

    # zoom 1: first EMERGENCY ack (grant_ack == 8, i.e. zone3)
    for t, v in s.get("grant_ack", []):
        if v == 8:
            draw(s, max(0, t - tmax * 0.03), min(tmax, t + tmax * 0.02),
                 "EMERGENCY zone jumps the queue (grant_ack[3])",
                 f"{outdir}/wave_emergency.png")
            break

    # zoom 2: first rise of insufficient
    prev = 0
    for t, v in s.get("insufficient", []):
        if v == 1 and prev == 0:
            draw(s, max(0, t - tmax * 0.02), min(tmax, t + tmax * 0.03),
                 "Insufficient supply: flag + WAIT, no valve opens",
                 f"{outdir}/wave_insufficient.png")
            break
        prev = v


if __name__ == "__main__":
    main()
