// 把某个 key 在所有语言里的 **块标量**（`>-` / `|` 写法的多行值）规范成单行双引号
// 标量。用法：
//
//   dart run tool/i18n_flatten_block_scalars.dart oreno3d.thirdPartyTagsExplanation
//   dart run tool/i18n_flatten_block_scalars.dart <key> --dry-run
//
// 为什么需要它：块标量让「每门语言逐行对齐」这件事不再成立——同一个 key，一门
// 语言占 8 行、另一门占 1 行。而 `i18n_rebuild` / `i18n_sync` 都是**按行**工作的：
// rebuild 会把 en 的 8 行骨架直接铺过去，碰到只有 1 行的目标语言就把那 7 行续行
// 原样留在文件里，YAML 当场解析不了（本仓真的发生过一次）。规范成单行后，所有
// 语言的行结构一致，三个工具都能安全工作。
//
// 语义不变：改写后的标量解析值与原块标量的解析值逐字相同（工具会逐条核对）。
import 'dart:io';

import 'package:yaml/yaml.dart';

const _i18nDir = 'lib/i18n';

bool isKeyName(String key) {
  if (key.isEmpty) return false;
  if (!key.contains(' ')) return !key.contains(':');
  return RegExp(r'^[A-Za-z0-9_]+\([^()]*\)$').hasMatch(key);
}

({int indent, String key, String value})? parseLine(String line) {
  if (line.trim().isEmpty) return null;
  final trimmedLeft = line.trimLeft();
  if (trimmedLeft.startsWith('#')) return null;
  final indent = line.length - trimmedLeft.length;
  final colon = line.indexOf(':');
  if (colon == -1) return null;
  final key = line.substring(indent, colon).trim();
  if (!isKeyName(key)) return null;
  return (indent: indent, key: key, value: line.substring(colon + 1).trim());
}

/// 找到 key 路径对应的行号（叶子行）。
int? findKeyLine(List<String> lines, String keyPath) {
  final stack = <({int indent, String key})>[];
  for (var i = 0; i < lines.length; i++) {
    final parsed = parseLine(lines[i]);
    if (parsed == null) continue;
    final indent = lines[i].length - lines[i].trimLeft().length;
    while (stack.isNotEmpty && stack.last.indent >= indent) {
      stack.removeLast();
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    if (path == keyPath) return i;
    if (parsed.value.isEmpty) stack.add((indent: indent, key: parsed.key));
  }
  return null;
}

Object? lookup(Object? node, List<String> path) {
  var current = node;
  for (final segment in path) {
    if (current is! YamlMap) return null;
    current = current[segment];
  }
  return current;
}

String quoted(String v) {
  final buffer = StringBuffer('"');
  for (final rune in v.runes) {
    final ch = String.fromCharCode(rune);
    switch (ch) {
      case '"':
        buffer.write('\\"');
      case '\\':
        buffer.write('\\\\');
      case '\n':
        buffer.write('\\n');
      case '\t':
        buffer.write('\\t');
      case '\r':
        buffer.write('\\r');
      default:
        buffer.write(ch);
    }
  }
  buffer.write('"');
  return buffer.toString();
}

void main(List<String> args) {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  final dryRun = args.contains('--dry-run');
  if (positional.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_flatten_block_scalars.dart <key> [--dry-run]');
    exit(2);
  }
  final keyPath = positional.first;
  final parts = keyPath.split('.');

  for (final entity in Directory(_i18nDir).listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.endsWith('.i18n.yaml')) continue;
    final locale = name.substring(0, name.length - '.i18n.yaml'.length);
    final content = entity.readAsStringSync();
    final lines = content.split('\n');
    final index = findKeyLine(lines, keyPath);
    if (index == null) {
      stdout.writeln('$locale: 找不到 $keyPath，跳过');
      continue;
    }
    final raw = parseLine(lines[index])!.value;
    final isBlock = raw.startsWith('>') || raw.startsWith('|');
    // 续行：从下一行起，直到下一个 key 行或注释行
    final continuation = <int>[];
    for (var i = index + 1; i < lines.length; i++) {
      if (parseLine(lines[i]) != null) break;
      if (lines[i].trimLeft().startsWith('#')) break;
      continuation.add(i);
    }
    if (!isBlock && continuation.isEmpty) {
      stdout.writeln('$locale: 已经是单行，无需改动');
      continue;
    }

    final parsed = lookup(loadYaml(content), parts);
    final value = '$parsed';
    final indent = lines[index].length - lines[index].trimLeft().length;
    final key = parseLine(lines[index])!.key;

    final output = <String>[];
    for (var i = 0; i < lines.length; i++) {
      if (i == index) {
        output.add('${' ' * indent}$key: ${quoted(value)}');
        continue;
      }
      if (continuation.contains(i)) continue;
      output.add(lines[i]);
    }
    if (dryRun) {
      stdout.writeln('$locale: 将把块标量规范成单行（${continuation.length} 行续行删除）');
      continue;
    }
    entity.writeAsStringSync(output.join('\n'));

    // 复核：解析值必须与改写前逐字相同
    final after = lookup(loadYaml(entity.readAsStringSync()), parts);
    if ('$after' != value) {
      stdout.writeln('⚠️ $locale 复核失败：改写前「${value.substring(0, 30)}…」'
          '改写后「${'$after'.substring(0, 30)}…」');
      exit(1);
    }
    stdout.writeln('$locale: 已规范成单行（删 ${continuation.length} 行续行），解析值逐字一致');
  }
}
