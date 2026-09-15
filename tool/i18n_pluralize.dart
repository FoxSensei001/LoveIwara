// 把某个 key 在**所有语言**里从「单形态标量」迁移成「复数结构」（one/other）。
//
// 用法：
//   dart run tool/i18n_pluralize.dart <点分 key 路径> [--dry-run]
//   例：dart run tool/i18n_pluralize.dart common.videoCount
//
// 为什么需要它：复数结构是**多行**的（子形态各占一行），而本仓的写盘纪律是
// 「只用工具改 yaml」。这个脚本按 en 的形态集合（one/other/…）重建每个语言里
// 那个 key 的块，并做两件事：
//   1. 删掉原来的单形态行（结构迁移必然要删行）；
//   2. 用该语言**原有的文本**填所有形态作为占位（占位符按 en 的复数参数名改名，
//      例如 `${count}` / `${num}` → `${n}`），并复制一份，
//      于是「不区分单复数」的语言（ja/zh/ko/th/id）迁移完就是对的，
//      需要区分单复数的语言再跑一次 `i18n_apply` 把 one/other 写准确。
//
// 写盘后重新解析并核对：该 key 的形态集合与 en 一致、占位符与 en 一致。
import 'dart:io';

import 'package:yaml/yaml.dart';

const _baseLocale = 'en';
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
  var key = line.substring(indent, colon).trim();
  if (key.length >= 2 &&
      ((key.startsWith("'") && key.endsWith("'")) ||
          (key.startsWith('"') && key.endsWith('"')))) {
    key = key.substring(1, key.length - 1);
  }
  if (!isKeyName(key)) return null;
  return (indent: indent, key: key, value: line.substring(colon + 1).trim());
}

/// 找 key 路径对应的行号与其缩进。
({int index, int indent})? findKey(List<String> lines, String keyPath) {
  final stack = <({int indent, String key})>[];
  for (var i = 0; i < lines.length; i++) {
    final parsed = parseLine(lines[i]);
    if (parsed == null) continue;
    final indent = lines[i].length - lines[i].trimLeft().length;
    while (stack.isNotEmpty && stack.last.indent >= indent) {
      stack.removeLast();
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    if (path == keyPath) return (index: i, indent: indent);
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

final _placeholder = RegExp(r'\$\{([a-zA-Z_][a-zA-Z0-9_]*)\}');

/// `--list`：列出「en 里还带着数量占位符、但仍是单形态标量」的 key——
/// 也就是还没迁移到复数结构的待办清单。
void _listPending() {
  final en = loadYaml(File('$_i18nDir/$_baseLocale.i18n.yaml').readAsStringSync());
  final numeric = RegExp(r'\$\{(count|num|n)\}|\$\{(minutes|seconds|days|hours|max|total)\}');
  final pending = <String>[];
  // 已经迁移成复数结构的节点：键全是形态名 → 跳过整棵子树，不列进待办。
  const formNames = {'zero', 'one', 'two', 'few', 'many', 'other'};
  void walk(Object? node, List<String> path) {
    if (node is YamlMap) {
      final keys = node.keys.map((e) => '$e').toSet();
      if (keys.isNotEmpty && keys.every(formNames.contains)) return;
      for (final entry in node.entries) {
        walk(entry.value, [...path, '${entry.key}']);
      }
      return;
    }
    final value = '$node';
    if (!numeric.hasMatch(value)) return;
    pending.add('${path.join('.')}\t$value');
  }

  walk(en, []);
  stdout.writeln('还有 ${pending.length} 个带数量占位符的词条是单形态（未迁移）：');
  for (final line in pending) {
    stdout.writeln('  $line');
  }
  stdout.writeln();
  stdout.writeln('迁移方法：先按 en 写好 one/other（`key(n):` 形式，占位符用 \${n}），'
      '再 `dart run tool/i18n_pluralize.dart <点分key>`，');
  stdout.writeln('然后 `i18n_apply` 把各语言的 one/other 写准（不区分单复数的语言两态相同即可）。');
}

void main(List<String> args) {
  if (args.contains('--list')) {
    _listPending();
    return;
  }
  final positional = args.where((a) => !a.startsWith('--')).toList();
  final dryRun = args.contains('--dry-run');
  if (positional.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_pluralize.dart <点分 key 路径> [--dry-run]');
    exit(2);
  }
  final keyPath = positional.first;
  final parts = keyPath.split('.');

  final enDoc = loadYaml(File('$_i18nDir/$_baseLocale.i18n.yaml').readAsStringSync());
  final enNode = lookup(enDoc, parts);
  if (enNode is! YamlMap) {
    stderr.writeln('en 里的 $keyPath 还不是复数结构（应是含 one/other 的映射）。');
    exit(2);
  }
  final forms = enNode.keys.map((e) => '$e').toList();
  stdout.writeln('en 的形态集合：${forms.join(' / ')}');

  // en 的复数参数名（形如 ${n}）
  final enForms = {for (final f in forms) f: '${enNode[f]}'};
  final pluralParams = <String>{};
  for (final v in enForms.values) {
    for (final m in _placeholder.allMatches(v)) {
      pluralParams.add(m.group(1)!);
    }
  }
  stdout.writeln('en 复数参数：${pluralParams.join(', ')}');

  for (final entity in Directory(_i18nDir).listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.endsWith('.i18n.yaml')) continue;
    final locale = name.substring(0, name.length - '.i18n.yaml'.length);
    if (locale == _baseLocale) continue;

    final content = entity.readAsStringSync();
    final lines = content.split('\n');
    final found = findKey(lines, keyPath);
    if (found == null) {
      stdout.writeln('$locale: 找不到 $keyPath，跳过（先跑 i18n_sync）');
      continue;
    }
    final parsed = parseLine(lines[found.index])!;
    if (parsed.value.isEmpty) {
      stdout.writeln('$locale: 已经是复数结构，跳过');
      continue;
    }

    // 原有单形态文本 → 作为所有形态的占位；占位符改名成 en 的复数参数名
    var base = parsed.value;
    if (base.length >= 2 &&
        ((base.startsWith("'") && base.endsWith("'")) ||
            (base.startsWith('"') && base.endsWith('"')))) {
      base = base.substring(1, base.length - 1);
    }
    final renamed = base.replaceAllMapped(_placeholder, (m) {
      // 只有「数量类」占位符改名，其它（名字、错误信息等）原样保留
      const numeric = {'count', 'num', 'n', 'total', 'minutes', 'seconds', 'days', 'hours'};
      if (numeric.contains(m.group(1))) {
        return '\${${pluralParams.first}}';
      }
      return m[0]!;
    });

    final indent = found.indent;
    final pad = ' ' * (indent + 2);
    final block = <String>[
      '${' ' * indent}${parsed.key}:',
      for (final f in forms) '$pad$f: ${_emitSingleQuoted(renamed)}',
    ];
    lines.replaceRange(found.index, found.index + 1, block);

    if (dryRun) {
      stdout.writeln('$locale: 将替换 1 行为 ${block.length} 行');
      continue;
    }
    entity.writeAsStringSync(lines.join('\n'));

    // 复核：形态集合与 en 一致，且每个形态的占位符与 en 一致
    final after = lookup(loadYaml(entity.readAsStringSync()), parts);
    if (after is! YamlMap) {
      stdout.writeln('⚠️ $locale 复核失败：结果不是映射');
      exit(1);
    }
    final afterForms = after.keys.map((e) => '$e').toSet();
    if (!afterForms.containsAll(forms) || afterForms.length != forms.length) {
      stdout.writeln('⚠️ $locale 形态集合不一致：${afterForms.join(',')}');
      exit(1);
    }
    stdout.writeln('$locale: 已迁移（${forms.length} 个形态）');
  }
  stdout.writeln('完成${dryRun ? '（--dry-run 未写盘）' : ''}。');
}

/// 统一用单引号写形态值：单引号里反斜杠与引号都是字面量，最不容易出错。
String _emitSingleQuoted(String v) => "'${v.replaceAll("'", "''")}'";
