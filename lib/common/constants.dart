import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';

class CommonConstants {
  CommonConstants._internal();

  // 应用版本
  static const String VERSION = '0.3.0';

  // 应用名称
  static String? applicationName = 'i_iwara';

  // 应用昵称 
  static String applicationNickname = 'Love Iwara';
  // 应用包名
  static String packageName = 'm.c.g.a.i_iwara';


  // 应用图标路径
  static String launcherIconPath = 'assets/icon/launcher_icon_v2.png';

  // 是否强制更新
  static bool isForceUpdate = false;

  // 默认语言占位符，如果修改的话，注意 @{link /lib/xxxi18n.yml} 文件中对应的翻译
  static String defaultLanguagePlaceholder = '[TL]';

  // 网站基础URL
  static const String iwaraBaseUrl = 'https://www.iwara.tv';

  // api基础URL
  static const String iwaraApiBaseUrl = 'https://api.iwara.tv';

  // 图片资源基础URL
  static const String iwaraImageBaseUrl = 'https://i.iwara.tv';

  // 是否设置过亮度
  static bool isSetBrightness = false;

  // 是否设置过音量
  static bool isSetVolume = false;

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

  // 是否启用R18内容
  static bool enableR18 = true;

  // 是否记录历史记录
  static bool enableHistory = true;

  static String defaultPlaylistThumbnailUrl =
      '$iwaraBaseUrl/images/default-thumbnail.jpg';

  static int themeMode = 0; // 0: system(动态主题), 1: light, 2: dark
  static bool useDynamicColor = true; // 使用动态颜色
  static bool usePresetColor = true; // 使用预设颜色
  static int currentPresetIndex = 0; // 预设颜色索引
  static String currentCustomHex = ''; // 自定义颜色
  static List<String> customThemeColors = []; // 自定义颜色列表

  static ColorScheme? dynamicLightColorScheme;
  static ColorScheme? dynamicDarkColorScheme;

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
  // 规则
  static String rules = '/rules';

  // 用户
  static String user = '/user';

  // 用户消息 count
  static String userCounts = '/user/counts';

  // 用户消息全部已读
  static String userNotificationAllRead = '/notifications/all/read';

  // 查找用户
  static String autocompleteUsers = '/autocomplete/users';

  // 用户WithId
  static String userWithId(String userId) => '/user/$userId';

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

  // 用户发帖子冷却时间
  static String userPostCooldown() => '/user/post/cooldown';

  // 论坛帖子冷却时间
  static String forumThreadCooldown() => '/user/forumThread/cooldown';

  // 论坛总表
  static String forum() => '/forum';

  // 论坛帖子
  static String forumThread(String forumCategoryId) => '/forum/$forumCategoryId';

  // 论坛帖子回复
  static String forumThreadReply(String threadId) => '/forum/$threadId/reply';

  // 论坛帖子列表
  static String forumThreadsWithCategoryId(String categoryId) => '/forum/$categoryId';

  // 论坛帖子列表
  static String forumThreads() => '/forum/threads';

  // 论坛帖子回复
  static String forumPosts(String postId) => '/forum/post/$postId';

  // 论坛帖子详情
  static String forumThreadDetail(String categoryId, String threadId) => '/forum/$categoryId/$threadId';

  // 用户通知
  static String userNotifications(String userId) => '/user/$userId/notifications';

  // 标记消息已读
  static String userNotificationWithId(String notificationId) => '/notifications/$notificationId/read';

  // 用户会话列表
  static String userConversations(String userId) => '/user/$userId/conversations';

  // 会话消息
  static String conversationMessages(String conversationId) => '/conversation/$conversationId/messages';

  // 消息
  static String messageWithId(String messageId) => '/message/$messageId';

  // 视频详情
  static String video(String videoId) => '/video/$videoId';
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
