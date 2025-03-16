import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/forum_list_controller.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_list_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';

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

class _ThreadListPageState extends State<ThreadListPage> with SingleTickerProviderStateMixin {
  late ThreadListRepository listSourceRepository;
  late ForumListController _forumListController;
  
  final ScrollController _scrollController = ScrollController();
  final RxString _categoryName = ''.obs;
  final RxString _categoryDescription = ''.obs;

  @override
  void initState() {
    super.initState();

    // 初始化论坛控制器
    _forumListController = Get.put(ForumListController(), tag: widget.categoryId);
    
    listSourceRepository = ThreadListRepository(categoryId: widget.categoryId, updateCategoryName: (name, description) {
      _categoryName.value = name;
      _categoryDescription.value = description;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    Get.delete<ForumListController>(tag: widget.categoryId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => 
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _categoryName.value,
              overflow: TextOverflow.ellipsis,
            ),
            if (_categoryDescription.value.isNotEmpty)
              Text(
                _categoryDescription.value,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        )
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
          // 添加分页/瀑布流切换按钮
          Obx(() => IconButton(
            icon: Icon(_forumListController.isPaginated.value 
                ? Icons.grid_view 
                : Icons.menu),
            onPressed: () {
              // 如果当前为瀑布流模式，则要执行刷新以清空数据
              if (!_forumListController.isPaginated.value) {
                listSourceRepository.refresh();
              }
              _forumListController.setPaginatedMode(!_forumListController.isPaginated.value);
            },
            tooltip: _forumListController.isPaginated.value 
                ? t.common.pagination.waterfall
                : t.common.pagination.pagination,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_forumListController.isPaginated.value) {
                _forumListController.refreshPageUI();
              } else {
                listSourceRepository.refresh();
              }
            },
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateThreadDialog(context, widget.categoryId),
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: Obx(() {
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
            itemBuilder: (context, thread, index) => ThreadListItemWidget(
              thread: thread,
              categoryId: widget.categoryId,
              onTap: () => _navigateToThreadDetail(thread),
            ),
          );
        } else {
          // 瀑布流模式
          return LoadingMoreCustomScrollView(
            key: ValueKey('thread_waterfall_$rebuildKey'),
            controller: _scrollController,
            slivers: <Widget>[
              LoadingMoreSliverList<ForumThreadModel>(
                SliverListConfig<ForumThreadModel>(
                  extendedListDelegate: const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, thread, index) => ThreadListItemWidget(
                    thread: thread,
                    categoryId: widget.categoryId,
                    onTap: () => _navigateToThreadDetail(thread),
                  ),
                  sourceList: listSourceRepository,
                  padding: EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 5.0,
                    bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0,
                  ),
                  indicatorBuilder: (context, status) => myLoadingMoreIndicator(
                    context,
                    status,
                    isSliver: true,
                    loadingMoreBase: listSourceRepository,
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  void _showCreateThreadDialog(BuildContext context, String categoryId) {
    UserService userService = Get.find<UserService>();
    if (!userService.isLogin) {
      AppService.switchGlobalDrawer();
      showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.warning));
      return;
    }
    Get.dialog(
      ForumPostDialog(
        onSubmit: () {
          // 刷新帖子列表
          listSourceRepository.refresh();
        },
        initCategoryId: categoryId,
      ),
    );
  }

  void _navigateToThreadDetail(ForumThreadModel thread) {
    // 导航到帖子详情页
    NaviService.navigateToForumThreadDetailPage(widget.categoryId, thread.id);
  }
} 