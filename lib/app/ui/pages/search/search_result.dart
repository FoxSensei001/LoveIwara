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

  // 更新当前搜索查询
  void updateSearch(String query) {
    currentSearch.value = query;
  }
  
  // 更新当前搜索分段
  void updateSegment(String segment) {
    selectedSegment.value = segment;
  }
  
  // 切换分页模式
  void togglePaginationMode() {
    if (isPaginated.value) {
      isPaginated.value = false;
      Get.find<ConfigService>().settings[ConfigKey.DEFAULT_PAGINATION_MODE]!.value = false;
      CommonConstants.isPaginated = false;
    } else {
      isPaginated.value = true;
      Get.find<ConfigService>().settings[ConfigKey.DEFAULT_PAGINATION_MODE]!.value = true;
      CommonConstants.isPaginated = true;
    }
    rebuildKey.value++;
  }
  
  // 刷新搜索结果
  void refreshSearch() {
    rebuildKey.value++;
  }
}

class SearchResult extends StatefulWidget {
  final String initialSearch;
  final String initialSegment;

  const SearchResult({
    super.key, 
    required this.initialSearch, 
    required this.initialSegment
  });

  @override
  _SearchResultState createState() => _SearchResultState();
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

  void _safeScrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Widget _buildCurrentSearchList() {
    return Obx(() {
      final query = searchController.currentSearch.value;
      final segment = searchController.selectedSegment.value;
      final isPaginated = searchController.isPaginated.value;
      final rebuildKey = searchController.rebuildKey.value;
      
      LogUtils.d('构建搜索列表: 关键词=$query, 类型=$segment, 使用分页=$isPaginated, 重建键=$rebuildKey', 'SearchResult');
      
      Widget child;
      switch (segment) {
        case 'video':
          child = VideoSearchList(
            key: ValueKey('video_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
          );
          break;
        case 'image':
          child = ImageSearchList(
            key: ValueKey('image_$rebuildKey'),
            query: query,
            isPaginated: isPaginated,
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
        default:
          child = Center(
            child: Text(slang.t.search.unsupportedSearchType(searchType: segment)),
          );
      }
      
      return GlowNotificationWidget(
        child: child,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.search.searchResult),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 搜索框和刷新按钮区域
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                        onTap: () {
                          Get.dialog(SearchDialog(
                            initialSearch: searchController.currentSearch.value,
                            initialSegment: SearchSegment.fromValue(searchController.selectedSegment.value),
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
                          ));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 分页模式切换按钮
                  Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    clipBehavior: Clip.antiAlias,
                    child: Obx(() => InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        searchController.togglePaginationMode();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          searchController.isPaginated.value ? Icons.grid_view : Icons.menu,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 8),
                  // 刷新按钮
                  Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        searchController.refreshSearch();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.refresh,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 分段控制器区域
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'video',
                            icon: const Icon(Icons.video_library, size: 20),
                            label: MediaQuery.of(context).size.width > 360 
                              ? Text(t.common.video) 
                              : null,
                          ),
                          ButtonSegment(
                            value: 'image',
                            icon: const Icon(Icons.image, size: 20),
                            label: MediaQuery.of(context).size.width > 360 
                              ? Text(t.common.gallery) 
                              : null,
                          ),
                          ButtonSegment(
                            value: 'post',
                            icon: const Icon(Icons.article, size: 20),
                            label: MediaQuery.of(context).size.width > 360 
                              ? Text(t.common.post) 
                              : null,
                          ),
                          ButtonSegment(
                            value: 'user',
                            icon: const Icon(Icons.person, size: 20),
                            label: MediaQuery.of(context).size.width > 360 
                              ? Text(t.common.user) 
                              : null,
                          ),
                          ButtonSegment(
                            value: 'forum',
                            icon: const Icon(Icons.forum, size: 20),
                            label: MediaQuery.of(context).size.width > 360 
                              ? Text(t.forum.forum) 
                              : null,
                          ),
                        ],
                        selected: {searchController.selectedSegment.value},
                        onSelectionChanged: (Set<String> selection) {
                          if (selection.isNotEmpty) {
                            searchController.updateSegment(selection.first);
                            _safeScrollToTop();
                          }
                        },
                        multiSelectionEnabled: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.primaryContainer;
                            }
                            return null;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.onPrimaryContainer;
                            }
                            return Theme.of(context).colorScheme.onSurfaceVariant;
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),

            // 搜索结果区域
            Expanded(
              child: _buildCurrentSearchList(),
            ),
          ],
        ),
      ),
    );
  }
}
