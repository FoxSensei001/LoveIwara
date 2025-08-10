import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';

/// 基础输入组件，提供通用的输入功能
class BaseInputWidget extends StatefulWidget {
  final TextEditingController controller;
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
  final GlobalKey<EnhancedEmojiTextFieldState>? emojiTextFieldKey;
  final String? submitText;

  const BaseInputWidget({
    super.key,
    required this.controller,
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
    this.emojiTextFieldKey,
    this.submitText,
  });

  @override
  State<BaseInputWidget> createState() => _BaseInputWidgetState();
}

class _BaseInputWidgetState extends State<BaseInputWidget> {
  final ConfigService _configService = Get.find<ConfigService>();
  late EmojiSize _selectedEmojiSize;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    
    // 初始化表情包规格
    if (widget.showEmojiPicker) {
      final savedSizeSuffix = _configService[ConfigKey.DEFAULT_EMOJI_SIZE];
      _selectedEmojiSize = EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;
    }

    // 设置初始内容
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      widget.controller.text = widget.initialContent!;
    }

    // 添加小尾巴
    if (widget.initialContent == null || widget.initialContent!.isEmpty) {
      if (_configService[ConfigKey.ENABLE_SIGNATURE_KEY]) {
        widget.controller.text += _configService[ConfigKey.SIGNATURE_CONTENT_KEY];
      }
    }

    _currentLength = widget.controller.text.length;
    
    widget.controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentLength = widget.controller.text.length;
        });
      }
    });
  }

  void _showPreview() {
    MarkdownPreviewHelper.showPreview(context, widget.controller.text);
  }

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  void _showEmojiPickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerSheet(
        initialSize: _selectedEmojiSize,
        onEmojiSelected: (imageUrl, size) {
          _insertEmoji(imageUrl);
          Navigator.pop(context);
        },
        onSizeChanged: (size) {
          setState(() {
            _selectedEmojiSize = size;
          });
          // 保存用户选择到配置
          _configService[ConfigKey.DEFAULT_EMOJI_SIZE] = size.altSuffix;
        },
      ),
    );
  }

  void _insertEmoji(String imageUrl, [EmojiSize? size]) {
    if (widget.emojiTextFieldKey?.currentState != null) {
      // 使用EnhancedEmojiTextField的内部方法插入表情
      widget.emojiTextFieldKey!.currentState!.insertEmoji(imageUrl, size: size ?? _selectedEmojiSize);
    }
    
    // 更新字符计数
    setState(() {
      _currentLength = widget.controller.text.length;
    });
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

  void _handleSubmit() {
    if (_currentLength > widget.maxLength || _currentLength == 0) return;

    // 检查内容是否为空
    if (widget.controller.text.trim().isEmpty) {
      return;
    }

    // 如果需要规则协议但用户未同意
    if (widget.showRulesAgreement) {
      final bool hasAgreed = _configService[ConfigKey.RULES_AGREEMENT_KEY];
      if (!hasAgreed) {
        _showRulesDialog();
        return;
      }
    }

    widget.onSubmit?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 输入框
        if (widget.showEmojiPicker)
          EnhancedEmojiTextField(
            key: widget.emojiTextFieldKey,
            controller: widget.controller,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: widget.errorText ?? (_currentLength > widget.maxLength
                  ? t.errors.exceedsMaxLength(max: widget.maxLength.toString())
                  : null),
            ),
            onChanged: (value) {
              setState(() {
                _currentLength = value.length;
              });
            },
            enabled: widget.enabled && !widget.isLoading,
            focusNode: widget.focusNode,
            onEmojiInserted: (imageUrl) {
              setState(() {
                _currentLength = widget.controller.text.length;
              });
            },
          )
        else
          TextField(
            controller: widget.controller,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled && !widget.isLoading,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              counterText: '$_currentLength/${widget.maxLength}',
              errorText: widget.errorText ?? (_currentLength > widget.maxLength
                  ? t.errors.exceedsMaxLength(max: widget.maxLength.toString())
                  : null),
            ),
            onChanged: (value) {
              setState(() {
                _currentLength = value.length;
              });
            },
          ),
        
        const SizedBox(height: 16),
        
        // 操作按钮行
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          children: [
            if (widget.showTranslation)
              IconButton(
                onPressed: widget.controller.text.isNotEmpty
                    ? () {
                        Get.dialog(
                          TranslationDialog(
                            text: widget.controller.text,
                            defaultLanguageKeyMode: false,
                          ),
                          barrierDismissible: true,
                        );
                      }
                    : null,
                icon: Icon(
                  Icons.translate,
                  color: widget.controller.text.isEmpty
                      ? Theme.of(context).disabledColor
                      : null,
                ),
                tooltip: t.common.translate,
              ),
            if (widget.showEmojiPicker)
              IconButton(
                onPressed: _showEmojiPickerDialog,
                icon: const Icon(Icons.emoji_emotions_outlined),
                tooltip: t.emoji.selectEmoji,
              ),
            if (widget.showMarkdownHelp)
              IconButton(
                onPressed: _showMarkdownHelp,
                icon: const Icon(Icons.help_outline),
                tooltip: t.markdown.markdownSyntax,
              ),
            if (widget.showPreview)
              IconButton(
                onPressed: _showPreview,
                icon: const Icon(Icons.preview),
                tooltip: t.common.preview,
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 底部操作按钮
        Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.showRulesAgreement)
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
            if (widget.onCancel != null)
              TextButton(
                onPressed: widget.onCancel,
                child: Text(t.common.cancel),
              ),
            if (widget.onSubmit != null)
              ElevatedButton(
                onPressed: (_currentLength > widget.maxLength || _currentLength == 0)
                    ? null
                    : _handleSubmit,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.submitText ?? t.common.send),
              ),
          ],
        ),
      ],
    );
  }
}
