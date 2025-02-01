import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/ui/pages/home/home_navigation_layout.dart';
import 'package:i_iwara/app/ui/pages/login/login_page.dart';
import 'package:i_iwara/app/ui/pages/settings/about_page.dart';
import 'package:i_iwara/app/ui/pages/settings/app_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/player_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/proxy_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/theme_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/sign_in/sing_in_page.dart';
import 'package:i_iwara/app/ui/pages/splash/splash_page.dart';
import 'package:i_iwara/app/ui/widgets/global_drawer_content_widget.dart';
import 'package:i_iwara/app/ui/widgets/privacy_over_lay_widget.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:oktoast/oktoast.dart';

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
  ColorScheme? lightColorScheme;
  ColorScheme? darkColorScheme;
  @override
  void initState() {
    super.initState();
    Get.find<VersionService>().doAutoCheckUpdate();
    Get.find<MessageService>().markReady();
    Get.find<DeepLinkService>().markReady();

    // 平台亮度监听
    WidgetsBinding.instance.addObserver(_ThemeModeObserver(
      // 当系统亮度发生变化时，更新主题
      onThemeModeChange: (brightness) {
        int currentThemeMode = CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
        final themeService = Get.find<ThemeService>();
        final bool useDynamicColor = themeService.useDynamicColor;
        ColorScheme? colorScheme;

        if (useDynamicColor && (lightColorScheme != null && darkColorScheme != null)) {
          // 使用动态颜色
          colorScheme = currentThemeMode == 1 
              ? lightColorScheme 
              : currentThemeMode == 2 
                  ? darkColorScheme 
                  : brightness == Brightness.light 
                      ? lightColorScheme 
                      : darkColorScheme;
        } else {
          // 使用自定义颜色
          final Color seedColor = themeService.getCurrentThemeColor();
          colorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: currentThemeMode == 1 
                ? Brightness.light 
                : currentThemeMode == 2 
                    ? Brightness.dark 
                    : brightness,
          );
        }

        Get.changeTheme(ThemeData(
          colorScheme: colorScheme,
          useMaterial3: true,
        ));
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        int currentThemeMode = CommonConstants.themeMode; // 0: system(动态主题), 1: light, 2: dark
        final themeService = Get.find<ThemeService>();
        final bool useDynamicColor = themeService.useDynamicColor;
        final Color seedColor = themeService.getCurrentThemeColor();

        if (lightDynamic != null && darkDynamic != null) {
          // 记录动态颜色到常量
          CommonConstants.dynamicLightColorScheme = lightDynamic.harmonized();
          CommonConstants.dynamicDarkColorScheme = darkDynamic.harmonized();
        }

        // 如果使用动态颜色且系统支持动态颜色
        if (useDynamicColor && (lightDynamic != null && darkDynamic != null)) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
          // 保存到常量中
          CommonConstants.dynamicLightColorScheme = lightColorScheme;
          CommonConstants.dynamicDarkColorScheme = darkColorScheme;
          // 只在非初始化时更新主题
          if (Get.context != null) {
            bool systemIsLight = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
            if (currentThemeMode == 1) {
              Get.changeTheme(ThemeData.from(colorScheme: lightDynamic.harmonized()));
            } else if (currentThemeMode == 2) {
              Get.changeTheme(ThemeData.from(colorScheme: darkDynamic.harmonized()));
            } else {
              Get.changeTheme(ThemeData.from(colorScheme: systemIsLight ? lightDynamic.harmonized() : darkDynamic.harmonized()));
            }
          }
        } else {
          // 使用自定义颜色
          lightColorScheme = ColorScheme.fromSeed(seedColor: seedColor);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
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
            getPages: [
              GetPage(
                name: Routes.SPLASH,
                page: () => const SplashPage(),
              ),
              GetPage(
                name: Routes.HOME,
                page: () => const HomeNavigationLayout(),
              ),
              GetPage(
                  name: Routes.SETTINGS_PAGE,
                  page: () => const SettingsPage(),
                  transition: Transition.rightToLeft),
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
            initialRoute: Routes.SPLASH,
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
      default:
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
