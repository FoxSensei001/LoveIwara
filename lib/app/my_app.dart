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

import '../utils/proxy/proxy_util.dart';
import 'models/dto/escape_intent.dart';
import 'services/theme_service.dart';
import 'services/message_service.dart';
import 'services/deep_link_service.dart';
import 'utils/exit_confirm_util.dart';

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
    WidgetsBinding.instance.addObserver(_ThemeModeObserver(
      // 当系统亮度发生变化时，更新主题
      onThemeModeChange: (brightness) {
        int currentThemeMode = CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
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

        Get.changeTheme(ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
        ));
      },
    ));
  }

  /// 检查首次设置状态
  void _checkFirstTimeSetup() {
    try {
      final configService = Get.find<ConfigService>();
      final bool isFirstTimeSetupCompleted = configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED];
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
        int currentThemeMode = CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
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
          ).harmonized().copyWith(
            surface: Colors.white, // 根据设计需求调整亮色表面色，使用 white 作为亮色背景
          );
          darkColorScheme = ColorScheme.fromSeed(
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
                WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
            if (currentThemeMode == 1) {
              Get.changeTheme(ThemeData.from(colorScheme: lightColorScheme));
            } else if (currentThemeMode == 2) {
              Get.changeTheme(ThemeData.from(colorScheme: darkColorScheme));
            } else {
              Get.changeTheme(ThemeData.from(
                  colorScheme: systemIsLight ? lightColorScheme : darkColorScheme));
            }
          }
        } else {
          // 使用自定义颜色，通过 seed 生成后再 harmonized，确保色彩协调性
          lightColorScheme = ColorScheme.fromSeed(seedColor: seedColor).harmonized();
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ).harmonized();
        }

        return OKToast(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: t.common.appName,
            theme: ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
            ),
            themeMode: currentThemeMode == 0 
                ? ThemeMode.system 
                : currentThemeMode == 1 
                    ? ThemeMode.light 
                    : ThemeMode.dark,
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
                  transition: Transition.rightToLeft),
              if (ProxyUtil.isSupportedPlatform())
                GetPage(
                    name: Routes.PROXY_SETTINGS_PAGE,
                    page: () => const ProxySettingsPage(),
                    transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.AI_TRANSLATION_SETTINGS_PAGE,
                  page: () => const AITranslationSettingsPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.THEME_SETTINGS_PAGE,
                  page: () => const ThemeSettingsPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.APP_SETTINGS_PAGE,
                  page: () => const AppSettingsPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.ABOUT_PAGE,
                  page: () => const AboutPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.DOWNLOAD_SETTINGS_PAGE,
                  page: () => const DownloadSettingsPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                  name: Routes.FORUM_SETTINGS_PAGE,
                  page: () => const ForumSettingsPage(),
                  transition: Transition.rightToLeft),
              GetPage(
                name: Routes.LOGIN,
                page: () => const LoginPage(),
                transition: Transition.cupertino,
              ),
              GetPage(
                name: Routes.SIGN_IN,
                page: () => const SignInPage(),
                transition: Transition.cupertino,
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
        break;
      case AppLifecycleState.inactive:
        if (activeBackgroundPrivacyMode && !_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = true;
          });
        }
        break;
      case AppLifecycleState.paused:
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _shortCutsWrapper(
              context, _windowTitleBarFrame(context, widget.child)),
        ),
        if (_showPrivacyOverlay) const PrivacyOverlay(),
      ],
    );
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
        body: WindowTitleBarLayout(child));
  }

  Widget _buildDrawer() {
    return Drawer(child: GlobalDrawerColumns());
  }
}
