import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class MarkdownPreviewDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.common.preview,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showTitle && title != null && title!.isNotEmpty) ...[
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  CustomMarkdownBody(
                    data: content,
                    clickInternalLinkByUrlLaunch: true,
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
  /// 显示内容预览
  static void showPreview(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MarkdownPreviewDialog(content: content),
    );
  }

  /// 显示带标题的内容预览
  static void showPreviewWithTitle(BuildContext context, String content, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MarkdownPreviewDialog(
        content: content,
        title: title,
        showTitle: true,
      ),
    );
  }
}
