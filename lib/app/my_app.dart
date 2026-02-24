import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/ui/widgets/global_drawer_content_widget.dart';
import 'package:i_iwara/app/ui/widgets/privacy_over_lay_widget.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'models/dto/escape_intent.dart';
import 'services/theme_service.dart';
import 'services/message_service.dart';
import 'services/deep_link_service.dart';
import 'services/auth_service.dart';
import 'services/pop_coordinator.dart';
import 'utils/exit_confirm_util.dart';
import 'ui/widgets/media_query_insets_fix.dart';

/// Android 预测式返回手势所需的页面过渡主题
///
/// 在 Android 13+ 上使用 PredictiveBackPageTransitionsBuilder 实现预测式返回动画，
/// 其他平台使用 FadeForwardsPageTransitionsBuilder（Material 3 默认）。
PageTransitionsTheme get _predictiveBackPageTransitionsTheme {
  // Android 平台且非 Web 环境使用预测式返回
  if (!kIsWeb && Platform.isAndroid) {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    );
  }
  // 其他平台使用默认
  return const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
    },
  );
}

/// 创建包含预测式返回支持的 ThemeData
ThemeData buildThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    pageTransitionsTheme: _predictiveBackPageTransitionsTheme,
  );
}

/// Global reactive theme state – written by ThemeService / DynamicColorBuilder,
/// read by the Obx-wrapped MaterialApp.router.
final Rx<ThemeData> appLightTheme = ThemeData().obs;
final Rx<ThemeData> appDarkTheme = ThemeData.dark().obs;
final Rx<ThemeMode> appThemeMode = ThemeMode.system.obs;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ColorScheme lightColorScheme;
  late ColorScheme darkColorScheme;
  ThemeService themeService = Get.find<ThemeService>();

  @override
  void initState() {
    super.initState();
    // Initialize back button interception (ChildBackButtonDispatcher on GoRouter)
    // so overlay/drawer close runs before GoRouter's route-pop handling.
    PopCoordinator.init();
    Get.find<VersionService>().doAutoCheckUpdate();
    Get.find<MessageService>().markReady();
    Get.find<DeepLinkService>().markReady();

    // 首次设置检查现在由 GoRouter redirect 处理，不需要手动跳转

    // 平台亮度监听
    WidgetsBinding.instance.addObserver(
      _ThemeModeObserver(
        // 当系统亮度发生变化时，更新主题
        onThemeModeChange: (brightness) {
          int currentThemeMode =
              CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
          final bool useDynamicColor = themeService.useDynamicColor;
          ColorScheme? colorScheme;

          if (useDynamicColor) {
            // 使用动态颜色
            colorScheme = currentThemeMode == 1
                ? lightColorScheme
                : currentThemeMode == 2
                ? darkColorScheme
                : brightness == Brightness.light
                ? lightColorScheme
                : darkColorScheme;
          } else {
            // 使用自定义颜色，通过 seed 生成后再 harmonized，确保色彩协调性
            final Color seedColor = themeService.getCurrentThemeColor();
            colorScheme = ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: currentThemeMode == 1
                  ? Brightness.light
                  : currentThemeMode == 2
                  ? Brightness.dark
                  : brightness,
            ).harmonized();
          }

          // 使用响应式变量代替 Get.changeTheme
          appLightTheme.value = buildThemeData(colorScheme: colorScheme);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        int currentThemeMode =
            CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
        final bool useDynamicColor = themeService.useDynamicColor;
        final Color seedColor = themeService.getCurrentThemeColor();

        if (lightDynamic != null && darkDynamic != null) {
          // 记录动态颜色到常量
          CommonConstants.dynamicLightColorScheme = lightDynamic.harmonized();
          CommonConstants.dynamicDarkColorScheme = darkDynamic.harmonized();
        }

        // 如果使用动态颜色且系统支持动态颜色
        if (useDynamicColor && (lightDynamic != null && darkDynamic != null)) {
          // 使用动态颜色的 primary 作为 seed，通过 fromSeed 再 harmonized 生成完整颜色方案
          final Color dynamicSeedLight = lightDynamic.primary;
          final Color dynamicSeedDark = darkDynamic.primary;

          lightColorScheme = ColorScheme.fromSeed(
            seedColor: dynamicSeedLight,
            brightness: Brightness.light,
          ).harmonized().copyWith(surface: Colors.white);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: dynamicSeedDark,
            brightness: Brightness.dark,
          ).harmonized().copyWith(surface: Colors.black);
          // 保存到常量中
          CommonConstants.dynamicLightColorScheme = lightColorScheme;
          CommonConstants.dynamicDarkColorScheme = darkColorScheme;
        } else {
          // 使用自定义颜色，通过 seed 生成后再 harmonized，确保色彩协调性
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
          ).harmonized();
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ).harmonized();
        }

        // 更新响应式主题变量
        appLightTheme.value = buildThemeData(colorScheme: lightColorScheme);
        appDarkTheme.value = buildThemeData(colorScheme: darkColorScheme);
        appThemeMode.value = currentThemeMode == 0
            ? ThemeMode.system
            : currentThemeMode == 1
            ? ThemeMode.light
            : ThemeMode.dark;

        return OKToast(
          child: Obx(
            () => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: t.common.appName,
              theme: appLightTheme.value,
              darkTheme: appDarkTheme.value,
              themeMode: appThemeMode.value,
              // 添加本地化支持
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('ja', ''), // Japanese
                Locale('zh', 'CN'), // Chinese (Simplified)
                Locale('zh', 'TW'), // Chinese (Traditional)
              ],
              locale: LocaleSettings.currentLocale.flutterLocale,
              routerConfig: appRouter,
              builder: (context, child) {
                if (null == child) {
                  return const SizedBox.shrink();
                }
                return MyAppLayout(child: child);
              },
            ),
          ),
        );
      },
    );
  }
}

class _ThemeModeObserver extends WidgetsBindingObserver {
  final Function(Brightness) onThemeModeChange;

  _ThemeModeObserver({required this.onThemeModeChange});

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    onThemeModeChange(brightness);
  }
}

class MyAppLayout extends StatefulWidget {
  final Widget child;

  const MyAppLayout({super.key, required this.child});

  @override
  State<MyAppLayout> createState() => _MyAppLayoutState();
}

class _MyAppLayoutState extends State<MyAppLayout> with WidgetsBindingObserver {
  bool _showPrivacyOverlay = false;
  late ConfigService _configService;
  DateTime? _lastPausedTime;

  // 文件拖放状态
  bool _isDragging = false;

  // 支持的视频文件扩展名
  static const List<String> _videoExtensions = [
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
    'ts',
  ];

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    bool activeBackgroundPrivacyMode =
        _configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE];
    switch (state) {
      case AppLifecycleState.resumed:
        if (_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = false;
          });
        }
        // 应用恢复到前台时，通知 AuthService 检查并刷新 token
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        if (activeBackgroundPrivacyMode && !_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = true;
          });
        }
        break;
      case AppLifecycleState.paused:
        // 记录进入后台的时间
        _lastPausedTime = DateTime.now();
        break;
      case AppLifecycleState.hidden:
        if (activeBackgroundPrivacyMode && !_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = true;
          });
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  /// 应用恢复到前台时的处理
  void _onAppResumed() {
    // 如果应用在后台超过 1 分钟，触发 token 刷新检查
    if (_lastPausedTime != null) {
      final duration = DateTime.now().difference(_lastPausedTime!);
      if (duration.inMinutes >= 1) {
        LogUtils.d('应用在后台 ${duration.inMinutes} 分钟，检查 token 状态');
        try {
          final authService = Get.find<AuthService>();
          authService.onAppResumed();
        } catch (e) {
          LogUtils.e('恢复前台时刷新 token 失败', error: e);
        }
      }
      _lastPausedTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 只在桌面平台启用文件拖放功能
    final bool isDesktop = GetPlatform.isDesktop;

    Widget content = Stack(
      children: [
        Scaffold(
          body: _shortCutsWrapper(
            context,
            _windowTitleBarFrame(context, widget.child),
          ),
        ),
        if (_showPrivacyOverlay) const PrivacyOverlay(),
        // 拖拽悬浮提示
        if (_isDragging && isDesktop) _buildDragOverlay(context),
      ],
    );

    // 桌面平台添加文件拖放支持
    if (isDesktop) {
      content = DropTarget(
        onDragEntered: (details) {
          setState(() => _isDragging = true);
        },
        onDragExited: (details) {
          setState(() => _isDragging = false);
        },
        onDragDone: (details) {
          setState(() => _isDragging = false);
          _handleDroppedFiles(details.files);
        },
        child: content,
      );
    }

    return ApplyFixedMediaQueryInsets(child: content);
  }

  /// 构建拖拽悬浮提示
  Widget _buildDragOverlay(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.video_file,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.mediaPlayer.dropVideoFileHere,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.mediaPlayer.supportedFormats,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 处理拖放的文件
  void _handleDroppedFiles(List<DropItem> files) {
    LogUtils.i('收到拖放文件: ${files.length} 个', 'FileDrop');

    for (final file in files) {
      final String path = file.path;
      LogUtils.i('拖放文件路径: $path', 'FileDrop');

      // 检查文件扩展名
      final ext = path.toLowerCase().split('.').lastOrNull ?? '';
      if (_videoExtensions.contains(ext)) {
        LogUtils.i('识别为视频文件，准备播放: $path', 'FileDrop');
        NaviService.navigateToLocalVideoPlayerPageFromPath(path);
        return; // 只处理第一个视频文件
      }
    }

    // 如果没有找到支持的视频文件，显示提示
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(t.mediaPlayer.noSupportedVideoFile),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _shortCutsWrapper(BuildContext context, Widget child) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const EscapeIntent(),
      },
      child: Actions(
        actions: {
          EscapeIntent: CallbackAction<EscapeIntent>(
            onInvoke: (intent) {
              if (PopCoordinator.shouldConfirmExitAtHomeRoot()) {
                ExitConfirmUtil.handleExit(
                  context,
                  () => SystemNavigator.pop(),
                );
              } else {
                PopCoordinator.handleBack(context);
              }
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }

  Widget _windowTitleBarFrame(BuildContext context, Widget child) {
    return Scaffold(
      key: AppService.globalDrawerKey,
      drawer: _buildDrawer(),
      drawerEnableOpenDragGesture: false,
      body: WindowTitleBarLayout(child),
    );
  }

  Widget _buildDrawer() {
    return Drawer(child: GlobalDrawerColumns());
  }
}
