import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

/// 桌面端「原生全屏」的唯一事实来源。
///
/// # ⛔ 为什么不能直接问 `windowManager.isFullScreen()`
///
/// 本应用的桌面全屏是 media_kit_video 的 `Utils.EnterNativeFullscreen` 做的：
/// 它自己摘掉 `WS_OVERLAPPEDWINDOW` 再 `SetWindowPos` 铺满显示器
/// （见 media_kit_video/windows/utils.cc）。而 window_manager 在 Windows 上
/// 的 `IsFullScreen()` 只是回读它自己的 `g_is_window_fullscreen`——那个布尔
/// 只由它自己的 `setFullScreen` 置位。两条路谁也不认识谁，于是这个查询在
/// Windows 上**恒为 false**。
///
/// 信了它的代价是实打实的：全屏中换片时，新页会把「当前这个已经满屏的窗口
/// 几何」当成「进全屏前的几何」缓存下来，退出全屏再也还原不回原始窗口大小
/// （2026-08-30 用户报障）。所以进/出全屏一律经由 [markEntered] / [markExited]
/// 在这里留痕，判据以本标志为准。
class DesktopNativeFullscreen {
  DesktopNativeFullscreen._();

  static bool _active = false;

  /// 同步查询：本进程有没有把窗口切进原生全屏。
  ///
  /// 给窗口几何持久化这类高频回调用——它们跑在 resize/move 事件上，不该为了
  /// 问一句状态再多走一次 MethodChannel。
  static bool get isActive => _active;

  static void markEntered() => _active = true;

  static void markExited() => _active = false;

  /// 异步查询：本地标记 **或** 窗口管理器自己的状态。
  ///
  /// macOS / Linux 上全屏可能由系统侧发起（绿灯钮、WM 快捷键），那种情况本地
  /// 标记看不见，得再问一次 window_manager 兜底。Windows 上后半句恒 false，
  /// 由前半句负责。
  static Future<bool> resolve() async {
    if (!GetPlatform.isDesktop) return false;
    if (_active) return true;
    try {
      return await windowManager.isFullScreen();
    } catch (_) {
      return false;
    }
  }
}
