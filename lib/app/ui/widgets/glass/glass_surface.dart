import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 按下反馈：缩放 + 对外暴露 pressed 状态。
///
/// 所有玻璃按钮共用这一套手感：按下 0.96 缩放、120ms；松开 / 取消还原。
class GlassPressable extends StatefulWidget {
  const GlassPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scale = GlassTokens.pressedScale,
    this.tapHandledDeeper = false,
  });

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scale;

  /// [onTap] 的**真正触发点在更深处**，这层不要再注册自己的 tap 识别器。
  ///
  /// 用在 [GlassSurface] 的 liquidWidgets + [GlassSurface.liquidTouch] 那条路上：
  /// 形变层自带的 `GestureDetector` 比这层深，竞技场上稳赢，这层注册也是白注册
  /// （详见 [GlassSurface] 里 `tapInsideLiquidBox` 那段）。
  ///
  /// 置真后这层只剩两件事：
  ///   - **画按下反馈**——改用不进竞技场的 `Listener` 追踪按下状态。
  ///     继续用 `GestureDetector` 的话，`onTapDown` 要等 100ms 的 deadline 才来、
  ///     随后还会因判负回滚成 `onTapCancel`，快速点按几乎看不到反馈。
  ///   - **对无障碍暴露「这是个按钮」**——[onTap] 仍会挂到 `Semantics.onTap`
  ///     上（读屏的「激活」走这条），形变层那边则关掉语义避免出现两个节点。
  final bool tapHandledDeeper;

  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v || !mounted) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final interactive =
        widget.enabled && (widget.onTap != null || widget.onLongPress != null);
    final Widget scaled = AnimatedScale(
      scale: _pressed ? widget.scale : 1.0,
      duration: GlassTokens.pressDuration,
      curve: Curves.easeOut,
      child: widget.builder(context, _pressed),
    );

    if (interactive && widget.tapHandledDeeper) {
      Widget result = scaled;
      // 长按没有「更深的一层」接管，仍旧走识别器：它在 500ms 时自己宣布胜利，
      // 能把里头那只 tap 挤掉。
      if (widget.onLongPress != null) {
        result = GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: widget.onLongPress,
          child: result,
        );
      }
      return Semantics(
        button: true,
        onTap: widget.onTap,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _setPressed(true),
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: result,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: interactive ? widget.onTap : null,
      onLongPress: interactive ? widget.onLongPress : null,
      child: scaled,
    );
  }
}

/// 玻璃体容器：胶囊或圆形，是全 App **唯一**的玻璃材质定义处。
///
/// 材质有**三套后端**，由所处子树里的 `LiquidGlassScope` 决定（见
/// `liquid_glass_material.dart` 的 [GlassBackend]）：
///   - [GlassBackend.plain]（默认）：半透明底色 + 细描边 + 柔和投影，
///     无 BackdropFilter，零 shader 成本。
///   - [GlassBackend.easyLens]：`liquid_glass_easy` 的真折射透镜
///     （[LiquidGlassBox]）。玻璃菜单钉死在这一档。
///   - [GlassBackend.liquidWidgets]：`liquid_glass_widgets` 的 `AdaptiveGlass`
///     （[LiquidWidgetsGlassBox]）。页面 chrome 现在走这一档。
///
/// 三档**尺寸语义完全一致**，只换材质——换档不会动布局。
///
/// 传 [onTap] 时整体可按（带缩放与底色加深）；不传时只做容器，
/// 由子组件各自处理点击（例如 [GlassButtonGroup]）。
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.height = GlassTokens.pillHeight,
    this.width,
    this.padding = EdgeInsets.zero,
    this.circle = false,
    this.borderRadius,
    this.tooltip,
    this.elevated = true,
    this.clipContent = false,
    this.liquidTouch = true,
    this.materialize = 1.0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 玻璃体高度。传 null 表示**按内容自适应**（菜单面板一类高度不定的玻璃），
  /// 这时 [borderRadius] 必须显式给出——没有高度就推不出胶囊半径。
  /// [circle] 为真时不可为 null。
  final double? height;

  final double? width;
  final EdgeInsetsGeometry padding;
  final bool circle;
  final BorderRadius? borderRadius;
  final String? tooltip;
  final bool elevated;
  final bool clipContent;

  /// 液态档下是否接入交互形变（按住并拖动时整只玻璃跟着手指走、松手弹回）。
  /// 传统档忽略此项。
  ///
  /// **默认开**。2026-08-23 从 opt-in 翻成 opt-out：跟手形变是这套材质的基本
  /// 手感之一，「一块玻璃按下去会不会动」不该由每个调用点各自决定——用户在
  /// 订阅页 header 上按住下拉钮没反应、按住旁边的按钮组却会蠕动，读起来就是
  /// 「有的是玻璃，有的是塑料」。只有确实不该动的地方才显式关掉。
  ///
  /// 两个液态档的实现不一样，**别混着记**：
  ///   - [GlassBackend.liquidWidgets]（当前 chrome 档）：借
  ///     `GlassButton.custom(transparent)` 的 `LiquidStretch`，**没有尺寸要求**，
  ///     抱内容的玻璃也能开。
  ///   - [GlassBackend.easyLens]：接的是 lens 的 `touch`，**要求 [height] /
  ///     [width] 已经是钉死尺寸**（见 [LiquidGlassBox.touchFlex]）。抱内容的
  ///     玻璃在这一档下会被本组件**自动降级为不开**——默认开了之后不能再指望
  ///     每个调用点自己守这条约束，否则玻璃会被撑满可用空间。
  final bool liquidTouch;

  /// 材质的「在场程度」：0 = 玻璃还没长出来，1 = 正常。
  ///
  /// **玻璃自己的淡入淡出必须走这里，不能用 `Opacity` 包一层**：α∈(0,1) 时
  /// `RenderOpacity` 会 `saveLayer` 把子树隔离出去，液态档的 lens 靠 backdrop
  /// 采样吃身后的像素，隔离之后层里什么都没有——读起来就是「内容先出现、
  /// 玻璃背景后到」（详见 `liquid_glass_material.dart` 顶部那段实锤）。
  /// 这里压的是**材质自身**的透明度（底色 / 描边 / 投影），图层结构全程不变，
  /// 折射一帧都不会断。
  ///
  /// 两档的 0 端不完全一样：传统档是彻底透明，液态档还留着折射与边缘光
  /// （见 [LiquidGlassBox.materialize]）。它是给几十到一两百毫秒的**材质淡入**
  /// 用的，不是显隐开关——真要藏起来请让调用方别建这块玻璃。
  final double materialize;

  @override
  Widget build(BuildContext context) {
    assert(
      !circle || height != null,
      'GlassSurface(circle: true) 必须给 height——圆的直径就是它。',
    );
    assert(
      height != null || borderRadius != null,
      'GlassSurface(height: null) 必须给 borderRadius——没有高度推不出胶囊半径。',
    );
    final cs = Theme.of(context).colorScheme;
    final double m = materialize.clamp(0.0, 1.0);
    final radius =
        borderRadius ??
        BorderRadius.circular((height ?? GlassTokens.pillHeight) / 2);
    final GlassBackend backend = LiquidGlassScope.of(context);

    // easy 档的 touch 要求尺寸已经钉死（见 [LiquidGlassBox.touchFlex]）：抱内容
    // 的玻璃开了它要么被撑满可用空间、要么在无界约束里静默失效。[liquidTouch]
    // 默认开之后不能再指望每个调用点自己守这条，所以这里自己判——钉不死就降级
    // 成不开。widgets 档没有这条约束。
    final bool effectiveLiquidTouch =
        liquidTouch &&
        (backend != GlassBackend.easyLens ||
            (height != null && (circle || width != null)));

    // ⛔ liquidWidgets 档的跟手形变是**借** `GlassButton` 实现的，而它自带一层
    // `onTap` 必填的 `GestureDetector`——在命中路径上比下面那层 [GlassPressable]
    // 更深，竞技场上稳赢。所以「整只玻璃可按 + [liquidTouch]」时，点击必须交给
    // 盒子内部发出去（[LiquidWidgetsGlassBox.onTap]），外层只留按下反馈与语义。
    //
    // 2026-08-23 真机报的「热门视频页 header 头像点不开全局抽屉」就是这一条：
    // 身份圆钮是全站唯一同时给了 [onTap] 和 [liquidTouch] 的调用点，改档之后
    // 那一下点击被形变层的空实现整只吃掉。把键放在胶囊**里头**的写法
    // （[GlassButtonGroup]）不受影响——各键自己更深，照样赢得过形变层。
    final bool tapInsideLiquidBox =
        onTap != null &&
        effectiveLiquidTouch &&
        backend == GlassBackend.liquidWidgets;

    Color dim(Color c) => m >= 1 ? c : c.withValues(alpha: c.a * m);

    Widget buildBox(bool pressed) {
      Widget content = Padding(padding: padding, child: child);
      // 两个液态档的裁切都由 shader 自己按形状做掉，这里不再套
      // ClipOval/ClipRRect（多一层裁剪只会多一个 saveLayer，形状还未必对得上
      // shader 的角）。
      switch (backend) {
        case GlassBackend.easyLens:
          return LiquidGlassBox(
            height: height,
            width: width,
            circle: circle,
            cornerRadius: radius.topLeft.x,
            pressed: pressed,
            elevated: elevated,
            touchFlex: effectiveLiquidTouch,
            materialize: m,
            child: content,
          );
        case GlassBackend.liquidWidgets:
          return LiquidWidgetsGlassBox(
            height: height,
            width: width,
            circle: circle,
            cornerRadius: radius.topLeft.x,
            pressed: pressed,
            elevated: elevated,
            interactive: effectiveLiquidTouch,
            onTap: tapInsideLiquidBox ? onTap : null,
            materialize: m,
            child: content,
          );
        case GlassBackend.plain:
          break;
      }
      if (clipContent) {
        content = circle
            ? ClipOval(child: content)
            : ClipRRect(borderRadius: radius, child: content);
      }
      return AnimatedContainer(
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        height: height,
        width: circle ? height : width,
        decoration: BoxDecoration(
          color: dim(
            pressed ? GlassTokens.pressedFill(cs) : GlassTokens.fill(cs),
          ),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : radius,
          border: Border.all(
            color: dim(GlassTokens.stroke(cs)),
            width: GlassTokens.strokeWidth,
          ),
          boxShadow: elevated
              ? GlassTokens.shadow(cs, alphaScale: m)
              : null,
        ),
        child: content,
      );
    }

    Widget result;
    if (onTap == null && onLongPress == null) {
      result = buildBox(false);
    } else {
      result = GlassPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        tapHandledDeeper: tapInsideLiquidBox,
        // 形变层自己就有一下按压放大（[GlassTokens.widgetsInteractionScale] =
        // 1.05），外面再叠 0.96 的缩小几乎正好抵消，读起来是「按了没反应」。
        // 这一档的按下反馈由形变 + 底色变化负责，不再另外缩放。
        scale: tapInsideLiquidBox ? 1.0 : GlassTokens.pressedScale,
        builder: (context, pressed) => buildBox(pressed),
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

/// 玻璃图标按钮。
///
/// - [standalone] = true：独立圆形玻璃钮（带底色 / 投影），直径 [size]。
/// - [standalone] = false：放在 [GlassButtonGroup] 里的透明图标位，按下时
///   只在图标下方出现圆形高亮。
///
/// 触发耗时动作（刷新 / 保存 / 全部已读……）的按钮必须给出 loading 反馈：
/// 页面已有可观察状态时传 [loading]，没有就用 [GlassAsyncIconButton] 让按钮
/// 自己跟着 Future 走。
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.standalone = false,
    this.size,
    this.iconSize = GlassTokens.iconSize,
    this.showBadge = false,
    this.badgeLabel,
    this.color,
    this.loading = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool standalone;
  final double? size;
  final double iconSize;
  final bool showBadge;
  final Widget? badgeLabel;
  final Color? color;

  /// 正在执行一段耗时动作：图标**原位**换成沙漏、按钮置灰不可按、小红点收起。
  ///
  /// 这是全 App 唯一的「按钮级 loading」表达，不要各页自己往 icon 里塞
  /// `CircularProgressIndicator`：转圈在 40×40 的按钮位上比图标小一圈、粗细
  /// 与线性图标不同族，换进换出还会跳一下尺寸；沙漏是同一套图标语言里的一枚
  /// 字形，走 [GlassAnimatedIcon] 的缩放交叉过渡后读起来就是「这枚键自己变了
  /// 个样子」，与词汇表里其它形变同源。
  ///
  /// 复位由状态源负责：接 Rx / setState 的传 [loading]，没有状态源的用
  /// [GlassAsyncIconButton]。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double resolvedSize =
        size ??
        (standalone ? GlassTokens.pillHeight : GlassTokens.groupIconButtonSize);
    // loading 期间按钮一律不可按：重复点击刷新只会把同一份请求发两遍，
    // 而「灰掉」正是用户能读到的「已经在做了」。
    final VoidCallback? effectiveOnPressed = loading ? null : onPressed;

    // 可用↔置灰的颜色变化也要过渡：直接换 IconThemeData.color 会让图标瞬间
    // 跳成灰色，而同一个按钮的底色（GlassSurface 的 AnimatedContainer）却在
    // 平滑推移，两者不同步就读成「闪了一下」。见 GlassAnimatedColors 的说明。
    Widget iconWidget = GlassAnimatedColors(
      colors: [
        color ??
            (effectiveOnPressed == null
                ? cs.onSurface.withValues(alpha: 0.38)
                : cs.onSurface),
      ],
      builder: (context, c) => IconTheme.merge(
        data: IconThemeData(size: iconSize, color: c.first),
        // 图标本身在同一按钮位上换 codePoint 时做缩放交叉过渡
        // （如多选↔退出、瀑布↔分页、动作↔沙漏）。
        child: GlassAnimatedIcon(
          icon: loading ? const Icon(Icons.hourglass_top) : icon,
        ),
      ),
    );
    // 徽标始终挂载，通过弹跳缩放来实现显隐，避免小红点瞬间跳出/消失。
    // 有 label 的场景交给 Flutter 原生 Badge（数字变化本身就带过渡）。
    // loading 期间收起徽标：沙漏已经说明「这件事正在做」，红点再挂着反而
    // 像是又有新的待办。
    final bool effectiveShowBadge = showBadge && !loading;
    if (badgeLabel != null) {
      iconWidget = Badge(
        label: badgeLabel,
        isLabelVisible: effectiveShowBadge,
        child: iconWidget,
      );
    } else {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -1,
            right: -1,
            child: GlassAnimatedDot(visible: effectiveShowBadge),
          ),
        ],
      );
    }

    if (standalone) {
      return GlassSurface(
        circle: true,
        height: resolvedSize,
        onTap: effectiveOnPressed,
        tooltip: tooltip,
        child: Center(child: iconWidget),
      );
    }

    Widget result = GlassPressable(
      onTap: effectiveOnPressed,
      scale: 0.9,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        width: resolvedSize,
        height: resolvedSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pressed
              ? cs.onSurface.withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Center(child: iconWidget),
      ),
    );
    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}

/// 自己管 loading 的玻璃图标钮：点下去立刻进沙漏态，直到 [onPressed] 返回的
/// Future 落定（正常结束或抛错都会复位）。
///
/// 用在**没有现成可观察状态**的耗时动作上——页面里那些 `onPressed: _refreshList`
/// 之类「发出去就不管」的写法，点完按钮毫无变化，用户只能盯着列表猜有没有生效。
/// 页面本身已经有 `isLoading` / `isSaving` 这类 Rx 或 setState 状态时，直接用
/// [GlassIconButton.loading]，别在同一件事上养两份状态。
///
/// [minLoadingDuration] 保证沙漏至少停留一小会儿：命中缓存的刷新可能 20ms 就
/// 回来了，不兜底的话按钮只是闪一下，读起来像「点了没反应」。
class GlassAsyncIconButton extends StatefulWidget {
  const GlassAsyncIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.standalone = false,
    this.size,
    this.iconSize = GlassTokens.iconSize,
    this.showBadge = false,
    this.badgeLabel,
    this.color,
    this.loading = false,
    this.minLoadingDuration = const Duration(milliseconds: 320),
  });

  final Widget icon;

  /// 耗时动作。传 null 表示禁用（与 [GlassIconButton.onPressed] 一致）。
  final Future<void> Function()? onPressed;
  final String? tooltip;
  final bool standalone;
  final double? size;
  final double iconSize;
  final bool showBadge;
  final Widget? badgeLabel;
  final Color? color;

  /// 外部状态也表示「这件事正在做」时置真，与内部的忙碌状态取或。
  ///
  /// 用于同一件事既能从按钮触发、又能从别处触发的场合（下拉刷新、controller
  /// 自发刷新）——这时按钮除了跟自己的 Future，也要跟着外部状态进沙漏。
  final bool loading;
  final Duration minLoadingDuration;

  @override
  State<GlassAsyncIconButton> createState() => _GlassAsyncIconButtonState();
}

class _GlassAsyncIconButtonState extends State<GlassAsyncIconButton> {
  bool _busy = false;

  Future<void> _run() async {
    final action = widget.onPressed;
    if (_busy || action == null) return;
    setState(() => _busy = true);
    try {
      await Future.wait<void>([
        action(),
        Future<void>.delayed(widget.minLoadingDuration),
      ]);
    } catch (e, s) {
      // 动作自身的失败提示由调用方负责（SnackBar / 错误态）；这里只保证
      // 按钮能复位，并把异常照常上报，免得它被按钮悄悄吞掉。
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: s,
          library: 'glass_surface',
          context: ErrorDescription('GlassAsyncIconButton 的动作执行失败'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      icon: widget.icon,
      onPressed: widget.onPressed == null ? null : _run,
      loading: _busy || widget.loading,
      tooltip: widget.tooltip,
      standalone: widget.standalone,
      size: widget.size,
      iconSize: widget.iconSize,
      showBadge: widget.showBadge,
      badgeLabel: widget.badgeLabel,
      color: widget.color,
    );
  }
}

/// 把多个 [GlassIconButton]（或任意 40×40 控件）聚合进一个玻璃胶囊。
///
/// 胶囊自身宽度带 [AnimatedSize]：内部子项显隐 / 尺寸变化时，胶囊会平滑
/// 收放而不是瞬跳。条件出现的子项建议用 [GlassGroupSlot] 包一层，让子项
/// 在被移除前有一段收窄+淡出的落幕动效——两层动画在时间上叠合，看起来
/// 是「胶囊连着按钮一起被挤进/挤出」，而不是先塌陷后按钮再消失。
class GlassButtonGroup extends StatelessWidget {
  const GlassButtonGroup({
    super.key,
    required this.children,
    this.height = GlassTokens.pillHeight,
    this.spacing = 0,
    this.touchFlex = true,
    this.touchFlexSignature,
  });

  final List<Widget> children;
  final double height;
  final double spacing;

  /// 液态档下是否给整只胶囊接入交互形变。传统档忽略。**默认开**，
  /// 理由同 [GlassSurface.liquidTouch]。
  ///
  /// 走哪条路由取决于档位（见 [GlassSurface.liquidTouch]）：
  ///   - [GlassBackend.liquidWidgets]：直接开，没有尺寸要求。
  ///   - [GlassBackend.easyLens]：lens 的 `touch` 要求尺寸钉死，而胶囊宽度是
  ///     「抱内容」算出来的、还会随按钮增删动画过渡——只能走
  ///     [LiquidGlassSettledTouch]：过渡中退回不开 touch 的自然布局，
  ///     等尺寸真的不动了才量一次并锁上。这条路要 [touchFlexSignature]，
  ///     没给就**不开**（默认开之后不能拿 assert 去炸调用点）。
  final bool touchFlex;

  /// 影响胶囊里哪些子项可见（因而影响胶囊宽度）的外部状态摘要，例如
  /// `'$isWide|$isMultiSelect'`。只有 [GlassBackend.easyLens] 档需要，
  /// 见 [LiquidGlassSettledTouch.signature]。
  final Object? touchFlexSignature;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final List<Widget> row = [];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && spacing > 0) row.add(SizedBox(width: spacing));
      row.add(children[i]);
    }

    Widget buildSurface({double? width, bool liquidTouch = false}) {
      return GlassSurface(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        liquidTouch: liquidTouch,
        child: AnimatedSize(
          // 外壳收放比槽位（GlassGroupSlot）略慢半拍：壳体「追着」内容走，
          // 入场跟着按钮慢慢撑开、出场等内容收完再从容合拢，读起来是
          // 同一坨液态玻璃在形变，而不是两层动画各自为政。
          duration: GlassTokens.groupMorphDuration,
          curve: GlassTokens.groupSlotCurve,
          alignment: Alignment.centerRight,
          clipBehavior: Clip.hardEdge,
          child: Row(mainAxisSize: MainAxisSize.min, children: row),
        ),
      );
    }

    if (!touchFlex) return buildSurface();

    // 只有 easy 的 lens 要求把尺寸钉死。widgets 档的交互态没有这条约束，
    // 直接开就行——顺带整只绕开了「量一次再锁死」那条路：那条路一旦锁在
    // 过渡途中就再也回不来（见 [LiquidGlassSettledTouch] 上那段实测记录）。
    if (LiquidGlassScope.of(context) != GlassBackend.easyLens) {
      return buildSurface(liquidTouch: true);
    }

    // 没给签名就不开——[touchFlex] 默认开之后，缺签名是「这个调用点没考虑过
    // easy 档」而不是写错了，不该把页面炸掉。
    if (touchFlexSignature == null) return buildSurface();
    return LiquidGlassSettledTouch(
      signature: touchFlexSignature ?? row.length,
      builder: (context, lockedSize) => buildSurface(
        width: lockedSize?.width,
        liquidTouch: lockedSize != null,
      ),
    );
  }
}

/// 装进 [GlassButtonGroup] 的变宽文字动作位，配 [GlassDialogAction] 一类
/// 「取消/确认」按钮组使用。
///
/// [GlassIconButton] 是固定 40×40 的图标槽，文字按钮宽度天然随文案变化，
/// 装不进那套尺寸约定，所以另起一个——手感（按下缩放、可用性变色、装进
/// 玻璃胶囊后自带 `touchFlex` 长按蠕动）与 [GlassIconButton] 是同一族，只是
/// 视觉换成「文字位」而不是「图标位」。不自带外壳：外壳统一由包住它的
/// [GlassButtonGroup] 提供，多个动作键因此共处同一坨玻璃、按住能一起蠕动，
/// 而不是各自一只独立胶囊。
class GlassTextActionButton extends StatelessWidget {
  const GlassTextActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// 本组里的主动作：文字转主色 + 字重加粗。次要动作（取消一类）留默认。
  final bool emphasized;

  /// 破坏性动作（删除/清空一类不可逆操作）：文字转 `cs.error`。
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool enabled = onPressed != null;
    final Color base = destructive
        ? cs.error
        : (emphasized ? cs.primary : cs.onSurfaceVariant);

    return GlassAnimatedColors(
      colors: [enabled ? base : cs.onSurface.withValues(alpha: 0.38)],
      builder: (context, c) => GlassPressable(
        onTap: onPressed,
        scale: 0.94,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: GlassTokens.pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: pressed
                ? cs.onSurface.withValues(alpha: 0.08)
                : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: c.first,
              fontSize: 14.5,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
