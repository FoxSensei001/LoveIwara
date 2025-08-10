import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/widgets/input/input_components.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class SignatureEditDialog extends StatefulWidget {
  final String initialContent;

  const SignatureEditDialog({super.key, required this.initialContent});

  @override
  State<SignatureEditDialog> createState() => _SignatureEditDialogState();
}

class _SignatureEditDialogState extends State<SignatureEditDialog> {
  void _handleSubmit(String text) {
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    return BaseDialogInput(
      title: t.settings.editSignature,
      hintText: t.settings.enterSignature,
      maxLength: 1000,
      maxLines: 5,
      showEmojiPicker: true,  // 启用表情包功能
      showTranslation: true,
      showMarkdownHelp: true,
      showPreview: true,
      showRulesAgreement: false,
      onSubmit: _handleSubmit,
      initialContent: widget.initialContent,
      submitText: t.common.confirm,
      cancelText: t.common.cancel,
    );
  }
}