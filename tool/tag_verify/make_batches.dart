/// 把**所有需要判断的条目**打成 AI 批次任务，交给 agent（Antigravity / Claude Code / Codex）跑。
///
/// 两类任务：
///   - `translate`：词条缺某些语言的译名（多为重抓带回的新词条）
///   - `adjudicate`：现有译名与 Danbooru 证据不一致，需要裁决保留还是替换
///
/// 契约（与 tool/tag_verify/README.md 一致，收回时由 ingest.dart 强制校验）：
///   - 每批默认 120 条，agent 读 `batch_XXX.in.json` 写 `batch_XXX.out.json`
///   - **agent 永远不碰主词库**，合并只由 ingest.dart 做
///   - key 与条数必须与输入完全一致，不得增删
///   - 没有把握就 keep / 保留原文，不要编
///
/// 用法：
///   dart run tool/tag_verify/make_batches.dart              # 生成全部批次
///   dart run tool/tag_verify/make_batches.dart --size 80
library;

import 'dart:convert';
import 'dart:io';

const _defaultSize = 120;
const _langs = ['zh-CN', 'zh-TW', 'ja', 'en'];
final _paren = RegExp(r'[（(][^）)]*[）)]');

Map<String, dynamic> _json(String p) =>
    jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;

List<String> _cleanPool(Map<String, dynamic>? cand, String source) {
  final list = <String>{
    ...?(cand?['zh-CN'] as List?)?.map((e) => '$e'),
    ...?(cand?['zhAny'] as List?)?.map((e) => '$e'),
  };
  return list
      .map((e) => e.replaceAll(_paren, '').trim())
      .where((e) => e.isNotEmpty && e != source)
      .toList()
    ..sort();
}

void main(List<String> args) {
  final size = int.tryParse(_opt(args, '--size') ?? '') ?? _defaultSize;
  final tasks = <Map<String, dynamic>>[];

  // 已经在 overrides.json 里有决定的条目不再入队——否则每次重新出批，
  // 上一轮判过的又会回到队列里被重复裁决。
  Set<String> decided(String path) {
    final f = File(path);
    if (!f.existsSync()) return {};
    final doc = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return ((doc['entries'] as Map?) ?? const {}).keys.map((e) => '$e').toSet();
  }

  final decidedOreno = decided('tool/data/oreno3d_tags/overrides.json');
  final decidedIwara = decided('tool/data/iwara_tags/overrides.json');

  // ---------------- oreno3d ----------------
  final oRaw = _json('tool/data/oreno3d_tags/oreno3d_tags.json');
  final oLoc = _json('tool/data/oreno3d_tags/oreno3d_tags_localized.json');
  final oEv = _json('tool/tag_verify/out/evidence.json');
  final oByKey = <String, Map<String, dynamic>>{
    for (final cat in ['origins', 'characters', 'tags'])
      for (final e in (oRaw[cat] as List))
        '$cat/${(e as Map)['id']}': e.cast<String, dynamic>(),
  };

  for (final r in (oEv['results'] as List).cast<Map<String, dynamic>>()) {
    final key = r['key'] as String;
    final entry = oByKey[key];
    if (entry == null) continue;
    final source = entry['name'] as String;
    final cur = (oLoc[key] as Map?)?.cast<String, dynamic>();
    final evidence = _evidence(r);

    if (cur == null) {
      tasks.add({
        'dataset': 'oreno3d',
        'key': key,
        'type': 'translate',
        'source': source,
        'origin': entry['origin'],
        'workCount': entry['workCount'],
        'need': _langs.where((l) => l != 'ja').toList(),
        'known': {'ja': source},
        'evidence': evidence,
      });
      continue;
    }

    final missing =
        _langs.where((l) => '${cur[l] ?? ''}'.trim().isEmpty).toList();
    if (missing.isNotEmpty) {
      tasks.add({
        'dataset': 'oreno3d',
        'key': key,
        'type': 'translate',
        'source': source,
        'origin': entry['origin'],
        'workCount': entry['workCount'],
        'need': missing,
        'known': {
          for (final l in _langs)
            if ('${cur[l] ?? ''}'.trim().isNotEmpty) l: '${cur[l]}',
        },
        'evidence': evidence,
      });
    }

    if (r['verdict'] == 'disagree' && !decidedOreno.contains(key)) {
      final pool = _cleanPool(
          (r['candidates'] as Map?)?.cast<String, dynamic>(), source);
      if (pool.isEmpty) continue;
      tasks.add({
        'dataset': 'oreno3d',
        'key': key,
        'type': 'adjudicate',
        'source': source,
        'origin': entry['origin'],
        'workCount': entry['workCount'],
        'current': {
          for (final l in _langs)
            if ('${cur[l] ?? ''}'.trim().isNotEmpty) l: '${cur[l]}',
        },
        'candidates': pool,
        'evidence': evidence,
      });
    }
  }

  // ---------------- iwara ----------------
  final iLoc = _json('tool/data/iwara_tags/iwara_tags_localized.json');
  final iEv = _json('tool/tag_verify/out/evidence_iwara.json');
  for (final r in (iEv['results'] as List).cast<Map<String, dynamic>>()) {
    if (r['verdict'] != 'disagree') continue;
    final key = r['key'] as String;
    if (decidedIwara.contains(key)) continue;
    final source = key.replaceAll('_', ' ');
    final cur = (iLoc[key] as Map?)?.cast<String, dynamic>() ?? const {};
    final pool = _cleanPool(
        (r['candidates'] as Map?)?.cast<String, dynamic>(), source);
    if (pool.isEmpty) continue;
    final ev = _evidence(r);
    final warn = _categoryWarning('iwara', ev);
    final task = <String, dynamic>{
      'dataset': 'iwara',
      'key': key,
      'type': 'adjudicate',
      'source': source,
      'current': {
        for (final l in _langs)
          if ('${cur[l] ?? ''}'.trim().isNotEmpty) l: '${cur[l]}',
      },
      'candidates': pool,
      'evidence': ev,
    };
    if (warn != null) task['warning'] = warn;
    tasks.add(task);
  }

  // 热门的先做：错在热门词条上影响面更大。
  tasks.sort((a, b) =>
      ((b['workCount'] as int?) ?? 0).compareTo((a['workCount'] as int?) ?? 0));

  final outDir = Directory('tool/tag_verify/out/batches')
    ..createSync(recursive: true);
  for (final f in outDir.listSync()) {
    if (f.path.endsWith('.in.json')) f.deleteSync();
  }

  const enc = JsonEncoder.withIndent('  ');
  var n = 0;
  for (var i = 0; i < tasks.length; i += size) {
    n++;
    final slice =
        tasks.sublist(i, i + size > tasks.length ? tasks.length : i + size);
    File('${outDir.path}/batch_${n.toString().padLeft(3, '0')}.in.json')
        .writeAsStringSync(enc.convert({
      'schema': 1,
      'batch': n,
      'count': slice.length,
      'contract': _contract,
      'entries': slice,
    }));
  }

  final byType = <String, int>{};
  for (final t in tasks) {
    byType['${t['type']}'] = (byType['${t['type']}'] ?? 0) + 1;
  }
  stdout.writeln('共 ${tasks.length} 条待判断 -> $n 个批次（每批 $size）');
  byType.forEach((k, v) => stdout.writeln('  $k  $v'));
  stdout.writeln('输出目录 ${outDir.path}');
  stdout.writeln('\n跑完把结果写成同名的 .out.json，然后：');
  stdout.writeln('  dart run tool/tag_verify/ingest.dart');
}

Map<String, dynamic>? _evidence(Map<String, dynamic> r) {
  final d = (r['danbooru'] as Map?)?.cast<String, dynamic>();
  if (d == null) return null;
  return {
    'url': d['url'],
    'otherNames': d['otherNames'],
    if (d['category'] != null) 'danbooruCategory': d['category'],
  };
}

/// iwara 是 MMD / 3D **角色**视频站。当 Danbooru 上同名 tag 是 `general` 分类时，
/// 它讲的是普通名词，而 iwara 上这个标签十有八九指的是同名角色：
///   firefly -> 流萤（星铁），Danbooru 上是「萤火虫」
///   fern    -> 菲伦（葬送的芙莉莲），Danbooru 上是「蕨类植物」
///   dawn    -> 小光（宝可梦），Danbooru 上是「黎明」
/// 这类候选**不能**拿去覆盖角色译名。这不是靠提示词叮嘱能保证的事，
/// 所以把分类和这段警告一起塞进每条任务里。
String? _categoryWarning(String dataset, Map<String, dynamic>? evidence) {
  if (dataset != 'iwara') return null;
  if (evidence?['danbooruCategory'] != 'general') return null;
  return 'Danbooru 上这个 tag 是 general（普通名词）分类，candidates 描述的是那个普通名词。'
      'iwara 是角色向站点，本标签很可能指的是**同名角色**而非普通名词——'
      '若现有译名是角色/作品名而候选是通用词，应当 keep，不要替换。';
}

const _contract = {
  'output': '写成同名 .out.json，结构 '
      '{"batch":N,"entries":[{"key":...,"decision":...,"names":{...},'
      '"reason":...,"ref":[...]}]}',
  'rules': [
    'key 与条数必须与输入完全一致，不得增删、不得改写 key',
    'type=translate：为 need 里的每个语言给出译名，写进 names；known 里的不要改',
    'type=adjudicate：decision 取 keep（保留 current）或 replace（用 names 覆盖）；'
        'replace 时 names 必须给出要改的语言',
    '没有把握一律 keep / 保留原文，不要编。宁可留日文也不要给一个错的中文名',
    'candidates 来自 Danbooru 的既有别名，是线索不是答案——'
        '它可能是日文写法、旧译名，甚至是别的角色',
    '每条都要给 reason（一句话），replace 必须给 ref（可访问的来源 URL）',
    '同名不同人的词条（不同 origin 的同一个日文名）必须给出不同译名，不要合并',
    '条目带 warning 字段时**必须先读它再做判断**——它说明这条证据有已知的误导方向',
    'evidence.danbooruCategory 说明 Danbooru 那条 tag 讲的是什么：'
        'character=角色、copyright=作品、general=普通名词。'
        'iwara 是角色向站点，general 分类的候选常常与本标签的实际所指无关',
    '绝不要把罗马音塞回中文译名（「天海琉夏」->「雨海Ruka」这种方向是错的）',
  ],
};

String? _opt(List<String> a, String f) {
  final i = a.indexOf(f);
  return (i < 0 || i + 1 >= a.length) ? null : a[i + 1];
}
