import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/ui/pages/favorites/my_favorites.dart';
import 'package:i_iwara/app/ui/pages/follows/follows_page.dart';
import 'package:i_iwara/app/ui/pages/friends/friends_page.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';
import 'package:i_iwara/app/ui/pages/history/history_list_page.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list_detail.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/video_detail_page_v2.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/pages/download/gallery_download_task_detail_page.dart';

import '../routes/app_routes.dart';
import '../ui/pages/author_profile/author_profile_page.dart';
import '../ui/pages/gallery_detail/gallery_detail_page.dart';
import '../ui/pages/search/search_result.dart';
import '../ui/pages/post_detail/post_detail_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
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
      LogUtils.d('关闭Drawer', 'AppService');
    } else {
      globalDrawerKey.currentState!.openDrawer();
      LogUtils.d('打开Drawer', 'AppService');
    }
  }

  void toggleTitleBar() {
    _showTitleBar.value = !_showTitleBar.value;
  }

  updateIndex(int value) {
    _currentIndex.value = value;
  }

  static void tryPop() {
    LogUtils.d('tryPop', 'AppService');
    if (CommonConstants.isForceUpdate) {
      showToastWidget(MDToastWidget(message: slang.t.errors.forceUpdateNotPermittedToGoBack, type: MDToastType.error));
      return;
    }
    if (AppService.globalDrawerKey.currentState!.isDrawerOpen) {
      AppService.globalDrawerKey.currentState!.openEndDrawer();
      LogUtils.d('关闭Drawer', 'AppService');
    } else {
      // 先判断是否有打开的对话框或底部表单
      if (Get.isDialogOpen ?? false) {
        Get.closeAllDialogs();
        LogUtils.d('关闭Get.isDialogOpen', 'AppService');
      } else if (Get.isBottomSheetOpen ?? false) {
        Get.closeAllBottomSheets();
        LogUtils.d('关闭Get.isBottomSheetOpen', 'AppService');
      } else {
        GetDelegate? homeDele = Get.nestedKey(Routes.HOME);
        GetDelegate? rootDele = Get.nestedKey(null);

        if (homeDele?.canBack ?? false) {
          homeDele?.back();
          LogUtils.d('关闭homeDele?.canBack', 'AppService');
        } else if (homeDele?.navigatorKey.currentState?.canPop() ?? false) {
          homeDele?.navigatorKey.currentState?.pop();
          LogUtils.d(
              '关闭homeDele?.navigatorKey.currentState?.canPop()', 'AppService');
        } else if (rootDele?.canBack ?? false) {
          rootDele?.back();
          LogUtils.d('关闭rootDele?.canBack', 'AppService');
        } else {
          // 退出应用
          SystemNavigator.pop();
          LogUtils.d('关闭Get.back()', 'AppService');
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
  /// 跳转到作者个人主页
  static void navigateToAuthorProfilePage(String username) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.AUTHOR_PROFILE(username)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AuthorProfilePage(
          username: username,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到图库详情页
  static void navigateToGalleryDetailPage(String id) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.GALLERY_DETAIL(id)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GalleryDetailPage(
          imageModelId: id,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到视频详情页
  static void navigateToVideoDetailPage(String id) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.VIDEO_DETAIL(id)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MyVideoDetailPage(videoId: id);
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到登录页
  static void navigateToSignInPage() {
    Get.toNamed(Routes.SIGN_IN);
  }

  /// 跳转到搜索结果页
  static void toSearchPage(
      {required String searchInfo, required String segment}) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.SEARCH_RESULT),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SearchResult();
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到播放列表详情页
  static navigateToPlayListDetail(String id, {bool isMine = false}) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.PLAYLIST_DETAIL(id)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PlayListDetailPage(playlistId: id, isMine: isMine);
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到播放列表页
  static void navigateToPlayListPage(String userId, {bool isMine = false}) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.PLAY_LIST),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PlayListPage(userId: userId, isMine: isMine);
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到最爱页
  static void navigateToFavoritePage() {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.FAVORITE),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const MyFavorites();
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到好友列表页
  static void navigateToFriendsPage() {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.FRIENDS),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const FriendsPage();
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到历史记录列表页
  static void navigateToHistoryListPage() {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.HISTORY_LIST),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const HistoryListPage();
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到全屏视频播放页
  static void navigateToFullScreenVideoPlayerScreenPage(
      MyVideoStateController myVideoStateController) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.FULL_SCREEN_VIDEO_PLAYER_SCREEN),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MyVideoScreen(
          isFullScreen: true,
          myVideoStateController: myVideoStateController,
        );
      },
    ));
  }

  static void navigateToFollowingListPage(String userId, String name, String username) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.FOLLOWING_LIST(userId)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FollowsPage( 
          userId: userId,
          name: name,
          username: username,
          initIsFollowing: true,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    ));
  }

  static void navigateToFollowersListPage(String userId, String name, String username) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.FOLLOWERS_LIST(userId)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FollowsPage(
          userId: userId,
          name: name,
          username: username,
          initIsFollowing: false,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      // 从右到左的原生动画
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到帖子详情页
  /// @param id 帖子ID
  /// @param post 帖子模型，当值存在时可以用于初步渲染一些数据，以便用户快速浏览
  static void navigateToPostDetailPage(String id, PostModel? post) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(name: Routes.POST_DETAIL(id)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PostDetailPage(postId: id);
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    ));
  }

  /// 跳转到图片详情页
  static void navigateToPhotoViewWrapper({required List<ImageItem> imageItems, required int initialIndex, required List<MenuItem> Function(dynamic context, dynamic item) menuItemsBuilder}) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.PHOTO_VIEW_WRAPPER),
      pageBuilder: (context, animation, secondaryAnimation) {
        return MyGalleryPhotoViewWrapper(
          galleryItems: imageItems,
          initialIndex: initialIndex,
          menuItemsBuilder: menuItemsBuilder,
        );
      },
    ));
  }

  // 跳转到下载任务列表页
  static void navigateToDownloadTaskListPage() {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: const RouteSettings(name: Routes.DOWNLOAD_TASK_LIST),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const DownloadTaskListPage();
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    ));
  }

  // 跳转到图库下载任务详情页
  static void navigateToGalleryDownloadTaskDetailPage(String taskId) {
    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
      settings: RouteSettings(
        name: Routes.GALLERY_DOWNLOAD_TASK_DETAIL,
        arguments: taskId,
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GalleryDownloadTaskDetailPage(taskId: taskId);
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        );
      },
    ));
  }
}
