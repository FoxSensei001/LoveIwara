import 'package:flutter/material.dart';
import 'package:i_iwara/common/widgets/input/base_input_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 基础对话框输入组件
class BaseDialogInput extends StatefulWidget {
  final String title;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final bool showEmojiPicker;
  final bool showTranslation;
  final bool showMarkdownHelp;
  final bool showPreview;
  final bool showRulesAgreement;
  final Function(String)? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String? errorText;
  final String? initialContent;
  final bool enabled;
  final FocusNode? focusNode;
  final String? submitText;
  final String? cancelText;

  const BaseDialogInput({
    super.key,
    required this.title,
    required this.hintText,
    this.maxLength = 1000,
    this.maxLines = 5,
    this.showEmojiPicker = false,
    this.showTranslation = true,
    this.showMarkdownHelp = true,
    this.showPreview = true,
    this.showRulesAgreement = false,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.errorText,
    this.initialContent,
    this.enabled = true,
    this.focusNode,
    this.submitText,
    this.cancelText,
  });

  @override
  State<BaseDialogInput> createState() => _BaseDialogInputState();
}

class _BaseDialogInputState extends State<BaseDialogInput> {
  late TextEditingController _controller;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey = GlobalKey<EnhancedEmojiTextFieldState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String text) {
    widget.onSubmit?.call(text);
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop();
    }
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
            // 标题栏
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
                  onPressed: _handleCancel,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 输入区域
            BaseInputWidget(
              controller: _controller,
              title: widget.title,
              hintText: widget.hintText,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              showEmojiPicker: widget.showEmojiPicker,
              showTranslation: widget.showTranslation,
              showMarkdownHelp: widget.showMarkdownHelp,
              showPreview: widget.showPreview,
              showRulesAgreement: widget.showRulesAgreement,
              onSubmit: _handleSubmit,
              onCancel: _handleCancel,
              isLoading: widget.isLoading,
              errorText: widget.errorText,
              initialContent: widget.initialContent,
              enabled: widget.enabled,
              focusNode: widget.focusNode,
              emojiTextFieldKey: widget.showEmojiPicker ? _emojiTextFieldKey : null,
              submitText: widget.submitText,
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示对话框输入框的便捷方法
class DialogInputHelper {
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    required String hintText,
    int maxLength = 1000,
    int maxLines = 5,
    bool showEmojiPicker = false,
    bool showTranslation = true,
    bool showMarkdownHelp = true,
    bool showPreview = true,
    bool showRulesAgreement = false,
    String? initialContent,
    String? submitText,
    String? cancelText,
  }) async {
    String? result;
    
    await showDialog<String>(
      context: context,
      builder: (context) => BaseDialogInput(
        title: title,
        hintText: hintText,
        maxLength: maxLength,
        maxLines: maxLines,
        showEmojiPicker: showEmojiPicker,
        showTranslation: showTranslation,
        showMarkdownHelp: showMarkdownHelp,
        showPreview: showPreview,
        showRulesAgreement: showRulesAgreement,
        initialContent: initialContent,
        submitText: submitText,
        cancelText: cancelText,
        onSubmit: (text) {
          result = text;
          Navigator.of(context).pop();
        },
      ),
    );
    
    return result;
  }
}
