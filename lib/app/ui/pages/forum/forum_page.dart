import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/iwara_page.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/recent_thread_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_skeleton_page.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ForumPage extends StatefulWidget implements HomeWidgetInterface {
  static final globalKey = GlobalKey<_ForumPageState>();
  final int contentResetVersion;

  const ForumPage({super.key, this.contentResetVersion = 0});

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
  // “最近”列表的滚动控制器，用于再次点击栏目时回到顶部
  final ScrollController _recentThreadsScrollController = ScrollController();
  // 分类内容（rail 布局下同一时刻仅显示一个分类）的滚动控制器，用于回到顶部
  final ScrollController _categoryScrollController = ScrollController();

  /// 当前可见列表是否已滚过一段距离（控制右下角「回到顶部」浮钮）。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);
  static const double _backToTopOffset = 600;
  static const double _cardRadius = 14.0;
  static const double _pageSidePadding = 8.0;
  final double appBarHeight = GlassTokens.headerRowHeight;

  // ---- 「最近」列表分页模式 ----
  final RxBool _isPaginated = CommonConstants.isPaginated.obs;
  static const int _recentItemsPerPage = 20;
  int _recentCurrentPage = 0;
  bool _recentPageLoading = false;
  List<ForumThreadModel> _recentPaginatedItems = [];
  IndicatorStatus _recentIndicatorStatus = IndicatorStatus.fullScreenBusying;
  String? _recentErrorMessage;
  bool _recentFirstLoad = true;

  int get _recentTotalItems => _recentThreadRepository.requestTotalCount;
  int get _recentTotalPages => _recentTotalItems > 0
      ? (_recentTotalItems / _recentItemsPerPage).ceil()
      : 1;

  // ---- 全站公告卡片「显示原始文本」外部受控开关 ----
  bool _sitewideShowOriginal = false;
  bool _sitewideHasProcessed = false;

  // 置顶公告相关
  List<ForumThreadModel> _stickyAnnouncements = [];
  bool _isLoadingStickyAnnouncements = false;

  // 全站公告相关（apiq /page/sitewide-announcement）
  IwaraPageModel? _sitewideAnnouncement;
  bool _isLoadingSitewideAnnouncement = false;
  String? _sitewideAnnouncementError;

  ShapeBorder _forumCardShape(
    BuildContext context, {
    double radius = _cardRadius,
    double borderAlpha = 0.3,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: borderAlpha),
      ),
    );
  }

  Widget _buildForumLabelChip({
    required String text,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? colorScheme.onSurfaceVariant;
    final bg = backgroundColor ?? fg.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildForumMetaChip({
    required IconData icon,
    required String text,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? colorScheme.onSurfaceVariant;
    final bg = backgroundColor ?? fg.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: fg),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 当前可见列表回到顶部（“最近”或某个分类，二者同一时刻只挂载其一）。
  void _scrollCurrentListToTop() {
    for (final controller in [
      _recentThreadsScrollController,
      _categoryScrollController,
    ]) {
      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _updateBackToTop() {
    bool show = false;
    for (final controller in [
      _recentThreadsScrollController,
      _categoryScrollController,
    ]) {
      if (controller.hasClients && controller.offset > _backToTopOffset) {
        show = true;
        break;
      }
    }
    if (_showBackToTop.value != show) _showBackToTop.value = show;
  }

  void tryRefreshCurrentList() {
    if (!mounted) return;
    _scrollCurrentListToTop();
    // 整体重载：分类树、最近帖子、置顶/全站公告
    _refreshAll();
  }

  @override
  void initState() {
    super.initState();
    _recentThreadsScrollController.addListener(_updateBackToTop);
    _categoryScrollController.addListener(_updateBackToTop);
    _sitewideShowOriginal =
        Get.find<ConfigService>()[ConfigKey.SHOW_UNPROCESSED_MARKDOWN_TEXT_KEY];
    _loadCategories();
    _recentThreadRepository = RecentThreadListRepository();
    if (_isPaginated.value) {
      _loadRecentPage(0);
    }
    _loadStickyAnnouncements();
    if (CommonConstants.enableForumSitewideAnnouncement) {
      _loadSitewideAnnouncement();
    }
  }

  /// 切换「最近」列表的瀑布流 / 分页模式。
  void _togglePaginationMode() {
    final newValue = !_isPaginated.value;
    _isPaginated.value = newValue;
    CommonConstants.isPaginated = newValue;
    Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = newValue;

    _scrollCurrentListToTop();
    if (newValue) {
      _recentCurrentPage = 0;
      _loadRecentPage(0);
    } else {
      _recentThreadRepository.refresh(true);
    }
  }

  /// 加载「最近」列表的分页数据。
  Future<void> _loadRecentPage(int page) async {
    if (_recentPageLoading) return;

    setState(() {
      _recentPageLoading = true;
      if (_recentFirstLoad || page == 0) {
        _recentIndicatorStatus = IndicatorStatus.fullScreenBusying;
      } else {
        _recentIndicatorStatus = IndicatorStatus.loadingMoreBusying;
      }
    });

    final bool pageChanged = page != _recentCurrentPage && !_recentFirstLoad;

    try {
      final items = await _recentThreadRepository.loadPageData(
        page,
        _recentItemsPerPage,
      );

      if (!mounted) return;

      setState(() {
        _recentPaginatedItems = items;
        _recentCurrentPage = page;
        _recentPageLoading = false;
        _recentFirstLoad = false;

        if (items.isEmpty && page == 0) {
          _recentIndicatorStatus = IndicatorStatus.empty;
        } else if (items.isEmpty) {
          _recentIndicatorStatus = IndicatorStatus.noMoreLoad;
        } else {
          _recentIndicatorStatus = IndicatorStatus.none;
        }
      });

      if (pageChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollCurrentListToTop();
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _recentPageLoading = false;
        _recentFirstLoad = false;
        _recentErrorMessage = CommonUtils.parseExceptionMessage(e);
        _recentIndicatorStatus = page == 0
            ? IndicatorStatus.fullScreenError
            : IndicatorStatus.error;
      });
    }
  }

  @override
  void dispose() {
    _recentThreadRepository.dispose();
    _recentThreadsScrollController.removeListener(_updateBackToTop);
    _categoryScrollController.removeListener(_updateBackToTop);
    _recentThreadsScrollController.dispose();
    _categoryScrollController.dispose();
    _showBackToTop.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ForumPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentResetVersion != widget.contentResetVersion) {
      _recentThreadRepository.dispose();
      _recentThreadRepository = RecentThreadListRepository();
      _resetForContentChange();
    }
  }

  void _resetForContentChange() {
    _recentThreadRepository.clear();

    setState(() {
      _selectedRailIndex = 0;
      _categories = null;
      _error = null;
      _isLoading = true;
      _stickyAnnouncements = [];
      _isLoadingStickyAnnouncements = false;
      _sitewideAnnouncement = null;
      _sitewideAnnouncementError = null;
      _isLoadingSitewideAnnouncement = false;
      // 分页态重置（仓库已重建，旧页数据/错误全部作废）
      _recentPaginatedItems = [];
      _recentCurrentPage = 0;
      _recentFirstLoad = true;
      _recentPageLoading = false;
      _recentErrorMessage = null;
      _recentIndicatorStatus = IndicatorStatus.fullScreenBusying;
    });

    _refreshAll();
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
      if (_isPaginated.value)
        _loadRecentPage(0)
      else
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
    if (!userService.isAuthenticated) {
      AppService.switchGlobalDrawer();
      showGlassToast(
        slang.t.errors.pleaseLoginFirst,
        type: GlassToastType.warning,
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

  void _openSearchDialog() {
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
  }

  /// 左上角「我」圆钮：登录中显示闪烁占位，已登录显示头像（带未读红点）。
  Widget _buildAvatarButton(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final Widget inner;
      if (userService.isLogining.value) {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-shimmer'),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      } else if (userService.hasLoadedProfile &&
          userService.currentUser.value != null) {
        inner = KeyedSubtree(
          // 用户 id 变化时（切换账号）也触发一次交叉过渡
          key: ValueKey('avatar-${userService.currentUser.value?.id}'),
          child: IgnorePointer(
            // 头像铺满圆钮（只留 1px 玻璃描边），不要一圈内边距
            child: AvatarWidget(
              user: userService.currentUser.value,
              size: GlassTokens.pillHeight - 2,
            ),
          ),
        );
      } else {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-placeholder'),
          child: Icon(
            Icons.account_circle,
            size: 26,
            color: colorScheme.onSurface,
          ),
        );
      }
      final count =
          userService.notificationCount.value + userService.messagesCount.value;
      return GlassSurface(
        circle: true,
        tooltip: t.common.me,
        onTap: AppService.switchGlobalDrawer,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // shimmer / avatar / placeholder 三态交叉过渡
            GlassShapeSwitcher(child: inner),
            Positioned(
              right: 2,
              top: 2,
              child: GlassAnimatedDot(visible: count > 0),
            ),
          ],
        ),
      );
    });
  }

  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';

  /// 右侧动作胶囊：[搜索(仅宽屏)] 发帖 · 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        GlassGroupSlot(
          visible: isWide,
          child: GlassIconButton(
            icon: const Icon(Icons.search),
            tooltip: t.common.search,
            onPressed: _openSearchDialog,
          ),
        ),
        // 瀑布/分页切换只作用于「最近」列表，切到分类栏目时随之挤出
        GlassGroupSlot(
          visible: _selectedRailIndex == 0,
          child: Obx(
            () => GlassIconButton(
              icon: Icon(
                _isPaginated.value ? Icons.view_stream : Icons.view_module,
              ),
              tooltip: _isPaginated.value
                  ? t.common.pagination.waterfall
                  : t.common.pagination.pagination,
              onPressed: _togglePaginationMode,
            ),
          ),
        ),
        GlassIconButton(
          icon: const Icon(Icons.add),
          tooltip: t.forum.createThread,
          onPressed: _showPostDialog,
        ),
        SizedBox(
          width: GlassTokens.groupIconButtonSize,
          height: GlassTokens.groupIconButtonSize,
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: GlassTokens.iconSize),
            position: PopupMenuPosition.under,
            // 往下挪一点，别压住玻璃胶囊本身
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case _menuActionOpenSearch:
                  _openSearchDialog();
                  break;
                case _menuActionRefresh:
                  _refreshAll();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!isWide)
                PopupMenuItem<String>(
                  value: _menuActionOpenSearch,
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 12),
                      Text(t.common.search),
                    ],
                  ),
                ),
              PopupMenuItem<String>(
                value: _menuActionRefresh,
                child: Row(
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 12),
                    Text(t.common.refresh),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；「最近」分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(
      () => Positioned(
        // 移动端底栏可见时与搜索圆钮中心共轴；宽屏（rail 布局）用普通右边距
        right: isFloatingBarInsetActive(context)
            ? GlassTokens.floatingActionCoAxisRight(GlassTokens.pillHeight)
            : 16,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (_isPaginated.value && _selectedRailIndex == 0 ? 46 : 0),
        child: ValueListenableBuilder<bool>(
          valueListenable: _showBackToTop,
          builder: (context, visible, _) => IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              duration: GlassTokens.motionDuration,
              curve: GlassTokens.motionCurve,
              offset: visible ? Offset.zero : const Offset(0, 0.4),
              child: AnimatedOpacity(
                duration: GlassTokens.motionDuration,
                opacity: visible ? 1 : 0,
                child: GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.vertical_align_top),
                  tooltip: t.common.scrollToTop,
                  onPressed: _scrollCurrentListToTop,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // header 行（状态栏 + 玻璃 header）占用的总高度，列表用它做 paddingTop
    final double effectivePaddingTop = statusBarHeight + appBarHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // 内容铺满整页，自己用 effectivePaddingTop 让出 header
          Positioned.fill(child: _buildBody(context, effectivePaddingTop)),

          // 顶部渐变蒙层（列表滚到下面时淡出）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: EdgeFadeScrim.top(
              height: effectivePaddingTop + GlassTokens.headerFadeExtent,
              solidExtent: statusBarHeight,
            ),
          ),

          // header 行：左 头像圆钮 / 中 标题 / 右 动作胶囊
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            height: appBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildAvatarButton(context),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GlassSurface(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // 用 Row(min) 而不是 Center：Center 在有界约束下会撑满整个中间区
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.forum.forum,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionGroup(context, isWide: isWide),
                ],
              ),
            ),
          ),

          _buildScrollToTopFab(context),
        ],
      ),
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
          key: ValueKey('forum-tabs-${widget.contentResetVersion}'),
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
              // 分类栏也从玻璃 header 下方开始、底部给浮动底栏让位（内容可滚到背后）
              padding: EdgeInsets.only(
                top: effectivePaddingTop,
                bottom: MediaQuery.of(context).padding.bottom,
              ),
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
                      controller: _categoryScrollController,
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

  bool get _hasSitewideSection =>
      CommonConstants.enableForumSitewideAnnouncement &&
      (_isLoadingSitewideAnnouncement ||
          _sitewideAnnouncement != null ||
          _sitewideAnnouncementError != null);

  bool get _hasStickySection =>
      _isLoadingStickyAnnouncements || _stickyAnnouncements.isNotEmpty;

  /// 「最近」列表顶部的公告区块（全站公告 + 置顶公告），瀑布流和分页两种
  /// 模式共用；没有内容时返回 null。
  Widget? _buildTopSectionsSliver(double effectivePaddingTop) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 900;
    final bool hasSitewideSection = _hasSitewideSection;
    final bool hasStickySection = _hasStickySection;
    if (!hasSitewideSection && !hasStickySection) return null;

    return SliverPadding(
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
    );
  }

  static const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
  _recentWaterfallDelegate = SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 300,
    crossAxisSpacing: 5,
    mainAxisSpacing: 5,
  );

  Widget _buildRecentThreadItem(ForumThreadModel thread) {
    return ThreadListItemWidget(
      thread: thread,
      categoryId: thread.section,
      onTap: () => NaviService.navigateToForumThreadDetailPage(
        thread.section,
        thread.id,
        initialThread: thread,
      ),
    );
  }

  Widget _buildRecentThreads(BuildContext context, double effectivePaddingTop) {
    return Obx(
      () => _isPaginated.value
          ? _buildRecentPaginated(context, effectivePaddingTop)
          : _buildRecentWaterfall(context, effectivePaddingTop),
    );
  }

  /// 瀑布流模式的「最近」列表。
  Widget _buildRecentWaterfall(
    BuildContext context,
    double effectivePaddingTop,
  ) {
    final topSliver = _buildTopSectionsSliver(effectivePaddingTop);

    return LoadingMoreCustomScrollView(
      controller: _recentThreadsScrollController,
      slivers: <Widget>[
        ?topSliver,
        LoadingMoreSliverList<ForumThreadModel>(
          SliverListConfig<ForumThreadModel>(
            extendedListDelegate: _recentWaterfallDelegate,
            itemBuilder: (context, thread, index) =>
                _buildRecentThreadItem(thread),
            sourceList: _recentThreadRepository,
            padding: EdgeInsets.only(
              top: topSliver != null ? 0 : effectivePaddingTop, // 顶部由置顶区域占位
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

  /// 分页模式的「最近」列表：公告区块 + 瀑布网格 + 底部分页栏。
  Widget _buildRecentPaginated(
    BuildContext context,
    double effectivePaddingTop,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // 46 = 分页栏内容高度；再加悬浮模式上方的透明渐入区
    final paginationBarHeight = 46 + PaginationBar.fadeAboveExtent;
    final topSliver = _buildTopSectionsSliver(effectivePaddingTop);

    final bool isFullScreenStatus =
        _recentIndicatorStatus == IndicatorStatus.fullScreenBusying ||
        _recentIndicatorStatus == IndicatorStatus.fullScreenError ||
        (_recentIndicatorStatus == IndicatorStatus.empty &&
            _recentPaginatedItems.isEmpty);

    return Stack(
      children: [
        RefreshIndicator(
          // 下拉指示器从玻璃 header 下方弹出
          displacement: effectivePaddingTop,
          onRefresh: _refreshAll,
          child: CustomScrollView(
            controller: _recentThreadsScrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              topSliver ??
                  SliverToBoxAdapter(
                    child: SizedBox(height: effectivePaddingTop + 8),
                  ),
              if (isFullScreenStatus)
                buildIndicator(
                      context,
                      _recentIndicatorStatus,
                      () => _loadRecentPage(_recentCurrentPage),
                      emptyIcon: Icons.forum_outlined,
                      paddingTop: 0,
                      errorMessage: _recentErrorMessage,
                    ) ??
                    const SliverToBoxAdapter(child: SizedBox.shrink())
              else
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: paginationBarHeight + bottomPadding + 4.0,
                  ),
                  sliver: SliverWaterfallFlow(
                    gridDelegate: _recentWaterfallDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildRecentThreadItem(_recentPaginatedItems[index]),
                      childCount: _recentPaginatedItems.length,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 分页控制栏
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PaginationBar(
            currentPage: _recentCurrentPage,
            totalPages: _recentTotalPages,
            totalItems: _recentTotalItems,
            isLoading: _recentPageLoading,
            onPageChanged: _loadRecentPage,
            useBlurEffect: true,
            paddingBottom: bottomPadding,
            showBottomPadding: true,
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

  /// 卡片内幽灵胶囊钮：小图标 + 小字 + 浅色胶囊底（与评论区动作行同款）。
  Widget _buildGhostAction({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg = color ?? colorScheme.onSurfaceVariant;
    final bg = color != null
        ? color.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHigh;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 卡片内幽灵圆钮（仅图标）。
  Widget _buildGhostIconAction({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  /// 全站公告卡片：宽窄屏统一布局——头部行（图标 + 标题 + 刷新圆钮）、
  /// chips（敏感 / 更新时间）、正文 Markdown、底部单行动作
  /// [显示原始文本] [查看全文]（原生 toggle 已关闭，由本卡片受控）。
  Widget _buildSitewideAnnouncementCard() {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

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
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildGhostIconAction(
                  icon: Icons.refresh,
                  tooltip: t.common.refresh,
                  onTap: _loadSitewideAnnouncement,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (page.sensitive)
                  _buildForumLabelChip(
                    text: t.common.sensitive,
                    foregroundColor: colorScheme.error,
                    backgroundColor: colorScheme.error.withValues(alpha: 0.12),
                  ),
                _buildForumMetaChip(
                  icon: Icons.schedule_rounded,
                  text: CommonUtils.formatFriendlyTimestamp(page.updatedAt),
                ),
              ],
            ),
            const Divider(height: 18),
            CustomMarkdownBody(
              data: body,
              padding: EdgeInsets.zero,
              maxImageHeight: 220,
              // 原生开关关闭，改由下方动作行受控（和「查看全文」放同一行）
              showProcessedTextToggle: false,
              initialShowUnprocessedText: _sitewideShowOriginal,
              onProcessedContentChanged: (hasProcessed) {
                if (_sitewideHasProcessed == hasProcessed) return;
                setState(() => _sitewideHasProcessed = hasProcessed);
              },
            ),
            const SizedBox(height: 8),
            // 单行动作：显示原始文本（有处理差异时才出现） · 查看全文
            Row(
              children: [
                const Spacer(),
                if (_sitewideHasProcessed) ...[
                  _buildGhostAction(
                    icon: _sitewideShowOriginal
                        ? Icons.format_paint
                        : Icons.format_paint_outlined,
                    label: _sitewideShowOriginal
                        ? t.common.showProcessedText
                        : t.common.showOriginalText,
                    onTap: () => setState(
                      () => _sitewideShowOriginal = !_sitewideShowOriginal,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                _buildGhostAction(
                  icon: Icons.open_in_full,
                  label: t.forum.sitewide.readMore,
                  color: colorScheme.primary,
                  onTap: () => _showSitewideAnnouncementDialog(body: body),
                ),
              ],
            ),
          ],
        ),
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
                    GlassIconButton(
                      standalone: true,
                      icon: const Icon(Icons.close),
                      tooltip: slang.t.common.close,
                      onPressed: () => Navigator.of(dialogContext).pop(),
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

  Widget _buildSitewideAnnouncementErrorCard({
    required String title,
    required String message,
  }) {
    final t = slang.Translations.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
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
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
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
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
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
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _getCategoryAccentColor(category.name);
    // 移除外部 Padding，因为父级 SingleChildScrollView 或 TabBarView 已处理顶部边距
    return Card(
      elevation: 0,
      margin: isNarrowScreen
          ? EdgeInsets
                .zero // 窄屏模式下不需要边距
          : const EdgeInsets.only(bottom: 16.0, left: _pageSidePadding),
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题栏
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.55,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(_cardRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _getCategoryIcon(category.name),
                  size: 20,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 子分类列表
          if (isWideScreen) _buildWideSubCategoryHeaderRow(context),
          ..._buildSeparatedChildren<ForumCategoryModel>(
            items: category.children,
            itemBuilder: (subCategory, index) {
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

  Widget _buildWideSubCategoryHeaderRow(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurfaceVariant,
      height: 1.2,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(t.forum.category, style: textStyle)),
          Expanded(
            flex: 1,
            child: Text(
              t.forum.threads,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              t.forum.posts,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 3, child: Text(t.forum.lastReply, style: textStyle)),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTile(
    ForumCategoryModel subCategory,
    BuildContext context,
    bool isNarrowTabLayout,
  ) {
    // 接收 isNarrowTabLayout
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    // final bool isNarrowTabLayout = MediaQuery.of(context).size.width < 260; // 使用传入的参数

    if (isWideScreen) {
      final colorScheme = Theme.of(context).colorScheme;
      final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.22,
      );
      final descriptionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
        height: 1.2,
      );
      final statStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurfaceVariant,
        height: 1.2,
      );

      final lastThread = subCategory.lastThread;
      final Widget lastReplyWidget;
      if (lastThread != null && lastThread.lastPost != null) {
        final thread = lastThread;
        final lastPost = thread.lastPost!;
        lastReplyWidget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => NaviService.navigateToAuthorProfilePage(
                lastPost.user.username,
                initialUser: lastPost.user,
              ),
              child: AvatarWidget(user: lastPost.user, size: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (thread.sticky)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.push_pin_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              NaviService.navigateToForumThreadDetailPage(
                                subCategory.id,
                                thread.id,
                                initialThread: thread,
                              ),
                          child: Text(
                            thread.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildForumMetaChip(
                        icon: Icons.schedule_rounded,
                        text: CommonUtils.formatFriendlyTimestamp(
                          thread.updatedAt,
                        ),
                      ),
                      _buildForumMetaChip(
                        icon: Icons.visibility_rounded,
                        text: CommonUtils.formatFriendlyNumber(thread.numViews),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        lastReplyWidget = Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            slang.t.common.tmpNoReplies,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
          ),
        );
      }

      return InkWell(
        onTap: () => NaviService.navigateToForumThreadListPage(subCategory.id),
        hoverColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        highlightColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.18,
        ),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      subCategory.locked
                          ? Icons.lock_rounded
                          : _getSubCategoryIcon(subCategory.id),
                      size: 18,
                      color: subCategory.locked
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subCategory.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                          if (subCategory.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subCategory.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: descriptionStyle,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numThreads),
                    style: statStyle,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    CommonUtils.formatFriendlyNumber(subCategory.numPosts),
                    style: statStyle,
                  ),
                ),
              ),
              Expanded(flex: 3, child: lastReplyWidget),
            ],
          ),
        ),
      );
    }

    // 窄屏布局
    final colorScheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      height: 1.22,
    );
    final descriptionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 12,
      color: colorScheme.onSurfaceVariant,
      height: 1.2,
    );

    return InkWell(
      onTap: () => NaviService.navigateToForumThreadListPage(subCategory.id),
      hoverColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
      highlightColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.18,
      ),
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    subCategory.locked
                        ? Icons.lock_rounded
                        : _getSubCategoryIcon(subCategory.id),
                    size: 20,
                    color: subCategory.locked
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subCategory.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildForumMetaChip(
                            icon: Icons.forum_outlined,
                            text: CommonUtils.formatFriendlyNumber(
                              subCategory.numThreads,
                            ),
                          ),
                          if (!isNarrowTabLayout)
                            _buildForumMetaChip(
                              icon: Icons.chat_bubble_outline_rounded,
                              text: CommonUtils.formatFriendlyNumber(
                                subCategory.numPosts,
                              ),
                            ),
                        ],
                      ),
                      if (subCategory.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subCategory.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: descriptionStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (subCategory.lastThread != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarWidget(
                    user: subCategory.lastThread!.lastPost?.user,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToForumThreadDetailPage(
                              subCategory.id,
                              subCategory.lastThread!.id,
                              initialThread: subCategory.lastThread,
                            );
                          },
                          child: Text(
                            subCategory.lastThread!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildForumMetaChip(
                              icon: Icons.schedule_rounded,
                              text: CommonUtils.formatFriendlyTimestamp(
                                subCategory.lastThread!.updatedAt,
                              ),
                            ),
                            _buildForumMetaChip(
                              icon: Icons.visibility_rounded,
                              text: CommonUtils.formatFriendlyNumber(
                                subCategory.lastThread!.numViews,
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

  Color _getCategoryAccentColor(String categoryName) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (categoryName == t.forum.groups.chinese) {
      return colorScheme.secondary;
    }
    if (categoryName == t.forum.groups.japanese) {
      return colorScheme.tertiary;
    }
    if (categoryName == t.forum.groups.global) {
      return colorScheme.primary;
    }
    return colorScheme.primary;
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

  List<Widget> _buildSeparatedChildren<T>({
    required List<T> items,
    required Widget Function(T item, int index) itemBuilder,
    Widget separator = const Divider(height: 1),
  }) {
    if (items.isEmpty) {
      return const [];
    }

    return [
      for (int index = 0; index < items.length; index++) ...[
        itemBuilder(items[index], index),
        if (index < items.length - 1) separator,
      ],
    ];
  }

  Widget _buildStickyAnnouncementsSection() {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: _forumCardShape(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.forum.leafNames.announcements,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.push_pin_rounded,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._buildSeparatedChildren<ForumThreadModel>(
            items: _stickyAnnouncements,
            itemBuilder: (announcement, index) {
              return InkWell(
                onTap: () {
                  NaviService.navigateToForumThreadDetailPage(
                    announcement.section,
                    announcement.id,
                    initialThread: announcement,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 11.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildForumMetaChip(
                                  icon: Icons.visibility_rounded,
                                  text: CommonUtils.formatFriendlyNumber(
                                    announcement.numViews,
                                  ),
                                ),
                                _buildForumMetaChip(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  text: CommonUtils.formatFriendlyNumber(
                                    announcement.numPosts,
                                  ),
                                ),
                                _buildForumMetaChip(
                                  icon: Icons.schedule_rounded,
                                  text: CommonUtils.formatFriendlyTimestamp(
                                    announcement.updatedAt,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
