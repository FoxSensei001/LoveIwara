import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// # 液态玻璃形变过渡词汇表
///
/// 「液态」的神在于**没有硬切**：所有 header 上的按钮组、分段胶囊、头像、
/// 徽标只要形状/存在性/图标发生变化，都应当以可感知的动效介入，而不是被
/// 瞬间替换。这个文件把散落在各页 header 里的常见形变收敛成一小组带默认
/// 时值 / 曲线的原语，页面代码只负责决定「谁该变」，不再重复实现「怎么变」。
///
/// 现有形变点及对应原语：
///
/// | 形变场景                              | 现象                          | 原语                    |
/// | ----------------------------------- | ---------------------------- | --------------------- |
/// | `GlassButtonGroup` 增/删按钮           | 宽屏才显搜索、tab 决定是否显示筛选 / 批量  | [GlassGroupSlot]      |
/// | `GlassIconButton` 图标切换              | 多选↔退出、瀑布↔分页                | 见 GlassIconButton 内实现 |
/// | 筛选/未读小红点出现或消失                    | `showBadge` 由 false→true    | [GlassAnimatedDot]    |
/// | 无壳内容形态互换（头像↔shimmer 占位）          | 宽度突变的整体替换                  | [GlassShapeSwitcher]  |
/// | 整块 action group 从有到无（作者页无操作时）  | 整个胶囊瞬间消失                    | [GlassShapeSwitcher]  |
/// | 玻璃胶囊之间的形态互换（分段胶囊↔下拉按钮）      | 两侧都自带底色/描边/阴影              | [GlassCapsuleMorph]   |
///
/// 统一遵守：
/// - 时值 = [GlassTokens.motionDuration]（200ms），必要时略缩短到 160ms。
/// - 曲线 = [GlassTokens.motionCurve]（`easeOutCubic`）——入场重、出场轻。
/// - 出场元素从可视位置向内收（宽度→0 + 淡出），而不是先淡出再抽空间。

/// 一个可动画显隐的「槽位」：`visible=false` 时宽度收到 0 + 淡出，
/// `visible=true` 时反向恢复。用于按钮组里那些**条件出现**的按钮，让胶囊
/// 整体宽度也跟着平滑收放（外层再套一层 `AnimatedSize` 由 [GlassButtonGroup]
/// 提供，两层在时序上互相配合）。
class GlassGroupSlot extends StatefulWidget {
  const GlassGroupSlot({
    super.key,
    required this.visible,
    required this.child,
    this.axis = Axis.horizontal,
    this.duration,
    this.curve,
  });

  final bool visible;
  final Widget child;
  final Axis axis;
  final Duration? duration;
  final Curve? curve;

  @override
  State<GlassGroupSlot> createState() => _GlassGroupSlotState();
}

class _GlassGroupSlotState extends State<GlassGroupSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// 缓存最后一次可见时的 child，用于出场动画期间继续渲染。
  Widget? _cached;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? GlassTokens.motionDuration,
      value: widget.visible ? 1.0 : 0.0,
    );
    if (widget.visible) _cached = widget.child;
  }

  @override
  void didUpdateWidget(covariant GlassGroupSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration ?? GlassTokens.motionDuration;
    }
    if (widget.visible) {
      _cached = widget.child;
      if (_controller.status != AnimationStatus.forward &&
          _controller.value != 1.0) {
        _controller.forward();
      }
    } else if (oldWidget.visible) {
      _controller.reverse().whenCompleteOrCancel(() {
        if (!mounted) return;
        if (!widget.visible && _controller.value == 0.0) {
          setState(() => _cached = null);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? GlassTokens.motionCurve,
      reverseCurve: (widget.curve ?? GlassTokens.motionCurve).flipped,
    );
    return ClipRect(
      child: SizeTransition(
        axis: widget.axis,
        sizeFactor: curve,
        alignment: widget.axis == Axis.horizontal
            ? Alignment.centerLeft
            : Alignment.topCenter,
        child: FadeTransition(
          opacity: curve,
          child: _cached ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// 会「弹跳出场 / 收缩入场」的小红点，用于筛选生效指示、通知未读等。
///
/// 用法：作为 header 上任意子级 Widget 的角标层，配合 `Positioned` 摆到
/// 右上角即可；同一位置在 `visible` 切换时不会有卡顿。
class GlassAnimatedDot extends StatelessWidget {
  const GlassAnimatedDot({
    super.key,
    required this.visible,
    this.size = 9,
    this.color,
    this.borderColor,
    this.borderWidth = 1.5,
  });

  final bool visible;
  final double size;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: AnimatedScale(
        scale: visible ? 1.0 : 0.0,
        duration: GlassTokens.motionDuration,
        curve: visible ? Curves.easeOutBack : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: GlassTokens.motionDuration,
          curve: GlassTokens.motionCurve,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color ?? cs.error,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? cs.surface,
                width: borderWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 形态互换：把「同一位置、形状可能大不相同」的两个 Widget 之间的替换
/// 变成「淡出旧的 + 淡入新的 + 容器宽高连续过渡」。
///
/// 典型场景：
///   - 头像圆钮里的「shimmer 占位 ↔ 用户头像 ↔ 默认图标」；
///   - 作者页 header 里整块 action group 有↔无（比如未登录访客）。
///
/// 用 [layoutAlignment] 控制退场元素与新元素在 Stack 里的对齐；如果新旧
/// 尺寸差别大而希望「从左边不动、从右边伸缩」，传 [Alignment.centerLeft]。
///
/// ⚠️ 只适合**无壳内容**互换。如果新旧两侧都是自带底色/描边/阴影的玻璃
/// 胶囊（如分段胶囊 ↔ 下拉按钮），用 [GlassCapsuleMorph]——直接交叉替换
/// 两只胶囊时，尺寸过渡的矩形裁剪会把圆角端切平、把阴影硬裁在容器里，
/// 动画结束撤掉裁剪时阴影又会突然重绘一次。
class GlassShapeSwitcher extends StatelessWidget {
  const GlassShapeSwitcher({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.layoutAlignment = Alignment.center,
    this.sizeAlignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
  });

  final Widget child;
  final Duration? duration;
  final Curve? curve;

  /// 交叉切换时的对齐——`Stack` 用它决定新旧 child 叠放位置。
  final Alignment layoutAlignment;

  /// 容器尺寸变化的锚点——`AnimatedSize` 用它决定从哪里生长。
  final Alignment sizeAlignment;

  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final d = duration ?? GlassTokens.motionDuration;
    final c = curve ?? GlassTokens.motionCurve;
    return AnimatedSize(
      duration: d,
      curve: c,
      alignment: sizeAlignment,
      clipBehavior: clipBehavior,
      child: AnimatedSwitcher(
        duration: d,
        switchInCurve: c,
        switchOutCurve: c.flipped,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: layoutAlignment,
          clipBehavior: Clip.none,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: c),
            ),
            child: child,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 「同一只胶囊、内容形态互换」：胶囊本体（底色/描边/阴影）自始至终只有
/// 一层、常驻不灭，宽度随新内容平滑伸缩；新旧内容在胶囊**内部** crossfade，
/// 超出当前宽度的部分被胶囊自身的圆角裁掉——露出过程始终是「一只完整的
/// 胶囊在变宽/变窄」，圆角端永远完整，阴影不经过任何矩形裁剪。
///
/// 用于分段胶囊 ↔ 下拉按钮这类「两侧都是玻璃胶囊」的互换。子内容必须是
/// **无壳**的：[GlassSegmentedControl] 传 `flat: true`，下拉侧只放
/// 「文字 + 箭头」的内容行，玻璃壳统一由这里提供。
///
/// 与 [GlassShapeSwitcher] 一样，用 child 的 Key 变化来触发切换。
class GlassCapsuleMorph extends StatelessWidget {
  const GlassCapsuleMorph({
    super.key,
    required this.child,
    this.height = GlassTokens.pillHeight,
    this.duration,
    this.curve,
    this.alignment = Alignment.centerLeft,
  });

  final Widget child;
  final double height;
  final Duration? duration;
  final Curve? curve;

  /// 宽度伸缩的锚点，同时也是新旧内容在胶囊内叠放的对齐。
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final d = duration ?? GlassTokens.motionDuration;
    final c = curve ?? GlassTokens.motionCurve;
    return GlassSurface(
      height: height,
      // 内容按目标宽度整体布局；伸缩途中超出的部分交给胶囊的圆角裁剪
      //（AnimatedSize 自己不裁，避免矩形硬边切掉圆角端）。
      clipContent: true,
      child: AnimatedSize(
        duration: d,
        curve: c,
        alignment: alignment,
        clipBehavior: Clip.none,
        child: AnimatedSwitcher(
          duration: d,
          switchInCurve: c,
          switchOutCurve: c.flipped,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: alignment,
            clipBehavior: Clip.none,
            children: [
              ...previousChildren,
              ?currentChild,
            ],
          ),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: child,
        ),
      ),
    );
  }
}

/// 把一个 `Widget icon` 的替换升级为「旧图标缩小淡出 → 新图标放大淡入」。
///
/// 这是给 [GlassIconButton] 内部用的，也开放给别的 header 场景直接使用
/// （比如自绘的按钮）。传入的图标需要在 identity 变化时能被 [_iconKey]
/// 识别为不同 child——`Icon` 会自动按 `codePoint` 去重，其他 widget
/// 建议自带 `Key`。
class GlassAnimatedIcon extends StatelessWidget {
  const GlassAnimatedIcon({
    super.key,
    required this.icon,
    this.duration,
    this.curve,
  });

  final Widget icon;
  final Duration? duration;
  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? GlassTokens.motionDuration,
      switchInCurve: curve ?? GlassTokens.motionCurve,
      switchOutCurve: (curve ?? GlassTokens.motionCurve).flipped,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: KeyedSubtree(key: _iconKey(icon), child: icon),
    );
  }
}

/// 从任意图标 Widget 里提炼一个「同一按钮位」上稳定可比的 Key，用于
/// `AnimatedSwitcher` 判断是否触发交叉过渡。
Key _iconKey(Widget icon) {
  if (icon.key != null) return icon.key!;
  if (icon is Icon && icon.icon != null) {
    return ValueKey<int>(icon.icon!.codePoint);
  }
  return ValueKey<Type>(icon.runtimeType);
}
