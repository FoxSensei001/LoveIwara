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
const _delay = Duration(milliseconds: 350);

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
  } else {
    stderr.writeln('要么 --missing，要么 --keys a,b,c');
    exitCode = 64;
    return;
  }
  keys.sort();

  final limit = int.tryParse(_optionOf(args, '--limit') ?? '');
  if (limit != null && limit < keys.length) keys = keys.sublist(0, limit);

  stdout.writeln('待核实 ${keys.length} 条');

  final client = HttpClient();
  final results = <Map<String, dynamic>>[];
  var hit = 0;
  var originConfirmed = 0;

  for (var i = 0; i < keys.length; i++) {
    final key = keys[i];
    final entry = byKey[key]!;
    final name = entry['name'] as String;
    final origin = entry['origin'] as String?;

    List<dynamic> pages = const [];
    var matchedVia = name;
    for (final v in _queryVariants(name)) {
      pages = await _query(client, v);
      await Future<void>.delayed(_delay);
      if (pages.isNotEmpty) {
        matchedVia = v;
        break;
      }
    }

    if (pages.isEmpty) {
      results.add({
        'key': key,
        'ja': name,
        'origin': origin,
        'found': false,
        'confidence': 'none',
      });
      stdout.writeln('  ${(i + 1).toString().padLeft(3)}/${keys.length} '
          '${key.padRight(18)} $name  -> 查不到，需 AI 判断');
      continue;
    }

    final page = (pages.first as Map).cast<String, dynamic>();
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

    hit++;
    if (okOrigin) originConfirmed++;

    results.add({
      'key': key,
      'ja': name,
      'origin': origin,
      'found': true,
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
    stdout.writeln('  ${(i + 1).toString().padLeft(3)}/${keys.length} '
        '${key.padRight(18)} ${name.padRight(22)} -> $zh  '
        '[$confidence${okOrigin ? ', 归属已核' : ''}]');
  }
  client.close();

  final outDir = Directory('tool/tag_verify/out')..createSync(recursive: true);
  final f = File('${outDir.path}/evidence.json');
  f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'schema': 1,
    'source': 'danbooru wiki_pages.other_names',
    'total': results.length,
    'hit': hit,
    'originConfirmed': originConfirmed,
    'results': results,
  }));

  stdout.writeln('\n查得到 $hit/${keys.length}，其中归属也对得上 $originConfirmed 条');
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
