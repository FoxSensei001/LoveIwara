/// ② 确定性核实层：先查得到的就不问 AI。
///
/// 二次元角色 / 作品的译名是**可以查到事实**的，不该交给模型推理——
/// 尤其是刚实装的新角色，模型的训练数据往往还没有它们，一问就编。
///
/// 数据源：Danbooru wiki（免费、无需 key、社区维护的事实标准）。
/// 它的 `other_names` 同时收录日文原名、简体中文名、繁体中文名与英文别名，
/// 而且常带作品后缀（`オデット(原神)`、`ロッシ(エンドフィールド)`），
/// 顺带就能验证「这个角色属于哪部作品」——也就是我们要的「身份」信号。
///
/// 本脚本**只产出证据，不改任何词库**。它的输出是 AI 批次任务的输入：
/// 查得到的条目直接定死不必再问模型，查不到的才需要人 / AI 判断。
///
/// 用法（仓库根目录执行）：
///   dart run tool/tag_verify/lookup.dart --missing        # 只查还没有译名的词条
///   dart run tool/tag_verify/lookup.dart --keys characters/5182,origins/854
///   dart run tool/tag_verify/lookup.dart --missing --limit 5   # 先小批试跑
library;

import 'dart:convert';
import 'dart:io';

import '../tag_audit/cjk_variants.dart';

const _ua = 'LoveIwara-tag-verify/0.1 (+https://github.com/FoxSensei001/LoveIwara)';
const _endpoint = 'https://danbooru.donmai.us/wiki_pages.json';

/// 礼貌限速：Danbooru 允许更快，但没必要——这是低频离线任务。
const _delay = Duration(milliseconds: 300);

/// 查询缓存：全量跑 2580 条要十几分钟，中途挂掉不该从头再来。
/// 键是实际发出的查询词，值是 Danbooru 的首条结果（查不到则记 null）。
class _Cache {
  final File file;
  final Map<String, dynamic> data;
  var _dirty = 0;

  _Cache(this.file, this.data);

  factory _Cache.load(String path) {
    final f = File(path);
    if (!f.existsSync()) return _Cache(f, {});
    try {
      return _Cache(f, jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
    } catch (_) {
      return _Cache(f, {});
    }
  }

  bool has(String k) => data.containsKey(k);
  Map<String, dynamic>? get(String k) =>
      (data[k] as Map?)?.cast<String, dynamic>();

  void put(String k, Map<String, dynamic>? v) {
    data[k] = v;
    if (++_dirty >= 25) flush();
  }

  void flush() {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(data));
    _dirty = 0;
  }
}

final _kana = RegExp(r'[ぁ-ゟァ-ヺー-ヿ]');
final _han = RegExp(r'[一-鿿]');
final _hangul = RegExp(r'[가-힣]');
final _latin = RegExp(r'[A-Za-z]');
final _simplified = kSimplifiedOnly.split('').toSet();
final _traditional = kTraditionalOnly.split('').toSet();

/// 把 Danbooru 的 other_names 分到各语言桶里。
///
/// 判简繁用 tag_audit 那两张「独用字」表；两者都不含（全是共用字）时无法判定，
/// 归入 `zhAny`——这种名字简繁写法相同，两边都能用。
class NameBuckets {
  final List<String> ja = [];
  final List<String> zhCN = [];
  final List<String> zhTW = [];
  final List<String> zhAny = [];
  final List<String> en = [];
  final List<String> dropped = [];

  void add(String n) {
    if (_hangul.hasMatch(n)) {
      dropped.add(n); // 韩文用不上
      return;
    }
    if (_kana.hasMatch(n)) {
      ja.add(n);
      return;
    }
    if (_han.hasMatch(n)) {
      final chars = n.split('');
      final hasS = chars.any(_simplified.contains);
      final hasT = chars.any(_traditional.contains);
      if (hasS && !hasT) {
        zhCN.add(n);
      } else if (hasT && !hasS) {
        zhTW.add(n);
      } else {
        // 两张独用字表都不命中：这个名字简繁写法相同，两边都能用。
        zhAny.add(n);
      }
      return;
    }
    if (_latin.hasMatch(n)) {
      en.add(n);
      return;
    }
    dropped.add(n);
  }

  /// 从候选里挑一个最适合直接当译名用的：
  /// 优先简体桶，其次简繁通用桶；剥掉 `玛绮朵(少女前线2)` 这类作品后缀；取最短的一个。
  /// 只是建议值——最终采不采仍由人决定。
  String? get preferredZh {
    final pool = [...zhCN, ...zhAny];
    if (pool.isEmpty) return null;
    final cleaned = pool
        .map((e) => e.replaceAll(RegExp(r'[（(][^）)]*[）)]'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) return null;
    cleaned.sort((a, b) => a.runes.length.compareTo(b.runes.length));
    return cleaned.first;
  }

  Map<String, dynamic> toJson() => {
        if (ja.isNotEmpty) 'ja': ja,
        if (zhCN.isNotEmpty) 'zh-CN': zhCN,
        if (zhTW.isNotEmpty) 'zh-TW': zhTW,
        if (zhAny.isNotEmpty) 'zhAny': zhAny,
        if (en.isNotEmpty) 'en': en,
      };
}

/// 把 Danbooru 的 snake_case tag 还原成可读英文，并剥掉作品后缀。
///   velina_airgid            -> Velina Airgid
///   odette_(genshin_impact)  -> Odette
String prettifyTag(String tag) {
  final noParen = tag.replaceAll(RegExp(r'_?\([^)]*\)'), '');
  return noParen
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

/// 从 `オデット(原神)` 这类别名里抠出括号内的作品名，用于核对归属。
List<String> originHints(List<String> names, String title) {
  final hints = <String>{};
  for (final n in [...names, title]) {
    for (final m in RegExp(r'[（(]([^）)]+)[）)]').allMatches(n)) {
      hints.add(m.group(1)!.trim());
    }
  }
  return hints.toList();
}

/// 词库里有些名字自带括注（`ココナ(心夏)`、`レミエール・ダン(ラミル)`），
/// Danbooru 通常只收其中一种写法。全名查不到时，依次退回到
/// 「去掉括注的主名」与「括注里的别名」再试。
List<String> _queryVariants(String name) {
  final variants = <String>[name];
  final stripped = name.replaceAll(RegExp(r'[（(][^）)]*[）)]'), '').trim();
  if (stripped.isNotEmpty && stripped != name) variants.add(stripped);
  for (final m in RegExp(r'[（(]([^）)]+)[）)]').allMatches(name)) {
    final inner = m.group(1)!.trim();
    if (inner.isNotEmpty) variants.add(inner);
  }
  return variants;
}

Future<Map<String, dynamic>?> _queryCached(
    HttpClient client, _Cache cache, String name) async {
  if (cache.has(name)) return cache.get(name);
  final pages = await _query(client, name);
  final first = pages.isEmpty ? null : (pages.first as Map).cast<String, dynamic>();
  cache.put(name, first == null
      ? null
      : {'title': first['title'], 'other_names': first['other_names']});
  await Future<void>.delayed(_delay);
  return cache.get(name);
}

Future<List<dynamic>> _query(HttpClient client, String name) async {
  final uri = Uri.parse(_endpoint).replace(queryParameters: {
    'search[other_names_match]': name,
    'limit': '3',
  });
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.userAgentHeader, _ua);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) return jsonDecode(body) as List<dynamic>;
      if (res.statusCode == 429) {
        await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
        continue;
      }
      stderr.writeln('  ! $name -> HTTP ${res.statusCode}');
      return const [];
    } catch (e) {
      if (attempt == 2) {
        stderr.writeln('  ! $name -> $e');
        return const [];
      }
      await Future<void>.delayed(Duration(seconds: attempt + 1));
    }
  }
  return const [];
}

Future<void> main(List<String> args) async {
  final raw = jsonDecode(
    File('tool/data/oreno3d_tags/oreno3d_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final loc = jsonDecode(
    File('tool/data/oreno3d_tags/oreno3d_tags_localized.json')
        .readAsStringSync(),
  ) as Map<String, dynamic>;

  final byKey = <String, Map<String, dynamic>>{};
  for (final cat in ['origins', 'characters', 'tags']) {
    for (final e in (raw[cat] as List)) {
      byKey['$cat/${(e as Map)['id']}'] = e.cast<String, dynamic>();
    }
  }

  var keys = <String>[];
  final keysArg = _optionOf(args, '--keys');
  if (keysArg != null) {
    keys = keysArg.split(',').map((e) => e.trim()).where(byKey.containsKey).toList();
  } else if (args.contains('--missing')) {
    keys = byKey.keys.where((k) => !loc.containsKey(k)).toList();
  } else if (args.contains('--all')) {
    keys = byKey.keys.toList();
  } else {
    stderr.writeln('要么 --all / --missing，要么 --keys a,b,c');
    exitCode = 64;
    return;
  }
  keys.sort();

  final limit = int.tryParse(_optionOf(args, '--limit') ?? '');
  if (limit != null && limit < keys.length) keys = keys.sublist(0, limit);

  stdout.writeln('待核实 ${keys.length} 条');

  final cache = _Cache.load('tool/tag_verify/out/danbooru_cache.json');
  final client = HttpClient();
  final results = <Map<String, dynamic>>[];
  var hit = 0;
  var originConfirmed = 0;
  final verdicts = <String, int>{};
  final quiet = args.contains('--quiet');

  for (var i = 0; i < keys.length; i++) {
    final key = keys[i];
    final entry = byKey[key]!;
    final name = entry['name'] as String;
    final origin = entry['origin'] as String?;

    Map<String, dynamic>? page;
    var matchedVia = name;
    for (final v in _queryVariants(name)) {
      page = await _queryCached(client, cache, v);
      if (page != null) {
        matchedVia = v;
        break;
      }
    }

    if (page == null) {
      results.add({
        'key': key,
        'ja': name,
        'origin': origin,
        'found': false,
        'verdict': 'no_evidence',
        'confidence': 'none',
      });
      verdicts['no_evidence'] = (verdicts['no_evidence'] ?? 0) + 1;
      if (!quiet) {
        stdout.writeln('  ${(i + 1).toString().padLeft(4)}/${keys.length} '
            '${key.padRight(18)} $name  -> 查不到，需 AI 判断');
      }
      continue;
    }

    final title = '${page['title']}';
    final others = ((page['other_names'] as List?) ?? const [])
        .map((e) => '$e')
        .toList();

    final buckets = NameBuckets();
    for (final n in others) {
      buckets.add(n);
    }

    final hints = originHints(others, title);
    // 归属核对：Danbooru 的作品后缀（原神 / エンドフィールド…）与词库里的 origin
    // 只要有一方包含另一方就算对得上——两边用词粒度不同，不做严格相等。
    final okOrigin = origin != null &&
        hints.any((h) =>
            origin.contains(h) ||
            h.contains(origin) ||
            _loose(origin).contains(_loose(h)) ||
            _loose(h).contains(_loose(origin)));

    // 只有日文原名精确出现在 other_names 里，才认为查的是同一个对象。

    hit++;
    if (okOrigin) originConfirmed++;

    final exact = others.contains(matchedVia);
    // 靠退回变体（去括注 / 括注内别名）命中的，证据比全名命中弱：
    // 「ココナ(心夏)」用「心夏」去查，可能撞上另一个同字角色。
    // 除非归属也对得上，否则一律压到 low，交给人 / AI 判断。
    final viaFallback = matchedVia != name;
    final confidence = !exact
        ? 'low'
        : (okOrigin || origin == null)
            ? (viaFallback && !okOrigin ? 'low' : 'high')
            : (viaFallback ? 'low' : 'medium');

    // 与词库里现有译名比对——这才是「AI 当年认错了多少人」的信号来源。
    final existingZh =
        ((loc[key] as Map?)?['zh-CN'] as String?)?.trim() ?? '';
    final zhPool = <String>{...buckets.zhCN, ...buckets.zhAny};
    final zhPoolClean = zhPool
        .map((e) => e.replaceAll(RegExp(r'[（(][^）)]*[）)]'), '').trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    String verdict;
    if (existingZh.isEmpty) {
      verdict = 'untranslated';
    } else if (confidence != 'high') {
      // 证据不够硬就不下判断。典型反例：斯普拉遁的 ホタル 查 Danbooru 会命中
      // 星铁那个 ホタル 的页面（归属对不上 → medium），此时说「译名一致」是假的一致。
      verdict = 'weak_evidence';
    } else if (zhPoolClean.isEmpty) {
      verdict = 'no_zh_evidence';
    } else if (zhPoolClean.contains(existingZh) || zhPool.contains(existingZh)) {
      verdict = 'agree';
    } else if (zhPoolClean.any((c) => existingZh.contains(c) || c.contains(existingZh))) {
      // 「玛绮朵」vs「玛绮朵(少女前线2)」这类包含关系算一致。
      verdict = 'agree_loose';
    } else {
      verdict = 'disagree';
    }
    verdicts[verdict] = (verdicts[verdict] ?? 0) + 1;

    results.add({
      'key': key,
      'ja': name,
      'origin': origin,
      'found': true,
      'existingZh': existingZh,
      'verdict': verdict,
      'confidence': confidence,
      'exactJaMatch': exact,
      'danbooru': {
        'title': title,
        'url': 'https://danbooru.donmai.us/wiki_pages/$title',
        'otherNames': others,
        'originHints': hints,
        'originMatched': okOrigin,
        if (matchedVia != name) 'matchedVia': matchedVia,
      },
      'candidates': {
        ...buckets.toJson(),
        'enFromTag': prettifyTag(title),
        'preferredZh': buckets.preferredZh,
      },
    });

    final zh = buckets.zhCN.isNotEmpty
        ? buckets.zhCN.first
        : (buckets.zhAny.isNotEmpty ? buckets.zhAny.first : '—');
    if (!quiet) {
      stdout.writeln('  ${(i + 1).toString().padLeft(4)}/${keys.length} '
          '${key.padRight(18)} ${name.padRight(22)} -> $zh  '
          '[$confidence${okOrigin ? ', 归属已核' : ''}]');
    } else if ((i + 1) % 200 == 0) {
      stdout.writeln('  进度 ${i + 1}/${keys.length}  '
          '（命中 $hit，分歧 ${verdicts['disagree'] ?? 0}）');
    }
  }
  client.close();
  cache.flush();

  final outDir = Directory('tool/tag_verify/out')..createSync(recursive: true);
  final f = File('${outDir.path}/evidence.json');
  f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'schema': 1,
    'source': 'danbooru wiki_pages.other_names',
    'total': results.length,
    'hit': hit,
    'originConfirmed': originConfirmed,
    'verdicts': verdicts,
    'results': results,
  }));

  stdout.writeln('\n查得到 $hit/${keys.length}，其中归属也对得上 $originConfirmed 条');
  if (verdicts.isNotEmpty) {
    stdout.writeln('与现有译名比对：');
    for (final e in verdicts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))) {
      stdout.writeln('  ${e.key.padRight(16)} ${e.value}');
    }
  }
  stdout.writeln('剩下 ${keys.length - hit} 条需要 AI 判断');
  stdout.writeln('证据 -> ${f.path}');
}

/// 归一化作品名后再比对：去掉空白与常见分隔符，避免
/// 「アークナイツ：エンドフィールド」与「エンドフィールド」因标点对不上。
String _loose(String s) =>
    s.replaceAll(RegExp(r'[\s・:：\-—()（）!！?？,，.。]'), '').toLowerCase();

String? _optionOf(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}
