import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:window_manager/window_manager.dart';

/// 桌面端「原生全屏会话」的唯一事实来源。
///
/// 它管三件互相咬合的事，缺一件就会漏出用户能看见的坏状态：
///
/// 1. **现在是不是全屏**（[isActive] / [resolve]）
/// 2. **进全屏之前窗口长什么样**（[captureGeometry] / [restoreGeometry]）
/// 3. **这个全屏还有没有人在用**（[acquire] / [release]）
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
/// （2026-08-30 用户报障）。所以进/出全屏一律经由本类留痕，判据以本标志为准。
///
/// # ⛔ 为什么窗口几何快照必须挂在这里，而不是挂在播放页的 controller 上
///
/// 快照原本是 `MyVideoStateController` 的私有字段，靠 `VideoFullscreenHandoff`
/// 在换片时一页页传下去。只要有**一次**没传到，快照就永远消失了——而「换到一条
/// 播不了的片子」恰恰就是那一次：站外短链视频不接手全屏，交接件被有意丢掉，
/// 于是窗口铺满屏幕、再也回不去原来的大小（2026-08-31 用户报障）。
///
/// 全屏是**窗口**的状态，不是某一页的状态。所以快照跟着窗口走，谁来问都答得出。
///
/// # ⛔ 为什么需要 [acquire] / [release]
///
/// 「桌面端已经退出全屏、回到详情页」这件事没有任何系统事件会通知我们：
/// media_kit 那条全屏是我们自己开的，页面被 `pushReplacement` 顶掉时也不会
/// 有人替我们收。真正的判据只有一条——
///
///   **原生全屏还开着，但已经没有任何一页在里面演出了。**
///
/// [acquire] 登记「我在这个全屏里播」，[release] 注销。最后一个演出者离场而
/// 会话还开着，就是一次孤儿会话：收回全屏、还原窗口几何、把标题栏和侧边导航
/// 放回来。这条判据对「全屏连播换片」是免疫的——那是旧页放手前新页已经接手。
class DesktopNativeFullscreen {
  DesktopNativeFullscreen._();

  static const String _tag = 'DesktopNativeFullscreen';

  /// media_kit_video 的原生工具通道。桌面全屏的进与出都只经过它这一条。
  static const MethodChannel _mediaKitChannel = MethodChannel(
    'com.alexmercerind/media_kit_video',
  );

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

  // --------------------------------------------------------------- 进 / 出

  /// 把窗口切进原生全屏，并留痕。
  static Future<void> enterNative() async {
    if (!GetPlatform.isDesktop) return;
    try {
      await _mediaKitChannel.invokeMethod('Utils.EnterNativeFullscreen');
    } catch (e, s) {
      LogUtils.e('进入原生全屏失败', tag: _tag, error: e, stackTrace: s);
    } finally {
      // ⛔ 失败也要留痕：`Utils.EnterNativeFullscreen` 有可能只做了一半
      // （改了窗口样式、SetWindowPos 却抛了），标记漏掉就再也没人来收尾。
      markEntered();
    }
  }

  /// 退出原生全屏，并清掉留痕。**不**负责还原几何——那是 [restoreGeometry]
  /// 的事，调用方按自己的时序决定要不要还原（系统侧退出时窗口已经自己回去了）。
  static Future<void> exitNative() async {
    if (!GetPlatform.isDesktop) return;
    try {
      await _mediaKitChannel.invokeMethod('Utils.ExitNativeFullscreen');
    } catch (e, s) {
      LogUtils.e('退出原生全屏失败', tag: _tag, error: e, stackTrace: s);
    } finally {
      markExited();
    }
  }

  // ----------------------------------------------------------- 会话演出者

  /// 「谁在这个全屏里演出」。装的是播放页的 controller。
  ///
  /// 用 [Set] 而不是计数器：同一个 controller 可能重复 [acquire]（进全屏 +
  /// 全屏接力开局各一次），计数器会配不平，Set 天然幂等。
  static final Set<Object> _presenters = <Object>{};

  static bool _orphanCheckScheduled = false;

  /// 现在还有没有人在全屏里演出。
  static bool get hasPresenter => _presenters.isNotEmpty;

  /// 登记「我在这个全屏里播」。幂等。
  static void acquire(Object presenter) {
    if (!GetPlatform.isDesktop) return;
    _presenters.add(presenter);
  }

  /// 注销演出者。最后一个离场而会话还开着，就排一次孤儿检查。
  static void release(Object presenter) {
    if (!GetPlatform.isDesktop) return;
    if (!_presenters.remove(presenter)) return;
    _scheduleOrphanCheck();
  }

  static Timer? _orphanCheckTimer;

  /// 放手到判定之间的缓冲。
  ///
  /// 「全屏连播换片」是两步：旧页放手、新页接手。`pushReplacement` 下新页的
  /// onInit 跑在旧页 dispose **之前**，所以正常接力根本不会走到这里；这段缓冲
  /// 兜的是别的路径（push 失败后的 NaviService 兜底重开等）里两步倒过来的情形。
  static const Duration _orphanCheckDelay = Duration(milliseconds: 300);

  static void _scheduleOrphanCheck() {
    if (_orphanCheckScheduled) return;
    if (!_active) return;
    if (_presenters.isNotEmpty) return;

    _orphanCheckScheduled = true;
    // ⛔ 用定时器而不是 `addPostFrameCallback`：放手常常发生在路由收尾这种
    // **不一定还会有下一帧**的时刻（页面已经画完、没人再标脏），post-frame 回调
    // 会一直悬着不执行，全屏就永远收不回来。
    _orphanCheckTimer?.cancel();
    _orphanCheckTimer = Timer(_orphanCheckDelay, () {
      _orphanCheckScheduled = false;
      _orphanCheckTimer = null;
      unawaited(_endOrphanedSession());
    });
  }

  /// 孤儿会话收尾：原生全屏还开着，但已经没有任何一页在里面演出。
  ///
  /// 三件事一起做，缺一件用户都看得见：
  /// - 不退原生全屏 → 窗口一直铺满显示器；
  /// - 不还原几何 → macOS / Linux 上退出后停在一个不属于用户的尺寸；
  /// - 不放回 chrome → 标题栏与侧边导航还藏着，窗口拖不动、跳不出视频分区。
  static Future<void> _endOrphanedSession() async {
    if (!GetPlatform.isDesktop) return;
    if (_presenters.isNotEmpty) return;
    // ⛔ 判据只能是**我们自己**开的那个会话（[_active]），不能用 [resolve]：
    // macOS 上用户可能正用绿灯钮把某个非播放页开成全屏，那不是孤儿，是他要的。
    if (!_active) return;

    LogUtils.i('原生全屏已无演出者，收回全屏并还原窗口', _tag);
    await exitNative();
    _restoreAppChrome();
    await restoreGeometry(reason: 'orphaned native fullscreen session');
  }

  /// 把应用自己的 chrome（标题栏 / 侧边导航）放回来。
  ///
  /// 进全屏时是 `AppService.hideSystemUI()` 藏起来的，孤儿会话里那一页早已
  /// 销毁，没人替它调逆操作。
  static void _restoreAppChrome() {
    try {
      if (Get.isRegistered<AppService>()) {
        Get.find<AppService>().showSystemUI();
      }
    } catch (e, s) {
      LogUtils.e('恢复应用 chrome 失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  // ------------------------------------------------------------- 窗口几何

  static Size? _sizeBeforeFullscreen;
  static Offset? _positionBeforeFullscreen;
  static bool _wasMaximizedBeforeFullscreen = false;
  static bool _hasGeometrySnapshot = false;
  static bool _restoringGeometry = false;

  /// 手上有没有「进全屏前的窗口几何」。
  static bool get hasGeometrySnapshot => _hasGeometrySnapshot;

  /// 拍一张进全屏前的窗口几何。
  static Future<void> captureGeometry() async {
    if (!GetPlatform.isDesktop) return;
    if (_restoringGeometry) return;

    // ⛔ 手上已经有快照了就别再拍一张。它是**真正的**进全屏前几何，而此刻窗口
    // 大概率已经满屏，重拍等于把它换成满屏尺寸。
    if (_hasGeometrySnapshot) {
      LogUtils.d('已持有进全屏前的窗口几何快照，跳过重复缓存', _tag);
      return;
    }

    // ⛔ 已经在原生全屏里了就更不能拍：拍到的就是满屏。宁可不拍（退出时
    // media_kit 自己会把窗口还原回 rect_before_fullscreen_），也好过拍错。
    if (await resolve()) {
      LogUtils.d('窗口已处于原生全屏，跳过缓存（避免把满屏几何当成还原目标）', _tag);
      return;
    }

    try {
      _wasMaximizedBeforeFullscreen = await windowManager.isMaximized();
      if (_wasMaximizedBeforeFullscreen) {
        _sizeBeforeFullscreen = null;
        _positionBeforeFullscreen = null;
      } else {
        _sizeBeforeFullscreen = await windowManager.getSize();
        _positionBeforeFullscreen = await windowManager.getPosition();
      }
      _hasGeometrySnapshot = true;
      LogUtils.d(
        '缓存桌面窗口几何: maximized=$_wasMaximizedBeforeFullscreen, '
            'size=${_sizeBeforeFullscreen ?? 'n/a'}, '
            'position=${_positionBeforeFullscreen ?? 'n/a'}',
        _tag,
      );
    } catch (e, s) {
      LogUtils.e('缓存桌面窗口几何失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  /// 把窗口还原成 [captureGeometry] 拍下的那一组。没有快照就什么都不做。
  static Future<void> restoreGeometry({required String reason}) async {
    if (!GetPlatform.isDesktop) return;
    if (!_hasGeometrySnapshot) return;
    if (_restoringGeometry) return;

    _restoringGeometry = true;
    try {
      // 等待系统全屏状态稳定退出，避免 setSize/setPosition 被系统覆盖。
      for (int i = 0; i < 10; i++) {
        final stillFullscreen = await windowManager.isFullScreen();
        if (!stillFullscreen) break;
        await Future.delayed(const Duration(milliseconds: 20));
      }

      if (_wasMaximizedBeforeFullscreen) {
        if (!await windowManager.isMaximized()) {
          await windowManager.maximize();
        }
      } else {
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        }
        final size = _sizeBeforeFullscreen;
        if (size != null) {
          await windowManager.setSize(size);
        }
        final position = _positionBeforeFullscreen;
        if (position != null) {
          await windowManager.setPosition(position);
        }
      }

      LogUtils.d(
        '恢复桌面窗口几何完成: reason=$reason, '
            'maximized=$_wasMaximizedBeforeFullscreen, '
            'size=${_sizeBeforeFullscreen ?? 'n/a'}, '
            'position=${_positionBeforeFullscreen ?? 'n/a'}',
        _tag,
      );
    } catch (e, s) {
      LogUtils.e('恢复桌面窗口几何失败: reason=$reason', tag: _tag, error: e, stackTrace: s);
    } finally {
      // ⛔ 失败也要清掉快照。留着它，下次进全屏会被上面那道「已有快照就跳过」
      // 的护栏挡住不再重拍，之后退出全屏就会还原到一个早已过期的几何。
      _hasGeometrySnapshot = false;
      _restoringGeometry = false;
    }
  }

  /// 单测用：把这个进程级会话恢复到出厂状态。
  @visibleForTesting
  static void resetForTest() {
    _active = false;
    _presenters.clear();
    _orphanCheckTimer?.cancel();
    _orphanCheckTimer = null;
    _orphanCheckScheduled = false;
    _sizeBeforeFullscreen = null;
    _positionBeforeFullscreen = null;
    _wasMaximizedBeforeFullscreen = false;
    _hasGeometrySnapshot = false;
    _restoringGeometry = false;
  }
}
