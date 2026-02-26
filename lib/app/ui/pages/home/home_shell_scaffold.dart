import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/services/android_back_gesture_bridge.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/pop_coordinator.dart';
import 'package:i_iwara/app/utils/exit_confirm_util.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/easy_throttle.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/routes/app_router.dart';

/// Home shell scaffold that wraps both tab pages and detail pages.
/// Receives [Widget child] from go_router's ShellRoute.
/// NavigationRail always visible on wide screens.
/// BottomNav only visible on tab-root routes for narrow screens.
class HomeShellScaffold extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const HomeShellScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  State<HomeShellScaffold> createState() => _HomeShellScaffoldState();
}

class _HomeShellScaffoldState extends State<HomeShellScaffold>
    with WidgetsBindingObserver {
  static const String _frameworkBackThrottleTag =
      'home_shell_framework_handles_back_refresh';
  static const String _backDispatcherPriorityThrottleTag =
      'home_shell_back_dispatcher_take_priority';
  final AppService appService = Get.find<AppService>();
  final UserService userService = Get.find<UserService>();
  final ConfigService configService = Get.find<ConfigService>();

  /// Fixed branch key → branch index mapping (compile-time fixed).
  static const Map<String, int> _branchIndexMap = {
    'video': 0,
    'gallery': 1,
    'subscription': 2,
    'forum': 3,
  };

  static const List<String> _defaultOrder = [
    'video',
    'gallery',
    'subscription',
    'forum',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userService.startNotificationTimer();
    unawaited(
      AndroidBackGestureBridge.loadBackAnimationEnabledOnce().then((_) {
        if (!mounted) return;
        _ensureFrameworkHandlesBack(reason: 'loadBackAnimationEnabledOnce');
      }),
    );
    _ensureFrameworkHandlesBack(reason: 'initState');
  }

  @override
  void dispose() {
    userService.stopNotificationTimer();
    EasyThrottle.cancel('refresh_page');
    EasyThrottle.cancel('switch_page');
    EasyThrottle.cancel(_frameworkBackThrottleTag);
    EasyThrottle.cancel(_backDispatcherPriorityThrottleTag);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didHaveMemoryPressure() {
    // StatefulShellRoute.indexedStack preserves branch state automatically.
    // Memory release is handled by Flutter's framework when branches are rebuilt.
    LogUtils.d("内存存在压力", "HomeShellScaffold");
  }

  /// Get the display-ordered list of navigation keys.
  List<String> get _displayOrder {
    final orderRaw = configService[ConfigKey.NAVIGATION_ORDER];
    final raw = orderRaw is List ? orderRaw : const <dynamic>[];
    final result = <String>[];

    for (final item in raw) {
      if (item is! String) continue;
      if (!_branchIndexMap.containsKey(item)) continue;
      if (result.contains(item)) continue;
      result.add(item);
    }

    for (final item in _defaultOrder) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }

    return result;
  }

  String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  int? _branchIndexFromPath(String path) {
    switch (_normalizePath(path)) {
      case '/':
        return 0;
      case '/gallery':
        return 1;
      case '/subscriptions':
        return 2;
      case '/forum':
        return 3;
      default:
        return null;
    }
  }

  bool get _isTabRootRoute => _branchIndexFromPath(widget.currentPath) != null;

  /// Convert a display index (from navigation bar tap) to a go_router branch index.
  int _displayIndexToBranchIndex(int displayIndex) {
    final order = _displayOrder;
    if (displayIndex < 0 || displayIndex >= order.length) return 0;
    final key = order[displayIndex];
    return _branchIndexMap[key] ?? 0;
  }

  /// Convert the current go_router branch index to a display index.
  int get _currentDisplayIndex {
    final currentBranch =
        _branchIndexFromPath(widget.currentPath) ??
        appService.navigationShell?.currentIndex ??
        appService.currentIndex;
    final order = _displayOrder;
    for (int i = 0; i < order.length; i++) {
      if ((_branchIndexMap[order[i]] ?? -1) == currentBranch) return i;
    }
    return 0;
  }

  /// Handle navigation bar tap.
  void _handleNavigationTap(int displayIndex) {
    final branchIndex = _displayIndexToBranchIndex(displayIndex);
    final shell = appService.navigationShell;
    final currentBranch = shell?.currentIndex ?? appService.currentIndex;

    if (branchIndex == currentBranch) {
      // Same tab → refresh
      if (EasyThrottle.throttle('refresh_page', const Duration(seconds: 1), () {
        VibrateUtils.vibrate();
        _refreshCurrentBranch();
      })) {
        return;
      }
      return;
    }

    // Switch tab
    if (EasyThrottle.throttle(
      'switch_page',
      const Duration(milliseconds: 300),
      () {
        VibrateUtils.vibrate();
        shell?.goBranch(
          branchIndex,
          initialLocation: branchIndex == currentBranch,
        );
        // Sync appService.currentIndex for Obx consumers
        appService.currentIndex = branchIndex;
      },
    )) {
      return;
    }
  }

  /// Refresh the current branch page via HomeWidgetInterface.
  void _refreshCurrentBranch() {
    // This is handled by the individual pages via their GlobalKey-based refreshCurrent()
    // We can trigger it by going to the same branch with initialLocation: true
    final shell = appService.navigationShell;
    shell?.goBranch(shell.currentIndex, initialLocation: true);
  }

  /// Whether we are at the true home root (tab root, no overlay, no detail page).
  bool get _isAtHomeRoot {
    // If current route isn't a tab root, we're definitely not at home root.
    // This avoids transient false positives during route transitions.
    if (!_isTabRootRoute) return false;
    if (OverlayTracker.instance.hasOverlay) return false;
    final shellNav = shellNavigatorKey.currentState;
    if (shellNav != null && shellNav.canPop()) return false;
    return !GoRouter.of(context).canPop();
  }

  /// Keep Android back dispatch routed to Flutter.
  void _ensureFrameworkHandlesBack({
    required String reason,
    bool? isAtHomeRoot,
  }) {
    if (!GetPlatform.isAndroid) return;
    EasyThrottle.throttle(
      _frameworkBackThrottleTag,
      const Duration(milliseconds: 250),
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final rootState = isAtHomeRoot ?? _isAtHomeRoot;
          final backAnimationEnabled =
              AndroidBackGestureBridge.backAnimationEnabled ?? false;

          // Strategy (方案 1):
          // - 非 Home root：始终由 Flutter 接管返回，避免 OEM 走系统 finish。
          // - Home root：
          //   - 若系统预测返回动画可用（enable_back_animation=1）→ 交回系统处理（获得系统手势返回动画）
          //   - 否则 → 仍由 Flutter 接管（保留 ExitConfirmUtil 二次确认拦截）
          final shouldHandleBack = !rootState || !backAnimationEnabled;

          AndroidBackGestureBridge.syncFrameworkHandlesBack(
            shouldHandleBack: shouldHandleBack,
            reason:
                'HomeShellScaffold.$reason path=${widget.currentPath} isAtHomeRoot=$rootState backAnimationEnabled=$backAnimationEnabled',
          );
          LogUtils.d(
            'setFrameworkHandlesBack($shouldHandleBack): reason=$reason, '
                'path=${widget.currentPath}, isAtHomeRoot=$rootState, '
                'backAnimationEnabled=$backAnimationEnabled',
            'HomeShellScaffold',
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    // PopScope for back handling:
    // - Intercept all back events inside Shell.
    // - Delegate to PopCoordinator for unified order:
    //   overlay/drawer -> internal page -> route pop.
    // - At home root: show double-confirm exit.
    Widget body = Obx(() {
      // Read showBottomNavi to trigger Obx rebuild when navigation visibility changes
      // ignore: unused_local_variable
      final _ = appService.showBottomNavi;

      final bool isAtRoot = _isAtHomeRoot;
      _ensureFrameworkHandlesBack(reason: 'build', isAtHomeRoot: isAtRoot);
      EasyThrottle.throttle(
        _backDispatcherPriorityThrottleTag,
        const Duration(milliseconds: 250),
        () => PopCoordinator.ensureDispatcherPriority(
          'HomeShellScaffold.build path=${widget.currentPath}',
        ),
      );

      return PopScope(
        // Only intercept at home root for exit confirmation.
        // Non-root routes should use normal navigator pop to avoid double-pop
        // when a top-level route is being closed by the root navigator.
        canPop: !isAtRoot,
        onPopInvokedWithResult: (didPop, result) {
          LogUtils.d(
            'PopScope: didPop=$didPop, isAtRoot=$isAtRoot, canPop=${!isAtRoot}, '
                'routeCurrent=${ModalRoute.of(context)?.isCurrent}, '
                'rootCanPop=${rootNavigatorKey.currentState?.canPop() ?? false}, '
                'shellCanPop=${shellNavigatorKey.currentState?.canPop() ?? false}',
            'HomeShellScaffold',
          );

          // If a higher-level route has already handled this back action,
          // do not run fallback pop logic again.
          if (didPop) return;

          // Shell route is not the top-most active route (e.g. a root-level
          // fullscreen page is currently covering it), ignore this callback.
          final shellRoute = ModalRoute.of(context);
          if (shellRoute != null && !shellRoute.isCurrent) return;

          // At home root → double-confirm exit
          if (isAtRoot) {
            // On Android (especially with predictive back), let the system exit
            // immediately. Other platforms keep the confirm behavior.
            if (GetPlatform.isAndroid) {
              final backAnimationEnabled =
                  AndroidBackGestureBridge.backAnimationEnabled ?? false;
              if (backAnimationEnabled) {
                // Ideally, home root should be handled by system (frameworkHandlesBack=false)
                // so this callback should rarely run. Keep a direct-exit fallback here.
                SystemNavigator.pop();
              } else {
                ExitConfirmUtil.handleExit(
                  context,
                  () => SystemNavigator.pop(),
                );
              }
              return;
            }
            ExitConfirmUtil.handleExit(context, () => SystemNavigator.pop());
            return;
          }

          PopCoordinator.handleBack(context);
        },
        child: widget.child,
      );
    });

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Row(
            children: [
              // Side navigation rail
              Obx(() {
                if (!appService.showRailNavi) return const SizedBox.shrink();
                if (!isWide) return const SizedBox.shrink();

                return _buildNavigationRail(context, t);
              }),
              // Main content
              Expanded(
                child: Scaffold(
                  body: body,
                  bottomNavigationBar: Obx(() {
                    if (!appService.showBottomNavi) {
                      return const SizedBox.shrink();
                    }
                    if (isWide) return const SizedBox.shrink();
                    if (!_isTabRootRoute) return const SizedBox.shrink();

                    return BottomNavigationBar(
                      currentIndex: _currentDisplayIndex,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      onTap: _handleNavigationTap,
                      items: _buildBottomNavigationBarItems(),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, dynamic t) {
    return LayoutBuilder(
      builder: (context, railConstraints) {
        final navigationItems = _buildNavigationRailDestinations();
        final estimatedMinHeight =
            (navigationItems.length * 72.0) + (2 * 48.0) + 32.0;
        final availableHeight = railConstraints.maxHeight;
        final hasEnoughSpace = availableHeight >= estimatedMinHeight;

        Widget buildTrailingButtons() {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: slang.t.common.settings,
                  onPressed: () {
                    AppService.switchGlobalDrawer();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  tooltip: slang.t.common.back,
                  onPressed: () {
                    AppService.tryPop();
                  },
                ),
              ],
            ),
          );
        }

        if (hasEnoughSpace) {
          return Obx(
            () => NavigationRail(
              labelType: NavigationRailLabelType.all,
              selectedIndex: _currentDisplayIndex,
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [const Spacer(), buildTrailingButtons()],
                ),
              ),
              onDestinationSelected: _handleNavigationTap,
              destinations: navigationItems,
            ),
          );
        } else {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: railConstraints.maxHeight),
              child: IntrinsicHeight(
                child: Obx(
                  () => NavigationRail(
                    labelType: NavigationRailLabelType.all,
                    selectedIndex: _currentDisplayIndex,
                    trailing: buildTrailingButtons(),
                    onDestinationSelected: _handleNavigationTap,
                    destinations: navigationItems,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  List<NavigationRailDestination> _buildNavigationRailDestinations() {
    final order = _displayOrder;
    return order.map((key) {
      final item = AppService.navigationItems[key]!;
      return NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.title),
      );
    }).toList();
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    final order = _displayOrder;
    return order.map((key) {
      final item = AppService.navigationItems[key]!;
      return BottomNavigationBarItem(icon: Icon(item.icon), label: item.title);
    }).toList();
  }
}
