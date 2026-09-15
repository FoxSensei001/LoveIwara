// 按基准 en 的行结构重建某个语言的 yaml，保留它已有的译文。
//
// 用法：dart run tool/i18n_rebuild.dart <locale> [--dry-run]
//
// 机器翻译流程里，执行方常会重排行、插空行、改缩进，把「逐行只换值」的形态
// 破坏掉，严重时连 YAML 都解析不了。这个脚本用宽松解析（自己维护缩进栈，不
// 走 yaml 包）把目标文件里还能认出来的 `key 路径 -> 译文` 捞出来，再照着 en
// 的行序重新铺一遍：能对上的用译文，对不上的留英文原文等下一轮翻译。
import 'dart:io';

/// 一行里的缩进、key、以及冒号右边的原始内容（未 trim 尾部换行）。
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

/// 合法的 key 名。带参数的 key（`progress(current, total)`）里含空格，必须放行，
/// 否则这类词条会被当成注释行跳过：扫描时收不到已有译文，回放时又把 en 原文写
/// 回去，等于把它们悄悄退回英文。
bool isKeyName(String key) {
  if (key.isEmpty) return false;
  if (!key.contains(' ')) return !key.contains(':');
  return RegExp(r'^[A-Za-z0-9_]+\([^()]*\)$').hasMatch(key);
}

/// 宽松扫描出 `a.b.c -> 冒号右边原样文本`，只收叶子（值非空的行）。
Map<String, String> scanTranslations(List<String> lines) {
  final result = <String, String>{};
  final stack = <({int indent, String key})>[];
  for (final line in lines) {
    final parsed = parseLine(line);
    if (parsed == null) continue;
    while (stack.isNotEmpty && stack.last.indent >= parsed.indent) {
      stack.removeLast();
    }
    if (parsed.value.isEmpty) {
      stack.add((indent: parsed.indent, key: parsed.key));
      continue;
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    result[path] = parsed.value;
  }
  return result;
}

void main(List<String> args) {
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_rebuild.dart <locale> [--dry-run]');
    exit(2);
  }
  final locale = positional.first;
  final dryRun = args.contains('--dry-run');

  final baseLines = File('lib/i18n/en.i18n.yaml').readAsLinesSync();
  final targetFile = File('lib/i18n/$locale.i18n.yaml');
  final existing = targetFile.existsSync()
      ? scanTranslations(targetFile.readAsLinesSync())
      : <String, String>{};

  // 目标文件已经和 en 逐行对齐时，空行与注释沿用目标文件自己的——注释是各语言
  // 的本地说明，照搬 en 会把它覆盖掉（历史行为，已修）。行数不一致说明结构已
  // 漂移，这时只能以 en 为准重建注释骨架。
  final targetLines = targetFile.existsSync() ? targetFile.readAsLinesSync() : <String>[];
  final aligned = targetLines.length == baseLines.length;

  final output = <String>[];
  final stack = <({int indent, String key})>[];
  var reused = 0;
  var fellBack = 0;
  var keptLocal = 0;

  for (var i = 0; i < baseLines.length; i++) {
    final line = baseLines[i];
    final parsed = parseLine(line);
    if (parsed == null) {
      if (aligned && parseLine(targetLines[i]) == null) {
        output.add(targetLines[i]);
        keptLocal++;
      } else {
        output.add(line);
      }
      continue;
    }
    while (stack.isNotEmpty && stack.last.indent >= parsed.indent) {
      stack.removeLast();
    }
    if (parsed.value.isEmpty) {
      stack.add((indent: parsed.indent, key: parsed.key));
      output.add(line); // 父节点行原样保留
      continue;
    }
    final path = [...stack.map((e) => e.key), parsed.key].join('.');
    final translated = existing[path];
    if (translated != null && translated != parsed.value) {
      reused++;
      output.add('${' ' * parsed.indent}${parsed.key}: $translated');
    } else {
      fellBack++;
      output.add(line); // 没译过，留英文等下一轮
    }
  }

  stdout.writeln('$locale: 复用已有译文 $reused 条，留英文 $fellBack 条，'
      '沿用本地注释空行 $keptLocal 行，共 ${output.length} 行（en 为 ${baseLines.length} 行）');

  if (dryRun) {
    stdout.writeln('--dry-run，未写盘。');
    return;
  }
  targetFile.writeAsStringSync('${output.join('\n')}\n');
  stdout.writeln('已重建 ${targetFile.path}');
}
