/// 内容屏蔽规则类型。
/// - [keyword]：对视频/图库标题进行包含匹配（可选区分大小写）。
/// - [regex]：对标题进行正则匹配（可选区分大小写）。
/// - [userId]：按作者用户 ID 精确屏蔽。
enum BlockRuleType { keyword, regex, userId }

extension BlockRuleTypeX on BlockRuleType {
  String get storageValue {
    switch (this) {
      case BlockRuleType.keyword:
        return 'keyword';
      case BlockRuleType.regex:
        return 'regex';
      case BlockRuleType.userId:
        return 'userId';
    }
  }

  static BlockRuleType fromStorage(String? value) {
    switch (value) {
      case 'regex':
        return BlockRuleType.regex;
      case 'userId':
        return BlockRuleType.userId;
      case 'keyword':
      default:
        return BlockRuleType.keyword;
    }
  }
}

/// 一条本地内容屏蔽规则。纯本地存储，不与 Iwara 服务端交互。
class BlockRule {
  /// 唯一 id。
  final String id;
  final BlockRuleType type;

  /// 规则值：关键词文本 / 正则表达式 / 用户 ID。
  final String value;

  /// 可选展示名。userId 规则用于存用户名，便于设置页展示。
  final String? label;

  final bool enabled;

  /// 仅对 keyword / regex 生效，默认 false。
  final bool caseSensitive;

  /// 创建时间（毫秒时间戳），用于排序展示。
  final int createdAt;

  const BlockRule({
    required this.id,
    required this.type,
    required this.value,
    this.label,
    this.enabled = true,
    this.caseSensitive = false,
    this.createdAt = 0,
  });

  BlockRule copyWith({
    String? id,
    BlockRuleType? type,
    String? value,
    String? label,
    bool? enabled,
    bool? caseSensitive,
    int? createdAt,
  }) {
    return BlockRule(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.storageValue,
      'value': value,
      'label': label,
      'enabled': enabled,
      'caseSensitive': caseSensitive,
      'createdAt': createdAt,
    };
  }

  factory BlockRule.fromJson(Map<String, dynamic> json) {
    return BlockRule(
      id: json['id']?.toString() ?? '',
      type: BlockRuleTypeX.fromStorage(json['type']?.toString()),
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString(),
      enabled: _toBool(json['enabled'], defaultValue: true),
      caseSensitive: _toBool(json['caseSensitive']),
      createdAt: _toInt(json['createdAt']),
    );
  }

  static bool _toBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lowered = value.toLowerCase();
      if (lowered == 'true' || lowered == '1') return true;
      if (lowered == 'false' || lowered == '0') return false;
    }
    return defaultValue;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// 命中结果，携带命中的规则，供 UI 展示「为什么被屏蔽」。
class BlockMatch {
  final BlockRule rule;

  const BlockMatch(this.rule);
}
