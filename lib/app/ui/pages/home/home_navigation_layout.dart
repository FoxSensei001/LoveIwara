import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_page.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../../../routes/app_routes.dart';
import '../../../services/app_service.dart';
import '../../../services/user_service.dart';
import '../popular_media_list/popular_gallery_list_page.dart';
import '../popular_media_list/popular_video_list_page.dart';
import '../subscriptions/subscriptions_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 侧边栏、底部导航栏、主要内容
class HomeNavigationLayout extends StatefulWidget {
  const HomeNavigationLayout({super.key});

  static final HomeNavigatorObserver homeNavigatorObserver = HomeNavigatorObserver();

  @override
  State<HomeNavigationLayout> createState() => _HomeNavigationLayoutState();
}

class _HomeNavigationLayoutState extends State<HomeNavigationLayout> {
  final AppService appService = Get.find<AppService>();
  final UserService userService = Get.find<UserService>();

  @override
  void initState() {
    super.initState();
    // 启动通知计数定时任务
    userService.startNotificationTimer();
  }

  @override
  void dispose() {
    // 停止通知计数定时任务
    userService.stopNotificationTimer();
    super.dispose();
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
                          onDestinationSelected: (value) {
                            if (appService.currentIndex == value) return;
                            appService.currentIndex = value;
                            final routes = [
                              Routes.POPULAR_VIDEOS,
                              Routes.GALLERY,
                              Routes.SUBSCRIPTIONS,
                              Routes.FORUM,
                            ];
                            AppService.homeNavigatorKey.currentState!
                                .pushNamedAndRemoveUntil(
                              routes[value],
                              (route) => false,
                            );
                          },
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
                // 主要内容
                Expanded(
                  child: Scaffold(
                    body: Navigator(
                      key: AppService.homeNavigatorKey,
                      observers: [
                        HomeNavigationLayout.homeNavigatorObserver,
                      ],
                      onGenerateRoute: (RouteSettings settings) {
                        WidgetBuilder builder;
                        Route<dynamic> route;

                        switch (settings.name) {
                          case Routes.ROOT:
                          case Routes.POPULAR_VIDEOS:
                            builder = (BuildContext context) =>
                                PopularVideoListPage();
                            route = PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      builder(context),
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                            break;
                          case Routes.GALLERY:
                            builder = (BuildContext context) =>
                                PopularGalleryListPage();
                            route = PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      builder(context),
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                            break;
                          case Routes.SUBSCRIPTIONS:
                            builder = (BuildContext context) =>
                                const SubscriptionsPage();
                            route = PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      builder(context),
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                            break;
                          case Routes.FORUM:
                            builder = (BuildContext context) =>
                                const ForumPage();
                            route = PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      builder(context),
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                            break;
                          default:
                            builder = (BuildContext context) =>
                                const Center(child: Text('404'));
                            route = PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      builder(context),
                              settings: settings,
                              transitionDuration: Duration.zero,
                            );
                        }

                        return route;
                      },
                    ),
                    // 底部导航栏
                    bottomNavigationBar: Obx(() {
                      if (!appService.showBottomNavi) {
                        return const SizedBox.shrink();
                      }
                      if (isWide) return const SizedBox.shrink();

                      final index = appService.currentIndex;
                      final routes = [
                        Routes.POPULAR_VIDEOS,
                        Routes.GALLERY,
                        Routes.SUBSCRIPTIONS,
                        Routes.FORUM,
                      ];

                      return BottomNavigationBar(
                        currentIndex: index,
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedItemColor: Theme.of(context).colorScheme.primary,
                        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
                        onTap: (value) {
                          appService.currentIndex = value;
                          AppService.homeNavigatorKey.currentState
                              ?.pushNamedAndRemoveUntil(
                            routes[value],
                            (route) => false,
                          );
                        },
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
  const _NaviPopScope(
      {required this.child, this.popGesture = false, required this.action});

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
              LogUtils.i('[顶层Popscope结果, value: $value, result: $result]',
                  'PopScope');
              action();
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
            if (details.velocity.pixelsPerSecond.dx < 0 ||
                details.velocity.pixelsPerSecond.dx > 0) {
              if (panStartAtEdge) {
                action();
              }
            }
            panStartAtEdge = false;
          },
          child: res);
    }
    return res;
  }
}
