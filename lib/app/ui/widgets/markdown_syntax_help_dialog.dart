import 'package:flutter/material.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_original_text_toggle.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class MarkdownSyntaxHelp extends StatelessWidget {
  const MarkdownSyntaxHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否是窄屏设备（如手机）
    final isNarrowScreen = screenWidth < 600;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.markdown.markdownSyntax,
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
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16 + computeSheetBottomInset(context),
                ),
                children: [
                  _buildSection(
                    title: t.markdown.iwaraSpecialMarkdownSyntax,
                    items: [
                      _SyntaxItem(
                        title: t.markdown.internalLink,
                        syntax:
                            'https://iwara.tv/video/abc123\nhttps://iwara.tv/image/xyz789\nhttps://iwara.tv/profile/user123',
                        description: t.markdown.supportAutoConvertLinkBelow,
                      ),
                      _SyntaxItem(
                        title: t.markdown.mentionUser,
                        syntax: '@username',
                        description: t.markdown.mentionUserDescription,
                      ),
                    ],
                    isNarrowScreen: isNarrowScreen,
                  ),
                  _buildSection(
                    title: t.markdown.markdownBasicSyntax,
                    items: [
                      _SyntaxItem(
                        title: t.markdown.paragraphAndLineBreak,
                        syntax: t.markdown.paragraphAndLineBreakSyntax,
                        description:
                            t.markdown.paragraphAndLineBreakDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.textStyle,
                        syntax: t.markdown.textStyleSyntax,
                        description: t.markdown.textStyleDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.quote,
                        syntax: t.markdown.quoteSyntax,
                        description: t.markdown.quoteDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.list,
                        syntax: t.markdown.listSyntax,
                        description: t.markdown.listDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.linkAndImage,
                        syntax: t.markdown.linkAndImageSyntax(
                          imgUrl: CommonConstants.defaultAvatarUrl,
                          link: CommonConstants.iwaraBaseUrl,
                        ),
                        description: t.markdown.linkAndImageDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.title,
                        syntax: t.markdown.titleSyntax,
                        description: t.markdown.titleDescription,
                      ),
                      _SyntaxItem(
                        title: t.markdown.separator,
                        syntax: t.markdown.separatorSyntax,
                        description: t.markdown.separatorDescription,
                      ),
                    ],
                    isNarrowScreen: isNarrowScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SyntaxItem> items,
    required bool isNarrowScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map((item) => _buildSyntaxItem(item, isNarrowScreen)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSyntaxItem(_SyntaxItem item, bool isNarrowScreen) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            if (item.description != null) ...[
              const SizedBox(height: 8),
              Text(
                item.description!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            if (isNarrowScreen) ...[
              // 窄屏设备上垂直布局
              _buildSyntaxBox(item),
              const SizedBox(height: 12),
              _buildPreviewBox(item),
            ] else ...[
              // 宽屏设备上水平布局
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSyntaxBox(item)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPreviewBox(item)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSyntaxBox(_SyntaxItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slang.t.markdown.syntax,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.syntax,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBox(_SyntaxItem item) {
    return _SyntaxPreviewBox(item: item);
  }
}

/// 语法示例的渲染结果框。
///
/// 单独拆成有状态组件，只为托住「显示原始文本」的开关状态：
/// CustomMarkdownBody 的行内开关已关闭，那枚 only-icon 钮收进了框头
/// 「预览」标签那一行的右端。
class _SyntaxPreviewBox extends StatefulWidget {
  const _SyntaxPreviewBox({required this.item});

  final _SyntaxItem item;

  @override
  State<_SyntaxPreviewBox> createState() => _SyntaxPreviewBoxState();
}

class _SyntaxPreviewBoxState extends State<_SyntaxPreviewBox> {
  bool _showOriginal = false;
  bool _hasProcessedContent = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  slang.t.common.preview,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              MarkdownOriginalTextToggle(
                visible: _hasProcessedContent,
                showOriginal: _showOriginal,
                pillSize: 24,
                onChanged: (v) => setState(() => _showOriginal = v),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CustomMarkdownBody(
            data: widget.item.syntax,
            clickInternalLinkByUrlLaunch: true,
            initialShowUnprocessedText: _showOriginal,
            onProcessedContentChanged: (v) {
              if (_hasProcessedContent == v) return;
              setState(() => _hasProcessedContent = v);
            },
          ),
        ],
      ),
    );
  }
}

class _SyntaxItem {
  final String title;
  final String syntax;
  final String? description;

  const _SyntaxItem({
    required this.title,
    required this.syntax,
    this.description,
  });
}
