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
      action: () {
        // TODO 还需要完整的验证Pop逻辑
        if (AppService.homeNavigatorKey.currentState!.canPop()) {
          AppService.homeNavigatorKey.currentState!.pop();
        } else {
          SystemNavigator.pop();
        }

        // AppService.tryPop();
      },
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

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
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
                          destinations: [
                            NavigationRailDestination(
                              icon: const Icon(Icons.video_library),
                              label: Text(t.common.video),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.photo),
                              label: Text(t.common.gallery),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.subscriptions),
                              label: Text(t.common.subscriptions),
                            ),
                            NavigationRailDestination(
                              icon: const Icon(Icons.forum),
                              label: Text(t.forum.forum),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // 主要内容区域：使用 Navigator 和 IndexedStack 结合懒加载页面
                Expanded(
                  child: Scaffold(
                    body: Navigator(
                      key: AppService.homeNavigatorKey,
                      observers: [
                        HomeNavigationLayout.homeNavigatorObserver,
                      ],
                      onGenerateRoute: (settings) {
                        if (settings.name == Routes.ROOT ||
                            settings.name == Routes.POPULAR_VIDEOS ||
                            settings.name == Routes.GALLERY ||
                            settings.name == Routes.SUBSCRIPTIONS ||
                            settings.name == Routes.FORUM) {
                          return PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Obx(() => LazyIndexedStack(
                                    key: _lazyStackKey,
                                    index: appService.currentIndex,
                                    itemBuilders: [
                                      (context) => PopularVideoListPage(
                                          key: PopularVideoListPage.globalKey),
                                      (context) => PopularGalleryListPage(
                                          key:
                                              PopularGalleryListPage.globalKey),
                                      (context) => SubscriptionsPage(
                                          key: SubscriptionsPage.globalKey),
                                      (context) =>
                                          ForumPage(key: ForumPage.globalKey),
                                    ],
                                  ));
                            },
                            settings: settings,
                            transitionDuration: Duration.zero,
                          );
                        }
                        // 其他路由按照原逻辑处理
                        return null;
                      },
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
                        selectedItemColor:
                            Theme.of(context).colorScheme.primary,
                        unselectedItemColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        onTap: handleNavigationTap,
                        items: [
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.video_library),
                            label: t.common.video,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.photo),
                            label: t.common.gallery,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.subscriptions),
                            label: t.common.subscriptions,
                          ),
                          BottomNavigationBarItem(
                            icon: const Icon(Icons.forum),
                            label: t.forum.forum,
                          ),
                        ],
                      );
                    }),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

/// [TODO_PLACEHOLDER] HOME 页面路由观察器
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
    routes.removeLast();
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
    routes.remove(oldRoute);
    if (newRoute != null) {
      routes.add(newRoute);
    }
    _tryHideBottomNavi();
    for (var callback in _routeChangeCallbacks) {
      callback(newRoute, oldRoute);
    }
  }

  void _tryHideBottomNavi() {
    if (routes.length > 1 && appService.showBottomNavi) {
      appService.showBottomNavi = false;
    } else if (routes.length <= 1 && !appService.showBottomNavi) {
      appService.showBottomNavi = true;
    }
  }
}

class _NaviPopScope extends StatelessWidget {
  const _NaviPopScope({
    required this.child,
    this.popGesture = false,
    required this.action,
  });

  final Widget child;
  final bool popGesture;
  final VoidCallback action;

  static bool panStartAtEdge = false;

  @override
  Widget build(BuildContext context) {
    Widget res = GetPlatform.isIOS
        ? child
        : PopScope(
            canPop: GetPlatform.isAndroid ? false : true,
            onPopInvokedWithResult: (value, result) {
              LogUtils.i(
                  '[顶层Popscope结果, value: $value, result: $result]', 'PopScope');
              ExitConfirmUtil.handleExit(context, action);
            },
            child: child,
          );

    if (popGesture) {
      res = GestureDetector(
        onPanStart: (details) {
          if (details.globalPosition.dx < 64) {
            panStartAtEdge = true;
          }
        },
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx.abs() > 0 && panStartAtEdge) {
            ExitConfirmUtil.handleExit(context, action);
          }
          panStartAtEdge = false;
        },
        child: res,
      );
    }
    return res;
  }
}
