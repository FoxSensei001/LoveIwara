import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:i_iwara/app/models/iwara_news.model.dart';

class IwaraNewsParser {
  static String decodeHtmlText(String? text) {
    if (text == null || text.isEmpty) return '';
    return (html_parser.parseFragment(text).text ?? '').trim();
  }

  static String htmlToPlainText(String? html) {
    if (html == null || html.isEmpty) return '';
    final document = html_parser.parseFragment(html);
    return (document.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String htmlToMarkdown(String? html) {
    if (html == null || html.isEmpty) return '';

    final fragment = html_parser.parseFragment(html);

    fragment.querySelectorAll('script, style, iframe, noscript').forEach((e) {
      e.remove();
    });

    final buffer = StringBuffer();
    for (final node in fragment.nodes) {
      _writeNode(node, buffer, listDepth: 0);
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .trim();
  }

  static Map<IwaraNewsLanguage, String> extractTranslationLinks(String html) {
    final document = html_parser.parse(html);
    final result = <IwaraNewsLanguage, String>{};

    for (final link in document.querySelectorAll('.lang-item a[href][lang]')) {
      final href = link.attributes['href']?.trim();
      final language = _normalizeLanguage(link.attributes['lang']);
      if (href == null || href.isEmpty || language == null) {
        continue;
      }
      result[language] ??= href;
    }

    return result;
  }

  static IwaraNewsLanguage? inferLanguageFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final segments = uri.pathSegments.where((e) => e.isNotEmpty).toList();
    if (segments.isEmpty) return IwaraNewsLanguage.en;

    final first = segments.first.toLowerCase();
    if (first == 'ja') return IwaraNewsLanguage.ja;
    if (first == 'zh') return IwaraNewsLanguage.zh;
    return IwaraNewsLanguage.en;
  }

  static IwaraNewsLanguage? _normalizeLanguage(String? input) {
    if (input == null || input.isEmpty) return null;
    final normalized = input.toLowerCase();
    if (normalized.startsWith('ja')) return IwaraNewsLanguage.ja;
    if (normalized.startsWith('zh')) return IwaraNewsLanguage.zh;
    if (normalized.startsWith('en')) return IwaraNewsLanguage.en;
    return null;
  }

  static void _writeNode(
    Node node,
    StringBuffer buffer, {
    required int listDepth,
  }) {
    if (node is Text) {
      final text = node.text.replaceAll(RegExp(r'\s+'), ' ');
      if (text.trim().isNotEmpty) {
        buffer.write(text);
      }
      return;
    }

    if (node is! Element) return;

    final tag = node.localName?.toLowerCase() ?? '';
    switch (tag) {
      case 'br':
        buffer.write('\n');
        return;
      case 'hr':
        buffer.write('\n\n---\n\n');
        return;
      case 'p':
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('\n\n');
        return;
      case 'div':
      case 'section':
      case 'article':
      case 'figure':
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('\n\n');
        return;
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final level = int.tryParse(tag.substring(1)) ?? 1;
        buffer.write('${'#' * level} ');
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('\n\n');
        return;
      case 'ul':
      case 'ol':
        for (final child in node.children.where((e) => e.localName == 'li')) {
          _writeNode(child, buffer, listDepth: listDepth + 1);
        }
        buffer.write('\n');
        return;
      case 'li':
        buffer.write('${'  ' * (listDepth > 0 ? listDepth - 1 : 0)}- ');
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('\n');
        return;
      case 'strong':
      case 'b':
        buffer.write('**');
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('**');
        return;
      case 'em':
      case 'i':
        buffer.write('*');
        _writeChildren(node, buffer, listDepth: listDepth);
        buffer.write('*');
        return;
      case 'blockquote':
        final nested = StringBuffer();
        _writeChildren(node, nested, listDepth: listDepth);
        final lines = nested
            .toString()
            .trim()
            .split('\n')
            .where((line) => line.trim().isNotEmpty);
        for (final line in lines) {
          buffer.write('> ${line.trim()}\n');
        }
        buffer.write('\n');
        return;
      case 'a':
        final href = node.attributes['href']?.trim() ?? '';
        final textBuffer = StringBuffer();
        _writeChildren(node, textBuffer, listDepth: listDepth);
        final text = textBuffer.toString().trim();
        if (href.isEmpty) {
          buffer.write(text);
          return;
        }
        if (text.isEmpty || text == href) {
          buffer.write(href);
          return;
        }
        buffer.write('[$text]($href)');
        return;
      case 'img':
        final src = node.attributes['src']?.trim() ?? '';
        if (src.isEmpty) return;
        final alt = decodeHtmlText(node.attributes['alt']);
        buffer.write('![$alt]($src)\n\n');
        return;
      default:
        _writeChildren(node, buffer, listDepth: listDepth);
        return;
    }
  }

  static void _writeChildren(
    Element element,
    StringBuffer buffer, {
    required int listDepth,
  }) {
    for (final child in element.nodes) {
      _writeNode(child, buffer, listDepth: listDepth);
    }
  }
}
