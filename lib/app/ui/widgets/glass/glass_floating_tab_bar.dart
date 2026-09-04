import 'dart:async';

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
// 带前缀：两个玻璃包的公开面与本仓库自己的组件大面积重名（见
// `liquid_glass_material.dart` 顶部那段说明），不加前缀会一片 ambiguous_import。
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 浮动底栏里的一项。
class GlassTabItem {
  const GlassTabItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
  });

  final IconData icon;

  /// 选中时换成的图标（一般是同一枚的实心版）。为 null 时选中态沿用 [icon]。
  final IconData? activeIcon;

  final String label;

  /// 右上角角标（为 null 时不显示）。
  final Widget? badge;
}

/// 浮动底栏右侧那枚独立圆钮（搜索）。
///
/// 它不是随便一个 `Widget`：底栏整体由 `liquid_glass_widgets` 画，这枚钮必须
/// 交给它自己的 `extraButton` 才能与胶囊**共用同一层玻璃**（`LiquidGlassBlendGroup`），
/// 两块玻璃靠近时边缘会互相融合而不是各画各的。所以这里只收「图标 + 动作」，
/// 由本组件转成包里的 `GlassTabBarExtraButton`。
class GlassFloatingBarAction {
  const GlassFloatingBarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.onLongPress,
  });

  final IconData icon;

  /// 无障碍标签（这枚钮只有图标，屏幕阅读器念的是它）。
  final String label;

  final VoidCallback onPressed;

  /// 长按这枚圆钮（用来吐一张玻璃菜单）。收到的 `anchorContext` 是**圆钮自己
  /// 那块地方**的 context——`showGlassMenu` 就是从它身上量落点的。
  ///
  /// 到点会震一下，并且手指不用抬就能直接划进弹出来的面板选（走
  /// [GlassTapArea.longPressOpensOverlay]）。
  final void Function(BuildContext anchorContext)? onLongPress;
}

/// 一格标签最多能占多宽。
///
/// 两档共用同一套几何：整条宽度扣掉右侧圆钮（直径 = 栏高）与它的 12px 间距，
/// 剩下的按栏目数均分，再留 8px 让标签不贴着格子边。
///
/// 量它是为了**把标签钉在一行里省略**，而不是让它把图标挤小：液态档那条栏
/// 整格内容包在 `FittedBox(scaleDown)` 里，标签超宽会连图标一起缩。
/// 宽度未知（无界约束）时返回 `double.infinity`，退回包自己的兜底。
double _labelMaxWidth({
  required double barWidth,
  required int tabCount,
  required bool hasAction,
  required double height,
}) {
  if (!barWidth.isFinite || tabCount <= 0) return double.infinity;
  final double capsule = barWidth - (hasAction ? height + 12 : 0);
  final double slot = capsule / tabCount;
  return slot <= 24 ? 24 : slot - 8;
}

/// 底栏一格里的标签：**每一格都有**，单行、超出上限就省略。
///
/// ⭐ [maxWidth] 不是审美参数，是这条栏的**结构约束**：液态档那条栏把整格
/// 内容包在 `FittedBox(scaleDown)` 里，标签一超宽就**连图标一起等比缩小**，
/// 而且各格缩放比还不一样——这正是 2026-09-04 用户报的「按钮变得很小、所有
/// 按钮看起来不整齐」（日文 / 英文尤其明显）。把标签钉在一格宽度内省略掉，
/// 图标就永远是 26。
///
/// 上限怎么算见 [_labelMaxWidth]。
class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.maxWidth,
    required this.style,
  });

  final String label;
  final double maxWidth;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

/// 浮动在内容之上的玻璃 Tab 胶囊，可选在右侧并排一枚独立圆钮（[action]）。
///
/// # 它现在是 `liquid_glass_widgets` 的 `GlassTabBar.bottom`
///
/// 2026-08-23 从自绘（`GlassSurface` + `AnimatedPositioned` 高亮块 + 长按拾起）
/// 换成包里的底部导航。换来的是自绘那版做不出的三件事：
///
///   1. **果冻指示器**：拖动时高亮块会被「拽」出挤压/回弹的形变（jelly physics），
///      松手按速度吸附——甩得快能跨过好几项。
///   2. **磁透镜**：指示器是一块真玻璃，浮在图标层**之上**，经过谁就把谁折射
///      并微微放大（`MaskingQuality.high`），而不是在图标下面垫一块底色。
///   3. **直接拖动**：不再需要「长按拾起」这一步——按住就能滑（自绘那版必须
///      先长按，否则会和页面的横向手势打架；包里的手势是在自己这条 Row 上收的）。
///
/// # 两档两份实现（2026-09-04）
///
/// 液态档就是上面那只 `GlassTabBar.bottom`；**Material 档整只换成 M3 的
/// [NavigationBar]**（[_MaterialFloatingTabBar]）——胶囊几何、右侧圆钮、
/// 外边距全都不变，换掉的只有材质与那套手势。
///
/// 这与 2026-08-26 的旧结论（「底栏是唯一不跟全局开关走的 chrome，假玻璃档下
/// 它照旧是真玻璃」）相反，是用户 2026-09-04 重新拍的板：那一档不再是液态玻璃
/// 的仿造品，而是一套自洽的 Material，底栏跟着走才说得通。当年反对第二份实现
/// 的理由（果冻指示器 / 磁透镜 / 按住即滑要写两遍）在这里不成立——M3 的
/// `NavigationBar` 本来就有自己的一整套指示器动画与涟漪，不需要我们复刻液态
/// 那套手感，**按住即滑是液态档专有的**。
///
/// 顺带的收益：Material 档下整个 App 再没有一块玻璃在采样背景，shader 预热
/// 可以整只跳过（见 `main.dart` 那段）。
///
/// # 放哪儿
///
/// 包的文档说「永远放进 `Scaffold.bottomNavigationBar`」——**本仓库不这么做**。
/// 一旦挂上那个槽位，Scaffold 会给 body 套 `removePadding(removeBottom: true)`，
/// shell 里所有页面的 `SafeArea(bottom: true)` 全部失效（历史上整套安全区失效
/// 的总根因，见 `home_shell_scaffold.dart` 里那段注释）。这里改成 `Stack` 覆盖层，
/// 所以本组件**只负责「一行」**：不含安全区、不含左右边距，调用方用
/// [GlassTokens.floatingTabBarSideMargin] / [GlassTokens.floatingTabBarBottomMargin]
/// 自己摆位。包里的 `horizontalPadding` / `verticalPadding` 因此一律传 0。
///
/// # 落地时机：抬手才换页，按住只留给拖动
///
/// 包是在 **`onTapDown`** 那一刻回调 `onTabSelected` 的。tap 识别器和横向拖拽在
/// 同一个竞技场里，`onTapDown` 会在**按下满 ~100ms**（`kPressTimeout`）时抢先发出
/// ——也就是说「按住准备滑」这个动作，在手指还没动之前页面就已经换掉了：整棵分支
/// 子树重建，指示器又被新的 `selectedIndex` 拽回去和手指打架，于是滑动时灵时不灵；
/// 从当前项按住再滑还会白刷新一次。
///
/// 所以本组件把「换页」这一下从**按下**挪到**抬手**：按住期间只把下标记下来，手指
/// 一旦走出 [kTouchSlop]（这一下已经被判成拖动）就把它作废，改等拖动结束时包给出
/// 的最终下标。
///
/// # 但「焦点」必须当场跟过去
///
/// 推迟的只能是**换页**，不能是**高亮**。包里指示器的落点只有一个来源：外面传进来的
/// `selectedIndex`（`didUpdateWidget` 里比对后弹过去）；按住期间既然我们压着不换页，
/// `selectedIndex` 就一直是旧的那一项，于是「按住订阅不动，焦点还赖在视频上，手指
/// 左右挪一下才跟过来」——挪动那下之所以有效，是横向拖拽接管了指示器坐标，跟
/// `selectedIndex` 根本不是一条路。
///
/// 所以这里把「视觉选中」和「路由选中」拆开：按下报上来的下标立刻记进 [_pressedIndex]
/// 并喂给包（指示器带弹簧弹过去、图标/文字当场换成选中色），路由该换页还是等抬手。
/// 这不会把开头那个「按下就换页」的毛病带回来：换的只是本组件自己的一个 int，分支
/// 子树不重建，拖动期间也只有拖拽在写指示器坐标。
///
/// 快速点击感受不到差别（按下到抬手不过几十毫秒），**同项也回调**这条也没变，所以
/// 「再次点击当前栏目 → 回顶 + 重载」仍然成立。
class GlassFloatingTabBar extends StatefulWidget {
  const GlassFloatingTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.action,
    this.height = GlassTokens.floatingTabBarHeight,
  });

  final List<GlassTabItem> items;
  final int currentIndex;

  /// 换项回调：**抬手**那一刻才回调（同项也回调），见类文档「落地时机」。
  final ValueChanged<int> onTap;

  /// 右侧并排的独立圆钮；为 null 时整条只有胶囊。
  final GlassFloatingBarAction? action;

  final double height;

  @override
  State<GlassFloatingTabBar> createState() => _GlassFloatingTabBarState();
}

class _GlassFloatingTabBarState extends State<GlassFloatingTabBar> {
  /// 包已经报了换项、但这一下手势还没结束——先记着，别急着换页。
  int? _pending;

  /// [_pending] 是手指还按着时记下的（`onTapDown` 抢跑那一次），而不是手势结束
  /// 后包给出的最终结果。
  bool _pendingFromPress = false;

  bool _pointerDown = false;

  /// 本次手势里手指是否已经走出 [kTouchSlop]——走出去了就按拖动算。
  bool _movedBeyondSlop = false;

  Offset _downPosition = Offset.zero;

  bool _commitScheduled = false;

  /// 手指底下这一项：页面还没换（换页要等抬手），但高亮/指示器已经先跟过去了。
  /// 为 null 表示「以路由为准」。见类文档「但『焦点』必须当场跟过去」。
  int? _pressedIndex;

  /// 喂给包的 `selectedIndex`：按住期间跟手指，其余时候跟路由。
  int get _visualIndex => _pressedIndex ?? widget.currentIndex;

  @override
  void didUpdateWidget(covariant GlassFloatingTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 路由真的换过去了（或者被别处改到了另一项）→ 抢先点亮的那份作废，交还给路由。
    if (widget.currentIndex != oldWidget.currentIndex) {
      _pressedIndex = null;
    }
  }

  void _handleTabSelected(int index) {
    _pending = index;
    _pendingFromPress = _pointerDown;
    _setPressedIndex(index);
    if (_pointerDown) return; // 按住期间只记着，等抬手再落地
    _scheduleCommit();
  }

  void _setPressedIndex(int? index) {
    if (_pressedIndex == index) return;
    setState(() => _pressedIndex = index);
  }

  /// 落地推迟一个微任务：抬手时 raw `Listener` 先于手势识别器收到事件，而拖动的
  /// 最终下标是紧随其后在同一轮派发里由竞技场清算出来的。等一个微任务，拿到的就
  /// 是这一轮的最后一个下标（拖动结果会覆盖按下时记的那个）。
  void _scheduleCommit() {
    if (_commitScheduled) return;
    _commitScheduled = true;
    scheduleMicrotask(_commit);
  }

  void _commit() {
    _commitScheduled = false;
    if (!mounted || _pointerDown) return;
    final int? index = _pending;
    final bool fromPress = _pendingFromPress;
    _pending = null;
    _pendingFromPress = false;
    if (index == null) return;
    // 按下时抢跑记的那个下标，遇上手指真的拖走了就作废：最终落到哪一项，包会在
    // 拖动结束时另报一次（那时 `_pointerDown` 已经是 false，直接落地）。
    if (fromPress && _movedBeyondSlop) {
      // 走到这儿说明这一下被判成拖动、却没等来拖动结束的下标（手势被上层抢走 /
      // 中途取消）。既然页面不会换，抢先点亮的那项也得退回路由那一项。
      _setPressedIndex(null);
      return;
    }
    widget.onTap(index);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _movedBeyondSlop = false;
    _downPosition = event.position;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_movedBeyondSlop) return;
    if ((event.position - _downPosition).distance > kTouchSlop) {
      _movedBeyondSlop = true;
    }
  }

  void _handlePointerRelease(PointerEvent event) {
    _pointerDown = false;
    _scheduleCommit();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _build(context, barWidth: constraints.maxWidth),
    );
  }

  Widget _build(BuildContext context, {required double barWidth}) {
    final cs = Theme.of(context).colorScheme;
    final GlassFloatingBarAction? action = widget.action;
    final List<GlassTabItem> items = widget.items;
    final double height = widget.height;
    final double labelMaxWidth = _labelMaxWidth(
      barWidth: barWidth,
      tabCount: items.length,
      hasAction: action != null,
      height: height,
    );

    // Material 档整只换成 M3 的导航栏（见类文档「两档两份实现」）。
    // 右侧圆钮的几何契约（最右边的 height × height 方块）两档一致，所以
    // [_withActionLongPress] 那层长按手势区照旧盖在外面、只写一遍。
    if (!GlassMaterialScope.isLiquid(context)) {
      return _withActionLongPress(
        action: action,
        height: height,
        bar: _MaterialFloatingTabBar(
          items: items,
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          action: action,
          height: height,
          labelMaxWidth: labelMaxWidth,
        ),
      );
    }

    // raw `Listener` 只是旁听手指的起落（不进竞技场、不改命中测试），用来判断
    // 包报上来的下标该立刻落地还是先压着——见类文档「落地时机」。
    return _withActionLongPress(
      action: action,
      height: height,
      bar: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerRelease,
        onPointerCancel: _handlePointerRelease,
        child: lgw.GlassTabBar.bottom(
          // ⛔ **不把 [GlassTabItem.label] 交给包**：它的标签是无条件渲染的
          // （每一格都带字），而整格内容包在 `FittedBox(scaleDown)` 里——字一长
          // 就把**图标一起缩小**，每格缩放比还各不相同，读起来就是「按钮大小
          // 参差不齐」（2026-09-04 用户报的正是这条，日文 / 英文尤其明显）。
          //
          // 改成自己画：只有选中项显示标签，且**带收放过渡**（见
          // [_LiquidTabContent]）。包只认 icon 槽位，所以整块「图标 + 标签」
          // 塞进去；无障碍名字走 `semanticLabel`，不会因为没有 label 而丢。
          tabs: [
            for (int i = 0; i < items.length; i++)
              lgw.GlassTab(
                semanticLabel: items[i].label,
                icon: _LiquidTabContent(
                  item: items[i],
                  selected: false,
                  labelMaxWidth: labelMaxWidth,
                ),
                activeIcon: _LiquidTabContent(
                  item: items[i],
                  selected: true,
                  labelMaxWidth: labelMaxWidth,
                ),
              ),
          ],
          // 按住期间这里跟的是手指（[_visualIndex]），不是路由——换页还在等抬手。
          selectedIndex: items.isEmpty
              ? 0
              : _visualIndex.clamp(0, items.length - 1),
          onTabSelected: _handleTabSelected,
          extraButton: action == null
              ? null
              : lgw.GlassTabBarExtraButton(
                  icon: Icon(action.icon),
                  label: action.label,
                  onTap: action.onPressed,
                  // 圆钮的槽位高度恒等于栏高，直径小于栏高会被拉成椭圆
                  // （见 [GlassTokens.floatingActionSize] 的说明）。
                  size: height,
                  iconColor: cs.onSurface,
                ),

          // ---- 布局：外边距全部由调用方的 Stack 负责，这里只留「一行」 ----
          horizontalPadding: 0,
          verticalPadding: 0,
          barHeight: height,
          // 传 height / 2 而不是包的默认哨兵值（9999）：那个值会让圆钮从
          // `LiquidOval` 退化成 `LiquidRoundedRectangle`，多一次无谓的裁剪。
          barBorderRadius: height / 2,
          // 与自绘那版的 `SizedBox(width: 12)` 同一口径。
          spacing: 12,

          // ---- 排版：沿用自绘那版标定过的图标尺寸 ----
          // 标签的字号 / 字重在 [_LiquidTabContent] 里（包这边已经没有标签了），
          // 颜色由包的 `IconTheme` + `DefaultTextStyle` 一并下发。
          iconSize: 26,
          selectedIconColor: cs.primary,
          unselectedIconColor: cs.onSurfaceVariant,

          // ---- 材质：与全站 chrome 同一份玻璃（见 GlassTokens.widgetsGlass）----
          settings: GlassTokens.widgetsGlass(
            cs,
            tint: GlassTokens.widgetsTint(cs),
          ),
          quality: chromeGlassQuality,
          indicatorColor: GlassTokens.tabIndicatorTint(cs),
        ),
      ),
    );
  }

  /// 给右侧圆钮补上长按（[GlassFloatingBarAction.onLongPress]）。
  ///
  /// 液态档下这枚钮整只由 `liquid_glass_widgets` 画，而包里的
  /// `GlassTabBarExtraButton` 只有 `onTap`——够不着。所以长按统一由这层**盖在
  /// 它上面**的透明手势区来收，两档共用一条实现（Material 档那枚圆钮也不单独
  /// 接），免得日后改了一边忘了另一边。
  ///
  /// 落点靠几何约定：两档的圆钮都恰好占这一行**最右边的 `height × height`
  /// 方块**——液态档是包里的 `Positioned(right: 0, width: size)`，Material 档是
  /// Row 末尾那枚直径等于栏高的圆钮。这个前提由 [GlassTokens.floatingActionSize]
  /// 锁着（直径必须等于栏高，否则圆钮会被拉成椭圆）。
  ///
  /// `translucent`：这一层只旁听长按，**点按照旧穿下去**给真正的圆钮。长按到点
  /// 时 `LongPressGestureRecognizer` 会在竞技场上直接宣布胜利（不必比谁更深），
  /// 把身下那只 tap 判负——所以「长按弹菜单」不会顺带把搜索页也跳掉。
  Widget _withActionLongPress({
    required GlassFloatingBarAction? action,
    required double height,
    required Widget bar,
  }) {
    final void Function(BuildContext)? onLongPress = action?.onLongPress;
    if (onLongPress == null) return bar;
    return Stack(
      // 约束原样传给底栏：Stack 默认会把约束放松成 loose，底栏就不再撑满
      // 调用方给的宽度了。
      fit: StackFit.passthrough,
      children: [
        bar,
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: height,
          child: Builder(
            builder: (anchorContext) => GlassTapArea(
              behavior: HitTestBehavior.translucent,
              // 语义（「搜索」按钮）由身下那枚真正的圆钮发，这层再挂一个就成了
              // 两个节点。
              excludeFromSemantics: true,
              longPressOpensOverlay: true,
              onLongPress: () => onLongPress(anchorContext),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Material 档的浮动底栏：M3 的导航栏装进同一只浮动胶囊里。
///
/// **几何与液态档完全一致**（这是硬契约，不是巧合）：
///   - 整条只有「一行」，高度 [height]，不含安全区、不含左右边距；
///   - 右侧那枚圆钮占最右边的 `height × height` 方块，直径等于栏高
///     （见 [GlassTokens.floatingActionSize]）——[GlassFloatingTabBar] 那层
///     长按手势区就是照这个方块定位的，两档共用一份实现。
///
/// 材质走 [GlassTokens.materialFill]：不透明、无描边、**无投影**
/// （Material 档一概不画投影，见 [MaterialSurfaceBox]），层级差别由 M3 的
/// surface container 色阶表达。选中项那颗药丸是框架公开的
/// [NavigationIndicator]（M3 那套 `easeInOutCubicEmphasized` 横向缩放 +
/// 100ms 淡入淡出），涟漪由 [InkWell] 出。
///
/// # ⛔ 为什么不直接用框架的 `NavigationBar`
///
/// 试过，退回来了：它的标签是一只**没有 `maxLines` 的 `Text`**，可用宽度不够
/// 时会**折行**，第二行直接掉出这条 64px 的胶囊被裁掉（golden 里实拍到）。
/// 而这条栏最窄的情形正好踩中——360dp 屏、四个栏目、右边还扣掉 64+12 的圆钮，
/// 每格只剩约 63px，英文的 "Subscriptions" / "Community" 铁定放不下。
/// 标签的换行属性来自 `NavigationBar` **内部那只 `Material`** 自带的
/// `AnimatedDefaultTextStyle`（`maxLines: null`），在外面包 `DefaultTextStyle`
/// 盖不住，`labelTextStyle` 里也塞不进 `maxLines`——`TextStyle` 根本没有这个
/// 字段。液态档那条（包里的 `GlassTabBar.bottom`）是 `maxLines: 1` +
/// `ellipsis`，两档的排版必须对齐，所以这一格自己画。
///
/// 自己画的只有「一行 icon + label + 指示器」，M3 的观感件（指示器动画、
/// 涟漪、色角色）全部用框架现成的，不是另起一套语言。
class _MaterialFloatingTabBar extends StatelessWidget {
  const _MaterialFloatingTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.action,
    required this.height,
    required this.labelMaxWidth,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlassFloatingBarAction? action;
  final double height;

  /// 一格标签的宽度上限，见 [_labelMaxWidth]。
  final double labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final MediaQueryData mq = MediaQuery.of(context);
    final int selected = items.isEmpty
        ? 0
        : currentIndex.clamp(0, items.length - 1);

    final Widget bar = Material(
      color: GlassTokens.materialFill(cs),
      // ⛔ 不给 elevation：这一档不画投影。
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(height / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        // 栏高是钉死的，系统字号拉满会把标签顶出去：夹到 1.2。
        child: MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.2),
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _MaterialTab(
                    item: items[i],
                    selected: i == selected,
                    // 同项也回调（首页「再点一次当前栏目 = 回顶 + 重载」靠它）。
                    onTap: () => onTap(i),
                    labelMaxWidth: labelMaxWidth,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final GlassFloatingBarAction? action = this.action;
    if (action == null) return bar;
    return Row(
      children: [
        Expanded(child: bar),
        // 与液态档同一口径（包里给的 `spacing: 12`）。
        const SizedBox(width: 12),
        _MaterialFloatingBarActionButton(action: action, size: height),
      ],
    );
  }
}

/// Material 档底栏里的一格：指示器 + 图标 + 单行标签。
///
/// 排版沿用液态档那条标定过的值（图标 26、标签 11.5、间距 2），换档只换材质
/// 不换字号；标签 `maxLines: 1` + `ellipsis`，与包里那条一致。
class _MaterialTab extends StatefulWidget {
  const _MaterialTab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.labelMaxWidth,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double labelMaxWidth;

  @override
  State<_MaterialTab> createState() => _MaterialTabState();
}

class _MaterialTabState extends State<_MaterialTab>
    with SingleTickerProviderStateMixin {
  /// 500ms 是 M3 `NavigationBar` 自己的 `animationDuration` 默认值。
  late final AnimationController _selection = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: widget.selected ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant _MaterialTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == oldWidget.selected) return;
    widget.selected ? _selection.forward() : _selection.reverse();
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final GlassTabItem item = widget.item;
    final IconData iconData = widget.selected
        ? (item.activeIcon ?? item.icon)
        : item.icon;

    Widget icon = Icon(
      iconData,
      size: 26,
      color: widget.selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
    );
    if (item.badge != null) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(top: -4, right: -6, child: item.badge!),
        ],
      );
    }

    return Semantics(
      selected: widget.selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const StadiumBorder(),
        excludeFromSemantics: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                NavigationIndicator(
                  animation: _selection,
                  color: GlassTokens.materialSelected(cs),
                ),
                icon,
              ],
            ),
            const SizedBox(height: 2),
            // 每格都有标签，装不下就在一格宽度内省略（见 [_TabLabel]）。
            _TabLabel(
              label: item.label,
              maxWidth: widget.labelMaxWidth,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.1,
                fontWeight: widget.selected
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: widget.selected ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Material 档底栏右侧那枚独立圆钮。
///
/// 点按走 [InkWell]（M3 的涟漪就是这一档的按下反馈）；**长按不在这里接**
/// ——它由 [GlassFloatingTabBar] 盖在整条栏之上的那层透明手势区统一收，两档
/// 共用一份（见 `_withActionLongPress`）。
class _MaterialFloatingBarActionButton extends StatelessWidget {
  const _MaterialFloatingBarActionButton({
    required this.action,
    required this.size,
  });

  final GlassFloatingBarAction action;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: action.label,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: GlassTokens.materialFill(cs),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: action.onPressed,
            child: Semantics(
              button: true,
              label: action.label,
              child: Center(
                child: Icon(action.icon, size: 26, color: cs.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 液态档底栏一格的内容：图标（含角标）+ 标签。
///
/// 塞进包的 `GlassTab.icon` / `activeIcon` 槽位——包会按选中态在这两只之间切。
///
/// ⛔ 标签**不能交给包自己画**（`GlassTab.label`）：它把整格「图标 + 标签」包在
/// `FittedBox(scaleDown)` 里，标签一长就连图标一起缩，各格缩放比还不一样。
/// 自己画就能把标签钉在 [labelMaxWidth] 内省略，图标恒定 26。
///
/// 颜色不用自己给：包在 icon 槽外面套了 `IconTheme` + `DefaultTextStyle`
/// （都用当前状态的图标色），标签的字号 / 字重才是这里要定的。
class _LiquidTabContent extends StatelessWidget {
  const _LiquidTabContent({
    required this.item,
    required this.selected,
    required this.labelMaxWidth,
  });

  final GlassTabItem item;
  final bool selected;
  final double labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    Widget icon = Icon(selected ? (item.activeIcon ?? item.icon) : item.icon);
    if (item.badge != null) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(top: -4, right: -6, child: item.badge!),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        // 与自绘那版同一口径（图标到标签 2、字号 11.5）。
        const SizedBox(height: 2),
        _TabLabel(
          label: item.label,
          maxWidth: labelMaxWidth,
          style: TextStyle(
            fontSize: 11.5,
            height: 1.1,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
