import 'package:flutter/material.dart';
import 'package:i_iwara/common/widgets/input/base_input_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';

/// 基础底部弹窗输入组件
class BaseBottomSheetInput extends StatefulWidget {
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
  final bool isLoading;
  final String? errorText;
  final String? initialContent;
  final bool enabled;
  final FocusNode? focusNode;
  final IconData? titleIcon;
  final String? submitText;

  const BaseBottomSheetInput({
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
    this.isLoading = false,
    this.errorText,
    this.initialContent,
    this.enabled = true,
    this.focusNode,
    this.titleIcon,
    this.submitText,
  });

  @override
  State<BaseBottomSheetInput> createState() => _BaseBottomSheetInputState();
}

class _BaseBottomSheetInputState extends State<BaseBottomSheetInput> {
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
    Navigator.of(context).pop();
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                if (widget.titleIcon != null) ...[
                  Icon(
                    widget.titleIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                ],
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
                  onPressed: _handleCancel,
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // 内容区域
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BaseInputWidget(
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
          ),
        ],
      ),
    );
  }
}

/// 显示底部弹窗输入框的便捷方法
class BottomSheetInputHelper {
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
    IconData? titleIcon,
    String? submitText,
  }) async {
    String? result;
    
    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BaseBottomSheetInput(
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
        titleIcon: titleIcon,
        submitText: submitText,
        onSubmit: (text) {
          result = text;
          Navigator.of(context).pop();
        },
      ),
    );
    
    return result;
  }
}
