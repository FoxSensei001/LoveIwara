/// 把正文里的 `<think>…</think>` 拆出来，归到推理那一边。
///
/// ⭐ 为什么要有这个东西：一部分中转（以及 QwQ / 早期 R1 的直连）不走
/// `reasoning_content` 字段，而是把思考**直接写进正文**，包在 `<think>` 里。
/// 不拆的话两头都坏：思考过程界面上看不到（它混在「正文」里，而结构化调用的
/// 正文是不给人看的），正文那头又多出一大段思考——翻译里就是一坨英文自言自语，
/// AI 搜索里是 JSON 前面垫了几百字、偶尔还夹着花括号。
///
/// ⛔ 流式下标签会被切在两个 chunk 之间（`<thi` + `nk>`），所以要有状态：
/// 结尾像是某个标签前缀的那几个字先扣住，等下一段来了再判。
class ThinkTagSplitter {
  static const String _open = '<think>';
  static const String _close = '</think>';

  bool _inThink = false;
  String _carry = '';

  /// 喂一段增量，吐出这一段里「正文」与「思考」各是什么。
  ({String visible, String thinking}) add(String chunk) {
    var s = _carry + chunk;
    _carry = '';
    final visible = StringBuffer();
    final thinking = StringBuffer();

    while (s.isNotEmpty) {
      final tag = _inThink ? _close : _open;
      final target = _inThink ? thinking : visible;
      final i = s.indexOf(tag);
      if (i >= 0) {
        target.write(s.substring(0, i));
        s = s.substring(i + tag.length);
        _inThink = !_inThink;
        continue;
      }
      final keep = _partialTagSuffix(s, tag);
      target.write(s.substring(0, s.length - keep));
      _carry = s.substring(s.length - keep);
      break;
    }
    return (visible: visible.toString(), thinking: thinking.toString());
  }

  /// 流结束：扣住的那几个字其实不是标签，按当前所处的一侧还回去。
  ({String visible, String thinking}) close() {
    final rest = _carry;
    _carry = '';
    return _inThink
        ? (visible: '', thinking: rest)
        : (visible: rest, thinking: '');
  }

  /// [s] 的结尾是不是 [tag] 的一个真前缀，是的话有多长。
  static int _partialTagSuffix(String s, String tag) {
    for (var k = tag.length - 1; k > 0; k--) {
      if (s.endsWith(tag.substring(0, k))) return k;
    }
    return 0;
  }
}

/// 一次要完的整段文本：拆成正文与思考。
({String visible, String thinking}) splitThinkTags(String text) {
  if (!text.contains('<think>')) return (visible: text, thinking: '');
  final splitter = ThinkTagSplitter();
  final a = splitter.add(text);
  final b = splitter.close();
  return (
    visible: (a.visible + b.visible).trim(),
    thinking: (a.thinking + b.thinking).trim(),
  );
}
