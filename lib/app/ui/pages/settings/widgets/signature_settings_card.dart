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
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_recipe_gallery.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_variable_picker.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
import 'package:i_iwara/app/utils/signature_recipes.dart';
import 'package:i_iwara/app/utils/signature_scenes.dart';
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
///
/// ## ⭐ 预览自带场景切换
///
/// 设置页里没有上下文，所以 `{title}` 这类变量在这儿**永远算不出值**。原先的
/// 办法是让它们原样留着花括号，于是预览与输入框长得一模一样，整块形同虚设。
///
/// 现在它拿一份真实的示范上下文（用户自己最近看过的那条，见
/// `signature_scenes.dart`）渲染，并给出四个场景来回切：同一条小尾巴在视频页 /
/// 论坛 / 作者页 / 没有上下文下各是什么样。⛔ 那条「填不出就整段消失、所以一条
/// 模板到处通用」的规则，写十行字也说不明白，切两下就看懂了——「没有上下文」
/// 那一档演的就是消失。
class SignaturePreviewBlock extends StatefulWidget {
  const SignaturePreviewBlock({super.key, required this.signature});

  /// 用户写的那句话，可以带 `{变量}`。
  final String signature;

  @override
  State<SignaturePreviewBlock> createState() => _SignaturePreviewBlockState();
}

class _SignaturePreviewBlockState extends State<SignaturePreviewBlock> {
  SignatureSceneSet? _scenes;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // 查一次库（缓存在 signature_scenes.dart 里），回来之前先按空上下文画，
    // 不摆骨架屏：这块本来就只有一行字，闪一下比空一块好。
    loadSignatureScenes(slang.t).then((value) {
      if (mounted) setState(() => _scenes = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final service = Get.find<SignatureService>();
    final scenes = _scenes;
    final scene = scenes == null
        ? null
        : scenes.scenes[_index.clamp(0, scenes.scenes.length - 1)];

    // 数据源那几个变量不会为了画一次预览去打别人的接口：取过就用上次那句，
    // 没取过就用一句示范（[signatureDemoValues]）。真取一次的地方在数据源列表里。
    final resolved = service.estimate(
      widget.signature,
      context: scene?.context ?? SignatureContext.empty,
      fill: SignatureFill.sample,
      contextComplete: scene != null,
      pinned: signatureDemoValues(t, service),
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
        // 场景条是查完库才长出来的：出入场带动画，不硬切（项目约定）。
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: scenes == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⛔ 分段胶囊一律走 GlassAdaptiveSegmentedControl：摆不下
                      // 时它会自己退化成下拉钮，裸的 GlassSegmentedControl 只会
                      // 横着裁掉半截（闸门见 test/glass_style_guard_test.dart）。
                      GlassAdaptiveSegmentedControl(
                        items: [
                          for (final s in scenes.scenes)
                            GlassSegmentItem(
                              label: s.label,
                              icon: Icon(s.icon, size: 15),
                            ),
                        ],
                        selectedIndex: _index,
                        onChanged: (i) => setState(() => _index = i),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        scenes.fromHistory
                            ? t.settings.signatureSceneFromHistory
                            : t.settings.signatureSceneFromDemo,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
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

/// 输入框空着时摆出来的几条现成写法。
///
/// ⛔ 用户原话：「你准备的这些变量其实就算是我也不清楚要怎么用」。变量面板回答
/// 的是「有哪些零件」，而人卡住的地方是**「拼起来是什么样」**——所以这里给的是
/// 整句，点一下就落进输入框，再照着改。
///
/// ⛔ 而且给的是**渲染好的整句**（`正在看《月光下的旋转》`），不是一枚写着
/// 「正在看什么」的胶囊。上一版就是后者：点下去才知道长什么样，点下去看到的
/// 还是 `正在看《{title}》`——用户从头到尾没见过一次真实结果
/// （2026-09-21 用户第二次点名）。
///
/// 只在空着时在场：那时它是空状态的引导，而不是一排随时会把用户写的话冲掉的
/// 按钮。⭐ 想随时翻的话，底栏「更多」里那条「案例」是常驻入口。
/// 出入场都带动画（项目约定：不接受硬切 `SizedBox.shrink()`）。
class _RecipeStarters extends StatefulWidget {
  const _RecipeStarters({
    required this.visible,
    required this.onPick,
    required this.onMore,
  });

  final bool visible;
  final ValueChanged<String> onPick;
  final VoidCallback onMore;

  @override
  State<_RecipeStarters> createState() => _RecipeStartersState();
}

class _RecipeStartersState extends State<_RecipeStarters> {
  SignatureSceneSet? _scenes;

  @override
  void initState() {
    super.initState();
    loadSignatureScenes(slang.t).then((value) {
      if (mounted) setState(() => _scenes = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final starters = signatureStarterRecipes(
      t,
      aiAvailable: Get.find<SignatureService>().aiAvailable,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: widget.visible ? 1 : 0,
        child: !widget.visible
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settings.signatureRecipesHint,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final recipe in starters)
                      SignatureRecipeCard(
                        recipe: recipe,
                        scenes: _scenes,
                        // 窄版：省掉模板那一行和场景标签。这儿是给个起点，
                        // 教语法是画廊的事。
                        compact: true,
                        onTap: () => widget.onPick(recipe.template),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GlassButtonGroup(
                        children: [
                          GlassTextActionButton(
                            label: t.settings.signatureRecipesMore,
                            onPressed: widget.onMore,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
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

  /// 套用一条现成写法。
  ///
  /// ⛔ 空着时整条落进去，**写了东西就插在光标处**——案例画廊是常驻入口（底栏
  /// 「更多」里），而一个写了半天的人点开案例，绝不该被整句冲掉。案例本身是
  /// 成句的，插在中间也读得通。
  void _useRecipe(String template) {
    if (_controller.text.trim().isEmpty) {
      _controller.value = TextEditingValue(
        text: template,
        selection: TextSelection.collapsed(offset: template.length),
      );
      return;
    }
    _insertVariable(template);
  }

  Future<void> _pickRecipe() async {
    final template = await showSignatureRecipeGallery(context);
    if (template == null || !mounted) return;
    _useRecipe(template);
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
                  // ⛔ 这里**不设字数上限**。小尾巴多长该由用户自己拿捏：
                  // 发出去太长自然会被平台或下面那道收短逻辑修剪
                  // （`_composeForSubmit`），而一个 200 字的硬闸只会让人在
                  // 写第三行的时候发现自己写不下去，还说不出为什么不行。
                  GlassInputSurface(
                    child: EnhancedEmojiTextField(
                      key: _emojiKey,
                      controller: _controller,
                      maxLines: 3,
                      decoration: glassFieldDecoration(
                        context,
                        hint: t.settings.enterSignature,
                      ),
                    ),
                  ),
                  // 空着的时候给几条现成写法。见 [_RecipeStarters]。
                  _RecipeStarters(
                    visible: _controller.text.trim().isEmpty,
                    onPick: _useRecipe,
                    onMore: _pickRecipe,
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
              onSubmit: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
              onEmoji: _showEmojiPicker,
              onInsertVariable: _pickVariable,
              // 案例的常驻入口。空状态那几张卡片只在输入框空着时在场，而
              // 「我想看看还能怎么写」这件事不该只在一张白纸上才问得出来。
              onRecipes: _pickRecipe,
              onMarkdownHelp: () => showGlassDraggableBottomSheet(
                context: context,
                builder: (context) => const MarkdownSyntaxHelp(),
              ),
              // 没有上限就不摆字数标签（[GlassComposerBar] 的计数在 limit 为
              // null 时整只不在场）——一个没有分母的计数器只是噪音。
              length: _controller.text.length,
            ),
          ),
        ],
      ),
    );
  }
}
