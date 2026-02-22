import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_page.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:i_iwara/utils/easy_throttle.dart';

import '../../../routes/app_routes.dart';
import '../../../services/app_service.dart';
import '../../../services/user_service.dart';
import '../../../services/config_service.dart';
import '../popular_media_list/popular_gallery_list_page.dart';
import '../popular_media_list/popular_video_list_page.dart';
import '../subscriptions/subscriptions_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/exit_confirm_util.dart';
import 'package:i_iwara/app/ui/widgets/lazy_indexed_stack.dart';

/// 侧边栏、底部导航栏、主要内容
class HomeNavigationLayout extends StatefulWidget {
  static final homeNavigatorObserver = HomeNavigatorObserver();

  const HomeNavigationLayout({super.key});

  @override
  State<HomeNavigationLayout> createState() => _HomeNavigationLayoutState();
}

class _HomeNavigationLayoutState extends State<HomeNavigationLayout>
    with WidgetsBindingObserver {
  final AppService appService = Get.find<AppService>();
  final UserService userService = Get.find<UserService>();
  final ConfigService configService = Get.find<ConfigService>();

  /// 使用 LazyIndexedStack 进行懒加载，使用 GlobalKey 引用它以便内存释放
  final GlobalKey<LazyIndexedStackState> _lazyStackKey =
      GlobalKey<LazyIndexedStackState>();

  @override
  void initState() {
    super.initState();
    // 注册内存观察者，监听内存压力事件
    WidgetsBinding.instance.addObserver(this);
    // 启动通知计数定时任务
    userService.startNotificationTimer();
  }

  @override
  void dispose() {
    // 停止通知计数定时任务
    userService.stopNotificationTimer();
    // 清理节流器
    EasyThrottle.cancel('refresh_page');
    EasyThrottle.cancel('switch_page');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 当系统内存紧张时，通过 LazyIndexedStack 释放非当前显示页面
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    _lazyStackKey.currentState?.releaseNonCurrent();
    LogUtils.d("内存存在压力，释放其他页面", "HomeNavigationLayout");
  }

  /// 新增的通用导航处理方法
  void handleNavigationTap(int value) {
    if (appService.currentIndex == value) {
      // 如果是当前页面，则不进行切换，而是刷新当前页面
      // 添加节流，1秒内只能刷新一次
      if (EasyThrottle.throttle(
        'refresh_page',
        const Duration(seconds: 1), // 节流时间
        () {
          VibrateUtils.vibrate();
          _lazyStackKey.currentState?.refreshCurrent();
        },
      )) {
        return; // 如果被节流了，直接返回
      }
      return;
    }

    // 切换页面的逻辑添加节流
    if (EasyThrottle.throttle(
      'switch_page',
      const Duration(milliseconds: 300), // 节流时间
      () {
        VibrateUtils.vibrate();
        // 清除所有子页面后再切换主页面
        while (AppService.homeNavigatorKey.currentState!.canPop()) {
          AppService.homeNavigatorKey.currentState!.pop();
        }
        appService.currentIndex = value;
      },
    )) {
      return; // 如果被节流了，直接返回
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return _NaviPopScope(
      action: AppService.tryPop,
      popGesture: GetPlatform.isIOS,
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Row(
              children: [
                // 侧边栏
                Obx(() {
                  if (!appService.showRailNavi) return const SizedBox.shrink();
                  if (!isWide) return const SizedBox.shrink();

                  return LayoutBuilder(
                    builder: (context, railConstraints) {
                      // 计算所需的最小高度
                      // 每个导航项约 72px，设置和退出按钮各 48px，加上一些边距
                      final navigationItemCount =
                          _buildNavigationRailDestinations().length;
                      final estimatedMinHeight =
                          (navigationItemCount * 72.0) + (2 * 48.0) + 32.0;
                      final availableHeight = railConstraints.maxHeight;
                      final hasEnoughSpace =
                          availableHeight >= estimatedMinHeight;

                      if (hasEnoughSpace) {
                        // 高度足够：使用固定布局，按钮在底部
                        return Obx(
                          () => NavigationRail(
                            labelType: NavigationRailLabelType.all,
                            selectedIndex: appService.currentIndex,
                            // leading: const SizedBox(height: 16), // 移除顶部的空隙
                            trailing: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.settings),
                                          tooltip: t.common.settings,
                                          onPressed: () {
                                            AppService.switchGlobalDrawer();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.exit_to_app),
                                          tooltip: t.common.back,
                                          onPressed: () {
                                            AppService.tryPop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onDestinationSelected: handleNavigationTap,
                            destinations: _buildNavigationRailDestinations(),
                          ),
                        );
                      } else {
                        // 高度不够：使用滚动布局
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: railConstraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Obx(
                                () => NavigationRail(
                                  labelType: NavigationRailLabelType.all,
                                  selectedIndex: appService.currentIndex,
                                  trailing: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.settings),
                                          tooltip: t.common.settings,
                                          onPressed: () {
                                            AppService.switchGlobalDrawer();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.exit_to_app),
                                          tooltip: t.common.back,
                                          onPressed: () {
                                            AppService.tryPop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  onDestinationSelected: handleNavigationTap,
                                  destinations:
                                      _buildNavigationRailDestinations(),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
                // 主要内容区域：使用 Navigator 和 IndexedStack 结合懒加载页面
                Expanded(
                  child: Scaffold(
                    body: NavigatorPopHandler(
                      onPopWithResult: (_) => AppService.tryPop(),
                      child: Navigator(
                        key: AppService.homeNavigatorKey,
                        observers: [HomeNavigationLayout.homeNavigatorObserver],
                        onGenerateRoute: (settings) {
                          if (settings.name == Routes.ROOT ||
                              settings.name == Routes.POPULAR_VIDEOS ||
                              settings.name == Routes.GALLERY ||
                              settings.name == Routes.SUBSCRIPTIONS ||
                              settings.name == Routes.FORUM) {
                            return PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                    return Obx(
                                      () => LazyIndexedStack(
                                        key: _lazyStackKey,
                                        index: appService.currentIndex,
                                        itemBuilders: _buildPageBuilders(),
                                      ),
                                    );
                                  },
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                          }
                          // 其他路由按照原逻辑处理
                          return null;
                        },
                      ),
                    ),
                    // 底部导航栏
                    bottomNavigationBar: Obx(() {
                      if (!appService.showBottomNavi) {
                        return const SizedBox.shrink();
                      }
                      if (isWide) return const SizedBox.shrink();

                      return BottomNavigationBar(
                        currentIndex: appService.currentIndex,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedItemColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                        unselectedItemColor: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                        onTap: handleNavigationTap,
                        items: _buildBottomNavigationBarItems(),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 构建侧边栏导航目标
  List<NavigationRailDestination> _buildNavigationRailDestinations() {
    // 监听导航配置变化
    final orderRaw = configService[ConfigKey.NAVIGATION_ORDER];
    final order = (orderRaw as List<dynamic>).cast<String>();

    return order.map((key) {
      final item = AppService.navigationItems[key]!;
      return NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.title),
      );
    }).toList();
  }

  // 构建底部导航栏项目
  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    // 监听导航配置变化
    final orderRaw = configService[ConfigKey.NAVIGATION_ORDER];
    final order = (orderRaw as List<dynamic>).cast<String>();

    return order.map((key) {
      final item = AppService.navigationItems[key]!;
      return BottomNavigationBarItem(icon: Icon(item.icon), label: item.title);
    }).toList();
  }

  // 构建页面构建器列表
  List<Widget Function(BuildContext)> _buildPageBuilders() {
    // 监听导航配置变化
    final orderRaw = configService[ConfigKey.NAVIGATION_ORDER];
    final order = (orderRaw as List<dynamic>).cast<String>();

    return order.map((key) {
      switch (key) {
        case 'video':
          return (context) =>
              PopularVideoListPage(key: PopularVideoListPage.globalKey);
        case 'gallery':
          return (context) =>
              PopularGalleryListPage(key: PopularGalleryListPage.globalKey);
        case 'subscription':
          return (context) =>
              SubscriptionsPage(key: SubscriptionsPage.globalKey);
        case 'forum':
          return (context) => ForumPage(key: ForumPage.globalKey);
        default:
          return (context) =>
              PopularVideoListPage(key: PopularVideoListPage.globalKey);
      }
    }).toList();
  }
}

/// HOME 页面路由观察器
class HomeNavigatorObserver extends NavigatorObserver {
  final AppService appService = Get.find();
  var routes = Queue<Route>();
  final List<Function(Route?, Route?)> _routeChangeCallbacks = [];

  HomeNavigatorObserver();

  void addRouteChangeCallback(Function(Route?, Route?) callback) {
    _routeChangeCallbacks.add(callback);
  }

  void removeRouteChangeCallback(Function(Route?, Route?) callback) {
    _routeChangeCallbacks.remove(callback);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (routes.isNotEmpty) {
      routes.removeLast();
    } else {
      LogUtils.w(
        'didPop called but routes is empty, route: ${route.settings.name}',
        'HomeNavigatorObserver',
      );
    }
    _tryHideBottomNavi();
    for (var callback in _routeChangeCallbacks) {
      callback(route, previousRoute);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    routes.addLast(route);
    _tryHideBottomNavi();
    for (var callback in _routeChangeCallbacks) {
      callback(route, previousRoute);
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    routes.remove(route);
    _tryHideBottomNavi();
    for (var callback in _routeChangeCallbacks) {
      callback(route, previousRoute);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (oldRoute != null && newRoute != null) {
      // pushReplacement 场景：仅替换栈顶路由，保留其下方的路由
      // 找到旧路由在队列中的位置并替换
      final routesList = routes.toList();
      final index = routesList.indexOf(oldRoute);
      if (index != -1) {
        routesList[index] = newRoute;
        routes = Queue.of(routesList);
      } else {
        // 旧路由不在队列中（异常情况），直接添加新路由
        routes.addLast(newRoute);
      }
    } else if (newRoute != null && oldRoute == null) {
      // offAllNamed 场景：清空所有路由并重新开始
      routes.clear();
      routes.add(newRoute);
    } else if (oldRoute != null && newRoute == null) {
      // 仅移除旧路由
      routes.remove(oldRoute);
    }
    _tryHideBottomNavi();
    for (var callback in _routeChangeCallbacks) {
      callback(newRoute, oldRoute);
    }
  }

  void _tryHideBottomNavi() {
    // 确保在路由栈重置时正确显示底部导航栏
    if (routes.length > 1 && appService.showBottomNavi) {
      appService.showBottomNavi = false;
    } else if (routes.length <= 1 && !appService.showBottomNavi) {
      appService.showBottomNavi = true;
    }
  }

  /// 手动重置路由栈状态（用于处理特殊情况）
  void resetRouteStack() {
    routes.clear();
    appService.showBottomNavi = true;
  }
}

/// 顶层返回手势处理组件
/// Android: 使用 PopScope 配合动态 canPop 实现预测式返回手势
/// iOS: 使用自定义边缘滑动手势
///
/// 注意 Android 预测式返回的关键机制：
/// Android 13+ 通过 OnBackInvokedCallback 接收返回手势。Flutter 通过
/// SystemNavigator.setFrameworkHandlesBack(bool) 控制是否注册该回调。
/// 当 setFrameworkHandlesBack(false) 时回调被注销，系统返回手势会直接
/// finish Activity（退出应用），完全绕过 Flutter。
///
/// 问题：嵌套 Navigator 在首页根态发出 NavigationNotification(canHandlePop: false)，
/// 与根路由的 PopScope(canPop: false) 产生的 canHandlePop: true 存在时序竞态，
/// 可能导致最终 setFrameworkHandlesBack(false)，使返回手势直接退出应用。
///
/// 解决方案：在首页根态时主动调用 setFrameworkHandlesBack(true) 确保回调注册。
class _NaviPopScope extends StatefulWidget {
  const _NaviPopScope({
    required this.child,
    this.popGesture = false,
    required this.action,
  });

  final Widget child;
  final bool popGesture;
  final VoidCallback action;

  @override
  State<_NaviPopScope> createState() => _NaviPopScopeState();
}

class _NaviPopScopeState extends State<_NaviPopScope> {
  static bool panStartAtEdge = false;

  /// 确保在首页根态时 Android 系统返回手势回调已注册
  void _ensureFrameworkHandlesBack(bool isAtHomeRoot) {
    if (!GetPlatform.isAndroid) return;
    if (!isAtHomeRoot) return;
    // 在帧结束后设置，避免在 build 期间产生副作用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SystemNavigator.setFrameworkHandlesBack(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget res = GetPlatform.isIOS
        ? widget.child
        : Obx(() {
            // 动态计算 canPop：
            // 优先基于 Navigator 实时状态，同时参考 showBottomNavi 作为响应式信号
            final AppService appService = Get.find<AppService>();
            // 读取 showBottomNavi 以触发 Obx 响应式重建
            final bool isBottomNaviVisible = appService.showBottomNavi;
            // 基于 Navigator 真实能力判断
            final bool nestedCanPop =
                AppService.homeNavigatorKey.currentState?.canPop() ?? false;
            // Home 根态：底部导航可见 且 嵌套 Navigator 不可 pop
            final bool isAtHomeRoot = isBottomNaviVisible && !nestedCanPop;
            final bool canPop = !isAtHomeRoot;

            // 首页根态时确保 Android 系统返回手势回调已注册，
            // 防止嵌套 Navigator 的 NavigationNotification 竞态导致回调被注销
            _ensureFrameworkHandlesBack(isAtHomeRoot);

            return PopScope(
              canPop: canPop,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                // 如果嵌套 Navigator 可以 pop，说明 NavigatorPopHandler 会处理，
                // 避免与 NavigatorPopHandler 重复执行 pop
                final nestedCanPop =
                    AppService.homeNavigatorKey.currentState?.canPop() ?? false;
                if (nestedCanPop) return;
                // didPop 为 false 且嵌套不可 pop，说明在 Home 根态
                // 走双击退出确认逻辑
                LogUtils.d(
                  '[顶层Popscope结果, didPop: $didPop, result: $result]',
                  'PopScope',
                );
                ExitConfirmUtil.handleExit(context, widget.action);
              },
              child: widget.child,
            );
          });

    if (widget.popGesture) {
      res = GestureDetector(
        onPanStart: (details) {
          if (details.globalPosition.dx < 64) {
            panStartAtEdge = true;
          }
        },
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx.abs() > 0 && panStartAtEdge) {
            ExitConfirmUtil.handleExit(context, widget.action);
          }
          panStartAtEdge = false;
        },
        child: res,
      );
    }
    return res;
  }
}
