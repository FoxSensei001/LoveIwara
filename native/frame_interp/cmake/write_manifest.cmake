# 在 install 阶段运行：扫一遍已经装进组件目录的动态库，写出 manifest.json。
#
# 入参（由 CMakeLists.txt 用 install(CODE "set(...)") 先行设好）：
#   FI_PLATFORM        例如 windows-x64
#   FI_LIBRARY         引擎库文件名
#   FI_MODEL_NAME      模型目录名
#   FI_ABI             引擎的 ABI 版本号
#   FI_PRELOAD_GLOBS   依赖库的通配，按依赖顺序排（被依赖的在前）
set(entries)
foreach(pattern ${FI_PRELOAD_GLOBS})
    file(GLOB hits RELATIVE "${CMAKE_INSTALL_PREFIX}" "${CMAKE_INSTALL_PREFIX}/${pattern}")
    list(SORT hits)
    foreach(hit ${hits})
        list(APPEND entries "\"${hit}\"")
    endforeach()
endforeach()
list(JOIN entries ", " preload)

file(WRITE "${CMAKE_INSTALL_PREFIX}/manifest.json"
"{
  \"abi\": ${FI_ABI},
  \"platform\": \"${FI_PLATFORM}\",
  \"library\": \"${FI_LIBRARY}\",
  \"preload\": [${preload}],
  \"model\": \"models/${FI_MODEL_NAME}\"
}
")
