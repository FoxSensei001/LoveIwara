import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_search_input_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_controller.dart';
import 'package:i_iwara/app/ui/widgets/paged_search/paged_search_view.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 带搜索的 header 行：返回 / 标题（通常是分段胶囊）/ 搜索 / 动作胶囊。
///
/// 搜索平时只是一枚放大镜圆钮；点开后圆钮向左长成长条输入框，标题先淡出让位。
/// 长条里依次是：放大镜、输入框、范围图标、关闭键。
/// - 范围图标表示「只搜已加载 / 搜全部」，点开弹玻璃菜单选择；搜全部时它同时
///   报状态（加载进度圈 / 等确认 / 出错 / 已取消），已在「全部」时再点一次看详情。
/// - 关闭键：有字先清字，没字再收起（收起时退回「只搜已加载」）。
/// - 没字、没在搜全部、又失去焦点时自动收起；有字或在搜全部时一直展开。
/// - 窄屏（行宽 < [wideRowWidth]）展开时，右侧动作胶囊收起给输入框让位，
///   [keepActions] 为 true（如多选态要留着退出键）时照常显示。
/// - [search] 为 null（本地列表）时没有范围图标。
///
/// 每个 tab 一份 [input]，切 tab 时换掉 [search] / [input] 即可；焦点、展开状态
/// 与「已弹过等待提示」的记录跟着本组件走。
class PagedSearchHeaderRow extends StatefulWidget {
  const PagedSearchHeaderRow({
    super.key,
    required this.leading,
    required this.title,
    this.actions,
    this.keepActions = false,
    required this.search,
    required this.input,
    required this.hintText,
    required this.onChanged,
    required this.keyPrefix,
    this.labels = PagedSearchLabels.items,
  });

  /// 行首，通常是返回圆钮。
  final Widget leading;

  /// 中间的标题区，通常是分段胶囊；搜索展开时淡出。
  final Widget title;

  /// 行尾动作胶囊。
  final Widget? actions;
  final bool keepActions;

  final PagedSearchController<dynamic>? search;
  final TextEditingController input;
  final String hintText;

  /// 输入或清空后回调，参数是新的搜索词。
  final ValueChanged<String> onChanged;

  /// 内部控件的 key 前缀：`<prefix>-search-toggle` / `-search-field` /
  /// `-search-scope` / `-search-close`。
  final String keyPrefix;

  final PagedSearchLabelsOf labels;

  /// 不小于它时，搜索展开也保留动作胶囊。
  static const double wideRowWidth = 600;

  @override
  State<PagedSearchHeaderRow> createState() => _PagedSearchHeaderRowState();
}

class _PagedSearchHeaderRowState extends State<PagedSearchHeaderRow>
    with SingleTickerProviderStateMixin {
  static const double _gap = 8;
  static const double _button = GlassTokens.pillHeight;

  /// 宽屏上输入框展开的最大宽度。
  static const double _maxPillWidth = 480;

  /// 输入框旁边至少还剩这么宽，标题才留在原地不让位。
  static const double _minTitleBeside = 240;

  final FocusNode _focus = FocusNode();
  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    reverseDuration: const Duration(milliseconds: 300),
  );
  bool _open = false;

  /// 菜单或详情弹窗开着时焦点会被路由拿走，这期间不自动收起。
  bool _overlayOpen = false;

  /// 已为「全量加载要等很久」自动弹过详情的搜索，免得每次通知都再弹一遍。
  final Set<PagedSearchController<dynamic>> _warned = {};

  bool get _mustStayOpen =>
      widget.input.text.isNotEmpty || (widget.search?.searchAll ?? false);

  @override
  void initState() {
    super.initState();
    _open = _mustStayOpen;
    _morph.value = _open ? 1 : 0;
    _focus.addListener(_onFocusChanged);
    widget.search?.addListener(_onSearchChanged);
    _onSearchChanged();
  }

  @override
  void didUpdateWidget(PagedSearchHeaderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.search != widget.search) {
      oldWidget.search?.removeListener(_onSearchChanged);
      widget.search?.addListener(_onSearchChanged);
      _onSearchChanged();
    }
    if (oldWidget.search != widget.search || oldWidget.input != widget.input) {
      // 切 tab：新 tab 有搜索词就展开，否则只有正在输入时才保持展开
      if (_mustStayOpen) {
        _setOpen(true);
      } else if (!_focus.hasFocus) {
        _setOpen(false);
      }
    }
  }

  @override
  void dispose() {
    widget.search?.removeListener(_onSearchChanged);
    _focus.removeListener(_onFocusChanged);
    _focus.dispose();
    _morph.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    if (_open == open) return;
    setState(() => _open = open);
    open ? _morph.forward() : _morph.reverse();
  }

  void _onFocusChanged() {
    if (_focus.hasFocus) {
      _setOpen(true);
    } else {
      _collapseIfIdle();
    }
  }

  void _collapseIfIdle() {
    if (!mounted || _overlayOpen || _focus.hasFocus || _mustStayOpen) return;
    _setOpen(false);
  }

  void _expand() {
    _setOpen(true);
    _focus.requestFocus();
  }

  /// 关闭键：有字先清字（留在输入里），没字才整个收起。
  void _closeOrClear() {
    final input = widget.input;
    if (input.text.isNotEmpty) {
      input.clear();
      widget.onChanged('');
      _focus.requestFocus();
      return;
    }
    final search = widget.search;
    if (search != null && search.searchAll) search.useLoaded();
    _focus.unfocus();
    _setOpen(false);
  }

  void _onSearchChanged() {
    _warned.removeWhere((search) => !search.awaitingConfirmation);
    final search = widget.search;
    // 搜全部可能从别处开始（如详情弹窗里的「重试」）：结果已经盖在列表上了，
    // 搜索框也得跟着展开，不然用户找不到退出口
    if (search != null && search.searchAll && !_open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && search == widget.search && search.searchAll) {
          _setOpen(true);
        }
      });
    }
    if (search == null ||
        !search.awaitingConfirmation ||
        _overlayOpen ||
        !_warned.add(search)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && search == widget.search && search.awaitingConfirmation) {
        _showDetails(search);
      } else {
        _warned.remove(search);
      }
    });
  }

  Future<void> _withOverlay(Future<void> Function() body) async {
    _overlayOpen = true;
    try {
      await body();
    } finally {
      _overlayOpen = false;
      _collapseIfIdle();
    }
  }

  Future<void> _showDetails(PagedSearchController<dynamic> search) {
    if (_overlayOpen) return Future.value();
    _focus.unfocus();
    return _withOverlay(
      () => showAppDialog<void>(
        PagedSearchDetailsDialog(search: search, labels: widget.labels),
      ),
    );
  }

  Future<void> _pickScope(
    BuildContext anchorContext,
    PagedSearchController<dynamic> search,
    PagedSearchLabels labels,
  ) {
    if (_overlayOpen) return Future.value();
    return _withOverlay(() async {
      final status = _allScopeStatus(search, labels);
      final picked = await showGlassMenu<int>(
        anchorContext: anchorContext,
        entries: [
          GlassMenuOption<int>(
            value: 0,
            label: labels.scopeLoaded,
            icon: Icons.manage_search,
            description: labels.loadedCount(
              count: search.loadedCount,
              total: search.totalCount?.toString() ?? '?',
            ),
            selected: !search.searchAll,
          ),
          GlassMenuOption<int>(
            value: 1,
            label: labels.scopeAll,
            icon: Icons.travel_explore,
            description: status,
            selected: search.searchAll,
          ),
        ],
      );
      if (!mounted || picked == null) return;
      if (picked == 0) {
        search.useLoaded();
      } else if (search.searchAll) {
        // 已经在搜全部：再点一次是想看进度 / 重试 / 取消
        await _showDetails(search);
      } else {
        search.startAll();
      }
    });
  }

  /// 「全部」那一行的小字：只报需要用户知道的状态，完成时靠对勾就够了。
  String? _allScopeStatus(
    PagedSearchController<dynamic> search,
    PagedSearchLabels labels,
  ) {
    if (!search.searchAll) return null;
    if (search.error != null) return labels.failed;
    if (search.cancelled) return labels.cancelled;
    if (search.probing) return labels.probing;
    if (search.loading || search.awaitingConfirmation) {
      return '${search.scannedCount} / ${search.totalCount ?? '?'}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GlassTokens.headerRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final actions = widget.actions;
            final showActions =
                !_open ||
                widget.keepActions ||
                constraints.maxWidth >= PagedSearchHeaderRow.wideRowWidth;
            return Row(
              children: [
                widget.leading,
                const SizedBox(width: _gap),
                Expanded(child: _buildMorphArea(context)),
                if (actions != null)
                  GlassCapsuleReveal(
                    visible: showActions,
                    child: Padding(
                      padding: const EdgeInsets.only(left: _gap),
                      child: actions,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 标题与搜索共用的那一段：标题固定占左侧，搜索从右端的圆钮向左长开。
  ///
  /// 时序两段基本不重叠：标题先在前三成多淡出，长条从两成半起才开始变宽，
  /// 所以标题的布局宽度全程不变（不会在半路从分段胶囊退化成下拉钮）。
  Widget _buildMorphArea(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // 宽屏：输入框长到 [_maxPillWidth] 就停，标题留在左边不让位
        // （一条横跨整屏的输入框又空又难找焦点）
        final wide = width >= _maxPillWidth + _gap + _minTitleBeside;
        final pillTarget = wide ? _maxPillWidth : width;
        final titleWidth = wide
            ? width - _maxPillWidth - _gap
            : math.max(0.0, width - _button - _gap);
        return SizedBox(
          width: width,
          height: _button,
          child: AnimatedBuilder(
            animation: _morph,
            builder: (context, _) {
              final t = _morph.value;
              final titleOut = wide
                  ? 0.0
                  : const Interval(0, .35, curve: Curves.easeOut).transform(t);
              final grow = Interval(
                wide ? 0 : .25,
                1,
                curve: GlassTokens.motionCurve,
              ).transform(t);
              final pillWidth = lerpDouble(_button, pillTarget, grow)!;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (titleOut < 1)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: titleWidth,
                      child: IgnorePointer(
                        ignoring: titleOut > 0,
                        child: Opacity(
                          opacity: 1 - titleOut,
                          child: Transform.scale(
                            scale: 1 - .06 * titleOut,
                            alignment: Alignment.centerLeft,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: widget.title,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: pillWidth,
                    child: _buildPill(context, t, pillTarget),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPill(BuildContext context, double t, double fullWidth) {
    final t9n = slang.Translations.of(context);
    final contentIn = const Interval(
      .55,
      1,
      curve: Curves.easeOut,
    ).transform(t);
    final iconOut = const Interval(0, .3, curve: Curves.easeOut).transform(t);
    // ⛔ 这里的结构收起 / 展开两态必须完全一样：onTap、tooltip 这类「有 ↔ 无」
    // 的切换会让玻璃换一套包装，输入框整只重建，刚拿到的焦点随之丢掉，
    // 没字时紧接着就被判成「失焦收起」。输入框因此也常驻（收起时透明、不接手势），
    // 点开那一刻才有东西可以接焦点。
    return Semantics(
      button: !_open,
      label: t9n.common.search,
      child: GlassSurface(
        key: ValueKey('${widget.keyPrefix}-search-toggle'),
        height: _button,
        borderRadius: BorderRadius.circular(_button / 2),
        clipContent: true,
        // 收起态整只圆钮可点；展开后点在空白处（左内边距、图标之间的缝）
        // 也给输入框取焦，深处的输入框与图标键照样先赢
        onTap: _expand,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1 - iconOut,
              child: const Icon(Icons.search, size: GlassTokens.iconSize),
            ),
            // 内容按展开后的宽度一次排好，靠右锚定；长开途中多出来的
            // 部分由胶囊圆角裁掉，输入框不会被挤成一条缝。
            OverflowBox(
              alignment: Alignment.centerRight,
              minWidth: fullWidth,
              maxWidth: fullWidth,
              child: IgnorePointer(
                ignoring: !_open,
                child: Opacity(
                  opacity: contentIn,
                  child: _buildContent(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final search = widget.search;
    return ListenableBuilder(
      listenable: Listenable.merge([widget.input, ?search]),
      builder: (context, _) {
        final labels = widget.labels(t);
        return Padding(
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: GlassSearchInputField(
                  key: ValueKey('${widget.keyPrefix}-search-field'),
                  controller: widget.input,
                  focusNode: _focus,
                  hintText: widget.hintText,
                  onChanged: () => widget.onChanged(widget.input.text),
                  onSubmitted: (_) => _focus.unfocus(),
                ),
              ),
              if (search != null) _buildScopeButton(context, search, labels),
              GlassIconButton(
                key: ValueKey('${widget.keyPrefix}-search-close'),
                icon: const Icon(Icons.close),
                tooltip: widget.input.text.isNotEmpty
                    ? t.common.clear
                    : t.common.close,
                onPressed: _closeOrClear,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 范围图标：只搜已加载是「列表里找」，搜全部是「地球」；搜全部时兼报状态。
  Widget _buildScopeButton(
    BuildContext context,
    PagedSearchController<dynamic> search,
    PagedSearchLabels labels,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final total = search.totalCount ?? 0;
    final Widget icon;
    Color? color;
    if (!search.searchAll) {
      icon = const Icon(Icons.manage_search);
    } else if (search.loading) {
      icon = SizedBox(
        key: const ValueKey('loading'),
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: search.probing || total == 0
              ? null
              : (search.scannedCount / total).clamp(0.0, 1.0),
        ),
      );
    } else if (search.error != null) {
      icon = const Icon(Icons.error_outline);
      color = scheme.error;
    } else if (search.awaitingConfirmation) {
      icon = const Icon(Icons.schedule);
      color = scheme.tertiary;
    } else if (search.cancelled) {
      icon = const Icon(Icons.pause_circle_outline);
    } else {
      icon = const Icon(Icons.travel_explore);
    }
    return Builder(
      builder: (anchorContext) => GlassIconButton(
        key: ValueKey('${widget.keyPrefix}-search-scope'),
        icon: icon,
        color: color,
        opensOverlay: true,
        tooltip: search.searchAll ? labels.scopeAll : labels.scopeLoaded,
        onPressed: () => _pickScope(anchorContext, search, labels),
      ),
    );
  }
}

/// 标签宽度封顶的玻璃下拉钮：分段胶囊摆不下时的替身。
///
/// 放大字号或长译文时标签省略，下拉箭头始终留在胶囊内。
///
/// [prefix] 是标签前一段弱化的说明（如关注页的「谁的列表」）：位置不够时
/// 先省略它，当前选中的那一段尽量保持完整。
class GlassBoundedDropdown extends StatelessWidget {
  const GlassBoundedDropdown({
    super.key,
    required this.width,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.labelKey,
    this.prefix,
  });

  final double width;
  final List<GlassSegmentItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Key? labelKey;
  final String? prefix;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: GlassDropdownTrigger(
      child: Expanded(child: _buildLabel(context)),
      onTap: (anchorContext) async {
        final picked = await showGlassMenu<int>(
          anchorContext: anchorContext,
          entries: [
            for (var i = 0; i < items.length; i++)
              GlassMenuOption<int>(
                value: i,
                label: items[i].label,
                selected: i == selectedIndex,
              ),
          ],
        );
        if (context.mounted && picked != null) onChanged(picked);
      },
    ),
  );

  Widget _buildLabel(BuildContext context) {
    const labelStyle = TextStyle(fontWeight: FontWeight.w600);
    final labelText = items[selectedIndex].label;
    final label = Text(
      labelText,
      key: labelKey,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: labelStyle,
    );
    final prefix = this.prefix;
    if (prefix == null || prefix.isEmpty) return label;
    final muted = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    const separator = '·';
    const separatorGap = 4.0;
    // 量的是箭头与内边距之外真正留给文字的宽度，不是整只胶囊的 [width]。
    return LayoutBuilder(
      builder: (context, constraints) {
        final needed =
            _textWidth(context, labelText, labelStyle) +
            _textWidth(context, separator, muted) +
            separatorGap * 2 +
            math.min(_textWidth(context, prefix, muted), _minPrefixWidth);
        // 连几个字的 prefix 都摆不下（窄屏 + 放大字号）：只留标签，
        // 别把 prefix 挤成一个省略号。
        if (constraints.maxWidth < needed) return label;
        return Row(
          children: [
            Flexible(
              child: Text(
                prefix,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: separatorGap),
              child: Text(separator, style: muted),
            ),
            label,
          ],
        );
      },
    );
  }

  /// prefix 至少露出这么宽（约两三个字）才值得显示。
  static const double _minPrefixWidth = 32;

  static double _textWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
