import 'package:flutter/material.dart';

/// 「液态玻璃」风格的尺寸 / 颜色 token。
///
/// 设计来源：docs/mockups/telegram_chat_list_design.md（本地设计稿，已 gitignore）。
/// 全平台统一使用「半透明纯色渐变」而不是 BackdropFilter（性能 / 多端一致性）。
///
/// 「液态」的神在于**没有硬切**：任何 header 上的按钮组、分段胶囊、头像、
/// 徽标发生形变都要有过渡而不是被瞬间替换。形变过渡的原语和取值参见
/// `glass_morph.dart` 顶部的形变词汇表；[motionDuration] / [motionCurve]
/// 是所有形变共用的时值与曲线。
abstract final class GlassTokens {
  // ---- 尺寸 ----
  /// 玻璃胶囊 / 圆钮的标准高度。
  static const double pillHeight = 44;

  /// 胶囊组内单个图标按钮的占位尺寸。
  static const double groupIconButtonSize = 40;

  /// 图标尺寸。
  static const double iconSize = 22;

  /// 顶部 header 行高度（不含状态栏）。
  static const double headerRowHeight = 56;

  /// header 行下方再多渐隐多少距离。
  static const double headerFadeExtent = 56;

  /// 浮动 Tab 栏高度。
  static const double floatingTabBarHeight = 64;

  /// 浮动 Tab 栏距屏幕底部安全区的间距。
  static const double floatingTabBarBottomMargin = 4;

  /// 浮动 Tab 栏左右边距。
  static const double floatingTabBarSideMargin = 16;

  /// 浮动底栏旁的独立圆钮直径。
  static const double floatingActionSize = 60;

  /// 页面列表需要在安全区之上额外让出的高度（浮动底栏 + 间距 + 少量呼吸）。
  static const double floatingBarReservedExtent =
      floatingTabBarHeight + floatingTabBarBottomMargin + 8;

  /// 底部渐变蒙层在浮动底栏之上再延伸多少。
  static const double bottomFadeExtent = 56;

  // ---- 动效 ----
  static const Duration pressDuration = Duration(milliseconds: 120);
  static const Duration motionDuration = Duration(milliseconds: 200);
  static const Curve motionCurve = Curves.easeOutCubic;
  static const double pressedScale = 0.96;

  // ---- 颜色 ----
  /// 玻璃体底色（半透明，随明暗主题翻转）。
  static Color fill(ColorScheme cs) =>
      cs.surfaceContainerLow.withValues(alpha: 0.80);

  /// 玻璃体按下时的底色。
  static Color pressedFill(ColorScheme cs) =>
      Color.alphaBlend(cs.onSurface.withValues(alpha: 0.08), fill(cs));

  /// 玻璃体内侧细描边。
  static Color stroke(ColorScheme cs) => cs.outlineVariant.withValues(
    alpha: cs.brightness == Brightness.dark ? 0.45 : 0.35,
  );

  /// 玻璃体外投影。
  static List<BoxShadow> shadow(ColorScheme cs) => [
    BoxShadow(
      color: Colors.black.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.40 : 0.10,
      ),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  /// 选中态高亮底色（Tab / 分段）。
  static Color selectedHighlight(ColorScheme cs) =>
      cs.secondaryContainer.withValues(alpha: 0.9);

  /// 边缘渐变蒙层的基色。
  static Color scrimBase(ColorScheme cs) => cs.surface;
}

/// 把 Shell 为浮动底栏额外抬高的 `MediaQuery.padding.bottom` 还原成系统原始
/// 安全区（取 `viewPadding.bottom`）。
///
/// 用在**不被浮动底栏遮挡**、却处在 Shell 子树里的区域：例如页面 Scaffold 的
/// 抽屉（drawer / endDrawer）——它们从侧边滑出盖在底栏之上，不需要给底栏让位。
class RemoveFloatingBarInset extends StatelessWidget {
  const RemoveFloatingBarInset({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (mq.padding.bottom <= mq.viewPadding.bottom) return child;
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: mq.viewPadding.bottom),
      ),
      child: child,
    );
  }
}
