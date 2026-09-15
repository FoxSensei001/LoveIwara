// 用英文模板生成 Quest 空间面板的某个语言资源目录（纯增量，不碰 en 模板）。
//
// 用法：
//   dart run tool/questui_apply.dart <values 目录名> <tsv文件> [--dry-run]
//   例：dart run tool/questui_apply.dart values-ko /path/to/strings_ko.tsv
//
// TSV 每行 `string_name<TAB>译文`。脚本以 `android/questui/src/main/res/values/strings.xml`
// 为唯一结构模板逐行替换文本，因此 string 名、注释、行序、条数一定与 en 一致；
// Android 需要的 XML 转义（& < > ' "）由脚本处理，执行者只管给纯文本。
import 'dart:io';

const _templatePath = 'android/questui/src/main/res/values/strings.xml';
// ⛔ 必须 multiLine：本正则要逐行匹配整份文件。少了它，`^`/`$` 只锚定
// 整个字符串的首尾，`allMatches` 永远数到 0，写盘后复核会假失败并 exit 1
// （内容其实已正确落盘），CI 上表现为「工具报错但文件是对的」。
final _stringLine = RegExp(
  r'^(\s*<string name="([^"]+)"[^>]*>)(.*)(</string>)\s*$',
  multiLine: true,
);

/// 写进 `<string>` 里的文本。
///
/// 两种写法，区别是**首尾空格**：
///   * 普通文案：XML 转义 `& < >`（Android 还要求转义 `'` 与 `"`）。
///   * 首尾带空格的文案（`xr_dot_separator` = ` · `）：整条用双引号包起来。
///     Android 的规定是「被双引号包住的字符串保留前后空格」，而 `"` 本身不转义。
///     这是仓库里 `values/`、`values-ja`、`values-zh-rCN` 的一致写法，
///     写成 `\" · \"` 会让面板上真的多出两个引号。
String androidValue(String value) {
  if (value != value.trim()) {
    return '"${value.replaceAll('"', '\\"')}"';
  }
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '\\"')
      .replaceAll("'", "\\'");
}

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.length < 2) {
    stderr.writeln('用法：dart run tool/questui_apply.dart <values 目录名> <tsv文件> [--dry-run]');
    exit(2);
  }
  final valuesDir = positional.first;
  final template = File(_templatePath).readAsStringSync().split('\n');

  final translations = <String, String>{};
  for (final tsv in positional.sublist(1)) {
    for (final line in File(tsv).readAsStringSync().split('\n')) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      final tab = line.indexOf('\t');
      if (tab == -1) {
        stderr.writeln('TSV 行缺少 TAB：$line');
        exit(2);
      }
      translations[line.substring(0, tab).trim()] = line.substring(tab + 1);
    }
  }

  final known = <String>{};
  final output = <String>[];
  var replaced = 0;
  for (final line in template) {
    final m = _stringLine.firstMatch(line);
    if (m == null) {
      output.add(line);
      continue;
    }
    final name = m.group(2)!;
    known.add(name);
    final value = translations[name];
    if (value == null) {
      output.add(line);
      continue;
    }
    replaced++;
    output.add('${m.group(1)}${androidValue(value)}${m.group(4)}');
  }

  final unknown = translations.keys.toSet().difference(known);
  stdout.writeln('$valuesDir: 模板 ${known.length} 条，替换 $replaced 条，'
      '未替换 ${known.length - replaced} 条（留英文），未知 key ${unknown.length} 条');
  for (final u in unknown.take(10)) {
    stdout.writeln('  未知: $u');
  }

  final outPath = 'android/questui/src/main/res/$valuesDir/strings.xml';
  if (dryRun) {
    stdout.writeln('--dry-run，未写盘（目标 $outPath）。');
    return;
  }
  final file = File(outPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(output.join('\n'));
  final written = File(outPath).readAsStringSync();
  final count = _stringLine.allMatches(written).length;
  if (count != known.length) {
    stdout.writeln('⚠️ 复核失败：写出 $count 条 <string>，模板是 ${known.length} 条。');
    exit(1);
  }
  stdout.writeln('已写入 $outPath（$count 条 <string>，与模板一致）。');
}
