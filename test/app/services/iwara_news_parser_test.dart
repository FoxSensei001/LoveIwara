import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/services/iwara_news_parser.dart';

void main() {
  group('IwaraNewsParser', () {
    test('extracts translation links from language switcher', () {
      const html = '''
      <ul>
        <li class="lang-item"><a href="https://news.iwara.tv/post-a/" lang="en-US">English</a></li>
        <li class="lang-item"><a href="https://news.iwara.tv/ja/post-a-ja/" lang="ja">日本語</a></li>
        <li class="lang-item"><a href="https://news.iwara.tv/zh/post-a-zh/" lang="zh-CN">中文</a></li>
      </ul>
      ''';

      final links = IwaraNewsParser.extractTranslationLinks(html);

      expect(links[IwaraNewsLanguage.en], 'https://news.iwara.tv/post-a/');
      expect(
        links[IwaraNewsLanguage.ja],
        'https://news.iwara.tv/ja/post-a-ja/',
      );
      expect(
        links[IwaraNewsLanguage.zh],
        'https://news.iwara.tv/zh/post-a-zh/',
      );
    });

    test('converts wordpress html into markdown-like text', () {
      const html = '''
      <iframe src="https://ads.example.com"></iframe>
      <p>Hello <strong>world</strong>.</p>
      <h3>Updates</h3>
      <ul>
        <li>First item</li>
        <li><a href="https://example.com">Read more</a></li>
      </ul>
      ''';

      final markdown = IwaraNewsParser.htmlToMarkdown(html);

      expect(markdown, contains('Hello **world**.'));
      expect(markdown, contains('### Updates'));
      expect(markdown, contains('- First item'));
      expect(markdown, contains('- [Read more](https://example.com)'));
      expect(markdown, isNot(contains('iframe')));
    });

    test('infers language from post url', () {
      expect(
        IwaraNewsParser.inferLanguageFromUrl('https://news.iwara.tv/post-a/'),
        IwaraNewsLanguage.en,
      );
      expect(
        IwaraNewsParser.inferLanguageFromUrl(
          'https://news.iwara.tv/ja/post-a-ja/',
        ),
        IwaraNewsLanguage.ja,
      );
      expect(
        IwaraNewsParser.inferLanguageFromUrl(
          'https://news.iwara.tv/zh/post-a-zh/',
        ),
        IwaraNewsLanguage.zh,
      );
    });
  });
}
