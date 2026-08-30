import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/tag_localization_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_gallery_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_video_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_filter_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 标签媒体列表页面（`/tag_videos/:tagId`、`/tag_galleries/:tagId`）。
///
/// 版式走 `GlassHeaderOverlay` 悬浮 header，**只有一行**：
///
///     [返回] [? 标签名 ————] [排序 ▾] [ 筛选 │ ⋮ ]
///
/// 列表铺满整页、靠 `paddingTop` 让出 header 从它背后滚过。
///
/// 与热门列表页（`PopularMediaListPageBase`）的三处差别都是这一页的性质决定的：
/// - 标签是路由参数（这一页就是看这个标签的），筛选抽屉里标签锁定不可改；
/// - header 中间那只胶囊写的是标签名，点按开的是标签详情弹窗（原文 / 译文 /
///   复制 / 纠错），不是通用的「完整标题」弹窗；
/// - ⛔ **排序不占一整行**：热门页拿排序当页面主轴（那一页就是来挑排序的），
///   这一页的主轴是「这个标签」，排序只是个筛法。所以它是一枚
///   `GlassAdaptiveSegmentedControl(dropdownOnly: true)` 的「当前是谁 ▾」胶囊，
///   跟右边的动作胶囊一起靠右站，中间 8px 正是融合层标定的距离
///   （见 `GlassHeaderOverlay` 的配方）。分段那份「跟手」没有丢——牌面接
///   `TabController.animation`，横滑 `TabBarView` 时字跟着手指一格一格翻。
class TagMediaListPage extends StatefulWidget {
  final Tag tag;
  final MediaType mediaType;

  const TagMediaListPage({
    super.key,
    required this.tag,
    required this.mediaType,
  });

  @override
  State<TagMediaListPage> createState() => _TagMediaListPageState();
}

class _TagMediaListPageState extends State<TagMediaListPage>
    with SingleTickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;

  late PopularMediaListController _mediaListController;
  final Map<SortId, BaseMediaRepository> _repositories = {};
  final Map<SortId, BaseMediaController> _controllers = {};

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  /// 分段胶囊读的当前页序号。用 Rx 而不是在 TabController 监听里 setState：
  /// 监听每帧都响，setState 会把整页跟着重建一遍，而胶囊的跟手高亮本来就由
  /// `progress`（TabController.animation）自己插值。
  final RxInt _currentTabIndex = 0.obs;

  /// 这一页所有 GetX 实例的 tag 前缀。
  String get _baseTag =>
      'tag_${widget.mediaType.name.toLowerCase()}_list_${widget.tag.id}';

  bool get _isGallery => widget.mediaType == MediaType.IMAGE;

  /// header 胶囊上写的标签名：优先本地词库译名，没有译名时就是原始 key。
  String get _tagDisplayName =>
      TagLocalizationService.displayName(widget.tag.id);

  @override
  void initState() {
    super.initState();

    // 设置初始标签
    tags = [widget.tag];

    final String baseTag = _baseTag;

    // 初始化控制器
    _mediaListController = Get.put(PopularMediaListController(), tag: baseTag);
    // 这一页没有可折叠的 header 行（header 是悬浮的）
    _mediaListController.configureHeaderExtent(0);

    for (var sort in sorts) {
      final String controllerTag = '${baseTag}_${sort.id.name}';
      late BaseMediaController controller;
      if (_isGallery) {
        controller = Get.put(
          PopularGalleryController(sortId: sort.id.name),
          tag: controllerTag,
        );
      } else {
        controller = Get.put(
          PopularVideoController(sortId: sort.id.name),
          tag: controllerTag,
        );
      }
      _controllers[sort.id] = controller;
      _repositories[sort.id] = controller.repository;

      // 为每个控制器设置标签参数
      controller.updateSearchParams(
        searchTagIds: [widget.tag.id],
        searchDate: year,
        searchRating: rating,
      );
    }

    _tabController = TabController(length: sorts.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    final String baseTag = _baseTag;
    Get.delete<PopularMediaListController>(tag: baseTag);

    for (var sort in sorts) {
      final String controllerTag = '${baseTag}_${sort.id.name}';
      if (_isGallery) {
        Get.delete<PopularGalleryController>(tag: controllerTag);
      } else {
        Get.delete<PopularVideoController>(tag: controllerTag);
      }
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  void _onTabChange() {
    _currentTabIndex.value = _tabController.index;
    _mediaListController.setActiveSort(sorts[_tabController.index].id);
  }

  /// 打开右侧「筛选」抽屉。标签是路由参数（这一页就是看这个标签的），锁定不可改，
  /// 只放开年 / 月 / 评级；改动即时生效。
  void _openFilterDrawer() {
    showMediaFilterDrawer(
      context: context,
      tags: tags,
      date: year,
      rating: rating,
      tagsFixed: true,
      onChanged: (_, newDate, newRating, _) {
        if (!mounted) return;
        setState(() {
          year = newDate;
          rating = newRating;
        });
        _updateSearchParams();
      },
    );
  }

  /// 当前是否有生效中的筛选（决定筛选入口是否显示小红点）。
  /// 标签不算——它是这一页的身份，不是用户挑上去的条件。
  bool get _hasActiveFilter => year.isNotEmpty || rating.isNotEmpty;

  void _updateSearchParams() {
    for (var sort in sorts) {
      final controller = _controllers[sort.id]!;
      controller.updateSearchParams(
        searchTagIds: tags.map((e) => e.id).toList(),
        searchDate: year,
        searchRating: rating,
      );
    }
    _mediaListController.refreshPageUI();
  }

  void _tryRefreshCurrentSort() {
    if (mounted) {
      var sortId = sorts[_tabController.index].id;
      var repository = _repositories[sortId];
      if (!_mediaListController.isPaginated.value) {
        repository?.refresh(true);
      } else {
        _mediaListController.refreshPageUI();
      }
    }
  }

  // ------------------------------------------------------ 「接着看」数据源投递

  /// 这一栏**真正发出去的那份查询**（排序 + 这个标签 + 年月 + 评级）。
  ///
  /// 交给详情页之后，「接着看」的来源池就不再是一份到底就没了的快照，而是顺着
  /// 同一份查询一直翻下去（见 [MediaListQuery] / `RemoteListPlaybackQueue`）。
  ///
  /// ⛔ 参数从仓库的 [BaseMediaRepository.buildQueryParams] 上取，**不在这里
  /// 重拼一份**：筛选状态住在仓库里（`updateSearchParams`），页面这边的
  /// `tags/year/rating` 只是抽屉的回填值，两者在"抽屉改了但还没提交"的那一刻
  /// 是不一样的。重拼出来的池就不是用户正在看的那份列表了（与热门列表页同源）。
  MediaListQuery? _listQueryFor(SortId sortId) {
    final repository = _repositories[sortId];
    if (repository == null) return null;
    return MediaListQuery.pruned(
      mediaType: _isGallery
          ? PlaybackMediaType.gallery
          : PlaybackMediaType.video,
      params: repository.buildQueryParams(0, 20),
    );
  }

  /// 图库卡片的池引用：与视频那条走同一份查询，只是图库没有
  /// `innerPlaylistContext` 这条通道，改由列表页自己把池登记好、只传一个 ref。
  PlaybackQueueRef? _galleryQueueRef(SortId sortId, String galleryId) {
    final query = _listQueryFor(sortId);
    if (query == null) return null;
    final repository = _repositories[sortId];
    final seed = <InnerPlaylistItemSnapshot>[
      if (repository != null)
        for (final item in repository)
          if (item is ImageModel) InnerPlaylistItemSnapshot.fromGallery(item),
    ];
    return PlaybackQueueRef(
      queueId: PlaybackQueueService.to
          .openRemoteList(query, seed: seed)
          .queueId,
      currentItemId: galleryId,
    );
  }

  /// 从标签列表点开一条视频：把这一栏的查询与已加载的条目一起交出去，详情页的
  /// 「接着看」于是落在**这个标签的这一种排序**上，而不是空着。
  ///
  /// [sortId] 由各栏自己的闭包捕获，不读 `_tabController.index`——TabBarView 会
  /// 把左右邻栏一起挂着，拿"当前页序号"去查询在邻栏还留着手指时是错的。
  Future<void> _openVideoFromTagList({
    required SortId sortId,
    required String videoId,
    required List<Video> loadedVideos,
    Map<String, dynamic>? extData,
  }) async {
    Video? initialVideoInfo;
    for (final video in loadedVideos) {
      if (video.id == videoId) {
        initialVideoInfo = video;
        break;
      }
    }

    final playlistContext = InnerPlaylistContext.fromVideos(
      source: InnerPlaylistSource.tagMediaList,
      videos: loadedVideos,
      currentVideoId: videoId,
      query: _listQueryFor(sortId),
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }

  // ------------------------------------------------------------------ chrome

  static const String _menuActionTagInfo = 'tag_info';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';

  void _handleTopBarMenuAction(String action) {
    switch (action) {
      case _menuActionTagInfo:
        showTagDetailDialog(context, widget.tag);
        break;
      case _menuActionRefresh:
        _tryRefreshCurrentSort();
        break;
      case _menuActionScrollTop:
        _mediaListController.scrollToTop();
        break;
      case _menuActionTogglePagination:
        if (!_mediaListController.isPaginated.value) {
          _repositories[sorts[_tabController.index].id]?.refresh(true);
        }
        _mediaListController.setPaginatedMode(
          !_mediaListController.isPaginated.value,
        );
        break;
    }
  }

  List<GlassMenuEntry> _buildTopBarMenuItems() {
    return <GlassMenuEntry>[
      GlassMenuOption<String>(
        value: _menuActionTagInfo,
        icon: Icons.help_outline,
        label: t.common.tagInfo,
      ),
      GlassMenuOption<String>(
        value: _menuActionRefresh,
        icon: Icons.refresh,
        label: t.common.refresh,
      ),
      GlassMenuOption<String>(
        value: _menuActionScrollTop,
        icon: Icons.vertical_align_top,
        label: t.common.scrollToTop,
      ),
      const GlassMenuSeparator(),
      GlassMenuOption<String>(
        value: _menuActionTogglePagination,
        icon: _mediaListController.isPaginated.value
            ? Icons.grid_view
            : Icons.view_stream,
        label: _mediaListController.isPaginated.value
            ? t.common.pagination.waterfall
            : t.common.pagination.pagination,
      ),
    ];
  }

  /// 右侧动作胶囊：筛选（生效时带红点）· 更多。
  Widget _buildActionGroup(BuildContext context) {
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: t.searchFilter.filterSettings,
          showBadge: _hasActiveFilter,
          onPressed: _openFilterDrawer,
        ),
        Builder(
          builder: (anchorContext) => GlassIconButton(
            icon: const Icon(Icons.more_vert),
            // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到
            // 某一条上松手选中（见 GlassTapArea.opensOverlay）。
            opensOverlay: true,
            onPressed: () async {
              final action = await showGlassMenu<String>(
                anchorContext: anchorContext,
                entries: _buildTopBarMenuItems(),
                touchFlex: true,
              );
              if (action != null) _handleTopBarMenuAction(action);
            },
          ),
        ),
      ],
    );
  }

  /// 排序胶囊：「当前是谁 ▾」，点开是五档排序的菜单。
  ///
  /// 恒下拉（`dropdownOnly`）而不是平铺分段——理由见类注释。牌面接
  /// `TabController.animation`，横滑 `TabBarView` 时跟着手指翻。
  ///
  /// 顺带解掉了原先「排序必须另起一行」的那条约束：平铺分段的果冻指示器是一只
  /// 嵌套透镜，进 header 的融合层会被照亮（见 `GlassBlendGroup.isInside`），
  /// 下拉钮没有这只透镜，于是可以和动作胶囊同层站着。
  Widget _buildSortPill(BuildContext context) {
    return Obx(
      () => GlassAdaptiveSegmentedControl(
        dropdownOnly: true,
        selectedIndex: _currentTabIndex.value,
        progress: _tabController.animation,
        onChanged: _tabController.animateTo,
        items: [
          for (final sort in sorts)
            GlassSegmentItem(label: sort.label, icon: sort.icon),
        ],
      ),
    );
  }

  /// header 行：返回圆钮 / 标签胶囊 / 排序胶囊 / 动作胶囊。
  ///
  /// 标签胶囊吃掉中间所有余量，排序与动作两块贴着右边——右边这一坨是「对这一
  /// 堆东西怎么看、怎么筛」，读起来是一组。
  Widget _buildHeaderRow(BuildContext context) {
    return Padding(
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
          Expanded(
            child: GlassTitlePill(
              title: _tagDisplayName,
              // 图标说的是「点了会怎样」——和右边菜单里那条「标签信息」是同一个
              // 动作，所以用同一枚图标。
              icon: Icons.help_outline,
              // 点它开的是标签详情（原文 / 译文 / 复制 / 纠错）而不是通用的
              // 「完整标题」弹窗——这只胶囊写的是一个实体，不是一段正文标题。
              onTap: () => showTagDetailDialog(context, widget.tag),
            ),
          ),
          const SizedBox(width: 8),
          _buildSortPill(context),
          const SizedBox(width: 8),
          _buildActionGroup(context),
        ],
      ),
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Obx(() {
      final visible = _mediaListController.currentScrollOffset.value > 800;
      return Positioned(
        right: 16,
        bottom:
            computeBottomSafeInset(MediaQuery.of(context)) +
            16 +
            (_mediaListController.isPaginated.value
                ? PaginationBar.barHeight
                : 0),
        child: GlassReveal(
          visible: visible,
          builder: (context, m) => GlassIconButton(
            materialize: m,
            standalone: true,
            icon: const Icon(Icons.vertical_align_top),
            tooltip: t.common.scrollToTop,
            onPressed: _mediaListController.scrollToTop,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    // 单行 chrome：排序已经并进 header 行，蒙层与列表让位都只算这一行。
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        // header 与浮层 chrome 走真折射透镜，列表本体留在传统档
        // （见 GlassHeaderOverlay.liquid）。
        liquid: true,
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        header: _buildHeaderRow(context),
        extra: [_buildScrollToTopFab(context)],
        // 视口必须铺满整页（不能在外面套 Padding，否则内容会在 header 下边缘被
        // 裁掉、永远滚不到 header 背后）；留白交给列表自身的 paddingTop。
        body: Obx(() {
          final isPaginated = _mediaListController.isPaginated.value;
          final rebuildKey = _mediaListController.rebuildKey.value.toString();

          return TabBarView(
            controller: _tabController,
            children: sorts.map((sort) {
              if (_isGallery) {
                return MediaTabView<ImageModel>(
                  key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                  sortId: sort.id,
                  repository:
                      _repositories[sort.id]!
                          as BaseMediaRepository<ImageModel>,
                  emptyIcon: Icons.photo_library_outlined,
                  isPaginated: isPaginated,
                  rebuildKey: rebuildKey,
                  paddingTop: headerExtent,
                  mediaListController: _mediaListController,
                  showBottomPadding: true,
                  playbackQueueRefBuilder: (galleryId) =>
                      _galleryQueueRef(sort.id, galleryId),
                );
              }
              return MediaTabView<Video>(
                key: ValueKey('${sort.id}_$isPaginated$rebuildKey'),
                sortId: sort.id,
                repository:
                    _repositories[sort.id]! as BaseMediaRepository<Video>,
                emptyIcon: Icons.video_library_outlined,
                isPaginated: isPaginated,
                rebuildKey: rebuildKey,
                paddingTop: headerExtent,
                mediaListController: _mediaListController,
                showBottomPadding: true,
                onOpenVideo:
                    ({
                      required videoId,
                      required loadedVideos,
                      Map<String, dynamic>? extData,
                    }) => _openVideoFromTagList(
                      sortId: sort.id,
                      videoId: videoId,
                      loadedVideos: loadedVideos,
                      extData: extData,
                    ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}
