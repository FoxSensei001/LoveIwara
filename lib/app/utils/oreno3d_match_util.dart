import 'dart:math' as math;

/// Oreno3d 视频匹配相关的纯函数工具。
///
/// 背景（issue #95 + 2026-08-27 对 oreno3d 站内搜索的实测）：
/// oreno3d 没有按 iwara 视频ID/URL 检索的能力（`keyword=<iwaraId>` 命中 0 条），
/// 只能用标题/作者做关键词搜索，再用详情页里的真实 iwara 链接做 ID 校验。
///
/// 实测到的三条站内搜索行为，直接决定了这里的取词与打分策略：
///   1. **多 token 是 AND 收窄**，不是 OR。`菲比 泳装` 只返回同时含这两个词的 2 条，
///      而 `菲比` 单独搜有 5 页。所以正确用法是「把标题的词拼成一条查询」，
///      而不是一个词搜一次。
///   2. **一个 token 都命中不了时，返回的是整站热门榜**（`风骚丈母娘 上` 的前三条
///      与标题毫无关系）。所以拿到结果后必须先本地打分，分数不够就一个详情页都别拉，
///      否则就是对着热门榜做无谓的网络请求 —— 这正是 issue #95 的观感来源。
///   3. **搜索索引覆盖作者字段**（`keyword=10yue` 返回该作者全部作品），而 oreno3d 的
///      标题/作者是从 iwara 逐字抓来的（实测逐字节相同）。所以作者名是一条独立且
///      很强的查询路径，标题完全一致时相似度可以直接到 1.0。
///
/// 由此形成的查询计划见 [buildSearchQueries]，打分见 [candidateScore]。
/// 真正的匹配仍然只认 iwara ID 校验，打分只决定「值不值得为它拉一次详情页」。
class Oreno3dMatchUtil {
  Oreno3dMatchUtil._();

  /// 值得为候选项拉一次详情页做 ID 校验的分数门槛。
  ///
  /// 候选按 [candidateScore] 降序排列，一旦某条低于此值就可以整段停止 ——
  /// 后面的只会更低。作者完全一致的候选项分数下限是 0.65（见 [candidateScore]），
  /// 恒高于此门槛，因此「同作者」这条线索永远能进入校验。
  static const double verifyGate = 0.55;

  /// 单条查询里最多带多少个 token。
  ///
  /// 站内是 AND 语义，token 越多结果越窄；但标题里偶尔混入 oreno3d 那边没有的词
  /// （例如上传者自己加的画质标记），token 全带上反而会一条都匹配不到、退化成热门榜。
  /// 8 个是实测下来「够窄又不至于过拟合」的量。超出时丢掉最不显著的那些
  /// （见 [_salience]），而不是简单截断——最有区分度的词常常正好排在标题末尾。
  static const int _maxQueryTokens = 8;

  /// 全角 ASCII（！-～）折半角时的码位偏移。
  static const int _fullWidthOffset = 0xFEE0;

  /// 生成搜索查询，按「命中率从高到低」排好序，调用方应逐条去搜、命中即停。
  ///
  /// 三段递进（实测顺序很重要）：
  ///   1. **整条标题的 token 拼成一条**。AND 语义下这是最窄的查询，oreno3d 的标题
  ///      与 iwara 完全一致，绝大多数视频在这一步就命中第 1 名。
  ///   2. **作者名**。标题被上传者改过、或标题里混了 oreno3d 那边没有的词时，
  ///      靠作者名把范围缩到「这个作者的作品」，再用标题相似度挑。
  ///   3. **最显著的 2 个 token**。前两条都落空时的兜底：比整条标题宽松、
  ///      又比单个通用词窄。
  ///
  /// 返回值已去重，最多 3 条。
  static List<String> buildSearchQueries(String title, String? authorName) {
    final queries = <String>[];
    void add(String? raw) {
      final s = raw?.trim() ?? '';
      if (s.isEmpty) return;
      if (!queries.contains(s)) queries.add(s);
    }

    final tokens = queryTokens(title);
    if (tokens.isNotEmpty) add(_capBySalience(tokens, _maxQueryTokens).join(' '));
    add(authorName);
    final distinctive = distinctiveTokens(tokens, 2);
    if (distinctive.length >= 2) add(distinctive.join(' '));

    return queries;
  }

  /// 把标题切成可用于站内搜索的 token（不截断，截断由 [buildSearchQueries] 按显著度做）。
  ///
  /// 规则：全角折半角后，按「非字母数字」切分（标点、符号、emoji、空白都是分隔符），
  /// 重复词只保留第一次出现（AND 查询里重复毫无作用，留着只会让 token 上限失真），
  /// 然后丢掉没有区分度的碎片：
  ///   - 含 CJK/假名的 token 一律保留（哪怕只有一个字，中日文单字也有区分度）；
  ///   - 纯拉丁/数字的 token 需要长度 >= 2，且不能是纯数字（`4K`、`60fps` 里的
  ///     `60` 这类到处都是，只会把查询打宽）。
  static List<String> queryTokens(String title) {
    final tokens = <String>[];
    final seen = <String>{};
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isEmpty) return;
      final token = buffer.toString();
      buffer.clear();
      final keep = _hasCjk(token) ||
          (token.length >= 2 && !_isAllDigits(token));
      if (keep && seen.add(token)) tokens.add(token);
    }

    for (final rune in _foldWidth(title).runes) {
      if (_isWordRune(rune)) {
        buffer.writeCharCode(rune);
      } else {
        flush();
      }
    }
    flush();

    return tokens;
  }

  /// 把 token 数量压到 [limit] 以内：丢掉最不显著的，保留原有顺序。
  static List<String> _capBySalience(List<String> tokens, int limit) {
    if (tokens.length <= limit) return tokens;
    final keptSet = _bySalience(tokens).take(limit).toSet();
    return tokens.where(keptSet.contains).toList();
  }

  /// 从 token 列表里挑出最显著的 [count] 个：越长越显著，CJK 比拉丁更显著
  /// （同样长度下，一个四字汉字词的区分度远高于一个四字母英文词）。
  static List<String> distinctiveTokens(List<String> tokens, int count) {
    final sorted = _bySalience(tokens);
    return sorted.length <= count ? sorted : sorted.sublist(0, count);
  }

  /// 按显著度降序排列；显著度相同的按原顺序排，不依赖 [List.sort] 的稳定性
  /// （Dart 并不保证稳定，等分 token 的先后不该随实现摇摆）。
  static List<String> _bySalience(List<String> tokens) {
    final indexed = [
      for (var i = 0; i < tokens.length; i++) (index: i, token: tokens[i]),
    ]..sort((a, b) {
        final bySalience = _salience(b.token).compareTo(_salience(a.token));
        return bySalience != 0 ? bySalience : a.index.compareTo(b.index);
      });
    return [for (final e in indexed) e.token];
  }

  static int _salience(String token) =>
      token.length + (_hasCjk(token) ? 2 : 0);

  /// 给一个搜索结果候选项打分，决定「值不值得为它拉一次详情页校验」。
  ///
  /// 分数 = 标题相似度 [titleAffinity]；作者完全一致时把相似度抬到至少 0.3 再 +0.35，
  /// 也就是「同作者」这条线索本身就足以越过 [verifyGate]。
  /// 这是因为 oreno3d 的作者名抓自 iwara 且逐字相同，作者撞名的概率远低于标题撞词。
  static double candidateScore({
    required String iwaraTitle,
    required String? iwaraAuthor,
    required String candidateTitle,
    required String candidateAuthor,
  }) {
    var score = titleAffinity(iwaraTitle, candidateTitle);
    if (isSameAuthor(iwaraAuthor, candidateAuthor)) {
      score = math.max(score, 0.3) + 0.35;
    }
    return score;
  }

  /// 作者名是否指同一个人。归一化后比较，容忍大小写/全半角/首尾空格差异。
  static bool isSameAuthor(String? a, String? b) {
    if (a == null || b == null) return false;
    final fa = foldForCompare(a);
    final fb = foldForCompare(b);
    return fa.isNotEmpty && fa == fb;
  }

  /// 两条标题的相似度，取值 [0, 1]。
  ///
  /// 用归一化后的**字符二元组 Dice 系数**，而不是按空格分词 —— 中日文标题常常整条
  /// 就是一个「词」，按空格分词只会得到 0 或 1 两种结果，排序等于失效。
  static double titleAffinity(String a, String b) {
    final fa = foldForCompare(a);
    final fb = foldForCompare(b);
    if (fa.isEmpty || fb.isEmpty) return 0.0;
    if (fa == fb) return 1.0;
    // 单字符没有二元组可言，退化成相等判断（上面已处理相等）。
    if (fa.length < 2 || fb.length < 2) return 0.0;

    final setA = _bigrams(fa);
    final setB = _bigrams(fb);
    final intersection = setA.where(setB.contains).length;
    return 2 * intersection / (setA.length + setB.length);
  }

  /// 归一化字符串用于比较：全角折半角、转小写、只保留字母数字与 CJK/假名，
  /// 空白与标点/emoji 一律丢弃。
  ///
  /// 丢空白是有意的：oreno3d 与 iwara 的标题偶尔在空格数量上有出入
  /// （`Elysia  Mobius` vs `Elysia Mobius`），但那不代表它们是两条视频。
  static String foldForCompare(String input) {
    final buffer = StringBuffer();
    for (final rune in _foldWidth(input).runes) {
      if (_isWordRune(rune)) {
        buffer.writeCharCode(_toLowerAscii(rune));
      }
    }
    return buffer.toString();
  }

  /// 全角 ASCII → 半角，全角空格 → 普通空格。
  static String _foldWidth(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0xFF01 && rune <= 0xFF5E) {
        buffer.writeCharCode(rune - _fullWidthOffset);
      } else if (rune == 0x3000) {
        buffer.writeCharCode(0x20);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static int _toLowerAscii(int rune) =>
      (rune >= 0x41 && rune <= 0x5A) ? rune + 0x20 : rune;

  static List<String> _bigrams(String s) {
    final list = <String>[];
    for (var i = 0; i + 1 < s.length; i++) {
      list.add(s.substring(i, i + 2));
    }
    return list;
  }

  static bool _isAllDigits(String s) {
    for (final rune in s.runes) {
      if (rune < 0x30 || rune > 0x39) return false;
    }
    return true;
  }

  /// 是否是「构成词」的字符：字母、数字、CJK、假名、谚文。
  ///
  /// 反过来说，标点、符号、emoji、变体选择子、中点「・」、浊音记号都不是 ——
  /// 它们是分隔符，`プリンツ・オイゲン` 必须切成两个 token 才搜得到。
  static bool _isWordRune(int r) {
    if (r >= 0x30 && r <= 0x39) return true; // 0-9
    if (r >= 0x41 && r <= 0x5A) return true; // A-Z
    if (r >= 0x61 && r <= 0x7A) return true; // a-z
    if (r >= 0xC0 && r <= 0x24F) return r != 0xD7 && r != 0xF7; // 拉丁扩展
    if (r >= 0x370 && r <= 0x4FF) return true; // 希腊 / 西里尔
    if (r >= 0x1100 && r <= 0x11FF) return true; // 谚文字母
    if (r >= 0x3041 && r <= 0x3096) return true; // 平假名
    if (r == 0x309D || r == 0x309E) return true; // 平假名叠字符
    if (r >= 0x30A1 && r <= 0x30FA) return r != 0x30FB; // 片假名（不含中点）
    if (r >= 0x30FC && r <= 0x30FF) return true; // 长音符及叠字符
    if (r >= 0x3400 && r <= 0x4DBF) return true; // CJK 扩展 A
    if (r >= 0x4E00 && r <= 0x9FFF) return true; // CJK 统一表意
    if (r >= 0xAC00 && r <= 0xD7A3) return true; // 谚文音节
    if (r >= 0xF900 && r <= 0xFAFF) return true; // CJK 兼容表意
    if (r >= 0xFF66 && r <= 0xFF9D) return true; // 半角片假名
    return false;
  }

  /// 是否含汉字 / 假名（CJK 统一、扩展 A、平假名、片假名、半角片假名）。
  static bool _hasCjk(String s) {
    for (final r in s.runes) {
      if ((r >= 0x4E00 && r <= 0x9FFF) ||
          (r >= 0x3400 && r <= 0x4DBF) ||
          (r >= 0x3040 && r <= 0x309F) ||
          (r >= 0x30A0 && r <= 0x30FF) ||
          (r >= 0xFF66 && r <= 0xFF9D)) {
        return true;
      }
    }
    return false;
  }
}
