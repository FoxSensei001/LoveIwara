/// 人工修正层（overrides）——**永远压过 AI 译名**，重抓 / 重译都不碰它。
///
/// 设计前提：`*_localized.json` 是 AI 产出的，随时可能被整批重跑覆盖。
/// 任何人工采纳的修正如果直接写回那个文件，下一次重跑就会静默消失。
/// 所以人工修正单独存一份 `overrides.json`，由合并脚本在最后一层盖上去。
///
/// 合并优先级（后者胜）：原始元数据 → AI 译名 → overrides
///
/// 主键：
///   - iwara：`tag id`（如 `mother`）
///   - oreno3d：`type/id`（如 `characters/3872`）——**不能用日文原名**，
///     因为 2554 个词条只有 2515 个不同的日文名，38 组同名词条会互相顶掉。
library;

import 'dart:convert';
import 'dart:io';

/// 词库支持的语言，顺序即产物里的字段顺序。
const kLangs = ['zh-CN', 'zh-TW', 'ja', 'en'];

/// 一条人工修正。
class Override {
  /// 只覆盖改过的语言；没列出的语言继续走 AI 译名，
  /// 这样 AI 后续改进还进得来（Q30：按语言逐个覆盖）。
  final Map<String, String> names;

  /// 元数据覆盖（iwara 的 type / sensitive）。
  final Map<String, dynamic> meta;

  /// 改动当时 AI 译名的值，用于重跑后的冲突检测。
  final Map<String, String> prev;

  final String? src; // manual | user | ai
  final String? by;
  final List<String> ref;
  final String? at;
  final String? note;

  const Override({
    this.names = const {},
    this.meta = const {},
    this.prev = const {},
    this.src,
    this.by,
    this.ref = const [],
    this.at,
    this.note,
  });

  factory Override.fromJson(Map<String, dynamic> j) => Override(
        names: ((j['n'] as Map?)?.cast<String, dynamic>() ?? const {})
            .map((k, v) => MapEntry(k, '$v')),
        meta: (j['meta'] as Map?)?.cast<String, dynamic>() ?? const {},
        prev: ((j['prev'] as Map?)?.cast<String, dynamic>() ?? const {})
            .map((k, v) => MapEntry(k, '$v')),
        src: j['src'] as String?,
        by: j['by'] as String?,
        ref: ((j['ref'] as List?) ?? const []).map((e) => '$e').toList(),
        at: j['at'] as String?,
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (names.isNotEmpty) 'n': names,
        if (meta.isNotEmpty) 'meta': meta,
        if (prev.isNotEmpty) 'prev': prev,
        if (src != null) 'src': src,
        if (by != null) 'by': by,
        if (ref.isNotEmpty) 'ref': ref,
        if (at != null) 'at': at,
        if (note != null) 'note': note,
      };
}

/// 一条「上游变了、人工修正需要复核」的记录。
///
/// 注意：**仍然会应用这条修正**，只是把它报出来。
/// 静默丢弃会让用户看到的译名突然退回旧值；静默保留则让你永远不知道底下变了。
class ReviewItem {
  final String key;
  final String lang;
  final String recordedPrev; // 改动当时的 AI 译名
  final String currentAi; // 现在的 AI 译名
  final String applied; // 实际生效的人工译名

  const ReviewItem({
    required this.key,
    required this.lang,
    required this.recordedPrev,
    required this.currentAi,
    required this.applied,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'lang': lang,
        'prev': recordedPrev,
        'currentAi': currentAi,
        'applied': applied,
      };

  @override
  String toString() =>
      '$key [$lang] 人工值「$applied」写于 AI 值为「$recordedPrev」时，'
      '现在 AI 值已变成「$currentAi」';
}

/// 合并结果。
class MergeResult {
  /// 主键 → 该条最终的四语言译名。
  final Map<String, Map<String, String>> names;

  /// 主键 → 元数据覆盖（只含被 overrides 改过的）。
  final Map<String, Map<String, dynamic>> meta;

  /// 需要人工复核的条目（上游 AI 值已偏离记录的 prev）。
  final List<ReviewItem> needsReview;

  /// 实际生效的覆盖条数（按 主键×语言 计）。
  final int appliedCount;

  /// overrides 里存在、但原始数据里已经没有的主键（上游删了这个词条）。
  final List<String> orphanKeys;

  const MergeResult({
    required this.names,
    required this.meta,
    required this.needsReview,
    required this.appliedCount,
    required this.orphanKeys,
  });
}

/// 把 AI 译名与人工修正合并。
///
/// [aiNames] 主键 → 语言 → 译名（已按主键归一，不再有日文名 key）。
/// [knownKeys] 原始数据里真实存在的主键，用于检出孤儿 override。
MergeResult mergeOverrides({
  required Map<String, Map<String, String>> aiNames,
  required Map<String, Override> overrides,
  required Set<String> knownKeys,
}) {
  final names = <String, Map<String, String>>{
    for (final e in aiNames.entries) e.key: Map<String, String>.from(e.value),
  };
  final meta = <String, Map<String, dynamic>>{};
  final review = <ReviewItem>[];
  final orphans = <String>[];
  var applied = 0;

  overrides.forEach((key, ov) {
    if (!knownKeys.contains(key)) {
      orphans.add(key);
      return;
    }

    final current = names.putIfAbsent(key, () => <String, String>{});

    ov.names.forEach((lang, value) {
      final ai = current[lang] ?? '';
      final recorded = ov.prev[lang];
      // 记录了改前值、且上游 AI 值已经不是当初那个 → 报出来复核，但照样应用。
      if (recorded != null && recorded != ai) {
        review.add(ReviewItem(
          key: key,
          lang: lang,
          recordedPrev: recorded,
          currentAi: ai,
          applied: value,
        ));
      }
      current[lang] = value;
      applied++;
    });

    if (ov.meta.isNotEmpty) meta[key] = Map<String, dynamic>.from(ov.meta);
  });

  return MergeResult(
    names: names,
    meta: meta,
    needsReview: review,
    appliedCount: applied,
    orphanKeys: orphans,
  );
}

/// 读取 overrides 文件；文件不存在时返回空表（这是正常状态，不是错误）。
Map<String, Override> loadOverrides(String path) {
  final f = File(path);
  if (!f.existsSync()) return {};
  final raw = f.readAsStringSync().trim();
  if (raw.isEmpty) return {};
  return parseOverrides(raw);
}

Map<String, Override> parseOverrides(String jsonText) {
  final root = jsonDecode(jsonText) as Map<String, dynamic>;
  final entries = (root['entries'] as Map?)?.cast<String, dynamic>() ?? const {};
  return entries.map(
    (k, v) => MapEntry(k, Override.fromJson((v as Map).cast<String, dynamic>())),
  );
}

/// 内容指纹：同样的内容永远得到同样的 rev，任何一个字变了 rev 就变。
///
/// 用途是让 App 判断「词库到底有没有更新」。
/// 现有实现用的是「条目数变了才重建」的启发式，只改译名不改条数时判不出来。
String contentRev(Object payload) {
  final bytes = utf8.encode(jsonEncode(payload));
  // FNV-1a 64 位：不引入额外依赖，冲突概率对这个用途足够低。
  var hash = 0xcbf29ce484222325;
  const prime = 0x100000001b3;
  for (final b in bytes) {
    hash ^= b;
    hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
  }
  // Dart 的 int 是有符号 64 位，直接 toRadixString 会得到负数字符串，
  // 经 BigInt 转成无符号再输出，保证恒为 16 位十六进制。
  return BigInt.from(hash).toUnsigned(64).toRadixString(16).padLeft(16, '0');
}
