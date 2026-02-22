import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/ui/pages/home/home_navigation_layout.dart';
import 'package:i_iwara/app/ui/pages/login/login_page_wrapper.dart';
import 'package:i_iwara/app/ui/pages/settings/about_page.dart';
import 'package:i_iwara/app/ui/pages/settings/app_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/player_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/proxy_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/theme_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/download_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/forum_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/sign_in/sing_in_page.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/first_time_setup_page.dart';
import 'package:i_iwara/app/ui/widgets/global_drawer_content_widget.dart';
import 'package:i_iwara/app/ui/widgets/privacy_over_lay_widget.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../utils/proxy/proxy_util.dart';
import 'models/dto/escape_intent.dart';
import 'services/theme_service.dart';
import 'services/message_service.dart';
import 'services/deep_link_service.dart';
import 'services/auth_service.dart';
import 'utils/exit_confirm_util.dart';
import 'package:i_iwara/app/ui/pages/profile/personal_profile_page.dart';

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
    Get.find<VersionService>().doAutoCheckUpdate();
    Get.find<MessageService>().markReady();
    Get.find<DeepLinkService>().markReady();

    // 检查首次设置状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeSetup();
    });

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

          Get.changeTheme(
            buildThemeData(colorScheme: colorScheme),
          );
        },
      ),
    );
  }

  /// 检查首次设置状态
  void _checkFirstTimeSetup() {
    try {
      final configService = Get.find<ConfigService>();
      final bool isFirstTimeSetupCompleted =
          configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED];
      LogUtils.i('检查首次设置状态: $isFirstTimeSetupCompleted', '首次设置检测');

      if (!isFirstTimeSetupCompleted) {
        LogUtils.i('首次设置未完成，准备跳转到首次设置页面', '首次设置检测');
        // 使用延迟确保应用完全初始化后再跳转
        Future.delayed(const Duration(milliseconds: 500), () {
          LogUtils.i('开始跳转到首次设置页面', '首次设置检测');
          Get.offAllNamed(Routes.FIRST_TIME_SETUP);
        });
      } else {
        LogUtils.i('首次设置已完成，继续正常流程', '首次设置检测');
      }
    } catch (e) {
      LogUtils.e('检查首次设置状态时发生错误', tag: '首次设置检测', error: e);
    }
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

          lightColorScheme =
              ColorScheme.fromSeed(
                seedColor: dynamicSeedLight,
                brightness: Brightness.light,
              ).harmonized().copyWith(
                surface: Colors.white, // 根据设计需求调整亮色表面色，使用 white 作为亮色背景
              );
          darkColorScheme =
              ColorScheme.fromSeed(
                seedColor: dynamicSeedDark,
                brightness: Brightness.dark,
              ).harmonized().copyWith(
                surface: Colors.black, // 根据设计需求调整暗色表面色，默认使用黑色
              );
          // 保存到常量中
          CommonConstants.dynamicLightColorScheme = lightColorScheme;
          CommonConstants.dynamicDarkColorScheme = darkColorScheme;

          // 只在非初始化时更新主题
          if (Get.context != null) {
            bool systemIsLight =
                WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.light;
            if (currentThemeMode == 1) {
              Get.changeTheme(buildThemeData(colorScheme: lightColorScheme));
            } else if (currentThemeMode == 2) {
              Get.changeTheme(buildThemeData(colorScheme: darkColorScheme));
            } else {
              Get.changeTheme(
                buildThemeData(
                  colorScheme: systemIsLight
                      ? lightColorScheme
                      : darkColorScheme,
                ),
              );
            }
          }
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

        return OKToast(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: t.common.appName,
            theme: buildThemeData(colorScheme: lightColorScheme),
            darkTheme: buildThemeData(colorScheme: darkColorScheme),
            themeMode: currentThemeMode == 0
                ? ThemeMode.system
                : currentThemeMode == 1
                ? ThemeMode.light
                : ThemeMode.dark,
            // 使用平台原生过渡动画，在 Android 13+ 上支持预测式返回手势
            defaultTransition: Transition.native,
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
            getPages: [
              GetPage(
                name: Routes.HOME,
                page: () => const HomeNavigationLayout(),
              ),
              GetPage(
                name: Routes.FIRST_TIME_SETUP,
                page: () => const FirstTimeSetupPage(),
                transition: Transition.fadeIn,
              ),
              GetPage(
                name: Routes.PLAYER_SETTINGS_PAGE,
                page: () => const PlayerSettingsPage(),
                transition: Transition.native,
              ),
              if (ProxyUtil.isSupportedPlatform())
                GetPage(
                  name: Routes.PROXY_SETTINGS_PAGE,
                  page: () => const ProxySettingsPage(),
                  transition: Transition.native,
                ),
              GetPage(
                name: Routes.AI_TRANSLATION_SETTINGS_PAGE,
                page: () => const AITranslationSettingsPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.THEME_SETTINGS_PAGE,
                page: () => const ThemeSettingsPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.APP_SETTINGS_PAGE,
                page: () => const AppSettingsPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.ABOUT_PAGE,
                page: () => const AboutPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.DOWNLOAD_SETTINGS_PAGE,
                page: () => const DownloadSettingsPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.FORUM_SETTINGS_PAGE,
                page: () => const ForumSettingsPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.LOGIN,
                page: () => const LoginPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.SIGN_IN,
                page: () => const SignInPage(),
                transition: Transition.native,
              ),
              GetPage(
                name: Routes.PERSONAL_PROFILE,
                page: () => const PersonalProfilePage(),
                transition: Transition.native,
              ),
            ],
            initialRoute: Routes.HOME,
            builder: (context, child) {
              if (null == child) {
                return const SizedBox.shrink();
              }
              return MyAppLayout(child: child);
            },
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

    return content;
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
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
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
              ExitConfirmUtil.handleExit(context, () => AppService.tryPop());
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
