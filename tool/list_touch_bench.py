#!/usr/bin/env python3
"""列表滚动帧耗时基准：用**真实触摸**滑动，按实测刷新率算预算。

为什么不用 glass_profile_bench.py 的 ext.glassperf.swipe：那是 Dart 里合成的
指针事件，系统看不到触摸，部分厂商的机型不触发触摸提频，屏幕
停在 50Hz，按 120Hz 预算算会得出「八成帧超预算」的假结论。这里改用
`adb shell input swipe`（走 InputDispatcher），并用相邻帧 vsyncStart 间隔的
中位数判实际刷新率。代价：`input` 每次在设备上拉起一个 Java 进程，丢帧率有
约 ±1 个百分点的抖动，对比时看 3 轮中位数。

构建（帧探针只在 GLASS_PERF 包里注册）：
  flutter build apk --profile --flavor standard --target-platform android-arm64 \
    --dart-define=GLASS_PERF=1 --dart-define=GLASS_ADAPTIVE=true
  adb -s <设备> install -r build/app/outputs/flutter-apk/app-standard-profile.apk

用法（先在手机上走完首次引导，确认列表能正常加载）：
  python3 tool/list_touch_bench.py --serial <设备> --routes /,/gallery,/community \
    --modes plain,liquid --output /tmp/bench.json
  加 --cpu 另外采一段 UI isolate 的 CPU 样本，按类别报占比。

每次注入滑动前都会确认前台是被测包；不是就立刻中止（别把手势打进别的应用）。
"""

import argparse
import collections
import json
import re
import statistics
import subprocess
import sys
import time
import urllib.parse
import urllib.request

SERIAL = None
PACKAGE = None


def adb(*args):
    return subprocess.run(["adb", "-s", SERIAL, *args],
                          capture_output=True, text=True).stdout


def rpc(base, method, **params):
    url = base + method + "?" + urllib.parse.urlencode(params)
    with urllib.request.urlopen(url, timeout=120) as response:
        result = json.load(response)
    if "error" in result:
        raise RuntimeError(result["error"])
    return result["result"]


def launch():
    """冷启动被测包，返回已转发好的 VM service 地址。"""
    adb("logcat", "-c")
    adb("shell", "am", "force-stop", PACKAGE)
    adb("shell", "monkey", "-p", PACKAGE, "-c",
        "android.intent.category.LAUNCHER", "1")
    for _ in range(60):
        time.sleep(1)
        match = re.search(r"(http://127\.0\.0\.1:(\d+)/[^/\s]*/)",
                          adb("logcat", "-d"))
        if match:
            adb("forward", f"tcp:{match.group(2)}", f"tcp:{match.group(2)}")
            return match.group(1)
    sys.exit("没在 logcat 里找到 VM service 地址：确认装的是 profile 包")


def probe_isolate(base):
    for _ in range(30):
        for isolate in rpc(base, "getVM")["isolates"]:
            info = rpc(base, "getIsolate", isolateId=isolate["id"])
            if "ext.glassperf.frames" in info.get("extensionRPCs", []):
                return isolate["id"]
        time.sleep(1)
    sys.exit("没有 ext.glassperf.*：要装 --dart-define=GLASS_PERF=1 的包")


def ensure_foreground():
    focus = next((line for line in adb("shell", "dumpsys", "window").splitlines()
                  if "mCurrentFocus" in line), "")
    if PACKAGE not in focus:
        sys.exit("中止：前台不是被测包 → " + focus.strip()[:100])


def screen_size():
    match = re.search(r"cur=(\d+)x(\d+)", adb("shell", "dumpsys", "window", "displays"))
    return (int(match.group(1)), int(match.group(2))) if match else (1080, 2400)


def swipe(size, upward):
    ensure_foreground()
    width, height = size
    x = str(int(width * 0.55))
    low, high = str(int(height * 0.8)), str(int(height * 0.42))
    y1, y2 = (low, high) if upward else (high, low)
    adb("shell", "input", "swipe", x, y1, x, y2, "220")
    time.sleep(0.45)


def percentile(values, quantile):
    values = sorted(values)
    return values[round((len(values) - 1) * quantile)] / 1000


def summarize(frames):
    # frames: [vsyncStart, build, raster, totalSpan, frameNumber]（微秒）
    pairs = [(a, b) for a, b in zip(frames, frames[1:]) if b[4] == a[4] + 1]
    interval = statistics.median(b[0] - a[0] for a, b in pairs)
    build = [f[1] for f in frames]
    raster = [f[2] for f in frames]
    # 两帧间隔 ≥ 1.5 个周期算丢帧；≥ 200ms 是滑动之间的停顿，不算。
    dropped = [(a, b) for a, b in pairs if 1.5 * interval <= b[0] - a[0] < 200_000]
    causes = collections.Counter(
        "build" if a[1] > interval else "raster" if a[2] > interval else "between"
        for a, _ in dropped)
    return {
        "frames": len(frames), "hz": round(1e6 / interval, 1),
        "build_p50": percentile(build, .5), "build_p95": percentile(build, .95),
        "build_p99": percentile(build, .99),
        "raster_p50": percentile(raster, .5), "raster_p95": percentile(raster, .95),
        "build_over_pct": round(100 * sum(x > interval for x in build) / len(frames), 2),
        "raster_over_pct": round(100 * sum(x > interval for x in raster) / len(frames), 2),
        "dropped_pct": round(100 * len(dropped) / len(pairs), 2),
        # 丢帧前一帧是谁慢：build / raster 超预算，还是两帧之间 UI isolate 在忙别的
        "dropped_cause": {k: round(100 * v / max(len(dropped), 1), 1)
                          for k, v in causes.items()},
    }


CPU_BUCKETS = [
    ("frame", ("drawFrame", "_drawFrame", "_beginFrame")),
    ("network", ("_RawSecureSocket", "_SecureFilterImpl", "_NativeSocket",
                 "HttpClient", "_HttpParser", "HttpFileService")),
    ("image_cache", ("CacheManager", "CacheStore", "ImageLoader",
                     "CachedNetworkImage", "ImageCacheManager")),
    ("file_io", ("_RandomAccessFile", "_File.", "_Directory", "_IOService")),
    ("platform_channel", ("MethodChannel",)),
]


def cpu_breakdown(base, isolate, size, swipes):
    rpc(base, "setFlag", name="profiler", value="true")
    rpc(base, "setFlag", name="profile_period", value="250")
    rpc(base, "clearCpuSamples", isolateId=isolate)
    start = rpc(base, "getVMTimelineMicros")["timestamp"]
    for _ in range(swipes):
        swipe(size, True)
    end = rpc(base, "getVMTimelineMicros")["timestamp"]
    data = rpc(base, "getCpuSamples", isolateId=isolate,
               timeOriginMicros=start, timeExtentMicros=end - start)
    functions = data["functions"]

    def name(index):
        function = functions[index]["function"]
        owner = function.get("owner")
        owner = owner.get("name") if isinstance(owner, dict) else None
        return f"{owner}.{function.get('name')}" if owner else function.get("name", "?")

    counts = collections.Counter()
    for sample in data["samples"]:
        stack = " ".join(name(i) for i in sample["stack"])
        bucket = next((label for label, needles in CPU_BUCKETS
                       if any(n in stack for n in needles)), "other")
        counts[bucket] += 1
    total = max(len(data["samples"]), 1)
    return {k: round(100 * v / total, 1) for k, v in counts.most_common()}


def main():
    global SERIAL, PACKAGE
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--serial", required=True)
    parser.add_argument("--package", default="m.c.g.a.i_iwara.profile")
    parser.add_argument("--base", help="已转发的 VM service 地址；不给就冷启动被测包")
    parser.add_argument("--routes", default="/,/gallery,/community")
    parser.add_argument("--modes", default="plain", help="plain（Material）/ liquid，逗号分隔")
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--up", type=int, default=10, help="每轮先往下翻几次")
    parser.add_argument("--down", type=int, default=6, help="再往回翻几次")
    parser.add_argument("--cpu", action="store_true", help="每个路由另采一段 CPU 样本")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    SERIAL, PACKAGE = args.serial, args.package

    base = args.base.rstrip("/") + "/" if args.base else launch()
    isolate = probe_isolate(base)
    ext = lambda e, **p: rpc(base, "ext.glassperf." + e, isolateId=isolate, **p)
    if not args.base:
        time.sleep(8)  # 冷启动后等首页列表加载
    size = screen_size()
    records = []
    for mode in args.modes.split(","):
        ext("mode", value=mode)
        for route in args.routes.split(","):
            ext("go", route=route)
            time.sleep(4)
            state = ext("state")
            if state["route"] != route:
                sys.exit(f"路由不对：{state}")
            for trial in range(args.rounds):
                for upward in (True, False):  # 热身，丢掉这段
                    swipe(size, upward)
                time.sleep(1)
                ext("frames")
                for upward in [True] * args.up + [False] * args.down:
                    swipe(size, upward)
                time.sleep(1)
                raw = ext("frames")
                ext("report")
                summary = {"mode": mode, "route": route, "trial": trial,
                           **summarize(raw["frames"])}
                print(json.dumps(summary, ensure_ascii=False), flush=True)
                records.append({"summary": summary, "frames": raw["frames"]})
            if args.cpu:
                cpu = cpu_breakdown(base, isolate, size, args.up)
                print(json.dumps({"mode": mode, "route": route, "cpu": cpu},
                                 ensure_ascii=False), flush=True)
                records.append({"mode": mode, "route": route, "cpu": cpu})
            with open(args.output, "w", encoding="utf-8") as out:
                json.dump(records, out)
    keys = ["hz", "build_p99", "raster_p95", "build_over_pct",
            "raster_over_pct", "dropped_pct"]
    for mode in args.modes.split(","):
        for route in args.routes.split(","):
            trials = [r["summary"] for r in records
                      if "summary" in r and r["summary"]["mode"] == mode
                      and r["summary"]["route"] == route]
            medians = {k: round(statistics.median(t[k] for t in trials), 3) for k in keys}
            print(f"{mode} {route} 中位数 {json.dumps(medians)}", flush=True)


if __name__ == "__main__":
    main()
