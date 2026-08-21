import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/pop_coordinator.dart';
import 'package:i_iwara/app/ui/widgets/animated_navigation_rail_slot.dart';
import 'package:i_iwara/app/ui/pages/community/community_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/easy_throttle.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/utils/exit_confirm_util.dart';
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
  final FocusNode _contentFocusNode = FocusNode(
    debugLabel: 'Home shell content',
  );
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
    glassBottomBarObstruction = 0;
    userService.stopNotificationTimer();
    EasyThrottle.cancel('refresh_page');
    _contentFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 来自 Android onTrimMemory(level >= TRIM_MEMORY_RUNNING_LOW)，绝大多数是
  /// UI_HIDDEN / BACKGROUND，即用户切后台而非真的内存告急。缓存释放已由框架
  /// 完成（PaintingBinding 清 imageCache、ServicesBinding 清 rootBundle、引擎通知 VM GC），
  /// 这里再清一遍无收益，仅保留日志作为闪退排查的时间锚点。
  @override
  void didHaveMemoryPressure() {
    LogUtils.d('收到系统 trim memory 信号（多为切后台）', 'HomeShellScaffold');
    super.didHaveMemoryPressure();
  }

  /// Get the display-ordered list of navigation keys.
  List<String> get _displayOrder {
    return HomeShellNavigation.normalizeOrder(
      configService[ConfigKey.NAVIGATION_ORDER],
    );
  }

  /// User-hidden navigation keys (e.g. forum / news).
  List<String> get _hiddenItems {
    return HomeShellNavigation.normalizeHidden(
      configService[ConfigKey.NAVIGATION_HIDDEN],
    );
  }

  /// Display order with hidden items removed — what the nav UI actually shows.
  List<String> get _visibleOrder {
    return HomeShellNavigation.visibleOrder(_displayOrder, _hiddenItems);
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
      _visibleOrder,
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

    VibrateUtils.vibrate();
    if (shell != null) {
      shell.goBranch(
        branchIndex,
        initialLocation: branchIndex == currentBranch,
      );
    } else {
      appRouter.go(_branchIndexToPath(branchIndex));
    }
    // Sync appService.currentIndex for Obx consumers.
    appService.currentIndex = branchIndex;
  }

  /// Refresh the current branch page via HomeWidgetInterface.
  /// 再次点击当前栏目：回到顶部 + 重新加载当前子 tab（已访问的其他子 tab 待下次切换时刷新）。
  void _refreshCurrentBranch() {
    final shell = appService.navigationShell;
    final branchIndex = shell?.currentIndex ?? appService.currentIndex;
    refreshHomeBranch(branchIndex);
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
    Widget body = Builder(
      builder: (context) {
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

            // At home root → 二次确认退出（5s 内再次返回才真正退出）
            if (isAtRoot) {
              ExitConfirmUtil.handleExit(context, () => SystemNavigator.pop());
              return;
            }

            PopCoordinator.handleBack(context);
          },
          child: widget.child,
        );
      },
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final mediaQuery = MediaQuery.of(context);
          final reduceMotion =
              mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;
          return Row(
            children: [
              // Side navigation rail
              Obx(() {
                final displayOrder = _visibleOrder;
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
                return AnimatedNavigationRailSlot(
                  visible: shouldShowWideNavigationRail(
                    constraints.maxWidth,
                    enabled: appService.showRailNavi,
                  ),
                  reduceMotion: reduceMotion,
                  width: railWidth,
                  onFocusExitRequested: _contentFocusNode.requestFocus,
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
                child: Focus(
                  focusNode: _contentFocusNode,
                  skipTraversal: true,
                  includeSemantics: false,
                  child: Obx(() {
                    // 浮动底栏永远不放进 Scaffold.bottomNavigationBar。
                    //
                    // Scaffold 是按 `bottomNavigationBar != null` 来决定要不要给
                    // body 套 MediaQuery.removePadding(removeBottom: true) 的；
                    // 一旦挂上（哪怕是 SizedBox.shrink()），整个 shell 内所有页面的
                    // MediaQuery.padding.bottom 都会变成 0，SafeArea(bottom: true)
                    // 全部失效（历史上整套安全区失效的总根因）。
                    //
                    // 现在底栏是 Stack 覆盖层：列表内容从它下面透过去；同时把
                    // 底栏占用的高度**加进** MediaQuery.padding.bottom，这样页面里
                    // 所有按安全区让位的逻辑（SafeArea / computeBottomSafeInset /
                    // padding.bottom）都自动把底栏算进去，不需要每页单独处理。
                    final bool showBottomNav =
                        appService.showBottomNavi && !isWide && _isTabRootRoute;

                    final Widget content = Scaffold(body: body);
                    if (!showBottomNav) {
                      glassBottomBarObstruction = 0;
                      return content;
                    }

                    final mq = MediaQuery.of(context);
                    final double safeBottom = mq.padding.bottom;
                    final double reserved =
                        GlassTokens.floatingBarReservedExtent;
                    // 根 Overlay 上的浮层（toast）不在本子树里，读不到下面这份
                    // 被抬高的 MediaQuery，只能靠这个全局值避开底栏。
                    glassBottomBarObstruction = safeBottom + reserved;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        MediaQuery(
                          data: mq.copyWith(
                            padding: mq.padding.copyWith(
                              bottom: safeBottom + reserved,
                            ),
                          ),
                          child: content,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: EdgeFadeScrim.bottom(
                            height:
                                safeBottom +
                                reserved +
                                GlassTokens.bottomFadeExtent,
                            solidExtent: safeBottom,
                          ),
                        ),
                        Positioned(
                          left: GlassTokens.floatingTabBarSideMargin,
                          right: GlassTokens.floatingTabBarSideMargin,
                          bottom:
                              safeBottom +
                              GlassTokens.floatingTabBarBottomMargin,
                          child: _buildFloatingTabBar(context),
                        ),
                      ],
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

  Widget _buildFloatingTabBar(BuildContext context) {
    final displayOrder = _visibleOrder;
    final currentDisplayIndex = _currentDisplayIndexForOrder(displayOrder);

    // 浮动底栏是整个 App 里最该「真的是玻璃」的一块：它常驻在滚动内容之上，
    // 身后一直有东西在流动。它本身不在任何滚动容器里，正是 lens 的适用场景。
    return LiquidGlassScope(
      child: GlassFloatingTabBar(
        currentIndex: currentDisplayIndex,
        onTap: (index) => _handleNavigationTap(index, displayOrder),
        items: displayOrder.map((key) {
          final item = AppService.navigationItems[key]!;
          return GlassTabItem(icon: item.icon, label: item.title);
        }).toList(),
        trailing: GlassIconButton(
          standalone: true,
          size: GlassTokens.floatingActionSize,
          iconSize: 26,
          icon: const Icon(Icons.search),
          tooltip: slang.t.common.search,
          onPressed: _openSearchForCurrentBranch,
        ),
      ),
    );
  }

  /// 底部独立搜索钮：按当前栏目选择默认搜索分段，统一走全局搜索对话框 → 搜索结果页。
  void _openSearchForCurrentBranch() {
    final shell = appService.navigationShell;
    final branchIndex = shell?.currentIndex ?? appService.currentIndex;
    String? key;
    for (final entry in HomeShellNavigation.branchIndexByKey.entries) {
      if (entry.value == branchIndex) {
        key = entry.key;
        break;
      }
    }
    final SearchSegment segment = switch (key) {
      'gallery' => SearchSegment.image,
      // 社区栏目分论坛 / 新闻两半：在论坛那半才默认论坛分段，
      // 新闻那半没有对应的搜索分段，落回视频。
      'community' =>
        CommunityPage.globalKey.currentState?.isOnForum ?? false
            ? SearchSegment.forum
            : SearchSegment.video,
      // subscription / video 及未知栏目统一默认视频分段
      _ => SearchSegment.video,
    };
    showAppDialog(
      SearchDialog(
        userInputKeywords: '',
        initialSegment: segment,
        onSearch: (searchInfo, segment, filters, sort) {
          NaviService.toSearchPage(
            searchInfo: searchInfo,
            segment: segment,
            filters: filters,
            sort: sort,
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
                _buildRailIdentityButton(context),
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

  /// 侧边栏右下角的身份入口：首页根显示设置钮（打开抽屉），一旦深入到其他
  /// 页面（详情页等）就换成头像钮——与窄屏 header 上「头像=我」的语义对齐，
  /// 两侧同一个功能，只是形状完全不同，用 [GlassShapeSwitcher] 做形变过渡
  /// 而不是硬切。
  Widget _buildRailIdentityButton(BuildContext context) {
    final bool showAvatar = !_isAtHomeRoot;
    return GlassShapeSwitcher(
      child: showAvatar
          ? KeyedSubtree(
              key: const ValueKey('rail_identity_avatar'),
              child: _buildRailAvatarButton(context),
            )
          : KeyedSubtree(
              key: const ValueKey('rail_identity_settings'),
              child: IconButton(
                icon: const Icon(Icons.settings),
                tooltip: slang.t.common.settings,
                onPressed: () {
                  AppService.switchGlobalDrawer();
                },
              ),
            ),
    );
  }

  Widget _buildRailAvatarButton(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final user = userService.hasLoadedProfile
          ? userService.currentUser.value
          : null;
      final count =
          userService.notificationCount.value + userService.messagesCount.value;

      // 侧栏身份钮也走液态档：它压在 NavigationRail 的实心面上，折射出来的是
      // rail 的底色 + 自己身下那一小片，与窄屏 header 上同一枚圆钮观感一致。
      return LiquidGlassScope(
        child: GlassSurface(
          circle: true,
          tooltip: t.common.me,
          onTap: AppService.switchGlobalDrawer,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (user != null)
                IgnorePointer(
                  child: AvatarWidget(
                    user: user,
                    size: GlassTokens.pillHeight - 2,
                  ),
                )
              else
                Icon(
                  Icons.account_circle,
                  size: 26,
                  color: colorScheme.onSurface,
                ),
              Positioned(
                right: 2,
                top: 2,
                child: GlassAnimatedDot(visible: count > 0),
              ),
            ],
          ),
        ),
      );
    });
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
}
