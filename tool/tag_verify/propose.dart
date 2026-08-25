/// 把核实证据变成两样可审阅的东西：
///
///   1. **补译提案**（`out/proposal_untranslated.json`）——重抓带回的新词条，
///      能从 Danbooru 证据直接填的语言先填好，填不了的列进批次任务交给 AI。
///      归宿是 `*_localized.json`（派生层），因为它们是「新产出的译名」。
///
///   2. **修正提案**（`out/proposal_fixes.json`）——现有译名的机械性缺陷，
///      目前只做「中文里夹罗马音」（`足立Rei` → `足立零`）这一类：
///      判据明确、几乎不需要判断。归宿是 `overrides.json`（人工层），
///      因为它们是对既有 AI 译名的修正，必须永不被重译覆盖。
///
///   3. **AI 批次任务**（`out/batch_XXX.in.json`）——确定性层填不动的部分。
///      每批默认 120 条，严格文件对文件：agent 读 .in.json 写 .out.json，
///      **永远不碰主词库**，合并由脚本做。
///
/// 本脚本只产出提案，**不改任何词库**。审阅通过后用 --apply 落盘。
///
/// 用法：
///   dart run tool/tag_verify/propose.dart                    # 只生成提案
///   dart run tool/tag_verify/propose.dart --apply-untranslated
///   dart run tool/tag_verify/propose.dart --apply-fixes
library;

import 'dart:convert';
import 'dart:io';

const _langs = ['zh-CN', 'zh-TW', 'ja', 'en'];
const _batchSize = 120;
final _latin = RegExp(r'[A-Za-z]');
final _paren = RegExp(r'[（(][^）)]*[）)]');
final _han = RegExp(r'[一-鿿]');

String? _evidenceUrl(Map<String, dynamic> r) {
  if (r['found'] != true) return null;
  final d = (r['danbooru'] as Map?)?.cast<String, dynamic>();
  return d?['url'] as String?;
}

Map<String, dynamic>? _evidenceOf(Map<String, dynamic> r) {
  if (r['found'] != true) return null;
  final d = (r['danbooru'] as Map?)?.cast<String, dynamic>();
  if (d == null) return null;
  return {'danbooru': d['url'], 'otherNames': d['otherNames']};
}

List<String>? _refOf(Map<String, dynamic> r) {
  final u = _evidenceUrl(r);
  return u == null ? null : [u];
}

Map<String, dynamic> _json(String p) =>
    jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;

void main(List<String> args) {
  final ev = _json('tool/tag_verify/out/evidence.json');
  final raw = _json('tool/data/oreno3d_tags/oreno3d_tags.json');
  final loc = _json('tool/data/oreno3d_tags/oreno3d_tags_localized.json');

  final byKey = <String, Map<String, dynamic>>{
    for (final cat in ['origins', 'characters', 'tags'])
      for (final e in (raw[cat] as List))
        '$cat/${(e as Map)['id']}': e.cast<String, dynamic>(),
  };

  // 同名词条（38 组共享日文名）不参与批量修正——见上面第 2 段的理由。
  final nameCount = <String, int>{};
  for (final e in byKey.values) {
    final n = e['name'] as String;
    nameCount[n] = (nameCount[n] ?? 0) + 1;
  }
  final sharedJaNames =
      nameCount.entries.where((e) => e.value > 1).map((e) => e.key).toSet();

  final untranslated = <String, dynamic>{};
  final needAi = <Map<String, dynamic>>[];
  final fixes = <String, dynamic>{};

  for (final r in (ev['results'] as List).cast<Map<String, dynamic>>()) {
    final key = r['key'] as String;
    final entry = byKey[key];
    if (entry == null) continue;
    final ja = entry['name'] as String;
    final cand = (r['candidates'] as Map?)?.cast<String, dynamic>();

    String? pick(String bucket) {
      final list = (cand?[bucket] as List?)?.map((e) => '$e').toList() ?? const [];
      final cleaned = list
          .map((e) => e.replaceAll(_paren, '').trim())
          .where((e) => e.isNotEmpty && e != ja)
          .toList();
      if (cleaned.isEmpty) return null;
      cleaned.sort((a, b) => a.runes.length.compareTo(b.runes.length));
      return cleaned.first;
    }

    // ---- 1. 新词条补译 ----
    if (r['verdict'] == 'untranslated' || !loc.containsKey(key)) {
      final zhCN = pick('zh-CN') ?? pick('zhAny');
      final zhTW = pick('zh-TW') ?? pick('zhAny');
      final en = (cand?['enFromTag'] as String?) ??
          ((cand?['en'] as List?)?.isNotEmpty == true
              ? '${(cand!['en'] as List).first}'
              : null);

      final filled = <String, String>{'ja': ja};
      if (zhCN != null) filled['zh-CN'] = zhCN;
      if (zhTW != null) filled['zh-TW'] = zhTW;
      if (en != null && en.isNotEmpty) filled['en'] = en;
      final missing = _langs.where((l) => !filled.containsKey(l)).toList();

      untranslated[key] = {
        ...filled,
        '_src': ja,
        '_evidence': _evidenceUrl(r),
        '_confidence': r['confidence'],
        if (missing.isNotEmpty) '_missing': missing,
      };
      if (missing.isNotEmpty) {
        needAi.add({
          'key': key,
          'ja': ja,
          'origin': entry['origin'],
          'workCount': entry['workCount'],
          'known': filled,
          'need': missing,
          'evidence': _evidenceOf(r),
        });
      }
      continue;
    }

    // ---- 2. 中文译名里夹罗马音（姓译了名没译）----
    //
    // 这一类**没有**看上去那么机械，必须逐条设防：
    //   - 括号里的拉丁字母是消歧标记不是没译的名字
    //     （`阿尔托莉雅·潘德拉贡(Lancer)`、`兔女郎 (Bunny)`），替换会把不同角色合并；
    //   - 同名词条（那 38 组）不能靠这条批量改，否则两个 メイ 会又被塞成同一个名字；
    //   - 候选必须**保留现有译名里的每一个汉字**，否则就不是「把罗马音补上」
    //     而是换成了另一个人（`白子＊Terror` -> `黑子`）。
    final existing = ((loc[key] as Map?)?.cast<String, dynamic>()) ?? const {};
    if (sharedJaNames.contains(ja)) continue;
    for (final lang in ['zh-CN', 'zh-TW']) {
      final cur = '${existing[lang] ?? ''}'.trim();
      if (cur.isEmpty || !_latin.hasMatch(cur)) continue;
      // 原名本身就带拉丁字母的不算（Arcaea、v flower）。
      if (_latin.hasMatch(ja)) continue;
      // 拉丁字母只出现在括号里 = 消歧标记，跳过。
      if (!_latin.hasMatch(cur.replaceAll(_paren, ''))) continue;
      final better = lang == 'zh-CN' ? (pick('zh-CN') ?? pick('zhAny')) : pick('zh-TW');
      if (better == null || _latin.hasMatch(better)) continue;
      // 候选必须保留现有译名里出现过的每一个汉字。
      final curHan = _han.allMatches(cur).map((m) => m.group(0)!).toSet();
      if (!curHan.every(better.contains)) continue;
      // 现有译名完全没有汉字时，上面那条规则是空判——此时只认「候选唯一」的情况，
      // 否则会从一堆别名里随手挑一个（`Vocaloid` -> `亜種`）。
      if (curHan.isEmpty) {
        final pool = <String>{
          ...?(cand?['zh-CN'] as List?)?.map((e) => '$e'),
          ...?(cand?['zhAny'] as List?)?.map((e) => '$e'),
        }.map((e) => e.replaceAll(_paren, '').trim()).where((e) => e.isNotEmpty && e != ja).toSet();
        if (pool.length != 1) continue;
      }
      (fixes[key] ??= <String, dynamic>{
        'n': <String, String>{},
        'prev': <String, String>{},
        'src': 'danbooru',
        'ref': <String>[...?_refOf(r)],
        'note': '中文译名里夹着罗马音（姓译了名没译）',
      });
      (fixes[key]['n'] as Map<String, String>)[lang] = better;
      (fixes[key]['prev'] as Map<String, String>)[lang] = cur;
    }
  }

  final outDir = Directory('tool/tag_verify/out')..createSync(recursive: true);
  const enc = JsonEncoder.withIndent('  ');

  File('${outDir.path}/proposal_untranslated.json')
      .writeAsStringSync(enc.convert({
    'schema': 1,
    'target': 'tool/data/oreno3d_tags/oreno3d_tags_localized.json',
    'total': untranslated.length,
    'entries': untranslated,
  }));

  File('${outDir.path}/proposal_fixes.json').writeAsStringSync(enc.convert({
    'schema': 1,
    'target': 'tool/data/oreno3d_tags/overrides.json',
    'total': fixes.length,
    'entries': fixes,
  }));

  // ---- 3. AI 批次任务 ----
  var batch = 0;
  for (var i = 0; i < needAi.length; i += _batchSize) {
    batch++;
    final slice = needAi.sublist(
        i, i + _batchSize > needAi.length ? needAi.length : i + _batchSize);
    File('${outDir.path}/batch_${batch.toString().padLeft(3, '0')}.in.json')
        .writeAsStringSync(enc.convert({
      'schema': 1,
      'batch': batch,
      'instructions': '为每个 key 补齐 need 里列出的语言。'
          '只输出 {"batch":N,"entries":{"<key>":{"<lang>":"<译名>"}}}，'
          'key 与条数必须与输入完全一致，不得增删。'
          'known 里已有的语言不要改。evidence.otherNames 是 Danbooru 上的既有别名，'
          '可作依据；没有把握时宁可保留日文原名也不要编。',
      'count': slice.length,
      'entries': slice,
    }));
  }

  stdout.writeln('补译提案      ${untranslated.length} 条 -> proposal_untranslated.json');
  stdout.writeln('  其中仍缺语言 ${needAi.length} 条 -> $batch 个 AI 批次文件');
  stdout.writeln('罗马音修正提案 ${fixes.length} 条 -> proposal_fixes.json');

  if (args.contains('--apply-untranslated')) {
    for (final e in untranslated.entries) {
      final v = Map<String, dynamic>.from(e.value as Map);
      v.removeWhere((k, _) => k.startsWith('_') && k != '_src');
      loc[e.key] = v;
    }
    File('tool/data/oreno3d_tags/oreno3d_tags_localized.json')
        .writeAsStringSync(enc.convert(loc));
    stdout.writeln('已写入 ${untranslated.length} 条补译到 oreno3d_tags_localized.json');
  }

  if (args.contains('--apply-fixes')) {
    const p = 'tool/data/oreno3d_tags/overrides.json';
    final ov = _json(p);
    final entries = (ov['entries'] as Map).cast<String, dynamic>();
    for (final e in fixes.entries) {
      final v = Map<String, dynamic>.from(e.value as Map)
        ..['at'] = '2026-08-25'
        ..['by'] = 'dev';
      entries[e.key] = v;
    }
    ov['entries'] = entries;
    File(p).writeAsStringSync(enc.convert(ov));
    stdout.writeln('已写入 ${fixes.length} 条修正到 overrides.json');
  }
}
