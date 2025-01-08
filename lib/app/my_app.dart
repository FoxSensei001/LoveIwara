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
import 'package:i_iwara/app/ui/pages/settings/player_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/proxy_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/theme_settings_page.dart';
import 'package:i_iwara/app/ui/pages/sign_in/sing_in_page.dart';
import 'package:i_iwara/app/ui/widgets/global_drawer_content_widget.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:oktoast/oktoast.dart';

import '../utils/proxy/proxy_util.dart';
import 'models/dto/escape_intent.dart';
import 'services/theme_service.dart';

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    Get.find<VersionService>().doAutoCheckUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return OKToast(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: t.common.appName,
            theme: Get.find<ThemeService>().getTheme(
              context,
              dynamicLight: lightDynamic,
              dynamicDark: darkDynamic,
            ),
            getPages: [
              GetPage(
                name: Routes.HOME,
                page: () => HomeNavigationLayout(),
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
                  name: Routes.THEME_SETTINGS_PAGE,
                  page: () => const ThemeSettingsPage(),
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

class PrivacyOverlay extends StatelessWidget {
  const PrivacyOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white, // 白色背景
        child: Center(
          child: Text(
            t.common.privacyHint,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
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
        _configService[ConfigService.ACTIVE_BACKGROUND_PRIVACY_MODE];
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
              AppService.tryPop();
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
        body: WindowTitleBarLayout(child));
  }

  Widget _buildDrawer() {
    return Drawer(child: GlobalDrawerColumns());
  }
}
