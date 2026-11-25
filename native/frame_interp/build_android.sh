#!/usr/bin/env bash
# 构建 Android arm64-v8a 的补帧组件包。
#
# 只出 arm64-v8a：32 位和 x86 的设备上，应用直接把补帧入口藏掉
# （frame_interp_component.dart 的 platformKey）。
#
# 产物有两样（和 build_windows.ps1 一一对应）：
#   <输出目录>/frame_interp-android-arm64/      完整的组件目录。构建应用时把环境
#                                               变量 FRAME_INTERP_ANDROID_COMPONENT_DIR
#                                               指向它，android/app/frame_interp.gradle
#                                               就会把它打进 APK。
#   <输出目录>/frame_interp-android-arm64.zip   发布用的包：只装我们自己构建的部分
#                                               （引擎库、裁剪过的 FFmpeg、清单、
#                                               许可证），不含 libncnn.so 和模型——
#                                               那两样由 frame_interp.gradle 直接从
#                                               各自的官方出处下载。把它传到 Release，
#                                               再把打印出来的 SHA-256 填进
#                                               android/app/frame_interp.gradle。
#
# ⛔ 换了 ncnn 版本或模型，frame_interp.gradle 里对应的地址和哈希要一起换。
#
# 依赖（都不进仓库）：
#   NCNN_DIR     ncnn 预编译包 ncnn-<版本>-android-vulkan-shared 里的 arm64-v8a 目录
#   FFMPEG_DIR   build_ffmpeg_android.sh 的 <输出目录>/install
#   MODEL_DIR    RIFE v4.6 模型目录（flownet.param / flownet.bin）
#   ANDROID_NDK  NDK 根目录（r26 及以上）
# 另外 PATH 上要有 cmake（3.20+）和 ninja；Android SDK 的 cmake 目录里两样都有。
#
# 用法：
#   NCNN_DIR=... FFMPEG_DIR=... MODEL_DIR=... ANDROID_NDK=... build_android.sh [输出目录]
set -euo pipefail

: "${NCNN_DIR:?}" "${FFMPEG_DIR:?}" "${MODEL_DIR:?}" "${ANDROID_NDK:?}"

HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-"$HERE/out"}
mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)

case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) native_path() { cygpath -m "$1"; } ;;
    *) native_path() { echo "$1"; } ;;
esac
# Windows 上的 python3 常常只是应用商店的占位符，先找 python。
PY=$(command -v python || command -v python3)

BUILD="$OUT/build-android-arm64"
STAGE="$OUT/frame_interp-android-arm64"
ZIP="$OUT/frame_interp-android-arm64.zip"
rm -rf "$BUILD" "$STAGE" "$ZIP"

cmake -S "$(native_path "$HERE")" -B "$(native_path "$BUILD")" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE="$(native_path "$ANDROID_NDK")/build/cmake/android.toolchain.cmake" \
    -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 -DANDROID_STL=c++_static \
    -DFI_NCNN_DIR="$(native_path "$NCNN_DIR")" \
    -DFI_FFMPEG_DIR="$(native_path "$FFMPEG_DIR")" \
    -DFI_MODEL_DIR="$(native_path "$MODEL_DIR")" \
    -DFI_BUILD_CLI=OFF
cmake --build "$(native_path "$BUILD")"
cmake --install "$(native_path "$BUILD")" --prefix "$(native_path "$STAGE")" --strip

# 压缩包里不带外层目录：manifest.json 就在根上，解压出来直接就是组件目录。
(cd "$STAGE" && rm -f "$ZIP" && \
    find . -type f ! -name libncnn.so ! -path './models/*' | sed 's|^\./||' | sort | \
    "$PY" -c "
import sys, zipfile
names = [line.strip() for line in sys.stdin if line.strip()]
with zipfile.ZipFile(sys.argv[1], 'w', zipfile.ZIP_DEFLATED) as z:
    for name in names:
        z.write(name, name)
" "$(native_path "$ZIP")")

echo
echo "component: $STAGE"
echo "package:   $ZIP"
"$PY" - "$(native_path "$ZIP")" <<'EOF'
import hashlib, os, sys
path = sys.argv[1]
print("sha256:   ", hashlib.sha256(open(path, "rb").read()).hexdigest())
print("bytes:    ", os.path.getsize(path))
EOF
