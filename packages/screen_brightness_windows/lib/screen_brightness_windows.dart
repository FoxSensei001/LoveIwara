import 'dart:async';

import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';

/// Windows 平台的空实现（no-op）。
///
/// 上游 `screen_brightness_windows`（原生 C++ `ScreenBrightnessWindowsPlugin`）
/// 通过 DDC/CI（`GetMonitorBrightness` / `SetMonitorBrightness`，Dxva2.lib）直接
/// 读写**物理显示器的硬件亮度**，并且在窗口收到 `WM_CLOSE` / `WM_DESTROY` 时
/// 无条件调用 `OnApplicationPause()` → `SetScreenBrightness(缓存值)`。当某些显示器
/// 的 DDC/CI 读数不稳定/刻度不匹配时，缓存值接近 0，于是**关闭软件的瞬间会把整个
/// 系统的硬件亮度写成 0（整屏变黑）**，且关掉软件后也不会恢复。
///
/// 本 App 在桌面端并不需要亮度功能：手势调亮度在 desktop 已被禁用，
/// `setDefaultBrightness()` 也只在 Android/iOS 生效。而关窗变黑是原生处理器所为，
/// 任何 Dart 侧调用（包括 `setAutoReset(false)`）都无法阻止它。因此这里用一个
/// 纯 Dart 的空实现，通过 `dependency_overrides` 顶替上游 Windows 实现：没有任何
/// C++ 被注册，就不会挂 WndProc，也就不会碰 DDC/CI，从根上消除该问题。
///
/// Android / iOS / macOS 的实现完全不受影响。
class ScreenBrightnessWindows extends ScreenBrightnessPlatform {
  /// 由 Flutter 自动生成的 Dart 插件注册器调用。
  static void registerWith() {
    ScreenBrightnessPlatform.instance = ScreenBrightnessWindows();
  }

  /// 仅在内存里记住 App 设置过的值，绝不下发到硬件。
  double _applicationBrightness = 1.0;

  @override
  Future<double> get system async => 1.0;

  @override
  Future<void> setSystemScreenBrightness(double brightness) async {
    // no-op：不操作系统/硬件亮度。
  }

  @override
  Stream<double> get onSystemScreenBrightnessChanged =>
      const Stream<double>.empty();

  @override
  Future<double> get application async => _applicationBrightness;

  @override
  Future<void> setApplicationScreenBrightness(double brightness) async {
    // 只记录数值，不下发到显示器硬件。
    _applicationBrightness = brightness;
  }

  @override
  Future<void> resetApplicationScreenBrightness() async {
    // no-op：无需恢复，因为我们从未改过硬件亮度。
  }

  @override
  Stream<double> get onApplicationScreenBrightnessChanged =>
      const Stream<double>.empty();

  @override
  Future<bool> get hasApplicationScreenBrightnessChanged async => false;

  @override
  Future<bool> get isAutoReset async => false;

  @override
  Future<void> setAutoReset(bool isAutoReset) async {
    // no-op
  }

  @override
  Future<bool> get isAnimate async => false;

  @override
  Future<void> setAnimate(bool isAnimate) async {
    // no-op
  }

  @override
  Future<bool> get canChangeSystemBrightness async => false;
}
