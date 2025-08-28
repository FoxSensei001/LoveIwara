import 'dart:math' as math;
import 'package:flutter/material.dart';

class PlaybackSpeedAnimationWidget extends StatefulWidget {
  final double playbackSpeed;
  final bool isVisible;

  const PlaybackSpeedAnimationWidget({
    super.key,
    required this.playbackSpeed,
    required this.isVisible,
  });

  @override
  State<PlaybackSpeedAnimationWidget> createState() => _PlaybackSpeedAnimationWidgetState();
}

class _PlaybackSpeedAnimationWidgetState extends State<PlaybackSpeedAnimationWidget>
    with TickerProviderStateMixin {
  static const double _kHeight = 32;
  static const double _kHorizontalPadding = 12.0;

  late AnimationController _visibilityController;
  late AnimationController _loopController;
  late AnimationController _bumpController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bumpScaleAnimation;

  bool _shouldDisplay = false;

  // Material You 风格：不使用背景填充与霓虹渐变，仅保留描边与轻微动效

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _visibilityController, curve: Curves.easeOutBack),
    );

    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _bumpScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bumpController, curve: Curves.easeOutCubic),
    );

    if (widget.isVisible) {
      _shouldDisplay = true;
      _visibilityController.forward();
      _updateLoopSpeed();
      _loopController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlaybackSpeedAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible && !oldWidget.isVisible) {
      setState(() => _shouldDisplay = true);
      _visibilityController.forward(from: 0);
      _updateLoopSpeed();
      _loopController.repeat();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _visibilityController.reverse().whenComplete(() {
        if (!mounted) return;
        setState(() => _shouldDisplay = false);
        _loopController.stop();
        _loopController.reset();
      });
    }

    if (widget.playbackSpeed != oldWidget.playbackSpeed) {
      _bumpController.forward(from: 0).whenComplete(_bumpController.reverse);
      _updateLoopSpeed();
      if (_loopController.isAnimating) {
        _loopController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    _loopController.dispose();
    _bumpController.dispose();
    super.dispose();
  }

  void _updateLoopSpeed() {
    // 根据倍速轻微加速“速度线”滚动，范围限定避免过快
    final clamped = widget.playbackSpeed.clamp(0.5, 3.0);
    final baseMs = 1400.0;
    final ms = (baseMs / clamped).clamp(500.0, 2000.0);
    _loopController.duration = Duration(milliseconds: ms.round());
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldDisplay) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return IgnorePointer(
      ignoring: true,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: Colors.black54,
              shape: StadiumBorder(
                side: BorderSide(
                  color: cs.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Container(
              height: _kHeight,
              padding: const EdgeInsets.symmetric(horizontal: _kHorizontalPadding),
              // 无背景填充，保持透明
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ArrowFlow(
                    progress: _loopController,
                    color: Colors.white,
                    count: 3,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _loopController,
                    builder: (context, child) {
                      final angle = math.sin(_loopController.value * 2 * math.pi) * 0.06;
                      return Transform.rotate(angle: angle, child: child);
                    },
                    child: Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ScaleTransition(
                    scale: _bumpScaleAnimation,
                    child: Text(
                      '×${_formatSpeed(widget.playbackSpeed)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ) ?? TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatSpeed(double speed) {
    if ((speed % 1).abs() < 1e-6) {
      return speed.toStringAsFixed(0);
    }
    // 一位小数更符合 UI 的简洁风格
    return speed.toStringAsFixed(1);
  }
}

class _ArrowFlow extends StatelessWidget {
  final Animation<double> progress;
  final Color color;
  final int count;
  final double size;

  const _ArrowFlow({
    required this.progress,
    required this.color,
    this.count = 3,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final widgets = <Widget>[];
        for (int i = 0; i < count; i++) {
          final phase = (progress.value + i / count) % 1.0;
          final wave = 0.5 + 0.5 * math.sin(phase * 2 * math.pi);
          final opacity = 0.25 + 0.75 * wave; // 0.25~1.0
          widgets.add(Icon(
            Icons.chevron_right_rounded,
            size: size,
            color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
          ));
          if (i < count - 1) widgets.add(const SizedBox(width: 2));
        }
        return Row(mainAxisSize: MainAxisSize.min, children: widgets);
      },
    );
  }
}

