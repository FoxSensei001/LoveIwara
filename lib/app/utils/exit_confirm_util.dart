import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
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

  /// 检查当前路由是否为主页路由
  static bool isHomeRoute() {
    final currentRoute = HomeNavigationLayout.homeNavigatorObserver.routes.last;
    return _homeRoutes.contains(currentRoute.settings.name);
  }

  /// 处理退出操作
  static void handleExit(BuildContext context, VoidCallback action) {
    // 判断当前有没有 Get 的 overlay
    final haveOverlay = Get.isDialogOpen ?? Get.isBottomSheetOpen ?? false;
    if (isHomeRoute() && !haveOverlay) {
      // final currentRoute = HomeNavigationLayout.homeNavigatorObserver.routes.last;
      
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