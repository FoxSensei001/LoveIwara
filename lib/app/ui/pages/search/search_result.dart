import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/rx_ever.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_filter_drawer.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/batch_download_selection.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_corner_dock.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';

import 'package:i_iwara/app/ui/pages/popular_media_list/controllers/batch_select_controller.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/widgets/tag_detail_dialog.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_saved_items_drawer.dart';
import 'widgets/saved_search_drawer.dart';

class SearchResultController extends GetxController {
  // 搜索状态管理
  final RxString currentSearch = ''.obs;
  final Rx<SearchSegment> selectedSegment = SearchSegment.video.obs;
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  final RxInt rebuildKey = 0.obs;
  final RxString selectedSort = 'latest'.obs; // 添加 sort 状态管理（主要用于 oreno3d）
  final RxString searchType = ''.obs; // 添加搜索类型状态管理（用于 oreno3d）
  final Rx<Map<String, dynamic>?> extData = Rx<Map<String, dynamic>?>(
    null,
  ); // 添加扩展数据管理
  final RxString currentSingleTagNameBehindSearchInput =
      ''.obs; // 用于显示 oreno3d 标签名

  // 筛选项状态管理
  final RxList<Filter> filters = <Filter>[].obs;

  // 批量开启模式
  late BatchSelectController<Video> videoBatchController;
  late BatchSelectController<ImageModel> imageBatchController;

  SearchResultController() {
    videoBatchController = BatchSelectController<Video>();
    imageBatchController = BatchSelectController<ImageModel>();

    // 监听分页模式变化
    rxEver(isPaginated, (bool val) {
      videoBatchController.setPaginatedMode(val);
      imageBatchController.setPaginatedMode(val);
    });

    // 监听搜索词变化，如果是分页模式则清空选择
    rxEver(currentSearch, (_) {
      videoBatchController.onPageChanged();
      imageBatchController.onPageChanged();
    });

    // 监听分段变化，清空所有选择并退出多选模式
    rxEver(selectedSegment, (_) {
      videoBatchController.exitMultiSelect();
      imageBatchController.exitMultiSelect();
    });
  }

  @override
  void onClose() {
    videoBatchController.dispose();
    imageBatchController.dispose();
    super.onClose();
  }

  // 存储滚动回调
  final List<Function()> _scrollToTopCallbacks = [];

  // 注册滚动到顶部的回调函数
  void registerScrollToTopCallback(Function() callback) {
    if (!_scrollToTopCallbacks.contains(callback)) {
      _scrollToTopCallbacks.add(callback);
    }
  }

  // 注销滚动到顶部的回调函数
  void unregisterScrollToTopCallback(Function() callback) {
    _scrollToTopCallbacks.remove(callback);
  }

  // 执行所有滚动到顶部的回调
  void scrollToTop() {
    for (var callback in _scrollToTopCallbacks) {
      callback();
    }
  }

  // 更新当前搜索查询
  void updateSearch(String query) {
    currentSearch.value = query;
  }

  // 更新当前搜索分段
  void updateSegment(SearchSegment segment) {
    selectedSegment.value = segment;

    // 根据分段设置合适的默认排序
    selectedSort.value = FilterConfig.getDefaultSortForSegment(segment);

    // 切换分段时重置筛选项
    filters.clear();

    // 切换分段时滚动到顶部
    scrollToTop();
  }

  // 更新搜索类型（用于 oreno3d）
  void updateSearchType(String type) {
    searchType.value = type;
  }

  // 更新扩展数据
  void updateExtData(Map<String, dynamic>? data) {
    extData.value = data;
  }

  // 更新 oreno3d 标签名
  void updateCurrentSingleTagNameBehindSearchInput(String name) {
    currentSingleTagNameBehindSearchInput.value = name;
  }

  // 更新排序方式
  void updateSort(String sort) {
    selectedSort.value = sort;
    // 切换排序时刷新搜索结果
    refreshSearch();
  }

  // 更新筛选项
  void updateFilters(List<Filter> newFilters) {
    filters.assignAll(newFilters);
    // 更新筛选项时刷新搜索结果
    refreshSearch();
  }

  // 刷新搜索结果
  void refreshSearch() {
    rebuildKey.value++;
    // 刷新后滚动到顶部
    scrollToTop();
  }
}

class SearchResult extends StatefulWidget {
  final String initialSearch;
  final SearchSegment initialSegment;
  final String? initialSearchType; // 新增搜索类型参数
  final Map<String, dynamic>? extData; // 新增扩展数据参数
  final List<Filter>? initialFilters; // 新增初始筛选项参数
  final String? initialSort; // 新增初始排序参数

  const SearchResult({
    super.key,
    required this.initialSearch,
    required this.initialSegment,
    this.initialSearchType,
    this.extData,
    this.initialFilters,
    this.initialSort,
  });

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showBackToTop = ValueNotifier(false);
  late SearchResultController searchController;

  /// 用于打开右侧「已保存搜索」抽屉。
  late final SavedSearchService _savedSearchService;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SavedSearchService>()) {
      Get.put(SavedSearchService(), permanent: true);
    }
    _savedSearchService = Get.find<SavedSearchService>();
    _initializeSearchController();
    _setupSearchController();
    _setupSearchTextController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _showBackToTop.dispose();
    Get.delete<SearchResultController>(tag: 'search_controller');
    super.dispose();
  }

  // 初始化搜索控制器
  void _initializeSearchController() {
    searchController = Get.put(
      SearchResultController(),
      tag: 'search_controller',
    );
    searchController.updateSearch(widget.initialSearch);
    searchController.updateSegment(widget.initialSegment);
    // 初始化排序（根据分段默认或外部传入）
    if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
      searchController.updateSort(widget.initialSort!);
    } else {
      searchController.updateSort(
        FilterConfig.getDefaultSortForSegment(widget.initialSegment),
      );
    }

    // 设置初始筛选项
    if (widget.initialFilters != null) {
      searchController.updateFilters(widget.initialFilters!);
    }
  }

  // 设置搜索控制器参数
  void _setupSearchController() {
    // 处理扩展数据
    if (widget.extData != null) {
      searchController.updateExtData(widget.extData);
      final searchType = widget.extData!['searchType'] as String?;
      final tagName = widget.extData!['name'] as String?;
      if (searchType != null) {
        searchController.updateSearchType(searchType);
      }
      if (tagName != null) {
        searchController.updateCurrentSingleTagNameBehindSearchInput(tagName);
      }
    } else if (widget.initialSearchType != null) {
      searchController.updateSearchType(widget.initialSearchType!);
    }
  }

  // 设置搜索文本控制器
  void _setupSearchTextController() {
    // 设置搜索文本
    _searchController.text = widget.initialSearch;

    // 监听输入框变化
    _searchController.addListener(() {
      searchController.updateSearch(_searchController.text);
    });
  }

  // 构建搜索列表组件
  Widget _buildSearchListWidget(
    SearchSegment segment,
    String query,
    bool isPaginated,
    int rebuildKey,
    String sort,
    String searchType,
    Map<String, dynamic>? extData,
    double paddingTop,
  ) {
    switch (segment) {
      case SearchSegment.video:
        return Obx(
          () => VideoSearchList(
            key: ValueKey('video_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
            paddingTop: paddingTop,
            sort: sort,
            isMultiSelectMode:
                searchController.videoBatchController.isMultiSelect.value,
            selectedItemIds:
                searchController.videoBatchController.selectedMediaIds,
            onItemSelect: (video) =>
                searchController.videoBatchController.toggleSelection(video),
          ),
        );
      case SearchSegment.image:
        return Obx(
          () => ImageSearchList(
            key: ValueKey('image_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
            paddingTop: paddingTop,
            sort: sort,
            isMultiSelectMode:
                searchController.imageBatchController.isMultiSelect.value,
            selectedItemIds:
                searchController.imageBatchController.selectedMediaIds,
            onItemSelect: (image) =>
                searchController.imageBatchController.toggleSelection(image),
          ),
        );
      case SearchSegment.user:
        return UserSearchList(
          key: ValueKey('user_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sort: sort,
        );
      case SearchSegment.post:
        return PostSearchList(
          key: ValueKey('post_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sort: sort,
        );
      case SearchSegment.forum:
        return ForumSearchList(
          key: ValueKey('forum_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sort: sort,
        );
      case SearchSegment.forum_posts:
        return ForumPostsSearchList(
          key: ValueKey('forum_posts_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sort: sort,
        );
      case SearchSegment.playlist:
        return PlaylistSearchList(
          key: ValueKey('playlist_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sort: sort,
        );
      case SearchSegment.oreno3d:
        return Oreno3dSearchList(
          key: ValueKey('oreno3d_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          paddingTop: paddingTop,
          sortType: sort,
          searchType: searchType.isNotEmpty ? searchType : null,
          extData: extData,
        );
    }
  }

  Widget _buildCurrentSearchList(double paddingTop) {
    return Obx(() {
      String query = searchController.currentSearch.value;
      final segment = searchController.selectedSegment.value;
      final isPaginated = searchController.isPaginated.value;
      final rebuildKey = searchController.rebuildKey.value;
      final sort = searchController.selectedSort.value;
      final searchType = searchController.searchType.value;
      final extData = searchController.extData.value;
      final filters = searchController.filters;

      // 应用筛选项到查询
      if (filters.isNotEmpty) {
        final contentType = FilterConfig.getContentType(segment);
        if (contentType != null) {
          final filterStrings = filters
              .map((filter) {
                final field = contentType.fields.firstWhere(
                  (f) => f.name == filter.field,
                  orElse: () => contentType.fields.first,
                );
                return FilterConfig.generateFilterString(filter, field);
              })
              .where((s) => s.isNotEmpty)
              .join(' ');

          if (filterStrings.isNotEmpty) {
            query = '$query $filterStrings';
          }
        }
      }

      LogUtils.d(
        '构建搜索列表: 关键词=$query, 类型=$segment, 使用分页=$isPaginated, 重建键=$rebuildKey, 排序=$sort, 搜索类型=$searchType, 扩展数据=$extData, 筛选项数量=${filters.length}',
        'SearchResult',
      );

      final child = _buildSearchListWidget(
        segment,
        query,
        isPaginated,
        rebuildKey,
        sort,
        searchType,
        extData,
        paddingTop,
      );
      return GlowNotificationWidget(child: child);
    });
  }

  // 检查是否应该隐藏搜索输入框
  bool _shouldHideSearchInput() {
    final segment = searchController.selectedSegment.value;
    final extData = searchController.extData.value;

    // 如果是 oreno3d 模式且有扩展数据（表示不是 /search API）
    if (segment == SearchSegment.oreno3d && extData != null) {
      final searchType = extData['searchType'] as String?;
      return searchType != null &&
          ['origin', 'tag', 'character'].contains(searchType);
    }

    return false;
  }

  /// oreno3d 单实体浏览时的标题胶囊：`? 标签名`，点它开实体详情
  /// （原文 / 译文 / 复制 / 纠错）。
  ///
  /// ⛔ 它**不能**长得像搜索框。更早一版是「`#标签名` + 一枚放大镜」的组合胶囊：
  /// 形状与文本搜索那只一模一样、右边还嵌着搜索钮，于是整只被读成「一个搜索
  /// 框」而不是「我正在看哪个标签」，点下去出来的又是复制——三种身份挤在一只
  /// 胶囊上。同一件事在 Iwara 标签页（`tag_media_list_page`）是一枚
  /// [GlassTitlePill]、点按开标签详情，两边现在对齐到同一套读法；复制并没有
  /// 丢，它在详情弹窗里。搜索入口挪去右边的动作胶囊（见 [_buildActionGroup]），
  /// 那里本来就是「对这一堆东西怎么看、怎么筛」的一组。
  Widget _buildOreno3dBrowsePill(BuildContext context) {
    final name = searchController.currentSingleTagNameBehindSearchInput.value
        .trim();
    return GlassTitlePill(
      // 名字还没到时给 null：胶囊自己会显示 shimmer 占位（连引导图标一起不
      // 画），比画一个光秃秃的图标诚实。
      title: name.isEmpty ? null : name,
      // 与 Iwara 标签页同一枚：点它开的是同一种实体详情。
      icon: Icons.help_outline,
      onTap: _showOreno3dTagDetailDialog,
    );
  }

  // 显示翻译对话框
  void _showTranslationDialog() {
    showTranslationDialog(
      context,
      text: searchController.currentSingleTagNameBehindSearchInput.value,
    );
  }

  // 显示 Oreno3d 实体详情（译文 + 原文 + 复制 + 翻译纠错反馈），与 Iwara 标签同款
  void _showOreno3dTagDetailDialog() {
    showOreno3dTagDetailDialog(
      context,
      type: searchController.searchType.value,
      id: searchController.extData.value?['id'] as String?,
      localizedName:
          searchController.currentSingleTagNameBehindSearchInput.value,
    );
  }

  // 构建搜索胶囊：显示当前关键词，点按打开搜索弹窗。
  // 关键词读的是页面本地的 _searchController（与旧版输入框一致）：
  // SearchResultController 是固定 tag 的共享实例，栈上叠两个搜索页时会互相
  // 覆写，读它会导致返回上一个搜索页后关键词丢失。
  Widget _buildSearchPill(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return GlassSurface(
      onTap: _showSearchDialog,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                final query = value.text;
                return Text(
                  query.isEmpty ? t.search.pleaseEnterSearchContent : query,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: query.isEmpty
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: query.isEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 打开搜索页面（关键词取页面本地文本，见 _buildSearchPill 的注释）
  void _showSearchDialog() {
    NaviService.navigateToSearchPage(
      userInputKeywords: _searchController.text,
      initialSegment: searchController.selectedSegment.value,
      initialSort: searchController.selectedSort.value,
      initialFilters: searchController.filters.toList(),
      onSearch: _handleSearchResult,
    );
  }

  // 处理搜索结果
  void _handleSearchResult(
    String searchInfo,
    SearchSegment segment,
    List<Filter> filters,
    String sort,
  ) {
    // 更新搜索参数
    searchController.updateSearch(searchInfo);
    searchController.updateSegment(segment);
    searchController.updateFilters(filters);
    searchController.updateSort(sort);

    // 文本搜索：清除 oreno3d 单实体浏览状态，避免仍按 id 浏览
    searchController.updateExtData(null);
    searchController.updateSearchType('');
    searchController.updateCurrentSingleTagNameBehindSearchInput('');

    // 更新UI
    _searchController.text = searchInfo;
    searchController.refreshSearch();
  }

  // 打开右侧「已保存搜索」抽屉（与筛选抽屉走同一条路由）
  void _openSavedSearchDrawer() {
    showSavedSearchDrawer(
      context: context,
      onApply: _applySavedSearch,
      onAddCurrent: _promptSaveCurrentSearch,
    );
  }

  // 根据当前搜索条件生成一个默认名称
  String _buildDefaultSearchName() {
    final keyword = searchController.currentSearch.value.trim();
    final tagName = searchController.currentSingleTagNameBehindSearchInput.value
        .trim();
    final segment = searchController.selectedSegment.value;
    final segmentLabel = SavedSearchDrawer.segmentLabel(segment);

    if (keyword.isNotEmpty) return '$segmentLabel · $keyword';
    if (tagName.isNotEmpty) return '$segmentLabel · #$tagName';
    return segmentLabel;
  }

  // 弹出命名对话框，将当前搜索条件保存为一条已保存搜索
  Future<void> _promptSaveCurrentSearch() async {
    final t = slang.Translations.of(context);
    final defaultName = _buildDefaultSearchName();
    final name = await showGlassPromptNameDialog(
      title: t.savedSearch.namePromptTitle,
      hint: t.savedSearch.nameHint,
      initialText: defaultName,
    );
    if (name == null) return;

    final extData = searchController.extData.value;
    final search = SavedSearch(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty ? defaultName : name,
      keyword: searchController.currentSearch.value,
      segment: searchController.selectedSegment.value,
      sort: searchController.selectedSort.value,
      filters: searchController.filters.toList(),
      searchType: searchController.searchType.value,
      extData: extData == null ? null : Map<String, dynamic>.from(extData),
      singleTagName:
          searchController.currentSingleTagNameBehindSearchInput.value,
    );
    await _savedSearchService.add(search);
    showAppToast(
      t.savedSearch.saveSuccess,
      type: AppToastType.success,
      position: AppToastPosition.bottom,
    );
  }

  // 应用一条已保存搜索
  void _applySavedSearch(SavedSearch search) {
    // 注意顺序：updateSegment 会重置排序与筛选项，须在其后再设置排序/筛选项
    searchController.updateSearch(search.keyword);
    searchController.updateSegment(search.segment);
    searchController.updateSort(search.sort);
    searchController.updateFilters(search.filters.toList());

    // 还原 Oreno3D 单实体浏览态（普通搜索时这些值为空）
    searchController.updateExtData(
      search.extData == null
          ? null
          : Map<String, dynamic>.from(search.extData!),
    );
    searchController.updateSearchType(search.searchType);
    searchController.updateCurrentSingleTagNameBehindSearchInput(
      search.singleTagName,
    );

    _searchController.text = search.keyword;
    searchController.refreshSearch();
  }

  IconData _segmentIcon(SearchSegment segment) {
    return switch (segment) {
      SearchSegment.video => Icons.video_library,
      SearchSegment.image => Icons.image,
      SearchSegment.user => Icons.person,
      SearchSegment.playlist => Icons.playlist_play,
      SearchSegment.post => Icons.article,
      SearchSegment.forum => Icons.forum,
      SearchSegment.forum_posts => Icons.comment,
      SearchSegment.oreno3d => Icons.view_in_ar,
    };
  }

  String _segmentLabel(slang.Translations t, SearchSegment segment) {
    return switch (segment) {
      SearchSegment.video => t.common.video,
      SearchSegment.image => t.common.gallery,
      SearchSegment.user => t.common.user,
      SearchSegment.playlist => t.common.playlist,
      SearchSegment.post => t.common.post,
      SearchSegment.forum => t.forum.forum,
      SearchSegment.forum_posts => t.forum.posts,
      SearchSegment.oreno3d => 'Oreno3D',
    };
  }

  IconData _sortIconFor(SearchSegment segment, String value) {
    if (segment == SearchSegment.oreno3d) {
      return switch (value) {
        'hot' => Icons.trending_up,
        'favorites' => Icons.favorite,
        'latest' => Icons.schedule,
        'popularity' => Icons.star,
        _ => Icons.sort,
      };
    }
    return switch (value) {
      'relevance' => Icons.recommend,
      'date' => Icons.schedule,
      'views' => Icons.visibility,
      'likes' => Icons.favorite,
      _ => Icons.sort,
    };
  }

  /// 打开右侧「筛选」抽屉。改动即时生效（每次生效都会刷新搜索结果），抽屉常驻不关。
  void _showFilterDialog() {
    showSearchFilterDrawer(
      context: context,
      segment: searchController.selectedSegment.value,
      initialFilters: searchController.filters.toList(),
      onFiltersChanged: searchController.updateFilters,
    );
  }

  /// 分段入口：玻璃胶囊组里的图标位 + 玻璃下拉菜单。
  Widget _buildSegmentMenuButton(slang.Translations t, SearchSegment segment) {
    return Builder(
      builder: (anchorContext) => GlassIconButton(
        icon: Icon(_segmentIcon(segment)),
        tooltip: _segmentLabel(t, segment),
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
        // 松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onPressed: () async {
          final picked = await showGlassMenu<SearchSegment>(
            anchorContext: anchorContext,
            entries: [
              for (final seg in SearchSegment.values)
                GlassMenuOption<SearchSegment>(
                  value: seg,
                  icon: _segmentIcon(seg),
                  label: _segmentLabel(t, seg),
                  selected: seg == segment,
                ),
            ],
          );
          if (picked != null) searchController.updateSegment(picked);
        },
      ),
    );
  }

  /// 排序入口：图标随当前排序变化。
  Widget _buildSortMenuButton(
    slang.Translations t,
    SearchSegment segment,
    String sort,
  ) {
    final List<(String, String)> entries;
    if (segment == SearchSegment.oreno3d) {
      entries = [
        ('hot', t.oreno3d.sortTypes.hot),
        ('favorites', t.oreno3d.sortTypes.favorites),
        ('latest', t.oreno3d.sortTypes.latest),
        ('popularity', t.oreno3d.sortTypes.popularity),
      ];
    } else {
      entries = [
        for (final opt in FilterConfig.getSortOptionsForSegment(segment))
          (opt.value, opt.label),
      ];
    }

    return Builder(
      builder: (anchorContext) => GlassIconButton(
        icon: Icon(_sortIconFor(segment, sort)),
        tooltip: t.common.sort,
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
        // 松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onPressed: () async {
          final picked = await showGlassMenu<String>(
            anchorContext: anchorContext,
            entries: [
              for (final (value, label) in entries)
                GlassMenuOption<String>(
                  value: value,
                  icon: _sortIconFor(segment, value),
                  label: label,
                  selected: value == sort,
                ),
            ],
          );
          if (picked != null) searchController.updateSort(picked);
        },
      ),
    );
  }

  static const String _menuActionToggleMultiSelect = 'toggle_multi_select';
  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionTagInfo = 'tag_info';
  static const String _menuActionTranslate = 'translate';

  /// 「更多」菜单：多选（视频/图库）、刷新、分页切换；
  /// oreno3d 单实体浏览时再加标签详情 / 翻译。
  /// 「已保存搜索」不在这里：它是常驻入口，见 _buildActionGroup。
  Widget _buildMoreMenuButton(
    slang.Translations t,
    SearchSegment segment,
    bool isBrowseMode,
  ) {
    VoidCallback? toggleMultiSelect;
    bool isMultiSelect = false;
    if (segment == SearchSegment.video) {
      toggleMultiSelect =
          searchController.videoBatchController.toggleMultiSelect;
      isMultiSelect = searchController.videoBatchController.isMultiSelect.value;
    } else if (segment == SearchSegment.image) {
      toggleMultiSelect =
          searchController.imageBatchController.toggleMultiSelect;
      isMultiSelect = searchController.imageBatchController.isMultiSelect.value;
    }

    return Builder(
      builder: (anchorContext) => GlassIconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: t.common.more,
        // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
        // 松手选中（见 GlassTapArea.opensOverlay）。
        opensOverlay: true,
        onPressed: () async {
          final picked = await showGlassMenu<String>(
            anchorContext: anchorContext,
            entries: [
              if (toggleMultiSelect != null)
                GlassMenuOption<String>(
                  value: _menuActionToggleMultiSelect,
                  icon: isMultiSelect ? Icons.close : Icons.checklist,
                  label: isMultiSelect
                      ? t.common.exitEditMode
                      : t.common.editMode,
                ),
              GlassMenuOption<String>(
                value: _menuActionRefresh,
                icon: Icons.refresh,
                label: t.common.refresh,
              ),
              GlassMenuOption<String>(
                value: _menuActionTogglePagination,
                icon: searchController.isPaginated.value
                    ? Icons.grid_view
                    : Icons.view_stream,
                label: searchController.isPaginated.value
                    ? t.common.pagination.waterfall
                    : t.common.pagination.pagination,
              ),
              if (isBrowseMode) ...[
                const GlassMenuSeparator(),
                GlassMenuOption<String>(
                  value: _menuActionTagInfo,
                  icon: Icons.help_outline,
                  label: t.common.tagInfo,
                ),
                GlassMenuOption<String>(
                  value: _menuActionTranslate,
                  icon: Icons.translate,
                  label: t.common.translate,
                ),
              ],
            ],
          );
          if (picked == null) return;
          switch (picked) {
            case _menuActionToggleMultiSelect:
              toggleMultiSelect?.call();
              break;
            case _menuActionRefresh:
              searchController.refreshSearch();
              break;
            case _menuActionTogglePagination:
              searchController.isPaginated.toggle();
              searchController.scrollToTop();
              break;
            case _menuActionTagInfo:
              _showOreno3dTagDetailDialog();
              break;
            case _menuActionTranslate:
              _showTranslationDialog();
              break;
          }
        },
      ),
    );
  }

  /// 「我在看什么、怎么排」：分段 · 排序。
  ///
  /// 与下面那组动作分成两份**不是**为了在 header 上摆成两只胶囊——宽屏下它们
  /// 仍然共处同一坨玻璃（见 [_buildHeaderActionGroup]）。分开是因为窄屏时这两组
  /// 各自去了一个下角：这一组读作「我在看什么」，落左下；那一组读作「怎么筛、
  /// 还能干什么」，落右下。按钮本身只有这一份定义。
  List<Widget> _browseButtons(
    slang.Translations t,
    SearchSegment segment,
    String sort,
  ) {
    final showSort =
        segment == SearchSegment.oreno3d ||
        FilterConfig.getSortOptionsForSegment(segment).isNotEmpty;
    return [
      _buildSegmentMenuButton(t, segment),
      if (showSort) _buildSortMenuButton(t, segment, sort),
    ];
  }

  /// 「怎么筛、还能干什么」：搜索（仅单实体浏览）· 筛选 · 已保存搜索 · 更多。
  List<Widget> _actionButtons(
    slang.Translations t,
    SearchSegment segment, {
    required bool isBrowseMode,
    required int filterCount,
  }) {
    return [
      // 单实体浏览时标题胶囊写的是标签名（不再是搜索框），搜索入口就落在
      // 这里——弹窗内可换原作 / 角色 / 标签，或改回文本搜索。
      if (isBrowseMode)
        GlassIconButton(
          icon: const Icon(Icons.search),
          tooltip: t.common.search,
          onPressed: _showSearchDialog,
        ),
      if (segment != SearchSegment.oreno3d)
        GlassIconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: t.searchFilter.filterSettings,
          showBadge: filterCount > 0,
          badgeLabel: filterCount > 0 ? Text('$filterCount') : null,
          onPressed: _showFilterDialog,
        ),
      // 「已保存搜索」常驻：原先藏在「更多」菜单里，入口太深
      GlassIconButton(
        icon: const Icon(Icons.bookmarks_outlined),
        tooltip: t.savedSearch.title,
        onPressed: _openSavedSearchDrawer,
      ),
      _buildMoreMenuButton(t, segment, isBrowseMode),
    ];
  }

  /// header 右缘那只胶囊（**宽屏**）：分段 · 排序 · 筛选 · 已保存搜索 · 更多
  /// 全在同一坨玻璃里。窄屏时它整只不在场，两组按钮各自去了一个下角。
  Widget _buildHeaderActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final segment = searchController.selectedSegment.value;
      final sort = searchController.selectedSort.value;
      final isBrowseMode = _shouldHideSearchInput();
      return GlassButtonGroup(
        children: [
          ..._browseButtons(t, segment, sort),
          ..._actionButtons(
            t,
            segment,
            isBrowseMode: isBrowseMode,
            filterCount: searchController.filters.length,
          ),
        ],
      );
    });
  }

  /// 左下角坞里的「我在看什么」胶囊（窄屏）。
  Widget _buildBrowseGroup(BuildContext context, {double materialize = 1}) {
    final t = slang.Translations.of(context);
    return Obx(
      () => GlassButtonGroup(
        materialize: materialize,
        children: _browseButtons(
          t,
          searchController.selectedSegment.value,
          searchController.selectedSort.value,
        ),
      ),
    );
  }

  /// 右下角坞里的「怎么筛、还能干什么」胶囊（窄屏）。
  Widget _buildActionGroup(BuildContext context, {double materialize = 1}) {
    final t = slang.Translations.of(context);
    return Obx(
      () => GlassButtonGroup(
        materialize: materialize,
        children: _actionButtons(
          t,
          searchController.selectedSegment.value,
          isBrowseMode: _shouldHideSearchInput(),
          filterCount: searchController.filters.length,
        ),
      ),
    );
  }

  /// 滚过一段后出现的「回到顶部」浮钮。它住在右下角坞的最上一格，与（窄屏才
  /// 在场的）动作胶囊排成一列，而不是各自占一处右下角。
  ///
  /// 选择态下退场：那会儿底部让给 [GlassSelectionDock]，两块玻璃不该叠在一起。
  Widget _buildScrollToTopButton(
    BuildContext context, {
    required bool selecting,
  }) {
    final t = slang.Translations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _showBackToTop,
      builder: (context, visible, _) => GlassReveal(
        visible: visible && !selecting,
        // 这处历来没有位移，只做材质淡入
        slideFrom: Offset.zero,
        builder: (context, m) => GlassIconButton(
          materialize: m,
          standalone: true,
          icon: const Icon(Icons.vertical_align_top),
          tooltip: t.common.scrollToTop,
          onPressed: searchController.scrollToTop,
        ),
      ),
    );
  }

  /// 屏幕下角的两坨浮层：左下「我在看什么」，右下「怎么筛 + 回顶」。
  ///
  /// 两坨都常驻挂载，窄↔宽、常态↔选择态的切换交给里面的 [GlassReveal]
  /// （有出有入），而不是把整只 `Positioned` 从树上摘掉。分页模式下整体抬到
  /// 分页栏之上。
  List<Widget> _buildCornerDocks(BuildContext context, {required bool sink}) {
    Widget dock(
      GlassDockCorner corner,
      List<Widget> Function(bool selecting) children,
    ) {
      return Obx(() {
        final batch = _activeSearchBatchController();
        final bool selecting = batch != null && batch.isMultiSelect.value;
        return GlassCornerDock(
          corner: corner,
          extraBottomInset: searchController.isPaginated.value
              ? PaginationBar.barHeight
              : 0,
          children: children(selecting),
        );
      });
    }

    return [
      dock(
        GlassDockCorner.bottomLeft,
        (selecting) => [
          GlassReveal(
            visible: sink && !selecting,
            builder: (context, m) => _buildBrowseGroup(context, materialize: m),
          ),
        ],
      ),
      dock(
        GlassDockCorner.bottomRight,
        (selecting) => [
          _buildScrollToTopButton(context, selecting: selecting),
          GlassReveal(
            visible: sink && !selecting,
            builder: (context, m) => _buildActionGroup(context, materialize: m),
          ),
        ],
      ),
    ];
  }

  /// 当前 segment 对应的批量选择控制器（视频 / 图库之外的段不支持批量）。
  BatchSelectController<dynamic>? _activeSearchBatchController() {
    switch (searchController.selectedSegment.value) {
      case SearchSegment.video:
        return searchController.videoBatchController;
      case SearchSegment.image:
        return searchController.imageBatchController;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerRowHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerRowHeight;
    // 窄屏摆不下一整行：右侧那一坨动作沉到屏幕下角（见 GlassCornerDock），
    // header 只留「返回 + 搜索/标签胶囊」，胶囊因此能摊开整行。
    final bool sink = useCornerDock(context);

    // 底部安全区由列表自己通过 computeBottomSafeInset 负责
    // （base_search_list 传 showBottomPadding: true），这里不再包 SafeArea；
    // 顶部让位交给列表的 paddingTop，内容滚动时从玻璃 header 背后经过。
    return Scaffold(
      body: BatchDownloadSelectionScope(
        // 视频 / 图库两个控制器只广播当前 segment 那一个
        controllers: [
          searchController.videoBatchController,
          searchController.imageBatchController,
        ],
        activeIndex: () => switch (searchController.selectedSegment.value) {
          SearchSegment.video => 0,
          SearchSegment.image => 1,
          _ => -1,
        },
        child: GlassHeaderOverlay(
          liquid: true,
          headerExtent: headerExtent,
          headerTop: statusBarHeight,
          solidExtent: statusBarHeight,
          // 底部要多让出角落坞那一条，否则最后一行永远压在坞底下
          //（分页模式除外，见 CornerDockBottomInset）。
          body: Obx(
            () => CornerDockBottomInset(
              active: sink && !searchController.isPaginated.value,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical &&
                      notification.depth == 0) {
                    _showBackToTop.value = notification.metrics.pixels >= 300;
                  }
                  return false;
                },
                child: _buildCurrentSearchList(headerExtent),
              ),
            ),
          ),
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
                Expanded(
                  child: Obx(() {
                    // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次页面级
                    // 的模式切换，header 不该毫无反应
                    final batch = _activeSearchBatchController();
                    if (batch != null && batch.isMultiSelect.value) {
                      return GlassCapsuleMorph(
                        child: SizedBox(
                          key: const ValueKey('selection'),
                          width: 168,
                          child: GlassSelectionSummary(
                            selectedCount: batch.selectedCount,
                            allSelected: false,
                            // 懒加载列表够不到未加载的部分，不给全选
                            onToggleAll: null,
                          ),
                        ),
                      );
                    }
                    return _shouldHideSearchInput()
                        ? _buildOreno3dBrowsePill(context)
                        : _buildSearchPill(context);
                  }),
                ),
                GlassCapsuleReveal(
                  visible: !sink,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      _buildHeaderActionGroup(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          extra: [
            ..._buildCornerDocks(context, sink: sink),
            // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
            // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
            Obx(
              () => GlassSelectionDock(
                paginated: searchController.isPaginated.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
