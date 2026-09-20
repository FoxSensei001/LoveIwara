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
      final tpl = SignatureTemplate.parse('来自 {app} {{注意}} {date:yyyy}');
      expect(tpl.variables.map((v) => v.key), ['app', 'date:yyyy']);
      expect(
        tpl.render({'app': 'Love Iwara', 'date:yyyy': '2026'}),
        '来自 Love Iwara {注意} 2026',
      );
    });

    test('同一个变量写两遍只求值一次', () {
      final tpl = SignatureTemplate.parse('{hitokoto} / {hitokoto}');
      expect(tpl.variables.length, 1);
    });

    test('取不到值的变量整段消失，不留空洞也不留花括号', () {
      final tpl = SignatureTemplate.parse('发自 {app}，今日一言：{hitokoto}');
      expect(tpl.render({'app': 'Love Iwara'}), '发自 Love Iwara，今日一言：');
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
