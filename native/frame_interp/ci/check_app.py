#!/usr/bin/env python3
"""CI 用：检查构建出来的应用里，补帧组件有没有按预期摆好。

.github/workflows/frame-interp-component.yml 拿刚编出来、还没发布的组件包，走和
发布后一模一样的那条路（下载 → 校验 → 拼装 → 打进应用）构建一次真正的应用，再用
这个脚本看产物。这样组件包发到 Release 之前，就知道它打进应用以后能不能用。

看的东西：
  - 清单在、平台和 ABI 对、清单列的库都在；
  - 模型没被打包流程动过（哈希和钉死的一致——安卓打包时会 strip 原生库，模型是
    伪装成 .so 放进去的，最怕被碰）；
  - 安卓：库是压缩存的（= 安装时会被拆进原生库目录，引擎靠那个目录找模型和清单）、
    LOAD 段按 16KB 对齐（Android 15 起的 16KB 页设备）、只有 arm64-v8a 带组件；
  - 苹果：framework 的架构和平台对得上应用本体（别把模拟器切片打进真机包、
    别漏了 Intel 的切片）、Info.plist 齐全、macOS 上签名能过校验；
  - Linux / macOS：给了 --loader（fi_load_check.c 编出来的程序）就真的加载一次。

用法：
  check_app.py android <flutter-apk 输出目录>
  check_app.py linux   <bundle 目录>     [--loader <fi_load_check>]
  check_app.py macos   <.app>            [--loader <fi_load_check>]
  check_app.py ios     <.app>
模型哈希从环境变量 MODEL_BIN_SHA256 / MODEL_PARAM_SHA256 读（工作流里本来就有）。
有问题时逐条打 ::error::，最后退出码 1。
"""

import argparse
import hashlib
import json
import os
import plistlib
import struct
import subprocess
import sys
import zipfile
from pathlib import Path

ABI = 1
ANDROID_LIB_DIR = "lib/arm64-v8a/"
# 安卓上清单和模型被改名成 libfi_*.so 放进原生库目录（见 android/app/frame_interp.gradle）。
ANDROID_MANIFEST = "libfi_manifest.so"
ANDROID_MODELS = {
    "flownet.param": "libfi_model_flownet_param.so",
    "flownet.bin": "libfi_model_flownet_bin.so",
}
APPLE_FRAMEWORKS = ["FrameInterp", "FiAvutil", "FiSwscale", "FiAvcodec", "FiAvformat"]
PAGE_16K = 16384

_errors = []


def error(message):
    _errors.append(message)
    print(f"::error::{message}", flush=True)


def ok(message, since=None):
    """since：进这一段检查之前的 len(_errors)；这一段里报过错就不打「ok」。"""
    if since is not None and len(_errors) > since:
        return
    print(f"ok: {message}", flush=True)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def expected_models():
    try:
        return {
            "flownet.bin": os.environ["MODEL_BIN_SHA256"].lower(),
            "flownet.param": os.environ["MODEL_PARAM_SHA256"].lower(),
        }
    except KeyError as e:
        sys.exit(f"environment variable {e.args[0]} is not set")


def parse_manifest(data, platform, where):
    try:
        manifest = json.loads(data)
    except ValueError as e:
        error(f"{where}: manifest is not JSON: {e}")
        return None
    since = len(_errors)
    if manifest.get("abi") != ABI:
        error(f"{where}: manifest abi is {manifest.get('abi')!r}, expected {ABI}")
    if manifest.get("platform") != platform:
        error(f"{where}: manifest platform is {manifest.get('platform')!r}, expected {platform!r}")
    if not isinstance(manifest.get("library"), str) or not isinstance(manifest.get("preload"), list):
        error(f"{where}: manifest has no library / preload")
        return None
    if not isinstance(manifest.get("model"), str):
        error(f"{where}: manifest has no model directory")
        return None
    ok(f"{where}: manifest abi {ABI}, platform {platform}", since)
    return manifest


def check_model_bytes(name, data, where):
    want = expected_models()[name]
    got = sha256(data)
    if got != want:
        error(f"{where}: {name} was altered by packaging (sha256 {got}, expected {want})")
    else:
        ok(f"{where}: {name} intact")


# ---- Android -----------------------------------------------------------------


def elf_load_alignments(data):
    """64 位 ELF 的每个 PT_LOAD 段的 p_align；不是 64 位 ELF 返回 None。"""
    if data[:4] != b"\x7fELF" or data[4] != 2:
        return None
    endian = "<" if data[5] == 1 else ">"
    (phoff,) = struct.unpack_from(endian + "Q", data, 0x20)
    phentsize, phnum = struct.unpack_from(endian + "HH", data, 0x36)
    alignments = []
    for i in range(phnum):
        offset = phoff + i * phentsize
        (p_type,) = struct.unpack_from(endian + "I", data, offset)
        if p_type == 1:  # PT_LOAD
            (p_align,) = struct.unpack_from(endian + "Q", data, offset + 0x30)
            alignments.append(p_align)
    return alignments


def is_ours_android(name):
    """其他 ABI 的目录里不该出现的东西。"""
    base = name.rsplit("/", 1)[-1]
    return (
        base.startswith("libfi_")
        or base == "libframe_interp.so"
        or base == "libncnn.so"
        or base.endswith("_fi.so")
    )


def check_android(apk_dir):
    # 递归找：分包都出在 build/app/outputs 下面，只是 Flutter 会不会把每个分包都拷
    # 进 flutter-apk/ 不好说。同一个包被看两遍无妨。
    apks = sorted(Path(apk_dir).rglob("*.apk"))
    if not apks:
        error(f"no APK in {apk_dir}")
        return
    carrying = 0
    for apk in apks:
        where = apk.name
        with zipfile.ZipFile(apk) as z:
            infos = {info.filename: info for info in z.infolist()}
            elsewhere = [
                n for n in infos
                if n.startswith("lib/") and not n.startswith(ANDROID_LIB_DIR) and is_ours_android(n)
            ]
            for n in elsewhere:
                error(f"{where}: {n}: only arm64-v8a may carry the component")

            libs = {n[len(ANDROID_LIB_DIR):]: info for n, info in infos.items()
                    if n.startswith(ANDROID_LIB_DIR)}
            if not libs:
                ok(f"{where}: no arm64-v8a libraries, carries no component")
                continue
            if ANDROID_MANIFEST not in libs:
                error(f"{where}: has arm64-v8a libraries but no {ANDROID_MANIFEST}")
                continue
            carrying += 1

            manifest = parse_manifest(z.read(libs[ANDROID_MANIFEST]), "android-arm64", where)
            if manifest is None:
                continue
            natives = [manifest["library"], *manifest["preload"]]
            packed = natives + [ANDROID_MANIFEST, *ANDROID_MODELS.values()]

            since = len(_errors)
            for name in packed:
                info = libs.get(name)
                if info is None:
                    error(f"{where}: {ANDROID_LIB_DIR}{name} missing")
                    continue
                # 压缩存放 = useLegacyPackaging，安装时拆进原生库目录。存储（不压缩）
                # 的话系统直接从 APK 里映射 .so，原生库目录里就没有清单和模型了。
                if info.compress_type != zipfile.ZIP_DEFLATED:
                    error(f"{where}: {name} is stored uncompressed, so it will not be "
                          "extracted to the native library directory on install")
            ok(f"{where}: {len(packed)} component entries present and compressed", since)

            since = len(_errors)
            for name in natives:
                if name not in libs:
                    continue
                alignments = elf_load_alignments(z.read(libs[name]))
                if alignments is None:
                    error(f"{where}: {name} is not a 64-bit ELF")
                elif not alignments or min(alignments) < PAGE_16K:
                    error(f"{where}: {name} LOAD alignment {alignments} < 16KB "
                          "(will not load on 16KB-page devices)")
            ok(f"{where}: native libraries are 16KB aligned", since)

            for model, packed_name in ANDROID_MODELS.items():
                if packed_name in libs:
                    check_model_bytes(model, z.read(libs[packed_name]), where)
    if carrying == 0:
        error("no APK carries the frame interpolation component")


# ---- 目录形式的组件（Linux，以及苹果 framework 的资源目录） ----------------------


def check_component_dir(root, platform, where, library_dir=None):
    """返回清单，加载检查要用。library_dir 是库所在的目录（默认就是 root）。"""
    library_dir = library_dir or root
    manifest_path = root / "manifest.json"
    if not manifest_path.is_file():
        error(f"{where}: {manifest_path} missing")
        return None
    manifest = parse_manifest(manifest_path.read_bytes(), platform, where)
    if manifest is None:
        return None
    for name in [manifest["library"], *manifest["preload"]]:
        if not (library_dir / name).is_file():
            error(f"{where}: {library_dir / name} missing")
    model_dir = root / manifest["model"]
    for model in expected_models():
        path = model_dir / model
        if not path.is_file():
            error(f"{where}: {path} missing")
        else:
            check_model_bytes(model, path.read_bytes(), where)
    return manifest


def run_loader(loader, library, preload, where):
    command = [str(loader), str(library), *[str(p) for p in preload]]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        error(f"{where}: engine failed to load: {result.stderr.strip() or result.returncode}")
        return
    if f"fi_abi_version={ABI}" not in result.stdout:
        error(f"{where}: engine reports {result.stdout.strip()!r}, expected fi_abi_version={ABI}")
        return
    ok(f"{where}: engine loads, fi_abi_version={ABI}")
    # CI 的机器多半没有能用的 GPU：只打印，不判对错。
    probe = subprocess.run(command, capture_output=True, text=True,
                           env={**os.environ, "FI_LOAD_CHECK_GPU": "1"})
    detail = (probe.stdout + probe.stderr).strip().splitlines()
    print(f"info: {where}: GPU probe exit {probe.returncode}: {detail[-1] if detail else ''}")


def check_linux(bundle, loader):
    root = Path(bundle) / "lib" / "frame_interp"
    manifest = check_component_dir(root, "linux-x64", "linux bundle")
    if manifest and loader:
        run_loader(loader, root / manifest["library"],
                   [root / p for p in manifest["preload"]], "linux bundle")


# ---- Apple -------------------------------------------------------------------

CPU_NAMES = {0x0100000C: "arm64", 0x01000007: "x86_64"}
PLATFORM_NAMES = {1: "macOS", 2: "iOS", 7: "iOS Simulator"}


def macho_slices(data):
    """[(架构, 平台)]，平台取 LC_BUILD_VERSION；不是 Mach-O 返回 None。"""
    (magic_be,) = struct.unpack_from(">I", data, 0)
    if magic_be in (0xCAFEBABE, 0xCAFEBABF):
        wide = magic_be == 0xCAFEBABF
        (count,) = struct.unpack_from(">I", data, 4)
        slices = []
        for i in range(count):
            if wide:
                _, _, offset, size = struct.unpack_from(">iiQQ", data, 8 + i * 32)
            else:
                _, _, offset, size = struct.unpack_from(">iiII", data, 8 + i * 20)
            inner = macho_slices(data[offset:offset + size])
            if inner is None:
                return None
            slices.extend(inner)
        return slices
    (magic,) = struct.unpack_from("<I", data, 0)
    if magic != 0xFEEDFACF:
        return None
    cputype, _, _, ncmds = struct.unpack_from("<iiII", data, 4)
    offset = 32
    platform = None
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<II", data, offset)
        if cmd == 0x32:  # LC_BUILD_VERSION
            (platform,) = struct.unpack_from("<I", data, offset + 8)
        offset += cmdsize
    return [(CPU_NAMES.get(cputype & 0xFFFFFFFF, hex(cputype)), PLATFORM_NAMES.get(platform, platform))]


def read_plist(path, where):
    try:
        with open(path, "rb") as f:
            return plistlib.load(f)
    except (OSError, plistlib.InvalidFileException) as e:
        error(f"{where}: cannot read {path}: {e}")
        return None


def check_apple(app, kind, loader):
    app = Path(app)
    if kind == "macos":
        contents = app / "Contents"
        frameworks = contents / "Frameworks"
        app_plist = read_plist(contents / "Info.plist", app.name)
        executable = contents / "MacOS" / (app_plist or {}).get("CFBundleExecutable", "")
        platform_key, platform_name = "macos", "macOS"
    else:
        frameworks = app / "Frameworks"
        app_plist = read_plist(app / "Info.plist", app.name)
        executable = app / (app_plist or {}).get("CFBundleExecutable", "")
        platform_key, platform_name = "ios-arm64", "iOS"
    if app_plist is None:
        return

    app_slices = macho_slices(executable.read_bytes()) if executable.is_file() else None
    if not app_slices:
        error(f"{app.name}: cannot read the app executable {executable}")
        return
    app_archs = sorted({arch for arch, _ in app_slices})
    ok(f"{app.name}: app executable is {', '.join(app_archs)}")

    for name in APPLE_FRAMEWORKS:
        framework = frameworks / f"{name}.framework"
        where = f"{app.name}/{name}.framework"
        since = len(_errors)
        if not framework.is_dir():
            error(f"{where} missing")
            continue
        binary = framework / name  # macOS 上是指向 Versions/Current/ 的链接
        if not binary.is_file():
            error(f"{where}: binary {name} missing")
            continue
        slices = macho_slices(binary.read_bytes())
        if not slices:
            error(f"{where}: {name} is not a 64-bit Mach-O")
            continue
        archs = {arch for arch, _ in slices}
        for arch in app_archs:
            if arch not in archs:
                error(f"{where}: no {arch} slice, but the app runs as {arch}")
        for arch, platform in slices:
            if platform != platform_name:
                error(f"{where}: {arch} slice is built for {platform}, expected {platform_name}")

        resources = framework / "Resources" if kind == "macos" else framework
        plist = read_plist(resources / "Info.plist", where)
        if plist is not None:
            if plist.get("CFBundleExecutable") != name:
                error(f"{where}: Info.plist CFBundleExecutable is {plist.get('CFBundleExecutable')!r}")
            if kind == "ios":
                minimum = plist.get("MinimumOSVersion")
                app_minimum = app_plist.get("MinimumOSVersion")
                if not minimum:
                    error(f"{where}: Info.plist has no MinimumOSVersion")
                elif app_minimum and _version(minimum) > _version(app_minimum):
                    error(f"{where}: MinimumOSVersion {minimum} is above the app's {app_minimum}")

        if kind == "macos" and sys.platform == "darwin":
            # 版本化 framework 的目录结构不对，签名这一关就过不去（打 DMG 时会再签一遍）。
            result = subprocess.run(["codesign", "--verify", "--strict", str(framework)],
                                    capture_output=True, text=True)
            if result.returncode != 0:
                error(f"{where}: codesign verification failed: {result.stderr.strip()}")
        ok(f"{where}: {', '.join(sorted(archs))} for {platform_name}", since)

    framework = frameworks / "FrameInterp.framework"
    resources = framework / "Resources" if kind == "macos" else framework
    manifest = check_component_dir(resources, platform_key, f"{app.name}/FrameInterp.framework",
                                   library_dir=framework)
    if manifest and loader:
        # 和应用一样，从真正的二进制所在的目录打开（frame_interp_component.dart 的
        # _locate：macOS 上是 Versions/A/，根上那个只是链接）。
        library_dir = (framework / manifest["library"]).resolve().parent
        run_loader(loader, library_dir / manifest["library"],
                   [library_dir / p for p in manifest["preload"]], app.name)


def _version(text):
    return tuple(int(part) for part in str(text).split(".") if part.isdigit())


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("kind", choices=["android", "linux", "macos", "ios"])
    parser.add_argument("path")
    parser.add_argument("--loader", help="fi_load_check binary (linux / macos)")
    args = parser.parse_args()

    if args.kind == "android":
        check_android(args.path)
    elif args.kind == "linux":
        check_linux(args.path, args.loader)
    else:
        check_apple(args.path, args.kind, args.loader if args.kind == "macos" else None)

    if _errors:
        print(f"{len(_errors)} problem(s) found", file=sys.stderr)
        sys.exit(1)
    print("all checks passed")


if __name__ == "__main__":
    main()
