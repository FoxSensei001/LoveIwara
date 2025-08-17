import 'package:flutter/material.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';

class FilterRowWidget extends StatelessWidget {
  final Filter filter;
  final List<FilterField> availableFields;
  final Function(String, Filter) onUpdate;
  final Function(String) onRemove;

  const FilterRowWidget({
    super.key,
    required this.filter,
    required this.availableFields,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final selectedField = availableFields.firstWhere(
      (f) => f.name == filter.field,
      orElse: () => availableFields.first,
    );
    
    final availableOperators = FilterConfig.getOperatorsForType(selectedField.type);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 字段选择
              Expanded(
                flex: 2,
                child: _buildFieldSelector(context, selectedField, availableFields),
              ),
              const SizedBox(width: 8),
              
              // 语言选择（如果字段支持本地化）
              if (selectedField.isLocalizable) ...[
                Expanded(
                  flex: 1,
                  child: _buildLocaleSelector(context),
                ),
                const SizedBox(width: 8),
              ],
              
              // 操作符选择
              Expanded(
                flex: 2,
                child: _buildOperatorSelector(context, filter.operator, availableOperators),
              ),
              const SizedBox(width: 8),
              
              // 值输入
              Expanded(
                flex: 3,
                child: _buildValueInput(context, filter, selectedField),
              ),
              const SizedBox(width: 8),
              
              // 删除按钮
              _buildDeleteButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(BuildContext context, FilterField selectedField, List<FilterField> availableFields) {
    return DropdownButtonFormField<String>(
      value: filter.field,
      decoration: InputDecoration(
        labelText: '字段',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: availableFields.map((field) {
        return DropdownMenuItem<String>(
          value: field.name,
          child: Text(field.displayName),
        );
      }).toList(),
      onChanged: (String? newFieldName) {
        if (newFieldName != null) {
          final newField = availableFields.firstWhere((f) => f.name == newFieldName);
          final newOperators = FilterConfig.getOperatorsForType(newField.type);
          final newOperator = newOperators.isNotEmpty ? newOperators.first : FilterOperator.EQUALS;
          
          dynamic defaultValue = '';
          if (newField.type == FilterFieldType.BOOLEAN) {
            defaultValue = 'true';
          } else if (newField.type == FilterFieldType.STRING_ARRAY) {
            defaultValue = <String>[];
          } else if (newOperator == FilterOperator.RANGE) {
            defaultValue = {'from': '', 'to': ''};
          }

          onUpdate(filter.id, Filter(
            id: filter.id,
            field: newFieldName,
            operator: newOperator,
            value: defaultValue,
            locale: newField.isLocalizable ? 'en' : null,
          ));
        }
      },
    );
  }

  Widget _buildLocaleSelector(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: filter.locale ?? 'en',
      decoration: InputDecoration(
        labelText: '语言',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('en')),
        DropdownMenuItem(value: 'ja', child: Text('ja')),
        DropdownMenuItem(value: 'zh', child: Text('zh')),
      ],
      onChanged: (String? newLocale) {
        if (newLocale != null) {
          onUpdate(filter.id, filter.copyWith(locale: newLocale));
        }
      },
    );
  }

  Widget _buildOperatorSelector(BuildContext context, FilterOperator selectedOperator, List<FilterOperator> availableOperators) {
    return DropdownButtonFormField<FilterOperator>(
      value: selectedOperator,
      decoration: InputDecoration(
        labelText: '操作符',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: availableOperators.map((operator) {
        return DropdownMenuItem<FilterOperator>(
          value: operator,
          child: Text(FilterConfig.getOperatorLabel(operator)),
        );
      }).toList(),
      onChanged: (FilterOperator? newOperator) {
        if (newOperator != null) {
          dynamic value = filter.value;
          if (newOperator == FilterOperator.RANGE && value is! Map) {
            value = {'from': '', 'to': ''};
          } else if (newOperator != FilterOperator.RANGE && value is Map) {
            value = '';
          }
          onUpdate(filter.id, filter.copyWith(operator: newOperator, value: value));
        }
      },
    );
  }

  Widget _buildValueInput(BuildContext context, Filter filter, FilterField field) {
    if (filter.operator == FilterOperator.RANGE) {
      return _buildRangeInput(context, filter, field);
    }

    switch (field.type) {
      case FilterFieldType.BOOLEAN:
        return _buildBooleanInput(context, filter);
      case FilterFieldType.DATE:
        return _buildDateInput(context, filter);
      case FilterFieldType.NUMBER:
        return _buildNumberInput(context, filter);
      case FilterFieldType.STRING_ARRAY:
        return _buildStringArrayInput(context, filter);
      default:
        return _buildStringInput(context, filter);
    }
  }

  Widget _buildRangeInput(BuildContext context, Filter filter, FilterField field) {
    final fromValue = filter.value is Map ? filter.value['from'] ?? '' : '';
    final toValue = filter.value is Map ? filter.value['to'] ?? '' : '';

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: fromValue,
            decoration: InputDecoration(
              labelText: '从',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: field.type == FilterFieldType.DATE ? null : TextInputType.number,
            onChanged: (value) {
              final currentValue = filter.value is Map ? Map<String, dynamic>.from(filter.value) : {'from': '', 'to': ''};
              currentValue['from'] = value;
              onUpdate(filter.id, filter.copyWith(value: currentValue));
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text('到'),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: toValue,
            decoration: InputDecoration(
              labelText: '到',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: field.type == FilterFieldType.DATE ? null : TextInputType.number,
            onChanged: (value) {
              final currentValue = filter.value is Map ? Map<String, dynamic>.from(filter.value) : {'from': '', 'to': ''};
              currentValue['to'] = value;
              onUpdate(filter.id, filter.copyWith(value: currentValue));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBooleanInput(BuildContext context, Filter filter) {
    return DropdownButtonFormField<String>(
      value: filter.value?.toString() ?? 'true',
      decoration: InputDecoration(
        labelText: '值',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: const [
        DropdownMenuItem(value: 'true', child: Text('是')),
        DropdownMenuItem(value: 'false', child: Text('否')),
      ],
      onChanged: (String? value) {
        if (value != null) {
          onUpdate(filter.id, filter.copyWith(value: value));
        }
      },
    );
  }

  Widget _buildDateInput(BuildContext context, Filter filter) {
    return TextFormField(
      initialValue: filter.value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: '日期',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: filter.value != null ? DateTime.parse(filter.value) : DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onUpdate(filter.id, filter.copyWith(value: date.toIso8601String().split('T')[0]));
        }
      },
    );
  }

  Widget _buildNumberInput(BuildContext context, Filter filter) {
    return TextFormField(
      initialValue: filter.value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: '数值',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        onUpdate(filter.id, filter.copyWith(value: value));
      },
    );
  }

  Widget _buildStringArrayInput(BuildContext context, Filter filter) {
    final tags = filter.value is List ? (filter.value as List).cast<String>() : <String>[];
    final tagsText = tags.join(', ');
    
    return TextFormField(
      initialValue: tagsText,
      decoration: InputDecoration(
        labelText: '标签',
        hintText: '标签1, 标签2, ...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        final newTags = value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        onUpdate(filter.id, filter.copyWith(value: newTags));
      },
    );
  }

  Widget _buildStringInput(BuildContext context, Filter filter) {
    return TextFormField(
      initialValue: filter.value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: '值',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        onUpdate(filter.id, filter.copyWith(value: value));
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () => onRemove(filter.id),
      icon: const Icon(Icons.delete_outline),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}
