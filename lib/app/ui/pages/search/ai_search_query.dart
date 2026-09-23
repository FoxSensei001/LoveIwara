import 'dart:async';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/services/tag_name_index.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';
import 'package:i_iwara/app/ui/pages/search/repositories/search_repositories.dart';
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
    this.preview,
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

  /// 模型交上来的这份表**原样**试搜过的话，那次的结果。没试过、或试的是别的
  /// 写法，就是 null。弹窗拿它说「预计约 N 条」，用户改了表之后要自己判断它
  /// 还作不作数（见 [AiSearchPreview.matches]）。
  final AiSearchPreview? preview;

  bool get isEmpty =>
      query.trim().isEmpty &&
      filters.isEmpty &&
      sort == null &&
      !segmentChanged;
}

/// 一次试搜的结果：与用户按下搜索之后**第一屏**看到的是同一份（同一个仓库、
/// 同样的多路归并与核对）。
class AiSearchPreview {
  const AiSearchPreview({
    required this.fingerprint,
    required this.total,
    required this.titles,
  });

  /// 这次试搜实际发出去的是什么（板块 + 排序 + 完整查询串）。
  final String fingerprint;

  /// 估计总数（多路归并时是并集的估计）。
  final int total;

  /// 前几条的标题。
  final List<String> titles;

  /// 表单现在的样子是不是就是试搜过的那一份。
  bool matches({
    required SearchSegment segment,
    required String keyword,
    required List<Filter> filters,
    required String? sort,
    required SearchSegment currentSegment,
    required String currentSort,
  }) =>
      fingerprint ==
      _plannedSearch(
        segment: segment,
        keyword: keyword,
        filters: filters,
        sort: sort,
        currentSegment: currentSegment,
        currentSort: currentSort,
      ).fingerprint;
}

/// 这份表在搜索结果页上**真正**会发出去的那次搜索。
///
/// ⭐ 两件事都照搜索结果页的逻辑来，一处不许自己另算：查询串走
/// [FilterConfig.composeSearchQuery]（引号、筛选的拼法），排序照
/// `search_result._openAiSearch`（换了板块又没给排序就退回新板块的默认）。
({String query, String sort, String fingerprint}) _plannedSearch({
  required SearchSegment segment,
  required String keyword,
  required List<Filter> filters,
  required String? sort,
  required SearchSegment currentSegment,
  required String currentSort,
}) {
  final query = FilterConfig.composeSearchQuery(
    keyword: keyword.trim(),
    segment: segment,
    filters: filters,
    exactMatch: _exactMatchEnabled,
  );
  final effectiveSort =
      sort ??
      (segment != currentSegment
          ? FilterConfig.getDefaultSortForSegment(segment)
          : currentSort);
  return (
    query: query,
    sort: effectiveSort,
    fingerprint: '${segment.name}|$effectiveSort|$query',
  );
}

bool get _exactMatchEnabled =>
    !Get.isRegistered<ConfigService>() ||
    Get.find<ConfigService>()[ConfigKey.SEARCH_EXACT_MATCH] != false;

bool get _tagExpansionEnabled =>
    !Get.isRegistered<ConfigService>() ||
    Get.find<ConfigService>()[ConfigKey.SEARCH_TAG_EXPANSION] != false;

/// 这个关键词在这个板块上会被认成哪些标签、自动按标签补搜。
///
/// 与搜索仓库同一个判法（[resolveQueryTags] + [TagLocalizationService.matchName]
/// + 用户的「按标签补搜」开关），弹窗拿它随着用户改关键词实时说明。
List<TagNameMatch> aiSearchRecognizedTags(
  String keyword,
  SearchSegment segment,
) {
  if (!_tagExpansionEnabled || segment == SearchSegment.oreno3d) {
    return const [];
  }
  return resolveQueryTags(
    keyword,
    apiType: segment.apiType,
    resolveTag: TagLocalizationService.matchName,
  );
}

/// 让 AI 按**整张搜索表**填一次：板块 / 关键词 / 排序 / 筛选。
///
/// ⭐ 不让模型去写 iwara 那套花括号语法（`{likes:>100}`）。`FilterConfig` 里
/// 每个板块能筛什么、每个字段是什么类型、SELECT 字段有哪几个合法值、能怎么排，
/// 本来就是现成的白名单——把它摊给模型，模型只能填表，编出来的东西在解析这一步
/// 当场作废，而不是发出去等服务端回 500。花括号仍由既有的
/// [FilterConfig.generateFilterString] 渲染，格式只有那一处说了算。
///
/// # ⭐ 与搜索增强是**一套**，不是两套（2026-09-23 重做）
///
/// 早先的试搜工具自己拼一条单路请求：不走标签补路、不走别名路、不核对，按相关度
/// 看 3 条。于是模型看到「"初音未来" 0 条」就去改写，而用户真按下搜索时标签路
/// 有 156 条——它在按一个用户永远看不到的数字做决定，还把好词改坏了。
/// 现在三件工具都落在 App 真实的那条路上：
///
/// - `preview_search` 收**与答案同形**的一张表，照搜索结果页的拼法与排序造一个
///   真仓库（[createIwaraSearchRepository]）拉第 0 页——模型看到的就是用户会看到的；
/// - `lookup_tags` 查随包的标签词库，并直说「这个词 App 会不会自动按标签补搜」；
/// - `find_user` 把作者的显示名换成 `{author:…}` 要的 @username。
///
/// 提示词因此不再重讲 App 已经在做的事（补引号、跨语言补路、引号 0 条退裸词），
/// 只讲模型真要决定的：选哪个词、哪些该变成筛选、怎么排。
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

  final session = _AiSearchSession(segment, currentSort);
  final ai = Get.find<AiService>();
  final result = await ai.structured(
    AiRequest(
      task: AiTask.searchQuery,
      input: request,
      system: _systemPrompt(segment, currentSort),
      decorateError: decorateError,
      thinkAloud: true,
      tools: [
        session.previewTool(allFields.keys.toList()),
        session.lookupTagsTool(),
        session.findUserTool(),
      ],
    ),
    schema: _schemaFor(allFields.keys.toList()),
    onProgress: onProgress,
  );

  if (!result.isSuccess || result.data == null) {
    return ApiResult.fail(result.message);
  }

  final form = _parse(result.data!, segment);
  final planned = _plannedSearch(
    segment: form.segment,
    keyword: form.query,
    filters: form.filters,
    sort: form.sort,
    currentSegment: segment,
    currentSort: currentSort,
  );
  return ApiResult.success(
    data: AiSearchQuery(
      query: form.query,
      segment: form.segment,
      segmentChanged: form.segment != segment,
      sort: form.sort,
      filters: form.filters,
      preview: session.previews[planned.fingerprint],
    ),
  );
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
      'indexes ("segments"). Pick the right segment first, then the keyword, '
      'the sort and the filters that segment actually supports.',
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
    // ⭐ 这一段只讲**模型要决定的事**。App 自己会做的（补引号、跨语言补路、
    // 按标签补路、引号 0 条退裸词）放在下一段当事实告诉它，别让它去模仿——
    // 早先两百行把这些规则教给模型，它就在答案里手工再做一遍，与 App 做的叠在
    // 一起反而坏事（例：自己加 title 筛选，被 AND 成交集）。
    ..writeln('How the Iwara engine reads "query" (measured):')
    ..writeln(
      '- Words are ANDed and the last word is prefix-matched: `miku` 7289, '
      '`miku dance` 699, `miku dance cosplay` 2. Every extra word narrows '
      'hard, so search the most distinctive term and do NOT pile on context '
      'the user did not ask for (`"甘雨"` 119, `"原神" "甘雨"` only 10).',
    )
    ..writeln(
      '- "…" is an exact phrase. Unquoted CJK is shredded into OR-ed '
      'fragments (白金ディスコ 1686 hits, only 34 real; "白金ディスコ" exactly '
      'those 34), so quote every CJK name or term, kana included. Quote Latin '
      'phrases of 2+ words; leave a single Latin word bare.',
    )
    ..writeln(
      '- ⛔ Never quote a whole phrase joined by a particle (の が を に は で '
      'と): `"原神の甘雨"` → 0. Quote the parts: `"原神" "甘雨"`. But do not '
      'split names that contain one (ときのそら, このすば, けものフレンズ).',
    )
    ..writeln(
      '- `-word` excludes (space before, attached to the word). There are NO '
      'boolean operators: AND / OR / NOT / + / ! / parentheses are plain '
      'words. Do not put `:` `/` or curly braces in "query".',
    )
    ..writeln(
      '- Free text searches titles and descriptions only — NOT tags and NOT '
      'usernames. Tags and authors are filters or tag names (see below).',
    )
    ..writeln()
    ..writeln('What the app does by itself after you answer — do not redo it:')
    ..writeln(
      '- ⭐ Tag expansion (videos and images): every word of "query" that is '
      'EXACTLY a tag name in any language is also searched as that tag, and '
      'as its Japanese / English / Chinese name, and the results are merged '
      'and checked (a result must have the name in its title or carry the '
      'tag). This is where most results come from — measured recall 17% '
      'without it, 97% with it (原神 as text alone: 17 recent videos, with the '
      'tag: 324). So put a character / series / genre in "query" by a name '
      'the app recognises; `lookup_tags` tells you which names those are.',
    )
    ..writeln(
      '- Therefore a tags FILTER is a hard constraint, not a way to reach the '
      'tag: it is ANDed into every merged search and cuts out everything '
      'untagged. Use it only when the user wants "only videos tagged X", '
      'or NOT_IN for "without X".',
    )
    ..writeln(
      '- It re-runs the keyword against the Chinese and Japanese title '
      'indexes (the engine only searches one language per query). ⛔ So never '
      'add a title/body filter just to reach another language — it would be '
      'ANDed and CUT results (409 ∩ 307 = 38).',
    )
    ..writeln(
      '- It auto-quotes CJK words without hiragana, and if a quoted phrase '
      'returns nothing it retries unquoted. You do not need to pre-emptively '
      'drop quotes.',
    )
    ..writeln()
    ..writeln('Filters and sort:')
    ..writeln(
      '- ⭐ "popular" / "most viewed" / "trending" / "newest" is a SORT, not '
      'an invented threshold like views >= 10000 — a made-up number silently '
      'throws away everything below it.',
    )
    ..writeln(
      '- "author" is the exact @username (case-insensitive); display names '
      'and fragments match nothing. When the user names an author, call '
      '`find_user` and use the username it returns. IN on author is OR '
      '(several authors), NOT_IN excludes.',
    )
    ..writeln(
      '- IN on one filter is OR; two filters on the same field are AND.',
    )
    ..writeln(
      '- "rating": ~88% of the catalogue is ecchi, so only set it when the '
      'user explicitly asks for SFW / NSFW. ⛔ "duration" is recorded for '
      'only 55% of videos — any duration filter silently drops the other '
      '45%; use it only when the request really is about length.',
    )
    ..writeln(
      '- title / body / name filters need "locale": en for Latin, ja for '
      'anything with kana or Japanese kanji, zh only for Chinese-only text '
      '(崩坏, 发). Use them only when the user asks to constrain on title or '
      'description.',
    )
    ..writeln()
    ..writeln('How to work:')
    ..writeln(
      '1. For every character / series / genre / theme in the request, call '
      '`lookup_tags` (all terms in one call). Prefer a name with '
      '"app_auto_expands": true; if the user\'s word has none, a listed '
      'similar tag\'s name may be the right term. Never invent a slug.',
    )
    ..writeln('2. If an author is named, call `find_user`.')
    ..writeln(
      '3. Call `preview_search` with your full candidate answer. It runs '
      'EXACTLY the search the user will get (same merging, same checks) and '
      'returns the estimated total, how many each route contributed, which '
      'tags were expanded, and the first titles. Judge the TITLES: are they '
      'what the user asked for? 0 results or off-topic titles → adjust and '
      'preview again. Tens of thousands for a specific request → too loose. '
      'Answer with a version you previewed.',
    )
    ..writeln()
    ..writeln('Answer fields:')
    ..writeln(
      '- "segment": keep "${current.name}" unless the request clearly points '
      'at another index.',
    )
    ..writeln(
      '- "sort": a sort value of the segment you picked, or omit it to leave '
      'the user\'s current sort alone.',
    )
    ..writeln(
      '- "query": quoted phrases, bare words and `-word` exclusions only. '
      'Strip anything you expressed as segment, sort or filter; "" when the '
      'request is purely about those.',
    )
    ..writeln(
      '- "filters": only fields listed under the segment you picked. Omit '
      'it when nothing maps cleanly — fold the rest into "query" instead of '
      'inventing a field.',
    )
    ..writeln()
    ..writeln('Value formats (the "value" field is always a string):')
    ..writeln('- RANGE: "from..to". One side may be empty: "100.." or "..100".')
    ..writeln('- IN / NOT_IN: comma-separated, e.g. "a,b,c".')
    ..writeln('- DATE: ISO date, "2026-01-31".')
    ..writeln('- BOOLEAN: "true" or "false".')
    ..writeln()
    // 思考过程要给用户看，用他的界面语言写；原生推理管不了，正文那几句管得了。
    ..writeln(
      'Write your explanation sentences in the language with BCP-47 tag '
      '"${slang.LocaleSettings.currentLocale.languageTag}".',
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
        'looks thin. It cannot be previewed.',
  SearchSegment.forum => 'Forum threads (titles only are searchable).',
  SearchSegment.forum_posts => 'Individual forum replies, not whole threads.',
  SearchSegment.post => 'Blog-style posts written by users.',
  SearchSegment.playlist => 'User-made video playlists.',
  _ => null,
};

/// 答案的 `properties`，试搜工具的入参原样复用它——模型试搜的与交上来的是
/// 同一种东西，不必学两套。
Map<String, dynamic> _formProperties(List<String> fieldNames) => {
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
};

/// ⛔ 用 `Schema.fromMap` 手写这张表，不用 `json_schema_builder` 的
/// `ObjectSchema` / `StringSchema` 那套 builder：dartantic 只 re-export 了
/// `S` 和 `Schema` 两个名字，那些 builder 要额外把 `json_schema_builder` 加成
/// 直接依赖，为几行 schema 不值当。这张表还会被原样 `jsonEncode` 进提示词
/// （见 `AiService._jsonContractPrompt`），写成什么样模型就看到什么样。
Schema _schemaFor(List<String> fieldNames) => Schema.fromMap({
  'type': 'object',
  'properties': _formProperties(fieldNames),
  'required': ['query'],
});

// ─────────────────────────────────────────────────────────────────────────
// 工具
// ─────────────────────────────────────────────────────────────────────────

/// 试搜最多几次、查标签最多几次、查作者最多几次。
///
/// ⛔ 必须有上限，而且要**在工具里硬拦**，不能只写在提示词里：一次试搜是一次
/// 真实的多路搜索 + 一整轮对话，模型钻进「再查一次说不定更好」的循环时，用户
/// 看到的是弹窗转了一分钟。
const int _maxPreviewCalls = 4;
const int _maxLookupCalls = 3;
const int _maxFindUserCalls = 2;

/// 试搜拉第 0 页拉多少条、回给模型看前几条。
const int _previewPageSize = 20;
const int _previewTitleCount = 8;

/// 一次试搜最多等多久。多路归并首屏实测约 1.5s，冷连接会更久。
const Duration _previewTimeout = Duration(seconds: 25);

/// 一次 AI 搜索里几件工具共用的状态：次数、以及试搜过的结果（最后拿去对答案）。
class _AiSearchSession {
  _AiSearchSession(this.current, this.currentSort);

  final SearchSegment current;
  final String currentSort;

  int _previewsUsed = 0;
  int _lookupsUsed = 0;
  int _userLookupsUsed = 0;

  /// 指纹（见 [_plannedSearch]）→ 那次试搜的结果。
  final Map<String, AiSearchPreview> previews = {};

  /// ⭐ 让模型能**真的搜一下**再回答——而且搜的就是用户会搜的那一次。
  ///
  /// ⛔ 入参是**与答案同形**的一张表，不接花括号原文：整份提示词都刻意没教它
  /// 那套语法，在这儿开个后门等于让它现学一套没人校验的东西。
  ///
  /// ⛔ 出错一律**回成一条结果**而不是抛出去：抛出去会把整轮对话打断，用户只
  /// 拿到一句网络错误；回给它看，它自己会换个写法。
  AiTool previewTool(List<String> fieldNames) => AiTool(
    tool: Tool<Map<String, dynamic>>(
      name: 'preview_search',
      description:
          'Run your candidate answer as the real search the user will get: '
          'same query assembly, same automatic tag expansion and merging, '
          'same sort. Takes exactly the same fields as your answer. Returns '
          'the estimated total, how many results each route contributed '
          '(main = your words as typed, tags = expanded tag, alias = the name '
          'in another language, title = another language\'s title index), '
          'the expanded tags, the first titles, and notes about anything in '
          'your form that was dropped or changed. oreno3d cannot be '
          'previewed. At most $_maxPreviewCalls calls.',
      inputSchema: Schema.fromMap({
        'type': 'object',
        'properties': _formProperties(fieldNames),
        'required': ['query'],
      }),
      onCall: (args) async {
        if (_previewsUsed >= _maxPreviewCalls) {
          return {
            'error':
                'preview limit of $_maxPreviewCalls reached — answer with '
                'what you have.',
          };
        }
        _previewsUsed++;
        return _runPreview(args);
      },
    ),
    describeCall: (args) {
      final query = (args['query'] as String?)?.trim() ?? '';
      final filters = (args['filters'] as List?)?.length ?? 0;
      final parts = [
        if (query.isNotEmpty) query,
        if (filters > 0) slang.t.ai.searchToolFilterCount(count: filters),
      ];
      return slang.t.ai.searchToolProbing(
        query: parts.isEmpty ? '…' : parts.join(' + '),
      );
    },
    describeResult: (result) {
      if (result is! Map) return slang.t.ai.searchToolFailed(reason: '$result');
      final error = result['error'];
      if (error != null) return slang.t.ai.searchToolFailed(reason: '$error');
      final titles =
          (result['first_results'] as List?)?.cast<String>().take(3) ??
          const <String>[];
      final tags = (result['expanded_tags'] as List?)?.cast<String>() ?? [];
      final found = slang.t.ai.searchToolFound(
        count: result['estimated_total'] as int? ?? 0,
        titles: titles.join(' / '),
      );
      return tags.isEmpty
          ? found
          : '${slang.t.ai.searchToolExpanded(tags: tags.map((t) => '#$t').join(' '))} · $found';
    },
  );

  Future<Map<String, dynamic>> _runPreview(Map<String, dynamic> args) async {
    final notes = <String>[];
    final form = _parse(args, current, notes: notes);
    if (form.segment == SearchSegment.oreno3d) {
      return {'error': 'oreno3d cannot be previewed — answer directly.'};
    }
    final planned = _plannedSearch(
      segment: form.segment,
      keyword: form.query,
      filters: form.filters,
      sort: form.sort,
      currentSegment: current,
      currentSort: currentSort,
    );
    final repo = createIwaraSearchRepository(
      form.segment,
      query: planned.query,
      sort: planned.sort,
    );
    if (repo == null) return {'error': 'segment cannot be previewed'};

    try {
      final response = await repo
          .fetchDataFromSource(
            repo.buildQueryParams(0, _previewPageSize),
            0,
            _previewPageSize,
          )
          .timeout(_previewTimeout);
      final items = repo.extractDataList(response);
      final total = repo.extractTotalCount(response);
      final titles = <String>[
        for (final item in items)
          if (_clip(repo.previewTitle(item)) case final title
              when title.isNotEmpty)
            title,
      ].take(_previewTitleCount).toList();
      final tags = [
        for (final match in repo.plan.tags)
          TagLocalizationService.displayName(match.slugs.first),
      ];

      previews[planned.fingerprint] = AiSearchPreview(
        fingerprint: planned.fingerprint,
        total: total,
        titles: titles,
      );

      return {
        'sent_query': planned.query,
        'sort': planned.sort,
        'estimated_total': total,
        if (repo.isMerging)
          'routes': [
            for (final r in repo.routeStats)
              {'kind': r.kind.name, 'query': r.query, 'count': r.count},
          ],
        if (tags.isNotEmpty) 'expanded_tags': tags,
        'first_results': titles,
        if (notes.isNotEmpty) 'notes': notes,
      };
    } catch (e) {
      LogUtils.w('AI 搜索试搜失败：$e', 'AiSearchQuery');
      return {'error': '$e'};
    } finally {
      repo.dispose();
    }
  }

  /// ⭐ 查随包的标签词库——与「按标签补搜」用的是同一个判法，所以它说「会自动
  /// 补搜」就真的会。
  AiTool lookupTagsTool() => AiTool(
    tool: Tool<Map<String, dynamic>>(
      name: 'lookup_tags',
      description:
          'Look terms up in the Iwara tag dictionary the app ships with. For '
          'each term: whether it is EXACTLY a tag name (then '
          '"app_auto_expands" says the app will search that tag for you when '
          'the term is in "query" on videos/images), the real slugs, the '
          'tag\'s names in other languages, and similar tags when there is no '
          'exact match. Put all terms in one call. At most $_maxLookupCalls '
          'calls.',
      inputSchema: Schema.fromMap({
        'type': 'object',
        'properties': {
          'terms': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': 'Names to look up, in any language.',
          },
        },
        'required': ['terms'],
      }),
      onCall: (args) async {
        if (_lookupsUsed >= _maxLookupCalls) {
          return {'error': 'lookup limit reached — answer with what you have.'};
        }
        _lookupsUsed++;
        return {
          'results': [for (final term in _terms(args)) _describeTerm(term)],
        };
      },
    ),
    describeCall: (args) =>
        slang.t.ai.searchToolLookupTags(terms: _terms(args).join(', ')),
    describeResult: (result) {
      if (result is! Map || result['results'] is! List) {
        return slang.t.ai.searchToolFailed(
          reason: '${result is Map ? result['error'] : result}',
        );
      }
      return [
        for (final r in (result['results'] as List).whereType<Map>())
          r['slugs'] is List
              ? '${r['term']} → #${TagLocalizationService.displayName((r['slugs'] as List).first as String)}'
              : '${r['term']} → ${slang.t.ai.searchToolTagMissing}',
      ].join(' · ');
    },
  );

  static List<String> _terms(Map<String, dynamic> args) =>
      ((args['terms'] as List?) ?? const [])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .take(12)
          .toList();

  Map<String, dynamic> _describeTerm(String term) {
    final exact = TagLocalizationService.matchName(term);
    final similar = [
      for (final tag in TagLocalizationService.search(term, limit: 8))
        if (exact == null || !exact.slugs.contains(tag.id))
          {'slug': tag.id, 'name': TagLocalizationService.displayName(tag.id)},
    ].take(6).toList();
    return {
      'term': term,
      if (exact != null) ...{
        'slugs': exact.slugs,
        'names': exact.aliases,
        'app_auto_expands': _tagExpansionEnabled,
      },
      if (exact == null) 'exact_tag': false,
      if (similar.isNotEmpty) 'similar_tags': similar,
    };
  }

  /// 作者的显示名 → `{author:…}` 要的 @username。
  AiTool findUserTool() => AiTool(
    tool: Tool<Map<String, dynamic>>(
      name: 'find_user',
      description:
          'Find Iwara users by display name or handle and get their exact '
          '@username (what the "author" filter needs). At most '
          '$_maxFindUserCalls calls.',
      inputSchema: Schema.fromMap({
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name as the user wrote it.',
          },
        },
        'required': ['name'],
      }),
      onCall: (args) async {
        if (_userLookupsUsed >= _maxFindUserCalls) {
          return {'error': 'find_user limit reached.'};
        }
        _userLookupsUsed++;
        return _findUser((args['name'] as String?)?.trim() ?? '');
      },
    ),
    describeCall: (args) =>
        slang.t.ai.searchToolFindUser(name: '${args['name'] ?? '…'}'),
    describeResult: (result) {
      if (result is! Map || result['users'] is! List) {
        return slang.t.ai.searchToolFailed(
          reason: '${result is Map ? result['error'] : result}',
        );
      }
      final users = (result['users'] as List).whereType<Map>().toList();
      return slang.t.ai.searchToolUsersFound(
        count: users.length,
        users: users.take(3).map((u) => '@${u['username']}').join(' / '),
      );
    },
  );

  Future<Map<String, dynamic>> _findUser(String name) async {
    if (name.isEmpty) return {'error': 'empty name'};
    final api = Get.find<ApiService>();
    final queries = <String>[
      autoQuoteKeyword(name),
      // 像个 handle 就再精确查一次用户名：自由文本搜的是显示名与简介。
      if (RegExp(r'^[A-Za-z0-9_.\-]+$').hasMatch(name)) '{username:$name}',
    ];
    final users = <String, Map<String, String>>{};
    try {
      for (final query in queries) {
        final response = await api.get(
          '/search',
          queryParameters: {
            'query': query,
            'type': SearchSegment.user.apiType,
            'page': 0,
            'limit': 6,
            'sort': 'relevance',
          },
        );
        final results = (response.data is Map)
            ? (response.data['results'] as List?) ?? const []
            : const [];
        for (final item in results.whereType<Map>()) {
          final username = '${item['username'] ?? ''}';
          if (username.isEmpty) continue;
          users[username.toLowerCase()] ??= {
            'username': username,
            'name': '${item['name'] ?? ''}',
          };
        }
      }
    } catch (e) {
      LogUtils.w('AI 搜索查作者失败：$e', 'AiSearchQuery');
      if (users.isEmpty) return {'error': '$e'};
    }
    return {'users': users.values.take(6).toList()};
  }
}

String _clip(String text) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return flat.length <= 80 ? flat : '${flat.substring(0, 80)}…';
}

// ─────────────────────────────────────────────────────────────────────────
// 解析
// ─────────────────────────────────────────────────────────────────────────

/// 一张解析、校验过的表。
typedef _Form = ({
  SearchSegment segment,
  String query,
  String? sort,
  List<Filter> filters,
});

/// [notes] 收集「表里哪些东西被丢掉或改掉了」（英文，回给模型看）：试搜时它得
/// 知道自己写的标签不存在、字段不属于这个板块，否则会拿着一张被悄悄改过的表
/// 去解读结果。
_Form _parse(
  Map<String, dynamic> raw,
  SearchSegment current, {
  List<String>? notes,
}) {
  final segment = _parseSegment(raw['segment'], current, notes);
  final fields = FilterConfig.getContentType(segment)?.fields ?? const [];

  var query = (raw['query'] as String?)?.trim() ?? '';
  final filters = <Filter>[];
  // 解析不掉的标签落回关键词，见 _resolveTags。
  final leftovers = <String>[];

  final rawFilters = raw['filters'];
  if (rawFilters is List) {
    for (final item in rawFilters) {
      if (item is! Map) continue;
      final filter = _toFilter(
        item.cast<String, dynamic>(),
        fields,
        leftovers,
        notes,
      );
      if (filter != null) filters.add(filter);
    }
  }

  for (final word in leftovers) {
    if (query.toLowerCase().contains(word.toLowerCase())) continue;
    query = query.isEmpty ? word : '$query $word';
  }

  // ⛔ oreno3d 是另一个站的搜索，不吃 iwara 的引号/减号语法。
  if (segment != SearchSegment.oreno3d) query = autoQuoteKeyword(query);

  return (
    segment: segment,
    query: query,
    sort: _parseSort(raw['sort'], segment, notes),
    filters: filters,
  );
}

/// 认不出就留在用户当前的板块。⛔ 不要猜一个——把人送去别的索引，比少换一次
/// 板块难收拾得多。
SearchSegment _parseSegment(
  Object? raw,
  SearchSegment fallback,
  List<String>? notes,
) {
  final name = (raw as String?)?.trim();
  if (name == null || name.isEmpty) return fallback;
  final seg = SearchSegment.values.firstWhereOrNull((s) => s.name == name);
  if (seg == null) {
    LogUtils.w('AI 搜索给了不存在的板块：$name', 'AiSearchQuery');
    notes?.add('unknown segment "$name" — kept "${fallback.name}"');
    return fallback;
  }
  return seg;
}

/// 排序值必须是**它选的那个板块**的合法值。oreno3d 的 `hot` 放到视频板块上
/// 是一条服务端不认识的参数，搜出来是空的。
String? _parseSort(Object? raw, SearchSegment segment, List<String>? notes) {
  final value = (raw as String?)?.trim();
  if (value == null || value.isEmpty) return null;
  final allowed = FilterConfig.getSortOptionsForSegment(
    segment,
  ).map((o) => o.value);
  if (!allowed.contains(value)) {
    LogUtils.w('AI 搜索给了 ${segment.name} 不支持的排序：$value', 'AiSearchQuery');
    notes?.add('sort "$value" is not valid for ${segment.name} — ignored');
    return null;
  }
  return value;
}

Filter? _toFilter(
  Map<String, dynamic> raw,
  List<FilterField> fields,
  List<String> leftovers,
  List<String>? notes,
) {
  final fieldName = (raw['field'] as String?)?.trim();
  if (fieldName == null || fieldName.isEmpty) return null;

  // ⛔ 白名单在这里兜底，不能只靠 schema 的 enum：一来 enum 是**所有板块的
  // 并集**（板块由模型现选，schema 定不下来），二来走「提示词契约」那条降级路
  // 时没有任何东西强制模型遵守 enum（见 AiService.structured 的两条路）。
  final field = fields.firstWhereOrNull((f) => f.name == fieldName);
  if (field == null) {
    LogUtils.w('AI 搜索给了本板块没有的字段：$fieldName', 'AiSearchQuery');
    notes?.add('filter field "$fieldName" does not exist here — dropped');
    return null;
  }

  final operator = FilterOperator.values.firstWhereOrNull(
    (o) => o.name == (raw['operator'] as String?)?.trim(),
  );
  if (operator == null) {
    notes?.add('filter on "$fieldName" has an unknown operator — dropped');
    return null;
  }

  // ⛔ 运算符也要按字段类型验：筛选抽屉里每个字段只给得出
  // [FilterConfig.getOperatorsForType] 那几个，模型却看得见全部。
  // 放一条 `CONTAINS` 到 NUMBER 字段上，抽屉里那一行会落进编辑器画不出来的
  // 状态，花括号也拼不成。
  if (!FilterConfig.getOperatorsForType(field.type).contains(operator)) {
    LogUtils.w(
      'AI 搜索把 ${operator.name} 用在了 ${field.name}（${field.type.name}）上',
      'AiSearchQuery',
    );
    notes?.add('${operator.name} is not allowed on "$fieldName" — dropped');
    return null;
  }

  var value = _parseValue(
    (raw['value'] ?? '').toString().trim(),
    field,
    operator,
  );
  if (value == null) {
    notes?.add('value "${raw['value']}" for "$fieldName" is invalid — dropped');
    return null;
  }

  if (field.name == 'tags' && value is List<String>) {
    value = _resolveTags(value, leftovers, notes);
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
  r'㐀-䶿一-鿿豈-﫿]',
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
List<String> _resolveTags(
  List<String> raw,
  List<String> leftovers,
  List<String>? notes,
) {
  final out = <String>[];
  for (final item in raw) {
    final resolved = _resolveTag(item);
    if (resolved.isEmpty) {
      LogUtils.w('AI 搜索给了词库里没有的标签：$item，退回关键词', 'AiSearchQuery');
      notes?.add('tag "$item" is not in the dictionary — moved into query');
      leftovers.add(item);
      continue;
    }
    for (final slug in resolved) {
      if (!out.contains(slug)) out.add(slug);
    }
  }
  return out;
}

/// 只认**精确**命中：先问「按标签补搜」用的那个名字索引（四种语言的名字都认；
/// 同名的一组标签全要，`巨乳` 是五个 slug），再按 id / 当前语言译名比（忽略大小写
/// 与下划线/空格之差）。认不出返回空表。
///
/// ⛔ 不要拿 [TagLocalizationService.search] 的第一条凑数：那是个带 contains 的
/// 模糊搜索，「dance」会命中一堆无关标签，换进筛选条件里就是一条用户没要、
/// 也看不懂哪来的硬条件。
List<String> _resolveTag(String raw) {
  final byName = TagLocalizationService.matchName(raw);
  if (byName != null && byName.slugs.isNotEmpty) return byName.slugs;

  final needle = _normalizeTag(raw);
  if (needle.isEmpty) return const [];

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
      if (_normalizeTag(tag.id) == needle) return [tag.id];
      if (_normalizeTag(TagLocalizationService.displayName(tag.id)) == needle) {
        return [tag.id];
      }
    }
  }
  return const [];
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
