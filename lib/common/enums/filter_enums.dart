import 'package:flutter/material.dart';

enum FilterFieldType { STRING, NUMBER, BOOLEAN, DATE, STRING_ARRAY, SELECT }

enum FilterOperator {
  CONTAINS(':'),
  EQUALS('='),
  NOT_EQUALS('!='),
  GREATER_THAN('>'),
  GREATER_EQUAL('>='),
  LESS_THAN('<'),
  LESS_EQUAL('<='),
  RANGE('[..]'),
  IN('[]'),
  NOT_IN('![]');

  final String value;
  const FilterOperator(this.value);
}

class FilterFieldOption {
  final String value;
  final String label;

  const FilterFieldOption({required this.value, required this.label});
}

class FilterField {
  final String name;
  final FilterFieldType type;
  final bool isLocalizable;
  final String displayName;
  final IconData? iconData;
  final Color? iconColor;
  final List<FilterFieldOption>? options;

  const FilterField({
    required this.name,
    required this.type,
    this.isLocalizable = false,
    required this.displayName,
    this.iconData,
    this.iconColor,
    this.options,
  });
}

class Filter {
  final String id;
  final String field;
  final String? locale;
  final FilterOperator operator;
  final dynamic value;

  const Filter({
    required this.id,
    required this.field,
    this.locale,
    required this.operator,
    required this.value,
  });

  Filter copyWith({
    String? id,
    String? field,
    String? locale,
    FilterOperator? operator,
    dynamic value,
  }) {
    return Filter(
      id: id ?? this.id,
      field: field ?? this.field,
      locale: locale ?? this.locale,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  // to string
  @override
  String toString() {
    return 'Filter(id: $id, field: $field, locale: $locale, operator: $operator, value: $value)';
  }
}

class FilterContentType {
  final String id;
  final String name;
  final List<FilterField> fields;

  const FilterContentType({
    required this.id,
    required this.name,
    required this.fields,
  });
}
