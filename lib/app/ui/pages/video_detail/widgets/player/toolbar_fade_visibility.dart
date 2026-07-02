import 'package:flutter/material.dart';

/// 顶部/底部工具栏的淡入淡出显隐（替代原先的位移滑入滑出）。
///
/// 关键点：淡出后的工具栏仍留在原位，因此隐藏后（以及淡出进行中）必须放行
/// 指针事件，否则会变成一层看不见的点击拦截层——原先滑出屏幕外的方案天然
/// 没有这个问题。`ignoring` 随动画每帧更新，保证响应式。
class ToolbarFadeVisibility extends StatelessWidget {
  final AnimationController animation;
  final Widget child;

  const ToolbarFadeVisibility({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => IgnorePointer(
        ignoring:
            animation.status == AnimationStatus.reverse ||
            animation.value <= 0.0,
        child: child,
      ),
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}
