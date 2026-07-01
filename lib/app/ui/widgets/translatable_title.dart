import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';

/// 标题组件：在标题**最前端**内联一个「翻译」按钮，与文本融为一体；
/// 当标题文本超过 [collapsedMaxLines] 行（默认一行）时，紧挨翻译按钮再显示一个
/// 上下折线箭头（chevron），用于展开 / 折叠完整标题。
///
/// - 折叠态：最多显示 [collapsedMaxLines] 行，超出以省略号（不可选文本）或截断
///   （可选文本）收尾；
/// - 展开态：显示完整标题；
/// - 是否显示折叠箭头由实际测量决定：仅当文本在预留出翻译按钮宽度后仍超过
///   [collapsedMaxLines] 行时才出现。
class TranslatableTitle extends StatefulWidget {
  final String text;
  final TextStyle? style;

  /// 折叠时允许的最大行数（默认 1 行）。
  final int collapsedMaxLines;

  /// 文本是否可选中（视频标题沿用可选中，图库标题为普通文本）。
  final bool selectable;

  /// 内联图标尺寸。
  final double iconSize;

  const TranslatableTitle({
    super.key,
    required this.text,
    this.style,
    this.collapsedMaxLines = 1,
    this.selectable = false,
    this.iconSize = 20,
  });

  @override
  State<TranslatableTitle> createState() => _TranslatableTitleState();
}

class _TranslatableTitleState extends State<TranslatableTitle> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final String displayText = widget.text;
    final TextStyle effectiveStyle =
        widget.style ?? DefaultTextStyle.of(context).style;
    final Color primary = Theme.of(context).colorScheme.primary;
    // 单个内联图标的可点击占位宽度（图标 + 左右各 4px 内边距）。
    final double iconSlotWidth = widget.iconSize + 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        // 仅预留「翻译」按钮的宽度来判断是否超过折叠行数：
        // 折叠箭头只有在超出时才出现，故不参与这里的判定。
        final TextPainter painter = TextPainter(
          text: TextSpan(text: displayText, style: effectiveStyle),
          maxLines: widget.collapsedMaxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(
            maxWidth: (maxWidth - iconSlotWidth).clamp(0.0, maxWidth),
          );
        final bool isOverflowing = painter.didExceedMaxLines;

        // 用裸 Icon + GestureDetector 而非 IconButton：后者即便 padding/constraints
        // 置零，内部仍保留布局盒子与对齐留白，内联到文本里会有明显 gap。
        Widget inlineIconButton({
          required Widget iconChild,
          required VoidCallback onPressed,
          String? tooltip,
        }) {
          // 纵向多给、横向少给内边距：既把可点击区域撑到 ~28x36（手指好点），
          // 又不至于把图标之间、图标与文字之间的间距拉得太开。
          // HitTestBehavior.opaque 让整个内边距区域都可点击。
          Widget child = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: iconChild,
            ),
          );
          if (tooltip != null && tooltip.isNotEmpty) {
            child = Tooltip(message: tooltip, child: child);
          }
          return child;
        }

        const Duration animDuration = Duration(milliseconds: 220);
        const Curve animCurve = Curves.easeInOut;

        final List<InlineSpan> spans = [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: inlineIconButton(
              iconChild: Icon(
                Icons.translate,
                size: widget.iconSize,
                color: primary,
              ),
              onPressed: () =>
                  showTranslationDialog(context, text: displayText),
            ),
          ),
          if (isOverflowing)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: inlineIconButton(
                // 折叠/展开箭头做 180° 旋转形变动画（向下 ⇄ 向上）。
                iconChild: AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: animDuration,
                  curve: animCurve,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: widget.iconSize,
                    color: primary,
                  ),
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
          TextSpan(text: displayText),
        ];

        final TextSpan rootSpan = TextSpan(
          style: effectiveStyle,
          children: spans,
        );
        final int? maxLines = _expanded ? null : widget.collapsedMaxLines;

        // 折叠态需要用「…」提示被截断，但 SelectableText.rich 不支持
        // overflow 省略号（maxLines 只会硬裁切）。因此仅在「展开且需可选中」
        // 时才用 SelectableText.rich（此时是完整文本，保留可选中体验）；
        // 其余情况（含所有折叠态）一律用支持 ellipsis 的 Text.rich。
        final Widget textWidget = (widget.selectable && _expanded)
            ? SelectableText.rich(rootSpan, maxLines: maxLines)
            : Text.rich(
                rootSpan,
                maxLines: maxLines,
                overflow: _expanded
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              );

        // 展开/折叠时标题高度做形变动画（与箭头旋转同步），逐行展开而非瞬变。
        return AnimatedSize(
          duration: animDuration,
          curve: animCurve,
          alignment: Alignment.topLeft,
          child: textWidget,
        );
      },
    );
  }
}
