import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 小尾巴的**所见即所得**预览块：把设置里那句话按真正发出去的样子渲染出来。
///
/// 旧版设置页只把小尾巴内容当一行纯文本塞在 `ListTile` 的 subtitle 里，用户
/// 看不到那条 `---` 会变成什么——而它恰恰是整件事出问题的地方（详见
/// [CommentMarkup] 的类文档：分隔线的语法在旧实现里根本没生效过）。
///
/// 这里直接走和评论区同一个 [CustomMarkdownBody] 渲染 [CommentMarkup.compose]
/// 的结果：设置页里看到的，就是别人在评论区看到的。
class SignaturePreviewBlock extends StatelessWidget {
  const SignaturePreviewBlock({super.key, required this.signature});

  final String signature;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.settings.signaturePreview,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: CustomMarkdownBody(
            // 用一句示例正文占位，好让分隔线有「上文」可分——只给签名一行的话
            // 看不出它和正文之间是怎么隔开的。
            data: CommentMarkup.compose(
              body: t.settings.signatureSampleBody,
              signature: signature,
            ),
            padding: EdgeInsets.zero,
            selectable: false,
          ),
        ),
      ],
    );
  }
}

/// 打开小尾巴编辑器，返回用户确认后的新内容（取消返回 null）。
Future<String?> showSignatureEditor(
  BuildContext context, {
  required String initialContent,
}) {
  return showGlassBottomSheet<String>(
    context: context,
    builder: (context) => SignatureEditSheet(initialContent: initialContent),
  );
}

/// 设置页里「小尾巴」那张卡的可复用内容区：开关 + 预览 + 编辑入口。
///
/// 设置页与首次引导页共用同一份（这两处过去各写了一遍，开关文案和编辑入口
/// 的行为都对不上）。外壳（Card / StepPageLayout）仍由各自页面提供。
class SignatureSettingsBody extends StatelessWidget {
  const SignatureSettingsBody({
    super.key,
    required this.enabled,
    required this.content,
    required this.onContentChanged,
    this.switchBuilder,
  });

  final bool enabled;
  final String content;
  final ValueChanged<String> onContentChanged;

  /// 开关那一行由调用页提供（设置页用 `GlassSwitchItem`、引导页用它自己的
  /// 设置行），这里只负责开关**以下**的部分。
  final Widget Function(BuildContext context)? switchBuilder;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (switchBuilder != null) switchBuilder!(context),
        // 开关关掉时整块收起来，但要有过渡——项目约定：出现与消失都必须
        // 有动画，不接受硬切 SizedBox.shrink()。
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: enabled ? 1 : 0,
            child: !enabled
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t.settings.signatureRuleHint,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SignaturePreviewBlock(signature: content),
                        const SizedBox(height: 12),
                        // 玻璃胶囊而不是裸 FilledButton：材质档由主题设置统一
                        // 供给，裸 Material 按钮会绕过那个开关（见
                        // test/glass_style_guard_test.dart 的棘轮闸门）。
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GlassButtonGroup(
                              children: [
                                GlassTextActionButton(
                                  label: t.settings.editSignature,
                                  emphasized: true,
                                  onPressed: () async {
                                    final result = await showSignatureEditor(
                                      context,
                                      initialContent: content,
                                    );
                                    if (result != null) {
                                      onContentChanged(result);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// 小尾巴编辑器。
///
/// **不复用发评论那只 composer**。旧版直接套 `BaseBottomSheetInput`，于是编辑
/// 自己的签名时界面上挂着一枚「翻译」按钮（对着自己写的一行字翻译毫无意义），
/// 预览还要再开一层弹层才能看见。这里只留真正相关的三件事：输入、表情、
/// 以及**边打边看**的效果预览。
///
/// 另外它显式不参与小尾巴自身（不会出现「编辑签名时又给你自动加一条签名」）。
class SignatureEditSheet extends StatefulWidget {
  const SignatureEditSheet({super.key, required this.initialContent});

  final String initialContent;

  @override
  State<SignatureEditSheet> createState() => _SignatureEditSheetState();
}

class _SignatureEditSheetState extends State<SignatureEditSheet> {
  static const int _maxLength = 200;

  late final TextEditingController _controller;
  final GlobalKey<EnhancedEmojiTextFieldState> _emojiKey =
      GlobalKey<EnhancedEmojiTextFieldState>();
  late EmojiSize _emojiSize;

  @override
  void initState() {
    super.initState();
    // 老配置里的小尾巴自带前导 `\n\n---`，分隔线现在由 CommentMarkup 统一补，
    // 进编辑框前先剥掉，免得用户看见一条自己没写过、改了还会出两条的横线。
    _controller = TextEditingController(
      text: CommentMarkup.compose(body: '', signature: widget.initialContent)
          .replaceFirst(RegExp(r'^-{3,}\s*\n*'), '')
          .trim(),
    );
    _controller.addListener(() => setState(() {}));

    final config = Get.find<ConfigService>();
    _emojiSize =
        EmojiSize.fromAltSuffix(config[ConfigKey.DEFAULT_EMOJI_SIZE]) ??
        EmojiSize.medium;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    final config = Get.find<ConfigService>();
    showGlassBottomSheet(
      context: context,
      builder: (context) => EmojiPickerSheet(
        initialSize: _emojiSize,
        // ⛔ 这里**不 pop**：连选是刻意的（斗图要连发几张）。弹层由用户
        // 自己关，底部会实时显示这次插了几个。
        onEmojiSelected: (imageUrl, size) =>
            _emojiKey.currentState?.insertEmoji(imageUrl, size: size),
        onSizeChanged: (size) {
          setState(() => _emojiSize = size);
          config[ConfigKey.DEFAULT_EMOJI_SIZE] = size.altSuffix;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final int length = _controller.text.length;
    final bool tooLong = length > _maxLength;

    return GlassBottomSheet(
      showCloseButton: false,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GlassComposerHeader(
              title: t.settings.editSignature,
              icon: Icons.edit_note,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassInputSurface(
                  error: tooLong,
                  child: EnhancedEmojiTextField(
                    key: _emojiKey,
                    controller: _controller,
                    maxLines: 3,
                    maxLength: _maxLength,
                    decoration: glassFieldDecoration(
                      context,
                      hint: t.settings.enterSignature,
                      errorText: tooLong
                          ? t.errors.exceedsMaxLength(
                              max: _maxLength.toString(),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // 边打边看：分隔线怎么来的、签名跟正文怎么隔开，都在这儿。
                SignaturePreviewBlock(signature: _controller.text),
                const SizedBox(height: 12),
                // 与发评论那族共用同一条底栏。本编辑器不提供预览（上面那块
                // 就是边打边看的实时预览），也不参与小尾巴自身。
                GlassComposerBar(
                  submitText: t.common.confirm,
                  onSubmit: tooLong
                      ? null
                      : () => Navigator.of(context).pop(_controller.text.trim()),
                  onEmoji: _showEmojiPicker,
                  onMarkdownHelp: () => showGlassDraggableBottomSheet(
                    context: context,
                    builder: (context) => const MarkdownSyntaxHelp(),
                  ),
                  length: _controller.text.length,
                  limit: _maxLength,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
