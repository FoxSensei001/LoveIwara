/// 评论 / 回复正文的**结构契约**。
///
/// 这里是「引用头」「用户正文」「小尾巴」三段结构的唯一权威：怎么拼出去、
/// 怎么从别人发的原文里认回来，都只在这一个文件里说了算。调用方（composer、
/// 评论卡片、论坛楼层卡片）一律走这里，不要再各自拼字符串——那正是旧版
/// `'Reply #N: @x\n---\n'` 散落在调用点、语法还是错的根因。
///
/// ## 为什么是这个格式
///
/// 我们发出去的文本会被三个渲染器读：我们自己的 [CustomMarkdownBody]、
/// iwara 网页端、以及别的第三方客户端。2026-09-20 拿 iwara 网页端自带的
/// 「预览」实测过下面几条（输入 → 网页端输出的 HTML）：
///
/// ```text
/// > 引用行                →  <blockquote><p>…</p></blockquote>   ✅ 原生支持
/// 空行 + ---              →  <hr>                                 ✅
/// 文本行紧跟 ---          →  <div class="text text--h2">文本行</div>
/// ```
///
/// 最后一条是旧模板的死因：`---` 紧跟在文本行下面时，它是 **setext 二级标题
/// 的下划线**，不是分隔线。所以旧模板 `Reply #N: @x\n---\n` 在我们这儿和网页端
/// 都渲染成一个大标题，那条分隔线**从来没出现过**；用户再在 `---` 行尾打字，
/// 连标题都不成立，整块塌成一段字面量。两头都错，不是用户用错。
///
/// 新格式改用 markdown 引用块承载引用头，块与块之间一律留空行，三个渲染器
/// 表现一致。
///
/// ## 软换行
///
/// iwara 网页端按标准 markdown 办事：单个 `\n` 是软换行，折成空格。我们的
/// [MarkdownFormatter.replaceNewlines] 却在**渲染时**把每个 `\n` 变成硬换行，
/// 于是同一条评论在我们这儿分行、在网页端连成一坨。[hardenLineBreaks] 把这件事
/// 挪到**发送时**做：写死进发出去的原文，两端从此看到同一个排版。
library;

import 'package:i_iwara/common/constants.dart';

/// 一条回复所指向的楼层。
class ReplyQuote {
  const ReplyQuote({
    required this.floor,
    required this.username,
    this.excerpt,
  });

  /// 楼层号（展示用，与 iwara 的 `replyNum + 1` 一致）。
  final int floor;

  /// 被回复者用户名，不含 `@`。
  final String username;

  /// 被回复内容的一行摘要，可空。
  final String? excerpt;

  @override
  bool operator ==(Object other) =>
      other is ReplyQuote &&
      other.floor == floor &&
      other.username == username &&
      other.excerpt == excerpt;

  @override
  int get hashCode => Object.hash(floor, username, excerpt);
}

/// [CommentMarkup.parse] 的结果：把一坨原文拆成可以分别呈现的三段。
class ParsedComment {
  const ParsedComment({
    required this.raw,
    required this.body,
    this.quote,
    this.footer,
  });

  /// 原始全文，没动过。「显示原始文本」那条路要用它。
  final String raw;

  /// 剥掉引用头与小尾巴之后，作者自己写的那部分。
  final String body;

  /// 认出来的引用头；认不出就是 null。
  final ReplyQuote? quote;

  /// 认出来的小尾巴（不含分隔线）；认不出就是 null。
  final String? footer;

  /// 是否有任何一段被剥离——卡片据此决定要不要画引用条 / 脚注行。
  bool get hasStructure => quote != null || footer != null;
}

class CommentMarkup {
  CommentMarkup._();

  /// 引用头首行。保持 `Reply #N: @user` 这个**英文**措辞不随语言变：
  /// 它要被我们自己的 [parse] 认回来，也要被网页端的国际读者看懂，还要能
  /// 认出历史数据——那些早就发出去的旧格式回复用的正是这行字。
  static final RegExp _quoteHeadPattern = RegExp(
    r'^\s*Reply\s*#(\d+)\s*[:：]?\s*@(\S+?)\s*$',
  );

  /// 只含分隔线的一行（`---` / `***` / `___`，允许行尾硬换行留下的空格）。
  static final RegExp _thematicBreakPattern = RegExp(
    r'^\s*(?:-{3,}|\*{3,}|_{3,})\s*$',
  );

  /// 摘要里出现的图片/表情 markdown。整段留在引用里会在引用条里塞进一张图，
  /// 摘要要的是「一眼认出回的是哪条」，不是复刻原文。
  static final RegExp _imageMarkdownPattern = RegExp(r'!\[[^\]]*\]\([^)]*\)');

  /// 摘要最多保留多少个字符。按中日文算，40 字已经够占满引用条两行。
  static const int _excerptMaxChars = 40;

  /// 小尾巴最长多少字才认。
  static const int _footerMaxChars = 40;

  /// 句末标点。签名不会以句号收尾，正文的结尾段落常常会——这是把两者分开
  /// 最省事也最不容易误伤的一条线索。
  static final RegExp _sentenceEndPattern = RegExp(r'[。．！？!?…]\s*$');

  /// 把一段被回复的正文压成可以塞进引用块的一行摘要。
  static String? buildExcerpt(String? source) {
    if (source == null) return null;
    var text = source
        .replaceAll(_imageMarkdownPattern, '')
        // 引用别人的引用会套娃，只留最内层的文字
        .replaceAll(RegExp(r'^\s*>+\s?', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) return null;
    if (text.length > _excerptMaxChars) {
      text = '${text.substring(0, _excerptMaxChars).trimRight()}…';
    }
    return text;
  }

  /// 拼出引用块。末尾**不带**空行，空行由 [compose] 统一负责。
  static String buildQuoteBlock(ReplyQuote quote) {
    final lines = <String>['Reply #${quote.floor}: @${quote.username}'];
    final excerpt = quote.excerpt;
    if (excerpt != null && excerpt.isNotEmpty) {
      lines.add(excerpt);
    }
    return lines.map((l) => '> $l').join('\n');
  }

  /// 把三段拼成真正发出去的那串字。
  ///
  /// 块与块之间一律空行隔开——这是 `---` 能成为分隔线而不是 setext 下划线的
  /// 唯一条件，也是网页端分段的唯一依据。
  ///
  /// [hardenBody] 为真时把正文里的软换行写死成硬换行，见 [hardenLineBreaks]。
  static String compose({
    required String body,
    ReplyQuote? quote,
    String? signature,
    bool hardenBody = true,
  }) {
    final blocks = <String>[];

    if (quote != null) {
      blocks.add(buildQuoteBlock(quote));
    }

    final trimmedBody = body.trim();
    if (trimmedBody.isNotEmpty) {
      blocks.add(hardenBody ? hardenLineBreaks(trimmedBody) : trimmedBody);
    }

    final trimmedSignature = signature?.trim();
    if (trimmedSignature != null && trimmedSignature.isNotEmpty) {
      // 小尾巴自带的前导 `---` 去掉，由这里统一补——旧默认值
      // `'\n\n---\nSent from …'` 就带着一条，不去掉会出现两条分隔线。
      final stripped = _stripLeadingThematicBreak(trimmedSignature);
      if (stripped.isNotEmpty) {
        blocks.add('---');
        blocks.add(stripped);
      }
    }

    return blocks.join('\n\n');
  }

  /// 把**用户自己打的**软换行写死成 markdown 硬换行（行尾两个空格）。
  ///
  /// 只动正文，不动围栏代码块里的内容——在 ``` 块里加行尾空格会污染代码。
  /// 已经是硬换行的行、空行、以及最后一行都不再加。
  static String hardenLineBreaks(String text) {
    final lines = text.split('\n');
    var inFence = false;
    final out = <String>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (RegExp(r'^\s*(?:```|~~~)').hasMatch(line)) {
        inFence = !inFence;
        out.add(line);
        continue;
      }

      final isLast = i == lines.length - 1;
      final nextIsBlank = !isLast && lines[i + 1].trim().isEmpty;

      if (inFence ||
          isLast ||
          line.trim().isEmpty ||
          nextIsBlank ||
          line.endsWith('  ')) {
        out.add(line);
        continue;
      }

      out.add('$line  ');
    }

    return out.join('\n');
  }

  /// [hardenLineBreaks] 的逆操作：把行尾用来表示硬换行的空格抹掉。
  ///
  /// 编辑已发布的评论时要先过这一道，否则用户在输入框里看到的每一行都挂着
  /// 看不见的空格，再提交一次又硬化一层，越编越脏。
  /// 和 [hardenLineBreaks] 一样跳过围栏代码块：那里头的行尾空格是内容。
  static String softenLineBreaks(String text) {
    final lines = text.split('\n');
    var inFence = false;
    return lines.map((line) {
      if (RegExp(r'^\s*(?:```|~~~)').hasMatch(line)) {
        inFence = !inFence;
        return line;
      }
      return inFence ? line : line.replaceFirst(RegExp(r'[ \t]+$'), '');
    }).join('\n');
  }

  /// 从一坨原文里把引用头与小尾巴认回来。
  ///
  /// 认得出新格式（markdown 引用块）也认得出旧格式（裸 `Reply #N: @x` 首行
  /// 加不加 `---` 都算），所以**早就发出去的历史回复**一样能被美化，不需要
  /// 迁移数据。认不出来就原样退回，[ParsedComment.body] 等于全文。
  ///
  /// [knownSignature] 是本机用户自己配置的小尾巴。自己发的评论不必猜，逐字
  /// 对上就算；别人发的才走 [_detectFooter] 那套保守判据。
  static ParsedComment parse(String raw, {String? knownSignature}) {
    var lines = raw.split('\n');
    ReplyQuote? quote;

    // ---- 引用头 ----
    final quoteEnd = _detectQuoteHead(lines);
    if (quoteEnd != null) {
      quote = quoteEnd.quote;
      lines = lines.sublist(quoteEnd.consumedLines);
      // 引用块后面紧跟的空行 / 旧格式那条分隔线一并吃掉
      while (lines.isNotEmpty &&
          (lines.first.trim().isEmpty ||
              _thematicBreakPattern.hasMatch(lines.first))) {
        lines = lines.sublist(1);
      }
    }

    // ---- 小尾巴 ----
    String? footer;
    final footerStart = _detectFooter(lines, knownSignature: knownSignature);
    if (footerStart != null) {
      footer = lines.sublist(footerStart + 1).join('\n').trim();
      lines = lines.sublist(0, footerStart);
    }

    return ParsedComment(
      raw: raw,
      body: lines.join('\n').trim(),
      quote: quote,
      footer: (footer == null || footer.isEmpty) ? null : footer,
    );
  }

  /// 识别开头的引用头，返回引用对象与它占掉了几行；不是引用头就返回 null。
  static ({ReplyQuote quote, int consumedLines})? _detectQuoteHead(
    List<String> lines,
  ) {
    var start = 0;
    while (start < lines.length && lines[start].trim().isEmpty) {
      start++;
    }
    if (start >= lines.length) return null;

    final first = lines[start];
    final isBlockquote = RegExp(r'^\s*>').hasMatch(first);
    final headText = isBlockquote
        ? first.replaceFirst(RegExp(r'^\s*>\s?'), '')
        : first;

    final match = _quoteHeadPattern.firstMatch(headText);
    if (match == null) return null;

    final floor = int.tryParse(match.group(1)!);
    if (floor == null) return null;
    final username = match.group(2)!;

    var consumed = start + 1;
    final excerptLines = <String>[];

    if (isBlockquote) {
      // 新格式：引用块里剩下的行都是摘要
      while (consumed < lines.length &&
          RegExp(r'^\s*>').hasMatch(lines[consumed])) {
        excerptLines.add(
          lines[consumed].replaceFirst(RegExp(r'^\s*>\s?'), '').trim(),
        );
        consumed++;
      }
    }

    final excerpt = buildExcerpt(
      excerptLines.where((l) => l.isNotEmpty).join(' '),
    );

    return (
      quote: ReplyQuote(floor: floor, username: username, excerpt: excerpt),
      consumedLines: consumed,
    );
  }

  /// 找出小尾巴那条分隔线在第几行；没有就返回 null。
  ///
  /// 判据刻意收得很紧。误判的代价是把人家正文的结尾段落灰掉——那比「没认出
  /// 签名、照常整段显示」难看得多，所以每一条都往严了卡：
  ///
  /// 1. 必须是**最后**一条分隔线，且前面真的有正文；
  /// 2. 后面只剩**一行**，不超过 [_footerMaxChars] 个字；
  /// 3. 那一行不以句末标点收尾（签名不会写「。」，正文结尾常常会）。
  ///
  /// [knownSignature] 逐字对上时直接放行，不走上面的启发式——自己发的评论
  /// 我们知道确切答案，没必要猜。
  static int? _detectFooter(List<String> lines, {String? knownSignature}) {
    final expected = _stripLeadingThematicBreak(knownSignature?.trim() ?? '');

    for (var i = lines.length - 1; i > 0; i--) {
      if (!_thematicBreakPattern.hasMatch(lines[i])) continue;

      final tail = lines.sublist(i + 1).join('\n').trim();
      if (tail.isEmpty) return null;

      // 分隔线前面必须真的有正文，否则整条评论就只剩一个签名了
      if (lines.sublist(0, i).join('\n').trim().isEmpty) return null;

      if (expected.isNotEmpty && tail == expected) return i;

      if (tail.contains('\n')) return null;
      if (tail.length > _footerMaxChars) return null;
      if (_sentenceEndPattern.hasMatch(tail)) return null;

      return i;
    }
    return null;
  }

  static String _stripLeadingThematicBreak(String text) {
    final lines = text.split('\n');
    var start = 0;
    while (start < lines.length &&
        (lines[start].trim().isEmpty ||
            _thematicBreakPattern.hasMatch(lines[start]))) {
      start++;
    }
    return lines.sublist(start).join('\n').trim();
  }

  /// 小尾巴设置项的出厂值。
  ///
  /// 这里**不再**带前导 `'\n\n---'`：分隔线由 [compose] 统一补，设置项里存的
  /// 就是用户眼里那句话本身。旧配置里带分隔线的值也能用，[compose] 会剥掉。
  static String get defaultSignature =>
      'Sent from ${CommonConstants.applicationNickname}';
}
