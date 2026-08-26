#!/usr/bin/env python3
"""抓一段光栅线程的时间线，按事件名聚合耗时——回答「这 2.5ms 到底花在哪」。

用法：python3 tool/glass_trace.py --serial <设备号> --knob blend=off
"""
import argparse, collections, json, re, subprocess, sys, time, urllib.parse, urllib.request

PKG = "m.c.g.a.i_iwara"
SERIAL = None


def adb(*a):
    return subprocess.run(["adb"] + (["-s", SERIAL] if SERIAL else []) + list(a),
                          capture_output=True, text=True).stdout


def rpc(base, method, **p):
    url = f"{base}{method}?{urllib.parse.urlencode(p)}"
    for _ in range(3):
        try:
            with urllib.request.urlopen(url, timeout=30) as r:
                return json.load(r)
        except Exception:
            time.sleep(0.5)
    raise RuntimeError(url)


def main():
    global SERIAL
    ap = argparse.ArgumentParser()
    ap.add_argument("--serial")
    ap.add_argument("--knob", action="append", default=[])
    ap.add_argument("--mode", default="liquid")
    ap.add_argument("--seconds", type=float, default=4.0)
    ap.add_argument("--nav-video", default=None,
                    help="用 ext.glassperf.nav 直达某个视频详情页（传 video id）")
    ap.add_argument("--pause", action="store_true",
                    help="进页面后点一下暂停键（去掉视频解码这个大背景噪声）")
    ap.add_argument("--still", action="store_true",
                    help="不做滑动，只靠播放本身产生帧（视频页用这个最安全）")
    ap.add_argument("--swipe-x", type=float, default=None,
                    help="纵向滑动落在屏幕宽度的哪个比例上。默认列表页 0.58、"
                         "视频页 0.85——⛔ 视频页绝不能落进播放器区域，见下方注释")
    ap.add_argument("--tap", action="append", default=[],
                    help="抓之前先点一下（x,y 物理像素），可多次；用来走到目标页")
    args = ap.parse_args()
    SERIAL = args.serial

    adb("logcat", "-c")
    adb("shell", "am", "force-stop", PKG)
    adb("shell", "monkey", "-p", PKG, "-c", "android.intent.category.LAUNCHER", "1")
    url = None
    for _ in range(60):
        time.sleep(1)
        m = re.search(r"(http://127\.0\.0\.1:\d+/[^/]*/)", adb("logcat", "-d"))
        if m:
            url = m.group(1)
            break
    if not url:
        sys.exit("no vm service")
    port = re.search(r":(\d+)/", url).group(1)
    adb("forward", f"tcp:{port}", f"tcp:{port}")
    iso = None
    for _ in range(30):
        vm = rpc(url, "getVM")
        for i in vm["result"]["isolates"]:
            d = rpc(url, "getIsolate", isolateId=i["id"])["result"]
            if any(e.startswith("ext.glassperf.") for e in d.get("extensionRPCs", [])):
                iso = i["id"]
                break
        if iso:
            break
        time.sleep(1)
    time.sleep(12)

    rpc(url, "ext.glassperf.mode", isolateId=iso, value=args.mode)
    for kv in args.knob:
        k, v = kv.split("=")
        rpc(url, "ext.glassperf.knob", isolateId=iso, name=k, value=v)
    time.sleep(2)

    if args.nav_video:
        rpc(url, "ext.glassperf.nav", isolateId=iso, video=args.nav_video)
        time.sleep(14)
        if args.pause:
            adb("shell", "input", "tap", "258", "2019")
            time.sleep(2)

    for t in args.tap:
        x, y = t.split(",")
        adb("shell", "input", "tap", x, y)
        time.sleep(4)

    rpc(url, "setVMTimelineFlags", recordedStreams='["Dart","Embedder","GC"]')
    rpc(url, "clearVMTimeline")

    w, h = 3000, 2120
    m = re.search(r"cur=(\d+)x(\d+)", adb("shell", "dumpsys", "window", "displays"))
    if m:
        w, h = int(m.group(1)), int(m.group(2))
    # ⛔ 纵向滑动**绝不能落在播放器区域内**：播放器把上下拖拽当成音量/亮度手势，
    # 于是「跑个性能基准」会把用户的媒体音量拖到 0，还会弹出音量浮层污染读数。
    # 2026-08-24 真机上就这么干过一次。视频页默认落在右侧详情栏（0.85），
    # 列表页没有播放器，0.58 安全。
    default_x = 0.85 if args.nav_video else 0.58
    cx = int(w * (args.swipe_x if args.swipe_x is not None else default_x))
    end = time.time() + args.seconds
    while time.time() < end:
        if args.still:
            # 视频在解码，每帧都有活干，不需要任何手势去催帧——这也正好避开
            # 播放器的音量/亮度手势。
            time.sleep(0.5)
            continue
        adb("shell", "input", "swipe", str(cx), str(int(h * 0.75)),
            str(cx), str(int(h * 0.25)), "150")

    tl = rpc(url, "getVMTimeline")["result"]["traceEvents"]
    # 线程名
    names = {}
    for e in tl:
        if e.get("ph") == "M" and e.get("name") == "thread_name":
            names[e["tid"]] = e["args"]["name"]

    agg = collections.defaultdict(lambda: [0, 0.0])
    opens = collections.defaultdict(list)
    for e in tl:
        tid = e.get("tid")
        thread = names.get(tid, str(tid))
        if "raster" not in thread.lower() and "gpu" not in thread.lower():
            continue
        ph = e.get("ph")
        if ph == "X" and "dur" in e:
            a = agg[e["name"]]
            a[0] += 1
            a[1] += e["dur"] / 1000.0
        elif ph == "B":
            opens[(tid, e["name"])].append(e["ts"])
        elif ph == "E":
            st = opens[(tid, e["name"])]
            if st:
                a = agg[e["name"]]
                a[0] += 1
                a[1] += (e["ts"] - st.pop()) / 1000.0

    print(f"\n光栅线程事件（mode={args.mode} knobs={args.knob}）")
    print(f"{'event':<50}{'count':>8}{'total ms':>12}{'avg ms':>10}")
    print("-" * 80)
    for name, (c, total) in sorted(agg.items(), key=lambda kv: -kv[1][1])[:25]:
        print(f"{name[:49]:<50}{c:>8}{total:>12.1f}{total / c:>10.3f}")
    if not agg:
        print("（没抓到光栅线程事件，线程名：", sorted(set(names.values()))[:20], "）")


if __name__ == "__main__":
    main()
