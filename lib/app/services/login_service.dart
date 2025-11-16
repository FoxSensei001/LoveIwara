// services/login_service.dart
import 'package:get/get.dart';
import '../ui/pages/login/login_page_v2.dart';

/// 全局登录服务，用于统一管理登录弹窗
class LoginService {
  static LoginService? _instance;
  static LoginService get instance => _instance ??= LoginService._();

  LoginService._();

  /// 显示登录对话框
  /// 返回 true 表示登录成功，false 表示取消或失败
  static Future<bool> showLogin() async {
    final context = Get.context;
    if (context == null) return false;

    final result = await LoginDialog.show(context);
    return result == true;
  }

  /// 便捷的静态方法，用于替换 Get.toNamed(Routes.LOGIN)
  static Future<bool> requireLogin() async {
    return await showLogin();
  }

  /// 检查登录状态，如果未登录则显示登录对话框
  static Future<bool> ensureLogin() async {
    // 这里可以添加检查当前登录状态的逻辑
    // 如果已登录则直接返回 true，否则显示登录对话框
    return await showLogin();
  }
}
