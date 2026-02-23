// ignore_for_file: constant_identifier_names, non_constant_identifier_names
abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const POPULAR_VIDEOS = _Paths.ROOT; // /home/popular_videos
  static const GALLERY = _Paths.GALLERY;
  static const SUBSCRIPTIONS = _Paths.SUBSCRIPTIONS;
  static String VIDEO_DETAIL(String videoId) =>
      _Paths.VIDEO_DETAIL.replaceAll(':videoId', videoId);
  static String VIDEO_DETAIL_PREFIX = _Paths.VIDEO_DETAIL_PREFIX;
  static String AUTHOR_PROFILE(String userName) =>
      _Paths.AUTHOR_PROFILE.replaceAll(':userName', userName);
  static String GALLERY_DETAIL(String galleryId) =>
      _Paths.GALLERY_DETAIL.replaceAll(':galleryId', galleryId);

  static const LOGIN = _Paths.LOGIN;
  static const SETTINGS_PAGE = _Paths.SETTINGS_PAGE;
  static const PLAYER_SETTINGS_PAGE = _Paths.PLAYER_SETTINGS_PAGE;
  static const PROXY_SETTINGS_PAGE = _Paths.PROXY_SETTINGS_PAGE;
  static const THEME_SETTINGS_PAGE = _Paths.THEME_SETTINGS_PAGE;
  static const NOT_FOUND = _Paths.NOT_FOUND;
  static const SIGN_IN = _Paths.SIGN_IN;

  static const ROOT = _Paths.ROOT;
  static const FIRST_TIME_SETUP = _Paths.FIRST_TIME_SETUP;

  static const SEARCH_RESULT = _Paths.SEARCH_RESULT;

  static const PLAY_LIST = _Paths.PLAY_LIST;

  static const FAVORITE = _Paths.FAVORITE;

  static const FRIENDS = _Paths.FRIENDS;

  static const HISTORY_LIST = _Paths.HISTORY_LIST;

  static String PLAYLIST_DETAIL(String id) =>
      _Paths.PLAYLIST_DETAIL.replaceAll(':id', id);

  static String FOLLOWING_LIST(String userId) =>
      _Paths.FOLLOWING_LIST.replaceAll(':userId', userId);

  static String FOLLOWERS_LIST(String userId) =>
      _Paths.FOLLOWERS_LIST.replaceAll(':userId', userId);

  static const ABOUT_PAGE = '/settings/about';

  static const DOWNLOAD_TASK_LIST = '/download_task_list';
  static const GALLERY_DOWNLOAD_TASK_DETAIL = '/gallery_download_task_detail';

  static const PHOTO_VIEW_WRAPPER = '/photo_view_wrapper';

  static const TAG_BLACKLIST = '/tag_blacklist';

  static const FORUM = '/forum';

  static String POST_DETAIL(String id) => '/post/$id';

  static String FORUM_THREAD_LIST(String categoryId) => '/forum/$categoryId';

  static String FORUM_THREAD_DETAIL(String categoryId, String threadId) =>
      '/forum/$categoryId/$threadId';

  static const APP_SETTINGS_PAGE = '/app_settings_page';

  static const NOTIFICATION_LIST = '/notification_list';

  static const CONVERSATION = '/conversation';

  static const LOCAL_FAVORITE = '/local_favorite';

  static const AUTHOR_PROFILE_PREFIX = '/author_profile';

  static String MESSAGE_DETAIL(String conversationId) =>
      '/message_detail/$conversationId';

  static String LOCAL_FAVORITE_DETAIL(String folderId) =>
      '/local_favorite_detail/$folderId';

  static const AI_TRANSLATION_SETTINGS_PAGE =
      _Paths.AI_TRANSLATION_SETTINGS_PAGE;
  static const TRANSLATION_SETTINGS_PAGE = _Paths.TRANSLATION_SETTINGS_PAGE;
  static const DOWNLOAD_SETTINGS_PAGE = _Paths.DOWNLOAD_SETTINGS_PAGE;
  static const FORUM_SETTINGS_PAGE = _Paths.FORUM_SETTINGS_PAGE;

  static const EMOJI_LIBRARY = _Paths.EMOJI_LIBRARY;

  static const LAYOUT_SETTINGS_PAGE = _Paths.LAYOUT_SETTINGS_PAGE;
  static const NAVIGATION_ORDER_SETTINGS_PAGE =
      _Paths.NAVIGATION_ORDER_SETTINGS_PAGE;

  static String TAG_VIDEOS(String tagId) =>
      _Paths.TAG_VIDEOS.replaceAll(':tagId', tagId);
  static String TAG_GALLERIES(String tagId) =>
      _Paths.TAG_GALLERIES.replaceAll(':tagId', tagId);
  static const PERSONAL_PROFILE = _Paths.PERSONAL_PROFILE;
}

abstract class _Paths {
  _Paths._();

  static const HOME = '/';
  static const LOGIN = '/login';
  static const PERSONAL_PROFILE = '/personal_profile';
  static const VIDEO_DETAIL = '/video_detail/:videoId';
  static const VIDEO_DETAIL_PREFIX = '/video_detail';
  static const SETTINGS_PAGE = '/settings_page';
  static const PLAYER_SETTINGS_PAGE = '/player_settings_page';
  static const PROXY_SETTINGS_PAGE = '/proxy_settings_page';
  static const THEME_SETTINGS_PAGE = '/theme_settings_page';
  static const AUTHOR_PROFILE = '/author_profile/:userName';
  static const NOT_FOUND = '/not_found';
  static const SEARCH_RESULT = '/search_result';
  static const PLAYLIST_DETAIL = '/playlist_detail/:id';
  static const PLAY_LIST = '/play_list';
  static const FIRST_TIME_SETUP = '/first_time_setup';

  static const GALLERY = '/gallery';
  static const GALLERY_DETAIL = '/gallery_detail/:galleryId';
  static const SUBSCRIPTIONS = '/subscriptions';
  static const SIGN_IN = '/sign_in';
  static const FAVORITE = '/favorite';
  static const FRIENDS = '/friends';
  static const FOLLOWING_LIST = '/following_list/:userId';
  static const FOLLOWERS_LIST = '/followers_list/:userId';
  static const ROOT = '/';
  static const HISTORY_LIST = '/history_list';
  static const AI_TRANSLATION_SETTINGS_PAGE = '/ai_translation_settings';
  static const TRANSLATION_SETTINGS_PAGE = '/translation_settings';
  static const DOWNLOAD_SETTINGS_PAGE = '/download_settings';
  static const FORUM_SETTINGS_PAGE = '/forum_settings_page';
  static const TAG_VIDEOS = '/tag_videos/:tagId';
  static const TAG_GALLERIES = '/tag_galleries/:tagId';
  static const EMOJI_LIBRARY = '/emoji_library';
  static const LAYOUT_SETTINGS_PAGE = '/layout_settings_page';
  static const NAVIGATION_ORDER_SETTINGS_PAGE =
      '/navigation_order_settings_page';
}
