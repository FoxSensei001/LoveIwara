import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/signature_template.dart';

/// 小尾巴模板是纯函数，而它有两个「错了也不会有人报错」的地方，值得各钉一颗钉子：
///
/// 1. 变量值要洗干净才能进 markdown（换行、行首的 `#` / `---`）；
/// 2. 识别自己小尾巴用的那条正则，骨架太短时必须**拒绝生成**——否则它会匹配
///    任何东西，把别人评论的最后一段判成签名灰掉。
void main() {
  group('解析与渲染', () {
    test('认出变量、参数，和花括号转义', () {
      final tpl = SignatureTemplate.parse('来自 {platform} {{注意}} {date:yyyy}');
      expect(tpl.variables.map((v) => v.key), ['platform', 'date:yyyy']);
      expect(
        tpl.render({'platform': 'Android', 'date:yyyy': '2026'}),
        '来自 Android {注意} 2026',
      );
    });

    test('同一个变量写两遍只求值一次', () {
      final tpl = SignatureTemplate.parse('{hitokoto} / {hitokoto}');
      expect(tpl.variables.length, 1);
    });

    test('取不到值的变量整段消失，不留空洞也不留花括号', () {
      final tpl = SignatureTemplate.parse('看 {title} 中，今日一言：{hitokoto}');
      // ⭐ 连那个悬在末尾的冒号一起收掉。发出去一句「今日一言：」比少半句更难看，
      // 而上层那条「填不出就整段消失」的承诺本来就不该卡在标点上。
      expect(tpl.render({'title': '某个视频'}), '看 某个视频 中，今日一言');
    });

    test('⭐ 变量撑着的成对包围符与悬空连接符，跟着变量一起消失', () {
      String render(String source, [Map<String, String> values = const {}]) =>
          SignatureTemplate.parse(source).render(values);

      // 成对包围符：整对没有，不留一个空书名号
      expect(render('正在看《{title}》'), '正在看');
      expect(render('正在看《{title}》', {'title': '月光'}), '正在看《月光》');
      // 悬空连接符：两侧都空了才吃，另一侧还剩字就留着
      expect(render('看到 {playtime} / {duration}'), '看到');
      expect(render('今日一言：{hitokoto}'), '今日一言');
      // ⛔ 这一条是前一版的回归：`·` 左边还剩「正在看」，凭什么把它并进日期
      expect(
        render('正在看《{title}》 · {date}', {'date': '2026-09-21'}),
        '正在看 · 2026-09-21',
      );
      // ⛔ 只吃紧挨着洞的那一段，离得远的连字号不许动
      expect(render('a-b {title}'), 'a-b');
    });

    test('⭐ 降级后的小尾巴仍认得出是自己的（骨架正则要容忍被吃掉的标点）', () {
      final pattern = SignatureTemplate.matchPatternOf(
        '正在看《{title}》 · {date}',
      )!;
      expect(pattern.hasMatch('正在看《月光下的旋转》 · 2026-09-21'), isTrue);
      expect(pattern.hasMatch('正在看 · 2026-09-21'), isTrue);
      // 老版本已经发出去的那些（带空书名号）也要继续认得
      expect(pattern.hasMatch('正在看《》 · 2026-09-21'), isTrue);
      expect(pattern.hasMatch('随便一句别人的评论'), isFalse);
    });

    test('认不出的变量在预览里原样留着，好让用户看见自己打错了', () {
      final tpl = SignatureTemplate.parse('{dat}');
      expect(tpl.render({}, keepUnknown: true), '{dat}');
      expect(tpl.render({}), '');
    });
  });

  group('变量值洗白', () {
    test('换行压成空格：多行小尾巴在评论区那边会认不出来', () {
      expect(SignatureTemplate.sanitizeValue('上一行\n下一行'), '上一行 下一行');
    });

    test('超长截断', () {
      final long = 'あ' * 200;
      final out = SignatureTemplate.sanitizeValue(long);
      expect(out.length, SignatureTemplate.maxVariableLength);
      expect(out.endsWith('…'), isTrue);
    });

    test('落在行首的块级标记要转义，否则一言能把版式搅乱', () {
      expect(
        SignatureTemplate.sanitizeValue('--- 分隔线', escapeBlockStart: true),
        r'\--- 分隔线',
      );
      // 不在行首就不动它：正文中间的减号是内容
      expect(SignatureTemplate.sanitizeValue('--- 分隔线'), '--- 分隔线');
    });
  });

  group('识别用的骨架正则', () {
    test('骨架够长时，认得出同一模板的不同求值结果', () {
      final pattern = SignatureTemplate.parse(
        '发自 Love Iwara · {date}',
      ).toMatchPattern();
      expect(pattern, isNotNull);
      expect(pattern!.hasMatch('发自 Love Iwara · 2026-09-20'), isTrue);
      expect(pattern.hasMatch('发自 Love Iwara · 2025-01-01'), isTrue);
      expect(pattern.hasMatch('随便一句别人写的话'), isFalse);
    });

    test('⛔ 整条都是变量时必须拒绝生成——那条正则会匹配任何东西', () {
      expect(SignatureTemplate.parse('{hitokoto}').toMatchPattern(), isNull);
      expect(SignatureTemplate.parse('{date} {time}').toMatchPattern(), isNull);
    });

    test('没有变量时也返回 null：那种情况调用方走逐字比对', () {
      expect(SignatureTemplate.parse('发自 Love Iwara').toMatchPattern(), isNull);
    });
  });
}
