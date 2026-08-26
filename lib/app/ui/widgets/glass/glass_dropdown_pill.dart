import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';

/// 下拉入口的**无壳内容**：`[child] ▾`，按下整只压深一档。
///
/// 玻璃壳一律由外层的 [GlassCapsuleMorph] 提供（见 [GlassDropdownPill]）——
/// 触发位是胶囊的全部内容，按下再自缩会把整只胶囊带得一起抖，所以这里
/// `scale: 1.0`，反馈交给底色与菜单弹出本身。
///
/// 两个用处：
///   - [GlassDropdownPill]：文字标签式的下拉钮（下载页的分类筛选）。
///   - `GlassAdaptiveSegmentedControl`：分段胶囊摆不下时退化出来的那只下拉钮，
///     内容是跟手翻牌的 [GlassFlipLabel]。
class GlassDropdownTrigger extends StatelessWidget {
  const GlassDropdownTrigger({
    super.key,
    required this.child,
    required this.onTap,
    this.opensOverlay = true,
    this.showArrow = true,
    this.height = GlassTokens.pillHeight,
  });

  /// 无壳内容（文字 / 翻牌标签 / 图标 + 文字…），不含右边那只箭头。
  final Widget child;

  /// 拿到的是**触发位自身**的 context——[showGlassMenu] 靠它量落点。
  final void Function(BuildContext anchorContext) onTap;

  /// 这一下是不是「吐出一张浮层」。真值时长按也能打开，且长按不抬手可以直接
  /// 划到某一条上松手选中（见 [GlassTapArea.opensOverlay]）。点了是跳页面的
  /// 场合传 false。
  final bool opensOverlay;

  /// 右边那只 `▾`。点了不是开菜单（[opensOverlay] 为假）的场合通常也不该有。
  final bool showArrow;

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Builder：落点与材质档位都要从触发位自身的 context 量。
    return Builder(
      builder: (anchorContext) => GlassPressable(
        opensOverlay: opensOverlay,
        onTap: () => onTap(anchorContext),
        scale: 1.0,
        builder: (context, pressed) => AnimatedContainer(
          duration: GlassTokens.pressDuration,
          curve: Curves.easeOut,
          height: height,
          decoration: BoxDecoration(
            color: pressed
                ? colorScheme.onSurface.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 14, right: showArrow ? 8 : 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                if (showArrow)
                  Icon(
                    Icons.arrow_drop_down,
                    size: 22,
                    color: colorScheme.onSurface,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// header 上的「当前是谁 ▾」玻璃胶囊。
///
/// # 什么时候用它、什么时候用分段胶囊
///
/// 分段胶囊（tab）是给**固定的、少数几个平级视图**用的；用户自己建出来的东西
/// （下载分类这种，数量不封顶、随时增删）摆成一排选中态标签，读起来就是 tab，
/// 但它其实是个**筛选**——2026-08-26 用户原话：「tab 不是用来展示这种效果的」。
/// 这类「N 选一」一律走下拉：当前选中的那个亮在胶囊上，点开才铺开全部
/// （与筛选抽屉里「单选项一律换 Select」是同一条规矩）。
///
/// 标签变化时胶囊自己做宽度形变 + 内容交接（[GlassCapsuleMorph] 单壳常驻），
/// 不是两只胶囊硬切。
class GlassDropdownPill extends StatelessWidget {
  const GlassDropdownPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.opensOverlay = true,
    this.showArrow = true,
    this.height = GlassTokens.pillHeight,
  });

  /// 胶囊上的字：当前选中项（带计数就自己拼进来）。
  final String label;

  final IconData? icon;

  /// 见 [GlassDropdownTrigger.onTap]。
  final void Function(BuildContext anchorContext) onTap;

  /// 见 [GlassDropdownTrigger.opensOverlay]。
  final bool opensOverlay;

  /// 见 [GlassDropdownTrigger.showArrow]。
  final bool showArrow;

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassCapsuleMorph(
      height: height,
      child: KeyedSubtree(
        // 换了标签就是一次内容交接：外层胶囊据此做宽度形变 + 交叉淡入。
        key: ValueKey('${icon?.codePoint}|$label'),
        child: GlassDropdownTrigger(
          onTap: onTap,
          opensOverlay: opensOverlay,
          showArrow: showArrow,
          height: height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colorScheme.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
