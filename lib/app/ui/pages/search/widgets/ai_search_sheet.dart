import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/ui/pages/search/ai_search_query.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_row_widget.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/search_mode_menu.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 「用一句话搜」——AI 把大白话变成搜索词 + 筛选条件。
///
/// ⭐ 它**只填表，不按搜索键**。结果区把解析出来的东西逐条摊开给用户看，确认
/// 之后才落进搜索框和筛选抽屉。理由写在 [AiSearchQuery] 上：结果不对时，用户
/// 得能分清是自己没说清还是模型理解错了；自动执行会把这两件事糊在一起。
///
/// 返回用户确认的结果，取消返回 null。
///
/// ⛔ 必须走 [showGlassDraggableBottomSheet]：里头是 [GlassFloatingHeaderSheet]
/// （标题行与底栏浮在内容之上），它要的是可拖拽壳那条手势链路。配方与
/// [showAiProviderEditor] 逐字相同——那张是本项目弹层 chrome 的样板。
Future<AiSearchQuery?> showAiSearchSheet(
  BuildContext context, {
  required SearchSegment segment,
  required String currentSort,
}) {
  return showGlassDraggableBottomSheet<AiSearchQuery>(
    context: context,
    builder: (context) =>
        _AiSearchSheet(segment: segment, currentSort: currentSort),
  );
}

class _AiSearchSheet extends StatefulWidget {
  const _AiSearchSheet({required this.segment, required this.currentSort});

  final SearchSegment segment;

  /// 用户此刻的排序。模型不指定排序时就是它继续生效，而「关键词会不会被
  /// 引擎忽略」这件事是按**真正生效的**排序判的。
  final String currentSort;

  @override
  State<_AiSearchSheet> createState() => _AiSearchSheetState();
}

class _AiSearchSheetState extends State<_AiSearchSheet> {
  final TextEditingController _controller = TextEditingController();

  /// 结果区的关键词框。模型常把话说得太满（一整句塞进关键词），而这件事
  /// 用户一眼看得出、改一下就好，所以这里是输入框而不是一行字。
  final TextEditingController _queryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _running = false;
  String? _error;

  /// 跑的过程中模型在说什么。
  ///
  /// ⭐ 走 [ValueNotifier] 而不是 `setState`：它按 120ms 一拍来（见
  /// `AiService._streamPace`），拿 setState 重建的是整张弹窗——包括上面那个
  /// 正在被输入法编辑的输入框。只让"思考中"那一块自己重建。
  final ValueNotifier<AiProgress?> _progress = ValueNotifier(null);

  /// 这一轮模型吐出来的思考/草稿全文，跑完之后留着给折叠行回看。
  ///
  /// ⭐ 结果不对时，这段是唯一能分清"我没说清"还是"它理解错了"的东西——
  /// 而那正是这张弹窗存在的理由。所以**报错时也要留着**。
  String _thinkingLog = '';

  /// 这一轮模型查过些什么。跑完照样留着——「它是查过才这么填的」和「它是猜的」
  /// 是两回事，而这正是用户要判断的东西。
  ///
  /// ⛔ 只在**非空**时覆盖：末尾那次 `parsing` 播报带的是空表（解析阶段不再有
  /// 工具在跑），照单全收会让查过的记录在最后一刻凭空消失。
  List<AiToolCall> _toolCalls = const [];
  bool _thinkingExpanded = false;
  DateTime? _startedAt;
  Duration? _took;

  /// 有没有一份**可编辑的**结果。它不是 [AiSearchQuery] 而是拆开的几个字段：
  /// 模型给的是初稿，板块/排序/每一条筛选都要能被用户改掉再按下去。
  bool _hasResult = false;
  late SearchSegment _segment = widget.segment;
  String? _sort;
  final List<Filter> _filters = [];

  @override
  void dispose() {
    _controller.dispose();
    _queryController.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final request = _controller.text.trim();
    if (request.isEmpty || _running) return;

    setState(() {
      _running = true;
      _error = null;
      _hasResult = false;
      _filters.clear();
      _thinkingLog = '';
      _toolCalls = const [];
      _thinkingExpanded = false;
      _took = null;
      _startedAt = DateTime.now();
    });
    _progress.value = const AiProgress(stage: AiStage.waiting);

    final result = await buildAiSearchQuery(
      request: request,
      segment: widget.segment,
      currentSort: widget.currentSort,
      onProgress: (progress) {
        // ⛔ 这条按 token 节拍跑：只准写 notifier，不许 setState，更不许打日志。
        if (!mounted) return;
        _progress.value = progress;
        // ⛔ 只留推理内容，不留 draft：结构化调用的 draft 就是那份正在成形的
        // JSON，把它攒下来叫「思考过程」是假的——那份 JSON 解析完就在结果区里
        // 逐条摊开了。非推理模型于是这一段为空，折叠行只剩工具调用记录，
        // 那也比一坨 JSON 诚实。
        if (progress.reasoning.isNotEmpty) _thinkingLog = progress.reasoning;
        if (progress.toolCalls.isNotEmpty) _toolCalls = progress.toolCalls;
      },
    );
    if (!mounted) return;
    _progress.value = null;

    setState(() {
      _running = false;
      _took = _startedAt == null
          ? null
          : DateTime.now().difference(_startedAt!);
      if (!result.isSuccess || result.data == null) {
        _error = result.message;
        return;
      }
      final query = result.data!;
      // 一句都没解析出来时给一句人话，而不是摆一张空结果区——用户会以为是
      // 界面坏了，而不是「这句话没说清」。
      if (query.isEmpty) {
        _error = slang.t.ai.searchEmpty;
        return;
      }
      _hasResult = true;
      _segment = query.segment;
      _sort = query.sort;
      _queryController.text = query.query;
      _filters
        ..clear()
        ..addAll(query.filters);
    });
  }

  /// 把用户改过的这份表交回去。[AiSearchQuery.segmentChanged] 按**现在**选中的
  /// 板块重算——用户可能已经把模型换的板块换回来了。
  void _apply() {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    Navigator.pop(
      context,
      AiSearchQuery(
        query: _queryController.text.trim(),
        segment: _segment,
        segmentChanged: _segment != widget.segment,
        sort: _sort,
        filters: _filters.map((f) => f.copyWith()).toList(),
      ),
    );
  }

  /// 换板块要连带清理筛选：字段表是按板块给的，「时长」在图片板块里不存在，
  /// 留着它只会在抽屉里画出一行画不出来的条件，或者被服务端静默忽略。
  void _changeSegment(SearchSegment next) {
    if (next == _segment) return;
    final fields = FilterConfig.getContentType(next)?.fields ?? const [];

    final kept = <Filter>[];
    var dropped = 0;
    for (final filter in _filters) {
      final field = fields.firstWhereOrNull((f) => f.name == filter.field);
      final ok =
          field != null &&
          FilterConfig.getOperatorsForType(
            field.type,
          ).contains(filter.operator);
      if (ok) {
        kept.add(filter);
      } else {
        dropped++;
      }
    }

    final sorts = FilterConfig.getSortOptionsForSegment(
      next,
    ).map((o) => o.value);
    setState(() {
      _segment = next;
      _filters
        ..clear()
        ..addAll(kept);
      // 旧板块的排序值在新板块上可能根本不是合法参数（oreno3d 的 hot 放到视频
      // 板块上搜出来是空的）。
      if (_sort != null && !sorts.contains(_sort)) {
        _sort = FilterConfig.getDefaultSortForSegment(next);
      }
    });

    if (dropped > 0) {
      showAppToast(slang.t.ai.searchFiltersDropped(count: dropped));
    }
  }

  Future<void> _pickSegment(BuildContext anchorContext) async {
    final t = slang.Translations.of(context);
    final picked = await showGlassMenu<SearchSegment>(
      anchorContext: anchorContext,
      entries: [
        for (final seg in SearchSegment.values)
          GlassMenuOption<SearchSegment>(
            value: seg,
            icon: Icons.category_outlined,
            label: searchSegmentLabel(seg, t),
            selected: seg == _segment,
          ),
      ],
    );
    if (picked != null) _changeSegment(picked);
  }

  Future<void> _pickSort(BuildContext anchorContext) async {
    final options = FilterConfig.getSortOptionsForSegment(_segment);
    if (options.isEmpty) return;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        for (final option in options)
          GlassMenuOption<String>(
            value: option.value,
            icon: Icons.sort,
            label: option.label,
            selected: option.value == _sort,
          ),
      ],
    );
    if (picked != null) setState(() => _sort = picked);
  }

  void _updateFilter(String id, Filter next) {
    final index = _filters.indexWhere((f) => f.id == id);
    if (index == -1) return;
    setState(() => _filters[index] = next);
  }

  void _removeFilter(String id) {
    setState(() => _filters.removeWhere((f) => f.id == id));
  }

  /// ⭐ 「没加引号的 CJK 关键词 + 非相关度排序」是 iwara 引擎的坏模式：那段字会
  /// 被拆成片段做 OR，换成按时间/播放排序之后第一页与关键词毫无关系
  /// （实测 `初音ミク` 按时间排，前 20 条只有 3 条真的相关；加了引号是 20 条）。
  ///
  /// 这条不做成「禁止修改」：用户正要动的那个控件被锁住，比结果不准更难受。
  /// 说清后果，再把排序钮摆在旁边让他自己选。
  bool get _keywordNeedsQuotes {
    // sort 为 null ＝沿用用户当前的排序（App 的默认就是 date，正是坏的那一档）。
    if ((_sort ?? widget.currentSort) == 'relevance') return false;
    // oreno3d 是另一个站的搜索，不吃 iwara 的引号语法。
    if (_segment == SearchSegment.oreno3d) return false;
    return keywordMatchesLoosely(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    // ⛔ 版式走 [GlassFloatingHeaderSheet]，配方与 [AiProviderEditorSheet]
    // 逐字相同：**标题行与底栏都浮在内容之上**，正文从两者背后滚过去，交界处
    // 只有一层 [EdgeFadeScrim]（由壳统一画）。
    //
    // 收口前这里是「标题行一格 + Divider + 正文一格 + 自己搭的 Stack 动作条」
    // ——两条硬边把弹窗切成三截，蒙层/让位高度/底部安全区还各手写了一份
    // （2026-09-21 用户点名：AI 供应商编辑弹窗那套才是最佳实践）。
    return GlassFloatingHeaderSheet(
      title: t.ai.searchTitle,
      leading: Icon(Icons.auto_awesome, size: 20, color: cs.primary),
      // 开得高一档（同 [AiProviderEditorSheet]）：这张弹窗一进来就自动聚焦
      // 输入框，键盘会吃掉屏幕下半截——开在 0.7 的话键盘上方只剩得下标题行。
      // AI 结果可长可短（思考过程展开后尤其长），所以仍然留着让用户拖大拖小。
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      footer: _buildFooter(t),
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
                t.ai.searchHint,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              GlassInputSurface(
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 2,
                  autofocus: true,
                  enabled: !_running,
                  textInputAction: TextInputAction.search,
                  // ⛔ 必须重建：下面那枚键的可用性读的就是这个输入框的内容，
                  // 不跟着敲键重建的话，用户打完字那枚键还是灰的（点不动，
                  // 也说不出为什么）。
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _run(),
                  decoration: glassFieldDecoration(
                    context,
                    hint: t.ai.searchPlaceholder,
                  ),
                ),
              ),
              // 出现与消失都要有过渡，不硬切。
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 跑的过程中把模型正在说的话摆出来。⛔ 一个不动的转圈
                    // 既说不清"是不是卡死了"，也说不清"它有没有听懂"，而
                    // 这类请求动辄十几二十秒（还可能在降级重试）。
                    if (_running)
                      _ThinkingPanel(
                        progress: _progress,
                        startedAt: _startedAt,
                      ),
                    if (_error != null) _buildError(cs, _error!),
                    if (_hasResult) _buildResult(t, cs),
                    // 跑完仍然留着回看：结果不对时，这段是唯一能分清
                    // "我没说清"还是"它理解错了"的东西。
                    if (!_running &&
                        (_thinkingLog.isNotEmpty || _toolCalls.isNotEmpty))
                      _buildThinkingLog(t, cs),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  /// 浮在内容之上的底栏。
  ///
  /// ⛔ 这里**没有「取消」**：标题行右端那枚玻璃圆钮就是取消（由壳供），
  /// 同 [AiProviderEditorSheet]。
  Widget _buildFooter(slang.Translations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GlassButtonGroup(
          // 出结果前后这组钮从 1 枚变 2 枚，宽度形变要认得出是同一坨玻璃。
          touchFlexSignature: 'ai-search|$_hasResult|$_running',
          children: [
            if (!_hasResult)
              GlassTextActionButton(
                label: _running ? t.ai.searchGenerating : t.ai.searchTitle,
                emphasized: true,
                onPressed: _running || _controller.text.trim().isEmpty
                    ? null
                    : _run,
              )
            else ...[
              GlassTextActionButton(
                label: t.common.retry,
                onPressed: _running ? null : _run,
              ),
              GlassTextActionButton(
                label: t.ai.searchApply,
                emphasized: true,
                onPressed: _apply,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildError(ColorScheme cs, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 15, color: cs.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, height: 1.35, color: cs.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 把解析结果摊开，并且**允许改**：关键词是输入框，板块与排序点得动，
  /// 每条筛选就是筛选抽屉里那张卡（同一个 [FilterRowWidget]）。
  ///
  /// ⛔ 不要只显示「已生成 3 个条件」——用户没法判断对不对，也就没法决定要不要
  /// 按下去。摊开来看才是这一步存在的理由；模型给的是初稿，不是判决。
  Widget _buildResult(slang.Translations t, ColorScheme cs) {
    // ⛔ 按**现在选中的那个板块**取字段表：模型可能把用户送去别的索引，用户
    // 也可能又换了回来，拿错表会把条件的名字显示成 API 字段名（甚至找不到）。
    final fields = FilterConfig.getContentType(_segment)?.fields ?? const [];
    // 模型没指定排序时显示的是**会生效的那个**（用户当前的），不是一个破折号：
    // 「关键词会不会被引擎忽略」那条提醒正是按它判的，两处对不上就没法理解。
    final effectiveSort = _sort ?? widget.currentSort;
    final sortLabel = FilterConfig.getSortOptionsForSegment(
      _segment,
    ).firstWhereOrNull((o) => o.value == effectiveSort)?.label;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, size: 14, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GlassInputSurface(
                        child: TextField(
                          controller: _queryController,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          // 关键词一变，下面那条「这个排序下关键词不作数」的
                          // 提醒要跟着出现/消失。
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _apply(),
                          decoration: glassFieldDecoration(
                            context,
                            hint: t.ai.searchPlaceholder,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // ⛔ 换板块必须明说。按下去之后页面整个换了个索引，不声不响的话
                // 用户只会以为自己点错了。点它就能换回来（或换去别处）。
                Builder(
                  builder: (anchorContext) => _buildChip(
                    cs,
                    Icons.swap_horiz,
                    _segment == widget.segment
                        ? searchSegmentLabel(_segment, t)
                        : t.ai.searchSwitchSegment(
                            segment: searchSegmentLabel(_segment, t),
                          ),
                    emphasized: _segment != widget.segment,
                    onTap: () => _pickSegment(anchorContext),
                  ),
                ),
                Builder(
                  builder: (anchorContext) => _buildChip(
                    cs,
                    Icons.sort,
                    '${t.common.sort}: ${sortLabel ?? '—'}',
                    onTap: () => _pickSort(anchorContext),
                  ),
                ),
                if (_keywordNeedsQuotes)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 13, color: cs.tertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.ai.searchKeywordNeedsQuotes,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: cs.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_filters.isNotEmpty && fields.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              t.ai.searchFilters,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final filter in _filters)
                    FilterRowWidget(
                      key: ValueKey(filter.id),
                      filter: filter,
                      availableFields: fields,
                      onUpdate: _updateFilter,
                      onRemove: _removeFilter,
                      onValidate: (f) =>
                          FilterConfig.validateFilter(f, _segment),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 结果区里「板块 / 排序」那种一行小标记。给了 [onTap] 就是可点的。
  Widget _buildChip(
    ColorScheme cs,
    IconData icon,
    String text, {
    bool emphasized = false,
    VoidCallback? onTap,
  }) {
    final color = emphasized ? cs.primary : cs.onSurfaceVariant;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: color,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (onTap != null) Icon(Icons.arrow_drop_down, size: 16, color: color),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: onTap == null
          ? row
          // 点按吐的是玻璃菜单，所以要声明 opensOverlay：长按也能开，并且手指
          // 能接力划到某一条再松手（组件没法自己预知 onTap 干什么）。
          : GlassTapArea(
              onTap: onTap,
              opensOverlay: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: row,
              ),
            ),
    );
  }

  /// 跑完之后留下的那一行「思考过程 · 8.2s」，点开看全文。
  ///
  /// 默认收起：多数时候结果是对的，没人要看这段；但结果不对时它是唯一的线索，
  /// 所以不能跑完就扔。
  Widget _buildThinkingLog(slang.Translations t, ColorScheme cs) {
    final seconds = _took == null
        ? null
        : (_took!.inMilliseconds / 1000).toStringAsFixed(1);
    final label = seconds == null
        ? t.ai.searchThinking
        : '${t.ai.searchThinking} · ${seconds}s';

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassTapArea(
            onTap: () => setState(() => _thinkingExpanded = !_thinkingExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _thinkingExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.chevron_right,
                      size: 15,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 出现与消失都要有过渡，不硬切。
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _thinkingExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_toolCalls.isNotEmpty)
                          _ToolCallLines(calls: _toolCalls),
                        if (_thinkingLog.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              top: _toolCalls.isEmpty ? 0 : 8,
                            ),
                            child: _ThinkingText(
                              text: _thinkingLog,
                              maxHeight: 180,
                              follow: false,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// 跑的过程中那一块：转圈 + 已用秒数 + 模型正在写的字。
///
/// ⭐ 单独一个 widget，是为了让 120ms 一拍的重建只落在这里——外面那张弹窗上
/// 还有个正在被输入法编辑的输入框，跟着一起重建既浪费又容易出怪事。
class _ThinkingPanel extends StatefulWidget {
  const _ThinkingPanel({required this.progress, required this.startedAt});

  final ValueListenable<AiProgress?> progress;
  final DateTime? startedAt;

  @override
  State<_ThinkingPanel> createState() => _ThinkingPanelState();
}

class _ThinkingPanelState extends State<_ThinkingPanel> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // 秒数一秒一跳。⛔ 别跟着帧走：这块在场的时间可能有半分钟，而它只是个
    // 计时器（本项目已经在「透明度 0 的常驻转圈把整应用拖到满帧重绘」上栽过）。
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final started = widget.startedAt;
    final elapsed = started == null
        ? null
        : DateTime.now().difference(started).inSeconds;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: ValueListenableBuilder<AiProgress?>(
          valueListenable: widget.progress,
          builder: (context, progress, _) {
            final calls = progress?.toolCalls ?? const <AiToolCall>[];
            // ⭐ 服务内部有两层自动重来（流式降级、去掉工具再跑），每一层最长
            // 都要一两分钟。不把它说出来，界面就是一行不动的字加一个转圈——
            // 2026-09-21 用户报障「出错了也一点反应没有」。
            final notice = progress?.notice ?? '';
            final stage = progress?.stage ?? AiStage.waiting;
            final retrying = stage == AiStage.retrying;
            // ⛔ 正文只取 [AiProgress.reasoning]，**不用 visibleText**：它在没有
            // 推理内容时会回落到 draft，而结构化调用的 draft 就是那坨正在成形的
            // JSON。把 `{"segment":"video","query":"\"初音ミク\"…` 摆给用户看，
            // 既不是"思考过程"也没人读得下去——那份 JSON 解析完就在下面的结果区
            // 里逐条摊开了，比原文好懂得多。写答案这件事改由阶段那行字交代。
            final reasoning = progress?.reasoning ?? '';
            final label = _stageLabel(t, stage, progress?.draft ?? '', calls);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.6,
                        color: retrying ? cs.error : cs.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // 有出有入：换阶段是这块唯一会动的东西，硬切等于没换。
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        // ⛔ 默认的 layoutBuilder 是**居中**的 Stack：摆在 Row 的
                        // Expanded 里，换档那 200ms 里新旧两句话会一起跳到中间
                        // 再跳回来，看起来像界面抽了一下。
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previous, ?current],
                        ),
                        child: Text(
                          label,
                          // ⛔ key 必须跟着文案走：AnimatedSwitcher 认的是
                          // widget 身份，不给 key 的话「正在推理…」换成
                          // 「正在试搜…」是同一个 Text，一帧硬切过去。
                          key: ValueKey(label),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: retrying ? cs.error : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (elapsed != null)
                      Text(
                        '${elapsed}s',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                // 出现与消失都要有过渡，不硬切。
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: (reasoning.isEmpty && calls.isEmpty && notice.isEmpty)
                      // 还没出字（原生结构化那条路根本拿不到流）：只有上面那行。
                      ? const SizedBox(width: double.infinity)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ⭐ 失败原因摆在最上面：用户要凭它决定还等不等
                            // （端点 500 值得等一下，密钥错了等到天亮也没用）。
                            if (notice.isNotEmpty)
                              _NoticeLine(reason: notice, cs: cs),
                            // 查过什么摆在上面：它比思考过程好懂得多，也是唯一
                            // 能分清「它查过才这么填」和「它是猜的」的东西。
                            if (calls.isNotEmpty) _ToolCallLines(calls: calls),
                            if (reasoning.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _ThinkingText(
                                  text: reasoning,
                                  maxHeight: 108,
                                  follow: true,
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 此刻在干什么，一句话。
///
/// ⭐ [AiStage] 那几档是**专门为这一行存在的**：服务是一次要完的，调用方在它
/// 返回之前手上什么都没有。收口前这里印的是一句恒定的「正在理解…」，于是
/// 2026-09-21 用户看到的是整整一分钟一个标点都没变的界面（实际上那段时间里
/// 请求发出去了、试搜了一次、500 了、又在重试）。
///
/// ⛔ 措辞由**界面**给而不是服务：`AiService` 不知道自己是在替翻译、搜索还是
/// 小尾巴干活，说不出「正在试搜」这种话（见 [AiRequest.timeoutMessage] 的注释）。
String _stageLabel(
  slang.Translations t,
  AiStage stage,
  String draft,
  List<AiToolCall> calls,
) => switch (stage) {
  // ⭐ 查完之后服务会退回 waiting（「又回去想了，还没开始写答案」）。这一档
  // 与"刚发出去还没回音"是两件事，对着一次已经查到 2143 条的试搜再说一句
  // 「等待回应」只会让人以为白查了。
  AiStage.waiting when calls.isNotEmpty => t.ai.searchStageThinkingNext,
  AiStage.waiting => t.ai.searchStageWaiting,
  AiStage.reasoning => t.ai.searchStageReasoning,
  AiStage.callingTool => t.ai.searchStageTool,
  // 字数是这一档唯一动得起来的东西——JSON 原文对用户零价值，但"它正在写，而且
  // 越写越多"这件事是有价值的。
  AiStage.drafting => t.ai.searchStageDrafting(chars: draft.runes.length),
  AiStage.parsing => t.ai.searchStageParsing,
  AiStage.retrying => t.ai.searchRetrying,
};

/// 「上一次为什么没成」那一行。
///
/// ⛔ 原因要**原样**摆出来（截断但不改写）：这句话的唯一用途就是让用户看出
/// 是端点在 500 还是自己的密钥不对，换成一句「出错了」等于什么都没说。
class _NoticeLine extends StatelessWidget {
  const _NoticeLine({required this.reason, required this.cs});

  final String reason;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline, size: 12, color: cs.error),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.ai.searchRetryReason(reason: reason.trim()),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, height: 1.4, color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 模型查过 / 正在查什么，一次调用一行。
///
/// ⭐ 这是「思考过程」里最有用的一段：思维链是它**打算**怎么做，工具调用是它
/// **真的**去查了、查到了什么。结果不对时，看一眼「试搜 "白金ディスコ" → 34 条」
/// 就知道问题不在搜索词上。
class _ToolCallLines extends StatelessWidget {
  const _ToolCallLines({required this.calls});

  final List<AiToolCall> calls;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final call in calls)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 11,
                    height: 11,
                    child: call.running
                        // 同时至多有一个在跑，不会堆出一排 ticker。
                        ? CircularProgressIndicator(
                            strokeWidth: 1.4,
                            color: cs.primary,
                          )
                        : Icon(Icons.done, size: 11, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 6),
                // ⭐ 查什么在左、查到什么在右，两栏分家而不是一条 `A → B` 的
                // 长句：用户扫这一块只为一件事——**数字**（0 条说明有条件把
                // 结果杀光了）。挤在句中间时它是第几个词全看关键词多长。
                Expanded(
                  flex: 3,
                  child: Text(
                    call.call,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: cs.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                if (call.result != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      call.result!,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// 一块限高、可滚的小字。[follow] 为真时始终贴着最后一行（正在出字）。
class _ThinkingText extends StatefulWidget {
  const _ThinkingText({
    required this.text,
    required this.maxHeight,
    required this.follow,
  });

  final String text;
  final double maxHeight;
  final bool follow;

  @override
  State<_ThinkingText> createState() => _ThinkingTextState();
}

class _ThinkingTextState extends State<_ThinkingText> {
  final ScrollController _scroll = ScrollController();

  /// 内容有没有溢出到这一头之外。两头各自判：只在**真的还有字被藏起来**的那
  /// 一侧画渐隐，否则滚到顶还淡掉第一行，看起来像少了半句话。
  bool _overflowTop = false;
  bool _overflowBottom = false;

  @override
  void didUpdateWidget(_ThinkingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text == oldWidget.text) return;
    if (widget.follow) {
      _stickToBottom();
    } else {
      _syncEdgesAfterFrame();
    }
  }

  /// ⛔ 要等这一帧布局完才知道新的最大滚动量——文字是刚加上去的，现在问到的
  /// 还是上一帧的高度，贴不到底。
  void _stickToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
      _syncEdges();
    });
  }

  void _syncEdgesAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncEdges();
    });
  }

  void _syncEdges() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    // 1px 容差：maxScrollExtent 是浮点算出来的，严格比较会在贴底那一帧抖。
    final top = p.pixels > p.minScrollExtent + 1;
    final bottom = p.pixels < p.maxScrollExtent - 1;
    if (top != _overflowTop || bottom != _overflowBottom) {
      setState(() {
        _overflowTop = top;
        _overflowBottom = bottom;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _syncEdgesAfterFrame();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 渐隐带按像素折算成比例：这块的高度是定的，写死 stop 会让 108 和 180
    // 两处的渐隐看起来不是一回事。
    final fade = (_fadeExtent / widget.maxHeight).clamp(0.0, 0.4);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      // ⭐ 上下渐隐而不是硬裁：这块字是**流过去的**，被切掉半行的边缘读起来
      // 像日志尾巴；淡出去才像"还在继续"。ShaderMask 只在思考块在场时有，
      // 不是常驻图层。
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _overflowTop ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            const Color(0xFFFFFFFF),
            _overflowBottom ? const Color(0x00FFFFFF) : const Color(0xFFFFFFFF),
          ],
          stops: [0, fade, 1 - fade, 1],
        ).createShader(rect),
        child: NotificationListener<ScrollNotification>(
          onNotification: (_) {
            _syncEdges();
            return false;
          },
          child: SingleChildScrollView(
            controller: _scroll,
            // ⛔ 不用 SelectableText：它的裸识别器 slop 恒 18，比滚动更深也更早
            // 赢，用户想滚这块小窗（或滚整张弹窗）会变成在选字，夹 slop 也救不回。
            child: Text(
              widget.text,
              // ⛔ 不用等宽：思考链是散文不是代码，等宽字既窄又密，11px 下
              // 一眼看过去就是一坨 log。
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 思考文本上下那条渐隐带的高度。
const double _fadeExtent = 16;

/// AI 搜索现在能不能用（有没有一份配好的供应商档案）。
///
/// ⛔ 用它来决定**点下去之后说什么**，不要用它决定那枚钮在不在场。一个功能的
/// 唯一入口按「配没配过」藏起来，等于新用户永远发现不了它——本项目已经在小
/// 尾巴上栽过一次（2026-09-20 用户报障：「菜单里根本没这个选项」）。
bool get isAiSearchAvailable =>
    Get.isRegistered<AiService>() &&
    Get.find<AiService>().isAvailable(AiTask.searchQuery);
