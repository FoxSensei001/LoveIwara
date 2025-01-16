import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/global_search_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/media_tile_list_loading_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import 'search_dialog.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';

class SearchResult extends StatefulWidget {
  const SearchResult({super.key});

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final GlobalSearchService globalSearchService =
      Get.find<GlobalSearchService>();

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    globalSearchService.fetchSearchResult(refresh: true);
    _searchController.text = globalSearchService.currentSearch.value;

    // 监听输入框变化并更新 observable
    _searchController.addListener(() {
      globalSearchService.currentSearch.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose(); // Dispose scroll controller
    globalSearchService.resetAll();
    super.dispose();
  }

  void _safeScrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Widget _buildSearchResult(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      if (globalSearchService.errorWidget.value != null) {
        return globalSearchService.errorWidget.value!;
      }

      if (globalSearchService.isLoading.value &&
          globalSearchService.isCurrentResultEmpty) {
        return const Center(child: MediaTileListSkeletonWidget());
      }

      if (globalSearchService.isResultEmpty) {
        return const Center(child: MyEmptyWidget());
      }

      Widget child;
      switch (globalSearchService.selectedSegment.value) {
        case 'video':
          child = _buildVideoResult();
          break;
        case 'image':
          child = _buildImageResult();
          break;
        case 'user':
          child = _buildUserResult();
          break;
        case 'post':
          child = _buildPostResult();
          break;
        case 'forum':
          child = _buildForumResult();
          break;
        default:
          child = Text(
            t.search.notSupportCurrentSearchType(searchType: globalSearchService.selectedSegment.value));
      }

      return child;
    });
  }

  Widget _buildVideoResult() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _calculateColumns(constraints.maxWidth);
        final itemCount =
            (globalSearchService.searchVideoResult.length / columns).ceil() + 1;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!globalSearchService.isLoading.value &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100 &&
                globalSearchService.hasMore) {
              globalSearchService.fetchSearchResult();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController, // Add controller here
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index < itemCount - 1) {
                return _buildRow(index, columns, constraints.maxWidth);
              } else {
                return _buildLoadMoreIndicator(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildRow(int index, int columns, double maxWidth) {
    return Obx(() {
      final startIndex = index * columns;
      final endIndex = (startIndex + columns)
          .clamp(0, globalSearchService.searchVideoResult.length);
      final rowItems =
          globalSearchService.searchVideoResult.sublist(startIndex, endIndex);
      final remainingColumns = columns - rowItems.length;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...rowItems.map((video) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: VideoCardListItemWidget(
                      video: video,
                      width: maxWidth / columns - 8,
                    ),
                  ),
                )),
            // 添加空的占位 Expanded 来填充剩余空间
            ...List.generate(
              remainingColumns,
              (index) => Expanded(child: Container()),
            ),
          ],
        ),
      );
    });
  }

  int _calculateColumns(double availableWidth) {
    if (availableWidth > 1200) return 5;
    if (availableWidth > 900) return 4;
    if (availableWidth > 600) return 3;
    if (availableWidth > 300) return 2;
    return 1;
  }

  Widget _buildLoadMoreIndicator(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() => globalSearchService.hasMore
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                t.common.noMoreDatas,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ));
  }

  Widget _buildImageResult() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _calculateColumns(constraints.maxWidth);
        final itemCount =
            (globalSearchService.searchImageResult.length / columns).ceil() + 1;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!globalSearchService.isLoading.value &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 100 &&
                globalSearchService.hasMore) {
              globalSearchService.fetchSearchResult();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController, // Add controller here
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index < itemCount - 1) {
                return _buildImageRow(index, columns, constraints.maxWidth);
              } else {
                return _buildLoadMoreIndicator(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildImageRow(int index, int columns, double maxWidth) {
    return Obx(() {
      final startIndex = index * columns;
      final endIndex = (startIndex + columns)
          .clamp(0, globalSearchService.searchImageResult.length);
      final rowItems =
          globalSearchService.searchImageResult.sublist(startIndex, endIndex);
      final remainingColumns = columns - rowItems.length;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...rowItems.map((image) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ImageModelCardListItemWidget(
                      imageModel: image,
                      width: maxWidth / columns - 8,
                    ),
                  ),
                )),
            // 添加空的占位 Expanded 来填充剩余空间
            ...List.generate(
              remainingColumns,
              (index) => Expanded(child: Container()),
            ),
          ],
        ),
      );
    });
  }

  // Add new method for user results
  Widget _buildUserResult() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (!globalSearchService.isLoading.value &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
            globalSearchService.hasMore) {
          globalSearchService.fetchSearchResult();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: globalSearchService.searchUserResult.length + 1,
        itemBuilder: (context, index) {
          if (index < globalSearchService.searchUserResult.length) {
            final user = globalSearchService.searchUserResult[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              child: UserCard(
                user: user,
                onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
              ),
            );
          } else {
            return _buildLoadMoreIndicator(context);
          }
        },
      ),
    );
  }

  Widget _buildPostResult() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _calculateColumns(constraints.maxWidth);
        final itemCount = (globalSearchService.searchPostResult.length / columns).ceil() + 1;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!globalSearchService.isLoading.value &&
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
                globalSearchService.hasMore) {
              globalSearchService.fetchSearchResult();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index < itemCount - 1) {
                return _buildPostRow(index, columns, constraints.maxWidth);
              } else {
                return _buildLoadMoreIndicator(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPostRow(int index, int columns, double maxWidth) {
    return Obx(() {
      final startIndex = index * columns;
      final endIndex = (startIndex + columns)
          .clamp(0, globalSearchService.searchPostResult.length);
      final rowItems = globalSearchService.searchPostResult.sublist(startIndex, endIndex);
      final remainingColumns = columns - rowItems.length;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...rowItems.map((post) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: PostCardListItemWidget(
                      post: post,
                    ),
                  ),
                )),
            ...List.generate(
              remainingColumns,
              (index) => Expanded(child: Container()),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildForumResult() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _calculateColumns(constraints.maxWidth);
        final itemCount = (globalSearchService.searchForumResult.length / columns).ceil() + 1;

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!globalSearchService.isLoading.value &&
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
                globalSearchService.hasMore) {
              globalSearchService.fetchSearchResult();
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index < itemCount - 1) {
                return _buildForumRow(index, columns, constraints.maxWidth);
              } else {
                return _buildLoadMoreIndicator(context);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildForumRow(int index, int columns, double maxWidth) {
    return Obx(() {
      final startIndex = index * columns;
      final endIndex = (startIndex + columns)
          .clamp(0, globalSearchService.searchForumResult.length);
      final rowItems = globalSearchService.searchForumResult.sublist(startIndex, endIndex);
      final remainingColumns = columns - rowItems.length;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...rowItems.map((thread) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ThreadListItemWidget(
                      thread: thread,
                      categoryId: thread.section,
                    ),
                  ),
                )),
            ...List.generate(
              remainingColumns,
              (index) => Expanded(child: Container()),
            ),
          ],
        ),
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
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: globalSearchService.searchPlaceholder.value.isEmpty
                              ? t.search.pleaseEnterSearchContent
                              : globalSearchService.searchPlaceholder.value,
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
                            initialSearch: globalSearchService.currentSearch.value,
                            initialSegment: SearchSegment.fromValue(
                                globalSearchService.selectedSegment.value),
                            onSearch: (searchInfo, segment) {
                              if (globalSearchService.selectedSegment.value != segment) {
                                globalSearchService.selectedSegment.value = segment;
                                globalSearchService.clearOtherSearchResult();
                              } else {
                                globalSearchService.selectedSegment.value = segment;
                              }
                              globalSearchService.fetchSearchResult(refresh: true);
                              _searchController.text = searchInfo;
                              Get.back();
                            },
                          ));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        globalSearchService.fetchSearchResult(refresh: true);
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
                        selected: {globalSearchService.selectedSegment.value},
                        onSelectionChanged: (Set<String> selection) {
                          if (selection.isNotEmpty) {
                            globalSearchService.selectedSegment.value =
                                selection.first;
                            _safeScrollToTop();
                            if (!globalSearchService.isCurrentResultInitialized) {
                              globalSearchService.fetchSearchResult();
                            }
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
              child: _buildSearchResult(context),
            ),
          ],
        ),
      ),
    );
  }
}
