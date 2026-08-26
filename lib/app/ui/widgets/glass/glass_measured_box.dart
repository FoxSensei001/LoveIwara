import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 把子树布局后的**真实尺寸**回报出来（布局期取值，帧末回调）。
///
/// 用来干掉「在文件顶部手写常数去猜 header 有多高」这件事。猜错了没有任何
/// 信号——玻璃输入框实测 48 而不是 44（`prefixIcon` 的 48 点击区顶着），
/// 带副标题的抽屉标题行实测仍是 44（标题 28 + 副标题 16 正好填满）——
/// 结果就是列表要么顶在控件底缘上（[GlassPickerDialog] 那四张弹窗的报障），
/// 要么白多出一截。量出来就不会错，字号放大 / 加减一行也自动跟上。
class GlassMeasuredBox extends SingleChildRenderObjectWidget {
  const GlassMeasuredBox({
    super.key,
    required this.onSize,
    required super.child,
  });

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderGlassMeasuredBox(onSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderGlassMeasuredBox).onSize = onSize;
  }
}

class _RenderGlassMeasuredBox extends RenderProxyBox {
  _RenderGlassMeasuredBox(this.onSize);

  ValueChanged<Size> onSize;
  Size? _lastReported;

  @override
  void performLayout() {
    super.performLayout();
    if (_lastReported == size) return;
    _lastReported = size;
    final Size measured = size;
    // 布局中途不能 setState，推到帧末回报。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!attached) return;
      onSize(measured);
    });
  }
}
