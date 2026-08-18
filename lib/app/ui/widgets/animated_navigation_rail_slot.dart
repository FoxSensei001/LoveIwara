import 'package:flutter/material.dart';

bool shouldShowWideNavigationRail(double maxWidth, {required bool enabled}) {
  return maxWidth > 600 && enabled;
}

/// Keeps a navigation rail mounted while its leading-edge slot animates.
class AnimatedNavigationRailSlot extends StatefulWidget {
  static const Duration motionDuration = Duration(milliseconds: 240);
  static const Duration reverseMotionDuration = Duration(milliseconds: 200);
  static const Duration reducedMotionDuration = Duration(milliseconds: 120);

  final bool visible;
  final bool reduceMotion;
  final double width;
  final VoidCallback? onFocusExitRequested;
  final Widget child;

  const AnimatedNavigationRailSlot({
    super.key,
    required this.visible,
    required this.reduceMotion,
    required this.width,
    required this.child,
    this.onFocusExitRequested,
  });

  @override
  State<AnimatedNavigationRailSlot> createState() =>
      _AnimatedNavigationRailSlotState();
}

class _AnimatedNavigationRailSlotState extends State<AnimatedNavigationRailSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _motion;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final FocusScopeNode _focusScopeNode;

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScopeNode(debugLabel: 'Wide navigation rail');
    _controller = AnimationController(
      vsync: this,
      duration: _forwardDuration,
      reverseDuration: _reverseDuration,
      value: widget.visible ? 1 : 0,
    );
    _motion = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      // The controller runs backwards, so this produces a perceived ease-out.
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.75, curve: Curves.easeOutCubic),
      reverseCurve: const Interval(0.25, 1, curve: Curves.easeInCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(_motion);
  }

  Duration get _forwardDuration => widget.reduceMotion
      ? AnimatedNavigationRailSlot.reducedMotionDuration
      : AnimatedNavigationRailSlot.motionDuration;

  Duration get _reverseDuration => widget.reduceMotion
      ? AnimatedNavigationRailSlot.reducedMotionDuration
      : AnimatedNavigationRailSlot.reverseMotionDuration;

  @override
  void didUpdateWidget(covariant AnimatedNavigationRailSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller
      ..duration = _forwardDuration
      ..reverseDuration = _reverseDuration;

    if (oldWidget.visible && !widget.visible && _focusScopeNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final onFocusExitRequested = widget.onFocusExitRequested;
        if (onFocusExitRequested != null) {
          onFocusExitRequested();
        } else {
          _focusScopeNode.unfocus();
        }
      });
    }

    if (oldWidget.visible != widget.visible ||
        oldWidget.reduceMotion != widget.reduceMotion) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: FocusScope(
        node: _focusScopeNode,
        canRequestFocus: widget.visible,
        descendantsAreFocusable: widget.visible,
        descendantsAreTraversable: widget.visible,
        child: widget.child,
      ),
      builder: (context, child) {
        final slotFactor = widget.reduceMotion
            ? (widget.visible || _controller.value > 0 ? 1.0 : 0.0)
            : _motion.value;
        final slide = widget.reduceMotion ? Offset.zero : _slide.value;

        return ClipRect(
          child: SizeTransition(
            axis: Axis.horizontal,
            alignment: Alignment.centerLeft,
            sizeFactor: AlwaysStoppedAnimation(slotFactor),
            child: SizedBox(
              width: widget.width,
              child: IgnorePointer(
                ignoring: !widget.visible,
                child: ExcludeSemantics(
                  excluding: !widget.visible,
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(_opacity.value),
                    child: SlideTransition(
                      position: AlwaysStoppedAnimation(slide),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
