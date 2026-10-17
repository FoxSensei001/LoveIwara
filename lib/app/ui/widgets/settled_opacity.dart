import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 只在**半透明**时才合成的 [Opacity]。
///
/// # 为什么不直接用 Opacity / AnimatedOpacity
///
/// 现在的 Flutter 里 `RenderOpacity` / `RenderAnimatedOpacity` 只要 alpha > 0
/// 就是重绘边界，**不透明度 1.0 也照样推一个 `OpacityLayer`**。放在列表卡片里，
/// 一张卡就多出一两个合成层，而且这些层会把卡片外面那只 `ClipRRect` 也逼成
/// `ClipRRectLayer`。平板一屏 24 张卡实测是 ~100 个层，每帧滚动都要在
/// `compositeFrame` 里逐个 addToScene（2026-10-17 profile：占 UI 线程 18%）。
///
/// 这里退回早年的做法：
/// - alpha = 255：直接画子树，不推层、不是重绘边界；
/// - alpha = 0：不画；
/// - 其余：推 `OpacityLayer`。
///
/// 代价是淡入淡出的每一帧要重画到最近的重绘边界（通常是卡片本身）。所以只用
/// 在**平时停在 0 或 1、偶尔过渡几百毫秒**的地方；一直在动的透明度仍用
/// [FadeTransition]。
class SettledOpacity extends SingleChildRenderObjectWidget {
  const SettledOpacity({super.key, required this.opacity, super.child})
    : assert(opacity >= 0.0 && opacity <= 1.0);

  final double opacity;

  @override
  RenderSettledOpacity createRenderObject(BuildContext context) =>
      RenderSettledOpacity(opacity: opacity);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSettledOpacity renderObject,
  ) {
    renderObject.opacity = opacity;
  }
}

class RenderSettledOpacity extends RenderProxyBox {
  RenderSettledOpacity({double opacity = 1.0, RenderBox? child})
    : _alpha = ui.Color.getAlphaFromOpacity(opacity),
      super(child);

  int _alpha;

  bool get _translucent => _alpha != 0 && _alpha != 255;

  set opacity(double value) {
    final int alpha = ui.Color.getAlphaFromOpacity(value);
    if (alpha == _alpha) return;
    final bool didNeedCompositing = alwaysNeedsCompositing;
    final bool wasVisible = _alpha != 0;
    _alpha = alpha;
    if (didNeedCompositing != alwaysNeedsCompositing) {
      markNeedsCompositingBitsUpdate();
    }
    markNeedsPaint();
    if (wasVisible != (_alpha != 0)) markNeedsSemanticsUpdate();
  }

  @override
  bool get alwaysNeedsCompositing => child != null && _translucent;

  @override
  bool paintsChild(RenderBox child) => _alpha != 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null || _alpha == 0) {
      layer = null;
      return;
    }
    if (_alpha == 255) {
      layer = null;
      context.paintChild(child, offset);
      return;
    }
    layer = context.pushOpacity(
      offset,
      _alpha,
      super.paint,
      oldLayer: layer as OpacityLayer?,
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null && _alpha != 0) visitor(child!);
  }
}
