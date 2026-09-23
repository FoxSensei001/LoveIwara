import 'dart:convert';

/// 从模型的自由文本里把那个 JSON 对象抠出来。
///
/// # ⛔ 为什么非要有这个东西
///
/// 2026-09-20 拿真中转实测：请求里带了
/// `response_format: {type: json_schema, strict: true}`，中转**静默忽略**——
/// 不报错、不警告，HTTP 200，回一整段散文（18 秒、626 个 completion token）。
/// 换一个模型（deepseek）同样如此，所以是**中转层面**的，不是模型挑食。
///
/// 而同一个问题改成「用提示词要求只回 JSON」的纯文本调用，当场就回了
/// `{"segment": "...", "query": "...", "sort": "..."}`，干干净净。
///
/// 结论：对 OpenAI 兼容端点，**提示词契约 + 防御式解析**才是能用的那条路，
/// `outputSchema` 只在真支持的那几家（Anthropic / Google 走工具调用编排，
/// 官方 OpenAI 走 response_format）上可靠。
///
/// # 要对付的三种形状
///
/// 1. 干净的 `{...}`；
/// 2. ` ```json\n{...}\n``` ` 围栏（最常见，第一次实测就撞上了）；
/// 3. 前后带一两句废话的 `好的，这是结果：{...} 希望有帮助`。
Map<String, dynamic>? extractJsonObject(String raw) {
  final text = stripCodeFence(raw).trim();
  if (text.isEmpty) return null;

  // 先按整段试一次：绝大多数情况这就成了，不必走扫描。
  final direct = _tryDecodeObject(text);
  if (direct != null) return direct;

  // ⭐ 取**最后一个**解得开的对象，不是第一个：要求模型「先说几句再交 JSON」
  // 之后（AiRequest.thinkAloud），前面那几句话里偶尔会冒出一对花括号（它在
  // 复述语法），那一段解不开或解出来不是答案；答案永远在最后。
  Map<String, dynamic>? last;
  var from = 0;
  while (true) {
    final span = _firstBalancedObject(text, from);
    if (span == null) {
      final open = text.indexOf('{', from);
      if (open < 0) break;
      // ⛔ 配不平有两种来头，要分开：
      // - 被截断的答案（撞上 maxTokens，外层没合上）：它以 `{"` 开头。后面的
      //   `{` 全在它里面，往里扫会撞上某条筛选 `{"field":…}`——配得平、解得开，
      //   却不是答案。所以到此为止，交给调用方按「没解出来」报原文；它前面
      //   若有一份完整的（上一轮工具调用前的草稿），也已经过时，一并作废。
      // - 话里一只落单的 `{`（「用 { 括起来」）：跳过它，后面的答案照样认。
      if (_jsonObjectStart.hasMatch(text.substring(open))) return null;
      from = open + 1;
      continue;
    }
    // ⛔ 解不开也整段跳过，不往里钻：钻进去会把答案里的某一条筛选当成答案。
    last = _tryDecodeObject(text.substring(span.start, span.end)) ?? last;
    from = span.end;
  }
  return last;
}

/// 像一个 JSON 对象的开头：`{` 后面（隔着空白）紧跟一个键的引号，或直接合上。
final RegExp _jsonObjectStart = RegExp(r'^\{\s*("|\})');

Map<String, dynamic>? _tryDecodeObject(String text) {
  try {
    final decoded = jsonDecode(text);
    if (decoded is Map) return decoded.cast<String, dynamic>();
  } catch (_) {
    // 交给调用方按"没解出来"处理
  }
  return null;
}

/// 去掉 Markdown 代码围栏。
///
/// ⛔ 只在**整段就是一个围栏块**时才剥。文本里夹着围栏的情况交给
/// [_firstBalancedObject] 扫——在这里贪心地删所有 ``` 会把正文里
/// 合法的反引号一起吃掉。
String stripCodeFence(String raw) {
  final text = raw.trim();
  if (!text.startsWith('```')) return text;

  final firstBreak = text.indexOf('\n');
  if (firstBreak < 0) return text;

  // 首行是 ``` 或 ```json 这类语言标注，整行丢掉
  final withoutOpen = text.substring(firstBreak + 1);
  final closing = withoutOpen.lastIndexOf('```');
  if (closing < 0) return withoutOpen.trim();
  return withoutOpen.substring(0, closing).trim();
}

/// 扫出第一个**括号配平**的 `{...}`。
///
/// ⛔ 不能用 `indexOf('{')` + `lastIndexOf('}')`：模型经常在 JSON 后面再补一句
/// 带花括号的解释，那样会把两段之间的废话一起圈进来。也不能无视字符串——
/// 值里出现的 `}`（比如 `"note": "a} b"`）会让计数提前归零。
({int start, int end})? _firstBalancedObject(String text, [int from = 0]) {
  final start = text.indexOf('{', from);
  if (start < 0) return null;

  var depth = 0;
  var inString = false;
  var escaped = false;

  for (var i = start; i < text.length; i++) {
    final ch = text[i];

    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (ch == r'\') {
        escaped = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }

    if (ch == '"') {
      inString = true;
    } else if (ch == '{') {
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0) return (start: start, end: i + 1);
    }
  }
  return null;
}
