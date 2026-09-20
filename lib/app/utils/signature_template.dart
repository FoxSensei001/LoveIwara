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
  static const int maxVariableLength = 100;

  /// 渲染结果的总长上限。
  static const int maxRenderedLength = 300;

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
  String render(
    Map<String, String> values, {
    bool keepUnknown = false,
    bool clampLength = true,
  }) {
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
            }
            continue;
          }
          final value = sanitizeValue(raw, escapeBlockStart: atLineStart);
          if (value.isEmpty) continue;
          buffer.write(value);
          atLineStart = false;
      }
    }

    var out = buffer
        .toString()
        // 变量整段消失后常留下并排的空格 / 悬着的标点前空格，收一收
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();

    if (clampLength && out.length > maxRenderedLength) {
      out = '${out.substring(0, maxRenderedLength - 1).trimRight()}…';
    }
    return out;
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
    for (final token in tokens) {
      switch (token) {
        case SignatureLiteral(:final text):
          // 空白按「一段空白」匹配：变量消失后两侧空格会被 render 收掉，
          // 这里照原样卡空格数的话就对不上了。
          final parts = text.split(RegExp(r'\s+'));
          buffer.write(
            parts.where((p) => p.isNotEmpty).map(RegExp.escape).join(r'\s*'),
          );
          if (parts.isNotEmpty && parts.last.isEmpty) buffer.write(r'\s*');
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
