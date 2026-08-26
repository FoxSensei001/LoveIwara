import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';

/// 标题组件：在标题**最前端**内联一个「翻译」按钮，与文本融为一体；
/// 当标题文本超过 [collapsedMaxLines] 行（默认一行）时，紧挨翻译按钮再显示一个
/// 上下折线箭头（chevron），用于展开 / 折叠完整标题。
///
/// - 折叠态：最多显示 [collapsedMaxLines] 行，超出以省略号（不可选文本）或截断
///   （可选文本）收尾；
/// - 展开态：显示完整标题；
/// - 是否显示折叠箭头由实际测量决定：仅当文本在预留出翻译按钮宽度后仍超过
///   [collapsedMaxLines] 行时才出现；此时点击标题文本本身（不止箭头）同样可以
///   展开 / 折叠。
///
/// 长按一律有去处：折叠态（以及不可选中的展开态）渲染的是一段纯 `Text`，
/// 自己没有任何选中 / 复制能力——短标题连折叠箭头都不出现，用户想复制标题
/// 就彻底没有入口。这两种情况统一补上「长按 → 完整标题弹窗」
/// （[showGlassFullTitleDialog]：全文可自由选取 + 复制 / 翻译按钮），
/// 与 header 里的 `GlassTitlePill` 长按落到同一个地方。
/// 可选中的展开态（视频标题）里 `SelectableText` 自带的长按选中 + 复制工具条
/// 更深、在手势竞技场里先赢一步，桌面端的拖选也照旧。
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
  late final TapGestureRecognizer _titleTapRecognizer;

  @override
  void initState() {
    super.initState();
    _titleTapRecognizer = TapGestureRecognizer()
      ..onTap = () => setState(() => _expanded = !_expanded);
  }

  @override
  void dispose() {
    _titleTapRecognizer.dispose();
    super.dispose();
  }

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
        )..layout(maxWidth: (maxWidth - iconSlotWidth).clamp(0.0, maxWidth));
        final bool isOverflowing = painter.didExceedMaxLines;

        // 用裸 Icon + GestureDetector 而非 IconButton：后者即便 padding/constraints
        // 置零，内部仍保留布局盒子与对齐留白，内联到文本里会有明显 gap。
        Widget inlineIconButton({
          required Widget iconChild,
          required VoidCallback onPressed,
          String? tooltip,
        }) {
          // 两个内联动作使用同一固定图标槽，避免各自的内边距把标题行高撑大，
          // 也让翻译与展开按钮在文字的中线处对齐。
          // HitTestBehavior.opaque 让整个图标槽都可点击。
          Widget child = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: SizedBox(
              width: iconSlotWidth,
              height: iconSlotWidth,
              child: Center(child: iconChild),
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
          TextSpan(
            text: displayText,
            // 仅在存在折叠/展开的意义（即文本确实溢出）时才让标题文本本身可点
            // 击触发展开/折叠，避免未溢出时误吞正常的文本点击（如选中）手势。
            recognizer: isOverflowing ? _titleTapRecognizer : null,
          ),
        ];

        final TextSpan rootSpan = TextSpan(
          style: effectiveStyle,
          children: spans,
        );

        // 折叠态需要用「…」提示被截断，但 SelectableText.rich 不支持
        // overflow 省略号（maxLines 只会硬裁切），所以折叠态一律用 Text.rich；
        // 展开态若需可选中（视频标题）则用 SelectableText.rich。
        // 两态各自预构建成独立 child，交给 AnimatedCrossFade 统一做「尺寸 + 淡入
        // 淡出」过渡，而不是让文本内容瞬间被替换（原先 AnimatedSize 只animate了
        // 外层盒子大小，文字本身在折叠瞬间就已直接跳变成省略号版本）。
        final Widget collapsedChild = Text.rich(
          rootSpan,
          maxLines: widget.collapsedMaxLines,
          overflow: TextOverflow.ellipsis,
        );
        final Widget expandedChild = widget.selectable
            ? SelectableText.rich(rootSpan)
            : Text.rich(rootSpan, overflow: TextOverflow.clip);

        // 长按一律有去处（见类文档）。挂在最外层而不是每个 child 上：opaque 让
        // 标题盒子里文字右边的空白也吃长按（短标题只占很窄一条），两态也就只有
        // 一条代码路径。可选中的展开态里 SelectableText 自己的长按识别器比这层
        // 深，竞技场里先它一步赢下，原本的长按选中 / 桌面拖选都不受影响。
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => showGlassFullTitleDialog(context, displayText),
          child: AnimatedCrossFade(
            duration: animDuration,
            sizeCurve: animCurve,
            firstCurve: animCurve,
            secondCurve: animCurve,
            alignment: Alignment.topLeft,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: collapsedChild,
            secondChild: expandedChild,
          ),
        );
      },
    );
  }
}
