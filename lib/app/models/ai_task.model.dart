import 'dart:convert';

/// AI 能力的**用途**。
///
/// ⭐ 这个枚举是"AI 不止用于翻译"这件事的支点：供应商是一份可复数的配置，
/// 用途是一张绑定表，于是"翻译用便宜快的、搜索用强的"才表达得出来。
///
/// ⛔ 不要为每个用途复制一整套供应商配置——那是把配置项乘以 N，用户要把同一个
/// 密钥填三遍。绑定表只是 `{用途: 档案id}` 一格。
enum AiTask {
  /// 正文 / 标题 / 评论翻译。
  translate,

  /// 自然语言 → 搜索筛选条件（结构化输出）。
  searchQuery,

  /// 小尾巴里由 AI 写出来的那一句。
  signature;

  /// 存进配置的键名。⛔ 用显式字符串而不是 `name`：枚举改名不该让用户的绑定失效。
  String get wireName => switch (this) {
    AiTask.translate => 'translate',
    AiTask.searchQuery => 'search_query',
    AiTask.signature => 'signature',
  };

  static AiTask? fromWireName(String raw) {
    for (final task in AiTask.values) {
      if (task.wireName == raw) return task;
    }
    return null;
  }
}

/// 一个用途累计花掉的量。
///
/// 存在的理由：从"只有翻译在用 AI"变成"三处都在花钱"之后，用户必须看得见钱
/// 花在哪儿，否则只会感到"这 App 在偷偷用我的 key"。
///
/// ⚠️ token 数来自 `ChatResult.usage`，而**不是每家都给**（`LanguageModelUsage`
/// 的字段全是可空的）。给不出来时 [calls] 照样涨，token 停在原地——所以 UI 上
/// 要以"次数"为主、token 为辅，别做成"0 token＝没调用过"。
class AiUsageStat {
  const AiUsageStat({
    this.calls = 0,
    this.promptTokens = 0,
    this.responseTokens = 0,
    this.failures = 0,
  });

  final int calls;
  final int promptTokens;
  final int responseTokens;

  /// 失败次数（也计入 [calls]）。配错密钥时这两个数会一起涨，是个有用的线索。
  final int failures;

  int get totalTokens => promptTokens + responseTokens;

  AiUsageStat plus({
    int calls = 0,
    int promptTokens = 0,
    int responseTokens = 0,
    int failures = 0,
  }) => AiUsageStat(
    calls: this.calls + calls,
    promptTokens: this.promptTokens + promptTokens,
    responseTokens: this.responseTokens + responseTokens,
    failures: this.failures + failures,
  );

  Map<String, dynamic> toJson() => {
    'calls': calls,
    'promptTokens': promptTokens,
    'responseTokens': responseTokens,
    'failures': failures,
  };

  factory AiUsageStat.fromJson(Map<String, dynamic> json) => AiUsageStat(
    calls: (json['calls'] as num?)?.toInt() ?? 0,
    promptTokens: (json['promptTokens'] as num?)?.toInt() ?? 0,
    responseTokens: (json['responseTokens'] as num?)?.toInt() ?? 0,
    failures: (json['failures'] as num?)?.toInt() ?? 0,
  );

  static const AiUsageStat zero = AiUsageStat();

  /// 整张表的编解码。坏数据当成"还没用过"——用量统计坏掉不该影响任何功能。
  static Map<AiTask, AiUsageStat> decodeMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final out = <AiTask, AiUsageStat>{};
      decoded.forEach((key, value) {
        if (key is! String || value is! Map) return;
        final task = AiTask.fromWireName(key);
        if (task == null) return;
        out[task] = AiUsageStat.fromJson(value.cast<String, dynamic>());
      });
      return out;
    } catch (_) {
      return const {};
    }
  }

  static String encodeMap(Map<AiTask, AiUsageStat> stats) => jsonEncode({
    for (final entry in stats.entries) entry.key.wireName: entry.value.toJson(),
  });
}

/// 用途 → 档案 id 的绑定表。
abstract final class AiTaskBindings {
  static Map<AiTask, String> decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final out = <AiTask, String>{};
      decoded.forEach((key, value) {
        if (key is! String || value is! String || value.trim().isEmpty) return;
        final task = AiTask.fromWireName(key);
        if (task != null) out[task] = value;
      });
      return out;
    } catch (_) {
      return const {};
    }
  }

  static String encode(Map<AiTask, String> bindings) => jsonEncode({
    for (final entry in bindings.entries) entry.key.wireName: entry.value,
  });
}
