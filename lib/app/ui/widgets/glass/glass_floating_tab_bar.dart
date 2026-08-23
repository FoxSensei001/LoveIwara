import 'package:flutter/material.dart';
// 带前缀：两个玻璃包的公开面与本仓库自己的组件大面积重名（见
// `liquid_glass_material.dart` 顶部那段说明），不加前缀会一片 ambiguous_import。
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lgw;
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
/// # 同项重复点击 = 刷新
///
/// 包是在 **`onTapDown`** 那一刻回调 [onTap] 的（不是抬手），并且**同项也回调**，
/// 所以「再次点击当前栏目 → 回顶 + 重载」这条既有行为仍然成立。代价是：从当前
/// 选中项按住再拖走，会先触发一次该栏目的刷新（按住超过 ~100ms 时 tap 识别器
/// 才会先于拖拽发出 down）。调用方那边有 1s 节流兜底，不会连发。
class GlassFloatingTabBar extends StatelessWidget {
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
  final ValueChanged<int> onTap;

  /// 右侧并排的独立圆钮；为 null 时整条只有胶囊。
  final GlassFloatingBarAction? action;

  final double height;

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
    final GlassFloatingBarAction? action = this.action;

    return lgw.GlassTabBar.bottom(
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
      selectedIndex: items.isEmpty
          ? 0
          : currentIndex.clamp(0, items.length - 1),
      onTabSelected: onTap,
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
        tint: GlassTokens.liquidTint(cs),
      ),
      quality: lgw.GlassQuality.premium,
      indicatorColor: GlassTokens.tabIndicatorTint(cs),
    );
  }
}
