/// 小尾巴模板：把用户写的那句话里的 `{变量}` 在**发送那一刻**换成实际值。
///
/// ⛔ 这里的「动态」只发生在按下发送的那一秒。评论一旦发到 Iwara 就是一串死
/// 文本，服务端不会再渲染任何东西——所以能做的是「发送时把 `{date}` 换成今
/// 天」，做不到「评论里的日期以后还会自己走」。
///
/// 语法刻意做得极窄，因为这串东西最终要混进 markdown 里发出去：
///
/// - `{name}`、`{name:参数}`——变量名只认 `[A-Za-z_][A-Za-z0-9_]*`；
/// - `{{` / `}}` 是花括号本身的转义；
/// - 认不出来的变量**原样留着**，不报错也不吞掉。用户打错一个字母时看到的是
///   `{dat}` 而不是一条凭空少了半句的小尾巴，错在哪儿一眼就知道。
///
/// 求值（谁去拿今天的日期、谁去请求一言）不在这里，见 `SignatureService`：
/// 这个文件是纯的、不碰网络也不碰时钟，好让它能被直接测。
library;

/// 模板拆出来的一段。
sealed class SignatureToken {
  const SignatureToken();
}

/// 原样输出的字面量。
class SignatureLiteral extends SignatureToken {
  const SignatureLiteral(this.text);

  final String text;
}

/// 一个待求值的变量。
class SignatureVariable extends SignatureToken {
  const SignatureVariable({required this.name, this.arg, required this.raw});

  /// 变量名，已转小写（`{DATE}` 和 `{date}` 是同一个）。
  final String name;

  /// 冒号后面那段参数，没有就是 null。语义由各变量自己定：`{date:yyyy 年}`
  /// 是格式串，`{pick:a|b|c}` 是候选，`{src:weather}` 是自定义源的 id。
  final String? arg;

  /// 模板里原本那串字（含花括号）。求值失败要原样放回去时用它。
  final String raw;

  /// 求值缓存的键：同一次渲染里 `{hitokoto}` 出现两次只请求一次。
  String get key => arg == null ? name : '$name:$arg';

  @override
  bool operator ==(Object other) =>
      other is SignatureVariable && other.name == name && other.arg == arg;

  @override
  int get hashCode => Object.hash(name, arg);
}

/// 一条解析好的小尾巴模板。
class SignatureTemplate {
  const SignatureTemplate._(this.source, this.tokens);

  /// 用户写的原文。
  final String source;

  final List<SignatureToken> tokens;

  static final RegExp _tokenPattern = RegExp(
    r'\{\{|\}\}|\{([A-Za-z_][A-Za-z0-9_]*)(?::([^}]*))?\}',
  );

  /// 变量值的长度上限。一言可能返回很长一句，自定义接口更是什么都可能返回，
  /// 不封顶的话一条小尾巴能把整条评论顶过服务端的长度上限。
  ///
  /// ⛔ 封的只有**别人给的值**。用户自己写的那些字不封顶：这里曾经还有一条
  /// 「渲染结果总长 300」的闸，它会把一条写长了的小尾巴在发送时悄悄截掉半句，
  /// 而用户在编辑器里看不出任何异样。真正该由谁兜底是清楚的——最终文本超过
  /// 该平台的上限时，`_composeForSubmit` 会把小尾巴收短到放得下为止，
  /// 正文一个字都不动。
  static const int maxVariableLength = 100;

  factory SignatureTemplate.parse(String source) {
    final tokens = <SignatureToken>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isNotEmpty) {
        tokens.add(SignatureLiteral(buffer.toString()));
        buffer.clear();
      }
    }

    var index = 0;
    for (final match in _tokenPattern.allMatches(source)) {
      buffer.write(source.substring(index, match.start));
      index = match.end;

      final raw = match.group(0)!;
      if (raw == '{{') {
        buffer.write('{');
        continue;
      }
      if (raw == '}}') {
        buffer.write('}');
        continue;
      }

      flush();
      tokens.add(
        SignatureVariable(
          name: match.group(1)!.toLowerCase(),
          arg: match.group(2),
          raw: raw,
        ),
      );
    }
    buffer.write(source.substring(index));
    flush();

    return SignatureTemplate._(source, tokens);
  }

  /// 模板里出现过的变量，已按 [SignatureVariable.key] 去重。
  ///
  /// 同一个变量写两遍只求值一次：写两次 `{hitokoto}` 想要两句不同的话，这种
  /// 需求罕见，而多发一次请求的代价是实打实的。
  List<SignatureVariable> get variables {
    final seen = <String>{};
    final out = <SignatureVariable>[];
    for (final token in tokens) {
      if (token is SignatureVariable && seen.add(token.key)) {
        out.add(token);
      }
    }
    return out;
  }

  bool get hasVariables => variables.isNotEmpty;

  /// 把求好的值填回去。
  ///
  /// [values] 里没有的键（求值失败、或者根本不认识这个变量）按 [keepUnknown]
  /// 处理：真发送时传 false（拿不到就当这段不存在），设置页预览时传 true
  /// （让用户看见自己打错的那个变量名）。
  ///
  /// 值为空串的变量一律消失——网络变量取不到时，小尾巴该是少一段，而不是
  /// 留一个空洞或者一串花括号发出去。
  String render(Map<String, String> values, {bool keepUnknown = false}) {
    final buffer = StringBuffer();
    var atLineStart = true;

    for (final token in tokens) {
      switch (token) {
        case SignatureLiteral(:final text):
          buffer.write(text);
          if (text.isNotEmpty) {
            atLineStart = text.endsWith('\n');
          }
        case SignatureVariable():
          final raw = values[token.key];
          if (raw == null) {
            if (keepUnknown) {
              buffer.write(token.raw);
              atLineStart = false;
              continue;
            }
            buffer.write(_gap);
            continue;
          }
          final value = sanitizeValue(raw, escapeBlockStart: atLineStart);
          if (value.isEmpty) {
            buffer.write(_gap);
            continue;
          }
          buffer.write(value);
          atLineStart = false;
      }
    }

    return _closeGaps(buffer.toString())
        // 变量整段消失后常留下并排的空格 / 悬着的标点前空格，收一收
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();
  }

  /// 空变量留下的洞，只在 [render] 内部活着，[_closeGaps] 之后一个都不剩。
  ///
  /// 用私用区码位而不是普通字符：用户的小尾巴里什么都可能有，拿 `\u0000` 之类
  /// 也行，但私用区永远不会出现在真实文本里，调试时也看得见。
  static const String _gap = '\uE000';

  /// 被空变量撑开的包围符。左右一一对应。
  static const String _openers = '《（(「『【[<“‘"\'';
  static const String _closers = '》）)」』】]>”’"\'';

  /// 变量消失后**悬在那儿的连接符**。
  ///
  /// ⛔ 两条都带一个「洞的另一侧必须是空白或端点」的断言。少了它，
  /// `正在看《{title}》 · {date}` 在标题为空时会被收成 `正在看2026-09-21`
  /// ——那个 `·` 分隔的左边其实还剩着「正在看」，凭什么吃掉它。只有当洞那一侧
  /// 确实什么都不剩时，连接符才是悬空的。
  /// ⛔ `-` 必须留在末尾：这串字符要原样塞进字符类 `[$_seps]`，摆在中间就成了
  /// 区间符。同一串还被 [_runLength] 当普通字符集合用，所以里头不能有转义反斜杠。
  static const String _seps = '·•/|,，、:：;；—~～-';
  static final RegExp _danglingBefore = RegExp(
    '[ \\t]*[$_seps]+[ \\t]*\uE000(?![^ \\t\uE000])',
  );
  static final RegExp _danglingAfter = RegExp(
    '(?<![^ \\t\uE000])\uE000[ \\t]*[$_seps]+[ \\t]*',
  );

  /// 把空变量留下的洞连同它撑着的标点一起收掉。
  ///
  /// ⛔ 这是真发送路径上的缺陷，不是预览问题（2026-09-21 发现）：一条写着
  /// `正在看《{title}》` 的小尾巴，在私信这种给不出标题的场合会原样发出
  /// **`正在看《》`**；`看到 {playtime} / {duration}` 会发出 **`看到 /`**。
  /// 上层那条「填不出就整段消失、所以一条模板到处通用」的承诺，卡在标点上。
  ///
  /// 两步，都只动**紧挨着洞**的字符，绝不碰用户写的其余内容：
  ///
  /// 1. 成对包围符：`《`+洞+`》` → 整个没有。只在左右确实配对时才动手，
  ///    所以 `（{a}】` 这种写歪了的不会被误吃。
  /// 2. 悬空连接符：洞任一侧的 `·` `/` `-` 一类，连同两边空白一起吃掉。
  ///    ⛔ 只吃**紧邻**的那一段；`a - b {x}` 里 `a` 与 `b` 之间那个连字号
  ///    离洞隔着字，不在此列。
  static String _closeGaps(String text) {
    if (!text.contains(_gap)) return text;
    var out = text;

    // 成对包围符：可能套了好几层（`「《{title}》」`），收敛到不动为止。
    for (var i = 0; i < _openers.length; i++) {
      final open = RegExp.escape(_openers[i]);
      final close = RegExp.escape(_closers[i]);
      final pattern = RegExp('$open[ \\t]*$_gap+[ \\t]*$close');
      var guard = 0;
      while (pattern.hasMatch(out) && guard++ < 8) {
        out = out.replaceAll(pattern, _gap);
      }
    }

    out = out.replaceAll(_danglingBefore, _gap);
    out = out.replaceAll(_danglingAfter, _gap);

    return out.replaceAll(_gap, '');
  }

  /// 洗一个变量值，让它能安全地待在 markdown 小尾巴里。
  ///
  /// 三件事，每件都堵过一个真会出事的口子：
  ///
  /// 1. **换行压成空格**。值里带换行会把小尾巴撑成多行，而多行小尾巴在评论区
  ///    那边的识别判据里是直接否决项（见 `CommentMarkup._detectFooter`），
  ///    自己的小尾巴反而认不出来了。
  /// 2. **截断**。见 [maxVariableLength]。
  /// 3. **行首块级标记转义**。值落在行首且以 `#` `>` `-` 开头时，markdown 会
  ///    把它渲染成标题 / 引用 / 列表甚至分隔线——一条 `---` 开头的一言能把
  ///    小尾巴自己那条分隔线之后的结构整个搅乱。
  static String sanitizeValue(String value, {bool escapeBlockStart = false}) {
    var text = value.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
    if (text.isEmpty) return '';

    if (text.length > maxVariableLength) {
      text = '${text.substring(0, maxVariableLength - 1).trimRight()}…';
    }

    if (escapeBlockStart && RegExp(r'^[#>\-+*=|]').hasMatch(text)) {
      text = '\\$text';
    }
    return text;
  }

  /// 字面量部分（去掉空白）至少要有这么多字，模板才配拿去做识别用的正则。
  ///
  /// 见 [toMatchPattern]。
  static const int _minLiteralChars = 4;

  /// 编译成一条用来**认出自己的小尾巴**的正则。
  ///
  /// 评论区靠「配置里那句话逐字对上」来判断末尾那段是不是小尾巴（认出来才会
  /// 收进折叠的小字里）。小尾巴一旦带变量，每条发出去的都不一样，逐字比对就
  /// 永远不中——自己的小尾巴会当场混回正文里显示。所以这里把变量位置换成
  /// 通配，用模板的**骨架**去认。
  ///
  /// ⛔ 骨架太短就不认：`{hitokoto}` 这种整条都是变量的模板会编译出一条匹配
  /// 任何东西的正则，拿它去扫别人的评论，会把人家正文的最后一段判成小尾巴灰
  /// 掉。字面量不足 [_minLiteralChars] 个字时返回 null，调用方退回保守启发式。
  RegExp? toMatchPattern() {
    if (!hasVariables) return null;

    final literalChars = tokens
        .whereType<SignatureLiteral>()
        .map((t) => t.text.replaceAll(RegExp(r'\s+'), ''))
        .join()
        .length;
    if (literalChars < _minLiteralChars) return null;

    final buffer = StringBuffer(r'^\s*');
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      switch (token) {
        case SignatureLiteral(:final text):
          // ⛔ 紧挨着变量的那几个标点要写成**可选**的：变量取空时 [_closeGaps]
          // 会把它们连同变量一起吃掉（`正在看《{title}》` 降级成 `正在看`），
          // 照原样卡死的话，自己的小尾巴在给不出上下文的场合就认不出来了
          // ——那正是这条正则要防的事。
          final prevIsVar = i > 0 && tokens[i - 1] is SignatureVariable;
          final nextIsVar =
              i + 1 < tokens.length && tokens[i + 1] is SignatureVariable;

          var body = text;
          var head = '';
          var tail = '';
          if (prevIsVar) {
            final n = _runLength(body, _closers + _seps, fromStart: true);
            head = body.substring(0, n);
            body = body.substring(n);
          }
          if (nextIsVar) {
            final n = _runLength(body, _openers + _seps, fromStart: false);
            tail = body.substring(body.length - n);
            body = body.substring(0, body.length - n);
          }

          buffer.write(_optionalRun(head));
          // 空白按「一段空白」匹配：变量消失后两侧空格会被 render 收掉，
          // 这里照原样卡空格数的话就对不上了。
          final parts = body.split(RegExp(r'\s+'));
          buffer.write(
            parts.where((p) => p.isNotEmpty).map(RegExp.escape).join(r'\s*'),
          );
          if (parts.isNotEmpty && parts.last.isEmpty) buffer.write(r'\s*');
          buffer.write(_optionalRun(tail));
        case SignatureVariable():
          // `{0,}`（可为空）而不是 `{1,}`：网络变量取不到时那一段真的会没有。
          buffer.write('[\\s\\S]{0,$maxVariableLength}?');
      }
    }
    buffer.write(r'\s*$');

    try {
      return RegExp(buffer.toString());
    } on FormatException {
      return null;
    }
  }

  /// [text] 开头 / 结尾连续属于 [chars]（外加空白）的那一段有多长。
  static int _runLength(String text, String chars, {required bool fromStart}) {
    var n = 0;
    while (n < text.length) {
      final c = fromStart ? text[n] : text[text.length - 1 - n];
      if (chars.contains(c) || c.trim().isEmpty) {
        n++;
      } else {
        break;
      }
    }
    return n;
  }

  /// 把一段「可能被吃掉」的字符写成可选的正则片段。
  static String _optionalRun(String text) {
    if (text.isEmpty) return '';
    final parts = text
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map(RegExp.escape)
        .join(r'\s*');
    // 整段都是空白：让它匹配「有或没有空白」即可。
    if (parts.isEmpty) return r'\s*';
    return '(?:\\s*$parts\\s*)?';
  }

  static final Map<String, RegExp?> _patternCache = {};

  /// [toMatchPattern] 的带缓存版本。评论列表每条都要问一次，而模板在一屏之内
  /// 根本不会变，每条都重新编译一次正则纯属浪费。
  static RegExp? matchPatternOf(String template) {
    final key = template.trim();
    if (key.isEmpty) return null;
    if (_patternCache.containsKey(key)) return _patternCache[key];
    if (_patternCache.length > 32) _patternCache.clear();
    return _patternCache[key] = SignatureTemplate.parse(key).toMatchPattern();
  }
}
