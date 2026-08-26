import 'package:flutter/material.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/tag_selector_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FilterRowWidget extends StatefulWidget {
  final Filter filter;
  final List<FilterField> availableFields;
  final Function(String, Filter) onUpdate;
  final Function(String) onRemove;
  final String? Function(Filter)? onValidate;

  const FilterRowWidget({
    super.key,
    required this.filter,
    required this.availableFields,
    required this.onUpdate,
    required this.onRemove,
    this.onValidate,
  });

  @override
  State<FilterRowWidget> createState() => _FilterRowWidgetState();
}

class _FilterRowWidgetState extends State<FilterRowWidget> {
  late TextEditingController _dateController;
  late TextEditingController _dateFromController;
  late TextEditingController _dateToController;
  final GlobalKey<FormFieldState> _formFieldKey = GlobalKey<FormFieldState>();

  /// 本卡片拿到的宽度够不够并排放两列控件，由 build 里的 LayoutBuilder 定。
  bool _narrow = true;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.filter.value?.toString() ?? '',
    );
    _dateFromController = TextEditingController();
    _dateToController = TextEditingController();
    _updateDateControllers();
  }

  void _updateDateControllers() {
    if (widget.filter.value is Map) {
      final map = widget.filter.value as Map;
      _dateFromController.text = map['from']?.toString() ?? '';
      _dateToController.text = map['to']?.toString() ?? '';
    } else {
      _dateController.text = widget.filter.value?.toString() ?? '';
    }
  }

  @override
  void didUpdateWidget(FilterRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检查 filter 是否有变化
    bool shouldUpdate = false;

    if (oldWidget.filter.value != widget.filter.value) {
      shouldUpdate = true;
    } else if (widget.filter.value is Map && oldWidget.filter.value is Map) {
      // 对于 Map 类型（如日期范围），检查内容是否有变化
      final oldMap = oldWidget.filter.value as Map;
      final newMap = widget.filter.value as Map;
      if (oldMap.length != newMap.length) {
        shouldUpdate = true;
      } else {
        for (final key in newMap.keys) {
          if (oldMap[key] != newMap[key]) {
            shouldUpdate = true;
            break;
          }
        }
      }
    }

    if (shouldUpdate) {
      _updateDateControllers();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  // 验证当前筛选项
  String? _validateCurrentFilter() {
    if (widget.onValidate != null) {
      return widget.onValidate!(widget.filter);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedField = widget.availableFields.firstWhere(
      (f) => f.name == widget.filter.field,
      orElse: () => widget.availableFields.first,
    );

    final availableOperators = FilterConfig.getOperatorsForType(
      selectedField.type,
    );
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // 按**自己拿到的宽度**分档，不是屏幕宽：这张卡片现在住在 380~460 宽的
        // 筛选抽屉里，桌面端屏幕再宽也得按窄列排，否则「运算符 200 + 语言 120」
        // 那一行会被挤到换行、看着像排版事故。
        _narrow = constraints.maxWidth < 520;
        return _buildCard(context, colorScheme, selectedField, availableOperators);
      },
    );
  }

  /// 卡片本体。
  Widget _buildCard(
    BuildContext context,
    ColorScheme colorScheme,
    FilterField selectedField,
    List<FilterOperator> availableOperators,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      // 与玻璃控件同一套底色/描边，卡片圆角与弹窗外壳呼应
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GlassTokens.stroke(colorScheme), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：字段选择和删除按钮
          Row(
            // 字段选择器现在带上方标签，删除按钮对齐到下拉框（底部）而非整列中线
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildFieldSelector(
                  context,
                  selectedField,
                  widget.availableFields,
                ),
              ),
              const SizedBox(width: 12),
              _buildDeleteButton(context),
            ],
          ),
          const SizedBox(height: 12),

          // 操作符和语言选择（如果支持本地化）
          if (_narrow) ...[
            // 窄列：垂直布局
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOperatorSelector(
                  context,
                  widget.filter.operator,
                  availableOperators,
                ),
                if (selectedField.isLocalizable) ...[
                  const SizedBox(height: 12),
                  _buildLocaleSelector(context),
                ],
              ],
            ),
          ] else ...[
            // 宽列：水平布局
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 200,
                  child: _buildOperatorSelector(
                    context,
                    widget.filter.operator,
                    availableOperators,
                  ),
                ),
                if (selectedField.isLocalizable)
                  SizedBox(width: 120, child: _buildLocaleSelector(context)),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // 值输入区域
          _buildValueInput(context, widget.filter, selectedField),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(
    BuildContext context,
    FilterField selectedField,
    List<FilterField> availableFields,
  ) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.field,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GlassDropdownField<String>(
          value: widget.filter.field,
          items: availableFields
              .map(
                (field) => GlassDropdownItem<String>(
                  value: field.name,
                  label: field.displayName,
                ),
              )
              .toList(),
          onChanged: (String? newFieldName) {
            if (newFieldName != null) {
              final newField = availableFields.firstWhere(
                (f) => f.name == newFieldName,
              );
              final newOperators = FilterConfig.getOperatorsForType(
                newField.type,
              );
              final newOperator = newOperators.isNotEmpty
                  ? newOperators.first
                  : FilterOperator.EQUALS;

              dynamic defaultValue = '';
              if (newField.type == FilterFieldType.BOOLEAN) {
                defaultValue = 'true';
              } else if (newField.type == FilterFieldType.STRING_ARRAY) {
                defaultValue = <String>[];
              } else if (newField.type == FilterFieldType.SELECT) {
                defaultValue = newField.options?.isNotEmpty == true
                    ? newField.options!.first.value
                    : '';
              } else if (newOperator == FilterOperator.RANGE) {
                defaultValue = {'from': '', 'to': ''};
              }

              widget.onUpdate(
                widget.filter.id,
                Filter(
                  id: widget.filter.id,
                  field: newFieldName,
                  operator: newOperator,
                  value: defaultValue,
                  locale: newField.isLocalizable ? 'en' : null,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocaleSelector(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.language,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GlassDropdownField<String>(
          value: widget.filter.locale ?? 'en',
          items: const [
            GlassDropdownItem<String>(value: 'en', label: 'en'),
            GlassDropdownItem<String>(value: 'ja', label: 'ja'),
            GlassDropdownItem<String>(value: 'zh', label: 'zh'),
          ],
          onChanged: (String? newLocale) {
            if (newLocale != null) {
              widget.onUpdate(
                widget.filter.id,
                widget.filter.copyWith(locale: newLocale),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildOperatorSelector(
    BuildContext context,
    FilterOperator selectedOperator,
    List<FilterOperator> availableOperators,
  ) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.operator,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GlassDropdownField<FilterOperator>(
          value: selectedOperator,
          items: availableOperators
              .map(
                (operator) => GlassDropdownItem<FilterOperator>(
                  value: operator,
                  label: FilterConfig.getOperatorLabel(operator),
                ),
              )
              .toList(),
          onChanged: (FilterOperator? newOperator) {
            if (newOperator != null) {
              dynamic value = widget.filter.value;
              if (newOperator == FilterOperator.RANGE && value is! Map) {
                value = {'from': '', 'to': ''};
              } else if (newOperator != FilterOperator.RANGE && value is Map) {
                value = '';
              }
              widget.onUpdate(
                widget.filter.id,
                widget.filter.copyWith(operator: newOperator, value: value),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildValueInput(
    BuildContext context,
    Filter filter,
    FilterField field,
  ) {
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
      case FilterFieldType.SELECT:
        return _buildSelectInput(context, filter, field);
      default:
        return _buildStringInput(context, filter);
    }
  }

  Widget _buildRangeInput(
    BuildContext context,
    Filter filter,
    FilterField field,
  ) {
    final t = slang.Translations.of(context);
    final fromValue = filter.value is Map ? filter.value['from'] ?? '' : '';
    final toValue = filter.value is Map ? filter.value['to'] ?? '' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.type == FilterFieldType.DATE
              ? t.searchFilter.dateRange
              : t.searchFilter.numberRange,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (_narrow) ...[
          // 窄列：垂直布局
          Column(
            children: [
              field.type == FilterFieldType.DATE
                  ? _buildDateRangeField(
                      context,
                      filter,
                      field,
                      'from',
                      fromValue,
                    )
                  : _buildNumberRangeField(
                      context,
                      filter,
                      field,
                      'from',
                      fromValue,
                    ),
              const SizedBox(height: 12),
              field.type == FilterFieldType.DATE
                  ? _buildDateRangeField(context, filter, field, 'to', toValue)
                  : _buildNumberRangeField(
                      context,
                      filter,
                      field,
                      'to',
                      toValue,
                    ),
            ],
          ),
        ] else ...[
          // 宽列：水平布局
          Row(
            children: [
              Expanded(
                child: field.type == FilterFieldType.DATE
                    ? _buildDateRangeField(
                        context,
                        filter,
                        field,
                        'from',
                        fromValue,
                      )
                    : _buildNumberRangeField(
                        context,
                        filter,
                        field,
                        'from',
                        fromValue,
                      ),
              ),
              const SizedBox(width: 12),
              Text(t.searchFilter.to),
              const SizedBox(width: 12),
              Expanded(
                child: field.type == FilterFieldType.DATE
                    ? _buildDateRangeField(
                        context,
                        filter,
                        field,
                        'to',
                        toValue,
                      )
                    : _buildNumberRangeField(
                        context,
                        filter,
                        field,
                        'to',
                        toValue,
                      ),
              ),
            ],
          ),
        ],
        // 显示验证错误信息
        if (_validateCurrentFilter() != null) ...[
          const SizedBox(height: 8),
          Text(
            _validateCurrentFilter()!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNumberRangeField(
    BuildContext context,
    Filter filter,
    FilterField field,
    String fieldKey,
    String currentValue,
  ) {
    final t = slang.Translations.of(context);
    return TextFormField(
      initialValue: currentValue,
      decoration: InputDecoration(
        labelText: fieldKey == 'from' ? t.searchFilter.from : t.searchFilter.to,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        try {
          double.parse(value.trim());
        } catch (e) {
          return t.searchFilter.pleaseEnterValidNumber;
        }
        return null;
      },
      onChanged: (value) {
        final currentValue = filter.value is Map
            ? Map<String, dynamic>.from(filter.value)
            : {'from': '', 'to': ''};
        currentValue[fieldKey] = value;
        widget.onUpdate(filter.id, filter.copyWith(value: currentValue));
        // 触发验证
        _formFieldKey.currentState?.validate();
      },
    );
  }

  Widget _buildDateRangeField(
    BuildContext context,
    Filter filter,
    FilterField field,
    String fieldKey,
    String currentValue,
  ) {
    final t = slang.Translations.of(context);
    return GestureDetector(
      onTap: () async {
        DateTime? initialDate;
        try {
          if (currentValue.isNotEmpty) {
            initialDate = DateTime.parse(currentValue);
          }
        } catch (e) {
          // 如果解析失败，使用当前日期
          initialDate = DateTime.now();
        }

        final date = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: Localizations.localeOf(context),
        );
        if (date != null) {
          final dateString = date.toIso8601String().split('T')[0];
          final currentValue = filter.value is Map
              ? Map<String, dynamic>.from(filter.value)
              : {'from': '', 'to': ''};
          currentValue[fieldKey] = dateString;
          widget.onUpdate(filter.id, filter.copyWith(value: currentValue));
          // 触发验证
          _formFieldKey.currentState?.validate();
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: fieldKey == 'from'
              ? _dateFromController
              : _dateToController,
          decoration: InputDecoration(
            labelText: fieldKey == 'from'
                ? t.searchFilter.from
                : t.searchFilter.to,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: const Icon(Icons.calendar_today),
            hintText: t.searchFilter.clickToSelectDate,
          ),
          readOnly: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            try {
              DateTime.parse(value.trim());
            } catch (e) {
              return t.searchFilter.pleaseEnterValidDate;
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildBooleanInput(BuildContext context, Filter filter) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.value,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GlassDropdownField<String>(
          value: filter.value?.toString() ?? 'true',
          items: [
            GlassDropdownItem<String>(value: 'true', label: t.searchFilter.yes),
            GlassDropdownItem<String>(value: 'false', label: t.searchFilter.no),
          ],
          onChanged: (String? value) {
            if (value != null) {
              widget.onUpdate(filter.id, filter.copyWith(value: value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateInput(BuildContext context, Filter filter) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.date,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? initialDate;
            try {
              if (filter.value != null && filter.value.toString().isNotEmpty) {
                initialDate = DateTime.parse(filter.value.toString());
              }
            } catch (e) {
              // 如果解析失败，使用当前日期
              initialDate = DateTime.now();
            }

            final date = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              locale: Localizations.localeOf(context),
            );
            if (date != null) {
              final dateString = date.toIso8601String().split('T')[0];
              widget.onUpdate(filter.id, filter.copyWith(value: dateString));
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                suffixIcon: const Icon(Icons.calendar_today),
                hintText: t.searchFilter.clickToSelectDate,
              ),
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                try {
                  DateTime.parse(value.trim());
                } catch (e) {
                  return t.searchFilter.pleaseEnterValidDate;
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput(BuildContext context, Filter filter) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.number,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: filter.value?.toString() ?? '',
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            try {
              double.parse(value.trim());
            } catch (e) {
              return t.searchFilter.pleaseEnterValidNumber;
            }
            return null;
          },
          onChanged: (value) {
            widget.onUpdate(filter.id, filter.copyWith(value: value));
          },
        ),
      ],
    );
  }

  Widget _buildStringArrayInput(BuildContext context, Filter filter) {
    final tags = filter.value is List
        ? (filter.value as List).cast<String>()
        : <String>[];

    final t = slang.Translations.of(context);
    return TagSelectorWidget(
      selectedTags: tags,
      onTagsChanged: (newTags) {
        widget.onUpdate(filter.id, filter.copyWith(value: newTags));
      },
      labelText: t.searchFilter.tags,
      hintText: t.searchFilter.select,
    );
  }

  Widget _buildStringInput(BuildContext context, Filter filter) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.value,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: filter.value?.toString() ?? '',
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: (value) {
            widget.onUpdate(filter.id, filter.copyWith(value: value));
          },
        ),
      ],
    );
  }

  Widget _buildSelectInput(
    BuildContext context,
    Filter filter,
    FilterField field,
  ) {
    final t = slang.Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.searchFilter.value,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GlassDropdownField<String>(
          value: filter.value?.toString() ?? '',
          items:
              field.options?.map((option) {
                return GlassDropdownItem<String>(
                  value: option.value,
                  label: option.label,
                );
              }).toList() ??
              const [],
          onChanged: (String? value) {
            if (value != null) {
              widget.onUpdate(filter.id, filter.copyWith(value: value));
            }
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () => widget.onRemove(widget.filter.id),
      icon: const Icon(Icons.delete_outline),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }
}
