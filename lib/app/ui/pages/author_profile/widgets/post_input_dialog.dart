import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';

class PostInputDialog extends StatefulWidget {
  final Function(String title, String body) onSubmit;

  const PostInputDialog({super.key, required this.onSubmit});

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
  late EmojiSize _selectedEmojiSize;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiTextFieldKey =
      GlobalKey<EnhancedEmojiTextFieldState>();

  // 标题最大长度
  static const int maxTitleLength = 100;
  // 内容最大长度
  static const int maxBodyLength = 50000;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    final configService = Get.find<ConfigService>();
    String initialBody = '';

    // 如果启用了小尾巴，则在正文中添加小尾巴
    if (configService[ConfigKey.ENABLE_SIGNATURE_KEY]) {
      initialBody += configService[ConfigKey.SIGNATURE_CONTENT_KEY];
    }

    _bodyController = TextEditingController(text: initialBody);

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

    // 初始化表情尺寸
    final savedSizeSuffix = _configService[ConfigKey.DEFAULT_EMOJI_SIZE];
    _selectedEmojiSize =
        EmojiSize.fromAltSuffix(savedSizeSuffix) ?? EmojiSize.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _showPreview() {
    MarkdownPreviewHelper.showPreviewWithTitle(
      context,
      _bodyController.text,
      _titleController.text,
    );
  }

  void _showMarkdownHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
        builder: (context, scrollController) =>
            RulesAgreementDialog(scrollController: scrollController),
      ),
    );

    if (result == true) {
      // 只记录「已同意」，不代发内容——用户仍需自己按提交键
      await _configService.setSetting(ConfigKey.RULES_AGREEMENT_KEY, true);
    }
  }

  void _handleSubmit() async {
    final t = slang.t;
    if (_currentTitleLength > maxTitleLength || _currentTitleLength == 0) {
      return;
    }
    if (_currentBodyLength > maxBodyLength || _currentBodyLength == 0) return;

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showGlassToast(t.errors.titleCanNotBeEmpty, type: GlassToastType.error);
      return;
    }

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showGlassToast(t.errors.contentCanNotBeEmpty, type: GlassToastType.error);
      return;
    }

    // 未同意规则时提交键本就是禁用态，这里只兜底拦一道
    if (!_configService[ConfigKey.RULES_AGREEMENT_KEY]) return;

    setState(() {
      _isLoading = true;
    });
    await widget.onSubmit(_titleController.text, _bodyController.text);
    setState(() {
      _isLoading = false;
    });
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiPickerSheet(
        initialSize: _selectedEmojiSize,
        onEmojiSelected: (imageUrl, size) {
          _emojiTextFieldKey.currentState?.insertEmoji(imageUrl, size: size);
          Navigator.pop(context);
        },
        onSizeChanged: (size) {
          setState(() {
            _selectedEmojiSize = size;
          });
          _configService[ConfigKey.DEFAULT_EMOJI_SIZE] = size.altSuffix;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassComposerHeader(
              title: t.common.createPost,
              icon: Icons.post_add,
              onClose: () => AppService.tryPop(),
            ),
            const SizedBox(height: 16),
            GlassInputSurface(
              child: TextField(
                controller: _titleController,
                maxLines: 1,
                maxLength: maxTitleLength,
                decoration: glassFieldDecoration(
                  context,
                  label: t.common.title,
                  hint: t.common.enterTitle,
                  counterText: '$_currentTitleLength/$maxTitleLength',
                  errorText: _currentTitleLength > maxTitleLength
                      ? t.errors.exceedsMaxLength(
                          max: maxTitleLength.toString(),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassInputSurface(
              child: EnhancedEmojiTextField(
                key: _emojiTextFieldKey,
                controller: _bodyController,
                maxLines: 5,
                maxLength: maxBodyLength,
                decoration: glassFieldDecoration(
                  context,
                  hint: t.common.writeYourContentHere,
                  errorText: _currentBodyLength > maxBodyLength
                      ? t.errors.exceedsMaxLength(max: maxBodyLength.toString())
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _currentBodyLength = value.length;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // 工具行：翻译 · 表情 · MD 帮助 · 预览
            GlassComposerToolbar(
              onTranslate: () {
                showTranslationDialog(
                  context,
                  text: _bodyController.text,
                  defaultLanguageKeyMode: false,
                );
              },
              translateEnabled: _bodyController.text.isNotEmpty,
              onEmoji: _showEmojiPicker,
              onMarkdownHelp: _showMarkdownHelp,
              onPreview: _showPreview,
            ),
            const SizedBox(height: 16),
            Obx(() {
              final bool hasAgreed =
                  _configService[ConfigKey.RULES_AGREEMENT_KEY];
              final bool contentReady =
                  _currentTitleLength > 0 &&
                  _currentTitleLength <= maxTitleLength &&
                  _currentBodyLength > 0 &&
                  _currentBodyLength <= maxBodyLength;
              return GlassComposerActions(
                rulesAgreed: hasAgreed,
                onRulesTap: () => _showRulesDialog(),
                onSubmit: contentReady && hasAgreed ? _handleSubmit : null,
                // 只差「同意规则」时：按钮仍可点，点下去弹规则全文
                onBlockedTap: !hasAgreed ? () => _showRulesDialog() : null,
                isLoading: _isLoading,
              );
            }),
          ],
        ),
      ),
    );
  }
}
