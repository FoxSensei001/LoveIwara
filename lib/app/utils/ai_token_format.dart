/// token 计数的显示格式。
///
/// ⭐ 各家控制台、计价页、SDK 文档说 token 都是 `128K` / `2.4M` 这一套，几乎没有
/// 人写 `163840`。这不只是好看：**上下文窗口和累计用量天然是几万到几十亿的量级**，
/// 裸数字一长，人第一眼读到的是「一串数字」而不是「多大」——要数位数才知道是
/// 16 万还是 160 万。
///
/// 进位阶梯与英文数量级一致（也是各家计价页在用的那套）：
///
/// | 后缀 | 基数 | 例 |
/// |---|---|---|
/// | （无） | 1 | `845` |
/// | `K` | 千 | `12.3K` / `128K` / `163.8K` |
/// | `M` | 百万 | `1M` / `2.4M` |
/// | `B` | 十亿 | `3.2B` |
/// | `T` | 万亿 | `1.1T` |
///
/// ⛔ 小数位末尾的 `.0` 一律抹掉：`128.0K` 会被读成「精确到小数位」的意思，
/// 而它其实就是整的 128K。
String formatTokenCount(int tokens) {
  if (tokens < 0) return '0';
  // 一千以下原样：这个量级下精确值本身就是信息。
  if (tokens < 1000) return '$tokens';
  for (final (base, suffix) in _units) {
    final value = tokens / base;
    // ⛔ 闸门是「四舍五入到一位小数之后**够不够 1**」，而不是 `tokens >= base`。
    // 按后者写，999_999 会落到 M 的下一档、以 K 算成 `1000K`——那个写法谁也不用
    // （该说 1M 了）。这么写每一级进位都自动对，不用一级一级手挑常数。
    if (value >= 0.99995) return '${_trim(value)}$suffix';
  }
  return '$tokens';
}

/// 从大到小——[formatTokenCount] 取**第一个够得着**的那级。
const List<(int, String)> _units = [
  (1000000000000, 'T'),
  (1000000000, 'B'),
  (1000000, 'M'),
  (1000, 'K'),
];

String _trim(double value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
