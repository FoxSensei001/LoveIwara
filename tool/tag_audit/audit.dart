/// 标签词库「零成本可疑度审计」——不联网、不调 AI、不改动任何现有数据。
///
/// 只用脚本能确定的信号，给 iwara / oreno3d 两份词库的每一条打分排序，
/// 产出一份「该先看哪几条」的工作单。设计依据见 tool/tag_audit/README.md。
///
/// 用法：
///   dart run tool/tag_audit/audit.dart                 # 输出报告到 tool/tag_audit/out/
///   dart run tool/tag_audit/audit.dart --top 50        # 顺便在终端打印前 50 条
library;

import 'dart:convert';
import 'dart:io';

import '../tag_overrides/overrides.dart';
import 'cjk_variants.dart';

const _langs = ['zh-CN', 'zh-TW', 'ja', 'en'];

/// 信号权重。顺序即优先级：脚本能确定的信号一律排在需要 AI 判断的信号之前。
/// 分值只用于排序，不代表「错误概率」。
const _weights = <String, int>{
  'name_collision': 1000, // 多个词条共享同一个日文原名 → 结构上无法分别翻译
  'parser_split_risk': 700, // 名字含空白 → 列表页解析器按空格切碎
  'stuffed_translation': 500, // 译名里塞了多个候选（斜杠/括号/顿号）
  'kana_left_in_zh': 300, // 中文译名里残留假名 → 大概率没翻
  'script_mismatch': 250, // zh-TW 里有简体字 / zh-CN 里有繁体字
  'missing_translation': 180, // 缺该语言的译名
  'suspicious_length': 40, // 译名远长于原名 → 可能塞了解释
  'cross_lang_identical': 30, // 四语言全同（多为正常，弱信号）
  // 下面这条不是「错」，是「要不要给中文名」的编辑决策：
  // 命中的多为歌名 / 西文作品名（Apple Pie、RWBY、School Days），保留原文往往才是对的。
  'latin_untranslated': 20,
};

class Finding {
  final String scope; // iwara | oreno3d
  final String key; // 主键：iwara=tag id；oreno3d=type/id
  final String source; // 原文（iwara=tag id；oreno3d=日文名）
  final int weight;
  final List<String> signals;
  final Map<String, String> names;
  final int heat; // workCount，用于同档内排序
  final Map<String, dynamic> extra;

  Finding({
    required this.scope,
    required this.key,
    required this.source,
    required this.weight,
    required this.signals,
    required this.names,
    required this.heat,
    this.extra = const {},
  });

  Map<String, dynamic> toJson() => {
        'scope': scope,
        'key': key,
        'source': source,
        'score': weight,
        'signals': signals,
        'names': names,
        'heat': heat,
        if (extra.isNotEmpty) 'extra': extra,
      };
}

// 排除 U+30FB「・」：它在中文译名里是合法的并列分隔符，不代表没翻译。
bool _hasKana(String s) => RegExp(r'[ぁ-ゟァ-ヺー-ヿ]').hasMatch(s);
bool _hasHan(String s) => RegExp(r'[一-鿿]').hasMatch(s);

final _simplifiedSet = kSimplifiedOnly.split('').toSet();
final _traditionalSet = kTraditionalOnly.split('').toSet();

String _variantChars(String s, Set<String> table) =>
    s.split('').where(table.contains).toSet().join();

/// 「塞了多个候选」的痕迹：斜杠 / 顿号 / 括号内再给一个名字。
final _stuffed = RegExp(r'[/／、|｜・]');

/// iwara 侧「原文」的可读形式，与 App 的 prettifyId 对齐。
String _prettifyId(String id) => id.replaceAll('_', ' ').trim();

List<String> _langSignals({
  required String source,
  required Map<String, String> names,
  required List<String> signals,
  required Map<String, dynamic> extra,
}) {
  final perLang = <String, List<String>>{};

  for (final lang in _langs) {
    final v = names[lang];
    final hits = <String>[];

    if (v == null || v.trim().isEmpty) {
      hits.add('missing_translation');
      perLang[lang] = hits;
      continue;
    }

    final isZh = lang == 'zh-CN' || lang == 'zh-TW';
    // 原文是否「本来就需要翻译」：不含汉字（纯拉丁/纯假名）时，
    // 译名与原文相同才说明没翻；原文含汉字时相同往往是正确答案（白露→白露）。
    final sourceNeedsTranslation = !_hasHan(source);

    // 「塞了多个候选」只在中文侧算信号：
    // en 的 'Hypnosis / Mind control' 是合法义项并列，ja 的 'Fate/Grand Order' 是原名自带。
    if (isZh && _stuffed.hasMatch(v) && !_stuffed.hasMatch(source)) {
      hits.add('stuffed_translation');
    }

    if (isZh && _hasKana(v) && _hasHan(source)) {
      // 原文本身是纯假名的（如「ヒカリ」）不算——保留假名可能是有意的。
      hits.add('kana_left_in_zh');
    }

    if (lang == 'zh-TW') {
      final bad = _variantChars(v, _simplifiedSet);
      if (bad.isNotEmpty) {
        hits.add('script_mismatch');
        extra['zh-TW_simplified_chars'] = bad;
      }
    }
    if (lang == 'zh-CN') {
      final bad = _variantChars(v, _traditionalSet);
      if (bad.isNotEmpty) {
        hits.add('script_mismatch');
        extra['zh-CN_traditional_chars'] = bad;
      }
    }

    if (isZh && sourceNeedsTranslation && v.trim() == source.trim()) {
      hits.add('latin_untranslated');
    }

    // 长度异常只看中文侧：en 用多个词解释一个日文词是正常的。
    if (isZh && v.runes.length > source.runes.length * 3 + 6) {
      hits.add('suspicious_length');
    }

    if (hits.isNotEmpty) perLang[lang] = hits;
  }

  if (perLang.isNotEmpty) extra['perLang'] = perLang;

  final distinct = _langs
      .map((l) => names[l])
      .whereType<String>()
      .where((s) => s.trim().isNotEmpty)
      .toSet();
  // 原文是纯拉丁文（歌名、游戏名、西文角色名）时，四语言相同是正确答案。
  if (distinct.length == 1 &&
      names.length == _langs.length &&
      (_hasHan(source) || _hasKana(source))) {
    signals.add('cross_lang_identical');
  }

  return perLang.values.expand((e) => e).toSet().toList()..sort();
}

int _score(List<String> signals) =>
    signals.fold(0, (a, s) => a + (_weights[s] ?? 0));

// ---------------------------------------------------------------- oreno3d

List<Finding> _auditOreno3d(String root) {
  final raw = jsonDecode(
      File('$root/tool/data/oreno3d_tags/oreno3d_tags.json').readAsStringSync())
      as Map<String, dynamic>;
  final loc = jsonDecode(File(
              '$root/tool/data/oreno3d_tags/oreno3d_tags_localized.json')
          .readAsStringSync())
      as Map<String, dynamic>;

  // 收集全部词条并建立「日文名 → 词条」倒排，用于同名冲突检测。
  final entries = <Map<String, dynamic>>[];
  for (final cat in ['origins', 'characters', 'tags']) {
    final node = raw[cat];
    final items = node is Map ? node.values : (node as List);
    for (final e in items) {
      final m = (e as Map).cast<String, dynamic>();
      entries.add({...m, '_cat': cat});
    }
  }

  final byName = <String, List<Map<String, dynamic>>>{};
  for (final e in entries) {
    byName.putIfAbsent(e['name'] as String, () => []).add(e);
  }

  // 审计的对象是「用户最终看到的译名」，所以要把人工修正层合并进来——
  // 这样在 overrides 里修好一条，工作单就少一条。
  final keys = entries.map((e) => '${e['_cat']}/${e['id']}').toSet();
  final merged = mergeOverrides(
    aiNames: {
      for (final e in loc.entries)
        e.key: {
          for (final l in kLangs)
            if ((e.value as Map)[l] != null) l: '${(e.value as Map)[l]}',
        }
    },
    overrides: loadOverrides('$root/tool/data/oreno3d_tags/overrides.json'),
    knownKeys: keys,
  ).names;

  final out = <Finding>[];
  for (final e in entries) {
    final cat = e['_cat'] as String;
    final id = '${e['id']}';
    final name = e['name'] as String;
    final localized = merged['$cat/$id'] ?? const <String, String>{};

    final signals = <String>[];
    final extra = <String, dynamic>{};

    final sharing = byName[name]!;
    // 迁移后同名词条已能分别翻译，所以只在「译名仍然一模一样」时才算待办：
    // 修一组少一组，工作单会随进度缩短。
    final siblingZh = sharing
        .map((o) => merged['${o['_cat']}/${o['id']}']?['zh-CN'] ?? '')
        .toSet();
    if (sharing.length > 1 && siblingZh.length == 1) {
      signals.add('name_collision');
      extra['shares_name_with'] = sharing
          .where((o) => !(o['_cat'] == cat && '${o['id']}' == id))
          .map((o) => {
                'key': '${o['_cat']}/${o['id']}',
                'origin': o['origin'],
              })
          .toList();
      // 跨作品同名（origin 不同）才是真错；同作品重复条目多半无害。
      final origins = sharing.map((o) => o['origin']).toSet();
      extra['cross_origin'] = origins.length > 1;
    }

    // 只有 tags 类别会出现在搜索结果卡片上（origins / characters 不上卡片），
    // 而卡片解析器是唯一按空白切分的地方。已用真实 HTML 确认：
    // 卡片里的标签是纯文本、逐行排列、无链接无 id。
    if (cat == 'tags' && RegExp(r'\s').hasMatch(name)) {
      signals.add('parser_split_risk');
    }

    signals.addAll(_langSignals(
      source: name,
      names: localized,
      signals: signals,
      extra: extra,
    ));

    if (signals.isEmpty) continue;

    out.add(Finding(
      scope: 'oreno3d',
      key: '$cat/$id',
      source: name,
      weight: _score(signals),
      signals: signals.toSet().toList()..sort(),
      names: localized,
      heat: (e['workCount'] as int?) ?? 0,
      extra: {
        if (e['origin'] != null) 'origin': e['origin'],
        if (e['groupName'] != null) 'group': e['groupName'],
        ...extra,
      },
    ));
  }
  return out;
}

// ------------------------------------------------------------------ iwara

List<Finding> _auditIwara(String root) {
  final raw = jsonDecode(
          File('$root/tool/data/iwara_tags/iwara_tags.json').readAsStringSync())
      as Map<String, dynamic>;
  final loc = jsonDecode(
          File('$root/tool/data/iwara_tags/iwara_tags_localized.json')
              .readAsStringSync())
      as Map<String, dynamic>;

  final merged = mergeOverrides(
    aiNames: {
      for (final e in loc.entries)
        e.key: {
          for (final l in kLangs)
            if ((e.value as Map)[l] != null) l: '${(e.value as Map)[l]}',
        }
    },
    overrides: loadOverrides('$root/tool/data/iwara_tags/overrides.json'),
    knownKeys: (raw['tags'] as List).map((e) => '${(e as Map)['id']}').toSet(),
  ).names;

  final out = <Finding>[];
  for (final e in (raw['tags'] as List)) {
    final m = (e as Map).cast<String, dynamic>();
    final id = m['id'] as String;
    final source = _prettifyId(id);
    final names = merged[id] ?? const <String, String>{};

    final signals = <String>[];
    final extra = <String, dynamic>{};

    signals.addAll(_langSignals(
      source: source,
      names: names,
      signals: signals,
      extra: extra,
    ));

    if (signals.isEmpty) continue;

    out.add(Finding(
      scope: 'iwara',
      key: id,
      source: source,
      weight: _score(signals),
      signals: signals.toSet().toList()..sort(),
      names: names,
      heat: 0,
      extra: {
        'type': m['type'],
        'sensitive': m['sensitive'],
        ...extra,
      },
    ));
  }
  return out;
}

// ----------------------------------------------------------------- report

void main(List<String> args) {
  final root = Directory.current.path;
  var top = 0;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--top' && i + 1 < args.length) {
      top = int.tryParse(args[i + 1]) ?? 0;
    }
  }

  final findings = [..._auditOreno3d(root), ..._auditIwara(root)]
    ..sort((a, b) {
      final c = b.weight.compareTo(a.weight);
      if (c != 0) return c;
      final h = b.heat.compareTo(a.heat);
      if (h != 0) return h;
      return a.key.compareTo(b.key);
    });

  final outDir = Directory('$root/tool/tag_audit/out')..createSync(recursive: true);
  File('${outDir.path}/worklist.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'schema': 1,
        'generatedFrom': {
          'oreno3d': 'tool/data/oreno3d_tags/oreno3d_tags{,_localized}.json',
          'iwara': 'tool/data/iwara_tags/iwara_tags{,_localized}.json',
        },
        'total': findings.length,
        'findings': findings.map((f) => f.toJson()).toList(),
      }));

  // 统计
  final bySignal = <String, int>{};
  final byScope = <String, int>{};
  for (final f in findings) {
    byScope[f.scope] = (byScope[f.scope] ?? 0) + 1;
    for (final s in f.signals) {
      bySignal[s] = (bySignal[s] ?? 0) + 1;
    }
  }

  final buf = StringBuffer()
    ..writeln('# 标签词库可疑度审计（零成本信号）')
    ..writeln()
    ..writeln('生成方式：`dart run tool/tag_audit/audit.dart`，纯离线、不含任何 AI 判断。')
    ..writeln()
    ..writeln('## 总览')
    ..writeln()
    ..writeln('| 范围 | 命中条目 |')
    ..writeln('|---|---|');
  byScope.forEach((k, v) => buf.writeln('| $k | $v |'));
  buf
    ..writeln('| **合计** | **${findings.length}** |')
    ..writeln()
    ..writeln('## 按信号')
    ..writeln()
    ..writeln('| 信号 | 权重 | 命中 |')
    ..writeln('|---|---|---|');
  final sorted = bySignal.entries.toList()
    ..sort((a, b) => (_weights[b.key] ?? 0).compareTo(_weights[a.key] ?? 0));
  for (final e in sorted) {
    buf.writeln('| ${e.key} | ${_weights[e.key] ?? 0} | ${e.value} |');
  }

  buf
    ..writeln()
    ..writeln('## 工作单（前 200 条）')
    ..writeln()
    ..writeln('| # | 主键 | 原文 | zh-CN | 信号 | 热度 |')
    ..writeln('|---|---|---|---|---|---|');
  for (var i = 0; i < findings.length && i < 200; i++) {
    final f = findings[i];
    buf.writeln('| ${i + 1} | `${f.key}` | ${f.source} | '
        '${f.names['zh-CN'] ?? '—'} | ${f.signals.join(', ')} | ${f.heat} |');
  }
  File('${outDir.path}/report.md').writeAsStringSync(buf.toString());

  stdout.writeln('命中 ${findings.length} 条（oreno3d ${byScope['oreno3d'] ?? 0} / '
      'iwara ${byScope['iwara'] ?? 0}）');
  stdout.writeln('信号分布：');
  for (final e in sorted) {
    stdout.writeln('  ${e.key.padRight(22)} ${e.value}');
  }
  stdout.writeln('产物：tool/tag_audit/out/report.md, worklist.json');

  if (top > 0) {
    stdout.writeln('\n前 $top 条：');
    for (var i = 0; i < findings.length && i < top; i++) {
      final f = findings[i];
      stdout.writeln('  ${(i + 1).toString().padLeft(3)}. ${f.key.padRight(20)} '
          '${f.source.padRight(24)} -> ${f.names['zh-CN'] ?? '—'}   [${f.signals.join(',')}]');
    }
  }
}
