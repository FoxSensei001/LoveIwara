#!/usr/bin/env bash
# 给补帧引擎编一份裁剪过的 FFmpeg（Linux x86_64，系统 gcc，LGPL），连带它要静态
# 链进去的 dav1d（AV1 软解）。
#
# 和 Windows 那份（build_ffmpeg_windows.sh）开的部件基本一样，差在：
#   - 编码器换成 NVIDIA 的 nvenc 和 VAAPI（AMD / Intel 走它）；
#   - 库名统一加 `_fi` 后缀（libavcodec_fi.so.62 这样），并带 RPATH=$ORIGIN：
#     系统里多半装着发行版自己的 FFmpeg，同名同版本号的库会被动态链接器混用。
#
# libva 不随组件带：它要和系统里的显卡驱动（iHD / radeonsi）配套，驱动路径各发行版
# 也不一样。没装 libva 的机器上引擎加载失败，应用会把补帧当作不可用、不露入口。
#
# 运行环境：Ubuntu 22.04（glibc 2.35，出来的库在更新的发行版上都能用）。
# 需要的包：build-essential nasm pkg-config meson ninja-build libva-dev
#
# 用法：
#   build_ffmpeg_linux.sh <ffmpeg 源码目录> <dav1d 源码目录> <nv-codec-headers 目录> <输出目录>
#
# 几样源码各自从官方取：
#   FFmpeg 8.1         https://ffmpeg.org/releases/ffmpeg-8.1.tar.xz
#   dav1d 1.5.5        https://downloads.videolan.org/pub/videolan/dav1d/1.5.5/dav1d-1.5.5.tar.xz
#   nv-codec-headers   https://github.com/FFmpeg/nv-codec-headers  （tag n12.2.72.0）
#
# 产物：<输出目录>/install（include、lib/*.so.*、LICENSE.txt），交给
# build_linux.sh 的 FFMPEG_DIR。
set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "usage: $0 <ffmpeg-src> <dav1d-src> <nv-codec-headers> <out-dir>" >&2
    exit 2
fi

SRC=$(cd "$1" && pwd)
DAV1D_SRC=$(cd "$2" && pwd)
NVHEADERS=$(cd "$3" && pwd)
mkdir -p "$4"
OUT=$(cd "$4" && pwd)

DEPS="$OUT/deps"
mkdir -p "$DEPS"

# ---- nvenc 的头文件（运行时按需 dlopen 驱动，不链接任何 NVIDIA 的库） ---------
make -C "$NVHEADERS" install PREFIX="$DEPS" >/dev/null

# ---- dav1d：静态库，链进 avcodec ------------------------------------------
DAV1D_BUILD="$OUT/dav1d-build"
rm -rf "$DAV1D_BUILD"
# 不传 -Db_pic=true：meson 在 Linux 上 b_pic 默认就是开的，而新版 meson（CI 上 1.12.1、
# 本机 1.6.1 都如此）在 project() 阶段不认命令行上的这个选项，配置直接报 Unknown option。
meson setup "$DAV1D_BUILD" "$DAV1D_SRC" \
    --buildtype=release --default-library=static \
    -Denable_tools=false -Denable_tests=false \
    --prefix="$DEPS" --libdir=lib
meson compile -C "$DAV1D_BUILD"
meson install -C "$DAV1D_BUILD"
cp "$DAV1D_SRC/COPYING" "$DEPS/dav1d-COPYING"

# ---- FFmpeg ---------------------------------------------------------------

# 解码器、解析器、封装与 Windows 版同一张表，理由见 build_ffmpeg_windows.sh。
DECODERS=h264,hevc,vp8,vp9,libdav1d,mpeg4,mpeg2video,mpeg1video,vc1,wmv3,msmpeg4v3,mjpeg,flv,h263
PARSERS=h264,hevc,vp8,vp9,av1,mpeg4video,mpegvideo,vc1,mjpeg,h263,aac,aac_latm,ac3,mpegaudio,opus,vorbis,flac,dca
DEMUXERS=mov,matroska,avi,flv,mpegts,mpegps,asf,m4v,h264,hevc
MUXERS=mp4,matroska
BSFS=h264_mp4toannexb,hevc_mp4toannexb,extract_extradata,aac_adtstoasc,vp9_superframe,vp9_superframe_split
# 编码器只留硬件的。补帧本来就要一块能跑 Vulkan 计算的显卡，有这块卡的机器
# 要么是 NVIDIA（nvenc），要么是 AMD / Intel（VAAPI，Mesa 带着）。
ENCODERS=h264_nvenc,hevc_nvenc,h264_vaapi,hevc_vaapi

BUILD="$OUT/build"
rm -rf "$BUILD"
mkdir -p "$BUILD"
cd "$BUILD"

PKG_CONFIG_PATH="$DEPS/lib/pkgconfig:$DEPS/lib/x86_64-linux-gnu/pkgconfig" "$SRC/configure" \
    --prefix="$OUT/install" \
    --build-suffix=_fi \
    --enable-pic --enable-shared --disable-static \
    --disable-everything --disable-autodetect \
    --disable-programs --disable-doc --disable-debug \
    --disable-avdevice --disable-avfilter --disable-swresample \
    --disable-network \
    --enable-libdav1d \
    --enable-ffnvcodec --enable-nvenc \
    --enable-vaapi \
    --enable-decoder=$DECODERS \
    --enable-parser=$PARSERS \
    --enable-demuxer=$DEMUXERS \
    --enable-muxer=$MUXERS \
    --enable-bsf=$BSFS \
    --enable-encoder=$ENCODERS \
    --enable-protocol=file \
    --extra-ldflags="-Wl,-rpath,'\$\$ORIGIN' -Wl,--disable-new-dtags"

make -j"$(nproc)"
make install

cp "$SRC/COPYING.LGPLv2.1" "$OUT/install/LICENSE.txt"
{
    printf '\n\n==== dav1d (statically linked into avcodec) ====\n\n'
    cat "$DEPS/dav1d-COPYING"
} >> "$OUT/install/LICENSE.txt"
echo "done: $OUT/install"
