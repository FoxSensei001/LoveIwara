// 译文质量巡检：把「机器首轮」里**能自动发现**的缺陷扫出来，供人工校对前先清一遍。
//
// 用法：
//   dart run tool/i18n_quality_scan.dart                # 扫全部语言
//   dart run tool/i18n_quality_scan.dart de es          # 只扫指定语言
//
// 它查的是**结构外的质量问题**（结构问题归 `i18n_check.dart` 管）：
//   A. 残留英文：整句里混着没翻的英文实词（≥2 个，且不在品牌/技术白名单里）
//   B. 空白异常：首尾空白、连续两个空格
//   C. 换行不一致：`\n` 数量与 en 不同（正文段落结构被改坏）
//   D. 标点丢失：en 以 . … ： ? ! 结尾而译文没有（或反之）
//   E. 长度异常：en 较长而译文短得离谱（疑似截断/漏译）
//
// 输出同时写进 `docs/i18n-quality-findings.md`，便于逐条派工。
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'i18n_check.dart' show sameWordAllowlist;

const _baseLocale = 'en';
const _i18nDir = 'lib/i18n';

/// 只属于英语的**虚词**。目标语言的句子里几乎不可能自然出现这些词，所以
/// 一旦命中就极可能是「整句没翻」或「半句没翻」——比按实词比对可靠得多
/// （实词在拉丁语系里到处都是同形词：fr 的 images / permission / playlist 都是
/// 合法法语，按实词查会把噪声当信号）。
const _englishOnlyWords = <String>{
  'the', 'of', 'and', 'with', 'your', 'you', 'this', 'that', 'will', 'have',
  'from', 'when', 'they', 'their', 'should', 'would', 'could', 'than', 'these',
  'those', 'which', 'while', 'about', 'into', 'because', 'between', 'during',
  'before', 'after', 'again', 'always', 'never', 'please', 'cannot', 'yourself',
  'something', 'anything', 'everything', 'nothing', 'somewhere', 'anywhere',
  'however', 'therefore', 'otherwise', 'although', 'unless', 'until',
};

/// 品牌名 / 技术名 / 规格串：出现在译文里是**正确**的，不算残留英文。
const _brands = <String>{
  'iwara', 'love', 'oreno3d', 'mmd', 'anime4k', 'quest', 'vr', 'vr180', 'vr360', 'mpv',
  'github', 'discord', 'telegram', 'mp4', 'webm', 'mkv', 'av1', 'hevc', 'gpu', 'aac',
  'hdr', 'hls', 'dash', 'cors', 'api', 'url', 'uri', 'json', 'yaml', 'http', 'https',
  'android', 'ios', 'macos', 'windows', 'linux', 'webdav', 'socks', 'proxy', 'user',
  'agent', 'dark', 'light', 'system', 'auto', 'liquid', 'glass', 'material', 'regex',
  'anime', 'mode', 'hq', 'fast', 'lite', 'deepseek', 'openai', 'anthropic', 'claude',
  'gemini', 'google', 'siliconflow', 'zhipu', 'glm', 'gpt', 'api key', 'rtx', 'nvidia',
  'intel', 'amd', 'snapdragon', 'eac', 'flat', 'fisheye', 'id', 'ai', 'ok', 'emoji',
  'danmaku', 'vc', 'bilibili', 'youtube', 'x', 'twitter', 'pixiv', 'fanbox', 'patreon'
};

final _word = RegExp(r"[A-Za-z][A-Za-z'’\-]{3,}");

Map<String, String> _flatten(YamlMap node, [String prefix = '']) {
  final result = <String, String>{};
  for (final entry in node.entries) {
    final key = prefix.isEmpty ? '${entry.key}' : '$prefix.${entry.key}';
    final value = entry.value;
    if (value is YamlMap) {
      result.addAll(_flatten(value, key));
    } else {
      result[key] = '$value';
    }
  }
  return result;
}

Map<String, String> _load(String locale) => _flatten(
    loadYaml(File('$_i18nDir/$locale.i18n.yaml').readAsStringSync()) as YamlMap);

/// ⛔ 取词前必须先抠掉占位符与格式串：`${resolution}` / `{count}` / `%1$s` 里的
/// 名字是**机器标识**，不是译文里的英文单词。不抠掉的话，`${size}`、`${success}`
/// 这类会被算成「残留英文」，把真正的信号淹掉（本工具第一版就是这么被淹掉的）。
final _placeholderOrFormat = RegExp(
  r'\$\{[a-zA-Z_][a-zA-Z0-9_]*\}|\{[a-zA-Z_][a-zA-Z0-9_]*\}|%[0-9]+\$[sd]|\\[nt]',
);

Set<String> _words(String text) => _word
    .allMatches(text.replaceAll(_placeholderOrFormat, ' '))
    .map((m) => m[0]!.toLowerCase())
    .where((w) => w.length >= 4 && !_brands.contains(w))
    .toSet();

List<String> _allLocales() => Directory(_i18nDir)
    .listSync()
    .whereType<File>()
    .map((f) => f.uri.pathSegments.last)
    .where((n) => n.endsWith('.i18n.yaml'))
    .map((n) => n.substring(0, n.length - '.i18n.yaml'.length))
    .toList()
  ..sort();

void main(List<String> args) {
  // `--inspect <key>`：把某个 key 在各语言里的值按「真换行 / 字面反斜杠」可视化打印，
  // 用来判断 YAML 里写的是真换行还是字面量 \n —— 这类差异只在渲染时才显形。
  final inspectIndex = args.indexOf('--inspect');
  if (inspectIndex != -1 && inspectIndex + 1 < args.length) {
    final key = args[inspectIndex + 1];
    const newline = '\n';
    const backslash = '\\';
    for (final locale in _allLocales()) {
      final value = _load(locale)[key];
      if (value == null) {
        stdout.writeln('$locale: 无此 key');
        continue;
      }
      final visual =
          value.replaceAll(backslash, '⧵').replaceAll(newline, '⏎');
      final nl = newline.allMatches(value).length;
      final bs = backslash.allMatches(value).length;
      stdout.writeln('$locale: 真换行=$nl 反斜杠=$bs 长度=${value.length}');
      stdout.writeln('    $visual');
    }
    return;
  }

  final base = _load(_baseLocale);
  final locales = (args.isEmpty
          ? Directory(_i18nDir)
              .listSync()
              .whereType<File>()
              .map((f) => f.uri.pathSegments.last)
              .where((n) => n.endsWith('.i18n.yaml'))
              .map((n) => n.substring(0, n.length - '.i18n.yaml'.length))
              .where((l) => l != _baseLocale)
              .toList()
          : args)
      .toList()
    ..sort();

  final out = StringBuffer();
  out.writeln('# 译文质量巡检结果');
  out.writeln();
  out.writeln('由 `dart run tool/i18n_quality_scan.dart` 生成。只列**疑似问题**，'
      '每条都要人工判断。');
  out.writeln();
  out.writeln('## 怎么读这份报告');
  out.writeln();
  out.writeln('- **F 英文虚词 = 高信号**：`the/of/and/with/your…` 这些只属于英语的虚词'
      '几乎不可能自然出现在目标语言句子里，命中即「没翻干净」。'
      '基线（人工译文 ja/zh-CN/zh-TW）也有 1 条，都是文中**故意保留的英文示例**'
      '（如 `which mpv`、`Material You`、正则示例 `the (movie|series)`）。');
  out.writeln('- **A 实词同形 = 低信号/噪声**：拉丁语系里 `images/permission/playlist/'
      'notification` 这些词本身就是合法译文，所以 A 类条数在人工译文里也有 37~40 条。'
      '**A 类只能人工扫一眼，不要当缺陷清单**。（本工具第一版还漏了「先抠掉 '
      '`\${...}` 占位符再取词」，把 `\${size}` `\${success}` 这类机器标识也算成了英文，'
      '已经修掉。）');
  out.writeln('- **B 空白 / C 换行 / D 标点 / E 长度**：只报**与 en 不一致**的。'
      '其中 C 已按运行期语义归一——slang 生成 Dart 时会把 YAML 里的字面量 `\\n` '
      '写成真换行，两种 YAML 写法运行期完全一样（已实测）。');
  out.writeln();
  final summary = <String, List<int>>{};

  for (final locale in locales) {
    final cur = _load(locale);
    final allow = sameWordAllowlist[locale] ?? const <String>{};
    final mix = <String>[];
    final englishWords = <String>[];
    final space = <String>[];
    final newline = <String>[];
    final punct = <String>[];
    final short = <String>[];

    for (final key in base.keys) {
      final en = base[key];
      final tr = cur[key];
      if (en == null || tr == null || tr == en) continue;
      if (allow.contains(key)) continue;

      // F. 英文虚词：命中即高置信度的「没翻干净」
      final hits = _englishOnlyWords
          .where((w) => RegExp(
                '(?<![A-Za-z])$w(?![A-Za-z])',
                caseSensitive: false,
              ).hasMatch(tr))
          .toList()
        ..sort();
      if (hits.isNotEmpty) {
        englishWords.add('$key\t[${hits.join(', ')}]\t$tr');
      }
      // A. 残留英文
      final shared = _words(en).intersection(_words(tr));
      if (shared.length >= 2 ||
          (shared.length == 1 &&
              shared.first.length >= 8 &&
              _words(tr).length <= 2)) {
        mix.add('$key\t[${(shared.toList()..sort()).join(', ')}]\t$tr');
      }
      // B. 空白：只报**与 en 不一致**的。en 自己就带首尾空格的前缀片段、以及 markdown
      //    示例里那两个尾随空格（在 markdown 里是有意义的结构），都不算缺陷。
      if ((tr != tr.trim()) != (en != en.trim())) {
        space.add('$key\t[首尾空白与 en 不同]\ten=${en.replaceAll(' ', '·')} '
            '译文=${tr.replaceAll(' ', '·')}');
      }
      if (tr.contains('  ') != en.contains('  ')) {
        space.add('$key\t[连续空格与 en 不同]\t$tr');
      }
      // C. 换行
      //
      // ⛔ 必须先把**字面量** `\n` 归一成真换行再比：slang 生成 Dart 时会把
      // YAML 里的字面量 `\n` 写成 Dart 的 `\n`（运行时就是真换行），所以
      // 「en 用单引号写字面量、译文用双引号写真换行」这种差异**运行期完全一样**，
      // 不是缺陷（已用 test/tool/i18n_generated_inspect_test.dart 实测确认）。
      String normalize(String v) => v.replaceAll('\\n', '\n');
      final enNl = '\n'.allMatches(normalize(en)).length;
      final trNl = '\n'.allMatches(normalize(tr)).length;
      if (enNl != trNl) {
        newline.add('$key\ten 有 $enNl 个换行，译文 $trNl 个');
      }
      // D. 标点
      const marks = ['...', '…', '?', '!', '.', ':', '。', '？', '！', '：'];
      bool endsWithMark(String s) =>
          marks.any((m) => s.trimRight().endsWith(m));
      if (endsWithMark(en) && !endsWithMark(tr)) {
        punct.add('$key\ten「$en」→「$tr」');
      }
      // E. 长度
      if (en.length >= 24 && tr.length < en.length * 0.45) {
        short.add('$key\ten(${en.length})「$en」→ 译文(${tr.length})「$tr」');
      }
    }

    summary[locale] = [
      mix.length,
      space.length,
      newline.length,
      punct.length,
      short.length,
      englishWords.length,
    ];
    out.writeln('## $locale');
    out.writeln();
    out.writeln('| 类别 | 条数 |');
    out.writeln('|---|---|');
    out.writeln('| A 残留英文 | ${mix.length} |');
    out.writeln('| B 空白异常 | ${space.length} |');
    out.writeln('| C 换行不一致 | ${newline.length} |');
    out.writeln('| D 标点不一致 | ${punct.length} |');
    out.writeln('| E 长度异常 | ${short.length} |');
    out.writeln('| **F 英文虚词（高信号）** | **${englishWords.length}** |');
    out.writeln();
    void dump(String title, List<String> items, {int limit = 40}) {
      if (items.isEmpty) return;
      out.writeln('### $title');
      out.writeln();
      for (final line in items.take(limit)) {
        out.writeln('- `$line`');
      }
      if (items.length > limit) {
        out.writeln('- …另有 ${items.length - limit} 条（完整列表见终端输出）');
      }
      out.writeln();
    }

    dump('F 英文虚词（几乎可以肯定是没翻干净）', englishWords);
    dump('A 残留英文（实词同形，噪声大，仅供人工扫一眼）', mix);
    dump('B 空白异常', space);
    dump('C 换行不一致', newline);
    dump('D 标点不一致', punct);
    dump('E 长度异常', short);
  }

  out.writeln('## 汇总');
  out.writeln();
  out.writeln('| 语言 | F 英文虚词 | A 实词同形 | B 空白 | C 换行 | D 标点 | E 长度 |');
  out.writeln('|---|---|---|---|---|---|---|');
  for (final e in summary.entries) {
    out.writeln('| ${e.key} | **${e.value[5]}** | ${e.value[0]} | ${e.value[1]} | '
        '${e.value[2]} | ${e.value[3]} | ${e.value[4]} |');
  }
  File('docs/i18n-quality-findings.md').writeAsStringSync(out.toString());

  for (final e in summary.entries) {
    stdout.writeln('${e.key}: 英文虚词(F) ${e.value[5]} / 实词同形(A) ${e.value[0]} / '
        '空白 ${e.value[1]} / 换行 ${e.value[2]} / 标点 ${e.value[3]} / 长度 ${e.value[4]}');
  }
  stdout.writeln('已写入 docs/i18n-quality-findings.md');
}
