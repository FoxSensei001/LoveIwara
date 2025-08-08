import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class SignatureEditDialog extends StatefulWidget {
  final String initialContent;

  const SignatureEditDialog({super.key, required this.initialContent});

  @override
  State<SignatureEditDialog> createState() => _SignatureEditDialogState();
}

class _SignatureEditDialogState extends State<SignatureEditDialog> {
  late TextEditingController _controller;
  int _currentLength = 0;

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
                  originalData: _controller.text,
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
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

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    return AlertDialog(
      title: Text(t.settings.editSignature),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: t.settings.enterSignature,
              border: const OutlineInputBorder(),
              counterText: '$_currentLength/1000',
              errorText: _currentLength > 1000
                  ? t.errors.exceedsMaxLength(max: '1000')
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.common.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(t.common.confirm),
        ),
      ],
    );
  }
}