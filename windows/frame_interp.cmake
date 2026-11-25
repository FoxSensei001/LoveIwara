# 把补帧组件（引擎库 + 裁剪过的 FFmpeg + ncnn + 模型）打进应用目录。
#
# 组件不参与 Flutter 的编译；这里只负责在 install 阶段把一个现成的组件目录
# 原样拷到可执行文件旁边的 frame_interp/ 下。应用启动时看这个目录在不在，
# 在就露出补帧入口（lib/app/services/frame_interp/frame_interp_component.dart）。
#
# 组件从哪来，按下面的顺序找：
#
#   1. FRAME_INTERP_COMPONENT_DIR —— 一个已经构建好的完整组件目录（见
#      native/frame_interp/build_windows.ps1）。CMake 变量或同名环境变量都行；
#      改引擎的时候用它，免得每改一次都要重新发包。
#   2. 否则按下面写死的地址和哈希下载、拼出来（做法同 media_kit 取 libmpv）。
#      拼成它的三样东西各有各的出处：
#        - 引擎库和裁剪过的 FFmpeg：我们自己构建的，挂在本仓库的 Release 上；
#        - ncnn.dll：直接取 ncnn 官方发布的预编译包——引擎就是对着这一份链的，
#          所以版本和哈希都钉死，换版本必须连引擎一起重新构建；
#        - RIFE 模型：直接取上游仓库某一次提交里的文件。
#      后两样不转存到我们这边：出处一目了然，也省得替别人分发二进制。
#   3. FRAME_INTERP_DISABLE=ON（或同名环境变量非空）—— 这次构建不带补帧。
#
# ⛔ 下载来的东西是要被加载进应用进程的原生代码，每一样都必须带哈希校验。

# ---- 2 用到的地址与哈希 ---------------------------------------------------

# 我们自己的包：native/frame_interp/build_windows.ps1 打出来的 zip。
# 重新发包时这两行和 Release 上的文件一起换。
set(_fi_package_url
    "https://github.com/FoxSensei001/LoveIwara/releases/download/frame-interp-1/frame_interp-windows-x64.zip")
set(_fi_package_sha256 "8b37f1fee0705c25239677c4432cc0378f281bd27e692d36c6136a583cc3e0ef")
# 镜像 / 本地验证用：换一个地方取同一个包（哈希照旧校验，所以换不了内容）。
if(DEFINED ENV{FRAME_INTERP_PACKAGE_URL} AND NOT "$ENV{FRAME_INTERP_PACKAGE_URL}" STREQUAL "")
  set(_fi_package_url "$ENV{FRAME_INTERP_PACKAGE_URL}")
endif()

set(_fi_ncnn_url
    "https://github.com/Tencent/ncnn/releases/download/20261020/ncnn-20261020-windows-vs2026-shared.zip")
set(_fi_ncnn_sha256 "e6589801f5b89210e9cda50447a6da955f0f5ef3e19686e1b4a64ddc5910c2ed")
set(_fi_ncnn_dll_in_archive "ncnn-20261020-windows-vs2026-shared/x64/bin/ncnn.dll")

set(_fi_model_name "rife-v4.6")
set(_fi_model_base
    "https://raw.githubusercontent.com/nihui/rife-ncnn-vulkan/a7532fc3f9f8f008cd6eecd6f2ffe2a9698e0cf7/models/rife-v4.6")
set(_fi_model_bin_sha256 "f334ed2260149ce0188a6dcf049844e8b0cdd912e01cbcfb63553157d2508958")
set(_fi_model_param_sha256 "724569596bcd1e7b9fa50455c604777ebed99746d2ef40aa86e31b5725f1053c")

# 下载一个文件并校验哈希，失败重试几次。
#
# 不用 file(DOWNLOAD ... EXPECTED_HASH)：它一次连不上就直接让整个配置失败，
# 而从国内连 GitHub 握手失败是常事，重试一下多半就过了。
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
      # 下下来了但内容不对：这不是网络抖动，重试没有意义。
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

# 故意不进缓存：`flutter build` 每次都会重新配置，环境变量换了（或撤了）
# 就该立刻跟着变，而不是继续用上一次构建记下来的那个值。
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
else()
  # 目录名带着三样东西的哈希：任何一样换了都会另起一个目录重新拼，
  # 不会和上一版的文件混在一起。
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

    set(_fi_ncnn_zip "${_fi_cache}/ncnn-${_fi_key_b}.zip")
    set(_fi_ncnn_tmp "${_fi_cache}/ncnn-${_fi_key_b}")
    _fi_download("${_fi_ncnn_url}" "${_fi_ncnn_zip}" "${_fi_ncnn_sha256}")
    file(ARCHIVE_EXTRACT INPUT "${_fi_ncnn_zip}" DESTINATION "${_fi_ncnn_tmp}"
      PATTERNS "${_fi_ncnn_dll_in_archive}")
    file(COPY "${_fi_ncnn_tmp}/${_fi_ncnn_dll_in_archive}" DESTINATION "${_fi_assembled}")
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

# 每次都先清掉上一次装进去的：组件换了版本、或者这次不带了，旧文件都不该留着。
install(CODE "
  file(REMOVE_RECURSE \"\${CMAKE_INSTALL_PREFIX}/frame_interp\")
  " COMPONENT Runtime)

if(_fi_source)
  message(STATUS "Bundling frame interpolation component from ${_fi_source}")
  install(DIRECTORY "${_fi_source}/"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/frame_interp"
    COMPONENT Runtime
    PATTERN ".assembled" EXCLUDE)
endif()
