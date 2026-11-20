#!/usr/bin/env bash
# 构建 iOS / macOS 的补帧组件包（只能在 macOS 上跑，要 Xcode 命令行工具）。
#
# 苹果上组件是一组 xcframework，由 CocoaPods 嵌进应用、按应用的身份签名
# （native/frame_interp/apple/FrameInterp.podspec）：
#   FrameInterp.xcframework   引擎本体。ncnn（连同 glslang）和 MoltenVK 静态链在
#                             里面：ncnn 自带的 Vulkan 加载器在苹果上找不到系统
#                             Vulkan 时，最后一步就是用静态链进来的 MoltenVK。
#                             清单 manifest.json 在它的资源目录里。
#   FiAvutil / FiSwscale / FiAvcodec / FiAvformat.xcframework
#                             裁剪过的 FFmpeg（LGPL），保持动态库，能被单独替换。
#                             名字带 Fi 前缀：播放器 media_kit 在苹果上也带着
#                             一组 FFmpeg 的 framework，同名就会撞。
# 每个 xcframework 有三个切片：ios-arm64、ios-arm64_x86_64-simulator、
# macos-arm64_x86_64。没有模拟器切片的话，链接到模拟器时整个应用都编不过。
#
# 产物：
#   <输出目录>/frame_interp-apple/        组件目录（上面那组 xcframework + licenses/）。
#                                         构建应用时把环境变量
#                                         FRAME_INTERP_APPLE_COMPONENT_DIR 指向它。
#   <输出目录>/frame_interp-apple.zip     发布用的包，内容同上但不含模型——模型由
#                                         apple/prepare_component.sh 从上游下载后
#                                         放进去。把它传到 Release，再把打印出来的
#                                         SHA-256 填进 apple/prepare_component.sh。
#
# 依赖（都不进仓库）：
#   FFMPEG_SRC          FFmpeg 8.1 源码
#   DAV1D_SRC           dav1d 1.5.5 源码
#   NCNN_SRC            ncnn 源码（tag 20261020，带 glslang 子模块）
#   MOLTENVK_XCFRAMEWORK  MoltenVK 发布包里的静态 MoltenVK.xcframework
#                       （MoltenVK/MoltenVK/static/MoltenVK.xcframework）
#   MODEL_DIR           可选：RIFE v4.6 模型目录。给了就直接打进组件目录（本地调试
#                       用）；发布用的 zip 里总是不带。
# PATH 上要有 cmake（3.20+）、ninja、meson、nasm（x86_64 切片的汇编要用）。
#
# 用法：
#   FFMPEG_SRC=... DAV1D_SRC=... NCNN_SRC=... MOLTENVK_XCFRAMEWORK=... build_apple.sh [输出目录]
set -euo pipefail

: "${FFMPEG_SRC:?}" "${DAV1D_SRC:?}" "${NCNN_SRC:?}" "${MOLTENVK_XCFRAMEWORK:?}"
MODEL_DIR=${MODEL_DIR:-}

HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-"$HERE/out"}
mkdir -p "$OUT"
OUT=$(cd "$OUT" && pwd)
WORK="$OUT/apple-work"
STAGE="$OUT/frame_interp-apple"
ZIP="$OUT/frame_interp-apple.zip"
rm -rf "$WORK" "$STAGE" "$ZIP"
mkdir -p "$WORK" "$STAGE/licenses"

IOS_MIN=15.0
MACOS_MIN=12.0
JOBS=$(sysctl -n hw.ncpu)
FFMPEG_LIBS=(avutil swscale avcodec avformat)
# FFmpeg 库名 → framework 名
fw_name() {
    case "$1" in
        avutil) echo FiAvutil ;; swscale) echo FiSwscale ;;
        avcodec) echo FiAvcodec ;; avformat) echo FiAvformat ;;
    esac
}

# 解码器、解析器、封装与 Windows 版同一张表，理由见 build_ffmpeg_windows.sh。
DECODERS=h264,hevc,vp8,vp9,libdav1d,mpeg4,mpeg2video,mpeg1video,vc1,wmv3,msmpeg4v3,mjpeg,flv,h263
PARSERS=h264,hevc,vp8,vp9,av1,mpeg4video,mpegvideo,vc1,mjpeg,h263,aac,aac_latm,ac3,mpegaudio,opus,vorbis,flac,dca
DEMUXERS=mov,matroska,avi,flv,mpegts,mpegps,asf,m4v,h264,hevc
MUXERS=mp4,matroska
BSFS=h264_mp4toannexb,hevc_mp4toannexb,extract_extradata,aac_adtstoasc,vp9_superframe,vp9_superframe_split
# 苹果上只有 VideoToolbox：有硬件编码单元用硬件，没有时退到苹果自带的软件编码器
# （引擎里开了 allow_sw）。
ENCODERS=h264_videotoolbox,hevc_videotoolbox

# 一个切片：<名字> <sdk> <架构> <最低系统的编译参数> <CMake 的 CMAKE_SYSTEM_NAME>
SLICES=(
    "ios-arm64            iphoneos        arm64  -miphoneos-version-min=$IOS_MIN          iOS"
    "iossim-arm64         iphonesimulator arm64  -mios-simulator-version-min=$IOS_MIN     iOS"
    "iossim-x86_64        iphonesimulator x86_64 -mios-simulator-version-min=$IOS_MIN     iOS"
    "macos-arm64          macosx          arm64  -mmacosx-version-min=$MACOS_MIN          Darwin"
    "macos-x86_64         macosx          x86_64 -mmacosx-version-min=$MACOS_MIN          Darwin"
)

cpu_family() { [[ "$1" == arm64 ]] && echo aarch64 || echo x86_64; }

# 把一只 dylib 包成 framework。iOS 的 framework 是扁平的；macOS 的必须带版本目录，
# 否则签名时报「bundle format unrecognized」。
make_framework() {
    local dylib=$1 name=$2 dest=$3 sdk=$4
    local fw="$dest/$name.framework" binary id
    rm -rf "$fw"
    if [[ "$sdk" == macosx ]]; then
        mkdir -p "$fw/Versions/A/Resources"
        cp "$dylib" "$fw/Versions/A/$name"
        ln -s A "$fw/Versions/Current"
        ln -s "Versions/Current/$name" "$fw/$name"
        ln -s Versions/Current/Resources "$fw/Resources"
        binary="$fw/Versions/A/$name"
        id="@rpath/$name.framework/Versions/A/$name"
        write_plist "$fw/Versions/A/Resources/Info.plist" "$name" macosx
    else
        mkdir -p "$fw"
        cp "$dylib" "$fw/$name"
        binary="$fw/$name"
        id="@rpath/$name.framework/$name"
        write_plist "$fw/Info.plist" "$name" "$sdk"
    fi
    install_name_tool -id "$id" "$binary"
}

write_plist() {
    local path=$1 name=$2 sdk=$3 min_key="" min_value=""
    if [[ "$sdk" != macosx ]]; then
        min_key="<key>MinimumOSVersion</key>"
        min_value="<string>$IOS_MIN</string>"
    fi
    cat > "$path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>en</string>
    <key>CFBundleExecutable</key><string>$name</string>
    <key>CFBundleIdentifier</key><string>m.c.g.a.i-iwara.$name</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>$name</string>
    <key>CFBundlePackageType</key><string>FMWK</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    $min_key$min_value
</dict>
</plist>
EOF
}

# 某个 framework 里真正的二进制。
fw_binary() {
    local fw=$1 name
    name=$(basename "$fw" .framework)
    if [[ -d "$fw/Versions/A" ]]; then echo "$fw/Versions/A/$name"; else echo "$fw/$name"; fi
}

moltenvk_slice() {
    case "$1" in
        ios-arm64) find "$MOLTENVK_XCFRAMEWORK" -maxdepth 1 -type d -name 'ios-arm64' ;;
        iossim-*) find "$MOLTENVK_XCFRAMEWORK" -maxdepth 1 -type d -name 'ios-*simulator' ;;
        macos-*) find "$MOLTENVK_XCFRAMEWORK" -maxdepth 1 -type d -name 'macos-*' ;;
    esac
}

build_slice() {
    local slice=$1 sdk=$2 arch=$3 minflag=$4 system=$5
    local dir="$WORK/$slice" sysroot cc minver
    sysroot=$(xcrun -sdk "$sdk" --show-sdk-path)
    cc="xcrun -sdk $sdk clang"
    minver=${minflag#*=}
    mkdir -p "$dir"
    echo "==== $slice"

    # -- dav1d（静态）
    cat > "$dir/cross.ini" <<EOF
[binaries]
c = ['xcrun', '-sdk', '$sdk', 'clang']
ar = ['xcrun', '-sdk', '$sdk', 'ar']
strip = ['xcrun', '-sdk', '$sdk', 'strip']

[built-in options]
c_args = ['-arch', '$arch', '$minflag']
c_link_args = ['-arch', '$arch', '$minflag']

[host_machine]
system = 'darwin'
cpu_family = '$(cpu_family "$arch")'
cpu = '$arch'
endian = 'little'
EOF
    meson setup "$dir/dav1d-build" "$DAV1D_SRC" --cross-file "$dir/cross.ini" \
        --buildtype=release --default-library=static \
        -Denable_tools=false -Denable_tests=false \
        --prefix="$dir/deps" --libdir=lib
    meson compile -C "$dir/dav1d-build"
    meson install -C "$dir/dav1d-build"

    # -- FFmpeg（动态库，随后包成 framework）
    mkdir -p "$dir/ffmpeg-build"
    (cd "$dir/ffmpeg-build" && PKG_CONFIG_PATH="$dir/deps/lib/pkgconfig" "$FFMPEG_SRC/configure" \
        --prefix="$dir/ffmpeg" \
        --enable-cross-compile --target-os=darwin --arch="$arch" \
        --cc="$cc" --sysroot="$sysroot" \
        --extra-cflags="-arch $arch $minflag" --extra-ldflags="-arch $arch $minflag" \
        --pkg-config-flags=--static \
        --build-suffix=_fi --install-name-dir=@rpath \
        --enable-pic --enable-shared --disable-static \
        --disable-everything --disable-autodetect \
        --disable-programs --disable-doc --disable-debug \
        --disable-avdevice --disable-avfilter --disable-swresample \
        --disable-network \
        --enable-libdav1d --enable-videotoolbox \
        --enable-decoder=$DECODERS --enable-parser=$PARSERS \
        --enable-demuxer=$DEMUXERS --enable-muxer=$MUXERS \
        --enable-bsf=$BSFS --enable-encoder=$ENCODERS \
        --enable-protocol=file && make -j"$JOBS" && make install)

    # 包成 framework，并把它们彼此之间的引用从 libavutil_fi.NN.dylib 改成
    # framework 的路径。引擎就是对着这几只 framework 链接的。
    mkdir -p "$dir/frameworks/include"
    cp -R "$dir/ffmpeg/include/." "$dir/frameworks/include/"
    local lib real name binary dep depname depfw depid
    for lib in "${FFMPEG_LIBS[@]}"; do
        real=$(find "$dir/ffmpeg/lib" -maxdepth 1 -type f -name "lib${lib}_fi.*.dylib" | head -1)
        name=$(fw_name "$lib")
        make_framework "$real" "$name" "$dir/frameworks" "$sdk"
    done
    for lib in "${FFMPEG_LIBS[@]}"; do
        binary=$(fw_binary "$dir/frameworks/$(fw_name "$lib").framework")
        # otool -L 的头一行是文件自己；剩下里形如 @rpath/libavutil_fi.60.dylib 的
        # 就是要改的引用。
        for dep in $(otool -L "$binary" | awk 'NR>1 {print $1}' | grep '@rpath/lib.*_fi\.' || true); do
            depname=$(basename "$dep" | sed -E 's/^lib([a-z]+)_fi\..*$/\1/')
            depfw=$(fw_name "$depname")
            if [[ "$sdk" == macosx ]]; then
                depid="@rpath/$depfw.framework/Versions/A/$depfw"
            else
                depid="@rpath/$depfw.framework/$depfw"
            fi
            install_name_tool -change "$dep" "$depid" "$binary"
        done
    done

    # -- ncnn（静态，Vulkan 走它自带的加载器 + 静态链进来的 MoltenVK）
    local system_args=()
    [[ "$system" == iOS ]] && system_args=(-DCMAKE_SYSTEM_NAME=iOS)
    cmake -S "$NCNN_SRC" -B "$dir/ncnn-build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release "${system_args[@]}" \
        -DCMAKE_OSX_SYSROOT="$sdk" -DCMAKE_OSX_ARCHITECTURES="$arch" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$minver" \
        -DCMAKE_INSTALL_PREFIX="$dir/ncnn" \
        -DNCNN_VULKAN=ON -DNCNN_SIMPLEVK=ON -DNCNN_OPENMP=OFF \
        -DNCNN_DISABLE_RTTI=ON -DNCNN_SHARED_LIB=OFF \
        -DNCNN_BUILD_TOOLS=OFF -DNCNN_BUILD_EXAMPLES=OFF \
        -DNCNN_BUILD_BENCHMARK=OFF -DNCNN_BUILD_TESTS=OFF -DNCNN_PYTHON=OFF
    cmake --build "$dir/ncnn-build"
    cmake --install "$dir/ncnn-build"

    # -- 引擎
    local moltenvk
    moltenvk="$(moltenvk_slice "$slice")/libMoltenVK.a"
    local model_args=()
    [[ -n "$MODEL_DIR" ]] && model_args=(-DFI_MODEL_DIR="$MODEL_DIR")
    cmake -S "$HERE" -B "$dir/engine-build" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release "${system_args[@]}" \
        -DCMAKE_OSX_SYSROOT="$sdk" -DCMAKE_OSX_ARCHITECTURES="$arch" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$minver" \
        -DFI_NCNN_DIR="$dir/ncnn" -DFI_FFMPEG_DIR="$dir/frameworks" \
        -DFI_MOLTENVK_LIB="$moltenvk" "${model_args[@]}" \
        -DFI_BUILD_CLI=OFF
    cmake --build "$dir/engine-build"
    cmake --install "$dir/engine-build" --prefix "$dir/engine" --strip
    cp -R "$dir/engine/FrameInterp.framework" "$dir/frameworks/"
    if [[ "$sdk" != macosx ]]; then
        local plist
        plist=$(find "$dir/frameworks/FrameInterp.framework" -maxdepth 2 -name Info.plist | head -1)
        plutil -replace MinimumOSVersion -string "$IOS_MIN" "$plist"
    fi
}

for entry in "${SLICES[@]}"; do
    # shellcheck disable=SC2086
    build_slice $entry
done

# ---- 拼成 xcframework -------------------------------------------------------

# 同一平台的两个架构合成一个通用二进制的 framework。
merge_arches() {
    local into=$1 a=$2 b=$3 fw
    rm -rf "$into"
    mkdir -p "$into"
    for fw in "$a"/*.framework; do
        cp -R "$fw" "$into/"
        local name binary
        name=$(basename "$fw")
        binary=$(fw_binary "$into/$name")
        lipo -create "$(fw_binary "$a/$name")" "$(fw_binary "$b/$name")" -output "$binary"
    done
}
merge_arches "$WORK/macos" "$WORK/macos-arm64/frameworks" "$WORK/macos-x86_64/frameworks"
merge_arches "$WORK/iossim" "$WORK/iossim-arm64/frameworks" "$WORK/iossim-x86_64/frameworks"

for name in FrameInterp FiAvutil FiSwscale FiAvcodec FiAvformat; do
    xcodebuild -create-xcframework \
        -framework "$WORK/ios-arm64/frameworks/$name.framework" \
        -framework "$WORK/iossim/$name.framework" \
        -framework "$WORK/macos/$name.framework" \
        -output "$STAGE/$name.xcframework"
done

cp "$FFMPEG_SRC/COPYING.LGPLv2.1" "$STAGE/licenses/ffmpeg.txt"
cp "$DAV1D_SRC/COPYING" "$STAGE/licenses/dav1d.txt"
cp "$HERE/third_party/rife-ncnn-vulkan/LICENSE" "$STAGE/licenses/rife-ncnn-vulkan.txt"
cp "$NCNN_SRC/LICENSE.txt" "$STAGE/licenses/ncnn.txt"
[[ -f "$NCNN_SRC/glslang/LICENSE.txt" ]] && cp "$NCNN_SRC/glslang/LICENSE.txt" "$STAGE/licenses/glslang.txt"
MOLTENVK_LICENSE=$(find "$(dirname "$MOLTENVK_XCFRAMEWORK")/../.." -maxdepth 2 -name LICENSE | head -1 || true)
[[ -n "$MOLTENVK_LICENSE" ]] && cp "$MOLTENVK_LICENSE" "$STAGE/licenses/moltenvk.txt"

# 发布用的包：去掉模型（应用构建时再从上游取），保留 framework 里的符号链接。
PACK="$WORK/pack"
rm -rf "$PACK"
cp -R "$STAGE" "$PACK"
find "$PACK" -type d -name models -prune -exec rm -rf {} +
(cd "$PACK" && ditto -c -k --sequesterRsrc . "$ZIP")

echo
echo "component: $STAGE"
echo "package:   $ZIP"
echo "sha256:    $(shasum -a 256 "$ZIP" | cut -d' ' -f1)"
echo "bytes:     $(stat -f %z "$ZIP")"
