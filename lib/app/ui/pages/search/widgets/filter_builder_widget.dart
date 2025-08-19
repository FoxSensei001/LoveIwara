import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_row_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/responsive_dialog_widget.dart';

class FilterBuilderWidget extends StatefulWidget {
  final SearchSegment initialSegment;
  final List<Filter>? initialFilters;
  final Function(List<Filter>) onFiltersChanged;
  final String? searchTerm;
  final bool destroyOnClose;

  const FilterBuilderWidget({
    super.key,
    required this.initialSegment,
    this.initialFilters,
    required this.onFiltersChanged,
    this.searchTerm,
    this.destroyOnClose = true,
  });

  @override
  State<FilterBuilderWidget> createState() => _FilterBuilderWidgetState();
}

class _FilterBuilderWidgetState extends State<FilterBuilderWidget> {
  late SearchSegment _currentSegment;
  late List<Filter> _filters;
  late List<Filter> _originalFilters; // 保存原始筛选项
  bool _copied = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentSegment = widget.initialSegment;
    _originalFilters =
        widget.initialFilters?.map((f) => f.copyWith()).toList() ?? [];
    _filters = _originalFilters.map((f) => f.copyWith()).toList(); // 深拷贝初始筛选项
  }

  @override
  void didUpdateWidget(FilterBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSegment != widget.initialSegment) {
      _currentSegment = widget.initialSegment;
      _originalFilters =
          widget.initialFilters?.map((f) => f.copyWith()).toList() ?? [];
      _filters = _originalFilters.map((f) => f.copyWith()).toList();
      widget.onFiltersChanged(_filters);
    }
  }

  void _addFilter() {
    final contentType = FilterConfig.getContentType(_currentSegment);
    if (contentType == null || contentType.fields.isEmpty) return;

    // 显示字段选择对话框
    _showFieldSelectionDialog(context, contentType.fields);
  }

  void _showFieldSelectionDialog(
    BuildContext context,
    List<FilterField> availableFields,
  ) {
    final t = slang.Translations.of(context);
    ResponsiveDialog.show(
      context: context,
      title: t.searchFilter.selectField,
      content: ListView.builder(
        itemCount: availableFields.length,
        itemBuilder: (context, index) {
          final field = availableFields[index];
          return ListTile(
            leading: _getFieldIcon(field),
            title: Text(field.displayName),
            subtitle: Text(field.name),
            onTap: () {
              AppService.tryPop();
              _createFilterWithField(field);
            },
          );
        },
      ),
    );
  }

  Widget _getFieldIcon(FilterField field) {
    // 优先使用配置中的图标
    if (field.iconData != null) {
      return Icon(field.iconData, color: field.iconColor);
    }

    // 如果没有配置图标，则根据字段类型提供默认图标
    switch (field.type) {
      case FilterFieldType.STRING:
        return const Icon(Icons.text_fields, color: Colors.blue);
      case FilterFieldType.NUMBER:
        return const Icon(Icons.numbers, color: Colors.green);
      case FilterFieldType.BOOLEAN:
        return const Icon(Icons.check_box, color: Colors.orange);
      case FilterFieldType.DATE:
        return const Icon(Icons.calendar_today, color: Colors.purple);
      case FilterFieldType.STRING_ARRAY:
        return const Icon(Icons.label, color: Colors.red);
      case FilterFieldType.SELECT:
        return const Icon(Icons.arrow_drop_down, color: Colors.indigo);
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

    final newFilter = Filter(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      field: field.name,
      operator: operator,
      value: defaultValue,
      locale: field.isLocalizable ? 'en' : null,
    );

    setState(() {
      _filters.add(newFilter);
    });
    // 通知父组件筛选项已更新（临时状态）
    widget.onFiltersChanged(_filters);
  }

  void _updateFilter(String id, Filter newFilter) {
    setState(() {
      final index = _filters.indexWhere((f) => f.id == id);
      if (index != -1) {
        _filters[index] = newFilter;
      }
    });
    // 通知父组件筛选项已更新（临时状态）
    widget.onFiltersChanged(_filters);
  }

  void _removeFilter(String id) {
    setState(() {
      _filters.removeWhere((f) => f.id == id);
    });
    // 通知父组件筛选项已更新（临时状态）
    widget.onFiltersChanged(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
    // 通知父组件筛选项已更新（临时状态）
    widget.onFiltersChanged(_filters);
  }

  // 获取当前的筛选项列表
  List<Filter> get currentFilters => _filters;

  String _generateQuery() {
    final contentType = FilterConfig.getContentType(_currentSegment);
    if (contentType == null) return '';

    final filterStrings = _filters
        .map((filter) {
          final field = contentType.fields.firstWhere(
            (f) => f.name == filter.field,
            orElse: () => contentType.fields.first,
          );
          return FilterConfig.generateFilterString(filter, field);
        })
        .where((str) => str.isNotEmpty)
        .join(' ');

    return filterStrings.trim();
  }

  void _copyToClipboard() {
    final query = _generateQuery();
    Clipboard.setData(ClipboardData(text: query));

    setState(() {
      _copied = true;
    });

    final t = slang.Translations.of(context);
    showToastWidget(
      MDToastWidget(
        message: t.searchFilter.copied,
        type: MDToastType.success,
      ),
      position: ToastPosition.bottom,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  // 验证表单
  bool _validateForm() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  // 验证范围类型的值
  String? _validateRangeValue(Filter filter) {
    if (filter.operator != FilterOperator.RANGE) return null;
    
    if (filter.value is! Map) return slang.t.searchFilter.rangeValueFormatError;
    
    final rangeValue = filter.value as Map;
    final from = rangeValue['from']?.toString().trim();
    final to = rangeValue['to']?.toString().trim();
    
    // 对于范围类型，要求必须填写两个值
    if (from == null || from.isEmpty) {
      return slang.t.searchFilter.pleaseFillStartValue;
    }
    
    if (to == null || to.isEmpty) {
      return slang.t.searchFilter.pleaseFillEndValue;
    }
    
    // 验证逻辑关系
    final field = FilterConfig.getContentType(_currentSegment)?.fields
        .firstWhere((f) => f.name == filter.field);
    
    if (field?.type == FilterFieldType.NUMBER) {
      try {
        final fromNum = double.parse(from);
        final toNum = double.parse(to);
        if (fromNum >= toNum) {
          return slang.t.searchFilter.startValueMustBeLessThanEndValue;
        }
      } catch (e) {
        return slang.t.searchFilter.pleaseEnterValidNumber;
      }
    } else if (field?.type == FilterFieldType.DATE) {
      try {
        final fromDate = DateTime.parse(from);
        final toDate = DateTime.parse(to);
        if (fromDate.isAfter(toDate)) {
          return slang.t.searchFilter.startDateMustBeBeforeEndDate;
        }
      } catch (e) {
        return slang.t.searchFilter.pleaseEnterValidDate;
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final contentType = FilterConfig.getContentType(_currentSegment);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 固定在顶部的筛选项数量显示和操作按钮
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 筛选项数量显示
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slang.t.searchFilter.filterCount(count: _filters.length),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // 操作按钮 - 居右显示
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_filters.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: _clearAllFilters,
                          icon: const Icon(Icons.clear_all, color: Colors.white),
                          tooltip: slang.t.searchFilter.clearAll,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _addFilter,
                        icon: const Icon(Icons.add, color: Colors.white),
                        tooltip: slang.t.searchFilter.add,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 可滚动的内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 筛选项列表
                    if (_filters.isNotEmpty) ...[
                      ...(_filters
                          .map(
                            (filter) => FilterRowWidget(
                              filter: filter,
                              availableFields: contentType?.fields ?? [],
                              onUpdate: _updateFilter,
                              onRemove: _removeFilter,
                              onValidate: _validateRangeValue,
                            ),
                          )
                          .toList()),
                      const SizedBox(height: 16),
                    ],

                    // 生成的查询
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                slang.t.searchFilter.generatedQuery,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              IconButton(
                                onPressed: _validateForm() ? _copyToClipboard : null,
                                icon: Icon(_copied ? Icons.check : Icons.copy),
                                tooltip: slang.t.searchFilter.copyToClipboard,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SelectableText(
                              _generateQuery(),
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
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
