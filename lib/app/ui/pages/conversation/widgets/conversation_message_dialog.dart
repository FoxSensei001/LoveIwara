import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

class ConversationMessageDialog extends StatefulWidget {
  const ConversationMessageDialog({
    super.key,
    required this.conversationId,
    this.onSubmit,
  });

  final String conversationId;
  final VoidCallback? onSubmit;

  @override
  State<ConversationMessageDialog> createState() => _ConversationMessageDialogState();
}

class _ConversationMessageDialogState extends State<ConversationMessageDialog> {
  final ConversationService _conversationService = Get.find<ConversationService>();
  late TextEditingController _bodyController;
  bool _isLoading = false;
  int _currentBodyLength = 0;

  // 内容最大长度
  static const int maxBodyLength = 1000;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();

    _bodyController.addListener(() {
      if (mounted) {
        setState(() {
          _currentBodyLength = _bodyController.text.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bodyController.dispose();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomMarkdownBody(
                      data: _bodyController.text,
                      clickInternalLinkByUrlLaunch: true,
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

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  void _handleSubmit() async {
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;

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

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _conversationService.sendMessage(
      widget.conversationId,
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
        Navigator.pop(context);
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
                      t.conversation.sendMessage,
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
                        onPressed: () => Navigator.pop(context),
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
                maxLines: 5,
                maxLength: maxBodyLength,
                decoration: InputDecoration(
                  labelText: t.common.content,
                  hintText: t.common.writeYourContentHere,
                  border: const OutlineInputBorder(),
                  counterText: '$_currentBodyLength/$maxBodyLength',
                  errorText: _currentBodyLength > maxBodyLength
                      ? t.errors.exceedsMaxLength(max: maxBodyLength.toString())
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(t.common.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_currentBodyLength > maxBodyLength ||
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