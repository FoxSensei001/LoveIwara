import 'dart:async';
import 'dart:io';
import 'dart:ui' show Canvas, PaintingStyle, Picture, PictureRecorder, Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/startup/app_startup.dart';
import 'package:i_iwara/app/startup/app_startup_shell.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'app/ui/widgets/restart_app_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/refresh_rate_helper.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  // 确保Flutter初始化
  runZonedGuarded(
    () async {
      // 确保Flutter初始化
      WidgetsFlutterBinding.ensureInitialized();

      // 日志初始化 - 仅初始化基本功能，不依赖数据库
      bool isProduction = !kDebugMode;
      await LogUtils.init(isProduction: isProduction);

      // 初始化日志持久化服务
      final logService = await LogService().init();
      Get.put(logService, permanent: true);

      // 注册生命周期监听，确保移动端正常退出时清理崩溃标记
      final lifecycleObserver = _AppLifecycleObserver(logService);
      WidgetsBinding.instance.addObserver(lifecycleObserver);

      // 记录应用启动信息
      LogUtils.i('应用启动', '启动初始化');

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

      runApp(
        RestartApp.scope(
          child: TranslationProvider(child: const AppStartupShell()),
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

/// 初始化桌面端设置
Future<void> _initializeDesktop() async {
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow();

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

  // 先设置窗口大小（不需要补偿，因为此时标题栏还未隐藏）
  if (storedWidth != null &&
      storedHeight != null &&
      storedWidth >= minWidth &&
      storedHeight >= minHeight) {
    await windowManager.setSize(Size(storedWidth, storedHeight));
    LogUtils.d('已从配置恢复窗口大小: ${storedWidth}x$storedHeight', '桌面初始化');
  } else {
    // 如果没有存储的尺寸或尺寸无效，则使用默认尺寸
    await windowManager.setSize(const Size(defaultWidth, defaultHeight));
    LogUtils.d('使用默认窗口大小: ${defaultWidth}x$defaultHeight', '桌面初始化');
  }

  // 先设置标题栏样式为隐藏
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: GetPlatform.isMacOS,
  );
  // if (GetPlatform.isLinux) {
  //   await windowManager.setBackgroundColor(Colors.transparent);
  // }

  // 在隐藏标题栏之后再恢复窗口位置，此时需要减去系统标题栏高度进行补偿
  if (storedX != null &&
      storedY != null &&
      storedX != -1.0 &&
      storedY != -1.0) {
    final adjustedY = storedY;
    await windowManager.setPosition(Offset(storedX, adjustedY));
    LogUtils.d(
      '已从配置恢复窗口位置: x=$storedX, y=$storedY (调整后: x=$storedX, y=$adjustedY)',
      '桌面初始化',
    );
  }

  await windowManager.show();
  await windowManager.focus();

  // --- 修改：添加窗口大小变化监听器 ---
  windowManager.addListener(DesktopWindowListener());

  // 添加应用关闭监听，确保日志写入完成
  windowManager.setPreventClose(true);
}

/// 桌面窗口事件监听器
class DesktopWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    await _closeServices();
    // await windowManager.destroy();
    exit(0);
  }

  @override
  void onWindowResized() {
    _saveWindowSize();
  }

  @override
  void onWindowMoved() {
    _saveWindowPosition();
  }

  @override
  void onWindowMaximize() {
    LogUtils.d('窗口最大化', '桌面监听器');
    _saveWindowSize();
    _saveWindowPosition();
  }

  @override
  void onWindowUnmaximize() {
    LogUtils.d('窗口取消最大化', '桌面监听器');
  }

  @override
  void onWindowEnterFullScreen() {
    LogUtils.d('窗口进入全屏', '桌面监听器');
  }

  @override
  void onWindowLeaveFullScreen() {
    LogUtils.d('窗口退出全屏', '桌面监听器');
  }

  Future<void> _saveWindowSize() async {
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
      await _logService.flush();
      await _logService.crash.markCleanExit();
    } finally {
      _marking = false;
    }
  }
}

/// 确保在应用退出前关闭日志文件
Future<void> _closeServices() async {
  try {
    // 标记正常退出并刷新日志
    if (Get.isRegistered<LogService>()) {
      final logService = Get.find<LogService>();
      await logService.flush();
      await logService.crash.markCleanExit();
    }

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
