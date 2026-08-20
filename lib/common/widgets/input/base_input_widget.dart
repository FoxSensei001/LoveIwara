import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

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
      _selectedEmojiSize =
          EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;
    }

    // 设置初始内容
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      widget.controller.text = widget.initialContent!;
    }

    // 添加小尾巴
    if (widget.initialContent == null || widget.initialContent!.isEmpty) {
      if (_configService[ConfigKey.ENABLE_SIGNATURE_KEY]) {
        widget.controller.text +=
            _configService[ConfigKey.SIGNATURE_CONTENT_KEY];
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
      widget.emojiTextFieldKey!.currentState!.insertEmoji(
        imageUrl,
        size: size ?? _selectedEmojiSize,
      );
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
        builder: (context, scrollController) =>
            RulesAgreementDialog(scrollController: scrollController),
      ),
    );

    if (result == true) {
      // 只记录「已同意」，不代发内容——同意规则和发出内容是两件事，
      // 用户点完同意后仍需自己按提交键。
      await _configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, true);
    }
  }

  void _handleSubmit() {
    if (_currentLength > widget.maxLength || _currentLength == 0) return;

    // 检查内容是否为空
    if (widget.controller.text.trim().isEmpty) {
      return;
    }

    // 未同意规则时提交键本就是禁用态（见 build 里的 canSubmit），
    // 这里只兜底拦一道，不再顺手弹规则弹窗+代发。
    if (widget.showRulesAgreement &&
        !_configService[ConfigKey.RULES_AGREEMENT_KEY]) {
      return;
    }

    widget.onSubmit?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final String? errorText =
        widget.errorText ??
        (_currentLength > widget.maxLength
            ? t.errors.exceedsMaxLength(max: widget.maxLength.toString())
            : null);
    final bool canSubmit =
        _currentLength > 0 && _currentLength <= widget.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 输入域：玻璃壳包住无边框输入控件
        GlassInputSurface(
          child: widget.showEmojiPicker
              ? EnhancedEmojiTextField(
                  key: widget.emojiTextFieldKey,
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  decoration: glassFieldDecoration(
                    context,
                    hint: widget.hintText,
                    errorText: errorText,
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
              : TextField(
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  enabled: widget.enabled && !widget.isLoading,
                  focusNode: widget.focusNode,
                  decoration: glassFieldDecoration(
                    context,
                    hint: widget.hintText,
                    errorText: errorText,
                    counterText: '$_currentLength/${widget.maxLength}',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentLength = value.length;
                    });
                  },
                ),
        ),

        const SizedBox(height: 16),

        // 工具行：翻译 / 表情 / MD 帮助 / 预览，聚成一只玻璃胶囊
        GlassComposerToolbar(
          onTranslate: widget.showTranslation
              ? () {
                  showAppDialog(
                    TranslationDialog(
                      text: widget.controller.text,
                      defaultLanguageKeyMode: false,
                    ),
                    barrierDismissible: true,
                  );
                }
              : null,
          translateEnabled: widget.controller.text.isNotEmpty,
          onEmoji: widget.showEmojiPicker ? _showEmojiPickerDialog : null,
          onMarkdownHelp: widget.showMarkdownHelp ? _showMarkdownHelp : null,
          onPreview: widget.showPreview ? _showPreview : null,
        ),

        const SizedBox(height: 16),

        // 动作行：左侧规则徽标 · 右侧提交（未同意规则时提交键为禁用态，
        // 用户先点徽标读规则并同意，再自己按提交）
        if (widget.showRulesAgreement)
          Obx(() {
            final bool hasAgreed =
                _configService[ConfigKey.RULES_AGREEMENT_KEY];
            return GlassComposerActions(
              rulesAgreed: hasAgreed,
              onRulesTap: () => _showRulesDialog(),
              onSubmit: widget.onSubmit == null || !canSubmit || !hasAgreed
                  ? null
                  : _handleSubmit,
              // 只差「同意规则」时：按钮仍可点，点下去弹规则全文
              onBlockedTap: !hasAgreed && canSubmit
                  ? () => _showRulesDialog()
                  : null,
              submitText: widget.submitText,
              isLoading: widget.isLoading,
            );
          })
        else
          GlassComposerActions(
            onSubmit: widget.onSubmit == null || !canSubmit
                ? null
                : _handleSubmit,
            submitText: widget.submitText,
            isLoading: widget.isLoading,
          ),
      ],
    );
  }
}
