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
          border: Border.all(color: GlassTokens.stroke(cs), width: 0.6),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double resolvedSize =
        size ??
        (standalone ? GlassTokens.pillHeight : GlassTokens.groupIconButtonSize);

    Widget iconWidget = IconTheme.merge(
      data: IconThemeData(
        size: iconSize,
        color: color ?? (onPressed == null ? cs.onSurface.withValues(alpha: 0.38) : cs.onSurface),
      ),
      // 图标本身在同一按钮位上换 codePoint 时做缩放交叉过渡
      // （如多选↔退出、瀑布↔分页）。
      child: GlassAnimatedIcon(icon: icon),
    );
    // 徽标始终挂载，通过弹跳缩放来实现显隐，避免小红点瞬间跳出/消失。
    // 有 label 的场景交给 Flutter 原生 Badge（数字变化本身就带过渡）。
    if (badgeLabel != null) {
      iconWidget = Badge(
        label: badgeLabel,
        isLabelVisible: showBadge,
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
            child: GlassAnimatedDot(visible: showBadge),
          ),
        ],
      );
    }

    if (standalone) {
      return GlassSurface(
        circle: true,
        height: resolvedSize,
        onTap: onPressed,
        tooltip: tooltip,
        child: Center(child: iconWidget),
      );
    }

    Widget result = GlassPressable(
      onTap: onPressed,
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
        duration: GlassTokens.motionDuration,
        curve: GlassTokens.motionCurve,
        alignment: Alignment.centerRight,
        clipBehavior: Clip.hardEdge,
        child: Row(mainAxisSize: MainAxisSize.min, children: row),
      ),
    );
  }
}
