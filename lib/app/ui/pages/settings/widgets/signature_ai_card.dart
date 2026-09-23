import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/signature_ai_settings.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_variable_picker.dart';
import 'package:i_iwara/app/ui/widgets/ai/ai_ui_parts.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/signature_ai_recipes.dart';
import 'package:i_iwara/app/utils/signature_scenes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置页里的「AI 一言」整块。
///
/// ⛔ **它不在「数据源」那张列表里**（2026-09-21 用户点名）。数据源的含义是
/// 「一个会返回一句话的地址」——地址、取值路径、加工规则，整套向导都是围着
/// 这件事转的。AI 一言一样都不占。
///
/// 它仍然是模板里的一个变量（`{ai_hitokoto}`），求值管线也仍与数据源共用
/// ——分开的只是**设置页的呈现**，不是底层概念。
///
/// 外壳（Card / 标题行）由设置页提供，与 `SignatureProvidersBody` 同一个约定。
class SignatureAiBody extends StatefulWidget {
  const SignatureAiBody({super.key});

  @override
  State<SignatureAiBody> createState() => _SignatureAiBodyState();
}

class _SignatureAiBodyState extends State<SignatureAiBody> {
  final SignatureService _service = Get.find<SignatureService>();

  /// 刚测出来的那句话 / 刚碰到的错。与数据源列表同一个读法。
  String? _tested;
  String? _failed;

  Future<void> _test() async {
    // ⭐ 带上示范上下文。空上下文跑出来的是一句放之四海皆准的格言，而 AI 一言
    // 与接口一言唯一的分野就是它**知道用户在看什么**。
    final scenes = await loadSignatureScenes(slang.t);
    final value = await _service.fetchAiWith(
      _service.aiSettings,
      context: scenes.byId(SignatureScene.videoId).context,
    );
    if (!mounted) return;
    setState(() {
      if (value == null || value.trim().isEmpty) {
        _failed = slang.t.settings.signatureSourceTestFailed;
      } else {
        _failed = null;
        _tested = value.trim();
      }
    });
  }

  Future<void> _edit() async {
    final saved = await showSignatureAiSheet(
      context,
      initial: _service.aiSettings,
    );
    if (saved == null) return;
    await _service.saveAiSettings(saved);
    if (!mounted) return;
    // 设置换了，上一句就不再是这份设置的产物，别拿它冒充新效果。
    setState(() {
      _tested = null;
      _failed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final available = _service.aiAvailable;
    final settings = _service.aiSettings;
    final instruction = settings.instruction.trim().isEmpty
        ? t.settings.signatureAiDefaultInstruction
        : settings.instruction.trim();
    final subtitle =
        _failed ??
        _tested ??
        _service.lastValueOf(SignatureProvider.aiHitokoto.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.settings.signatureAiHint,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _edit,
                child: AiInfoCard(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    t.settings.signatureAiSourceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (!settings.isDefault) ...[
                                  const SizedBox(width: 6),
                                  AiTag(t.settings.signaturePromptEdited),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '{${SignatureProvider.aiHitokoto.id}}',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // ⭐ 卡片上直接写出「它现在被要求写什么」：这是用户对
                            // 这个功能最想知道的一件事，不该藏在点进去的弹窗里。
                            Text(
                              instruction,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                            if (!available) ...[
                              const SizedBox(height: 2),
                              Text(
                                t.settings.signatureAiUnavailable,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.3,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ] else if (subtitle != null &&
                                subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.3,
                                  color: _failed != null
                                      ? cs.error
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // AI 不可用时测试必然失败，摆一枚点了只会报错的钮没有意义。
                      if (available)
                        GlassAsyncIconButton(
                          icon: const Icon(Icons.play_arrow_outlined),
                          tooltip: t.settings.signatureSourceTest,
                          standalone: true,
                          onPressed: _test,
                        ),
                      GlassIconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: t.settings.signatureAiSheetTitle,
                        standalone: true,
                        onPressed: _edit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 编辑 AI 一言。返回用户要保存的那份，取消返回 null。
Future<SignatureAiSettings?> showSignatureAiSheet(
  BuildContext context, {
  required SignatureAiSettings initial,
}) {
  return showGlassDraggableBottomSheet<SignatureAiSettings>(
    context: context,
    builder: (context) => _SignatureAiSheet(initial: initial),
  );
}

/// AI 一言的编辑弹窗：看得到什么 / 写什么 / 格式 / 玩法 / 试一下。
///
/// ⭐ 这张弹窗要回答的是用户原话里的两个问题（2026-09-23）：「AI 能获取到
/// 什么信息」「可以指挥 AI 干嘛」。旧版只摆一段英文系统提示词，两个问题都
/// 答不上——看得到什么藏在一段看不见的附加消息里，能干嘛要用户自己想。
///
/// ⛔ 版式走 [GlassFloatingHeaderSheet]：正文是一张滚动列表，标题行与底栏都
/// 浮在它之上（全站约定）。
class _SignatureAiSheet extends StatefulWidget {
  const _SignatureAiSheet({required this.initial});

  final SignatureAiSettings initial;

  @override
  State<_SignatureAiSheet> createState() => _SignatureAiSheetState();
}

/// 一次「试一下」的结果。
class _TryResult {
  const _TryResult({
    required this.text,
    required this.tag,
    this.failed = false,
  });

  final String text;

  /// 「在视频页 · 中」：这句是按什么条件写出来的。改一次设置试一次，并排着
  /// 比才看得出改动有没有用。
  final String tag;
  final bool failed;
}

class _SignatureAiSheetState extends State<_SignatureAiSheet> {
  final SignatureService _service = Get.find<SignatureService>();

  late final TextEditingController _instruction;
  late SignatureAiLength _length;
  late bool _allowEmoji;
  late SignatureAiLanguage _language;
  late bool _readReplyText;

  SignatureSceneSet? _scenes;
  int _sceneIndex = 0;

  final List<_TryResult> _results = [];
  bool _running = false;
  bool _wireOpen = false;

  /// 最多留几次「试一下」的结果。
  static const int _maxResults = 3;

  String get _defaultInstruction =>
      slang.t.settings.signatureAiDefaultInstruction;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    // ⭐ 出厂那句直接摊在输入框里，不是空框加一句「留空则使用默认」：用户要改
    // 的是措辞，看得见原句才知道从哪儿改起。保存时与出厂那句相同就存空串，
    // 好让它继续跟着界面语言走。
    _instruction = TextEditingController(
      text: s.instruction.trim().isEmpty ? _defaultInstruction : s.instruction,
    );
    _instruction.addListener(() => setState(() {}));
    _length = s.length;
    _allowEmoji = s.allowEmoji;
    _language = s.language;
    _readReplyText = s.readReplyText;
    loadSignatureScenes(slang.t).then((value) {
      if (mounted) setState(() => _scenes = value);
    });
  }

  @override
  void dispose() {
    // ⛔ 在 State.dispose 里收：sheet 的 future 在 pop 那一刻就完成了，弹层还要
    // 播退场动画，提前 dispose 会撞上「used after being disposed」。
    _instruction.dispose();
    super.dispose();
  }

  SignatureAiSettings get _current {
    final text = _instruction.text.trim();
    return SignatureAiSettings(
      instruction: text == _defaultInstruction.trim() ? '' : text,
      length: _length,
      allowEmoji: _allowEmoji,
      language: _language,
      readReplyText: _readReplyText,
    );
  }

  SignatureScene? get _scene => _scenes?.scenes[_sceneIndex];

  SignatureContext get _sceneContext =>
      _scene?.context ?? SignatureContext.empty;

  void _resetToDefault() {
    setState(() {
      _instruction.text = _defaultInstruction;
      _length = SignatureAiSettings.defaults.length;
      _allowEmoji = SignatureAiSettings.defaults.allowEmoji;
      _language = SignatureAiSettings.defaults.language;
      _readReplyText = SignatureAiSettings.defaults.readReplyText;
    });
  }

  /// 把 `{title}` 这类变量插在光标处；输入框没焦点过就接在末尾。
  void _insertVariable(String name) {
    final token = '{$name}';
    final value = _instruction.value;
    final sel = value.selection;
    final start = sel.isValid ? sel.start : value.text.length;
    final end = sel.isValid ? sel.end : value.text.length;
    _instruction.value = TextEditingValue(
      text: value.text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + token.length),
    );
  }

  void _applyRecipe(SignatureAiRecipe recipe) {
    if (recipe.needsReplyText && !_readReplyText) {
      showAppToast(
        slang.t.settings.signatureAiRecipeNeedsReply,
        type: AppToastType.info,
      );
      return;
    }
    _instruction.value = TextEditingValue(
      text: recipe.instruction,
      selection: TextSelection.collapsed(offset: recipe.instruction.length),
    );
  }

  /// 拿**当前这份**设置（不是已保存的那份）在当前场景下真跑一次。
  Future<void> _tryIt() async {
    final t = slang.t;
    final scene = _scene;
    final tag =
        '${scene?.label ?? t.settings.signatureSceneNone} · '
        '${_lengthLabel(t, _length)}';
    setState(() => _running = true);
    String? value;
    try {
      value = await _service.fetchAiWith(_current, context: _sceneContext);
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
          _results.insert(
            0,
            value == null || value.trim().isEmpty
                ? _TryResult(
                    text: t.settings.signatureSourceTestFailed,
                    tag: tag,
                    failed: true,
                  )
                : _TryResult(text: value.trim(), tag: tag),
          );
          if (_results.length > _maxResults) _results.removeLast();
        });
      }
    }
  }

  static String _lengthLabel(slang.Translations t, SignatureAiLength l) =>
      switch (l) {
        SignatureAiLength.short => t.settings.signatureAiLengthShort,
        SignatureAiLength.medium => t.settings.signatureAiLengthMedium,
        SignatureAiLength.long => t.settings.signatureAiLengthLong,
      };

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final available = _service.aiAvailable;

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: t.settings.signatureAiSheetTitle,
      leading: const Icon(Icons.auto_awesome, size: 20),
      footer: Row(
        children: [
          if (!_current.isDefault)
            GlassTextActionButton(
              label: t.settings.signaturePromptReset,
              onPressed: _resetToDefault,
            ),
          const Spacer(),
          GlassTextActionButton(
            label: t.common.confirm,
            emphasized: true,
            onPressed: () => Navigator.of(context).pop(_current),
          ),
        ],
      ),
      bodyBuilder: (context, scrollController, headerExtent, footerExtent) =>
          ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              headerExtent,
              16,
              footerExtent + 16,
            ),
            children: [
              _buildSee(context, t),
              const SizedBox(height: 22),
              _buildWhat(context, t),
              const SizedBox(height: 22),
              _buildFormat(context, t),
              const SizedBox(height: 22),
              _buildRecipes(context, t),
              const SizedBox(height: 22),
              _buildTry(context, t, available),
            ],
          ),
    );
  }

  // ------------------------------------------------------ 看得到什么

  /// 这次会进事实表的那几项，按变量名排。与 `SignatureContext.toPromptFacts`
  /// 一一对应——这里摆出来的就是 AI 真拿到的，不多不少。
  static const List<String> _factVariables = [
    'title',
    'author',
    'tags',
    'section',
    'reply_to',
    'floor',
    'duration',
    'playtime',
  ];

  Widget _buildSee(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final scenes = _scenes;
    final ctx = _sceneContext;

    final hidden = [
      t.settings.signatureAiCannotSeeDraft,
      if (!_readReplyText) t.settings.signatureAiCannotSeeReply,
      t.settings.signatureAiCannotSeeAccount,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(t.settings.signatureAiSeeTitle),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: scenes == null
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ⛔ 分段胶囊一律走 GlassAdaptiveSegmentedControl（摆不下时
                    // 自己退化成下拉钮），闸门见 test/glass_style_guard_test.dart。
                    GlassAdaptiveSegmentedControl(
                      items: [
                        for (final s in scenes.scenes)
                          GlassSegmentItem(
                            label: s.label,
                            icon: Icon(s.icon, size: 15),
                          ),
                      ],
                      selectedIndex: _sceneIndex,
                      onChanged: (i) => setState(() => _sceneIndex = i),
                    ),
                    const SizedBox(height: 6),
                    _Caption(
                      scenes.fromHistory
                          ? t.settings.signatureSceneFromHistory
                          : t.settings.signatureSceneFromDemo,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final name in _factVariables)
                          _FactChip(
                            label: SignatureVariableLabels.of(t, name),
                            value: _service.renderAiInstruction('{$name}', ctx),
                            unavailableText:
                                t.settings.signatureAiFactUnavailable,
                            onTap: () => _insertVariable(name),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _Caption(t.settings.signatureAiFactTapHint),
                  ],
                ),
        ),
        const SizedBox(height: 4),
        GlassSwitchItem(
          title: Text(t.settings.signatureAiReadReply),
          subtitle: Text(t.settings.signatureAiReadReplyDesc),
          value: _readReplyText,
          onChanged: (v) => setState(() => _readReplyText = v),
        ),
        // 打开之后，在当前场景下它会读到的那句原话就摆在这儿。
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _readReplyText && (ctx.replyText?.isNotEmpty ?? false)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AiInfoCard(
                    child: Text(
                      ctx.replyText!,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Text(
          t.settings.signatureAiCannotSee(items: hidden),
          style: TextStyle(
            fontSize: 11.5,
            height: 1.45,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        _Caption(t.settings.signatureAiPrivacy),
      ],
    );
  }

  // ------------------------------------------------------ 写什么

  Widget _buildWhat(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final scene = _scene;
    final rendered = _service.renderAiInstruction(
      _instruction.text,
      _sceneContext,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(t.settings.signatureAiWhatTitle),
        GlassInputSurface(
          child: TextField(
            controller: _instruction,
            maxLines: null,
            minLines: 3,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontSize: 13.5, height: 1.45),
            decoration: glassFieldDecoration(
              context,
              hint: _defaultInstruction,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _Caption(t.settings.signatureAiWhatHint),
        const SizedBox(height: 8),
        // 代入之后的样子：`{title}` 在这个场景下变成了什么、哪一段消失了。
        AiInfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.settings.signatureAiWhatPreview(
                  scene: scene?.label ?? t.settings.signatureSceneNone,
                ),
                style: TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 3),
              Text(
                rendered.isEmpty ? '—' : rendered,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------ 格式

  Widget _buildFormat(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    const lengths = SignatureAiLength.values;
    const languages = SignatureAiLanguage.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(t.settings.signatureAiFormatTitle),
        // 写死的那几条：不给改，但要让人看见——它们解释了为什么 AI 写出来的
        // 永远是一行、不带引号。
        Row(
          children: [
            Icon(Icons.lock_outline, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.settings.signatureAiFormatFixed,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _LabeledRow(
          label: t.settings.signatureAiLength,
          child: GlassAdaptiveSegmentedControl(
            items: [
              for (final l in lengths)
                GlassSegmentItem(label: _lengthLabel(t, l)),
            ],
            selectedIndex: lengths.indexOf(_length),
            onChanged: (i) => setState(() => _length = lengths[i]),
          ),
        ),
        const SizedBox(height: 8),
        _LabeledRow(
          label: t.settings.signatureAiLanguage,
          child: GlassAdaptiveSegmentedControl(
            items: [
              GlassSegmentItem(label: t.settings.signatureAiLanguageUi),
              GlassSegmentItem(label: t.settings.signatureAiLanguageDraft),
            ],
            selectedIndex: languages.indexOf(_language),
            onChanged: (i) => setState(() => _language = languages[i]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _language == SignatureAiLanguage.draft
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _Caption(t.settings.signatureAiLanguageDraftHint),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 4),
        GlassSwitchItem(
          title: Text(t.settings.signatureAiAllowEmoji),
          value: _allowEmoji,
          onChanged: (v) => setState(() => _allowEmoji = v),
        ),
      ],
    );
  }

  // ------------------------------------------------------ 玩法

  Widget _buildRecipes(BuildContext context, slang.Translations t) {
    final recipes = signatureAiRecipes(t);
    final current = _instruction.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(t.settings.signatureAiRecipesTitle),
        _Caption(t.settings.signatureAiRecipesHint),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            final columns = constraints.maxWidth >= 520 ? 3 : 2;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final r in recipes)
                  SizedBox(
                    width: width,
                    child: _RecipeCard(
                      recipe: r,
                      selected: current == r.instruction.trim(),
                      locked: r.needsReplyText && !_readReplyText,
                      exampleLabel: t.settings.signatureAiExample,
                      lockedNote: t.settings.signatureAiRecipeNeedsReply,
                      onTap: () => _applyRecipe(r),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------ 试一下

  Widget _buildTry(BuildContext context, slang.Translations t, bool available) {
    final cs = Theme.of(context).colorScheme;
    final messages = _service.buildAiMessages(_current, context: _sceneContext);
    final sceneLabel = _scene?.label ?? t.settings.signatureSceneNone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _SectionTitle(t.settings.signatureAiTryTitle)),
            // AI 没配好时「试一下」必然失败，别摆一枚只会报错的钮。
            if (available)
              GlassTextActionButton(
                label: t.settings.signaturePromptTry,
                loading: _running,
                emphasized: true,
                onPressed: _tryIt,
              ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!available)
                AiNoticeLine(
                  t.settings.signatureAiTryNeedsProvider,
                  tone: AiTone.neutral,
                )
              else if (_results.isEmpty)
                _Caption(t.settings.signatureAiTryEmpty(scene: sceneLabel))
              else
                for (final r in _results)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: AiInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          r.failed
                              ? AiNoticeLine(r.text, tone: AiTone.error)
                              : Text(
                                  r.text,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                          const SizedBox(height: 3),
                          Text(
                            r.tag,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // ⭐ 发给模型的两段**原文**，与发送时同一个函数拼出来。给想知道「它到底
        // 收到了什么」的人一个不用猜的答案。
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => setState(() => _wireOpen = !_wireOpen),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: _wireOpen ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.settings.signatureAiWireTitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _wireOpen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WireBlock(
                      label: t.settings.signatureAiWireSystem,
                      text: messages.system,
                    ),
                    const SizedBox(height: 8),
                    _WireBlock(
                      label: t.settings.signatureAiWireUser,
                      text: messages.user,
                    ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    ),
  );
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      height: 1.4,
      color: Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
    ),
  );
}

/// 上面一行小标签，下面一枚控件。
///
/// ⛔ 不做成「左标签右控件」：手机宽度下分段胶囊只剩三分之二的宽，「长 · 约
/// 60 字」这类段名会被从右边截掉（渲染实测）。
class _LabeledRow extends StatelessWidget {
  const _LabeledRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 6),
      child,
    ],
  );
}

/// 事实表里的一项：「标题 · 月光下的旋转」。点一下把 `{title}` 插进要求里。
///
/// 这个场景给不出时照样摆着、灰掉并写明「这里给不出」——各处给得深浅不一，
/// 让它消失的话用户没法知道换一个场合它就有了。
class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.label,
    required this.value,
    required this.unavailableText,
    required this.onTap,
  });

  final String label;
  final String value;
  final String unavailableText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final available = value.isNotEmpty;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(
                fontSize: 10.5,
                color: cs.onSurfaceVariant.withValues(
                  alpha: available ? 0.9 : 0.5,
                ),
              ),
            ),
            TextSpan(
              text: available ? value : unavailableText,
              style: TextStyle(
                fontSize: 12,
                color: available
                    ? cs.onSurface
                    : cs.onSurfaceVariant.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Material(
        color: available
            ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
            : cs.surfaceContainerHighest.withValues(alpha: 0.2),
        shape: StadiumBorder(
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: available ? InkWell(onTap: onTap, child: content) : content,
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.selected,
    required this.locked,
    required this.exampleLabel,
    required this.lockedNote,
    required this.onTap,
  });

  final SignatureAiRecipe recipe;
  final bool selected;
  final bool locked;
  final String exampleLabel;
  final String lockedNote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      opacity: locked ? 0.55 : 1,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? cs.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                // 要求里的 `{title}` 着主色：一眼看出哪几处会被当场代入。
                Text.rich(
                  TextSpan(
                    children: [
                      for (final part in _splitVariables(recipe.instruction))
                        TextSpan(
                          text: part,
                          style: part.startsWith('{')
                              ? TextStyle(color: cs.primary)
                              : null,
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$exampleLabel · ',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      TextSpan(
                        text: recipe.example,
                        style: TextStyle(color: cs.primary),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
                if (locked) ...[
                  const SizedBox(height: 4),
                  Text(
                    lockedNote,
                    style: TextStyle(fontSize: 10.5, color: cs.tertiary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 把一句要求切成「普通文字 / `{变量}`」交替的几段。
List<String> _splitVariables(String text) {
  final out = <String>[];
  var index = 0;
  for (final m in RegExp(r'\{[A-Za-z_][^}]*\}').allMatches(text)) {
    if (m.start > index) out.add(text.substring(index, m.start));
    out.add(m[0]!);
    index = m.end;
  }
  if (index < text.length) out.add(text.substring(index));
  return out;
}

/// 「这次 AI 实际收到的」里的一段原文。
///
/// ⛔ 用普通 Text，不用 SelectableText：头显上拖选识别器会吃掉整张弹层的
/// 上下拖动（见 memory xr-text-selection-steals-page-drag）。
class _WireBlock extends StatelessWidget {
  const _WireBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              fontFamily: 'monospace',
              color: cs.onSurface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
