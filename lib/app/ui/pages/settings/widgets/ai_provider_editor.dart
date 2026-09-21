import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 打开 AI 供应商配置编辑器。
///
/// 新建时第一屏先让用户挑选预置项，编辑既有档案时直接进表单。
///
/// ⛔ 必须走 [showGlassDraggableBottomSheet]：里头是 [GlassFloatingHeaderSheet]
/// （标题行与底栏浮在内容之上），它要的是可拖拽壳那条手势链路。
Future<AiProviderProfile?> showAiProviderEditor(
  BuildContext context, {
  AiProviderProfile? initial,
  required Set<String> takenIds,
}) {
  return showGlassDraggableBottomSheet<AiProviderProfile>(
    context: context,
    builder: (context) =>
        AiProviderEditorSheet(initial: initial, takenIds: takenIds),
  );
}

class AiProviderEditorSheet extends StatefulWidget {
  const AiProviderEditorSheet({
    super.key,
    this.initial,
    required this.takenIds,
  });

  final AiProviderProfile? initial;
  final Set<String> takenIds;

  @override
  State<AiProviderEditorSheet> createState() => _AiProviderEditorSheetState();
}

class _AiProviderEditorSheetState extends State<AiProviderEditorSheet> {
  late bool _isPickingPreset;
  late String _id;
  late String _kind;
  late String _presetId;

  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _maxTokensController;

  late bool _reasoning;
  late bool _sendTemperature;
  late bool _streaming;
  late bool _structuredOutput;

  /// 正在拉模型列表。见触发钮那里为什么不能用 GlassAsyncIconButton。
  bool _loadingModels = false;
  bool _advancedOpen = false;

  bool _testing = false;
  String? _testSuccessMessage;
  String? _testErrorMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _isPickingPreset = initial == null;

    _id = initial?.id ?? '';
    _kind = initial?.kind ?? AiProviderKind.openai;
    _presetId = initial?.presetId ?? '';

    _nameController = TextEditingController(text: initial?.name ?? '');
    _apiKeyController = TextEditingController(text: initial?.apiKey ?? '');
    _baseUrlController = TextEditingController(text: initial?.baseUrl ?? '');
    _modelController = TextEditingController(text: initial?.model ?? '');
    _temperatureController = TextEditingController(
      text: (initial?.temperature ?? AiProviderProfile.defaultTemperature)
          .toString(),
    );
    _maxTokensController = TextEditingController(
      text: _maxTokensText(
        initial?.maxTokens ?? AiProviderProfile.defaultMaxTokens,
      ),
    );

    _reasoning = initial?.reasoning ?? false;
    _sendTemperature = initial?.sendTemperature ?? true;
    _streaming = initial?.streaming ?? true;
    _structuredOutput = initial?.structuredOutput ?? true;

    for (final c in [
      _nameController,
      _apiKeyController,
      _baseUrlController,
      _modelController,
      _temperatureController,
      _maxTokensController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  /// 输出上限输入框里该显示什么。0 ＝「不填这个参数」，对应**空输入框**——
  /// 印一个 `0` 出来会被当成「上限是零」，那是完全相反的意思。
  static String _maxTokensText(int value) => value > 0 ? value.toString() : '';

  void _selectPreset(AiProviderPreset preset) {
    // ⛔ 撞名时不要靠「再读一次 microsecondsSinceEpoch」来躲：同一微秒内重试
    // 拿到的是同一个数，那是一圈空转而不是重试。用递增后缀，一定能收敛。
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    var newId = stamp;
    var suffix = 1;
    while (widget.takenIds.contains(newId)) {
      newId = '${stamp}_${suffix++}';
    }
    final profile = preset.toProfile(id: newId);
    _id = profile.id;
    _kind = profile.kind;
    _presetId = profile.presetId;
    _nameController.text = profile.name;
    _baseUrlController.text = profile.baseUrl;
    _modelController.text = profile.model;
    _apiKeyController.text = profile.apiKey;
    _reasoning = profile.reasoning;
    _sendTemperature = profile.sendTemperature;
    _streaming = profile.streaming;
    _structuredOutput = profile.structuredOutput;
    _temperatureController.text = profile.temperature.toString();
    _maxTokensController.text = _maxTokensText(profile.maxTokens);
    setState(() {
      _isPickingPreset = false;
    });
  }

  AiProviderProfile _buildCurrentProfile() {
    final temp =
        double.tryParse(_temperatureController.text.trim()) ??
        AiProviderProfile.defaultTemperature;
    // 空着 / 填了个负数都归到 0 ＝「不发这个参数」。
    final parsedTokens = int.tryParse(_maxTokensController.text.trim()) ?? 0;
    final tokens = parsedTokens > 0 ? parsedTokens : 0;
    return AiProviderProfile(
      id: _id,
      name: _nameController.text.trim().isEmpty
          ? AiProviderKind.displayName(_kind)
          : _nameController.text.trim(),
      kind: _kind,
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      presetId: _presetId,
      apiKey: _apiKeyController.text.trim(),
      reasoning: _reasoning,
      sendTemperature: _sendTemperature,
      streaming: _streaming,
      structuredOutput: _structuredOutput,
      temperature: temp,
      maxTokens: tokens,
      headers: widget.initial?.headers ?? const {},
    );
  }

  /// 去服务端拉一张能用的模型列表，拉到就弹菜单让用户挑一条。
  ///
  /// ⛔ 失败时要把**真实原因**摆出来，不能一律说「模型列表为空」：密钥错、
  /// 地址少个 `/v1`、中转挂了，三件事的报错完全不同，而统一成「为空」之后
  /// 用户只会去怀疑模型名（2026-09-21 用户报障「需要加个获取模型列表的能力」
  /// ——能力一直在，只是它既看不见、失败了还不说人话）。落在表单里那块
  /// 就地结果区，和「测试」共用一处，不用 toast：toast 会飘走，而这条信息
  /// 用户多半要照着改半天。
  Future<void> _fetchModels(BuildContext anchorContext) async {
    if (_loadingModels) return;
    final t = slang.Translations.of(context);
    final profile = _buildCurrentProfile();
    setState(() {
      _loadingModels = true;
      _testSuccessMessage = null;
      _testErrorMessage = null;
    });
    final res = await Get.find<AiService>().listModels(profile);
    if (!mounted) return;
    setState(() => _loadingModels = false);

    if (!res.isSuccess) {
      setState(() {
        _testErrorMessage = res.message.isNotEmpty
            ? res.message
            : t.ai.modelEmpty;
      });
      return;
    }
    final models = res.data ?? const <String>[];
    if (models.isEmpty) {
      // 真的返回了空表：这条接口通了但这家不给列表（本地端点常见）。
      setState(() => _testErrorMessage = t.ai.modelEmpty);
      return;
    }

    if (!anchorContext.mounted) return;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        for (final m in models)
          GlassMenuOption<String>(
            value: m,
            label: m,
            selected: _modelController.text.trim() == m,
          ),
      ],
    );
    if (picked != null && mounted) {
      setState(() {
        _modelController.text = picked;
      });
    }
  }

  Future<void> _testConnection() async {
    final t = slang.Translations.of(context);
    setState(() {
      _testing = true;
      _testSuccessMessage = null;
      _testErrorMessage = null;
    });
    try {
      final profile = _buildCurrentProfile();
      final res = await Get.find<AiService>().test(profile);
      if (!mounted) return;
      final data = res.data;
      if (data != null && data.connectionValid) {
        setState(() {
          _testSuccessMessage = t.ai.testOk;
        });
      } else {
        final err = data?.custMessage ?? res.message;
        setState(() {
          _testErrorMessage = err.isNotEmpty ? err : 'Failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _testing = false;
        });
      }
    }
  }

  void _onConfirm() {
    final t = slang.Translations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppToast(t.ai.providerNameLabel, type: AppToastType.warning);
      return;
    }
    final profile = _buildCurrentProfile();
    Navigator.of(context).pop(profile);
  }

  /// 这一屏在做什么。看得见的标题走它，[GlassFloatingHeaderSheet.title] 退成
  /// 无障碍标签。
  String _stageTitle(slang.Translations t) {
    if (_isPickingPreset) return t.ai.pickPreset;
    return widget.initial == null ? t.ai.addProvider : widget.initial!.name;
  }

  /// 能不能退回「挑一个供应商」那屏。编辑既有档案时第一屏就是终点，没有上一步。
  bool get _canGoBack => widget.initial == null && !_isPickingPreset;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final title = _stageTitle(t);

    // ⛔ 版式走 [GlassFloatingHeaderSheet]：正文是一张滚动列表（第一屏是供应商
    // 列表，第二屏是表单），所以**标题行与底栏都浮在它之上**，内容从两者背后
    // 滚过去。「标题行占一格、列表占一格」的上下分家写法是收口前的老样式
    // （全站约定，参考 SignatureProviderWizard —— 那也是同样的两步流程）。
    return GlassFloatingHeaderSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      title: widget.initial == null ? t.ai.addProvider : widget.initial!.name,
      // 走 titleWidget 是为了换屏时标题有过渡，而不是硬切。
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
          _isPickingPreset ? Icons.auto_awesome : Icons.tune,
          key: ValueKey(_isPickingPreset),
          size: 20,
        ),
      ),
      // 挑供应商那屏没有底栏：点哪条就直接走了（同向导的第一屏）。
      footer: _isPickingPreset ? null : _buildFooter(context, t),
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
              // 两屏之间左右滑过去，不硬切——它读起来是一条路走下来的。
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
                child: _isPickingPreset
                    ? _buildPresetPicker(context, t)
                    : _buildEditorForm(context, t),
              ),
            ],
          ),
    );
  }

  /// 浮在内容之上的底栏：左边「上一步 / 测试」，右边「确定」。
  ///
  /// ⛔ 这里**没有「取消」**：标题行右端那枚玻璃圆钮就是取消，同向导。
  Widget _buildFooter(BuildContext context, slang.Translations t) {
    return Row(
      children: [
        GlassButtonGroup(
          touchFlexSignature: 'ai-provider|$_canGoBack|$_testing',
          children: [
            if (_canGoBack)
              GlassTextActionButton(
                label: t.common.back,
                onPressed: () => setState(() => _isPickingPreset = true),
              ),
            GlassTextActionButton(
              label: t.ai.test,
              loading: _testing,
              onPressed: _testConnection,
            ),
          ],
        ),
        const Spacer(),
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: t.common.confirm,
              emphasized: true,
              onPressed: _onConfirm,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetPicker(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;

    // 预置项一共就这几条，摊在外层那张 ListView 里即可——弹层的滚动控制器只能
    // 接一个可滚动组件（它同时是拖拽变高那条手势链路），里头再套一张会打架。
    return Column(
      key: const ValueKey('preset_picker'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final preset in kAiProviderPresets)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(
              preset.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle:
                (preset.baseUrl ??
                        AiProviderKind.defaultBaseUrlHint(preset.kind)) ==
                    null
                ? null
                : Text(
                    preset.baseUrl ??
                        AiProviderKind.defaultBaseUrlHint(preset.kind)!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _selectPreset(preset),
          ),
      ],
    );
  }

  Widget _buildEditorForm(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final needsKey = AiProviderKind.needsApiKey(_kind);
    final supportsBaseUrl = AiProviderKind.supportsCustomBaseUrl(_kind);
    final supportsThinking = AiProviderKind.supportsThinking(_kind);
    final supportsTemp = AiProviderKind.supportsTemperature(_kind);

    // ⛔ 这里**不画标题行、也不画底栏**：两者都浮在内容之上，由外面那只
    // [GlassFloatingHeaderSheet] 供（见 build）。表单从它们背后滚过去。
    return Column(
      key: const ValueKey('editor_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 名称
        Text(
          t.ai.providerNameLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        GlassInputSurface(
          child: TextField(
            controller: _nameController,
            decoration: glassFieldDecoration(
              context,
              hint: t.ai.providerNameLabel,
            ),
          ),
        ),
        // API 密钥
        if (needsKey) ...[
          const SizedBox(height: 12),
          Text(
            t.ai.apiKey,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          GlassInputSurface(
            child: TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: glassFieldDecoration(context, hint: t.ai.apiKey),
            ),
          ),
        ],
        // 端点地址
        if (supportsBaseUrl) ...[
          const SizedBox(height: 12),
          Text(
            t.ai.baseUrl,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          GlassInputSurface(
            child: TextField(
              controller: _baseUrlController,
              keyboardType: TextInputType.url,
              decoration: glassFieldDecoration(
                context,
                hint: AiProviderKind.defaultBaseUrlHint(_kind) ?? '',
              ),
            ),
          ),
        ],
        // 模型
        const SizedBox(height: 12),
        Text(
          t.ai.model,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GlassInputSurface(
                child: TextField(
                  controller: _modelController,
                  decoration: glassFieldDecoration(context, hint: t.ai.model),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ⛔ 这枚键吐的是一张玻璃菜单，所以必须声明 opensOverlay：
            // 组件没法预知 onPressed 会干什么，不声明就没有「长按也能
            // 打开、按住不抬手直接划到某一条松手选中」那条路（见
            // GlassTapArea.opensOverlay）。⚠️ 因此不能用
            // GlassAsyncIconButton —— 它没有这个参数，loading 自己管。
            Builder(
              builder: (anchorContext) => GlassIconButton(
                standalone: true,
                opensOverlay: true,
                loading: _loadingModels,
                icon: const Icon(Icons.refresh),
                tooltip: t.ai.modelPick,
                onPressed: () => _fetchModels(anchorContext),
              ),
            ),
          ],
        ),
        // 折叠的高级选项
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _advancedOpen = !_advancedOpen),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _advancedOpen ? 0.25 : 0,
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  t.ai.advanced,
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !_advancedOpen
              ? const SizedBox(width: double.infinity)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (supportsThinking)
                      GlassSwitchItem(
                        title: Text(t.ai.reasoning),
                        value: _reasoning,
                        onChanged: (v) => setState(() => _reasoning = v),
                      ),
                    GlassSwitchItem(
                      title: Text(t.ai.streaming),
                      value: _streaming,
                      onChanged: (v) => setState(() => _streaming = v),
                    ),
                    GlassSwitchItem(
                      title: Text(t.ai.structuredOutput),
                      subtitle: Text(t.ai.structuredOutputHint),
                      value: _structuredOutput,
                      onChanged: (v) => setState(() => _structuredOutput = v),
                    ),
                    if (supportsTemp && !_reasoning) ...[
                      const SizedBox(height: 8),
                      Text(
                        t.ai.temperature,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GlassInputSurface(
                        child: TextField(
                          controller: _temperatureController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: glassFieldDecoration(
                            context,
                            hint: AiProviderProfile.defaultTemperature
                                .toString(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      t.ai.maxTokens,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GlassInputSurface(
                      child: TextField(
                        controller: _maxTokensController,
                        keyboardType: TextInputType.number,
                        decoration: glassFieldDecoration(
                          context,
                          hint: t.ai.maxTokensAuto,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        // 就地测试结果
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _testSuccessMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _testSuccessMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : _testErrorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _testErrorMessage!,
                    style: TextStyle(fontSize: 12, color: cs.error),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
