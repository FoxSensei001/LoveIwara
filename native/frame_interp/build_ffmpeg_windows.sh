#!/usr/bin/env bash
# 给补帧引擎编一份裁剪过的 FFmpeg（Windows x64，MSVC 工具链，LGPL）。
#
# 现成的全功能 FFmpeg 动态库有一百三十多兆，而引擎只用到其中很小一块：
# 把视频解出来、用显卡编回去、把音轨字幕原样拷过去。这里只开用得到的部件，
# 出来的几只 DLL 加起来十兆上下。
#
# 运行环境：MSYS2 的 bash，且必须是从「x64 Native Tools Command Prompt」
# （即跑过 vcvars64.bat 的环境）里启动的——configure 要能直接找到 cl / link。
# 需要 MSYS2 包：make nasm diffutils pkgconf
#
# 用法：
#   build_ffmpeg_windows.sh <ffmpeg 源码目录> <nv-codec-headers 目录> <AMF 仓库目录> \
#                           <dav1d 安装目录> <输出目录>
#
# 几样源码各自从官方取：
#   FFmpeg 8.1         https://ffmpeg.org/releases/ffmpeg-8.1.tar.xz
#   nv-codec-headers   https://github.com/FFmpeg/nv-codec-headers  （tag n12.2.72.0）
#   AMF                https://github.com/GPUOpen-LibrariesAndSDKs/AMF （只用头文件）
#   dav1d 1.5.5        https://github.com/videolan/dav1d
#
# dav1d（AV1 软解）要先自己编成静态库。它用 meson，不走这里的 make，所以不在
# 本脚本里编。在 vcvars64 环境里，PATH 上有 meson、ninja、nasm 的前提下：
#   meson setup <构建目录> --buildtype=release --default-library=static \
#       -Denable_tools=false -Denable_tests=false -Db_vscrt=mt --prefix=<安装目录>
#   meson compile -C <构建目录> && meson install -C <构建目录>
# 再把源码根目录里的 COPYING 拷到 <安装目录>/COPYING（meson 不装它，这里要用）。
set -euo pipefail

SRC=$(cd "$1" && pwd)
NVHEADERS=$(cd "$2" && pwd)
AMF=$(cd "$3" && pwd)
DAV1D=$(cd "$4" && pwd)
mkdir -p "$5"
OUT=$(cd "$5" && pwd)

# MSYS2 自带一个叫 link 的小工具，会抢在 MSVC 的链接器前面。
if [[ "$(command -v link)" == /usr/bin/link* ]]; then
    echo "MSVC link.exe is shadowed by /usr/bin/link; start bash with MSYS2_PATH_TYPE=inherit from a vcvars64 prompt" >&2
    exit 1
fi

DEPS="$OUT/deps"
mkdir -p "$DEPS/include"
# 前缀写成 C:/... 的形式：它会进 .pc 文件，pkg-config 吐出来的 -I 路径最后是
# 给 cl.exe 用的，MSYS 的 /c/... 写法它不认。
make -C "$NVHEADERS" install PREFIX="$(cygpath -m "$DEPS")" >/dev/null
rm -rf "$DEPS/include/AMF"
cp -r "$AMF/amf/public/include" "$DEPS/include/AMF"

# dav1d：拷进同一个依赖目录，顺手抹平两处 MSVC 下对不上的地方——
#   - meson 把静态库装成 libdav1d.a，而 FFmpeg 的 MSVC 链接会把 -ldav1d
#     翻成 dav1d.lib 去找；
#   - 它的 .pc 里前缀是反斜杠路径，pkg-config 会把反斜杠当转义吃掉。
mkdir -p "$DEPS/lib/pkgconfig"
rm -rf "$DEPS/include/dav1d"
cp -r "$DAV1D/include/dav1d" "$DEPS/include/dav1d"
cp "$DAV1D/lib/libdav1d.a" "$DEPS/lib/dav1d.lib"
sed -e "s|^prefix=.*|prefix=$(cygpath -m "$DEPS")|" \
    -e 's|^includedir=.*|includedir=${prefix}/include|' \
    -e 's|^libdir=.*|libdir=${prefix}/lib|' \
    "$DAV1D/lib/pkgconfig/dav1d.pc" > "$DEPS/lib/pkgconfig/dav1d.pc"

# 解码器：只为「读得懂片源」。音频不解码（原样拷贝），所以一个音频解码器都不开。
# AV1 走 libdav1d：FFmpeg 自带的 av1 解码器只能走硬件加速，没有软解。
DECODERS=h264,hevc,vp8,vp9,libdav1d,mpeg4,mpeg2video,mpeg1video,vc1,wmv3,msmpeg4v3,mjpeg,flv,h263
# 解析器要覆盖片源里可能出现的音视频流——封装器拷贝流时靠它们切帧、取参数。
#
# av1 解析器还有一层不能删的理由：mp4 / mkv 封装器无条件带着一份「编码码流」
# 的类型表，表里只可能有 AV1 和 APV 两种，一种都没启用时它是个空数组初始化，
# MSVC 不认（libavformat/cbs.c: error C7757）。
PARSERS=h264,hevc,vp8,vp9,av1,mpeg4video,mpegvideo,vc1,mjpeg,h263,aac,aac_latm,ac3,mpegaudio,opus,vorbis,flac,dca
DEMUXERS=mov,matroska,avi,flv,mpegts,mpegps,asf,m4v,h264,hevc
MUXERS=mp4,matroska
BSFS=h264_mp4toannexb,hevc_mp4toannexb,extract_extradata,aac_adtstoasc,vp9_superframe,vp9_superframe_split
# 编码器只留硬件的：NVIDIA、AMD，以及系统自带的 Media Foundation（Intel 核显
# 走它的硬件 MFT；什么显卡都没有时它还有微软的软件编码器兜底）。
ENCODERS=h264_nvenc,hevc_nvenc,h264_amf,hevc_amf,h264_mf,hevc_mf

BUILD="$OUT/build"
mkdir -p "$BUILD"
cd "$BUILD"

PKG_CONFIG_PATH="$DEPS/lib/pkgconfig" "$SRC/configure" \
    --toolchain=msvc --arch=x86_64 --target-os=win64 \
    --prefix="$OUT/install" \
    --enable-shared --disable-static \
    --disable-everything --disable-autodetect \
    --disable-programs --disable-doc --disable-debug \
    --disable-avdevice --disable-avfilter --disable-swresample \
    --disable-network \
    --enable-libdav1d \
    --enable-ffnvcodec --enable-nvenc --enable-amf --enable-mediafoundation --enable-d3d11va \
    --enable-decoder=$DECODERS \
    --enable-parser=$PARSERS \
    --enable-demuxer=$DEMUXERS \
    --enable-muxer=$MUXERS \
    --enable-bsf=$BSFS \
    --enable-encoder=$ENCODERS \
    --enable-protocol=file \
    --extra-cflags="-I$(cygpath -m "$DEPS/include")"

make -j"$(nproc)"
make install

# MSVC 工具链把导入库装成 bin/*.lib，挪到 lib/ 下，和引擎的 CMake 约定对上。
mkdir -p "$OUT/install/lib"
mv "$OUT/install/bin/"*.lib "$OUT/install/lib/" 2>/dev/null || true
cp "$SRC/COPYING.LGPLv2.1" "$OUT/install/LICENSE.txt"
# dav1d 是静态链进 avcodec 的，它的许可证（BSD-2）得跟着一起发。
{
    printf '

==== dav1d (statically linked into avcodec) ====

'
    cat "$DAV1D/COPYING"
} >> "$OUT/install/LICENSE.txt"
echo "done: $OUT/install"
