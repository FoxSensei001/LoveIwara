import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/common/constants.dart';

class IwaraDeepLinkUtils {
  const IwaraDeepLinkUtils._();

  static String? normalizeToAppLocation(Uri uri) {
    if (uri.host.isNotEmpty && !isSupportedAppLinkHost(uri.host)) {
      return null;
    }

    if (isSupportedNewsHost(uri.host)) {
      return normalizeNewsToAppLocation(uri);
    }

    final pathSegments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (pathSegments.isEmpty) {
      return null;
    }

    switch (pathSegments[0]) {
      case 'video':
        return pathSegments.length > 1
            ? '/video_detail/${pathSegments[1]}'
            : null;
      case 'image':
        return pathSegments.length > 1
            ? '/gallery_detail/${pathSegments[1]}'
            : null;
      case 'playlist':
        return pathSegments.length > 1
            ? '/playlist_detail/${pathSegments[1]}'
            : null;
      case 'post':
        return pathSegments.length > 1 ? '/post/${pathSegments[1]}' : null;
      case 'forum':
        if (pathSegments.length > 2) {
          return '/forum_threads/${pathSegments[1]}/${pathSegments[2]}';
        }
        return pathSegments.length > 1
            ? '/forum_threads/${pathSegments[1]}'
            : null;
      case 'profile':
        if (pathSegments.length <= 1) {
          return null;
        }
        return buildAuthorProfileLocation(
          pathSegments[1],
          tab: normalizeAuthorProfileTab(
            pathSegments.length > 2 ? pathSegments[2] : null,
          ),
        );
      default:
        return null;
    }
  }

  static bool isSupportedAppLinkHost(String? host) {
    return isSupportedNewsHost(host) ||
        host != null &&
            host.isNotEmpty &&
            (host == CommonConstants.iwaraDomain ||
                host.endsWith('.${CommonConstants.iwaraDomain}') ||
                host == CommonConstants.iwaraAiDomain ||
                host.endsWith('.${CommonConstants.iwaraAiDomain}'));
  }

  static bool isSupportedNewsHost(String? host) {
    final normalized = (host ?? '').trim().toLowerCase();
    return normalized == CommonConstants.iwaraNewsHost;
  }

  static String? normalizeNewsToAppLocation(Uri uri) {
    if (!isSupportedNewsHost(uri.host)) {
      return null;
    }

    final pathSegments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    if (pathSegments.isEmpty) {
      return '/news';
    }

    var index = 0;
    final language = _resolveNewsLanguageFromPrefix(pathSegments.first);
    if (language != null) {
      index = 1;
      if (pathSegments.length <= index) {
        return buildNewsLocation(language: language);
      }
    }

    if (pathSegments.length > index && pathSegments[index] == 'category') {
      if (pathSegments.length <= index + 1) {
        return buildNewsLocation(language: language);
      }

      final category = resolveNewsCategoryType(pathSegments[index + 1]);
      final resolvedLanguage =
          language ??
          _resolveNewsLanguageFromCategorySlug(pathSegments[index + 1]);
      return buildNewsLocation(category: category, language: resolvedLanguage);
    }

    return buildNewsDetailLocation(uri.toString());
  }

  static String? normalizeAuthorProfileTab(String? rawTab) {
    switch ((rawTab ?? '').trim().toLowerCase()) {
      case '':
      case 'video':
      case 'videos':
        return null;
      case 'image':
      case 'images':
      case 'gallery':
      case 'galleries':
        return 'gallery';
      case 'playlist':
      case 'playlists':
        return 'playlists';
      case 'post':
      case 'posts':
        return 'posts';
      default:
        return null;
    }
  }

  static int resolveAuthorProfileInitialTabIndex(String? rawTab) {
    switch (normalizeAuthorProfileTab(rawTab)) {
      case 'gallery':
        return 1;
      case 'playlists':
        return 2;
      case 'posts':
        return 3;
      default:
        return 0;
    }
  }

  static String buildAuthorProfileLocation(String username, {String? tab}) {
    final normalizedTab = normalizeAuthorProfileTab(tab);
    return Uri(
      path: '/author_profile/$username',
      queryParameters: normalizedTab == null ? null : {'tab': normalizedTab},
    ).toString();
  }

  static String buildNewsLocation({
    IwaraNewsCategoryType? category,
    IwaraNewsLanguage? language,
  }) {
    final queryParameters = <String, String>{};
    if (category != null) {
      queryParameters['category'] = category.name;
    }
    if (language != null) {
      queryParameters['lang'] = language.name;
    }
    return Uri(
      path: '/news',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String buildNewsDetailLocation(String url) {
    final normalizedUrl = url.trim();
    final uri = Uri.parse(normalizedUrl);
    final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
    final slug = segments.isEmpty ? 'post' : segments.last;
    return Uri(
      path: '/news/$slug',
      queryParameters: {'url': normalizedUrl},
    ).toString();
  }

  static IwaraNewsCategoryType? resolveNewsCategoryType(String? slug) {
    final normalized = _normalizeNewsCategorySlug(slug);
    switch (normalized) {
      case 'news-updates':
        return IwaraNewsCategoryType.newsUpdates;
      case 'articles':
        return IwaraNewsCategoryType.articles;
      case 'broadcast':
        return IwaraNewsCategoryType.broadcast;
      default:
        return null;
    }
  }

  static IwaraNewsLanguage? resolveNewsLanguage(String? rawLanguage) {
    switch ((rawLanguage ?? '').trim().toLowerCase()) {
      case 'en':
        return IwaraNewsLanguage.en;
      case 'ja':
        return IwaraNewsLanguage.ja;
      case 'zh':
        return IwaraNewsLanguage.zh;
      default:
        return null;
    }
  }

  static String _normalizeNewsCategorySlug(String? slug) {
    final normalized = (slug ?? '').trim().toLowerCase();
    if (normalized.endsWith('-ja')) {
      return normalized.substring(0, normalized.length - 3);
    }
    if (normalized.endsWith('-zh')) {
      return normalized.substring(0, normalized.length - 3);
    }
    return normalized;
  }

  static IwaraNewsLanguage? _resolveNewsLanguageFromPrefix(String? prefix) {
    return resolveNewsLanguage(prefix);
  }

  static IwaraNewsLanguage? _resolveNewsLanguageFromCategorySlug(String? slug) {
    final normalized = (slug ?? '').trim().toLowerCase();
    if (normalized.endsWith('-ja')) {
      return IwaraNewsLanguage.ja;
    }
    if (normalized.endsWith('-zh')) {
      return IwaraNewsLanguage.zh;
    }
    if (normalized.isNotEmpty) {
      return IwaraNewsLanguage.en;
    }
    return null;
  }
}
