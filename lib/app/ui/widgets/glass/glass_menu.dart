import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
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
/// `LiquidGlassScope`。所以 [showGlassMenu] 在打开的那一刻就地取一次面板该用的
/// 档位（[panelGlassBackend]）再在面板外面重新供上。
///
/// 那个档**恒为液态**，不跟触发件走：绝大多数触发件（列表行的 `⋮`、播放器
/// 工具栏、设置页的下拉）身处滚动容器或视频浮层，本来就上不了 lens；跟着它们
/// 走的结果是这些菜单全部静默落回传统档，改造等于没做。理由详见
/// [panelGlassBackend]。
///
/// ## ⛔ 菜单钉死在 easy 那一档，不跟着 chrome 走
///
/// 页面 chrome 从 2026-08-23 起换到了 `liquid_glass_widgets`
/// （[chromeGlassBackend]），**菜单没跟**——见 [panelGlassBackend]。理由是本文件
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
    this.description,
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

  /// 标题下面那行小字。给了它这一条就长高一档（[_rowHeightWithDescription]），
  /// 用在「选项本身需要解释」的场合——播放器的 Anime4K 预设是典型：光看
  /// 「Mode A」猜不出它做什么。别拿它当副标题堆长句，一行放不下会被截断。
  final String? description;

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

/// 一组条目的小标题（不可选中、不参与滑动取焦）。
///
/// 替掉此前各处用 `PopupMenuItem(enabled: false, child: Text(...))` 硬凑出来的
/// 那种「假条目标题」——那种写法在玻璃菜单里会变成一条能取焦却什么都不做的
/// 空行。
class GlassMenuSectionHeader extends GlassMenuEntry {
  const GlassMenuSectionHeader(this.label);

  final String label;
}

/// 面板圆角。比胶囊（22）小一档：面板是「一块板」，胶囊是「一颗药」。
const double _panelRadius = 20;

/// 单行高度。比 Material 的 48 略矮，配 44 的胶囊读起来是同一族尺寸。
const double _rowHeight = 44;

/// 带 [GlassMenuOption.description] 的行高。两行文字（14.5 + 11.5）加上下留白。
const double _rowHeightWithDescription = 60;

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

/// [GlassMenuSectionHeader] 一行占的高度（上下留白 + 一行 12 号字）。
const double _sectionHeaderHeight = 30;

/// 副标题字号；量宽（[_measureMenuPanelSize]）与渲染（[_GlassMenuRow]）共用。
const double _descriptionFontSize = 11.5;

/// 分组小标题字号，同上。
const double _sectionHeaderFontSize = 12;
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

/// 面板形变绕哪个角转：
/// - 纵向：翻到上方（[flipped] 为真）时展开原点在面板底边（1.0），自下而上从按钮处卷开；
///   在下方（[flipped] 为假）时展开原点在面板顶边（-1.0），自上而下从按钮处卷开。
/// - 横向：精确根据触发件中心横坐标相对于面板最终布局位置的比例折算，
///   使展开原点始终对准屏幕上的触发件。
Alignment _revealOrigin({
  required Rect anchorRect,
  required Size screen,
  required bool flipped,
  required Size? panelSize,
}) {
  final double screenWidth = screen.width;
  final double panelWidth = panelSize?.width ?? _minPanelWidth;
  final double layoutX = anchorRect.left.clamp(
    _screenMargin,
    math.max(_screenMargin, screenWidth - panelWidth - _screenMargin),
  );
  final double anchorCenterX = anchorRect.center.dx;
  final double ratioX = panelWidth > 0
      ? ((anchorCenterX - layoutX) / panelWidth).clamp(0.0, 1.0)
      : 0.5;
  final double alignX = (ratioX * 2.0 - 1.0).clamp(-1.0, 1.0);
  return Alignment(alignX, flipped ? 1.0 : -1.0);
}

/// 一条**行本身**的高度（不含上下外边距）。
///
/// 带副标题的选项要高一档（[_rowHeightWithDescription]）。行的按压底色、滑动
/// 取焦的焦点底板、面板量高三处必须读同一份——2026-08-26 用户报的「焦点底板
/// 比色觉辅助那一条矮一截」正是焦点底板自己写死了 [_rowHeight]。
double _rowHeightOf(GlassMenuEntry entry) => switch (entry) {
  GlassMenuOption(:final description) =>
    description == null ? _rowHeight : _rowHeightWithDescription,
  _ => _rowHeight,
};

/// 一条在面板内容里占的纵向高度（行高 + 上下外边距）。
double _entryHeight(GlassMenuEntry entry) => switch (entry) {
  GlassMenuSeparator() => _separatorHeight,
  GlassMenuSectionHeader() => _sectionHeaderHeight,
  GlassMenuOption() => _rowHeightOf(entry) + _rowMarginVertical * 2,
};

/// 每条在**滚动内容坐标系**里的纵向起点：面板自己的上下留白加在滚动容器外面，
/// 所以第一条从 0 开始。
///
/// 行高全是静态常量（[_entryHeight] / [_separatorHeight]），所以这里不像
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

/// 手指纵向可以越过首/末条多远仍算吃着那一条——**还没吃着任何一条时**用这一档。
///
/// 取得比面板自己的上下留白（[_panelVerticalPadding] 的一半，6）宽一点即可：
/// 这一档主要管手指接力刚开始那会儿，人还按在触发钮上、悬在面板外头。这时候
/// 不能给太宽，否则「长按开菜单、原地松手」会直接选中最靠近触发钮的那一条
/// ——那一条往往是删除一类的破坏性动作。
const double _focusVerticalSlack = 12;

/// 已经吃着某一条之后，手指纵向可以飘出去多远仍算咬着它。
///
/// 与横向的 [_focusHorizontalSlack] 同一个量级，理由也一样：**长按本来就会飘**。
/// 手指按在首条上不动地等一秒，实际落点会晃十几二十像素；而首条上方只剩面板
/// 那 6px 留白，飘上去一点就出界。出界之后是个死区：位移已经过了 [kTouchSlop]，
/// 行自己的点按早被判负（那是滑动取焦故意要的，见 `_handlePointerUp`），而焦点
/// 又没了 —— 松手两条路都不出手，这一下**整个被吞掉**。2026-08-24 用户报的
/// 「长按第一条松开没反应，第二条却可以」就是它（第二条是末条，下方有的是余量）。
const double _focusStickySlack = 40;

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

  double measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: baseStyle.merge(style)),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }

  double contentWidth = 0;
  double height = _panelVerticalPadding;
  for (final entry in entries) {
    switch (entry) {
      case GlassMenuSeparator():
        height += _entryHeight(entry);
      case GlassMenuSectionHeader(:final label):
        final double rowWidth =
            _rowHorizontalChrome +
            measureText(
              label,
              const TextStyle(
                fontSize: _sectionHeaderFontSize,
                fontWeight: FontWeight.w700,
              ),
            );
        if (rowWidth > contentWidth) contentWidth = rowWidth;
        height += _entryHeight(entry);
      case GlassMenuOption(
        :final leading,
        :final label,
        :final description,
        :final icon,
        :final selected,
      ):
        // 行首那一格（图标 / leading 槽位）两行共用，只算一次。
        double lead = 0;
        if (leading != null) {
          lead = _rowLeadingWidth;
        } else if (icon != null) {
          lead = _rowIconWidth;
        }
        double rowWidth =
            _rowHorizontalChrome +
            lead +
            measureText(
              label,
              TextStyle(
                fontSize: 14.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
        if (selected) rowWidth += _rowCheckWidth;
        if (description != null) {
          // 副标题与标题左对齐（在同一个 Expanded 里），所以它的行宽算法只差
          // 字号；对勾也压在同一行右侧，一并计入。
          final double descWidth =
              _rowHorizontalChrome +
              lead +
              measureText(
                description,
                const TextStyle(fontSize: _descriptionFontSize),
              ) +
              (selected ? _rowCheckWidth : 0);
          if (descWidth > rowWidth) rowWidth = descWidth;
        }
        if (rowWidth > contentWidth) contentWidth = rowWidth;
        // 量高与排版共用 [_entryHeight]：两处各写一遍的话，改了行高总有一处
        // 忘记跟，面板要么多出一条空白、要么最后一行被裁掉。
        height += _entryHeight(entry);
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
/// [globalAnchor]：用它**顶掉**从 [anchorContext] 量出来的落点（全局坐标）。
/// 右键上下文菜单专用——那时候没有「触发件」，面板该贴着指针弹出来，传一个
/// 指针位置的零尺寸 `Rect` 即可（面板会从那一点撑开）。
/// [priorityNearAnchor]：[entries] 是按**优先级从高到低**给的，面板翻到触发件
/// 上方时整列倒过来排（见 [_orderNearAnchor]）。
Future<T?> showGlassMenu<T>({
  required BuildContext anchorContext,
  required List<GlassMenuEntry> entries,
  Rect? globalAnchor,
  double minWidth = _minPanelWidth,
  double maxWidth = _maxPanelWidth,
  bool touchFlex = true,
  bool priorityNearAnchor = false,
}) {
  final anchorBox = anchorContext.findRenderObject();
  final navigator = Navigator.of(anchorContext, rootNavigator: true);
  final overlayBox = navigator.overlay?.context.findRenderObject();
  if (overlayBox is! RenderBox) return Future<T?>.value();
  if (globalAnchor == null && anchorBox is! RenderBox) {
    return Future<T?>.value();
  }

  final Rect anchorRect = globalAnchor != null
      ? overlayBox.globalToLocal(globalAnchor.topLeft) & globalAnchor.size
      : (anchorBox as RenderBox).localToGlobal(
              Offset.zero,
              ancestor: overlayBox,
            ) &
            anchorBox.size;

  final Size? precomputedSize = _measureMenuPanelSize(
    anchorContext: anchorContext,
    entries: entries,
    anchorRect: anchorRect,
    minWidth: minWidth,
    maxWidth: maxWidth,
  );

  // 排序在这儿定，不在面板里：面板量宽 / 量高都与顺序无关（宽取各行最大、
  // 高是各行相加），所以先量后排是安全的。
  final List<GlassMenuEntry> orderedEntries = priorityNearAnchor
      ? _orderNearAnchor(
          entries: entries,
          anchorContext: anchorContext,
          anchorRect: anchorRect,
          panelHeight: precomputedSize?.height,
        )
      : entries;

  // 关键：材质档位在这里就地取样，因为路由本身不在页面子树里。
  final GlassBackend backend = panelGlassBackend(anchorContext);

  // 手指接力：长按触发钮打开菜单时手指还按着，把这根手指接过来，面板就能直接
  // 进「滑动取焦」——按住不抬手划到某一条、松手即选中。普通点按（抬手才触发）
  // 认领不到，见 [GlassPointerHandoff]。**必须在同步前缀里领**，一旦 await 过
  // 窗口就关了。
  final GlassPointerHandoffSession? handoff = GlassPointerHandoff.claim();

  // 接了手指就必须走浮层档：路由一 push，`Navigator` 会把这根手指整只取消掉，
  // 接力当场断掉（详见 [_GlassMenuOverlayHost] 的类注释）。
  if (handoff != null) {
    return _showGlassMenuOverlay<T>(
      navigator: navigator,
      // 浮层不在路由栈上，页面被换掉时不会自己消失，得盯着锚点那条路由，
      // 见 [_GlassMenuOverlayHostState._watchAnchorRoute]。
      anchorRoute: ModalRoute.of(anchorContext),
      entries: orderedEntries,
      anchorRect: anchorRect,
      minWidth: minWidth,
      maxWidth: maxWidth,
      backend: backend,
      touchFlex:
          touchFlex && precomputedSize != null && backend != GlassBackend.plain,
      precomputedSize: precomputedSize,
      capturedThemes: InheritedTheme.capture(
        from: anchorContext,
        to: navigator.context,
      ),
      handoff: handoff,
    );
  }

  return navigator.push(
    _GlassMenuRoute<T>(
      entries: orderedEntries,
      handoff: handoff,
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

/// 把菜单挂到根 `Overlay` 上（而不是 push 成路由），只给手指接力那条路用。
/// 理由见 [_GlassMenuOverlayHost] 的类注释。
Future<T?> _showGlassMenuOverlay<T>({
  required NavigatorState navigator,
  required ModalRoute<Object?>? anchorRoute,
  required List<GlassMenuEntry> entries,
  required Rect anchorRect,
  required double minWidth,
  required double maxWidth,
  required GlassBackend backend,
  required bool touchFlex,
  required Size? precomputedSize,
  required CapturedThemes capturedThemes,
  required GlassPointerHandoffSession handoff,
}) {
  final OverlayState? overlay = navigator.overlay;
  if (overlay == null) return Future<T?>.value();
  final Completer<T?> completer = Completer<T?>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _GlassMenuOverlayHost<T>(
      anchorRoute: anchorRoute,
      entries: entries,
      anchorRect: anchorRect,
      minWidth: minWidth,
      maxWidth: maxWidth,
      backend: backend,
      touchFlex: touchFlex,
      precomputedSize: precomputedSize,
      capturedThemes: capturedThemes,
      handoff: handoff,
      onClosed: (value) {
        entry.remove();
        entry.dispose();
        if (!completer.isCompleted) completer.complete(value);
      },
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

/// 面板的身子：路由档与浮层档（[_GlassMenuOverlayHost]）**共用同一份**。
///
/// 两条路只在「谁托着它、怎么关」上不同，长相与交互一律走这儿，免得日后改了
/// 一边忘了另一边。
Widget _buildGlassMenuBody<T>({
  required BuildContext context,
  required Animation<double> animation,
  required List<GlassMenuEntry> entries,
  required Rect anchorRect,
  required double minWidth,
  required double maxWidth,
  required GlassBackend backend,
  required bool touchFlex,
  required Size? precomputedSize,
  required CapturedThemes capturedThemes,
  required GlassPointerHandoffSession? handoff,
  required ValueChanged<T> onSelected,
  required VoidCallback onDismissed,
}) {
  final Size screen = MediaQuery.sizeOf(context);
  final EdgeInsets padding = MediaQuery.paddingOf(context);
  final bool flipped = _opensUpward(
    anchorRect: anchorRect,
    screenHeight: screen.height,
    padding: padding,
    panelHeight: precomputedSize?.height,
  );
  final Widget panel = _GlassMenuPanel<T>(
    entries: entries,
    onSelected: onSelected,
    onDismissed: onDismissed,
    handoff: handoff,
    touchFlex: touchFlex,
    precomputedSize: precomputedSize,
    // 出入场长在面板内部而不是 buildTransitions 里，理由见该处注释。
    animation: animation,
    revealOrigin: _revealOrigin(
      anchorRect: anchorRect,
      screen: screen,
      flipped: flipped,
      panelSize: precomputedSize,
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

/// 浮层档的宿主：**手指接力时不能走路由**。
///
/// ⛔ `Navigator` 每次 push / pop 之后都会把**当前所有还按着的手指整只取消掉**
/// （`NavigatorState._cancelActivePointers`，框架里那条 TODO 挂着
/// flutter#4770）。取消之后 `GestureBinding` 把这根手指的命中路径删了，后续的
/// move / up 连派发都不派发——也就是说，只要菜单是 push 出来的，「长按弹出、
/// 手指不抬起接着划」这条路在框架层面就是死的：面板刚一出现，手指就已经废了。
///
/// 所以长按接力开出来的菜单挂在 `Overlay` 上而不是路由上：插一条 `OverlayEntry`
/// 不经过 `Navigator`，手指还活着，触发钮那层 `Listener` 能继续把落点转发进来。
/// 普通点按打开的仍旧走路由（那时手指早抬了，没有接力可言），两条路的**身子是
/// 同一份**（[_buildGlassMenuBody]），差别只有这三样：出入场自己起一个
/// controller、屏障自己画、关闭走 completer 而不是 `Navigator.pop`。
class _GlassMenuOverlayHost<T> extends StatefulWidget {
  const _GlassMenuOverlayHost({
    required this.anchorRoute,
    required this.entries,
    required this.anchorRect,
    required this.minWidth,
    required this.maxWidth,
    required this.backend,
    required this.touchFlex,
    required this.precomputedSize,
    required this.capturedThemes,
    required this.handoff,
    required this.onClosed,
  });

  /// 触发钮所在的那条路由，用来在页面被换掉时把浮层一并收走。
  final ModalRoute<Object?>? anchorRoute;

  final List<GlassMenuEntry> entries;
  final Rect anchorRect;
  final double minWidth;
  final double maxWidth;
  final GlassBackend backend;
  final bool touchFlex;
  final Size? precomputedSize;
  final CapturedThemes capturedThemes;
  final GlassPointerHandoffSession handoff;

  /// 退场动画跑完之后回调，带上选中的值（没选就是 null）。
  final ValueChanged<T?> onClosed;

  @override
  State<_GlassMenuOverlayHost<T>> createState() =>
      _GlassMenuOverlayHostState<T>();
}

class _GlassMenuOverlayHostState<T> extends State<_GlassMenuOverlayHost<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _enterDuration(widget.entries.length),
      reverseDuration: _exitDuration,
    );
    _controller.forward();
    _watchAnchorRoute();
  }

  /// ⛔ 浮层不在路由栈上——页面被 pop / 被别的页面盖住时，它**不会**跟着消失，
  /// 会孤零零地浮在下一个页面上（iOS 边缘侧滑返回最容易撞上）。所以盯着触发钮
  /// 那条路由的两条动画：自己在退场（[ModalRoute.animation] 反跑）或者被别人盖
  /// 住（[ModalRoute.secondaryAnimation] 正跑），都立刻收摊。
  void _watchAnchorRoute() {
    final ModalRoute<Object?>? route = widget.anchorRoute;
    if (route == null) return;
    void check() {
      if (_closing) return;
      final bool leaving =
          route.animation?.status == AnimationStatus.reverse ||
          route.animation?.status == AnimationStatus.dismissed ||
          route.secondaryAnimation?.status == AnimationStatus.forward;
      if (leaving) _close(null);
    }

    _anchorStatusListener = (_) => check();
    route.animation?.addStatusListener(_anchorStatusListener!);
    route.secondaryAnimation?.addStatusListener(_anchorStatusListener!);
  }

  AnimationStatusListener? _anchorStatusListener;

  @override
  void dispose() {
    final AnimationStatusListener? listener = _anchorStatusListener;
    if (listener != null) {
      widget.anchorRoute?.animation?.removeStatusListener(listener);
      widget.anchorRoute?.secondaryAnimation?.removeStatusListener(listener);
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close(T? value) async {
    if (_closing) return;
    _closing = true;
    await _controller.reverse();
    if (!mounted) return;
    widget.onClosed(value);
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Stack(
      children: [
        // 屏障：与 PopupRoute 那档一致——不压暗，只负责「点空白处关掉」。
        // 它是在手指按下**之后**才插进来的，接不到这根手指，不会跟接力打架。
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _close(null),
          ),
        ),
        _buildGlassMenuBody<T>(
          context: context,
          animation: _controller.view,
          entries: widget.entries,
          anchorRect: widget.anchorRect,
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          backend: widget.backend,
          touchFlex: widget.touchFlex,
          precomputedSize: widget.precomputedSize,
          capturedThemes: widget.capturedThemes,
          handoff: widget.handoff,
          onSelected: _close,
          onDismissed: () => _close(null),
        ),
      ],
    );

    // 路由那档由 `PopupRoute` 自己吃返回键；浮层没有路由，得自己接一层。
    // `BackButtonListener` 找不到 `Router` 会**直接抛**（不是返回 null），
    // 而挂在裸 `Navigator` 上的 App（以及大部分 widget test）本来就没有
    // Router——所以先探一下再决定包不包。
    if (Router.maybeOf(context) == null) return content;
    return BackButtonListener(
      onBackButtonPressed: () async {
        if (_closing) return false;
        await _close(null);
        return true;
      },
      child: content,
    );
  }
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
    this.handoff,
  });

  /// 从触发钮接过来的那根手指（长按打开时才有），见 [GlassPointerHandoff]。
  final GlassPointerHandoffSession? handoff;

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
    return _buildGlassMenuBody<T>(
      context: context,
      animation: animation,
      entries: entries,
      anchorRect: anchorRect,
      minWidth: minWidth,
      maxWidth: maxWidth,
      backend: backend,
      touchFlex: touchFlex,
      precomputedSize: precomputedSize,
      capturedThemes: capturedThemes,
      handoff: handoff,
      onSelected: (value) => Navigator.of(context).pop(value),
      onDismissed: () => Navigator.of(context).pop(),
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

/// 下方剩余空间放不下整张面板时翻到上方弹。
///
/// 与 [_GlassMenuLayout.getPositionForChild] 使用完全同一套判定，
/// 保证动画形变的原点（[revealOrigin]）与最终落点方向永远一致。
/// 「优先级最高的那条永远贴着触发件」。
///
/// 面板在触发件**下方**展开时，第一条离触发件最近，原样即可；翻到**上方**时
/// 最近的变成了最后一条，于是整列倒过来。调用点因此不用自己判断「我在屏幕顶
/// 还是屏幕底」——底部浮动栏那枚搜索钮和顶部 header 那枚用的是同一份顺序表，
/// 弹出来却各自顺手（见 `search_mode_menu.dart`）。
///
/// 只对**纯选项**的菜单成立：分组标题 / 分隔线倒过来之后归属会错位，所以那种
/// 菜单不该开这一条。
List<GlassMenuEntry> _orderNearAnchor({
  required List<GlassMenuEntry> entries,
  required BuildContext anchorContext,
  required Rect anchorRect,
  required double? panelHeight,
}) {
  assert(
    entries.every((e) => e is! GlassMenuSectionHeader && e is! GlassMenuSeparator),
    'priorityNearAnchor 只能用在纯选项菜单上：分组标题 / 分隔线倒过来会错位。',
  );
  final bool flipped = _opensUpward(
    anchorRect: anchorRect,
    screenHeight: MediaQuery.sizeOf(anchorContext).height,
    padding: MediaQuery.paddingOf(anchorContext),
    panelHeight: panelHeight,
  );
  return flipped ? entries.reversed.toList() : entries;
}

bool _opensUpward({
  required Rect anchorRect,
  required double screenHeight,
  required EdgeInsets padding,
  required double? panelHeight,
}) {
  final double belowTop = anchorRect.bottom + _anchorGap;
  final double effectiveHeight = panelHeight ?? (_rowHeight * 3);
  final bool fitsBelow =
      belowTop + effectiveHeight <= screenHeight - padding.bottom;
  return !fitsBelow;
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
    this.handoff,
  });

  /// 从触发钮接过来的那根手指，见 [GlassPointerHandoff]。
  final GlassPointerHandoffSession? handoff;

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
    _focusFade = AnimationController(vsync: this, duration: _focusFadeDuration);
    _attachHandoff();
  }

  @override
  void dispose() {
    widget.handoff?.detach();
    _shape.dispose();
    _material.dispose();
    _focusFade.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---- 手指接力（长按触发钮打开的那一路，见 [GlassPointerHandoff]）----

  /// 这根手指是从触发钮接过来的，面板自己的 [Listener] 一个事件也收不到。
  bool _handoffActive = false;

  /// 挂上接力。**要等第一帧**：坐标要靠内容层的 `RenderBox` 换算，而它这会儿
  /// 还没布局；[GlassPointerHandoffSession.position] 存着最后一次落点，所以
  /// 晚一帧挂上也不会丢起手焦点。
  void _attachHandoff() {
    final GlassPointerHandoffSession? session = widget.handoff;
    if (session == null || session.finished) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || session.finished) return;
      _handoffActive = true;
      setState(() {
        _sliding = true;
        // 起手不滑：底板直接落在手指底下（与按面板那条路同一个规矩）。
        _pillSlides = false;
      });
      final Offset? at = session.position;
      if (at != null) _focusAtGlobal(at, haptic: false);
      session.attach(
        onMove: (position) => _focusAtGlobal(position, haptic: true),
        onRelease: _handleHandoffRelease,
      );
    });
  }

  /// 全局坐标 → 内容坐标 → 焦点。内容层的 `RenderBox` 自带滚动偏移与出入场的
  /// 那两层 `Transform`，换算出来的正好是 [_entryAt] 要的那套坐标。
  void _focusAtGlobal(Offset global, {required bool haptic}) {
    if (!mounted || _selected) return;
    final RenderObject? box = _contentKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final Offset local = box.globalToLocal(global);
    if (!_pillSlides && _focusIndex != null) _pillSlides = true;
    _setFocus(_entryAt(local, _contentWidth), haptic: haptic);
  }

  void _handleHandoffRelease(Offset? global) {
    _handoffActive = false;
    if (!mounted) return;
    final int? target = _focusIndex;
    // 取消（[global] 为 null）不算选中；松手时人还悬在触发钮上（没落到任何一条）
    // 也不关面板——那就退回一张普通打开着的菜单，再点一下就是了。
    if (global == null || target == null) {
      setState(() {
        _sliding = false;
        _focusIndex = null;
      });
      _focusFade.reverse();
      return;
    }
    final GlassMenuEntry entry = widget.entries[target];
    if (entry is GlassMenuOption<T> && entry.enabled) {
      VibrateUtils.vibrate();
      _select(entry.value);
    }
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
  bool get _hasLongPressEntry =>
      widget.entries.any((e) => e is GlassMenuOption && e.onLongPress != null);

  /// 内容层的实际宽度，用来判断手指有没有横向荡出去。
  double get _contentWidth =>
      _contentKey.currentContext?.size?.width ?? double.infinity;

  bool _isSelectable(GlassMenuEntry entry) =>
      entry is GlassMenuOption<T> && entry.enabled;

  /// 内容坐标 → 条目下标。落在禁用行或面板外面时返回 null。
  ///
  /// 两处「粘」都只在**已经吃着某一条**之后才生效（[_focusIndex] 非空）：
  ///   - 纵向越界的容差放宽到 [_focusStickySlack]；
  ///   - 划过分隔线时保持原焦点。分隔线是条 11px 的发丝线，不是落点，但从它
  ///     上面**路过**不该把焦点丢掉——丢了就等于把这一下吞掉（见
  ///     [_focusStickySlack]）。按下时**直接**落在分隔线上仍然不亮底板：那是
  ///     人主动选了个非目标，与路过是两回事。
  int? _entryAt(Offset local, double width) {
    if (widget.entries.isEmpty) return null;
    if (local.dx < -_focusHorizontalSlack ||
        local.dx > width + _focusHorizontalSlack) {
      return null;
    }
    final int? current = _focusIndex;
    final double verticalSlack = current == null
        ? _focusVerticalSlack
        : _focusStickySlack;
    final List<double> tops = _entryTops(widget.entries);
    final double contentHeight = tops.last + _entryHeight(widget.entries.last);
    // 越过首/末条一小段仍按首/末条算。
    double dy = local.dy;
    if (dy < 0) {
      if (dy < -verticalSlack) return null;
      dy = 0;
    } else if (dy >= contentHeight) {
      if (dy > contentHeight + verticalSlack) return null;
      dy = contentHeight - 1;
    }
    for (var i = 0; i < widget.entries.length; i++) {
      final GlassMenuEntry entry = widget.entries[i];
      if (dy < tops[i] || dy >= tops[i] + _entryHeight(entry)) continue;
      if (_isSelectable(entry)) return i;
      // 分组标题 / 分隔线：路过不丢焦点；禁用行仍旧一律不给（那是「这条现在
      // 不能选」，粘上去只会让人以为选中了）。
      final bool passThrough =
          entry is GlassMenuSeparator || entry is GlassMenuSectionHeader;
      return passThrough ? current : null;
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
    if (_pointer != null ||
        _selected ||
        _handoffActive ||
        _isScrollable ||
        _hasLongPressEntry) {
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

  /// 焦点底板：跟行的按压底色同一个圆角、同一族底色，位置与高度按静态行高算
  /// （[_entryTops] / [_rowHeightOf]）。
  ///
  /// ⛔ 高度必须跟着**这一条**走，不能写死 [_rowHeight]：带副标题的选项高一档，
  /// 写死的话底板只盖住上面 44px，副标题露在外面（2026-08-26 用户报的图库图片
  /// 菜单里「色觉辅助」那一条）。[AnimatedPositioned] 会把高度变化一起补间，
  /// 于是从普通行滑到副标题行时底板是「长开」的，不是跳一下。
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
      height: _rowHeightOf(widget.entries[index]),
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
        GlassMenuSectionHeader(:final label) => _GlassMenuSectionHeaderRow(
          label: label,
        ),
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
            widget.revealBeginScale.dx + (1 - widget.revealBeginScale.dx) * p;
        final double sy =
            widget.revealBeginScale.dy + (1 - widget.revealBeginScale.dy) * p;
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

/// 一组条目的小标题行。不接任何手势——它不是条目，只是块牌子。
class _GlassMenuSectionHeaderRow extends StatelessWidget {
  const _GlassMenuSectionHeaderRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: _sectionHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _rowMarginHorizontal + 12,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _sectionHeaderFontSize,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
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
        // ⛔ 这一处**必须**关掉「黏手」的容忍圈（见 [GlassTapArea.sticky]）：
        // 上面那套滑动取焦正是靠 tap 在 kTouchSlop 处自行判负来和点按分家的
        // （见 `_handlePointerUp` 里那段），黏上之后一次滑动取焦会连带触发行
        // 自己的点击 —— 同一项被选中两遍。
        stickyTouch: false,
        // 整行缩放会让面板看着在抖；行的反馈只用底色。
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: _rowHeightOf(option),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                    if (option.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          option.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _descriptionFontSize,
                            height: 1.2,
                            color: enabled
                                ? cs.onSurfaceVariant
                                : cs.onSurface.withValues(alpha: 0.38),
                          ),
                        ),
                      ),
                  ],
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
