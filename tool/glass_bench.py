#!/usr/bin/env python3
"""液态玻璃帧耗时基准：同一台真机上把「真玻璃 / 假玻璃」跑同一套场景做 A/B。

前置：装好 `--profile --dart-define=GLASS_PERF=1` 的包（见 FramePerfProbe）。

用法：
    python3 tool/glass_bench.py                 # 默认跑 liquid / plain 各两轮
    python3 tool/glass_bench.py --rounds 3
"""
import argparse
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request

PKG = "m.c.g.a.i_iwara"
SERIAL = None


def adb(*args, capture=True):
    cmd = ["adb"] + (["-s", SERIAL] if SERIAL else []) + list(args)
    if capture:
        return subprocess.run(cmd, capture_output=True, text=True).stdout
    subprocess.run(cmd)
    return ""


def screen_size():
    """当前**旋转后**的尺寸。`wm size` 报的是自然方向，横屏平板上会反过来。"""
    out = adb("shell", "dumpsys", "window", "displays")
    m = re.search(r"cur=(\d+)x(\d+)", out)
    if m:
        return int(m.group(1)), int(m.group(2))
    out = adb("shell", "wm", "size")
    m = re.search(r"Override size: (\d+)x(\d+)", out) or re.search(
        r"Physical size: (\d+)x(\d+)", out
    )
    return int(m.group(1)), int(m.group(2))


ISOLATE = None


def main_isolate(base):
    """service extension 是**按 isolate 注册**的，HTTP RPC 必须带 isolateId，
    否则一律返回 -32601 Method not found（而且是 HTTP 200，静默失败）。"""
    for _ in range(30):
        vm = rpc(base, "getVM")
        for iso in vm["result"].get("isolates", []):
            d = rpc(base, "getIsolate", isolateId=iso["id"])["result"]
            if any(e.startswith("ext.glassperf.") for e in d.get("extensionRPCs", [])):
                return iso["id"]
        time.sleep(1)
    sys.exit("没找到注册了 ext.glassperf.* 的 isolate")


def launch_and_get_base():
    adb("logcat", "-c")
    adb("shell", "am", "force-stop", PKG)
    adb("shell", "monkey", "-p", PKG, "-c", "android.intent.category.LAUNCHER", "1")
    url = None
    for _ in range(60):
        time.sleep(1)
        log = adb("logcat", "-d")
        m = re.search(r"The Dart VM service is listening on (http://127\.0\.0\.1:\d+/[^/]*/)", log)
        if m:
            url = m.group(1)
            break
    if not url:
        sys.exit("没等到 Dart VM service，确认装的是 profile 包")
    port = re.search(r":(\d+)/", url).group(1)
    adb("forward", f"tcp:{port}", f"tcp:{port}")
    return url


def rpc(base, method, **params):
    """VM service 的 HTTP-GET RPC。偶发 RemoteDisconnected（连接被回收）重试两次。"""
    q = urllib.parse.urlencode(params)
    last = None
    for _ in range(3):
        try:
            with urllib.request.urlopen(f"{base}{method}?{q}", timeout=20) as r:
                return json.load(r)
        except Exception as e:  # noqa: BLE001 - 网络/连接抖动一律重试
            last = e
            time.sleep(0.5)
    raise last


SHOTS_DIR = None


def mark(base, label):
    r = rpc(base, "ext.glassperf.mark", isolateId=ISOLATE, label=label)
    if "error" in r:
        sys.exit(f"mark 失败: {r['error']}")
    if SHOTS_DIR:
        # 每段开头存一张图：分段脚本一旦有一下点空，后面全会跑偏，而读数看起来
        # 依然「正常」。有图才能事后判断这一轮到底测的是不是想测的东西。
        safe = label.replace("|", "_").replace("#", "-")
        raw = subprocess.run(
            ["adb"] + (["-s", SERIAL] if SERIAL else [])
            + ["exec-out", "screencap", "-p"],
            capture_output=True,
        ).stdout
        with open(f"{SHOTS_DIR}/{safe}.png", "wb") as f:
            f.write(raw)


def set_knob(base, name, value):
    r = rpc(base, "ext.glassperf.knob", isolateId=ISOLATE, name=name, value=value)
    if "error" in r:
        sys.exit(f"knob 失败: {r['error']}")
    return r["result"]


def set_mode(base, mode):
    r = rpc(base, "ext.glassperf.mode", isolateId=ISOLATE, value=mode)
    if "error" in r:
        sys.exit(f"mode 失败: {r['error']}")


def scenario(base, w, h, tag):
    """一轮固定动作序列。每段自己打标签，读数按标签归类。"""
    # 横屏平板左侧是导航栏，纵向手势要落在内容区里，别打在栏上。
    cx = int(w * 0.58)

    mark(base, f"{tag}|idle")
    time.sleep(3)

    mark(base, f"{tag}|scroll")
    for _ in range(8):
        adb("shell", "input", "swipe", str(cx), str(int(h * 0.75)),
            str(cx), str(int(h * 0.25)), "120")
        time.sleep(0.6)
    time.sleep(1)

    mark(base, f"{tag}|scroll-back")
    for _ in range(8):
        adb("shell", "input", "swipe", str(cx), str(int(h * 0.25)),
            str(cx), str(int(h * 0.75)), "120")
        time.sleep(0.6)
    time.sleep(1)

    mark(base, f"{tag}|tab-swipe")
    for _ in range(6):
        adb("shell", "input", "swipe", str(int(w * 0.8)), str(int(h * 0.5)),
            str(int(w * 0.2)), str(int(h * 0.5)), "200")
        time.sleep(0.8)
        adb("shell", "input", "swipe", str(int(w * 0.2)), str(int(h * 0.5)),
            str(int(w * 0.8)), str(int(h * 0.5)), "200")
        time.sleep(0.8)

    mark(base, f"{tag}|settle")
    time.sleep(2)


def start_log_capture(path):
    """整轮跑完再 `logcat -d` 是不行的：本 App 日志量大，环形缓冲会把早期读数冲掉
    （实测 4 轮只剩 1 条）。改成全程 tee 到文件。"""
    adb("logcat", "-c")
    f = open(path, "w")
    cmd = ["adb"] + (["-s", SERIAL] if SERIAL else []) + ["logcat"]
    return subprocess.Popen(cmd, stdout=f, stderr=subprocess.DEVNULL), f



# ---- 视频详情页（横屏平板分屏布局）的坐标，按屏幕比例给 ----
#
# 这一组是照 OnePlus Pad 横屏 3000x2120 的分屏布局标定的：左边播放器、右边
# 详情/评论/相关三个 tab。窄屏（手机）是上下堆叠的另一套布局，比例对不上，
# 要测手机得另标一组。
VIDEO_POINTS = {
    "home_card": (0.180, 0.198),      # 首页第一张视频卡
    "tab_comments": (0.846, 0.068),   # 右侧「评论列表」tab
    "comment_fab": (0.961, 0.926),    # 评论区右下角的速拨球
    "compose": (0.959, 0.775),        # 速拨球展开后的「写评论」铅笔
    "compose_close": (0.746, 0.551),  # 评论弹窗右上角的玻璃关闭圆钮
    "fullscreen": (0.671, 0.952),     # 播放器控制条右端的全屏键
    # 控制条上的一块空地。播放器的控件会自动隐藏，隐藏时点全屏键的位置只会把
    # 控件唤出来、不会真的进全屏——下一次返回键就把整个详情页弹掉了。所以每次
    # 点全屏之前先在这里点一下：控件已显示时这是控制条上的空白（无操作），
    # 控件隐藏时它落在视频上、只负责唤醒。两种情况都不会误触发播放/暂停。
    #
    # ⛔ 这里只能**点**，绝不能纵向拖：播放器把上下拖拽当成音量/亮度手势
    # （glass_trace.py 里踩过，把用户媒体音量拖到了 0）。
    "controls_wake": (0.400, 0.952),
    "comments_mid": (0.850, 0.500),   # 评论列表中部（用来滑动）
}


def pt(w, h, name):
    fx, fy = VIDEO_POINTS[name]
    return str(int(w * fx)), str(int(h * fy))


VIDEO_ID = None


def route(base):
    """当前 GoRouter 位置。纯 RPC，不碰 GPU，可以在测量段之间随便问。"""
    try:
        return rpc(base, "ext.glassperf.state", isolateId=ISOLATE)["result"]["route"]
    except Exception:
        return "?"


def on_video(base):
    return route(base).startswith("/video_detail/")


def nav_video(base, w, h):
    """不靠点击直达视频详情页 + 评论 tab。

    ⛔ 这一步存在的理由：视频页那套编排只要有一下点空，后面的按键就落在别处
    ——实测过「全屏没进去 → 返回键把详情页整个弹掉 → 剩下几段全在首页上跑」，
    而读数看起来完全正常（假玻璃那一轮整轮都在测首页，还测出了「假玻璃更慢」
    这种反常结论）。所以复位必须走路由，不能靠再点一遍。
    """
    rpc(base, "ext.glassperf.nav", isolateId=ISOLATE, video=VIDEO_ID)
    time.sleep(12)  # 等首帧解码出来
    adb("shell", "input", "tap", *pt(w, h, "tab_comments"))
    time.sleep(3)


def ensure_video(base, w, h, tag):
    """跑偏了就复位。复位那几帧扔进 `recover` 桶，不算进任何一个场景。"""
    if on_video(base):
        return
    mark(base, f"{tag}|recover")
    nav_video(base, w, h)


def goto_video(base, w, h):
    """整轮开始时走一次：点开首页第一张卡，把视频 id 记下来供后续复位使用。"""
    global VIDEO_ID
    adb("shell", "input", "tap", *pt(w, h, "home_card"))
    time.sleep(14)
    r = route(base)
    if not r.startswith("/video_detail/"):
        sys.exit(f"没进到视频详情页（当前 {r}），确认首页第一张卡的坐标")
    VIDEO_ID = r.split("/video_detail/")[1].split("?")[0]
    print(f"video id: {VIDEO_ID}")
    adb("shell", "input", "tap", *pt(w, h, "tab_comments"))
    time.sleep(3)


def scenario_video(base, w, h, tag):
    """看视频这条路径：播放 / 滚评论 / 开关评论弹窗 / 进出全屏 / 全屏播放。

    ⚠️ 这里的「静置」段和列表页不一样，是**可信**的：视频在解码，每帧都有活干，
    GPU 不会降频，不存在列表页 idle 那种「零星几帧反而更慢」的假象。

    每段之前都验一次路由，跑偏就复位——见 [ensure_video]。
    """
    ensure_video(base, w, h, tag)
    mark(base, f"{tag}|play")
    time.sleep(6)

    ensure_video(base, w, h, tag)
    mark(base, f"{tag}|comments")
    x, _y = pt(w, h, "comments_mid")
    for _ in range(8):
        adb("shell", "input", "swipe", x, str(int(h * 0.72)),
            x, str(int(h * 0.28)), "150")
        time.sleep(0.5)
    time.sleep(1)

    ensure_video(base, w, h, tag)
    mark(base, f"{tag}|composer")
    for _ in range(4):
        adb("shell", "input", "tap", *pt(w, h, "comment_fab"))
        time.sleep(1.2)
        adb("shell", "input", "tap", *pt(w, h, "compose"))
        time.sleep(2.0)
        adb("shell", "input", "tap", *pt(w, h, "compose_close"))
        time.sleep(1.5)

    ensure_video(base, w, h, tag)
    mark(base, f"{tag}|fullscreen")
    for _ in range(4):
        adb("shell", "input", "tap", *pt(w, h, "controls_wake"))
        time.sleep(0.6)
        adb("shell", "input", "tap", *pt(w, h, "fullscreen"))
        time.sleep(2.5)
        adb("shell", "input", "keyevent", "KEYCODE_BACK")
        time.sleep(2.5)
        if not on_video(base):
            break  # 全屏没进去、返回键把页面弹了；剩下几次别再点，交给下一段复位

    ensure_video(base, w, h, tag)
    adb("shell", "input", "tap", *pt(w, h, "controls_wake"))
    time.sleep(0.6)
    adb("shell", "input", "tap", *pt(w, h, "fullscreen"))
    time.sleep(2)
    mark(base, f"{tag}|fs-play")
    time.sleep(6)
    adb("shell", "input", "keyevent", "KEYCODE_BACK")
    time.sleep(2)

    mark(base, f"{tag}|settle")
    time.sleep(1)


LINE = re.compile(
    r"GLASSPERF \[(?P<label>[^\]]+)\] n=(?P<n>\d+) jank=(?P<jank>\d+)\([\d.]+%\) "
    r"build\{p50=(?P<bp50>[\d.]+) p90=(?P<bp90>[\d.]+) p99=(?P<bp99>[\d.]+) max=(?P<bmax>[\d.]+)\} "
    r"raster\{p50=(?P<rp50>[\d.]+) p90=(?P<rp90>[\d.]+) p99=(?P<rp99>[\d.]+) max=(?P<rmax>[\d.]+)\}"
)


def collect(path=None):
    log = open(path, errors="replace").read() if path else adb("logcat", "-d")
    rows = []
    for m in LINE.finditer(log):
        d = m.groupdict()
        rows.append(
            {
                "label": d["label"],
                "n": int(d["n"]),
                "jank": int(d["jank"]),
                **{k: float(d[k]) for k in
                   ("bp50", "bp90", "bp99", "bmax", "rp50", "rp90", "rp99", "rmax")},
            }
        )
    return rows


def aggregate(rows):
    """按 `mode|scene` 归并多轮：帧数加权平均分位数（够用的近似），jank 直接求和。"""
    buckets = {}
    for r in rows:
        if "|" not in r["label"]:
            continue
        mode, scene = r["label"].split("|", 1)
        mode = mode.split("#")[0]
        key = (mode, scene)
        b = buckets.setdefault(
            key, {"n": 0, "jank": 0, **{k: 0.0 for k in
                  ("bp50", "bp90", "bp99", "rp50", "rp90", "rp99")},
                  "bmax": 0.0, "rmax": 0.0}
        )
        b["n"] += r["n"]
        b["jank"] += r["jank"]
        for k in ("bp50", "bp90", "bp99", "rp50", "rp90", "rp99"):
            b[k] += r[k] * r["n"]
        b["bmax"] = max(b["bmax"], r["bmax"])
        b["rmax"] = max(b["rmax"], r["rmax"])
    for b in buckets.values():
        for k in ("bp50", "bp90", "bp99", "rp50", "rp90", "rp99"):
            b[k] /= max(b["n"], 1)
    return buckets


def report(buckets, only_scenes=None, order=None):
    scenes = []
    for (_, scene) in buckets:
        if only_scenes and scene not in only_scenes:
            continue
        if scene not in scenes:
            scenes.append(scene)
    modes = order or []
    for (mode, _) in buckets:
        if mode not in modes:
            modes.append(mode)
    print()
    print(f"{'scene':<14}{'mode':<9}{'n':>6}{'jank%':>8}"
          f"{'build p50':>11}{'p90':>8}{'p99':>8}"
          f"{'raster p50':>12}{'p90':>8}{'p99':>8}{'max':>8}{'Δp50':>9}")
    print("-" * 110)
    for scene in scenes:
        base_row = buckets.get(("baseline", scene)) or buckets.get(("liquid", scene))
        for mode in modes:
            b = buckets.get((mode, scene))
            if not b:
                continue
            print(f"{scene:<14}{mode:<9}{b['n']:>6}"
                  f"{b['jank'] * 100 / max(b['n'], 1):>7.1f}%"
                  f"{b['bp50']:>11.2f}{b['bp90']:>8.2f}{b['bp99']:>8.2f}"
                  f"{b['rp50']:>12.2f}{b['rp90']:>8.2f}{b['rp99']:>8.2f}{b['rmax']:>8.2f}"
                  + (f"{b['rp50'] - base_row['rp50']:>+9.2f}"
                     if base_row and b is not base_row else ""))
        print()


def main():
    global SERIAL, ISOLATE, SHOTS_DIR
    ap = argparse.ArgumentParser()
    ap.add_argument("--serial", default=None)
    ap.add_argument("--rounds", type=int, default=2)
    ap.add_argument("--attribute", action="store_true",
                    help="跑归因矩阵（每次只关一项）而不是简单的真/假玻璃 A/B")
    ap.add_argument("--shots", default=None,
                    help="每段开头存一张截图到这个目录，用来核对动作序列没跑偏")
    ap.add_argument("--scenario", default="list", choices=["list", "video"],
                    help="list=列表页；video=视频详情页（播放/评论/弹窗/全屏）")
    ap.add_argument("--scenes", default="scroll,tab-swipe",
                    help="报告里只看这些场景（逗号分隔）。idle/settle 受 GPU 降频"
                         "影响大，默认不看")
    ap.add_argument("--warmup", type=int, default=12,
                    help="启动后先等这么多秒让首屏数据加载完")
    args = ap.parse_args()
    SERIAL = args.serial
    SHOTS_DIR = args.shots
    if SHOTS_DIR:
        os.makedirs(SHOTS_DIR, exist_ok=True)

    base = launch_and_get_base()
    print(f"VM service: {base}")
    ISOLATE = main_isolate(base)
    print(f"isolate: {ISOLATE}")
    log_path = "/tmp/glass_bench_logcat.txt"
    proc, fh = start_log_capture(log_path)
    time.sleep(args.warmup)
    w, h = screen_size()
    print(f"screen: {w}x{h}")

    run = scenario_video if args.scenario == "video" else scenario
    if args.scenario == "video":
        goto_video(base, w, h)
        if args.scenes == "scroll,tab-swipe":
            args.scenes = "play,comments,composer,fullscreen,fs-play"

    if args.attribute:
        # 归因矩阵：每次只动一项，其余保持生产默认，看各自值多少毫秒。
        variants = [
            ("baseline", []),
            ("no-chromegrp", [("chromeGroup", "off")]),
            ("no-blend", [("blend", "off")]),
        ]
        for i in range(args.rounds):
            order = variants if i % 2 == 0 else list(reversed(variants))
            for name, knobs in order:
                print(f"round {i + 1}: {name}")
                # 先全部复位成生产默认，再只打开本变体那一项
                for k, v in (("blend", "on"), ("chromeGroup", "on")):
                    set_knob(base, k, v)
                set_mode(base, "liquid")
                for k, v in knobs:
                    set_knob(base, k, v)
                time.sleep(2)
                run(base, w, h, f"{name}#{i}")
            print(f"round {i + 1}: plain")
            set_mode(base, "plain")
            time.sleep(2)
            run(base, w, h, f"plain#{i}")
    else:
        for i in range(args.rounds):
            # 交替顺序，抵消「越跑越热 / 缓存越跑越暖」的系统性偏移
            modes = ("liquid", "plain") if i % 2 == 0 else ("plain", "liquid")
            for mode in modes:
                print(f"round {i + 1}: {mode}")
                set_mode(base, mode)
                time.sleep(2)
                run(base, w, h, f"{mode}#{i}")

    mark(base, "done|done")
    time.sleep(1)
    proc.terminate()
    fh.close()
    rows = collect(log_path)
    if not rows:
        sys.exit("没抓到 GLASSPERF 读数")
    report(aggregate(rows), only_scenes=set(args.scenes.split(",")))


if __name__ == "__main__":
    main()
