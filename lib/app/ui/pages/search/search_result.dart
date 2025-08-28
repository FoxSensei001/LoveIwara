import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_common_widgets.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_button_widget.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';

import 'search_dialog.dart';

class SearchController extends GetxController {
  // 搜索状态管理
  final RxString currentSearch = ''.obs;
  final Rx<SearchSegment> selectedSegment = SearchSegment.video.obs;
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  final RxInt rebuildKey = 0.obs;
  final RxString selectedSort = 'hot'.obs; // 添加 sort 状态管理（主要用于 oreno3d）
  final RxString searchType = ''.obs; // 添加搜索类型状态管理（用于 oreno3d）
  final Rx<Map<String, dynamic>?> extData = Rx<Map<String, dynamic>?>(null); // 添加扩展数据管理
  final RxString currentSingleTagNameBehindSearchInput = ''.obs; // 用于显示 oreno3d 标签名
  
  // 筛选项状态管理
  final RxList<Filter> filters = <Filter>[].obs;

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

  // 切换分页模式
  void togglePaginationMode() {
    if (isPaginated.value) {
      isPaginated.value = false;
      Get.find<ConfigService>()
          .settings[ConfigKey.DEFAULT_PAGINATION_MODE]!
          .value =
      false;
      CommonConstants.isPaginated = false;
    } else {
      isPaginated.value = true;
      Get.find<ConfigService>()
          .settings[ConfigKey.DEFAULT_PAGINATION_MODE]!
          .value =
      true;
      CommonConstants.isPaginated = true;
    }
    rebuildKey.value++;
    // 切换分页模式后滚动到顶部
    scrollToTop();
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
  late SearchController searchController;

  @override
  void initState() {
    super.initState();
    _initializeSearchController();
    _setupSearchController();
    _setupSearchTextController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    Get.delete<SearchController>(tag: 'search_controller');
    super.dispose();
  }

  // 初始化搜索控制器
  void _initializeSearchController() {
    searchController = Get.put(SearchController(), tag: 'search_controller');
    searchController.updateSearch(widget.initialSearch);
    searchController.updateSegment(widget.initialSegment);
    // 初始化排序（根据分段默认或外部传入）
    if (widget.initialSort != null && widget.initialSort!.isNotEmpty) {
      searchController.updateSort(widget.initialSort!);
    } else {
      searchController.updateSort(FilterConfig.getDefaultSortForSegment(widget.initialSegment));
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
  Widget _buildSearchListWidget(SearchSegment segment, String query, bool isPaginated, int rebuildKey, String sort, String searchType, Map<String, dynamic>? extData) {
    switch (segment) {
      case SearchSegment.video:
        return VideoSearchList(
          key: ValueKey('video_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.image:
        return ImageSearchList(
          key: ValueKey('image_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.user:
        return UserSearchList(
          key: ValueKey('user_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.post:
        return PostSearchList(
          key: ValueKey('post_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.forum:
        return ForumSearchList(
          key: ValueKey('forum_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.forum_posts:
        return ForumPostsSearchList(
          key: ValueKey('forum_posts_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.playlist:
        return PlaylistSearchList(
          key: ValueKey('playlist_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sort: sort,
        );
      case SearchSegment.oreno3d:
        return Oreno3dSearchList(
          key: ValueKey('oreno3d_$rebuildKey'),
          query: query,
          isPaginated: isPaginated,
          sortType: sort,
          searchType: searchType.isNotEmpty ? searchType : null,
          extData: extData,
        );
    }
  }

  Widget _buildCurrentSearchList() {
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

      final child = _buildSearchListWidget(segment, query, isPaginated, rebuildKey, sort, searchType, extData);
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
      return searchType != null && ['origin', 'tag', 'character'].contains(searchType);
    }

    return false;
  }

  // 构建标签显示组件
  Widget _buildTagDisplayWidget() {
    return TagDisplayWidget(
      tagName: searchController.currentSingleTagNameBehindSearchInput.value,
      onCopy: _copyTagToClipboard,
      onTranslate: _showTranslationDialog,
    );
  }

  // 复制标签到剪贴板
  void _copyTagToClipboard() {
    final textToCopy = searchController.currentSingleTagNameBehindSearchInput.value;
    Clipboard.setData(ClipboardData(text: textToCopy));
    showToastWidget(
      MDToastWidget(
        message: slang.t.download.copySuccess,
        type: MDToastType.success,
      ),
      position: ToastPosition.bottom,
    );
  }

  // 显示翻译对话框
  void _showTranslationDialog() {
    Get.dialog(
      TranslationDialog(
        text: searchController.currentSingleTagNameBehindSearchInput.value,
      ),
    );
  }

  // 构建搜索输入框
  Widget _buildSearchInputField() {
    return Expanded(
      child: SearchInputField(
        controller: _searchController,
        hintText: searchController.currentSearch.value.isEmpty
            ? slang.t.search.pleaseEnterSearchContent
            : searchController.currentSearch.value,
        readOnly: true,
        onTap: _showSearchDialog,
      ),
    );
  }

  // 显示搜索对话框
  void _showSearchDialog() {
    Get.dialog(
      SearchDialog(
        userInputKeywords: searchController.currentSearch.value,
        initialSegment: searchController.selectedSegment.value,
        initialSort: searchController.selectedSort.value,
        initialFilters: searchController.filters.toList(),
        onSearch: _handleSearchResult,
      ),
    );
  }

  // 处理搜索结果
  void _handleSearchResult(String searchInfo, SearchSegment segment, List<Filter> filters, String sort) {
    // 更新搜索参数
    searchController.updateSearch(searchInfo);
    searchController.updateSegment(segment);
    searchController.updateFilters(filters);
    searchController.updateSort(sort);

    // 更新UI
    _searchController.text = searchInfo;
    searchController.refreshSearch();

    // 关闭对话框
    Get.back();
  }

  // 构建分段选择器
  Widget _buildSegmentSelector() {
    return Obx(() => SearchSegmentSelector(
      selectedSegment: searchController.selectedSegment.value,
      onSegmentChanged: searchController.updateSegment,
    ));
  }

  // 构建排序选择器
  Widget _buildSortSelector() {
    return Obx(() {
      final segment = searchController.selectedSegment.value;
      if (segment == SearchSegment.oreno3d) {
        return SortSelector(
          selectedSort: searchController.selectedSort.value,
          onSortChanged: searchController.updateSort,
        );
      }
      final options = FilterConfig.getSortOptionsForSegment(segment);
      if (options.isEmpty) return const SizedBox.shrink();
      return CommonSortSelector(
        selectedSort: searchController.selectedSort.value,
        options: options,
        onSortChanged: searchController.updateSort,
      );
    });
  }

  // 构建应用栏操作按钮
  List<Widget> _buildAppBarActions() {
    final t = slang.Translations.of(context);
    return [
      // 刷新按钮
      IconButton(
        onPressed: () {
          searchController.refreshSearch();
        },
        icon: const Icon(Icons.refresh),
        tooltip: t.common.refresh,
      ),
      // 分页模式切换按钮
      Obx(
        () => IconButton(
          onPressed: () {
            searchController.togglePaginationMode();
          },
          icon: Icon(
            searchController.isPaginated.value
                ? Icons.grid_view
                : Icons.menu,
          ),
          tooltip: searchController.isPaginated.value
              ? t.common.pagination.waterfall
              : t.common.pagination.pagination,
        ),
      ),
    ];
  }

  // 构建搜索控件区域
  Widget _buildSearchControlsArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // 根据条件决定是否显示搜索输入框
          Obx(() => _shouldHideSearchInput()
              ? _buildTagDisplayWidget()
              : _buildSearchInputField()),
          _buildSegmentSelector(),
          _buildSortSelector(),
          Obx(() => FilterButtonWidget(
            currentSegment: searchController.selectedSegment.value,
            filters: searchController.filters.toList(),
            onFiltersChanged: searchController.updateFilters,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.search.searchResult),
        actions: _buildAppBarActions(),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchControlsArea(),
            // 搜索结果区域
            Expanded(child: _buildCurrentSearchList()),
          ],
        ),
      ),
    );
  }
}
