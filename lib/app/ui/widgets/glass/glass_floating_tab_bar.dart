import 'dart:async';

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
// 带前缀：两个玻璃包的公开面与本仓库自己的组件大面积重名（见
// `liquid_glass_material.dart` 顶部那段说明），不加前缀会一片 ambiguous_import。
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';

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
  });

  final IconData icon;

  /// 无障碍标签（这枚钮只有图标，屏幕阅读器念的是它）。
  final String label;

  final VoidCallback onPressed;
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

  /// 图标 + 角标。角标是 `Positioned`，靠 [Icon] 撑出 Stack 的尺寸。
  Widget _icon(GlassTabItem item, IconData data) {
    final Widget icon = Icon(data);
    if (item.badge == null) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(top: -4, right: -6, child: item.badge!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final GlassFloatingBarAction? action = widget.action;
    final List<GlassTabItem> items = widget.items;
    final double height = widget.height;

    // 假玻璃档：整只换成自绘那一版（[_PlainFloatingTabBar]）。
    //
    // 这块是**全站唯一一处 `GlassSurface` 管不到的 chrome**：胶囊、果冻指示器、
    // 右侧圆钮都由 `liquid_glass_widgets` 自己画，[LiquidGlassScope] 对它没有
    // 任何作用。用户在主题设置里关掉液态玻璃之后，整个 App 只剩它还在采样背景
    // ——最显眼的那一条，还偏偏是关不掉的那一条。所以档位判断放在这里，而不是
    // 让调用方去挑该建哪一个。
    //
    // 换掉之后必然少两件事：果冻指示器的挤压回弹、按住不放左右拖着换项。它们
    // 都是液态材质自带的手感（拖动那条还依赖包内部的手势），假玻璃档下本来就
    // 不该有；点按换项、同项也回调、角标、无障碍语义都保留。
    if (!GlassMaterialScope.isLiquid(context)) {
      return _PlainFloatingTabBar(
        items: items,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        action: action,
        height: height,
      );
    }

    // raw `Listener` 只是旁听手指的起落（不进竞技场、不改命中测试），用来判断
    // 包报上来的下标该立刻落地还是先压着——见类文档「落地时机」。
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerRelease,
      onPointerCancel: _handlePointerRelease,
      child: lgw.GlassTabBar.bottom(
        tabs: [
          for (final item in items)
            lgw.GlassTab(
              icon: _icon(item, item.icon),
              activeIcon: item.activeIcon == null
                  ? null
                  : _icon(item, item.activeIcon!),
              label: item.label,
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

        // ---- 排版：沿用自绘那版标定过的字号 / 图标尺寸 ----
        iconSize: 26,
        labelFontSize: 11.5,
        iconLabelSpacing: 2,
        selectedIconColor: cs.primary,
        unselectedIconColor: cs.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          height: 1.1,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          height: 1.1,
          fontWeight: FontWeight.w500,
        ),

        // ---- 材质：与全站 chrome 同一份玻璃（见 GlassTokens.widgetsGlass）----
        settings: GlassTokens.widgetsGlass(
          cs,
          tint: GlassTokens.widgetsTint(cs),
        ),
        quality: lgw.GlassQuality.premium,
        indicatorColor: GlassTokens.tabIndicatorTint(cs),
      ),
    );
  }
}


/// 浮动底栏的**假玻璃档**实现：传统 [GlassSurface] 胶囊 + 滑动高亮块 + 右侧圆钮。
///
/// 这是 2026-08-23 换包之前的那一版（`AnimatedPositioned` 高亮块），换包时被
/// 整只删掉，现在因为全局材质开关又请了回来——差别是**不再有「长按拾起跟手
/// 拖拽」**：那条当初是为了不和页面的横向手势打架才做成长按的，而假玻璃档
/// 本来就是「省事优先」的一档，点按换项足够。
class _PlainFloatingTabBar extends StatelessWidget {
  const _PlainFloatingTabBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.action,
    required this.height,
  });

  final List<GlassTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlassFloatingBarAction? action;
  final double height;

  /// 各项之间的水平间距（高亮块两侧各让出这么多）。
  static const double _itemMargin = 2;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double innerHeight = height - 8;
    final GlassFloatingBarAction? action = this.action;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GlassSurface(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double slotWidth = items.isEmpty
                    ? constraints.maxWidth
                    : constraints.maxWidth / items.length;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (items.isNotEmpty)
                      AnimatedPositioned(
                        duration: GlassTokens.motionDuration,
                        curve: GlassTokens.motionCurve,
                        left: slotWidth * currentIndex + _itemMargin,
                        top: (height - innerHeight) / 2,
                        width: slotWidth - _itemMargin * 2,
                        height: innerHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: GlassTokens.selectedHighlight(cs),
                            borderRadius: BorderRadius.circular(
                              innerHeight / 2,
                            ),
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: _PlainTab(
                              item: items[i],
                              selected: i == currentIndex,
                              // 同项也回调：「再点一次当前栏目 → 回顶 + 重载」
                              // 这条与液态档一致。
                              onTap: () => onTap(i),
                              height: height,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          GlassIconButton(
            standalone: true,
            // 圆钮直径恒等于栏高，否则与胶囊不齐（见 GlassTokens.floatingActionSize）。
            size: height,
            iconSize: 26,
            icon: Icon(action.icon),
            tooltip: action.label,
            onPressed: action.onPressed,
          ),
        ],
      ],
    );
  }
}

/// 假玻璃档下的一项：图标 + 文字 + 角标，选中底色由外面那块滑动高亮块负责。
class _PlainTab extends StatelessWidget {
  const _PlainTab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.height,
  });

  final GlassTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double innerHeight = height - 8;
    final IconData icon = selected ? (item.activeIcon ?? item.icon) : item.icon;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GlassPressable(
        scale: 0.94,
        onTap: onTap,
        builder: (context, pressed) => GlassAnimatedColors(
          colors: [
            selected ? cs.primary : cs.onSurfaceVariant,
            pressed ? cs.onSurface.withValues(alpha: 0.06) : Colors.transparent,
          ],
          builder: (context, c) => Container(
            height: innerHeight,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: c[1],
              borderRadius: BorderRadius.circular(innerHeight / 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GlassAnimatedIcon(icon: Icon(icon, size: 26, color: c[0])),
                    if (item.badge != null)
                      Positioned(top: -4, right: -6, child: item.badge!),
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.1,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: c[0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
