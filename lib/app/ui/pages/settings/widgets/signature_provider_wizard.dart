import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/signature_preset.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_variable_picker.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/comment_structure_widgets.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 接数据源的向导。完成返回 [SignatureProvider]，中途退出返回 null。
///
/// ## 两条路，长度差很多
///
/// **现成的**（绝大多数人走这条）：挑一个名字 → 看一眼它会给什么 → 完成。
/// 口味、长度、要不要带出处都是摆在眼前的选项，一个字都不用打。
///
/// **自己的接口**：地址 → 从真实返回里挑一段 → 起名。这条路保留原样，因为
/// 「取值路径」没法凭空想象——它要求用户先知道那个接口返回什么形状的 JSON。
/// 所以先请求、再让他照着值点一条，路径由我们在背后记。
///
/// ⛔ 第一步不是空白输入框。用户想要的通常只是「一句随机的话」，让他从
/// 「去哪儿找一个接口」开始是把我们的实现细节当成了他的任务。
///
/// ⛔ 版式走 [GlassFloatingHeaderSheet]：正文是一张滚动列表，所以**标题行与
/// 底栏都浮在它之上**，列表从两者背后滚过去（全站约定，同评论列表弹层）。
/// 步骤点摆在底栏左端——它得一直看得见，跟着列表滚走就没意义了。
Future<SignatureProvider?> showSignatureProviderWizard(
  BuildContext context, {
  SignatureProvider? initial,
  required Set<String> takenIds,
}) {
  return showGlassDraggableBottomSheet<SignatureProvider>(
    context: context,
    builder: (context) =>
        SignatureProviderWizard(initial: initial, takenIds: takenIds),
  );
}

/// 向导走到哪一屏。
enum _Stage {
  /// 挑一个现成的，或者声明「我自己填地址」。
  choose,

  /// 现成源的调节屏：选项 + 样例。
  tune,

  /// 自定义：填地址。
  url,

  /// 自定义：从真实返回里挑一段。
  pick,

  /// 自定义：起名。
  name,
}

class SignatureProviderWizard extends StatefulWidget {
  const SignatureProviderWizard({
    super.key,
    this.initial,
    required this.takenIds,
  });

  final SignatureProvider? initial;
  final Set<String> takenIds;

  @override
  State<SignatureProviderWizard> createState() =>
      _SignatureProviderWizardState();
}

class _SignatureProviderWizardState extends State<SignatureProviderWizard> {
  final SignatureService _service = Get.find<SignatureService>();

  late final TextEditingController _urlController;
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  late final TextEditingController _extractController;

  late _Stage _stage;

  bool _fetching = false;
  String? _fetchError;

  // ----------------------------------------------------------- 现成源那一支

  SignaturePreset? _preset;

  /// 选项当前的取值（直接就是要拼到地址上的查询参数）。
  Map<String, List<String>> _params = const {};

  /// 带不带出处。默认不带——小尾巴本来就该短。
  bool _withSuffix = false;

  /// 调节屏上那份真实返回。换选项要重新请求，换出处开关不用。
  String? _body;

  /// 那份返回按当前配置算出来的样例（含翻译）。算它要走异步，所以存成状态，
  /// 不在 build 里现算。
  String? _sample;

  // ----------------------------------------------------------- 自定义那一支

  List<SignatureValueCandidate> _candidates = const [];
  String? _pickedPath;
  String? _pickedValue;

  /// 接在正文后面的那一段（出处 / 作者），null＝不接。
  String? _suffixPath;

  /// 路径里的下标换成 `*`：每次随机取一条，而不是永远第 0 条。
  bool _randomPick = false;

  bool _stripHtml = true;
  bool _advancedOpen = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _urlController = TextEditingController(text: initial?.url ?? '');
    _nameController = TextEditingController(text: initial?.name ?? '');
    _idController = TextEditingController(text: initial?.id ?? '');
    _extractController = TextEditingController(text: initial?.extract ?? '');
    _pickedPath = initial?.path;
    _stripHtml = initial?.stripHtml ?? true;
    _suffixPath = (initial?.suffixPath.isNotEmpty ?? false)
        ? initial!.suffixPath
        : null;
    _randomPick = initial?.path.contains('*') ?? false;

    // 编辑一条现成源：直接落在它的调节屏上，不用重走一遍挑选。
    final preset = initial == null
        ? null
        : SignaturePreset.byId(initial.presetId);
    if (preset != null) {
      _preset = preset;
      _params = Map.of(initial!.params);
      _withSuffix = initial.suffixPath.isNotEmpty;
      _stage = _Stage.tune;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSample());
    } else {
      _stage = initial == null ? _Stage.choose : _Stage.url;
    }

    for (final c in [
      _urlController,
      _nameController,
      _idController,
      _extractController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    // ⛔ 在 State.dispose 里收：sheet 的 future 在 pop 那一刻就完成了，弹层还要
    // 播退场动画，提前 dispose 会撞上「used after being disposed」。
    _urlController.dispose();
    _nameController.dispose();
    _idController.dispose();
    _extractController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ 组装数据源

  /// 当前这套配置构成的数据源。样例、预览、最终返回全走它，不会两边各写一遍。
  SignatureProvider _compose({String id = '_preview'}) {
    final preset = _preset;
    if (preset != null) {
      return preset.toProvider(
        id: id,
        params: _params,
        withSuffix: _withSuffix,
      );
    }
    return SignatureProvider(
      id: id,
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      path: _effectivePath,
      stripHtml: _stripHtml,
      extract: _extractController.text,
      suffixPath: _suffixPath ?? '',
    );
  }

  /// 自定义源最终用的取值路径：挑中的那条，按需把下标换成随机。
  String get _effectivePath {
    final picked = _pickedPath ?? '';
    return _randomPick ? randomizePath(picked) : picked;
  }

  // --------------------------------------------------------- 现成源：调节屏

  void _choosePreset(SignaturePreset preset) {
    setState(() {
      _preset = preset;
      _params = preset.defaultParams;
      _withSuffix = false;
      _body = null;
      _sample = null;
      _fetchError = null;
      _stage = _Stage.tune;
    });
    _loadSample();
  }

  /// 样例：取一份真实返回 → 按当前配置拼 →（开关开着的话）翻成界面语言。
  ///
  /// ⭐ 走的是 `resolveValue`，和真发送、和设置页那枚测试钮**同一条路**。样例
  /// 里是中文、发出去却是英文（或反过来）是最不该出现的那类问题。
  ///
  /// [refetch] 为 false 时复用手上那份返回：换「带上出处」只是换一种拼法，
  /// 不必再打一次接口；换选项则是换地址，必须重取。
  Future<void> _loadSample({bool refetch = true}) async {
    setState(() {
      _fetching = true;
      _fetchError = null;
    });
    try {
      if (refetch || _body == null) {
        final body = await _service.fetchBody(_compose());
        if (!mounted) return;
        _body = body.isEmpty ? null : body;
      }
      final body = _body;
      final sample = body == null
          ? null
          : await _service.resolveValue(_compose(), body: body);
      if (!mounted) return;
      setState(() => _sample = sample);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchError = e.toString();
        _sample = null;
      });
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  void _setOption(SignaturePresetOption option, SignaturePresetChoice choice) {
    setState(() {
      final next = Map<String, List<String>>.of(_params);
      if (choice.values.isEmpty) {
        next.remove(option.key);
      } else {
        next[option.key] = choice.values;
      }
      _params = next;
    });
    _loadSample();
  }

  /// 现成源的引用名：就用预置的那个；被占了就往后排。编辑时保持原样，
  /// 否则模板里写好的 `{hitokoto}` 会在改个口味之后指空。
  String get _presetId {
    final preset = _preset!;
    final initial = widget.initial;
    if (initial != null && initial.presetId == preset.id) return initial.id;

    var id = preset.id;
    var n = 2;
    while (widget.takenIds.contains(id)) {
      id = '${preset.id}_$n';
      n++;
    }
    return id;
  }

  // ------------------------------------------------------- 自定义：第一步

  Future<void> _fetchAndAdvance() async {
    setState(() {
      _fetching = true;
      _fetchError = null;
    });
    try {
      final body = await _service.fetchRaw(_urlController.text);
      final candidates = flattenResponseCandidates(body);
      if (!mounted) return;
      if (candidates.isEmpty) {
        setState(
          () => _fetchError = slang.t.settings.signatureSourceTestFailed,
        );
        return;
      }
      setState(() {
        _candidates = candidates;
        // 编辑既有源时，把它原本选的那条重新勾上（路径还在的话）。
        final keep = _pickedPath;
        final match = candidates.firstWhereOrNull(
          (e) => e.path == keep || randomizePath(e.path) == keep,
        );
        _pickedPath =
            match?.path ??
            (candidates.length == 1 ? candidates.first.path : null);
        _pickedValue =
            match?.value ??
            (candidates.length == 1 ? candidates.first.value : null);
        _stage = _Stage.pick;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _fetchError = e.toString());
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  /// 挑中那条经过加工之后的样子——用户在向导里看到的、最终发出去的，都是它。
  String? get _shapedValue {
    final raw = _pickedValue;
    if (raw == null) return null;
    final shaped = _compose().applyTransform(raw);
    return shaped.isEmpty ? null : shaped;
  }

  /// 正文 + 出处拼完的样子（自定义源的挑选屏上用）。
  String? get _joinedValue {
    final main = _shapedValue;
    if (main == null) return null;
    final suffixPath = _suffixPath;
    if (suffixPath == null) return main;
    final candidate = _candidates.firstWhereOrNull((e) => e.path == suffixPath);
    if (candidate == null) return main;
    final suffix = _compose().applyTransform(
      candidate.value,
      applyExtract: false,
    );
    if (suffix.isEmpty || main.contains(suffix)) return main;
    return '$main${SignatureProvider.valueJoiner}$suffix';
  }

  /// 接口这会儿正好不通、但用户只是想改个名字时的出口。
  void _skipFetch() {
    setState(() {
      _candidates = const [];
      _stage = _Stage.name;
    });
  }

  // ------------------------------------------------------- 自定义：第三步

  /// 引用名：用户自己填的优先，其次从名称推，再不行从地址猜。
  ///
  /// ⛔ 三级回退缺一不可。只按名称推的话，一个叫「天气」的源会推出空串
  /// （`normalizeId` 只留 ASCII），中文用户得到的就是一句「引用名只能用小写
  /// 字母」——而他压根不知道该填什么。
  String get _effectiveId {
    final typed = SignatureProvider.normalizeId(_idController.text);
    if (typed.isNotEmpty) return typed;

    final fromName = SignatureProvider.normalizeId(_nameController.text);
    if (fromName.isNotEmpty) return fromName;

    return SignatureProvider.suggestIdFromUrl(_urlController.text);
  }

  String? get _idError {
    final t = slang.t;
    final id = _effectiveId;
    if (id.isEmpty) return t.settings.signatureSourceIdInvalid;
    if (SignatureService.builtinVariableNames.contains(id)) {
      return t.settings.signatureSourceIdReserved;
    }
    if (widget.takenIds.contains(id)) {
      return t.settings.signatureSourceIdDuplicate;
    }
    return null;
  }

  void _finishCustom() {
    if (_idError != null) return;
    Navigator.of(context).pop(_compose(id: _effectiveId));
  }

  void _finishPreset() => Navigator.of(context).pop(_compose(id: _presetId));

  // -------------------------------------------------------------------- 版式

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassFloatingHeaderSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      // 标题给的是这一屏在做什么（「挑一个」/ 源的名字 / 「起个名字」），
      // 走 titleWidget 是为了换屏时有过渡；[title] 退成无障碍标签。
      title: widget.initial == null
          ? t.settings.signatureWizardTitle
          : t.settings.signatureEditSource,
      titleWidget: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        child: Text(
          _stepTitle(t),
          key: ValueKey(_stepTitle(t)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      leading: const Icon(Icons.link, size: 20),
      footer: _buildFooter(context, t),
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
              // 屏与屏之间左右滑过去，不是硬切——它读起来是一条路走下来的。
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: switch (_stage) {
                  _Stage.choose => _chooseStep(context, t),
                  _Stage.tune => _tuneStep(context, t),
                  _Stage.url => _urlStep(context, t),
                  _Stage.pick => _pickStep(context, t),
                  _Stage.name => _nameStep(context, t),
                },
              ),
            ],
          ),
    );
  }

  /// 这一屏的标题。摆在浮起的标题行里，所以正文里不再重复写一遍。
  String _stepTitle(slang.Translations t) => switch (_stage) {
    _Stage.choose => t.settings.signatureWizardChooseTitle,
    // 调节屏的标题就是这个源自己的名字（品牌名，不翻译）。
    _Stage.tune => _preset?.name ?? t.settings.signatureWizardTitle,
    _Stage.url => t.settings.signatureWizardUrlTitle,
    _Stage.pick => t.settings.signatureWizardPickTitle,
    _Stage.name => t.settings.signatureWizardNameTitle,
  };

  int get _dotTotal => _preset != null ? 2 : 4;

  int get _dotIndex => switch (_stage) {
    _Stage.choose => 0,
    _Stage.tune => 1,
    _Stage.url => 1,
    _Stage.pick => 2,
    _Stage.name => 3,
  };

  /// 一屏的正文：一句说明 + 控件。**标题不在这儿**——它在浮起的标题行里，
  /// 正文里再写一遍就是两层标题叠着。
  Widget _stepBody({
    required Key key,
    required String hint,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hint,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }

  // ------------------------------------------------------------------ 挑一个

  Widget _chooseStep(BuildContext context, slang.Translations t) {
    return _stepBody(
      key: const ValueKey('choose'),
      hint: t.settings.signatureWizardChooseHint,
      children: [
        for (final preset in SignaturePreset.all)
          _ChoiceTile(
            title: preset.name,
            // 副标题是域名：不翻译、不用维护，而且是用户唯一需要的事实。
            subtitle: Uri.tryParse(preset.url)?.host ?? preset.url,
            icon: Icons.format_quote,
            onTap: () => _choosePreset(preset),
          ),
        const SizedBox(height: 4),
        _ChoiceTile(
          title: t.settings.signatureWizardCustomSource,
          subtitle: t.settings.signatureSourceUrl,
          icon: Icons.link,
          onTap: () => setState(() => _stage = _Stage.url),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ 现成源调节屏

  Widget _tuneStep(BuildContext context, slang.Translations t) {
    final preset = _preset!;
    final cs = Theme.of(context).colorScheme;

    return _stepBody(
      key: ValueKey('tune-${preset.id}'),
      // 说明行就是它的域名：不翻译、不用维护，也是用户唯一需要的事实。
      hint: Uri.tryParse(preset.url)?.host ?? preset.url,
      children: [
        for (final option in preset.options) ...[
          Text(
            SignatureVariableLabels.optionLabel(t, option.labelKey),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final choice in option.choices)
                ChoiceChip(
                  label: Text(
                    SignatureVariableLabels.optionLabel(t, choice.labelKey),
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: option.choiceFor(_params) == choice,
                  onSelected: (_) => _setOption(option, choice),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (preset.suffixPath.isNotEmpty)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              t.settings.signatureWizardWithOrigin,
              style: const TextStyle(fontSize: 13),
            ),
            value: _withSuffix,
            onChanged: (v) {
              setState(() => _withSuffix = v);
              // 拼法变了，样例要跟着变；但接口不用再打一次。
              _loadSample(refetch: false);
            },
          ),
        const SizedBox(height: 8),
        _sampleBlock(context, t),
      ],
    );
  }

  /// 「它会给我什么」——这一块是调节屏存在的理由，每改一个选项它都当场变。
  Widget _sampleBlock(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final value = _sample;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t.settings.signaturePreview,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            GlassAsyncIconButton(
              icon: const Icon(Icons.refresh),
              tooltip: t.common.refresh,
              standalone: true,
              onPressed: _loadSample,
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: _fetchError != null
                  ? cs.errorContainer.withValues(alpha: 0.5)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _fetching && value == null
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _fetchError != null
                ? Text(
                    _fetchError!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: cs.onErrorContainer,
                    ),
                  )
                : CommentStructurePreview(
                    body: t.settings.signatureSampleBody,
                    signature: value ?? '',
                  ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- 自定义地址

  Widget _urlStep(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    return _stepBody(
      key: const ValueKey('url'),
      hint: t.settings.signatureWizardUrlHint,
      children: [
        GlassInputSurface(
          child: TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autofocus: widget.initial == null,
            decoration: glassFieldDecoration(
              context,
              hint: 'https://v1.hitokoto.cn/',
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _fetchError == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _fetchError!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: cs.onErrorContainer,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _pickStep(BuildContext context, slang.Translations t) {
    return _stepBody(
      key: const ValueKey('pick'),
      hint: _candidates.length == 1 && _candidates.first.path.isEmpty
          ? t.settings.signatureWizardPickPlainHint
          : t.settings.signatureWizardPickHint,
      children: [
        for (final candidate in _candidates)
          _CandidateTile(
            candidate: candidate,
            // 卡片上显示的就是**加工后**的样子：用户挑的是「小尾巴里会出现
            // 什么」，不是「接口原样返回了什么」。
            shownValue: _compose().applyTransform(candidate.value),
            selected: _pickedPath == candidate.path,
            wholeBodyLabel: t.settings.signatureWizardWholeBody,
            onTap: () => setState(() {
              _pickedPath = candidate.path;
              _pickedValue = candidate.value;
              if (_suffixPath == candidate.path) _suffixPath = null;
            }),
          ),
        if (_pickedValue != null) _transformBlock(context, t),
      ],
    );
  }

  /// 加工区：紧跟在选中的那条下面——它加工的就是刚选中的值，挨着才看得懂。
  ///
  /// 默认路径上用户什么都不用做（剥标签本来就开着，卡片上已经是干净的）；
  /// 只有需要再修一刀的人才会去展开「高级」。
  Widget _transformBlock(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final raw = _pickedValue ?? '';
    final hasHtml = stripHtmlFrom(raw) != raw.trim();
    final extract = _extractController.text.trim();
    final shaped = _joinedValue;
    final extractMissed =
        extract.isNotEmpty &&
        _shapedValue != null &&
        _shapedValue == _strippedOnly(raw);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标签开关只在真有标签时出现：没有标签的接口上它是一句废话。
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !hasHtml
                ? const SizedBox(width: double.infinity)
                : SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    title: Text(
                      t.settings.signatureWizardStripHtml,
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: _stripHtml,
                    onChanged: (v) => setState(() => _stripHtml = v),
                  ),
          ),
          // 同理：只有返回里确实有一排平行的条目时，「随机取一条」才说得通。
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_randomizable
                ? const SizedBox(width: double.infinity)
                : SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    title: Text(
                      t.settings.signatureWizardRandomItem,
                      style: const TextStyle(fontSize: 13),
                    ),
                    value: _randomPick,
                    onChanged: (v) => setState(() => _randomPick = v),
                  ),
          ),
          // 高级：正则提取 + 接一段出处。折叠着，因为绝大多数接口到上面两行
          // 就已经够用了。
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
                    t.settings.signatureWizardAdvanced,
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
                      GlassInputSurface(
                        child: TextField(
                          controller: _extractController,
                          decoration: glassFieldDecoration(
                            context,
                            hint: t.settings.signatureWizardExtractHint,
                          ),
                        ),
                      ),
                      if (extractMissed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                          child: Text(
                            t.settings.signatureWizardExtractMissed,
                            style: TextStyle(fontSize: 11, color: cs.error),
                          ),
                        ),
                      if (_suffixCandidates.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          t.settings.signatureWizardSuffixTitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            ChoiceChip(
                              label: Text(
                                t.settings.signatureWizardSuffixNone,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _suffixPath == null,
                              onSelected: (_) =>
                                  setState(() => _suffixPath = null),
                            ),
                            for (final candidate in _suffixCandidates)
                              ChoiceChip(
                                label: Text(
                                  _shortLabel(candidate.value),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: _suffixPath == candidate.path,
                                onSelected: (_) => setState(
                                  () => _suffixPath = candidate.path,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
          ),
          // 加工完到底长什么样，当场摆出来。这一行是整个加工区存在的理由。
          if (shaped != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                shaped,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 能不能「每次随机取一条」：挑中的路径里带下标，而且返回里确实有好几条
  /// 平行的同名字段。只有一条的时候这个开关等于没有，不该摆出来占地方。
  bool get _randomizable {
    final picked = _pickedPath;
    if (picked == null) return false;
    final shape = randomizePath(picked);
    if (shape == picked) return false;
    return _candidates.where((e) => randomizePath(e.path) == shape).length > 1;
  }

  /// 可以接在正文后面的字段。排掉正文自己，条数封顶免得一排胶囊铺满半屏。
  List<SignatureValueCandidate> get _suffixCandidates => _candidates
      .where((e) => e.path != _pickedPath && e.path.isNotEmpty)
      .take(12)
      .toList();

  String _shortLabel(String value) {
    final text = _compose().applyTransform(value, applyExtract: false);
    return text.length <= 10 ? text : '${text.substring(0, 10)}…';
  }

  /// 只剥标签、不提取的样子。用来判断「提取规则写了但没匹配上」。
  String _strippedOnly(String raw) =>
      _compose().copyWith(extract: '').applyTransform(raw);

  Widget _nameStep(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    final id = _effectiveId;
    final error = _idError;

    return _stepBody(
      key: const ValueKey('name'),
      hint: t.settings.signatureWizardNameHint,
      children: [
        GlassInputSurface(
          child: TextField(
            controller: _nameController,
            decoration: glassFieldDecoration(
              context,
              hint: t.settings.signatureSourceName,
            ),
          ),
        ),
        const SizedBox(height: 10),
        GlassInputSurface(
          error: error != null,
          child: TextField(
            controller: _idController,
            decoration: glassFieldDecoration(
              context,
              hint: t.settings.signatureSourceId,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Text(
            error ?? (id.isEmpty ? t.settings.signatureSourceIdHint : '{$id}'),
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              fontFamily: error == null && id.isNotEmpty ? 'monospace' : null,
              color: error != null
                  ? cs.error
                  : (id.isEmpty ? cs.onSurfaceVariant : cs.primary),
            ),
          ),
        ),
        // 最后给一眼「用起来是什么样」：拿刚才挑中的那个真实的值，按发出去的
        // 样子渲染一遍。到这儿为止，用户一次都没被要求理解「取值路径」。
        if (_joinedValue != null) ...[
          const SizedBox(height: 16),
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
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: CommentStructurePreview(
              body: t.settings.signatureSampleBody,
              signature: _joinedValue,
            ),
          ),
        ],
      ],
    );
  }

  /// 浮在列表之上的底栏：左边进度、右边动作。
  ///
  /// 两样都没有时返回 null——底栏整条不存在（壳会把 `footerExtent` 记成 0），
  /// 而不是留一条空带子在那儿。
  Widget? _buildFooter(BuildContext context, slang.Translations t) {
    // 编辑一条已有的源不是一段旅程，不摆步骤点。
    final showDots = widget.initial == null;
    final actions = _footerActions(t);
    if (!showDots && actions.isEmpty) return null;

    return Row(
      children: [
        if (showDots) _StepDots(current: _dotIndex, total: _dotTotal),
        const Spacer(),
        if (actions.isNotEmpty)
          GlassButtonGroup(
            touchFlexSignature:
                'sig-wizard|${_stage.name}|${_fetchError != null}',
            children: actions,
          ),
      ],
    );
  }

  List<Widget> _footerActions(slang.Translations t) {
    final canAdvanceFromUrl = _urlController.text.trim().isNotEmpty;

    return [
      if (_canGoBack)
        GlassTextActionButton(label: t.common.back, onPressed: _goBack),
      // 地址不通时给一条出路：只是想改个名字的人不该被一个临时挂掉的
      // 接口卡在这一步。
      if (_stage == _Stage.url && _fetchError != null && widget.initial != null)
        GlassTextActionButton(
          label: t.settings.signatureWizardSkipTest,
          onPressed: _skipFetch,
        ),
      // 挑一个现成的那屏没有「下一步」：点哪条就直接走了。
      if (_stage != _Stage.choose)
        switch (_stage) {
          _Stage.tune => GlassTextActionButton(
            label: t.settings.signatureWizardDone,
            emphasized: true,
            onPressed: _finishPreset,
          ),
          _Stage.url => GlassTextActionButton(
            label: t.settings.signatureWizardFetch,
            emphasized: true,
            loading: _fetching,
            onPressed: canAdvanceFromUrl ? _fetchAndAdvance : null,
          ),
          _Stage.pick => GlassTextActionButton(
            label: t.settings.signatureWizardNext,
            emphasized: true,
            onPressed: _pickedPath == null
                ? null
                : () => setState(() => _stage = _Stage.name),
          ),
          _Stage.name => GlassTextActionButton(
            label: t.settings.signatureWizardDone,
            emphasized: true,
            onPressed: _idError == null ? _finishCustom : null,
          ),
          _Stage.choose => const SizedBox.shrink(),
        },
    ];
  }

  /// 编辑既有源时第一屏就是终点，没有「上一步」可回。
  bool get _canGoBack =>
      _stage != _Stage.choose &&
      !(widget.initial != null &&
          (_stage == _Stage.tune || _stage == _Stage.url));

  void _goBack() {
    setState(() {
      switch (_stage) {
        case _Stage.tune:
        case _Stage.url:
          _preset = null;
          _fetchError = null;
          _stage = _Stage.choose;
        case _Stage.pick:
          _stage = _Stage.url;
        case _Stage.name:
          _stage = _candidates.isEmpty ? _Stage.url : _Stage.pick;
        case _Stage.choose:
          break;
      }
    });
  }
}

/// 顶上那排步骤点。当前那颗是一道横杠，走到哪儿一眼看得出。
class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 摆在底栏左端，所以自己不占多余的边距、也不居中——由底栏那一行安排位置。
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 4,
            width: i == current ? 18 : 6,
            decoration: BoxDecoration(
              color: i <= current
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

/// 第一屏那几条：一个名字、一行出处、点了就走。
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 候选值一条。**值在上、路径在下**：用户是照着值挑的，路径只是说明。
class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.shownValue,
    required this.selected,
    required this.wholeBodyLabel,
    required this.onTap,
  });

  final SignatureValueCandidate candidate;

  /// 加工之后的样子（卡片上显示的就是它）。
  final String shownValue;
  final bool selected;
  final String wholeBodyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? cs.primaryContainer.withValues(alpha: 0.55)
            : cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shownValue.isEmpty ? candidate.value : shownValue,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, height: 1.35),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.path.isEmpty
                            ? wholeBodyLabel
                            : candidate.path,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: candidate.path.isEmpty
                              ? null
                              : 'monospace',
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, size: 20, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
