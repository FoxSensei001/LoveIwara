import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/config_service.dart';

/// 配置值解析的单测。
///
/// 起因是两个成因相同的坑：Map 分支 `catch` 之后**不打日志**地回退默认值
/// （「所有自定义快捷键忽然没了」这类故障毫无痕迹可查），而 List 分支的
/// `jsonDecode` **根本没有 try**——一条脏数据会把异常抛出 `_loadSettings`，
/// 而 `init()` 没有兜底，于是整份配置一起加载失败。
///
/// 现在解析被拆成这个纯函数：**解析不了就抛**，由调用方统一记日志 + 只回退
/// 该键的默认值。下面钉住的就是这条边界。
void main() {
  group('正常解析', () {
    test('bool / int / double / String', () {
      expect(ConfigService.parseStoredSetting(false, 'true'), isTrue);
      expect(ConfigService.parseStoredSetting(false, 'TRUE'), isTrue);
      expect(ConfigService.parseStoredSetting(true, 'false'), isFalse);
      expect(ConfigService.parseStoredSetting(0, '42'), 42);
      expect(ConfigService.parseStoredSetting(0.0, '1.5'), 1.5);
      expect(ConfigService.parseStoredSetting('', 'hello'), 'hello');
    });

    test('数值解析不出来时回退默认值，不抛——这是历史行为，保持不变', () {
      expect(ConfigService.parseStoredSetting(7, 'not-a-number'), 7);
      expect(ConfigService.parseStoredSetting(1.5, 'nope'), 1.5);
    });

    test('List 与 Map', () {
      expect(ConfigService.parseStoredSetting(<dynamic>[], '[1,2]'), [1, 2]);
      expect(
        ConfigService.parseStoredSetting(<String, dynamic>{}, '{"a":1}'),
        {'a': 1},
      );
    });

    test('Map<String,int> / Map<String,String> 按默认值的类型收窄', () {
      final ints = ConfigService.parseStoredSetting(
        <String, int>{},
        '{"a":1,"b":"2"}',
      );
      expect(ints, isA<Map<String, int>>());
      expect(ints, {'a': 1, 'b': 2});

      final strs = ConfigService.parseStoredSetting(
        <String, String>{},
        '{"a":1}',
      );
      expect(strs, isA<Map<String, String>>());
      expect(strs, {'a': '1'});
    });
  });

  group('脏数据一律抛给调用方，由它记日志并只回退这一个键', () {
    test('List 位置上的坏 JSON——以前这里没有 try，会掀掉整份配置', () {
      expect(
        () => ConfigService.parseStoredSetting(<dynamic>[], '{oops'),
        throwsA(isA<FormatException>()),
      );
    });

    test('Map 位置上的坏 JSON', () {
      expect(
        () => ConfigService.parseStoredSetting(<String, dynamic>{}, 'not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('JSON 合法但类型不对，同样算损坏', () {
      expect(
        () => ConfigService.parseStoredSetting(<dynamic>[], '{"a":1}'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ConfigService.parseStoredSetting(<String, dynamic>{}, '[1,2]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
