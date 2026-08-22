import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

/// # 玻璃下拉弹窗
///
/// header 上那几只胶囊按下去弹出来的东西，此前全是 Material 的 `PopupMenuButton`
/// ——一张不透明的 elevation 卡片。胶囊本身已经是玻璃了，它吐出来的面板却是块
/// 实心板，这是整条交互链上唯一的硬切。
///
/// 本文件提供一整套替代：
///   - [GlassMenuOption] / [GlassMenuSeparator]：条目描述；
///   - [showGlassMenu]：贴着触发件弹出玻璃面板，返回被选中的值。
///
/// ## 材质是从触发件那儿「带过去」的
///
/// 菜单是一条独立路由，挂在**根 Overlay** 上——它不在页面子树里，读不到页面的
/// `LiquidGlassScope`。所以 [showGlassMenu] 在打开的那一刻就地读一次触发件的
/// 档位（[LiquidGlassScope.isEnabled]），再在面板外面重新供上：**玻璃胶囊弹出
/// 玻璃菜单，传统胶囊弹出传统菜单**，一条链上不会出现两种材质。
///
/// ## 与 `PopupMenuButton` 的行为差异
///
/// - 落点算法一致（触发件正下方、左对齐、越界后回夹进屏幕），但**下方放不下
///   时会翻到上方**弹出，而不是把面板压扁。
/// - 出入场是下面这套「卷开」，不是 Material 的纵向展开。
/// - 行的按压/悬停反馈自绘，不走 Material 水波——水波画在最近的祖先 Material
///   上、穿透中间的 ClipRRect，在圆角面板的四角会露出直角（`_buildTabDropdown`
///   里那条 `borderRadius` 注释就是在按同一个问题）。
///
/// ## 出入场：玻璃先到，字随后
///
/// 参照 Telegram 的 `ActionBarPopupWindow`——**先卷开背景，条目跟着帘子一条条
/// 现身**（`backScaleY` 0→1 配 `startChildAnimation` 的 alpha + 6dp 位移），
/// 而不是整块面板一起淡入。对我们还多一层非做不可的理由：
///
/// > **这层不能有任何 `Opacity`**。α∈(0,1) 时 `RenderOpacity` 会 `saveLayer`
/// > 把子树隔离出去，液态档的 lens 靠 backdrop 采样吃身后的像素，隔离之后层里
/// > 什么都没有——玻璃要等动画跑完、透明度层被撤掉的那一刻才「啪」地补上。
/// > 本文件此前用 `FadeTransition` 做出入场，实机就是「**文字先出现、液态玻璃
/// > 背景后到**」（详见 `liquid_glass_material.dart` 顶部那段）。
///
/// 所以现在整套出入场只用两样东西，都不建透明度层：
///   - **形**：一层 `Transform` 把面板从「触发件那么大」撑到成品尺寸，锚点取
///     触发件那一侧的角；内容再套一层**反向** `Transform` 抵消掉，于是内容
///     全程按自然尺寸待在原地，没卷到的部分由玻璃自己的形状裁掉。
///   - **质**：色调 / 描边 / 投影的透明度走 [GlassSurface.materialize]，在入场
///     前 38% 就上满——玻璃比字先到位，正好是这次要修的那个观感。
///
/// 条目自己的淡入淡出（[_GlassMenuEntryReveal]）在玻璃**里面**，透明度层建在
/// backdrop 采样之后，不影响折射。

/// 玻璃菜单里的一项（条目或分隔线）。
sealed class GlassMenuEntry {
  const GlassMenuEntry();
}

/// 一条可选中的菜单项。
class GlassMenuOption<T> extends GlassMenuEntry {
  const GlassMenuOption({
    required this.value,
    required this.label,
    this.icon,
    this.leading,
    this.selected = false,
    this.destructive = false,
    this.enabled = true,
  });

  /// 选中后由 [showGlassMenu] 返回的值。
  final T value;

  final String label;
  final IconData? icon;

  /// 行首的自定义控件，用在图标不是 [IconData] 的场合（排序项自带 `Widget` 图标、
  /// 用户头像……）。给了它就顶掉 [icon]。它被包在一层 [IconTheme] 里，
  /// 里面的 `Icon` 会自动跟着行的语义色走。
  final Widget? leading;

  /// 当前生效项：文字/图标转主色，行尾出现对勾。
  final bool selected;

  /// 破坏性动作（删除一类）：整行转 error 色。
  final bool destructive;

  final bool enabled;
}

/// 分组之间的细分隔线。
class GlassMenuSeparator extends GlassMenuEntry {
  const GlassMenuSeparator();
}

/// 面板圆角。比胶囊（22）小一档：面板是「一块板」，胶囊是「一颗药」。
const double _panelRadius = 20;

/// 单行高度。比 Material 的 48 略矮，配 44 的胶囊读起来是同一族尺寸。
const double _rowHeight = 44;

/// 面板宽度区间。下限保证短文案（「刷新」）不会缩成一条，上限防止长用户名
/// 把面板拉到半个屏幕宽。
const double _minPanelWidth = 176;
const double _maxPanelWidth = 320;

/// 面板与触发件之间的空隙：与旧 `PopupMenuButton(offset: Offset(0, 8))` 一致，
/// 留这一口是为了不压住玻璃胶囊自己的投影。
const double _anchorGap = 8;

/// 面板与屏幕边缘的最小间距。
const double _screenMargin = 8;

// ---- 静态量尺寸用的几何常量，必须与 _GlassMenuRow / _GlassMenuSeparatorLine
// 的实际布局逐项对应，改了那边的 margin/padding 记得同步这里。----
const double _rowMarginVertical = 1; // AnimatedContainer margin: vertical
const double _rowTotalHeight = _rowHeight + _rowMarginVertical * 2;
const double _rowHorizontalChrome =
    6 * 2 /* margin */ + 12 * 2 /* padding */;
const double _rowIconWidth = 20 + 12; // icon + gap
const double _rowCheckWidth = 12 + 18; // gap + check icon
const double _separatorHeight = 5 * 2 + 1; // padding + line
const double _panelVerticalPadding = 6 * 2;

/// TextPainter 量宽天然会比真实渲染略保守（字体 hinting / 取整），
/// 留一点余量避免刚好卡在临界宽度上被硬套省略号。
const double _panelWidthSlack = 6;

// ---- 出入场（见文件头「出入场」一节）----

/// 入场时长：条目越多，帘子要卷得越久（Telegram 的 `150 + 16 * count`）。
Duration _enterDuration(int entryCount) =>
    Duration(milliseconds: (160 + 16 * entryCount).clamp(200, 300));

/// 出场时长：退场不该让人等，与 Telegram 的 dismiss 同一口径。
const Duration _exitDuration = Duration(milliseconds: 150);

/// 最后一条最晚在入场进度的这个位置开始现身，后半程留给它自己淡完。
const double _entryRevealSpan = 0.5;

/// 条目现身时的起手位移，朝触发件那一侧（Telegram 是 6dp）。
const double _entryRevealShift = 6;

/// 入场起手缩放的下限。再小玻璃会在头几帧被压成一条缝，圆角也跟着压扁成直角。
const double _revealMinScaleX = 0.62;
const double _revealMinScaleY = 0.18;

/// 量不出面板尺寸时的起手缩放（见 [_revealBeginScale]）。
const double _revealFallbackScaleX = 0.90;
const double _revealFallbackScaleY = 0.32;

/// 面板「从多大开始长」：量得到成品尺寸时就用**触发件自己的尺寸**——按钮本身
/// 就是块玻璃，面板从它那么大撑开，读起来是「这枚键吐出一张面板」，而不是
/// 凭空冒出一块板再放大。
Offset _revealBeginScale({required Rect anchor, required Size? panel}) {
  if (panel == null || panel.isEmpty) {
    return const Offset(_revealFallbackScaleX, _revealFallbackScaleY);
  }
  return Offset(
    (anchor.width / panel.width).clamp(_revealMinScaleX, 1.0),
    (anchor.height / panel.height).clamp(_revealMinScaleY, 1.0),
  );
}

/// 面板形变绕哪个角转：横向按触发件在屏幕左/中/右三档取一档，纵向按面板翻没
/// 翻到上方取顶/底。硬取 topCenter 的话，靠右的「更多」菜单会看着像是从屏幕
/// 中间冒出来的。
Alignment _revealOrigin({
  required Rect anchorRect,
  required Size screen,
  required bool flipped,
}) {
  final double cx = anchorRect.center.dx;
  final double x = screen.width <= 0
      ? 0
      : (cx < screen.width * 0.35
            ? -1.0
            : (cx > screen.width * 0.65 ? 1.0 : 0.0));
  return Alignment(x, flipped ? 1.0 : -1.0);
}

/// 每条的入场起点：按它在面板里的纵向位置折算——帘子扫到谁，谁才开始现身
/// （Telegram `setBackScaleY` 里那套逐条点火）。翻到上方弹时帘子自下而上卷，
/// 顺序跟着反过来。
///
/// 行高是静态的（[_rowTotalHeight] / [_separatorHeight]），所以这里不像
/// [_measureMenuPanelSize] 那样会量不出来，自定义 `leading` 的条目一样适用。
List<double> _entryRevealStarts(
  List<GlassMenuEntry> entries, {
  required bool flipped,
}) {
  final List<double> tops = <double>[];
  double y = _panelVerticalPadding / 2;
  for (final entry in entries) {
    tops.add(y);
    y += entry is GlassMenuSeparator ? _separatorHeight : _rowTotalHeight;
  }
  final double total = y + _panelVerticalPadding / 2;
  if (total <= 0) return List<double>.filled(entries.length, 0);
  return <double>[
    for (final double top in tops)
      ((flipped ? total - top : top) / total).clamp(0.0, 1.0) *
          _entryRevealSpan,
  ];
}

/// 静态量出面板需要的精确尺寸。两个用处：
///   1. `touch` 一旦打开就要求精确尺寸（见 [LiquidGlassBox.touchFlex]），
///      这里量出来让它从第一帧就生效；
///   2. 出入场要拿它算「面板该从多大开始长」（见 [_revealBeginScale]）。
///
/// 关于 (1)：如果先按「自然尺寸」渲染一帧、量完再在下一帧把 `touch` 从 null
/// 切成非 null，liquid_glass_easy 内部会因为 touch/deform 走的是完全不同的
/// 实现分支而重新搭一次子树——读起来是「文字先出现，液态玻璃背景才跟上来」
/// 的一次可感知的重初始化（本文件此前确实是按「先测量再补 touch」的两段式
/// 写的，已改成这里的一次到位）。所以宁可牺牲一点精度，用 [TextPainter]
/// 离线量出自然宽高，一次性把精确尺寸喂给 lens。
///
/// 只支持纯 [GlassMenuOption.icon] 的条目；用了 [GlassMenuOption.leading]
/// 自定义控件的条目没法脱离渲染树静态量宽，返回 null——调用方据此直接
/// 不开 touch（退回"抱内容"的自然布局）、起手缩放也退回一组保守常数，
/// 而不是硬套一个量不准的尺寸。
Size? _measureMenuPanelSize({
  required BuildContext anchorContext,
  required List<GlassMenuEntry> entries,
  required Rect anchorRect,
  required double minWidth,
  required double maxWidth,
}) {
  if (entries.isEmpty) return null;
  final TextDirection direction = Directionality.of(anchorContext);
  final TextScaler scaler = MediaQuery.textScalerOf(anchorContext);
  final TextStyle baseStyle = DefaultTextStyle.of(anchorContext).style;

  double contentWidth = 0;
  double height = _panelVerticalPadding;
  for (final entry in entries) {
    switch (entry) {
      case GlassMenuSeparator():
        height += _separatorHeight;
      case GlassMenuOption(:final leading, :final label, :final icon, :final selected):
        if (leading != null) return null;
        final painter = TextPainter(
          text: TextSpan(
            text: label,
            style: baseStyle.merge(
              TextStyle(
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        double rowWidth = _rowHorizontalChrome + painter.width;
        if (icon != null) rowWidth += _rowIconWidth;
        if (selected) rowWidth += _rowCheckWidth;
        painter.dispose();
        if (rowWidth > contentWidth) contentWidth = rowWidth;
        height += _rowTotalHeight;
    }
  }

  // 与 _GlassMenuLayout.getConstraintsForChild 用同一套公式算可用高度，
  // 保证这里量出来的尺寸不会比真正落地时的约束更宽松。
  final Size screen = MediaQuery.sizeOf(anchorContext);
  final EdgeInsets padding = MediaQuery.paddingOf(anchorContext);
  final double belowSpace =
      screen.height - anchorRect.bottom - _anchorGap - padding.bottom;
  final double aboveSpace = anchorRect.top - _anchorGap - padding.top;
  final double maxAvailableHeight = math.max(
    _rowHeight,
    math.max(belowSpace, aboveSpace),
  );

  final double width = (contentWidth + _panelWidthSlack).clamp(
    minWidth,
    maxWidth,
  );
  return Size(width, math.min(height, maxAvailableHeight));
}

/// 贴着 [anchorContext] 对应的控件弹出一张玻璃菜单，返回被选中项的值
/// （点空白关闭时返回 null）。
///
/// [anchorContext] 必须是**触发件自身**的 context（`Builder` 包一层最省事），
/// 落点和材质档位都是从它身上量出来的。
/// [touchFlex]：面板是否接入 [GlassTokens.liquidFlex]（长按跟手拉伸）。
/// 只在液态档下有意义，传统档忽略。默认关闭——不是每个菜单都该动，
/// 调用方按场景显式打开；实际能否生效还取决于 [_measureMenuPanelSize]
/// 能不能静态量出尺寸（见其说明）。
Future<T?> showGlassMenu<T>({
  required BuildContext anchorContext,
  required List<GlassMenuEntry> entries,
  double minWidth = _minPanelWidth,
  double maxWidth = _maxPanelWidth,
  bool touchFlex = false,
}) {
  final anchorBox = anchorContext.findRenderObject();
  final navigator = Navigator.of(anchorContext, rootNavigator: true);
  final overlayBox = navigator.overlay?.context.findRenderObject();
  if (anchorBox is! RenderBox || overlayBox is! RenderBox) {
    return Future<T?>.value();
  }

  final Offset topLeft = anchorBox.localToGlobal(
    Offset.zero,
    ancestor: overlayBox,
  );
  final Rect anchorRect = topLeft & anchorBox.size;

  final Size? precomputedSize = _measureMenuPanelSize(
    anchorContext: anchorContext,
    entries: entries,
    anchorRect: anchorRect,
    minWidth: minWidth,
    maxWidth: maxWidth,
  );

  return navigator.push(
    _GlassMenuRoute<T>(
      entries: entries,
      anchorRect: anchorRect,
      minWidth: minWidth,
      maxWidth: maxWidth,
      touchFlex: touchFlex && precomputedSize != null,
      precomputedSize: precomputedSize,
      // 关键：材质档位在这里就地取样，因为路由本身不在页面子树里。
      liquid: LiquidGlassScope.isEnabled(anchorContext),
      capturedThemes: InheritedTheme.capture(
        from: anchorContext,
        to: navigator.context,
      ),
      barrierLabel: MaterialLocalizations.of(
        anchorContext,
      ).modalBarrierDismissLabel,
    ),
  );
}

class _GlassMenuRoute<T> extends PopupRoute<T> {
  _GlassMenuRoute({
    required this.entries,
    required this.anchorRect,
    required this.minWidth,
    required this.maxWidth,
    required this.liquid,
    required this.touchFlex,
    required this.precomputedSize,
    required this.capturedThemes,
    required this.barrierLabel,
  });

  final List<GlassMenuEntry> entries;
  final Rect anchorRect;
  final double minWidth;
  final double maxWidth;
  final bool liquid;

  /// 已经是 `precomputedSize != null` 之后的最终结果（见 [showGlassMenu]）。
  final bool touchFlex;

  /// [_measureMenuPanelSize] 静态量出的精确尺寸；量不出来时为 null。
  /// [touchFlex] 为 true 时必非 null，但反过来不成立——不开 touch 的菜单也会
  /// 量，出入场的起手缩放要用（见 [_revealBeginScale]）。
  final Size? precomputedSize;
  final CapturedThemes capturedThemes;

  @override
  final String barrierLabel;

  @override
  bool get barrierDismissible => true;

  /// 不压暗底层：菜单是个轻量弹层，压一层黑纱会让它读起来像弹窗。
  @override
  Color? get barrierColor => null;

  @override
  Duration get transitionDuration => _enterDuration(entries.length);

  @override
  Duration get reverseTransitionDuration => _exitDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Size screen = MediaQuery.sizeOf(context);
    final bool flipped = _opensUpward(
      anchorRect: anchorRect,
      screenHeight: screen.height,
    );
    final Widget panel = _GlassMenuPanel<T>(
      entries: entries,
      onSelected: (value) => Navigator.of(context).pop(value),
      touchFlex: touchFlex,
      precomputedSize: precomputedSize,
      // 出入场长在面板内部而不是 buildTransitions 里，理由见该处注释。
      animation: animation,
      revealOrigin: _revealOrigin(
        anchorRect: anchorRect,
        screen: screen,
        flipped: flipped,
      ),
      revealBeginScale: _revealBeginScale(
        anchor: anchorRect,
        panel: precomputedSize,
      ),
      flipped: flipped,
    );
    return capturedThemes.wrap(
      LiquidGlassScope(
        enabled: liquid,
        child: CustomSingleChildLayout(
          delegate: _GlassMenuLayout(
            anchorRect: anchorRect,
            minWidth: minWidth,
            maxWidth: maxWidth,
            padding: MediaQuery.paddingOf(context),
          ),
          child: panel,
        ),
      ),
    );
  }

  /// 出入场**不在这里做**，而是长在 [_GlassMenuPanel] 内部（见文件头
  /// 「出入场」一节）。两条理由：
  ///   1. 这一层拿到的 `child` 是铺满全屏的布局代理，缩放只能绕屏幕上的某个
  ///      点转，绕不到面板自己的锚点角；
  ///   2. 这里包任何 `Opacity` / `FadeTransition` 都会 `saveLayer`，把液态档
  ///      lens 的 backdrop 采样隔断——那正是「文字先出现、玻璃后到」的成因。
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// 下方剩余空间连两行都摆不下时翻到上方弹。
///
/// 只是个**给动画用的**粗判：真正的落点由 [_GlassMenuLayout] 按面板实测高度
/// 算。两者用同一个阈值，所以除非面板高度正好卡在边界上，缩放锚点不会跟落点
/// 打架。
bool _opensUpward({required Rect anchorRect, required double screenHeight}) {
  final double below = screenHeight - anchorRect.bottom - _anchorGap;
  final double above = anchorRect.top - _anchorGap;
  return below < _rowHeight * 2 && above > below;
}

/// 面板落点：触发件正下方、左对齐、夹进屏幕；下方摆不下就翻到上方。
class _GlassMenuLayout extends SingleChildLayoutDelegate {
  const _GlassMenuLayout({
    required this.anchorRect,
    required this.minWidth,
    required this.maxWidth,
    required this.padding,
  });

  final Rect anchorRect;
  final double minWidth;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double belowSpace =
        constraints.maxHeight - anchorRect.bottom - _anchorGap - padding.bottom;
    final double aboveSpace = anchorRect.top - _anchorGap - padding.top;
    // 面板最高只能吃掉它那一侧的可用高度——超了就在面板内部滚，而不是
    // 整块板越到屏幕外面去。
    final double maxHeight = math.max(
      _rowHeight,
      math.max(belowSpace, aboveSpace),
    );
    return BoxConstraints(
      minWidth: math.min(minWidth, constraints.maxWidth - _screenMargin * 2),
      maxWidth: math.min(maxWidth, constraints.maxWidth - _screenMargin * 2),
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // 横向：与触发件左边缘对齐，越界后整块夹回屏幕内（与旧的
    // PopupMenuButton(position: under) 同一套算法）。
    final double x = (anchorRect.left).clamp(
      _screenMargin,
      math.max(_screenMargin, size.width - childSize.width - _screenMargin),
    );

    final double belowTop = anchorRect.bottom + _anchorGap;
    final bool fitsBelow =
        belowTop + childSize.height <= size.height - padding.bottom;
    final double y = fitsBelow
        ? belowTop
        : math.max(
            padding.top + _screenMargin,
            anchorRect.top - _anchorGap - childSize.height,
          );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_GlassMenuLayout oldDelegate) =>
      anchorRect != oldDelegate.anchorRect ||
      minWidth != oldDelegate.minWidth ||
      maxWidth != oldDelegate.maxWidth ||
      padding != oldDelegate.padding;
}

/// 面板本体：一块玻璃 + 里头一列行，外加整套出入场（见文件头「出入场」一节）。
///
/// [touchFlex] 打开时接入 [GlassTokens.liquidFlex]，这时 [precomputedSize]
/// 必须非空——[_measureMenuPanelSize] 已经在 [showGlassMenu] 里静态量出了
/// 精确尺寸，这里直接钉死喂给 [GlassSurface]，touch 从第一帧就生效，不需要
/// 「先按自然尺寸布局、量完再补 touch」的两段式（那样会让 lens 中途从
/// touch:null 切到非 null，读起来是「文字先出现，液态玻璃背景才跟上来」的
/// 一次可感知的重初始化，见 [_measureMenuPanelSize] 的说明）。
///
/// 出入场只动 [Transform] 与 [GlassSurface.materialize]，**全程不建透明度层**，
/// 所以尺寸也全程不变——这正好和上面那条「尺寸必须钉死」对得上：卷开是画出来
/// 的，不是布局出来的。
class _GlassMenuPanel<T> extends StatefulWidget {
  const _GlassMenuPanel({
    required this.entries,
    required this.onSelected,
    required this.animation,
    required this.revealOrigin,
    required this.revealBeginScale,
    required this.flipped,
    this.touchFlex = false,
    this.precomputedSize,
  });

  final List<GlassMenuEntry> entries;
  final ValueChanged<T> onSelected;
  final bool touchFlex;
  final Size? precomputedSize;

  /// 路由的出入场动画（0→1 入场，1→0 出场）。
  final Animation<double> animation;

  /// 面板形变绕哪个角转（见 [_revealOrigin]）。
  final Alignment revealOrigin;

  /// 入场起手的横 / 纵向缩放（见 [_revealBeginScale]）。
  final Offset revealBeginScale;

  /// 面板是否翻到了触发件上方：帘子改成自下而上卷，条目也倒着现身。
  final bool flipped;

  @override
  State<_GlassMenuPanel<T>> createState() => _GlassMenuPanelState<T>();
}

class _GlassMenuPanelState<T> extends State<_GlassMenuPanel<T>> {
  /// 面板的「形」：从触发件那么大撑到成品尺寸。
  late final CurvedAnimation _shape;

  /// 面板的「质」：色调 / 描边 / 投影的透明度。
  late final CurvedAnimation _material;

  @override
  void initState() {
    super.initState();
    _shape = CurvedAnimation(
      parent: widget.animation,
      curve: GlassTokens.motionCurve,
      // 出场也用 easeOutCubic：反着跑时它「前半程几乎不动、最后一口收干净」，
      // 正好让内容先撤空、面板再缩回按钮，而不是一上来就塌下去。
      reverseCurve: GlassTokens.motionCurve,
    );
    _material = CurvedAnimation(
      parent: widget.animation,
      // 入场：色调在前 38% 就上满——玻璃要比字先到位。
      curve: const Interval(0, 0.38, curve: Curves.easeOut),
      // 出场：撑到一半才开始化，收回去的过程里它仍然是块玻璃；区间取得比入场
      // 宽，是为了让「入场没跑完就被点掉」时两条曲线在同一个 v 上接得上。
      reverseCurve: const Interval(0, 0.5, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _shape.dispose();
    _material.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> starts = _entryRevealStarts(
      widget.entries,
      flipped: widget.flipped,
    );
    final double shift = widget.flipped
        ? _entryRevealShift
        : -_entryRevealShift;

    final List<Widget> rows = <Widget>[];
    for (var i = 0; i < widget.entries.length; i++) {
      final GlassMenuEntry entry = widget.entries[i];
      final Widget row = switch (entry) {
        GlassMenuSeparator() => const _GlassMenuSeparatorLine(),
        GlassMenuOption<T>(:final value) => _GlassMenuRow(
          option: entry,
          onTap: () => widget.onSelected(value),
        ),
        // 条目泛型与菜单泛型对不上（调用方写错了）：渲染成不可点的
        // 行，而不是整张面板炸掉。
        GlassMenuOption() => _GlassMenuRow(option: entry, onTap: null),
      };
      rows.add(
        _GlassMenuEntryReveal(
          animation: widget.animation,
          start: starts[i],
          shift: shift,
          child: row,
        ),
      );
    }

    final Size? size = widget.touchFlex ? widget.precomputedSize : null;
    // 内容只建这一次，靠 AnimatedBuilder 的 child 透传下去：每帧重建的只有
    // 外层形变盒和玻璃本身，行的淡入各自在自己的 AnimatedBuilder 里跑。
    final Widget body = Padding(
      padding: const EdgeInsets.symmetric(vertical: _panelVerticalPadding / 2),
      // 宽度贴最宽的一行（下限/上限由外层布局代理的约束卡住）；
      // IntrinsicWidth 必须在滚动容器**外面**：Material 自己的 _PopupMenu
      // 也是这个顺序，反过来套 intrinsic 传不下去。
      child: IntrinsicWidth(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        ),
      ),
    );

    return AnimatedBuilder(
      animation: widget.animation,
      child: body,
      builder: (context, child) {
        final double p = _shape.value;
        final double sx =
            widget.revealBeginScale.dx +
            (1 - widget.revealBeginScale.dx) * p;
        final double sy =
            widget.revealBeginScale.dy +
            (1 - widget.revealBeginScale.dy) * p;
        return Transform(
          alignment: widget.revealOrigin,
          transform: Matrix4.diagonal3Values(sx, sy, 1),
          child: GlassSurface(
            // 高度按内容走：菜单有几行就多高，超出由内部滚动兜住。touchFlex 时
            // 换成静态量出的精确值，满足 liquidTouch 的约束要求。
            height: size?.height,
            width: size?.width,
            borderRadius: BorderRadius.circular(_panelRadius),
            clipContent: true,
            liquidTouch: size != null,
            materialize: _material.value,
            child: Transform(
              // 反着缩回去：玻璃在卷开，内容按自然尺寸留在原地，还没卷到的
              // 部分由玻璃自己的形状裁掉（Telegram 也是这么干的——背景在改
              // 尺寸，条目并不跟着变形，只是被一条条露出来）。
              alignment: widget.revealOrigin,
              transform: Matrix4.diagonal3Values(1 / sx, 1 / sy, 1),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// 一条菜单项的错峰现身：帘子扫到它，它才淡入并归位（Telegram
/// `startChildAnimation` 那一下：alpha 0→1 配一小段位移）。
///
/// 出场不错峰——整块内容一起先撤走，面板随后才收回去，和 Telegram 的 dismiss
/// 同一个读法。这里的 [Opacity] 建在玻璃**内部**，透明度层落在 backdrop 采样
/// 之后，不会像包在整块面板外面那样把折射打断。
class _GlassMenuEntryReveal extends StatelessWidget {
  const _GlassMenuEntryReveal({
    required this.animation,
    required this.start,
    required this.shift,
    required this.child,
  });

  final Animation<double> animation;

  /// 入场进度里这条开始现身的位置（0–1，见 [_entryRevealStarts]）。
  final double start;

  /// 现身时的起手位移（朝触发件那一侧），随进度归零。
  final double shift;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final double t = _progress;
        // 到位后连透明度层和形变盒一起撤掉，静止态不留任何额外的层。
        if (t >= 1) return child!;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, shift * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  double get _progress {
    final double v = animation.value;
    if (animation.status == AnimationStatus.reverse) {
      // 出场不错峰：整块内容一起淡走（Telegram 的 dismiss 也是整窗一起淡）。
      // 用不带区间的 easeOut 还有一层好处——入场没跑完就被点掉时，它和下面
      // 那条错峰曲线在同一个 v 上取值相近，不会「啪」地跳一下。
      return Curves.easeOut.transform(v);
    }
    return GlassTokens.motionCurve.transform(
      ((v - start) / (1 - start)).clamp(0.0, 1.0),
    );
  }
}

class _GlassMenuSeparatorLine extends StatelessWidget {
  const _GlassMenuSeparatorLine();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Container(height: 1, color: GlassTokens.stroke(cs)),
    );
  }
}

/// 一行菜单项。
///
/// 悬停 / 按下的高亮自绘（不走 Material 水波，理由见文件头），并且用
/// [AnimatedContainer] 走 [GlassTokens.pressDuration]——和玻璃按钮按下去
/// 的那一下是同一段时值。
class _GlassMenuRow extends StatefulWidget {
  const _GlassMenuRow({required this.option, required this.onTap});

  final GlassMenuOption<dynamic> option;
  final VoidCallback? onTap;

  @override
  State<_GlassMenuRow> createState() => _GlassMenuRowState();
}

class _GlassMenuRowState extends State<_GlassMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final option = widget.option;
    final bool enabled = option.enabled && widget.onTap != null;

    final Color fg = !enabled
        ? cs.onSurface.withValues(alpha: 0.38)
        : option.destructive
        ? cs.error
        : option.selected
        ? cs.primary
        : cs.onSurface;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GlassPressable(
        enabled: enabled,
        onTap: widget.onTap,
        // 整行缩放会让面板看着在抖；行的反馈只用底色。
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: _rowHeight,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: !enabled
                ? Colors.transparent
                : pressed
                ? cs.onSurface.withValues(alpha: 0.10)
                : _hovered
                ? cs.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (option.leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(size: 20, color: fg),
                  child: option.leading!,
                ),
                const SizedBox(width: 12),
              ] else if (option.icon != null) ...[
                Icon(option.icon, size: 20, color: fg),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: fg,
                    fontWeight: option.selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (option.selected) ...[
                const SizedBox(width: 12),
                Icon(Icons.check, size: 18, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
