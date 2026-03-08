import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/models/iwara_site.dart';

/// URL 类型枚举
enum IwaraUrlType {
  profile,
  video,
  image,
  forum,
  forumThread,
  playlist,
  post,
  rule,
  unknown,
}

/// URL 解析结果
class IwaraUrlInfo {
  final IwaraUrlType type;
  final String? id;
  final String? secondaryId; // 用于论坛帖子等需要两个ID的情况
  final String originalUrl;
  final IwaraSite site;

  IwaraUrlInfo({
    required this.type,
    this.id,
    this.secondaryId,
    required this.originalUrl,
    this.site = IwaraSite.main,
  });

  bool get isIwaraUrl =>
      IwaraSiteUtils.isIwaraHost(Uri.tryParse(originalUrl)?.host);
}

/// URL 工具类
class UrlUtils {
  static const Set<String> _iwaraPathRoots = {
    'profile',
    'video',
    'image',
    'forum',
    'playlist',
    'post',
    'rule',
  };

  static bool isRelativeIwaraPath(String url) {
    try {
      final normalizedUrl = url.trim();
      if (normalizedUrl.isEmpty) {
        return false;
      }

      final uri = Uri.parse(normalizedUrl);
      if (uri.hasScheme || uri.host.isNotEmpty) {
        return false;
      }

      final pathSegments = uri.pathSegments.where(
        (segment) => segment.isNotEmpty,
      );
      if (pathSegments.isEmpty) {
        return false;
      }

      return _iwaraPathRoots.contains(pathSegments.first);
    } catch (_) {
      return false;
    }
  }

  static String? resolveRelativeIwaraUrl(String url, IwaraSite site) {
    if (!isRelativeIwaraPath(url)) {
      return null;
    }

    try {
      final uri = Uri.parse(url.trim());
      final baseUri = Uri.parse(site.baseUrl);
      final normalizedPath = uri.path.startsWith('/')
          ? uri.path
          : '/${uri.path}';
      return baseUri
          .replace(
            path: normalizedPath,
            query: uri.hasQuery ? uri.query : null,
            fragment: uri.fragment.isEmpty ? null : uri.fragment,
          )
          .toString();
    } catch (_) {
      return null;
    }
  }

  /// 将 Iwara 相关域名的 `http` 链接升级为 `https`。
  ///
  /// 背景：部分资源在 `http` 下会返回 404，但 `https` 可正常访问。
  static String upgradeIwaraHttpToHttps(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme.toLowerCase() != 'http') {
        return url;
      }

      final host = uri.host.toLowerCase();
      final iwaraDomain = CommonConstants.iwaraDomain.toLowerCase();
      final iwaraAiDomain = CommonConstants.iwaraAiDomain.toLowerCase();
      final isIwaraHost =
          host == iwaraDomain ||
          host.endsWith('.$iwaraDomain') ||
          host == iwaraAiDomain ||
          host.endsWith('.$iwaraAiDomain');

      if (!isIwaraHost) {
        return url;
      }

      return uri.replace(scheme: 'https').toString();
    } catch (_) {
      return url;
    }
  }

  /// 解析 URL
  static IwaraUrlInfo parseUrl(String url, {IwaraSite? siteForRelativeUrl}) {
    try {
      final normalizedUrl = url.trim();
      final uri = Uri.parse(normalizedUrl);
      final isRelativeUrl = !uri.hasScheme && uri.host.isEmpty;

      final site = isRelativeUrl
          ? (siteForRelativeUrl ?? IwaraSite.main)
          : IwaraSiteUtils.fromHost(uri.host);
      if (isRelativeUrl) {
        if (!isRelativeIwaraPath(normalizedUrl) || siteForRelativeUrl == null) {
          return IwaraUrlInfo(
            type: IwaraUrlType.unknown,
            originalUrl: normalizedUrl,
            site: site,
          );
        }
      } else if (!IwaraSiteUtils.isIwaraHost(uri.host)) {
        return IwaraUrlInfo(
          type: IwaraUrlType.unknown,
          originalUrl: normalizedUrl,
          site: site,
        );
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        return IwaraUrlInfo(
          type: IwaraUrlType.unknown,
          originalUrl: normalizedUrl,
          site: site,
        );
      }

      // 根据路径第一段判断类型
      switch (pathSegments[0]) {
        case 'profile':
          return IwaraUrlInfo(
            type: IwaraUrlType.profile,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'video':
          return IwaraUrlInfo(
            type: IwaraUrlType.video,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'image':
          return IwaraUrlInfo(
            type: IwaraUrlType.image,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'forum':
          if (pathSegments.length >= 3) {
            return IwaraUrlInfo(
              type: IwaraUrlType.forumThread,
              id: pathSegments[1],
              secondaryId: pathSegments[2],
              originalUrl: normalizedUrl,
              site: site,
            );
          } else if (pathSegments.length == 2) {
            return IwaraUrlInfo(
              type: IwaraUrlType.forum,
              id: pathSegments[1],
              originalUrl: normalizedUrl,
              site: site,
            );
          }
          return IwaraUrlInfo(
            type: IwaraUrlType.forum,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'playlist':
          return IwaraUrlInfo(
            type: IwaraUrlType.playlist,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'post':
          return IwaraUrlInfo(
            type: IwaraUrlType.post,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        case 'rule':
          return IwaraUrlInfo(
            type: IwaraUrlType.rule,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: normalizedUrl,
            site: site,
          );
        default:
          return IwaraUrlInfo(
            type: IwaraUrlType.unknown,
            originalUrl: normalizedUrl,
            site: site,
          );
      }
    } catch (e) {
      return IwaraUrlInfo(type: IwaraUrlType.unknown, originalUrl: url);
    }
  }

  /// 获取域名对应的 Favicon URL
  static String getFaviconUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      return 'https://www.google.com/s2/favicons?domain=$host&sz=64';
    } catch (e) {
      return '';
    }
  }

  /// 获取 Iwara 内容类型对应的图标
  static String getIwaraTypeEmoji(IwaraUrlType type) {
    switch (type) {
      case IwaraUrlType.video:
        return '🎬';
      case IwaraUrlType.forum:
      case IwaraUrlType.forumThread:
        return '📌';
      case IwaraUrlType.image:
        return '🖼️';
      case IwaraUrlType.profile:
        return '👤';
      case IwaraUrlType.playlist:
        return '🎵';
      case IwaraUrlType.post:
        return '💬';
      case IwaraUrlType.rule:
        return '📜';
      case IwaraUrlType.unknown:
        return '❓';
    }
  }
}
