#!/usr/bin/env python3
"""Measure glass/list frame costs through the existing profile-only VM extensions.

Build: flutter run --profile --flavor standard --dart-define=GLASS_PERF=1 -d DEVICE
Use --dart-define=GLASS_ADAPTIVE=true to include production quality adaptation.
Run: python3 tool/glass_profile_bench.py --base VM_URL --route / --output frames.json
The URL must be reachable from the host (adb forward on Android).
No logcat, account credentials, extra Python packages, or device-specific coordinates.
"""

import argparse
import json
from pathlib import Path
import statistics
import time
import urllib.parse
import urllib.request


DEFAULTS = {
    "quality": "premium", "contentAware": "on", "blur": "off",
    "shadows": "2", "bar": "liquid", "headerBlur": "on",
    "barBlur": "on", "mask": "high",
}
VARIANTS = {
    "production": {},
    "blurred": {"blur": "on"},
    "material": {},
    "standard": {"quality": "standard"},
    "no-sample": {"contentAware": "off"},
    "no-shadow": {"shadows": "0"},
}


class Probe:
    def __init__(self, base):
        self.base = base.rstrip("/") + "/"
        self.isolate = None
        for isolate in self.rpc("getVM").get("isolates", []):
            info = self.rpc("getIsolate", isolateId=isolate["id"])
            if "ext.glassperf.frames" in info.get("extensionRPCs", []):
                self.isolate = isolate["id"]
                break
        if self.isolate is None:
            raise RuntimeError("No GLASS_PERF isolate: install a profile benchmark build")

    def rpc(self, method, **params):
        url = self.base + method + "?" + urllib.parse.urlencode(params)
        with urllib.request.urlopen(url, timeout=30) as response:
            result = json.load(response)
        if "error" in result:
            raise RuntimeError(result["error"])
        return result["result"]

    def ext(self, extension, **params):
        return self.rpc("ext.glassperf." + extension, isolateId=self.isolate, **params)

    def configure(self, variant):
        config = DEFAULTS | VARIANTS[variant]
        self.ext("mode", value="plain" if variant == "material" else "liquid")
        for name, value in config.items():
            result = self.ext("knob", name=name, value=value)
            if not result.get("ok"):
                raise RuntimeError(f"Knob rejected: {name}={value}")
        # Discard transitions/quality-adapter warmup before measuring steady scroll.
        time.sleep(1)

    def swipe(self, upward):
        self.ext("swipe", dy="-340" if upward else "340", ms="250",
                 x=".55", y=".75" if upward else ".3")
        time.sleep(.65)


def percentile(values, quantile):
    values = sorted(values)
    return values[round((len(values) - 1) * quantile)] / 1000


def summarize(raw):
    frames, budget = raw["frames"], raw["budgetUs"]
    if len(frames) < 60:
        raise RuntimeError(f"Only {len(frames)} frames: verify visible scrollable content")
    build, raster = [f[1] for f in frames], [f[2] for f in frames]
    return {
        "n": len(frames), "budget_ms": budget / 1000,
        "build_p50": percentile(build, .5), "build_p95": percentile(build, .95),
        "raster_p50": percentile(raster, .5), "raster_p95": percentile(raster, .95),
        "raster_jank_pct": 100 * sum(x > budget for x in raster) / len(frames),
        "either_jank_pct": 100 * sum(f[1] > budget or f[2] > budget for f in frames) / len(frames),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="Forwarded Dart VM service URL")
    parser.add_argument("--route", default="/")
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--variants", default="production,blurred,material")
    parser.add_argument("--gesture", choices=["oscillate", "forward"], default="oscillate")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    variants = args.variants.split(",")
    if args.rounds < 3 or any(v not in VARIANTS for v in variants):
        parser.error("Use at least 3 rounds and known variants: " + ",".join(VARIANTS))
    probe = Probe(args.base)
    # Completing onboarding is deliberately left to the operator; preserve app settings.
    probe.ext("go", route=args.route)
    time.sleep(3)
    state = probe.ext("state")
    if state["route"] != args.route:
        raise RuntimeError(f"Unexpected route: {state}")
    print("state", state, flush=True)
    records = []
    args.output.parent.mkdir(parents=True, exist_ok=True)
    try:
        for trial in range(args.rounds):
            for variant in variants if trial % 2 == 0 else reversed(variants):
                probe.configure(variant)
                for upward in [True, False]:
                    probe.swipe(upward)
                time.sleep(1)
                probe.ext("frames")
                probe.ext("mark", label=f"{variant}-{trial}")
                directions = ([True, False] * 4 if args.gesture == "oscillate"
                              else [True] * 8 + [False] * 8)
                for upward in directions:
                    probe.swipe(upward)
                time.sleep(1)
                raw = probe.ext("frames")
                probe.ext("report")
                state = probe.ext("state")
                if state["route"] != args.route:
                    raise RuntimeError("Route changed during measurement")
                summary = {"variant": variant, "trial": trial, **summarize(raw)}
                records.append({"summary": summary, "state": state, "raw": raw})
                args.output.write_text(json.dumps(records), encoding="utf-8")
                print(json.dumps(summary), flush=True)
        for variant in variants:
            trials = [r["summary"] for r in records if r["summary"]["variant"] == variant]
            medians = {key: round(statistics.median(t[key] for t in trials), 3)
                       for key in ["build_p95", "raster_p50", "raster_p95",
                                   "raster_jank_pct", "either_jank_pct"]}
            print(variant, "median", medians, flush=True)
    finally:
        probe.configure("production")


if __name__ == "__main__":
    main()
