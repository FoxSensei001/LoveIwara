import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

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
  });

  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double scale;

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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: interactive ? (_) => _setPressed(true) : null,
      onTapUp: interactive ? (_) => _setPressed(false) : null,
      onTapCancel: interactive ? () => _setPressed(false) : null,
      onTap: interactive ? widget.onTap : null,
      onLongPress: interactive ? widget.onLongPress : null,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        child: widget.builder(context, _pressed),
      ),
    );
  }
}

/// 玻璃体容器：半透明底色 + 细描边 + 柔和投影，胶囊或圆形。
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
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final bool circle;
  final BorderRadius? borderRadius;
  final String? tooltip;
  final bool elevated;
  final bool clipContent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    Widget buildBox(bool pressed) {
      Widget content = Padding(padding: padding, child: child);
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
          color: pressed ? GlassTokens.pressedFill(cs) : GlassTokens.fill(cs),
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : radius,
          border: Border.all(
            color: GlassTokens.stroke(cs),
            width: GlassTokens.strokeWidth,
          ),
          boxShadow: elevated ? GlassTokens.shadow(cs) : null,
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

    Widget iconWidget = IconTheme.merge(
      data: IconThemeData(
        size: iconSize,
        color:
            color ??
            (effectiveOnPressed == null
                ? cs.onSurface.withValues(alpha: 0.38)
                : cs.onSurface),
      ),
      // 图标本身在同一按钮位上换 codePoint 时做缩放交叉过渡
      // （如多选↔退出、瀑布↔分页、动作↔沙漏）。
      child: GlassAnimatedIcon(
        icon: loading ? const Icon(Icons.hourglass_top) : icon,
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
  });

  final List<Widget> children;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final List<Widget> row = [];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && spacing > 0) row.add(SizedBox(width: spacing));
      row.add(children[i]);
    }
    return GlassSurface(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 2),
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
}
