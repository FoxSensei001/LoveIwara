import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:shimmer/shimmer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  String _status = t.splash.preparing;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // 创建呼吸动画
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // 重复播放动画
    _controller.repeat(reverse: true);
    
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // 延迟一帧，确保 UI 已经构建
      await Future.delayed(Duration.zero);
      
      setState(() => _status = t.splash.initializing);
      
      // 标记消息服务准备就绪
      setState(() => _status = t.splash.initializingMessageService);
      Get.find<MessageService>().markReady();
      
      // 可以在这里添加其他需要在UI就绪后初始化的操作
      setState(() => _status = t.splash.ready);
      
      // 导航到主页
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      LogUtils.e('启动页初始化失败', error: e);
      setState(() => _status = t.splash.errors.initializationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 应用图标带呼吸动画
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: child,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    CommonConstants.launcherIconPath,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 应用名称带 Shimmer 效果
              Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.primary,
                highlightColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  t.common.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // 加载指示器
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 状态文本带 Shimmer 效果
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                      highlightColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        _status,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 