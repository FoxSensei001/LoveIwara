import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/forum_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
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
  List<ForumCategoryTreeModel>? _categories;
  bool _isLoading = true;
  String? _error;
  final UserService userService = Get.find<UserService>();
  int _selectedRailIndex = 0; // 修改变量名称：选中 rail 的索引（0 为 最近，其余从 _categories 中获取）
  late RecentThreadListRepository _recentThreadRepository;
  final appBarHeight = 56.0;

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
  }

  @override
  void dispose() {
    _recentThreadRepository.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

  void _showPostDialog() {
    UserService userService = Get.find<UserService>();
    if (!userService.isLogin) {
      AppService.switchGlobalDrawer();
      showToastWidget(MDToastWidget(
          message: slang.t.errors.pleaseLoginFirst, type: MDToastType.warning));
      return;
    }
    Get.dialog(
      ForumPostDialog(
        onSubmit: () {
          // 刷新帖子列表
          _loadCategories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 计算 AppBar 和状态栏的总高度
    final double effectivePaddingTop = MediaQuery.of(context).padding.top + appBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true, // 让内容延伸到AppBar下面，以便显示毛玻璃效果
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: appBarHeight,
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.7), // 设置半透明背景
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 毛玻璃效果参数
            child: Container(
              color: Colors.transparent,
            ),
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
                          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        size: 40
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Obx(() {
                          final count = userService.notificationCount.value +
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
              Get.dialog(SearchDialog(
                initialSearch: '',
                initialSegment: SearchSegment.forum,
                onSearch: (searchInfo, segment) {
                  NaviService.toSearchPage(
                    searchInfo: searchInfo,
                    segment: segment,
                  );
                },
              ));
            },
            tooltip: t.common.search,
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
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

  Widget _buildBody(BuildContext context, double effectivePaddingTop) { // 接收 effectivePaddingTop
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
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
      return MyEmptyWidget(
        onRefresh: _loadCategories,
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 260) {
      // 使用顶部 Tab 来切换"最近"及各分类内容
      return RefreshIndicator(
        displacement: effectivePaddingTop, // 设置下拉指示器的偏移量
        onRefresh: _loadCategories,
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
                  ..._categories!.map((category) => Tab(
                        icon: Icon(_getCategoryIcon(category.name)),
                        text: category.name,
                      )),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecentThreads(context, effectivePaddingTop), // 传递 effectivePaddingTop
                    ..._categories!.map((category) => SingleChildScrollView(
                          padding: EdgeInsets.only(top: effectivePaddingTop), // 为 TabView 中的分类内容添加顶部边距
                          child: _buildCategorySection(category, true), // 传递 isInTabView = true
                        )),
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
      onRefresh: _loadCategories,
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
                  ? _buildRecentThreads(context, effectivePaddingTop) // 传递 effectivePaddingTop
                  : SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: effectivePaddingTop, // 为分类内容添加顶部边距
                      ),
                      child: _buildCategorySection(
                          _categories![_selectedRailIndex - 1], true), // 传递 isInTabView = true
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentThreads(BuildContext context, double effectivePaddingTop) { // 接收 effectivePaddingTop
    return LoadingMoreCustomScrollView(
      slivers: <Widget>[
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
                  thread.section, thread.id),
            ),
            sourceList: _recentThreadRepository,
            padding: EdgeInsets.only(
              top: effectivePaddingTop, // 使用计算好的顶部边距
              bottom: MediaQuery.of(context).padding.bottom, // 添加底部安全区域边距
              left: 8, // 统一左右边距
              right: 8,
            ),
            indicatorBuilder: (context, status) {
              // 判断是否为全屏状态
              final bool isFullScreenIndicator = status == IndicatorStatus.fullScreenBusying ||
                                                status == IndicatorStatus.fullScreenError ||
                                                status == IndicatorStatus.empty;
              return myLoadingMoreIndicator(
                context,
                status,
                isSliver: true,
                loadingMoreBase: _recentThreadRepository,
                // 传递 paddingTop 给指示器构建函数
                paddingTop: isFullScreenIndicator ? effectivePaddingTop : 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(ForumCategoryTreeModel category, bool isInTabView) { // 接收 isInTabView
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 260;
    // 移除外部 Padding，因为父级 SingleChildScrollView 或 TabBarView 已处理顶部边距
    return Card(
      elevation: 2,
      margin: isNarrowScreen
          ? EdgeInsets.zero // 窄屏模式下不需要边距
          : const EdgeInsets.only(bottom: 16.0), // 宽屏模式只需要底部边距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.5),
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
              return _buildSubCategoryTile(subCategory, context, isNarrowScreen && isInTabView);
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
      ForumCategoryModel subCategory, BuildContext context, bool isNarrowTabLayout) { // 接收 isNarrowTabLayout
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
                            NaviService.navigateToAuthorProfilePage(subCategory
                                .lastThread!.lastPost!.user.username);
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        NaviService
                                            .navigateToForumThreadDetailPage(
                                                subCategory.id,
                                                subCategory.lastThread!.id);
                                      },
                                      child: Text(
                                        subCategory.lastThread!.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                            subCategory.lastThread!.lastPost!
                                                .user.username);
                                      },
                                      child: buildUserName(
                                          context,
                                          subCategory
                                              .lastThread!.lastPost!.user),
                                    ),
                                  ),
                                  Text(
                                    ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.remove_red_eye,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    CommonUtils.formatFriendlyNumber(
                                        subCategory.lastThread!.numViews),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
                                subCategory.id, subCategory.lastThread!.id);
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
                                        subCategory.lastThread!.lastPost!
                                            .user.username);
                                  },
                                  child: buildUserName(context,
                                      subCategory.lastThread!.lastPost!.user),
                                ),
                              ),
                              Text(
                                ' · ${CommonUtils.formatFriendlyTimestamp(subCategory.lastThread!.updatedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
}
