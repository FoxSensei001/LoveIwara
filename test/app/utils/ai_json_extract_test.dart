import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/ai_json_extract.dart';

/// 这些形状全是真模型吐出来过的。
/// 出处见 `docs/ai-provider-workstream.md` §5.1「中转静默忽略 json_schema」。
void main() {
  group('从自由文本里抠 JSON', () {
    test('干净的对象', () {
      expect(extractJsonObject('{"a":1,"b":"x"}'), {'a': 1, 'b': 'x'});
    });

    test('⛔ ```json 围栏（第一次实测就撞上的那个）', () {
      const raw = '```json\n{"segment":"videos","sort":"views"}\n```';
      expect(extractJsonObject(raw), {'segment': 'videos', 'sort': 'views'});
    });

    test('没有语言标注的围栏', () {
      expect(extractJsonObject('```\n{"a":1}\n```'), {'a': 1});
    });

    test('前后带废话', () {
      const raw = '好的，这是结果：\n{"a":1}\n希望有帮助！';
      expect(extractJsonObject(raw), {'a': 1});
    });

    test('⛔ 后面又跟了一段带花括号的解释——不能把两段圈成一个', () {
      const raw = '{"a":1}\n说明：形如 {x} 的占位会被替换。';
      expect(extractJsonObject(raw), {'a': 1});
    });

    test('⛔ 字符串值里的 } 不能让括号计数提前归零', () {
      const raw = '{"note":"close brace } inside","a":1}';
      expect(extractJsonObject(raw), {'note': 'close brace } inside', 'a': 1});
    });

    test('转义引号不算字符串结束', () {
      const raw = r'{"note":"he said \"hi\" }","a":1}';
      expect(extractJsonObject(raw)?['a'], 1);
    });

    test('嵌套对象', () {
      expect(extractJsonObject('前言 {"a":{"b":[1,2]}} 后记')?['a'], {
        'b': [1, 2],
      });
    });

    test('根本没有 JSON 时返回 null，不抛', () {
      expect(extractJsonObject('我没法执行搜索，但可以告诉你……'), isNull);
      expect(extractJsonObject(''), isNull);
      expect(extractJsonObject('   '), isNull);
    });

    test('⛔ 顶层是数组不算：调用方要的是一个对象', () {
      expect(extractJsonObject('[1,2,3]'), isNull);
    });

    test('括号没配平（被 maxTokens 截断）时返回 null', () {
      expect(extractJsonObject('{"a":1,"b":'), isNull);
    });
  });

  group('剥围栏', () {
    test('只在整段就是一个围栏块时剥', () {
      expect(stripCodeFence('```json\n{"a":1}\n```'), '{"a":1}');
      // 正文里夹着反引号的，原样留给扫描器处理
      const inline = 'see `code` here';
      expect(stripCodeFence(inline), inline);
    });
  });
}
