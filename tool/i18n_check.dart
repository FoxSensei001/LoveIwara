// i18n 一致性校验：比对各语言 yaml 与基准语言 en 的 key 集合和占位符。
//
// 用法：dart run tool/i18n_check.dart
// 退出码 0 表示全部一致，1 表示存在缺失 key、多余 key 或占位符不匹配。
//
// slang 配了 fallback_strategy: base_locale，缺词条不会让生成失败——漏译全靠
// 这条闸门显式抓出来。
import 'dart:io';

import 'package:yaml/yaml.dart';

const baseLocale = 'en';
const i18nDir = 'lib/i18n';

/// `${name}` 与 `{name}` 两种形态都算占位符，翻译时必须原样保留。
final placeholderPattern = RegExp(r'\$\{[a-zA-Z_][a-zA-Z0-9_]*\}|\{[a-zA-Z_][a-zA-Z0-9_]*\}');

Map<String, String> flatten(YamlMap node, [String prefix = '']) {
  final result = <String, String>{};
  for (final entry in node.entries) {
    final key = prefix.isEmpty ? '${entry.key}' : '$prefix.${entry.key}';
    final value = entry.value;
    if (value is YamlMap) {
      result.addAll(flatten(value, key));
    } else {
      result[key] = '$value';
    }
  }
  return result;
}

Map<String, String> loadLocale(String locale) {
  final file = File('$i18nDir/$locale.i18n.yaml');
  return flatten(loadYaml(file.readAsStringSync()) as YamlMap);
}

List<String> discoverLocales() {
  return Directory(i18nDir)
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((n) => n.endsWith('.i18n.yaml'))
      .map((n) => n.substring(0, n.length - '.i18n.yaml'.length))
      .where((l) => l != baseLocale)
      .toList()
    ..sort();
}

void main(List<String> args) {
  final base = loadLocale(baseLocale);
  final baseKeys = base.keys.toSet();

  // `--list-untranslated <locale>`：只吐出该语言仍与 en 逐字相同的词条，
  // 一行一条 `key<TAB>英文原文`，给翻译流程当待办清单用。
  final listIndex = args.indexOf('--list-untranslated');
  if (listIndex != -1 && listIndex + 1 < args.length) {
    final locale = args[listIndex + 1];
    final current = loadLocale(locale);
    final pending = baseKeys.intersection(current.keys.toSet())
        .where((k) => current[k] == base[k] && !_legitimatelyIdentical(base[k]!))
        .toList()
      ..sort();
    for (final key in pending) {
      stdout.writeln('$key\t${base[key]!.replaceAll('\n', '\\n')}');
    }
    stderr.writeln('$locale 待翻 ${pending.length} 条');
    return;
  }

  stdout.writeln('$baseLocale: ${base.length} 条叶子（基准）');

  var failed = false;
  for (final locale in discoverLocales()) {
    final current = loadLocale(locale);
    final keys = current.keys.toSet();
    final missing = baseKeys.difference(keys).toList()..sort();
    final extra = keys.difference(baseKeys).toList()..sort();

    final mismatched = <String>[];
    for (final key in baseKeys.intersection(keys)) {
      final expected = placeholderPattern.allMatches(base[key]!).map((m) => m[0]!).toSet();
      final actual = placeholderPattern.allMatches(current[key]!).map((m) => m[0]!).toSet();
      if (!_setEquals(expected, actual)) {
        mismatched.add('$key: 期望 ${_sorted(expected)}，实际 ${_sorted(actual)}');
      }
    }
    mismatched.sort();

    // 与 en 逐字相同的词条＝大概率没翻。品牌名、纯数字、纯占位符这类本来就
    // 该保持原样，不算漏译。
    final untranslated = <String>[];
    final allowed = <String>[];
    for (final key in baseKeys.intersection(keys)) {
      final source = base[key]!;
      if (current[key] != source || _legitimatelyIdentical(source)) continue;
      if (sameWordAllowlist[locale]?.contains(key) ?? false) {
        allowed.add(key);
        continue;
      }
      untranslated.add(key);
    }
    untranslated.sort();

    final ok = missing.isEmpty && extra.isEmpty && mismatched.isEmpty;
    final translatable = baseKeys.intersection(keys).where((k) => !_legitimatelyIdentical(base[k]!)).length;
    final rate = translatable == 0 ? 0.0 : untranslated.length / translatable * 100;
    stdout.writeln(
      '$locale: ${current.length} 条，缺 ${missing.length}，多 ${extra.length}，'
      '占位符不符 ${mismatched.length}，疑似未翻 ${untranslated.length}'
      '（${rate.toStringAsFixed(1)}%）'
      '${allowed.isEmpty ? '' : '，同形外来词豁免 ${allowed.length}'}'
      '${ok && untranslated.isEmpty ? '  ✓' : ''}',
    );
    _report('缺失', missing);
    _report('多余', extra);
    _report('占位符', mismatched);
    _report('未翻', untranslated, limit: 10);
    if (!ok) failed = true;
  }

  if (failed) {
    stdout.writeln('\n校验未通过。');
    exit(1);
  }
  stdout.writeln('\n全部语言与 $baseLocale 一致。');
}

void _report(String label, List<String> items, {int limit = 20}) {
  for (final item in items.take(limit)) {
    stdout.writeln('    $label: $item');
  }
  if (items.length > limit) {
    stdout.writeln('    $label: ……另有 ${items.length - limit} 条');
  }
}

String _sorted(Set<String> values) => (values.toList()..sort()).join(', ');

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

/// 这些值在任何语言里保持与 en 一致都是正常的，不该计入漏译：
/// 纯占位符 / 纯数字与符号 / URL / 单个品牌名。
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

bool _setEquals(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);
