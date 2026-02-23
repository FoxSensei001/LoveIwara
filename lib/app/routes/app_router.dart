import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/models/message_and_conversation.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/utils/logger_utils.dart';

// 页面相关的 import
import 'package:i_iwara/app/ui/pages/home/home_shell_scaffold.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_video_list_page.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/popular_gallery_list_page.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/subscriptions_page.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_page.dart';
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
import 'package:i_iwara/app/ui/pages/profile/personal_profile_page.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/my_gallery_photo_view_wrapper.dart';
import 'package:i_iwara/app/ui/pages/emoji_library/emoji_library_page.dart';
import 'package:i_iwara/app/ui/pages/settings/layout_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/navigation_order_settings_page.dart';
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

/// 全局唯一的 GoRouter 实例。
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  observers: [OverlayTracker.instance, navigationRootObserver],
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

    // 图片浏览包装页 —— 顶层全屏路由，覆盖 Shell
    GoRoute(
      path: '/photo_view_wrapper',
      name: 'photo_view_wrapper',
      pageBuilder: (context, state) {
        final extra = state.extra as PhotoViewExtra;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MyGalleryPhotoViewWrapper(
            galleryItems: extra.imageItems,
            initialIndex: extra.initialIndex,
            menuItemsBuilder: extra.menuItemsBuilder,
            enableMenu: extra.enableMenu,
          ),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),

    // ====================================================================
    // 外层 ShellRoute：提供带 NavigationRail + BottomNav 的整体框架。
    // 详情页会推入到该 Shell 的 Navigator 中，从而让框架（包含 NavigationRail）
    // 始终保持可见。
    // ====================================================================
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      observers: [routeObserver, navigationShellObserver],
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
                  builder: (context, state) =>
                      PopularVideoListPage(key: PopularVideoListPage.globalKey),
                ),
              ],
            ),
            // 分支 1：图集
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/gallery',
                  name: 'gallery',
                  builder: (context, state) => PopularGalleryListPage(
                    key: PopularGalleryListPage.globalKey,
                  ),
                ),
              ],
            ),
            // 分支 2：订阅
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/subscriptions',
                  name: 'subscriptions',
                  builder: (context, state) =>
                      SubscriptionsPage(key: SubscriptionsPage.globalKey),
                ),
              ],
            ),
            // 分支 3：论坛
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/forum',
                  name: 'forum_home',
                  builder: (context, state) =>
                      ForumPage(key: ForumPage.globalKey),
                ),
              ],
            ),
          ],
        ),

        // ========== 详情类页面（挂在 Shell 内部，导航栏保持可见） ==========

        // 视频详情
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
            return GalleryDetailPage(imageModelId: galleryId);
          },
        ),

        // 作者主页
        GoRoute(
          path: '/author_profile/:userName',
          name: 'author_profile',
          builder: (context, state) {
            final username = state.pathParameters['userName']!;
            return AuthorProfilePage(username: username);
          },
        ),

        // 搜索结果页
        GoRoute(
          path: '/search_result',
          name: 'search_result',
          builder: (context, state) {
            final extra = state.extra as SearchResultExtra?;
            return SearchResult(
              initialSearch: extra?.searchInfo ?? '',
              initialSegment: extra?.segment ?? SearchSegment.video,
              initialSearchType: extra?.searchType,
              extData: extra?.extData,
              initialFilters: extra?.filters,
              initialSort: extra?.sort,
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
          builder: (context, state) => const NotificationListPage(),
        ),

        // 会话列表
        GoRoute(
          path: '/conversation',
          name: 'conversation',
          builder: (context, state) => const ConversationPage(),
        ),

        // 会话详情（消息列表）
        GoRoute(
          path: '/message_detail/:conversationId',
          name: 'message_detail',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final conversation = _resolveConversationForMessageDetail(
              state,
              conversationId,
            );
            return MessageListWidget(
              conversation: conversation,
              fromNarrowScreen: true,
            );
          },
        ),

        // 帖子详情
        GoRoute(
          path: '/post/:id',
          name: 'post_detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PostDetailPage(postId: id);
          },
        ),

        // 论坛帖子列表
        GoRoute(
          path: '/forum_threads/:categoryId',
          name: 'forum_thread_list',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            return ThreadListPage(categoryId: categoryId);
          },
        ),

        // 论坛帖子详情
        GoRoute(
          path: '/forum_threads/:categoryId/:threadId',
          name: 'forum_thread_detail',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId']!;
            final threadId = state.pathParameters['threadId']!;
            return ThreadDetailPage(categoryId: categoryId, threadId: threadId);
          },
        ),

        // 标签视频列表
        GoRoute(
          path: '/tag_videos/:tagId',
          name: 'tag_videos',
          builder: (context, state) {
            final tag = _resolveTag(state);
            return TagVideoListPage(tag: tag);
          },
        ),

        // 标签图集列表
        GoRoute(
          path: '/tag_galleries/:tagId',
          name: 'tag_galleries',
          builder: (context, state) {
            final tag = _resolveTag(state);
            return TagGalleryListPage(tag: tag);
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
          builder: (context, state) => const FavoriteListPage(),
        ),

        // 本地收藏夹详情
        GoRoute(
          path: '/local_favorite_detail/:folderId',
          name: 'local_favorite_detail',
          builder: (context, state) {
            final folderId = state.pathParameters['folderId']!;
            final extra = state.extra as LocalFavoriteDetailExtra?;
            return FavoriteFolderDetailPage(
              folderId: folderId,
              folderTitle: extra?.folderTitle,
            );
          },
        ),

        // 标签黑名单
        GoRoute(
          path: '/tag_blacklist',
          name: 'tag_blacklist',
          builder: (context, state) => const TagBlacklistPage(),
        ),

        // 个人资料页
        GoRoute(
          path: '/personal_profile',
          name: 'personal_profile',
          builder: (context, state) => const PersonalProfilePage(),
        ),

        // 表情库
        GoRoute(
          path: '/emoji_library',
          name: 'emoji_library',
          builder: (context, state) => const EmojiLibraryPage(),
        ),

        // 布局设置
        GoRoute(
          path: '/layout_settings_page',
          name: 'layout_settings',
          builder: (context, state) => const LayoutSettingsPage(),
        ),

        // 导航顺序设置
        GoRoute(
          path: '/navigation_order_settings_page',
          name: 'navigation_order_settings',
          builder: (context, state) => const NavigationOrderSettingsPage(),
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
    final bool isFirstTimeSetupCompleted =
        configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED];

    final isOnSetupPage = state.matchedLocation == '/first_time_setup';

    if (!isFirstTimeSetupCompleted && !isOnSetupPage) {
      LogUtils.i('首次设置未完成，重定向到首次设置页面', 'AppRouter');
      return '/first_time_setup';
    }

    if (isFirstTimeSetupCompleted && isOnSetupPage) {
      LogUtils.i('首次设置已完成，重定向到首页', 'AppRouter');
      return '/';
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

  LogUtils.w(
    '标签路由缺少 Tag extra，使用 tagId=$tagId 回退构造 Tag',
    'AppRouter',
  );
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

  LogUtils.w(
    '关注/粉丝路由缺少 FollowsPageExtra，使用 userId=$userId 回退构造',
    'AppRouter',
  );

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

// ========== 供复杂参数路由使用的额外数据类 ==========

class VideoDetailExtra {
  final Map<String, dynamic>? extData;
  final String? localPath;
  final DownloadTask? localTask;
  final List<DownloadTask>? localAllQualityTasks;

  const VideoDetailExtra({
    this.extData,
    this.localPath,
    this.localTask,
    this.localAllQualityTasks,
  });
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
  final List<MenuItem> Function(dynamic context, dynamic item) menuItemsBuilder;
  final bool enableMenu;

  const PhotoViewExtra({
    required this.imageItems,
    required this.initialIndex,
    required this.menuItemsBuilder,
    this.enableMenu = true,
  });
}
