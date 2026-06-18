/// Oreno3d 视频匹配相关的纯函数工具。
///
/// 背景（issue #95 + 后续观察）：oreno3d 没有按 iwara 视频ID/URL 检索的能力，
/// 只能用标题做关键词搜索，再用 oreno3d 详情页里的真实 iwara 链接做 ID 校验。
/// 实测 oreno3d 站内搜索按空格切 token、看起来是 OR 命中后按 hot 重排，
/// 因此关键词中只要：
///   - 含 `" - "` 等"破句"字符（issue #95），或
///   - token 太多 / token 选得太"通用"，
/// 命中数会瞬间膨胀，热门视频凭播放量碾压目标视频，目标会被挤出前列、
/// 看起来像"返回整站按热度排序"。
///
/// 因此本工具同时承担两件事：
///   1. [sanitizeKeyword] —— 净化单条关键词；
///   2. [extractKeywordCandidates] —— 从一条 iwara 标题里挑出**多个候选关键词**，
///      让调用方按显著度顺序逐个去搜，配合 iwara-ID 校验提高命中率。
class Oreno3dMatchUtil {
  Oreno3dMatchUtil._();

  /// 会破坏 oreno3d 搜索解析或污染 token 切分的字符。
  ///
  /// 整体策略：能"把一条标题切成有用 token 的"分隔/装饰字符全替换为空格，
  /// 再交给 [_multiSpace] 折叠空白。不删词，避免把短的 ASCII token 误吞。
  ///
  /// 注意：所有 ASCII 标点都放原始 char class，CJK 全角符号同样列出。
  /// emoji / 高位符号区间另由 [_decorativeSymbols] 处理（Dart 正则的字符类
  /// 不支持代理对，需要 unicode 模式）。
  static final RegExp _breakingChars = RegExp(
    r'[-–—―‐\[\](){}【】「」『』〈〉《》［］｛｝（）'
    r'★☆♥♡♪♫♬♩♭♯❤❥◆◇■□●○▲△▼▽※]',
  );

  /// emoji / Dingbats / Misc Symbols / 变体选择子等"装饰位"。
  /// 启用 unicode 模式才能用 `\u{...}` 引用 BMP 外的码位（如 🥰 = U+1F970）。
  static final RegExp _decorativeSymbols = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{200D}]',
    unicode: true,
  );

  static final RegExp _multiSpace = RegExp(r'\s+');

  /// 净化 oreno3d 搜索关键词。
  ///
  /// 把所有"破句字符"和装饰符号替换为空格，再折叠多余空白、去首尾空白。
  /// 不删除任何词，避免误伤；标题相似度比较仍应使用原始标题。
  static String sanitizeKeyword(String title) {
    return title
        .replaceAll(_breakingChars, ' ')
        .replaceAll(_decorativeSymbols, ' ')
        .replaceAll(_multiSpace, ' ')
        .trim();
  }

  /// 计算两个标题的相似度（基于词的双向包含匹配）。
  ///
  /// 返回 title1 中能在 title2 找到匹配的词所占比例，范围 [0, 1]。
  /// 会过滤空字符串，否则 `word.contains('')` 恒为 true 会造成虚假满分匹配
  /// （title1/title2 含双空格或首尾空格时）。
  static double titleSimilarity(String title1, String title2) {
    final words1 = _words(title1);
    final words2 = _words(title2);

    if (words1.isEmpty) return 0.0;

    int matchCount = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1.contains(word2) || word2.contains(word1)) {
          matchCount++;
          break;
        }
      }
    }

    return matchCount / words1.length;
  }

  /// 从一条 iwara 标题里抽出多个候选关键词，按"匹配命中率从高到低"排好序。
  ///
  /// 调用方应**按顺序**逐个去 oreno3d 搜，第一个能被 iwara-ID 校验通过的就停，
  /// 不要并发地把全部候选都打一遍——每个候选还要继续拉详情页。
  ///
  /// 选词策略（实测顺序很重要）：
  ///   1. **CJK 长词**（>=2 字符且含汉字 / 假名）。词越长越独特，命中目标视频
  ///      的概率越高，且不容易被热门视频挤掉。最多取 3 条。
  ///   2. **连续的 ASCII 词对**（如 `Aria ZZZ`）。单个 ASCII 短词（`ZZZ`、`HMV`）
  ///      过于通用，必须组对才有区分度。
  ///   3. **完整标题净化版**作为最后兜底。命中率最差，但保留旧行为，避免对那些
  ///      原本就能匹配的视频造成回归。
  ///
  /// 当标题含 `【…】` / `「…」` / `(…)` 等成对括号时，**优先使用括号内的内容**
  /// 抽 token——上传者通常把"作品/角色名"塞在括号里，比标题前缀（往往是个人化
  /// 的随手描述）显著得多。
  ///
  /// 候选列表已去重（基于字符串相等），并以原始顺序保留。
  static List<String> extractKeywordCandidates(String title) {
    final added = <String>{};
    final ordered = <String>[];
    void add(String? raw) {
      if (raw == null) return;
      final s = raw.trim();
      if (s.isEmpty) return;
      if (added.add(s)) ordered.add(s);
    }

    // 1. 抽出所有成对括号的内容；没有就用整条标题。
    final bracketSegments = _bracketRegex
        .allMatches(title)
        .map((m) => m.group(1) ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // 用括号段做"显著来源"；没括号则退回完整标题。
    final salientSource =
        bracketSegments.isNotEmpty ? bracketSegments.join(' ') : title;

    // 2. 切出 token（按净化后的空格分词）。
    final tokens = sanitizeKeyword(salientSource)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();

    // 3. 优先：长 CJK token。按长度倒序，最多取 3 条。
    final cjkLong = tokens.where((t) => _hasCjk(t) && t.length >= 2).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final t in cjkLong.take(_maxCjkCandidates)) {
      add(t);
    }

    // 4. 次优：连续的 ASCII 词对。
    //   token 列表里第 i 和 i+1 都是纯 ASCII 字母数字时，把它们拼成一个候选。
    //   单 ASCII token 不单独入选——容易过短/过通用而退化。
    var pairCount = 0;
    for (var i = 0; i + 1 < tokens.length; i++) {
      if (pairCount >= _maxAsciiPairCandidates) break;
      final a = tokens[i];
      final b = tokens[i + 1];
      if (_isLatinAlphanum(a) && _isLatinAlphanum(b)) {
        add('$a $b');
        pairCount++;
      }
    }

    // 5. 最后：完整标题净化版兜底。
    add(sanitizeKeyword(title));

    return ordered;
  }

  static List<String> _words(String title) {
    return title
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// 匹配各种成对括号；group(1) 为内层文本。
  /// 故意只匹配同侧成对（如 `【` 配 `】`），不跨括号类型，避免误吞。
  static final RegExp _bracketRegex = RegExp(
    r'【([^【】]+)】'
    r"|「([^「」]+)」"
    r'|『([^『』]+)』'
    r'|〈([^〈〉]+)〉'
    r'|《([^《》]+)》'
    r'|（([^（）]+)）'
    r'|\[([^\[\]]+)\]'
    r'|\(([^()]+)\)',
  );

  /// 判断字符串是否含汉字 / 假名（CJK Unified、CJK Ext A、平假名、片假名、半角片假名）。
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

  /// 判断是否为纯 ASCII 字母 / 数字（允许撇号，常见于 `I'm` 之类）。
  static bool _isLatinAlphanum(String s) {
    if (s.isEmpty) return false;
    for (final r in s.runes) {
      final ok = (r >= 0x30 && r <= 0x39) ||
          (r >= 0x41 && r <= 0x5A) ||
          (r >= 0x61 && r <= 0x7A) ||
          r == 0x27;
      if (!ok) return false;
    }
    return true;
  }

  /// 候选关键词数量上限。把请求量控制在可接受范围内：
  ///   每候选最多再拉 3 个详情，候选 3 + 词对 2 + 兜底 1 = 6，最多 18 次详情请求；
  ///   实际上第一个候选命中就停，绝大多数视频只打 1~2 次。
  static const int _maxCjkCandidates = 3;
  static const int _maxAsciiPairCandidates = 2;
}
