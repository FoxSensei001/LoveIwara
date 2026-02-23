import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/share_service.dart';
import 'package:i_iwara/app/ui/pages/play_list/controllers/play_list_detail_controller.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class PlayListDetailPage extends StatefulWidget {
  final String playlistId;
  final bool isMine;

  const PlayListDetailPage({
    super.key,
    required this.playlistId,
    required this.isMine,
  });

  @override
  State<PlayListDetailPage> createState() => _PlayListDetailPageState();
}

class _PlayListDetailPageState extends State<PlayListDetailPage> {
  late PlayListDetailController controller;
  final ScrollController _scrollController = ScrollController();
  final RxBool _showBackToTop = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      PlayListDetailController(playlistId: widget.playlistId),
    );

    // 添加滚动监听
    _scrollController.addListener(() {
      if (_scrollController.offset >= 1000) {
        _showBackToTop.value = true;
      } else {
        _showBackToTop.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.repository.dispose();
    Get.delete<PlayListDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => controller.repository.refresh(true),
            child: LoadingMoreCustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                LoadingMoreSliverList<Video>(
                  SliverListConfig<Video>(
                    extendedListDelegate:
                        const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 300,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                    itemBuilder: buildVideoItem,
                    sourceList: controller.repository,
                    padding: EdgeInsets.only(
                      left: 5.0,
                      right: 5.0,
                      top: 5.0,
                      bottom: MediaQuery.of(context).padding.bottom, // 添加底部安全区域
                    ),
                    lastChildLayoutType: LastChildLayoutType.foot,
                    indicatorBuilder: (context, status) =>
                        myLoadingMoreIndicator(
                          context,
                          status,
                          isSliver: true,
                          loadingMoreBase: controller.repository,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // 底部多选栏
        ],
      ),
      floatingActionButton: Obx(() {
        final bool isMultiSelect = controller.isMultiSelect.value;
        final bool showBackToTop = _showBackToTop.value;

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
                      if (controller.selectedVideos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Badge(
                            label: Text(
                              controller.selectedVideos.length.toString(),
                            ),
                            child: FloatingActionButton(
                              heroTag: 'playlistDeleteFAB',
                              onPressed: () => _showDeleteConfirmDialog(),
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
                        heroTag: 'playlistExitMultiSelectFAB',
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
                  heroTag: 'playlistBackToTopFAB',
                  onPressed: () {
                    _scrollController.animateTo(
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
              MediaQuery.of(context).padding.bottom,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget buildVideoItem(BuildContext context, Video video, int index) {
    return Obx(() {
      final bool isSelected = controller.selectedVideos.contains(video.id);
      final bool isMultiSelect = controller.isMultiSelect.value;

      return Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            VideoCardListItemWidget(video: video, width: 300),
            if (isMultiSelect)
              Positioned.fill(
                child: Material(
                  color: Colors.black26,
                  child: InkWell(
                    onTap: () => controller.toggleSelection(video.id),
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
        ),
      );
    });
  }

  void _showShareDialog() {
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.share),
        content: Text(slang.t.common.areYouSureYouWantToShareThisPlaylist),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              AppService.tryPop();
              ShareService.sharePlayListDetail(
                widget.playlistId,
                controller.playlistTitle.value,
              );
            },
            child: Text(slang.t.common.share),
          ),
        ],
      ),
    );
  }

  void _copyPlaylistLink() async {
    final String url =
        '${CommonConstants.iwaraBaseUrl}/playlist/${widget.playlistId}';
    try {
      await ShareService.copyToClipboard(url);
      Get.snackbar(
        slang.t.common.success,
        slang.t.galleryDetail.copyLink,
        snackPosition: SnackPosition.bottom,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        slang.t.common.error,
        slang.t.errors.failedToOperate,
        snackPosition: SnackPosition.bottom,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final t = slang.Translations.of(context);
    return AppBar(
      title: Obx(() => Text(controller.playlistTitle.value)),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditTitleDialog();
                break;
              case 'multiSelect':
                controller.toggleMultiSelect();
                break;
              case 'deleteCurPlaylist':
                // 删除播放列表功能已被移除
                break;
              case 'share':
                _showShareDialog();
                break;
              case 'copyLink':
                _copyPlaylistLink();
                break;
            }
          },
          itemBuilder: (context) => [
            if (widget.isMine)
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(t.common.editTitle),
                  ],
                ),
              ),
            if (widget.isMine)
              PopupMenuItem(
                value: 'multiSelect',
                child: Row(
                  children: [
                    const Icon(Icons.checklist),
                    const SizedBox(width: 8),
                    Text(t.common.editMode),
                  ],
                ),
              ),
            // 删除
            // const PopupMenuItem(
            //   value: 'deleteCurPlaylist',
            //   child: Row(
            //     children: [
            //       Icon(Icons.delete),
            //       SizedBox(width: 8),
            //       Text('删除此播放列表'),
            //     ],
            //   ),
            // ),
            // 分享
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share),
                  const SizedBox(width: 8),
                  Text(t.common.share),
                ],
              ),
            ),
            // 复制链接
            PopupMenuItem(
              value: 'copyLink',
              child: Row(
                children: [
                  const Icon(Icons.copy),
                  const SizedBox(width: 8),
                  Text(slang.t.galleryDetail.copyLink),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditTitleDialog() {
    final TextEditingController textController = TextEditingController(
      text: controller.playlistTitle.value,
    );

    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.editTitle),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: slang.t.common.pleaseEnterNewTitle,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.editTitle(textController.text.trim());
                AppService.tryPop();
              }
            },
            child: Text(slang.t.common.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.common.confirmDelete),
        content: Text(
          slang.t.common.areYouSureYouWantToDeleteSelectedItems(
            num: controller.selectedVideos.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.cancel),
          ),
          TextButton(
            onPressed: () async {
              AppService.tryPop();
              await controller.deleteSelected();
              // 删除完成后关闭多选模式
              if (controller.selectedVideos.isEmpty &&
                  controller.isMultiSelect.value) {
                controller.toggleMultiSelect();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(slang.t.common.delete),
          ),
        ],
      ),
    );
  }

  // /// 我靠，iwara压根就没有删除播放列表的功能
  // @Deprecated('此功能已被移除，iwara不支持删除播放列表')
  // void _showDeleteCurPlaylistConfirmDialog() {
  //   showAppDialog(
  //     AlertDialog(
  //       title: const Text('确认删除'),
  //       content: const Text('确定要删除此播放列表吗？'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('取消'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             controller.deleteCurPlaylist();
  //           },
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('删除'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
