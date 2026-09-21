import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/signature_ai_prompt.dart';
import 'package:i_iwara/app/utils/signature_scenes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置页里的「AI 一言」整块。
///
/// ⛔ **它不在「数据源」那张列表里**（2026-09-21 用户点名）。数据源的含义是
/// 「一个会返回一句话的地址」——地址、取值路径、加工规则，整套向导都是围着
/// 这件事转的。AI 一言一样都不占：它不请求地址，唯一的可调项是**提示词**。
/// 混在一起时点进去会落在「填接口地址」那一屏上，对着一个 AI 功能问 URL。
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
    try {
      // ⭐ 带上示范上下文。空上下文跑出来的是一句放之四海皆准的格言，而 AI 一言
      // 与接口一言唯一的分野就是它**知道用户在看什么**——不带上下文试一次，
      // 等于把这个功能最值钱的部分藏起来（见 SignatureContext.toPromptFacts）。
      final scenes = await loadSignatureScenes(slang.t);
      final value = await _service.fetchWith(
        _service.aiProvider,
        context: scenes.byId(SignatureScene.videoId).context,
      );
      if (!mounted) return;
      setState(() {
        _failed = null;
        if (value == null || value.trim().isEmpty) {
          _failed = slang.t.settings.signatureSourceTestFailed;
        } else {
          _tested = value.trim();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _failed = e.toString());
    }
  }

  Future<void> _editPrompt() async {
    final saved = await showSignatureAiPromptSheet(
      context,
      initial: _service.aiProvider.prompt,
    );
    if (saved == null) return;
    await _service.saveAiPrompt(saved);
    if (!mounted) return;
    // 提示词换了，上一句就不再是这条提示词的产物，别拿它冒充新效果。
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
    final customized = _service.aiProvider.prompt.trim().isNotEmpty;
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
          Material(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _editPrompt,
              child: Padding(
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
                              if (customized) ...[
                                const SizedBox(width: 6),
                                _Tag(text: t.settings.signaturePromptEdited),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          // 模板里怎么引用它。和数据源那张列表同一个读法。
                          Text(
                            '{${SignatureProvider.aiHitokoto.id}}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: cs.primary,
                            ),
                          ),
                          // AI 没配好时这里说的是「为什么它现在不会出现在变量
                          // 面板里」——提示词照样能编辑，不把入口藏掉。
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
                      tooltip: t.settings.signaturePromptTitle,
                      standalone: true,
                      onPressed: _editPrompt,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer),
      ),
    );
  }
}

/// 编辑 AI 一言的提示词。返回用户要保存的那份，取消返回 null。
///
/// 返回空串＝恢复出厂（调用方交给 [SignatureService.saveAiPrompt] 处理）。
Future<String?> showSignatureAiPromptSheet(
  BuildContext context, {
  required String initial,
}) {
  return showGlassDraggableBottomSheet<String>(
    context: context,
    builder: (context) => _SignatureAiPromptSheet(initial: initial),
  );
}

/// ⛔ 版式走 [GlassFloatingHeaderSheet]：正文是一张滚动列表，标题行与底栏都
/// 浮在它之上（全站约定）。
class _SignatureAiPromptSheet extends StatefulWidget {
  const _SignatureAiPromptSheet({required this.initial});

  final String initial;

  @override
  State<_SignatureAiPromptSheet> createState() =>
      _SignatureAiPromptSheetState();
}

class _SignatureAiPromptSheetState extends State<_SignatureAiPromptSheet> {
  final SignatureService _service = Get.find<SignatureService>();

  late final TextEditingController _controller;

  /// 「试一下」取回来的那句话 / 那个错。
  String? _sample;
  String? _error;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // ⭐ 出厂那份直接摊在输入框里，而不是留一个空框加一句「留空则使用默认」。
    // 用户要改的是措辞，看不见原文就只能从零写一遍——而那份原文里恰好有他
    // 多半想保留的几条硬规则（只输出一句、不要引号、长度上限）。
    _controller = TextEditingController(
      text: widget.initial.trim().isEmpty
          ? SignatureAiPrompt.defaultTemplate
          : widget.initial,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // ⛔ 在 State.dispose 里收：sheet 的 future 在 pop 那一刻就完成了，弹层还要
    // 播退场动画，提前 dispose 会撞上「used after being disposed」。
    _controller.dispose();
    super.dispose();
  }

  bool get _isDefault =>
      _controller.text.trim() == SignatureAiPrompt.defaultTemplate.trim();

  void _resetToDefault() {
    setState(() {
      _controller.text = SignatureAiPrompt.defaultTemplate;
      _sample = null;
      _error = null;
    });
  }

  /// 拿**当前输入框里**这份提示词真跑一次，不是拿已保存的那份。
  ///
  /// ⭐ 这是这张弹窗存在的理由：提示词改得好不好，只有看它写出来的句子才知道。
  Future<void> _tryIt() async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      // 与卡片上那枚「测试」同一个道理：带上示范上下文，否则改完提示词试出来的
      // 那句话永远看不出「它其实知道你在看什么」。
      final scenes = await loadSignatureScenes(slang.t);
      final value = await _service.fetchWith(
        SignatureProvider(
          id: SignatureProvider.aiHitokoto.id,
          name: SignatureProvider.aiHitokoto.name,
          url: '',
          kind: SignatureProvider.kindAi,
          prompt: _controller.text,
        ),
        context: scenes.byId(SignatureScene.videoId).context,
      );
      if (!mounted) return;
      setState(() {
        if (value == null || value.trim().isEmpty) {
          _error = slang.t.settings.signatureSourceTestFailed;
        } else {
          _sample = value.trim();
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: t.settings.signaturePromptTitle,
      leading: const Icon(Icons.auto_awesome, size: 20),
      footer: Row(
        children: [
          if (!_isDefault)
            GlassTextActionButton(
              label: t.settings.signaturePromptReset,
              onPressed: _resetToDefault,
            ),
          const Spacer(),
          GlassButtonGroup(
            touchFlexSignature: 'sig-ai-prompt|${_service.aiAvailable}',
            children: [
              // AI 没配好时「试一下」必然失败，别摆一枚只会报错的钮。
              if (_service.aiAvailable)
                GlassTextActionButton(
                  label: t.settings.signaturePromptTry,
                  loading: _running,
                  onPressed: _tryIt,
                ),
              GlassTextActionButton(
                label: t.common.confirm,
                emphasized: true,
                onPressed: () =>
                    Navigator.of(context).pop(_controller.text.trim()),
              ),
            ],
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
              Text(
                t.settings.signaturePromptHint,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              GlassInputSurface(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  minLines: 10,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 13, height: 1.45),
                  decoration: glassFieldDecoration(
                    context,
                    hint: SignatureAiPrompt.defaultTemplate,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // `{language}` 是这张弹窗里唯一需要解释的东西：删掉它之后，
              // 德语用户拿到的一言会跟着提示词的语言走，而不是界面语言。
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.translate, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: SignatureAiPrompt.languagePlaceholder,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: cs.primary,
                            ),
                          ),
                          TextSpan(
                            text: '  ${t.settings.signaturePromptLanguageHint}',
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (_sample != null || _error != null) ...[
                const SizedBox(height: 14),
                Text(
                  t.settings.signaturePromptSample,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error ?? _sample!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: _error != null ? cs.error : null,
                    ),
                  ),
                ),
                if (_error == null) ...[
                  const SizedBox(height: 6),
                  // 说破试写用的是什么上下文。不说的话，用户会以为这句话里凭空
                  // 冒出来的标题是模型编的。
                  Text(
                    t.settings.signaturePromptSampleContext,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ],
          ),
    );
  }
}
