import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// [MarkdownOriginalTextToggle] 的外观族：放进哪种容器就选哪一款。
/// 三款都是 only-icon（文案退到 tooltip），不再像正文内置开关那样
/// 在内容下方独占一整行。
enum MarkdownToggleStyle {
  /// 评论 / 简介一类的动作行：浅色圆钮，默认 30 高，与同行的幽灵胶囊等高。
  pill,

  /// 弹窗标题行：独立玻璃圆钮，与同行的关闭钮同族。
  glass,

  /// 页面顶栏 `GlassButtonGroup` 内部：透明图标位。
  group,
}

/// 「显示原始文本 ↔ 显示处理后文本」的 only-icon 切换钮。
///
/// CustomMarkdownBody 早先自带一枚带文字的行内开关，会挤在正文下方自成一行；
/// 它已被整只移除，全站统一改为把这个动作收进外层**已有的**动作栏 / 标题行，
/// 正文那侧只保留两个接口：
///
/// ```dart
/// CustomMarkdownBody(
///   initialShowUnprocessedText: _showOriginal, // 受控当前状态
///   onProcessedContentChanged: (v) => setState(() => _hasProcessed = v),
/// )
/// ```
///
/// 然后在外层动作栏里放一枚本组件，`visible: _hasProcessed`。
///
/// [visible] 为 false 时整枚钮走 [GlassGroupSlot] 收起（宽度→0 + 淡出），
/// 与形变词汇表里「按钮组增删」同源——正文加载完才发现有加工差异时，
/// 按钮是长出来的，不是瞬间跳出来的。
class MarkdownOriginalTextToggle extends StatelessWidget {
  const MarkdownOriginalTextToggle({
    super.key,
    required this.showOriginal,
    required this.onChanged,
    this.visible = true,
    this.style = MarkdownToggleStyle.pill,
    this.pillSize = defaultPillSize,
    this.padding = EdgeInsets.zero,
  });

  /// 动作行常用高度，与评论 / 论坛楼层里幽灵胶囊的 `_actionPillHeight` 一致。
  static const double defaultPillSize = 30;

  /// 当前是否正显示原始（未加工）文本。
  final bool showOriginal;

  /// 切换回调，参数是切换后的新值。
  final ValueChanged<bool> onChanged;

  /// 是否有可切换的加工差异；false 时整枚钮收起。
  final bool visible;

  final MarkdownToggleStyle style;

  /// 仅 [MarkdownToggleStyle.pill] 生效。
  final double pillSize;

  /// 与同行相邻控件之间的间距。必须走这里而不是在外面包 `Padding`——
  /// 它挂在收起动画的**内侧**，钮收起时这段间距会一起归零，
  /// 不会在动作行里留下一块悬空的空白。
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final tooltip = showOriginal
        ? t.common.showProcessedText
        : t.common.showOriginalText;
    final iconData = showOriginal
        ? Icons.format_paint
        : Icons.format_paint_outlined;
    void toggle() => onChanged(!showOriginal);

    final Widget button;
    switch (style) {
      case MarkdownToggleStyle.glass:
        button = GlassIconButton(
          standalone: true,
          icon: Icon(iconData),
          tooltip: tooltip,
          onPressed: toggle,
        );
      case MarkdownToggleStyle.group:
        button = GlassIconButton(
          icon: Icon(iconData),
          tooltip: tooltip,
          onPressed: toggle,
        );
      case MarkdownToggleStyle.pill:
        button = _buildPill(context, iconData, tooltip, toggle);
    }

    return GlassGroupSlot(
      visible: visible,
      child: padding == EdgeInsets.zero
          ? button
          : Padding(padding: padding, child: button),
    );
  }

  Widget _buildPill(
    BuildContext context,
    IconData iconData,
    String tooltip,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // 开启（正在看原文）时用主色淡底提示「当前不是默认显示」，
    // 与动作行里其它带 color 的幽灵胶囊同一套底色规则。
    final fg = showOriginal ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final bg = showOriginal
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHigh;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: pillSize,
            height: pillSize,
            child: Center(
              child: GlassAnimatedIcon(
                icon: Icon(iconData, size: 16, color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
