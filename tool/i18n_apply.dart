// 按 `key<TAB>译文` 的 TSV 批量写入某语言的 yaml，**只替换冒号右边的值**。
//
// 用法：
//   dart run tool/i18n_apply.dart <locale> <tsv文件> [<tsv文件>...] [--dry-run]
//
// 为什么要有这个脚本：直接手改 yaml 会插空行、改缩进、丢 key，把「逐行只换值」
// 的形态破坏掉（见 i18n_align / i18n_rebuild 的注释）。这个脚本以 en 的行结构
// 为唯一坐标，只用 TSV 里的 key 路径去定位行，其余字节一律不动，因此结构不可能
// 被翻译内容带坏。
//
// TSV 里 `#` 开头的行与空行忽略。`key<TAB>@en` 表示回填 en 原文。
// 写盘后会重新解析整个文件，逐条核对解析值与预期值一致；不一致立即报错。
import 'dart:async';
import 'dart:io';

import 'package:yaml/yaml.dart';

const _enPath = 'lib/i18n/en.i18n.yaml';

/// YAML 里带引号的 key（`'general_zh': 常规`）去掉引号再当 key 用。
///
/// 那两个引号是 YAML 的写法，不是 key 的一部分：`tool/i18n_check.dart` 走 YAML
/// 解析器，产出的待办清单里是不带引号的 `forum.leafNames.general_zh`。两边对齐，
/// 才不会有「TSV 必须手写引号才认」和「写盘后复核按带引号路径查不到、误报 null」
/// 这两类坑。
String _stripQuotes(String key) {
  if (key.length >= 2) {
    final first = key[0];
    final last = key[key.length - 1];
    if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
      return key.substring(1, key.length - 1);
    }
  }
  return key;
}

/// TSV 里的 key 路径也容错：每个点分段都允许带引号。
String _normalizePath(String path) => path.split('.').map(_stripQuotes).join('.');

/// 与 i18n_rebuild / i18n_align 一致：带参数的 key（`progress(current, total)`）
/// 含空格，仍然是合法 key。
bool _isKeyName(String key) {
  if (key.isEmpty) return false;
  if (!key.contains(' ')) return !key.contains(':');
  return RegExp(r'^[A-Za-z0-9_]+\([^()]*\)$').hasMatch(key);
}

class _Leaf {
  _Leaf(this.index, this.indent, this.key, this.path, this.raw);
  final int index;
  final int indent;
  final String key;
  final String path;
  final String raw;

  /// en 用块标量（`>-` / `|` / `|-`）写的多行值。
  bool get isBlockScalar =>
      raw == '>' || raw == '|' || raw == '>-' || raw == '|-' ||
      raw == '>+' || raw == '|+';
}

/// 块标量占用的续行区间：从 [leaf] 的下一行起，直到遇到下一个 key 行或注释行为止
/// （块内容里的空行、缩进行都算在内）。
List<int> _blockContinuationLines(List<String> lines, _Leaf leaf) {
  final result = <int>[];
  for (var i = leaf.index + 1; i < lines.length; i++) {
    final line = lines[i];
    if (_parseLine(line) != null) break;
    if (line.trimLeft().startsWith('#')) break;
    result.add(i);
  }
  return result;
}

({String key, String value})? _parseLine(String line) {
  if (line.trim().isEmpty) return null;
  final trimmedLeft = line.trimLeft();
  if (trimmedLeft.startsWith('#')) return null;
  final indent = line.length - trimmedLeft.length;
  final colon = line.indexOf(':');
  if (colon == -1) return null;
  final key = _stripQuotes(line.substring(indent, colon).trim());
  if (!_isKeyName(key)) return null;
  return (key: key, value: line.substring(colon + 1).trim());
}

List<_Leaf> _scanLeaves(List<String> lines) {
  final leaves = <_Leaf>[];
  final stack = <({int indent, String key})>[];
  for (var i = 0; i < lines.length; i++) {
    final parsed = _parseLine(lines[i]);
    if (parsed == null) continue;
    final indent = lines[i].length - lines[i].trimLeft().length;
    while (stack.isNotEmpty && stack.last.indent >= indent) {
      stack.removeLast();
    }
    if (parsed.value.isEmpty) {
      stack.add((indent: indent, key: parsed.key));
      continue;
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    leaves.add(_Leaf(i, indent, parsed.key, path, parsed.value));
  }
  return leaves;
}

String _styleOf(String raw) {
  if (raw.startsWith('"')) return 'double';
  if (raw.startsWith("'")) return 'single';
  return 'plain';
}

const _specialFirstChars = '*&!%@-?|>[]{}#,`';

bool _needsDouble(String v) {
  if (v.isEmpty) return true;
  if (v.contains('\\')) return true;
  if (v != v.trim()) return true;
  if (v.contains(': ') || v.endsWith(':')) return true;
  if (v.contains(' #')) return true;
  if (_specialFirstChars.contains(v[0])) return true;
  if (RegExp(r'^(true|false|yes|no|on|off|null|~)$', caseSensitive: false).hasMatch(v)) return true;
  if (RegExp(r'^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?$').hasMatch(v)) return true;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(v)) return true;
  return false;
}

String _single(String v) => "'${v.replaceAll("'", "''")}'";

/// YAML 双引号里不合法、但正则里很常见的转义（`\d`、`\[`…）。这类值只能写成
/// 单引号标量——单引号里反斜杠是字面量。
final _invalidEscape = RegExp(r'\\(?!["\\/ntruUx])');

String _emit(String v, String style) {
  // 单引号是安全的兜底：YAML 单引号标量里反斜杠是**字面量**，正则示例
  // （`^\[.*\]`、`\d{4}`）只能这么写。
  if (style == 'single') return _single(v);
  if (style == 'plain') {
    if (!_needsDouble(v)) return v;
    if (v.contains('\\') && _invalidEscape.hasMatch(v)) return _single(v);
    return '"${v.replaceAll('"', '\\"')}"';
  }
  // en 是双引号：`\n` 这类转义要保留原样，只转义 `"`。含非法转义序列
  // （例如正则里的 `\d`）时退回单引号，语义变成字面反斜杠——正是想要的。
  if (_invalidEscape.hasMatch(v)) return _single(v);
  return '"${v.replaceAll('"', '\\"')}"';
}

Object? _lookup(Object? node, List<String> path) {
  Object? current = node;
  for (final segment in path) {
    if (current is! YamlMap) return null;
    current = current[segment];
  }
  return current;
}

Future<void> main(List<String> args) async {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_apply.dart <locale> <tsv文件>... [--dry-run]');
    exit(2);
  }
  // 同一门语言可能被多个执行者并行翻译（按待办清单切片）。整体读-改-写必须在锁里
  // 完成，否则后写的一方会把前一方刚写进去的译文整段覆盖掉。
  final lockDir = Directory('${Directory.systemTemp.path}/loveiwara-i18n-${{positional.first}}.lock');
  final deadline = DateTime.now().add(const Duration(minutes: 20));
  var waited = false;
  while (true) {
    try {
      lockDir.createSync();
      break;
    } on FileSystemException {
      if (DateTime.now().isAfter(deadline)) {
        stderr.writeln('等待 ${lockDir.path} 超时，放弃。');
        exit(3);
      }
      if (!waited) {
        stdout.writeln('另一执行者正在写 ${positional.first}.i18n.yaml，等待中…');
        waited = true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }
  try {
    _apply(args);
  } finally {
    try {
      lockDir.deleteSync();
    } on FileSystemException {
      // 忽略
    }
  }
}

void _apply(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.length < 2) {
    stderr.writeln('用法：dart run tool/i18n_apply.dart <locale> <tsv文件>... [--dry-run]');
    exit(2);
  }
  final locale = positional.first;
  final tsvFiles = positional.sublist(1);

  final enLines = File(_enPath).readAsStringSync().split('\n');
  final targetPath = 'lib/i18n/$locale.i18n.yaml';
  final targetFile = File(targetPath);
  if (!targetFile.existsSync()) {
    stderr.writeln('目标文件不存在：$targetPath（先跑 dart run tool/i18n_rebuild.dart $locale）');
    exit(2);
  }
  final targetLines = targetFile.readAsStringSync().split('\n');

  // 行数不要求与 en 完全相等：各语言的空行/注释行可能多几条。定位靠 key 路径，
  // 不靠行号，所以只要 key 集合与 en 一致就安全；差异只做提示。
  if (targetLines.length != enLines.length) {
    stdout.writeln('注意：行数与 en 不一致（en ${enLines.length}，$locale ${targetLines.length}），'
        '按 key 路径定位，不受影响。');
  }

  final enLeaves = _scanLeaves(enLines);
  final targetLeaves = _scanLeaves(targetLines);
  final enByPath = {for (final l in enLeaves) l.path: l};
  final targetByPath = {for (final l in targetLeaves) l.path: l};

  final applied = <String, String>{};
  final unknown = <String>[];
  final conflicts = <String>[];

  for (final tsv in tsvFiles) {
    final file = File(tsv);
    if (!file.existsSync()) {
      stderr.writeln('TSV 不存在：$tsv');
      exit(2);
    }
    for (final line in file.readAsStringSync().split('\n')) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      final tab = line.indexOf('\t');
      if (tab == -1) {
        stderr.writeln('TSV 行缺少 TAB 分隔：$line');
        exit(2);
      }
      final key = _normalizePath(line.substring(0, tab).trim());
      var value = line.substring(tab + 1);
      final enLeaf = enByPath[key];
      if (enLeaf == null) {
        unknown.add(key);
        continue;
      }
      if (value == '@en') value = enLeaf.raw;
      final target = targetByPath[key];
      if (target == null) {
        unknown.add('$key(目标缺行)');
        continue;
      }
      if (applied.containsKey(key) && applied[key] != value) {
        conflicts.add(key);
      }
      applied[key] = value;
    }
  }

  final errors = <String>[];
  final expected = <String, String>{};
  final droppedLines = <int>{};
  for (final entry in applied.entries) {
    final enLeaf = enByPath[entry.key]!;
    final target = targetByPath[entry.key]!;
    String emitted;
    try {
      emitted = _emit(entry.value, _styleOf(enLeaf.raw));
    } on FormatException catch (e) {
      errors.add('${entry.key}: ${e.message}');
      continue;
    }
    final probe = (loadYaml('v: $emitted') as YamlMap)['v'];
    expected[entry.key] = '$probe';
    targetLines[target.index] = '${' ' * target.indent}${target.key}: $emitted';
    if (enLeaf.isBlockScalar) {
      droppedLines.addAll(_blockContinuationLines(targetLines, target));
    }
  }

  stdout.writeln('$locale: 应用 ${applied.length} 条，未知 key ${unknown.length}，'
      '格式错误 ${errors.length}，同一 key 冲突 ${conflicts.length}，'
      '块标量续行删除 ${droppedLines.length} 行');
  for (final k in unknown.take(10)) {
    stdout.writeln('  未知: $k');
  }
  for (final e in errors.take(10)) {
    stdout.writeln('  错误: $e');
  }
  for (final c in conflicts.take(10)) {
    stdout.writeln('  冲突: $c');
  }
  if (unknown.isNotEmpty || errors.isNotEmpty) {
    stdout.writeln('未写盘（先修掉未知 key 与格式错误）。');
    exit(1);
  }

  if (dryRun) {
    stdout.writeln('--dry-run，未写盘。');
    return;
  }
  final outputLines = <String>[
    for (var i = 0; i < targetLines.length; i++)
      if (!droppedLines.contains(i)) targetLines[i],
  ];
  targetFile.writeAsStringSync(outputLines.join('\n'));

  // 写盘后重新解析核对：解析值必须与预期逐条一致（同时证明文件仍可被 YAML 解析）。
  final reparsed = loadYaml(targetFile.readAsStringSync());
  final mismatched = <String>[];
  for (final entry in expected.entries) {
    final actual = '${_lookup(reparsed, entry.key.split('.'))}';
    if (actual != entry.value) {
      mismatched.add('${entry.key}: 期望 ${entry.value} / 实际 $actual');
    }
  }
  if (mismatched.isNotEmpty) {
    stdout.writeln('⚠️ 写盘后核对失败 ${mismatched.length} 条：');
    for (final m in mismatched.take(10)) {
      stdout.writeln('  $m');
    }
    exit(1);
  }
  stdout.writeln('已写入 $targetPath，并逐条核对通过。');
}
