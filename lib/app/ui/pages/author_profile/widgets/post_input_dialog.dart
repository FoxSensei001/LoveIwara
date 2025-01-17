import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

class PostInputDialog extends StatefulWidget {
  final Function(String title, String body) onSubmit;

  const PostInputDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<PostInputDialog> createState() => _PostInputDialogState();
}

class _PostInputDialogState extends State<PostInputDialog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _isLoading = false;
  int _currentTitleLength = 0;
  int _currentBodyLength = 0;
  final ConfigService _configService = Get.find<ConfigService>();

  // 标题最大长度
  static const int maxTitleLength = 100;
  // 内容最大长度
  static const int maxBodyLength = 50000;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    
    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });
    
    _bodyController.addListener(() {
      setState(() {
        _currentBodyLength = _bodyController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _showPreview() {
    final t = slang.t;
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
                    Text(
                      _titleController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
    final t = slang.t;
    if (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) return;
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.titleCanNotBeEmpty,
          type: MDToastType.error,
        ),
      );
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

    setState(() {
      _isLoading = true;
    });
    await widget.onSubmit(_titleController.text, _bodyController.text);
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
                    t.common.createPost,
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
            // 标题输入框
            TextField(
              controller: _titleController,
              maxLines: 1,
              maxLength: maxTitleLength,
              decoration: InputDecoration(
                labelText: t.common.title,
                hintText: t.common.enterTitle,
                border: const OutlineInputBorder(),
                counterText: '$_currentTitleLength/$maxTitleLength',
                errorText: _currentTitleLength > maxTitleLength 
                    ? t.errors.exceedsMaxLength(max: maxTitleLength.toString())
                    : null,
              ),
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
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Obx(() {
                  final bool hasAgreed = _configService[ConfigService.RULES_AGREEMENT_KEY];
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
                  onPressed: (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) ||
                           (_currentBodyLength > maxBodyLength || _currentBodyLength == 0)
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
    );
  }
} 