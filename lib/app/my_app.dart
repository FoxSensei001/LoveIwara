// material.dart 不导出这一个（它住在 cupertino 那边），而 pageTransitionsTheme
// 的 iOS / macOS 两档要照抄框架默认值，只能显式借过来。
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/version_service.dart';
import 'package:i_iwara/app/services/player_keybinding/keybinding_service.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_action.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_scope.dart';
import 'package:i_iwara/app/services/player_keybinding/text_input_focus.dart';
import 'package:i_iwara/app/services/player_keybinding/shortcut_target_registry.dart';
import 'package:i_iwara/app/services/glass_material_intro.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/global_drawer_content_widget.dart';
import 'package:i_iwara/app/ui/widgets/app_lock_screen.dart';
import 'package:i_iwara/app/ui/widgets/privacy_over_lay_widget.dart';
import 'package:i_iwara/app/ui/widgets/window_layout_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/utils/exit_confirm_util.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'services/theme_service.dart';
import 'services/message_service.dart';
import 'services/deep_link_service.dart';
import 'services/auth_service.dart';
import 'services/iwara_network_service.dart';
import 'services/pop_coordinator.dart';
import 'services/user_service.dart';
import 'ui/widgets/media_query_insets_fix.dart';

/// 创建默认 `ThemeData`。
///
/// Android 不再显式指定 predictive back 页面转场，恢复 Flutter 默认行为。
ThemeData buildThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    // 页面转场：**只把桌面端 Zoom 那两档的快照关掉**，其余平台照抄 Flutter 的
    // 默认表（缺项会兜底成带快照的 Zoom，所以五个平台都得写全）。
    //
    // ⛔ 为什么关快照：`ZoomPageTransitionsBuilder` 默认把进出场的页面
    // `toImageSync()` 成一张位图再动画。那次栅格化是在**父级 paint 期间**建场景
    // （`_RenderSnapshotWidget._paintAndDetachToImage` → `OffsetLayer.buildScene`），
    // 而液态玻璃的渲染对象都混了 `TransformTrackingRenderObjectMixin`：它的层在
    // `addToScene` 里发现累计变换变了就回调 `onTransformChanged()` →
    // `markNeedsPaint()`，于是在 paint 里标脏，撞上框架的
    // `owner == null || !owner!.debugDoingPaint` 断言（2026-08-30 报障，栈顶是
    // `_RenderLightweightGlass.onTransformChanged`）。
    //
    // 顺带治的还有一条老毛病：快照是一张离屏位图，里头的 `BackdropFilter` 采不到
    // 身后的像素——转场那几百毫秒里玻璃本来就是错的。
    //
    // Android 留给 predictive back（那一档由系统接管，且移动端没报过这条），
    // iOS / macOS 是 Cupertino 转场，都不走快照这条路。
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        ),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        ),
      },
    ),
    // ⛔ 触屏上不再由长按/点按唤出 tooltip（鼠标悬停不受影响，见
    // `TooltipTriggerMode` 的文档：「This property does not affect mouse
    // devices」）。
    //
    // 原因是它会**打断长按**：`Tooltip` 在触屏档默认注册一只
    // `LongPressGestureRecognizer`，500ms 一到就宣布胜利、弹出黑条并震一下，
    // 同时把同一个竞技场里的 tap 判负。而玻璃件的手感恰恰建立在「按住不放」
    // 上——按住蠕动、按住拖着玩、按住等胶囊形变，全都在 500ms 之后才开始，
    // 于是每次都被这条黑条截胡。
    //
    // 放在主题上而不是各个玻璃组件里，是因为这不是玻璃独有的毛病，而且
    // `tooltip:` 这个参数散落在 `GlassIconButton` / `GlassSurface` /
    // 裸 `Tooltip` / `IconButton` 一堆入口上，逐个去关必然漏。主题是所有
    // `Tooltip` 的共同上游（`Tooltip` 读 `TooltipTheme` 兜底），一处钉死。
    // 由 `test/glass_style_guard_test.dart` 盯着不许回退。
    tooltipTheme: const TooltipThemeData(
      triggerMode: TooltipTriggerMode.manual,
    ),
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
  late final _ThemeModeObserver _themeModeObserver;

  void _ensureNetworkAndUserServiceReady({int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        if (Get.isRegistered<IwaraNetworkService>()) {
          Get.find<IwaraNetworkService>().setContext(ctx);
        }
        if (Get.isRegistered<AuthService>()) {
          Get.find<AuthService>().markReady();
        }
        if (Get.isRegistered<UserService>()) {
          Get.find<UserService>().markReady();
        }
        LogUtils.d(
          'Network/Auth/User services marked ready (attempt=$attempt)',
          'MyApp',
        );
        return;
      }

      if (ctx != null && !ctx.mounted) {
        LogUtils.w(
          'Found root navigator context but not mounted, retrying (attempt=$attempt)',
          'MyApp',
        );
      } else if (attempt == 0) {
        LogUtils.d('Waiting for root navigator context...', 'MyApp');
      } else {
        LogUtils.d(
          'Retrying to get root navigator context (attempt=$attempt)',
          'MyApp',
        );
      }

      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) {
          return;
        }
        _ensureNetworkAndUserServiceReady(attempt: attempt + 1);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize back button interception (ChildBackButtonDispatcher on GoRouter)
    // so overlay/drawer close runs before GoRouter's route-pop handling.
    PopCoordinator.init();
    Get.find<VersionService>().doAutoCheckUpdate();
    Get.find<DeepLinkService>().markReady();
    // 玻璃质感的一次性提醒：自己会等到「没有链接在路上、没有别的弹窗、人确实
    // 站在首页」才弹，等不到就留到下次启动（见 GlassMaterialIntro 的类文档）。
    GlassMaterialIntro.scheduleAfterStartup();
    _ensureNetworkAndUserServiceReady();

    // 首次设置检查现在由 GoRouter redirect 处理，不需要手动跳转

    // 平台亮度监听
    _themeModeObserver = _ThemeModeObserver(
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
    );
    WidgetsBinding.instance.addObserver(_themeModeObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_themeModeObserver);
    super.dispose();
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

        return Obx(() {
          final siteModeVersion = Get.find<AppService>().siteModeVersion;
          return MaterialApp.router(
            key: ValueKey('app-site-mode-$siteModeVersion'),
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
              // toast 宿主必须挂在 MaterialApp **内部**：它往下找到的第一个
              // Navigator（也就是根导航器）的 Overlay 才是提示的落点，放到
              // MaterialApp 外面时那棵子树上没有 Theme / Localizations，
              // `Theme.of` 只能拿到 Flutter 的 fallback 主题（恒为浅色蓝），
              // 深色模式下整块提示会是一片亮白。
              return AppToastHost(child: MyAppLayout(child: child));
            },
          );
        });
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
  late AppLockService _appLockService;
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
    _appLockService = Get.find<AppLockService>();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final messageService = Get.find<MessageService>();
      messageService.markReady();
      messageService.showPendingSiteModeToastIfAny();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    bool activeBackgroundPrivacyMode =
        _configService[ConfigKey.ACTIVE_BACKGROUND_PRIVACY_MODE] ||
        _appLockService.enabled;
    switch (state) {
      case AppLifecycleState.resumed:
        _appLockService.onResumed();
        if (_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = false;
          });
        }
        // 应用恢复到前台时，通知 AuthService 检查并刷新 token
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _appLockService.onBackgrounded(state);
        if (activeBackgroundPrivacyMode &&
            !_appLockService.isAuthenticating.value &&
            !_showPrivacyOverlay) {
          setState(() {
            _showPrivacyOverlay = true;
          });
        }
        break;
      case AppLifecycleState.paused:
        _appLockService.onBackgrounded(state);
        // 记录进入后台的时间
        _lastPausedTime = DateTime.now();
        break;
      case AppLifecycleState.hidden:
        _appLockService.onBackgrounded(state);
        if (activeBackgroundPrivacyMode &&
            !_appLockService.isAuthenticating.value &&
            !_showPrivacyOverlay) {
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
        Obx(
          () => _appLockService.isLocked.value
              ? const Positioned.fill(child: AppLockScreen())
              : const SizedBox.shrink(),
        ),
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
    showAppToast(t.mediaPlayer.noSupportedVideoFile);
  }

  Widget _shortCutsWrapper(BuildContext context, Widget child) {
    return Focus(
      // Non-focusable, only participates in event bubbling (default eventResult ignored)
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        // 正在打字时，所有快捷键一律让位给输入框——这道闸门必须在最前面，
        // 且要盖住叶子作用域：用户很可能把「.」之类的可打印字符绑成了播放器
        // 快捷键，在评论框里敲它必须是输入字符，而不是调音量。
        final typing = isTextInputFocused();

        // 叶子作用域（视频/图库）：不依赖焦点，问注册表里栈顶那个合格目标。
        // 转发原始事件而非解析后的动作——进度键的长按倍速要靠 KeyUpEvent 收尾。
        if (!typing) {
          final leaf = ShortcutTargetRegistry.instance.dispatch(event);
          if (leaf == KeyEventResult.handled) return leaf;
        }

        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final service = Get.find<KeybindingService>();
        final action = service.resolve(event, ShortcutScope.global);
        if (action == null) return KeyEventResult.ignored;

        // 正在打字时，全局快捷键一律让位给输入框。
        //
        // 按键会从聚焦节点冒泡到这里，输入框并不消费 Esc/方向键之类，所以不加这道
        // 闸门的话：Esc（全局返回的默认键）会在用户写评论写到一半时把整页退掉、
        // 草稿一起丢；将来若有人把全局动作绑到字母键，打字就会满屏乱触发。
        // 这道闸门放在动作分派之前，对**所有**全局动作生效，而不只是返回。
        if (typing) {
          if (action == ShortcutAction.globalBack) {
            // 与桌面端惯例一致：第一下 Esc 先收起输入焦点，
            // 失焦之后再按才是真的返回。
            FocusManager.instance.primaryFocus?.unfocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        }

        if (action == ShortcutAction.globalBack) {
          if (PopCoordinator.shouldConfirmExitAtHomeRoot()) {
            // 首页根路由：二次确认退出（5s 内再次返回才真正退出）
            ExitConfirmUtil.handleExit(context, () => SystemNavigator.pop());
          } else {
            PopCoordinator.handleBack(context);
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
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
    return Drawer(
      child: SizedBox.expand(
        child: RepaintBoundary(child: GlobalDrawerColumns()),
      ),
    );
  }
}
