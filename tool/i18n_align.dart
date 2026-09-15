// 诊断某个语言 yaml 与基准 en 的**行级**对齐情况，找出第一处错位。
//
// 用法：dart run tool/i18n_align.dart <locale>
//
// 工兵被掐断时可能重排/改缩进，导致文件不再是「逐行只换值」的形态。这个脚本
// 不解析 YAML（坏文件解析不了），只按行比对 key 名。
import 'dart:io';

/// 抽出一行的「缩进 + key」，注释行和空行返回 null。
({int indent, String key})? lineKey(String line) {
  if (line.trim().isEmpty || line.trimLeft().startsWith('#')) return null;
  final indent = line.length - line.trimLeft().length;
  final colon = line.indexOf(':');
  if (colon == -1) return null;
  final key = line.substring(indent, colon).trim();
  if (!isKeyName(key)) return null;
  return (indent: indent, key: key);
}

/// 与 i18n_rebuild 保持一致：带参数的 key 里含空格，也要认。
bool isKeyName(String key) {
  if (key.isEmpty) return false;
  if (!key.contains(' ')) return !key.contains(':');
  return RegExp(r'^[A-Za-z0-9_]+\([^()]*\)$').hasMatch(key);
}

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('用法：dart run tool/i18n_align.dart <locale>');
    exit(2);
  }
  final locale = args.first;
  final base = File('lib/i18n/en.i18n.yaml').readAsLinesSync();
  final target = File('lib/i18n/$locale.i18n.yaml').readAsLinesSync();

  stdout.writeln('en: ${base.length} 行，$locale: ${target.length} 行');

  var mismatches = 0;
  final limit = base.length < target.length ? base.length : target.length;
  for (var i = 0; i < limit; i++) {
    final a = lineKey(base[i]);
    final b = lineKey(target[i]);
    if (a == null && b == null) continue;
    if (a?.key != b?.key || a?.indent != b?.indent) {
      mismatches++;
      if (mismatches <= 10) {
        stdout.writeln('第 ${i + 1} 行错位：');
        stdout.writeln('  en : ${base[i]}');
        stdout.writeln('  $locale : ${target[i]}');
      }
    }
  }
  stdout.writeln('\n行级错位总数：$mismatches');
  if (base.length != target.length) {
    stdout.writeln('⚠️ 行数也不同，差 ${(base.length - target.length).abs()} 行');
  }
}
