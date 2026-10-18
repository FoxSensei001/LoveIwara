import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/app/utils/url_utils.dart';

void main() {
  final formatter = MarkdownFormatter();
  const id = '0e08429c-0497-4537-a35a-be17ef16a7eb';
  const embed = '![poll:$id](iwara-poll://$id)';

  group('MarkdownFormatter.formatPollEmbeds 投票链接改写成卡片占位', () {
    test('裸链接（实际帖子里的写法）', () {
      expect(
        formatter.formatPollEmbeds('请投票！\n\nhttps://www.iwara.tv/poll/$id'),
        '请投票！\n\n$embed',
      );
    });

    test('不带 www、AI 站、结尾斜杠都认', () {
      expect(formatter.formatPollEmbeds('https://iwara.tv/poll/$id'), embed);
      expect(
        formatter.formatPollEmbeds('https://www.iwara.ai/poll/$id'),
        embed,
      );
      expect(
        formatter.formatPollEmbeds('https://www.iwara.tv/poll/$id/'),
        embed,
      );
    });

    test('带 query / fragment 的整段吞掉，不留残留文字', () {
      expect(
        formatter.formatPollEmbeds('https://www.iwara.tv/poll/$id?ref=x 谢谢'),
        '$embed 谢谢',
      );
      expect(
        formatter.formatPollEmbeds('https://www.iwara.tv/poll/$id#c'),
        embed,
      );
    });

    test('句中、括号里的裸链接也嵌入', () {
      expect(
        formatter.formatPollEmbeds('看这里 (https://www.iwara.tv/poll/$id) 谢谢'),
        '看这里 ($embed) 谢谢',
      );
    });

    test('[网址](网址) 与网页端一致，嵌入', () {
      const url = 'https://www.iwara.tv/poll/$id';
      expect(formatter.formatPollEmbeds('[$url]($url)'), embed);
    });

    test('带文字的链接保持原样（网页端也不嵌入）', () {
      const input = '[点这里投票](https://www.iwara.tv/poll/$id)';
      expect(formatter.formatPollEmbeds(input), input);
    });

    test('行内代码里的不改写，包括正文以代码开头', () {
      const input =
          '`https://www.iwara.tv/poll/$id` 和 https://www.iwara.tv/poll/$id';
      expect(
        formatter.formatPollEmbeds(input),
        '`https://www.iwara.tv/poll/$id` 和 $embed',
      );
    });

    test('同一条链接出现两次，两处都嵌入', () {
      const url = 'https://www.iwara.tv/poll/$id';
      expect(formatter.formatPollEmbeds('$url\n$url'), '$embed\n$embed');
    });

    test('别的站、别的路径不动', () {
      const inputs = [
        'https://example.com/poll/$id',
        'https://www.iwara.tv/poll/',
        'https://www.iwara.tv/poll/$id/extra',
        'https://www.iwara.tv/post/$id',
      ];
      for (final input in inputs) {
        expect(formatter.formatPollEmbeds(input), input, reason: input);
      }
    });

    test('后续链接格式化不会再碰占位（不加图标、不当裸链接包装）', () {
      final once = formatter.formatPollEmbeds('https://www.iwara.tv/poll/$id');
      expect(formatter.formatMarkdownLinks(once), embed);
    });
  });

  test('UrlUtils 认得投票链接', () {
    final info = UrlUtils.parseUrl('https://www.iwara.tv/poll/$id');
    expect(info.type, IwaraUrlType.poll);
    expect(info.id, id);
  });
}
