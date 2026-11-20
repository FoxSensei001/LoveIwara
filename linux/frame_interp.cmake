# 把补帧组件（引擎库 + 裁剪过的 FFmpeg + ncnn + 模型）打进应用的 lib/frame_interp/。
#
# 和 windows/frame_interp.cmake 是同一套做法：组件不参与 Flutter 的编译，这里只
# 负责在 install 阶段把一个现成的组件目录原样拷进去。应用启动时看这个目录在不在，
# 在就露出补帧入口（lib/app/services/frame_interp/frame_interp_component.dart）。
#
# 组件从哪来，按下面的顺序找：
#
#   1. FRAME_INTERP_COMPONENT_DIR —— native/frame_interp/build_linux.sh 出的完整
#      组件目录。CMake 变量或同名环境变量都行；改引擎的时候用它。
#   2. 否则按下面写死的地址和哈希下载、拼出来：
#        - 引擎库、裁剪过的 FFmpeg、OpenMP 运行时：我们自己构建的，挂在本仓库的
#          Release 上；
#        - libncnn.so.1：直接取 ncnn 官方发布的预编译包（引擎就是对着这一份链的，
#          换版本必须连引擎一起重新构建）；
#        - RIFE 模型：直接取上游仓库某一次提交里的文件（和 Windows 同一份）。
#      我们自己的包还没发布（下面的地址为空）时，这次构建不带补帧，只打一行提示。
#   3. FRAME_INTERP_DISABLE=ON（或同名环境变量非空）—— 这次构建不带补帧。
#
# ⛔ 下载来的东西是要被加载进应用进程的原生代码，每一样都必须带哈希校验。

# ---- 2 用到的地址与哈希 ---------------------------------------------------

# 我们自己的包：native/frame_interp/build_linux.sh 打出来的 zip。
# 发布到 Release 之后，把地址和它打印出来的 SHA-256 一起填上。
set(_fi_package_url "")
set(_fi_package_sha256 "")
# 环境变量 FRAME_INTERP_PACKAGE_URL 只换下载地址（镜像），哈希照旧用上面这个；连同
# FRAME_INTERP_PACKAGE_SHA256 一起给，就整个换成另一份包——CI 拿刚编出来、还没发布的
# 包验打包时用（.github/workflows/frame-interp-component.yml）。
if(DEFINED ENV{FRAME_INTERP_PACKAGE_URL} AND NOT "$ENV{FRAME_INTERP_PACKAGE_URL}" STREQUAL "")
  set(_fi_package_url "$ENV{FRAME_INTERP_PACKAGE_URL}")
  if(DEFINED ENV{FRAME_INTERP_PACKAGE_SHA256} AND NOT "$ENV{FRAME_INTERP_PACKAGE_SHA256}" STREQUAL "")
    string(TOLOWER "$ENV{FRAME_INTERP_PACKAGE_SHA256}" _fi_package_sha256)
  endif()
endif()

set(_fi_ncnn_url
    "https://github.com/Tencent/ncnn/releases/download/20261020/ncnn-20261020-ubuntu-2204-shared.zip")
set(_fi_ncnn_sha256 "d3152bf1bc0003b41f7cc8f50636df4fa28c87e63afaa21122e5f4bf759f50ca")

set(_fi_model_name "rife-v4.6")
set(_fi_model_base
    "https://raw.githubusercontent.com/nihui/rife-ncnn-vulkan/a7532fc3f9f8f008cd6eecd6f2ffe2a9698e0cf7/models/rife-v4.6")
set(_fi_model_bin_sha256 "f334ed2260149ce0188a6dcf049844e8b0cdd912e01cbcfb63553157d2508958")
set(_fi_model_param_sha256 "724569596bcd1e7b9fa50455c604777ebed99746d2ef40aa86e31b5725f1053c")

# 下载一个文件并校验哈希，失败重试几次。理由同 windows/frame_interp.cmake。
function(_fi_download url destination sha256)
  if(EXISTS "${destination}")
    file(SHA256 "${destination}" _have)
    if(_have STREQUAL "${sha256}")
      return()
    endif()
  endif()
  foreach(_attempt RANGE 1 4)
    file(DOWNLOAD "${url}" "${destination}" STATUS _status SHOW_PROGRESS)
    list(GET _status 0 _code)
    if(_code EQUAL 0)
      file(SHA256 "${destination}" _have)
      if(_have STREQUAL "${sha256}")
        return()
      endif()
      file(REMOVE "${destination}")
      message(FATAL_ERROR
        "Checksum mismatch for ${url}
  expected ${sha256}
  got      ${_have}")
    endif()
    message(STATUS "Download failed (attempt ${_attempt}): ${_status}")
  endforeach()
  file(REMOVE "${destination}")
  message(FATAL_ERROR
    "Could not download ${url}. Check the network, or set FRAME_INTERP_COMPONENT_DIR "
    "to a locally built component, or FRAME_INTERP_DISABLE=1 to build without it.")
endfunction()

# ---- 选来源 ---------------------------------------------------------------

# 故意不进缓存：理由同 windows/frame_interp.cmake。
if(NOT DEFINED FRAME_INTERP_COMPONENT_DIR)
  set(FRAME_INTERP_COMPONENT_DIR "$ENV{FRAME_INTERP_COMPONENT_DIR}")
endif()
if(NOT DEFINED FRAME_INTERP_DISABLE)
  set(FRAME_INTERP_DISABLE "$ENV{FRAME_INTERP_DISABLE}")
endif()

set(_fi_source "")

if(FRAME_INTERP_DISABLE)
  message(STATUS "Frame interpolation component disabled for this build")
elseif(FRAME_INTERP_COMPONENT_DIR)
  if(NOT EXISTS "${FRAME_INTERP_COMPONENT_DIR}/manifest.json")
    message(FATAL_ERROR
      "FRAME_INTERP_COMPONENT_DIR has no manifest.json: ${FRAME_INTERP_COMPONENT_DIR}")
  endif()
  set(_fi_source "${FRAME_INTERP_COMPONENT_DIR}")
elseif(_fi_package_url STREQUAL "" OR _fi_package_sha256 STREQUAL "")
  message(STATUS "Frame interpolation: no Linux package configured yet; building without it")
else()
  string(SUBSTRING "${_fi_package_sha256}" 0 12 _fi_key_a)
  string(SUBSTRING "${_fi_ncnn_sha256}" 0 12 _fi_key_b)
  string(SUBSTRING "${_fi_model_bin_sha256}" 0 12 _fi_key_c)
  set(_fi_cache "${CMAKE_BINARY_DIR}/frame_interp_cache")
  set(_fi_assembled "${_fi_cache}/${_fi_key_a}-${_fi_key_b}-${_fi_key_c}")
  set(_fi_done "${_fi_assembled}/.assembled")

  if(NOT EXISTS "${_fi_done}")
    message(STATUS "Fetching frame interpolation component")
    file(REMOVE_RECURSE "${_fi_assembled}")
    file(MAKE_DIRECTORY "${_fi_assembled}/models/${_fi_model_name}")

    set(_fi_package_zip "${_fi_cache}/package-${_fi_key_a}.zip")
    _fi_download("${_fi_package_url}" "${_fi_package_zip}" "${_fi_package_sha256}")
    file(ARCHIVE_EXTRACT INPUT "${_fi_package_zip}" DESTINATION "${_fi_assembled}")

    # 预编译包里 libncnn.so → libncnn.so.1 → libncnn.so.1.0.<版本>。引擎按 soname
    # （libncnn.so.1）找它，所以只取真文件、按 soname 起名。
    set(_fi_ncnn_zip "${_fi_cache}/ncnn-${_fi_key_b}.zip")
    set(_fi_ncnn_tmp "${_fi_cache}/ncnn-${_fi_key_b}")
    _fi_download("${_fi_ncnn_url}" "${_fi_ncnn_zip}" "${_fi_ncnn_sha256}")
    file(REMOVE_RECURSE "${_fi_ncnn_tmp}")
    file(ARCHIVE_EXTRACT INPUT "${_fi_ncnn_zip}" DESTINATION "${_fi_ncnn_tmp}"
      PATTERNS "*/lib/libncnn.so*")
    file(GLOB_RECURSE _fi_ncnn_candidates "${_fi_ncnn_tmp}/*/lib/libncnn.so.*")
    set(_fi_ncnn_real "")
    foreach(_candidate ${_fi_ncnn_candidates})
      if(NOT IS_SYMLINK "${_candidate}")
        set(_fi_ncnn_real "${_candidate}")
      endif()
    endforeach()
    if(_fi_ncnn_real STREQUAL "")
      message(FATAL_ERROR "libncnn.so not found in ${_fi_ncnn_zip}")
    endif()
    file(COPY_FILE "${_fi_ncnn_real}" "${_fi_assembled}/libncnn.so.1")
    file(REMOVE_RECURSE "${_fi_ncnn_tmp}")

    _fi_download("${_fi_model_base}/flownet.bin"
      "${_fi_assembled}/models/${_fi_model_name}/flownet.bin" "${_fi_model_bin_sha256}")
    _fi_download("${_fi_model_base}/flownet.param"
      "${_fi_assembled}/models/${_fi_model_name}/flownet.param" "${_fi_model_param_sha256}")

    if(NOT EXISTS "${_fi_assembled}/manifest.json")
      message(FATAL_ERROR "Frame interpolation package has no manifest.json")
    endif()
    file(WRITE "${_fi_done}" "")
  endif()
  set(_fi_source "${_fi_assembled}")
endif()

# ---- 打进应用目录 ---------------------------------------------------------

install(CODE "
  file(REMOVE_RECURSE \"${INSTALL_BUNDLE_LIB_DIR}/frame_interp\")
  " COMPONENT Runtime)

if(_fi_source)
  message(STATUS "Bundling frame interpolation component from ${_fi_source}")
  install(DIRECTORY "${_fi_source}/"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}/frame_interp"
    COMPONENT Runtime
    USE_SOURCE_PERMISSIONS
    PATTERN ".assembled" EXCLUDE)
endif()
