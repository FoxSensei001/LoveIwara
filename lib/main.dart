import 'dart:async';
import 'package:i_iwara/utils/frame_perf_probe.dart';
import 'package:i_iwara/utils/glass_perf_knobs.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';
import 'dart:io';
import 'dart:ui' show Canvas, PaintingStyle, Picture, PictureRecorder, Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart' show FrameTiming, TimingsCallback;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/startup/app_startup.dart';
import 'package:i_iwara/app/startup/app_startup_shell.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'app/ui/widgets/restart_app_widget.dart';
import 'package:i_iwara/utils/desktop_native_fullscreen.dart';
import 'package:i_iwara/utils/live_players.dart';
import 'package:i_iwara/utils/desktop_window_geometry.dart';
import 'package:i_iwara/utils/desktop_window_geometry_mirror.dart';
import 'package:i_iwara/utils/device_form_factor_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/process_uptime.dart';
import 'package:i_iwara/utils/refresh_rate_helper.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:i_iwara/utils/startup_trace.dart';
import 'package:window_manager/window_manager.dart';

/// [args] 是 Dart 入口参数，不是进程命令行：Windows 的 runner 往里塞了一条
/// `--startup-entry-ms`，把 Dart 看不见的加载器耗时递进来（见
/// `windows/runner/main.cpp`）。深链和「用视频文件打开」走的是真命令行，
/// 由原生侧自己解析，不经过这里。
void main(List<String> args) {
  // 确保Flutter初始化
  runZonedGuarded(
    () async {
      // 第一件事：问一下进程已经活了多久。这一段（加载 DLL、起 Dart VM、注册
      // 插件）在 Dart 侧看不见，却是 Windows 白屏最容易藏身的地方。越早问越准。
      StartupTrace.preMain = currentProcessUptime();
      StartupTrace.adoptNativeTimings(args);
      DesktopWindowGeometryMirror.adoptRunnerGeometry(args);

      // 确保Flutter初始化
      WidgetsFlutterBinding.ensureInitialized();
      StartupTrace.mark('binding');

      // 日志初始化 - 仅初始化基本功能，不依赖数据库
      bool isProduction = !kDebugMode;
      await LogUtils.init(isProduction: isProduction);
      StartupTrace.mark('log.utils');

      // 初始化日志持久化服务。
      // 显式传 policy：LogService 自己的默认值按 kReleaseMode 判定，而 LogUtils
      // 按 !kDebugMode——profile 模式下两者会打架（控制台不打 debug，落盘却照收）。
      // 统一用同一个 isProduction。
      final logService = await LogService().init(
        policy: LogPolicy.defaults(isProduction: isProduction),
      );
      Get.put(logService, permanent: true);
      // 挂上引用，让 LogUtils 的热路径不必每条日志都查一次 GetX 容器。
      LogUtils.attachLogService(logService);
      // init() 里会读上一会话的崩溃标记、写本会话的，还要 resolve 日志目录——
      // 都是同步磁盘 IO，单独记一段。
      StartupTrace.mark('log.service');

      // 注册生命周期监听，确保移动端正常退出时清理崩溃标记
      final lifecycleObserver = _AppLifecycleObserver(logService);
      WidgetsBinding.instance.addObserver(lifecycleObserver);

      // 记录应用启动信息。带上构建标识：日志文件跨多次升级累积，每个会话
      // 都要能看出当时跑的是哪个包。
      LogUtils.i(
        '应用启动 ${CommonConstants.FULL_VERSION} (${CommonConstants.buildTag})',
        '启动初始化',
      );

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent.withAlpha(
            0x01,
          ) /*Android=28,不能用全透明 */,
        ),
      );

      // 设置Flutter错误处理
      FlutterError.onError = (FlutterErrorDetails details) {
        LogUtils.captureUnhandledException(
          source: 'FlutterError.onError',
          message:
              'Flutter框架错误${details.context != null ? ' (${details.context})' : ''}',
          error: details.exception,
          stackTrace: details.stack ?? StackTrace.current,
        );

        FlutterError.presentError(details);
      };

      // 设置平台错误处理
      PlatformDispatcher.instance.onError = (error, stack) {
        LogUtils.captureUnhandledException(
          source: 'PlatformDispatcher.onError',
          message: '平台未捕获异常',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      await appStartupCoordinator.initializeCore(
        logService: logService,
        isProduction: isProduction,
      );
      await DeviceFormFactorUtils.applyMobileOrientationPolicy();
      StartupTrace.mark('orientation');

      // 液态玻璃的 shader 异步加载：不预热的话，冷启动首屏第一块玻璃会先渲染
      // 成磨砂、加载完再切成折射，肉眼能看见这一下材质跳变。不 await——加载失败
      // 只是退回磨砂，不该拖住启动。
      //
      // ⭐ Material 档整只跳过：2026-09-04 起浮动底栏也跟着全局档走（M3 的
      // `NavigationBar`，见 `GlassFloatingTabBar` 类文档），那一档下全 App 再没有
      // 一块玻璃要采样背景，热了纯属白花。档位在 `initializeCore` 里就已经从
      // 配置表灌好（`applyGlassMaterialFromConfig`），这里读到的是最终值；
      // 用户中途切回液态时由 `ThemeService.setLiquidGlassEnabled` 补热。
      if (glassMaterialMode.value == GlassMaterialMode.liquid) {
        unawaited(warmUpLiquidGlassShaders());
      }

      FramePerfProbe.start();
      // 这一刻之前，屏幕上什么都没有：Windows 的窗口要等第一帧光栅完才 Show
      // （见 windows/runner/flutter_window.cpp 的 SetNextFrameCallback）。
      // 「白屏多久」的分母就是从进程启动到下面那条 first.raster。
      StartupTrace.mark('pre-runApp');
      // 玻璃档位到这里才是最终值（initializeCore 里从配置表灌好的），抬头要在
      // 它之后生成。
      StartupTrace.header = _startupTraceHeader();
      _watchFirstFrame();

      runApp(
        wrapLiquidGlassApplication(
          // 固定档基准隔离管线成本；另传 GLASS_ADAPTIVE=true 可测自动降档。
          adaptiveQuality:
              !GlassPerfKnobs.benchBuild ||
              const bool.fromEnvironment('GLASS_ADAPTIVE'),
          child: RestartApp.scope(
            // 玻璃材质开关挂在最外层：Navigator / 根 Overlay 都在它下面，
            // 页面、弹窗、菜单、toast 才会在切档时一起重建。
            child: GlassMaterialScope(
              // 全 App 的「正在滚动」信号（见 ScrollActivityMonitor）：只旁听不拦截。
              child: NotificationListener<ScrollNotification>(
                onNotification: ScrollActivityMonitor.instance.handle,
                child: TranslationProvider(child: const AppStartupShell()),
              ),
            ),
          ),
        ),
      );

      if (GetPlatform.isDesktop) {
        await _initializeDesktopSafely();
      }

      // 在应用启动时配置图片缓存
      configureImageCache();

      // 启用高刷新率（仅限Android）
      if (GetPlatform.isAndroid) {
        RefreshRateHelper.enableHighRefreshRate()
            .then((success) {
              if (success) {
                LogUtils.i('高刷新率已启用', '启动初始化');
              } else {
                LogUtils.w('启用高刷新率失败，使用默认刷新率', '启动初始化');
              }
            })
            .catchError((error) {
              LogUtils.e('启用高刷新率时发生错误', tag: '启动初始化', error: error);
            });
      }
    },
    (error, stackTrace) {
      // 在这里处理未捕获的异常
      LogUtils.captureUnhandledException(
        source: 'runZonedGuarded',
        message: '未捕获的Zone异常',
        error: error,
        stackTrace: stackTrace,
      );

      // TODO: 可以在这里添加额外处理，例如显示错误页面或重启应用
    },
  );
}

/// 本次冷启动的身份抬头，写进计时文件的每一块。
///
/// `glass=` 这一项是**排查的主角**：液态玻璃出厂默认关闭，Material 档下全 App
/// 一块折射 shader 都不画。拿到用户的文件时，第一眼要能确认他当时跑的是哪一档，
/// 否则「是不是玻璃拖慢了启动」永远只能靠猜。
String _startupTraceHeader() {
  final mode = glassMaterialMode.value == GlassMaterialMode.liquid
      ? 'liquid'
      : 'material';
  return '${DateTime.now().toIso8601String()} · '
      '${CommonConstants.FULL_VERSION} (${CommonConstants.buildTag}) · '
      '${Platform.operatingSystem} · glass=$mode';
}

/// 第一帧 build / layout 跑完的时刻。
///
/// # ⛔ 别用 `addTimingsCallback` 量「首帧光栅」
///
/// 最早这里挂的是帧耗时回调，想单独量出光栅那一段（Windows 上 Impeller(ANGLE)
/// 要靠驱动在运行时编 GLSL，这一段曾经单独值十几秒，见 `chromeGlassQuality` 的
/// 实测记录）。实跑的读数是 **20 秒**，看着像实锤，其实是假的：
/// `onReportTimings` 是**攒批**送的，界面闲下来之后引擎可能很久才把批次吐出来，
/// 拿到的 `timings.first` 也已经不是首帧了（读数里 build / raster 双双为 0 就是
/// 破绽）。同一次启动，外部量到窗口 2.7 秒就可见。
///
/// 桌面端真正该量的是 `windowManager.show()` ——窗口从那一刻起才在屏幕上，
/// 「白屏多久」的终点就是它，见 `_initializeDesktop`。
void _watchFirstFrame() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    StartupTrace.mark('first.build');
  });

  // 前几帧各自什么时候**构建**、什么时候**光栅**，分开记。
  //
  // 为什么要这两条：窗口已经在屏幕上却一片空白，有两种完全不同的解释——
  // 「Dart 在出帧，但画出来的内容本来就是白的」和「根本没有帧送到屏幕上」。
  // 只看窗口可见时间区分不了，截屏也问不出来（ANGLE 的窗口 PrintWindow 抓到
  // 的是空白）。所以让 App 自己报。
  //
  // 只记前几帧：之后每帧都记就成了性能问题本身。
  var built = 0;
  WidgetsBinding.instance.addPersistentFrameCallback((_) {
    built++;
    if (built <= 6) {
      StartupTrace.mark('frame.build#$built');
    }
  });

  var batches = 0;
  late final TimingsCallback onTimings;
  onTimings = (List<FrameTiming> timings) {
    batches++;
    if (batches > 6) {
      WidgetsBinding.instance.removeTimingsCallback(onTimings);
      return;
    }
    final first = timings.first;
    // ⚠️ 这是**批次送达**的时刻，不是光栅完成的时刻：onReportTimings 是攒批送的，
    // 界面闲下来后引擎可能很久才吐。所以读它要看 n=（这一批几帧）和帧内耗时，
    // 别把送达时间当成首帧时间——之前就在这上面栽过一次，读出过 20 秒的假数。
    StartupTrace.mark(
      'frame.raster#$batches'
      '(n=${timings.length},b${first.buildDuration.inMilliseconds}'
      ',r${first.rasterDuration.inMilliseconds})',
    );
  };
  WidgetsBinding.instance.addTimingsCallback(onTimings);

  // 白屏期间的快照：就算后面卡死，这一份也已经在盘上了。
  for (final seconds in [6, 20]) {
    Timer(Duration(seconds: seconds), () {
      StartupTrace.mark('watch.${seconds}s(frames=$built,batches=$batches)');
      if (Get.isRegistered<LogService>()) {
        unawaited(
          StartupTrace.flush(Get.find<LogService>().paths.startupTraceFile),
        );
      }
    });
  }
}

/// 初始化桌面端设置
Future<void> _initializeDesktopSafely() async {
  try {
    await _initializeDesktop();
  } catch (error, stackTrace) {
    LogUtils.e(
      '桌面初始化失败，回退到默认窗口显示',
      tag: '桌面初始化',
      error: error,
      stackTrace: stackTrace,
    );

    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (fallbackError, fallbackStackTrace) {
      LogUtils.e(
        '桌面初始化回退失败',
        tag: '桌面初始化',
        error: fallbackError,
        stackTrace: fallbackStackTrace,
      );
    }
  }
}

/// runner 建窗口时用的几何和本次要摆的几何，差到要不要补一刀的程度。
///
/// # 容差为什么是 2 逻辑像素
///
/// 这组数走了一圈有损的来回：Dart 存的是逻辑 double（1638.4），runner 取整后
/// 按显示器 DPI 放大成物理像素交给 `CreateWindow`，下次再读回来又除一次。
/// 在非整数倍的显示缩放下，实测一圈会掉不到一个像素，镜像值就在相邻两个值
/// 之间来回跳。
///
/// 卡太紧的后果不是「不准」，而是**每次启动都判定不匹配、白付两百多毫秒的表面
/// 重建**——那正是这套机制要省掉的东西。而放宽到 2px 的代价是窗口可能比上次
/// 窄两个逻辑像素，没人看得出来。
const double _geometryTolerance = 2.0;

bool _matchesRunnerSize(Size target) {
  final applied = DesktopWindowGeometryMirror.appliedByRunner;
  if (applied == null) return false;
  return (applied.width - target.width).abs() <= _geometryTolerance &&
      (applied.height - target.height).abs() <= _geometryTolerance;
}

bool _matchesRunnerPosition(Offset target) {
  final applied = DesktopWindowGeometryMirror.appliedByRunner;
  if (applied == null) return false;
  return (applied.left - target.dx).abs() <= _geometryTolerance &&
      (applied.top - target.dy).abs() <= _geometryTolerance;
}

/// 给时间线用的一行说明：runner 给的是什么、本次要的是什么。
String _sizeDebug(Size target) {
  final applied = DesktopWindowGeometryMirror.appliedByRunner;
  String fmt(double v) => v.toStringAsFixed(1);
  if (applied == null) {
    return 'runner=none target=${fmt(target.width)}x${fmt(target.height)}';
  }
  return 'runner=${fmt(applied.width)}x${fmt(applied.height)} '
      'target=${fmt(target.width)}x${fmt(target.height)}';
}

/// 问一次窗口当下的几何并写进镜像。
Future<void> _writeGeometryMirrorFromCurrentWindow() async {
  try {
    final size = await windowManager.getSize();
    final position = await windowManager.getPosition();
    await DesktopWindowGeometryMirror.write(
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
    );
  } catch (_) {
    // 镜像只是启动快路，写不成下次多付一次 setSize 而已。
  }
}

/// 关掉 `screen_brightness` 的「随应用前后台自动复位」。
///
/// # 这个 App 在桌面端根本不调亮度
///
/// 亮度手势只给移动端（`gesture_area_widget.dart` 里 `!isWindows && !isMacOS
/// && !isLinux`），`setDefaultBrightness` 也只在 Android / iOS 跑。桌面端一次
/// 都不会调用 `setApplicationScreenBrightness`。
///
/// # 但插件光是注册进来就会动你的显示器
///
/// `screen_brightness_windows` 的构造函数（插件注册时，也就是 App 一启动）会
/// 读一次显示器亮度存起来，并挂上一个顶层窗口过程钩子；`is_auto_reset_` 默认
/// 为 true，于是每次收到 `WM_ACTIVATEAPP`（失去激活，也就是**用户点了别的
/// 窗口**）就走 `OnApplicationPause()` → `SetMonitorBrightness()`，通过
/// **DDC/CI 往显示器写一次物理背光**。
///
/// 用户反馈的「开着显示器 HDR，进软件后随便打开别的窗口，屏幕就暗一大截」对得上
/// 这条路径：HDR 模式下面板亮度由系统的 SDR 内容亮度管，外部 DDC/CI 写入会把
/// 面板踢出当前亮度状态。非 HDR 的机器上症状轻，但那次写入一样是多余的——
/// 用户在 App 开着的时候自己调了显示器亮度，一切窗口就被弹回旧值。
///
/// 包虽然把 `setAutoReset` 的文档写成「iOS only」，但 Windows 的 C++ 侧确实
/// 实现了（`HandleSetAutoResetMethodCall`）。
///
/// ⛔ Windows 现在已经整个换成纯 Dart 空实现（`packages/screen_brightness_windows`，
/// 经 pubspec 的 `dependency_overrides` 接入）：关窗、启动窗口期这两条写亮度的路
/// 这里关不掉，只能不注册那个 C++ 插件。这次调用在 Windows 上已是空操作，留着
/// 是给其它桌面平台的实现兜底。
Future<void> _disableScreenBrightnessAutoReset() async {
  try {
    await ScreenBrightness().setAutoReset(false);
    LogUtils.d('已关闭屏幕亮度的自动复位', '桌面初始化');
  } catch (e) {
    // Linux 没有这个平台实现，调用会抛 MissingPluginException；其余失败也不该
    // 影响启动——最坏情况是维持现状。
    LogUtils.d('关闭屏幕亮度自动复位失败（该平台可能没有实现）: $e', '桌面初始化');
  }
}

/// 初始化桌面端设置
Future<void> _initializeDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();
  StartupTrace.mark('desktop.ready');

  await _disableScreenBrightnessAutoReset();

  final configService = Get.find<ConfigService>();
  double? storedWidth = configService.settings[ConfigKey.WINDOW_WIDTH]?.value;
  double? storedHeight = configService.settings[ConfigKey.WINDOW_HEIGHT]?.value;
  double? storedX = configService.settings[ConfigKey.WINDOW_X]?.value;
  double? storedY = configService.settings[ConfigKey.WINDOW_Y]?.value;

  // 设置一个合理的默认最小尺寸，以防存储的值无效
  const defaultWidth = 800.0;
  const defaultHeight = 600.0;
  const minWidth = 200.0;
  const minHeight = 200.0;

  final hasSize =
      storedWidth != null &&
      storedHeight != null &&
      storedWidth >= minWidth &&
      storedHeight >= minHeight;
  final hasPosition =
      storedX != null && storedY != null && storedX != -1.0 && storedY != -1.0;

  // 存下的几何先对着当前的屏幕校一遍：上次在全屏 / 最大化时关掉、外接屏拔了、
  // 分辨率改了，原样摆回去窗口会一半在屏幕外、大小也不对。
  Rect? restored;
  if (hasSize && hasPosition) {
    restored = await fitStoredWindowRect(
      Rect.fromLTWH(storedX, storedY, storedWidth, storedHeight),
    );
  }
  // 以下每一步都挡在 show 之前，也就是全都顶在白屏上，所以逐个打点。
  StartupTrace.mark('desktop.fitRect');

  // 这次要摆成的尺寸。三种来源：校正过的、配置里原样的、出厂默认。
  final Size targetSize =
      restored?.size ??
      (hasSize
          ? Size(storedWidth, storedHeight)
          : const Size(defaultWidth, defaultHeight));

  // ⚠️ 这一只调用实测 220ms 上下，而同一只紧接着再来一次只要 38ms，只读的
  // getSize 只要 0.5ms——贵的不是平台通道，是**改窗口尺寸会让引擎把渲染表面
  // 拆了重建**，而这会儿 Flutter 视图已经建好了。
  //
  // 所以常见情况下根本不该走到这里：runner 在建窗口时就按镜像文件把尺寸给对了
  // （见 `windows/runner/window_geometry.cpp`），那时还没有表面，这笔钱是零。
  // 它回执的矩形和上面算出来的目标一致，就跳过——只有屏幕变了、分辨率改了、
  // 镜像还没写过（首次启动）这些情况才真的需要补一刀。
  final bool sizeAlreadyApplied = _matchesRunnerSize(targetSize);
  if (sizeAlreadyApplied) {
    LogUtils.d('窗口大小已由 runner 建窗口时应用: $targetSize', '桌面初始化');
  } else {
    await windowManager.setSize(targetSize);
    LogUtils.d('设置窗口大小: $targetSize', '桌面初始化');
  }
  // 跳没跳、没跳是因为差多少，都写进时间线：这一步值两百多毫秒，光看耗时
  // 看不出是「本来就不用做」还是「判定没匹配上白做了一次」。
  StartupTrace.mark(
    sizeAlreadyApplied
        ? 'desktop.setSize(skip)'
        : 'desktop.setSize(${_sizeDebug(targetSize)})',
  );

  // 先设置标题栏样式为隐藏
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: GetPlatform.isMacOS,
  );
  StartupTrace.mark('desktop.titleBar');
  // if (GetPlatform.isLinux) {
  //   await windowManager.setBackgroundColor(Colors.transparent);
  // }

  // 在隐藏标题栏之后再恢复窗口位置
  if (restored != null) {
    // 同上：runner 已经把窗口建在这个位置了就不必再挪。移动比缩放便宜得多
    // （实测 1.7ms，不触发表面重建），但白送的还是要。
    if (_matchesRunnerPosition(restored.topLeft)) {
      LogUtils.d('窗口位置已由 runner 建窗口时应用: ${restored.topLeft}', '桌面初始化');
    } else {
      await windowManager.setPosition(restored.topLeft);
    }
    // 校正过就把新值写回去：监听器要到 show 之后才挂上，用户一次都不拖的话，
    // 配置里会一直躺着那组坏值，每次启动都得重新校正一遍。
    if (restored !=
        Rect.fromLTWH(storedX!, storedY!, storedWidth!, storedHeight!)) {
      for (final (key, value) in [
        (ConfigKey.WINDOW_X, restored.left),
        (ConfigKey.WINDOW_Y, restored.top),
        (ConfigKey.WINDOW_WIDTH, restored.width),
        (ConfigKey.WINDOW_HEIGHT, restored.height),
      ]) {
        configService.updateSetting(key, value);
        unawaited(configService.saveSettingToStorage(key, value));
      }
    }
    LogUtils.d(
      '已从配置恢复窗口位置: 存储 x=$storedX, y=$storedY → ${restored.topLeft}',
      '桌面初始化',
    );
  }

  StartupTrace.mark('desktop.setPosition');

  // 第一次启动（或镜像被删了）时把当下的几何写进镜像，下次启动 runner 就能直接
  // 用。之后由 DesktopWindowListener 在窗口停稳时维护。
  unawaited(_writeGeometryMirrorFromCurrentWindow());

  await windowManager.show();
  await windowManager.focus();
  // ⭐ 白屏的终点就在这一行：在此之前屏幕上没有这个 App 的任何东西。
  StartupTrace.mark('desktop.show');
  if (Get.isRegistered<LogService>()) {
    final paths = Get.find<LogService>().paths;
    LogUtils.i('冷启动分段（至窗口可见）\n${StartupTrace.summary()}', '启动初始化');
    unawaited(StartupTrace.flush(paths.startupTraceFile));
  }

  // --- 修改：添加窗口大小变化监听器 ---
  windowManager.addListener(DesktopWindowListener());

  // 添加应用关闭监听，确保日志写入完成
  windowManager.setPreventClose(true);
}

/// 桌面窗口事件监听器
class DesktopWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    // 1. 第一时间同步标记正常退出：删除崩溃标记后，崩溃检测对本次关闭窗口
    //    即失效（checkAndRecover 只在标记存在时才读 fatal/hang 快照）。这样
    //    后续清理无论超时还是被强杀，下次启动都不会误报崩溃。
    LogUtils.markCleanExitSync();
    // 2. 隐藏窗口，让用户立刻感知到「已关闭」，避免清理期间窗口卡住数秒。
    //    先把 hide 消息发出去再停声：停声是同步 FFI，某个 mpv 核心卡住时会把
    //    UI 线程一起卡住，而 hide 由平台线程处理，不受影响。
    final Future<void> hiding = windowManager.hide();
    // 2.5 同步让所有播放器停声。此后直到进程真正结束，mpv 的音频线程一直
    //     活着（清理 + 原生析构可达数秒）；不先停声，用户看到的就是「窗口
    //     没了，声音还在卡着放」。
    LivePlayers.silenceAllSync();
    try {
      await hiding;
    } catch (_) {}
    // 3. 后台限时清理（flush / 停 watchdog / 关库）：正常很快，但日志 flush
    //    偶发偏慢。给 1.5s 上限，超时直接退出，不让用户干等——此时标记已删，
    //    超时退出也不会误报崩溃。
    await _closeServices().timeout(
      const Duration(milliseconds: 1500),
      onTimeout: () {},
    );
    // 4. 通过 window_manager.destroy() 让原生窗口有序销毁并退出，而不是用
    //    dart:io 的 exit(0) 强杀进程。Windows 上 destroy() 原生侧只是
    //    PostQuitMessage(0)，不经 WM_CLOSE，不会被 setPreventClose 拦截，
    //    也不会二次触发本回调。
    //
    //    为什么不能用 exit(0)：exit(0) 会立即触发 C 运行时退出与 DLL 卸载，
    //    而此时 media_kit(libmpv) 的播放线程、Flutter 引擎的 GPU/ANGLE 渲染
    //    线程可能仍存活（关窗时 GetX 控制器并不会被销毁，播放器 mpv 实例仍在
    //    运行）。这些原生线程在 DLL 被卸载后访问失效内存，会让 Windows 弹出
    //    内核级的 "Unknown Hard Error" 对话框（见 issue #107）。
    //    destroy() → PostQuitMessage(0) → 原生消息循环退出 → CoUninitialize →
    //    window 析构、FlutterWindow::OnDestroy 释放引擎与插件 → 进程正常结束，
    //    是一条让原生侧有序收尾的干净退出路径。这段原生收尾没有上限（插件
    //    析构可能等好几秒甚至卡住），windows/runner/main.cpp 给它兜了 3 秒，
    //    超时用 TerminateProcess 结束（不走 DLL 卸载，不会重现 #107）。
    try {
      await windowManager.destroy();
    } catch (e) {
      // 兜底：极端情况下 destroy 失败，仍退出避免窗口卡死。此时崩溃标记已删，
      // 不会误报为崩溃。
      LogUtils.w('windowManager.destroy() 失败，回退到 exit(0): $e', '桌面监听器');
      exit(0);
    }
  }

  @override
  void onWindowResized() => _scheduleGeometrySave();

  @override
  void onWindowMoved() => _scheduleGeometrySave();

  /// 拖动 / 缩放 / 进出全屏的动画会连着打几十次事件；等停下来再记一次，
  /// 记的时候窗口已经落定，[_skipGeometryPersist] 问到的也是最终状态。
  Timer? _geometryTimer;

  void _scheduleGeometrySave() {
    _geometryTimer?.cancel();
    _geometryTimer = Timer(const Duration(milliseconds: 400), () async {
      await _saveWindowSize();
      await _saveWindowPosition();
      // 原生 runner 下次启动要读的那份镜像。和配置库里那两组值同源，只是换了
      // 个 Flutter 引擎起来之前也读得到的格式——见
      // `DesktopWindowGeometryMirror`。
      if (await _skipGeometryPersist('几何镜像')) return;
      await _writeGeometryMirrorFromCurrentWindow();
    });
  }

  @override
  void onWindowMaximize() {
    // 最大化的尺寸不记：那是屏幕的尺寸，不是用户摆的窗口。取消最大化后还原
    // 出来的那一组会再触发 resize / move，自然记上。
    LogUtils.d('窗口最大化', '桌面监听器');
  }

  @override
  void onWindowUnmaximize() {
    LogUtils.d('窗口取消最大化', '桌面监听器');
  }

  @override
  void onWindowEnterFullScreen() {
    _systemFullScreen = true;
    LogUtils.d('窗口进入全屏', '桌面监听器');
  }

  @override
  void onWindowLeaveFullScreen() {
    _systemFullScreen = false;
    LogUtils.d('窗口退出全屏', '桌面监听器');
  }

  /// 系统级全屏（macOS 绿灯 / 全屏快捷键）。与 [DesktopNativeFullscreen]
  /// （播放器自己进的全屏）是两回事，两者都不能把几何写进配置。
  bool _systemFullScreen = false;

  /// 全屏期间这两条不落盘。
  ///
  /// ⛔ 播放器进原生全屏是一次真实的 SetWindowPos，resize / move 照常打过来，
  /// 照单全收就会把「铺满显示器」写进配置。用户此时关掉应用（或应用崩了），
  /// 下次启动窗口就以满屏尺寸开在 (0,0)。真正该记的是进全屏**之前**那一组，
  /// 它在退出全屏、窗口还原之后会重新触发一次 resize/move 自然补回来。
  ///
  /// macOS 的系统全屏同理，而且它的 resize 会**先于** enterFullScreen 回调
  /// 打过来，只看标志挡不住，所以落盘前再问一次窗口当下的状态。
  Future<bool> _skipGeometryPersist(String what) async {
    var skip = DesktopNativeFullscreen.isActive || _systemFullScreen;
    if (!skip) {
      try {
        skip =
            await windowManager.isFullScreen() ||
            await windowManager.isMaximized();
      } catch (_) {}
    }
    if (skip) LogUtils.d('全屏 / 最大化中，跳过保存窗口$what', '桌面监听器');
    return skip;
  }

  Future<void> _saveWindowSize() async {
    if (await _skipGeometryPersist('大小')) return;
    try {
      final size = await windowManager.getSize();
      final configService = Get.find<ConfigService>();

      // 更新配置服务中的值（内存中）
      configService.updateSetting(ConfigKey.WINDOW_WIDTH, size.width);
      configService.updateSetting(ConfigKey.WINDOW_HEIGHT, size.height);

      // 异步保存到持久化存储
      unawaited(
        configService
            .saveSettingToStorage(ConfigKey.WINDOW_WIDTH, size.width)
            .then(
              (_) => configService.saveSettingToStorage(
                ConfigKey.WINDOW_HEIGHT,
                size.height,
              ),
            )
            .then((_) {
              LogUtils.d('窗口大小已保存: ${size.width}x${size.height}', '桌面监听器');
            })
            .catchError((error, stackTrace) {
              LogUtils.e(
                '保存窗口大小失败',
                tag: '桌面监听器',
                error: error,
                stackTrace: stackTrace,
              );
            }),
      );
    } catch (e, s) {
      LogUtils.e('获取或保存窗口大小时出错', tag: '桌面监听器', error: e, stackTrace: s);
    }
  }

  Future<void> _saveWindowPosition() async {
    if (await _skipGeometryPersist('位置')) return;
    try {
      final position = await windowManager.getPosition();
      final configService = Get.find<ConfigService>();

      final adjustedY = position.dy;

      configService.updateSetting(ConfigKey.WINDOW_X, position.dx);
      configService.updateSetting(ConfigKey.WINDOW_Y, adjustedY);

      unawaited(
        configService
            .saveSettingToStorage(ConfigKey.WINDOW_X, position.dx)
            .then(
              (_) => configService.saveSettingToStorage(
                ConfigKey.WINDOW_Y,
                adjustedY,
              ),
            )
            .then((_) {
              LogUtils.d(
                '窗口位置已保存: x=${position.dx}, y=${position.dy} (存储为: x=${position.dx}, y=$adjustedY)',
                '桌面监听器',
              );
            })
            .catchError((error, stackTrace) {
              LogUtils.e(
                '保存窗口位置失败',
                tag: '桌面监听器',
                error: error,
                stackTrace: stackTrace,
              );
            }),
      );
    } catch (e, s) {
      LogUtils.e('获取或保存窗口位置时出错', tag: '桌面监听器', error: e, stackTrace: s);
    }
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver(this._logService);
  final LogService _logService;
  bool _marking = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      unawaited(_markCleanExit());
    }
  }

  Future<void> _markCleanExit() async {
    if (_marking) return;
    _marking = true;
    try {
      // 先同步删除崩溃标记（一次小文件删除，能在进程被杀前完成），再 best-effort
      // flush。即使 flush 没跑完进程就被系统回收，也不会误报崩溃；而真正的运行时
      // 崩溃发生在 detached 之前，标记仍在，照常能被检测到。
      _logService.crash.markCleanExitSync();
      await _logService.flush();
    } finally {
      _marking = false;
    }
  }
}

/// 确保在应用退出前关闭日志文件
Future<void> _closeServices() async {
  try {
    // LogUtils.close() 内部已完成 flush + stop watchdog + markCleanExit，
    // 这里不再重复 flush，避免关闭时多一次同步 IO。

    await LogUtils.close();

    // 关闭数据库连接
    if (Get.isRegistered<DatabaseService>()) {
      Get.find<DatabaseService>().close();
    }
  } catch (e) {
    // 记录关闭服务时可能出现的错误
    LogUtils.e('关闭服务失败', error: e);
  }
}

// 在应用启动时配置图片缓存
void configureImageCache() {
  // 适当调整图片缓存大小，平衡内存使用和性能
  PaintingBinding.instance.imageCache.maximumSize = 100; // 减少到100张图片
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      50 * 1024 * 1024; // 限制内存占用为50MB

  // 预热渲染管道
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _prewarmRendering();
  });
}

// 预热渲染管道，减少首次渲染时的卡顿
void _prewarmRendering() {
  // 创建一个离屏的图像进行渲染预热
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  // 预热一些常用的绘制操作
  final paint = Paint()
    ..color = Colors.transparent
    ..style = PaintingStyle.fill;

  canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), paint);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 100, 100),
      const Radius.circular(8.0),
    ),
    paint,
  );

  // 确保预热的内容被光栅化
  final Picture picture = recorder.endRecording();
  picture.toImage(1, 1).then((image) {
    image.dispose(); // 释放图像资源
  });
}
