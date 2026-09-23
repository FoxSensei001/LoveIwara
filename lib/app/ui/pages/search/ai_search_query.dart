import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/widgets/search_mode_menu.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// AI 把一句大白话变成「搜哪个板块 + 搜索词 + 怎么排 + 一组筛选条件」。
///
/// 它**不执行搜索**，只是把这张表替用户填好。为什么到此为止：搜索结果的好坏
/// 用户一眼就能判断，而「AI 替我改了搜索词还自动搜了」在结果不对时无从追究——
/// 他不知道到底是自己没说清，还是模型理解错了。填好表让他看一眼再按，两件事
/// 就分得开。
class AiSearchQuery {
  const AiSearchQuery({
    required this.query,
    required this.segment,
    required this.segmentChanged,
    required this.filters,
    this.sort,
  });

  /// 填进搜索框的关键词。可能是空串（「只按条件筛，不限关键词」）。
  final String query;

  /// 该去哪个板块搜。
  ///
  /// ⭐ 这一项是 2026-09-21 补的：在它之前模型只知道「当前板块的字段表」，
  /// 于是「受欢迎的 oreno3d 的 huohuo 视频」被填成了 `作者 = oreno3d` ——
  /// Oreno3D 是**另一个站的索引**（App 里是并列的一个板块），不是谁的名字。
  /// 板块这件事不告诉模型，它就只能在手里那张表上硬凑。
  final SearchSegment segment;

  /// [segment] 与用户当前所在的板块不同。弹窗要**显式告诉用户**，不能默默换——
  /// 按下去之后页面整个换了个索引，不说一声只会让人以为点错了。
  final bool segmentChanged;

  /// 排序值（[FilterConfig.getSortOptionsForSegment] 里的 `value`）。
  /// null ＝「不动用户当前的排序」。
  final String? sort;

  final List<Filter> filters;

  bool get isEmpty =>
      query.trim().isEmpty &&
      filters.isEmpty &&
      sort == null &&
      !segmentChanged;
}

/// 让 AI 按**整张搜索表**填一次：板块 / 关键词 / 排序 / 筛选。
///
/// ⭐ 不让模型去写 iwara 那套花括号语法（`{likes:>100}`）。`FilterConfig` 里
/// 每个板块能筛什么、每个字段是什么类型、SELECT 字段有哪几个合法值、能怎么排，
/// 本来就是现成的白名单——把它摊给模型，模型只能填表，编出来的东西在解析这一步
/// 当场作废，而不是发出去等服务端回 500。花括号仍由既有的
/// [FilterConfig.generateFilterString] 渲染，格式只有那一处说了算。
///
/// ⚠️ 模型**吐不出可靠的多态值**（一会儿数字一会儿数组），所以 schema 里
/// `value` 一律是字符串，复杂类型在 [_parseValue] 里按字段类型解析回来。
///
/// ⛔ `field` 的 enum 是**所有板块字段的并集**——板块由模型自己选，schema 却要
/// 在发请求前就定下来，没法只放选中那个板块的字段。所以真正的把关在
/// [_toFilter]：按**它选的那个板块**的字段表再验一遍，对不上的整条丢掉。
Future<ApiResult<AiSearchQuery>> buildAiSearchQuery({
  required String request,
  required SearchSegment segment,
  required String currentSort,
  String Function(String technicalReason)? decorateError,
  void Function(AiProgress progress)? onProgress,
}) async {
  final allFields = _allFields();
  if (allFields.isEmpty) {
    return ApiResult.fail('no filterable fields');
  }

  final ai = Get.find<AiService>();
  final result = await ai.structured(
    AiRequest(
      task: AiTask.searchQuery,
      input: request,
      system: _systemPrompt(segment, currentSort),
      decorateError: decorateError,
      tools: [_searchPreviewTool()],
    ),
    schema: _schemaFor(allFields.keys.toList()),
    onProgress: onProgress,
  );

  if (!result.isSuccess || result.data == null) {
    return ApiResult.fail(result.message);
  }

  return ApiResult.success(data: _parse(result.data!, segment));
}

/// 所有板块字段的并集，按字段名去重（`title` / `author` 之类在好几个板块里
/// 同名同义）。
Map<String, FilterField> _allFields() {
  final out = <String, FilterField>{};
  for (final seg in SearchSegment.values) {
    final fields = FilterConfig.getContentType(seg)?.fields;
    if (fields == null) continue;
    for (final f in fields) {
      out.putIfAbsent(f.name, () => f);
    }
  }
  return out;
}

/// 用户最近搜过什么。给模型当**用词参考**：同一个角色的写法（huohuo / 火火 /
/// フォフォ）他自己用哪一种，历史里就有答案。
///
/// ⛔ 用户把「记录搜索」关掉时一条都不给——那个开关的意思是「别记我搜了什么」，
/// 把它攒下来的东西转手发去第三方接口，比记下来本身更过分。
List<String> _historyHints() {
  if (!Get.isRegistered<UserPreferenceService>()) return const [];
  final prefs = Get.find<UserPreferenceService>();
  if (!prefs.searchRecordEnabled.value) return const [];

  final records = prefs.videoSearchHistory.toList()
    ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
  return records
      .map((r) => r.keyword.trim())
      .where((k) => k.isNotEmpty)
      .take(_historyHintCount)
      .toList();
}

/// 历史只取最近这么几条。再多就是拿用户的浏览痕迹去喂上下文，收益也见顶了。
const int _historyHintCount = 12;

String _systemPrompt(SearchSegment current, String currentSort) {
  final t = slang.t;
  final buffer = StringBuffer()
    ..writeln(
      'You fill in the search form of a client app for Iwara, an adult '
      'MMD/3D video and image site. The app searches several different '
      'indexes ("segments"). Pick the right segment first, then fill in the '
      'sort and the filters that segment actually supports.',
    )
    ..writeln()
    ..writeln(
      'The user is currently on segment "${current.name}", sorted by '
      '"$currentSort" — that is what stays in effect if you omit "sort".',
    )
    ..writeln()
    ..writeln('Segments:');

  for (final seg in SearchSegment.values) {
    buffer.writeln('- ${seg.name} — ${searchSegmentLabel(seg, t)}');
    final note = _segmentNote(seg);
    if (note != null) buffer.writeln('    $note');

    final sorts = FilterConfig.getSortOptionsForSegment(seg);
    if (sorts.isNotEmpty) {
      buffer.writeln(
        '    sort: ${sorts.map((s) => '${s.value} (${s.label})').join(', ')}',
      );
    }

    final fields = FilterConfig.getContentType(seg)?.fields ?? const [];
    if (fields.isEmpty) {
      buffer.writeln('    filters: none — this segment takes a keyword only.');
    } else {
      buffer.writeln('    filters:');
      for (final field in fields) {
        buffer.write(
          '      - ${field.name} (${field.type.name}, ${field.displayName})'
          ' ops: ${FilterConfig.getOperatorsForType(field.type).map((o) => o.name).join('/')}',
        );
        // SELECT 字段不把合法值列出来，模型必编——它只看得见字段名。
        // ⛔ 值为空串的那一项要剔掉：`rating` 的首项是「不限」，值就是 ''，
        // 原样印出来是 `one of: , ecchi, general`，开头那个逗号只会让模型
        // 以为有个叫空的合法值（而空值在 _parseValue 那关本来就会被丢）。
        final options = (field.options ?? const [])
            .map((o) => o.value)
            .where((v) => v.isNotEmpty)
            .toList();
        if (options.isNotEmpty) {
          buffer.write(' one of: ${options.join(', ')}');
        }
        buffer.writeln();
      }
    }
  }

  buffer
    ..writeln()
    // ⭐ 下面这一段是 2026-09-21 对着真端点量出来的（见 docs 与提交说明）。
    // 它不是背景知识，而是这张表填得好不好的**全部差别**：iwara 换了搜索引擎
    // 之后用户抱怨「搜不准」，根因就写在这几条里。
    ..writeln('How the Iwara search engine actually behaves (measured):')
    ..writeln(
      '- Words in "query" are ANDed, and the LAST word is matched as a '
      'prefix. `miku` 7289 hits and `dance` 14967 hits, but `miku dance` only '
      '699 and `miku dance cosplay` only 2. So adding a word is a strong '
      'narrowing — do use several words when the request is specific.',
    )
    ..writeln(
      '- ⭐⭐ QUOTE every multi-word or CJK phrase: "…" means exact phrase. '
      'This is the single most important thing you do. Unquoted CJK is NOT '
      'ANDed — it is shredded into fragments and OR-ed, which is why Iwara '
      'search feels broken: 白金ディスコ returns 1686 videos of which only 34 '
      'contain the phrase, while "白金ディスコ" returns exactly those 34. '
      'Measured precision of the first 20 hits for 初音ミク sorted by date: '
      'unquoted 3/20, quoted 20/20.',
    )
    ..writeln(
      '  → Quote a CJK run that is ONE name or term, kana and mixed script '
      'included: 初音ミク, 白金ディスコ, このすば, ゆるキャン, けものフレンズ, '
      '碧蓝航线. Measured, bare → quoted: このすば 4488 → 75, ゆるキャン 314 '
      '→ 22, にじさんじ 9857 → 65 — precision of the first 20 by date goes '
      'from 0-1/20 to 20/20 in every one of those. Quote Latin phrases of two '
      'or more words ("hatsune miku"); leave a single Latin word unquoted so '
      'prefix matching still helps.',
    )
    ..writeln(
      '  → ⛔ But NEVER wrap a whole phrase built with a particle (の, が, を, '
      'に, は, で, と) in one pair of quotes: that sentence almost never '
      'occurs verbatim in a title, so it returns nothing at all. Measured: '
      '原神の甘雨 138 bare but 0 quoted; 初音ミクのダンス 5250 bare but 0 '
      'quoted; 水着の女の子 440 bare but 1 quoted. Quote the PARTS and let AND '
      'join them — `"原神" "甘雨"` (10), `"初音ミク" "ダンス"` (135).',
    )
    ..writeln(
      '  → ⛔ Only split on a particle when at least 2 characters remain on '
      'each side, otherwise you cut a name apart: the の in ときのそら and the '
      'こ/すば in このすば are parts of the name itself (splitting ときのそら '
      'drops precision 20/20 → 9/20; splitting けものフレンズ drops 57 hits to '
      '1). When in doubt, quote the whole run and let `preview_search` tell '
      'you whether it exists.',
    )
    ..writeln(
      '  → Quotes compose: `"初音ミク" "ダンス"` (135) and `"初音ミク" ダンス` '
      '(421) both work. Never emit an empty pair of quotes — `""` matches '
      'nothing at all.',
    )
    ..writeln(
      '- Sorting only re-orders the recall set, it never narrows it. With an '
      'UNQUOTED keyword, date/views/likes therefore show the newest (or most '
      'viewed) of a mostly-irrelevant pool — the first page has nothing to do '
      'with what was typed. This is the single biggest complaint about Iwara '
      'search, and quoting fixes it: once quoted, every sort is clean.',
    )
    ..writeln(
      '- Exclude a word with a leading minus: `"初音ミク" -MMD`. ⛔ The minus '
      'must be attached to the word AND preceded by a space — a hyphen inside '
      'a word is just a hyphen (`R-18` is the same query as `R18`).',
    )
    ..writeln(
      '- ⛔ There are NO boolean operators. `AND`, `OR`, `NOT`, `+`, `!`, '
      'parentheses and `#` are all treated as ordinary characters or silently '
      'dropped — `miku NOT dance` searches for the word "not". Use spaces '
      '(AND), quotes (phrase) and `-` (exclude), nothing else. Also avoid `:` '
      'and `/` inside "query"; they wreck tokenisation.',
    )
    ..writeln(
      '- ⭐ The free-text query does NOT search tags ("hatsune_miku" as a '
      'keyword: 38 results; as a tags filter: 6489) and does NOT search '
      'usernames (gfsmmd as a keyword: 4; as an author filter: 126). Anything '
      'about tags or authors MUST become a filter.',
    )
    ..writeln(
      '- ⭐ When the request names a character, series or genre, write that '
      'name in "query" as its own quoted phrase (the user\'s words, the '
      'English name or the slug all work). The app recognises exact tag names '
      'in the query and AUTOMATICALLY also searches that tag plus the name in '
      'Japanese/English/Chinese, merging the results — a name in "query" '
      'reaches tagged videos whose titles never mention it (measured: 原神 as '
      'text alone finds 17 recent videos, with the automatic tag route 324). '
      'Add a tags filter only to CONSTRAIN: a filter is ANDed into every one '
      'of those searches, so it cuts out untagged matches. Write it in the '
      'user\'s own words or as the English slug — the app resolves it against '
      'the real Iwara tag dictionary and drops what it cannot resolve. Never '
      'invent a slug.',
    )
    ..writeln(
      '- IN on one filter is OR (tags IN [a,b] = a or b); two filters on the '
      'same field are AND. "miku AND genshin" is therefore two tags filters. '
      'NOT_IN really does exclude (measured: 320943 total − 6489 tagged = '
      '314457), so use it for "without tag X".',
    )
    ..writeln(
      '- "author" is the exact @username, case-insensitive. Partial handles '
      'and display names match NOTHING ({author: gfsm} → 0, {author: "GFS '
      'MMD"} → 0, {author: gfsmmd} → 126). Only fill it when the request '
      'gives a handle. If the user names an author in prose, either search '
      'the "user" segment or leave the name in "query".',
    )
    ..writeln(
      '- ⭐ Because words AND, do NOT pile on context the user did not ask '
      'for. `"甘雨"` finds 119 videos; adding her series as `"原神" "甘雨"` '
      'cuts it to 10, because most uploaders never write the series name. '
      'Search the most distinctive term; if it is a tag name the app '
      'already expands it to the tag.',
    )
    ..writeln(
      '- Typo tolerance is erratic ("mliku" → 7263 hits, "mikuu" → 4). Write '
      'the correct, conventional spelling yourself; do not pass the user\'s '
      'typo through, and prefer the romanisation their search history shows '
      'they use.',
    )
    ..writeln(
      '- "rating": ~88% of the catalogue is `ecchi`, so filtering on it '
      'narrows almost nothing. Only set it when the user explicitly asks for '
      'SFW / NSFW.',
    )
    ..writeln(
      '- ⛔ "duration" is only recorded for 55% of the videos, so ANY duration '
      'filter silently throws away the other 45%. Only use it when the '
      'request is really about length.',
    )
    ..writeln()
    ..writeln(
      '⭐ You can check yourself: call `preview_search` with the query (and '
      'tags) you are about to answer with, and look at the count. Do it at '
      'least once. A count of 0 or 1 means the phrase does not exist verbatim '
      'and you must fall back, IN THIS ORDER: (1) if it contains a particle, '
      'split it into two quoted parts (`"原神の甘雨"` 0 → `"原神" "甘雨"` 10; '
      '`"初音ミクのダンス"` 0 → `"初音ミク" "ダンス"` 135); (2) drop the least '
      'distinctive word; (3) as a last resort drop the quotes entirely. Stop '
      'at the first step that returns results. A count in the tens of '
      'thousands for a specific request means the opposite — you are too '
      'loose, most likely because a CJK phrase went unquoted. Answer with the '
      'version you actually verified.',
    )
    ..writeln()
    ..writeln('Rules:')
    ..writeln(
      '- "segment": keep "${current.name}" unless the request clearly points '
      'at another index.',
    )
    ..writeln(
      '- "sort": a sort value of the segment you picked, or omit it to leave '
      'the user\'s current sort alone.',
    )
    ..writeln(
      '- ⭐ Prefer sort over an invented threshold. "popular" / "most viewed" '
      '/ "trending" is a SORT, not a filter like views >= 10000 — a made-up '
      'number silently throws away everything below it.',
    )
    ..writeln(
      '- "query" is the free-text keyword, written in the engine\'s syntax: '
      'quoted phrases, bare words, and `-word` exclusions. Strip out anything '
      'you expressed as segment, sort or filter. If the request is purely '
      'about those, use "". Examples of good queries: `"初音ミク" "ダンス"`, '
      '`"hatsune miku" -mmd`, `cosplay`.',
    )
    ..writeln(
      '- "filters": only fields listed under the segment you picked. If the '
      'request mentions something with no matching field there, fold it into '
      '"query" instead of inventing a field or borrowing one from another '
      'segment.',
    )
    ..writeln('- Omit "filters" entirely when nothing maps cleanly.')
    ..writeln()
    ..writeln('Value formats (the "value" field is always a string):')
    ..writeln('- RANGE: "from..to". One side may be empty: "100.." or "..100".')
    ..writeln('- IN / NOT_IN: comma-separated, e.g. "a,b,c".')
    ..writeln('- DATE: ISO date, "2026-01-31".')
    ..writeln('- BOOLEAN: "true" or "false".')
    ..writeln()
    // 本地化字段不挑语言就等于没筛：`{title: x}` 是个不存在的字段，服务端
    // **静默忽略**它并把整个索引还回来（实测 320928 条＝全站）。
    ..writeln(
      '"locale" (only for the localized fields title / body / name — required '
      'there):',
    )
    ..writeln(
      '- Each language keeps its own index of the SAME text, analysed by that '
      'language\'s tokenizer, so the suffix decides how well the text splits. '
      'Measured: "kangxi" → en 666 / ja 76 / zh 2; "白金ディスコ" → ja 33 / '
      'en 14 / zh 0; "崩坏" → zh 548 / ja 277; "原神" → ja 914 / zh 309.',
    )
    ..writeln('- Latin letters / romaji → "en".')
    ..writeln('- Anything with kana, or Japanese written in kanji → "ja".')
    ..writeln(
      '- "zh" only for text that is Chinese-only — simplified characters that '
      'do not exist in Japanese (崩坏, 发, 龙) or a Chinese-only rendering of '
      'a name. Shared kanji (原神, 甘雨) do better on "ja", because most '
      'titles on the site are Japanese.',
    )
    ..writeln(
      '- ⛔ Do NOT add a title/body filter just to reach another language. '
      'Free text only searches ONE language\'s title+body (the engine guesses '
      'which, and guesses badly: 原神 → en, 明日方舟 → ja, 东方 → zh), but the '
      'app ALREADY re-runs your quoted keyword against the Chinese and '
      'Japanese title indexes and merges the results. A title filter would be '
      'ANDed with the free text instead, which CUTS results (原神 free text '
      '409 ∩ {title_zh:"原神"} 307 = only 38). Use these filters only when the '
      'user really wants to constrain — "only Chinese titles", "mentioned in '
      'the description".',
    );

  final history = _historyHints();
  if (history.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        'The user has searched these before (most recent first). Use them as '
        'a hint for spelling and vocabulary — e.g. which romanisation of a '
        'character name they use. Do NOT search for them unless asked:',
      )
      ..writeln(history.join(' | '));
  }

  return buffer.toString();
}

/// 光给一个板块名，模型分不清「这是个索引」还是「这是个作者/标签」。
/// 只有真会被认错的那几个需要一句话。
String? _segmentNote(SearchSegment seg) => switch (seg) {
  SearchSegment.oreno3d =>
    'A SEPARATE third-party catalogue (oreno3d.com) of MMD works, browsable '
        'by origin / character / tag. "oreno3d" names this index — it is NOT '
        'an author, a tag or a keyword on Iwara. Its matching is looser than '
        'Iwara\'s, but its entries are a catalogue of works, not of files: '
        'some of them point at videos that no longer exist on Iwara. Pick it '
        'only when the user asks for it by name or wants to browse by '
        'origin / character, not merely because an Iwara keyword search '
        'looks thin.',
  SearchSegment.forum => 'Forum threads.',
  SearchSegment.forum_posts => 'Individual forum replies, not whole threads.',
  SearchSegment.post => 'Blog-style posts written by users.',
  SearchSegment.playlist => 'User-made video playlists.',
  _ => null,
};

/// ⛔ 用 `Schema.fromMap` 手写这张表，不用 `json_schema_builder` 的
/// `ObjectSchema` / `StringSchema` 那套 builder：dartantic 只 re-export 了
/// `S` 和 `Schema` 两个名字，那些 builder 要额外把 `json_schema_builder` 加成
/// 直接依赖，为几行 schema 不值当。这张表还会被原样 `jsonEncode` 进提示词
/// （见 `AiService._jsonContractPrompt`），写成什么样模型就看到什么样。
Schema _schemaFor(List<String> fieldNames) => Schema.fromMap({
  'type': 'object',
  'properties': {
    'segment': {
      'type': 'string',
      'enum': SearchSegment.values.map((s) => s.name).toList(),
      'description': 'Which index to search.',
    },
    'query': {
      'type': 'string',
      'description': 'Free-text keyword. Empty string if filters cover it all.',
    },
    'sort': {
      'type': 'string',
      'description':
          'A sort value of the chosen segment. Omit to keep the current sort.',
    },
    'filters': {
      'type': 'array',
      'description': 'Structured filters. Omit when nothing maps.',
      'items': {
        'type': 'object',
        'properties': {
          'field': {'type': 'string', 'enum': fieldNames},
          'operator': {
            'type': 'string',
            'enum': FilterOperator.values.map((o) => o.name).toList(),
          },
          'value': {'type': 'string'},
          'locale': {
            'type': 'string',
            'enum': _locales,
            'description':
                'Language index for the localized fields (title/body/name). '
                'Required for those, ignored elsewhere.',
          },
        },
        'required': ['field', 'operator', 'value'],
      },
    },
  },
  'required': ['query'],
});

AiSearchQuery _parse(Map<String, dynamic> raw, SearchSegment current) {
  final segment = _parseSegment(raw['segment'], current);
  final fields = FilterConfig.getContentType(segment)?.fields ?? const [];

  var query = (raw['query'] as String?)?.trim() ?? '';
  final filters = <Filter>[];
  // 解析不掉的标签落回关键词，见 _resolveTags。
  final leftovers = <String>[];

  final rawFilters = raw['filters'];
  if (rawFilters is List) {
    for (final item in rawFilters) {
      if (item is! Map) continue;
      final filter = _toFilter(item.cast<String, dynamic>(), fields, leftovers);
      if (filter != null) filters.add(filter);
    }
  }

  for (final word in leftovers) {
    if (query.toLowerCase().contains(word.toLowerCase())) continue;
    query = query.isEmpty ? word : '$query $word';
  }

  // ⛔ oreno3d 是另一个站的搜索，不吃 iwara 的引号/减号语法。
  if (segment != SearchSegment.oreno3d) query = autoQuoteKeyword(query);

  final sort = _parseSort(raw['sort'], segment);

  return AiSearchQuery(
    query: query,
    segment: segment,
    segmentChanged: segment != current,
    sort: sort,
    filters: filters,
  );
}

/// 模型最多能试搜几次。
///
/// ⛔ 必须有个上限，而且要**在工具里硬拦**，不能只写在提示词里：一次试搜是一次
/// 真实网络请求 + 一整轮对话，模型钻进「再查一次说不定更好」的循环时，用户看到
/// 的是弹窗转了一分钟。四次够它验完关键词和两三个标签了。
const int _maxPreviewCalls = 4;

/// 试搜时看前几条标题。
const int _previewTitleCount = 3;

/// ⭐ 让模型能**真的搜一下**再回答。
///
/// 这是把「iwara 引擎很怪」这件事从提示词里解放出来的关键一步：提示词只能告诉
/// 它规则，试搜能告诉它**这一次到底成不成**。最值当的两种用法：
/// - 关键词加了引号之后还有没有结果（短语不存在时是 0 条，而 0 条比一堆不相关
///   更难受，它得退回不加引号）；
/// - 标签是不是真的（`{tags:[miku]}` 是 0 条，真 id 叫 `hatsune_miku`）。
///
/// ⛔ 工具只接**填表用的那几项**（板块 / 关键词 / 标签），不接花括号原文：整份
/// 提示词都刻意没教它那套语法（见 [buildAiSearchQuery] 的说明），在这儿开个后门
/// 等于让它现学一套没人校验的东西。
///
/// ⛔ 出错一律**回成一条结果**而不是抛出去：抛出去会把整轮对话打断，用户只拿到
/// 一句网络错误；回给它看，它自己会换个写法。
AiTool _searchPreviewTool() {
  var used = 0;

  // oreno3d 是另一个站，这个探针打的是 api.iwara.tv，探不了它。
  final segments = SearchSegment.values
      .where((s) => s != SearchSegment.oreno3d)
      .map((s) => s.name)
      .toList();

  return AiTool(
    tool: Tool<Map<String, dynamic>>(
      name: 'preview_search',
      description:
          'Run a candidate search against the real Iwara index and get back '
          'how many results it returns, plus the first few titles. Check '
          'yourself with this before you answer — above all (1) that a quoted '
          'phrase really occurs, and (2) that the tags you picked exist at '
          'all (a wrong tag slug returns 0 and would hand the user an empty '
          'page). At most $_maxPreviewCalls calls; if a result is 0 or '
          'obviously off, adjust and answer with the version you verified.',
      inputSchema: Schema.fromMap({
        'type': 'object',
        'properties': {
          'segment': {
            'type': 'string',
            'enum': segments,
            'description': 'Which index. Defaults to videos.',
          },
          'query': {
            'type': 'string',
            'description':
                'Free-text part, in the engine syntax: quoted phrases, bare '
                'words, -word to exclude. May be empty when only checking tags.',
          },
          'tags': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Tag slugs to require (they are OR-ed together).',
          },
        },
        'required': ['query'],
      }),
      onCall: (args) async {
        if (used >= _maxPreviewCalls) {
          return {
            'error':
                'preview limit of $_maxPreviewCalls reached — answer with '
                'what you have.',
          };
        }
        used++;
        return _runPreview(args);
      },
    ),
    describeCall: (args) {
      final parts = <String>[
        (args['query'] as String?)?.trim() ?? '',
        ..._previewTags(args).map((t) => '#$t'),
      ].where((e) => e.isNotEmpty);
      return slang.t.ai.searchToolProbing(
        query: parts.isEmpty ? '…' : parts.join(' '),
      );
    },
    describeResult: (result) {
      if (result is! Map) return slang.t.ai.searchToolFailed(reason: '$result');
      final error = result['error'];
      if (error != null) {
        return slang.t.ai.searchToolFailed(reason: '$error');
      }
      final titles = (result['titles'] as List?)?.cast<String>() ?? const [];
      return slang.t.ai.searchToolFound(
        count: result['count'] as int? ?? 0,
        titles: titles.join(' / '),
      );
    },
  );
}

List<String> _previewTags(Map<String, dynamic> args) =>
    (args['tags'] as List?)
        ?.map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList() ??
    const [];

/// 真打一次 `/search`，只取 count 与前几条标题。
Future<Map<String, dynamic>> _runPreview(Map<String, dynamic> args) async {
  final segment = SearchSegment.values.firstWhereOrNull(
    (s) => s.name == (args['segment'] as String?)?.trim(),
  );
  final type = (segment ?? SearchSegment.video).apiType;

  final tags = _previewTags(args);
  // ⛔ 自由文本必须在花括号前面，反过来文本会被引擎静默丢掉（见 composeQuery）。
  // 模型自己在 query 里写的筛选也一并挪到后面。
  final parts = splitQueryParts((args['query'] as String?)?.trim() ?? '');
  final query = composeQuery(
    parts.text,
    [
      parts.filters,
      if (tags.isNotEmpty) '{tags:[${tags.join(',')}]}',
    ].where((e) => e.isNotEmpty).join(' '),
  );

  try {
    final response = await Get.find<ApiService>().get(
      '/search',
      queryParameters: {
        'query': query,
        'type': type,
        'page': 0,
        'limit': _previewTitleCount,
        // ⛔ 探的是「有没有」，不是「先看谁」——按相关度排，第一页才代表这批
        // 结果里最像的那几条。
        'sort': 'relevance',
      },
    );
    final data = response.data;
    if (data is! Map) return {'error': 'unexpected response'};
    final results = (data['results'] as List?) ?? const [];
    return {
      'count': data['count'] ?? 0,
      'titles': [
        for (final item in results.take(_previewTitleCount))
          if (item is Map)
            '${item['title'] ?? item['name'] ?? item['username'] ?? ''}',
      ].where((e) => e.isNotEmpty).toList(),
    };
  } catch (e) {
    LogUtils.w('AI 搜索试搜失败：$e', 'AiSearchQuery');
    return {'error': '$e'};
  }
}

/// 认不出就留在用户当前的板块。⛔ 不要猜一个——把人送去别的索引，比少换一次
/// 板块难收拾得多。
SearchSegment _parseSegment(Object? raw, SearchSegment fallback) {
  final name = (raw as String?)?.trim();
  if (name == null || name.isEmpty) return fallback;
  final seg = SearchSegment.values.firstWhereOrNull((s) => s.name == name);
  if (seg == null) {
    LogUtils.w('AI 搜索给了不存在的板块：$name', 'AiSearchQuery');
    return fallback;
  }
  return seg;
}

/// 排序值必须是**它选的那个板块**的合法值。oreno3d 的 `hot` 放到视频板块上
/// 是一条服务端不认识的参数，搜出来是空的。
String? _parseSort(Object? raw, SearchSegment segment) {
  final value = (raw as String?)?.trim();
  if (value == null || value.isEmpty) return null;
  final allowed = FilterConfig.getSortOptionsForSegment(
    segment,
  ).map((o) => o.value);
  if (!allowed.contains(value)) {
    LogUtils.w('AI 搜索给了 ${segment.name} 不支持的排序：$value', 'AiSearchQuery');
    return null;
  }
  return value;
}

Filter? _toFilter(
  Map<String, dynamic> raw,
  List<FilterField> fields,
  List<String> leftovers,
) {
  final fieldName = (raw['field'] as String?)?.trim();
  if (fieldName == null || fieldName.isEmpty) return null;

  // ⛔ 白名单在这里兜底，不能只靠 schema 的 enum：一来 enum 是**所有板块的
  // 并集**（板块由模型现选，schema 定不下来），二来走「提示词契约」那条降级路
  // 时没有任何东西强制模型遵守 enum（见 AiService.structured 的两条路）。
  final field = fields.firstWhereOrNull((f) => f.name == fieldName);
  if (field == null) {
    LogUtils.w('AI 搜索给了本板块没有的字段：$fieldName', 'AiSearchQuery');
    return null;
  }

  final operator = FilterOperator.values.firstWhereOrNull(
    (o) => o.name == (raw['operator'] as String?)?.trim(),
  );
  if (operator == null) return null;

  // ⛔ 运算符也要按字段类型验：筛选抽屉里每个字段只给得出
  // [FilterConfig.getOperatorsForType] 那几个，模型却看得见全部。
  // 放一条 `CONTAINS` 到 NUMBER 字段上，抽屉里那一行会落进编辑器画不出来的
  // 状态，花括号也拼不成。
  if (!FilterConfig.getOperatorsForType(field.type).contains(operator)) {
    LogUtils.w(
      'AI 搜索把 ${operator.name} 用在了 ${field.name}（${field.type.name}）上',
      'AiSearchQuery',
    );
    return null;
  }

  var value = _parseValue(
    (raw['value'] ?? '').toString().trim(),
    field,
    operator,
  );
  if (value == null) return null;

  if (field.name == 'tags' && value is List<String>) {
    value = _resolveTags(value, leftovers);
    if ((value as List).isEmpty) return null;
  }

  return Filter(
    // 与手工添加的筛选同一套 id 规则：时间戳 + 字段名，抽屉里靠它认行。
    id: '${DateTime.now().microsecondsSinceEpoch}_${field.name}',
    field: field.name,
    // ⛔ 本地化字段不带语言后缀就等于**没有这条筛选**：`{title: x}` 是个不存在
    // 的字段，服务端静默忽略它并把整个索引还回来（实测 320928 条＝全站）。
    // 手工那条路在 filter_row_widget / search_filter_drawer 里默认填 'en'，
    // AI 这条路以前一个字都没填。
    locale: field.isLocalizable
        ? _parseLocale(raw['locale'], _flatten(value))
        : null,
    operator: operator,
    value: value,
  );
}

const List<String> _locales = ['en', 'ja', 'zh'];

/// 模型给的语言后缀；给不出或给错就按文字本身猜一个。
String _parseLocale(Object? raw, String sample) {
  final value = (raw as String?)?.trim().toLowerCase();
  if (value != null && _locales.contains(value)) return value;
  return _inferLocale(sample);
}

/// ⚠️ 只是兜底，正主是模型：「崩坏」该用 zh 而「原神」该用 ja 这种事，
/// 靠字符区间分不出来（都是汉字），模型知道哪个词是中文写法。
///
/// 兜底取 ja 而不是 en/zh：站上标题以日文居多，日文分词器对假名与汉字都能切，
/// 实测同一个汉字词在 ja 上的命中普遍不低于 zh（原神 914 vs 309）。
String _inferLocale(String text) =>
    // 假名 / 汉字（含扩展 A 与兼容区）都走 ja，其余（拉丁、韩文、数字）走 en。
    //
    // ⛔ 两类合成一条，别再拆回两个各自 `return 'ja'` 的 if：读的人得逐字比对
    // 两串字符区间才看得出它们是同一条规则，而改掉其中一个的返回值时，没有
    // 任何东西会提醒你另一个还在。
    _japaneseish.hasMatch(text) ? 'ja' : 'en';

/// 假名（含半角）+ 汉字（含扩展 A 与兼容区）。见 [_inferLocale]。
final RegExp _japaneseish = RegExp(
  r'[぀-ヿㇰ-ㇿｦ-ﾟ'
  r'㐀-䶿一-鿿豈-﫿]',
);

String _flatten(Object? value) {
  if (value is List) return value.join(' ');
  if (value is Map) return '${value['from'] ?? ''} ${value['to'] ?? ''}';
  return value?.toString() ?? '';
}

/// 把模型给的标签换成**真实存在的** tag id。
///
/// ⛔ 标签是精确匹配的关键词字段：`{tags: [miku]}` 与 `{tags: [no_such_tag]}`
/// 一样回 0 条（真正的 id 是 `hatsune_miku`，6489 条）。模型编一个像那么回事的
/// slug，用户得到的就是一张空列表，还看不出是哪一条条件把结果杀光的。
///
/// App 本来就随包带着整份 iwara 标签词库（[TagLocalizationService]，id + 当前
/// 语言译名），所以这件事不该让模型猜：它写用户的话或英文 slug，由我们查表。
/// 查不到的不留在筛选里，而是退回关键词——空列表比模糊结果难用得多。
List<String> _resolveTags(List<String> raw, List<String> leftovers) {
  final out = <String>[];
  for (final item in raw) {
    final resolved = _resolveTag(item);
    if (resolved == null) {
      LogUtils.w('AI 搜索给了词库里没有的标签：$item，退回关键词', 'AiSearchQuery');
      leftovers.add(item);
      continue;
    }
    if (!out.contains(resolved)) out.add(resolved);
  }
  return out;
}

/// 只认**精确**命中（id 或当前语言译名，忽略大小写与下划线/空格之差）。
/// ⛔ 不要拿 [TagLocalizationService.search] 的第一条凑数：那是个带 contains 的
/// 模糊搜索，「dance」会命中一堆无关标签，换进筛选条件里就是一条用户没要、
/// 也看不懂哪来的硬条件。
String? _resolveTag(String raw) {
  final needle = _normalizeTag(raw);
  if (needle.isEmpty) return null;

  // ⛔ 词库那边的检索是按原样 contains 的，不会把下划线与空格当一回事：
  // 模型写 "Hatsune Miku"、id 是 `hatsune_miku`，直接查一次是查不着的。
  // 所以三种写法都探一遍，判等仍按归一化后的结果。
  final probes = <String>{
    raw,
    raw.replaceAll(' ', '_'),
    raw.replaceAll('_', ' '),
  };
  for (final probe in probes) {
    for (final tag in TagLocalizationService.search(probe, limit: 12)) {
      if (_normalizeTag(tag.id) == needle) return tag.id;
      if (_normalizeTag(TagLocalizationService.displayName(tag.id)) == needle) {
        return tag.id;
      }
    }
  }
  return null;
}

String _normalizeTag(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'[\s_]+'), '');

/// 把模型给的那一串字按「字段类型 + 运算符」解析回 [Filter.value] 该有的形状。
///
/// 解析不出来就返回 null（这一条筛选作废），⛔ 不要塞一个猜出来的值进去：
/// 用户看到的是筛选抽屉里多了一条他没要的条件，而且不知道哪来的。
Object? _parseValue(String raw, FilterField field, FilterOperator operator) {
  if (raw.isEmpty) return null;

  if (operator == FilterOperator.RANGE) {
    final parts = raw.split('..');
    if (parts.length != 2) return null;
    final from = parts[0].trim();
    final to = parts[1].trim();
    // 两头都空等于没筛。generateFilterString 也会把这种整条丢掉。
    if (from.isEmpty && to.isEmpty) return null;
    return {'from': from, 'to': to};
  }

  if (operator == FilterOperator.IN || operator == FilterOperator.NOT_IN) {
    final items = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (items.isEmpty) return null;
    final kept = _validOptions(field, items);
    return kept.isEmpty ? null : kept;
  }

  switch (field.type) {
    case FilterFieldType.BOOLEAN:
      final lower = raw.toLowerCase();
      if (lower != 'true' && lower != 'false') return null;
      return lower;
    case FilterFieldType.NUMBER:
      return num.tryParse(raw)?.toString();
    case FilterFieldType.DATE:
      return DateTime.tryParse(raw) == null ? null : raw;
    case FilterFieldType.SELECT:
      final ok = _validOptions(field, [raw]);
      return ok.isEmpty ? null : ok.first;
    case FilterFieldType.STRING:
    case FilterFieldType.STRING_ARRAY:
      return raw;
  }
}

/// SELECT 字段只认它自己列出来的那几个值，其余丢掉。
List<String> _validOptions(FilterField field, List<String> candidates) {
  final options = field.options;
  if (options == null || options.isEmpty) return candidates;
  final allowed = options.map((o) => o.value).toSet();
  final kept = candidates.where(allowed.contains).toList();
  if (kept.length != candidates.length) {
    LogUtils.w(
      'AI 搜索给了 ${field.name} 不认识的值：'
          '${candidates.where((c) => !allowed.contains(c)).join(', ')}',
      'AiSearchQuery',
    );
  }
  return kept;
}
