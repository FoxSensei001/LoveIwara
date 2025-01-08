import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class CommonConstants {
  CommonConstants._internal();

  // 应用版本
  static const String VERSION = '0.1.0';

  // 应用图标路径
  static String launcherIconPath = 'assets/icon/launcher_icon_v2.png';

  // 是否强制更新
  static bool isForceUpdate = false;

  // 网站基础URL
  static const String iwaraBaseUrl = 'https://www.iwara.tv';

  // api基础URL
  static const String iwaraApiBaseUrl = 'https://api.iwara.tv';

  // 图片资源基础URL
  static const String iwaraImageBaseUrl = 'https://i.iwara.tv';

  // 默认用户头像URL
  static const String defaultAvatarUrl =
      '$iwaraBaseUrl/images/default-avatar.jpg';

  // 默认用户背景URL
  static const String defaultProfileHeaderUrl =
      '$iwaraBaseUrl/images/default-background.jpg';

  static List<Sort> mediaSorts = [
    Sort(id: SortId.trending, label: t.common.trending, icon: const Icon(Icons.trending_up)),
    Sort(id: SortId.date, label: t.common.latest, icon: const Icon(Icons.new_releases)),
    Sort(id: SortId.popularity, label: t.common.popular, icon: const Icon(Icons.star)),
    Sort(id: SortId.likes, label: t.common.likesCount, icon: const Icon(Icons.thumb_up)),
    Sort(id: SortId.views, label: t.common.viewsCount, icon: const Icon(Icons.remove_red_eye)),
  ];

  static const List<Sort> translationSorts = [
    // 中文
    Sort(id: SortId.zhCN, label: '简体中文', extData: 'zh-CN'),
    Sort(id: SortId.zhTW, label: '繁體中文', extData: 'zh-TW'),
    
    // 英语
    Sort(id: SortId.enUS, label: 'English', extData: 'en-US'),
    
    // 东亚语言
    Sort(id: SortId.ja, label: '日本語', extData: 'ja'),
    Sort(id: SortId.ko, label: '한국어', extData: 'ko'),
    Sort(id: SortId.vi, label: 'Tiếng Việt', extData: 'vi'),
    
    // 东南亚语言
    Sort(id: SortId.th, label: 'ภาษาไทย', extData: 'th'),
    Sort(id: SortId.id, label: 'Bahasa Indonesia', extData: 'id'),
    Sort(id: SortId.ms, label: 'Bahasa Melayu', extData: 'ms'),
    
    // 欧洲语言
    Sort(id: SortId.fr, label: 'Français', extData: 'fr'),
    Sort(id: SortId.de, label: 'Deutsch', extData: 'de'),
    Sort(id: SortId.es, label: 'Español', extData: 'es'),
    Sort(id: SortId.it, label: 'Italiano', extData: 'it'),
    Sort(id: SortId.pt, label: 'Português', extData: 'pt'),
    Sort(id: SortId.ru, label: 'Русский', extData: 'ru'),
  ];

  static String defaultThumbnailUrl =
      '$iwaraBaseUrl/images/default-thumbnail.jpg';

  static bool enableR18 = true;

  static String? applicationName = 'i_iwara';

  static String defaultPlaylistThumbnailUrl =
      '$iwaraBaseUrl/images/default-thumbnail.jpg';

  // 获取用户背景URL
  static userProfileHeaderUrl(String? headerId) {
    if (headerId == null) {
      return defaultProfileHeaderUrl;
    }
    return '$iwaraImageBaseUrl/image/profileHeader/$headerId/$headerId.jpg';
  }
}

class KeyConstants {
  // Auth Token
  static const String authToken = 'auth_token';

  // Access Token
  static const String accessToken = 'access_token';
}

class ApiConstants {
  // 视频列表
  static String videos() => '/videos';

  // 图片
  static String images() => '/images';

  // 作者详情
  static String profilePrefix() => '/profile';

  // 图库详情
  static String galleryDetail() => '/image';

  // 视频详情
  static String videoDetail() => '/video';

  // 用户详情
  static String userProfile(String userName) => '/profile/$userName';

  // 用户粉丝
  static String userFollowers(String userId) => '/user/$userId/followers';

  // 用户关注
  static String userFollowing(String userId) => '/user/$userId/following';

  // 朋友申请状态
  static String userRelationshipStatus(String userId) =>
      '/user/$userId/friends/status';

  // 加或取消朋友
  static String userAddOrRemoveFriend(String userId) => '/user/$userId/friends';

  // 关注或取消关注
  static String userFollowOrUnfollow(String userId) =>
      '/user/$userId/followers';

  // 评论 [params]: [type, id]
  static String comments(String type, String id) => '/$type/$id/comments';

  // 标签
  static String tags() => '/tags';

  // 图片详情
  static String imageDetail(String imageModelId) => '/image/$imageModelId';

  // 相关视频
  static String relatedVideos(String id) => '/video/$id/related';

  // 相关图片
  static String relatedImages(String mediaId) => '/image/$mediaId/related';

  // 视频点赞
  static String videoLikes(String videoId) => '/video/$videoId/likes';

  // 图片点赞
  static String imageLikes(String imageId) => '/image/$imageId/likes';

  // 轻量视频
  static String lightVideo(String videoId) => '/light/video/$videoId';

  // 轻量图库
  static String lightForum(String forumId) => '/light/forum/$forumId';

  // 轻量图片
  static String lightImage(String imageId) => '/light/image/$imageId';

  // 轻量用户
  static String lightProfile(String userId) => '/light/profile/$userId';

  // 轻量播放列表
  static String lightPlaylist(String playlistId) => '/light/playlist/$playlistId';

  // 搜索
  static String search() => '/search';

  // 最爱视频
  static String favoriteVideos() => '/favorites/videos';

  // 最爱图库
  static String favoriteImages() => '/favorites/images';

  // 设为最爱图片
  static String likeImage(String mediaId) => '/image/$mediaId/like';

  // 设为最爱视频
  static String likeVideo(String mediaId) => '/video/$mediaId/like';

  // 用户朋友
  static String userFriends(String userId) => '/user/$userId/friends';

  // 用户请求
  static String userFriendsRequests(String userId) => '/user/$userId/friends/requests';

  // 评论
  static String comment(String id) => '/comment/$id';

  // 帖子列表
  static String posts() => '/posts';

  // 帖子详情
  static String post(String id) => '/post/$id';
}

// 视频接口的排序方式
enum SortId {
  trending,
  date,
  popularity,
  likes,
  views,
  // 中文
  zhCN,
  zhTW,
  zhHK,
  // 英语变体
  enUS,
  enGB,
  // 东亚语言
  ja,
  ko,
  vi,
  // 东南亚语言
  th,
  id,
  ms,
  // 欧洲语言
  fr,
  de,
  es,
  it,
  pt,
  ru;
}
