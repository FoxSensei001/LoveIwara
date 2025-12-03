import 'package:flutter/material.dart';

/// 左右导航控制组件（仅负责显示左右渐变与箭头，不再拦截手势）
class NavigationControls extends StatelessWidget {
  final double tapAreaWidth;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool showOverlay;

  const NavigationControls({
    super.key,
    required this.tapAreaWidth,
    required this.showOverlay,
    this.canGoPrevious = true,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    // 不需要显示时直接不渲染
    if (!showOverlay || (!canGoPrevious && !canGoNext)) {
      return const SizedBox.shrink();
    }

    // 使用 IgnorePointer 确保不拦截任何指针事件，仅作视觉提示
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          // 左侧导航区域（仅在可向前时渲染）
          if (canGoPrevious)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: tapAreaWidth,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 32,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 右侧导航区域（仅在可向后时渲染）
          if (canGoNext)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: tapAreaWidth,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 32,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
