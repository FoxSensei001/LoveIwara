import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:oktoast/oktoast.dart';
import 'controllers/history_list_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

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
      HistoryListController(historyRepository: historyRepo, itemType: 'all'),
      tag: 'all',
    );

    videoController = Get.put(
      HistoryListController(historyRepository: historyRepo, itemType: 'video'),
      tag: 'video',
    );

    imageController = Get.put(
      HistoryListController(historyRepository: historyRepo, itemType: 'image'),
      tag: 'image',
    );

    postController = Get.put(
      HistoryListController(historyRepository: historyRepo, itemType: 'post'),
      tag: 'post',
    );

    threadController = Get.put(
      HistoryListController(historyRepository: historyRepo, itemType: 'thread'),
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

  Future<void> _selectDateRange() async {
    final controller = _getControllerForIndex(_tabController.index);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );

    if (picked != null && picked != controller.selectedDateRange.value) {
      controller.setDateRange(picked);
    }
  }

  void _clearDateRange() {
    final controller = _getControllerForIndex(_tabController.index);
    controller.setDateRange(null);
  }

  void _showFilterSheet() {
    final controller = _getControllerForIndex(_tabController.index);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final media = MediaQuery.of(context);
        final double bottomInset = media.viewInsets.bottom;
        final double bottomPadding = computeBottomSafeInset(media);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.4,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomInset + bottomPadding + 16,
                top: 8,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                        children: [
                          Text(
                            slang.t.common.selectDateRange,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => AppService.tryPop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 排序开关：创建时间/更新时间（倒序）
                      Obx(
                        () => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            controller.orderByUpdated.value
                                ? slang.t.common.updatedAt
                                : slang.t.common.publishedAt,
                          ),
                          subtitle: const Text('(DESC)'),
                          value: controller.orderByUpdated.value,
                          onChanged: (v) => controller.setOrderByUpdated(v),
                          secondary: const Icon(Icons.swap_vert),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 时间区间：按钮一行 + 结果单独下一行
                      Obx(() {
                        final dateRange = controller.selectedDateRange.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(slang.t.common.selectDateRange),
                                ),
                                if (dateRange != null)
                                  IconButton(
                                    tooltip: slang.t.common.clearDateRange,
                                    icon: const Icon(Icons.clear),
                                    onPressed: _clearDateRange,
                                  ),
                                FilledButton(
                                  onPressed: _selectDateRange,
                                  child: Text(slang.t.common.selectDateRange),
                                ),
                              ],
                            ),
                            if (dateRange != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 32,
                                ),
                                child: Text(
                                  '${CommonUtils.formatDate(dateRange.start)} - ${CommonUtils.formatDate(dateRange.end)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),
        actions: [
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading.value
                  ? Container(
                      margin: const EdgeInsets.only(right: 16),
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: slang.t.common.selectDateRange,
          ),
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
        ],
      ),
      floatingActionButton: Obx(() {
        final controller = _getControllerForIndex(_tabController.index);
        final bool isMultiSelect = controller.isMultiSelect.value;
        final bool showBackToTop = allController.showBackToTop.value;

        if (!isMultiSelect && !showBackToTop) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isMultiSelect)
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.selectedRecords.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Badge(
                            label: Text(
                              controller.selectedRecords.length.toString(),
                            ),
                            child: FloatingActionButton(
                              heroTag: 'historyDeleteFAB',
                              onPressed: () =>
                                  _showDeleteConfirmDialog(controller),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                              child: const Icon(Icons.delete),
                            ),
                          ),
                        ),
                      FloatingActionButton(
                        heroTag: 'historyExitMultiSelectFAB',
                        onPressed: () => controller.toggleMultiSelect(),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),
              if (showBackToTop)
                FloatingActionButton(
                  heroTag: 'historyBackToTopFAB',
                  onPressed: () {
                    final scrollController = _getScrollControllerForIndex(
                      _tabController.index,
                    );
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Icon(Icons.arrow_upward),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ).paddingOnly(
          bottom:
              (isMultiSelect ? 120.0 : 0.0) +
              computeBottomSafeInset(MediaQuery.of(context)),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: 400,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              computeBottomSafeInset(MediaQuery.of(context)) + 5.0,
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

      return SizedBox(
        width: 200,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width < 600 ? 6 : 8,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (record.itemType == 'video')
                    VideoCardListItemWidget(video: originalData, width: 200)
                  else if (record.itemType == 'image')
                    ImageModelCardListItemWidget(
                      imageModel: originalData,
                      width: 200,
                    )
                  else if (record.itemType == 'post')
                    PostCardListItemWidget(post: originalData)
                  else if (record.itemType == 'thread')
                    ThreadListItemWidget(
                      thread: originalData,
                      categoryId: originalData.section,
                    ),
                  _buildHistoryItemFooter(record, controller),
                ],
              ),
              if (isMultiSelect)
                Positioned.fill(
                  child: Material(
                    color: Colors.black26,
                    child: InkWell(
                      onTap: () => controller.toggleSelection(record.id),
                      child: Center(
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHistoryItemFooter(
    HistoryRecord record,
    HistoryListController controller,
  ) {
    // 获取类型对应的颜色和图标
    final (color, icon) = _getItemTypeStyle(record.itemType);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示时间
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Obx(() {
                final useUpdated = controller.orderByUpdated.value;
                final dt = useUpdated ? record.updatedAt : record.createdAt;
                return Text(
                  CommonUtils.formatFriendlyTimestamp(dt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // 显示类型
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      _getItemTypeText(record.itemType),
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 删除按钮
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _showDeleteRecordDialog(record, controller),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getItemTypeStyle(String type) {
    switch (type) {
      case 'video':
        return (Colors.blue, Icons.play_circle_outline);
      case 'image':
        return (Colors.green, Icons.image_outlined);
      case 'post':
        return (Colors.orange, Icons.article_outlined);
      case 'thread':
        return (Colors.purple, Icons.forum_outlined);
      default:
        return (Colors.grey, Icons.help_outline);
    }
  }

  String _getItemTypeText(String type) {
    switch (type) {
      case 'video':
        return slang.t.common.video;
      case 'image':
        return slang.t.common.gallery;
      case 'post':
        return slang.t.common.post;
      case 'thread':
        return slang.t.forum.forum;
      default:
        return type;
    }
  }

  void _showDeleteRecordDialog(
    HistoryRecord record,
    HistoryListController controller,
  ) {
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.confirmDelete),
        content: Text(
          slang.t.common.areYouSureYouWantToDeleteSelectedItems(num: 1),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              AppService.tryPop();
              await controller.historyDatabaseRepository.deleteRecord(
                record.id,
              );
              controller.repository.refresh();
              showToastWidget(
                MDToastWidget(
                  message: slang.t.common.success,
                  type: MDToastType.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(slang.t.common.delete),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(HistoryListController controller) {
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.confirmDelete),
        content: Text(
          slang.t.common.areYouSureYouWantToDeleteSelectedItems(
            num: controller.selectedRecords.length,
          ),
        ),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.search),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      onChanged: (value) => controller.search(value),
      controller: TextEditingController(text: controller.searchKeyword.value),
    );
  }

  void _showClearHistoryDialog() {
    final controller = _getControllerForIndex(_tabController.index);
    final itemType = controller.itemType;

    showAppDialog(
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(slang.t.common.confirm),
          ),
        ],
      ),
    );
  }
}
