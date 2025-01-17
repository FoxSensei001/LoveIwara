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

class ForumReplyDialog extends StatefulWidget {
  const ForumReplyDialog({
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
  State<ForumReplyDialog> createState() => _ForumReplyDialogState();
}

class _ForumReplyDialogState extends State<ForumReplyDialog> {
  final ForumService _forumService = Get.find<ForumService>();
  final ConfigService _configService = Get.find<ConfigService>();
  late TextEditingController _bodyController;
  late FocusNode _focusNode;
  bool _isLoading = false;
  int _currentBodyLength = 0;

  @override
  void initState() {
    super.initState();
    final bool disableQuote = _configService[ConfigService.DISABLE_FORUM_REPLY_QUOTE_KEY];
    _bodyController = TextEditingController(text: disableQuote ? null : widget.initialContent);
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
      await _configService.setSetting(ConfigService.RULES_AGREEMENT_KEY, true);
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

    final bool hasAgreed = _configService[ConfigService.RULES_AGREEMENT_KEY];
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
        AppService.tryPop();
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
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      t.forum.reply,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
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
                      IconButton(
                        onPressed: () => AppService.tryPop(),
                        icon: const Icon(Icons.close),
                        tooltip: t.common.close,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 内容输入框
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
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Obx(() {
                    final bool hasAgreed =
                        _configService[ConfigService.RULES_AGREEMENT_KEY];
                    return TextButton.icon(
                      onPressed: () => _showRulesDialog(),
                      icon: Icon(
                        hasAgreed
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      label: Text(t.common.agreeToRules),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  }),
                  TextButton(
                    onPressed: () => AppService.tryPop(),
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
      ),
    );
  }
} 