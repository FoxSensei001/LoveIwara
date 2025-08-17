import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_row_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/services/app_service.dart';

class FilterBuilderWidget extends StatefulWidget {
  final SearchSegment initialSegment;
  final List<Filter>? initialFilters;
  final Function(List<Filter>) onFiltersChanged;
  final String? searchTerm;

  const FilterBuilderWidget({
    super.key,
    required this.initialSegment,
    this.initialFilters,
    required this.onFiltersChanged,
    this.searchTerm,
  });

  @override
  State<FilterBuilderWidget> createState() => _FilterBuilderWidgetState();
}

class _FilterBuilderWidgetState extends State<FilterBuilderWidget> {
  late SearchSegment _currentSegment;
  late List<Filter> _filters;
  late String _searchTerm;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _currentSegment = widget.initialSegment;
    _filters = widget.initialFilters?.toList() ?? [];
    _searchTerm = widget.searchTerm ?? '';
  }

  @override
  void didUpdateWidget(FilterBuilderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSegment != widget.initialSegment) {
      _currentSegment = widget.initialSegment;
      _filters = [];
      widget.onFiltersChanged(_filters);
    }
  }

  void _addFilter() {
    final contentType = FilterConfig.getContentType(_currentSegment);
    if (contentType == null || contentType.fields.isEmpty) return;

    // 显示字段选择对话框
    _showFieldSelectionDialog(context, contentType.fields);
  }

  void _showFieldSelectionDialog(BuildContext context, List<FilterField> availableFields) {
    Get.dialog(
      AlertDialog(
        title: const Text('选择字段'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableFields.length,
            itemBuilder: (context, index) {
              final field = availableFields[index];
              return ListTile(
                leading: _getFieldIcon(field.type),
                title: Text(field.displayName),
                subtitle: Text(field.name),
                onTap: () {
                  AppService.tryPop();
                  _createFilterWithField(field);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _getFieldIcon(FilterFieldType type) {
    switch (type) {
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
    }
  }

  void _createFilterWithField(FilterField field) {
    final operators = FilterConfig.getOperatorsForType(field.type);
    final operator = operators.isNotEmpty ? operators.first : FilterOperator.EQUALS;

    dynamic defaultValue = '';
    if (field.type == FilterFieldType.BOOLEAN) {
      defaultValue = 'true';
    } else if (field.type == FilterFieldType.STRING_ARRAY) {
      defaultValue = <String>[];
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
    widget.onFiltersChanged(_filters);
  }

  void _updateFilter(String id, Filter newFilter) {
    setState(() {
      final index = _filters.indexWhere((f) => f.id == id);
      if (index != -1) {
        _filters[index] = newFilter;
      }
    });
    widget.onFiltersChanged(_filters);
  }

  void _removeFilter(String id) {
    setState(() {
      _filters.removeWhere((f) => f.id == id);
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
  }

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
    
    showToastWidget(
      MDToastWidget(
        message: slang.t.download.copySuccess,
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

  @override
  Widget build(BuildContext context) {
    final contentType = FilterConfig.getContentType(_currentSegment);
    final t = slang.Translations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '筛选项生成器',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_filters.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('清空'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addFilter,
                    icon: const Icon(Icons.add),
                    label: const Text('添加筛选项'),
                  ),
                ],
              ),
            ],
          ),
          
                      const SizedBox(height: 16),
          
          // 筛选项列表
          if (_filters.isNotEmpty) ...[
            Text(
              '筛选项 (${_filters.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...(_filters.map((filter) => FilterRowWidget(
              filter: filter,
              availableFields: contentType?.fields ?? [],
              onUpdate: _updateFilter,
              onRemove: _removeFilter,
            )).toList()),
            const SizedBox(height: 16),
          ],
          
          // 生成的查询
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '生成的查询',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: Icon(_copied ? Icons.check : Icons.copy),
                      tooltip: '复制到剪贴板',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
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
    );
  }
}
