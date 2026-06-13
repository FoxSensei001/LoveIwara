import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/utils/common_utils.dart';

void main() {
  final formatter = MarkdownFormatter();

  group('CommonUtils.parseTimestamp', () {
    test('解析 分:秒', () {
      expect(
        CommonUtils.parseTimestamp(minutes: '1', seconds: '01'),
        const Duration(seconds: 61),
      );
    });

    test('解析 时:分:秒', () {
      expect(
        CommonUtils.parseTimestamp(hours: '1', minutes: '23', seconds: '45'),
        const Duration(seconds: 5025),
      );
    });

    test('分或秒 >= 60 视为非法', () {
      expect(CommonUtils.parseTimestamp(minutes: '1', seconds: '99'), isNull);
      expect(CommonUtils.parseTimestamp(minutes: '99', seconds: '00'), isNull);
    });
  });

  group('MarkdownFormatter.formatTimestamps', () {
    test('ASCII 冒号 1:01 -> iwaraseek://61', () {
      final result = formatter.formatTimestamps('彩蛋在 1:01 哦');
      expect(result, contains('iwaraseek://61'));
      expect(result, contains('⏱ [1:01]'));
    });

    test('中文冒号 1：01 -> iwaraseek://61', () {
      final result = formatter.formatTimestamps('彩蛋在 1：01 哦');
      expect(result, contains('iwaraseek://61'));
      expect(result, contains('⏱ [1：01]'));
    });

    test('时:分:秒 1:23:45 -> iwaraseek://5025', () {
      final result = formatter.formatTimestamps('精彩片段 1:23:45');
      expect(result, contains('iwaraseek://5025'));
    });

    test('非法时间 1:99 保持原样', () {
      final result = formatter.formatTimestamps('错误 1:99 时间');
      expect(result, '错误 1:99 时间');
      expect(result, isNot(contains('iwaraseek')));
    });

    test('URL 路径中的 12:30 不被改写', () {
      const input = 'see https://example.com/a/12:30 here';
      expect(formatter.formatTimestamps(input), input);
    });

    test('已存在的 Markdown 链接内部不被改写', () {
      const input = '[看这里](https://example.com/12:30)';
      expect(formatter.formatTimestamps(input), input);
    });

    test('代码块内的时间不被改写', () {
      const input = '行内代码 `1:01` 不处理';
      expect(formatter.formatTimestamps(input), input);
    });

    test('普通文本与已有链接混排：仅普通文本被处理', () {
      const input = '[链接](https://x.com/12:30) 但 2:34 要处理';
      final result = formatter.formatTimestamps(input);
      expect(result, contains('https://x.com/12:30'));
      expect(result, contains('iwaraseek://154')); // 2*60+34
    });
  });
}
