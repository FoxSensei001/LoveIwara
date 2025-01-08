#!/bin/bash

# 检查命令行参数
platform=$1

case $platform in
    "android")
        flutter build apk --release
        ;;
    "windows")
        flutter build windows --release
        ;;
    "macos")
        flutter build macos --release
        ;;
    "linux")
        flutter build linux --release
        ;;
    "web")
        flutter build web --release
        ;;
    "all")
        flutter build windows --release
        flutter build macos --release
        flutter build linux --release
        flutter build web --release
        flutter build apk --release
        ;;
    *)
        echo "Usage: ./build.sh [windows|macos|linux|web|all]"
        exit 1
        ;;
esac
