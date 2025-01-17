// 定义所有路由路径
abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const POPULAR_VIDEOS =
      ROOT; // /home/popular_videos
  static const GALLERY = _Paths.HOME + _Paths.GALLERY;
  static const SUBSCRIPTIONS = _Paths.HOME + _Paths.SUBSCRIPTIONS;
  static String VIDEO_DETAIL(String videoId) => _Paths.HOME + _Paths.VIDEO_DETAIL.replaceAll(':videoId', videoId);
  static String VIDEO_DETAIL_PREFIX = _Paths.HOME + _Paths.VIDEO_DETAIL;
  static String AUTHOR_PROFILE(String userName) => _Paths.HOME + _Paths.AUTHOR_PROFILE.replaceAll(':userName', userName);
  static String GALLERY_DETAIL(String galleryId) => _Paths.HOME + _Paths.GALLERY_DETAIL.replaceAll(':galleryId', galleryId);

  static const LOGIN = _Paths.LOGIN;
  static const SETTINGS_PAGE = _Paths.SETTINGS_PAGE;
  static const PLAYER_SETTINGS_PAGE = _Paths.PLAYER_SETTINGS_PAGE;
  static const PROXY_SETTINGS_PAGE = _Paths.PROXY_SETTINGS_PAGE;
  static const THEME_SETTINGS_PAGE = _Paths.THEME_SETTINGS_PAGE;
  static const NOT_FOUND = _Paths.NOT_FOUND;
  static const SIGN_IN = _Paths.SIGN_IN;

  static const ROOT = _Paths.ROOT;
  static const SPLASH = '/splash';

  static const SEARCH_RESULT = _Paths.SEARCH_RESULT;

  static const PLAY_LIST = _Paths.PLAY_LIST;

  static const FAVORITE = _Paths.FAVORITE;

  static const FRIENDS = _Paths.FRIENDS;

  static const HISTORY_LIST = _Paths.HISTORY_LIST;

  static const FULL_SCREEN_VIDEO_PLAYER_SCREEN = '/full_screen_video_player_screen';

  static String PLAYLIST_DETAIL(String id) => _Paths.PLAYLIST_DETAIL.replaceAll(':id', id);

  static String FOLLOWING_LIST(String userId) => _Paths.FOLLOWING_LIST.replaceAll(':userId', userId);

  static String FOLLOWERS_LIST(String userId) => _Paths.FOLLOWERS_LIST.replaceAll(':userId', userId);

  static const ABOUT_PAGE = '/settings/about';

  static const DOWNLOAD_TASK_LIST = '/download_task_list';
  static const GALLERY_DOWNLOAD_TASK_DETAIL = '/gallery_download_task_detail';

  static const PHOTO_VIEW_WRAPPER = '/photo_view_wrapper';

  static const TAG_BLACKLIST = '/tag_blacklist';

  static const FORUM = '/forum';

  static String POST_DETAIL(String id) => '/post/$id';

  static FORUM_THREAD_LIST(String categoryId) => '/forum/$categoryId';

  static FORUM_THREAD_DETAIL(String categoryId, String threadId) => '/forum/$categoryId/$threadId';

  static const APP_SETTINGS_PAGE = '/app_settings_page';

  static const NOTIFICATION_LIST = '/notification_list';

  static const CONVERSATION = '/conversation';

  static MESSAGE_DETAIL(String conversationId) => '/message_detail/$conversationId';
}

abstract class _Paths {
  _Paths._();

  static const HOME = '/';
  static const LOGIN = '/login';
  static const VIDEO_DETAIL = '/video_detail/:videoId';
  static const SETTINGS_PAGE = '/settings_page';
  static const PLAYER_SETTINGS_PAGE = '/player_settings_page';
  static const PROXY_SETTINGS_PAGE = '/proxy_settings_page';
  static const THEME_SETTINGS_PAGE = '/theme_settings_page';
  static const AUTHOR_PROFILE = '/author_profile/:userName';
  static const NOT_FOUND = '/not_found';
  static const SEARCH_RESULT = '/search_result';
  static const PLAYLIST_DETAIL = '/playlist_detail/:id';
  static const PLAY_LIST = '/play_list';

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
}
