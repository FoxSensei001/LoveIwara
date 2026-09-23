import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_endpoint_preview.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/ai/ai_ui_parts.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:url_launcher/url_launcher.dart';

/// 接入一家 AI 供应商的结果。
class AiProviderDraft {
  const AiProviderDraft({required this.provider, required this.models});

  final AiProvider provider;
  final List<AiModel> models;
}

/// 接入向导：挑一家 → 填密钥 → 选模型 → **真试一次**。
///
/// ⭐ 第四步不是装饰。两件事只有真发一次请求才知道：
///
/// 1. `listModels` 列出来的模型**不一定能用**——2026-09-21 实测，同一张表里的
///    `qwen3.8-max` 请求回 404 model_not_found。让用户带着一条跑不通的配置离开
///    向导，他下次看到的是「AI 翻译失败」，而根本不会想到回来换模型。
/// 2. 这家端点认不认 `response_format: json_schema`。⛔ 这件事**没法从 kind 上
///    看出来**（中转的 kind 和官方 OpenAI 一模一样），改造前是让用户自己去猜那个
///    开关。这一步顺手探出来，写进档案。
Future<AiProviderDraft?> showAiProviderWizard(
  BuildContext context, {
  required Set<String> takenIds,
}) {
  return showGlassDraggableBottomSheet<AiProviderDraft>(
    context: context,
    builder: (context) => _AiProviderWizardSheet(takenIds: takenIds),
  );
}

enum _Step { pickProvider, apiKey, models, verify }

/// 第四步里每一格的状态。
enum _CheckState { pending, running, ok, warn, failed }

class _AiProviderWizardSheet extends StatefulWidget {
  const _AiProviderWizardSheet({required this.takenIds});

  final Set<String> takenIds;

  @override
  State<_AiProviderWizardSheet> createState() => _AiProviderWizardSheetState();
}

class _AiProviderWizardSheetState extends State<_AiProviderWizardSheet> {
  _Step _step = _Step.pickProvider;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  /// 选中的目录条目。null ＝ 走「自定义 OpenAI 兼容端点」那条。
  AiCatalogProvider? _catalog;
  String _id = '';

  List<String> _fetchedModels = const [];
  final Set<String> _selectedModels = {};
  bool _busy = false;
  String? _error;

  /// 第四步的两格。
  _CheckState _chatCheck = _CheckState.pending;
  _CheckState _schemaCheck = _CheckState.pending;
  bool? _structuredOutput;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _needsKey => _catalog?.needsApiKey ?? true;
  String get _kind => _catalog?.kind ?? AiProviderKind.openai;

  String get _effectiveBaseUrl {
    final typed = _baseUrlController.text.trim();
    if (typed.isNotEmpty) return typed;
    return _catalog?.baseUrl ?? '';
  }

  // ------------------------------------------------------------------ 流程

  void _pick(AiCatalogProvider? catalog) {
    // ⛔ 撞名时不要靠「再读一次 microsecondsSinceEpoch」来躲：同一微秒内重试拿到
    // 的是同一个数，那是一圈空转而不是重试。用递增后缀，一定能收敛。
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    var newId = stamp;
    var suffix = 1;
    while (widget.takenIds.contains(newId)) {
      newId = '${stamp}_${suffix++}';
    }
    setState(() {
      _catalog = catalog;
      _id = newId;
      _error = null;
      _nameController.text = catalog?.name ?? '';
      _baseUrlController.text = '';
      // 本机端点不要密钥，那一步直接跳过。
      _step = (catalog?.needsApiKey ?? true) ? _Step.apiKey : _Step.models;
    });
    if (_step == _Step.models) unawaitedFetch();
  }

  void unawaitedFetch() {
    // ignore: discarded_futures
    _fetchModels();
  }

  AiProvider _draftProvider() => AiProvider(
    id: _id,
    catalogId: _catalog?.id ?? '',
    name:
        _nameController.text.trim().isEmpty ||
            _nameController.text.trim() == _catalog?.name
        ? null
        : _nameController.text.trim(),
    // 完全自定义那条没有目录可继承，kind 必须自己带。
    kind: _catalog == null ? AiProviderKind.openai : null,
    baseUrl: _baseUrlController.text.trim().isEmpty
        ? null
        : _baseUrlController.text.trim(),
    structuredOutput: _structuredOutput,
    apiKey: _apiKeyController.text.trim(),
  );

  AiResolvedModel _resolve(String modelId) => resolveAiModel(
    provider: _draftProvider(),
    model: AiModel(providerId: _id, modelId: modelId),
    providerCatalog: _catalog,
    modelCatalog: AiCatalogService.modelOf(modelId),
  );

  Future<void> _fetchModels() async {
    final t = slang.t;
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await Get.find<AiService>().listModels(_resolve(''));
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res.isSuccess && (res.data?.isNotEmpty ?? false)) {
        _fetchedModels = res.data!;
        // 目录认识的那几条默认勾上——它们是我们**知道**能力的模型，
        // 而一张几百条的中转列表里用户多半不知道该选哪个。
        final known = _fetchedModels
            .where((m) => AiCatalogService.modelOf(m) != null)
            .take(3);
        _selectedModels
          ..clear()
          ..addAll(known);
      } else {
        _fetchedModels = const [];
        // ⛔ 拉不到不是死路：本地端点、部分中转就是不给列表，手填模型名照样能用。
        _error = res.isSuccess
            ? t.ai.modelEmpty
            : (res.message.isNotEmpty ? res.message : t.ai.modelEmpty);
      }
    });
  }

  /// 第四步：真发请求。
  Future<void> _verify() async {
    final ai = Get.find<AiService>();
    final modelId = _selectedModels.isEmpty ? '' : _selectedModels.first;
    setState(() {
      _step = _Step.verify;
      _chatCheck = _CheckState.running;
      _schemaCheck = _CheckState.pending;
      _error = null;
    });

    final chat = await ai.test(_resolve(modelId));
    if (!mounted) return;
    final chatOk = chat.data?.connectionValid ?? false;
    setState(() {
      _chatCheck = chatOk ? _CheckState.ok : _CheckState.failed;
      if (!chatOk) {
        _error = chat.data?.custMessage ?? chat.message;
      }
      _schemaCheck = chatOk ? _CheckState.running : _CheckState.pending;
    });
    if (!chatOk) return;

    // 探结构化输出：让它按一份极小的 schema 回一个 JSON。
    // ⛔ 探的是**端点**认不认 json_schema，所以必须绕开 AiService.structured 的
    // 降级路（那条路一定会成功，探不出任何东西）——这里直接把 flag 打开去试，
    // 回来的要是散文就说明这家静默忽略了它。
    final probe = _resolve(modelId);
    final schemaOk = await _probeStructuredOutput(ai, probe);
    if (!mounted) return;
    setState(() {
      _structuredOutput = schemaOk;
      _schemaCheck = schemaOk ? _CheckState.ok : _CheckState.warn;
    });
  }

  Future<bool> _probeStructuredOutput(
    AiService ai,
    AiResolvedModel model,
  ) async {
    try {
      final res = await ai.structured(
        AiRequest(
          task: AiTask.searchQuery,
          input: 'Reply with {"ok":true}.',
          model: model.copyWith(structuredOutput: true),
          timeout: const Duration(seconds: 45),
        ),
        // ⛔ 用 `Schema.fromMap` 手写，不用 json_schema_builder 的 builder：
        // dartantic 只 re-export 了 `S` / `Schema` 两个名字（同 ai_search_query）。
        schema: Schema.fromMap({
          'type': 'object',
          'properties': {
            'ok': {'type': 'boolean'},
          },
          'required': ['ok'],
        }),
      );
      return res.isSuccess && res.data?['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  void _finish() {
    final models = _selectedModels.isEmpty
        // 一个都没选也放行：空模型名 ＝「用服务端默认模型」，是合法配置
        // （本地端点尤其常见）。拦下来只会让人卡在最后一步。
        ? [AiModel(providerId: _id, modelId: '')]
        : [
            for (final m in _selectedModels)
              AiModel(providerId: _id, modelId: m),
          ];
    Navigator.of(
      context,
    ).pop(AiProviderDraft(provider: _draftProvider(), models: models));
  }

  // ------------------------------------------------------------------ 界面

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final title = switch (_step) {
      _Step.pickProvider => t.ai.pickPreset,
      _Step.apiKey => t.ai.wizardApiKeyTitle,
      _Step.models => t.ai.wizardModelsTitle,
      _Step.verify => t.ai.wizardVerifyTitle,
    };

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: t.ai.addProvider,
      titleWidget: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        child: Text(
          title,
          key: ValueKey(title),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Icon(
          switch (_step) {
            _Step.pickProvider => Icons.auto_awesome,
            _Step.apiKey => Icons.vpn_key_outlined,
            _Step.models => Icons.list_alt_outlined,
            _Step.verify => Icons.task_alt,
          },
          key: ValueKey(_step),
          size: 20,
        ),
      ),
      // 第一屏没有底栏：点哪条就直接走了。
      footer: _step == _Step.pickProvider ? null : _footer(t),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  _Step.pickProvider => _pickBody(t),
                  _Step.apiKey => _apiKeyBody(t),
                  _Step.models => _modelsBody(t),
                  _Step.verify => _verifyBody(t),
                },
              ),
              _errorBlock(),
            ],
          ),
    );
  }

  Widget _footer(slang.Translations t) {
    final canNext = switch (_step) {
      _Step.apiKey => !_needsKey || _apiKeyController.text.trim().isNotEmpty,
      _Step.models => !_busy,
      _ => true,
    };
    return Row(
      children: [
        GlassButtonGroup(
          touchFlexSignature: 'ai-wizard|$_step',
          children: [
            GlassTextActionButton(
              label: t.common.back,
              onPressed: () => setState(() {
                _step = switch (_step) {
                  _Step.verify => _Step.models,
                  _Step.models => _needsKey ? _Step.apiKey : _Step.pickProvider,
                  _ => _Step.pickProvider,
                };
                _error = null;
              }),
            ),
          ],
        ),
        const Spacer(),
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: _step == _Step.verify ? t.common.confirm : t.ai.wizardNext,
              emphasized: true,
              loading: _busy,
              onPressed: !canNext
                  ? null
                  : () {
                      switch (_step) {
                        case _Step.apiKey:
                          setState(() => _step = _Step.models);
                          unawaitedFetch();
                        case _Step.models:
                          _verify();
                        case _Step.verify:
                          _finish();
                        case _Step.pickProvider:
                          break;
                      }
                    },
            ),
          ],
        ),
      ],
    );
  }

  // ── 第一步：挑一家 ─────────────────────────────────────────────────────

  Widget _pickBody(slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final all = AiCatalogService.allProviders;
    final matched = query.isEmpty
        ? all
        : all
              .where(
                (p) =>
                    p.name.toLowerCase().contains(query) ||
                    p.id.toLowerCase().contains(query),
              )
              .toList();

    return Column(
      key: const ValueKey('pick'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ⛔ 这里**不能**用 [GlassSearchInputField]：那只件是给定高玻璃胶囊
        // （header 上那种）准备的，自身 `height: double.infinity`，塞进这条
        // 高度不定的 Column 里会当场抛「forces an infinite height」——而那条
        // 异常会打断整只 sliver 的 layout，geometry 留成 null，下一次 hit test
        // 报出来的是一句看不懂的「Null check operator used on a null value」。
        // 表单里的输入框一律与本向导其余几步同款：GlassInputSurface + TextField。
        GlassInputSurface(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            // 这张表是就地过滤的，回车没有额外动作——但它仍要收起输入法，
            // 否则列表被键盘压掉一半。
            onSubmitted: (_) => _searchFocus.unfocus(),
            onChanged: (_) => setState(() {}),
            decoration: glassFieldDecoration(
              context,
              hint: t.ai.searchProvider,
              icon: Icons.search,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (all.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              t.ai.catalogMissing,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        GlassSettingSection(
          children: [
            for (final provider in matched)
              GlassSettingTile(
                title: Text(
                  provider.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  provider.baseUrl.isEmpty
                      ? AiProviderKind.displayName(provider.kind)
                      : provider.baseUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _pick(provider),
              ),
            // ⛔ 永远排最后：第一屏不该是空白表单。用户想要的是「一个能用的
            // AI」，让他从 baseUrl 开始填是把我们的实现细节当成了他的任务。
            GlassSettingTile(
              icon: Icons.add_link,
              title: Text(
                t.ai.customProvider,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(t.ai.customProviderHint),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => _pick(null),
            ),
          ],
        ),
      ],
    );
  }

  // ── 第二步：密钥 ───────────────────────────────────────────────────────

  Widget _apiKeyBody(slang.Translations t) {
    final keyUrl = _catalog?.apiKeyUrl;
    return Column(
      key: const ValueKey('key'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AiLabeledField(
          label: t.ai.providerNameLabel,
          child: GlassInputSurface(
            child: TextField(
              controller: _nameController,
              decoration: glassFieldDecoration(
                context,
                hint: _catalog?.name ?? t.ai.customProvider,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AiLabeledField(
          label: t.ai.apiKey,
          footer: keyUrl == null
              ? null
              : Align(
                  alignment: Alignment.centerLeft,
                  child: GlassTextActionButton(
                    label: t.ai.getApiKey,
                    onPressed: () async {
                      final uri = Uri.tryParse(keyUrl);
                      if (uri != null) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ),
          child: GlassInputSurface(
            child: TextField(
              controller: _apiKeyController,
              obscureText: true,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: glassFieldDecoration(context, hint: t.ai.apiKey),
            ),
          ),
        ),
        // 自定义端点那条必须自己填地址；目录里那几家默认继承，也允许改。
        const SizedBox(height: 14),
        AiLabeledField(
          label: t.ai.baseUrl,
          footer: AiEndpointPreview(kind: _kind, baseUrl: _effectiveBaseUrl),
          child: GlassInputSurface(
            child: TextField(
              controller: _baseUrlController,
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: glassFieldDecoration(
                context,
                hint: _catalog?.baseUrl ?? 'https://api.example.com/v1',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 第三步：选模型 ─────────────────────────────────────────────────────

  Widget _modelsBody(slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final suggested = _catalog?.suggestedModels ?? const <String>[];
    final options = _fetchedModels.isNotEmpty ? _fetchedModels : suggested;

    return Column(
      key: const ValueKey('models'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _fetchedModels.isNotEmpty
                    ? t.ai.wizardModelsHint
                    : t.ai.wizardModelsFallbackHint,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            GlassIconButton(
              standalone: true,
              loading: _busy,
              icon: const Icon(Icons.refresh),
              tooltip: t.ai.fetchModels,
              onPressed: _fetchModels,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (options.isEmpty && !_busy)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              t.ai.wizardNoModels,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        for (final model in options)
          AiModelCheckRow(
            title: AiCatalogService.modelOf(model)?.name ?? model,
            modelId: model,
            checked: _selectedModels.contains(model),
            onChanged: (checked) => setState(() {
              if (checked) {
                _selectedModels.add(model);
              } else {
                _selectedModels.remove(model);
              }
            }),
          ),
      ],
    );
  }

  // ── 第四步：真试一次 ───────────────────────────────────────────────────

  Widget _verifyBody(slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('verify'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.ai.wizardVerifyHint,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _checkRow(t.ai.wizardCheckChat, _chatCheck, cs),
        _checkRow(
          t.ai.wizardCheckSchema,
          _schemaCheck,
          cs,
          // ⭐ 这一格**警告不是失败**：端点不认 json_schema 时我们会走提示词
          // 契约那条路，AI 搜索照样能用，只是慢一点。说成「失败」会让用户
          // 以为这家不能用。
          hint: t.ai.wizardCheckSchemaWarn,
        ),
      ],
    );
  }

  Widget _checkRow(
    String label,
    _CheckState state,
    ColorScheme cs, {
    String? hint,
  }) {
    final icon = switch (state) {
      _CheckState.pending => Icon(
        Icons.radio_button_unchecked,
        size: 18,
        color: cs.onSurfaceVariant,
      ),
      _CheckState.running => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      _CheckState.ok => Icon(
        Icons.check_circle,
        size: 18,
        color: Colors.green.shade600,
      ),
      _CheckState.warn => Icon(
        Icons.error_outline,
        size: 18,
        color: cs.tertiary,
      ),
      _CheckState.failed => Icon(Icons.cancel, size: 18, color: cs.error),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13)),
                if ((state == _CheckState.warn ||
                        state == _CheckState.failed) &&
                    hint != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: AiNoticeLine(
                      hint,
                      tone: state == _CheckState.warn
                          ? AiTone.warning
                          : AiTone.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBlock() => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
    alignment: Alignment.topCenter,
    child: _error == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AiNoticeLine(_error!, tone: AiTone.error),
          ),
  );
}
