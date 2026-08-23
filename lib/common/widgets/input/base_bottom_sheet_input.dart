import 'package:flutter/material.dart';
import 'package:i_iwara/common/widgets/input/base_input_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';

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
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey =
      GlobalKey<EnhancedEmojiTextFieldState>();

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
    // 外壳（背景 + 圆角 + 拖拽把手 + 安全区）统一走 GlassBottomSheet；
    // 标题行仍自己用 GlassComposerHeader（带 titleIcon），所以关掉它的内建
    // 标题参数（showCloseButton 无 title 时本就不生效，显式传 false 表意）。
    // padding: EdgeInsets.zero —— 保留原来两段各自的内边距，改动最小、观感不变。
    return GlassBottomSheet(
      showCloseButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部标题栏：标题 + 玻璃关闭圆钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: GlassComposerHeader(
              title: widget.title,
              icon: widget.titleIcon,
              onClose: _handleCancel,
            ),
          ),
          // 内容区域
          // 外壳 GlassBottomSheet 已统一负责让出键盘与系统安全区（导航条/手势条），
          // 这里不再叠加 computeSheetBottomInset，避免底部间距被重复撑开。
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
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
              isLoading: widget.isLoading,
              errorText: widget.errorText,
              initialContent: widget.initialContent,
              enabled: widget.enabled,
              focusNode: widget.focusNode,
              emojiTextFieldKey: widget.showEmojiPicker
                  ? _emojiTextFieldKey
                  : null,
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

    await showGlassBottomSheet<String>(
      context: context,
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
