import 'package:flutter/material.dart';

/// 左右导航控制组件
class NavigationControls extends StatefulWidget {
  final double tapAreaWidth;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  const NavigationControls({
    super.key,
    required this.tapAreaWidth,
    this.onPrevious,
    this.onNext,
    this.canGoPrevious = true,
    this.canGoNext = true,
  });

  @override
  State<NavigationControls> createState() => _NavigationControlsState();
}

class _NavigationControlsState extends State<NavigationControls>
    with TickerProviderStateMixin {
  late AnimationController _leftSideAnimationController;
  late AnimationController _rightSideAnimationController;
  late Animation<double> _leftSideAnimation;
  late Animation<double> _rightSideAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _leftSideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rightSideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 创建动画
    _leftSideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _leftSideAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _rightSideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rightSideAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _leftSideAnimationController.dispose();
    _rightSideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 左侧导航区域（仅在可向前时渲染）
        if (widget.canGoPrevious)
          Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.tapAreaWidth,
          child: MouseRegion(
            onEnter: (_) {
              if (!_leftSideAnimationController.isAnimating &&
                  _leftSideAnimationController.value == 0.0) {
                _leftSideAnimationController.forward();
              }
              if (_rightSideAnimationController.value > 0.0) {
                _rightSideAnimationController.reverse();
              }
            },
            onExit: (_) {
              _leftSideAnimationController.reverse();
            },
            child: GestureDetector(
              onTapDown: (_) {
                _leftSideAnimationController.forward();
              },
              onTapUp: (_) {
                _leftSideAnimationController.reverse();
                if (widget.canGoPrevious) {
                  widget.onPrevious?.call();
                }
              },
              onTapCancel: () {
                _leftSideAnimationController.reverse();
              },
              child: Container(
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _leftSideAnimation,
                  builder: (context, child) {
                    if (_leftSideAnimation.value == 0.0) {
                      return const SizedBox.expand();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(
                              alpha: 0.3 * _leftSideAnimation.value,
                            ),
                            Colors.white.withValues(
                              alpha: 0.15 * _leftSideAnimation.value,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * _leftSideAnimation.value),
                          child: const Icon(
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // 右侧导航区域（仅在可向后时渲染）
        if (widget.canGoNext)
          Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: widget.tapAreaWidth,
          child: MouseRegion(
            onEnter: (_) {
              if (!_rightSideAnimationController.isAnimating &&
                  _rightSideAnimationController.value == 0.0) {
                _rightSideAnimationController.forward();
              }
              if (_leftSideAnimationController.value > 0.0) {
                _leftSideAnimationController.reverse();
              }
            },
            onExit: (_) {
              _rightSideAnimationController.reverse();
            },
            child: GestureDetector(
              onTapDown: (_) {
                _rightSideAnimationController.forward();
              },
              onTapUp: (_) {
                _rightSideAnimationController.reverse();
                if (widget.canGoNext) {
                  widget.onNext?.call();
                }
              },
              onTapCancel: () {
                _rightSideAnimationController.reverse();
              },
              child: Container(
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _rightSideAnimation,
                  builder: (context, child) {
                    if (_rightSideAnimation.value == 0.0) {
                      return const SizedBox.expand();
                    }
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.white.withValues(
                              alpha: 0.3 * _rightSideAnimation.value,
                            ),
                            Colors.white.withValues(
                              alpha: 0.15 * _rightSideAnimation.value,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * _rightSideAnimation.value),
                          child: const Icon(
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
