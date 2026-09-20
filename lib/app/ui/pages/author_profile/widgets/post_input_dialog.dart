import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/rules_agreement_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/app/ui/widgets/markdown_preview_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
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

  /// 本次发帖要不要带小尾巴。初值取设置，可在工具行当场改；改的是这一次，
  /// 不写回设置——「这篇不想带」和「以后都不带」是两件事。
  late bool _signatureEnabled;

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

    // 小尾巴**不再**拼进正文。旧版把它当初始文本塞给用户编辑，于是那条
    // `---` 分隔线成了可以被改坏的正文；现在它只是一个状态，提交那一刻才由
    // [CommentMarkup.compose] 接到末尾。详见 [CommentMarkup] 的类文档。
    _signatureEnabled = _configService[ConfigKey.ENABLE_SIGNATURE_KEY];

    _bodyController = TextEditingController();

    _titleController.addListener(() {
      setState(() {
        _currentTitleLength = _titleController.text.length;
      });
    });

    _bodyController.addListener(() {
      setState(() {
        _currentBodyLength = _composedBody().length;
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

  /// 真正会被发出去的正文（含小尾巴）。字数统计 / 预览 / 提交三处都读它——
  /// 服务端卡的是最终文本，只数输入框里的字会让人在提交那一刻才发现超了。
  String _composedBody() => CommentMarkup.compose(
    body: _bodyController.text,
    signature: _signatureEnabled
        ? _configService[ConfigKey.SIGNATURE_CONTENT_KEY]
        : null,
  );

  /// 用户确实配过小尾巴才露出那枚开关；没配过的人不该看见一个自己从来
  /// 没用过的开关。
  bool get _showSignatureToggle {
    final String content = _configService[ConfigKey.SIGNATURE_CONTENT_KEY];
    return content.trim().isNotEmpty;
  }

  /// 预览给的是**发出去的样子**——小尾巴在内。
  void _showPreview() {
    MarkdownPreviewHelper.showPreviewWithTitle(
      context,
      _composedBody(),
      _titleController.text,
    );
  }

  void _showMarkdownHelp() {
    showGlassDraggableBottomSheet(
      context: context,
      builder: (context) => const MarkdownSyntaxHelp(),
    );
  }

  Future<void> _showRulesDialog() async {
    final result = await showGlassDraggableBottomSheet<bool>(
      context: context,
      builder: (context) => GlassDraggableBottomSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
    if (_currentBodyLength > maxBodyLength) return;
    if (_bodyController.text.trim().isEmpty) return;

    // 检查标题是否为空
    if (_titleController.text.trim().isEmpty) {
      showAppToast(t.errors.titleCanNotBeEmpty, type: AppToastType.error);
      return;
    }

    // 检查内容是否为空
    if (_bodyController.text.trim().isEmpty) {
      showAppToast(t.errors.contentCanNotBeEmpty, type: AppToastType.error);
      return;
    }

    // 未同意规则时提交键本就是禁用态，这里只兜底拦一道
    if (!_configService[ConfigKey.RULES_AGREEMENT_KEY]) return;

    setState(() {
      _isLoading = true;
    });
    await widget.onSubmit(_titleController.text, _composedBody());
    setState(() {
      _isLoading = false;
    });
  }

  void _showEmojiPicker() {
    // 走 showGlassBottomSheet 而不是裸 showModalBottomSheet：液态档供在那条
    // 路由上，裸开的弹层里所有玻璃件都会静默落回传统档。
    showGlassBottomSheet(
      context: context,
      builder: (context) => EmojiPickerSheet(
        initialSize: _selectedEmojiSize,
        // ⛔ 这里**不 pop**：连选是刻意的（斗图要连发几张）。弹层由用户
        // 自己关，底部会实时显示这次插了几个。
        onEmojiSelected: (imageUrl, size) =>
            _emojiTextFieldKey.currentState?.insertEmoji(imageUrl, size: size),
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
              // 齿轮：用户正对着小尾巴开关，想改内容就该一步到位，而不是
              // 关掉弹窗自己去设置树里翻。放关闭键左边（trailing 槽），
              // 关闭永远在最右端不挪窝。
              trailing: GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.tune),
                tooltip: slang.t.settings.chatSettings.name,
                onPressed: NaviService.navigateToChatSettingsPage,
              ),
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
                    _currentBodyLength = _composedBody().length;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            // 单行底栏：动作 · 状态 · 字数 · 发送（见 GlassComposerBar）
            Obx(() {
              final bool hasAgreed =
                  _configService[ConfigKey.RULES_AGREEMENT_KEY];
              final bool contentReady =
                  _currentTitleLength > 0 &&
                  _currentTitleLength <= maxTitleLength &&
                  _bodyController.text.trim().isNotEmpty &&
                  _currentBodyLength <= maxBodyLength;
              return GlassComposerBar(
                onSubmit: contentReady && hasAgreed ? _handleSubmit : null,
                // 只差「同意规则」时按钮仍可点，点下去弹规则全文
                onBlockedTap: !hasAgreed ? _showRulesDialog : null,
                submitText: t.common.send,
                isLoading: _isLoading,
                onEmoji: _showEmojiPicker,
                onPreview: _showPreview,
                previewHasContent: _bodyController.text.trim().isNotEmpty,
                onTranslate: () => showTranslationDialog(
                  context,
                  text: _bodyController.text,
                  defaultLanguageKeyMode: false,
                ),
                translateEnabled: _bodyController.text.isNotEmpty,
                onMarkdownHelp: _showMarkdownHelp,
                rulesAgreed: hasAgreed,
                onRulesTap: _showRulesDialog,
                showSignatureToggle: _showSignatureToggle,
                signatureEnabled: _signatureEnabled,
                onSignatureToggle: () => setState(() {
                  _signatureEnabled = !_signatureEnabled;
                  _currentBodyLength = _composedBody().length;
                }),
                // 数的是**最终文本**，与 errorText / 提交闸门同一把尺；
                // 拿输入框里的原始长度去比 maxBodyLength 会出现「计数没超、
                // 发送却是灰的」。
                length: _currentBodyLength,
                limit: maxBodyLength,
              );
            }),
          ],
        ),
      ),
    );
  }
}
