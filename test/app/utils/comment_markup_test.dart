import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';

void main() {
  test('compose -> parse 往返认得出小尾巴（含长签名/多行签名）', () {
    const long = '这是一句相当长的签名文本，长到足够越过四十个字符那条启发式的界线，从前认不出来。';
    final raw = CommentMarkup.compose(body: '正文一行', signature: long);
    expect(raw.contains('\n\n---  \n\n'), isTrue, reason: raw);
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.footer, long);
    expect(parsed.body, '正文一行');
  });

  test('⛔ 正文里的分隔线不许被硬化成记号（否则正文后半段会被判成签名）', () {
    // hardenLineBreaks 早先会给「下一行不是空行」的 --- 补上两个空格，造出一条
    // 和记号一模一样的赝品。判据是「`---  ` 以下即小尾巴」，所以赝品必须从
    // **生产端**杜绝：硬化时跳过分隔线。
    const tail = '这是一段相当长的正文结尾，超过四十个字符，绝不该被当成谁的签名给灰掉。';
    final raw = CommentMarkup.compose(body: 'foo\n---\n$tail');
    expect(raw.contains('---  '), isFalse, reason: raw);
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.footer, isNull, reason: raw);
    expect(parsed.body.contains(tail), isTrue);
  });

  test('⛔ 多行小尾巴要整段进脚注，不许只认最后一行', () {
    // 用户截图里的形状：小尾巴是两行，第二行自带 `——` 前缀。早先 _detectFooter
    // 从后往前找最后一条分隔线，于是第一行被留在正文里用正文字号黑压压显示，
    // 只有第二行进了脚注。
    const sig = '先把日子过热乎了再说。\n—— 廉价的自尊、粗劣的傲气，无论哪里都不值钱';
    final raw = CommentMarkup.compose(body: '123', signature: sig);
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.body, '123');
    // 小尾巴也过 hardenLineBreaks（见下一条测试），所以第一行多了硬换行记号
    expect(CommentMarkup.softenLineBreaks(parsed.footer!), sig);
  });

  test('⛔ 小尾巴与引用头也要硬化换行，不能只硬化正文', () {
    // 早先 compose 只给正文加了 hardenLineBreaks，于是一条多行的小尾巴在我们
    // 这儿分行（渲染时 replaceNewlines 全当硬换行）、在 iwara 网页端折成一坨。
    final raw = CommentMarkup.compose(
      body: '正文',
      quote: const ReplyQuote(floor: 7, username: 'bob', excerpt: '原话'),
      signature: '第一行\n第二行',
    );
    expect(raw.contains('> Reply #7: @bob  \n'), isTrue, reason: raw);
    expect(raw.contains('第一行  \n第二行'), isTrue, reason: raw);

    // 硬化不许破坏识别：三段照样拆得回来
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.quote?.floor, 7);
    expect(parsed.body, '正文');
    expect(CommentMarkup.softenLineBreaks(parsed.footer!), '第一行\n第二行');
  });

  test('⛔ 编辑往返稳定：soften → compose 不许越编越脏', () {
    // 编辑模式把全文摊进输入框（softenLineBreaks），保存时整条再过一遍
    // compose。这条链路必须是不动点，否则每保存一次就多硬化 / 多补一个空行。
    final first = CommentMarkup.compose(
      body: '正文一\n正文二',
      quote: const ReplyQuote(floor: 7, username: 'bob', excerpt: '原话'),
      signature: '签名一\n---\n签名二',
    );
    final again = CommentMarkup.compose(
      body: CommentMarkup.softenLineBreaks(first).trim(),
    );
    expect(again, first);
    // 再来一轮，确认真的收敛
    expect(
      CommentMarkup.compose(body: CommentMarkup.softenLineBreaks(again).trim()),
      first,
    );
  });

  test('⛔ 小尾巴内部自带 `---` 时仍从**第一条**记号切开', () {
    const sig = '先把日子过热乎了再说。\n---\n廉价的自尊、粗劣的傲气';
    final raw = CommentMarkup.compose(body: '123', signature: sig);
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.body, '123');
    // 扶正只补了一个空行，内容一个字没动
    expect(parsed.footer, '先把日子过热乎了再说。\n\n---\n廉价的自尊、粗劣的傲气');
  });

  group('⛔ setext H2 陷阱：紧跟文本的 `---` 从来不是分隔线', () {
    test('小尾巴里的 `---` 要补空行扶正，否则前一行变成大标题、线根本不出现', () {
      final raw = CommentMarkup.compose(body: '123', signature: '一言。\n---\n出处');
      // 补了空行 → 真的是 thematic break
      expect(raw.contains('一言。\n\n---\n出处'), isTrue, reason: raw);
      // ⛔ 绝不能再出现「文字行紧跟 ---」那种形状
      expect(RegExp(r'[^\n]\n-{3,}\s*\n').hasMatch(raw), isFalse, reason: raw);
    });

    test('正文里的 `---` 同样扶正', () {
      final raw = CommentMarkup.compose(body: 'foo\n---\nbar');
      expect(RegExp(r'[^\n]\n-{3,}\s*\n').hasMatch(raw), isFalse, reason: raw);
    });

    test('本来就独立成段的 `---` 不重复补空行', () {
      const text = 'foo\n\n---\n\nbar';
      expect(CommentMarkup.normalizeThematicBreaks(text), text);
    });

    test('围栏代码块里的 `---` 不动（那是代码）', () {
      const text = '```\nfoo\n---\nbar\n```';
      expect(CommentMarkup.normalizeThematicBreaks(text), text);
    });
  });

  test('旧格式（裸 ---）仍走启发式认得出', () {
    const raw = '正文\n\n---\nSent from App';
    expect(CommentMarkup.parse(raw).footer, 'Sent from App');
  });

  test('引用 + 正文 + 小尾巴三段往返', () {
    final raw = CommentMarkup.compose(
      body: '回一句',
      quote: const ReplyQuote(floor: 7, username: 'bob', excerpt: '原话'),
      signature: 'Sent from App',
    );
    final parsed = CommentMarkup.parse(raw);
    expect(parsed.quote?.floor, 7);
    expect(parsed.quote?.username, 'bob');
    expect(parsed.body, '回一句');
    expect(parsed.footer, 'Sent from App');
  });
}
