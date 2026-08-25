/// ② 确定性核实层（iwara 侧）。
///
/// iwara 的标签 id 本来就是 booru 风格的小写下划线命名（`inui_toko`、`hatsune_miku`），
/// 与 Danbooru 的 tag 命名同源——所以这边可以**按 tag 名精确匹配**，
/// 比 oreno3d 那边靠日文别名反查更硬。
///
/// 与 oreno3d 侧同构：只产出证据，不改任何词库。
///
/// 用法：
///   dart run tool/tag_verify/lookup_iwara.dart --all --quiet
///   dart run tool/tag_verify/lookup_iwara.dart --keys inui_toko,firefly
///   dart run tool/tag_verify/lookup_iwara.dart --all --limit 50
library;

import 'dart:convert';
import 'dart:io';

import '../tag_audit/cjk_variants.dart';

const _ua =
    'LoveIwara-tag-verify/0.1 (+https://github.com/FoxSensei001/LoveIwara)';
const _wiki = 'https://danbooru.donmai.us/wiki_pages.json';
const _delay = Duration(milliseconds: 300);
const _cachePath = 'tool/tag_verify/out/danbooru_cache_iwara.json';

final _kana = RegExp(r'[ぁ-ゟァ-ヺー-ヿ]');
final _han = RegExp(r'[一-鿿]');
final _hangul = RegExp(r'[가-힣]');
final _latin = RegExp(r'[A-Za-z]');
final _simplified = kSimplifiedOnly.split('').toSet();
final _traditional = kTraditionalOnly.split('').toSet();

/// 与 oreno3d 侧同一套分桶规则（简繁判定复用 tag_audit 的独用字表）。
Map<String, List<String>> bucketNames(List<String> names) {
  final out = <String, List<String>>{
    'ja': [],
    'zh-CN': [],
    'zh-TW': [],
    'zhAny': [],
    'en': [],
  };
  for (final n in names) {
    if (_hangul.hasMatch(n)) continue;
    if (_kana.hasMatch(n)) {
      out['ja']!.add(n);
    } else if (_han.hasMatch(n)) {
      final chars = n.split('');
      final hasS = chars.any(_simplified.contains);
      final hasT = chars.any(_traditional.contains);
      if (hasS && !hasT) {
        out['zh-CN']!.add(n);
      } else if (hasT && !hasS) {
        out['zh-TW']!.add(n);
      } else {
        out['zhAny']!.add(n);
      }
    } else if (_latin.hasMatch(n)) {
      out['en']!.add(n);
    }
  }
  out.removeWhere((_, v) => v.isEmpty);
  return out;
}

String? preferredZh(Map<String, List<String>> b) {
  final pool = [...?b['zh-CN'], ...?b['zhAny']]
      .map((e) => e.replaceAll(RegExp(r'[（(][^）)]*[）)]'), '').trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (pool.isEmpty) return null;
  pool.sort((a, b) => a.runes.length.compareTo(b.runes.length));
  return pool.first;
}

Future<Map<String, dynamic>?> _fetch(
    HttpClient client, Uri uri, String cacheKey, Map<String, dynamic> cache) async {
  if (cache.containsKey(cacheKey)) {
    return (cache[cacheKey] as Map?)?.cast<String, dynamic>();
  }
  Map<String, dynamic>? result;
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.userAgentHeader, _ua);
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode == 200) {
        final list = jsonDecode(body) as List<dynamic>;
        if (list.isNotEmpty) {
          final first = (list.first as Map).cast<String, dynamic>();
          result = {
            'title': first['title'],
            'other_names': first['other_names'],
          };
        }
        break;
      }
      if (res.statusCode == 429) {
        await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
        continue;
      }
      break;
    } catch (_) {
      if (attempt == 2) break;
      await Future<void>.delayed(Duration(seconds: attempt + 1));
    }
  }
  cache[cacheKey] = result;
  await Future<void>.delayed(_delay);
  return result;
}

Future<void> main(List<String> args) async {
  final raw = jsonDecode(
    File('tool/data/iwara_tags/iwara_tags.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final loc = jsonDecode(
    File('tool/data/iwara_tags/iwara_tags_localized.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final ids = (raw['tags'] as List)
      .map((e) => '${(e as Map)['id']}')
      .toList()
    ..sort();

  var keys = ids;
  final keysArg = _optionOf(args, '--keys');
  if (keysArg != null) {
    keys = keysArg.split(',').map((e) => e.trim()).where(ids.contains).toList();
  } else if (!args.contains('--all')) {
    stderr.writeln('要么 --all，要么 --keys a,b,c');
    exitCode = 64;
    return;
  }
  final limit = int.tryParse(_optionOf(args, '--limit') ?? '');
  if (limit != null && limit < keys.length) keys = keys.sublist(0, limit);

  final quiet = args.contains('--quiet');
  final cacheFile = File(_cachePath);
  final cache = cacheFile.existsSync()
      ? (jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>)
      : <String, dynamic>{};

  stdout.writeln('待核实 ${keys.length} 条 iwara 标签');

  final client = HttpClient();
  final results = <Map<String, dynamic>>[];
  final verdicts = <String, int>{};
  var hit = 0;

  for (var i = 0; i < keys.length; i++) {
    final id = keys[i];

    // iwara 的 tag id 与 Danbooru 的 tag 名同源，优先按标题精确匹配。
    var page = await _fetch(
      client,
      Uri.parse(_wiki).replace(queryParameters: {
        'search[title]': id,
        'limit': '1',
      }),
      'title:$id',
      cache,
    );
    var via = 'title';
    if (page == null) {
      // 退而求其次：把下划线换成空格当别名查（`inui toko`）。
      page = await _fetch(
        client,
        Uri.parse(_wiki).replace(queryParameters: {
          'search[other_names_match]': id.replaceAll('_', ' '),
          'limit': '1',
        }),
        'other:$id',
        cache,
      );
      via = 'other_names';
    }

    final existingZh = ((loc[id] as Map?)?['zh-CN'] as String?)?.trim() ?? '';

    if (page == null) {
      verdicts['no_evidence'] = (verdicts['no_evidence'] ?? 0) + 1;
      results.add({
        'key': id,
        'existingZh': existingZh,
        'found': false,
        'verdict': 'no_evidence',
        'confidence': 'none',
      });
    } else {
      hit++;
      final others =
          ((page['other_names'] as List?) ?? const []).map((e) => '$e').toList();
      final buckets = bucketNames(others);
      // 按标题精确命中就是同一个 tag，证据最硬；靠别名命中则弱一档。
      final confidence = via == 'title' ? 'high' : 'medium';
      final zhPool = <String>{...?buckets['zh-CN'], ...?buckets['zhAny']};
      final zhClean = zhPool
          .map((e) => e.replaceAll(RegExp(r'[（(][^）)]*[）)]'), '').trim())
          .where((e) => e.isNotEmpty)
          .toSet();

      String verdict;
      if (existingZh.isEmpty) {
        verdict = 'untranslated';
      } else if (confidence != 'high') {
        verdict = 'weak_evidence';
      } else if (zhClean.isEmpty) {
        verdict = 'no_zh_evidence';
      } else if (zhClean.contains(existingZh) || zhPool.contains(existingZh)) {
        verdict = 'agree';
      } else if (zhClean
          .any((c) => existingZh.contains(c) || c.contains(existingZh))) {
        verdict = 'agree_loose';
      } else {
        verdict = 'disagree';
      }
      verdicts[verdict] = (verdicts[verdict] ?? 0) + 1;

      results.add({
        'key': id,
        'existingZh': existingZh,
        'found': true,
        'verdict': verdict,
        'confidence': confidence,
        'matchedBy': via,
        'danbooru': {
          'title': page['title'],
          'url': 'https://danbooru.donmai.us/wiki_pages/${page['title']}',
          'otherNames': others,
        },
        'candidates': {...buckets, 'preferredZh': preferredZh(buckets)},
      });
    }

    if (!quiet) {
      final r = results.last;
      stdout.writeln('  ${(i + 1).toString().padLeft(4)}/${keys.length} '
          '${id.padRight(28)} 现译「$existingZh」 -> ${r['verdict']}');
    } else if ((i + 1) % 200 == 0) {
      stdout.writeln('  进度 ${i + 1}/${keys.length}'
          '（命中 $hit，分歧 ${verdicts['disagree'] ?? 0}）');
      cacheFile.parent.createSync(recursive: true);
      cacheFile.writeAsStringSync(jsonEncode(cache));
    }
  }
  client.close();
  cacheFile.parent.createSync(recursive: true);
  cacheFile.writeAsStringSync(jsonEncode(cache));

  final out = File('tool/tag_verify/out/evidence_iwara.json');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
    'schema': 1,
    'source': 'danbooru wiki_pages (title exact, other_names fallback)',
    'total': results.length,
    'hit': hit,
    'verdicts': verdicts,
    'results': results,
  }));

  stdout.writeln('\n查得到 $hit/${keys.length}');
  stdout.writeln('与现有译名比对：');
  for (final e in verdicts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value))) {
    stdout.writeln('  ${e.key.padRight(16)} ${e.value}');
  }
  stdout.writeln('证据 -> ${out.path}');
}

String? _optionOf(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}
