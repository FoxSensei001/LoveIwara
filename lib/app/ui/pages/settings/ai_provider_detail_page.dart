import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/services/ai_profile_store.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/ai_token_format.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_endpoint_preview.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_model_editor.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_model_picker_dialog.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:url_launcher/url_launcher.dart';

/// 一家供应商的详情页：连接 / 模型 / 高级。
///
/// ⭐ 这一页的主题是**「哪些是我改过的」**。每一栏只要用户覆盖过目录的默认值，
/// 旁边就多一枚回转箭头可以「重置为默认」——delta 存储在界面上的样子。改造前
/// 一切都是快照，用户看不出自己覆盖了什么，我们也不敢更新任何默认值。
///
/// # 连接这一段是**草稿**，要按保存才落库
///
/// 上一版是「失焦即提交」：光标一离开输入框就写进配置。那条路有两个说不通的
/// 地方——改到一半切走（去复制密钥、去看文档）就被当成最终答案存下去；而用户
/// 根本没有「我还没改完」这个状态可用，想反悔只能凭记性把原值敲回来。
///
/// 所以连接与高级那几项现在全是页面自己持有的草稿（[_enabled] / [_streaming] /
/// [_structuredOutput] 与三只 controller），只有按下保存才走
/// [ConfigProfileStore.saveConfig] / [ConfigProfileStore.setApiKey]。脏的时候
/// 底部浮出一条保存栏，退出时由 [PopScope] 拦一道。
///
/// ⛔ **模型那一段不在草稿里**：加一条、删一条、从服务端勾一批，都是各自独立
/// 的动作，而且删模型要连带清掉指向它的用途绑定——把这些也攒进「保存」里，等于
/// 让用户按一下按钮同时提交几件互不相干的事，任何一件失败都说不清是哪件。
/// 测试与拉取用的是**草稿值**（见 [_probeModel]），所以「改了地址不保存也能先
/// 试一下」照旧成立。
class AiProviderDetailPage extends StatefulWidget {
  const AiProviderDetailPage({
    super.key,
    required this.providerId,
    this.isWideScreen = false,
  });

  final String providerId;
  final bool isWideScreen;

  @override
  State<AiProviderDetailPage> createState() => _AiProviderDetailPageState();
}

class _AiProviderDetailPageState extends State<AiProviderDetailPage> {
  final AiService _aiService = Get.find<AiService>();
  ConfigProfileStore get _store => _aiService.store as ConfigProfileStore;

  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;

  bool _obscureKey = true;
  bool _loadingModels = false;
  bool _saving = false;

  // ── 草稿：连接 / 高级那几项在按下保存之前只活在这里 ──────────────────
  bool _enabled = true;

  /// 流式开关的**界面值**。库里存的是 delta（`null` ＝ 跟随默认的 true），
  /// 界面上只有开 / 关两态，合成在 [_composeDraft] 里做。
  bool _streaming = true;
  bool? _structuredOutput;

  /// 就地结果区。⛔ 不用 toast：toast 会飘走，而这条信息用户多半要照着改半天。
  String? _noticeOk;
  String? _noticeError;

  AiProvider? get _provider => _store.config.providerById(widget.providerId);
  AiCatalogProvider? get _catalog =>
      AiCatalogService.providerOf(_provider?.catalogId ?? '');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
    _seedFromStore();
    _store.ensureReady().then((_) {
      if (!mounted) return;
      // ⛔ 整份重新播种，不只是补密钥：第一帧 store 可能连 provider 都还没读出来
      // （`_provider` 为 null），那时草稿是一份默认值，拿它去比「脏没脏」会把
      // 每一栏都算成用户改过的。
      setState(_seedFromStore);
    });
  }

  /// 把草稿重置成库里现在的样子。
  void _seedFromStore() {
    final p = _provider;
    _nameController.text = p?.name ?? '';
    _baseUrlController.text = p?.baseUrl ?? '';
    // 密钥是异步解密出来的，第一帧多半还没有。
    _apiKeyController.text = _store.keyOf(widget.providerId) ?? '';
    _enabled = p?.enabled ?? true;
    _streaming = p?.streaming ?? true;
    _structuredOutput = p?.structuredOutput;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ 草稿

  /// 名字那一栏的 delta 值。与目录同名就不留 delta——以后目录改名跟着走。
  String? get _nameDelta {
    final text = _nameController.text.trim();
    return text.isEmpty || text == _catalog?.name ? null : text;
  }

  String? get _baseUrlDelta {
    final text = _baseUrlController.text.trim();
    return text.isEmpty || text == (_catalog?.baseUrl ?? '') ? null : text;
  }

  String get _apiKeyDraft => _apiKeyController.text.trim();

  /// 把草稿合进 [base]，得到「保存下去会长什么样」的那份 provider。
  AiProvider _composeDraft(AiProvider base) {
    var next = base.copyWith(enabled: _enabled);
    next = _nameDelta == null
        ? next.copyWith(clearName: true)
        : next.copyWith(name: _nameDelta);
    next = _baseUrlDelta == null
        ? next.copyWith(clearBaseUrl: true)
        : next.copyWith(baseUrl: _baseUrlDelta);
    // 流式默认就是开，开着 ＝ 不留 delta。
    next = _streaming
        ? next.copyWith(clearStreaming: true)
        : next.copyWith(streaming: false);
    next = _structuredOutput == null
        ? next.copyWith(clearStructuredOutput: true)
        : next.copyWith(structuredOutput: _structuredOutput);
    return next;
  }

  /// 草稿与库里不一样吗？
  ///
  /// ⛔ 逐项比，不比整个对象：[AiProvider] 没有值相等，而 `headers` 这类本页
  /// 根本没有界面的字段是原样带过去的，拿它们参与比较只会恒真。
  bool get _dirty {
    final p = _provider;
    if (p == null) return false;
    return _nameDelta != p.name ||
        _baseUrlDelta != p.baseUrl ||
        _enabled != p.enabled ||
        _streaming != (p.streaming ?? true) ||
        _structuredOutput != p.structuredOutput ||
        _apiKeyDraft != (_store.keyOf(widget.providerId) ?? '');
  }

  /// 落库。密钥没动就不碰它——[ConfigProfileStore.setApiKey] 一次要跑一轮 AES。
  ///
  /// 返回是否真的存进去了。⛔ 失败必须能被调用方看见：「保存并离开」那条路要是
  /// 拿不到成败，写库炸了也照样把人送走，改动就这么没了。
  Future<bool> _save() async {
    final current = _provider;
    if (current == null || _saving) return false;
    setState(() {
      _saving = true;
      _noticeError = null;
    });
    try {
      final config = _store.config;
      await _store.saveConfig(
        AiProviderConfig(
          providers: config.providers
              .map((p) => p.id == current.id ? _composeDraft(p) : p)
              .toList(),
          models: config.models,
        ),
      );
      if (_apiKeyDraft != (_store.keyOf(widget.providerId) ?? '')) {
        await _store.setApiKey(widget.providerId, _apiKeyDraft);
      }
      // 保存栏跟着收走已经是信号了，但「保存并离开」那条路上人已经不在这一页，
      // 只有这一句能告诉他刚才那下算数了。
      if (mounted) {
        showAppToast(
          slang.Translations.of(context).ai.savedToast,
          type: AppToastType.success,
        );
      }
      return true;
    } catch (e) {
      if (mounted) setState(() => _noticeError = '$e');
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 退出这一页。
  ///
  /// ⛔ 必须**等一帧**再 pop。[PopScope.canPop] 是跟着 build 走的：刚把草稿抹平
  /// （或刚保存完）的那一刻它还是上一帧的 `false`，立刻 pop 会被自己那道闸重新
  /// 拦下来——表现是弹窗关了、页面纹丝不动，而用户明明已经选了「放弃」。
  void _leave() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppService.tryPop();
    });
  }

  // ------------------------------------------------------------------ 写回

  Future<void> _mutateModels(
    List<AiModel> Function(List<AiModel>) update,
  ) async {
    final config = _store.config;
    await _store.saveConfig(
      AiProviderConfig(
        providers: config.providers,
        models: update(List.of(config.models)),
      ),
    );
    if (mounted) setState(() {});
  }

  // ------------------------------------------------------------------ 动作

  /// 当前这一页上（**还没保存的**那几项也算）拿去发请求的那份配置。
  AiResolvedModel _probeModel({String modelId = ''}) {
    final p = _provider!;
    return resolveAiModel(
      provider: _composeDraft(p).copyWith(apiKey: _apiKeyDraft),
      model: AiModel(providerId: p.id, modelId: modelId),
      providerCatalog: _catalog,
      modelCatalog: AiCatalogService.modelOf(modelId),
    );
  }

  Future<void> _fetchModels() async {
    if (_loadingModels || _provider == null) return;
    final t = slang.Translations.of(context);
    setState(() {
      _loadingModels = true;
      _noticeOk = null;
      _noticeError = null;
    });
    final res = await _aiService.listModels(_probeModel());
    if (!mounted) return;
    setState(() => _loadingModels = false);

    if (!res.isSuccess) {
      // ⛔ 把**真实原因**摆出来，不能一律说「模型列表为空」：密钥错、地址少个
      // `/v1`、中转挂了，三件事的报错完全不同，而统一成「为空」之后用户只会去
      // 怀疑模型名。
      setState(
        () => _noticeError = res.message.isNotEmpty
            ? res.message
            : t.ai.modelEmpty,
      );
      return;
    }
    final fetched = res.data ?? const <String>[];
    if (fetched.isEmpty) {
      setState(() => _noticeError = t.ai.modelEmpty);
      return;
    }

    final existing = _store.config
        .modelsOf(widget.providerId)
        .map((e) => e.modelId)
        .toSet();
    // 端点这次没报上来、但用户手填过的那几条**不归这张弹窗管**：它们不在
    // available 里，弹窗也就不该替它们表态。每次回调都把它们原样并回去。
    final offList = existing.where((m) => !fetched.contains(m)).toSet();

    if (!mounted) return;
    await showAiModelPicker(
      context,
      available: fetched,
      selected: existing.where(fetched.contains).toSet(),
      // ⭐ 勾了就落，没有「确定」。
      onChanged: (picked) =>
          _enqueue(() => _applyModelSet({...offList, ...picked})),
    );
    if (mounted) setState(() {});
  }

  /// 模型集合的写入队列。
  ///
  /// ⛔ 不串起来会丢更新：每次勾选都是「读当前配置 → 改 → await 落库」，用户连点
  /// 五下时第二下多半在第一下写回来之前就把旧配置读走了。虽然弹窗每次给的都是
  /// **完整集合**、后一次能纠正前一次，但**最后那一次**被覆盖就没人纠正了。
  Future<void> _modelWrites = Future<void>.value();

  void _enqueue(Future<void> Function() task) {
    _modelWrites = _modelWrites.then((_) => task());
  }

  /// 把这家的模型集合整体换成 [next]，并清掉指向已删模型的用途绑定。
  Future<void> _applyModelSet(Set<String> next) async {
    final config = _store.config;
    final current = config.modelsOf(widget.providerId);
    final kept = current.where((m) => next.contains(m.modelId)).toList();
    final added = next
        .where((id) => !current.any((m) => m.modelId == id))
        .map((id) => AiModel(providerId: widget.providerId, modelId: id));
    await _mutateModels(
      (all) => [
        ...all.where((m) => m.providerId != widget.providerId),
        // ⛔ 保留**原来那几条的覆盖项**（温度 / maxTokens / 推理开关）：
        // 整份重建会把用户调过的东西一声不响地抹平。
        ...kept,
        ...added,
      ],
    );
    final removed = current
        .where((m) => !next.contains(m.modelId))
        .map((m) => m.key)
        .toSet();
    if (removed.isEmpty) return;
    final bindings = Map<AiTask, String>.from(_store.bindings)
      ..removeWhere((_, value) => removed.contains(value));
    await _store.saveBindings(bindings);
    if (mounted) setState(() {});
  }

  Future<void> _addModel(String modelId) => _mutateModels(
    (models) => [
      ...models,
      AiModel(providerId: widget.providerId, modelId: modelId),
    ],
  );

  Future<void> _removeModel(String modelId) async {
    await _mutateModels(
      (models) => models
          .where(
            (m) => !(m.providerId == widget.providerId && m.modelId == modelId),
          )
          .toList(),
    );
    // 指向它的用途绑定一并清掉，否则那几项会静默落回「自动」而界面上还写着它。
    final key = '${widget.providerId}/$modelId';
    final bindings = Map<AiTask, String>.from(_store.bindings)
      ..removeWhere((_, value) => value == key);
    await _store.saveBindings(bindings);
    if (mounted) setState(() {});
  }

  Future<void> _addModelManually() async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController();
    final result = await showAppDialog<String>(
      GlassAlertDialog(
        title: t.ai.addModel,
        content: GlassInputSurface(
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: glassFieldDecoration(context, hint: t.ai.model),
          ),
        ),
        actions: [
          GlassDialogAction.pop(label: t.common.cancel, emphasized: false),
          // ⛔ 这一条不能用 .pop()：要交出去的是**输入框此刻的内容**，而
          // `.pop(result:)` 的值是建弹窗那一刻就定死的。
          GlassDialogAction(
            label: t.common.confirm,
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    // ⛔ 等弹窗**整个退场动画走完**再 dispose：showAppDialog 的 future 在 pop
    // 那一刻就完成，controller 还在给退场中的那一帧用。
    Future.delayed(const Duration(milliseconds: 400), controller.dispose);
    if (result == null || result.isEmpty || !mounted) return;
    final taken = _store.config
        .modelsOf(widget.providerId)
        .any((m) => m.modelId == result);
    if (taken) return;
    await _addModel(result);
  }

  Future<void> _testModel(AiModel model) async {
    final t = slang.Translations.of(context);
    setState(() {
      _noticeOk = null;
      _noticeError = null;
    });
    final res = await _aiService.test(_probeModel(modelId: model.modelId));
    if (!mounted) return;
    final data = res.data;
    setState(() {
      if (data != null && data.connectionValid) {
        _noticeOk =
            '${model.modelId.isEmpty ? t.ai.serverDefaultModel : model.modelId}: ${t.ai.testOk}';
      } else {
        final err = data?.custMessage ?? res.message;
        _noticeError = err.isNotEmpty ? err : 'Failed';
      }
    });
  }

  Future<void> _deleteProvider() async {
    final t = slang.Translations.of(context);
    final provider = _provider;
    if (provider == null) return;
    final confirmed = await showAppDialog<bool>(
      GlassAlertDialog(
        title: provider.name ?? _catalog?.name ?? provider.id,
        content: Text(t.ai.deleteProviderConfirm),
        actions: [
          GlassDialogAction.pop(
            label: t.common.cancel,
            result: false,
            emphasized: false,
          ),
          GlassDialogAction.pop(
            label: t.common.delete,
            result: true,
            destructive: true,
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final config = _store.config;
    await _store.saveConfig(
      AiProviderConfig(
        providers: config.providers.where((p) => p.id != provider.id).toList(),
        models: config.models
            .where((m) => m.providerId != provider.id)
            .toList(),
      ),
    );
    final bindings = Map<AiTask, String>.from(_store.bindings)
      ..removeWhere((_, value) => value.startsWith('${provider.id}/'));
    await _store.saveBindings(bindings);
    // 走 [_leave]：这家已经不在了，草稿脏不脏都不该再被问一次「要保存吗」。
    _leave();
  }

  // ------------------------------------------------------------------ 界面

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    final provider = _provider;

    if (provider == null) {
      // 删掉之后路由还停在这条路径上（宽屏右栏尤其常见）。
      return GlassSettingsScaffold(
        title: t.ai.providers,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                t.ai.providerGone,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      );
    }

    final catalog = _catalog;
    // ⛔ kind / 能否自定义地址读的是**草稿**：名字与地址都能在没保存时就改，
    // 端点预览那一栏要跟着走，否则它展示的是一份用户已经看不见的旧配置。
    final draft = _composeDraft(provider);
    final kind = draft.kind ?? catalog?.kind ?? AiProviderKind.openai;
    final needsKey = catalog?.needsApiKey ?? AiProviderKind.needsApiKey(kind);
    final supportsBaseUrl = AiProviderKind.supportsCustomBaseUrl(kind);
    final models = _store.config.modelsOf(provider.id);
    final dirty = _dirty;

    return PopScope(
      // 脏着就别让它走：系统返回键、header 上那枚返回圆钮（AppService.tryPop →
      // maybePop）、窄屏的跟手侧滑，三条路都从这里过。
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !mounted) return;
        await _confirmLeave();
      },
      child: Stack(
        children: [
          _scaffold(
            t,
            cs,
            provider: provider,
            catalog: catalog,
            kind: kind,
            needsKey: needsKey,
            supportsBaseUrl: supportsBaseUrl,
            models: models,
            bottomInset: bottomInset,
            // 保存栏浮在列表之上，最后一块卡片要能滚到它上面来。
            extraBottomInset: dirty ? _saveBarReserve : 0,
          ),
          _SaveBar(
            visible: dirty,
            saving: _saving,
            bottomInset: bottomInset,
            onSave: _save,
            onDiscard: () => setState(_seedFromStore),
          ),
        ],
      ),
    );
  }

  /// 保存栏浮起来时，列表底下要多留的那一截。
  static const double _saveBarReserve = 72;

  /// 退出前那道闸：保存并离开 / 放弃修改 / 留下。
  Future<void> _confirmLeave() async {
    final t = slang.Translations.of(context);
    final choice = await showAppDialog<String>(
      GlassAlertDialog(
        title: t.ai.unsavedTitle,
        content: Text(t.ai.unsavedBody),
        actions: [
          GlassDialogAction.pop(label: t.common.cancel, emphasized: false),
          GlassDialogAction.pop(
            label: t.ai.discardChanges,
            result: 'discard',
            destructive: true,
          ),
          GlassDialogAction.pop(
            label: t.ai.saveAndLeave,
            result: 'save',
            emphasized: true,
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'save') {
      // 存不下去就留在这一页，错误已经落在就地结果区里。
      if (!await _save() || !mounted) return;
    } else {
      // 放弃：把草稿抹回库里的样子，PopScope 这才肯放行。
      setState(_seedFromStore);
    }
    _leave();
  }

  Widget _scaffold(
    slang.Translations t,
    ColorScheme cs, {
    required AiProvider provider,
    required AiCatalogProvider? catalog,
    required String kind,
    required bool needsKey,
    required bool supportsBaseUrl,
    required List<AiModel> models,
    required double bottomInset,
    required double extraBottomInset,
  }) {
    return GlassSettingsScaffold(
      title: provider.name ?? catalog?.name ?? provider.id,
      actions: [
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.delete_outline),
          tooltip: t.ai.deleteProvider,
          onPressed: _deleteProvider,
        ),
      ],
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + bottomInset + extraBottomInset,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── 连接 ──────────────────────────────────────────────────
              GlassSettingSection(
                title: t.ai.connection,
                children: [
                  GlassSwitchItem(
                    title: Text(t.ai.providerEnabled),
                    subtitle: Text(t.ai.providerEnabledHint),
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  _field(
                    label: t.ai.providerNameLabel,
                    controller: _nameController,
                    hint: catalog?.name ?? provider.id,
                    // 名字与目录不同 ＝ 用户改过，给一枚重置。
                    onReset: _nameDelta == null
                        ? null
                        : () => setState(
                            () => _nameController.text = catalog?.name ?? '',
                          ),
                  ),
                  if (needsKey)
                    _field(
                      label: t.ai.apiKey,
                      controller: _apiKeyController,
                      hint: t.ai.apiKey,
                      obscure: _obscureKey,
                      trailing: [
                        GlassIconButton(
                          standalone: true,
                          icon: Icon(
                            _obscureKey
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          tooltip: _obscureKey ? t.ai.revealKey : t.ai.hideKey,
                          onPressed: () =>
                              setState(() => _obscureKey = !_obscureKey),
                        ),
                        if (_apiKeyController.text.trim().isNotEmpty)
                          GlassIconButton(
                            standalone: true,
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: t.common.copy,
                            onPressed: () => Clipboard.setData(
                              ClipboardData(
                                text: _apiKeyController.text.trim(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (supportsBaseUrl)
                    _field(
                      label: t.ai.baseUrl,
                      controller: _baseUrlController,
                      hint: catalog?.baseUrl ?? '',
                      keyboardType: TextInputType.url,
                      monospace: true,
                      onReset: _baseUrlDelta == null
                          ? null
                          : () => setState(
                              () => _baseUrlController.text =
                                  catalog?.baseUrl ?? '',
                            ),
                      // ⭐ 实时告诉用户「这份配置最终会打到哪个地址」。
                      // 「少一个 /v1 就 404」是这个模块最常见、也最难自查的
                      // 配置错误——用户只会以为是网络问题。
                      footer: AiEndpointPreview(
                        kind: kind,
                        baseUrl: _baseUrlController.text.trim().isEmpty
                            ? (catalog?.baseUrl ?? '')
                            : _baseUrlController.text.trim(),
                      ),
                    ),
                  if (catalog?.apiKeyUrl != null)
                    GlassSettingTile(
                      icon: Icons.vpn_key_outlined,
                      title: Text(t.ai.getApiKey),
                      subtitle: Text(
                        catalog!.apiKeyUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _open(catalog.apiKeyUrl!),
                    ),
                  if (catalog?.docsUrl != null)
                    GlassSettingTile(
                      icon: Icons.menu_book_outlined,
                      title: Text(t.ai.providerDocs),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => _open(catalog!.docsUrl!),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── 模型 ──────────────────────────────────────────────────
              GlassSettingSection(
                title: t.ai.models,
                children: [
                  if (models.isEmpty)
                    GlassSettingTile(
                      title: Text(
                        t.ai.noModelsHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final model in models)
                      _ModelRow(
                        key: ValueKey(model.key),
                        model: model,
                        onTest: () => _testModel(model),
                        onEdit: () async {
                          final edited = await showAiModelEditor(
                            context,
                            model: model,
                            providerKind: kind,
                          );
                          if (edited == null || !mounted) return;
                          await _mutateModels(
                            (all) => all
                                .map((m) => m.key == model.key ? edited : m)
                                .toList(),
                          );
                        },
                        onDelete: () => _removeModel(model.modelId),
                      ),
                  GlassSettingTile(
                    icon: Icons.cloud_download_outlined,
                    title: Text(t.ai.fetchModels),
                    subtitle: Text(
                      t.ai.fetchModelsHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: _loadingModels
                        ? const GlassTileSpinner()
                        : const Icon(Icons.chevron_right, size: 20),
                    onTap: _fetchModels,
                  ),
                  GlassSettingTile(
                    icon: Icons.edit_outlined,
                    title: Text(t.ai.addModel),
                    onTap: _addModelManually,
                  ),
                ],
              ),

              // 就地结果区（拉模型 / 测试共用）
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _noticeOk == null && _noticeError == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 12, left: 4),
                        child: Text(
                          _noticeError ?? _noticeOk!,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: _noticeError != null
                                ? cs.error
                                : Colors.green,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // ── 高级 ──────────────────────────────────────────────────
              GlassSettingSection(
                title: t.ai.advanced,
                children: [
                  GlassSwitchItem(
                    title: Text(t.ai.streaming),
                    value: _streaming,
                    onChanged: (v) => setState(() => _streaming = v),
                  ),
                  GlassSettingTile(
                    title: Text(t.ai.structuredOutput),
                    subtitle: Text(
                      t.ai.structuredOutputHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: _TriStateField(
                      value: _structuredOutput,
                      inherited: catalog?.structuredOutput,
                      onChanged: (v) => setState(() => _structuredOutput = v),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        showAppToast(
          slang.Translations.of(
            context,
          ).errors.errorWhileOpeningLink(link: url),
          type: AppToastType.error,
        );
      }
    }
  }

  /// 一栏带标签的输入框。[onReset] 非空时右边多一枚回转箭头＝「这一项我改过」。
  ///
  /// 内容只改草稿（每敲一下重建一次，好让保存栏与重置箭头跟着变），落库归
  /// [_save]。
  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    VoidCallback? onReset,
    List<Widget> trailing = const [],
    bool obscure = false,
    bool monospace = false,
    TextInputType? keyboardType,
    Widget? footer,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (onReset != null)
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.settings_backup_restore, size: 18),
                  tooltip: slang.Translations.of(context).ai.resetToDefault,
                  onPressed: onReset,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: GlassInputSurface(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboardType,
                    onChanged: (_) => setState(() {}),
                    style: monospace
                        ? const TextStyle(fontFamily: 'monospace')
                        : null,
                    decoration: glassFieldDecoration(context, hint: hint),
                  ),
                ),
              ),
              for (final widget in trailing) ...[
                const SizedBox(width: 6),
                widget,
              ],
            ],
          ),
          if (footer != null) ...[const SizedBox(height: 6), footer],
        ],
      ),
    );
  }
}

/// 脏的时候从底部浮上来的保存栏：「有未保存的修改」+ 放弃 / 保存。
///
/// ⛔ 出入场都要有动画（位移 + 缩放 + 材质淡入），硬切一个 `SizedBox.shrink()`
/// 不行；退场比入场干脆一点，走完才整只卸载——materialize 归 0 ≠ 不在场，留在
/// 树上的话它照样吃点击。配方与 `GlassSelectionDock` 同一套。
class _SaveBar extends StatefulWidget {
  const _SaveBar({
    required this.visible,
    required this.saving,
    required this.bottomInset,
    required this.onSave,
    required this.onDiscard,
  });

  final bool visible;
  final bool saving;
  final double bottomInset;
  final Future<void> Function() onSave;
  final VoidCallback onDiscard;

  @override
  State<_SaveBar> createState() => _SaveBarState();
}

class _SaveBarState extends State<_SaveBar>
    with SingleTickerProviderStateMixin {
  static const Duration _exitDuration = Duration(milliseconds: 160);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlassTokens.motionDuration,
    reverseDuration: _exitDuration,
    value: widget.visible ? 1 : 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final show = widget.visible;

    final status = _controller.status;
    if (show) {
      if (status != AnimationStatus.completed &&
          status != AnimationStatus.forward) {
        _controller.forward();
      }
    } else if (status != AnimationStatus.dismissed &&
        status != AnimationStatus.reverse) {
      _controller.reverse();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottomInset + 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isDismissed && !show) return const SizedBox.shrink();
          final double v = show
              ? GlassTokens.motionCurve.transform(_controller.value)
              : Curves.easeInCubic.transform(_controller.value);
          return IgnorePointer(
            ignoring: !show,
            child: Transform.translate(
              offset: Offset(0, (1 - v) * 16),
              child: Transform.scale(
                scale: 0.92 + 0.08 * v,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: GlassSurface(
                      materialize: v,
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              t.ai.unsavedBadge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassTextActionButton(
                            label: t.ai.discardChanges,
                            onPressed: widget.saving ? null : widget.onDiscard,
                          ),
                          GlassTextActionButton(
                            label: t.common.save,
                            emphasized: true,
                            loading: widget.saving,
                            onPressed: () => widget.onSave(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 模型列表里的一行：名字 + 能力小标 + 测试 / 删除。
class _ModelRow extends StatelessWidget {
  const _ModelRow({
    super.key,
    required this.model,
    required this.onTest,
    required this.onEdit,
    required this.onDelete,
  });

  final AiModel model;
  final Future<void> Function() onTest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final catalog = AiCatalogService.modelOf(model.modelId);
    final title = model.name ?? catalog?.name ?? model.modelId;

    return GlassSettingTile(
      title: Text(
        title.isEmpty ? t.ai.serverDefaultModel : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.modelId.isNotEmpty && title != model.modelId)
            Text(
              model.modelId,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: cs.primary,
              ),
            ),
          const SizedBox(height: 4),
          // ⛔ 目录查不到这个模型时**一个标都不画**，而不是画一排「不支持」：
          // 中转上几百个模型目录多半没有，画成「不支持」是在撒谎。
          if (catalog == null)
            Text(
              t.ai.modelUnknown,
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final cap in catalog.capabilities)
                  _CapChip(label: _capLabel(t, cap)),
                if (catalog.contextWindow != null)
                  _CapChip(
                    label: t.ai.contextWindow(
                      tokens: formatTokenCount(catalog.contextWindow!),
                    ),
                  ),
              ],
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassAsyncIconButton(
            standalone: true,
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: t.ai.test,
            onPressed: onTest,
          ),
          GlassIconButton(
            standalone: true,
            icon: const Icon(Icons.delete_outline),
            tooltip: t.ai.deleteModel,
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }

  static String _capLabel(slang.Translations t, AiModelCapability cap) =>
      switch (cap) {
        AiModelCapability.functionCall => t.ai.capFunctionCall,
        AiModelCapability.reasoning => t.ai.capReasoning,
        AiModelCapability.structuredOutput => t.ai.capStructuredOutput,
        AiModelCapability.vision => t.ai.capVision,
        AiModelCapability.fileInput => t.ai.capFileInput,
      };
}

class _CapChip extends StatelessWidget {
  const _CapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
      ),
    );
  }
}

/// 三态选择器：跟随目录 / 强制开 / 强制关。
///
/// ⭐ 必须是三态而不是两态：「还不知道这家认不认 json_schema」与「已知不认」
/// 是两件不同的事——前者该让向导去探，后者该直接走降级路。两态表达不出来。
///
/// ⛔ 走 [GlassDropdownField] 而不是自己拿个文字钮弹菜单：表单里的下拉全站收口
/// 到它（`test/glass_style_guard_test.dart` 盯着「开菜单的钮都声明了
/// opensOverlay」这条，而文字动作钮没有那个参数）。
class _TriStateField extends StatelessWidget {
  const _TriStateField({
    required this.value,
    required this.inherited,
    required this.onChanged,
  });

  /// 用户的覆盖。null ＝ 跟随目录。
  final bool? value;

  /// 目录说的。null ＝ 目录也不知道。
  final bool? inherited;

  final ValueChanged<bool?> onChanged;

  static const String _auto = '__auto__';
  static const String _on = '__on__';
  static const String _off = '__off__';

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 「跟随」这一项要说清**跟下来的是什么**，否则用户看到「自动」只会去猜。
    final autoLabel = switch (inherited) {
      true => t.ai.triAutoOn,
      false => t.ai.triAutoOff,
      null => t.ai.triAutoUnknown,
    };
    return GlassDropdownField<String>(
      shrinkWrap: true,
      value: switch (value) {
        true => _on,
        false => _off,
        null => _auto,
      },
      items: [
        GlassDropdownItem<String>(value: _auto, label: autoLabel),
        GlassDropdownItem<String>(value: _on, label: t.ai.triOn),
        GlassDropdownItem<String>(value: _off, label: t.ai.triOff),
      ],
      onChanged: (picked) => onChanged(switch (picked) {
        _on => true,
        _off => false,
        _ => null,
      }),
    );
  }
}
