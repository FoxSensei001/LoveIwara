import 'dart:async';

import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';

/// `screen_brightness` 在 Windows 上的空实现：所有读写都不碰显示器。
///
/// # 为什么不用上游实现
///
/// 上游 `screen_brightness_windows` 2.1.2 的 C++ 插件一注册（也就是 App 一启动）
/// 就用 DDC/CI 读一次显示器亮度缓存起来，并挂上顶层窗口过程钩子：
/// - `WM_CLOSE` / `WM_DESTROY` **不看** `is_auto_reset_`，关窗时无条件把缓存值
///   `SetMonitorBrightness` 写回显示器；
/// - 从插件注册到 Dart 侧 `setAutoReset(false)` 生效之间，失焦也会写一次；
/// - `resetApplicationScreenBrightness` 同样写缓存值。
///
/// 显示器开着 sRGB / HDR 这类锁亮度模式时，那个缓存值可能读成 0 —— 用户报
/// 「屏幕亮度瞬间降到 0」。这些路径在 Dart 侧都关不掉。
///
/// 本 App 在桌面端从不调亮度（亮度手势与默认亮度都只给移动端），所以整体换成
/// 空实现：只有 `dartPluginClass`，没有 `pluginClass`，C++ 不编译、不注册。
///
/// 接入方式：根 pubspec.yaml 的 `dependency_overrides`。
class ScreenBrightnessWindowsNoop extends ScreenBrightnessPlatform {
  /// 由 Flutter 生成的 dart_plugin_registrant 在启动时调用。
  static void registerWith() {
    ScreenBrightnessPlatform.instance = ScreenBrightnessWindowsNoop();
  }

  @override
  Future<double> get system async => 1.0;

  @override
  Future<void> setSystemScreenBrightness(double brightness) async {}

  @override
  Stream<double> get onSystemScreenBrightnessChanged =>
      const Stream<double>.empty();

  @override
  Future<double> get application async => 1.0;

  @override
  Future<void> setApplicationScreenBrightness(double brightness) async {}

  @override
  Future<void> resetApplicationScreenBrightness() async {}

  @override
  Stream<double> get onApplicationScreenBrightnessChanged =>
      const Stream<double>.empty();

  @override
  Future<bool> get hasApplicationScreenBrightnessChanged async => false;

  @override
  Future<bool> get isAutoReset async => false;

  @override
  Future<void> setAutoReset(bool isAutoReset) async {}

  @override
  Future<bool> get isAnimate async => false;

  @override
  Future<void> setAnimate(bool isAnimate) async {}

  @override
  Future<bool> get canChangeSystemBrightness async => false;
}
