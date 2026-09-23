import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/pages/search/ai_search_query.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_row_widget.dart';
import 'package:i_iwara/app/ui/widgets/ai/ai_ui_parts.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
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

  /// 这一轮的过程记录：推理、它说的话、查过什么，按时间排好（见
  /// [AiTraceEntry]）。跑完之后留着给折叠行回看。
  ///
  /// ⭐ 结果不对时，这段是唯一能分清"我没说清"还是"它理解错了"的东西——
  /// 而那正是这张弹窗存在的理由。所以**报错时也要留着**。
  ///
  /// ⛔ 只在**非空**时覆盖：末尾那次 `parsing` 播报、以及官方端点「查完再填表」
  /// 的第二趟都不带过程，照单全收会让记录在最后一刻凭空消失。
  List<AiTraceEntry> _trace = const [];

  /// 模型交上来的那份表原样试搜过的结果。用户改了表就不再作数（见
  /// [AiSearchPreview.matches]），界面上随之消失。
  AiSearchPreview? _preview;
  bool _thinkingExpanded = false;

  /// 第几轮。迟到的回调（上一轮超时后才跑完的工具）拿它认出自己过期了。
  int _runSeq = 0;
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
    final run = ++_runSeq;

    setState(() {
      _running = true;
      _error = null;
      _hasResult = false;
      _filters.clear();
      _trace = const [];
      _preview = null;
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
        // ⛔ 上一轮超时后还在跑的工具会迟到着回调，别让它写进这一轮。
        if (!mounted || run != _runSeq) return;
        // ⛔ 留过程记录，不留 draft：结构化调用的 draft 末尾是那份正在成形的
        // JSON，它解析完就在结果区里逐条摊开了。过程记录里的正文段会把 JSON
        // 剪掉（[AiTraceEntry.prose]），只留模型说的那几句话。
        if (progress.trace.isNotEmpty) _trace = progress.trace;
        // 空表＝「这一拍不带过程」（查完回去填表、重试、解析），不是「过程没了」：
        // 面板照样画攒着的那一份，否则时间线会在静默的那几秒里整块消失。
        _progress.value = progress.trace.isNotEmpty || _trace.isEmpty
            ? progress
            : AiProgress(
                stage: progress.stage,
                reasoning: progress.reasoning,
                draft: progress.draft,
                notice: progress.notice,
                toolCalls: progress.toolCalls,
                trace: _trace,
              );
      },
    );
    if (!mounted || run != _runSeq) return;
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
      _preview = query.preview;
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
                    // 说明只在还没跑过时有用：跑起来之后下面那条过程就是说明，
                    // 结果出来后它更只是压在方案卡上面的一段灰字。
                    if (!_running && !_hasResult && _error == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                        child: Text(
                          t.ai.searchHint,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    // ⭐ 跑的时候与跑完之后是**同一条**：收口前是两块（跑的时候一
                    // 张带限高滚动框的面板，跑完换成一行折叠的「思考过程」），
                    // 同一段记录换个壳再出现一次，展开后还是框里套框的第二层
                    // 滚动。现在它原地从「正在试搜…」变成「过程 · 查了 3 次 ·
                    // 8.2s」，展开就是整段摊在弹窗里，跟着弹窗一起滚。
                    //
                    // 跑完仍然留着回看：结果不对时，这段是唯一能分清
                    // "我没说清"还是"它理解错了"的东西。只交了 JSON 的模型剪完
                    // 是空的：别留一行点开什么都没有的折叠行。
                    if (_running || _TraceView.hasContent(_trace))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ProcessSection(
                          progress: _progress,
                          running: _running,
                          startedAt: _startedAt,
                          took: _took,
                          trace: _trace,
                          expanded: _thinkingExpanded,
                          onToggle: () => setState(
                            () => _thinkingExpanded = !_thinkingExpanded,
                          ),
                        ),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                        child: AiNoticeLine(_error!),
                      ),
                    if (_hasResult) _buildResult(t, cs),
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

  /// 「搜索方案」卡：把解析结果摊开，并且**允许改**——关键词是输入框，板块与
  /// 排序是两只下拉胶囊，每条筛选就是筛选抽屉里那张卡（同一个
  /// [FilterRowWidget]）。
  ///
  /// ⭐ 卡头的大字是**试搜过的条数**：用户决定按不按「应用」，看的就是这个数
  /// （0 条说明有条件把结果杀光了）。收口前它是卡片最底下一行 11px 的小字，
  /// 排在关键词、两行板块/排序、两条提示后面。
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

    final keyword = _queryController.text;
    final tags = aiSearchRecognizedTags(keyword, _segment);
    // ⛔ 试搜数字只在表单**原样**就是试搜过的那一份时才摆：用户改了一个字它就
    // 不再是这份表的结果，留着只会骗人。
    final preview = _preview;
    final estimate =
        preview != null &&
            preview.matches(
              segment: _segment,
              keyword: keyword,
              filters: _filters,
              sort: _sort,
              currentSegment: widget.segment,
              currentSort: widget.currentSort,
            )
        ? preview
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AiInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlanHeadline(t, cs, estimate),
                const SizedBox(height: 10),
                GlassInputSurface(
                  child: TextField(
                    controller: _queryController,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    // 关键词一变，卡头的条数与「关键词不作数」的提醒要跟着
                    // 出现/消失。
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _apply(),
                    decoration: glassFieldDecoration(
                      context,
                      hint: t.ai.searchPlaceholder,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // ⛔ 换板块必须明说。按下去之后页面整个换了个索引，不声不响
                    // 的话用户只会以为自己点错了。点它就能换回来（或换去别处）。
                    GlassDropdownPill(
                      height: _pillHeight,
                      icon: Icons.swap_horiz,
                      label: _segment == widget.segment
                          ? searchSegmentLabel(_segment, t)
                          : t.ai.searchSwitchSegment(
                              segment: searchSegmentLabel(_segment, t),
                            ),
                      onTap: _pickSegment,
                    ),
                    GlassDropdownPill(
                      height: _pillHeight,
                      icon: Icons.sort,
                      label: sortLabel ?? t.common.sort,
                      onTap: _pickSort,
                    ),
                  ],
                ),
                // 出现与消失都要有过渡：这两行跟着关键词/排序实时变。
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ⭐ 这是 AI 搜索与「按标签补搜」接上的那一处：用户看不出
                      // `"原神"` 按下去其实还会按 #原神 标签补搜的话（那才是大头：
                      // 文本 17 条、标签 324 条），会以为模型只给了一个词。
                      if (tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Text(
                                  t.ai.searchWillExpandTags,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              for (final match in tags)
                                AiTag(
                                  '#${TagLocalizationService.displayName(match.slugs.first)}',
                                  tone: AiTone.accent,
                                ),
                            ],
                          ),
                        ),
                      if (_keywordNeedsQuotes)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: AiNoticeLine(
                            t.ai.searchKeywordNeedsQuotes,
                            tone: AiTone.warning,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_filters.isNotEmpty && fields.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
              child: Text(
                '${t.ai.searchFilters} · ${_filters.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
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

  /// 卡头：小标题「搜索方案」+ 试搜过的条数（大字）+ 前几条的标题。
  ///
  /// 改了表之后条数不再作数，卡头退回只剩小标题——换档要有过渡。
  Widget _buildPlanHeadline(
    slang.Translations t,
    ColorScheme cs,
    AiSearchPreview? estimate,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.ai.searchPlanTitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: cs.onSurfaceVariant,
            ),
          ),
          if (estimate != null) ...[
            const SizedBox(height: 2),
            Text(
              t.ai.searchPlanEstimate(count: estimate.total),
              style: TextStyle(
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w700,
                // 0 条是这张卡最要紧的警告：一眼看得出有条件把结果杀光了。
                color: estimate.total == 0 ? cs.error : cs.onSurface,
              ),
            ),
            if (estimate.titles.isNotEmpty)
              Text(
                estimate.titles.take(3).join(' / '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
          ],
        ],
      ),
    );
  }
}

/// 方案卡里下拉胶囊的高度。比全站默认的 44 矮一档：它们摆在卡片里、紧挨着
/// 输入框，44 高的一排会比关键词本身还抢眼。
const double _pillHeight = 36;

/// 「过程」一条：跑的时候与跑完之后是同一个东西。
///
/// - 跑的时候：转圈 + 此刻在干什么 + 已用秒数；收起时底下露一行最新的动静
///   （最后一次试搜/最后一句推理），展开就是整段过程；
/// - 跑完：「思考过程 · 查了 3 次 · 8.2s」，默认收起，点开整段摊开。
///
/// ⛔ 展开后**不限高、不自己滚**：它摆在弹窗的列表里，限高就是列表里再套一个
/// 能滚的框，两层滚动互相抢手势（2026-09-23 用户点名）。
///
/// ⭐ 单独一个 widget，是为了让 120ms 一拍的重建只落在这里——外面那张弹窗上
/// 还有个正在被输入法编辑的输入框，跟着一起重建既浪费又容易出怪事。
class _ProcessSection extends StatefulWidget {
  const _ProcessSection({
    required this.progress,
    required this.running,
    required this.startedAt,
    required this.took,
    required this.trace,
    required this.expanded,
    required this.onToggle,
  });

  final ValueListenable<AiProgress?> progress;
  final bool running;
  final DateTime? startedAt;
  final Duration? took;

  /// 跑完之后的那份记录（跑的时候以 [progress] 里的为准）。
  final List<AiTraceEntry> trace;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_ProcessSection> createState() => _ProcessSectionState();
}

class _ProcessSectionState extends State<_ProcessSection> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(_ProcessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) _syncTicker();
  }

  /// 秒数一秒一跳，只在跑的时候跳。⛔ 别跟着帧走：这块在场的时间可能有半分钟，
  /// 而它只是个计时器（本项目已经在「透明度 0 的常驻转圈把整应用拖到满帧重绘」
  /// 上栽过）。
  void _syncTicker() {
    _ticker?.cancel();
    _ticker = widget.running
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() {});
          })
        : null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.running) return _build(context, null);
    return ValueListenableBuilder<AiProgress?>(
      valueListenable: widget.progress,
      builder: (context, progress, _) => _build(context, progress),
    );
  }

  Widget _build(BuildContext context, AiProgress? progress) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final running = widget.running;

    // ⛔ 正文只取过程记录，**不用 draft**：结构化调用的 draft 末尾是那坨
    // 正在成形的 JSON，它解析完就在方案卡里逐条摊开了。过程记录里的正文段
    // 已经剪掉 JSON（[AiTraceEntry.prose]）。
    final trace = running
        ? (progress?.trace ?? const <AiTraceEntry>[])
        : widget.trace;
    final calls = progress?.toolCalls ?? const <AiToolCall>[];
    final stage = progress?.stage ?? AiStage.waiting;
    // ⭐ 服务内部有两层自动重来（流式降级、去掉工具再跑），每一层最长都要一两
    // 分钟。不把它说出来，界面就是一行不动的字加一个转圈——2026-09-21 用户
    // 报障「出错了也一点反应没有」。
    final retrying = running && stage == AiStage.retrying;
    final notice = running ? (progress?.notice ?? '') : '';
    final hasTrace = _TraceView.hasContent(trace);

    final String label;
    final String meta;
    if (running) {
      label = _stageLabel(t, stage, progress?.draft ?? '', calls);
      final started = widget.startedAt;
      meta = started == null
          ? ''
          : '${DateTime.now().difference(started).inSeconds}s';
    } else {
      label = t.ai.searchThinking;
      final toolCount = trace.where((e) => e.kind == AiTraceKind.tool).length;
      final took = widget.took;
      meta = [
        if (toolCount > 0) t.ai.searchToolCount(count: toolCount),
        if (took != null) '${(took.inMilliseconds / 1000).toStringAsFixed(1)}s',
      ].join(' · ');
    }

    final accent = retrying ? cs.error : cs.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassTapArea(
          // 还没出字的时候没什么可展开的（原生结构化那条路根本拿不到流）。
          onTap: hasTrace ? widget.onToggle : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  // 有出有入：跑完那一下转圈换成对勾，不是一帧消失。
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: running
                        ? Padding(
                            key: const ValueKey('spin'),
                            padding: const EdgeInsets.all(1),
                            child: CircularProgressIndicator(
                              strokeWidth: 1.6,
                              color: retrying ? cs.error : cs.primary,
                            ),
                          )
                        : Icon(
                            Icons.psychology_alt_outlined,
                            key: const ValueKey('done'),
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    meta,
                    style: TextStyle(
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
                // 能展开才画箭头；有出有入。
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasTrace ? 1 : 0,
                  child: AnimatedRotation(
                    turns: widget.expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
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
          child: Padding(
            // 与标题文字对齐（图标 14 + 间距 8 + 外边 4）。
            padding: const EdgeInsets.only(left: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⭐ 失败原因摆在最上面：用户要凭它决定还等不等（端点 500 值得
                // 等一下，密钥错了等到天亮也没用）。
                if (notice.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AiNoticeLine(
                      t.ai.searchRetryReason(reason: notice.trim()),
                      maxLines: 3,
                    ),
                  ),
                if (hasTrace && widget.expanded)
                  // ⭐ 想、查、再想，按发生的先后排成一串：看得出哪次试搜是为了
                  // 验证哪个念头、查到之后又改了什么主意。
                  _TraceView(trace: trace)
                else if (hasTrace && running)
                  // 收起时只露最新的一行动静：证明它在干活，又不把弹窗撑长。
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _LatestTraceLine(trace: trace),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 过程收起时露出来的那一行：最后一段记录的最后一句。
class _LatestTraceLine extends StatelessWidget {
  const _LatestTraceLine({required this.trace});

  final List<AiTraceEntry> trace;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    AiTraceEntry? last;
    for (final e in trace.reversed) {
      if (_TraceView._visible(e)) {
        last = e;
        break;
      }
    }
    if (last == null) return const SizedBox.shrink();
    final text = switch (last.kind) {
      AiTraceKind.tool =>
        last.call!.result == null
            ? last.call!.call
            : '${last.call!.call} → ${last.call!.result}',
      AiTraceKind.reasoning => _lastLine(last.text),
      AiTraceKind.narration => _lastLine(last.prose),
    };
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        height: 1.4,
        color: cs.onSurfaceVariant.withValues(alpha: 0.85),
      ),
    );
  }

  static String _lastLine(String s) {
    final lines = s.trim().split('\n').where((l) => l.trim().isNotEmpty);
    return lines.isEmpty ? '' : lines.last.trim();
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

/// 过程记录：推理、模型说的话、工具调用，按时间排成一串。
///
/// ⭐ 为什么不再是「工具一块、思维链一块」：模型是边想边查的，拆开摆就只剩
/// 「它想了一大段」和「它查了三次」，看不出哪次试搜是为了验证哪个念头、查到
/// 结果之后又改了什么主意——而那才是用户要的「它为什么这么填」。
///
/// 三种段落长得不一样，一眼分得开：
/// - 推理（原生思维链）：小字、淡色、左边一道竖线——是它的草稿，不是结论；
/// - 说的话（非推理模型「先说再答」那几句 / 工具之间的旁白）：正常字色；
/// - 工具调用：一行，查什么在左、查到什么在右。
class _TraceView extends StatelessWidget {
  const _TraceView({required this.trace});

  final List<AiTraceEntry> trace;

  /// 有没有东西可画。正文段剪掉 JSON 之后可能是空的（只交了 JSON 的模型）。
  static bool hasContent(List<AiTraceEntry> trace) => trace.any(_visible);

  static bool _visible(AiTraceEntry e) => switch (e.kind) {
    AiTraceKind.tool => true,
    AiTraceKind.reasoning => e.text.trim().isNotEmpty,
    AiTraceKind.narration => e.prose.isNotEmpty,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = slang.Translations.of(context);
    final visible = trace.where(_visible).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in visible)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: switch (entry.kind) {
              AiTraceKind.tool => _ToolCallLine(call: entry.call!),
              AiTraceKind.reasoning => _ReasoningBlock(
                label: t.ai.searchTraceReasoning,
                text: entry.text.trim(),
                cs: cs,
              ),
              AiTraceKind.narration => Text(
                entry.prose,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.88),
                ),
              ),
            },
          ),
      ],
    );
  }
}

/// 一段原生思维链：左边一道竖线 + 小字淡色。
class _ReasoningBlock extends StatelessWidget {
  const _ReasoningBlock({
    required this.label,
    required this.text,
    required this.cs,
  });

  final String label;
  final String text;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.8),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 2),
          // ⛔ 不用等宽：思考链是散文不是代码，等宽字既窄又密，一眼看过去就是
          // 一坨 log。也不用 SelectableText：它的裸识别器 slop 恒 18，比滚动更深
          // 也更早赢，用户想滚这块会变成在选字。
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 模型查过 / 正在查的一次，一行。
///
/// ⭐ 这是过程记录里最有用的一种：思维链是它**打算**怎么做，工具调用是它
/// **真的**去查了、查到了什么。结果不对时，看一眼「试搜 "白金ディスコ" → 约 34
/// 条」就知道问题不在搜索词上。
class _ToolCallLine extends StatelessWidget {
  const _ToolCallLine({required this.call});

  final AiToolCall call;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 11,
            height: 11,
            child: call.running
                // 同时至多有一个在跑，不会堆出一排 ticker。
                ? CircularProgressIndicator(strokeWidth: 1.4, color: cs.primary)
                : Icon(Icons.done, size: 11, color: cs.primary),
          ),
        ),
        const SizedBox(width: 6),
        // ⭐ 查什么在左、查到什么在右，两栏分家而不是一条 `A → B` 的长句：用户扫
        // 这一块只为一件事——**数字**（0 条说明有条件把结果杀光了）。挤在句中间
        // 时它是第几个词全看关键词多长。
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
              maxLines: 3,
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
    );
  }
}

/// AI 搜索现在能不能用（有没有一份配好的供应商档案）。
///
/// ⛔ 用它来决定**点下去之后说什么**，不要用它决定那枚钮在不在场。一个功能的
/// 唯一入口按「配没配过」藏起来，等于新用户永远发现不了它——本项目已经在小
/// 尾巴上栽过一次（2026-09-20 用户报障：「菜单里根本没这个选项」）。
bool get isAiSearchAvailable =>
    Get.isRegistered<AiService>() &&
    Get.find<AiService>().isAvailable(AiTask.searchQuery);
