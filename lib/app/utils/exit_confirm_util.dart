import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/home/home_navigation_layout.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ExitConfirmUtil {
  static DateTime? _lastExitTime;

  static final List<String> _homeRoutes = [
    Routes.POPULAR_VIDEOS,
    Routes.GALLERY,
    Routes.SUBSCRIPTIONS,
    Routes.FORUM,
  ];

  /// 安全获取当前路由（空栈返回 null）
  static Route<dynamic>? _currentRouteOrNull() {
    final routes = HomeNavigationLayout.homeNavigatorObserver.routes;
    if (routes.isEmpty) return null;
    return routes.last;
  }

  /// 检查当前路由是否为主页路由（带空栈防护）
  static bool isHomeRoute() {
    final currentRoute = _currentRouteOrNull();
    if (currentRoute == null) return false;
    return _homeRoutes.contains(currentRoute.settings.name);
  }

  /// 判断当前是否处于 Home 根态（需要双击退出的场景）
  /// 条件：处于主页路由 + 无 overlay + 嵌套 Navigator 不可 pop
  static bool isHomeRootState() {
    final hasOverlay =
        (Get.isDialogOpen ?? false) || (Get.isBottomSheetOpen ?? false);
    if (hasOverlay) return false;

    final nestedCanPop =
        AppService.homeNavigatorKey.currentState?.canPop() ?? false;
    if (nestedCanPop) return false;

    return isHomeRoute();
  }

  /// 处理退出操作
  static void handleExit(BuildContext context, VoidCallback action) {
    if (isHomeRootState()) {
      if (checkCanExitAndShowMessage(context)) {
        action();
      }
    } else {
      action();
    }
  }

  static bool checkCanExitAndShowMessage(BuildContext context) {
    if (_lastExitTime == null) {
      _lastExitTime = DateTime.now();
      _showExitTip(context);
      return false;
    }

    final now = DateTime.now();
    if (now.difference(_lastExitTime!) <= const Duration(seconds: 5)) {
      _lastExitTime = null;
      return true;
    } else {
      _lastExitTime = now;
      _showExitTip(context);
      return false;
    }
  }

  static void _showExitTip(BuildContext context) {
    Get.showSnackbar(
      GetSnackBar(
        message: slang.t.common.exitConfirmTip,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
        snackPosition: SnackPosition.bottom,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        maxWidth: 400,
      ),
    );
  }
}
