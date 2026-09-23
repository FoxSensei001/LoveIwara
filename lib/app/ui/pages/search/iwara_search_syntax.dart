/// iwara 搜索框那串字**到了服务端会被怎么理解**，以及我们据此做的加工。
///
/// ⭐ 单独一个文件，是因为这件事既不归 AI 搜索也不归结果页：两条路发出去的是
/// 同一个 `query` 参数，规则只能有一处说了算。
///
/// # 实测（2026-09-21，对着 api.iwara.tv 逐条量的）
///
/// - 词与词之间是 **AND**，最后一个词按**前缀**匹配：
///   `miku` 7289、`dance` 14967，而 `miku dance` 只有 699。
/// - ⭐⭐ **引号＝短语精确匹配**，这是「iwara 搜不准」最要紧的一条。不加引号的
///   CJK **不走 AND**，而是被拆成片段做 OR：`白金ディスコ` 召回 1686 条，其中真
///   含这个词的只有 34 条；`"白金ディスコ"` 正好就是那 34 条。
/// - 排序只重排召回集、从不收窄它。所以裸的 CJK 关键词一旦换成按时间/播放排序，
///   第一页就与关键词毫无关系——实测 `初音ミク` 按时间排，前 20 条只有 3 条真
///   相关；加了引号是 20 条。
/// - `-词` 是排除（减号要贴着词、前面是空格；词内连字符不算，`R-18` 等同 `R18`）。
/// - ⛔ **没有布尔运算符**：`AND` / `OR` / `NOT` / `+` / `!` / 括号 / `#` 全都
///   会被当普通字符或直接丢掉。
/// - ⛔ `""`（空引号）匹配 0 条；引号落单时引擎把引号整个忽略。
///
/// 完整清单见提交说明与 `ai_search_query.dart` 里给模型的那段提示词。
library;

import 'package:i_iwara/app/services/tag_name_index.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 任何 CJK 字符（含平假名）。
final RegExp _anyCjk = RegExp(r'[々぀-ヿㇰ-ㇿｦ-ﾟ㐀-䶿一-鿿豈-﫿가-힯]');

/// 一段**不含平假名**的汉字 / 片假名 / 谚文，也就是「一个词」而不是「一句话」。
/// `々` `ー` `・` 这些词内符号算进来。
final RegExp _termRun = RegExp(
  r'^[々㐀-䶿一-鿿豈-﫿'
  r'゠-ヿㇰ-ㇿｦ-ﾟ가-힯]{2,}$',
);

/// 这个关键词会不会被引擎**拆碎了松散匹配**。
///
/// 拉丁词不在此列——它们本来就是 AND，按时间排也是干净的。
bool keywordMatchesLoosely(String query) {
  final text = query.trim();
  if (text.isEmpty || text.contains('"')) return false;
  return _anyCjk.hasMatch(text);
}

/// 把**确定是一个词**的 CJK 片段加上引号。
///
/// ⛔ **只在稳赢的情形下动手**。试过一版「按平假名切开再逐段加引号」，结果更糟：
/// 切碎之后每一段都是 AND，收窄是乘起来的（`原神の甘雨` 138 → `"原神" "甘雨"`
/// 10 → `"白金ディスコ" "踊"` 2），汉字假名混写的专名还会被拦腰斩断
/// （`"艦これ" "大和"` 140 → `"艦" "大和"` 3），而夹着平假名的整句加引号直接
/// 0 条（`"原神の甘雨"`、`"初音ミクのダンス"` 都是 0）。
///
/// 离线切不动日语，就别切：只给「整段没有平假名」的词加引号，其余原样放行。
/// 于是 `初音ミク` → `"初音ミク"`，而 `原神の甘雨` / `ふたなり` / `miku dance`
/// 一个字都不动。
String autoQuoteKeyword(String query) {
  var text = query.trim();
  if (text.isEmpty) return text;

  // 引号落单时引擎会把引号整个忽略，静默退回裸词那个坏模式。剥干净再按下面的
  // 规则重来，比留着一个不起作用的引号强。
  if ('"'.allMatches(text).length.isOdd) {
    text = text.replaceAll('"', ' ').trim();
  }
  // 已经有成对引号了就别插手：哪几个字是一个短语，写的人比这条正则清楚。
  if (text.contains('"')) return text;

  final out = <String>[];
  for (final token in text.split(RegExp(r'\s+'))) {
    if (token.isEmpty) continue;
    // `-词` 是排除。整段是个词才敢引（`-"MMD"` 实测与 `-MMD` 等价）。
    final negated = token.length > 1 && token.startsWith('-');
    final body = negated ? token.substring(1) : token;
    out.add(_termRun.hasMatch(body) ? '${negated ? '-' : ''}"$body"' : token);
  }

  final quoted = out.join(' ');
  if (quoted != text) {
    LogUtils.d('搜索词补引号：$text → $quoted', 'IwaraSearchSyntax');
  }
  return quoted;
}

/// [autoQuoteKeyword] 会不会真的改动这串字。界面据此决定要不要摆出那枚
/// 「精确匹配」胶囊——没改动就没什么可说的。
bool willAutoQuote(String query) {
  final text = query.trim();
  return text.isNotEmpty && autoQuoteKeyword(text) != text;
}

// ─────────────────────────────────────────────────────────────────────────
// 跨语言补路
// ─────────────────────────────────────────────────────────────────────────

/// 一条完整查询串的两半：自由文本，和花括号筛选。
class QueryParts {
  const QueryParts({required this.text, required this.filters});

  /// 自由文本部分（发给引擎的关键词）。
  final String text;

  /// 原样保留的 `{...}` 筛选串，多个之间以空格分隔。
  final String filters;
}

/// 把 `初音ミク {date>=123} {tags:[a]}` 拆成关键词与筛选两半。
///
/// 引擎里这两者是 AND，但我们改写关键词时必须绕开筛选——筛选串里全是花括号，
/// 混进来会被当成待加工的词。
QueryParts splitQueryParts(String query) {
  final text = StringBuffer();
  final filters = StringBuffer();
  var depth = 0;
  for (final rune in query.runes) {
    final ch = String.fromCharCode(rune);
    if (ch == '{') {
      depth++;
      filters.write(ch);
    } else if (ch == '}') {
      if (depth > 0) depth--;
      filters.write(ch);
      if (depth == 0) filters.write(' ');
    } else {
      (depth > 0 ? filters : text).write(ch);
    }
  }
  return QueryParts(
    text: text.toString().trim().replaceAll(RegExp(r'\s+'), ' '),
    filters: filters.toString().trim().replaceAll(RegExp(r'\s+'), ' '),
  );
}

/// 把自由文本里的引号全部摘掉、筛选原样保留；本来就没引号时返回 null。
///
/// 给「引号搜出 0 条」时退一步用。⛔ 引号并不总是更准：`"萝莉"` 引号自由文本
/// **0 条**，裸词 `萝莉` 9 条条条相关（2026-09-23 实测）。相关度排序与分页模式
/// 下没有跨语言补路兜着，不退这一步用户就只看到一个空列表。
String? looseQueryOf(String query) {
  final parts = splitQueryParts(query);
  if (!parts.text.contains('"')) return null;
  final text = parts.text
      // 多词的排除短语没有裸词写法（`-"MMD model"` 摘了引号只排除 MMD、还把
      // model 变成必含），宁可丢掉这条排除。
      .replaceAll(RegExp(r'(^|\s)-"[^"]*\s[^"]*"'), ' ')
      // `-"MMD"` 要退成 `-MMD`：减号与词之间空一格就不再是排除了。
      .replaceAll('-"', '-')
      .replaceAll('"', ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  if (text.isEmpty) return null;
  return [text, parts.filters].where((s) => s.isNotEmpty).join(' ');
}

/// 每个分段用哪个**本地化文本字段**补路。null ＝这个分段不补。
///
/// ⛔ 各分段的字段表并不一样（2026-09-21 逐个探过）：videos/images/posts/
/// forum_threads/playlists 有 `title_*`，users 是 `name_*`，forum_posts 只有
/// `body_*`，oreno3d 是另一个站、根本不吃这套语法。
String? crossLanguageFieldFor(String apiType) => switch (apiType) {
  'videos' || 'images' || 'posts' || 'forum_threads' || 'playlists' => 'title',
  'users' => 'name',
  'forum_posts' => 'body',
  _ => null,
};

/// 标题补路还要另外补哪几种语言（引擎自己挑的那一路之外）。
const List<String> crossLanguageLocales = ['zh', 'ja'];

// ─────────────────────────────────────────────────────────────────────────
// 搜索规划：一个关键词要往哪几路发
// ─────────────────────────────────────────────────────────────────────────

/// 一路搜索是什么来头。
enum SearchRouteKind {
  /// 用户的原话（补过引号、筛选挪到了文本后面）。永远是第一路。
  main,

  /// 认出的词换成标签筛选：`{tags:[hatsune_miku]}`。
  tags,

  /// 认出的词换成它在另一种语言里的名字：`"初音ミク"`、`"Hatsune Miku"`。
  alias,

  /// 原话搬进某语言的标题字段：`{title_zh:"碧蓝航线"}`。
  title,
}

/// 一路搜索：发给引擎的完整查询串，以及它的结果要不要回头核对。
class SearchRoute {
  const SearchRoute({
    required this.query,
    required this.kind,
    this.verifyNames = const [],
    this.verifySlugs = const [],
  });

  /// 发给引擎的完整查询串（自由文本在前、花括号在后）。
  final String query;

  final SearchRouteKind kind;

  /// 非空 ＝ 这一路的结果**不能直接信**：每一组里至少一个名字要出现在标题里
  /// （或挂着 [verifySlugs] 里对应那组标签），才算真是用户搜的那个东西。
  /// 见 [accepts]，以及 [SearchRepository] 的核对逻辑与 [_unreliableLocales]。
  final List<List<String>> verifyNames;

  /// 与 [verifyNames] 一一对应：那组名字是哪些标签的名字。空 ＝ 只看标题。
  final List<List<String>> verifySlugs;

  bool get needsVerify => verifyNames.isNotEmpty;

  /// 一页里过半是冒牌货时能不能整路放弃。主路是用户的原话，只逐条筛、永不整路放弃。
  bool get droppable => kind != SearchRouteKind.main;

  /// 这条结果是不是真的是那个东西：每一组名字要么有一个出现在标题里，要么
  /// 作品挂着那组对应的标签。
  ///
  /// ⛔ **简介不算**。引擎的自由文本也搜简介，而简介里提到一个名字多半是在
  /// 列清单：「下期预告：1. 布洛妮娅 2. 藿藿 (Huohuo) 3. …」——搜 `藿藿` 首页冒出
  /// 赛马娘就是这么来的，而且**来自原话那一路**（iwara 网页端搜出来也一样，
  /// 2026-09-23 真机）。实测名字路结果里 13% 是「只有简介提到、也没挂标签」，
  /// 抽样几乎全是无关的。
  bool accepts(String? title, [Iterable<String> tagIds = const []]) {
    final text = foldSearchText(title ?? '');
    final tags = tagIds.toSet();
    for (var i = 0; i < verifyNames.length; i++) {
      if (verifyNames[i].any((n) => text.contains(foldSearchText(n)))) continue;
      final slugs = i < verifySlugs.length ? verifySlugs[i] : const <String>[];
      if (slugs.any(tags.contains)) continue;
      return false;
    }
    return true;
  }
}

/// 一次搜索的全部路数，以及认出了哪些标签（给界面说明「为什么搜到这条」）。
class SearchPlan {
  const SearchPlan({required this.routes, required this.tags});

  /// 第一路永远是 [SearchRouteKind.main]。
  final List<SearchRoute> routes;

  /// 用户的词里认出的标签（不含被 `-` 排除的那些）。
  final List<TagNameMatch> tags;

  SearchRoute get main => routes.first;
}

/// 查一串字是不是标签名。生产环境是 `TagLocalizationService.matchName`。
typedef TagNameResolver = TagNameMatch? Function(String text);

/// 哪些分段有 `tags` 字段（2026-09-21 逐个探过，其余分段没有）。
bool segmentHasTags(String apiType) =>
    apiType == 'videos' || apiType == 'images';

/// 一个关键词要往哪几路发。第一路是用户原话，其余是补路；由调用方并发拉取、
/// 按排序键归并去重（见 [SearchRepository]）。
///
/// # ⭐ 为什么要按标签补路（2026-09-23，35 个真实查询 × 近 30 天全量评测）
///
/// iwara 的自由文本**只搜标题与简介、不搜标签**，而标题写成什么全凭上传者：
/// 日文、英文、角色名、梗。于是「用户说的那个东西」大部分根本不在标题里：
///
/// | 路数 | 召回 | 准确 |
/// |---|---|---|
/// | 原话（引号短语） | 11% | 100% |
/// | 原话 + 标题 zh/ja 补路（此前的做法） | 17% | 100% |
/// | 标签 `{tags:[slug]}` | 73% | 100% |
/// | 标签 + 原话 + 日文名 + 英文名 | 95% | 100% |
/// | 再加标题 zh/ja 补路 | 97% | 100% |
///
/// 例：近 30 天 `原神` 文本 17 条，`{tags:[genshin_impact]}` 324 条；`初音未来`
/// 文本 0 条，标签 156 条，日文名 `"初音ミク"` 又补回十来条只写了日文标题的。
///
/// # 规则
///
/// - 只在词**精确**等于某个标签的名字（四种语言任一，见 [TagNameIndex]）时
///   才补；认不出的词原样留在每一路里。连续几个词可以合起来认
///   （`hatsune miku` → hatsune_miku）。
/// - 标签路：认出的词换成 `{tags:[..]}`，其余词原样保留（与标签 AND）。
/// - 名字路：认出的词换成日/英/中文名的引号短语。结果要核对标题或简介
///   真含那个名字——名字是词库里的译名，偶尔会撞上别的东西。
/// - `-词` 若是标签名，额外给**每一路**加 `{tags!=[..]}`（实测排除有效）。
/// - ⛔ 花括号**必须**在自由文本后面：`{tags:[hatsune_miku]} "水着"` 返回 6483
///   条＝整个标签，文本被静默丢掉；`"水着" {tags:[hatsune_miku]}` 才是交集。
///   所以每一路都经 [composeQuery] 重新拼，用户手敲的顺序也一并纠正。
///
/// [resolveTag] 为 null（开关关掉、词库没就绪、分段没有标签）时不补标签与名字路，
/// 只剩原话与标题补路——也就是此前的行为。
SearchPlan planSearchRoutes(
  String query, {
  required String apiType,
  TagNameResolver? resolveTag,
}) {
  final parts = splitQueryParts(query);
  final tokens = _tokenize(parts.text);
  final resolver = segmentHasTags(apiType) ? resolveTag : null;

  final spans = resolver == null
      ? const <_Span>[]
      : _resolveSpans(tokens, resolver);
  final exclusions = <String>[
    if (resolver != null)
      for (final t in tokens)
        if (t.negated)
          if (resolver(t.text) case final m?) '{tags!=[${m.slugs.join(',')}]}',
  ];
  final filters = [
    parts.filters,
    ...exclusions,
  ].where((s) => s.isNotEmpty).join(' ');

  // ⭐ 认出了标签，就知道用户说的是「那个东西」：凡是文本路（原话、名字路），
  // 结果都得标题里写着它（任一语言的名字）或挂着它的标签才留下，简介里顺嘴
  // 提一句的不算（理由见 [SearchRoute.accepts]）。认不出的词不核对。
  final names = [
    for (final s in spans)
      {s.text, ...s.match.aliases.values}.toList(growable: false),
  ];
  final slugs = [for (final s in spans) s.match.slugs];

  final routes = <SearchRoute>[
    SearchRoute(
      query: composeQuery(parts.text, filters),
      kind: SearchRouteKind.main,
      verifyNames: names,
      verifySlugs: slugs,
    ),
  ];

  if (spans.isNotEmpty) {
    // 标签路：认出的词换成筛选，其余词（含排除）原样留在文本里。
    routes.add(
      SearchRoute(
        query: composeQuery(
          _rebuildText(tokens, spans, (_) => null, keepUnreplaced: false),
          [
            for (final s in spans) '{tags:[${s.match.slugs.join(',')}]}',
            filters,
          ].join(' '),
        ),
        kind: SearchRouteKind.tags,
      ),
    );

    // 名字路：同一句话，认出的词换成另一种语言的名字。
    for (final locale in const ['ja', 'en', 'zh-CN']) {
      final used = <String>[];
      final text = _rebuildText(tokens, spans, (span) {
        final alias = span.match.aliases[locale];
        if (alias == null) return null;
        final raw = foldSearchText(span.text);
        if (foldSearchText(alias) == raw) return null;
        // 用户敲的是繁体时，简体名那一路与原话是同一批结果（zh 分词器做繁简折叠）。
        final tw = span.match.aliases['zh-TW'];
        if (locale == 'zh-CN' && tw != null && foldSearchText(tw) == raw) {
          return null;
        }
        used.add(alias);
        return '"$alias"';
      }, keepUnreplaced: true);
      if (used.isEmpty) continue;
      routes.add(
        SearchRoute(
          query: composeQuery(text, filters),
          kind: SearchRouteKind.alias,
          verifyNames: names,
          verifySlugs: slugs,
        ),
      );
    }
  }

  routes.addAll(
    _titleRoutes(
      _titlePhrases(parts.text, tokens, spans),
      crossLanguageFieldFor(apiType),
      filters,
    ),
  );

  // 去重：换名之后可能撞回同一串（日文名与原话相同等）。
  final seen = <String>{};
  final unique = [
    for (final r in routes)
      if (seen.add(r.query)) r,
  ];

  if (unique.length > 1) {
    LogUtils.d(
      '搜索规划($apiType)：${unique.map((r) => '[${r.kind.name}] ${r.query}').join(' ⊕ ')}',
      'IwaraSearchSyntax',
    );
  }
  return SearchPlan(routes: unique, tags: [for (final s in spans) s.match]);
}

/// 把自由文本与筛选拼成一条查询串。⛔ 文本**必须**在前（理由见 [planSearchRoutes]）。
String composeQuery(String text, String filters) =>
    [text.trim(), filters.trim()].where((s) => s.isNotEmpty).join(' ');

/// 只认标签、不发请求：界面用它说明「这次按哪些标签补搜了」。
List<TagNameMatch> resolveQueryTags(
  String query, {
  required String apiType,
  required TagNameResolver resolveTag,
}) {
  if (!segmentHasTags(apiType)) return const [];
  final tokens = _tokenize(splitQueryParts(query).text);
  return [for (final s in _resolveSpans(tokens, resolveTag)) s.match];
}

class _Token {
  const _Token(this.raw, this.text, {required this.negated});

  /// 原样（含引号与减号），拼回文本时用。
  final String raw;

  /// 去掉引号与减号之后的内容。
  final String text;

  final bool negated;
}

/// 连续几个词合起来认出的一个标签。
class _Span {
  const _Span(this.start, this.end, this.text, this.match);

  final int start;
  final int end; // 不含
  final String text;
  final TagNameMatch match;
}

final RegExp _tokenPattern = RegExp(r'(-?)"([^"]*)"|(\S+)');

List<_Token> _tokenize(String text) => [
  for (final m in _tokenPattern.allMatches(text))
    if (m.group(3) case final bare?)
      _Token(
        bare,
        bare.length > 1 && bare.startsWith('-') ? bare.substring(1) : bare,
        negated: bare.length > 1 && bare.startsWith('-'),
      )
    else if (m.group(2)!.trim().isNotEmpty)
      _Token(m.group(0)!, m.group(2)!.trim(), negated: m.group(1) == '-'),
];

/// 最多几个相邻的词合起来认一个标签名（`honkai star rail`）。
const int _maxSpanTokens = 4;

/// 从左到右贪心取最长的能认出的连续片段。只在肯定词里找，排除词另算。
List<_Span> _resolveSpans(List<_Token> tokens, TagNameResolver resolve) {
  final spans = <_Span>[];
  var i = 0;
  while (i < tokens.length) {
    _Span? found;
    for (var len = _maxSpanTokens; len >= 1 && found == null; len--) {
      final end = i + len;
      if (end > tokens.length) continue;
      final slice = tokens.sublist(i, end);
      if (slice.any((t) => t.negated)) continue;
      final text = slice.map((t) => t.text).join(' ');
      final match = resolve(text);
      if (match != null) found = _Span(i, end, text, match);
    }
    if (found != null) {
      spans.add(found);
      i = found.end;
    } else {
      i++;
    }
  }
  return spans;
}

/// 按原顺序拼回文本，认出的片段交给 [replace] 换掉。
///
/// [replace] 返回 null 时：[keepUnreplaced] 为真就原样保留那几个词（名字路：
/// 这个词在该语言没有可用的名字），为假就整段丢掉（标签路：它已经变成筛选了）。
String _rebuildText(
  List<_Token> tokens,
  List<_Span> spans,
  String? Function(_Span span) replace, {
  required bool keepUnreplaced,
}) {
  final out = <String>[];
  var i = 0;
  for (final span in spans) {
    for (; i < span.start; i++) {
      out.add(tokens[i].raw);
    }
    final replaced = replace(span);
    if (replaced != null) {
      out.add(replaced);
    } else if (keepUnreplaced) {
      for (var j = span.start; j < span.end; j++) {
        out.add(tokens[j].raw);
      }
    }
    i = span.end;
  }
  for (; i < tokens.length; i++) {
    out.add(tokens[i].raw);
  }
  return out.join(' ');
}

// ─────────────────────────────────────────────────────────────────────────
// 标题补路（原话搬进 title_zh / title_ja）
// ─────────────────────────────────────────────────────────────────────────

/// # 为什么要补
///
/// ⭐ 同一段文本被 en/ja/zh 三套分词器各存一份，而自由文本查询**只搜其中一种
/// 语言的那一对字段**——引擎按查询串自己判一次语言，用户无从干预（试过
/// Accept-Language 和 lang/locale 参数，全部无效）。
///
/// 实测（2026-09-21）：`原神` 被判成了 en，`{title_en:原神}` 的 314 条 +
/// `{body_en:原神}` 的 108 条 − 重叠 13 ＝ **409，正好等于自由文本总数**；而
/// `{title_ja:原神}` 的 914 条里它只要了 146 条。对中文用户就是大面积召回损失：
/// `碧蓝航线` 自由文本 100 条，`{title_zh:"碧蓝航线"}` 有 403 条。
///
/// 而且路由**不可预测**：`明日方舟` 走 ja、`碧蓝航线` 走 en、`东方` 走 zh，
/// 都是纯汉字却各去各的。所以只能把两路 CJK 字段一并补上，让调用方去归并。
///
/// ⛔ **引擎没有跨字段 OR**：`{a:x}|{b:y}`、`,`、` OR `、`;`、直接相邻，五种
/// 写法全返回 0。`[a,b]` 是 OR 但只在同一个字段内部。所以并集只能发多次请求、
/// 在客户端归并——这正是 [SearchRepository] 里那套归并游标存在的理由。
///
/// # 为什么只补 title 不补 body
///
/// 实测把 title_en/body_zh/body_ja/body_en 也加进来（七路），相比三路
/// （自由文本 + title_zh + title_ja）首屏只多 1~2 条，不值四倍请求。
///
/// # 为什么要求整段都是带引号的短语
///
/// 只有这种形状能原样搬进花括号：`"初音ミク" "ダンス"` → `{title_ja:"初音ミク"}
/// {title_ja:"ダンス"}`（同字段多个花括号之间是 AND，语义不变）。掺了裸词或
/// `-排除` 就没有等价写法，宁可不补也别改变语义。这同时让它与「精确匹配」
/// 开关天然联动：关掉开关 ＝ 没有引号 ＝ 不补路，一个钮管两件事。
/// 标题补路要搬进花括号的短语；null ＝ 这句话没有等价的花括号写法，不补。
///
/// 两种情形能补：整段本来就是带引号的短语；或者认出了标签、且没有 `-排除`——
/// 这时每个词原样当短语。后者不用管「精确匹配」开关：认出标签后所有文本路都
/// 按「标题写着它 / 挂着它的标签」逐条核对（见 [SearchRoute.accepts]），裸词
/// 的碎片召回混不进来，没必要再靠引号把关。
List<String>? _titlePhrases(
  String text,
  List<_Token> tokens,
  List<_Span> spans,
) {
  final quoted = _wholeTextAsQuotedPhrases(text);
  if (quoted != null) return quoted;
  if (spans.isEmpty || tokens.isEmpty || tokens.any((t) => t.negated)) {
    return null;
  }
  return [for (final t in tokens) t.text];
}

List<SearchRoute> _titleRoutes(
  List<String>? phrases,
  String? field,
  String filters,
) {
  if (field == null || phrases == null || phrases.isEmpty) return const [];

  return [
    for (final lang in crossLanguageLocales)
      SearchRoute(
        query: composeQuery(
          '',
          [
            for (final phrase in phrases) '{${field}_$lang:"$phrase"}',
            filters,
          ].join(' '),
        ),
        kind: SearchRouteKind.title,
        verifyNames: _unreliableLocales.contains(lang)
            ? [
                for (final p in phrases) [p],
              ]
            : const [],
      ),
  ];
}

/// 补路结果**不能直接信**、必须回头核对标题的语言。
///
/// ⛔ ja 分词器不收简体专用字：`{title_ja:"萝"}` / `"丝"` / `"袜"` 单独查全是
/// **0 条**——这些字进索引时就被丢了。于是短语在查询端也被削成剩下的字，
/// `{title_ja:"萝莉"}` 实际在找「莉」，召回 229 条、前 20 条**0 条**含萝莉
/// （爱莉希雅、伊莉亚……）；`{title_ja:"丝袜"}` 连一个字都不剩，4846 条全是
/// 无关的。按时间归并后这些垃圾把 title_zh 那 28 条正经结果淹没了——用户报的
/// 「搜萝莉出来一堆无关内容」就是这个（2026-09-23 实测）。
///
/// 而它正常时是**干净的二值**：原神/初音ミク/甘雨/胡桃/巨乳/白金ディスコ 这一路
/// 前 20 条标题 20/20 字面含关键词，坏的时候 0/20。所以核对标题就能把两种情形
/// 分开，不必去猜哪些字是简体专用字。
///
/// zh 这一路**不核对**：它会做繁简折叠（`{title_zh:"蘿莉"}` 找回的正是那 28 条
/// 简体标题，`黑丝` 也找回了「黑絲」），字面核对会把这些正当结果全部误杀；
/// 实测它也从没出过答非所问的结果。
const Set<String> _unreliableLocales = {'ja'};

/// 整段自由文本**恰好**由若干个带引号的短语组成时，返回这些短语；否则 null。
List<String>? _wholeTextAsQuotedPhrases(String text) {
  if (text.isEmpty) return null;
  if (!RegExp(r'^(?:"[^"]+"\s*)+$').hasMatch(text)) return null;
  return RegExp(r'"([^"]+)"').allMatches(text).map((m) => m.group(1)!).toList();
}
