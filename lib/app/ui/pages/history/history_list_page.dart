import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'controllers/history_list_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';

class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HistoryListController allController;
  late HistoryListController videoController;
  late HistoryListController imageController;
  late HistoryListController postController;
  late HistoryListController threadController;

  final ScrollController _allScrollController = ScrollController();
  final ScrollController _videoScrollController = ScrollController();
  final ScrollController _imageScrollController = ScrollController();
  final ScrollController _postScrollController = ScrollController();
  final ScrollController _threadScrollController = ScrollController();

  int _lastTappedIndex = 0;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    final historyRepo = HistoryRepository();

    allController = Get.put(
      HistoryListController(
        historyRepository: historyRepo,
        itemType: 'all',
      ),
      tag: 'all',
    );

    videoController = Get.put(
      HistoryListController(
        historyRepository: historyRepo,
        itemType: 'video',
      ),
      tag: 'video',
    );

    imageController = Get.put(
      HistoryListController(
        historyRepository: historyRepo,
        itemType: 'image',
      ),
      tag: 'image',
    );

    postController = Get.put(
      HistoryListController(
        historyRepository: historyRepo,
        itemType: 'post',
      ),
      tag: 'post',
    );

    threadController = Get.put(
      HistoryListController(
        historyRepository: historyRepo,
        itemType: 'thread',
      ),
      tag: 'thread',
    );

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);

    _setupScrollControllers();
  }

  void _setupScrollControllers() {
    for (final controller in [
      _allScrollController,
      _videoScrollController,
      _imageScrollController,
      _postScrollController,
      _threadScrollController,
    ]) {
      controller.addListener(() {
        if (controller.offset >= 1000) {
          allController.showBackToTop.value = true;
        } else {
          allController.showBackToTop.value = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _disposeScrollControllers();
    Get.delete<HistoryListController>(tag: 'all');
    Get.delete<HistoryListController>(tag: 'video');
    Get.delete<HistoryListController>(tag: 'image');
    Get.delete<HistoryListController>(tag: 'post');
    Get.delete<HistoryListController>(tag: 'thread');
    super.dispose();
  }

  void _disposeScrollControllers() {
    _allScrollController.dispose();
    _videoScrollController.dispose();
    _imageScrollController.dispose();
    _postScrollController.dispose();
    _threadScrollController.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final previousController = _getControllerForIndex(_lastTappedIndex);
      if (previousController.isMultiSelect.value) {
        previousController.toggleMultiSelect();
      }
      _lastTappedIndex = _tabController.index;
      setState(() {});
    }
  }

  void _handleTabTap(int index) async {
    if (index == _lastTappedIndex) {
      final controller = _getControllerForIndex(index);
      final scrollController = _getScrollControllerForIndex(index);
      await _scrollToTopAndRefresh(controller.repository, scrollController);
    }
  }

  HistoryListController _getControllerForIndex(int index) {
    switch (index) {
      case 0:
        return allController;
      case 1:
        return videoController;
      case 2:
        return imageController;
      case 3:
        return postController;
      case 4:
        return threadController;
      default:
        return allController;
    }
  }

  ScrollController _getScrollControllerForIndex(int index) {
    switch (index) {
      case 0:
        return _allScrollController;
      case 1:
        return _videoScrollController;
      case 2:
        return _imageScrollController;
      case 3:
        return _postScrollController;
      case 4:
        return _threadScrollController;
      default:
        return _allScrollController;
    }
  }

  Future<void> _scrollToTopAndRefresh(
    LoadingMoreBase repository,
    ScrollController scrollController,
  ) async {
    if (!scrollController.hasClients) {
      isLoading.value = true;
      await repository.refresh();
      isLoading.value = false;
      return;
    }

    if (scrollController.position.pixels == 0.0) {
      isLoading.value = true;
      await repository.refresh();
      isLoading.value = false;
    } else {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      isLoading.value = true;
      await repository.refresh();
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),
        actions: [
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading.value
                    ? Container(
                        margin: const EdgeInsets.only(right: 16),
                        width: 20,
                        height: 20,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
          IconButton(
            onPressed: () => _showClearHistoryDialog(),
            icon: const Icon(Icons.delete_sweep),
            tooltip: slang.t.common.clearAllHistory,
          ),
          IconButton(
            onPressed: () {
              final controller = _getControllerForIndex(_tabController.index);
              controller.toggleMultiSelect();
            },
            icon: const Icon(Icons.checklist),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: _buildTabBar(),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryList(allController, _allScrollController),
              _buildHistoryList(videoController, _videoScrollController),
              _buildHistoryList(imageController, _imageScrollController),
              _buildHistoryList(postController, _postScrollController),
              _buildHistoryList(threadController, _threadScrollController),
            ],
          ),
          // 第一个tab的底部多选栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMultiSelectBar(allController),
          ),
          // 第二个tab的底部多选栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMultiSelectBar(videoController),
          ),
          // 第三个tab的底部多选栏
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMultiSelectBar(imageController),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMultiSelectBar(postController),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMultiSelectBar(threadController),
          ),
        ],
      ),
      floatingActionButton: Obx(() => allController.showBackToTop.value
          ? FloatingActionButton(
              onPressed: () {
                final scrollController =
                    _getScrollControllerForIndex(_tabController.index);
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ).paddingOnly(bottom: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0)
          : const SizedBox()),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: 400,
      margin: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: _handleTabTap,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.primary,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        padding: EdgeInsets.zero,
        tabs: [
          Tab(text: slang.t.common.all),
          Tab(text: slang.t.common.video),
          Tab(text: slang.t.common.gallery),
          Tab(text: slang.t.common.post),
          Tab(text: slang.t.forum.forum),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    HistoryListController controller,
    ScrollController scrollController,
  ) {
    return LoadingMoreCustomScrollView(
      controller: scrollController,
      slivers: [
        LoadingMoreSliverList<HistoryRecord>(
          SliverListConfig<HistoryRecord>(
            extendedListDelegate:
                const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
            ),
            itemBuilder: (context, record, index) =>
                _buildHistoryItem(context, record, controller),
            sourceList: controller.repository,
            padding: EdgeInsets.fromLTRB(
              5.0,
              5.0,
              5.0,
              Get.context != null ? MediaQuery.of(Get.context!).padding.bottom + 5.0 : 0,
            ),
            lastChildLayoutType: LastChildLayoutType.foot,
            indicatorBuilder: (context, status) => myLoadingMoreIndicator(
              context,
              status,
              isSliver: true,
              loadingMoreBase: controller.repository,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    HistoryRecord record,
    HistoryListController controller,
  ) {
    return Obx(() {
      final bool isSelected = controller.selectedRecords.contains(record.id);
      final bool isMultiSelect = controller.isMultiSelect.value;
      final dynamic originalData = record.getOriginalData();

      return Stack(
        children: [
          if (record.itemType == 'video')
            VideoCardListItemWidget(
              video: originalData,
              width: 200,
            )
          else if (record.itemType == 'image')
            ImageModelCardListItemWidget(
              imageModel: originalData,
              width: 200,
            )
          else if (record.itemType == 'post')
            PostCardListItemWidget(
              post: originalData,
            )
          else if (record.itemType == 'thread')
            ThreadListItemWidget(
              thread: originalData,
              categoryId: originalData.section,
            ),
          if (isMultiSelect)
            Positioned.fill(
              child: Material(
                color: Colors.black26,
                child: InkWell(
                  onTap: () => controller.toggleSelection(record.id),
                  child: Center(
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildMultiSelectBar(HistoryListController controller) {
    return Obx(() => controller.isMultiSelect.value
        ? BottomSheet(
            enableDrag: false,
            backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
            onClosing: () {},
            builder: (context) => SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Obx(() => Text(
                              slang.t.common.selectedRecords(
                                  num: controller.selectedRecords.length),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        const Spacer(),
                        IconButton(
                          onPressed: controller.toggleMultiSelect,
                          icon: const Icon(Icons.close),
                          tooltip: slang.t.common.exitEditMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.selectAll,
                            icon: Icon(
                              controller.isAllSelected
                                  ? Icons.deselect
                                  : Icons.select_all,
                            ),
                            label: Text(
                              controller.isAllSelected
                                  ? slang.t.common.cancelSelectAll
                                  : slang.t.common.selectAll,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _showDeleteConfirmDialog(controller),
                            icon: const Icon(Icons.delete),
                            label: Text(slang.t.common.delete),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox());
  }

  void _showDeleteConfirmDialog(HistoryListController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.common.confirmDelete),
        content: Text(slang.t.common.areYouSureYouWantToDeleteSelectedItems(
            num: controller.selectedRecords.length)),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppService.tryPop();
              controller.deleteSelected();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(slang.t.common.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final controller = _getControllerForIndex(_tabController.index);
    final t = slang.Translations.of(context);

    return TextField(
      decoration: InputDecoration(
        hintText: t.common.searchHistoryRecords,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        prefixIcon: const Icon(Icons.search),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onChanged: (value) => controller.search(value),
      controller: TextEditingController(text: controller.searchKeyword.value),
    );
  }

  void _showClearHistoryDialog() {
    final controller = _getControllerForIndex(_tabController.index);
    final itemType = controller.itemType;

    Get.dialog(
      AlertDialog(
        title: Text(slang.t.common.clearAllHistory),
        content: Text(slang.t.common.clearAllHistoryConfirm),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              await controller.clearHistoryByType(itemType);
              AppService.tryPop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(slang.t.common.confirm),
          ),
        ],
      ),
    );
  }
}
