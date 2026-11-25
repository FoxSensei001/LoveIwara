/// ② 确定性核实层（iwara 侧）的第二个证据源：EhTagTranslation 社区词库。
///
/// E 站中文社区维护的标签译名库（4.5 万条，每次提交自动发版），命名空间里的
/// `character` / `parody` 与 iwara 的角色 / 作品标签高度重合。
/// iwara 写 `tanga_ibuki`、E 站写 `ibuki tanga`，所以按**拆词后的集合**匹配。
///
/// 只产出证据，不改任何词库——与 Danbooru 那份证据并列，
/// 由 make_batches 附进每条任务，供 agent 参考。
///
/// 它能给的证据：
///   - `zh`：简体中文名（`|` 分隔的多个写法拆开）
///   - `ja`：介绍里写明的日文原名（`日语：…` / `原名：…`）
///   - `origins`：介绍里引用的作品（`p:xxx`）与「所属作品」那一行
///
/// ⚠️ 已知的误导方向（会写进每条任务的 warning，不靠提示词叮嘱）：
///   - 命名空间撞车：`almond_eye` 在 E 站是马娘角色，不是「杏眼」
///   - `male` / `female` 是性癖词，用的是本子圈说法（`anal → 爆肛`），
///     不一定适合 iwara 这边的措辞
///
/// 协议：数据库内容是 CC BY-NC-SA 3.0。这里只作核对证据，不把它的文本原样打包进 App。
///
/// 用法：
///   dart run tool/tag_verify/lookup_ehtt.dart              # 用缓存的数据库（没有就下载）
///   dart run tool/tag_verify/lookup_ehtt.dart --refresh    # 强制下载最新发版
library;

import 'dart:convert';
import 'dart:io';

const _dbUrl =
    'https://github.com/EhTagTranslation/Database/releases/latest/download/db.text.json.gz';
const _dbCache = 'tool/tag_verify/out/ehtt_db.text.json.gz';
const _outPath = 'tool/tag_verify/out/evidence_ehtt_iwara.json';

/// 这些命名空间与 iwara 标签基本无交集，纳入只会增加误配。
const _skipNamespaces = {
  'rows',
  'reclass',
  'language',
  'artist',
  'group',
  'cosplayer',
};

final _ascii = RegExp(r'^[\x00-\x7f]*$');
final _han = RegExp(r'[一-鿿]');
final _kana = RegExp(r'[぀-ゟ゠-ヿ]');
final _image = RegExp(r'!\[[^\]]*\]\([^)]*\)');
final _jaLine = RegExp(r'(?:日语|日文名|日文|日本語|原名)\s*[：:]\s*([^\n]+)');
final _originRef = RegExp(r'`(?:p|parody):([^`]+)`');
final _originLine = RegExp(r'(?:所属作品|出自作品)\s*[：:]?\s*([^\n]+)');

String normalize(String s) {
  final parts = s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((t) => t.isNotEmpty)
      .toList()
    ..sort();
  return parts.join(' ');
}

/// 去掉间隔号与空白再比，`爱丽丝·盖恩斯巴勒` 与 `爱丽丝盖恩斯巴勒` 算同一个。
String _cmp(String s) => s.replaceAll(RegExp(r'[·・\s]'), '');

List<String> _splitNames(String s) => s
    .split(RegExp(r'\s*[|｜/／、，,]\s*'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

/// `日语：` 那一行常常连着别的说明（`アルベド 英语：albedo）所属作品:…`），
/// 只取到第一个括号 / 下一个字段名之前。
String _jaHead(String line) =>
    line.split(RegExp(r'[（()）]|英语|英文|所属|出自|读音|假名'))[0].trim();

Future<Map<String, dynamic>> _loadDb(bool refresh) async {
  final f = File(_dbCache);
  if (refresh || !f.existsSync()) {
    stdout.writeln('下载 $_dbUrl');
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(_dbUrl));
      final res = await req.close();
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(_dbUrl));
      }
      final bytes = await res.fold<List<int>>([], (a, b) => a..addAll(b));
      f.parent.createSync(recursive: true);
      f.writeAsBytesSync(bytes);
    } finally {
      client.close();
    }
  }
  return jsonDecode(utf8.decode(gzip.decode(f.readAsBytesSync())))
      as Map<String, dynamic>;
}

Map<String, dynamic> _entry(String ns, String key, Map v) {
  final intro = '${v['intro'] ?? ''}'.replaceAll(_image, '').trim();
  final ja = <String>{
    for (final m in _jaLine.allMatches(intro))
      for (final n in _splitNames(_jaHead(m.group(1)!)))
        if (_kana.hasMatch(n) || _han.hasMatch(n)) n,
  };
  final origins = <String>{
    for (final m in _originRef.allMatches(intro)) m.group(1)!.trim(),
    for (final m in _originLine.allMatches(intro))
      m.group(1)!.replaceAll(_originRef, '').trim(),
  }..removeWhere((e) => e.isEmpty);
  return {
    'namespace': ns,
    'ehKey': key,
    'zh': _splitNames('${v['name']}'),
    if (ja.isNotEmpty) 'ja': ja.toList(),
    if (origins.isNotEmpty) 'origins': origins.take(4).toList(),
    if (intro.isNotEmpty)
      'intro': intro.length > 160 ? '${intro.substring(0, 160)}…' : intro,
  };
}

Future<void> main(List<String> args) async {
  final db = await _loadDb(args.contains('--refresh'));
  final head = (db['head'] as Map).cast<String, dynamic>();

  final index = <String, List<Map<String, dynamic>>>{};
  var total = 0;
  for (final ns in (db['data'] as List).cast<Map<String, dynamic>>()) {
    final name = '${ns['namespace']}';
    if (_skipNamespaces.contains(name)) continue;
    (ns['data'] as Map).forEach((k, v) {
      total++;
      index.putIfAbsent(normalize('$k'), () => []).add(_entry(name, '$k', v as Map));
    });
  }

  final raw = jsonDecode(
          File('tool/data/iwara_tags/iwara_tags.json').readAsStringSync())
      as Map<String, dynamic>;
  final loc = jsonDecode(File('tool/data/iwara_tags/iwara_tags_localized.json')
      .readAsStringSync()) as Map<String, dynamic>;

  final verdicts = <String, int>{};
  final results = <Map<String, dynamic>>[];
  for (final t in (raw['tags'] as List).cast<Map<String, dynamic>>()) {
    final key = '${t['id']}';
    final matches = index[normalize(key)];
    final ours = '${(loc[key] as Map?)?['zh-CN'] ?? ''}'.trim();
    String verdict;
    if (matches == null) {
      verdict = 'no_match';
    } else {
      final zh = matches.expand((m) => m['zh'] as List<String>).toList();
      if (ours.isEmpty) {
        verdict = 'ours_missing';
      } else if (zh.any((z) => _cmp(z) == _cmp(ours))) {
        verdict = 'agree';
      } else if (_ascii.hasMatch(ours) && zh.any(_han.hasMatch)) {
        // 我们中文位还是英文，它有中文——最值得先看的一类。
        verdict = 'ours_untranslated';
      } else {
        verdict = 'disagree';
      }
    }
    verdicts[verdict] = (verdicts[verdict] ?? 0) + 1;
    if (matches != null) {
      results.add({'key': key, 'verdict': verdict, 'matches': matches});
    }
  }

  File(_outPath)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
      'schema': 1,
      'source': 'EhTagTranslation/Database release db.text.json',
      'license': 'CC BY-NC-SA 3.0（只作核对证据，不原样分发）',
      'dbSha': head['sha'],
      'dbCommittedAt': (head['committer'] as Map?)?['when'],
      'dbEntriesUsed': total,
      'iwaraTotal': (raw['tags'] as List).length,
      'verdicts': verdicts,
      'results': results,
    }));

  stdout.writeln('EhTT ${head['sha']}（${(head['committer'] as Map?)?['when']}），'
      '参与匹配 $total 条');
  stdout.writeln('iwara ${(raw['tags'] as List).length} 条：');
  verdicts.forEach((k, v) => stdout.writeln('  $k  $v'));
  stdout.writeln('输出 $_outPath');
}
