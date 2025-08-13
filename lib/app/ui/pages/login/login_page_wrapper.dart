// pages/login/login_page_wrapper.dart
import 'package:flutter/material.dart';
import 'login_page.dart';

/// 保持路由兼容性的包装页面
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 直接显示 LoginDialog 作为全屏页面
    return Scaffold(
      body: LoginDialog(),
    );
  }
}
