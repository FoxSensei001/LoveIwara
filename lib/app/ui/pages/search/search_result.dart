import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_list_widgets.dart';
import 'package:i_iwara/app/ui/widgets/glow_notification_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

import 'search_dialog.dart';

class SearchController extends GetxController {
  // 搜索状态管理
  final RxString currentSearch = ''.obs;
  final RxString selectedSegment = 'video'.obs;
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  final RxInt rebuildKey = 0.obs;
  final RxString selectedSort = 'trending'.obs; // 添加 sort 状态管理
  final RxString searchType = ''.obs; // 添加搜索类型状态管理（用于 oreno3d）
  final Rx<Map<String, dynamic>?> extData = Rx<Map<String, dynamic>?>(null); // 添加扩展数据管理

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
  void updateSegment(String segment) {
    selectedSegment.value = segment;

    // 根据分段设置合适的默认排序
    if (segment == 'oreno3d') {
      selectedSort.value = 'hot'; // oreno3d默认使用hot排序
    } else if (segment == 'video' || segment == 'image') {
      selectedSort.value = 'trending'; // 视频和图片使用trending排序
    }

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

  // 更新排序方式
  void updateSort(String sort) {
    selectedSort.value = sort;
    // 切换排序时刷新搜索结果
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
  final String initialSegment;
  final String? initialSearchType; // 新增搜索类型参数
  final Map<String, dynamic>? extData; // 新增扩展数据参数

  const SearchResult({
    super.key,
    required this.initialSearch,
    required this.initialSegment,
    this.initialSearchType,
    this.extData,
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

    // 初始化搜索控制器
    searchController = Get.put(SearchController(), tag: 'search_controller');
    searchController.updateSearch(widget.initialSearch);
    searchController.updateSegment(widget.initialSegment);

    // 处理扩展数据
    if (widget.extData != null) {
      searchController.updateExtData(widget.extData);
      final searchType = widget.extData!['searchType'] as String?;
      if (searchType != null) {
        searchController.updateSearchType(searchType);
      }
    } else if (widget.initialSearchType != null) {
      searchController.updateSearchType(widget.initialSearchType!);
    }

    // 设置搜索文本
    _searchController.text = widget.initialSearch;

    // 监听输入框变化
    _searchController.addListener(() {
      searchController.updateSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    Get.delete<SearchController>(tag: 'search_controller');
    super.dispose();
  }

  // 获取分段图标
  Widget _getSegmentIcon(String segment) {
    switch (segment) {
      case 'video':
        return const Icon(Icons.video_library, size: 20);
      case 'image':
        return const Icon(Icons.image, size: 20);
      case 'post':
        return const Icon(Icons.article, size: 20);
      case 'user':
        return const Icon(Icons.person, size: 20);
      case 'forum':
        return const Icon(Icons.forum, size: 20);
      case 'oreno3d':
        return const Icon(Icons.view_in_ar, size: 20);
      default:
        return const Icon(Icons.search, size: 20);
    }
  }

  Widget _buildCurrentSearchList() {
    return Obx(() {
      final query = searchController.currentSearch.value;
      final segment = searchController.selectedSegment.value;
      final isPaginated = searchController.isPaginated.value;
      final rebuildKey = searchController.rebuildKey.value;
      final sort = searchController.selectedSort.value;
      final searchType = searchController.searchType.value;
      final extData = searchController.extData.value;

      LogUtils.d(
        '构建搜索列表: 关键词=$query, 类型=$segment, 使用分页=$isPaginated, 重建键=$rebuildKey, 排序=$sort, 搜索类型=$searchType, 扩展数据=$extData',
        'SearchResult',
      );

      Widget child;
      switch (segment) {
        case 'video':
          child = VideoSearchList(
            key: ValueKey('video_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
            sortType: sort,
          );
          break;
        case 'image':
          child = ImageSearchList(
            key: ValueKey('image_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
            sortType: sort,
          );
          break;
        case 'user':
          child = UserSearchList(
            key: ValueKey('user_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
          );
          break;
        case 'post':
          child = PostSearchList(
            key: ValueKey('post_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
          );
          break;
        case 'forum':
          child = ForumSearchList(
            key: ValueKey('forum_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
          );
          break;
        case 'oreno3d':
          child = Oreno3dSearchList(
            key: ValueKey('oreno3d_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
            sortType: sort,
            searchType: searchType.isNotEmpty ? searchType : null,
            extData: extData,
          );
          break;
        default:
          child = Center(
            child: Text(
              slang.t.search.unsupportedSearchType(searchType: segment),
            ),
          );
      }

      return GlowNotificationWidget(child: child);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.search.searchResult),
        actions: [
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
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 搜索框和分段选择器区域
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: TextField(
                        controller: _searchController,
                        readOnly: true,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: searchController.currentSearch.value.isEmpty
                              ? t.search.pleaseEnterSearchContent
                              : searchController.currentSearch.value,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onTap: () {
                          Get.dialog(
                            SearchDialog(
                              initialSearch:
                                  searchController.currentSearch.value,
                              initialSegment: SearchSegment.fromValue(
                                searchController.selectedSegment.value,
                              ),
                              onSearch: (searchInfo, segment) {
                                // 更新搜索参数
                                searchController.updateSearch(searchInfo);
                                searchController.updateSegment(segment);

                                // 更新UI
                                _searchController.text = searchInfo;
                                searchController.refreshSearch();

                                // 关闭对话框
                                Get.back();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // 分段选择下拉框（图标样式）
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    height: 44,
                    child: Obx(
                      () => PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        initialValue: searchController.selectedSegment.value,
                        onSelected: (String newValue) {
                          searchController.updateSegment(newValue);
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'video',
                              child: Row(
                                children: [
                                  const Icon(Icons.video_library, size: 20),
                                  const SizedBox(width: 8),
                                  Text(t.common.video),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'image',
                              child: Row(
                                children: [
                                  const Icon(Icons.image, size: 20),
                                  const SizedBox(width: 8),
                                  Text(t.common.gallery),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'post',
                              child: Row(
                                children: [
                                  const Icon(Icons.article, size: 20),
                                  const SizedBox(width: 8),
                                  Text(t.common.post),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'user',
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 20),
                                  const SizedBox(width: 8),
                                  Text(t.common.user),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'forum',
                              child: Row(
                                children: [
                                  const Icon(Icons.forum, size: 20),
                                  const SizedBox(width: 8),
                                  Text(t.forum.forum),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'oreno3d',
                              child: Row(
                                children: [
                                  const Icon(Icons.view_in_ar, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Oreno3D'),
                                ],
                              ),
                            ),
                          ];
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: _getSegmentIcon(
                              searchController.selectedSegment.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 排序下拉框（仅视频、图库和oreno3d显示）
                  Obx(() {
                    final segment = searchController.selectedSegment.value;
                    if (segment != 'video' && segment != 'image' && segment != 'oreno3d') {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      height: 44,
                      alignment: Alignment.center,
                      child: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        initialValue: searchController.selectedSort.value,
                        onSelected: (String newValue) {
                          searchController.updateSort(newValue);
                        },
                        itemBuilder: (BuildContext context) {
                          final segment = searchController.selectedSegment.value;
                          if (segment == 'oreno3d') {
                            // Oreno3d专用排序选项
                            return [
                              PopupMenuItem<String>(
                                value: 'hot',
                                child: Row(
                                  children: [
                                    const Icon(Icons.trending_up, size: 20),
                                    const SizedBox(width: 8),
                                    Text(t.oreno3d.sortTypes.hot),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'favorites',
                                child: Row(
                                  children: [
                                    const Icon(Icons.favorite, size: 20),
                                    const SizedBox(width: 8),
                                    Text(t.oreno3d.sortTypes.favorites),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'latest',
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 20),
                                    const SizedBox(width: 8),
                                    Text(t.oreno3d.sortTypes.latest),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'popularity',
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 20),
                                    const SizedBox(width: 8),
                                    Text(t.oreno3d.sortTypes.popularity),
                                  ],
                                ),
                              ),
                            ];
                          } else {
                            // 标准排序选项
                            return CommonConstants.mediaSorts.map((sort) {
                              return PopupMenuItem<String>(
                                value: sort.id.name,
                                child: Row(
                                  children: [
                                    if (sort.icon != null) ...[
                                      sort.icon!,
                                      const SizedBox(width: 8),
                                    ],
                                    Text(sort.label),
                                  ],
                                ),
                              );
                            }).toList();
                          }
                        },
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.sort,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 搜索结果区域
            Expanded(child: _buildCurrentSearchList()),
          ],
        ),
      ),
    );
  }
}
