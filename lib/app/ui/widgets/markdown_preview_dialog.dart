import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class MarkdownPreviewDialog extends StatefulWidget {
  const MarkdownPreviewDialog({
    super.key,
    required this.content,
    this.title,
    this.showTitle = false,
  });

  final String content;
  final String? title;
  final bool showTitle;

  @override
  State<MarkdownPreviewDialog> createState() => _MarkdownPreviewDialogState();
}

class _MarkdownPreviewDialogState extends State<MarkdownPreviewDialog> {
  /// 「显示原始文本」由标题行那枚玻璃圆钮受控（正文内置行内开关已关闭）。
  late bool _showOriginal;
  bool _hasProcessedContent = false;

  @override
  void initState() {
    super.initState();
    _showOriginal = Get.find<ConfigService>()[ConfigKey
        .SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        // 全站 DraggableScrollableSheet 都自己管背景/圆角，这份原来漏了，
        // 靠 showModalBottomSheet 的默认系统背景兜底——跟别的弹窗对不上口径。
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // 拖拽条，与全站其它 DraggableScrollableSheet 同一口径
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
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
                padding: EdgeInsets.fromLTRB(
                  16.0,
                  16.0,
                  16.0,
                  16.0 + computeSheetBottomInset(context),
                ),
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
                    CustomMarkdownBody(
                      data: widget.content,
                      clickInternalLinkByUrlLaunch: true,
                      initialShowUnprocessedText: _showOriginal,
                      onProcessedContentChanged: (v) {
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
      ),
    );
  }
}

/// 显示Markdown预览的便捷方法
class MarkdownPreviewHelper {
  /// 显示内容预览
  static void showPreview(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkdownPreviewDialog(content: content),
    );
  }

  /// 显示带标题的内容预览
  static void showPreviewWithTitle(BuildContext context, String content, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkdownPreviewDialog(
        content: content,
        title: title,
        showTitle: true,
      ),
    );
  }
}
