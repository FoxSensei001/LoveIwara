/// 把一个文件名折成**可直接用字典序比较**的排序 key。
///
/// # 为什么要预计算成 key，而不是写一个比较器
///
/// 本地媒体列表是 **DB 分页**的（千级条目不整表进内存），所以"按名称排序"只能由
/// SQL 的 `ORDER BY` 完成。而 SQLite 的字符串序是码元序：
///
/// ```text
/// ep1, ep10, ep11, ep12, ep2, ep3 …
/// ```
///
/// 用户把一整季拷进一个文件夹、指望「接着看」按集数往下走的场景，会第一个坏在这儿。
/// 在 Dart 里写比较器救不了分页（分页要求排序发生在数据库侧），所以改成**入库时
/// 预计算一列 `sort_name`**，`ORDER BY sort_name` 就是自然序。
///
/// # 做法
///
/// 1. 全角折半角——日文输入法默认全角，`１０` 与 `10` 必须排在一起
///    （同 `VrFormatDetector` 里那条"不折全角所有 ASCII 规则一条都命中不了"的教训）；
/// 2. 小写折叠——`Ep2` 与 `ep10` 不该因为大小写分到两个区；
/// 3. **数字段按「长度前缀 + 数值」展开**：`9` → `019`，`10` → `0210`，
///    于是 `019 < 0210`，字典序即数值序。
///
/// 用长度前缀而不是零填充到定长，是为了不给数字长度设上限——文件名里混着 13 位
/// 时间戳是常事，零填充到 12 位会让它和 12 位数的相对顺序失真。
///
/// ```text
/// ep2   → ep012
/// ep10  → ep0210
/// ep100 → ep03100        (ep012 < ep0210 < ep03100 ✓)
/// ```
///
/// ⛔ 前导零会被吃掉（`ep01` 与 `ep1` 折出同一个 key）。这是有意的——它们本来就
/// 该挨在一起。调用方在 SQL 里用 `ORDER BY sort_name, name` 做二次判定即可。
library;

/// 数字段最长支持 99 位（长度前缀占两位）。超过的按原样保留，不再展开——
/// 那已经不是"编号"而是一串校验和，顺序无意义。
const int _maxDigitRunLength = 99;

String naturalSortKey(String name) {
  final folded = _foldFullWidth(name).toLowerCase();
  final out = StringBuffer();
  var i = 0;
  while (i < folded.length) {
    final c = folded.codeUnitAt(i);
    final isDigit = c >= 0x30 && c <= 0x39;
    if (!isDigit) {
      out.writeCharCode(c);
      i++;
      continue;
    }
    // 抓完整个数字段。
    var j = i;
    while (j < folded.length) {
      final d = folded.codeUnitAt(j);
      if (d < 0x30 || d > 0x39) break;
      j++;
    }
    // 去前导零；全零则留一个 '0'。
    var digits = folded.substring(i, j);
    digits = digits.replaceFirst(RegExp(r'^0+(?=.)'), '');
    if (digits.length <= _maxDigitRunLength) {
      out.write(digits.length.toString().padLeft(2, '0'));
    }
    out.write(digits);
    i = j;
  }
  return out.toString();
}

/// 全角 ASCII（Ｕ+FF01–Ｕ+FF5E）折回半角，全角空格（U+3000）折成普通空格。
///
/// ⛔ 不能只靠 `toLowerCase()`：它把全角 Ｖ(U+FF36) 折成的是**全角** ｖ(U+FF56)，
/// 永远到不了 ASCII。
String _foldFullWidth(String input) {
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit == 0x3000) {
      buffer.writeCharCode(0x20);
    } else if (unit >= 0xFF01 && unit <= 0xFF5E) {
      buffer.writeCharCode(unit - 0xFEE0);
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}
