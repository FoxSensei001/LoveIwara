import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_row_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 打开搜索的「筛选」抽屉。
///
/// 改动**即时生效**：加/删筛选项、换字段或运算符立刻回调；输入框里敲的值等
/// 350ms 停手再回调（每敲一个字母就发一次请求既没意义又打服务端），且只有当
/// 全部筛选项都通过校验时才发——区间只填了一头就发出去，服务端直接 500。
Future<void> showSearchFilterDrawer({
  required BuildContext context,
  required SearchSegment segment,
  required List<Filter> initialFilters,
  required void Function(List<Filter> filters) onFiltersChanged,
}) {
  return showGlassSideDrawer<void>(
    context: context,
    builder: (_) => SearchFilterDrawer(
      segment: segment,
      initialFilters: initialFilters,
      onFiltersChanged: onFiltersChanged,
    ),
  );
}

/// 搜索筛选抽屉：已保存搜索 · 筛选项列表 · 生成的查询。
///
/// 前身是 `FilterBuilderWidget` + `ResponsiveDialog`（宽屏 800px 居中弹窗 /
/// 窄屏整页）。抽屉里可用宽度只有 380~460，筛选项卡片一律按窄列排版
/// （见 [FilterRowWidget] 现在按自身约束而不是屏幕宽判断）。
class SearchFilterDrawer extends StatefulWidget {
  const SearchFilterDrawer({
    super.key,
    required this.segment,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  final SearchSegment segment;
  final List<Filter> initialFilters;
  final void Function(List<Filter> filters) onFiltersChanged;

  @override
  State<SearchFilterDrawer> createState() => _SearchFilterDrawerState();
}

class _SearchFilterDrawerState extends State<SearchFilterDrawer> {
  late List<Filter> _filters;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _debounce;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters.map((f) => f.copyWith()).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------ 即时生效

  /// 有筛选项填得不合法（例如区间只填了一头）时不往外发。
  bool get _isValid => _filters.every((f) => _validateRangeValue(f) == null);

  void _emit({required bool immediate}) {
    _debounce?.cancel();
    void push() {
      if (!mounted || !_isValid) return;
      widget.onFiltersChanged(_filters.map((f) => f.copyWith()).toList());
    }

    if (immediate) {
      push();
    } else {
      _debounce = Timer(const Duration(milliseconds: 350), push);
    }
  }

  // -------------------------------------------------------------- 筛选项

  Future<void> _addFilter(BuildContext anchorContext) async {
    final contentType = FilterConfig.getContentType(widget.segment);
    if (contentType == null || contentType.fields.isEmpty) return;

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        for (final field in contentType.fields)
          GlassMenuOption<String>(
            value: field.name,
            icon: field.iconData ?? _defaultFieldIcon(field.type),
            label: field.displayName,
            description: field.name,
          ),
      ],
    );
    if (picked == null) return;

    final field = contentType.fields.firstWhere((f) => f.name == picked);
    _createFilterWithField(field);
  }

  static IconData _defaultFieldIcon(FilterFieldType type) {
    switch (type) {
      case FilterFieldType.STRING:
        return Icons.text_fields;
      case FilterFieldType.NUMBER:
        return Icons.numbers;
      case FilterFieldType.BOOLEAN:
        return Icons.check_box;
      case FilterFieldType.DATE:
        return Icons.calendar_today;
      case FilterFieldType.STRING_ARRAY:
        return Icons.label;
      case FilterFieldType.SELECT:
        return Icons.arrow_drop_down;
    }
  }

  void _createFilterWithField(FilterField field) {
    final operators = FilterConfig.getOperatorsForType(field.type);
    final operator = operators.isNotEmpty
        ? operators.first
        : FilterOperator.EQUALS;

    dynamic defaultValue = '';
    if (field.type == FilterFieldType.BOOLEAN) {
      defaultValue = 'true';
    } else if (field.type == FilterFieldType.STRING_ARRAY) {
      defaultValue = <String>[];
    } else if (field.type == FilterFieldType.SELECT) {
      defaultValue = field.options?.isNotEmpty == true
          ? field.options!.first.value
          : '';
    } else if (operator == FilterOperator.RANGE) {
      defaultValue = {'from': '', 'to': ''};
    }

    setState(() {
      _filters.add(
        Filter(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          field: field.name,
          operator: operator,
          value: defaultValue,
          locale: field.isLocalizable ? 'en' : null,
        ),
      );
    });
    // 新项通常还没填值，这一发只是让「筛选项 N 个」的角标跟上
    _emit(immediate: true);
  }

  void _updateFilter(String id, Filter newFilter) {
    final index = _filters.indexWhere((f) => f.id == id);
    if (index == -1) return;
    final old = _filters[index];
    setState(() => _filters[index] = newFilter);

    // 换字段 / 换运算符 / 换语言是「点一下就定了」的离散操作，立刻生效；
    // 只有值变了才可能是正在敲字，走防抖。
    final structural =
        old.field != newFilter.field ||
        old.operator != newFilter.operator ||
        old.locale != newFilter.locale;
    _emit(immediate: structural);
  }

  void _removeFilter(String id) {
    setState(() => _filters.removeWhere((f) => f.id == id));
    _emit(immediate: true);
  }

  void _clearAllFilters() {
    setState(_filters.clear);
    _emit(immediate: true);
  }

  /// 区间类型必须两头都填，且 from < to。返回 null 表示这一项没问题。
  String? _validateRangeValue(Filter filter) {
    if (filter.operator != FilterOperator.RANGE) return null;
    if (filter.value is! Map) return slang.t.searchFilter.rangeValueFormatError;

    final rangeValue = filter.value as Map;
    final from = rangeValue['from']?.toString().trim();
    final to = rangeValue['to']?.toString().trim();

    if (from == null || from.isEmpty) {
      return slang.t.searchFilter.pleaseFillStartValue;
    }
    if (to == null || to.isEmpty) {
      return slang.t.searchFilter.pleaseFillEndValue;
    }

    final field = FilterConfig.getContentType(
      widget.segment,
    )?.fields.firstWhere((f) => f.name == filter.field);

    if (field?.type == FilterFieldType.NUMBER) {
      try {
        if (double.parse(from) >= double.parse(to)) {
          return slang.t.searchFilter.startValueMustBeLessThanEndValue;
        }
      } catch (_) {
        return slang.t.searchFilter.pleaseEnterValidNumber;
      }
    } else if (field?.type == FilterFieldType.DATE) {
      try {
        if (DateTime.parse(from).isAfter(DateTime.parse(to))) {
          return slang.t.searchFilter.startDateMustBeBeforeEndDate;
        }
      } catch (_) {
        return slang.t.searchFilter.pleaseEnterValidDate;
      }
    }
    return null;
  }

  String _generateQuery() {
    final contentType = FilterConfig.getContentType(widget.segment);
    if (contentType == null) return '';

    return _filters
        .map((filter) {
          final field = contentType.fields.firstWhere(
            (f) => f.name == filter.field,
            orElse: () => contentType.fields.first,
          );
          return FilterConfig.generateFilterString(filter, field);
        })
        .where((str) => str.isNotEmpty)
        .join(' ')
        .trim();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateQuery()));
    setState(() => _copied = true);
    showAppToast(
      slang.t.searchFilter.copied,
      type: AppToastType.success,
      position: AppToastPosition.bottom,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final contentType = FilterConfig.getContentType(widget.segment);

    return Form(
      key: _formKey,
      child: GlassFilterDrawerShell(
        title: t.searchFilter.filterSettings,
        subtitle: t.searchFilter.drawerSubtitle,
        onReset: _filters.isEmpty ? null : _clearAllFilters,
        footer: _filters.isEmpty ? null : _buildQueryPreview(t),
        children: [
          GlassFilterSection(
            title: t.searchFilter.filterCount(count: _filters.length),
            actions: [
              Builder(
                builder: (anchorContext) => GlassIconButton(
                  standalone: true,
                  size: 32,
                  iconSize: 18,
                  icon: const Icon(Icons.add),
                  tooltip: t.searchFilter.add,
                  // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接
                  // 划到某一条上松手选中（见 GlassTapArea.opensOverlay）。
                  opensOverlay: true,
                  onPressed: () => _addFilter(anchorContext),
                ),
              ),
            ],
            child: _filters.isEmpty
                ? _buildEmptyState(t)
                : Column(
                    children: _filters
                        .map(
                          (filter) => FilterRowWidget(
                            key: ValueKey(filter.id),
                            filter: filter,
                            availableFields: contentType?.fields ?? [],
                            onUpdate: _updateFilter,
                            onRemove: _removeFilter,
                            onValidate: _validateRangeValue,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(slang.Translations t) {
    final colorScheme = Theme.of(context).colorScheme;
    return Builder(
      builder: (anchorContext) => InkWell(
        onTap: () => _addFilter(anchorContext),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: GlassTokens.stroke(colorScheme),
              width: GlassTokens.strokeWidth,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.filter_alt_outlined,
                size: 36,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 10),
              Text(
                '${t.common.noData} · ${t.searchFilter.add}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 贴底常驻的「生成的查询」：抽屉里改一下就变一次，放在滚动区里会滚出视野。
  Widget _buildQueryPreview(slang.Translations t) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 10),
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GlassTokens.stroke(colorScheme),
          width: GlassTokens.strokeWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.searchFilter.generatedQuery,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isValid ? _copyToClipboard : null,
                icon: Icon(_copied ? Icons.check : Icons.copy, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: t.searchFilter.copyToClipboard,
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              _generateQuery(),
              maxLines: 3,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
