import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/image_model_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/media_tile_list_loading_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/video_detail_info_skeleton_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';

import '../../../../common/enums/media_enums.dart';
import '../../../../utils/logger_utils.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/sliding_card_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/image_model_tile_list_item_widget.dart';
import '../video_detail/controllers/related_media_controller.dart';
import 'controllers/gallery_detail_controller.dart';

class GalleryDetailPage extends StatefulWidget {
  final String imageModelId;

  const GalleryDetailPage({super.key, required this.imageModelId});

  @override
  _GalleryDetailPageState createState() => _GalleryDetailPageState();
}

class _GalleryDetailPageState extends State<GalleryDetailPage> {
  late String imageModelId;
  late GalleryDetailController detailController;
  late CommentController commentController;
  late RelatedMediasController relatedMediasController;
  late OtherAuthorzMediasController otherAuthorzMediasController;
  late String uniqueTag;

  // 分配图库详情与附列表的宽度
  final sideColumnMinWidth = 400.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // dispose
  @override
  void dispose() {
    Get.delete<GalleryDetailController>(tag: uniqueTag);
    Get.delete<CommentController>(tag: uniqueTag);
    Get.delete<RelatedMediasController>(tag: uniqueTag);
    Get.delete<OtherAuthorzMediasController>(tag: uniqueTag);

    LogUtils.d('图库ID: $imageModelId 已销毁', 'GalleryDetailPage');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    imageModelId = widget.imageModelId;
    uniqueTag = UniqueKey().toString();

    if (imageModelId.isEmpty) {
      return;
    }
    LogUtils.d('图库ID: $imageModelId 初始化状态, $uniqueTag', 'GalleryDetailPage');

    // 初始化控制器
    detailController = Get.put(
      GalleryDetailController(imageModelId),
      tag: uniqueTag,
    );

    commentController = Get.put(
      CommentController(id: imageModelId, type: CommentType.image),
      tag: uniqueTag,
    );

    relatedMediasController = Get.put(
      RelatedMediasController(
          mediaId: imageModelId, mediaType: MediaType.IMAGE),
      tag: uniqueTag,
    );
  }

// 计算是否需要分两列
  bool _shouldUseWideScreenLayout(double screenHeight, double screenWidth) {
    // 固定使用1.7作为图库比例
    const double imageModelRatio = 1.7;
    // 图库的高度
    final imageModelHeight = screenWidth / imageModelRatio;
    // 如果图库高度超过屏幕高度的70%，并且屏幕宽度足够
    return imageModelHeight > screenHeight * 0.5;
  }

  Size _calcImageModelColumnWidthAndHeight(double screenWidth,
      double screenHeight, double sideColumnMinWidth, double paddingTop) {
    const double imageModelRatio = 1.7;
    LogUtils.d(
        '[DEBUG] screenWidth: $screenWidth, screenHeight: $screenHeight, imageModelRatio: $imageModelRatio, sideColumnMinWidth: $sideColumnMinWidth');

    double imageModelWidth = (screenHeight * 0.5) * imageModelRatio;
    double renderImageModelWidth;
    double renderImageModelHeight;

    if (imageModelWidth + sideColumnMinWidth < screenWidth) {
      renderImageModelWidth = imageModelWidth;
      renderImageModelHeight =
          renderImageModelWidth / imageModelRatio + paddingTop;
    } else {
      renderImageModelWidth = screenWidth - sideColumnMinWidth;
      renderImageModelHeight =
          renderImageModelWidth / imageModelRatio + paddingTop;
    }

    return Size(renderImageModelWidth, renderImageModelHeight);
  }

  void showCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // 顶部标题栏
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text(
                        '评论列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 添加评论按钮
                      TextButton.icon(
                        onPressed: () {
                          Get.dialog(
                            CommentInputDialog(
                              title: '发表评论',
                              submitText: '发表',
                              onSubmit: (text) async {
                                if (text.trim().isEmpty) {
                                  Get.snackbar('错误', '评论内容不能为空');
                                  return;
                                }
                                await commentController.postComment(text);
                              },
                            ),
                            barrierDismissible: true,
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                        label: const Text('发表评论'),
                      ),
                      // 关闭按钮
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // 评论列表
                Expanded(
                  child: Obx(() => CommentSection(
                      controller: commentController,
                      authorUserId: detailController.imageModelInfo.value?.user?.id)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageModelId.isEmpty) {
      return CommonErrorWidget(
        text: '无效的图库ID',
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回'),
          ),
        ],
      );
    }

    // 获取屏幕尺寸和内边距
    Size screenSize = MediaQuery.sizeOf(context);
    double paddingTop = MediaQuery.paddingOf(context).top;
    double screenHeight = screenSize.height;
    double screenWidth = screenSize.width;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (detailController.isCommentSheetVisible.value) {
            detailController.isCommentSheetVisible.toggle();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Obx(() {
          if (detailController.errorMessage.value != null) {
            return CommonErrorWidget(
              text: detailController.errorMessage.value ?? '在加载图库详情时出现了错误',
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('返回'),
                ),
              ],
            );
          }

          // 判断是否使用宽屏布局
          bool isWide = _shouldUseWideScreenLayout(screenHeight, screenWidth);
          Size renderImageModelSize = _calcImageModelColumnWidthAndHeight(
              screenWidth, screenHeight, sideColumnMinWidth, paddingTop);

          LogUtils.d(
              '[DEBUG] 是否使用宽屏布局: $isWide, 图库宽度: ${renderImageModelSize.width}, 图库高度: ${renderImageModelSize.height}',
              'GalleryDetailPage');

          if (isWide) {
            // 宽屏布局
            if (detailController.isImageModelInfoLoading.value) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧图库详情
                  SizedBox(
                    width: renderImageModelSize.width,
                    child: const MediaDetailInfoSkeletonWidget(),
                  ),
                  // 右侧评论列表
                  // Expanded(child: ImageModelTileListSkeletonWidget()),
                ],
              );
            }

            if (detailController.imageModelInfo.value == null) {
              return const MyEmptyWidget();
            }

            return PopScope(
              canPop: !detailController.isCommentSheetVisible.value,
              onPopInvokedWithResult: (bool didPop, dynamic result) {
                LogUtils.i(
                    '图库内部的PopScope被触发 $didPop, $result, ${!detailController.isCommentSheetVisible.value}',
                    'GalleryDetailPage');
                if (detailController.isCommentSheetVisible.value) {
                  detailController.isCommentSheetVisible.toggle();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: renderImageModelSize.width,
                    child: SingleChildScrollView(
                      physics: detailController.isHoveringHorizontalList.value
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageModelDetailContent(
                            controller: detailController,
                            paddingTop: paddingTop,
                            imageModelHeight: renderImageModelSize.height,
                            imageModelWidth: renderImageModelSize.width,
                          ),
                          CommentEntryAreaButtonWidget(
                              commentController: commentController,
                              onClickButton: () {
                                showCommentModal(context);
                              }).paddingVertical(16),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // 给个假区域默认占位整个容器高度
                        Container(
                          height: double.infinity,
                        ),
                        // 显示区域
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: paddingTop + 16),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: const Text('作者的其他图库',
                                      style: TextStyle(fontSize: 18))),
                              const SizedBox(height: 16),
                              // 作者的其他图库
                              if (detailController
                                          .otherAuthorzImageModelsController !=
                                      null &&
                                  detailController
                                      .otherAuthorzImageModelsController!
                                      .isLoading
                                      .value)
                                const MediaTileListSkeletonWidget()
                              else if (detailController
                                  .otherAuthorzImageModelsController!
                                  .imageModels
                                  .isEmpty)
                                const MyEmptyWidget()
                              else ...[
                                // 构建作者的其他图库列表
                                for (var imageModel in detailController
                                    .otherAuthorzImageModelsController!
                                    .imageModels)
                                  ImageModelTileListItem(
                                      imageModel: imageModel),
                              ],
                              const SizedBox(height: 16),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: const Text('相关图库',
                                      style: TextStyle(fontSize: 18))),
                              const SizedBox(height: 16),
                              if (relatedMediasController.isLoading.value)
                                const MediaTileListSkeletonWidget()
                              else if (relatedMediasController
                                  .imageModels.isEmpty)
                                const MyEmptyWidget()
                              else
                                // 构建相关图库列表
                                for (var imageModel
                                    in relatedMediasController.imageModels)
                                  ImageModelTileListItem(
                                      imageModel: imageModel),
                            ],
                          ),
                        ),
                        // SlidingCard 仅覆盖右侧区域
                        SlidingCard(
                          isVisible:
                              detailController.isCommentSheetVisible.value,
                          onDismiss: () =>
                              detailController.isCommentSheetVisible.toggle(),
                          title: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Text(
                                  '评论列表',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                // 添加发表评论按钮
                                TextButton.icon(
                                  onPressed: () {
                                    showCommentModal(context);
                                  },
                                  icon: const Icon(Icons.add_comment),
                                  label: const Text('发表评论'),
                                ),
                                // 关闭按钮
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => detailController
                                      .isCommentSheetVisible
                                      .toggle(),
                                ),
                              ],
                            ),
                          ),
                          child: CommentSection(
                              controller: commentController,
                              authorUserId: detailController
                                  .imageModelInfo.value?.user?.id),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            if (detailController.isImageModelInfoLoading.value) {
              return const MediaDetailInfoSkeletonWidget();
            }

            if (detailController.imageModelInfo.value == null) {
              return const MyEmptyWidget();
            }

            return PopScope(
              canPop: !detailController.isCommentSheetVisible.value,
              onPopInvokedWithResult: (bool didPop, dynamic result) {
                if (detailController.isCommentSheetVisible.value) {
                  detailController.isCommentSheetVisible.toggle();
                }
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: detailController.isHoveringHorizontalList.value
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 图库详情
                        ImageModelDetailContent(
                          controller: detailController,
                          paddingTop: paddingTop,
                        ),
                        // 评论区域
                        Container(
                            padding: const EdgeInsets.all(16),
                            child: CommentEntryAreaButtonWidget(
                              commentController: commentController,
                              onClickButton: () {
                                showCommentModal(context);
                              },
                            ).paddingVertical(16)),
                        // 作者的其他图库
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text('作者的其他图库',
                                style: TextStyle(fontSize: 18))),
                        if (detailController
                                    .otherAuthorzImageModelsController !=
                                null &&
                            detailController.otherAuthorzImageModelsController!
                                .isLoading.value)
                          const MediaTileListSkeletonWidget()
                        else if (detailController
                            .otherAuthorzImageModelsController!
                            .imageModels
                            .isEmpty)
                          const MyEmptyWidget()
                        else ...[
                          // 构建作者的其他图库列表
                          for (var imageModel in detailController
                              .otherAuthorzImageModelsController!.imageModels)
                            ImageModelTileListItem(imageModel: imageModel),
                        ],
                        // 相关图库
                        const SizedBox(height: 16),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const Text('相关图库',
                                style: TextStyle(fontSize: 18))),
                        const SizedBox(height: 16),
                        if (relatedMediasController.isLoading.value)
                          const MediaTileListSkeletonWidget()
                        else if (relatedMediasController.imageModels.isEmpty)
                          const MyEmptyWidget()
                        else ...[
                          // 构建相关图库列表
                          for (var imageModel
                              in relatedMediasController.imageModels)
                            ImageModelTileListItem(imageModel: imageModel),
                        ],
                      ],
                    ),
                  ),
                  SlidingCard(
                    isVisible: detailController.isCommentSheetVisible.value,
                    onDismiss: () =>
                        detailController.isCommentSheetVisible.toggle(),
                    title: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            '评论列表',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // 添加发表评论按钮
                          TextButton.icon(
                            onPressed: () {
                              showCommentModal(context);
                            },
                            icon: const Icon(Icons.add_comment),
                            label: const Text('发表评论'),
                          ),
                          // 关闭按钮
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                detailController.isCommentSheetVisible.toggle(),
                          ),
                        ],
                      ),
                    ),
                    child: CommentSection(
                        controller: commentController,
                        authorUserId:
                            detailController.imageModelInfo.value?.user?.id),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
