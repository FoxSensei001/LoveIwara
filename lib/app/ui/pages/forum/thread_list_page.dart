import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_list_repository.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/forum_post_dialog.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
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
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;
  final RxBool _enableFloatingButton = true.obs;
  final RxString _categoryName = ''.obs;
  final RxString _categoryDescription = ''.obs;
  late AnimationController _floatingButtonController;
  final HistoryRepository _historyRepository = HistoryRepository();

  @override
  void initState() {
    super.initState();
    _floatingButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    listSourceRepository = ThreadListRepository(categoryId: widget.categoryId, updateCategoryName: (name, description) {
      _categoryName.value = name;
      _categoryDescription.value = description;
    });

    // 添加滚动监听
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        _showBackToTop.value = true;
        _floatingButtonController.forward();
      } else {
        _showBackToTop.value = false;
        _floatingButtonController.reverse();
      }
    });

    // 监听启用状态变化
    ever(_enableFloatingButton, (bool enabled) {
      if (!enabled) {
        _floatingButtonController.reverse();
      } else if (_showBackToTop.value) {
        _floatingButtonController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    listSourceRepository.dispose();
    _floatingButtonController.dispose();
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
          Obx(() => IconButton(
            icon: Icon(_enableFloatingButton.value ? Icons.vertical_align_top : Icons.vertical_align_top_outlined),
            onPressed: () {
              _enableFloatingButton.value = !_enableFloatingButton.value;

              showToastWidget(MDToastWidget(
                message: _enableFloatingButton.value ? t.common.disabledFloatingButtons : t.common.enabledFloatingButtons,
                type: MDToastType.success
              ));
            },
            tooltip: _enableFloatingButton.value ? t.common.disableFloatingButtons : t.common.enableFloatingButtons,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: !_enableFloatingButton.value 
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                : null,
              foregroundColor: !_enableFloatingButton.value 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => listSourceRepository.refresh(),
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
      body: LoadingMoreCustomScrollView(
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
      ),
      floatingActionButton: ScaleTransition(
        scale: _floatingButtonController,
        child: Obx(() => (_showBackToTop.value && _enableFloatingButton.value)
            ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ).paddingBottom(Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0)
            : const SizedBox()),
      ),
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
    // 记录浏览历史
    _historyRepository.addRecordWithCheck(HistoryRecord.fromThread(thread));
    // 导航到帖子详情页
    NaviService.navigateToForumThreadDetailPage(widget.categoryId, thread.id);
  }
} 