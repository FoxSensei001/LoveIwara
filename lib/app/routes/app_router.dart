import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_fullscreen_handoff.model.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/utils/iwara_deep_link_utils.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/utils/logger_utils.dart';

// 页面相关的 import
import 'package:i_iwara/app/ui/pages/home/home_shell_scaffold.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_video_list_page.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_gallery_list_page.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/subscriptions_page.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_page.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/news/news_detail_page.dart';
import 'package:i_iwara/app/ui/pages/news/news_page.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/first_time_setup_page.dart';
import 'package:i_iwara/app/ui/pages/login/login_page_wrapper.dart';
import 'package:i_iwara/app/ui/pages/sign_in/sing_in_page.dart';
import 'package:i_iwara/app/ui/pages/video_detail/video_detail_page_v2.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/gallery_detail_page.dart';
import 'package:i_iwara/app/ui/pages/author_profile/author_profile_page.dart';
import 'package:i_iwara/app/ui/pages/search/search_result.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list_detail.dart';
import 'package:i_iwara/app/ui/pages/play_list/play_list.dart';
import 'package:i_iwara/app/ui/pages/favorites/my_favorites.dart';
import 'package:i_iwara/app/ui/pages/friends/friends_page.dart';
import 'package:i_iwara/app/ui/pages/history/history_list_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/download/download_task_list_page.dart';
import 'package:i_iwara/app/ui/pages/download/gallery_download_task_detail_page.dart';
import 'package:i_iwara/app/ui/pages/notifications/notification_list_page.dart';
import 'package:i_iwara/app/ui/pages/conversation/conversation_page.dart';
import 'package:i_iwara/app/ui/pages/conversation/widgets/message_list_widget.dart';
import 'package:i_iwara/app/ui/pages/post_detail/post_detail_page.dart';
import 'package:i_iwara/app/ui/pages/forum/thread_list_page.dart';
import 'package:i_iwara/app/ui/pages/forum/thread_detail_page.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_video_list_page.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_gallery_list_page.dart';
import 'package:i_iwara/app/ui/pages/follows/follows_page.dart';
import 'package:i_iwara/app/ui/pages/favorite/favorite_list_page.dart';
import 'package:i_iwara/app/ui/pages/favorite/favorite_folder_detail_page.dart';
import 'package:i_iwara/app/ui/pages/tag_blacklist/tag_blacklist_page.dart';
import 'package:i_iwara/app/ui/pages/favorite_tags/favorite_tags_page.dart'
    show FavoriteIwaraTagsPage, FavoriteOreno3dTagsPage;
import 'package:i_iwara/app/ui/pages/profile/personal_profile_page.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_library_page.dart';
import 'package:i_iwara/app/ui/pages/settings/layout_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/navigation_order_settings_page.dart';
import 'package:i_iwara/common/gallery_image_quality.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';

/// 全局 RouteObserver，供实现 RouteAware 的页面使用（例如视频详情页等）。
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final NavigatorObserver navigationRootObserver = _NavigationLogObserver('root');
final NavigatorObserver navigationShellObserver = _NavigationLogObserver(
  'shell',
);

/// 全局根 Navigator 的 key，用于访问根导航的 context。
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Home Shell（包含 NavigationRail + BottomNav Scaffold）的 Navigator key。
/// 详情页会推入到这个 Navigator 中，从而保持 Shell 结构一直可见。
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// 按分支索引获取对应的首页栏目页 Widget（实现了 [HomeWidgetInterface]）。
/// 分支顺序与下方 [StatefulShellRoute] 的 branches 一一对应：
/// 0=视频 1=图集 2=订阅 3=论坛 4=新闻。
Widget? _homeBranchWidget(int branchIndex) {
  switch (branchIndex) {
    case 0:
      return PopularVideoListPage.globalKey.currentWidget;
    case 1:
      return PopularGalleryListPage.globalKey.currentWidget;
    case 2:
      return SubscriptionsPage.globalKey.currentWidget;
    case 3:
      return ForumPage.globalKey.currentWidget;
    case 4:
      return NewsPage.globalKey.currentWidget;
    default:
      return null;
  }
}

/// 当用户在底部/侧边导航栏再次点击“当前所在栏目”时调用：
/// 触发该栏目页回到顶部并重新加载当前子 tab（已访问过的其他子 tab 也会在下次切换时刷新）。
void refreshHomeBranch(int branchIndex) {
  final widget = _homeBranchWidget(branchIndex);
  if (widget is HomeWidgetInterface) {
    (widget as HomeWidgetInterface).refreshCurrent();
  }
}

/// 构建一个「跟手侧滑返回」的页面。
///
/// 仅在 iOS 上启用整页跟手侧滑：从页面**任意位置**向右滑动即可返回，页面跟手位移、
/// 底层页视差跟随（视觉转场与系统默认的 Cupertino 转场一致，仅把手势区从最左边缘
/// 扩展到全屏）。其它平台（Android / 桌面）维持框架默认的 [MaterialPage] 转场，
/// 行为完全不变。
///
/// - [fullSwipe] 为 `false` 时退回「仅边缘可滑」（等价系统默认的窄边缘手势），
///   供含横向手势控件（TabBarView / 图集翻页 / 播放器横滑）的页面使用，避免抢手势。
///
/// 手势底层通过 [SwipeablePageRoute]（继承 [CupertinoPageRoute]）直接调用
/// `navigator.pop()`，并会自动尊重页面上的 [PopScope]：当 `canPop: false` 时手势
/// 失效，因此不会与现有的 PopScope / PopCoordinator 返回逻辑冲突。弹窗覆盖当前页时
/// 手势同样自动失效。
Page<void> buildAdaptiveSwipeablePage(
  GoRouterState state,
  Widget child, {
  bool fullSwipe = true,
}) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return SwipeablePage<void>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      arguments: state.extra,
      canOnlySwipeFromEdge: !fullSwipe,
      builder: (context) => child,
    );
  }
  return MaterialPage<void>(
    key: state.pageKey,
    name: state.name ?? state.fullPath,
    arguments: state.extra,
    child: child,
  );
}

/// 全局唯一的 GoRouter 实例。
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  observers: [OverlayTracker.root, navigationRootObserver],
  onException: (context, state, router) {
    final normalizedLocation = IwaraDeepLinkUtils.normalizeToAppLocation(
      state.uri,
    );
    if (normalizedLocation != null) {
      LogUtils.i(
        '将外部 deeplink 归一化为应用内路由: ${state.uri} -> $normalizedLocation',
        'AppRouter',
      );
      router.go(normalizedLocation);
      return;
    }

    LogUtils.e(
      'GoRouter 未匹配到路由: ${state.uri}',
      tag: 'AppRouter',
      error: state.error,
    );
    router.go('/');
  },
  redirect: _guardRedirect,
  routes: [
    // 首次启动设置页 —— 顶层路由，不在 Shell 中
    GoRoute(
      path: '/first_time_setup',
      name: 'first_time_setup',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const FirstTimeSetupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),

    // 登录 / 注册页 —— 顶层路由，不在 Shell 中
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/sign_in',
      name: 'sign_in',
      builder: (context, state) => const SignInPage(),
    ),

    // ====================================================================
    // 外层 ShellRoute：提供带 NavigationRail + BottomNav 的整体框架。
    // 详情页会推入到该 Shell 的 Navigator 中，从而让框架（包含 NavigationRail）
    // 始终保持可见。
    // ====================================================================
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      observers: [OverlayTracker.shell, routeObserver, navigationShellObserver],
      builder: (context, state, child) {
        return HomeShellScaffold(currentPath: state.uri.path, child: child);
      },
      routes: [
        // 内层 StatefulShellRoute：4 个 Tab，支持状态保留的切换
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            // 存储 shell 引用，供 HomeShellScaffold 使用 goBranch()
            // 从 NavigationRail/BottomNav 进行 Tab 切换。
            Get.find<AppService>().navigationShell = navigationShell;
            return navigationShell;
          },
          branches: [
            // 分支 0：视频（热门视频）
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'popular_videos',
                  builder: (context, state) => Obx(() {
                    final homeContentVersion =
                        Get.find<AppService>().homeContentVersion;
                    return PopularVideoListPage(
                      key: PopularVideoListPage.globalKey,
                      contentResetVersion: homeContentVersion,
                    );
                  }),
                ),
              ],
            ),
            // 分支 1：图集
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/gallery',
                  name: 'gallery',
                  builder: (context, state) => Obx(() {
                    final homeContentVersion =
                        Get.find<AppService>().homeContentVersion;
                    return PopularGalleryListPage(
                      key: PopularGalleryListPage.globalKey,
                      contentResetVersion: homeContentVersion,
                    );
                  }),
                ),
              ],
            ),
            // 分支 2：订阅
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/subscriptions',
                  name: 'subscriptions',
                  builder: (context, state) => Obx(() {
                    final homeContentVersion =
                        Get.find<AppService>().homeContentVersion;
                    final currentSite = Get.find<AppService>().currentSiteMode;
                    return SubscriptionsPage(
                      key: SubscriptionsPage.globalKey,
                      site: currentSite,
                      contentResetVersion: homeContentVersion,
                    );
                  }),
                ),
              ],
            ),
            // 分支 3：论坛
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/forum',
                  name: 'forum_home',
                  builder: (context, state) => Obx(() {
                    final homeContentVersion =
                        Get.find<AppService>().homeContentVersion;
                    return ForumPage(
                      key: ForumPage.globalKey,
                      contentResetVersion: homeContentVersion,
                    );
                  }),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/news',
                  name: 'news_home',
                  builder: (context, state) => Obx(() {
                    final homeContentVersion =
                        Get.find<AppService>().homeContentVersion;
                    return NewsPage(
                      key: NewsPage.globalKey,
                      contentResetVersion: homeContentVersion,
                      initialCategory:
                          IwaraDeepLinkUtils.resolveNewsCategoryType(
                            state.uri.queryParameters['category'],
                          ) ??
                          IwaraNewsCategoryType.newsUpdates,
                      initialLanguage: IwaraDeepLinkUtils.resolveNewsLanguage(
                        state.uri.queryParameters['lang'],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),

        // ========== 详情类页面（挂在 Shell 内部，导航栏保持可见） ==========

        // 图片浏览包装页 —— 挂在 Shell 内部，避免 root/shell 双栈竞争返回。
        GoRoute(
          path: '/photo_view_wrapper',
          name: 'photo_view_wrapper',
          pageBuilder: (context, state) {
            final extra = state.extra as PhotoViewExtra;
            return CustomTransitionPage(
              key: state.pageKey,
              opaque: false,
              barrierColor: Colors.transparent,
              child: _buildPhotoViewWrapperChild(extra),
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            );
          },
        ),

        // 视频详情
        GoRoute(
          path: '/news/:postId',
          name: 'news_detail',
          pageBuilder: (context, state) {
            final postId = int.tryParse(state.pathParameters['postId'] ?? '');
            final postUrl = state.uri.queryParameters['url'];
            final extra = state.extra;
            final newsExtra = extra is NewsDetailExtra ? extra : null;
            final resolvedPostUrl = postUrl == null || postUrl.isEmpty
                ? newsExtra?.postUrl
                : postUrl;
            if (postId == null &&
                (resolvedPostUrl == null || resolvedPostUrl.isEmpty) &&
                newsExtra == null) {
              return buildAdaptiveSwipeablePage(
                state,
                const Scaffold(
                  body: Center(child: Text('Invalid news route')),
                ),
              );
            }
            return buildAdaptiveSwipeablePage(
              state,
              NewsDetailPage(
                postId: postId,
                postUrl: resolvedPostUrl,
                previewData: newsExtra,
              ),
            );
          },
        ),

        GoRoute(
          path: '/video_detail/:videoId',
          name: 'video_detail',
          builder: (context, state) {
            final videoId = state.pathParameters['videoId']!;
            final extra = state.extra;
            if (extra is VideoDetailExtra) {
              return MyVideoDetailPage(
                videoId: videoId,
                extData: extra.extData,
                localPath: extra.localPath,
                localTask: extra.localTask,
                localAllQualityTasks: extra.localAllQualityTasks,
                innerPlaylistContext: extra.innerPlaylistContext,
                forceAutoPlay: extra.forceAutoPlay,
                forceEnterFullscreen: extra.forceEnterFullscreen,
                initialVideoInfo: extra.initialVideoInfo,
                fullscreenHandoff: extra.fullscreenHandoff,
              );
            }
            final extData = extra is Map<String, dynamic> ? extra : null;
            return MyVideoDetailPage(videoId: videoId, extData: extData);
          },
        ),

        // 图集详情
        GoRoute(
          path: '/gallery_detail/:galleryId',
          name: 'gallery_detail',
          builder: (context, state) {
            final galleryId = state.pathParameters['galleryId']!;
            final extra = state.extra;
            final galleryExtra = extra is GalleryDetailExtra ? extra : null;
            return GalleryDetailPage(
              imageModelId: galleryId,
              initialCoverUrl: galleryExtra?.coverUrl,
              initialTitle: galleryExtra?.title,
              initialImageCount: galleryExtra?.imageCount,
              initialAuthorId: galleryExtra?.authorId,
              initialAuthorName: galleryExtra?.authorName,
              initialAuthorUsername: galleryExtra?.authorUsername,
              initialAuthorAvatarUrl: galleryExtra?.authorAvatarUrl,
              initialAuthorRole: galleryExtra?.authorRole,
              initialAuthorPremium: galleryExtra?.authorPremium,
              extData: galleryExtra?.extData,
            );
          },
        ),

        // 作者主页
        GoRoute(
          path: '/author_profile/:userName',
          name: 'author_profile',
          builder: (context, state) {
            final username = state.pathParameters['userName']!;
            final extra = state.extra;
            final authorProfileExtra = extra is AuthorProfileExtra
                ? extra
                : null;
            return AuthorProfilePage(
              username: username,
              initialUser: authorProfileExtra?.initialUser,
              initialTabIndex:
                  IwaraDeepLinkUtils.resolveAuthorProfileInitialTabIndex(
                    state.uri.queryParameters['tab'],
                  ),
            );
          },
        ),

        // 搜索结果页
        GoRoute(
          path: '/search_result',
          name: 'search_result',
          pageBuilder: (context, state) {
            final extra = state.extra as SearchResultExtra?;
            return buildAdaptiveSwipeablePage(
              state,
              SearchResult(
                initialSearch: extra?.searchInfo ?? '',
                initialSegment: extra?.segment ?? SearchSegment.video,
                initialSearchType: extra?.searchType,
                extData: extra?.extData,
                initialFilters: extra?.filters,
                initialSort: extra?.sort,
              ),
            );
          },
        ),

        // 播放列表详情
        GoRoute(
          path: '/playlist_detail/:id',
          name: 'playlist_detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra as PlayListDetailExtra?;
            return PlayListDetailPage(
              playlistId: id,
              isMine: extra?.isMine ?? false,
            );
          },
        ),

        // 播放列表列表页
        GoRoute(
          path: '/play_list',
          name: 'play_list',
          builder: (context, state) {
            final extra = state.extra as PlayListExtra?;
            return PlayListPage(
              userId: extra?.userId ?? '',
              isMine: extra?.isMine ?? false,
            );
          },
        ),

        // 我的收藏
        GoRoute(
          path: '/favorite',
          name: 'favorite',
          builder: (context, state) => const MyFavorites(),
        ),

        // 好友列表
        GoRoute(
          path: '/friends',
          name: 'friends',
          builder: (context, state) => const FriendsPage(),
        ),

        // 历史记录列表
        GoRoute(
          path: '/history_list',
          name: 'history_list',
          builder: (context, state) => const HistoryListPage(),
        ),

        // 设置页面
        GoRoute(
          path: '/settings_page',
          name: 'settings_page',
          builder: (context, state) {
            final extra = state.extra as SettingsPageExtra?;
            return SettingsPage(initialPage: extra?.initialPage ?? -1);
          },
        ),

        // 下载任务列表
        GoRoute(
          path: '/download_task_list',
          name: 'download_task_list',
          builder: (context, state) => const DownloadTaskListPage(),
        ),

        // 图集下载任务详情
        GoRoute(
          path: '/gallery_download_task_detail/:taskId',
          name: 'gallery_download_task_detail',
          builder: (context, state) {
            final taskId = state.pathParameters['taskId']!;
            return GalleryDownloadTaskDetailPage(taskId: taskId);
          },
        ),

        // 通知列表
        GoRoute(
          path: '/notification_list',
          name: 'notification_list',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const NotificationListPage()),
        ),

        // 会话列表
        GoRoute(
          path: '/conversation',
          name: 'conversation',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const ConversationPage()),
        ),

        // 会话详情（消息列表）
        GoRoute(
          path: '/message_detail/:conversationId',
          name: 'message_detail',
          pageBuilder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final conversation = _resolveConversationForMessageDetail(
              state,
              conversationId,
            );
            return buildAdaptiveSwipeablePage(
              state,
              MessageListWidget(
                conversation: conversation,
                fromNarrowScreen: true,
              ),
            );
          },
        ),

        // 帖子详情
        GoRoute(
          path: '/post/:id',
          name: 'post_detail',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            final extra = state.extra;
            final postExtra = extra is PostDetailExtra ? extra : null;
            final initialPost =
                postExtra?.initialPost ?? (extra is PostModel ? extra : null);
            return buildAdaptiveSwipeablePage(
              state,
              PostDetailPage(postId: id, initialPost: initialPost),
            );
          },
        ),

        // 论坛帖子列表
        GoRoute(
          path: '/forum_threads/:categoryId',
          name: 'forum_thread_list',
          pageBuilder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            final extra = state.extra as ForumThreadListExtra?;
            return buildAdaptiveSwipeablePage(
              state,
              ThreadListPage(
                categoryId: categoryId,
                categoryName: extra?.categoryName ?? '',
              ),
            );
          },
        ),

        // 论坛帖子详情
        GoRoute(
          path: '/forum_threads/:categoryId/:threadId',
          name: 'forum_thread_detail',
          pageBuilder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            final threadId = state.pathParameters['threadId']!;
            final extra = state.extra;
            final threadExtra = extra is ForumThreadDetailExtra ? extra : null;
            final initialThread =
                threadExtra?.initialThread ??
                (extra is ForumThreadModel ? extra : null);
            return buildAdaptiveSwipeablePage(
              state,
              ThreadDetailPage(
                categoryId: categoryId,
                threadId: threadId,
                initialThread: initialThread,
              ),
            );
          },
        ),

        // 标签视频列表
        GoRoute(
          path: '/tag_videos/:tagId',
          name: 'tag_videos',
          pageBuilder: (context, state) {
            final tag = _resolveTag(state);
            return buildAdaptiveSwipeablePage(state, TagVideoListPage(tag: tag));
          },
        ),

        // 标签图集列表
        GoRoute(
          path: '/tag_galleries/:tagId',
          name: 'tag_galleries',
          pageBuilder: (context, state) {
            final tag = _resolveTag(state);
            return buildAdaptiveSwipeablePage(
              state,
              TagGalleryListPage(tag: tag),
            );
          },
        ),

        // 关注列表
        GoRoute(
          path: '/following_list/:userId',
          name: 'following_list',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final extra = _resolveFollowsExtra(
              state,
              userId: userId,
              defaultIsFollowing: true,
              defaultInitialIndex: 0,
            );
            return FollowsPage(
              userId: userId,
              name: extra.name,
              username: extra.username,
              initIsFollowing: extra.initIsFollowing,
              initialIndex: extra.initialIndex,
            );
          },
        ),

        // 粉丝列表
        GoRoute(
          path: '/followers_list/:userId',
          name: 'followers_list',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final extra = _resolveFollowsExtra(
              state,
              userId: userId,
              defaultIsFollowing: false,
              defaultInitialIndex: 1,
            );
            return FollowsPage(
              userId: userId,
              name: extra.name,
              username: extra.username,
              initIsFollowing: extra.initIsFollowing,
              initialIndex: extra.initialIndex,
            );
          },
        ),

        // 本地收藏夹列表
        GoRoute(
          path: '/local_favorite',
          name: 'local_favorite',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const FavoriteListPage()),
        ),

        // 本地收藏夹详情
        GoRoute(
          path: '/local_favorite_detail/:folderId',
          name: 'local_favorite_detail',
          pageBuilder: (context, state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as LocalFavoriteDetailExtra?;
            return buildAdaptiveSwipeablePage(
              state,
              FavoriteFolderDetailPage(
                folderId: folderId,
                folderTitle: extra?.folderTitle,
              ),
            );
          },
        ),

        // 标签黑名单
        GoRoute(
          path: '/tag_blacklist',
          name: 'tag_blacklist',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const TagBlacklistPage()),
        ),

        // 收藏的 Iwara 标签管理
        GoRoute(
          path: '/favorite_iwara_tags',
          name: 'favorite_iwara_tags',
          builder: (context, state) => const FavoriteIwaraTagsPage(),
        ),

        // 收藏的 Oreno3d 标签管理（原作/角色/标签）
        GoRoute(
          path: '/favorite_oreno3d_tags',
          name: 'favorite_oreno3d_tags',
          builder: (context, state) => const FavoriteOreno3dTagsPage(),
        ),

        // 个人资料页
        GoRoute(
          path: '/personal_profile',
          name: 'personal_profile',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const PersonalProfilePage()),
        ),

        // 表情库
        GoRoute(
          path: '/emoji_library',
          name: 'emoji_library',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const EmojiLibraryPage()),
        ),

        // 布局设置
        GoRoute(
          path: '/layout_settings_page',
          name: 'layout_settings',
          pageBuilder: (context, state) =>
              buildAdaptiveSwipeablePage(state, const LayoutSettingsPage()),
        ),

        // 导航顺序设置
        GoRoute(
          path: '/navigation_order_settings_page',
          name: 'navigation_order_settings',
          pageBuilder: (context, state) => buildAdaptiveSwipeablePage(
            state,
            const NavigationOrderSettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

class _NavigationLogObserver extends NavigatorObserver {
  _NavigationLogObserver(this.scope);

  final String scope;

  String _describeRoute(Route<dynamic>? route) {
    if (route == null) return 'null';
    final name = route.settings.name;
    return '${route.runtimeType}(name=$name, hash=${route.hashCode})';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LogUtils.d(
      '路由 didPush: scope=$scope, route=${_describeRoute(route)}, '
          'previous=${_describeRoute(previousRoute)}',
      'NavObserver',
    );
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LogUtils.d(
      '路由 didPop: scope=$scope, route=${_describeRoute(route)}, '
          'previous=${_describeRoute(previousRoute)}',
      'NavObserver',
    );
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LogUtils.d(
      '路由 didRemove: scope=$scope, route=${_describeRoute(route)}, '
          'previous=${_describeRoute(previousRoute)}',
      'NavObserver',
    );
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    LogUtils.d(
      '路由 didReplace: scope=$scope, new=${_describeRoute(newRoute)}, '
          'old=${_describeRoute(oldRoute)}',
      'NavObserver',
    );
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

/// 路由重定向守卫：检查首次设置是否已完成。
String? _guardRedirect(BuildContext context, GoRouterState state) {
  try {
    final configService = Get.find<ConfigService>();
    final appService = Get.find<AppService>();
    final bool isFirstTimeSetupCompleted =
        configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED];
    final preferredHomePath = appService.preferredHomePath;

    final isOnSetupPage = state.matchedLocation == '/first_time_setup';

    if (!isFirstTimeSetupCompleted && !isOnSetupPage) {
      LogUtils.i('首次设置未完成，重定向到首次设置页面', 'AppRouter');
      return '/first_time_setup';
    }

    if (isFirstTimeSetupCompleted && isOnSetupPage) {
      LogUtils.i('首次设置已完成，重定向到首页', 'AppRouter');
      return preferredHomePath;
    }

    if (isFirstTimeSetupCompleted &&
        state.matchedLocation == '/' &&
        preferredHomePath != '/') {
      // Redirect only once per app session, otherwise the Video tab (path '/'
      // in branch 0) would become unreachable when preferredHomePath != '/'.
      if (!appService.hasAppliedPreferredHomeRedirect) {
        appService.hasAppliedPreferredHomeRedirect = true;
        LogUtils.i('根据导航顺序重定向首页: / -> $preferredHomePath', 'AppRouter');
        return preferredHomePath;
      }
    }

    // Once we are away from '/', disable future preferred-home redirects.
    if (state.matchedLocation != '/' &&
        !appService.hasAppliedPreferredHomeRedirect) {
      appService.hasAppliedPreferredHomeRedirect = true;
    }
  } catch (e) {
    LogUtils.e('路由守卫检查首次设置状态出错', tag: 'AppRouter', error: e);
  }
  return null;
}

Tag _resolveTag(GoRouterState state) {
  final extra = state.extra;
  if (extra is Tag) return extra;

  final tagId = state.pathParameters['tagId'];
  if (tagId == null || tagId.isEmpty) {
    LogUtils.w('标签路由缺少 tagId，回退为空 Tag', 'AppRouter');
    return Tag(id: '', type: '');
  }

  LogUtils.w('标签路由缺少 Tag extra，使用 tagId=$tagId 回退构造 Tag', 'AppRouter');
  return Tag(id: tagId, type: '');
}

FollowsPageExtra _resolveFollowsExtra(
  GoRouterState state, {
  required String userId,
  required bool defaultIsFollowing,
  required int defaultInitialIndex,
}) {
  final extra = state.extra;
  if (extra is FollowsPageExtra) return extra;

  LogUtils.w('关注/粉丝路由缺少 FollowsPageExtra，使用 userId=$userId 回退构造', 'AppRouter');

  return FollowsPageExtra(
    name: userId,
    username: userId,
    initIsFollowing: defaultIsFollowing,
    initialIndex: defaultInitialIndex,
  );
}

ConversationModel _resolveConversationForMessageDetail(
  GoRouterState state,
  String conversationId,
) {
  final extra = state.extra;
  if (extra is ConversationModel) return extra;

  final now = DateTime.now();
  final fallbackUser = User(
    id: 'unknown',
    name: 'Unknown',
    username: 'unknown',
  );
  LogUtils.w(
    'message_detail 路由缺少 ConversationModel extra，使用 conversationId=$conversationId 回退构造会话',
    'AppRouter',
  );

  return ConversationModel(
    id: conversationId,
    createdAt: now,
    updatedAt: now,
    participants: [fallbackUser],
    lastMessage: MessageModel(
      id: 'fallback-$conversationId',
      conversation: conversationId,
      createdAt: now,
      updatedAt: now,
      user: fallbackUser,
    ),
  );
}

Widget _buildPhotoViewWrapperChild(PhotoViewExtra extra) {
  final normalizedInitialQuality = normalizeGalleryImageQuality(
    extra.initialQuality,
  );

  try {
    return Function.apply(MyGalleryPhotoViewWrapper.new, const [], {
          #galleryItems: extra.imageItems,
          #initialIndex: extra.initialIndex,
          #menuItemsBuilder: extra.menuItemsBuilder,
          #enableMenu: extra.enableMenu,
          #heroTagBuilder: extra.heroTagBuilder,
          #standardImageItems: extra.standardImageItems,
          #originalImageItems: extra.originalImageItems,
          #initialQuality: normalizedInitialQuality,
          #onQualityChanged: extra.onQualityChanged,
        })
        as Widget;
  } on NoSuchMethodError {
    return MyGalleryPhotoViewWrapper(
      galleryItems: extra.imageItems,
      initialIndex: extra.initialIndex,
      menuItemsBuilder: extra.menuItemsBuilder,
      enableMenu: extra.enableMenu,
      heroTagBuilder: extra.heroTagBuilder,
    );
  } on ArgumentError {
    return MyGalleryPhotoViewWrapper(
      galleryItems: extra.imageItems,
      initialIndex: extra.initialIndex,
      menuItemsBuilder: extra.menuItemsBuilder,
      enableMenu: extra.enableMenu,
      heroTagBuilder: extra.heroTagBuilder,
    );
  }
}

// ========== 供复杂参数路由使用的额外数据类 ==========

class GalleryDetailExtra {
  final String? coverUrl;
  final String? title;
  final int? imageCount;
  final String? authorId;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? authorRole;
  final bool? authorPremium;
  final Map<String, dynamic>? extData;

  const GalleryDetailExtra({
    this.coverUrl,
    this.title,
    this.imageCount,
    this.authorId,
    this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.authorRole,
    this.authorPremium,
    this.extData,
  });
}

class AuthorProfileExtra {
  final User? initialUser;

  const AuthorProfileExtra({this.initialUser});
}

class VideoDetailExtra {
  final Map<String, dynamic>? extData;
  final String? localPath;
  final DownloadTask? localTask;
  final List<DownloadTask>? localAllQualityTasks;
  final InnerPlaylistContext? innerPlaylistContext;
  final bool forceAutoPlay;
  final bool forceEnterFullscreen;
  final Video? initialVideoInfo;
  final VideoFullscreenHandoff? fullscreenHandoff;

  const VideoDetailExtra({
    this.extData,
    this.localPath,
    this.localTask,
    this.localAllQualityTasks,
    this.innerPlaylistContext,
    this.forceAutoPlay = false,
    this.forceEnterFullscreen = false,
    this.initialVideoInfo,
    this.fullscreenHandoff,
  });
}

class PostDetailExtra {
  final PostModel? initialPost;

  const PostDetailExtra({this.initialPost});
}

class NewsDetailExtra {
  final int? postId;
  final String? postUrl;
  final String title;
  final String excerpt;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final IwaraNewsLanguage language;
  final String? featuredImageUrl;
  final String heroTag;

  const NewsDetailExtra({
    this.postId,
    this.postUrl,
    required this.title,
    required this.excerpt,
    required this.publishedAt,
    required this.updatedAt,
    required this.language,
    this.featuredImageUrl,
    required this.heroTag,
  });
}

class ForumThreadListExtra {
  final String? categoryName;

  const ForumThreadListExtra({this.categoryName});
}

class ForumThreadDetailExtra {
  final ForumThreadModel? initialThread;

  const ForumThreadDetailExtra({this.initialThread});
}

class SearchResultExtra {
  final String searchInfo;
  final SearchSegment segment;
  final String? searchType;
  final Map<String, dynamic>? extData;
  final List<Filter>? filters;
  final String? sort;

  const SearchResultExtra({
    required this.searchInfo,
    required this.segment,
    this.searchType,
    this.extData,
    this.filters,
    this.sort,
  });
}

class PlayListDetailExtra {
  final bool isMine;
  const PlayListDetailExtra({this.isMine = false});
}

class PlayListExtra {
  final String userId;
  final bool isMine;
  const PlayListExtra({required this.userId, this.isMine = false});
}

class SettingsPageExtra {
  final int initialPage;
  const SettingsPageExtra({this.initialPage = -1});
}

class FollowsPageExtra {
  final String name;
  final String username;
  final bool initIsFollowing;
  final int initialIndex;

  const FollowsPageExtra({
    required this.name,
    required this.username,
    this.initIsFollowing = true,
    this.initialIndex = 0,
  });
}

class LocalFavoriteDetailExtra {
  final String? folderTitle;
  const LocalFavoriteDetailExtra({this.folderTitle});
}

class PhotoViewExtra {
  final List<ImageItem> imageItems;
  final int initialIndex;
  final List<MenuItem> Function(BuildContext context, ImageItem item)
  menuItemsBuilder;
  final bool enableMenu;
  final Object? Function(ImageItem item)? heroTagBuilder;
  final List<ImageItem>? standardImageItems;
  final List<ImageItem>? originalImageItems;
  final String initialQuality;
  final ValueChanged<String>? onQualityChanged;

  const PhotoViewExtra({
    required this.imageItems,
    required this.initialIndex,
    required this.menuItemsBuilder,
    this.enableMenu = true,
    this.heroTagBuilder,
    this.standardImageItems,
    this.originalImageItems,
    this.initialQuality = galleryImageQualityStandard,
    this.onQualityChanged,
  });
}
