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
/// # ⚠️ `Opacity` 会把折射打断（已被真机实锤）
///
/// lens 靠 backdrop 采样吃身后的像素，而 `Opacity`（0 < α < 1 时）会 `saveLayer`
/// 把子树隔离出去——层内没有背景，玻璃在淡入淡出的那两百毫秒里基本是空的。
/// α == 1 时 `RenderOpacity` 根本不建层，所以**静止态是好的，问题只在过渡中**：
/// 读起来就是「**里面的文字先出现，液态玻璃背景才后到**」——玻璃是在动画跑完、
/// 透明度层被撤掉的那一刻才「啪」地补上的。玻璃菜单（`showGlassMenu`）此前
/// 用 `FadeTransition` 做出入场，正是栽在这条上，已改成不含任何透明度层的
/// 「卷开」式出入场。
///
/// 所以：**玻璃自己的淡入淡出一律走 `GlassSurface.materialize`**（压材质自身的
/// 色调 / 描边 / 投影透明度，图层结构全程不变），不要拿 `Opacity` /
/// `AnimatedOpacity` / `FadeTransition` 去包一块玻璃。
///
/// 目前还踩在这条线上、尚未改的有两处：回顶浮钮的 `AnimatedOpacity`、
/// [GlassSelectionDock] 的 `Opacity`。它们的显隐都带位移，闪的那一下不如菜单
/// 明显，改法是一样的（换 `materialize`）。
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
    this.touchFlex = false,
    this.materialize = 1.0,
  });

  final Widget child;

  /// 为 null 表示按内容自适应高度（见 [GlassSurface.height]）。
  final double? height;

  final double? width;
  final bool circle;

  /// 圆角半径；为 null 时取 [height] / 2（即胶囊）。[circle] 为真时忽略。
  final double? cornerRadius;

  final bool pressed;
  final bool elevated;

  /// 是否接入 [GlassTokens.liquidFlex]——按住并拖动时玻璃跟手拉伸/回弹
  /// （liquid_glass_easy 的 `LiquidGlassTouch`），而不只是 [GlassPressable]
  /// 那层 0.96 缩放。默认 false：`touch` 传 null 时 lens 完全零成本
  /// （不建 `Listener`、不建 ticker），不该让每块玻璃都白白挂上手势监听。
  ///
  /// ⚠️ 只能用在**尺寸已经钉死**的调用点（[height] / [width] 都非 null，
  /// 或 [circle] 给了 [height]）。一旦 `touch` 非 null，lens 会拿收到的
  /// `constraints.biggest` 当形变的 rest size 并自己 `SizedBox.fromSize`——
  /// "抱内容"的玻璃（[height] 或 [width] 为 null，靠父级松/无界约束撑开）
  /// 直接开这个要么被撑满可用空间、要么在无界约束里静默不生效
  /// （见 docs/liquid_glass_easy.md 第 8 节）。
  final bool touchFlex;

  /// 材质的「在场程度」，见 [GlassSurface.materialize]。
  ///
  /// 压的是**色调与投影的透明度**，blur / 描边 / 折射一概不动：那几项一旦被
  /// 压到 0，lens 内部会切换图层结构（blur 层的建与拆），过渡中反而会闪一下。
  /// 所以 0 这一端不是「什么都没有」，而是「一块没有色调、只剩折射与边缘光的
  /// 清玻璃」——用来做几十到一两百毫秒的材质淡入足够，不要拿它当显隐开关。
  final double materialize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double m = materialize.clamp(0.0, 1.0);
    final double radius = circle
        ? height! / 2
        : (cornerRadius ?? (height ?? GlassTokens.pillHeight) / 2);

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
        // materialize 在 tween **之后**再压一次 alpha：直接把它算进 tween 的
        // end 会让 TweenAnimationBuilder 每帧都被当成「目标变了」而重启，
        // 120ms 的按压过渡反过来把材质淡入拖成一条追不上的尾巴。
        final Color base = tint ?? GlassTokens.liquidTint(cs);
        final Color color = m >= 1
            ? base
            : base.withValues(alpha: base.a * m);
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
                color: color,
                blur: GlassTokens.liquidBlur,
                saturation: GlassTokens.liquidSaturation,
                shadow: elevated
                    ? GlassTokens.liquidShadow(cs, alphaScale: m)
                    : null,
              ),
              refraction: GlassTokens.liquidRefraction,
            ),
            touch: touchFlex ? GlassTokens.liquidFlex : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// 给「抱内容、宽度会随外部状态过渡」的液态玻璃接入跟手形变，同时避开
/// [LiquidGlassBox.touchFlex] 的钉死尺寸要求。
///
/// touch 需要一个已经量出来的精确尺寸；但像 [GlassButtonGroup] 这样的胶囊，
/// 宽度会在按钮增删时经历一轮自己的过渡动画（[GlassGroupSlot] 的收放 +
/// 外壳的 `AnimatedSize`，两套时序还刻意错开半拍，见 `glass_morph.dart`），
/// 没法用一个公式实时算出"此刻正确的宽度"去跟手。
///
/// 这里换一个策略：**只在静止态开 touch**。[signature] 变化的瞬间立刻退回
/// [builder] 的自然布局（`lockedSize: null`，与不套这层包装时完全一致，
/// 过渡过程不会有任何尺寸错位）；等过渡大概率已经跑完（[settleDelay]，
/// 默认盖过按钮组胶囊里最长的那段动效再留一点余量）且期间没有新的
/// [signature] 变化，才量一次真实尺寸、钉死喂给 [builder]。
class LiquidGlassSettledTouch extends StatefulWidget {
  const LiquidGlassSettledTouch({
    super.key,
    required this.signature,
    required this.builder,
    this.settleDelay = const Duration(milliseconds: 420),
  });

  /// 影响内容宽高的外部状态摘要（例如 `'$isWide|$isMultiSelect'`）；
  /// 与上一次不 `==` 就视为「要重新经历一轮过渡」。
  final Object signature;

  /// `lockedSize` 为 null 表示还没到静止态（或刚开始一轮新过渡）；
  /// 非 null 时是量出来的精确尺寸，这时 [builder] 才应该开 touch。
  final Widget Function(BuildContext context, Size? lockedSize) builder;

  final Duration settleDelay;

  @override
  State<LiquidGlassSettledTouch> createState() =>
      _LiquidGlassSettledTouchState();
}

class _LiquidGlassSettledTouchState extends State<LiquidGlassSettledTouch> {
  final GlobalKey _contentKey = GlobalKey();
  Size? _lockedSize;
  int _settleToken = 0;

  @override
  void initState() {
    super.initState();
    _scheduleSettle();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSettledTouch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signature != widget.signature) {
      setState(() => _lockedSize = null);
      _scheduleSettle();
    }
  }

  void _scheduleSettle() {
    final int token = ++_settleToken;
    Future<void>.delayed(widget.settleDelay, () {
      if (!mounted || token != _settleToken) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || token != _settleToken) return;
        final renderObject = _contentKey.currentContext?.findRenderObject();
        if (renderObject is! RenderBox || !renderObject.hasSize) return;
        setState(() => _lockedSize = renderObject.size);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _contentKey,
      child: widget.builder(context, _lockedSize),
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
