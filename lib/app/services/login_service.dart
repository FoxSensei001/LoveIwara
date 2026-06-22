// services/login_service.dart
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../ui/pages/login/login_page_v2.dart';
import 'auth_service.dart';

/// 全局登录服务，用于统一管理登录弹窗
class LoginService {
  static LoginService? _instance;
  static LoginService get instance => _instance ??= LoginService._();

  LoginService._();

  /// 显示登录对话框
  /// 返回 true 表示登录成功，false 表示取消或失败
  static Future<bool> showLogin() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;

    final result = await LoginDialog.show(context);
    return result == true;
  }

  /// 便捷的静态方法，用于替换 Get.toNamed(Routes.LOGIN)
  static Future<bool> requireLogin() async {
    return await showLogin();
  }

  /// 检查登录状态，如果未登录则显示登录对话框。
  /// 已登录（含刷新中/降级离线的有效会话）直接返回 true，不弹框(MEDIUM#6)。
  /// 注意：返回 true 仅代表"当前持有有效会话"；若随后刷新最终失败，
  /// 由请求层(ApiService 401→刷新→重试→handleTokenExpired)兜底，调用方需容忍该情况。
  static Future<bool> ensureLogin() async {
    try {
      if (Get.isRegistered<AuthService>() &&
          Get.find<AuthService>().isAuthenticated) {
        return true;
      }
    } catch (e) {
      LogUtils.w('ensureLogin 检查登录状态失败，回退到弹窗: $e', 'LoginService');
    }
    return await showLogin();
  }
}
