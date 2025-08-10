import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';

class CommentInputBottomSheet extends StatefulWidget {
  final String? initialText;
  final Function(String) onSubmit;
  final String title;
  final String submitText;
  final int maxLength;

  const CommentInputBottomSheet({
    super.key,
    this.initialText,
    required this.onSubmit,
    required this.title,
    required this.submitText,
    this.maxLength = 1000,
  });

  @override
  State<CommentInputBottomSheet> createState() => _CommentInputBottomSheetState();
}

class _CommentInputBottomSheetState extends State<CommentInputBottomSheet> {
  late TextEditingController _controller;
  bool _isLoading = false;
  int _currentLength = 0;
  final ConfigService _configService = Get.find<ConfigService>();

  @override
  void initState() {
    super.initState();
    final configService = Get.find<ConfigService>();
    String initialText = widget.initialText ?? '';
    
    if (configService[ConfigKey.ENABLE_SIGNATURE_KEY]) {
      initialText += configService[ConfigKey.SIGNATURE_CONTENT_KEY];
    }
    
    _controller = TextEditingController(text: initialText);
    _currentLength = _controller.text.length;
    _controller.addListener(() {
      setState(() {
        _currentLength = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
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
                    slang.t.common.preview,
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
                child: CustomMarkdownBody(
                  data: _controller.text,
                  clickInternalLinkByUrlLaunch: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  Future<void> _showRulesDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => RulesAgreementDialog(
          scrollController: scrollController,
        ),
      ),
    );

    if (result == true) {
      await _configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, true);
      if (mounted) {
        _handleSubmit();
      }
    }
  }

  void _handleSubmit() async {
    if (_currentLength > widget.maxLength || _currentLength == 0) return;

    final bool hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
    if (!hasAgreed) {
      await _showRulesDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });
    await widget.onSubmit(_controller.text);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 输入框
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  maxLength: widget.maxLength,
                  decoration: InputDecoration(
                    hintText: t.common.writeYourCommentHere,
                    border: const OutlineInputBorder(),
                    counterText: '$_currentLength/${widget.maxLength}',
                    errorText: _currentLength > widget.maxLength 
                        ? t.errors.exceedsMaxLength(max: widget.maxLength.toString())
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // 操作按钮行
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: _controller.text.isNotEmpty
                          ? () {
                              Get.dialog(
                                TranslationDialog(
                                  text: _controller.text,
                                  defaultLanguageKeyMode: false,
                                ),
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.translate,
                        color: _controller.text.isEmpty
                            ? Theme.of(context).disabledColor
                            : null,
                      ),
                      tooltip: t.common.translate,
                    ),
                    IconButton(
                      onPressed: _showMarkdownHelp,
                      icon: const Icon(Icons.help_outline),
                      tooltip: t.markdown.markdownSyntax,
                    ),
                    IconButton(
                      onPressed: _showPreview,
                      icon: const Icon(Icons.preview),
                      tooltip: t.common.preview,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 底部操作按钮
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Obx(() {
                      final bool hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
                      return TextButton.icon(
                        onPressed: () => _showRulesDialog(),
                        icon: Icon(
                          hasAgreed ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                        label: Text(t.common.agreeToRules),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.common.cancel),
                    ),
                    ElevatedButton(
                      onPressed: _currentLength > widget.maxLength || _currentLength == 0
                          ? null
                          : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.submitText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
使用示例：

// 显示评论输入底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CommentInputBottomSheet(
    title: '发送评论',
    submitText: '发送',
    onSubmit: (text) async {
      // 处理评论提交逻辑
      await commentController.postComment(text);
    },
  ),
);

// 显示回复评论底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CommentInputBottomSheet(
    title: '回复评论',
    submitText: '回复',
    initialText: '@用户名 ',
    onSubmit: (text) async {
      await commentController.postComment(text, parentId: commentId);
    },
  ),
);
*/
