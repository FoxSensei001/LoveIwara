/// 把**所有需要判断的条目**打成 AI 批次任务，交给 agent（Antigravity / Claude Code / Codex）跑。
///
/// 两类任务：
///   - `translate`：词条缺某些语言的译名（多为重抓带回的新词条）
///   - `adjudicate`：现有译名与 Danbooru 证据不一致，需要裁决保留还是替换
///
/// 契约（与 tool/tag_verify/README.md 一致，收回时由 ingest.dart 强制校验）：
///   - 每批默认 120 条，agent 读 `batch_XXX.in.json`，
///     **拷贝 `batch_XXX.tpl.json` 为 `batch_XXX.out.json` 后就地填值**
///     （模板里 key 与条数已经排好，agent 不再有机会重排 key —— 实测它会整块丢掉
///     输入中间的一段再拿别处的 key 凑数，提示词拦不住，把动作删掉才拦得住）
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

/// 假名（不含 `・`，它是分隔符，「催眠・洗脑」这类是合格中文）。
final _kana = RegExp(r'[぀-ゟ゠-ヺー-ヿ]');

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

  // overrides 记「改过的」，reviewed 记「看过并判定保留的」——两者都不该再入队。
  final decidedOreno = {
    ...decided('tool/data/oreno3d_tags/overrides.json'),
    ...decided('tool/data/oreno3d_tags/reviewed.json'),
  };
  final decidedIwara = {
    ...decided('tool/data/iwara_tags/overrides.json'),
    ...decided('tool/data/iwara_tags/reviewed.json'),
  };

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

    // 「已有译名，但中文位上写的还是日文」——多为上一轮按「没把握就保留原文」
    // 留下的片假名人名。用户口径是这类也要音译成纯中文，否则界面照旧显示日文，
    // 正是最初报障的那个现象。这类条目 missing 为空，走不到上面的补译分支，
    // 必须单独收进队列。
    final kanaLangs = _langs
        .where((l) => l.startsWith('zh') && _kana.hasMatch('${cur[l] ?? ''}'))
        .toList();
    if (kanaLangs.isNotEmpty && !decidedOreno.contains(key)) {
      tasks.add({
        'dataset': 'oreno3d',
        'key': key,
        'type': 'translate',
        'source': source,
        'origin': entry['origin'],
        'workCount': entry['workCount'],
        'need': kanaLangs,
        'known': {
          for (final l in _langs)
            if (!kanaLangs.contains(l) && '${cur[l] ?? ''}'.trim().isNotEmpty)
              l: '${cur[l]}',
        },
        'note': '当前中文位仍是日文原文，请音译成纯中文（不要回填罗马音）',
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
  //
  // ⚠️ 这里**遍历原始标签表**，而不是遍历证据结果。
  // 老实现只走 `iEv['results']` 且只处理 `disagree`，有两个后果：
  //   1. 未补译的新标签压根不进队列——重抓带回 273 条时一条都排不出来；
  //   2. 「拉不到 Danbooru 证据」会变成排队的阻塞条件，而证据只是线索，
  //      不该决定一个词条要不要被翻译（agent 自己也能联网核实）。
  // 现在证据是可选附加项：有就带上，没有就留空。
  final iLoc = _json('tool/data/iwara_tags/iwara_tags_localized.json');
  final iEv = _json('tool/tag_verify/out/evidence_iwara.json');
  final iEvByKey = <String, Map<String, dynamic>>{
    for (final r in (iEv['results'] as List).cast<Map<String, dynamic>>())
      '${r['key']}': r,
  };
  final iRaw = _json('tool/data/iwara_tags/iwara_tags.json');

  for (final e in (iRaw['tags'] as List).cast<Map<String, dynamic>>()) {
    final key = '${e['id']}';
    final source = key.replaceAll('_', ' ');
    final cur = (iLoc[key] as Map?)?.cast<String, dynamic>();
    final r = iEvByKey[key];
    final ev = r == null ? null : _evidence(r);
    final warn = _categoryWarning('iwara', ev);

    Map<String, dynamic> mk(String type) {
      final t = <String, dynamic>{
        'dataset': 'iwara',
        'key': key,
        'type': type,
        'source': source,
        'tagType': e['type'],
        'evidence': ?ev,
      };
      if (warn != null) t['warning'] = warn;
      return t;
    }

    if (cur == null) {
      tasks.add(mk('translate')
        ..['need'] = _langs.toList()
        ..['known'] = const <String, String>{});
      continue;
    }

    final missing =
        _langs.where((l) => '${cur[l] ?? ''}'.trim().isEmpty).toList();
    if (missing.isNotEmpty) {
      tasks.add(mk('translate')
        ..['need'] = missing
        ..['known'] = {
          for (final l in _langs)
            if ('${cur[l] ?? ''}'.trim().isNotEmpty) l: '${cur[l]}',
        });
    }

    // 与 oreno3d 侧同一条：中文位上写的还是日文，等于没译。
    final kanaLangs = _langs
        .where((l) => l.startsWith('zh') && _kana.hasMatch('${cur[l] ?? ''}'))
        .toList();
    if (kanaLangs.isNotEmpty && !decidedIwara.contains(key)) {
      tasks.add(mk('translate')
        ..['need'] = kanaLangs
        ..['known'] = {
          for (final l in _langs)
            if (!kanaLangs.contains(l) && '${cur[l] ?? ''}'.trim().isNotEmpty)
              l: '${cur[l]}',
        }
        ..['note'] = '当前中文位仍是日文原文，请音译成纯中文（不要回填罗马音）');
    }

    if (r != null && r['verdict'] == 'disagree' && !decidedIwara.contains(key)) {
      final pool = _cleanPool(
          (r['candidates'] as Map?)?.cast<String, dynamic>(), source);
      if (pool.isEmpty) continue;
      tasks.add(mk('adjudicate')
        ..['current'] = {
          for (final l in _langs)
            if ('${cur[l] ?? ''}'.trim().isNotEmpty) l: '${cur[l]}',
        }
        ..['candidates'] = pool);
    }
  }

  // 热门的先做：错在热门词条上影响面更大。
  tasks.sort((a, b) =>
      ((b['workCount'] as int?) ?? 0).compareTo((a['workCount'] as int?) ?? 0));

  final outDir = Directory('tool/tag_verify/out/batches')
    ..createSync(recursive: true);
  for (final f in outDir.listSync()) {
    if (f.path.endsWith('.in.json') || f.path.endsWith('.tpl.json')) {
      f.deleteSync();
    }
  }

  const enc = JsonEncoder.withIndent('  ');
  var n = 0;
  for (var i = 0; i < tasks.length; i += size) {
    n++;
    final slice =
        tasks.sublist(i, i + size > tasks.length ? tasks.length : i + size);
    // 批次文件名跨代复用，所以给每份输入按 key 集合算一个指纹，
    // 要求输出原样回带。否则上一代的 .out.json 会被拿来比这一代的 .in.json，
    // 报出「漏了 120 条 / 凭空多出 120 条」这种把人引向错误方向的信息。
    final fingerprint = _fingerprint(slice.map((e) => '${e['key']}').toList());
    final stem = 'batch_${n.toString().padLeft(3, '0')}';
    File('${outDir.path}/$stem.in.json').writeAsStringSync(enc.convert({
      'schema': 1,
      'batch': n,
      'inputFingerprint': fingerprint,
      'count': slice.length,
      'contract': _contract,
      'entries': slice,
    }));

    // 同时出一份「填空模板」：key 已按输入顺序排好、条数已对，agent 只需就地填值。
    //
    // 这不是锦上添花。实测 agent 会整块丢掉输入中间的一段（如第 60-78 位），
    // 再从别的批次和凭空编造的 key 里补齐条数——**条数对得上，key 全错**。
    // 提示词里写「不得增删 key」拦不住这个：它不是不知道规则，是自己重排了一遍 key。
    // 模板把「重排 key」这个动作从流程里删掉，这一类错误就无从发生。
    File('${outDir.path}/$stem.tpl.json').writeAsStringSync(enc.convert({
      'batch': n,
      'inputFingerprint': fingerprint,
      'entries': [
        for (final t in slice)
          {
            'key': t['key'],
            if (t['type'] == 'adjudicate') 'decision': '',
            'names': {for (final l in (t['need'] as List? ?? const [])) l: ''},
            'reason': '',
          },
      ],
    }));
  }

  final byType = <String, int>{};
  for (final t in tasks) {
    byType['${t['type']}'] = (byType['${t['type']}'] ?? 0) + 1;
  }
  stdout.writeln('共 ${tasks.length} 条待判断 -> $n 个批次（每批 $size）');
  byType.forEach((k, v) => stdout.writeln('  $k  $v'));
  stdout.writeln('输出目录 ${outDir.path}');
  stdout.writeln('\n每批先 cp batch_XXX.tpl.json batch_XXX.out.json 再就地填值，然后：');
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

/// 按 key 集合算的稳定指纹（与顺序无关）。
String _fingerprint(List<String> keys) {
  final sorted = [...keys]..sort();
  var hash = 0xcbf29ce484222325;
  for (final b in utf8.encode(sorted.join('\n'))) {
    hash ^= b;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return BigInt.from(hash).toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

const _contract = {
  'output': '写成同名 .out.json，结构 '
      '{"batch":N,"inputFingerprint":"<原样抄输入里的那串>",'
      '"entries":[{"key":...,"decision":...,"names":{...},'
      '"reason":...,"ref":[...]}]}',
  'rules': [
    'key 与条数必须与输入完全一致，不得增删、不得改写 key',
    'inputFingerprint 必须从输入里原样抄到输出——它用来确认你处理的是这一代的输入',
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
    '绝不要把罗马音塞回中文译名（「天海琉夏」->「雨海Ruka」这种方向是错的）。'
    '没有公认中文名的小众角色（多为个人势 VTuber）也要按通行读法音译成纯中文，'
    '不要写成「杏户yuge」：词库同类词条压倒性是纯中文'
    '（改造前 129 条含假名的 Vtuber 词条里只有 10 条含拉丁，'
    '其中数条本就是拉丁艺名，还有一条正是上面那个反面例子）。',
  ],
};

String? _opt(List<String> a, String f) {
  final i = a.indexOf(f);
  return (i < 0 || i + 1 >= a.length) ? null : a[i + 1];
}
