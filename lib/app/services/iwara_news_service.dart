import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'http_client_factory.dart';
import 'iwara_news_parser.dart';

class IwaraNewsService extends GetxService {
  static const String _tag = 'IwaraNewsService';
  static const String _baseUrl = CommonConstants.iwaraNewsBaseUrl;
  static const int defaultPerPage = 20;

  static const Map<IwaraNewsCategoryType, Map<IwaraNewsLanguage, String>>
  _categorySlugs = {
    IwaraNewsCategoryType.newsUpdates: {
      IwaraNewsLanguage.en: 'news-updates',
      IwaraNewsLanguage.ja: 'news-updates-ja',
      IwaraNewsLanguage.zh: 'news-updates-zh',
    },
    IwaraNewsCategoryType.articles: {
      IwaraNewsLanguage.en: 'articles',
      IwaraNewsLanguage.ja: 'articles-ja',
      IwaraNewsLanguage.zh: 'articles-zh',
    },
    IwaraNewsCategoryType.broadcast: {
      IwaraNewsLanguage.en: 'broadcast',
      IwaraNewsLanguage.ja: 'broadcast-ja',
      IwaraNewsLanguage.zh: 'broadcast-zh',
    },
  };

  final Map<String, IwaraNewsCategory> _categoryCache = {};

  HttpClient get _client => HttpClientFactory.instance.createHttpClient();

  IwaraNewsLanguage resolveLanguage(String languageCode) {
    final normalized = languageCode.toLowerCase();
    if (normalized.startsWith('ja')) return IwaraNewsLanguage.ja;
    if (normalized.startsWith('zh')) return IwaraNewsLanguage.zh;
    return IwaraNewsLanguage.en;
  }

  String categorySlug(
    IwaraNewsCategoryType type,
    IwaraNewsLanguage language,
  ) =>
      _categorySlugs[type]![language]!;

  Future<List<IwaraNewsListItem>> fetchCategoryPosts(
    IwaraNewsCategoryType type, {
    required String languageCode,
    int page = 1,
    int perPage = defaultPerPage,
  }) async {
    final language = resolveLanguage(languageCode);
    final category = await _resolveCategory(type, language);
    final uri = Uri.parse('$_baseUrl/wp-json/wp/v2/posts').replace(
      queryParameters: {
        'categories': category.id.toString(),
        'page': '$page',
        'per_page': '$perPage',
        '_embed': 'true',
        '_fields':
            'id,date,modified,link,title,excerpt,categories,_embedded.wp:featuredmedia.source_url',
      },
    );

    final data = await _getJsonList(uri);
    return data
        .map(
          (item) => _parseListItem(
            item,
            categoryType: type,
            fallbackLanguage: language,
          ),
        )
        .toList();
  }

  Future<IwaraNewsDetail> fetchPostDetail(int postId) async {
    final uri = Uri.parse('$_baseUrl/wp-json/wp/v2/posts/$postId').replace(
      queryParameters: {
        '_embed': 'true',
        '_fields':
            'id,date,modified,link,title,excerpt,content,_embedded.wp:featuredmedia.source_url',
      },
    );

    final data = await _getJsonMap(uri);
    return _parseDetail(data);
  }

  Future<IwaraNewsDetail> fetchPostDetailByUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw const FormatException('Invalid news url');
    }

    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
    if (segments.isEmpty) {
      throw const FormatException('Invalid news url path');
    }

    final slug = segments.last;
    final queryUri = Uri.parse('$_baseUrl/wp-json/wp/v2/posts').replace(
      queryParameters: {
        'slug': slug,
        '_embed': 'true',
        '_fields':
            'id,date,modified,link,title,excerpt,content,_embedded.wp:featuredmedia.source_url',
      },
    );

    final list = await _getJsonList(queryUri);
    if (list.isEmpty) {
      throw StateError('News post not found for slug: $slug');
    }
    return _parseDetail(list.first);
  }

  Future<IwaraNewsCategory> _resolveCategory(
    IwaraNewsCategoryType type,
    IwaraNewsLanguage language,
  ) async {
    final slug = categorySlug(type, language);
    final cached = _categoryCache[slug];
    if (cached != null) return cached;

    final uri = Uri.parse('$_baseUrl/wp-json/wp/v2/categories').replace(
      queryParameters: {
        'slug': slug,
        'per_page': '1',
        '_fields': 'id,slug,name',
      },
    );

    final list = await _getJsonList(uri);
    if (list.isEmpty) {
      throw StateError('Category not found: $slug');
    }

    final data = list.first;
    final category = IwaraNewsCategory(
      id: _asInt(data['id']),
      slug: data['slug']?.toString() ?? slug,
      name: IwaraNewsParser.decodeHtmlText(data['name']?.toString()),
      type: type,
      language: language,
    );
    _categoryCache[slug] = category;
    return category;
  }

  IwaraNewsListItem _parseListItem(
    Map<String, dynamic> json, {
    required IwaraNewsCategoryType categoryType,
    required IwaraNewsLanguage fallbackLanguage,
  }) {
    final link = json['link']?.toString() ?? '';
    final language = IwaraNewsParser.inferLanguageFromUrl(link) ?? fallbackLanguage;
    return IwaraNewsListItem(
      id: _asInt(json['id']),
      title: IwaraNewsParser.decodeHtmlText(_rendered(json['title'])),
      excerpt: IwaraNewsParser.htmlToPlainText(_rendered(json['excerpt'])),
      link: link,
      publishedAt: _parseDateTime(json['date']),
      updatedAt: _parseDateTime(json['modified']),
      language: language,
      categoryType: categoryType,
      featuredImageUrl: _featuredImageUrl(json),
    );
  }

  Future<IwaraNewsDetail> _parseDetail(Map<String, dynamic> json) async {
    final link = json['link']?.toString() ?? '';
    final language =
        IwaraNewsParser.inferLanguageFromUrl(link) ?? IwaraNewsLanguage.en;

    final translationLinks = <IwaraNewsLanguage, String>{
      language: link,
    };

    try {
      if (link.isNotEmpty) {
        final html = await _getHtml(Uri.parse(link));
        translationLinks.addAll(IwaraNewsParser.extractTranslationLinks(html));
      }
    } catch (error, stackTrace) {
      LogUtils.w('解析新闻语言切换链接失败: $error', _tag);
      LogUtils.d('$stackTrace', _tag);
    }

    return IwaraNewsDetail(
      id: _asInt(json['id']),
      title: IwaraNewsParser.decodeHtmlText(_rendered(json['title'])),
      excerpt: IwaraNewsParser.htmlToPlainText(_rendered(json['excerpt'])),
      contentMarkdown: IwaraNewsParser.htmlToMarkdown(_rendered(json['content'])),
      link: link,
      publishedAt: _parseDateTime(json['date']),
      updatedAt: _parseDateTime(json['modified']),
      language: language,
      translationLinks: translationLinks,
      featuredImageUrl: _featuredImageUrl(json),
    );
  }

  Future<List<Map<String, dynamic>>> _getJsonList(Uri uri) async {
    final body = await _getString(uri);
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw StateError('Expected JSON list from $uri');
    }
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> _getJsonMap(Uri uri) async {
    final body = await _getString(uri);
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Expected JSON object from $uri');
    }
    return decoded;
  }

  Future<String> _getString(Uri uri) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json, text/html');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Request failed: ${response.statusCode}', uri: uri);
    }
    return body;
  }

  Future<String> _getHtml(Uri uri) async {
    final request = await _client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Request failed: ${response.statusCode}', uri: uri);
    }
    return body;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _parseDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _rendered(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value['rendered']?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  String? _featuredImageUrl(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    if (embedded is! Map<String, dynamic>) return null;
    final media = embedded['wp:featuredmedia'];
    if (media is! List || media.isEmpty) return null;
    final first = media.first;
    if (first is! Map<String, dynamic>) return null;
    return first['source_url']?.toString();
  }
}
