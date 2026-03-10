import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/pop_coordinator.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/easy_throttle.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/routes/home_shell_navigation.dart';

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
  final AppService appService = Get.find<AppService>();
  final UserService userService = Get.find<UserService>();
  final ConfigService configService = Get.find<ConfigService>();
  bool _hasSyncedInitialBranch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userService.startNotificationTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialBranchWithNavigationOrder();
    });
  }

  @override
  void dispose() {
    userService.stopNotificationTimer();
    EasyThrottle.cancel('refresh_page');
    EasyThrottle.cancel('switch_page');
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
    return HomeShellNavigation.normalizeOrder(
      configService[ConfigKey.NAVIGATION_ORDER],
    );
  }

  String _normalizePath(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  int? _branchIndexFromPath(String path) {
    final normalized = _normalizePath(path);
    for (final entry in HomeShellNavigation.pathByKey.entries) {
      if (entry.value == normalized) {
        return HomeShellNavigation.branchIndexForKey(entry.key, fallback: 0);
      }
    }
    return null;
  }

  bool get _isTabRootRoute => _branchIndexFromPath(widget.currentPath) != null;

  void _syncInitialBranchWithNavigationOrder() {
    if (!mounted || _hasSyncedInitialBranch) return;

    final normalizedPath = _normalizePath(widget.currentPath);
    if (normalizedPath != '/') {
      _hasSyncedInitialBranch = true;
      final currentBranch =
          _branchIndexFromPath(widget.currentPath) ??
          appService.navigationShell?.currentIndex ??
          appService.currentIndex;
      appService.currentIndex = currentBranch;
      return;
    }

    final shell = appService.navigationShell;
    if (shell == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncInitialBranchWithNavigationOrder();
      });
      return;
    }

    _hasSyncedInitialBranch = true;
    final preferredBranch = HomeShellNavigation.branchIndexFromDisplayIndex(
      0,
      _displayOrder,
    );
    final currentBranch = shell.currentIndex;
    if (preferredBranch == currentBranch) {
      appService.currentIndex = currentBranch;
      return;
    }

    shell.goBranch(preferredBranch, initialLocation: true);
    appService.currentIndex = preferredBranch;
  }

  /// Convert a display index (from navigation bar tap) to a go_router branch index.
  int _displayIndexToBranchIndex(int displayIndex, List<String> displayOrder) {
    return HomeShellNavigation.branchIndexFromDisplayIndex(
      displayIndex,
      displayOrder,
    );
  }

  String _branchIndexToPath(int branchIndex) {
    return HomeShellNavigation.pathForBranchIndex(branchIndex);
  }

  /// Convert the current go_router branch index to a display index.
  int _currentDisplayIndexForOrder(List<String> displayOrder) {
    final currentBranch =
        _branchIndexFromPath(widget.currentPath) ??
        appService.navigationShell?.currentIndex ??
        appService.currentIndex;
    return HomeShellNavigation.displayIndexFromBranchIndex(
      currentBranch,
      displayOrder,
    );
  }

  /// Handle navigation bar tap.
  void _handleNavigationTap(int displayIndex, List<String> displayOrder) {
    final branchIndex = _displayIndexToBranchIndex(displayIndex, displayOrder);
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
        if (shell != null) {
          shell.goBranch(
            branchIndex,
            initialLocation: branchIndex == currentBranch,
          );
        } else {
          appRouter.go(_branchIndexToPath(branchIndex));
        }
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

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    // PopScope for back handling:
    // - Intercept all back events inside Shell.
    // - Delegate to PopCoordinator for unified order:
    //   overlay/drawer -> internal page -> route pop.
    // - At home root: exit immediately.
    Widget body = Obx(() {
      // Read showBottomNavi to trigger Obx rebuild when navigation visibility changes
      // ignore: unused_local_variable
      final _ = appService.showBottomNavi;

      final bool isAtRoot = _isAtHomeRoot;
      final ModalRoute<dynamic>? shellRouteInBuild = ModalRoute.of(context);
      final bool isShellRouteCurrent = shellRouteInBuild?.isCurrent ?? true;
      final bool canAutoPopInShell = !isAtRoot && isShellRouteCurrent;
      final bool useManualBackDispatch = GetPlatform.isAndroid;
      final bool canPopViaNavigator = useManualBackDispatch
          ? false
          : canAutoPopInShell;
      return PopScope(
        // Android: disable navigator auto-pop and always dispatch by
        // PopCoordinator to avoid duplicated back dispatch that can pop shell
        // and root in one gesture.
        // Other platforms: keep navigator auto-pop behavior.
        canPop: canPopViaNavigator,
        onPopInvokedWithResult: (didPop, result) {
          LogUtils.d(
            'PopScope: didPop=$didPop, isAtRoot=$isAtRoot, canPop=$canPopViaNavigator, '
                'manualDispatch=$useManualBackDispatch, routeCurrent=$isShellRouteCurrent, '
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

          // If PopCoordinator already consumed this system back (e.g. by popping
          // a root-level overlay route), ignore this callback to avoid running
          // fallback logic again in shell.
          if (PopCoordinator.wasSystemBackConsumedRecently()) {
            LogUtils.d(
              'PopScope ignored: recent system back was consumed by PopCoordinator',
              'HomeShellScaffold',
            );
            return;
          }

          // At home root → exit immediately
          if (isAtRoot) {
            // Home root: exit immediately (no "press again" confirmation).
            SystemNavigator.pop();
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

                final displayOrder = _displayOrder;
                final currentDisplayIndex = _currentDisplayIndexForOrder(
                  displayOrder,
                );
                // NavigationRail expands to the max width from its parent.
                // In a Row, the non-flex child gets an unbounded max width,
                // so we must provide a tight width here.
                //
                // Compute width from the actual (localized) label content so
                // the rail stays compact in short locales and can grow when
                // labels are longer.
                final railWidth = _computeRailWidth(context, displayOrder);
                return SizedBox(
                  width: railWidth,
                  child: _buildNavigationRail(
                    context,
                    t,
                    displayOrder: displayOrder,
                    currentDisplayIndex: currentDisplayIndex,
                    railWidth: railWidth,
                  ),
                );
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

                    final displayOrder = _displayOrder;
                    final currentDisplayIndex = _currentDisplayIndexForOrder(
                      displayOrder,
                    );

                    return BottomNavigationBar(
                      currentIndex: currentDisplayIndex,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedItemColor: Theme.of(context).colorScheme.primary,
                      unselectedItemColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      onTap: (index) =>
                          _handleNavigationTap(index, displayOrder),
                      items: _buildBottomNavigationBarItems(displayOrder),
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

  Widget _buildNavigationRail(
    BuildContext context,
    dynamic t, {
    required List<String> displayOrder,
    required int currentDisplayIndex,
    required double railWidth,
  }) {
    return LayoutBuilder(
      builder: (context, railConstraints) {
        final navigationItems = _buildNavigationRailDestinations(displayOrder);
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
          return NavigationRail(
            labelType: NavigationRailLabelType.all,
            selectedIndex: currentDisplayIndex,
            minWidth: railWidth,
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [const Spacer(), buildTrailingButtons()],
              ),
            ),
            onDestinationSelected: (index) =>
                _handleNavigationTap(index, displayOrder),
            destinations: navigationItems,
          );
        } else {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: railConstraints.maxHeight),
              child: IntrinsicHeight(
                child: NavigationRail(
                  labelType: NavigationRailLabelType.all,
                  selectedIndex: currentDisplayIndex,
                  minWidth: railWidth,
                  trailing: buildTrailingButtons(),
                  onDestinationSelected: (index) =>
                      _handleNavigationTap(index, displayOrder),
                  destinations: navigationItems,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  double _computeRailWidth(BuildContext context, List<String> displayOrder) {
    // NavigationRail destination tiles include fixed paddings/indicator space.
    // We measure label text width and add a small constant to keep things
    // visually balanced.
    final railTheme = NavigationRailTheme.of(context);
    final textStyle =
        railTheme.unselectedLabelTextStyle ??
        Theme.of(context).textTheme.labelMedium ??
        const TextStyle(fontSize: 12);
    final textScaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);

    double maxLabelWidth = 0;
    for (final key in displayOrder) {
      final title = AppService.navigationItems[key]?.title;
      if (title == null || title.isEmpty) continue;

      final painter = TextPainter(
        text: TextSpan(text: title, style: textStyle),
        textDirection: direction,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();

      if (painter.width > maxLabelWidth) {
        maxLabelWidth = painter.width;
      }
    }

    // Default NavigationRail minWidth is ~72. Clamp to avoid very wide rails
    // with unexpectedly long labels.
    return (maxLabelWidth + 32).clamp(72.0, 200.0).toDouble();
  }

  List<NavigationRailDestination> _buildNavigationRailDestinations(
    List<String> displayOrder,
  ) {
    return displayOrder.map((key) {
      final item = AppService.navigationItems[key]!;
      return NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems(
    List<String> displayOrder,
  ) {
    return displayOrder.map((key) {
      final item = AppService.navigationItems[key]!;
      return BottomNavigationBarItem(icon: Icon(item.icon), label: item.title);
    }).toList();
  }
}
