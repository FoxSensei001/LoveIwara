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
///
/// # 平台段只盖「必须恒定可读」的那一截
///
/// 顶部蒙层请一律用 [EdgeFadeScrim.headerOverlay]，别自己拼
/// `height: headerExtent + 一个小常数, solidExtent: headerExtent`：那样平台段
/// 占掉整条蒙层的八成，header 里每一行的不透明度完全一样，渐变只发生在 header
/// 之外那十几像素里——观感就是「标题和内容之间硬切了一刀」，而不是过渡
/// （2026-08-26 用户报障的四张选择器弹窗全是这么写的）。平台段应当只盖状态栏
/// （页面）或标题行（弹窗），header 剩下的高度是淡出的一部分。
class EdgeFadeScrim extends StatelessWidget {
  const EdgeFadeScrim.top({
    super.key,
    required this.height,
    required this.solidExtent,
    this.peakAlpha = 0.72,
  }) : _isTop = true,
       assert(
         solidExtent <= height * 0.6,
         '顶部蒙层的平台段超过总高的六成：渐变会被压成一条硬边。'
         '平台段只盖状态栏 / 标题行，用 EdgeFadeScrim.headerOverlay 算高度。',
       );

  /// 浮层 header 的蒙层：只给「header 总高」与「平台段」，尾巴按
  /// [GlassTokens.scrimFadeTail] 的标定比例算，页面 / 弹窗共用同一条曲线。
  ///
  /// - [headerExtent]：从区域顶部到 header 最后一行底缘的距离（列表让位的高度）。
  /// - [plateauExtent]：恒定不透明的那一截——页面传状态栏高度，弹窗传标题行高度。
  ///
  /// 蒙层实际高度（列表若要「完全避开」渐变才需要用到）见 [overlayHeight]。
  EdgeFadeScrim.headerOverlay({
    super.key,
    required double headerExtent,
    required double plateauExtent,
    this.peakAlpha = 0.72,
  }) : height = overlayHeight(
         headerExtent: headerExtent,
         plateauExtent: plateauExtent,
       ),
       solidExtent = plateauExtent,
       _isTop = true;

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

  /// [EdgeFadeScrim.headerOverlay] 的总高 = header 高 + 按比例算出的尾巴。
  static double overlayHeight({
    required double headerExtent,
    required double plateauExtent,
  }) => headerExtent + GlassTokens.scrimFadeTail(headerExtent - plateauExtent);

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
