import 'package:i_iwara/common/constants.dart';

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

  IwaraUrlInfo({
    required this.type,
    this.id,
    this.secondaryId,
    required this.originalUrl,
  });

  bool get isIwaraUrl => originalUrl.startsWith(CommonConstants.iwaraBaseUrl);
}

/// URL 工具类
class UrlUtils {
  /// 解析 URL
  static IwaraUrlInfo parseUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // 如果不是 iwara 域名，直接返回 unknown
      if (!url.startsWith(CommonConstants.iwaraBaseUrl)) {
        return IwaraUrlInfo(type: IwaraUrlType.unknown, originalUrl: url);
      }

      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) {
        return IwaraUrlInfo(type: IwaraUrlType.unknown, originalUrl: url);
      }

      // 根据路径第一段判断类型
      switch (pathSegments[0]) {
        case 'profile':
          return IwaraUrlInfo(
            type: IwaraUrlType.profile,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        case 'video':
          return IwaraUrlInfo(
            type: IwaraUrlType.video,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        case 'image':
          return IwaraUrlInfo(
            type: IwaraUrlType.image,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        case 'forum':
          if (pathSegments.length >= 3) {
            return IwaraUrlInfo(
              type: IwaraUrlType.forumThread,
              id: pathSegments[1],
              secondaryId: pathSegments[2],
              originalUrl: url,
            );
          } else if (pathSegments.length == 2) {
            return IwaraUrlInfo(
              type: IwaraUrlType.forum,
              id: pathSegments[1],
              originalUrl: url,
            );
          }
          return IwaraUrlInfo(type: IwaraUrlType.forum, originalUrl: url);
        case 'playlist':
          return IwaraUrlInfo(
            type: IwaraUrlType.playlist,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        case 'post':
          return IwaraUrlInfo(
            type: IwaraUrlType.post,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        case 'rule':
          return IwaraUrlInfo(
            type: IwaraUrlType.rule,
            id: pathSegments.length > 1 ? pathSegments[1] : null,
            originalUrl: url,
          );
        default:
          return IwaraUrlInfo(type: IwaraUrlType.unknown, originalUrl: url);
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
