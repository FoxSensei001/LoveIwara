import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';

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
/// 档位（[LiquidGlassScope.of]），再在面板外面重新供上：**玻璃胶囊弹出
/// 玻璃菜单，传统胶囊弹出传统菜单**，一条链上不会出现两种材质。
///
/// ## ⛔ 菜单钉死在 easy 那一档，不跟着 chrome 走
///
/// 页面 chrome 从 2026-08-23 起换到了 `liquid_glass_widgets`
/// （[kChromeGlassBackend]），**菜单没跟**——见 [panelGlassBackend]。理由是本文件
/// 下面那整套「卷开」出入场和面板质感都是照 easy 的 lens 逐帧调出来的：
/// 起手缩放绕锚点角、`materialize` 的 0 端「只剩折射与边缘光的清玻璃」、
/// 条目错峰的 alpha 落在 backdrop 采样之后……换一套 shader 这些标定值全要
/// 重来。用户也是分别评价的：chrome 那边换新包更好，菜单这边现状就很好。
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
///
/// ## 滑动取焦：按住不放，焦点跟着手指走
///
/// 参照 `sdegenaar/liquid_glass_widgets` 的 `GlassMenu`：**手指按在面板上就有
/// 一块焦点底板贴上来，不抬手直接上下划，底板会滑到手指底下那一条上**，松手
/// 即选中。它把「瞄准→点」拆成了「按下→挪→松手」——一次触摸就能改主意，
/// 不用抬手重来，这在单手够不着的位置上尤其好使。
///
/// 落到本文件是这么分工的：
///   - **底板**（[_GlassMenuPanelState._buildFocusPill]）是 [Stack] 里一块
///     [AnimatedPositioned]，跟行的按压底色长得一模一样（同一个圆角、同一族
///     底色），行高全是静态常量（[_entryTops]），不需要量。起手那一下直接落在
///     手指底下（`duration: Duration.zero`），之后每换一条才滑过去。
///   - **手势**走一层 [Listener]，它只旁听、不进手势竞技场，所以行自己的
///     [GlassPressable] 照常处理普通点按。两条路按位移分家：抬手时位移没过
///     [kTouchSlop] 的算点按（让 `GlassPressable` 出手），过了的算滑动取焦
///     （这时 tap 已被竞技场判负，只剩这一条路），谁都不会选中两遍。
///   - **底板亮起时行不再画自己的按压/悬停底色**，免得同一条上叠两层。
///
/// > 底板的显隐只压底色的 alpha，不套 `Opacity`——理由同上面那条折射告警。
///
/// ### 内容长到能滚起来时，滑动取焦整只让位
///
/// 参考实现里也是这么切的：同一个纵向拖拽不可能既滚列表又换焦点，抢起来两边
/// 都别扭。所以面板一旦滚得动（[_GlassMenuPanelState._isScrollable]，拿
/// [ScrollController] 实测而不是按行高估），按下去就不进滑动取焦这条路——
/// 拖拽还给滚动，选中还给行自己的点按。

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
    this.onLongPress,
    this.selected = false,
    this.destructive = false,
    this.enabled = true,
  });

  /// 选中后由 [showGlassMenu] 返回的值。
  final T value;

  final String label;
  final IconData? icon;

  /// 行首的自定义控件，用在图标不是 [IconData] 的场合（排序项自带 `Widget` 图标、
  /// 用户头像……）。给了它就顶掉 [icon]。
  ///
  /// 它被塞进一个**固定 [_rowLeadingSize] 见方的槽位**并包一层 [IconTheme]
  /// （里面的 `Icon` 自动跟行的语义色走）。固定槽位有两层意思：与纯图标行
  /// 左对齐；以及让 [_measureMenuPanelSize] 能静态量出行宽——量不出来就开不了
  /// 跟手形变（见那个函数的说明）。所以**别在 leading 里塞会自己撑开的控件**。
  final Widget? leading;

  /// 长按这一条。给了它的菜单会**整只关掉滑动取焦**——同一次按住不可能既是
  /// 「划过去换焦点」又是「按住不动触发长按」，两个手势抢起来两边都不准
  /// （与「内容滚得动时让位」是同一条规矩，见 `_GlassMenuPanelState`）。
  ///
  /// 长按后菜单会关闭并返回 null——长按是**离开这张菜单去别处**的动作
  /// （典型：长按用户跳作者主页），不是选中。
  final VoidCallback? onLongPress;

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
const double _rowMarginHorizontal = 6; // AnimatedContainer margin: horizontal
const double _rowRadius = 12; // AnimatedContainer 的圆角，焦点底板要对齐它
const double _rowTotalHeight = _rowHeight + _rowMarginVertical * 2;
const double _rowHorizontalChrome =
    _rowMarginHorizontal * 2 /* margin */ + 12 * 2 /* padding */;
const double _rowIconWidth = 20 + 12; // icon + gap

/// [GlassMenuOption.leading] 的固定槽位边长。比纯图标（20）大一点点，让头像
/// 一类内容不至于太小，光学中心又与图标行对齐；固定死是为了行宽能被
/// [_measureMenuPanelSize] 静态量出来。
const double _rowLeadingSize = 22;
const double _rowLeadingWidth = _rowLeadingSize + 12; // leading + gap
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

/// 一条在面板内容里占的纵向高度。
double _entryHeight(GlassMenuEntry entry) =>
    entry is GlassMenuSeparator ? _separatorHeight : _rowTotalHeight;

/// 每条在**滚动内容坐标系**里的纵向起点：面板自己的上下留白加在滚动容器外面，
/// 所以第一条从 0 开始。
///
/// 行高全是静态常量（[_rowTotalHeight] / [_separatorHeight]），所以这里不像
/// [_measureMenuPanelSize] 那样会量不出来，自定义 `leading` 的条目一样适用——
/// 出入场的逐条点火（[_entryRevealStarts]）和滑动取焦的命中判定
/// （`_GlassMenuPanelState._entryAt`）都吃这一份几何。
List<double> _entryTops(List<GlassMenuEntry> entries) {
  final List<double> tops = <double>[];
  double y = 0;
  for (final entry in entries) {
    tops.add(y);
    y += _entryHeight(entry);
  }
  return tops;
}

/// 每条的入场起点：按它在面板里的纵向位置折算——帘子扫到谁，谁才开始现身
/// （Telegram `setBackScaleY` 里那套逐条点火）。翻到上方弹时帘子自下而上卷，
/// 顺序跟着反过来。
List<double> _entryRevealStarts(
  List<GlassMenuEntry> entries, {
  required bool flipped,
}) {
  if (entries.isEmpty) return const <double>[];
  final List<double> tops = _entryTops(entries);
  final double total =
      tops.last + _entryHeight(entries.last) + _panelVerticalPadding;
  if (total <= 0) return List<double>.filled(entries.length, 0);
  final List<double> starts = <double>[];
  for (final double top in tops) {
    // tops 是内容坐标，折算成整块面板里的位置要补回上留白。
    final double y = top + _panelVerticalPadding / 2;
    starts.add(
      ((flipped ? total - y : y) / total).clamp(0.0, 1.0) * _entryRevealSpan,
    );
  }
  return starts;
}

// ---- 滑动取焦（见文件头「滑动取焦」一节）----

/// 焦点底板滑到下一条要多久。比行自己的按压时值（[GlassTokens.pressDuration]，
/// 120）长一档：它是在「走过去」，不是原地亮一下。
const Duration _focusSlideDuration = Duration(milliseconds: 170);

/// 焦点底板的显隐时长。
const Duration _focusFadeDuration = Duration(milliseconds: 130);

/// 手指横向可以荡出面板多远仍算留在这一条上。竖着划的时候手指本来就会左右飘，
/// 卡死在面板边上会让焦点一闪一闪。
const double _focusHorizontalSlack = 40;

/// 手指纵向可以越过首/末条多远仍算吃着那一条。取得比面板自己的上下留白
/// （[_panelVerticalPadding] 的一半，6）宽一点：划到最后一条上再往下多走一像素
/// 就丢焦点太脆，而末条恰恰是最常划到的目标。越过这段才算划出去＝取消。
const double _focusVerticalSlack = 12;

/// 焦点底板满显时的底色浓度。取得比行自己的按压底色（0.10）深一档——滑动取焦
/// 时它是唯一的反馈，得压得住。
const double _focusFillAlpha = 0.12;

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
/// [GlassMenuOption.leading] 也能量：它被塞进一个固定 [_rowLeadingSize] 见方的
/// 槽位（见那个字段的说明），宽度贡献和纯图标一样是常数。
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
        if (leading != null) {
          rowWidth += _rowLeadingWidth;
        } else if (icon != null) {
          rowWidth += _rowIconWidth;
        }
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
/// [touchFlex]：面板是否接入跟手形变（按住拖动时整块面板顺着手指拉伸、松手
/// 弹回）。只在液态档下有意义，传统档忽略。**默认开**——跟手是这套材质的基本
/// 手感，不该由每个调用点各自决定（同 [GlassSurface.liquidTouch]）。实际能否
/// 生效还取决于 [_measureMenuPanelSize] 能不能静态量出尺寸（见其说明）。
Future<T?> showGlassMenu<T>({
  required BuildContext anchorContext,
  required List<GlassMenuEntry> entries,
  double minWidth = _minPanelWidth,
  double maxWidth = _maxPanelWidth,
  bool touchFlex = true,
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

  // 关键：材质档位在这里就地取样，因为路由本身不在页面子树里。
  final GlassBackend backend = panelGlassBackend(anchorContext);

  return navigator.push(
    _GlassMenuRoute<T>(
      entries: entries,
      anchorRect: anchorRect,
      minWidth: minWidth,
      maxWidth: maxWidth,
      // 传统档整只不开：那一档本来就没有跟手形变，而开着会把面板从「有几行
      // 就多高、多宽」改成静态量出来的钉死尺寸（[_measureMenuPanelSize] 是
      // 用 TextPainter 离线量的，与真实排版有一两像素出入）。既然拿不到好处，
      // 就别把这点误差引进去。
      touchFlex:
          touchFlex && precomputedSize != null && backend != GlassBackend.plain,
      precomputedSize: precomputedSize,
      backend: backend,
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
    required this.backend,
    required this.touchFlex,
    required this.precomputedSize,
    required this.capturedThemes,
    required this.barrierLabel,
  });

  final List<GlassMenuEntry> entries;
  final Rect anchorRect;
  final double minWidth;
  final double maxWidth;

  /// 面板自己的材质档（已经过 [panelGlassBackend] 折算）。
  final GlassBackend backend;

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
      onDismissed: () => Navigator.of(context).pop(),
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
        backend: backend,
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
    required this.onDismissed,
    required this.animation,
    required this.revealOrigin,
    required this.revealBeginScale,
    required this.flipped,
    this.touchFlex = false,
    this.precomputedSize,
  });

  final List<GlassMenuEntry> entries;
  final ValueChanged<T> onSelected;

  /// 关掉面板但不返回任何值（长按走这条，见 [GlassMenuOption.onLongPress]）。
  final VoidCallback onDismissed;

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

class _GlassMenuPanelState<T> extends State<_GlassMenuPanel<T>>
    with SingleTickerProviderStateMixin {
  /// 面板的「形」：从触发件那么大撑到成品尺寸。
  late final CurvedAnimation _shape;

  /// 面板的「质」：色调 / 描边 / 投影的透明度。
  late final CurvedAnimation _material;

  // ---- 滑动取焦（见文件头「滑动取焦」一节）----

  /// 内容的滚动位置。既用来实测面板滚不滚得动（[_isScrollable]），也是
  /// [_entryAt] 的坐标基准——[Listener] 挂在滚动内容**里面**，拿到的
  /// `localPosition` 天然就是内容坐标，不用再减一次 offset。
  final ScrollController _scroll = ScrollController();

  /// 内容层的 key，用来读它的实际宽度（[_contentWidth]）。
  final GlobalKey _contentKey = GlobalKey();

  /// 焦点底板的显隐（0 = 没有，1 = 满显）。
  late final AnimationController _focusFade;

  /// 手指当前落在哪一条上。null = 手指荡到面板外面或落在分隔线/禁用行上。
  int? _focusIndex;

  /// 底板画在哪一条上。焦点消失时**保留**上一条，让它原地淡出，而不是瞬移
  /// 回顶上再消失。
  int? _pillIndex;

  /// 这次换位要不要滑过去：按下那一下直接落在手指底下，之后才是滑。
  bool _pillSlides = false;

  /// 正在滑动取焦。这期间行不画自己的按压/悬停底色，反馈统一交给底板。
  bool _sliding = false;

  /// 正在追的那根手指。多指同时按面板时只认第一根。
  int? _pointer;
  Offset _pointerDownAt = Offset.zero;

  /// 已经选过了。滑动取焦在 `onPointerUp` 里出手，比手势竞技场清算 tap 早一步；
  /// 万一两条路都走通，pop 两次会把底下的页面一起关掉，这道闸拦住。
  bool _selected = false;

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
    _focusFade = AnimationController(
      vsync: this,
      duration: _focusFadeDuration,
    );
  }

  @override
  void dispose() {
    _shape.dispose();
    _material.dispose();
    _focusFade.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// 所有选中都从这里出去：滑动取焦和行自己的点按共用一条出口，只放行一次。
  void _select(T value) {
    if (_selected) return;
    _selected = true;
    widget.onSelected(value);
  }

  /// 长按走的出口：关面板（返回 null）之后再跑 [action]。
  ///
  /// 顺序不能反——[action] 往往是一次跳转（长按用户去作者主页），先跳再关
  /// 会让菜单的退场动画和路由推入叠在一起。
  void _selectNothingThen(VoidCallback action) {
    if (_selected) return;
    _selected = true;
    widget.onDismissed();
    action();
  }

  // ---- 滑动取焦 ----

  /// 内容已经超出可用高度、变成一条可滚的列表。
  ///
  /// 拿 [ScrollController] 实测而不是按行高估：估算要复刻一遍布局约束
  /// （[_GlassMenuLayout.getConstraintsForChild]），差一像素就会把两种交互
  /// 判反。滚得动的时候滑动取焦整只让位，理由见文件头。
  bool get _isScrollable =>
      _scroll.hasClients &&
      _scroll.position.hasContentDimensions &&
      _scroll.position.maxScrollExtent > 0;

  /// 有条目带 [GlassMenuOption.onLongPress]：滑动取焦整只让位。
  ///
  /// 与「滚得动时让位」同一条规矩——同一次按住不可能既是「划过去换焦点」
  /// 又是「按住不动等长按」：焦点底板会在长按计时的这 500ms 里一直贴着，
  /// 松手时两条路都认为该由自己出手。菜单只能二选一，谁被显式声明了就归谁。
  bool get _hasLongPressEntry => widget.entries.any(
    (e) => e is GlassMenuOption && e.onLongPress != null,
  );

  /// 内容层的实际宽度，用来判断手指有没有横向荡出去。
  double get _contentWidth =>
      _contentKey.currentContext?.size?.width ?? double.infinity;

  bool _isSelectable(GlassMenuEntry entry) =>
      entry is GlassMenuOption<T> && entry.enabled;

  /// 内容坐标 → 条目下标。落在分隔线、禁用行或面板外面时返回 null。
  int? _entryAt(Offset local, double width) {
    if (widget.entries.isEmpty) return null;
    if (local.dx < -_focusHorizontalSlack ||
        local.dx > width + _focusHorizontalSlack) {
      return null;
    }
    final List<double> tops = _entryTops(widget.entries);
    final double contentHeight =
        tops.last + _entryHeight(widget.entries.last);
    // 越过首/末条一小段仍按首/末条算（见 [_focusVerticalSlack]）。
    double dy = local.dy;
    if (dy < 0) {
      if (dy < -_focusVerticalSlack) return null;
      dy = 0;
    } else if (dy >= contentHeight) {
      if (dy > contentHeight + _focusVerticalSlack) return null;
      dy = contentHeight - 1;
    }
    for (var i = 0; i < widget.entries.length; i++) {
      final GlassMenuEntry entry = widget.entries[i];
      if (dy < tops[i] || dy >= tops[i] + _entryHeight(entry)) continue;
      return _isSelectable(entry) ? i : null;
    }
    return null;
  }

  void _setFocus(int? index, {required bool haptic}) {
    if (index == _focusIndex) return;
    if (index != null && haptic) {
      VibrateUtils.vibrate(type: HapticFeedback.selectionClick);
    }
    setState(() {
      _focusIndex = index;
      // 只往非空的位置搬：焦点消失时底板留在原地淡出。
      if (index != null) _pillIndex = index;
    });
    if (index == null) {
      _focusFade.reverse();
    } else {
      _focusFade.forward();
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pointer != null || _selected || _isScrollable || _hasLongPressEntry) {
      return;
    }
    _pointer = event.pointer;
    _pointerDownAt = event.localPosition;
    setState(() {
      _sliding = true;
      // 起手不滑：底板直接落在手指底下。
      _pillSlides = false;
    });
    _setFocus(_entryAt(event.localPosition, _contentWidth), haptic: false);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    _pillSlides = true;
    _setFocus(_entryAt(event.localPosition, _contentWidth), haptic: true);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    final int? target = _focusIndex;
    // 位移没过 [kTouchSlop] 的是**普通点按**：行自己的 GlassPressable 会在
    // 竞技场清算时出手（清算排在 Listener 之后），这里必须让开，否则一次点按
    // 会选中两遍。过了 slop 的话 tap 早已被判负，只剩这条路。
    final bool dragged =
        (event.localPosition - _pointerDownAt).distance > kTouchSlop;
    _endSlide();
    if (!dragged || target == null) return;
    final GlassMenuEntry entry = widget.entries[target];
    if (entry is GlassMenuOption<T> && entry.enabled) {
      VibrateUtils.vibrate();
      _select(entry.value);
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _pointer) return;
    _endSlide();
  }

  void _endSlide() {
    _pointer = null;
    setState(() {
      _sliding = false;
      _focusIndex = null;
    });
    _focusFade.reverse();
  }

  /// 焦点底板：跟行的按压底色同一个圆角、同一族底色，位置按静态行高算
  /// （[_entryTops]）。
  Widget _buildFocusPill(BuildContext context, List<double> tops) {
    final int? index = _pillIndex;
    final double v = _focusFade.value;
    if (index == null || index >= tops.length || v <= 0) {
      return const SizedBox.shrink();
    }
    final ColorScheme cs = Theme.of(context).colorScheme;
    return AnimatedPositioned(
      duration: _pillSlides ? _focusSlideDuration : Duration.zero,
      curve: GlassTokens.motionCurve,
      left: _rowMarginHorizontal,
      right: _rowMarginHorizontal,
      top: tops[index] + _rowMarginVertical,
      height: _rowHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // 显隐只压底色的 alpha，不套 Opacity——透明度层会把液态档的折射
          // 打断（见文件头）。
          color: cs.onSurface.withValues(alpha: _focusFillAlpha * v),
          borderRadius: BorderRadius.circular(_rowRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<double> tops = _entryTops(widget.entries);
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
        GlassMenuOption<T>(:final value, :final onLongPress) => _GlassMenuRow(
          option: entry,
          slideActive: _sliding,
          onTap: () => _select(value),
          // 长按是「离开这张菜单去别处」，不是选中：关掉面板并返回 null，
          // 再把动作交出去（见 [GlassMenuOption.onLongPress]）。
          onLongPress: onLongPress == null
              ? null
              : () => _selectNothingThen(onLongPress),
        ),
        // 条目泛型与菜单泛型对不上（调用方写错了）：渲染成不可点的
        // 行，而不是整张面板炸掉。
        GlassMenuOption() => _GlassMenuRow(
          option: entry,
          slideActive: _sliding,
          onTap: null,
        ),
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
          controller: _scroll,
          // 钉死 clamping，不跟平台走。iOS 默认的 BouncingScrollPhysics 把
          // `shouldAcceptUserOffset` 恒真，内容明明摆得下也照样吃掉纵向拖拽
          // ——滑动取焦会一边换焦点、一边把内容拽出橡皮筋。clamping 在内容
          // 摆得下时直接不装拖拽识别器，这条手势干干净净归滑动取焦；真滚起来
          // 时也不回弹，正好配面板这块被裁过的玻璃。
          physics: const ClampingScrollPhysics(),
          // Listener 挂在滚动内容**里面**：拿到的 localPosition 直接就是内容
          // 坐标，底板和命中判定共用一套几何，不用再跟 offset 对账。它只旁听、
          // 不进手势竞技场，行自己的点按照常走（见文件头「滑动取焦」一节）。
          child: Listener(
            key: _contentKey,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerUp,
            onPointerCancel: _handlePointerCancel,
            child: Stack(
              children: <Widget>[
                // 底板在行底下：只有它随 _focusFade 每帧重画，行列不跟着。
                AnimatedBuilder(
                  animation: _focusFade,
                  builder: (context, _) => _buildFocusPill(context, tops),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows,
                ),
              ],
            ),
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
  const _GlassMenuRow({
    required this.option,
    required this.onTap,
    this.onLongPress,
    this.slideActive = false,
  });

  final GlassMenuOption<dynamic> option;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 面板正在滑动取焦：底色让位给焦点底板，免得同一条上叠两层
  /// （见文件头「滑动取焦」一节）。
  final bool slideActive;

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
        onLongPress: enabled ? widget.onLongPress : null,
        // 整行缩放会让面板看着在抖；行的反馈只用底色。
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: _rowHeight,
          margin: const EdgeInsets.symmetric(
            horizontal: _rowMarginHorizontal,
            vertical: _rowMarginVertical,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: !enabled || widget.slideActive
                ? Colors.transparent
                : pressed
                ? cs.onSurface.withValues(alpha: 0.10)
                : _hovered
                ? cs.onSurface.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_rowRadius),
          ),
          child: Row(
            children: [
              if (option.leading != null) ...[
                SizedBox.square(
                  dimension: _rowLeadingSize,
                  child: Center(
                    child: IconTheme.merge(
                      data: IconThemeData(size: 20, color: fg),
                      child: option.leading!,
                    ),
                  ),
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
