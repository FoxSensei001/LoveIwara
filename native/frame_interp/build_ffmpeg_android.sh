#!/usr/bin/env bash
# 给补帧引擎编一份裁剪过的 FFmpeg（Android arm64-v8a，NDK clang，LGPL），连带
# 它要静态链进去的 dav1d（AV1 软解）。
#
# 和 Windows 那份（build_ffmpeg_windows.sh）开的部件基本一样，差在两处：
#   - 编码器换成系统的 MediaCodec（走 NDK 接口，不需要 JavaVM）；
#   - 库名统一加 `_fi` 后缀（libavcodec_fi.so 这样）。播放器 media_kit 在安卓上
#     也带着一份 FFmpeg，打进同一个 APK 的 lib/arm64-v8a/ 里，同名就会撞。
#
# 运行环境（两种都行）：
#   - Windows：MSYS2 的 bash（要 make、pkgconf、diffutils），NDK 用 Windows 版；
#   - Linux / macOS：任意 bash，NDK 用对应主机版。
# 都要能在 PATH 上找到 meson 和 ninja（`pip install meson ninja` 即可）。
#
# 环境变量：
#   ANDROID_NDK   NDK 根目录（r26 及以上）
#
# 用法：
#   build_ffmpeg_android.sh <ffmpeg 源码目录> <dav1d 源码目录> <输出目录>
#
# 两样源码各自从官方取：
#   FFmpeg 8.1    https://ffmpeg.org/releases/ffmpeg-8.1.tar.xz
#   dav1d 1.5.5   https://downloads.videolan.org/pub/videolan/dav1d/1.5.5/dav1d-1.5.5.tar.xz
#
# 产物：<输出目录>/install（include、lib/*.so、LICENSE.txt），交给
# build_android.sh 的 FFMPEG_DIR。
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <ffmpeg-src> <dav1d-src> <out-dir>" >&2
    exit 2
fi
: "${ANDROID_NDK:?set ANDROID_NDK to the NDK root}"

SRC=$(cd "$1" && pwd)
DAV1D_SRC=$(cd "$2" && pwd)
mkdir -p "$3"
OUT=$(cd "$3" && pwd)

# 和应用的 minSdk 对齐：低于它的设备本来也装不上应用。
API=24
TARGET=aarch64-linux-android$API

case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*)
        HOST_TAG=windows-x86_64
        EXE=.exe
        # 交给原生工具（clang、meson 写进 .pc 的前缀）的路径一律写成 C:/... 形式，
        # MSYS 的 /c/... 它们不认。
        native_path() { cygpath -m "$1"; }
        ;;
    Darwin)
        HOST_TAG=darwin-x86_64
        EXE=
        native_path() { echo "$1"; }
        ;;
    *)
        HOST_TAG=linux-x86_64
        EXE=
        native_path() { echo "$1"; }
        ;;
esac

NDK=$(native_path "$ANDROID_NDK")
BIN="$NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin"
CC="$BIN/clang$EXE"
CXX="$BIN/clang++$EXE"
AR="$BIN/llvm-ar$EXE"
NM="$BIN/llvm-nm$EXE"
RANLIB="$BIN/llvm-ranlib$EXE"
STRIP="$BIN/llvm-strip$EXE"
[[ -x "$CC" || -f "$CC" ]] || { echo "clang not found at $CC" >&2; exit 1; }

# configure 要一个主机编译器，MSYS2 里通常没有 gcc。这套配置不编、也不跑任何
# 主机工具，configure 只拿它做语法检查，交叉编译器顶上就行。Linux / macOS 主机上
# 有现成的 cc，不用管。
HOST_CC_FLAGS=()
if [[ "$HOST_TAG" == windows-x86_64 ]]; then
    HOST_CC_FLAGS=(--host-cc="$CC" --host-cflags="--target=$TARGET"
                   --host-ldflags="--target=$TARGET")
fi

DEPS="$OUT/deps"
mkdir -p "$DEPS"

# ---- dav1d：静态库，链进 avcodec ------------------------------------------

CROSS="$OUT/android-$TARGET.ini"
cat > "$CROSS" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'

[built-in options]
c_args = ['--target=$TARGET', '-fPIC']
c_link_args = ['--target=$TARGET']

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
EOF

DAV1D_BUILD="$OUT/dav1d-build"
rm -rf "$DAV1D_BUILD"
# Windows 上的 meson 在 PATH 里找不到任何 C 编译器时会去拉 Visual Studio 的环境，
# 而在 MSYS2 里那一步直接崩。把 NDK 的 clang 放到 PATH 上，它就不去找了。
export PATH="$ANDROID_NDK/toolchains/llvm/prebuilt/$HOST_TAG/bin:$PATH"
# 交叉编译时 meson 按「目标系统」的规矩检查前缀，Windows 主机上的 C:/... 过不了
# 这一关。所以前缀写 /，装的时候用 destdir 落到依赖目录，再把 .pc 里的前缀改回
# 真实位置——FFmpeg 的 configure 是照着 .pc 去找头文件和库的。
# MSYS2_ARG_CONV_EXCL：不让 MSYS 把参数里的 / 自作主张改成 C:/msys64/（别的参数
# 已经是原生路径了，不需要它转）。其余系统上这个变量没有作用。
MSYS2_ARG_CONV_EXCL='*' meson setup "$(native_path "$DAV1D_BUILD")" "$(native_path "$DAV1D_SRC")" \
    --cross-file "$(native_path "$CROSS")" \
    --buildtype=release --default-library=static \
    -Denable_tools=false -Denable_tests=false \
    --prefix=/ --libdir=lib --includedir=include
MSYS2_ARG_CONV_EXCL='*' meson compile -C "$(native_path "$DAV1D_BUILD")"
MSYS2_ARG_CONV_EXCL='*' meson install -C "$(native_path "$DAV1D_BUILD")" --destdir "$(native_path "$DEPS")"
sed -i -e "s|^prefix=.*|prefix=$(native_path "$DEPS")|" \
    -e 's|^includedir=.*|includedir=${prefix}/include|' \
    -e 's|^libdir=.*|libdir=${prefix}/lib|' \
    "$DEPS/lib/pkgconfig/dav1d.pc"
cp "$DAV1D_SRC/COPYING" "$DEPS/dav1d-COPYING"

# ---- FFmpeg ---------------------------------------------------------------

# 解码器、解析器、封装与 Windows 版同一张表，理由见 build_ffmpeg_windows.sh。
DECODERS=h264,hevc,vp8,vp9,libdav1d,mpeg4,mpeg2video,mpeg1video,vc1,wmv3,msmpeg4v3,mjpeg,flv,h263
PARSERS=h264,hevc,vp8,vp9,av1,mpeg4video,mpegvideo,vc1,mjpeg,h263,aac,aac_latm,ac3,mpegaudio,opus,vorbis,flac,dca
DEMUXERS=mov,matroska,avi,flv,mpegts,mpegps,asf,m4v,h264,hevc
MUXERS=mp4,matroska
BSFS=h264_mp4toannexb,hevc_mp4toannexb,extract_extradata,aac_adtstoasc,vp9_superframe,vp9_superframe_split
# 安卓上能用的硬件编码器只有 MediaCodec。CDD 要求每台设备都有 H.264 硬编，
# 所以不需要软件编码器兜底。
ENCODERS=h264_mediacodec,hevc_mediacodec

BUILD="$OUT/build"
rm -rf "$BUILD"
mkdir -p "$BUILD"
cd "$BUILD"

PKG_CONFIG_PATH="$DEPS/lib/pkgconfig" "$SRC/configure" \
    --prefix="$OUT/install" \
    --target-os=android --arch=aarch64 --cpu=armv8-a --enable-cross-compile \
    --cc="$CC" --cxx="$CXX" --ar="$AR" --nm="$NM" --ranlib="$RANLIB" --strip="$STRIP" \
    "${HOST_CC_FLAGS[@]}" \
    --extra-cflags="--target=$TARGET -fPIC -O2" \
    --extra-ldflags="--target=$TARGET -Wl,-z,max-page-size=16384" \
    --pkg-config=pkg-config --pkg-config-flags=--static \
    --build-suffix=_fi \
    --enable-pic --enable-shared --disable-static \
    --disable-everything --disable-autodetect \
    --disable-programs --disable-doc --disable-debug \
    --disable-avdevice --disable-avfilter --disable-swresample \
    --disable-network \
    --enable-libdav1d \
    --enable-jni --enable-mediacodec \
    --enable-decoder=$DECODERS \
    --enable-parser=$PARSERS \
    --enable-demuxer=$DEMUXERS \
    --enable-muxer=$MUXERS \
    --enable-bsf=$BSFS \
    --enable-encoder=$ENCODERS \
    --enable-protocol=file

make -j"$(nproc)"
make install

cp "$SRC/COPYING.LGPLv2.1" "$OUT/install/LICENSE.txt"
{
    printf '\n\n==== dav1d (statically linked into avcodec) ====\n\n'
    cat "$DEPS/dav1d-COPYING"
} >> "$OUT/install/LICENSE.txt"
echo "done: $OUT/install"
