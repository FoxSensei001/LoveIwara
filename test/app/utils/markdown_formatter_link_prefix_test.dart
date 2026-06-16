import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/markdown_formatter.dart';

void main() {
  final formatter = MarkdownFormatter();

  group('MarkdownFormatter.formatMarkdownLinks 链接图标前缀', () {
    test('锚点链接不加图标', () {
      const input = '[跳转](#section)';
      expect(formatter.formatMarkdownLinks(input), equals(input));
    });

    test('相对路径不加图标', () {
      const input = '[文档](docs/readme.md)';
      expect(formatter.formatMarkdownLinks(input), equals(input));
    });

    test('Iwara 相对路径不加图标', () {
      const input = '[视频](/video/abc123)';
      expect(formatter.formatMarkdownLinks(input), equals(input));
    });

    test('mailto 不加图标', () {
      const input = '[邮件](mailto:someone@example.com)';
      expect(formatter.formatMarkdownLinks(input), equals(input));
    });

    test('夹带特殊字符的非网址不加图标', () {
      const input = '[标签](#@!?)';
      expect(formatter.formatMarkdownLinks(input), equals(input));
    });

    test('绝对 http/https 网址添加 favicon 图标前缀', () {
      const input = '[站点](https://example.com)';
      final result = formatter.formatMarkdownLinks(input);
      expect(result, isNot(equals(input)));
      expect(result.startsWith('![emo:icon-i]'), isTrue);
      expect(result.endsWith(input), isTrue);
    });

    test('Iwara 视频网址添加类型 Emoji 前缀', () {
      const input = '[视频](https://iwara.tv/video/abc123)';
      final result = formatter.formatMarkdownLinks(input);
      expect(result.startsWith('🎬 '), isTrue);
      expect(result.endsWith(input), isTrue);
    });
  });
}
