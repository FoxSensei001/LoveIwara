import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/comment_structure_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 重新求值一次小尾巴，返回新的样子；失败返回 null（保持原样）。
typedef SignatureRegenerate = Future<String?> Function();

/// 写作侧的「发出去之后长什么样」。
///
/// ⛔ 这只弹窗**不再**接收一串 compose 好的 markdown。它按 正文 / 引用 /
/// 小尾巴 三段收，交给 [CommentStructurePreview] 用**和评论列表完全相同**的
/// 呈现件去画。理由写在那个类上：拿 compose 的结果跑 markdown，引用头会变成
/// 引用块、小尾巴会变成全宽 `<hr>` 加一行正文大小的字，和发出去之后的样子对
/// 不上，预览就失去了意义。
class MarkdownPreviewDialog extends StatefulWidget {
  const MarkdownPreviewDialog({
    super.key,
    required this.content,
    this.title,
    this.showTitle = false,
    this.quote,
    this.signature,
    this.onRegenerateSignature,
  });

  /// 作者自己写的正文（输入框里那部分）。
  final String content;

  final String? title;
  final bool showTitle;

  /// 这条回复冲着哪一楼去，没有就不画引用条。
  final ReplyQuote? quote;

  /// 小尾巴**求值后**的样子，没有就不画脚注行。
  final String? signature;

  /// 非 null 时小尾巴行尾出现一枚「换一句」。
  ///
  /// 只有模板里真的引用了数据源（一言之类）才该传——纯本地变量的小尾巴
  /// 没有「再生成一次」这回事，摆一枚按不出变化的钮只会让人以为是坏的。
  final SignatureRegenerate? onRegenerateSignature;

  @override
  State<MarkdownPreviewDialog> createState() => _MarkdownPreviewDialogState();
}

class _MarkdownPreviewDialogState extends State<MarkdownPreviewDialog> {
  /// 「显示原始文本」由标题行那枚玻璃圆钮受控（正文内置行内开关已关闭）。
  late bool _showOriginal;
  bool _hasProcessedContent = false;

  /// 当前显示的小尾巴。点过「换一句」之后它和 widget.signature 不再相同。
  String? _signature;
  bool _regenerating = false;

  @override
  void initState() {
    super.initState();
    _showOriginal =
        Get.find<ConfigService>()[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    _signature = widget.signature;
  }

  @override
  void didUpdateWidget(MarkdownPreviewDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signature != widget.signature) {
      _signature = widget.signature;
    }
  }

  Future<void> _regenerate() async {
    if (_regenerating) return;
    setState(() => _regenerating = true);
    String? next;
    try {
      next = await widget.onRegenerateSignature!();
    } finally {
      if (mounted) {
        setState(() {
          _regenerating = false;
          // 取不到就保持原样：一次取不到不该让预览里的小尾巴凭空消失。
          if (next != null && next.trim().isNotEmpty) _signature = next;
        });
      }
    }
  }

  Widget? _buildSignatureAction() {
    if (widget.onRegenerateSignature == null) return null;
    // ⛔ loading 走 GlassIconButton.loading（图标原位换沙漏），不要自己往
    // icon 里塞 CircularProgressIndicator——理由写在那个字段上。
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GlassIconButton(
        standalone: true,
        size: 26,
        iconSize: 14,
        loading: _regenerating,
        icon: const Icon(Icons.refresh_rounded),
        tooltip: t.settings.signatureRegenerate,
        onPressed: _regenerate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassDraggableBottomSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.common.preview,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                MarkdownOriginalTextToggle(
                  style: MarkdownToggleStyle.glass,
                  visible: _hasProcessedContent,
                  showOriginal: _showOriginal,
                  padding: const EdgeInsets.only(right: 4),
                  onChanged: (v) => setState(() => _showOriginal = v),
                ),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (widget.showTitle &&
                      widget.title != null &&
                      widget.title!.isNotEmpty) ...[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CommentStructurePreview(
                    body: widget.content,
                    quote: widget.quote,
                    signature: _signature,
                    signatureTrailing: _buildSignatureAction(),
                    showOriginalBody: _showOriginal,
                    onBodyProcessedChanged: (v) {
                      if (_hasProcessedContent == v) return;
                      setState(() => _hasProcessedContent = v);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示Markdown预览的便捷方法
class MarkdownPreviewHelper {
  /// 显示内容预览。
  ///
  /// [quote] / [signature] 是**结构**，分开传而不是拼进 [content]——理由见
  /// [CommentStructurePreview] 的类文档。
  static void showPreview(
    BuildContext context,
    String content, {
    ReplyQuote? quote,
    String? signature,
    SignatureRegenerate? onRegenerateSignature,
  }) {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => MarkdownPreviewDialog(
        content: content,
        quote: quote,
        signature: signature,
        onRegenerateSignature: onRegenerateSignature,
      ),
    );
  }

  /// 显示带标题的内容预览
  static void showPreviewWithTitle(
    BuildContext context,
    String content,
    String title, {
    String? signature,
    SignatureRegenerate? onRegenerateSignature,
  }) {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => MarkdownPreviewDialog(
        content: content,
        title: title,
        showTitle: true,
        signature: signature,
        onRegenerateSignature: onRegenerateSignature,
      ),
    );
  }
}
