// 生成翻译状态台账：按「语言 × 模块」与「逐条词条」两个粒度记录状态与责任人。
//
// 用法：dart run tool/i18n_ledger.dart
//
// 产出（都在 docs/ 下）：
//   i18n-translation-ledger.md      人读版：总表、模块×语言矩阵、维护指引
//   i18n-ledger-modules.csv         机读版：语言 × 模块 的完成度
//   i18n-ledger-entries.csv         机读版：逐条词条 × 12 门语言的状态
//
// 状态字符（单字符，已含「来源」信息）：
//   T = 已译，来源＝历史人工译文（已校对）
//   t = 已译，来源＝机器翻译首轮（待人工校对）
//   n = 与 en 相同但属合理相同（品牌名 / 纯占位符 / 纯数字符号）——无需翻译
//   U = 待译（与 en 逐字相同，属实漏译）
//   M = 该语言缺这个 key
//   P = 占位符与 en 不符（结构性缺陷）
//   D = 有争议（来自 docs/i18n-disputes.txt 的人工标注）
//
// 争议标注：`docs/i18n-disputes.txt`，每行 `locale<TAB>key<TAB>说明`，`#` 开头为注释。
import 'dart:io';

import 'package:yaml/yaml.dart';

const _baseLocale = 'en';
const _i18nDir = 'lib/i18n';
final _placeholderPattern =
    RegExp(r'\$\{[a-zA-Z_][a-zA-Z0-9_]*\}|\{[a-zA-Z_][a-zA-Z0-9_]*\}');

/// 责任人与来源
const _owner = <String, String>{
  'zh-CN': '既有译者（人工）',
  'zh-TW': '既有译者（人工）',
  'ja': '既有译者（人工）',
  'ko': '本地化流水线（机器首轮）',
  'ru': '既有译者 + 本地化流水线（机器首轮）',
  'th': '既有译者 + 本地化流水线（机器首轮）',
  'es': '本地化流水线（机器首轮）',
  'fr': '本地化流水线（机器首轮）',
  'de': '本地化流水线（机器首轮）',
  'vi': '本地化流水线（机器首轮）',
  'id': '本地化流水线（机器首轮）',
};

const _humanReviewed = {'zh-CN', 'zh-TW', 'ja'};

/// 某些词条在特定语言里**本来就该与 en 逐字相同**，不是漏译：
///   * 该语言照搬英文的通用软件词：Video / Forum / Filter / Premium / Playlist /
///     Tag / OK / Emoji / Regex / Zoom / Navigation / Router / Scanner …
///   * 品牌与技术名：Anthropic (Claude)、Google (Gemini)、DeepSeek Reasoning、
///     Liquid Glass、VR180 mono、Iwara online …
///   * 纯技术示例：正则本身（`^\[.*\]`、`\d{4}`），或该语言恰好也这么写的示例串。
/// 这里**逐条登记**（`locale -> key 集合`），只对登记过的 (语言, key) 生效；
/// 整句漏译、以及没登记的同形值，仍然会被当成「疑似未翻」抓出来。
/// 复核方式：`dart run tool/i18n_check.dart --list-untranslated <locale>` 里
/// 不该再出现这些 key，而其它未翻项照旧出现。
const sameWordAllowlist = <String, Set<String>>{
  'de': {
    'auth.captcha', 'bottomNav.community', 'bottomNav.subscription', 'bottomNav.video',
    'common.admin', 'common.fans', 'common.fensi', 'common.filter', 'common.follower',
    'common.imageQualityOriginal', 'common.imageQualityStandard', 'common.likesCount',
    'common.minute', 'common.ok', 'common.playlist', 'common.premium', 'common.tag', 'common.video',
    'diagnostics.schemaHealthOk', 'download.statusLabel', 'download.video', 'emoji.name',
    'externalPlayer.playerName', 'forum.forum', 'forum.groups.global', 'forum.leafNames.feedback',
    'forum.leafNames.support', 'forum.leafNames.support_ja', 'forum.leafNames.support_zh',
    'localMedia.browse.folderInfoName', 'localMedia.browse.sortFieldName',
    'localMedia.browse.videosSection', 'localMedia.sortName', 'localMedia.sourceOnline',
    'markdown.syntax', 'mediaPlayer.format', 'mediaPlayer.video', 'notifications.video',
    'oreno3d.tags', 'personalProfile.avatar', 'playList.videos', 'savedSearch.nameLabel',
    'savedSearchConfig.nameLabel', 'searchFilter.likes', 'searchFilter.operator',
    'searchFilter.sortTypes.likes', 'searchFilter.tags', 'searchFilter.videos',
    'settings.blockSettings.importExport', 'settings.blockSettings.regex',
    'settings.chatSettings.name', 'settings.community', 'settings.forum',
    'settings.forumSettings.name', 'settings.keybinding.categoryNavigation',
    'settings.keybinding.categoryZoom', 'settings.keybinding.scopeGlobal',
    'settings.keybinding.scopeVideo', 'settings.liquidGlassEffect',
    'settings.seekPreviewSizeStandard', 'settings.versionLabel', 'siteMode.mainSite',
    'translation.information', 'translation.presetNames.deepseekReasoner',
    'translation.presetNames.openaiReasoning', 'translation.providerAnthropic',
    'translation.providerGoogle', 'videoDetail.cast.deviceTypes.internetGatewayDevice',
    'videoDetail.cast.deviceTypes.scanner', 'videoDetail.pause'
  },
  'es': {
    'auth.captcha', 'bottomNav.localMedia', 'bottomNav.subscription', 'common.error',
    'common.general', 'common.imageQualityOriginal', 'common.ok', 'common.popular',
    'common.premium', 'diagnostics.schemaHealthOk', 'emoji.name', 'errors.error',
    'forum.groups.global', 'forum.leafNames.general', 'forum.leafNames.general_ja',
    'forum.leafNames.general_zh', 'mediaPlayer.local', 'personalProfile.avatar',
    'searchFilter.general', 'searchFilter.no', 'settings.blockSettings.regex',
    'settings.chatSettings.name', 'settings.downloadSettings.testError',
    'settings.keybinding.categoryZoom', 'settings.keybinding.scopeGlobal',
    'translation.providerAnthropic', 'translation.providerGoogle',
    'videoDetail.cast.deviceTypes.internetGatewayDevice', 'vrFormat.vr180Mono', 'vrFormat.vr360Mono'
  },
  'fr': {
    'auth.captcha', 'bottomNav.community', 'bottomNav.localMedia', 'common.admin',
    'common.imageQualityStandard', 'common.minute', 'common.ok', 'common.pagination.pagination',
    'common.premium', 'common.tag', 'common.videoQualitySource', 'conversation.conversation',
    'diagnostics.schemaHealthOk', 'download.pause', 'download.taskType', 'emoji.name',
    'forum.forum', 'forum.groups.administration', 'forum.groups.global', 'forum.leafNames.guides',
    'forum.leafNames.questions', 'forum.leafNames.questions_ja', 'forum.leafNames.questions_zh',
    'localMedia.browse.folderInfoSource', 'localMedia.browse.imagesSection', 'mediaPlayer.format',
    'mediaPlayer.local', 'news.articles', 'notifications.notifications', 'oreno3d.tags',
    'personalProfile.avatar', 'playbackQueue.galleryImageCount', 'playbackQueue.sourceTab',
    'savedSearchConfig.tagsCount', 'searchFilter.date', 'searchFilter.description',
    'searchFilter.images', 'searchFilter.playlists', 'searchFilter.tags', 'settings.appLockMinutes',
    'settings.blockSettings.regex', 'settings.downloadSettings.testCorrect', 'settings.forum',
    'settings.forumSettings.name', 'settings.hardwareDecodingAuto', 'settings.interaction',
    'settings.keybinding.categoryNavigation', 'settings.keybinding.categoryVolume',
    'settings.keybinding.categoryZoom', 'settings.keybinding.scopeGlobal',
    'settings.seekPreviewSizeStandard', 'settings.signature',
    'translation.presetNames.deepseekReasoner', 'translation.presetNames.openaiReasoning',
    'translation.providerAnthropic', 'translation.providerGoogle',
    'videoDetail.cast.deviceTypes.scanner', 'videoDetail.pause', 'videoDetail.volume',
    'vrFormat.vr180Mono', 'vrFormat.vr360Mono'
  },
  'id': {
    'bottomNav.community', 'bottomNav.subscription', 'bottomNav.video', 'common.filter',
    'common.ok', 'common.pagination.waterfall', 'common.premium', 'common.tag', 'common.tips',
    'common.video', 'diagnostics.schemaHealthOk', 'download.statusLabel', 'download.video',
    'emoji.name', 'forum.forum', 'forum.groups.global', 'localMedia.sortFolder',
    'localMedia.sourceOnline', 'mediaPlayer.format', 'mediaPlayer.video', 'notifications.kVideo',
    'notifications.video', 'personalProfile.avatar', 'searchFilter.boolean',
    'searchFilter.operator', 'settings.blockSettings.regex',
    'settings.blockSettings.regexEx1Pattern', 'settings.blockSettings.regexEx6Pattern',
    'settings.downloadSettings.testValid', 'settings.forum', 'settings.forumSettings.name',
    'settings.keybinding.categoryVolume', 'settings.keybinding.categoryZoom',
    'settings.keybinding.scopeGlobal', 'settings.keybinding.scopeVideo', 'siteMode.mainSite',
    'translation.providerAnthropic', 'translation.providerGoogle',
    'videoDetail.cast.deviceTypes.internetGatewayDevice', 'videoDetail.volume',
    'vrFormat.vr180Mono', 'vrFormat.vr360Mono'
  },
  'vi': {
    'auth.email', 'bottomNav.community', 'bottomNav.subscription', 'bottomNav.video', 'common.ok',
    'common.video', 'diagnostics.schemaHealthOk', 'download.video', 'mediaPlayer.video',
    'notifications.kVideo', 'notifications.video', 'searchFilter.boolean',
    'settings.blockSettings.regex', 'settings.keybinding.scopeVideo', 'siteMode.mainSite',
    'translation.presetNames.deepseekReasoner', 'translation.presetNames.openaiReasoning',
    'translation.providerAnthropic', 'translation.providerGoogle', 'vrFormat.vr180Mono',
    'vrFormat.vr360Mono'
  },
};

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

Map<String, String> _load(String locale) =>
    _flatten(loadYaml(File('$_i18nDir/$locale.i18n.yaml').readAsStringSync()) as YamlMap);

bool _legitimatelyIdentical(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) return true;
  if (RegExp(r'^[\d\s\p{P}\p{S}]+$', unicode: true).hasMatch(trimmed)) return true;
  if (RegExp(r'^\$?\{[a-zA-Z_][a-zA-Z0-9_]*\}$').hasMatch(trimmed)) return true;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return true;
  return const {
    'Iwara', 'Love Iwara', 'Oreno3D', 'MMD', 'Anime4K', 'Quest', 'VR', 'mpv',
    'GitHub', 'Discord', 'Telegram', 'English', '日本語', '中文', 'AI', 'ID',
  }.contains(trimmed);
}

Set<String> _placeholders(String value) =>
    _placeholderPattern.allMatches(value).map((m) => m[0]!).toSet();

({String state, String section}) _stateOf({
  required String locale,
  required String key,
  required Map<String, String> base,
  required Map<String, String> current,
  required Set<String> disputes,
}) {
  final section = key.contains('.') ? key.split('.').first : '(root)';
  if (disputes.contains('$locale\t$key')) return (state: 'D', section: section);
  final source = base[key]!;
  if (!current.containsKey(key)) return (state: 'M', section: section);
  final value = current[key]!;
  if (!_samePlaceholders(_placeholders(source), _placeholders(value))) {
    return (state: 'P', section: section);
  }
  if (value == source) {
    final allowed = sameWordAllowlist[locale]?.contains(key) ?? false;
    return (
      state: _legitimatelyIdentical(source) || allowed ? 'n' : 'U',
      section: section,
    );
  }
  return (state: _humanReviewed.contains(locale) ? 'T' : 't', section: section);
}

bool _samePlaceholders(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

String _csv(String field) {
  if (field.contains(',') || field.contains('"') || field.contains('\n')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}

Set<String> _loadDisputes() {
  final file = File('docs/i18n-disputes.txt');
  if (!file.existsSync()) return <String>{};
  final result = <String>{};
  for (final line in file.readAsLinesSync()) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    final parts = line.split('\t');
    if (parts.length >= 2) result.add('${parts[0].trim()}\t${parts[1].trim()}');
  }
  return result;
}

void main() {
  final base = _load(_baseLocale);
  final baseKeys = base.keys.toList();
  final locales = Directory(_i18nDir)
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n.endsWith('.i18n.yaml'))
      .map((n) => n.substring(0, n.length - '.i18n.yaml'.length))
      .where((l) => l != _baseLocale)
      .toList()
    ..sort();
  final disputes = _loadDisputes();

  final states = <String, Map<String, String>>{};
  for (final locale in locales) {
    final current = _load(locale);
    final row = <String, String>{};
    for (final key in baseKeys) {
      row[key] = _stateOf(
        locale: locale,
        key: key,
        base: base,
        current: current,
        disputes: disputes,
      ).state;
    }
    states[locale] = row;
  }

  // ── 逐条台账 CSV ──────────────────────────────────────────────
  final entries = StringBuffer();
  entries.writeln(
      '# LoveIwara 翻译状态台账（逐条）。由 `dart run tool/i18n_ledger.dart` 生成，勿手改。');
  entries.writeln('# 状态字符见 docs/i18n-translation-ledger.md 的图例。');
  entries.writeln(
      ['section', 'key', 'en_preview', ...locales].map(_csv).join(','));
  for (final key in baseKeys) {
    final section = key.contains('.') ? key.split('.').first : '(root)';
    final preview = base[key]!.replaceAll('\n', '\\n');
    entries.writeln([
      section,
      key,
      preview.length > 40 ? '${preview.substring(0, 40)}…' : preview,
      ...locales.map((l) => states[l]![key]!),
    ].map(_csv).join(','));
  }
  File('docs/i18n-ledger-entries.csv').writeAsStringSync(entries.toString());

  // ── 语言 × 模块 台账 CSV + 汇总 ────────────────────────────────
  final sections = <String>{};
  for (final key in baseKeys) {
    sections.add(key.contains('.') ? key.split('.').first : '(root)');
  }
  final sortedSections = sections.toList()..sort();

  final modules = StringBuffer();
  modules.writeln(
      '# LoveIwara 翻译状态台账（语言 × 模块）。由 `dart run tool/i18n_ledger.dart` 生成，勿手改。');
  modules.writeln(
      'locale,section,total,translated,pending,missing,placeholder_mismatch,no_need,disputed,coverage,owner,status');
  final perLocaleTotals = <String, Map<String, int>>{};
  final moduleRows = <String, Map<String, List<int>>>{};

  for (final locale in locales) {
    final totals = {'total': 0, 'translated': 0, 'pending': 0, 'missing': 0,
      'placeholder_mismatch': 0, 'no_need': 0, 'disputed': 0};
    for (final section in sortedSections) {
      final counts = [0, 0, 0, 0, 0, 0, 0];
      for (final key in baseKeys) {
        final sectionOfKey = key.contains('.') ? key.split('.').first : '(root)';
        if (sectionOfKey != section) continue;
        counts[0]++;
        switch (states[locale]![key]) {
          case 'T' || 't':
            counts[1]++;
          case 'U':
            counts[2]++;
          case 'M':
            counts[3]++;
          case 'P':
            counts[4]++;
          case 'n':
            counts[5]++;
          case 'D':
            counts[6]++;
        }
      }
      for (var i = 0; i < counts.length; i++) {
        totals[['total', 'translated', 'pending', 'missing', 'placeholder_mismatch', 'no_need', 'disputed'][i]] =
            totals[['total', 'translated', 'pending', 'missing', 'placeholder_mismatch', 'no_need', 'disputed'][i]]! + counts[i];
      }
      moduleRows.putIfAbsent(section, () => {})[locale] = counts;
      final coverage = counts[0] == 0
          ? 100.0
          : (counts[1] + counts[5]) / counts[0] * 100;
      final state = counts[2] + counts[3] + counts[4] + counts[6] > 0
          ? '进行中'
          : (counts[1] == 0 ? '无需翻译' : '首轮完成，待校对');
      modules.writeln([
        locale,
        section,
        counts[0],
        counts[1],
        counts[2],
        counts[3],
        counts[4],
        counts[5],
        counts[6],
        coverage.toStringAsFixed(1),
        _owner[locale] ?? '-',
        state,
      ].map((e) => _csv('$e')).join(','));
    }
    perLocaleTotals[locale] = totals;
  }
  File('docs/i18n-ledger-modules.csv').writeAsStringSync(modules.toString());

  // ── 人读版 md ────────────────────────────────────────────────
  final md = StringBuffer();
  final now = DateTime.now();
  md.writeln('# 多语言翻译状态台账');
  md.writeln();
  md.writeln('本文件由 `dart run tool/i18n_ledger.dart` 生成（生成时间：'
      '${now.toIso8601String().substring(0, 19)}，时区 ${now.timeZoneName}）。'
      '基准语言 `en` 共 **${baseKeys.length}** 条叶子词条，'
      '语言 **${locales.length + 1}** 门。');
  md.writeln();
  md.writeln('配套机读台账（每次改动后重新生成即可保持一致）：');
  md.writeln();
  md.writeln('- `docs/i18n-ledger-entries.csv`：逐条词条 × 每门语言的状态字符（可追溯的最小单位）；');
  md.writeln('- `docs/i18n-ledger-modules.csv`：语言 × 模块的完成度、覆盖率、责任人与状态。');
  md.writeln();
  md.writeln('## 图例');
  md.writeln();
  md.writeln('| 字符 | 含义 | 计入覆盖率 |');
  md.writeln('|---|---|---|');
  md.writeln('| `T` | 已译，来源＝历史人工译文（已校对） | 是 |');
  md.writeln('| `t` | 已译，来源＝机器翻译首轮（**待人工校对**） | 是 |');
  md.writeln('| `n` | 与 en 相同但属合理相同（品牌名 / 纯占位符 / 纯数字符号）——无需翻译 | 是 |');
  md.writeln('| `U` | 待翻译（与 en 逐字相同，属实漏译） | 否 |');
  md.writeln('| `M` | 该语言缺这个 key（结构缺陷） | 否 |');
  md.writeln('| `P` | 占位符与 en 不符（结构缺陷） | 否 |');
  md.writeln('| `D` | 有争议（人工在 `docs/i18n-disputes.txt` 标注） | 否 |');
  md.writeln();

  md.writeln('## 总表');
  md.writeln();
  md.writeln('| 语言 | 词条 | 已译(T/t) | 无需翻译(n) | 待译(U) | 缺失(M) | 占位符不符(P) | 有争议(D) | 覆盖率 | 责任人 | 状态 |');
  md.writeln('|---|---|---|---|---|---|---|---|---|---|---|');
  for (final locale in locales) {
    final t = perLocaleTotals[locale]!;
    final coverage = t['total'] == 0
        ? 100.0
        : (t['translated']! + t['no_need']!) / t['total']! * 100;
    final pending = t['pending']! + t['missing']! + t['placeholder_mismatch']! + t['disputed']!;
    final status = pending > 0
        ? '待办 $pending 条'
        : (_humanReviewed.contains(locale) ? '已完成' : '首轮完成，待人工校对');
    md.writeln('| `$locale` | ${t['total']} | ${t['translated']} | ${t['no_need']} | '
        '${t['pending']} | ${t['missing']} | ${t['placeholder_mismatch']} | '
        '${t['disputed']} | ${coverage.toStringAsFixed(1)}% | ${_owner[locale] ?? '-'} | $status |');
  }
  md.writeln();

  md.writeln('## 模块 × 语言（单元格 = 已译 / 总条数）');
  md.writeln();
  md.writeln('| 模块 | ${locales.join(' | ')} |');
  md.writeln('|---|${locales.map((_) => '---').join('|')}|');
  for (final section in sortedSections) {
    final cells = locales.map((locale) {
      final counts = moduleRows[section]![locale]!;
      final done = counts[1] + counts[5];
      final flag = counts[2] + counts[3] + counts[4] + counts[6] > 0 ? '' : ' ✓';
      return '$done/${counts[0]}$flag';
    }).join(' | ');
    md.writeln('| `$section` | $cells |');
  }
  md.writeln();

  md.writeln('## 有争议词条');
  md.writeln();
  if (disputes.isEmpty) {
    md.writeln('当前无人工标注的争议词条。');
    md.writeln();
    md.writeln('标注方式：在 `docs/i18n-disputes.txt` 增加一行 `locale<TAB>key<TAB>说明`，'
        '再跑一次 `dart run tool/i18n_ledger.dart`，该条会变成 `D` 并出现在这里。');
  } else {
    final disputesFile = File('docs/i18n-disputes.txt');
    md.writeln('| 语言 | key | 说明 |');
    md.writeln('|---|---|---|');
    for (final line in disputesFile.readAsLinesSync()) {
      if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
      final parts = line.split('\t');
      if (parts.length >= 2) {
        md.writeln('| `${parts[0].trim()}` | `${parts[1].trim()}` | '
            '${parts.length > 2 ? parts[2].trim() : ''} |');
      }
    }
  }
  md.writeln();

  md.writeln('## 维护方式');
  md.writeln();
  md.writeln('1. 改完任何 `lib/i18n/*.i18n.yaml` 后跑一次 `dart run tool/i18n_ledger.dart`，'
      '三份台账会整体重新生成——台账永远等于代码真实状态，不存在手抄误差。');
  md.writeln('2. 词条翻译/校对状态由**文件内容**推导：与 en 逐字相同＝`U`，'
      '不同＝已译；`T`（人工）与 `t`（机器首轮）的区分来自本工具里的语言责任人表，'
      '某个语言完成人工校对后，把该语言加进 `_humanReviewed` 即可整列从 `t` 变 `T`。');
  md.writeln('3. `n` 类词条（品牌名、`mode_a_hq` 这类预设名、纯占位符）不需要翻译，'
      '它们出现在 `U` 里反而是缺陷；判定规则与 `tool/i18n_check.dart` 完全一致。');
  md.writeln('4. 单条争议用 `docs/i18n-disputes.txt` 标注，不要手改生成的 CSV。');
  File('docs/i18n-translation-ledger.md').writeAsStringSync(md.toString());

  stdout.writeln('已生成：');
  stdout.writeln('  docs/i18n-translation-ledger.md');
  stdout.writeln('  docs/i18n-ledger-modules.csv（${locales.length * sortedSections.length} 行）');
  stdout.writeln('  docs/i18n-ledger-entries.csv（${baseKeys.length} 行 × ${locales.length} 门语言）');
}
