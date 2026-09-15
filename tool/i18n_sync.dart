// 把 en 里新增、目标语言还没有的 key **插入**到目标文件，其余字节一律不动。
//
// 用法：
//   dart run tool/i18n_sync.dart <locale> [--dry-run] [--en-value]
//
// 与 i18n_rebuild 的分工：
//   * i18n_sync  —— 目标文件结构本来是对的，只是比 en 少若干新 key 时用。插入
//     新行，保留目标文件自己的注释、空行与写法，改动量等于「新增词条数」。
//   * i18n_rebuild —— 目标文件结构已经坏了（行错位、缩进乱、YAML 解析失败）时
//     用，以 en 为骨架整份重铺。
// 早前「en 加了 key 就跑 rebuild」的做法会在行数不一致时把各语言的本地注释
// 一起换成 en 的，diff 大且丢信息；新增 key 只该用本脚本。
import 'dart:io';

import 'package:yaml/yaml.dart';

const _basePath = 'lib/i18n/en.i18n.yaml';

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
  // 同 i18n_apply：YAML 里带引号的 key（`'general_zh'`）去掉引号再当 key 用。
  var key = line.substring(indent, colon).trim();
  if (key.length >= 2) {
    final first = key[0];
    final last = key[key.length - 1];
    if ((first == "'" && last == "'") || (first == '"' && last == '"')) {
      key = key.substring(1, key.length - 1);
    }
  }
  if (!isKeyName(key)) return null;
  return (indent: indent, key: key, value: line.substring(colon + 1).trim());
}

/// 每行的 `(path, isLeaf)`；注释行/空行为 null。
List<({String path, bool leaf})?> scanPaths(List<String> lines) {
  final result = List<({String path, bool leaf})?>.filled(lines.length, null);
  final stack = <({int indent, String key})>[];
  for (var i = 0; i < lines.length; i++) {
    final parsed = parseLine(lines[i]);
    if (parsed == null) continue;
    final indent = lines[i].length - lines[i].trimLeft().length;
    while (stack.isNotEmpty && stack.last.indent >= indent) {
      stack.removeLast();
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    if (parsed.value.isEmpty) {
      stack.add((indent: indent, key: parsed.key));
      result[i] = (path: path, leaf: false);
    } else {
      result[i] = (path: path, leaf: true);
    }
  }
  return result;
}

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_sync.dart <locale> [--dry-run]');
    exit(2);
  }
  final locale = positional.first;
  final targetPath = 'lib/i18n/$locale.i18n.yaml';
  final targetFile = File(targetPath);
  if (!targetFile.existsSync()) {
    stderr.writeln('目标文件不存在：$targetPath（新语言请先跑 dart run tool/i18n_rebuild.dart $locale）');
    exit(2);
  }

  final enLines = File(_basePath).readAsStringSync().split('\n');
  final targetLines = targetFile.readAsStringSync().split('\n');
  final enPaths = scanPaths(enLines);
  final targetPaths = scanPaths(targetLines);

  final enKeys = <String>{};
  for (final p in enPaths) {
    if (p != null && p.leaf) enKeys.add(p.path);
  }
  // 锚点表必须连**非叶节点**一起收：新 key 常常挂在某个分组下（`gestureGuide:`），
  // 只认叶子会让它挂到前一个叶子后面，缩进就错了（YAML 直接解析失败）。
  final targetIndexByPath = <String, int>{};
  for (var i = 0; i < targetPaths.length; i++) {
    final p = targetPaths[i];
    if (p != null) targetIndexByPath[p.path] = i;
  }

  // 目标行索引 -> 需要挂在其后的新行（按 en 顺序）
  final insertAfter = <int, List<String>>{};
  final insertedKeys = <String>[];
  var lastInsertedAnchor = -1;

  for (var i = 0; i < enLines.length; i++) {
    final p = enPaths[i];
    if (p == null) continue;
    if (targetIndexByPath.containsKey(p.path)) continue;
    // 往前找第一个已经存在于目标文件（或刚刚插进去）的祖先/前兄弟
    var anchor = -1;
    for (var j = i - 1; j >= 0; j--) {
      final q = enPaths[j];
      if (q == null) continue;
      final t = targetIndexByPath[q.path];
      if (t != null) {
        anchor = t;
        break;
      }
    }
    if (anchor == -1) anchor = lastInsertedAnchor;
    if (anchor == -1) anchor = 0; // 兜底：文件开头
    insertAfter.putIfAbsent(anchor, () => <String>[]).add(enLines[i]);
    lastInsertedAnchor = anchor;
    insertedKeys.add(p.path);
  }

  final output = <String>[];
  for (var i = 0; i < targetLines.length; i++) {
    output.add(targetLines[i]);
    final extra = insertAfter[i];
    if (extra != null) output.addAll(extra);
  }

  stdout.writeln('$locale: 缺 ${insertedKeys.length} 个 key，将插入'
      '（目标 ${targetLines.length} 行 -> ${output.length} 行，en ${enLines.length} 行）');
  for (final k in insertedKeys.take(15)) {
    stdout.writeln('  + $k');
  }
  if (insertedKeys.length > 15) stdout.writeln('  ……另有 ${insertedKeys.length - 15} 个');

  if (dryRun) {
    stdout.writeln('--dry-run，未写盘。');
    return;
  }
  if (insertedKeys.isEmpty) {
    stdout.writeln('已是最新，无需改动。');
    return;
  }
  targetFile.writeAsStringSync(output.join('\n'));

  // 写盘后复核：key 集合必须与 en 完全一致，且文件仍能被 YAML 解析
  final written = targetFile.readAsStringSync();
  final reparsed = loadYaml(written);
  final afterPaths = scanPaths(written.split('\n'));
  final afterKeys = <String>{};
  for (final p in afterPaths) {
    if (p != null && p.leaf) afterKeys.add(p.path);
  }
  final missing = enKeys.difference(afterKeys);
  final extra = afterKeys.difference(enKeys);
  if (missing.isNotEmpty || extra.isNotEmpty || reparsed is! YamlMap) {
    stdout.writeln('⚠️ 复核失败：缺 ${missing.length}，多 ${extra.length}');
    exit(1);
  }
  stdout.writeln('已写入 $targetPath：${insertedKeys.length} 个新 key 以 en 原文占位，待翻译；'
      'key 集合与 en 一致，YAML 解析通过。');
}
