#!/usr/bin/env bash
# 准备 iOS / macOS 的补帧组件：把它摆到同目录的 component/ 下，供 FrameInterp.podspec
# 嵌进应用。ios/Podfile 和 macos/Podfile 在 pod install 时调它。
#
# 和 windows/frame_interp.cmake 是同一套做法，组件从哪来，按下面的顺序找：
#
#   1. 环境变量 FRAME_INTERP_APPLE_COMPONENT_DIR —— native/frame_interp/
#      build_apple.sh 出的完整组件目录。改引擎的时候用它。
#   2. 否则按下面写死的地址和哈希下载：
#        - 引擎和 FFmpeg 的 xcframework：我们自己构建的，挂在本仓库的 Release 上；
#        - RIFE 模型：直接取上游仓库某一次提交里的文件（和其他平台同一份），
#          放进每个切片里 FrameInterp.framework 的资源目录。
#      我们自己的包还没发布（下面的地址为空）时，这次构建不带补帧，只打一行提示。
#   3. 环境变量 FRAME_INTERP_DISABLE 非空 —— 这次构建不带补帧。
#
# 跑完之后 component/FrameInterp.xcframework 在不在，就是 Podfile 要不要引用这个
# pod 的依据。
#
# ⛔ 下载来的东西是要被加载进应用进程的原生代码，每一样都必须带哈希校验。
set -euo pipefail

# ---- 2 用到的地址与哈希 -----------------------------------------------------

# 我们自己的包：native/frame_interp/build_apple.sh 打出来的 zip。
# 发布到 Release 之后，把地址和它打印出来的 SHA-256 一起填上。
PACKAGE_URL=""
PACKAGE_SHA256=""
# 环境变量 FRAME_INTERP_APPLE_PACKAGE_URL 只换下载地址（镜像），哈希照旧用上面这个；
# 连同 FRAME_INTERP_APPLE_PACKAGE_SHA256 一起给，就整个换成另一份包——CI 拿刚编出来、
# 还没发布的包验打包时用（.github/workflows/frame-interp-component.yml）。
if [[ -n "${FRAME_INTERP_APPLE_PACKAGE_URL:-}" ]]; then
    PACKAGE_URL=$FRAME_INTERP_APPLE_PACKAGE_URL
    if [[ -n "${FRAME_INTERP_APPLE_PACKAGE_SHA256:-}" ]]; then
        PACKAGE_SHA256=$(printf '%s' "$FRAME_INTERP_APPLE_PACKAGE_SHA256" | tr 'A-F' 'a-f')
    fi
fi

MODEL_NAME="rife-v4.6"
MODEL_BASE="https://raw.githubusercontent.com/nihui/rife-ncnn-vulkan/a7532fc3f9f8f008cd6eecd6f2ffe2a9698e0cf7/models/rife-v4.6"
MODEL_BIN_SHA256="f334ed2260149ce0188a6dcf049844e8b0cdd912e01cbcfb63553157d2508958"
MODEL_PARAM_SHA256="724569596bcd1e7b9fa50455c604777ebed99746d2ef40aa86e31b5725f1053c"

HERE=$(cd "$(dirname "$0")" && pwd)
DEST="$HERE/component"
CACHE="$HERE/.cache"

say() { echo "frame_interp: $*"; }

sha256_of() { shasum -a 256 "$1" | cut -d' ' -f1; }

# 下载并校验，网络失败重试几次；内容对不上不重试（那不是网络抖动）。
download() {
    local url=$1 destination=$2 sha256=$3
    if [[ -f "$destination" && "$(sha256_of "$destination")" == "$sha256" ]]; then return; fi
    mkdir -p "$(dirname "$destination")"
    local attempt
    for attempt in 1 2 3 4; do
        if curl -fL --silent --show-error -o "$destination.tmp" "$url"; then
            local got
            got=$(sha256_of "$destination.tmp")
            if [[ "$got" != "$sha256" ]]; then
                rm -f "$destination.tmp"
                echo "Checksum mismatch for $url" >&2
                echo "  expected $sha256" >&2
                echo "  got      $got" >&2
                exit 1
            fi
            mv "$destination.tmp" "$destination"
            return
        fi
        say "download failed (attempt $attempt): $url"
    done
    rm -f "$destination.tmp"
    echo "Could not download $url. Check the network, set FRAME_INTERP_APPLE_COMPONENT_DIR" \
         "to a locally built component, or FRAME_INTERP_DISABLE=1 to build without it." >&2
    exit 1
}

# 每个切片里 FrameInterp.framework 的资源目录 = manifest.json 所在的目录
# （macOS 是 Versions/A/Resources，iOS 是 framework 根目录）。
install_models() {
    local manifest resources
    while IFS= read -r manifest; do
        resources=$(dirname "$manifest")
        mkdir -p "$resources/models/$MODEL_NAME"
        cp "$CACHE/flownet.param" "$CACHE/flownet.bin" "$resources/models/$MODEL_NAME/"
    # find 默认不跟符号链接，macOS framework 顶层那个 Resources 链接不会让同一份
    # 清单被找到两次。
    done < <(find "$DEST/FrameInterp.xcframework" -path '*FrameInterp.framework*' -name manifest.json)
}

# 先清掉上一次放进去的：组件换了版本、或者这次不带了，旧文件都不该留着。
rm -rf "$DEST"

if [[ -n "${FRAME_INTERP_DISABLE:-}" ]]; then
    say "disabled for this build"
    exit 0
fi

if [[ -n "${FRAME_INTERP_APPLE_COMPONENT_DIR:-}" ]]; then
    if [[ ! -d "$FRAME_INTERP_APPLE_COMPONENT_DIR/FrameInterp.xcframework" ]]; then
        echo "FRAME_INTERP_APPLE_COMPONENT_DIR has no FrameInterp.xcframework: $FRAME_INTERP_APPLE_COMPONENT_DIR" >&2
        exit 1
    fi
    say "bundling Apple component from $FRAME_INTERP_APPLE_COMPONENT_DIR"
    ditto "$FRAME_INTERP_APPLE_COMPONENT_DIR" "$DEST"
    # 本地编的组件可能已经带着模型；没带就补上。
    if ! find "$DEST/FrameInterp.xcframework" -name flownet.bin | grep -q .; then
        download "$MODEL_BASE/flownet.bin" "$CACHE/flownet.bin" "$MODEL_BIN_SHA256"
        download "$MODEL_BASE/flownet.param" "$CACHE/flownet.param" "$MODEL_PARAM_SHA256"
        install_models
    fi
    exit 0
fi

if [[ -z "$PACKAGE_URL" || -z "$PACKAGE_SHA256" ]]; then
    say "no Apple package configured yet; building without frame interpolation"
    exit 0
fi

say "fetching Apple component"
download "$PACKAGE_URL" "$CACHE/package-${PACKAGE_SHA256:0:12}.zip" "$PACKAGE_SHA256"
download "$MODEL_BASE/flownet.bin" "$CACHE/flownet.bin" "$MODEL_BIN_SHA256"
download "$MODEL_BASE/flownet.param" "$CACHE/flownet.param" "$MODEL_PARAM_SHA256"
mkdir -p "$DEST"
# ditto 解出来的 framework 里的符号链接原样保留（macOS 的 framework 靠它们）。
ditto -x -k "$CACHE/package-${PACKAGE_SHA256:0:12}.zip" "$DEST"
install_models
say "Apple component ready"
