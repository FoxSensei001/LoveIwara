import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/forum_list_controller.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_list_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_overflow_menu_button.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class ThreadListPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ThreadListPage({
    super.key,
    required this.categoryId,
    this.categoryName = '',
  });

  @override
  State<ThreadListPage> createState() => _ThreadListPageState();
}

class _ThreadListPageState extends State<ThreadListPage>
    with SingleTickerProviderStateMixin {
  late ThreadListRepository listSourceRepository;
  late ForumListController _forumListController;

  final ScrollController _scrollController = ScrollController();
  final RxString _categoryName = ''.obs;
  final RxString _categoryDescription = ''.obs;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    // 初始化论坛控制器
    _forumListController = Get.put(
      ForumListController(),
      tag: widget.categoryId,
    );

    listSourceRepository = ThreadListRepository(
      categoryId: widget.categoryId,
      updateCategoryName: (name, description) {
        _categoryName.value = name;
        _categoryDescription.value = description;
      },
    );

    // 注册滚动回调
    _forumListController.registerScrollToTopCallback(_scrollToTop);
  }

  // 滚动到顶部方法
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // 注销滚动回调
    _forumListController.unregisterScrollToTopCallback(_scrollToTop);
    _scrollController.dispose();
    listSourceRepository.dispose();
    _showBackToTop.dispose();
    Get.delete<ForumListController>(tag: widget.categoryId);
    super.dispose();
  }

  void _togglePaginationMode() {
    _forumListController.setPaginatedMode(
      !_forumListController.isPaginated.value,
    );
  }

  Future<void> _refreshList() async {
    if (_forumListController.isPaginated.value) {
      // 分页模式是靠 rebuildKey 换掉整个 MediaListView 来重载的，拿不到刷完的
      // 回执；刷新钮的沙漏在这里只由 GlassAsyncIconButton 的最短时长兜底。
      _forumListController.refreshPageUI();
      return;
    }
    await listSourceRepository.refresh();
    // 滚动到顶部
    _scrollToTop();
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

  /// 右侧动作胶囊：[搜索(仅宽屏)] 刷新 · 发帖 · 更多。
  ///
  /// 「更多」走 [GlassGroupOverflowMenuButton]：宽屏下搜索已经被提到胶囊上，
  /// 菜单里就只剩「瀑布/分页」一条，这时它会自动**变成那枚切换钮本身**，不再
  /// 让用户为一个选项多点一次弹层。
  ///
  /// 这里的 Obx 只圈住 isPaginated 那一处：图标/文案随模式变，而外层胶囊没有
  /// 别的可观察量——整只套 Obx 会因为「作用域里一个观察量都没有」抛 ObxError。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
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
        GlassAsyncIconButton(
          icon: const Icon(Icons.refresh),
          tooltip: t.common.refresh,
          onPressed: _refreshList,
        ),
        GlassIconButton(
          icon: const Icon(Icons.add),
          tooltip: t.forum.createThread,
          onPressed: () => _showCreateThreadDialog(context, widget.categoryId),
        ),
        Obx(() {
          final isPaginated = _forumListController.isPaginated.value;
          return GlassGroupOverflowMenuButton(
            actions: [
              GlassMenuAction(
                // 图标与文案一致：都表示「将要切换到的模式」
                icon: isPaginated ? Icons.view_stream : Icons.view_module,
                label: isPaginated
                    ? t.common.pagination.waterfall
                    : t.common.pagination.pagination,
                onSelected: _togglePaginationMode,
              ),
              if (!isWide)
                GlassMenuAction(
                  icon: Icons.search,
                  label: t.common.search,
                  onSelected: _openSearchDialog,
                ),
            ],
          );
        }),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Obx(
      () => Positioned(
        right: 16,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (_forumListController.isPaginated.value ? 46 : 0),
        child: ValueListenableBuilder<bool>(
          valueListenable: _showBackToTop,
          builder: (context, visible, _) => GlassReveal(
            visible: visible,
            builder: (context, m) => GlassIconButton(
              materialize: m,
              standalone: true,
              icon: const Icon(Icons.vertical_align_top),
              tooltip: t.common.scrollToTop,
              onPressed: _scrollToTop,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final double listTopPadding = headerExtent + 8;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      body: GlassHeaderOverlay(
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.axis == Axis.vertical &&
                notification.depth == 0) {
              _showBackToTop.value = notification.metrics.pixels >= 300;
            }
            return false;
          },
          child: _buildBody(context, listTopPadding),
        ),
        // header 行：左 返回圆钮 / 中 分类标题胶囊 / 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              // 分类标题胶囊：点按/长按弹出完整标题 + 分类描述
              Expanded(
                child: Obx(
                  () => GlassTitlePill(
                    title: _categoryName.value.isEmpty
                        ? null
                        : _categoryName.value,
                    subtitle: _categoryDescription.value.isEmpty
                        ? null
                        : _categoryDescription.value,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context, isWide: isWide),
            ],
          ),
        ),
        extra: [_buildScrollToTopFab(context)],
      ),
    );
  }

  Widget _buildBody(BuildContext context, double listTopPadding) {
    return Obx(() {
      final isPaginated = _forumListController.isPaginated.value;
      final rebuildKey = _forumListController.rebuildKey.value;

      if (isPaginated) {
        // 分页模式
        return MediaListView<ForumThreadModel>(
          key: ValueKey('thread_paginated_$rebuildKey'),
          sourceList: listSourceRepository,
          isPaginated: true,
          scrollController: _scrollController,
          emptyIcon: Icons.forum_outlined,
          paddingTop: listTopPadding,
          itemBuilder: (context, thread, index) => ThreadListItemWidget(
            thread: thread,
            categoryId: widget.categoryId,
            onTap: () => _navigateToThreadDetail(thread),
          ),
        );
      } else {
        // 瀑布流模式
        const waterfallDelegate =
            SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            );
        return LoadingMoreCustomScrollView(
          key: ValueKey('thread_waterfall_$rebuildKey'),
          controller: _scrollController,
          slivers: <Widget>[
            LoadingMoreSliverList<ForumThreadModel>(
              SliverListConfig<ForumThreadModel>(
                extendedListDelegate: waterfallDelegate,
                itemBuilder: (context, thread, index) => ThreadListItemWidget(
                  thread: thread,
                  categoryId: widget.categoryId,
                  onTap: () => _navigateToThreadDetail(thread),
                ),
                sourceList: listSourceRepository,
                padding: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: listTopPadding,
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                indicatorBuilder: (context, status) {
                  final errorMessage = listSourceRepository.lastErrorMessage;

                  IndicatorStatus actualStatus = status;
                  if (errorMessage != null &&
                      errorMessage.isNotEmpty &&
                      status == IndicatorStatus.empty &&
                      listSourceRepository.isEmpty) {
                    actualStatus = IndicatorStatus.fullScreenError;
                  }

                  final bool isFullScreenIndicator =
                      actualStatus == IndicatorStatus.fullScreenBusying ||
                      actualStatus == IndicatorStatus.fullScreenError ||
                      actualStatus == IndicatorStatus.empty;

                  return buildIndicator(
                    context,
                    actualStatus,
                    () => listSourceRepository.errorRefresh(),
                    emptyIcon: Icons.forum_outlined,
                    paddingTop: isFullScreenIndicator ? listTopPadding : 0,
                    errorMessage: errorMessage,
                    skeletonLayoutConfig: SkeletonLayoutConfig.fromDelegate(
                      waterfallDelegate,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    });
  }

  void _showCreateThreadDialog(BuildContext context, String categoryId) {
    UserService userService = Get.find<UserService>();
    if (!userService.isAuthenticated) {
      AppService.switchGlobalDrawer();
      showGlassToast(t.errors.pleaseLoginFirst, type: GlassToastType.warning);
      return;
    }
    showAppDialog(
      ForumPostDialog(
        onSubmit: () {
          listSourceRepository.refresh();
        },
        initCategoryId: categoryId,
      ),
    );
  }

  void _navigateToThreadDetail(ForumThreadModel thread) {
    NaviService.navigateToForumThreadDetailPage(
      widget.categoryId,
      thread.id,
      initialThread: thread,
    );
  }
}
