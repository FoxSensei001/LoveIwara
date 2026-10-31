import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'package:i_iwara/utils/logger_utils.dart';

/// Exits the application host, including the surrounding scene for an XR panel.
/// SystemNavigator.pop alone only backs out of the embedded Android activity.
class AppExit {
  AppExit._();

  static const _immersive = MethodChannel('i_iwara/immersive');

  static bool get _isDesktop =>
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static Future<void> exit() async {
    try {
      if (await _immersive.invokeMethod<bool>('exitApp') == true) return;
    } on MissingPluginException {
      // The standard build and desktop platforms have no immersive host.
    }

    // 桌面端必须走 windowManager.close()：SystemNavigator.pop() 在
    // Windows/Linux/macOS 上是空实现，一路点到这里只会「提示了要退出，然后
    // 什么也没发生」——宽屏侧边栏那枚返回钮按到底就是这个样子
    // （用户 2026-10-31，PC 实测）。close() 发 WM_CLOSE，被 main.dart 的
    // setPreventClose(true) 拦下交给 DesktopWindowListener.onWindowClose，
    // 和标题栏关闭按钮完全同一条收尾路径（停声 → 限时清理 → destroy）。
    if (_isDesktop) {
      try {
        await windowManager.close();
        return;
      } catch (e) {
        // 窗口管理器没初始化等极端情况：继续走平台默认路径，别把退出吞掉。
        LogUtils.w(
          'windowManager.close() 失败，回退到 SystemNavigator.pop(): $e',
          'AppExit',
        );
      }
    }

    await SystemNavigator.pop();
  }
}
