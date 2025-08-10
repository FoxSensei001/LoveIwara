import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/conversation/conversation_page.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/message_list_widget.dart';
import 'package:i_iwara/app/ui/pages/favorite/favorite_folder_detail_page.dart';
import 'package:i_iwara/app/ui/pages/favorite/favorite_list_page.dart';
import 'package:i_iwara/app/ui/pages/favorites/my_favorites.dart';
import 'package:i_iwara/app/ui/pages/follows/follows_page.dart';
import 'package:i_iwara/app/ui/pages/forum/thread_detail_page.dart';
import 'package:i_iwara/app/ui/pages/forum/thread_list_page.dart';
import 'package:i_iwara/app/ui/pages/friends/friends_page.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';
import 'package:i_iwara/app/ui/pages/history/history_list_page.dart';
import 'package:i_iwara/app/ui/pages/notifications/notification_list_page.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list_detail.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/tag_blacklist_page.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_gallery_list_page.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/video_detail_page_v2.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/gallery_download_task_detail_page.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_video_list_page.dart';
import 'package:i_iwara/app/models/tag.model.dart';

import '../routes/app_routes.dart';
import '../ui/pages/author_profile/author_profile_page.dart';
import '../ui/pages/gallery_detail/gallery_detail_page.dart';
import '../ui/pages/search/search_result.dart';
import '../ui/pages/post_detail/post_detail_page.dart';

/// 定义转场动画类型
enum TransitionType {
  slideRight, // 从右向左滑动
  fade,       // 淡入淡出
  none,       // 无动画
}

class AppService extends GetxService {
  // 默认标题栏高度
  static const double titleBarHeight = 26.0;

  final RxBool _showTitleBar = false.obs; // 是否显示标题栏 [ 全局使用 ]
  final RxBool _showRailNavi = true.obs; // 是否显示侧边栏 [ Home路由下使用 ]
  final RxBool _showBottomNavi = true.obs; // 是否显示底部导航栏 [ Home路由下使用 ]
  final RxInt _currentIndex = 0.obs; // 当前底部/侧边导航栏索引

  static final GlobalKey<ScaffoldState> globalDrawerKey =
      GlobalKey<ScaffoldState>();

  // 获取Home页面的navigatorKey
  static final GlobalKey<NavigatorState> homeNavigatorKey =
      Get.nestedKey(Routes.HOME)!.navigatorKey;

  AppService() {
    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      _showTitleBar.value = true;
    }
  }

  bool get showTitleBar => _showTitleBar.value;

  set showTitleBar(bool value) => {
        if (GetPlatform.isDesktop && !GetPlatform.isWeb)
          _showTitleBar.value = value
      };

  bool get showRailNavi => _showRailNavi.value;

  set showBottomNavi(bool value) => _showBottomNavi.value = value;

  bool get showBottomNavi => _showBottomNavi.value;

  set showRailNavi(bool value) => _showRailNavi.value = value;

  int get currentIndex => _currentIndex.value;

  set currentIndex(int value) => _currentIndex.value = value;

  static void switchGlobalDrawer() {
    if (globalDrawerKey.currentState!.isDrawerOpen) {
      globalDrawerKey.currentState!.openEndDrawer();
    } else {
      globalDrawerKey.currentState!.openDrawer();
    }
  }

  static void hideGlobalDrawer() {
    globalDrawerKey.currentState!.closeDrawer();
  }

  void toggleTitleBar() {
    _showTitleBar.value = !_showTitleBar.value;
  }

  updateIndex(int value) {
    _currentIndex.value = value;
  }

  static void tryPop({bool closeAll = false}) {
    // LogUtils.d('tryPop', 'AppService');
    if (AppService.globalDrawerKey.currentState!.isDrawerOpen) {
      AppService.globalDrawerKey.currentState!.openEndDrawer();
      // LogUtils.d('关闭Drawer', 'AppService');
    } else {
      // 先判断是否有打开的对话框或底部表单
      if (Get.isDialogOpen ?? false) {
        Get.close(closeAll: closeAll);
        // LogUtils.d('关闭Get.isDialogOpen', 'AppService');
      } else if (Get.isBottomSheetOpen ?? false) {
        Get.close(closeAll: closeAll);
        // LogUtils.d('关闭Get.isBottomSheetOpen', 'AppService');
      } else {
        GetDelegate? homeDele = Get.nestedKey(Routes.HOME);
        GetDelegate? rootDele = Get.nestedKey(null);

        if (homeDele?.canBack ?? false) {
          homeDele?.back();
          // LogUtils.d('关闭homeDele?.canBack', 'AppService');
        } else if (homeDele?.navigatorKey.currentState?.canPop() ?? false) {
          homeDele?.navigatorKey.currentState?.pop();
          // LogUtils.d(
              // '关闭homeDele?.navigatorKey.currentState?.canPop()', 'AppService');
        } else if (rootDele?.canBack ?? false) {
          rootDele?.back();
          //  LogUtils.d('关闭rootDele?.canBack', 'AppService');
        } else {
          // 退出应用
          SystemNavigator.pop();
          // LogUtils.d('关闭Get.back()', 'AppService');
        }
      }
    }
  }

  void hideSystemUI({hideTitleBar = true, hideRailNavi = true}) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    showTitleBar = !hideTitleBar;
    showRailNavi = !hideRailNavi;
  }

  void showSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    showTitleBar = true;
    showRailNavi = true;
  }
}

class NaviService {
  /// 通用页面导航方法
  static void _navigateToPage({
    required String routeName,
    required Widget page,
    Duration transitionDuration = const Duration(milliseconds: 200),
    TransitionType transitionType = TransitionType.slideRight,
  }) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionDuration: transitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case TransitionType.none:
            return child;
        }
      },
    ));
  }

  /// 跳转到作者个人主页
  static void navigateToAuthorProfilePage(String username) {
    _navigateToPage(
      routeName: Routes.AUTHOR_PROFILE(username),
      page: AuthorProfilePage(username: username),
    );
  }

  /// 跳转到图库详情页
  static void navigateToGalleryDetailPage(String id) {
    _navigateToPage(
      routeName: Routes.GALLERY_DETAIL(id),
      page: GalleryDetailPage(imageModelId: id),
    );
  }

  /// 跳转到视频详情页
  static void navigateToVideoDetailPage(String id, [Map<String, dynamic>? extData]) { // 注意 extData 外面的 []
    _navigateToPage(
      routeName: Routes.VIDEO_DETAIL(id),
      page: MyVideoDetailPage(videoId: id, extData: extData),
    );
  }

  /// 跳转到登录页
  static void navigateToSignInPage() {
    Get.toNamed(Routes.SIGN_IN);
  }

  /// 跳转到搜索结果页
  static void toSearchPage({
    required String searchInfo,
    required String segment,
    String? searchType,
    Map<String, dynamic>? extData,
  }) {
    _navigateToPage(
      routeName: Routes.SEARCH_RESULT,
      page: SearchResult(
        initialSearch: searchInfo,
        initialSegment: segment,
        initialSearchType: searchType,
        extData: extData,
      ),
    );
  }

  /// 跳转到播放列表详情页
  static navigateToPlayListDetail(String id, {bool isMine = false}) {
    _navigateToPage(
      routeName: Routes.PLAYLIST_DETAIL(id),
      page: PlayListDetailPage(playlistId: id, isMine: isMine),
    );
  }

  /// 跳转到播放列表页
  static void navigateToPlayListPage(String userId, {bool isMine = false}) {
    _navigateToPage(
      routeName: Routes.PLAY_LIST,
      page: PlayListPage(userId: userId, isMine: isMine),
    );
  }

  /// 跳转到最爱页
  static void navigateToFavoritePage() {
    _navigateToPage(
      routeName: Routes.FAVORITE,
      page: const MyFavorites(),
    );
  }

  /// 跳转到好友列表页
  static void navigateToFriendsPage() {
    _navigateToPage(
      routeName: Routes.FRIENDS,
      page: const FriendsPage(),
    );
  }

  /// 跳转到历史记录列表页
  static void navigateToHistoryListPage() {
    _navigateToPage(
      routeName: Routes.HISTORY_LIST,
      page: const HistoryListPage(),
    );
  }

  /// 跳转到全屏视频播放页
  static void navigateToFullScreenVideoPlayerScreenPage(
      MyVideoStateController myVideoStateController) {
    _navigateToPage(
      routeName: Routes.FULL_SCREEN_VIDEO_PLAYER_SCREEN,
      page: MyVideoScreen(
        isFullScreen: true,
        myVideoStateController: myVideoStateController,
      ),
      transitionType: TransitionType.none,
      transitionDuration: Duration.zero,
    );
  }

  static void navigateToFollowingListPage(String userId, String name, String username) {
    _navigateToPage(
      routeName: Routes.FOLLOWING_LIST(userId),
      page: FollowsPage(
        userId: userId,
        name: name,
        username: username,
        initIsFollowing: true,
      ),
    );
  }

  static void navigateToFollowersListPage(String userId, String name, String username) {
    _navigateToPage(
      routeName: Routes.FOLLOWERS_LIST(userId),
      page: FollowsPage(
        userId: userId,
        name: name,
        username: username,
        initIsFollowing: false,
      ),
    );
  }

  /// 跳转到帖子详情页
  static void navigateToPostDetailPage(String id, PostModel? post) {
    _navigateToPage(
      routeName: Routes.POST_DETAIL(id),
      page: PostDetailPage(postId: id),
    );
  }

  /// 跳转到图片详情页
  static void navigateToPhotoViewWrapper({
    required List<ImageItem> imageItems,
    required int initialIndex,
    required List<MenuItem> Function(dynamic context, dynamic item) menuItemsBuilder,
  }) {
    _navigateToPage(
      routeName: Routes.PHOTO_VIEW_WRAPPER,
      page: MyGalleryPhotoViewWrapper(
        galleryItems: imageItems,
        initialIndex: initialIndex,
        menuItemsBuilder: menuItemsBuilder,
      ),
      transitionDuration: const Duration(milliseconds: 300),
      transitionType: TransitionType.fade,
    );
  }

  /// 跳转到标签黑名单页
  static void navigateToTagBlacklistPage() {
    _navigateToPage(
      routeName: Routes.TAG_BLACKLIST,
      page: const TagBlacklistPage(),
    );
  }

  /// 跳转到论坛帖子列表页
  static void navigateToForumThreadListPage(String categoryId) {
    _navigateToPage(
      routeName: Routes.FORUM_THREAD_LIST(categoryId),
      page: ThreadListPage(categoryId: categoryId),
    );
  }

  /// 跳转到论坛帖子详情页
  static void navigateToForumThreadDetailPage(String categoryId, String threadId) {
    _navigateToPage(
      routeName: Routes.FORUM_THREAD_DETAIL(categoryId, threadId),
      page: ThreadDetailPage(categoryId: categoryId, threadId: threadId),
    );
  }

  /// 跳转到通知列表页
  static void navigateToNotificationListPage() {
    _navigateToPage(
      routeName: Routes.NOTIFICATION_LIST,
      page: const NotificationListPage(),
    );
  }

  /// 跳转到会话列表页
  static void navigateToConversationPage() {
    _navigateToPage(
      routeName: Routes.CONVERSATION,
      page: const ConversationPage(),
    );
  }

  // 跳转到下载任务列表页
  static void navigateToDownloadTaskListPage() {
    _navigateToPage(
      routeName: Routes.DOWNLOAD_TASK_LIST,
      page: const DownloadTaskListPage(),
    );
  }

  // 跳转到图库下载任务详情页
  static void navigateToGalleryDownloadTaskDetailPage(String taskId) {
    _navigateToPage(
      routeName: Routes.GALLERY_DOWNLOAD_TASK_DETAIL,
      page: GalleryDownloadTaskDetailPage(taskId: taskId),
    );
  }

  /// 跳转到消息详情页
  static void navigateToMessagePage(ConversationModel conversation) {
    _navigateToPage(
      routeName: Routes.MESSAGE_DETAIL(conversation.id),
      page: MessageListWidget(
        conversation: conversation,
        fromNarrowScreen: true,
      ),
    );
  }

  /// 跳转到本地收藏页
  static void navigateToLocalFavoritePage() {
    _navigateToPage(
      routeName: Routes.LOCAL_FAVORITE,
      page: const FavoriteListPage(),
    );
  }

  /// 跳转到本地收藏夹详情页
  static void navigateToLocalFavoriteDetailPage(String folderId, String? folderTitle) {
    _navigateToPage(
      routeName: Routes.LOCAL_FAVORITE_DETAIL(folderId),
      page: FavoriteFolderDetailPage(
        folderId: folderId,
        folderTitle: folderTitle,
      ),
    );
  }

  /// 跳转到标签视频列表页
  static void navigateToTagVideoListPage(Tag tag) {
    _navigateToPage(
      routeName: Routes.TAG_VIDEOS(tag.id),
      page: TagVideoListPage(tag: tag),
    );
  }

  /// 跳转到标签图库列表页
  static void navigateToTagGalleryListPage(Tag tag) {
    _navigateToPage(
      routeName: Routes.TAG_GALLERIES(tag.id),
      page: TagGalleryListPage(tag: tag),
    );
  }
}

