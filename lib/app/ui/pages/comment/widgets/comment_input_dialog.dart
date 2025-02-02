import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';

class CommentInputDialog extends StatefulWidget {
  final String? initialText;
  final Function(String) onSubmit;
  final String title;
  final String submitText;
  final int maxLength;


  const CommentInputDialog({
    super.key,
    this.initialText,
    required this.onSubmit,
    required this.title,
    required this.submitText,
    this.maxLength = 1000,
  });

  @override
  State<CommentInputDialog> createState() => _CommentInputDialogState();
}

class _CommentInputDialogState extends State<CommentInputDialog> {
  late TextEditingController _controller;
  bool _isLoading = false;
  int _currentLength = 0;
  final ConfigService _configService = Get.find<ConfigService>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
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
    return Dialog(
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
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                  onPressed: () => AppService.tryPop(),
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
    );
  }
}
