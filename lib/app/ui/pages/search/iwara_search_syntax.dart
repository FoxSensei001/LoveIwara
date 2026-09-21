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

/// 除了引擎自己挑的那一路，还要另外补哪几种语言。
const List<String> crossLanguageLocales = ['zh', 'ja'];

/// 同一个关键词还该往哪几路发。返回的是**额外**的查询串，空表 ＝ 不必补。
///
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
List<String> crossLanguageVariants(String query, String? field) {
  if (field == null) return const [];
  final parts = splitQueryParts(query);
  final phrases = _wholeTextAsQuotedPhrases(parts.text);
  if (phrases == null || phrases.isEmpty) return const [];

  return [
    for (final lang in crossLanguageLocales)
      [
        for (final phrase in phrases) '{${field}_$lang:"$phrase"}',
        parts.filters,
      ].where((s) => s.isNotEmpty).join(' '),
  ];
}

/// 整段自由文本**恰好**由若干个带引号的短语组成时，返回这些短语；否则 null。
List<String>? _wholeTextAsQuotedPhrases(String text) {
  if (text.isEmpty) return null;
  if (!RegExp(r'^(?:"[^"]+"\s*)+$').hasMatch(text)) return null;
  return RegExp(r'"([^"]+)"').allMatches(text).map((m) => m.group(1)!).toList();
}
