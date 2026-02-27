import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/iwara_page.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/utils/url_utils.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/recent_thread_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_skeleton_page.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ForumPage extends StatefulWidget implements HomeWidgetInterface {
  static final globalKey = GlobalKey<_ForumPageState>();

  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();

  @override
  void refreshCurrent() {
    final state = globalKey.currentState;
    if (state != null) {
      state.tryRefreshCurrentList();
    }
  }
}

class _ForumPageState extends State<ForumPage> {
  final ForumService _forumService = Get.find<ForumService>();
  final ApiService _apiService = Get.find<ApiService>();
  List<ForumCategoryTreeModel>? _categories;
  bool _isLoading = true;
  String? _error;
  final UserService userService = Get.find<UserService>();
  int _selectedRailIndex = 0; // 修改变量名称：选中 rail 的索引（0 为 最近，其余从 _categories 中获取）
  late RecentThreadListRepository _recentThreadRepository;
  final appBarHeight = 56.0;

  // 置顶公告相关
  List<ForumThreadModel> _stickyAnnouncements = [];
  bool _isLoadingStickyAnnouncements = false;

  // 全站公告相关（apiq /page/sitewide-announcement）
  IwaraPageModel? _sitewideAnnouncement;
  bool _isLoadingSitewideAnnouncement = false;
  String? _sitewideAnnouncementError;

  void tryRefreshCurrentList() {
    if (mounted) {
      _loadCategories();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _recentThreadRepository = RecentThreadListRepository();
    _loadStickyAnnouncements();
    if (CommonConstants.enableForumSitewideAnnouncement) {
      _loadSitewideAnnouncement();
    }
  }

  @override
  void dispose() {
    _recentThreadRepository.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final result = await _forumService.getForumCategoryTree();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _categories = result.data;
          _error = null;
        } else {
          _error = result.message;
          _categories = null;
        }
      });
    }
  }

  Future<void> _refreshAll() async {
    // 刷新分类列表、最近帖子列表、置顶公告（并发执行）
    final tasks = <Future<void>>[
      _loadCategories(isRefresh: true),
      _recentThreadRepository.refresh(true),
      _loadStickyAnnouncements(isRefresh: true),
      if (CommonConstants.enableForumSitewideAnnouncement)
        _loadSitewideAnnouncement(isRefresh: true),
    ];
    await Future.wait(tasks);
  }

  Future<void> _loadStickyAnnouncements({bool isRefresh = false}) async {
    if (!mounted) return;

    if (!isRefresh) {
      setState(() {
        _isLoadingStickyAnnouncements = true;
      });
    }

    final result = await _forumService.fetchStickyAnnouncements(limit: 5);

    if (mounted) {
      setState(() {
        _isLoadingStickyAnnouncements = false;
        if (result.isSuccess && result.data != null) {
          _stickyAnnouncements = result.data!;
        }
      });
    }
  }

  Future<void> _loadSitewideAnnouncement({bool isRefresh = false}) async {
    if (!mounted) return;

    if (!isRefresh) {
      setState(() {
        _isLoadingSitewideAnnouncement = true;
        _sitewideAnnouncementError = null;
      });
    }

    final result = await _apiService.fetchSitewideAnnouncement();

    if (!mounted) return;
    setState(() {
      _isLoadingSitewideAnnouncement = false;
      if (result.isSuccess && result.data != null) {
        _sitewideAnnouncement = result.data;
        _sitewideAnnouncementError = null;
      } else {
        _sitewideAnnouncement = null;
        _sitewideAnnouncementError = result.message.isNotEmpty
            ? result.message
            : slang.t.errors.failedToFetchData;
      }
    });
  }

  void _showPostDialog() {
    UserService userService = Get.find<UserService>();
    if (!userService.isLogin) {
      AppService.switchGlobalDrawer();
      showToastWidget(
        MDToastWidget(
          message: slang.t.errors.pleaseLoginFirst,
          type: MDToastType.warning,
        ),
      );
      return;
    }
    showAppDialog(
      ForumPostDialog(
        onSubmit: () {
          // 刷新帖子列表
          _loadCategories(isRefresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 计算 AppBar 和状态栏的总高度
    final double effectivePaddingTop =
        MediaQuery.of(context).padding.top + appBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true, // 让内容延伸到AppBar下面，以便显示毛玻璃效果
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: appBarHeight,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: 0.7), // 设置半透明背景
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 毛玻璃效果参数
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          children: [
            IconButton(
              icon: Obx(() {
                if (userService.isLogining.value) {
                  return Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          highlightColor: Theme.of(context).colorScheme.surface,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (userService.isLogin) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AvatarWidget(
                        user: userService.currentUser.value,
                        size: 40,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Obx(() {
                          final count =
                              userService.notificationCount.value +
                              userService.messagesCount.value;
                          if (count > 0) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ),
                    ],
                  );
                } else {
                  return const Icon(Icons.account_circle);
                }
              }),
              onPressed: () {
                AppService.switchGlobalDrawer();
              },
            ),
            Text(t.forum.forum),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showAppDialog(
                SearchDialog(
                  userInputKeywords: '',
                  initialSegment: SearchSegment.forum,
                  onSearch: (searchInfo, segment, filters, sort) {
                    NaviService.toSearchPage(
                      searchInfo: searchInfo,
                      segment: segment,
                      filters: filters,
                      sort: sort,
                    );
                  },
                ),
              );
            },
            tooltip: t.common.search,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: t.common.refresh,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showPostDialog,
            tooltip: t.forum.createThread,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: _buildBody(context, effectivePaddingTop), // 传递 effectivePaddingTop
    );
  }

  Widget _buildBody(BuildContext context, double effectivePaddingTop) {
    // 接收 effectivePaddingTop
    if (_isLoading) {
      return ForumSkeletonPage(paddingTop: effectivePaddingTop);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: Text(slang.t.common.retry),
            ),
          ],
        ),
      );
    }

    if (_categories == null || _categories!.isEmpty) {
      return MyEmptyWidget(onRefresh: _loadCategories);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 260) {
      // 使用顶部 Tab 来切换"最近"及各分类内容
      return RefreshIndicator(
        displacement: effectivePaddingTop, // 设置下拉指示器的偏移量
        onRefresh: _refreshAll,
        child: DefaultTabController(
          length: _categories!.length + 1,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                physics: const NeverScrollableScrollPhysics(),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                padding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.access_time),
                    text: slang.t.forum.recent,
                  ),
                  ..._categories!.map(
                    (category) => Tab(
                      icon: Icon(_getCategoryIcon(category.name)),
                      text: category.name,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecentThreads(
                      context,
                      effectivePaddingTop,
                    ), // 传递 effectivePaddingTop
                    ..._categories!.map(
                      (category) => SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: effectivePaddingTop,
                        ), // 为 TabView 中的分类内容添加顶部边距
                        child: _buildCategorySection(
                          category,
                          true,
                        ), // 传递 isInTabView = true
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 原有宽屏布局
    return RefreshIndicator(
      displacement: effectivePaddingTop, // 设置下拉指示器的偏移量
      onRefresh: _refreshAll,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 60,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: NavigationRail(
                    minWidth: 56,
                    selectedIndex: _selectedRailIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedRailIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all, // 显示图标和文本
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.access_time),
                        selectedIcon: const Icon(Icons.access_time),
                        label: Text(
                          slang.t.forum.recent,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // 其他分类项：生成顺序保持不变
                      ..._categories!.map((category) {
                        return NavigationRailDestination(
                          icon: Icon(_getCategoryIcon(category.name)),
                          selectedIcon: Icon(_getCategoryIcon(category.name)),
                          label: Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _selectedRailIndex == 0
                  ? _buildRecentThreads(
                      context,
                      effectivePaddingTop,
                    ) // 传递 effectivePaddingTop
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: effectivePaddingTop, // 为分类内容添加顶部边距
                      ),
                      child: _buildCategorySection(
                        _categories![_selectedRailIndex - 1],
                        true,
                      ), // 传递 isInTabView = true
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentThreads(BuildContext context, double effectivePaddingTop) {
    // 接收 effectivePaddingTop
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;
    final bool enableSitewide = CommonConstants.enableForumSitewideAnnouncement;
    final bool hasSitewideSection =
        enableSitewide &&
        (_isLoadingSitewideAnnouncement ||
            _sitewideAnnouncement != null ||
            _sitewideAnnouncementError != null);

    final bool hasStickySection =
        _isLoadingStickyAnnouncements || _stickyAnnouncements.isNotEmpty;

    final bool hasTopSections = hasSitewideSection || hasStickySection;

    return LoadingMoreCustomScrollView(
      slivers: <Widget>[
        if (hasTopSections)
          SliverPadding(
            padding: EdgeInsets.only(
              top: effectivePaddingTop + 8,
              left: 8,
              right: 8,
              bottom: 12,
            ),
            sliver: SliverToBoxAdapter(
              child: isWideScreen
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: hasSitewideSection && hasStickySection
                              ? 1100
                              : 720,
                        ),
                        child: _buildTopAnnouncementsRowOrSingle(
                          hasSitewideSection: hasSitewideSection,
                          hasStickySection: hasStickySection,
                        ),
                      ),
                    )
                  : _buildTopAnnouncementsColumn(
                      hasSitewideSection: hasSitewideSection,
                      hasStickySection: hasStickySection,
                    ),
            ),
          ),
        LoadingMoreSliverList<ForumThreadModel>(
          SliverListConfig<ForumThreadModel>(
            extendedListDelegate:
                const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
            itemBuilder: (context, thread, index) => ThreadListItemWidget(
              thread: thread,
              categoryId: thread.section,
              onTap: () => NaviService.navigateToForumThreadDetailPage(
                thread.section,
                thread.id,
              ),
            ),
            sourceList: _recentThreadRepository,
            padding: EdgeInsets.only(
              top: hasTopSections ? 0 : effectivePaddingTop, // 顶部由置顶区域占位
              bottom: MediaQuery.of(context).padding.bottom, // 添加底部安全区域边距
              left: 8, // 统一左右边距
              right: 8,
            ),
            indicatorBuilder: (context, status) {
              // 判断是否为全屏状态
              final bool isFullScreenIndicator =
                  status == IndicatorStatus.fullScreenBusying ||
                  status == IndicatorStatus.fullScreenError ||
                  status == IndicatorStatus.empty;
              return buildIndicator(
                context,
                status,
                () => _recentThreadRepository.errorRefresh(),
                emptyIcon: Icons.forum_outlined,
                // 传递 paddingTop 给指示器构建函数
                paddingTop: isFullScreenIndicator ? effectivePaddingTop : 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopAnnouncementsRowOrSingle({
    required bool hasSitewideSection,
    required bool hasStickySection,
  }) {
    final bool hasSticky = hasStickySection;

    if (hasSitewideSection && hasSticky) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildSitewideAnnouncementCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildStickyAnnouncementsCard()),
        ],
      );
    }

    if (hasSitewideSection) {
      return _buildSitewideAnnouncementCard();
    }
    return _buildStickyAnnouncementsCard();
  }

  Widget _buildTopAnnouncementsColumn({
    required bool hasSitewideSection,
    required bool hasStickySection,
  }) {
    final children = <Widget>[];
    if (hasSitewideSection) {
      children.add(_buildSitewideAnnouncementCard());
    }
    if (hasStickySection) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: 8));
      }
      children.add(_buildStickyAnnouncementsCard());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildStickyAnnouncementsCard() {
    if (_isLoadingStickyAnnouncements && _stickyAnnouncements.isEmpty) {
      return _buildStickyAnnouncementsSkeleton();
    }
    if (_stickyAnnouncements.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildStickyAnnouncementsSection();
  }

  Widget _buildSitewideAnnouncementCard() {
    final t = slang.Translations.of(context);
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;

    if (_isLoadingSitewideAnnouncement) {
      return _buildSitewideAnnouncementSkeleton();
    }

    if (_sitewideAnnouncementError != null) {
      return _buildSitewideAnnouncementErrorCard(
        title: t.forum.sitewide.title,
        message: _sitewideAnnouncementError!,
      );
    }

    final page = _sitewideAnnouncement;
    if (page == null) {
      return const SizedBox.shrink();
    }

    final languageCode = slang.LocaleSettings.currentLocale.languageCode;
    final title = t.forum.sitewide.title;
    final body = page.localizedBody(languageCode);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (!isWideScreen)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(t.forum.sitewide.badge),
                      ),
                    ),
                  if (page.sensitive)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(t.common.sensitive),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CommonUtils.formatFriendlyTimestamp(page.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: t.common.refresh,
                    onPressed: _loadSitewideAnnouncement,
                    icon: const Icon(Icons.refresh, size: 18),
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            if (isWideScreen)
              _buildSitewideAnnouncementPreview(body: body)
            else
              Column(
                children: [
                  CustomMarkdownBody(
                    data: body,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    maxImageHeight: 220,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            _showSitewideAnnouncementDialog(body: body),
                        icon: const Icon(Icons.open_in_full, size: 16),
                        label: Text(t.forum.sitewide.readMore),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSitewideAnnouncementPreview({required String body}) {
    final t = slang.Translations.of(context);
    final imageUrl = _extractFirstMarkdownImageUrl(body);
    final previewText = _buildPlainPreviewText(body);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                width: 160,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Container(width: 160, height: 90, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 160,
                  height: 90,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(t.forum.sitewide.badge),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          _showSitewideAnnouncementDialog(body: body),
                      icon: const Icon(Icons.open_in_full, size: 16),
                      label: Text(t.forum.sitewide.readMore),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  previewText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSitewideAnnouncementDialog({required String body}) {
    final t = slang.Translations.of(context);
    final title = t.forum.sitewide.title;
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: slang.t.common.close,
                      style: IconButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CustomMarkdownBody(
                    data: body,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    maxImageHeight: 420,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildPlainPreviewText(String markdown) {
    var text = markdown;
    text = text.replaceAll(RegExp(r'!\[[^\]]*\]\([^)]+\)'), ' ');
    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');
    text = text.replaceAll('\n', ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String? _extractFirstMarkdownImageUrl(String markdown) {
    final match = RegExp(r'!\[[^\]]*\]\(([^)]+)\)').firstMatch(markdown);
    if (match == null) return null;
    final url = match.group(1)?.trim();
    if (url == null || url.isEmpty) return null;
    return UrlUtils.upgradeIwaraHttpToHttps(url);
  }

  Widget _buildSitewideAnnouncementErrorCard({
    required String title,
    required String message,
  }) {
    final t = slang.Translations.of(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _loadSitewideAnnouncement,
              icon: const Icon(Icons.refresh),
              label: Text(t.common.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSitewideAnnouncementSkeleton() {
    final t = slang.Translations.of(context);
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 18,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.forum.sitewide.title,
                style: const TextStyle(color: Colors.transparent),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyAnnouncementsSkeleton() {
    final t = slang.Translations.of(context);
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 18,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    t.forum.leafNames.announcements,
                    style: const TextStyle(color: Colors.transparent),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    ForumCategoryTreeModel category,
    bool isInTabView,
  ) {
    // 接收 isInTabView
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 260;
    // 移除外部 Padding，因为父级 SingleChildScrollView 或 TabBarView 已处理顶部边距
    return Card(
      elevation: 2,
      margin: isNarrowScreen
          ? EdgeInsets
                .zero // 窄屏模式下不需要边距
          : const EdgeInsets.only(bottom: 16.0), // 宽屏模式只需要底部边距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category.name),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 子分类列表
          if (isWideScreen)
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4), // 标题
                1: FlexColumnWidth(1), // 主题数
                2: FlexColumnWidth(1), // 回复数
                3: FlexColumnWidth(3), // 最后回复
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  ),
                  children: [
                    _buildTableHeader(context, slang.t.forum.category),
                    _buildTableHeader(context, slang.t.forum.threads),
                    _buildTableHeader(context, slang.t.forum.posts),
                    _buildTableHeader(context, slang.t.forum.lastReply),
                  ],
                ),
              ],
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.children.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subCategory = category.children[index];
              // 传递 isNarrowTabLayout 参数给子项构建函数
              return _buildSubCategoryTile(
                subCategory,
                context,
                isNarrowScreen && isInTabView,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSubCategoryTile(
    ForumCategoryModel subCategory,
    BuildContext context,
    bool isNarrowTabLayout,
  ) {
    // 接收 isNarrowTabLayout
    final t = slang.Translations.of(context);
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    // final bool isNarrowTabLayout = MediaQuery.of(context).size.width < 260; // 使用传入的参数

    if (isWideScreen) {
      return InkWell(
        onTap: () {
          NaviService.navigateToForumThreadListPage(subCategory.id);
        },
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4), // 标题
            1: FlexColumnWidth(1), // 主题数
            2: FlexColumnWidth(1), // 回复数
            3: FlexColumnWidth(3), // 最后回复
          },
          children: [
            TableRow(
              children: [
                // 标题列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        subCategory.locked
                            ? Icons.lock
                            : _getSubCategoryIcon(subCategory.id),
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subCategory.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (subCategory.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subCategory.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 主题数列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numThreads),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // 回复数列
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numPosts),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // 最后回复列
                if (subCategory.lastThread?.lastPost != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToAuthorProfilePage(
                              subCategory.lastThread!.lastPost!.user.username,
                            );
                          },
                          child: AvatarWidget(
                            user: subCategory.lastThread!.lastPost?.user,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (subCategory.lastThread!.sticky)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        Icons.push_pin,
                                        size: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToForumThreadDetailPage(
                                          subCategory.id,
                                          subCategory.lastThread!.id,
                                        );
                                      },
                                      child: Text(
                                        subCategory.lastThread!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {
                                        NaviService.navigateToAuthorProfilePage(
                                          subCategory
                                              .lastThread!
                                              .lastPost!
                                              .user
                                              .username,
                                        );
                                      },
                                      child: buildUserName(
                                        context,
                                        subCategory.lastThread!.lastPost!.user,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.remove_red_eye,
                                    size: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CommonUtils.formatFriendlyNumber(
                                      subCategory.lastThread!.numViews,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(slang.t.common.tmpNoReplies),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // 窄屏布局
    return InkWell(
      onTap: () {
        NaviService.navigateToForumThreadListPage(subCategory.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Icon(
                      subCategory.locked
                          ? Icons.lock
                          : _getSubCategoryIcon(subCategory.id),
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subCategory.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // 只在非窄屏Tab布局时显示统计信息
                          if (!isNarrowTabLayout)
                            Text(
                              '${t.forum.threads}: ${CommonUtils.formatFriendlyNumber(subCategory.numThreads)}  ${t.forum.posts}: ${CommonUtils.formatFriendlyNumber(subCategory.numPosts)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      if (subCategory.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subCategory.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (subCategory.lastThread != null) ...[
              const SizedBox(height: 8),
              // 最后发帖信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarWidget(
                    user: subCategory.lastThread!.lastPost?.user,
                    size: 32,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToForumThreadDetailPage(
                              subCategory.id,
                              subCategory.lastThread!.id,
                            );
                          },
                          child: Text(
                            subCategory.lastThread!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (subCategory.lastThread!.lastPost != null)
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    NaviService.navigateToAuthorProfilePage(
                                      subCategory
                                          .lastThread!
                                          .lastPost!
                                          .user
                                          .username,
                                    );
                                  },
                                  child: buildUserName(
                                    context,
                                    subCategory.lastThread!.lastPost!.user,
                                  ),
                                ),
                              ),
                              Text(
                                ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final t = slang.Translations.of(context);
    if (categoryName == t.forum.groups.administration) {
      return Icons.admin_panel_settings;
    } else if (categoryName == t.forum.groups.global) {
      return Icons.public; // 全球使用 public 图标
    } else if (categoryName == t.forum.groups.chinese) {
      return Icons.chat; // 中文使用 chat 图标
    } else if (categoryName == t.forum.groups.japanese) {
      return Icons.translate; // 日文使用 translate 图标
    } else {
      return Icons.forum;
    }
  }

  IconData _getSubCategoryIcon(String id) {
    switch (id) {
      case 'announcements':
        return Icons.campaign;
      case 'feedback':
        return Icons.feedback;
      case 'support':
      case 'support-zh':
      case 'support-ja':
        return Icons.help;
      case 'general':
      case 'general-zh':
      case 'general-ja':
        return Icons.forum;
      case 'guides':
        return Icons.menu_book;
      case 'questions':
      case 'questions-zh':
      case 'questions-ja':
        return Icons.question_answer;
      case 'requests':
      case 'requests-zh':
      case 'requests-ja':
        return Icons.record_voice_over;
      case 'sharing':
        return Icons.share;
      case 'korean':
        return Icons.translate;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.forum;
    }
  }

  Widget _buildStickyAnnouncementsSection() {
    final t = slang.Translations.of(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.campaign,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.forum.leafNames.announcements,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.push_pin,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 公告列表
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _stickyAnnouncements.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final announcement = _stickyAnnouncements[index];
                return InkWell(
                  onTap: () {
                    NaviService.navigateToForumThreadDetailPage(
                      announcement.section,
                      announcement.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // 内容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.visibility,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CommonUtils.formatFriendlyNumber(
                                      announcement.numViews,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.comment,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CommonUtils.formatFriendlyNumber(
                                      announcement.numPosts,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    CommonUtils.formatFriendlyTimestamp(
                                      announcement.updatedAt,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 箭头
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
