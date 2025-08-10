import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

abstract class BaseInputDialog extends StatefulWidget {
  final String dialogTitle;
  final String submitText;
  final List<TextInputFieldConfig> inputConfigs;
  final bool showRulesAgreement;

  const BaseInputDialog({
    super.key,
    required this.dialogTitle,
    required this.submitText,
    required this.inputConfigs,
    this.showRulesAgreement = true,
  });
}

abstract class BaseInputDialogState<T extends BaseInputDialog> extends State<T> {
  late List<TextEditingController> controllers;
  final ConfigService _configService = Get.find<ConfigService>();
  bool _isLoading = false;
  List<int> _currentLengths = [];

  @override
  void initState() {
    super.initState();
    controllers = widget.inputConfigs.map((e) => TextEditingController()).toList();
    _currentLengths = List.filled(controllers.length, 0);
    
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].addListener(() {
        setState(() {
          _currentLengths[i] = controllers[i].text.length;
        });
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isSubmitDisabled {
    for (int i = 0; i < widget.inputConfigs.length; i++) {
      if (_currentLengths[i] > widget.inputConfigs[i].maxLength ||
          _currentLengths[i] == 0) {
        return true;
      }
    }
    return false;
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

  void _showPreview(String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => PreviewPanel(
          content: content,
          scrollController: scrollController,
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

  Future<void> _handleSubmit() async {
    if (_isSubmitDisabled) return;

    if (widget.showRulesAgreement) {
      final bool hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
      if (!hasAgreed) {
        await _showRulesDialog();
        return;
      }
    }

    setState(() => _isLoading = true);
    await onSubmit();
    if (mounted) setState(() => _isLoading = false);
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.dialogTitle,
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
              tooltip: slang.t.common.markdownSyntaxHelp,
            ),
            IconButton(
              onPressed: () => _showPreview(_buildPreviewContent()),
              icon: const Icon(Icons.preview),
              tooltip: slang.t.common.previewContent,
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              tooltip: slang.t.common.close,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildInputFields() {
    return Column(
      children: [
        for (int i = 0; i < widget.inputConfigs.length; i++)
          _buildInputField(i),
      ],
    );
  }

  Widget _buildInputField(int index) {
    final config = widget.inputConfigs[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controllers[index],
        maxLines: config.maxLines,
        maxLength: config.maxLength,
        decoration: InputDecoration(
          labelText: config.label,
          hintText: config.hint,
          border: const OutlineInputBorder(),
          counterText: slang.t.common.characterCount(current: _currentLengths[index], max: config.maxLength),
          errorText: _currentLengths[index] > config.maxLength
              ? slang.t.common.exceedsMaxLengthLimit(max: config.maxLength)
              : null,
        ),
      ),
    );
  }

  String _buildPreviewContent() {
    // 子类可重写此方法实现自定义预览内容
    return controllers.map((c) => c.text).join('\n\n');
  }

  Widget buildActionButtons() {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.showRulesAgreement)
          Obx(() {
            final hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
            return TextButton.icon(
              onPressed: _showRulesDialog,
              icon: Icon(hasAgreed ? Icons.check_box : Icons.check_box_outline_blank),
              label: Text(slang.t.common.agreeToCommunityRules),
            );
          }),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(slang.t.common.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitDisabled ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(),
            const SizedBox(height: 16),
            buildInputFields(),
            const SizedBox(height: 16),
            buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // 抽象方法
  Future<void> onSubmit();
}

class TextInputFieldConfig {
  final String label;
  final String hint;
  final int maxLines;
  final int maxLength;

  const TextInputFieldConfig({
    required this.label,
    required this.hint,
    this.maxLines = 5,
    required this.maxLength,
  });
}

class PreviewPanel extends StatelessWidget {
  final String content;
  final ScrollController scrollController;

  const PreviewPanel({
    super.key,
    required this.content,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slang.t.common.preview,
                style: TextStyle(
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
              data: content,
              originalData: content,
              clickInternalLinkByUrlLaunch: true,
            ),
          ),
        ),
      ],
    );
  }
} 