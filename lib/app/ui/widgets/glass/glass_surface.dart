import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_content_brightness.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// 按下反馈：缩放 + 对外暴露 pressed 状态。
///
/// 所有玻璃按钮共用这一套手感：按下 0.96 缩放、120ms；松开 / 取消还原。
///
/// 点击与长按本身交给 [GlassTapArea]——「手指移出按钮多远才算放弃这一下」
/// 那条规矩定义在那儿，这层不重复实现。
class GlassPressable extends StatefulWidget {
  const GlassPressable({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.scale = GlassTokens.pressedScale,
    this.tapHandledDeeper = false,
    this.stickyTouch = true,
    this.opensOverlay = false,
    this.longPressOpensOverlay = false,
  });

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scale;

  /// [onTap] / [onLongPress] 的**真正触发点在更深处**，这层不要再注册识别器。
  ///
  /// 用在 [GlassSurface] 的 liquidWidgets + [GlassSurface.liquidTouch] 那条路上：
  /// 那一档的跟手形变是借 `GlassButton` 实现的，而它自带一层 `GestureDetector`
  /// 比这层深、竞技场上稳赢，所以点击改由 [GlassSurface] 把 [GlassTapArea] 塞进
  /// **玻璃盒子里头**（比借来的那层还深）去发（详见 [GlassSurface] 里
  /// `tapInsideLiquidBox` 那段）。
  ///
  /// 置真后这层只剩两件事：
  ///   - **画按下反馈**——仍旧走 [GlassTapArea] 的 `onPressedChanged`（不进
  ///     竞技场的 `Listener`，按下那一帧就到，也照样在手指走出容忍圈时撤掉）；
  ///   - **对无障碍暴露「这是个按钮」**——[onTap] / [onLongPress] 挂到
  ///     [Semantics] 上（读屏的「激活」走这条），深处那层则关掉语义避免出现
  ///     两个节点。
  final bool tapHandledDeeper;

  /// 见 [GlassTapArea.sticky]。默认开；只有「本来就要拿位移做别的事」的调用点
  /// （玻璃菜单的滑动取焦）才关。
  final bool stickyTouch;

  /// 见 [GlassTapArea.opensOverlay]：这枚键的 [onTap] 是「吐出一张浮层」，
  /// 于是长按也能打开、并且长按不抬手可以直接滑进面板选。
  final bool opensOverlay;

  /// 见 [GlassTapArea.longPressOpensOverlay]：吐浮层的是 [onLongPress]
  /// （点按干别的事），长按那一下照样震动 + 手指接力。
  final bool longPressOpensOverlay;

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

    // 不可用时仍然吃掉落在按钮上的点击（改造前那只 `behavior: opaque` 的
    // `GestureDetector` 就是这么挡的），别把它漏给身下的东西。
    if (!interactive) {
      return Listener(behavior: HitTestBehavior.opaque, child: scaled);
    }

    if (widget.tapHandledDeeper) {
      return Semantics(
        button: true,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: GlassTapArea(
          onPressedChanged: _setPressed,
          sticky: widget.stickyTouch,
          excludeFromSemantics: true,
          child: scaled,
        ),
      );
    }

    return GlassTapArea(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onPressedChanged: _setPressed,
      sticky: widget.stickyTouch,
      opensOverlay: widget.opensOverlay,
      longPressOpensOverlay: widget.longPressOpensOverlay,
      child: scaled,
    );
  }
}

/// 玻璃体容器：胶囊或圆形，是全 App **唯一**的玻璃材质定义处。
///
/// 材质有**四套后端**，由所处子树里的 `LiquidGlassScope` 决定（见
/// `liquid_glass_material.dart` 的 [GlassBackend]）：
///   - [GlassBackend.plain]（默认）：半透明底色 + 细描边（无外投影），
///     无 BackdropFilter，零 shader 成本。液态档内部的「便宜档」。
///   - [GlassBackend.material]：不透明 M3 面（[MaterialSurfaceBox]），
///     无描边 / 无投影 / 无形变。用户选「Material」时全站走它。
///   - [GlassBackend.easyLens]：`liquid_glass_easy` 的真折射透镜
///     （[LiquidGlassBox]）。玻璃菜单钉死在这一档。
///   - [GlassBackend.liquidWidgets]：`liquid_glass_widgets` 的 `AdaptiveGlass`
///     （[LiquidWidgetsGlassBox]）。页面 chrome 现在走这一档。
///
/// 四档**尺寸语义完全一致**，只换材质——换档不会动布局。
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
    this.opensOverlay = false,
    this.longPressOpensOverlay = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 见 [GlassTapArea.opensOverlay]：[onTap] 是「吐出一张浮层」，长按也能打开，
  /// 且长按不抬手可以直接滑进面板取焦。
  final bool opensOverlay;

  /// 见 [GlassTapArea.longPressOpensOverlay]：吐浮层的是 [onLongPress]。
  final bool longPressOpensOverlay;

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

  /// 是否接入交互形变（按住并拖动时整只玻璃跟着手指走、松手弹回）。
  ///
  /// **三个玻璃档都吃这一项**：传统档 2026-08-26 起也有同一套形变（见
  /// [LiquidWidgetsPlainBox]），只是不带那圈指尖辉光。换材质不该换手感。
  ///
  /// ⛔ **[GlassBackend.material] 是例外，恒不开**：那一档不是玻璃，纸不会被
  /// 手指拽长（2026-09-04 用户拍板去掉）。判断收在本组件里，调用点不用管。
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
    final double m = materialize.clamp(0.0, 1.0);
    final radius =
        borderRadius ??
        BorderRadius.circular((height ?? GlassTokens.pillHeight) / 2);
    final GlassBackend backend = LiquidGlassScope.of(context);

    // easy 档的 touch 要求尺寸已经钉死（见 [LiquidGlassBox.touchFlex]）：抱内容
    // 的玻璃开了它要么被撑满可用空间、要么在无界约束里静默失效。[liquidTouch]
    // 默认开之后不能再指望每个调用点自己守这条，所以这里自己判——钉不死就降级
    // 成不开。widgets 档没有这条约束。
    //
    // Material 档一律不开：跟手形变是液态玻璃的物理，不是「手感」的通用底座
    // （2026-09-04 用户拍板一并去掉）。按在这个收口点上而不是指望 100+ 个
    // 调用点各自守一条。
    final bool effectiveLiquidTouch =
        liquidTouch &&
        backend != GlassBackend.material &&
        (backend != GlassBackend.easyLens ||
            (height != null && (circle || width != null)));

    // ⛔ liquidWidgets 档的跟手形变是**借** `GlassButton` 实现的，而它自带一层
    // `onTap` 必填的 `GestureDetector`——在命中路径上比下面那层 [GlassPressable]
    // 更深，竞技场上稳赢。所以「整只玻璃可按 + [liquidTouch]」时，外层是发不出
    // 点击的，识别器必须放到**比借来的那层还深**的地方去。
    //
    // 2026-08-23 真机报的「热门视频页 header 头像点不开全局抽屉」就是这一条：
    // 身份圆钮是全站唯一同时给了 [onTap] 和 [liquidTouch] 的调用点，改档之后
    // 那一下点击被形变层的空实现整只吃掉。把键放在胶囊**里头**的写法
    // （[GlassButtonGroup]）不受影响——各键自己更深，照样赢得过形变层。
    //
    // 2026-08-24 起改法从「把 onTap 交给 `GlassButton` 自己发」换成「把
    // [GlassTapArea] 塞进玻璃**内容**那一层」：借来的那只识别器是框架默认的
    // tap，走出 kTouchSlop（18px）就判负，而这套材质的手感恰恰要人按住拖着玩
    // ——手指蠕动两下再抬手就没反应了。内容层在 `AdaptiveGlass` 里头、比
    // `GlassButton` 更深，竞技场清算时先赢，「移出去多远才算放弃」这条规矩因此
    // 全 App 只有 [GlassTapArea] 一个出处。
    final bool tapInsideLiquidBox =
        onTap != null &&
        effectiveLiquidTouch &&
        (backend == GlassBackend.liquidWidgets ||
            backend == GlassBackend.plain);

    Color dim(Color c) => m >= 1 ? c : c.withValues(alpha: c.a * m);

    /// 「在场程度」压的不只是材质，**内容也得跟着退场**。
    ///
    /// ⛔ 不这么做的后果是「玻璃没了、图标还在」：2026-08-24 用户报的
    /// 「右下角回到顶部浮钮一直挂着、样式是老的、点了还穿透到列表」正是这个
    /// ——[GlassReveal] 把 [materialize] 压到 0，玻璃确实一点不剩，可里头那枚
    /// `vertical_align_top` 图标仍旧全黑地画在屏幕上，读起来就是「一枚没穿
    /// 玻璃的老式图标钮」；而它外面的 `IgnorePointer` 又让这一下点空。
    ///
    /// 压法走**颜色通道**（把 alpha 乘进图标 / 文字的颜色里），不是 `Opacity`
    /// ——后者会 `saveLayer` 把子树隔离出去，把液态档的折射打断（见
    /// [materialize] 的说明）。颜色通道不建图层，折射一帧都不会断。
    ///
    /// 覆盖不到的只有「自带显式颜色的非图标内容」（比如写死 color 的 `Text`、
    /// 图片、头像）：那种内容要真正退场，请让调用方在 0 端别建这块玻璃
    /// ——[GlassReveal] 已经替所有调用点这么做了。
    Widget dimContent(Widget content) {
      if (m >= 1) return content;
      Widget result = IconTheme.merge(
        data: IconThemeData(opacity: m),
        child: content,
      );
      final Color? textColor = DefaultTextStyle.of(context).style.color;
      if (textColor != null) {
        result = DefaultTextStyle.merge(
          style: TextStyle(color: dim(textColor)),
          child: result,
        );
      }
      return result;
    }

    Widget buildBox(bool pressed) {
      Widget content = Padding(padding: padding, child: dimContent(child));
      if (tapInsideLiquidBox) {
        // 塞在这儿是有讲究的：内容层随盒子的紧约束铺满整只玻璃，而它在借来的
        // `GlassButton` 那只识别器**里头**——竞技场清算时更深者先赢，点击就落
        // 在这层上。语义由外层 [GlassPressable] 统一发，这里关掉免得出现两个
        // 按钮节点。
        content = GlassTapArea(
          onTap: onTap,
          onLongPress: onLongPress,
          opensOverlay: opensOverlay,
          longPressOpensOverlay: longPressOpensOverlay,
          excludeFromSemantics: true,
          child: content,
        );
      }
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
            materialize: m,
            child: content,
          );
        case GlassBackend.material:
          return MaterialSurfaceBox(
            height: height,
            width: width,
            circle: circle,
            cornerRadius: radius.topLeft.x,
            pressed: pressed,
            materialize: m,
            clipContent: clipContent,
            child: content,
          );
        case GlassBackend.plain:
          return LiquidWidgetsPlainBox(
            height: height,
            width: width,
            circle: circle,
            cornerRadius: radius.topLeft.x,
            pressed: pressed,
            elevated: elevated,
            interactive: effectiveLiquidTouch,
            materialize: m,
            clipContent: clipContent,
            child: content,
          );
      }
    }

    Widget result;
    if (onTap == null && onLongPress == null) {
      result = buildBox(false);
    } else {
      result = GlassPressable(
        onTap: onTap,
        onLongPress: onLongPress,
        opensOverlay: opensOverlay,
        longPressOpensOverlay: longPressOpensOverlay,
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
    this.onLongPressed,
    this.tooltip,
    this.standalone = false,
    this.size,
    this.iconSize = GlassTokens.iconSize,
    this.showBadge = false,
    this.badgeLabel,
    this.color,
    this.loading = false,
    this.materialize = 1.0,
    this.opensOverlay = false,
    this.longPressOpensOverlay = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;

  /// 长按这枚键的另一件事。给了它之后 [opensOverlay] 合成的那只长按就不再顶上
  /// （显式的赢），所以「点按开菜单」的钮不要同时传这个。
  final VoidCallback? onLongPressed;

  final String? tooltip;
  final bool standalone;

  /// 见 [GlassTapArea.opensOverlay]：[onPressed] 是「吐出一张浮层」（菜单 /
  /// 下拉板），长按也能打开，且长按不抬手可以直接滑进面板取焦。
  final bool opensOverlay;

  /// 见 [GlassTapArea.longPressOpensOverlay]：吐浮层的是 [onLongPressed]，
  /// 点按干别的事（搜索钮：点按进搜索页、长按挑搜索模式）。
  final bool longPressOpensOverlay;
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

  /// 材质的「在场程度」，透传给 [GlassSurface.materialize]（仅 [standalone]
  /// 有壳时有意义）。玻璃的淡入淡出走这里，**不要**在外面包 `Opacity` /
  /// `AnimatedOpacity`——见 [GlassSurface.materialize] 与 [GlassReveal]。
  final double materialize;

  @override
  Widget build(BuildContext context) {
    // ⭐ [standalone] 的圆钮就是「独自浮在内容之上的一块玻璃」——全站 26 个
    // 「回到顶部」浮钮、角落坞里的钮都长这样，身后没有任何蒙层兜底，是最容易
    // 出现「底下是黑的、图标也是黑的」的一类。字色跟着身后内容走的判决因此挂
    // 在这里，而不是让每个页面各自去包一遍（见 [GlassAdaptiveChrome]）。
    //
    // 三种情况下它整只透传、零成本：非液态档、页面没开内容感知（找不到
    // 采样器）、或外面已经有一块 chrome 在管这片子树（header 那一行）。
    //
    // 圆钮是方的，投票格子用 2×2 而不是横栏那种 6×1。
    //
    // ⛔ 必须用 Builder 把整个 build 挪到判决**之下**：图标色是在这里就地从
    // `ColorScheme` 取的（一个 Color 值，不是一层 InheritedWidget），在外面
    // 包一层换了主题的 Theme 对它毫无作用。
    if (standalone) {
      return GlassAdaptiveChrome(
        gridColumns: 2,
        gridRows: 2,
        debugLabel: '独立圆钮',
        child: Builder(builder: _build),
      );
    }
    return _build(context);
  }

  Widget _build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double resolvedSize =
        size ??
        (standalone ? GlassTokens.pillHeight : GlassTokens.groupIconButtonSize);
    // loading 期间按钮一律不可按：重复点击刷新只会把同一份请求发两遍，
    // 而「灰掉」正是用户能读到的「已经在做了」。
    final VoidCallback? effectiveOnPressed = loading ? null : onPressed;
    final VoidCallback? effectiveOnLongPressed = loading ? null : onLongPressed;

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
        onLongPress: effectiveOnLongPressed,
        opensOverlay: opensOverlay,
        longPressOpensOverlay: longPressOpensOverlay,
        tooltip: tooltip,
        materialize: materialize,
        child: Center(child: iconWidget),
      );
    }

    // 组内变体（standalone == false）：外壳由 [GlassButtonGroup] 提供。
    //
    // ⛔ 玻璃档下按下时**不自绘暗底**，理由同 [GlassTextActionButton]——半透明
    // 胶囊里再叠一个深色圆斑就是「玻璃上的脏印子」。反馈留 0.9 缩放 + 长按时
    // 整只胶囊的蠕动。
    //
    // ⭐ Material 档反过来：它既没有蠕动、面又是不透明的（压根不存在「脏印
    // 子」），只剩 0.9 缩放太薄——而 M3 规定的按下反馈正是身下那个圆形状态层。
    final bool materialTier =
        LiquidGlassScope.of(context) == GlassBackend.material;
    Widget result = GlassPressable(
      onTap: effectiveOnPressed,
      onLongPress: effectiveOnLongPressed,
      opensOverlay: opensOverlay,
      longPressOpensOverlay: longPressOpensOverlay,
      scale: 0.9,
      builder: (context, pressed) => SizedBox(
        width: resolvedSize,
        height: resolvedSize,
        child: materialTier
            ? AnimatedContainer(
                duration: GlassTokens.pressDuration,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pressed
                      ? cs.onSurface.withValues(
                          alpha: GlassTokens.materialPressedStateLayer,
                        )
                      : Colors.transparent,
                ),
                child: Center(child: iconWidget),
              )
            : Center(child: iconWidget),
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

  /// 是否给整只胶囊接入交互形变。**默认开**，理由同 [GlassSurface.liquidTouch]。
  ///
  /// 走哪条路由取决于档位（见 [GlassSurface.liquidTouch]）：
  ///   - [GlassBackend.liquidWidgets] / [GlassBackend.plain]：直接开，没有尺寸
  ///     要求（两档借的是同一层形变）。
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
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// 本组里的主动作：文字转主色 + 字重加粗。次要动作（取消一类）留默认。
  final bool emphasized;

  /// 破坏性动作（删除/清空一类不可逆操作）：文字转 `cs.error`。
  final bool destructive;

  /// 这枚动作正在执行：文字**原位**换成转圈、按钮置灰不可按。
  ///
  /// 与 [GlassSubmitButton] 同一套表达（`AnimatedSwitcher` 交叉过渡 +
  /// `AnimatedSize` 让胶囊宽度平滑伸缩），不要在调用点自己往 label 里塞
  /// `CircularProgressIndicator`——收口前那些裸 `TextButton` 就是各塞各的，
  /// 尺寸会跳。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool enabled = onPressed != null && !loading;
    final Color base = destructive
        ? cs.error
        : (emphasized ? cs.primary : cs.onSurfaceVariant);

    return GlassAnimatedColors(
      colors: [enabled ? base : cs.onSurface.withValues(alpha: 0.38)],
      builder: (context, c) => GlassPressable(
        onTap: enabled ? onPressed : null,
        scale: 0.94,
        // ⛔ 按下时**不自绘暗底**。装进 [GlassButtonGroup] 之后，这枚键身下
        // 已经有一整块玻璃了，再补一层 `onSurface 8%` 的矩形/圆形色块，读起来
        // 不是「按下去了」而是「玻璃上多了一块脏印子」——长按时停留得久，尤其
        // 明显（2026-08-24 用户在「跳转到指定页面」弹窗上指出）。
        // 反馈并没有丢：点按是 [GlassPressable] 的 0.94 缩放，长按是整只胶囊
        // 的跟手蠕动（[GlassButtonGroup.touchFlex] 默认开）——而「长按」正是
        // 暗底最碍眼的那一档，它本来就该让位给蠕动。
        //
        // ⭐ Material 档反过来要画：那一档没有蠕动、身下也是不透明的面（不存在
        // 「脏印子」），M3 规定的按下反馈正是这层状态层。理由同 [GlassIconButton]
        // 的组内变体。
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: GlassTokens.pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration:
              LiquidGlassScope.of(context) == GlassBackend.material &&
                  pressed
              ? BoxDecoration(
                  color: cs.onSurface.withValues(
                    alpha: GlassTokens.materialPressedStateLayer,
                  ),
                  borderRadius: BorderRadius.circular(
                    GlassTokens.pillHeight / 2,
                  ),
                )
              : const BoxDecoration(color: Colors.transparent),
          // 文字 ↔ 转圈原位交叉过渡，胶囊宽度跟着平滑伸缩
          child: AnimatedSize(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            child: AnimatedSwitcher(
              duration: GlassTokens.motionDuration,
              switchInCurve: GlassTokens.motionCurve,
              switchOutCurve: GlassTokens.motionCurve.flipped,
              child: loading
                  ? SizedBox(
                      key: const ValueKey('glass-action-loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(c.first),
                      ),
                    )
                  : Text(
                      label,
                      key: const ValueKey('glass-action-label'),
                      style: TextStyle(
                        color: c.first,
                        fontSize: 14.5,
                        fontWeight: emphasized
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
