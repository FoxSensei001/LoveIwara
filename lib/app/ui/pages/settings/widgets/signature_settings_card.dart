import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/comment_structure_widgets.dart';
import 'package:i_iwara/app/ui/widgets/enhanced_emoji_text_field.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/markdown_syntax_help_dialog.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_variable_picker.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 小尾巴的**所见即所得**预览块：把设置里那句话按真正发出去的样子渲染出来。
///
/// 旧版设置页只把小尾巴内容当一行纯文本塞在 `ListTile` 的 subtitle 里，用户
/// 看不到那条 `---` 会变成什么——而它恰恰是整件事出问题的地方（详见
/// [CommentMarkup] 的类文档：分隔线的语法在旧实现里根本没生效过）。
///
/// ⛔ 这里走 [CommentStructurePreview]，**不是** `CustomMarkdownBody` 渲染
/// [CommentMarkup.compose] 的结果。后者画出来的小尾巴是一条全宽 `<hr>` 加一行
/// 与正文同样大同样黑的字，而评论列表里它是 11px、alpha 0.6、前缀一小截横线
/// 的脚注——设置页里看到的必须就是别人在评论区看到的，那是这块预览唯一的
/// 职责（2026-09-21 用户报障：两边样式不一样）。
class SignaturePreviewBlock extends StatelessWidget {
  const SignaturePreviewBlock({super.key, required this.signature});

  /// 用户写的那句话，可以带 `{变量}`。
  final String signature;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    // 数据源那几个变量在预览里保持原样（`{hitokoto}`），不会为了画一次预览
    // 就去打别人的接口。真取一次的地方在设置页的数据源列表里。
    final resolved = Get.find<SignatureService>().estimate(
      signature,
      fill: SignatureFill.sample,
    );

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
          child: CommentStructurePreview(
            // 用一句示例正文占位，好让脚注有「上文」可分——只给签名一行的话
            // 看不出它和正文之间是怎么隔开的。
            body: t.settings.signatureSampleBody,
            signature: resolved,
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
      text: CommentMarkup.compose(
        body: '',
        signature: widget.initialContent,
      ).replaceFirst(RegExp(r'^-{3,}\s*\n*'), '').trim(),
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

  /// 把一个变量插到光标处（有选区就替换掉选区）。
  ///
  /// ⛔ 不能只往末尾追加：用户想写「今天 {date} 在看…」时，变量该落在他停住
  /// 的地方。`controller.text` 的 setter 会把 selection 置无效，所以整条
  /// [TextEditingValue] 一起写，顺手把光标钉到插入内容之后。
  Future<void> _pickVariable() async {
    final token = await showSignatureVariablePicker(context);
    if (token == null || !mounted) return;
    _insertVariable(token);
  }

  void _insertVariable(String token) {
    final value = _controller.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;

    final next = value.text.replaceRange(start, end, token);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
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
          // ⛔ 中间这段必须能滚。弹层外壳把键盘高度让在内容**里面**
          // （`computeSheetBottomInset`），键盘一弹可用高度就少掉两三百，
          // 而输入框 3 行 + 预览（随小尾巴内容长高，带变量时更高）+ 底栏
          // 是定死的——真机报过 `RenderFlex overflowed by 193 pixels`。
          //
          // 让出的是**正文**，不是底栏：底栏上挂着确定 / 变量 / 表情，被挤出
          // 屏幕就等于点不着。
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  // 边打边看：分隔线怎么来的、签名跟正文怎么隔开、变量会变成
                  // 什么，都在这儿。
                  SignaturePreviewBlock(signature: _controller.text),
                ],
              ),
            ),
          ),
          // 与发评论那族共用同一条底栏。本编辑器不提供预览（上面那块就是
          // 边打边看的实时预览），也不参与小尾巴自身。
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: GlassComposerBar(
              submitText: t.common.confirm,
              onSubmit: tooLong
                  ? null
                  : () => Navigator.of(context).pop(_controller.text.trim()),
              onEmoji: _showEmojiPicker,
              onInsertVariable: _pickVariable,
              onMarkdownHelp: () => showGlassDraggableBottomSheet(
                context: context,
                builder: (context) => const MarkdownSyntaxHelp(),
              ),
              length: _controller.text.length,
              limit: _maxLength,
            ),
          ),
        ],
      ),
    );
  }
}
