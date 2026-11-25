# 构建 Windows x64 的补帧组件包。
#
# 本文件必须存成带 BOM 的 UTF-8：Windows PowerShell 5.1 把不带 BOM 的脚本按系统
# 代码页读，中文注释的尾字节会把换行吞掉，下一行命令就被并进注释里不执行了。
#
# 产物有两样：
#   <OutDir>\frame_interp-windows-x64\      完整的组件目录。构建应用时把环境变量
#                                           FRAME_INTERP_COMPONENT_DIR 指向它，
#                                           windows/frame_interp.cmake 就会把它
#                                           打进应用目录。
#   <OutDir>\frame_interp-windows-x64.zip   发布用的包：只装我们自己构建的部分
#                                           （引擎库、裁剪过的 FFmpeg、清单、
#                                           许可证），不含 ncnn.dll 和模型——那
#                                           两样由 windows/frame_interp.cmake
#                                           直接从各自的官方出处下载。把它传到
#                                           Release，再把打印出来的 SHA-256 填进
#                                           windows/frame_interp.cmake。
#
# ⛔ 换了 ncnn 版本或模型，windows/frame_interp.cmake 里对应的地址和哈希要跟着
#    一起换：引擎是对着这里的 -NcnnDir 那一份 ncnn 链的。
#
# 三样外部依赖要自己先准备好（都不进仓库）：
#   -NcnnDir    ncnn 预编译包（windows-vs20xx-shared）里的 x64 目录
#               https://github.com/Tencent/ncnn/releases
#   -FfmpegDir  FFmpeg 动态库开发包的根目录。发布用 build_ffmpeg_windows.sh
#               编出来的裁剪版（它的 <输出目录>/install）
#   -ModelDir   RIFE v4.6 模型目录（flownet.param / flownet.bin）
#               https://github.com/nihui/rife-ncnn-vulkan/tree/master/models/rife-v4.6
#
# 用法：
#   .\build_windows.ps1 -NcnnDir <...> -FfmpegDir <...> -ModelDir <...> [-OutDir <...>]
param(
    [Parameter(Mandatory = $true)][string]$NcnnDir,
    [Parameter(Mandatory = $true)][string]$FfmpegDir,
    [Parameter(Mandatory = $true)][string]$ModelDir,
    [string]$OutDir = (Join-Path $PSScriptRoot 'out')
)

$ErrorActionPreference = 'Stop'

$buildDir = Join-Path $OutDir 'build'
$stageDir = Join-Path $OutDir 'frame_interp-windows-x64'
$zipPath = Join-Path $OutDir 'frame_interp-windows-x64.zip'

if (Test-Path $stageDir) { Remove-Item -Recurse -Force $stageDir }
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

cmake -S $PSScriptRoot -B $buildDir -A x64 `
    "-DFI_NCNN_DIR=$NcnnDir" "-DFI_FFMPEG_DIR=$FfmpegDir" "-DFI_MODEL_DIR=$ModelDir" `
    -DFI_BUILD_CLI=OFF
if ($LASTEXITCODE -ne 0) { throw 'cmake configure failed' }

cmake --build $buildDir --config Release
if ($LASTEXITCODE -ne 0) { throw 'cmake build failed' }

cmake --install $buildDir --config Release --prefix $stageDir
if ($LASTEXITCODE -ne 0) { throw 'cmake install failed' }

# 压缩包里不带外层目录：manifest.json 就在根上，解压出来直接就是组件目录。
# 用系统自带的 tar（bsdtar，按扩展名出 zip）：Windows PowerShell 5.1 的
# Compress-Archive 遇到大文件会失败。
tar -a -c -f $zipPath -C $stageDir --exclude ncnn.dll --exclude models .
if ($LASTEXITCODE -ne 0) { throw 'packaging failed' }

$hash = (Get-FileHash -Algorithm SHA256 $zipPath).Hash.ToLower()
$size = (Get-Item $zipPath).Length
Write-Host ''
Write-Host "package: $zipPath"
Write-Host "sha256:  $hash"
Write-Host "bytes:   $size"
