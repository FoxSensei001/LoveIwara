import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/models/media_list_query.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/downloads_library_sync_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';

import 'package:i_iwara/app/models/sort.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/saved_search_config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/popular_media_list_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_tab_view.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_filter_drawer.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/saved_search_config_drawer.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' show t;
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:flutter/rendering.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/base_media_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/local_media_list_repository.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/local_image_folder_list_repository.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/horizontial_image_list.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/photo_view_wrapper_overlay.dart';
import 'package:i_iwara/app/ui/widgets/identity_avatar_button.dart';
import 'package:i_iwara/app/ui/widgets/search_mode_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/scroll_to_top_fab.dart';

// 定义抽象基类，包含泛型 T (媒体模型), C (特定媒体控制器), R (特定媒体仓库)
abstract class PopularMediaListPageBase<
  T,
  C extends GetxController,
  R extends LoadingMoreBase<T>
>
    extends StatefulWidget
    implements HomeWidgetInterface {
  final String controllerTag;
  final SearchSegment searchSegment;
  final IconData emptyIcon;
  final int contentResetVersion;

  const PopularMediaListPageBase({
    super.key,
    required this.controllerTag,
    required this.searchSegment,
    required this.emptyIcon,
    this.contentResetVersion = 0,
  });

  // 抽象方法，由子类实现以创建特定的 Controller
  C createSpecificController(String sortIdName);

  // 抽象方法，由子类实现以获取特定的 Repository
  R getSpecificRepository(C controller);

  // 类静态变量，用于保存所有已创建的state实例的引用
  static final Map<String, PopularMediaListPageBaseState> stateInstances = {};

  // 通用的refreshCurrent实现，子类可以直接调用此方法
  void refreshCurrentImpl() {
    // 通过controllerTag查找对应的state
    final state = stateInstances[controllerTag];
    if (state != null && state.mounted) {
      state.refreshOnReselect();
    }
  }
}

// 基类的 State - 移除下划线，设为公开
class PopularMediaListPageBaseState<
  T,
  C extends GetxController,
  R extends LoadingMoreBase<T>,
  W extends PopularMediaListPageBase<T, C, R>
>
    extends State<W>
        // ⛔ 必须是多 ticker 版。来源切换（线上 3 档 ⇄ 本机 6 档）会**换掉整只
        // TabController**（[_replaceTabController]），而 [SingleTickerProviderStateMixin]
        // 一个 State 只许要一根 ticker：第二次 `TabController(vsync: this)` 直接抛
        // 「multiple tickers were created」。那一抛发生在 [_selectLocalSource] 中途，
        // 于是它后面的 [_replaceLocalRepositories] 再也没跑到，
        // `_localRepositories[sortId]!` 当场 null → **整面墙变成红色报错页**。
        // （真机实证 2026-09-10：切到任意本机来源 100% 复现；`dart analyze` 看不出来，
        // 它是运行时断言。）
        with
        TickerProviderStateMixin {
  final List<Sort> sorts = CommonConstants.mediaSorts;
  late TabController _tabController;

  late PopularMediaListController _mediaListController;
  late BatchSelectController<T> _batchSelectController;
  final UserService userService = Get.find<UserService>();

  /// 用于打开右侧「已保存筛选」抽屉。

  /// 已保存筛选的存储池：热门视频/图库与订阅页共用同一份配置。
  String get _segmentKey => SavedSearchConfigService.sharedSegment;

  final Map<SortId, R> _repositories = {};
  final Map<SortId, C> _controllers = {};

  /// 视频页的本机来源状态。图库页继续使用线上列表，不创建这些池。
  final LocalMediaRepository _localMediaRepository = LocalMediaRepository();
  final List<LocalMediaSort> _localSorts = const <LocalMediaSort>[
    LocalMediaSort.addedDesc,
    LocalMediaSort.playedDesc,
    LocalMediaSort.nameAsc,
    LocalMediaSort.durationDesc,
    LocalMediaSort.sizeDesc,
    LocalMediaSort.folderAsc,
  ];
  final List<SortId> _localSortIds = const <SortId>[
    SortId.localAdded,
    SortId.localPlayed,
    SortId.localName,
    SortId.localDuration,
    SortId.localSize,
    SortId.localFolder,
  ];
  final List<LocalImageFolderSort> _localImageFolderSorts =
      const <LocalImageFolderSort>[
        LocalImageFolderSort.addedDesc,
        LocalImageFolderSort.nameAsc,
        LocalImageFolderSort.countDesc,
      ];
  final List<SortId> _localImageFolderSortIds = const <SortId>[
    SortId.localAdded,
    SortId.localName,
    SortId.localCount,
  ];
  List<SortId> get _activeLocalSortIds =>
      T == ImageModel ? _localImageFolderSortIds : _localSortIds;
  List<LocalMediaSource> _localSources = const <LocalMediaSource>[];
  final Map<SortId, LocalMediaListRepository> _localRepositories = {};
  final Map<SortId, LocalImageFolderListRepository>
  _localImageFolderRepositories = {};
  String? _localSourceId;
  String? _localCategoryId;
  bool _isLocalSource = false;
  Worker? _localScanWorker;
  Worker? _localMediaChangeWorker;
  Worker? _localScrollSettleWorker;

  /// 有过一次「库变了、但用户正滚在半空」的刷新被推迟了，等他自己回到顶部再补。
  bool _pendingLocalWallRefresh = false;

  /// 视作「还在顶部」的余量：这点位移内做破坏性刷新，用户看不出被弹回。
  static const double _kLocalWallTopSlack = 120.0;

  List<Tag> tags = [];
  String year = '';
  String rating = '';

  // Current tab index for segmented control / dropdown sync
  final RxInt _currentTabIndex = 0.obs;

  void tryRefreshCurrentSort() {
    if (mounted) {
      if (_isLocalSource) {
        _refreshActiveLocalRepository();
        return;
      }
      var sortId = sorts[_tabController.index].id;
      var repository = _repositories[sortId];
      if (!_mediaListController.isPaginated.value) {
        repository?.refresh(true);
      } else {
        _mediaListController.refreshPageUI();
      }
    }
  }

  /// 再次点击当前栏目时触发：当前子 tab 回到顶部并重新加载，
  /// 已访问过的其他子 tab 也一并刷新。
  void refreshOnReselect() {
    if (!mounted) return;
    // 重置头部折叠状态并把当前列表滚动到顶部
    _mediaListController.scrollToTop();

    if (_isLocalSource) {
      _refreshActiveLocalRepository();
      return;
    }

    final activeSortId = _activeTabId();
    if (_mediaListController.isPaginated.value) {
      // 分页模式：当前子 tab 立即重建并重新加载第 0 页（MediaListView.initState 会触发），
      // 其他已访问子 tab 标记为待刷新（下次切换到它时重建并重载）。
      _mediaListController.invalidateLoadedSorts(activeSortId: activeSortId);
    } else {
      // 瀑布流模式：仓库实例是持久复用的，仅重建 Widget 不会重新请求，
      // 因此直接对所有已加载子 tab 的仓库执行刷新（当前 tab 就地更新）。
      for (final sortId in _mediaListController.loadedSorts) {
        _repositories[sortId]?.refresh(true);
      }
    }
  }

  // 打开搜索页面
  void _openSearchDialog() {
    NaviService.navigateToSearchPage(initialSegment: widget.searchSegment);
  }

  /// 这一栏**真正发出去的那份查询**（排序 + 标签 + 年月 + 评级）。
  ///
  /// 交给详情页之后，「接着看」的来源池就不再是一份到底就没了的快照，而是顺着
  /// 同一份查询一直翻下去（见 [MediaListQuery] / `RemoteListPlaybackQueue`）。
  ///
  /// ⛔ 参数从仓库的 [BaseMediaRepository.buildQueryParams] 上取，**不在这里
  /// 重拼一份**：筛选状态住在仓库里（`updateSearchParams`），页面这边的
  /// `tags/year/rating` 只是抽屉的回填值，两者在"抽屉改了但还没提交"的那一刻
  /// 是不一样的。重拼出来的池就不是用户正在看的那份列表了。
  MediaListQuery? _listQueryFor(SortId sortId) {
    final repository = _repositories[sortId];
    if (repository is! BaseMediaRepository<T>) return null;
    return MediaListQuery.pruned(
      mediaType: T == ImageModel
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

  Future<void> _openVideoFromPopularList({
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
      source: InnerPlaylistSource.popularVideoList,
      videos: loadedVideos,
      currentVideoId: videoId,
      query: _listQueryFor(sorts[_tabController.index].id),
    );

    await NaviService.navigateToVideoDetailPage(
      videoId,
      extData: extData,
      innerPlaylistContext: playlistContext,
      initialVideoInfo: initialVideoInfo,
    );
  }

  bool get _supportsLocalSource => T == Video || T == ImageModel;

  void _refreshLocalSources() {
    if (!_supportsLocalSource) return;
    final sources = _localMediaRepository.getSources();
    final activeStillExists =
        _localSourceId == null ||
        sources.any((source) => source.id == _localSourceId);
    final wasLocalSource = _isLocalSource;
    final previousIndex = _tabController.index;
    final activeSourceWasRemoved = wasLocalSource && !activeStillExists;
    if (activeSourceWasRemoved) {
      _isLocalSource = false;
      _localSourceId = null;
      _localCategoryId = null;
      _disposeLocalRepositories();
    }
    if (!mounted) return;
    setState(() => _localSources = sources);
    if (activeSourceWasRemoved) {
      _replaceTabController(
        length: sorts.length,
        initialIndex: previousIndex.clamp(0, sorts.length - 1).toInt(),
      );
    }
  }

  Future<void> _syncLocalDownloads() async {
    if (!_supportsLocalSource ||
        !Get.isRegistered<DownloadsLibrarySyncService>()) {
      return;
    }
    await DownloadsLibrarySyncService.to.sync();
    _refreshLocalSources();
    if (_isLocalSource) _refreshActiveLocalRepository();
  }

  void _onLocalScanProgress(LocalMediaScanProgress? progress) {
    if (!mounted || !_supportsLocalSource || progress == null) return;
    // ⛔ 这个信号是**每批**推一次的（`local_media_scan_service.dart` 的批处理循环 /
    // MediaStore 每页 400 条各一次）。源那一行的 scan_state / item_count 只在
    // 开扫与扫完时变，中途每批都重查一次库是白花的 UI 线程时间。
    if (progress.finished) _refreshLocalSources();
    if (_isLocalSource && progress.sourceId == _localSourceId) {
      _requestLocalWallRefresh();
    }
  }

  void _onLocalMediaChanged() {
    if (!mounted || !_supportsLocalSource) return;
    _refreshLocalSources();
    if (!_isLocalSource) return;

    final categoryId = _localCategoryId;
    final categoryWasDeleted =
        categoryId != null &&
        categoryId != kLocalMediaUncategorized &&
        Get.isRegistered<DownloadService>() &&
        !DownloadService.to.categories.any(
          (category) => category.id == categoryId,
        );
    if (categoryWasDeleted) {
      // 当前筛选的分类被别处删掉了：这是**结构性**变化，墙上正显示的东西
      // 已经不存在，不能等用户滚回顶部。
      setState(() => _localCategoryId = null);
      _replaceLocalRepositories();
      _requestLocalWallRefresh(immediate: true);
      return;
    }
    _requestLocalWallRefresh();
  }

  /// ⭐ 本机墙**唯一**的「该重新拉一次了」入口。
  ///
  /// ⛔ 背后是 `LoadingMoreBase.refresh(true)`，它是**破坏性**的：清空列表、
  /// 重拉第 0 页、滚动位置复位。而触发它的两个信号——扫描进度、库变更 revision
  /// ——都是**后台**发生的，用户很可能正滚在半空看别的东西：
  ///
  /// - 扫一个两万条的目录，每批推一次进度 ⇒ 墙每隔几百毫秒弹回顶部一次；
  /// - 后台下完一个片子入库、派生服务回填一次封面，同理。
  ///
  /// 所以规矩是：**用户自己触发的（换来源/换排序/换分类/下拉刷新）立即刷；
  /// 后台触发的只在"用户本来就在顶部"时刷，否则记账，等他自己滚回顶部再补。**
  /// 滚在半空的人永远不会被弹走。
  void _requestLocalWallRefresh({bool immediate = false}) {
    if (!mounted || !_isLocalSource) return;
    if (immediate ||
        _mediaListController.currentScrollOffset.value <= _kLocalWallTopSlack) {
      _pendingLocalWallRefresh = false;
      _refreshActiveLocalRepository();
      return;
    }
    _pendingLocalWallRefresh = true;
  }

  /// 滚动停下来之后才判定，避免在惯性滑行**经过**顶部的那一帧上重拉。
  void _onLocalScrollSettled(double offset) {
    if (!mounted || !_pendingLocalWallRefresh || !_isLocalSource) return;
    if (offset > _kLocalWallTopSlack) return;
    _pendingLocalWallRefresh = false;
    _refreshActiveLocalRepository();
  }

  void _disposeLocalRepositories() {
    for (final repository in _localRepositories.values) {
      repository.dispose();
    }
    _localRepositories.clear();
    for (final repository in _localImageFolderRepositories.values) {
      repository.dispose();
    }
    _localImageFolderRepositories.clear();
  }

  void _replaceLocalRepositories() {
    _disposeLocalRepositories();
    final sourceId = _localSourceId;
    if (!_isLocalSource || sourceId == null) return;
    if (T == ImageModel) {
      for (var index = 0; index < _localImageFolderSorts.length; index++) {
        _localImageFolderRepositories[_localImageFolderSortIds[index]] =
            LocalImageFolderListRepository(
              sourceId: sourceId,
              sortOrder: _localImageFolderSorts[index],
              repository: _localMediaRepository,
            );
      }
      return;
    }
    for (var index = 0; index < _localSorts.length; index++) {
      _localRepositories[_localSortIds[index]] = LocalMediaListRepository(
        sourceId: sourceId,
        sortOrder: _localSorts[index],
        categoryId: _localCategoryId,
        repository: _localMediaRepository,
      );
    }
  }

  /// 本机墙那一档排序对应的池。**取不到就当场建一个**，绝不 `!`。
  ///
  /// ⛔ 这里原来是 `_localRepositories[sortId]!`。池是在 [_selectLocalSource] 里
  /// 一次性铺好的，而那条链路中间**曾经**会抛（见类声明上的 ticker 那条注释）——
  /// 一抛，池就没铺完，`!` 把「少了一个池」放大成「整面墙红屏」。构造这个池
  /// 是纯内存操作、不碰 IO，兜底建一个远比崩掉便宜。
  LocalMediaListRepository _localRepositoryFor(SortId sortId) {
    final existing = _localRepositories[sortId];
    if (existing != null) return existing;
    final index = _localSortIds.indexOf(sortId);
    final created = LocalMediaListRepository(
      sourceId: _localSourceId ?? '',
      sortOrder: _localSorts[index < 0 ? 0 : index],
      categoryId: _localCategoryId,
      repository: _localMediaRepository,
    );
    _localRepositories[sortId] = created;
    return created;
  }

  LocalImageFolderListRepository _localImageFolderRepositoryFor(SortId sortId) {
    final existing = _localImageFolderRepositories[sortId];
    if (existing != null) return existing;
    final index = _localImageFolderSortIds.indexOf(sortId);
    final created = LocalImageFolderListRepository(
      sourceId: _localSourceId ?? '',
      sortOrder: _localImageFolderSorts[index < 0 ? 0 : index],
      repository: _localMediaRepository,
    );
    _localImageFolderRepositories[sortId] = created;
    return created;
  }

  void _refreshActiveLocalRepository() {
    _pendingLocalWallRefresh = false;
    if (T == ImageModel) {
      if (_tabController.index < _localImageFolderSortIds.length) {
        final repository =
            _localImageFolderRepositories[_localImageFolderSortIds[_tabController
                .index]];
        repository?.refresh(true);
      }
      return;
    }
    final repository = _localRepositories[_localSortIds[_tabController.index]];
    repository?.refresh(true);
  }

  SortId _activeTabId() {
    if (!_isLocalSource) return sorts[_tabController.index].id;
    final activeIds = _activeLocalSortIds;
    final safeIndex = _tabController.index.clamp(0, activeIds.length - 1);
    return activeIds[safeIndex];
  }

  void _replaceTabController({required int length, int initialIndex = 0}) {
    final int safeIndex = initialIndex.clamp(0, length - 1).toInt();
    if (_tabController.length == length) {
      _tabController.index = safeIndex;
      return;
    }
    _tabController
      ..removeListener(_onTabChange)
      ..dispose();
    _tabController = TabController(
      length: length,
      initialIndex: safeIndex,
      vsync: this,
    )..addListener(_onTabChange);
    _currentTabIndex.value = _tabController.index;
    _mediaListController.setActiveSort(_activeTabId());
  }

  void _selectLocalSource(int index) {
    if (!_supportsLocalSource) return;
    if (index == 0) {
      if (!_isLocalSource) return;
      final previousIndex = _tabController.index;
      setState(() {
        _isLocalSource = false;
        _localSourceId = null;
        _batchSelectController.exitMultiSelect();
      });
      _disposeLocalRepositories();
      _replaceTabController(
        length: sorts.length,
        initialIndex: previousIndex.clamp(0, sorts.length - 1).toInt(),
      );
      return;
    }
    final sourceIndex = index - 1;
    if (sourceIndex < _localSources.length) {
      final source = _localSources[sourceIndex];
      final enteringLocal = !_isLocalSource;
      final previousIndex = _tabController.index;
      setState(() {
        _isLocalSource = true;
        _localSourceId = source.id;
        _localCategoryId = null;
        _batchSelectController.exitMultiSelect();
      });
      final localSortCount = _activeLocalSortIds.length;
      _replaceTabController(
        length: localSortCount,
        initialIndex: enteringLocal
            ? 0
            : previousIndex.clamp(0, localSortCount - 1),
      );
      _replaceLocalRepositories();
      return;
    }
    _openLocalSourceManager();
  }

  Future<void> _openLocalSourceManager() async {
    await NaviService.navigateToLocalMediaSourcesPage();
    _refreshLocalSources();
  }

  String _localSortAction(LocalMediaSort sort) => 'local_sort_${sort.name}';

  String _localSortLabel(LocalMediaSort sort) {
    final local = t.localMedia;
    return switch (sort) {
      LocalMediaSort.addedDesc => local.sortRecentlyAdded,
      LocalMediaSort.playedDesc => local.sortRecentlyPlayed,
      LocalMediaSort.nameAsc => local.sortName,
      LocalMediaSort.durationDesc => local.sortDuration,
      LocalMediaSort.sizeDesc => local.sortSize,
      LocalMediaSort.folderAsc => local.sortFolder,
      LocalMediaSort.modifiedDesc => local.sortRecentlyModified,
    };
  }

  IconData _localSortIcon(LocalMediaSort sort) => switch (sort) {
    LocalMediaSort.addedDesc => Icons.schedule_outlined,
    LocalMediaSort.playedDesc => Icons.history_outlined,
    LocalMediaSort.nameAsc => Icons.sort_by_alpha,
    LocalMediaSort.durationDesc => Icons.timelapse_outlined,
    LocalMediaSort.sizeDesc => Icons.storage_outlined,
    LocalMediaSort.folderAsc => Icons.folder_outlined,
    LocalMediaSort.modifiedDesc => Icons.update_outlined,
  };

  String _localImageFolderSortAction(LocalImageFolderSort sort) =>
      'local_image_sort_${sort.name}';

  String _localImageFolderSortLabel(LocalImageFolderSort sort) {
    final local = t.localMedia;
    return switch (sort) {
      LocalImageFolderSort.addedDesc => local.sortRecentlyAdded,
      LocalImageFolderSort.nameAsc => local.sortName,
      LocalImageFolderSort.countDesc => local.sortCount,
    };
  }

  IconData _localImageFolderSortIcon(LocalImageFolderSort sort) =>
      switch (sort) {
        LocalImageFolderSort.addedDesc => Icons.schedule_outlined,
        LocalImageFolderSort.nameAsc => Icons.sort_by_alpha,
        LocalImageFolderSort.countDesc => Icons.format_list_numbered,
      };

  void _selectSortIndex(int index) {
    final count = _isLocalSource ? _activeLocalSortIds.length : sorts.length;
    if (index < 0 || index >= count) return;
    _tabController.animateTo(index);
  }

  List<GlassSegmentItem> _sourceItems() {
    final local = t.localMedia;
    return <GlassSegmentItem>[
      GlassSegmentItem(
        label: local.sourceOnline,
        icon: const Icon(Icons.cloud_outlined),
      ),
      for (final source in _localSources)
        GlassSegmentItem(
          label: source.displayName,
          icon: Icon(
            source.isBuiltIn
                ? Icons.download_outlined
                : Icons.folder_open_outlined,
          ),
        ),
      GlassSegmentItem(
        label: _localSources.isEmpty ? local.addFolder : local.manageSources,
        icon: Icon(
          _localSources.isEmpty
              ? Icons.create_new_folder_outlined
              : Icons.settings_outlined,
        ),
      ),
    ];
  }

  int get _selectedSourceIndex {
    if (!_isLocalSource || _localSourceId == null) return 0;
    final index = _localSources.indexWhere(
      (source) => source.id == _localSourceId,
    );
    return index < 0 ? 0 : index + 1;
  }

  Widget _buildSourceControl() {
    return GlassAdaptiveSegmentedControl(
      key: ValueKey('${_selectedSourceIndex}_${_localSources.length}'),
      items: _sourceItems(),
      selectedIndex: _selectedSourceIndex,
      dropdownOnly: true,
      onChanged: _selectLocalSource,
    );
  }

  String _localCategoryLabel() {
    final categoryId = _localCategoryId;
    if (categoryId == null) return t.common.all;
    if (categoryId == kLocalMediaUncategorized) {
      return t.localMedia.uncategorized;
    }
    if (!Get.isRegistered<DownloadService>()) return t.common.all;
    return DownloadService.to.categories
            .firstWhereOrNull((category) => category.id == categoryId)
            ?.title ??
        t.common.all;
  }

  Future<void> _pickLocalCategory(BuildContext anchorContext) async {
    final sourceId = _localSourceId;
    if (sourceId == null || !anchorContext.mounted) return;
    final categories = Get.isRegistered<DownloadService>()
        ? DownloadService.to.categories.toList()
        : const [];
    final counts = _localMediaRepository.categoryCounts(sourceId: sourceId);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        GlassMenuOption<String>(
          value: '\u0000all',
          label: t.common.all,
          description:
              '${_localMediaRepository.countItems(sourceId: sourceId)}',
          icon: Icons.apps,
        ),
        GlassMenuOption<String>(
          value: kLocalMediaUncategorized,
          label: t.localMedia.uncategorized,
          description: '${counts.uncategorized}',
          icon: Icons.folder_outlined,
          enabled: counts.uncategorized > 0,
        ),
        for (final category in categories)
          GlassMenuOption<String>(
            value: category.id,
            label: category.title,
            description: '${counts.byCategory[category.id] ?? 0}',
            icon: Icons.folder_outlined,
            enabled: (counts.byCategory[category.id] ?? 0) > 0,
          ),
      ],
    );
    if (!mounted || picked == null) return;
    setState(() {
      _localCategoryId = picked == '\u0000all' ? null : picked;
    });
    _replaceLocalRepositories();
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SavedSearchConfigService>()) {
      Get.put(SavedSearchConfigService(), permanent: true);
    }
    _mediaListController = Get.put(
      PopularMediaListController(),
      tag: widget.controllerTag,
    );
    _batchSelectController = Get.put(
      BatchSelectController<T>(),
      tag: '${widget.controllerTag}_batch',
    );

    // 注册到静态映射中，便于外部访问
    PopularMediaListPageBase.stateInstances[widget.controllerTag] = this;

    for (var sort in sorts) {
      // 使用 widget 的抽象方法创建 Controller
      final controller = widget.createSpecificController(sort.id.name);
      _controllers[sort.id] = controller;
      // 使用 widget 的抽象方法获取 Repository
      _repositories[sort.id] = widget.getSpecificRepository(controller);
    }
    _tabController = TabController(length: sorts.length, vsync: this);
    _tabController.addListener(_onTabChange);
    _mediaListController.setActiveSort(_activeTabId());
    // 不再有可折叠的 header 行
    _mediaListController.configureHeaderExtent(0);

    if (_supportsLocalSource) {
      _refreshLocalSources();
      _localMediaChangeWorker = debounce<int>(
        LocalMediaRepository.changeRevision,
        (_) => _onLocalMediaChanged(),
        time: const Duration(milliseconds: 300),
      );
      _localScrollSettleWorker = debounce<double>(
        _mediaListController.currentScrollOffset,
        _onLocalScrollSettled,
        time: const Duration(milliseconds: 250),
      );
      if (Get.isRegistered<LocalMediaScanService>()) {
        _localScanWorker = ever<LocalMediaScanProgress?>(
          LocalMediaScanService.to.progress,
          _onLocalScanProgress,
        );
      }
      unawaited(_syncLocalDownloads());
    }
  }

  @override
  void dispose() {
    _localMediaChangeWorker?.dispose();
    _localScanWorker?.dispose();
    _localScrollSettleWorker?.dispose();
    _disposeLocalRepositories();
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    Get.delete<PopularMediaListController>(tag: widget.controllerTag);
    Get.delete<BatchSelectController<T>>(tag: '${widget.controllerTag}_batch');

    // 从静态映射中移除
    PopularMediaListPageBase.stateInstances.remove(widget.controllerTag);

    for (var controller in _controllers.values) {
      // 假设 Controller 有 sortId 属性
      Get.delete<C>(tag: (controller as dynamic).sortId);
    }
    _controllers.clear();
    _repositories.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.contentResetVersion != widget.contentResetVersion) {
      _resetForContentChange();
    }
  }

  void _resetForContentChange() {
    tags = [];
    year = '';
    rating = '';

    for (final controller in _controllers.values) {
      if (controller is BaseMediaController) {
        controller.resetState();
      }
    }

    _batchSelectController.exitMultiSelect();

    if (_tabController.index != 0) {
      _tabController.index = 0;
    }
    final activeSortId = _activeTabId();
    _mediaListController.setActiveSort(activeSortId);
    _currentTabIndex.value = 0;
    _mediaListController.invalidateLoadedSorts(activeSortId: activeSortId);
    _mediaListController.resetHeaderState();
    _mediaListController.currentScrollOffset.value = 0.0;
    _mediaListController.lastScrollDirection.value = ScrollDirection.idle;

    if (mounted) {
      setState(() {});
    }
  }

  void setParams({
    List<Tag> tags = const [],
    String year = '',
    String rating = '',
  }) {
    this.tags = tags;
    this.year = year;
    this.rating = rating;

    LogUtils.d(
      '设置查询参数: tags: $tags, year: $year, rating: $rating',
      'PopularMediaListPageBase',
    );

    for (var sort in sorts) {
      var controller = _controllers[sort.id]!;
      // 直接调用 controller 的 updateSearchParams 方法，需要确保 C 类型有这个方法
      // 因为 BaseMediaController 现在是 GetxController 的子类，并且有 updateSearchParams
      // 所以这里的 C 类型（PopularVideoController/PopularGalleryController）也会有这个方法
      if (controller is BaseMediaController) {
        // 类型检查确保安全调用
        (controller as BaseMediaController).updateSearchParams(
          searchTagIds: tags.map((e) => e.id).toList(),
          searchDate: year,
          searchRating: rating,
        );
      } else {
        // 如果你的 Controller 结构更复杂，可能需要不同的处理方式
        LogUtils.w(
          'Controller type mismatch: Expected BaseMediaController but got ${controller.runtimeType}',
          'PopularMediaListPageBase',
        );
      }
    }
    _mediaListController.refreshPageUI();
    // 顶栏的筛选小红点读的是本 State 的字段，refreshPageUI 只动 controller 的
    // Rx，这里必须自己触发一次重建，否则红点要等下一次无关重建才亮/灭。
    if (mounted) {
      setState(() {});
    }
  }

  /// 当前是否有生效中的筛选（决定筛选入口是否显示小红点）。
  bool get _hasActiveFilter =>
      tags.isNotEmpty || year.isNotEmpty || rating.isNotEmpty;

  void _onTabChange() {
    _currentTabIndex.value = _tabController.index;
    _mediaListController.setActiveSort(_activeTabId());
  }

  /// 打开右侧「筛选」抽屉。改动即时生效，抽屉常驻不关。
  void _openFilterDrawer() {
    showMediaFilterDrawer(
      context: context,
      tags: tags,
      date: year,
      rating: rating,
      // 本页的排序是 TabBar，这里不需要抽屉里的排序区，回调的 sortId 恒为 null
      onChanged: (tags, date, rating, _) {
        setParams(tags: tags, year: date, rating: rating);
      },
    );
  }

  /// 打开右侧「已保存筛选」抽屉（独立于筛选抽屉的一份清单，走同一条路由）。
  void _openSavedConfigDrawer() {
    showGlassSideDrawer<void>(
      context: context,
      builder: (drawerContext) => SavedSearchConfigDrawer(
        segment: _segmentKey,
        onApply: (config) {
          Navigator.of(drawerContext).pop();
          _applySavedConfig(config);
        },
        onAddCurrent: () {
          Navigator.of(drawerContext).pop();
          SavedSearchConfigDrawer.promptSaveCurrent(
            segment: _segmentKey,
            tags: tags,
            date: year,
            rating: rating,
          );
        },
      ),
    );
  }

  /// 应用一条已保存的筛选配置。
  void _applySavedConfig(SavedSearchConfig config) {
    setParams(
      tags: List<Tag>.from(config.tags),
      year: config.date,
      rating: config.rating,
    );
  }

  static const String _menuActionOpenSearch = 'open_search';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionToggleBatchSelect = 'toggle_batch_select';
  static const String _menuActionSortPrefix = 'sort_';
  static const String _menuActionLocalSortPrefix = 'local_sort_';
  static const String _menuActionLocalCategory = 'local_category';

  void _handleTopBarMenuAction(String action) {
    if (action.startsWith('local_image_sort_')) {
      final name = action.substring('local_image_sort_'.length);
      final index = _localImageFolderSorts.indexWhere(
        (sort) => sort.name == name,
      );
      _selectSortIndex(index);
      return;
    }
    if (action.startsWith(_menuActionLocalSortPrefix)) {
      final name = action.substring(_menuActionLocalSortPrefix.length);
      final index = _localSorts.indexWhere((sort) => sort.name == name);
      _selectSortIndex(index);
      return;
    }
    if (action.startsWith(_menuActionSortPrefix)) {
      final name = action.substring(_menuActionSortPrefix.length);
      final index = sorts.indexWhere((sort) => sort.id.name == name);
      _selectSortIndex(index);
      return;
    }
    switch (action) {
      case _menuActionLocalCategory:
        _pickLocalCategory(context);
        break;
      case _menuActionOpenSearch:
        _openSearchDialog();
        break;
      case _menuActionRefresh:
        tryRefreshCurrentSort();
        break;
      case _menuActionScrollTop:
        _mediaListController.scrollToTop();
        break;
      case _menuActionTogglePagination:
        _mediaListController.setPaginatedMode(
          !_mediaListController.isPaginated.value,
        );
        break;
      case _menuActionToggleBatchSelect:
        _batchSelectController.toggleMultiSelect();
        break;
    }
  }

  List<GlassMenuEntry> _buildTopBarMenuItems({required bool isWide}) {
    final List<GlassMenuEntry> items = [];

    void addMenuItem({
      required String value,
      required IconData icon,
      required String label,
    }) {
      items.add(
        GlassMenuOption<String>(value: value, icon: icon, label: label),
      );
    }

    // 窄屏的搜索在底部独立圆钮上，宽屏在右侧胶囊里；菜单里再留一个兜底入口。
    if (!isWide) {
      addMenuItem(
        value: _menuActionOpenSearch,
        icon: Icons.search,
        label: t.common.search,
      );
    }
    addMenuItem(
      value: _menuActionRefresh,
      icon: Icons.refresh,
      label: t.common.refresh,
    );
    addMenuItem(
      value: _menuActionScrollTop,
      icon: Icons.vertical_align_top,
      label: t.common.scrollToTop,
    );
    items.add(const GlassMenuSeparator());
    if (_isLocalSource && T != ImageModel) {
      items.add(
        GlassMenuOption<String>(
          value: _menuActionLocalCategory,
          icon: Icons.folder_special_outlined,
          label: t.localMedia.filterByCategory,
          description: _localCategoryLabel(),
        ),
      );
      items.add(const GlassMenuSeparator());
    }
    if (_isLocalSource) {
      if (T == ImageModel) {
        for (var index = 0; index < _localImageFolderSorts.length; index++) {
          final sort = _localImageFolderSorts[index];
          items.add(
            GlassMenuOption<String>(
              value: _localImageFolderSortAction(sort),
              icon: _localImageFolderSortIcon(sort),
              label: _localImageFolderSortLabel(sort),
              selected: index == _tabController.index,
            ),
          );
        }
      } else {
        for (var index = 0; index < _localSorts.length; index++) {
          final sort = _localSorts[index];
          items.add(
            GlassMenuOption<String>(
              value: _localSortAction(sort),
              icon: _localSortIcon(sort),
              label: _localSortLabel(sort),
              selected: index == _tabController.index,
            ),
          );
        }
      }
    } else {
      for (final sort in sorts) {
        items.add(
          GlassMenuOption<String>(
            value: '$_menuActionSortPrefix${sort.id.name}',
            leading: sort.icon,
            label: sort.label,
            selected: sort.id == sorts[_tabController.index].id,
          ),
        );
      }
    }
    // 批量选择：默认只收在菜单里；开启后按钮才会冒到右侧胶囊中，
    // 菜单里的入口同步换成「退出编辑模式」。
    if (!_isLocalSource) {
      items.add(const GlassMenuSeparator());
      addMenuItem(
        value: _menuActionToggleBatchSelect,
        icon: _batchSelectController.isMultiSelect.value
            ? Icons.close
            : Icons.checklist,
        label: _batchSelectController.isMultiSelect.value
            ? t.common.exitEditMode
            : t.common.editMode,
      );
    }
    items.add(const GlassMenuSeparator());
    addMenuItem(
      value: _menuActionTogglePagination,
      icon: _mediaListController.isPaginated.value
          ? Icons.grid_view
          : Icons.view_stream,
      label: _mediaListController.isPaginated.value
          ? t.common.pagination.waterfall
          : t.common.pagination.pagination,
    );
    return items;
  }

  /// 右侧动作胶囊：[搜索(仅宽屏)] 筛选 · 已保存筛选 · [退出批量(多选中才冒出)] 更多。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    return Obx(() {
      final isMultiSelect = _batchSelectController.isMultiSelect.value;
      return GlassButtonGroup(
        // 液态档下整只胶囊接跟手拉伸；宽度会随 isWide/isMultiSelect 动画
        // 过渡，签名变化时 LiquidGlassSettledTouch 会先退回自然布局、
        // 等过渡跑完再重新量出精确宽度并开 touch（见该类说明）。
        touchFlex: true,
        touchFlexSignature: '$isWide|$isMultiSelect',
        children: [
          GlassGroupSlot(
            visible: isWide,
            // 点按进搜索页（本页默认分段），长按挑搜索模式。
            child: SearchActionButton(segment: widget.searchSegment),
          ),
          GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.searchFilter.filterSettings,
            showBadge: _hasActiveFilter,
            onPressed: _openFilterDrawer,
          ),
          GlassIconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: t.savedSearchConfig.title,
            onPressed: _openSavedConfigDrawer,
          ),
          // 批量模式的入口在「更多」菜单里；开启后这里只承担退出职责
          GlassGroupSlot(
            visible: isMultiSelect,
            child: GlassIconButton(
              icon: const Icon(Icons.close),
              tooltip: t.common.exitEditMode,
              onPressed: _batchSelectController.toggleMultiSelect,
            ),
          ),
          Builder(
            builder: (anchorContext) => GlassIconButton(
              icon: const Icon(Icons.more_vert),
              // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
              // 松手选中（见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              onPressed: () async {
                final action = await showGlassMenu<String>(
                  anchorContext: anchorContext,
                  entries: _buildTopBarMenuItems(isWide: isWide),
                  touchFlex: true,
                );
                if (action != null) _handleTopBarMenuAction(action);
              },
            ),
          ),
        ],
      );
    });
  }

  /// 滚过约一屏后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    return Obx(() {
      final visible =
          _mediaListController.currentScrollOffset.value > 800 &&
          !_batchSelectController.isMultiSelect.value;
      return Positioned(
        // 移动端底栏可见时与搜索圆钮中心共轴；宽屏（rail 布局）用普通右边距
        right: isFloatingBarInsetActive(context)
            ? GlassTokens.floatingActionCoAxisRight(GlassTokens.pillHeight)
            : 16,
        // 分页模式下底部固定着分页栏，浮钮要在安全区之上再避开栏体
        bottom:
            MediaQuery.paddingOf(context).bottom +
            16 +
            (_mediaListController.isPaginated.value
                ? PaginationBar.barHeight
                : 0),
        child: ScrollToTopFab(
          visible: visible,
          onPressed: _mediaListController.scrollToTop,
        ),
      );
    });
  }

  Future<void> _openLocalItem(LocalMediaItem item) async {
    if (!item.isPlayableNow) {
      showAppToast(t.localMedia.fileMissing, type: AppToastType.error);
      return;
    }
    final sourceId = _localSourceId;
    PlaybackQueueRef? queueRef;
    if (sourceId != null && Get.isRegistered<PlaybackQueueService>()) {
      try {
        final source = _localSources.firstWhereOrNull(
          (candidate) => candidate.id == sourceId,
        );
        final queue = PlaybackQueueService.to.openLocalLibrary(
          sourceId: sourceId,
          categoryId: _localCategoryId,
          sort: _localSorts[_tabController.index],
          title: source?.displayName,
        );
        if (queue.loaded.isEmpty) await queue.loadMore();
        queueRef = PlaybackQueueRef(
          queueId: queue.queueId,
          currentItemId: item.id,
        );
      } catch (e, s) {
        LogUtils.w('创建本机播放队列失败: $e', 'PopularMediaListPageBase');
        LogUtils.d('$s', 'PopularMediaListPageBase');
      }
    }
    NaviService.navigateToLocalVideoPlayerPage(
      localPath: item.resolvePlaybackTarget(),
      localLibraryItemId: item.id,
      playbackQueueRef: queueRef,
    );
  }

  Future<void> _openLocalImageFolder(LocalImageFolder folder) async {
    final paths = _localMediaRepository.imagePathsInFolder(
      sourceId: _localSourceId,
      folderPath: folder.folderPath,
    );
    if (paths.isEmpty) {
      showAppToast(t.localMedia.fileMissing, type: AppToastType.error);
      return;
    }
    final imageItems = paths
        .map(
          (path) => ImageItem(
            url: 'file://$path',
            data: ImageItemData(
              id: path,
              url: 'file://$path',
              originalUrl: 'file://$path',
            ),
          ),
        )
        .toList();
    pushPhotoViewWrapperOverlay(
      context: context,
      imageItems: imageItems,
      initialIndex: 0,
      menuItemsBuilder: (context, item) => const [],
      enableMenu: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerRowHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerRowHeight;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = MediaQuery.sizeOf(context).width > 600;

          return BatchDownloadSelectionScope(
            controllers: [_batchSelectController],
            child: GlassHeaderOverlay(
              // 热门视频 / 图库：header 与浮层 chrome 走真折射透镜，列表本体
              // 留在传统档（见 GlassHeaderOverlay.liquid）。
              liquid: true,
              // 这一页是全站最需要内容感知字色的地方：满屏封面图，深浅完全
              // 由内容决定，header 底下压着什么谁也说不准
              // （见 GlassHeaderOverlay.contentAware）。
              contentAware: true,
              headerExtent: headerExtent,
              headerTop: statusBarHeight,
              solidExtent: statusBarHeight,
              body: Obx(() {
                // 内容区域：列表铺满整页，通过 paddingTop 让出 header
                final isPaginated = _mediaListController.isPaginated.value;
                final rebuildKey = _mediaListController.rebuildKey.value
                    .toString();
                final isMultiSelectMode =
                    !_isLocalSource &&
                    _batchSelectController.isMultiSelect.value;
                final selectedMediaIds = _batchSelectController.selectedMediaIds
                    .toSet();

                _batchSelectController.setPaginatedMode(isPaginated);

                // 视口必须铺满整页（不能在外面套 Padding，否则内容会在 header
                // 下边缘被视口裁掉、永远滚不到 header 背后）；留白交给列表自身的
                // paddingTop，这样首屏从 header 下方开始、滚动时从 header 背后经过。
                if (_isLocalSource && _supportsLocalSource) {
                  if (T == ImageModel) {
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        for (final sortId in _localImageFolderSortIds)
                          MediaTabView<LocalImageFolder>(
                            key: ValueKey(
                              'local_image_${_localSourceId}_${sortId.name}_'
                              '$isPaginated$rebuildKey',
                            ),
                            sortId: sortId,
                            repository: _localImageFolderRepositoryFor(sortId),
                            emptyIcon: widget.emptyIcon,
                            isPaginated: isPaginated,
                            showBottomPadding: true,
                            rebuildKey: rebuildKey,
                            paddingTop: headerExtent,
                            mediaListController: _mediaListController,
                            onOpenLocalImageFolder: _openLocalImageFolder,
                          ),
                      ],
                    );
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      for (final sortId in _localSortIds)
                        MediaTabView<LocalMediaItem>(
                          key: ValueKey(
                            'local_${_localSourceId}_${_localCategoryId}_'
                            '${sortId.name}_$isPaginated$rebuildKey',
                          ),
                          sortId: sortId,
                          repository: _localRepositoryFor(sortId),
                          emptyIcon: widget.emptyIcon,
                          isPaginated: isPaginated,
                          showBottomPadding: true,
                          rebuildKey: rebuildKey,
                          paddingTop: headerExtent,
                          mediaListController: _mediaListController,
                          onLocalItemChanged: () {
                            _refreshActiveLocalRepository();
                            _refreshLocalSources();
                          },
                          onOpenLocalItem: _openLocalItem,
                        ),
                    ],
                  );
                }
                return TabBarView(
                  controller: _tabController,
                  children: sorts.map((sort) {
                    final sortReloadVersion = _mediaListController
                        .reloadVersionFor(sort.id);
                    return MediaTabView<T>(
                      key: ValueKey(
                        '${sort.id}_${sortReloadVersion}_$isPaginated$rebuildKey',
                      ),
                      sortId: sort.id,
                      repository: _repositories[sort.id]!,
                      emptyIcon: widget.emptyIcon,
                      isPaginated: isPaginated,
                      // 底部安全区由 MediaQuery.padding.bottom 统一提供
                      //（窄屏时 Shell 已把浮动底栏的高度加进去）
                      showBottomPadding: true,
                      rebuildKey: rebuildKey,
                      paddingTop: headerExtent,
                      mediaListController: _mediaListController,
                      isMultiSelectMode: isMultiSelectMode,
                      selectedItemIds: selectedMediaIds,
                      onItemSelect: (media) =>
                          _batchSelectController.toggleSelection(media),
                      onPageChanged: () =>
                          _batchSelectController.onPageChanged(),
                      playbackQueueRefBuilder: T == ImageModel
                          ? (galleryId) => _galleryQueueRef(sort.id, galleryId)
                          : null,
                      onOpenVideo:
                          T == Video &&
                              widget.searchSegment == SearchSegment.video
                          ? ({
                              required videoId,
                              required loadedVideos,
                              Map<String, dynamic>? extData,
                            }) => _openVideoFromPopularList(
                              videoId: videoId,
                              loadedVideos: loadedVideos,
                              extData: extData,
                            )
                          : null,
                    );
                  }).toList(),
                );
              }),
              header: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const IdentityAvatarButton(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _supportsLocalSource
                          ? _buildSourceControl()
                          : Obx(() {
                              final bool selecting =
                                  _batchSelectController.isMultiSelect.value;
                              return GlassAdaptiveSegmentedControl(
                                selectedIndex: _currentTabIndex.value,
                                progress: _tabController.animation,
                                onChanged: (i) => _tabController.animateTo(i),
                                items: [
                                  for (final sort in sorts)
                                    GlassSegmentItem(
                                      label: sort.label,
                                      icon: sort.icon,
                                    ),
                                ],
                                replacement: selecting
                                    ? SizedBox(
                                        key: const ValueKey('selection'),
                                        width: 168,
                                        child: GlassSelectionSummary(
                                          selectedCount: _batchSelectController
                                              .selectedCount,
                                          allSelected: false,
                                          onToggleAll: null,
                                        ),
                                      )
                                    : null,
                              );
                            }),
                    ),
                    const SizedBox(width: 8),
                    _buildActionGroup(context, isWide: isWide),
                  ],
                ),
              ),
              extra: [
                _buildScrollToTopFab(context),

                // 批量动作：瀑布流模式下的底部玻璃坞。分页模式下动作行由分页栏
                // 自己承载（见 BatchSelectionScope），这里自动隐身，底部不会
                // 出现第二条玻璃。
                Obx(
                  () => GlassSelectionDock(
                    paginated: _mediaListController.isPaginated.value,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
