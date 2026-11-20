# 离线补帧引擎。
#
# 它不挂在 Flutter 的构建里：应用本体不链接这只库，而是把这里产出的整个目录
# 打进安装包，运行时用 dart:ffi 打开。所以这里是一个独立的 CMake 工程，产物是
# 一个组件目录（cmake --install），由各平台的打包脚本拷进应用目录。
#
# 三样外部依赖都不进仓库，由调用方用变量指过来：
#   FI_NCNN_DIR    ncnn 预编译包里某个架构的根目录（含 include/ncnn、lib、bin）
#   FI_FFMPEG_DIR  FFmpeg 动态库开发包的根目录（含 include、lib、bin）。发布用
#                  build_ffmpeg_windows.sh 编出来的裁剪版；现成的全功能构建也
#                  能用，只是大十倍。
#   FI_MODEL_DIR   RIFE 模型目录（含 flownet.param、flownet.bin）
cmake_minimum_required(VERSION 3.20)
project(frame_interp LANGUAGES CXX)

set(FI_NCNN_DIR "" CACHE PATH "ncnn prebuilt root for the target architecture")
set(FI_FFMPEG_DIR "" CACHE PATH "FFmpeg shared development package root")
set(FI_MODEL_DIR "" CACHE PATH "RIFE model directory (flownet.param / flownet.bin)")
set(FI_MODEL_NAME "rife-v4.6" CACHE STRING "Model directory name inside the component")
option(FI_BUILD_CLI "Build the fi_cli test tool" ON)

# 除了 Windows，FFmpeg 都是带 `_fi` 后缀编的（libavcodec_fi.so），免得和播放器
# 自带的那份同名（见 build_ffmpeg_android.sh / build_ffmpeg_linux.sh）。
if(WIN32)
    set(_fi_default_suffix "")
else()
    set(_fi_default_suffix "_fi")
endif()
set(FI_FFMPEG_SUFFIX "${_fi_default_suffix}" CACHE STRING "FFmpeg --build-suffix")

# 组件清单里的平台名，应用按它认组件（lib/app/services/frame_interp/
# frame_interp_component.dart 的 platformKey）。
if(WIN32)
    set(FI_PLATFORM "windows-x64")
elseif(ANDROID)
    if(NOT ANDROID_ABI STREQUAL "arm64-v8a")
        message(FATAL_ERROR "Only arm64-v8a is supported on Android, got ${ANDROID_ABI}")
    endif()
    set(FI_PLATFORM "android-arm64")
elseif(APPLE)
    # 苹果上组件是一只 FrameInterp.framework，由 build_apple.sh 逐个切片调本工程
    # 编出来再拼成 xcframework。FI_FFMPEG_DIR 在这里指的是装着 Fi*.framework 和
    # include/ 的目录；FI_NCNN_DIR 是 ncnn 源码编出来的静态库安装目录。
    if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        set(FI_PLATFORM "ios-arm64")
    else()
        set(FI_PLATFORM "macos")
    endif()
    # MoltenVK 的静态库（libMoltenVK.a）。ncnn 自带的 Vulkan 加载器在苹果上找不到
    # 系统 Vulkan 时，最后一步就是用静态链进来的 MoltenVK。
    set(FI_MOLTENVK_LIB "" CACHE FILEPATH "libMoltenVK.a for this slice")
    if(NOT EXISTS "${FI_MOLTENVK_LIB}")
        message(FATAL_ERROR "FI_MOLTENVK_LIB is not set or does not exist: '${FI_MOLTENVK_LIB}'")
    endif()
else()
    set(FI_PLATFORM "linux-x64")
endif()

# 苹果上模型可以不带（build_apple.sh 发布用的包不带，应用构建时再放进去）。
set(_fi_required_deps FI_NCNN_DIR FI_FFMPEG_DIR)
if(NOT APPLE)
    list(APPEND _fi_required_deps FI_MODEL_DIR)
endif()
foreach(dep ${_fi_required_deps})
    if(NOT ${dep} OR NOT EXISTS "${${dep}}")
        message(FATAL_ERROR "${dep} is not set or does not exist: '${${dep}}'")
    endif()
endforeach()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# ---- RIFE 的 ncnn 封装（nihui/rife-ncnn-vulkan，MIT，原样收录） -------------

set(RIFE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/rife-ncnn-vulkan")

# 着色器源码在构建时转成字节数组头文件，运行时由 ncnn 内置的 glslang 编成 SPIR-V。
set(RIFE_SHADER_HEADERS)
macro(rife_add_shader SHADER_SRC)
    get_filename_component(SHADER_SRC_NAME_WE ${SHADER_SRC} NAME_WE)
    set(SHADER_COMP_HEADER ${CMAKE_CURRENT_BINARY_DIR}/${SHADER_SRC_NAME_WE}.comp.hex.h)
    add_custom_command(
        OUTPUT ${SHADER_COMP_HEADER}
        COMMAND ${CMAKE_COMMAND}
            -DSHADER_SRC=${RIFE_DIR}/${SHADER_SRC}
            -DSHADER_COMP_HEADER=${SHADER_COMP_HEADER}
            -P "${RIFE_DIR}/generate_shader_comp_header.cmake"
        DEPENDS ${RIFE_DIR}/${SHADER_SRC}
        COMMENT "Preprocessing shader source ${SHADER_SRC_NAME_WE}.comp"
        VERBATIM
    )
    list(APPEND RIFE_SHADER_HEADERS ${SHADER_COMP_HEADER})
endmacro()

rife_add_shader(rife_preproc.comp)
rife_add_shader(rife_postproc.comp)
rife_add_shader(rife_preproc_tta.comp)
rife_add_shader(rife_postproc_tta.comp)
rife_add_shader(rife_flow_tta_avg.comp)
rife_add_shader(rife_v2_flow_tta_avg.comp)
rife_add_shader(rife_v4_flow_tta_avg.comp)
rife_add_shader(rife_flow_tta_temporal_avg.comp)
rife_add_shader(rife_v2_flow_tta_temporal_avg.comp)
rife_add_shader(rife_v4_flow_tta_temporal_avg.comp)
rife_add_shader(rife_out_tta_temporal_avg.comp)
rife_add_shader(rife_v4_timestep.comp)
rife_add_shader(rife_v4_timestep_tta.comp)
rife_add_shader(warp.comp)
rife_add_shader(warp_pack4.comp)
rife_add_shader(warp_pack8.comp)

# ---- 引擎 -----------------------------------------------------------------

add_library(frame_interp SHARED
    src/frame_interp.cpp
    ${RIFE_DIR}/rife.cpp
    ${RIFE_DIR}/warp.cpp
    ${RIFE_SHADER_HEADERS}
)
target_compile_definitions(frame_interp PRIVATE FI_BUILD)

# 非 Windows 的 ncnn 预编译包都是 -fno-rtti 编的（见它自带的 ncnn.cmake 里的
# INTERFACE_COMPILE_OPTIONS）。RIFE 的自定义层继承 ncnn::Layer，开着 RTTI 编就会
# 去要一个 ncnn 里根本没有的 typeinfo，链接不过。只对这两份源码关：引擎自己要用
# 异常，而异常从不穿过 ncnn 的栈帧，所以 -fno-exceptions 不用跟着加。
if(NOT MSVC)
    set_source_files_properties("${RIFE_DIR}/rife.cpp" "${RIFE_DIR}/warp.cpp"
        PROPERTIES COMPILE_OPTIONS "-fno-rtti")
endif()
target_include_directories(frame_interp
    PUBLIC include
    PRIVATE
        ${RIFE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        "${FI_NCNN_DIR}/include/ncnn"
        "${FI_FFMPEG_DIR}/include"
)
if(APPLE)
    # ncnn（连同它带的 glslang）是静态库，整个链进引擎；FFmpeg 是 build_apple.sh
    # 包好的四只动态 framework（LGPL 要求它能被单独替换）。
    file(GLOB FI_NCNN_STATIC "${FI_NCNN_DIR}/lib/*.a")
    target_link_options(frame_interp PRIVATE
        "-F${FI_FFMPEG_DIR}"
        # ncnn 对 vkGetInstanceProcAddr 只是弱引用，不点名的话链接器不会从
        # libMoltenVK.a 里把它拉进来，到运行时就「找不到 Vulkan」。
        "-Wl,-u,_vkGetInstanceProcAddr")
    target_link_libraries(frame_interp PRIVATE ${FI_NCNN_STATIC} "${FI_MOLTENVK_LIB}"
        "-framework FiAvformat" "-framework FiAvcodec" "-framework FiAvutil"
        "-framework FiSwscale"
        "-framework Metal" "-framework Foundation" "-framework QuartzCore"
        "-framework IOSurface" "-framework CoreGraphics")
    if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
        target_link_libraries(frame_interp PRIVATE "-framework UIKit")
        # 引擎在 Frameworks/FrameInterp.framework/FrameInterp，FFmpeg 的 framework
        # 就在上一层。
        set(_fi_rpath "@loader_path/..")
    else()
        target_link_libraries(frame_interp PRIVATE "-framework IOKit" "-framework AppKit")
        # macOS 的 framework 带版本目录：Versions/A/FrameInterp 往上三层才是 Frameworks。
        set(_fi_rpath "@loader_path/../../..")
    endif()

    # 清单和模型作为 framework 的资源打进去：应用在 Resources（iOS 上是 framework
    # 根目录）里读它们。苹果上依赖由 dyld 按 @rpath 自己找，preload 留空。
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/manifest.json"
"{
  \"abi\": 1,
  \"platform\": \"${FI_PLATFORM}\",
  \"library\": \"FrameInterp\",
  \"preload\": [],
  \"model\": \"models/${FI_MODEL_NAME}\"
}
")
    set(_fi_resources "${CMAKE_CURRENT_BINARY_DIR}/manifest.json")
    set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/manifest.json"
        PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
    if(FI_MODEL_DIR)
        set(_fi_models "${FI_MODEL_DIR}/flownet.param" "${FI_MODEL_DIR}/flownet.bin")
        set_source_files_properties(${_fi_models}
            PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/models/${FI_MODEL_NAME}")
        list(APPEND _fi_resources ${_fi_models})
    endif()
    target_sources(frame_interp PRIVATE ${_fi_resources})

    set_target_properties(frame_interp PROPERTIES
        FRAMEWORK TRUE
        OUTPUT_NAME FrameInterp
        MACOSX_FRAMEWORK_IDENTIFIER m.c.g.a.i-iwara.FrameInterp
        MACOSX_FRAMEWORK_BUNDLE_VERSION 1
        MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0
        INSTALL_NAME_DIR "@rpath"
        BUILD_WITH_INSTALL_NAME_DIR ON
        BUILD_RPATH "${_fi_rpath}"
        INSTALL_RPATH "${_fi_rpath}")
else()
    target_link_directories(frame_interp PRIVATE "${FI_NCNN_DIR}/lib" "${FI_FFMPEG_DIR}/lib")
    target_link_libraries(frame_interp PRIVATE ncnn
        avformat${FI_FFMPEG_SUFFIX} avcodec${FI_FFMPEG_SUFFIX}
        avutil${FI_FFMPEG_SUFFIX} swscale${FI_FFMPEG_SUFFIX})
endif()

if(MSVC)
    target_compile_options(frame_interp PRIVATE /utf-8 /EHsc)
    target_compile_definitions(frame_interp PRIVATE _CRT_SECURE_NO_WARNINGS NOMINMAX)
endif()

if(ANDROID)
    # Android 15 起有 16KB 页的设备，按 4KB 对齐的库在那上面装不进来。
    target_link_options(frame_interp PRIVATE "-Wl,-z,max-page-size=16384")
elseif(UNIX AND NOT APPLE)
    # 依赖都平铺在引擎旁边：让动态链接器就近找，而不是去系统目录里撞上发行版
    # 自带的那份同名库。
    set_target_properties(frame_interp PROPERTIES
        BUILD_RPATH "\$ORIGIN" INSTALL_RPATH "\$ORIGIN")
    target_link_options(frame_interp PRIVATE "-Wl,--disable-new-dtags")
endif()

if(FI_BUILD_CLI)
    add_executable(fi_cli tools/fi_cli.cpp)
    target_link_libraries(fi_cli PRIVATE frame_interp)
    if(MSVC)
        target_compile_options(fi_cli PRIVATE /utf-8)
        target_compile_definitions(fi_cli PRIVATE _CRT_SECURE_NO_WARNINGS)
    endif()
endif()

# ---- 组件目录 -------------------------------------------------------------
#
# install 出来的目录就是组件包的内容：引擎库和它依赖的动态库平铺在根上，模型放
# models/<名字>/，各家许可证放 licenses/。依赖怎么找到彼此，各平台不一样：
#   - Windows 靠「同目录优先」，外加应用按清单里的 preload 顺序先逐个加载；
#   - Linux 靠引擎和 FFmpeg 的 RPATH=$ORIGIN；
#   - Android 整个目录会被拆进 APK 的 lib/arm64-v8a/，系统按 soname 在应用自己
#     的库目录里找，用不着这里操心。

install(TARGETS frame_interp
    RUNTIME DESTINATION . LIBRARY DESTINATION . FRAMEWORK DESTINATION .)

# 把一组带版本号的共享库（Linux 上的 libfoo.so.N）按 soname 装进组件：
# 开发包里 libfoo.so.N 只是指向真文件的符号链接，这里装真文件、起 soname 的名字。
function(fi_install_sonamed out_names)
    set(names)
    foreach(pattern ${ARGN})
        file(GLOB candidates "${pattern}")
        foreach(candidate ${candidates})
            get_filename_component(name "${candidate}" NAME)
            if(name MATCHES "\\.so\\.[0-9]+$")
                file(REAL_PATH "${candidate}" real)
                install(FILES "${real}" DESTINATION . RENAME "${name}")
                list(APPEND names "${name}")
            endif()
        endforeach()
    endforeach()
    set(${out_names} ${names} PARENT_SCOPE)
endfunction()

set(_fi_s "${FI_FFMPEG_SUFFIX}")
if(WIN32)
    set(FI_LIBRARY "frame_interp.dll")
    file(GLOB FI_FFMPEG_RUNTIME
        "${FI_FFMPEG_DIR}/bin/avformat-*.dll"
        "${FI_FFMPEG_DIR}/bin/avcodec-*.dll"
        "${FI_FFMPEG_DIR}/bin/avutil-*.dll"
        "${FI_FFMPEG_DIR}/bin/swscale-*.dll"
        "${FI_FFMPEG_DIR}/bin/swresample-*.dll"
    )
    install(FILES ${FI_FFMPEG_RUNTIME} "${FI_NCNN_DIR}/bin/ncnn.dll" DESTINATION .)
    set(FI_PRELOAD_GLOBS "vcomp*.dll" "ncnn.dll" "avutil-*.dll" "swresample-*.dll"
                         "swscale-*.dll" "avcodec-*.dll" "avformat-*.dll")
elseif(ANDROID)
    set(FI_LIBRARY "libframe_interp.so")
    install(FILES
        "${FI_FFMPEG_DIR}/lib/libavutil${_fi_s}.so"
        "${FI_FFMPEG_DIR}/lib/libswscale${_fi_s}.so"
        "${FI_FFMPEG_DIR}/lib/libavcodec${_fi_s}.so"
        "${FI_FFMPEG_DIR}/lib/libavformat${_fi_s}.so"
        "${FI_NCNN_DIR}/lib/libncnn.so"
        DESTINATION .)
    set(FI_PRELOAD_GLOBS "libncnn.so" "libavutil${_fi_s}.so" "libswscale${_fi_s}.so"
                         "libavcodec${_fi_s}.so" "libavformat${_fi_s}.so")
elseif(APPLE)
    # FFmpeg 的 framework 由 build_apple.sh 自己摆，清单和模型已经作为资源打进
    # FrameInterp.framework 了（见上面「引擎」一节）。
else()
    set(FI_LIBRARY "libframe_interp.so")
    fi_install_sonamed(_fi_ffmpeg_names
        "${FI_FFMPEG_DIR}/lib/libavutil${_fi_s}.so.*"
        "${FI_FFMPEG_DIR}/lib/libswscale${_fi_s}.so.*"
        "${FI_FFMPEG_DIR}/lib/libavcodec${_fi_s}.so.*"
        "${FI_FFMPEG_DIR}/lib/libavformat${_fi_s}.so.*")
    fi_install_sonamed(_fi_ncnn_names "${FI_NCNN_DIR}/lib/libncnn.so.*")
    # ncnn 的 OpenMP 运行时。桌面发行版几乎都装着，但最小化安装的系统上未必有，
    # 由构建脚本拷一份放进 ncnn 目录（FI_EXTRA_RUNTIME）一起带上。
    set(FI_EXTRA_RUNTIME "" CACHE FILEPATH "Extra runtime libraries to bundle (e.g. libgomp.so.1)")
    foreach(extra ${FI_EXTRA_RUNTIME})
        install(FILES "${extra}" DESTINATION .)
    endforeach()
    set(FI_PRELOAD_GLOBS "libgomp.so.*" "libncnn.so.*" "libavutil${_fi_s}.so.*"
                         "libswscale${_fi_s}.so.*" "libavcodec${_fi_s}.so.*"
                         "libavformat${_fi_s}.so.*")
endif()

if(NOT APPLE)
    install(FILES "${FI_MODEL_DIR}/flownet.param" "${FI_MODEL_DIR}/flownet.bin"
        DESTINATION "models/${FI_MODEL_NAME}")
endif()
install(FILES "${RIFE_DIR}/LICENSE" DESTINATION licenses RENAME rife-ncnn-vulkan.txt)
if(EXISTS "${FI_FFMPEG_DIR}/LICENSE.txt")
    install(FILES "${FI_FFMPEG_DIR}/LICENSE.txt" DESTINATION licenses RENAME ffmpeg.txt)
endif()

# ncnn.dll 依赖 OpenMP 运行时（vcomp140.dll）。Flutter 应用自带 msvcp140 /
# vcruntime140，却不带这一只，用户机器上没装 VC++ 运行库时会因为它加载失败。
if(MSVC)
    set(CMAKE_INSTALL_OPENMP_LIBRARIES TRUE)
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
    include(InstallRequiredSystemLibraries)
    foreach(lib ${CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS})
        if(lib MATCHES "vcomp[0-9]+\.dll$")
            install(FILES "${lib}" DESTINATION .)
        endif()
    endforeach()
endif()

# 清单：应用靠它认出组件、知道先加载谁再加载谁。
#
# dart:ffi 打开一只动态库时，Windows 只会去应用目录和系统目录里找它的依赖，不会去
# 「这只库自己所在的目录」找。所以应用得按依赖顺序把 preload 里的库逐个按完整
# 路径先加载一遍——已经在进程里的模块按名字就能对上——最后再开 library。
# preload 的顺序就是依赖顺序：被依赖的排前面。别的平台用不着这一步，按同样的
# 顺序先加载一遍也无害，清单格式保持一致。
if(NOT APPLE)
string(REPLACE ";" "\" \"" _fi_globs_quoted "${FI_PRELOAD_GLOBS}")
install(CODE "
set(FI_PLATFORM \"${FI_PLATFORM}\")
set(FI_LIBRARY \"${FI_LIBRARY}\")
set(FI_PRELOAD_GLOBS \"${_fi_globs_quoted}\")
set(FI_MODEL_NAME \"${FI_MODEL_NAME}\")
set(FI_ABI 1)
")
install(SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/write_manifest.cmake")
endif()
