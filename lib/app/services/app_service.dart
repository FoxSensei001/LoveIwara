import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
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
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../routes/app_router.dart';
import '../routes/home_shell_navigation.dart';
import '../ui/pages/settings/settings_section.dart';
import 'config_service.dart';
import '../ui/widgets/restart_app_widget.dart';
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
    // 论坛 + 新闻合并成一个栏目：底栏最多容得下 5 个元素（4 tab + 搜索圆钮），
    // 两者在页内用 header 上的目的地下拉切换，见 community_page.dart。
    // 图标固定不随半边变化——tab 的图标要稳定，用户才找得到它。
    'community': NavigationItem(
      key: 'community',
      title: slang.t.settings.community,
      icon: Icons.forum,
      pageIndex: 3,
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

  Future<void> syncSiteModeFromConfig(ConfigService configService) async {
    final savedMode = configService[ConfigKey.APP_SITE_MODE] as String?;
    var site = IwaraSiteUtils.fromExtra(savedMode);
    // 启动时如果当前为 AI 站，则强制切回 TV（主）站
    if (site == IwaraSite.ai) {
      site = IwaraSite.main;
      await configService.setSetting(ConfigKey.APP_SITE_MODE, site.name);
    }
    _currentSiteMode.value = site;
  }

  /// 启动阶段直接以 [site] 起步（应用树尚未 build 时才可以这么用）。
  ///
  /// 用于"被一条 AI 站链接拉起来"的冷启动：[syncSiteModeFromConfig] 刚把站点强制
  /// 拉回主站，等 deeplink 真的去开页面时再切站，就要重启整棵树。这里趁树还没建
  /// 起来把站点定下来——不重启、不复位导航、不弹 toast，纯粹改一下内存里的值。
  Future<void> adoptStartupSiteMode(
    IwaraSite? site,
    ConfigService configService,
  ) async {
    if (site == null || _currentSiteMode.value == site) {
      return;
    }

    LogUtils.i(
      '启动链接属于 ${site.name} 站，直接以该站点起步',
      'AppService',
    );
    _currentSiteMode.value = site;
    await configService.setSetting(ConfigKey.APP_SITE_MODE, site.name);
  }

  /// 切换全局站点模式：换掉 MaterialApp 的 key 并重启整棵子树，所有页面按新站点
  /// 从头来过。
  ///
  /// 重启会把当前页面的 State 连同它正在进行的加载一起换掉，所以**依赖"切完站
  /// 原页面自己会重新请求"是不成立的**（详情页会永远停在 loading）。切站后还要
  /// 落到某个页面时，用 [onApplied] 在新树里重新导航过去，别指望旧页面还活着。
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
      // 重启会连 toast 宿主一起换掉，必须等新树起来再弹。
      messageService.queuePendingSiteModeToast(
        t.siteMode.switched(site: siteLabel),
        GlassToastType.success,
      );
    }

    _currentSiteMode.value = site;
    invalidateHomeContent();

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

    // siteModeVersion 只有 MaterialApp 的 key 在用，和 RestartApp 是同一次重建。
    _siteModeVersion.value++;
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
    PlaybackQueueRef? playbackQueueRef,
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
        extData != null ||
        playbackQueueRef != null;

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
              playbackQueueRef: playbackQueueRef,
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
    PlaybackQueueRef? playbackQueueRef,
    bool skipWatchedInQueue = false,
  }) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    try {
      // ⛔ 必须读 `appRouter.state`，**不能**读
      // `routeInformationProvider.value.uri`——后者的 RouteMatchList.uri 只反映
      // 非 ImperativeRouteMatch 的匹配，而视频详情页全是 push 进来的，于是这道
      // 守卫此前**从未生效过**（同一个视频连点两次会入栈两层）。
      // 同源说明见 settings_navigation.dart 与 glass_material_intro.dart。
      final currentPath = appRouter.state.uri.path;
      final targetPath = '/video_detail/$normalizedId';
      if (currentPath == targetPath) {
        return null;
      }
    } catch (_) {
      // ignore and continue push
    }

    // 首次进入视频详情前，先展示一次手势指引页（失败不阻断正常跳转）。
    await _maybeShowFirstTimeGestureGuide();

    final future = appRouter.push(
      '/video_detail/$normalizedId',
      extra:
          extData != null ||
              innerPlaylistContext != null ||
              playbackQueueRef != null ||
              forceAutoPlay ||
              forceEnterFullscreen ||
              initialVideoInfo != null
          ? VideoDetailExtra(
              extData: extData,
              innerPlaylistContext: innerPlaylistContext,
              playbackQueueRef: playbackQueueRef,
              skipWatchedInQueue: skipWatchedInQueue,
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

  /// 首次进入视频详情前展示一次手势指引页。
  ///
  /// 先置位「已展示」再推入指引页：既保证只出现一次，也避免指引展示期间
  /// 用户再次触发跳转导致指引页重复入栈。指引流程出现任何异常都不应阻断
  /// 正常的视频详情跳转。
  static Future<void> _maybeShowFirstTimeGestureGuide() async {
    try {
      if (!Get.isRegistered<ConfigService>()) return;
      final config = Get.find<ConfigService>();
      if (config[ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN] == true) return;
      await config.setSetting(
        ConfigKey.VIDEO_GESTURE_GUIDE_SHOWN,
        true,
        save: true,
      );
      await appRouter.push('/video_gesture_guide');
    } catch (e) {
      LogUtils.e('展示视频手势指引页失败', tag: 'AppService', error: e);
    }
  }

  /// 跳转到登录页
  static void navigateToSignInPage() {
    appRouter.push('/sign_in');
  }

  /// 跳转到搜索配置/历史页
  static void navigateToSearchPage({
    String userInputKeywords = '',
    SearchSegment initialSegment = SearchSegment.video,
    List<Filter>? initialFilters,
    String? initialSort,
    Function(String, SearchSegment, List<Filter>, String)? onSearch,
  }) {
    appRouter.push(
      '/search',
      extra: SearchPageExtra(
        userInputKeywords: userInputKeywords,
        initialSegment: initialSegment,
        initialFilters: initialFilters,
        initialSort: initialSort,
        onSearch: onSearch,
      ),
    );
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

  /// 稍后再看列表页。加入成功的 toast 上那枚动作钮也走这里。
  static void navigateToWatchLaterPage() {
    appRouter.push('/watch_later');
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

  /// 跳转到「收藏的 Iwara 标签」管理页
  static void navigateToFavoriteIwaraTagsPage() {
    appRouter.push('/favorite_iwara_tags');
  }

  /// 跳转到「收藏的 Oreno3d 标签」管理页
  static void navigateToFavoriteOreno3dTagsPage() {
    appRouter.push('/favorite_oreno3d_tags');
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

  /// 在 [site] 这个站点下打开一个资源（deeplink、正文里的站内链接等）。
  ///
  /// 站点一致时就是普通的 push。需要切站时，切站会把栈复位到首页再重建整棵树，
  /// [navigate] 在新树的第一帧之后执行——**别把另一个站点的历史页面留在返回路径
  /// 上**：应用冷启动恒为主站，一条 AI 站链接进来时，栈里剩下的全是主站的列表和
  /// 详情页，留着只会让用户在错的站点里继续点下去。同一条口径见
  /// [IwaraDifferentSiteRecovery]（服务端 301 判定跨站时的自动纠正）。
  static Future<void> navigateInSiteMode(
    IwaraSite site,
    Future<void> Function() navigate,
  ) async {
    final appService = Get.find<AppService>();
    if (appService.currentSiteMode == site) {
      await navigate();
      return;
    }

    await appService.applyGlobalSiteMode(site, onApplied: navigate);
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

  // ===== 设置树入口 =====
  //
  // 全部退化成「push 一个路径」。历史实现是往 `/settings_page` 塞一个
  // `SettingsPageExtra(initialPage: ProxyUtil.isSupportedPlatform() ? 12 : 11)`
  // 这样的平台相关魔数索引，索引表分散在三处且要反向 ±1 修正；现在平台差异
  // 由「路由注册不注册」表达，见 [SettingsSection.isAvailable]。
  //
  // 注意这些入口是 push 而不是 go：go_router 的 push 只压一页
  // （ImperativeRouteMatch 取 matchList.last），所以从抽屉直达
  // `/settings/block` 时栈里只有屏蔽设置这一页，返回直接离开设置——
  // 这正是历史上要靠 `_isDeepLinkEntry` 特判才能做到的行为。

  // 跳转到设置页
  static void navigateToSettingsPage() {
    appRouter.push(kSettingsRootPath);
  }

  // 跳转到翻译设置页
  static void navigateToTranslationSettingsPage() {
    appRouter.push(SettingsSection.translation.path);
  }

  // 跳转到内容屏蔽设置页
  static void navigateToBlockSettingsPage() {
    appRouter.push(SettingsSection.block.path);
  }

  // 跳转到诊断与反馈设置页（导出日志入口）
  static void navigateToDiagnosticsSettingsPage() {
    appRouter.push(SettingsSection.diagnostics.path);
  }

  // 跳转到布局设置页
  static void navigateToLayoutSettingsPage() {
    appRouter.push(SettingsSubRoutes.displayLayout);
  }

  // 跳转到导航排序设置页
  static void navigateToNavigationOrderSettingsPage() {
    appRouter.push(SettingsSubRoutes.displayNavigationOrder);
  }

  /// 跳转到本地视频播放页面（从下载任务进入）
  ///
  /// [playbackQueueRef] 是下载池的引用（从下载列表进来时带上）：本地播放页
  /// 的路由 id 只是个 `local_xxx` 占位，池的游标只能靠这个 ref 里的
  /// `currentItemId` 带过去——见 `PlaybackQueueNavigator`。
  static void navigateToLocalVideoPlayerPage({
    required String localPath,
    DownloadTask? task,
    List<DownloadTask>? allQualityTasks,
    PlaybackQueueRef? playbackQueueRef,
  }) {
    final routeVideoId = playbackQueueRef != null
        ? localVideoRouteId(playbackQueueRef.currentItemId)
        : 'local_${Uuid().v4()}';

    appRouter.push(
      '/video_detail/$routeVideoId',
      extra: VideoDetailExtra(
        localPath: localPath,
        localTask: task,
        localAllQualityTasks: allQualityTasks,
        playbackQueueRef: playbackQueueRef,
      ),
    );
    _ensureAndroidBackDispatcherPriority('push video_detail/$routeVideoId');
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
