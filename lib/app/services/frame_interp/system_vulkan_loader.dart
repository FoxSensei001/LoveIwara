import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:win32/win32.dart';

/// 让补帧引擎用上系统自带的 Vulkan 加载器（Windows）。
///
/// # 为什么要管这个
///
/// ncnn 建 Vulkan 实例时按名字加载 `vulkan-1.dll`，而按名字找 DLL，应用目录
/// 排在 System32 前面。应用目录里恰好就有一份：media_kit 随 ANGLE 一起放进来
/// 的 2022 年开发版加载器。它和新驱动的接口对不上——实测 NVIDIA 驱动一建实例
/// 就往它的代码段里写，整个应用当场崩掉。
///
/// 那份文件动不得（播放器的 ANGLE 要用），所以抢在 ncnn 之前按完整路径把
/// System32 那份装进进程：进程里已经有同名模块时，按名字加载直接拿到它，不会
/// 再去搜目录。
///
/// 只用到 dart:ffi，不依赖 Flutter：后台 isolate 里照样能调。
abstract final class SystemVulkanLoader {
  static const String _fileName = 'vulkan-1.dll';

  /// 把系统的加载器装进进程，返回它的句柄；调用方用完后负责关掉。
  ///
  /// 返回 null 时什么都没装：不是 Windows（用不着）、这台机器没有系统加载器
  /// （那也就没有 Vulkan 驱动），或者进程里已经有一份别处的。后两种情况
  /// [isActive] 为 false。
  static DynamicLibrary? pin() {
    if (!Platform.isWindows) return null;
    final systemPath = _systemLoaderPath();
    if (systemPath == null) return null;
    final loaded = _loadedLoaderPath();
    // 别处的那份已经在进程里了：再装一份同名的，按名字加载拿到哪份说不准。
    if (loaded != null && !_samePath(loaded, systemPath)) return null;
    if (!File(systemPath).existsSync()) return null;
    try {
      return DynamicLibrary.open(systemPath);
    } catch (_) {
      return null;
    }
  }

  /// 这会儿按名字加载 `vulkan-1.dll` 拿到的是不是系统那份。
  ///
  /// 为 false 时不许让引擎碰显卡（数显卡、跑作业都算）：ncnn 会自己按名字去
  /// 找，找到的就是应用目录那份旧的。不是 Windows 时恒为 true。
  static bool get isActive {
    if (!Platform.isWindows) return true;
    final systemPath = _systemLoaderPath();
    final loaded = _loadedLoaderPath();
    return systemPath != null &&
        loaded != null &&
        _samePath(loaded, systemPath);
  }

  static bool _samePath(String a, String b) =>
      p.windows.canonicalize(a) == p.windows.canonicalize(b);

  /// `%SystemRoot%\System32\vulkan-1.dll`；取不到系统目录时为 null。
  static String? _systemLoaderPath() {
    final buffer = wsalloc(MAX_PATH);
    try {
      final length = GetSystemDirectory(buffer, MAX_PATH);
      if (length == 0 || length >= MAX_PATH) return null;
      return p.windows.join(buffer.toDartString(length: length), _fileName);
    } finally {
      free(buffer);
    }
  }

  /// 进程里叫 `vulkan-1.dll` 的那个模块的完整路径。没有这个模块时为 null；
  /// 有但读不出路径时为空串（当作别处的）。
  static String? _loadedLoaderPath() {
    const capacity = 1024;
    final name = _fileName.toNativeUtf16();
    final buffer = wsalloc(capacity);
    try {
      final module = GetModuleHandle(name);
      if (module == 0) return null;
      final length = GetModuleFileName(module, buffer, capacity);
      if (length == 0 || length >= capacity) return '';
      return buffer.toDartString(length: length);
    } finally {
      free(name);
      free(buffer);
    }
  }
}
