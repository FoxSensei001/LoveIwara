/// 标签词库的**全语言名称索引**：用户敲下的一个词，是不是某个 iwara 标签的名字。
///
/// ⭐ 这是搜索「按标签补路」的地基（见 `iwara_search_syntax.dart` 的
/// `planSearchRoutes`）。iwara 的自由文本只搜标题/简介，**不搜标签**；而上传者
/// 的标题五花八门（日文、英文、角色名、梗），真正稳定的是标签。2026-09-23 实测
/// 近 30 天：搜 `原神` 的文本只召回 17 条，`{tags:[genshin_impact]}` 有 324 条。
///
/// 所以这里只回答一件事：这串字**精确地**是哪个（些）标签的名字，以及那几个标签
/// 在各语言里叫什么（拿去补「日文名 / 英文名」那几路文本搜索）。
///
/// ⛔ 只做**精确**匹配（折叠大小写、全半角、假名、标点之后逐字相等）。前缀/包含
/// 会把「初音」解析成「初音未来」、把「胡桃」同时解析成伊万里胡桃——补出来的路
/// 就不再是用户说的那个东西了。
library;

/// 名字里能直接当引号短语发给引擎的最短长度（折叠后）。一个字的名字太容易撞车。
const int _minNameLength = 2;

/// 词库的四种语言。
const List<String> tagNameLocales = ['zh-CN', 'zh-TW', 'ja', 'en'];

/// 一次命中：这串字对应的标签，以及它们在各语言下能拿去搜索的名字。
class TagNameMatch {
  const TagNameMatch({required this.slugs, required this.aliases});

  /// 同名的全部标签（`巨乳` 对应 big_boobs / big_breasts / huge_tits……五个），
  /// 发请求时放进同一个 `{tags:[a,b,c]}`——同字段内 `[..]` 是 OR。
  final List<String> slugs;

  /// 语言 → 可以安全放进引号短语里的名字。某语言没有合适的名字就不在表里。
  final Map<String, String> aliases;
}

/// 搜索用的文本折叠：大小写、全角 ASCII、片假名＝平假名，并丢掉标点、符号与空白。
///
/// 只折叠 iwara 引擎**确实会折叠**的那几样（`"まんこ"` ＝ `"マンコ"`），同时把
/// 标点与空白看成不存在——`崩坏：星穹铁道` / `崩坏星穹铁道` / `崩坏 星穹铁道`
/// 是同一个东西，`hatsune_miku` / `Hatsune Miku` 也是。
String foldSearchText(String text) {
  final buf = StringBuffer();
  for (final rune in text.runes) {
    var r = rune;
    if (r >= 0xFF01 && r <= 0xFF5E) r -= 0xFEE0; // 全角 ASCII → 半角
    if (_punctOrSpace.hasMatch(String.fromCharCode(r))) continue;
    if (r >= 0x30A1 && r <= 0x30F6) r -= 0x60; // 片假名 → 平假名
    buf.writeCharCode(r);
  }
  return buf.toString().toLowerCase();
}

final RegExp _punctOrSpace = RegExp(r'[\p{P}\p{S}\p{Z}\s_]', unicode: true);

/// 括号注释：`眼罩 (蒙眼)`、`CBT (阴茎睾丸虐待)`、`寝取られ(黒人)`。
final RegExp _parenthetical = RegExp(r'\s*[（(][^）)]*[）)]');

/// 放进引号短语会**毁掉整条查询**的写法。
///
/// ⛔ 实测 `"艦隊これくしょん -艦これ-"` 返回 **321254 条＝全站**：引号里「空格 +
/// 减号」被当成了排除语法，短语整个失效。词内连字符（`Chun-Li`、`DSR-50`）没事。
final RegExp _unsafeInPhrase = RegExp(r'(^|\s)-|["{}\[\]\\]');

/// 一个名字拆出的全部写法：`雅儿贝德/阿贝多` → 两个；括号注释去掉。
Iterable<String> _variants(String name) sync* {
  for (final part in name.split(RegExp(r'\s*[/／]\s*'))) {
    final clean = part.replaceAll(_parenthetical, '').trim();
    if (clean.isNotEmpty) yield clean;
  }
}

/// 音译人名的「名」：`蒂法·洛克哈特` → `蒂法`，`ティファ・ロックハート` → `ティファ`。
///
/// 只认中点（`·` `・` `•`）——它只出现在音译的人名里；空格不算（`Big Boobs`
/// 拆出 `Big` 就闹笑话了）。用户搜角色几乎只敲名，不敲全名。
String? _givenName(String variant) {
  final i = variant.indexOf(RegExp(r'[·・•]'));
  if (i <= 0) return null;
  final given = variant.substring(0, i).trim();
  // ⛔ 两个假名的「名」太常见：`ヨル` 折叠后是 `よる`、`リタ` 撞上「やりたい」，
  // 词库里有 28 个这样的名（ヨル/リタ/シロ/ココ…）。这种只认全名。
  if (given.length < 3 && _kanaOnly.hasMatch(given)) return null;
  return given;
}

final RegExp _kanaOnly = RegExp(r'^[぀-ヿ]+$');

class _Entry {
  _Entry(this.names);

  /// 语言 → 原始名字（可能带 `/` 与括号）。
  final Map<String, String> names;
}

/// 全语言名称 → 标签的索引。从词库 JSON 的 `tags` 段一次性建好，之后只读。
class TagNameIndex {
  TagNameIndex._(this._entries, this._byName, this._byGivenName);

  /// 从词库 JSON 的 `tags` 段建索引：`{slug: {n: {zh-CN:.., ja:.., ..}, ..}}`。
  factory TagNameIndex.fromTags(Map<String, dynamic> tags) {
    final entries = <String, _Entry>{};
    final byName = <String, List<String>>{};
    final byGivenName = <String, List<String>>{};

    void index(Map<String, List<String>> into, String name, String slug) {
      final key = foldSearchText(name);
      if (key.length < _minNameLength) return;
      final slugs = into.putIfAbsent(key, () => <String>[]);
      if (!slugs.contains(slug)) slugs.add(slug);
    }

    tags.forEach((slug, value) {
      if (value is! Map) return;
      final raw = value['n'];
      final names = <String, String>{};
      if (raw is Map) {
        for (final locale in tagNameLocales) {
          final name = raw[locale];
          if (name is String && name.trim().isNotEmpty) names[locale] = name;
        }
      }
      entries[slug] = _Entry(names);
      // slug 自己也是一个名字：`hatsune_miku`、`2b`、`ntr`。
      index(byName, slug, slug);
      for (final name in names.values) {
        for (final v in _variants(name)) {
          index(byName, v, slug);
          if (_givenName(v) case final given?) index(byGivenName, given, slug);
        }
      }
    });
    return TagNameIndex._(entries, byName, byGivenName);
  }

  final Map<String, _Entry> _entries;
  final Map<String, List<String>> _byName;

  /// 只按「名」认的次一级表。全名表里有的键永远先用全名表。
  final Map<String, List<String>> _byGivenName;

  int get length => _entries.length;

  /// 这串字精确地是哪些标签的名字；不是任何标签的名字就返回 null。
  TagNameMatch? match(String text) {
    final key = foldSearchText(text);
    if (key.length < _minNameLength) return null;
    final full = _byName[key];
    // 按「名」认出来的，补搜也用各语言的「名」：`"ティファ"` 远比全名
    // `"ティファ・ロックハート"` 搜得全（标题里几乎没人写全名）。
    final viaGivenName = full == null;
    final slugs = full ?? _byGivenName[key];
    if (slugs == null || slugs.isEmpty) return null;

    final aliases = <String, String>{};
    for (final locale in tagNameLocales) {
      for (final slug in slugs) {
        final name = _entries[slug]?.names[locale];
        if (name == null) continue;
        final variant = _variants(name).firstOrNull;
        final alias = viaGivenName && variant != null
            ? (_givenName(variant) ?? variant)
            : variant;
        if (alias == null ||
            _unsafeInPhrase.hasMatch(alias) ||
            foldSearchText(alias).length < _minNameLength) {
          continue;
        }
        aliases[locale] = alias;
        break;
      }
    }
    return TagNameMatch(slugs: List.unmodifiable(slugs), aliases: aliases);
  }
}
