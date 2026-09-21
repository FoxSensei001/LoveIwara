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

import 'package:i_iwara/app/utils/signature_template.dart';
import 'package:i_iwara/common/constants.dart';

/// 一条回复所指向的楼层。
class ReplyQuote {
  const ReplyQuote({required this.floor, required this.username, this.excerpt});

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

  /// ⭐ **我们自己**发出去的那条小尾巴分隔线：`---` 后面跟两个空格。
  ///
  /// 行尾空白在 markdown 里对分隔线毫无影响（`---`/`---  ` 都是 `<hr>`），我们
  /// 自己的渲染器、iwara 网页端、第三方客户端看到的东西一个像素都没变；但它给了
  /// [parse] 一个**确定的记号**：认出这一行就等于认出「下面那段是小尾巴」，
  /// 不必再走 [_detectFooter] 那套「短于 40 字、不以句号收尾、只有一行」的
  /// 启发式去猜。长签名、多行签名从此也认得出来。
  ///
  /// ⚠️ 只是记号，不是保证：分隔线仍可能被别的客户端重排、被服务端 trim 掉行尾
  /// 空白。认不出就退回启发式，与加这条之前完全一样，不会更差。
  static const String signatureBreak = '---  ';

  /// 认 [signatureBreak] 的正则。前导空格按 markdown 规矩放到 3 个，行尾至少
  /// 两个空白——一个空格是软换行的残留，两个才是我们刻意留的记号。
  static final RegExp _signatureBreakPattern = RegExp(
    r'^ {0,3}(?:-{3,}|\*{3,}|_{3,})[ \t]{2,}$',
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
  /// [harden] 为真时把软换行写死成硬换行，见 [hardenLineBreaks]。
  ///
  /// ⛔ **三段一视同仁**，别再只硬化正文。早先这里只给正文加了这一道，于是
  /// 一条多行的小尾巴（或带摘要的引用头）在我们这儿是分行的、在 iwara 网页端
  /// 折成一坨——那正是 [hardenLineBreaks] 当初要根治的割裂，只是漏掉了另外
  /// 两段（2026-09-21 比对网页端渲染时查出）。
  static String compose({
    required String body,
    ReplyQuote? quote,
    String? signature,
    bool harden = true,
  }) {
    final blocks = <String>[];

    // ⛔ 先把 `---` 扶正（补空行）再硬化：顺序反了的话 `foo↵---` 里的 foo 已经
    // 被判成 setext 标题行，补空行也救不回读者看到的东西。见
    // [normalizeThematicBreaks]。
    String prepare(String text) {
      final normalized = normalizeThematicBreaks(text);
      return harden ? hardenLineBreaks(normalized) : normalized;
    }

    if (quote != null) {
      blocks.add(prepare(buildQuoteBlock(quote)));
    }

    final trimmedBody = body.trim();
    if (trimmedBody.isNotEmpty) {
      blocks.add(prepare(trimmedBody));
    }

    final trimmedSignature = signature?.trim();
    if (trimmedSignature != null && trimmedSignature.isNotEmpty) {
      // 小尾巴自带的前导 `---` 去掉，由这里统一补——旧默认值
      // `'\n\n---\nSent from …'` 就带着一条，不去掉会出现两条分隔线。
      // 小尾巴同样要扶正：用户的模板里常常自己排一条线分隔两个数据源。
      final stripped = prepare(_stripLeadingThematicBreak(trimmedSignature));
      if (stripped.isNotEmpty) {
        // 带记号的分隔线，见 [signatureBreak]。
        blocks.add(signatureBreak);
        blocks.add(stripped);
      }
    }

    return blocks.join('\n\n');
  }

  /// 让独立成行的 `---` 真的成为一条分隔线。
  ///
  /// ⛔ markdown 里「一行文字 + 紧跟一行 `---`」是 **setext H2 下划线**：那行字
  /// 会变成大标题，而分隔线**从来不会出现**——在我们这儿如此，在 iwara 网页端
  /// 也如此。用户在小尾巴模板里写 `---` 的意思一律是「画条线」，所以补一个空行
  /// 把它还原成 thematic break（2026-09-21 用户的组合小尾巴就撞在这上面：
  /// `一言。↵---↵另一句`，两端都没有线，只有一个大标题）。
  ///
  /// 围栏代码块里的内容不动——那里面的 `---` 是代码。
  static String normalizeThematicBreaks(String text) {
    final lines = text.split('\n');
    final out = <String>[];
    var inFence = false;

    for (final line in lines) {
      if (RegExp(r'^\s*(?:```|~~~)').hasMatch(line)) {
        inFence = !inFence;
        out.add(line);
        continue;
      }
      if (!inFence &&
          _thematicBreakPattern.hasMatch(line) &&
          out.isNotEmpty &&
          out.last.trim().isNotEmpty) {
        out.add('');
      }
      out.add(line);
    }

    return out.join('\n');
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
          line.endsWith('  ') ||
          // ⛔ 分隔线一律不硬化。行尾两个空格对一条 `---` 本来就没有意义
          // （硬换行是行内的事，分隔线是块级元素），而硬化它的代价很大：
          // 正文里写 `foo↵---↵bar` 会被补成 `---  `，和小尾巴那条记号一模
          // 一样，于是人家正文后半段被判成签名灰掉。
          //
          // ⭐ 不生产赝品，记号就不必再验上下文——小尾巴的判据因此可以就是
          // 「`---  ` 以下的部分」这一句话（2026-09-21 用户明确）。
          _thematicBreakPattern.hasMatch(line)) {
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
  ///
  /// ⛔ **分隔线一行原样留着**，别顺手把它也软化了。`---  ` 行尾那两个空格不是
  /// 硬换行的残留，是 [signatureBreak] 那个记号本身。编辑模式把全文摊进输入框
  /// 时会过这一道——抹掉的话用户只是点开编辑再保存一次，小尾巴的记号就没了，
  /// 下次渲染只能退回启发式，多行小尾巴从此被当成正文黑压压地显示
  /// （2026-09-21 往返测试查出）。
  static String softenLineBreaks(String text) {
    final lines = text.split('\n');
    var inFence = false;
    return lines
        .map((line) {
          if (RegExp(r'^\s*(?:```|~~~)').hasMatch(line)) {
            inFence = !inFence;
            return line;
          }
          if (inFence || _thematicBreakPattern.hasMatch(line)) return line;
          return line.replaceFirst(RegExp(r'[ \t]+$'), '');
        })
        .join('\n');
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
  /// ⭐ 分两趟，方向相反，这是本方法唯一需要记住的事：
  ///
  /// - **第一趟从前往后**，找「有把握」的那条（带记号 / 逐字对上 / 骨架对上）。
  ///   有把握时要的是**最早**那条——小尾巴自己可以多行、中间还能有 `---`，
  ///   取最后一条会把小尾巴的前半段留在正文里。
  /// - **第二趟从后往前**，跑启发式，用来猜别人的评论。没把握时把更少的东西
  ///   判成签名更安全。
  ///
  /// 启发式那三条刻意收得很紧。误判的代价是把人家正文的结尾段落灰掉——那比
  /// 「没认出签名、照常整段显示」难看得多：
  ///
  /// 1. 必须是**最后**一条分隔线，且前面真的有正文；
  /// 2. 后面只剩**一行**，不超过 [_footerMaxChars] 个字；
  /// 3. 那一行不以句末标点收尾（签名不会写「。」，正文结尾常常会）。
  ///
  /// [knownSignature] 逐字对上时直接放行，不走上面的启发式——自己发的评论
  /// 我们知道确切答案，没必要猜。
  ///
  /// 小尾巴带 `{变量}` 时逐字是对不上的（每条发出去的都不一样），改用模板编译
  /// 出的骨架正则去认；骨架太短（整条都是变量）会退回下面的启发式，理由见
  /// [SignatureTemplate.toMatchPattern]。
  static int? _detectFooter(List<String> lines, {String? knownSignature}) {
    final expected = _stripLeadingThematicBreak(knownSignature?.trim() ?? '');
    final expectedPattern = expected.isEmpty
        ? null
        : SignatureTemplate.matchPatternOf(expected);

    /// 能当分隔线的那些行：前面有正文、后面有东西。
    bool usable(int i) {
      if (!_thematicBreakPattern.hasMatch(lines[i])) return false;
      if (lines.sublist(i + 1).join('\n').trim().isEmpty) return false;
      // 分隔线前面必须真的有正文，否则整条评论就只剩一个签名了
      if (lines.sublist(0, i).join('\n').trim().isEmpty) return false;
      return true;
    }

    // ---- 第一趟：从**最早**的分隔线找起，找有把握的那条 ----
    //
    // ⛔ 方向是刻意的，别改回从后往前。小尾巴自己可以是**多行、且中间带
    // `---`**（用户的模板想怎么排就怎么排）。从后往前找会停在小尾巴内部那条
    // 分隔线上，于是小尾巴的前半段被当成正文，用正文的字号黑压压地显示出来，
    // 只有最后一行进了脚注（2026-09-21 用户截图）。
    //
    // 有把握＝下面三条之一，都不是启发式：
    //   a. 这条分隔线带着我们的记号；
    //   b. 尾巴与本机配置里那条小尾巴逐字相同；
    //   c. 尾巴对得上小尾巴模板编译出的骨架正则。
    for (var i = 1; i < lines.length; i++) {
      if (!usable(i)) continue;
      final tail = lines.sublist(i + 1).join('\n').trim();

      // ⭐ **小尾巴的判据就是这一句：`---  ` 以下的部分**（三横杠两空格，
      // [signatureBreak]）。这条分隔线是我们（或另一个装了本 App 的人）拼
      // 出来的，下面那段确定是小尾巴，不必再拿启发式去猜。
      //
      // 早先这里还要求「上下都是空行」，因为 [hardenLineBreaks] 会把正文里的
      // `foo↵---↵bar` 补成 `---  `，造出赝品。那条约束现在没有了——改成
      // **不生产赝品**（硬化时跳过分隔线），判据因此能回到用户说的那一句。
      if (_signatureBreakPattern.hasMatch(lines[i])) return i;

      if (expected.isNotEmpty && tail == expected) return i;
      if (expectedPattern != null && expectedPattern.hasMatch(tail)) return i;
    }

    // ---- 第二趟：启发式，只认**最后**一条分隔线 ----
    //
    // 这一趟是拿来猜别人的评论的，所以判据收得很紧（见本方法的文档）。
    // 从后往前是对的：没有任何把握时，把更少的东西判成签名更安全。
    for (var i = lines.length - 1; i > 0; i--) {
      if (!usable(i)) continue;
      final tail = lines.sublist(i + 1).join('\n').trim();

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
