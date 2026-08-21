import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 屏幕顶部 / 底部的「渐进蒙层」。
///
/// 用一条从边缘向内容区衰减的纯色渐变代替实色栏：靠屏幕边缘保持 [peakAlpha]
/// 的不透明度（保证状态栏 / 手势条可读），越靠近内容越透明，列表滚到它
/// 下面会自然「溶」进边缘。不使用 BackdropFilter。
///
/// 曲线：[0, solidExtent] 为平台段（恒为 peakAlpha），之后用 smoothstep
/// （两端斜率为 0 的 S 曲线）衰减到 0，并细分成多段 stop —— 线性分段会在
/// 拐点处出现肉眼可见的「台阶」，这里有意避免。
class EdgeFadeScrim extends StatelessWidget {
  const EdgeFadeScrim.top({
    super.key,
    required this.height,
    required this.solidExtent,
    this.peakAlpha = 0.72,
  }) : _isTop = true;

  const EdgeFadeScrim.bottom({
    super.key,
    required this.height,
    required this.solidExtent,
    this.peakAlpha = 0.72,
  }) : _isTop = false;

  final double height;
  final double solidExtent;
  final double peakAlpha;
  final bool _isTop;

  static const int _segments = 16;

  static double _smoothstep(double u) => u * u * (3 - 2 * u);

  /// 生成 (stops, alphas)。
  static (List<double>, List<double>) buildCurve({
    required double height,
    required double solidExtent,
    required double peakAlpha,
  }) {
    final double plateau = height <= 0
        ? 0.0
        : (solidExtent / height).clamp(0.0, 0.95);
    final stops = <double>[];
    final alphas = <double>[];
    for (var i = 0; i <= _segments; i++) {
      final t = i / _segments;
      double a;
      if (t <= plateau) {
        a = peakAlpha;
      } else {
        final u = ((t - plateau) / (1 - plateau)).clamp(0.0, 1.0);
        a = peakAlpha * (1 - _smoothstep(u));
      }
      stops.add(t);
      alphas.add(a);
    }
    return (stops, alphas);
  }

  @override
  Widget build(BuildContext context) {
    if (height <= 0) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final base = GlassTokens.scrimBase(cs);
    final (stops, alphas) = buildCurve(
      height: height,
      solidExtent: solidExtent,
      peakAlpha: peakAlpha,
    );

    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _isTop ? Alignment.topCenter : Alignment.bottomCenter,
              end: _isTop ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [for (final a in alphas) base.withValues(alpha: a)],
              stops: stops,
            ),
          ),
        ),
      ),
    );
  }
}
