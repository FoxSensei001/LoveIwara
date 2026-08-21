import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 真·液态玻璃后端（`liquid_glass_easy`）的接线层。
///
/// # 为什么是「一个开关」而不是「全局替换」
///
/// 全 App 的玻璃材质只有一个定义处——[GlassSurface]。把它整只换成折射透镜，
/// 46 处调用点会在同一个 commit 里全部变样，没法一处一处按真机效果收敛；而且
/// 折射透镜有两条硬约束（见 `docs/liquid_glass_easy.md`）：
///
///   1. **一块 lens = 一次 backdrop 采样**。header 上三只胶囊就是三次。
///   2. **lens 不该放进滚动容器**：Android 的拉伸回弹会把滚动内容隔离进独立
///      合成层，lens 在两端会渲染成纯黑。
///
/// 所以材质的选择权交给页面：把要液态化的那一块用 [LiquidGlassScope] 包起来，
/// 子树里所有 [GlassSurface] 自动换成折射透镜，其余地方保持传统档不动。
/// 铺开的过程就是「多包几处 scope」，不是「再改一次材质」。
///
/// # 包哪里
///
/// 只包**浮在内容之上的那层 chrome**：header 行、浮动底栏、浮钮、底部动作坞。
/// 不要包列表本体（约束 2）——`GlassHeaderOverlay.liquid` 已经替你把 `body`
/// 单独关回传统档了。
///
/// # ⚠️ 待真机确认：`Opacity` 会把折射打断
///
/// lens 靠 backdrop 采样吃身后的像素，而 `Opacity`（0 < α < 1 时）会 `saveLayer`
/// 把子树隔离出去——层内没有背景，玻璃在淡入淡出的那两百毫秒里可能变黑/变空。
/// α == 1 时 `RenderOpacity` 根本不建层，所以**静止态是好的，风险只在过渡中**。
///
/// 目前踩在这条线上的有两处：回顶浮钮的 `AnimatedOpacity`、
/// [GlassSelectionDock] 的 `Opacity`。真机上如果真闪，就地把这两处的透明度动画
/// 换掉（例如改成两只 lens 交叉、或用 `visibility` 硬切配位移），别把整片
/// chrome 退回传统档——静止态占了 99% 的时间。
class LiquidGlassScope extends InheritedWidget {
  const LiquidGlassScope({
    super.key,
    this.enabled = true,
    required super.child,
  });

  /// 本子树的玻璃是否走折射透镜。传 false 可以在液态子树里**局部关掉**
  /// （例如某处确实要塞进滚动容器）。
  final bool enabled;

  /// 当前位置的玻璃该用哪套后端。没有祖先 scope 时返回 false（传统档）。
  static bool isEnabled(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<LiquidGlassScope>();
    return scope?.enabled ?? false;
  }

  @override
  bool updateShouldNotify(LiquidGlassScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// 折射透镜版的玻璃体：[GlassSurface] 在液态档下画的就是这个。
///
/// 尺寸语义与传统档的 `AnimatedContainer` 完全一致（[height] 紧约束、[width]
/// 为 null 时按内容收缩、[circle] 取正方），所以两档之间切换不会动布局。
///
/// 有三件事是 lens 自己做掉的、这里不再重复：
///   - **裁切**：lens 会按自身形状裁 child，传统档的 `clipContent` 在这里恒成立。
///   - **描边**：shader 画的边缘光带，不再有 `Border.all` 那 0.6px 的内缩。
///   - **投影**：走 `appearance.shadow`，它长在形变盒内，按下会跟着一起动。
class LiquidGlassBox extends StatelessWidget {
  const LiquidGlassBox({
    super.key,
    required this.child,
    this.height = GlassTokens.pillHeight,
    this.width,
    this.circle = false,
    this.cornerRadius,
    this.pressed = false,
    this.elevated = true,
  });

  final Widget child;
  final double height;
  final double? width;
  final bool circle;

  /// 圆角半径；为 null 时取 [height] / 2（即胶囊）。[circle] 为真时忽略。
  final double? cornerRadius;

  final bool pressed;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double radius = circle ? height / 2 : (cornerRadius ?? height / 2);

    // 正圆用 roundedRectangle（圆弧角，半径=半高时就是正圆，也最省）；
    // 胶囊 / 圆角矩形用 continuousRoundedRectangle——半径拉满时它退化成
    // Apple 那种「肩部平滑过渡」的胶囊，比纯圆弧角更贴 iOS 观感。
    final LiquidGlassCornerStyle cornerStyle = circle
        ? LiquidGlassCornerStyle.roundedRectangle
        : LiquidGlassCornerStyle.continuousRoundedRectangle;

    // 按下的底色变化要和传统档同一段过渡（pressDuration / easeOut）。
    // lens 没有 AnimatedContainer 那样的隐式插值，这里自己插。
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: pressed
            ? GlassTokens.liquidPressedTint(cs)
            : GlassTokens.liquidTint(cs),
      ),
      duration: GlassTokens.pressDuration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, tint, child) {
        return SizedBox(
          height: height,
          width: circle ? height : width,
          child: LiquidGlassLens(
            style: LiquidGlassStyle(
              shape: LiquidGlassShape(
                cornerStyle: cornerStyle,
                cornerRadius: radius,
                borderWidth: GlassTokens.liquidBorderWidth,
                borderType: GlassTokens.liquidBorderType,
              ),
              appearance: LiquidGlassAppearance(
                color: tint ?? GlassTokens.liquidTint(cs),
                blur: GlassTokens.liquidBlur,
                saturation: GlassTokens.liquidSaturation,
                shadow: elevated ? GlassTokens.liquidShadow(cs) : null,
              ),
              refraction: GlassTokens.liquidRefraction,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// 预热 shader。
///
/// lens 的 shader 是**异步加载**的：没加载完之前，全 App 第一块玻璃会先渲染成
/// 磨砂（`BackdropFilter` + 色调），加载完再 `setState` 切成折射。不预热的话
/// 用户在冷启动首屏就能看见这一下材质跳变。放在启动流程里 fire-and-forget 即可，
/// 失败了也只是退回磨砂，不该阻塞启动。
Future<void> warmUpLiquidGlassShaders() async {
  try {
    await LiquidGlassShaders.ensureLoaded();
  } catch (_) {
    // shader 不可用（构建损坏 / 不支持的环境）：玻璃停在磨砂档，功能不受影响。
  }
}
