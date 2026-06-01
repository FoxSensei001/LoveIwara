/// Oreno3d 视频匹配相关的纯函数工具。
///
/// 背景（issue #95）：oreno3d 没有按 iwara 视频ID/URL 检索的能力，只能用标题做
/// 关键词搜索，再用 oreno3d 详情页里的真实 iwara 链接做 ID 校验。实测发现：当
/// 搜索关键词含 `" - "` 等破折号时，oreno3d 的搜索会解析失败并返回“整站按热度
/// 排序的全部视频”，导致几乎每个视频都匹配到同一批最热视频（错误标签）。因此
/// 搜索前必须先净化关键词。
class Oreno3dMatchUtil {
  Oreno3dMatchUtil._();

  /// 会破坏 oreno3d 搜索解析的字符（破折号/连字符类）。
  static final RegExp _breakingChars = RegExp(r'[-–—―‐]');
  static final RegExp _multiSpace = RegExp(r'\s+');

  /// 净化 oreno3d 搜索关键词。
  ///
  /// 去掉破折号类字符并把它们替换为空格，再折叠多余空白、去首尾空白。
  /// 不删除任何词，避免误伤；标题相似度比较仍应使用原始标题。
  static String sanitizeKeyword(String title) {
    return title
        .replaceAll(_breakingChars, ' ')
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

  static List<String> _words(String title) {
    return title
        .toLowerCase()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
  }
}
