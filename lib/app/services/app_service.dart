import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:uuid/uuid.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_fullscreen_handoff.model.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/utils/iwara_deep_link_utils.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../routes/app_router.dart';
import '../routes/home_shell_navigation.dart';
import 'config_service.dart';
import '../ui/widgets/restart_app_widget.dart';
import 'auth_service.dart';
import 'message_service.dart';
import 'pop_coordinator.dart';

class AppService extends GetxService {
  // 默认标题栏高度
  static const double titleBarHeight = 26.0;

  final RxBool _showTitleBar = false.obs; // 是否显示标题栏 [ 全局使用 ]
  final RxBool _showRailNavi = true.obs; // 是否显示侧边栏 [ Home路由下使用 ]
  final RxBool _showBottomNavi = true.obs; // 是否显示底部导航栏 [ Home路由下使用 ]
  final RxInt _currentIndex = 0.obs; // 当前底部/侧边导航栏索引
  final Rx<IwaraSite> _currentSiteMode = IwaraSite.main.obs;
  final RxInt _siteModeVersion = 0.obs;
  final RxInt _homeContentVersion = 0.obs;

  /// One-shot guard used by router redirect logic.
  /// See `lib/app/routes/app_router.dart`.
  bool hasAppliedPreferredHomeRedirect = false;

  /// StatefulShellRoute 的 navigationShell 引用，
  /// 由 StatefulShellRoute builder 设置，
  /// 供 HomeShellScaffold NavigationRail/BottomNav tab 切换使用。
  StatefulNavigationShell? navigationShell;

  // 导航项配置
  static Map<String, NavigationItem> navigationItems = {
    'video': NavigationItem(
      key: 'video',
      title: slang.t.common.video,
      icon: Icons.video_library,
      pageIndex: 0,
    ),
    'gallery': NavigationItem(
      key: 'gallery',
      title: slang.t.common.gallery,
      icon: Icons.photo,
      pageIndex: 1,
    ),
    'subscription': NavigationItem(
      key: 'subscription',
      title: slang.t.common.subscriptions,
      icon: Icons.subscriptions,
      pageIndex: 2,
    ),
    'forum': NavigationItem(
      key: 'forum',
      title: slang.t.settings.forum,
      icon: Icons.forum,
      pageIndex: 3,
    ),
    'news': NavigationItem(
      key: 'news',
      title: slang.t.settings.news,
      icon: Icons.newspaper_rounded,
      pageIndex: 4,
    ),
  };

  static final GlobalKey<ScaffoldState> globalDrawerKey =
      GlobalKey<ScaffoldState>();

  AppService() {
    if (GetPlatform.isDesktop) {
      _showTitleBar.value = true;
    }
  }

  bool get showTitleBar => _showTitleBar.value;

  set showTitleBar(bool value) => {
    if (GetPlatform.isDesktop) _showTitleBar.value = value,
  };

  bool get showRailNavi => _showRailNavi.value;

  set showBottomNavi(bool value) => _showBottomNavi.value = value;

  bool get showBottomNavi => _showBottomNavi.value;

  set showRailNavi(bool value) => _showRailNavi.value = value;

  int get currentIndex => _currentIndex.value;

  set currentIndex(int value) => _currentIndex.value = value;

  IwaraSite get currentSiteMode => _currentSiteMode.value;

  int get siteModeVersion => _siteModeVersion.value;

  int get homeContentVersion => _homeContentVersion.value;

  void invalidateHomeContent() {
    _homeContentVersion.value++;
  }

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

  void updateIndex(int value) {
    _currentIndex.value = value;
  }

  static const List<String> _defaultNavigationOrder = [
    ...HomeShellNavigation.canonicalOrder,
  ];

  List<String> get navigationDisplayOrder {
    if (!Get.isRegistered<ConfigService>()) {
      return List<String>.from(_defaultNavigationOrder);
    }
    final orderRaw = Get.find<ConfigService>()[ConfigKey.NAVIGATION_ORDER];
    // Use a single normalization implementation so UI order and routing agree.
    return HomeShellNavigation.normalizeOrder(orderRaw);
  }

  int get preferredHomeBranchIndex {
    final order = navigationDisplayOrder;
    if (order.isEmpty) {
      return 0;
    }
    return HomeShellNavigation.branchIndexForKey(order.first);
  }

  String get preferredHomePath {
    // Keep in sync with StatefulShellRoute branch root paths.
    return HomeShellNavigation.pathForBranchIndex(preferredHomeBranchIndex);
  }

  void syncSiteModeFromConfig(ConfigService configService) {
    final savedMode = configService[ConfigKey.APP_SITE_MODE] as String?;
    _currentSiteMode.value = IwaraSiteUtils.fromExtra(savedMode);
  }

  Future<void> applyGlobalSiteMode(
    IwaraSite site, {
    bool resetNavigation = true,
    Future<void> Function()? onApplied,
  }) async {
    if (_currentSiteMode.value == site) {
      return;
    }

    if (Get.isRegistered<ConfigService>()) {
      final configService = Get.find<ConfigService>();
      await configService.setSetting(ConfigKey.APP_SITE_MODE, site.name);
    }

    if (Get.isRegistered<MessageService>()) {
      final messageService = Get.find<MessageService>();
      final t = slang.t;
      final siteLabel = site == IwaraSite.ai
          ? t.siteMode.aiSite
          : t.siteMode.mainSite;
      messageService.queuePendingSiteModeToast(
        t.siteMode.switched(site: siteLabel),
        MDToastType.success,
      );
    }

    _currentSiteMode.value = site;
    _siteModeVersion.value++;
    invalidateHomeContent();

    try {
      if (Get.isRegistered<AuthService>()) {
        Get.find<AuthService>().updateSiteMode(site);
      }
    } catch (_) {}

    try {
      hideGlobalDrawer();
    } catch (_) {}

    if (resetNavigation) {
      final preferredBranch = preferredHomeBranchIndex;
      final preferredPath = preferredHomePath;

      try {
        appRouter.go(preferredPath);
      } catch (_) {}

      try {
        navigationShell?.goBranch(preferredBranch, initialLocation: true);
      } catch (_) {}

      _currentIndex.value = preferredBranch;
    }

    RestartApp.restartApp();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (onApplied != null) {
        await onApplied();
      }
    });
  }

  static void tryPop({BuildContext? context, bool closeAll = false}) {
    final ctx = context ?? rootNavigatorKey.currentContext;
    if (ctx == null) {
      LogUtils.w(
        'tryPop: context is null, fallback SystemNavigator.pop',
        'AppService',
      );
      SystemNavigator.pop();
      return;
    }

    final route = ModalRoute.of(ctx);
    LogUtils.d(
      'tryPop: closeAll=$closeAll, '
          'routeType=${route?.runtimeType}, '
          'routeCurrent=${route?.isCurrent}, '
          'rootCanPop=${rootNavigatorKey.currentState?.canPop() ?? false}, '
          'shellCanPop=${shellNavigatorKey.currentState?.canPop() ?? false}, '
          'appRouterCanPop=${appRouter.canPop()}',
      'AppService',
    );

    if (closeAll) {
      // Close overlays/drawer/internal panels until none remains.
      var safety = 16;
      while (safety-- > 0 && PopCoordinator.tryCloseOverlayOrDrawer()) {}
      return;
    }

    PopCoordinator.handleBack(ctx);
  }

  void hideSystemUI({bool hideTitleBar = true, bool hideRailNavi = true}) {
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

class NavigationItem {
  final String key;
  final String title;
  final IconData icon;
  final int pageIndex;

  const NavigationItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.pageIndex,
  });
}

class NaviService {
  static const String mediaLikePatchLikedKey = '__media_like_patch_liked';
  static const String mediaLikePatchCountKey = '__media_like_patch_count';

  static void _ensureAndroidBackDispatcherPriority(String reason) {
    if (!GetPlatform.isAndroid) return;

    void apply(String phase) {
      PopCoordinator.ensureDispatcherPriority('NaviService $reason ($phase)');
      LogUtils.d(
        'ensureDispatcherPriority: reason=$reason, phase=$phase, '
            'rootCanPop=${rootNavigatorKey.currentState?.canPop() ?? false}, '
            'shellCanPop=${shellNavigatorKey.currentState?.canPop() ?? false}, '
            'appRouterCanPop=${appRouter.canPop()}',
        'NaviService',
      );
    }

    // Apply immediately (best-effort), then again after upcoming frame(s).
    // This helps in fast sequences like "dialog pop -> push detail" where
    // route transitions can temporarily disturb the dispatcher priority.
    apply('immediate');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apply('postFrame1');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        apply('postFrame2');
      });
    });
  }

  /// 跳转到作者个人主页
  static void navigateToAuthorProfilePage(
    String username, {
    User? initialUser,
    String? initialTab,
  }) {
    appRouter.push(
      IwaraDeepLinkUtils.buildAuthorProfileLocation(username, tab: initialTab),
      extra: initialUser == null
          ? null
          : AuthorProfileExtra(initialUser: initialUser),
    );
    _ensureAndroidBackDispatcherPriority('push author_profile/$username');
  }

  /// 跳转到图库详情页
  static Future<Object?> navigateToGalleryDetailPage(
    String id, {
    String? coverUrl,
    String? title,
    int? imageCount,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    String? authorRole,
    bool? authorPremium,
    Map<String, dynamic>? extData,
  }) {
    final shouldAttachExtra =
        coverUrl != null ||
        title != null ||
        imageCount != null ||
        authorId != null ||
        authorName != null ||
        authorUsername != null ||
        authorAvatarUrl != null ||
        authorRole != null ||
        authorPremium != null ||
        extData != null;

    final future = appRouter.push(
      '/gallery_detail/$id',
      extra: shouldAttachExtra
          ? GalleryDetailExtra(
              coverUrl: coverUrl,
              title: title,
              imageCount: imageCount,
              authorId: authorId,
              authorName: authorName,
              authorUsername: authorUsername,
              authorAvatarUrl: authorAvatarUrl,
              authorRole: authorRole,
              authorPremium: authorPremium,
              extData: extData,
            )
          : null,
    );
    _ensureAndroidBackDispatcherPriority('push gallery_detail/$id');
    return future;
  }

  /// 跳转到视频详情页
  static Future<Object?> navigateToVideoDetailPage(
    String id, {
    Map<String, dynamic>? extData,
    InnerPlaylistContext? innerPlaylistContext,
    bool forceAutoPlay = false,
    bool forceEnterFullscreen = false,
    Video? initialVideoInfo,
    VideoFullscreenHandoff? fullscreenHandoff,
  }) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return Future<Object?>.value();

    try {
      final currentPath = appRouter.routeInformationProvider.value.uri.path;
      final targetPath = '/video_detail/$normalizedId';
      if (currentPath == targetPath) {
        return Future<Object?>.value();
      }
    } catch (_) {
      // ignore and continue push
    }

    final future = appRouter.push(
      '/video_detail/$normalizedId',
      extra:
          extData != null ||
              innerPlaylistContext != null ||
              forceAutoPlay ||
              forceEnterFullscreen ||
              initialVideoInfo != null
          ? VideoDetailExtra(
              extData: extData,
              innerPlaylistContext: innerPlaylistContext,
              forceAutoPlay: forceAutoPlay,
              forceEnterFullscreen: forceEnterFullscreen,
              initialVideoInfo: initialVideoInfo,
              fullscreenHandoff: fullscreenHandoff,
            )
          : null,
    );
    _ensureAndroidBackDispatcherPriority('push video_detail/$normalizedId');
    return future;
  }

  /// 跳转到登录页
  static void navigateToSignInPage() {
    appRouter.push('/sign_in');
  }

  /// 跳转到搜索结果页
  static void toSearchPage({
    required String searchInfo,
    required SearchSegment segment,
    String? searchType,
    Map<String, dynamic>? extData,
    List<Filter>? filters,
    String? sort,
  }) {
    appRouter.push(
      '/search_result',
      extra: SearchResultExtra(
        searchInfo: searchInfo,
        segment: segment,
        searchType: searchType,
        extData: extData,
        filters: filters,
        sort: sort,
      ),
    );
  }

  /// 跳转到播放列表详情页
  static void navigateToPlayListDetail(String id, {bool isMine = false}) {
    appRouter.push(
      '/playlist_detail/$id',
      extra: PlayListDetailExtra(isMine: isMine),
    );
  }

  /// 跳转到播放列表页
  static void navigateToPlayListPage(String userId, {bool isMine = false}) {
    appRouter.push(
      '/play_list',
      extra: PlayListExtra(userId: userId, isMine: isMine),
    );
  }

  /// 跳转到最爱页
  static void navigateToFavoritePage() {
    appRouter.push('/favorite');
  }

  /// 跳转到好友列表页
  static void navigateToFriendsPage() {
    appRouter.push('/friends');
  }

  /// 跳转到历史记录列表页
  static void navigateToHistoryListPage() {
    appRouter.push('/history_list');
  }

  static void navigateToFollowingListPage(
    String userId,
    String name,
    String username,
  ) {
    appRouter.push(
      '/following_list/$userId',
      extra: FollowsPageExtra(
        name: name,
        username: username,
        initIsFollowing: true,
      ),
    );
  }

  static void navigateToFollowersListPage(
    String userId,
    String name,
    String username,
  ) {
    appRouter.push(
      '/followers_list/$userId',
      extra: FollowsPageExtra(
        name: name,
        username: username,
        initIsFollowing: false,
      ),
    );
  }

  static void navigateToSpecialFollowsListPage(
    String userId,
    String name,
    String username,
  ) {
    appRouter.push(
      '/following_list/$userId',
      extra: FollowsPageExtra(
        name: name,
        username: username,
        initIsFollowing: true,
        initialIndex: 2,
      ),
    );
  }

  /// 跳转到帖子详情页
  static void navigateToPostDetailPage(String id, dynamic post) {
    appRouter.push(
      '/post/$id',
      extra: PostDetailExtra(initialPost: post is PostModel ? post : null),
    );
  }

  /// 跳转到图片详情页
  static void navigateToPhotoViewWrapper({
    required List<ImageItem> imageItems,
    required int initialIndex,
    required List<MenuItem> Function(BuildContext context, ImageItem item)
    menuItemsBuilder,
    Object? Function(ImageItem item)? heroTagBuilder,
    bool enableMenu = true,
  }) {
    appRouter.push(
      '/photo_view_wrapper',
      extra: PhotoViewExtra(
        imageItems: imageItems,
        initialIndex: initialIndex,
        menuItemsBuilder: menuItemsBuilder,
        enableMenu: enableMenu,
        heroTagBuilder: heroTagBuilder,
      ),
    );
  }

  /// 跳转到标签黑名单页
  static void navigateToTagBlacklistPage() {
    appRouter.push('/tag_blacklist');
  }

  /// 跳转到个人资料页
  static void navigateToPersonalProfilePage() {
    appRouter.push('/personal_profile');
  }

  /// 跳转到论坛帖子列表页
  static void navigateToForumThreadListPage(
    String categoryId, {
    String? categoryName,
  }) {
    appRouter.push(
      '/forum_threads/$categoryId',
      extra: ForumThreadListExtra(categoryName: categoryName),
    );
  }

  /// 跳转到论坛帖子详情页
  static void navigateToForumThreadDetailPage(
    String categoryId,
    String threadId, {
    ForumThreadModel? initialThread,
  }) {
    appRouter.push(
      '/forum_threads/$categoryId/$threadId',
      extra: ForumThreadDetailExtra(initialThread: initialThread),
    );
  }

  static Future<void> navigateInSiteMode(
    IwaraSite site,
    Future<void> Function() navigate,
  ) async {
    final appService = Get.find<AppService>();
    if (appService.currentSiteMode == site) {
      await navigate();
      return;
    }

    await appService.applyGlobalSiteMode(
      site,
      resetNavigation: false,
      onApplied: navigate,
    );
  }

  /// 跳转到通知列表页
  static void navigateToNotificationListPage() {
    appRouter.push('/notification_list');
  }

  /// 跳转到会话列表页
  static void navigateToConversationPage() {
    appRouter.push('/conversation');
  }

  // 跳转到下载任务列表页
  static void navigateToDownloadTaskListPage() {
    appRouter.push('/download_task_list');
  }

  // 跳转到图库下载任务详情页
  static void navigateToGalleryDownloadTaskDetailPage(String taskId) {
    appRouter.push('/gallery_download_task_detail/$taskId');
  }

  /// 跳转到消息详情页
  static void navigateToMessagePage(ConversationModel conversation) {
    appRouter.push('/message_detail/${conversation.id}', extra: conversation);
  }

  /// 跳转到本地收藏页
  static void navigateToLocalFavoritePage() {
    appRouter.push('/local_favorite');
  }

  /// 跳转到本地收藏夹详情页
  static void navigateToLocalFavoriteDetailPage(
    String folderId,
    String? folderTitle,
  ) {
    appRouter.push(
      '/local_favorite_detail/$folderId',
      extra: LocalFavoriteDetailExtra(folderTitle: folderTitle),
    );
  }

  /// 跳转到标签视频列表页
  static void navigateToTagVideoListPage(Tag tag) {
    appRouter.push('/tag_videos/${tag.id}', extra: tag);
  }

  /// 跳转到标签图库列表页
  static void navigateToTagGalleryListPage(Tag tag) {
    appRouter.push('/tag_galleries/${tag.id}', extra: tag);
  }

  /// 跳转到表情包库页面
  static void navigateToEmojiLibraryPage() {
    appRouter.push('/emoji_library');
  }

  // 跳转到设置页
  static void navigateToSettingsPage() {
    appRouter.push('/settings_page');
  }

  // 跳转到翻译设置页
  static void navigateToTranslationSettingsPage() {
    appRouter.push(
      '/settings_page',
      extra: SettingsPageExtra(
        initialPage: ProxyUtil.isSupportedPlatform() ? 1 : 0,
      ),
    );
  }

  // 跳转到布局设置页
  static void navigateToLayoutSettingsPage() {
    appRouter.push('/layout_settings_page');
  }

  // 跳转到导航排序设置页
  static void navigateToNavigationOrderSettingsPage() {
    appRouter.push('/navigation_order_settings_page');
  }

  /// 跳转到本地视频播放页面（从下载任务进入）
  static void navigateToLocalVideoPlayerPage({
    required String localPath,
    DownloadTask? task,
    List<DownloadTask>? allQualityTasks,
  }) {
    final uuid = Uuid();
    final randomVideoId = 'local_${uuid.v4()}';

    appRouter.push(
      '/video_detail/$randomVideoId',
      extra: VideoDetailExtra(
        localPath: localPath,
        localTask: task,
        localAllQualityTasks: allQualityTasks,
      ),
    );
    _ensureAndroidBackDispatcherPriority('push video_detail/$randomVideoId');
  }

  /// 跳转到本地视频播放页面（从外部文件路径进入）
  static void navigateToLocalVideoPlayerPageFromPath(String filePath) {
    final uuid = Uuid();
    final randomVideoId = 'local_${uuid.v4()}';

    appRouter.push(
      '/video_detail/$randomVideoId',
      extra: VideoDetailExtra(localPath: filePath),
    );
    _ensureAndroidBackDispatcherPriority('push video_detail/$randomVideoId');
  }
}
