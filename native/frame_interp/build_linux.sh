#!/usr/bin/env bash
# 构建 Linux x86_64 的补帧组件包。
#
# 产物有两样（和 build_windows.ps1 一一对应）：
#   <输出目录>/frame_interp-linux-x64/      完整的组件目录。构建应用时把环境变量
#                                           FRAME_INTERP_COMPONENT_DIR 指向它，
#                                           linux/frame_interp.cmake 就会把它打进
#                                           应用的 lib/frame_interp/。
#   <输出目录>/frame_interp-linux-x64.zip   发布用的包：只装我们自己构建的部分
#                                           （引擎库、裁剪过的 FFmpeg、OpenMP
#                                           运行时、清单、许可证），不含 ncnn 和
#                                           模型——那两样由 linux/frame_interp.cmake
#                                           直接从各自的官方出处下载。把它传到
#                                           Release，再把打印出来的 SHA-256 填进
#                                           linux/frame_interp.cmake。
#
# ⛔ 换了 ncnn 版本或模型，linux/frame_interp.cmake 里对应的地址和哈希要一起换。
#
# 依赖（都不进仓库）：
#   NCNN_DIR     ncnn 预编译包 ncnn-<版本>-ubuntu-2204-shared 的根目录
#   FFMPEG_DIR   build_ffmpeg_linux.sh 的 <输出目录>/install
#   MODEL_DIR    RIFE v4.6 模型目录（flownet.param / flownet.bin）
# 运行环境同 build_ffmpeg_linux.sh（Ubuntu 22.04），另要 cmake 3.20+。
#
# 用法：
#   NCNN_DIR=... FFMPEG_DIR=... MODEL_DIR=... build_linux.sh [输出目录]
set -euo pipefail

: "${NCNN_DIR:?}" "${FFMPEG_DIR:?}" "${MODEL_DIR:?}"

HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-"$HERE/out"}
mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)

BUILD="$OUT/build-linux-x64"
STAGE="$OUT/frame_interp-linux-x64"
ZIP="$OUT/frame_interp-linux-x64.zip"
rm -rf "$BUILD" "$STAGE" "$ZIP"

# ncnn 依赖 OpenMP 运行时 libgomp.so.1。桌面发行版几乎都装着，但最小化安装的系统
# 上未必有；它带着 GCC 运行库例外条款，可以随应用一起发。
EXTRA=""
if readelf -d "$NCNN_DIR"/lib/libncnn.so* 2>/dev/null | grep -q 'libgomp.so.1'; then
    GOMP=$(gcc -print-file-name=libgomp.so.1)
    EXTRA=$(readlink -f "$GOMP")
    # 装进组件时按 soname 起名。
    cp "$EXTRA" "$OUT/libgomp.so.1"
    EXTRA="$OUT/libgomp.so.1"
fi

cmake -S "$HERE" -B "$BUILD" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DFI_NCNN_DIR="$NCNN_DIR" \
    -DFI_FFMPEG_DIR="$FFMPEG_DIR" \
    -DFI_MODEL_DIR="$MODEL_DIR" \
    -DFI_EXTRA_RUNTIME="$EXTRA" \
    -DFI_BUILD_CLI=OFF
cmake --build "$BUILD"
cmake --install "$BUILD" --prefix "$STAGE" --strip

# 自检：引擎在组件目录里得能自己找全依赖（RPATH=$ORIGIN 生效），不能漏到系统里
# 去找 FFmpeg / ncnn。
if LD_LIBRARY_PATH= ldd "$STAGE/libframe_interp.so" | grep -E 'not found|/usr/.*lib(av|sw)[a-z]+_fi'; then
    echo "libframe_interp.so does not resolve its dependencies inside the component" >&2
    exit 1
fi

# 压缩包里不带外层目录：manifest.json 就在根上，解压出来直接就是组件目录。
(cd "$STAGE" && zip -q -r "$ZIP" . -x 'libncnn.so*' -x 'models/*')

echo
echo "component: $STAGE"
echo "package:   $ZIP"
echo "sha256:    $(sha256sum "$ZIP" | cut -d' ' -f1)"
echo "bytes:     $(stat -c %s "$ZIP")"
