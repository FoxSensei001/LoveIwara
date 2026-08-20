import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
/// | 整只玻璃胶囊从有到无（某个 tab 没有任何动作）   | 胶囊瞬间消失 / 被矩形裁成一条细色块   | [GlassCapsuleReveal]  |
/// | 玻璃胶囊之间的形态互换（分段胶囊↔下拉按钮）      | 两侧都自带底色/描边/阴影              | [GlassCapsuleMorph]   |
/// | 下拉钮标题跟随横滑进度翻页               | 滑完才换字，中途一直是旧文案            | [GlassFlipLabel]      |
/// | 按钮触发耗时动作（刷新/保存/全部已读）      | 点完毫无变化，或各页自造转圈          | `GlassIconButton.loading` / `GlassAsyncIconButton` |
/// | 可用↔不可用 / 常态↔危险态的**语义色**变化 | 底色平滑推移、图标文字却瞬间跳色      | [GlassAnimatedColors] |
///
/// 「耗时动作」那一行同样是形变而不是替换：图标**原位**交叉过渡成沙漏、按钮
/// 顺带置灰，做完再换回来。不要塞 `CircularProgressIndicator`——转圈在 40×40
/// 的按钮位上比图标小一圈、粗细不同族，换进换出还会跳一下尺寸。页面已有
/// `isLoading` 之类可观察状态就传 `loading`，没有就用 `GlassAsyncIconButton`
/// 让按钮自己跟着 Future 走（含最短停留时长，避免命中缓存时只闪一下）。
///
/// 统一遵守：
/// - 时值 = [GlassTokens.motionDuration]（200ms），必要时略缩短到 160ms。
///   例外：[GlassGroupSlot] 的进出场是两套节奏（入场 300ms / 出场 200ms，
///   见 [GlassTokens.groupSlotEnterDuration]），宽度走缓入缓出——
///   easeOutCubic 开头猛冲，叠上外层胶囊的 AnimatedSize 后宽度像瞬跳。
/// - 曲线 = [GlassTokens.motionCurve]（`easeOutCubic`）——入场重、出场轻。
/// - 出场元素从可视位置向内收（宽度→0 + 淡出），而不是先淡出再抽空间。
/// - 凡是**手指还按在屏幕上**就能看出进度的形变（横滑切 tab），一律接
///   `progress`（小数下标）逐帧插值，不要等手势结束再放一段固定时长的动画：
///   见 [GlassSegmentedControl.progress] 与 [GlassFlipLabel]。
/// - **颜色也是形变**。一个控件的底色、图标色、文字色必须一起过渡、用同一段
///   时值；只给底色套 `AnimatedContainer` 而让 `Icon` / `Text` 直接换颜色，
///   会读成「按钮闪了一下」——底色还在推移，前景已经跳完了。统一用
///   [GlassAnimatedColors]。
///   注意与**按下反馈**分层：按下是 [GlassTokens.pressDuration]（120ms，要跟手），
///   可用性/语义色是 [GlassTokens.motionDuration]（200ms）。两者叠在一起时，
///   先让状态色插值出当前帧的基色，再把按下的暗化混到基色上。

/// 把一组颜色一起插值，交给 [builder] 拿到当前帧的值。
///
/// 用于**语义色 / 可用性**变化：按钮从置灰变可用、常态变危险态、选中变未选中。
/// 这类变化最容易只做一半——底色套了 `AnimatedContainer` 平滑推移，而
/// `Icon(color:)` 和 `Text(style: TextStyle(color:))` 仍然瞬间换色，两者不同步，
/// 读起来就是「按钮闪了一下」。把底色与前景色一并交给这个原语，它们才会同步。
///
/// ```dart
/// GlassAnimatedColors(
///   colors: [enabled ? cs.primary : cs.surfaceContainerHighest,
///            enabled ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.38)],
///   builder: (context, c) => ColoredBox(
///     color: c[0],
///     child: Icon(Icons.download, color: c[1]),
///   ),
/// )
/// ```
///
/// [colors] 的长度在同一个位置上必须保持稳定（长度变化会重建补间、丢掉进行中
/// 的过渡）。首帧不做动画，直接就是目标色。
class GlassAnimatedColors extends ImplicitlyAnimatedWidget {
  const GlassAnimatedColors({
    super.key,
    required this.colors,
    required this.builder,
    super.duration = GlassTokens.motionDuration,
    super.curve = GlassTokens.motionCurve,
  });

  final List<Color> colors;

  /// 收到的列表与 [colors] 一一对应，元素是当前帧插值后的颜色。
  final Widget Function(BuildContext context, List<Color> colors) builder;

  @override
  AnimatedWidgetBaseState<GlassAnimatedColors> createState() =>
      _GlassAnimatedColorsState();
}

class _GlassAnimatedColorsState
    extends AnimatedWidgetBaseState<GlassAnimatedColors> {
  List<ColorTween?> _tweens = const <ColorTween?>[];

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    if (_tweens.length != widget.colors.length) {
      _tweens = List<ColorTween?>.filled(widget.colors.length, null);
    }
    for (var i = 0; i < widget.colors.length; i++) {
      _tweens[i] =
          visitor(
                _tweens[i],
                widget.colors[i],
                (dynamic value) => ColorTween(begin: value as Color?),
              )
              as ColorTween?;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, [
      for (var i = 0; i < widget.colors.length; i++)
        _tweens[i]?.evaluate(animation) ?? widget.colors[i],
    ]);
  }
}

/// 一个可动画显隐的「槽位」：`visible=false` 时宽度收到 0 + 淡出，
/// `visible=true` 时反向恢复。用于按钮组里那些**条件出现**的按钮，让胶囊
/// 整体宽度也跟着平滑收放（外层再套一层 `AnimatedSize` 由 [GlassButtonGroup]
/// 提供，两层在时序上互相配合）。
///
/// 进出场是两套节奏：入场慢而完整（[GlassTokens.groupSlotEnterDuration]，
/// 宽度走缓入缓出，先酝酿再展开），出场快而干脆（[GlassTokens
/// .groupSlotExitDuration]）。图标自身的淡入/缩放仍走常规 motion 曲线，
/// 在宽度还在生长时就基本显形--读起来是「按钮冒出来」，而不是
/// 「一块矩形被拉宽」。
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

  Duration get _enterDuration =>
      widget.duration ?? GlassTokens.groupSlotEnterDuration;
  Duration get _exitDuration =>
      widget.duration ?? GlassTokens.groupSlotExitDuration;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.visible ? _enterDuration : _exitDuration,
      value: widget.visible ? 1.0 : 0.0,
    );
    if (widget.visible) _cached = widget.child;
  }

  @override
  void didUpdateWidget(covariant GlassGroupSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _cached = widget.child;
      if (_controller.status != AnimationStatus.forward &&
          _controller.value != 1.0) {
        _controller.duration = _enterDuration;
        _controller.forward();
      }
    } else if (oldWidget.visible) {
      _controller.duration = _exitDuration;
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
    // 宽度：缓入缓出。easeOutCubic 开头猛冲，叠上外层胶囊的 AnimatedSize
    // 后宽度像瞬跳；缓入缓出让展开有起势、收拢有余韵。
    final size = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? GlassTokens.groupSlotCurve,
      reverseCurve: (widget.curve ?? GlassTokens.groupSlotCurve).flipped,
    );
    // 图标显形：快曲线，让按钮在宽度还在生长时就先「冒头」。
    final appear = CurvedAnimation(
      parent: _controller,
      curve: GlassTokens.motionCurve,
    );
    return ClipRect(
      child: SizeTransition(
        axis: widget.axis,
        sizeFactor: size,
        alignment: widget.axis == Axis.horizontal
            ? Alignment.centerLeft
            : Alignment.topCenter,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(appear),
          child: FadeTransition(
            opacity: appear,
            child: _cached ?? const SizedBox.shrink(),
          ),
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

/// 整只玻璃胶囊的「有 ↔ 无」：胶囊**先原地缩小淡出、再把占位宽度收掉**，
/// 出现时反向（先撑开位置、再放大淡入）。
///
/// 为什么不是 [GlassShapeSwitcher] / [GlassGroupSlot]：
/// - [GlassGroupSlot] 只收内部按钮的宽度——[GlassButtonGroup] 的玻璃壳自己还有
///   左右内边距与描边，收到最后会在 header 上留下一条竖着的细色块；
/// - [GlassShapeSwitcher] 会一边淡出一边用**矩形**裁剪收宽度，胶囊的圆角端被
///   切平、阴影被硬裁在容器里，读起来就是「啪」一下被切掉，而不是被收走。
///
/// 这里两段时序不重叠：内容还看得见时宽度一动不动，宽度开始收时内容已经透明，
/// 所以全程不需要任何裁剪（用 `Align.widthFactor` 让位，超出部分照常绘制但此时
/// 已经不可见），圆角与阴影自始至终完整。
class GlassCapsuleReveal extends StatefulWidget {
  const GlassCapsuleReveal({
    super.key,
    required this.visible,
    required this.child,
    this.alignment = Alignment.centerRight,
  });

  final bool visible;
  final Widget child;

  /// 缩放锚点与让位方向：贴在 header 右缘的胶囊用 [Alignment.centerRight]，
  /// 收放时固定的那一端不动。
  final Alignment alignment;

  @override
  State<GlassCapsuleReveal> createState() => _GlassCapsuleRevealState();
}

class _GlassCapsuleRevealState extends State<GlassCapsuleReveal>
    with SingleTickerProviderStateMixin {
  /// 出场比入场干脆一点，但都要慢到看得清「收走」的过程。
  static const Duration _enterDuration = Duration(milliseconds: 320);
  static const Duration _exitDuration = Duration(milliseconds: 260);

  /// 时序切分点：进度低于它只动宽度，高于它只动内容（两段不重叠）。
  static const double _handoff = 0.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.visible ? _enterDuration : _exitDuration,
    value: widget.visible ? 1.0 : 0.0,
  );

  /// 缓存最后一次可见的 child，出场动画期间继续渲染。
  Widget? _cached;

  @override
  void initState() {
    super.initState();
    if (widget.visible) _cached = widget.child;
  }

  @override
  void didUpdateWidget(covariant GlassCapsuleReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _cached = widget.child;
      if (_controller.status != AnimationStatus.forward &&
          _controller.value != 1.0) {
        _controller.duration = _enterDuration;
        _controller.forward();
      }
    } else if (oldWidget.visible) {
      _controller.duration = _exitDuration;
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
    final child = _cached;
    if (child == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double v = _controller.value;
        // 前半程让位（宽度），后半程显形（缩放 + 透明度）——反向自动倒放。
        final double widthT = Curves.easeInOutCubic.transform(
          (v / _handoff).clamp(0.0, 1.0),
        );
        final double contentT = Curves.easeOutCubic.transform(
          ((v - _handoff) / (1 - _handoff)).clamp(0.0, 1.0),
        );
        return Align(
          alignment: widget.alignment,
          widthFactor: widthT,
          child: IgnorePointer(
            // 还没显形到一半时不该接手势（此时它几乎看不见）
            ignoring: contentT < 0.5,
            child: Opacity(
              opacity: contentT,
              child: Transform.scale(
                scale: 0.88 + 0.12 * contentT,
                alignment: widget.alignment,
                child: child,
              ),
            ),
          ),
        );
      },
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
          children: [...previousChildren, ?currentChild],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: c)),
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
///
/// ⚠️ 新旧内容是**交接**（baton pass）而不是叠化：旧内容在前半程收掉，新
/// 内容在后半程才开始长出来，两者永远不会同时可读。这里的两侧是「一行字 +
/// 箭头」与「三个平铺的分段」——对称叠化会让两行文字互相穿透成一团糊字
/// （2026-08-20 用户在订阅页横滑到「投稿」时反馈）。同时这段延迟也让胶囊
/// 自身的 [AnimatedSize] 有时间把宽度撑到位，新内容不会在还没长够的胶囊里
/// 被圆角硬裁一截。
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
    final d = duration ?? GlassTokens.capsuleMorphDuration;
    final c = curve ?? GlassTokens.motionCurve;
    // 交接时序：旧内容在四成处收干净，新内容从四成半起显形——两条 Interval
    // 首尾几乎相接，中间只留一帧的空窗。重叠会让两侧文字互相穿透糊成一团
    // （叠化的老毛病），空窗留长了又会看见一只空胶囊愣在那儿。
    //
    // 新内容故意压后一点，是为了等胶囊自身的 [AnimatedSize] 把宽度撑到位：
    // 它开始显形时宽度已经走了八成，等它到看得清的不透明度时宽度基本到底，
    // 全程不会被圆角裁掉一截。
    final Curve outCurve = Interval(0.6, 1.0, curve: c.flipped);
    final Curve inCurve = Interval(0.45, 1.0, curve: c);
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
          switchInCurve: inCurve,
          switchOutCurve: outCurve,
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: alignment,
            clipBehavior: Clip.none,
            children: [...previousChildren, ?currentChild],
          ),
          // 淡入淡出之外再带一点缩放：旧内容像被收走、新内容像长出来，
          // 而不是原地闪一下。锚在 [alignment]，胶囊固定的那一端不动。
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(animation),
              alignment: alignment,
              child: child,
            ),
          ),
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

/// 「跟手翻牌」标题：一行文字随横向滑动进度**连续翻页**，像日历 / 翻页钟
/// 翻过一格，而不是等手势落定后才整块换字。
///
/// 窄屏下分段胶囊会塌缩成一枚下拉触发钮（见 [GlassCapsuleMorph]），但页面
/// 本身仍支持横滑切换 tab。手指拖到一半时，钮里的文案理应也翻到一半——
/// 半途松手回弹，它就跟着退回去；这才是「跟手」。
///
/// 用法：传 [progress]（`TabController.animation`，或由 `PageController.page`
/// 喂出来的 `ValueNotifier<double>`，值为小数下标）与各档的 [labels]。
///
/// 翻牌时序按真实翻页板来（同一时刻只有一张牌可见，不做 crossfade，
/// 文字不会糊成两层重影）：
///   - 前半程：旧文案绕**自身下边缘**向上翻走（0° → -90°）；
///   - 交接点：两张牌都正好侧对着观察者，厚度为 0，天然无跳变；
///   - 后半程：新文案绕**自身上边缘**从下方翻上来（90° → 0°）。
/// 反向滑动时整段时序自动倒放。
///
/// 宽度也按小数位在相邻两档之间插值（文案长短不一时），外层胶囊跟着连续
/// 伸缩，而不是等落定后跳一下。为此需要预先量出每档的宽度，所以这里收
/// [labels] / [icons] 两个列表而不是一个 `IndexedWidgetBuilder`。
class GlassFlipLabel extends StatefulWidget {
  const GlassFlipLabel({
    super.key,
    required this.progress,
    required this.labels,
    this.icons,
    this.style,
    this.iconSize = 16,
    this.iconGap = 5,
    this.alignment = Alignment.centerLeft,
  });

  /// 连续的小数下标。整数位＝当前档，小数位＝翻牌进度。
  final ValueListenable<double> progress;

  final List<String> labels;

  /// 可选：每档文字前的小图标，跟文字一起翻（长度须与 [labels] 一致）。
  final List<Widget?>? icons;

  /// 文字样式；只给部分字段时会与外层 `DefaultTextStyle` 合并后再量宽。
  final TextStyle? style;

  final double iconSize;
  final double iconGap;

  /// 翻牌过程中窄于最宽档时，牌面往哪边贴。默认左对齐——左边缘钉住不动，
  /// 只有右边的箭头跟着宽度滑，读起来最稳。
  final Alignment alignment;

  @override
  State<GlassFlipLabel> createState() => _GlassFlipLabelState();
}

class _GlassFlipLabelState extends State<GlassFlipLabel> {
  /// 每档牌面的宽度（图标 + 间距 + 文字），逐帧插值用。
  List<double> _widths = const [];
  double _height = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measure();
  }

  @override
  void didUpdateWidget(GlassFlipLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.labels, widget.labels) ||
        oldWidget.style != widget.style ||
        oldWidget.iconSize != widget.iconSize ||
        oldWidget.iconGap != widget.iconGap ||
        (oldWidget.icons?.length ?? 0) != (widget.icons?.length ?? 0)) {
      _measure();
    }
  }

  /// 量宽只在 labels / 样式 / 文字缩放变化时做一次，不进逐帧的 builder。
  void _measure() {
    final TextStyle style = DefaultTextStyle.of(
      context,
    ).style.merge(widget.style);
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final TextDirection direction = Directionality.of(context);

    final widths = <double>[];
    double height = 0;
    for (var i = 0; i < widget.labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(text: widget.labels[i], style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      double width = painter.width;
      if (_iconAt(i) != null) width += widget.iconSize + widget.iconGap;
      widths.add(width);
      if (painter.height > height) height = painter.height;
      painter.dispose();
    }

    _widths = widths;
    _height = height > widget.iconSize ? height : widget.iconSize;
  }

  Widget? _iconAt(int index) {
    final icons = widget.icons;
    if (icons == null || index >= icons.length) return null;
    return icons[index];
  }

  /// 单张牌面：图标 + 文字，宽度取自然宽（外层用 OverflowBox 放开约束）。
  Widget _buildFace(BuildContext context, int index) {
    final icon = _iconAt(index);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(size: widget.iconSize),
            child: icon,
          ),
          SizedBox(width: widget.iconGap),
        ],
        Text(
          widget.labels[index],
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: widget.style,
        ),
      ],
    );
  }

  /// 翻转中的牌面：绕 [hinge] 边缘转 [angle]，带一点透视。
  Widget _buildFlipping(
    BuildContext context,
    int index, {
    required double angle,
    required Alignment hinge,
  }) {
    // 快转到侧面时（>0.7 即约 63°）淡出，免得正好 90° 时留下一条硬边
    final double edgeT = (angle.abs() / (math.pi / 2)).clamp(0.0, 1.0);
    final double opacity = edgeT <= 0.7
        ? 1.0
        : (1.0 - (edgeT - 0.7) / 0.3).clamp(0.0, 1.0);

    Widget face = Transform(
      alignment: hinge,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0016)
        ..rotateX(angle),
      child: _buildFace(context, index),
    );
    if (opacity < 1.0) face = Opacity(opacity: opacity, child: face);

    return OverflowBox(
      alignment: widget.alignment,
      minWidth: 0,
      maxWidth: double.infinity,
      child: face,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.labels.isEmpty) return const SizedBox.shrink();
    if (_widths.length != widget.labels.length) _measure();

    return AnimatedBuilder(
      animation: widget.progress,
      builder: (context, _) {
        final int maxIndex = widget.labels.length - 1;
        final double value = widget.progress.value.clamp(
          0.0,
          maxIndex.toDouble(),
        );
        final int lower = value.floor().clamp(0, maxIndex);
        final int upper = (lower + 1).clamp(0, maxIndex);
        final double t = value - lower;

        // 停在某一档上：直出静态牌面，不套 Transform / SizedBox，
        // 文字保持像素级清晰（绝大多数时间走的都是这条）。
        if (lower == upper || t <= 0.001) {
          return _buildFace(context, lower);
        }

        final double width =
            _widths[lower] + (_widths[upper] - _widths[lower]) * t;
        // 前半程翻走旧的（绕下边缘向上），后半程翻进新的（绕上边缘从下方）
        final bool showingOld = t < 0.5;
        return SizedBox(
          width: width,
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: showingOld
                    // 旧牌绕上边缘往上收（0° → 90°，牌身向后倒）
                    ? _buildFlipping(
                        context,
                        lower,
                        angle: t * math.pi,
                        hinge: Alignment.topCenter,
                      )
                    // 新牌绕下边缘从下方长上来（-90° → 0°）
                    : _buildFlipping(
                        context,
                        upper,
                        angle: -(1 - t) * math.pi,
                        hinge: Alignment.bottomCenter,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
