import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';

class ForumReplyBottomSheet extends StatefulWidget {
  const ForumReplyBottomSheet({
    super.key,
    required this.threadId,
    this.onSubmit,
    this.maxBodyInputLimit = 100000,
    this.initialContent,
  });

  final String threadId;
  final VoidCallback? onSubmit;
  final int maxBodyInputLimit;
  final String? initialContent;

  @override
  State<ForumReplyBottomSheet> createState() => _ForumReplyBottomSheetState();
}

class _ForumReplyBottomSheetState extends State<ForumReplyBottomSheet> {
  final ForumService _forumService = Get.find<ForumService>();
  final ConfigService _configService = Get.find<ConfigService>();
  late TextEditingController _bodyController;
  late FocusNode _focusNode;
  bool _isLoading = false;
  int _currentBodyLength = 0;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController(text: widget.initialContent ?? '');
    _focusNode = FocusNode();

    _bodyController.addListener(() {
      if (mounted) {
        setState(() {
          _currentBodyLength = _bodyController.text.length;
        });
      }
    });

    // 在下一帧请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
    _focusNode.dispose();
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
                child: CustomMarkdownBody(
                  data: _bodyController.text,
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
    if (_currentBodyLength > widget.maxBodyInputLimit || _currentBodyLength == 0) {
      return;
    }

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.contentCanNotBeEmpty,
          type: MDToastType.error,
        ),
      );
      return;
    }

    final bool hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
    if (!hasAgreed) {
      await _showRulesDialog();
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _forumService.postReply(
      widget.threadId,
      _bodyController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (result.isSuccess) {
      widget.onSubmit?.call();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      showToastWidget(
        MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.reply_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    t.forum.reply,
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
                  controller: _bodyController,
                  focusNode: _focusNode,
                  maxLines: 5,
                  maxLength: widget.maxBodyInputLimit,
                  decoration: InputDecoration(
                    labelText: t.common.content,
                    hintText: t.common.writeYourContentHere,
                    border: const OutlineInputBorder(),
                    counterText: '$_currentBodyLength/${widget.maxBodyInputLimit}',
                    errorText: _currentBodyLength > widget.maxBodyInputLimit
                        ? t.errors.exceedsMaxLength(max: widget.maxBodyInputLimit.toString())
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
                      onPressed: _bodyController.text.isNotEmpty
                          ? () {
                              Get.dialog(
                                TranslationDialog(
                                  text: _bodyController.text,
                                  defaultLanguageKeyMode: false,
                                ),
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.translate,
                        color: _bodyController.text.isEmpty
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
                      onPressed: (_currentBodyLength > widget.maxBodyInputLimit ||
                              _currentBodyLength == 0)
                          ? null
                          : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(t.common.send),
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

// 显示论坛回复底部弹窗
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ForumReplyBottomSheet(
    threadId: 'thread_id',
    initialContent: 'Reply #1: @username\n---\n',
    onSubmit: () {
      // 刷新帖子列表
      listSourceRepository.refresh();
    },
  ),
);
*/
