import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/comment/widgets/comment_input_dialog.dart';
import 'package:i_iwara/app/ui/pages/home/home_navigation_layout.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/media_tile_list_loading_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/video_detail_content_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/video_detail_info_skeleton_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../../common/enums/media_enums.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/sliding_card_widget.dart';
import '../comment/controllers/comment_controller.dart';
import '../comment/widgets/comment_entry_area_widget.dart';
import '../comment/widgets/comment_section_widget.dart';
import '../popular_media_list/widgets/video_tile_list_item_widget.dart';
import 'controllers/my_video_state_controller.dart';
import 'controllers/related_media_controller.dart';
import '../../../../i18n/strings.g.dart' as slang;

class MyVideoDetailPage extends StatefulWidget {
  final String videoId;

  const MyVideoDetailPage({super.key, required this.videoId});

  @override
  _MyVideoDetailPageState createState() => _MyVideoDetailPageState();
}

class _MyVideoDetailPageState extends State<MyVideoDetailPage> {
  final String uniqueTag = UniqueKey().toString();
  late String videoId;
  final AppService appService = Get.find();

  late MyVideoStateController controller;
  late CommentController commentController;
  late RelatedMediasController relatedVideoController;

  @override
  void initState() {
    super.initState();
    videoId = widget.videoId;

    if (videoId.isEmpty) {
      return;
    }

    // 初始化控制器
    controller = Get.put(
      MyVideoStateController(videoId),
      tag: uniqueTag,
    );

    commentController = Get.put(
      CommentController(id: videoId, type: CommentType.video),
      tag: uniqueTag,
    );

    relatedVideoController = Get.put(
      RelatedMediasController(mediaId: videoId, mediaType: MediaType.VIDEO),
      tag: uniqueTag,
    );

    // 注册路由变化回调
    HomeNavigationLayout.homeNavigatorObserver
        .addRouteChangeCallback(_onRouteChange);
  }

  /// 添加路由变化回调
  /// @params
  /// - `route`: 当前路由
  /// - `previousRoute`: 上一个路由
  void _onRouteChange(Route? route, Route? previousRoute) {
    LogUtils.d(
        "当前路由: ${route?.settings.name}, 上一个路由: ${previousRoute?.settings.name}, 操作类型: ${route?.isActive == true ? "进入" : "离开"}",
        '详情页路由监听');

     // 如果操作类型是离开，上一个路由contains Routes.VIDEO_DETAIL，则setDefaultBrightness
    if (route?.isActive == false && previousRoute?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true) {
      controller.setDefaultBrightness();
    }

    // 如果操作类型是进入，上一个路由contains Routes.VIDEO_DETAIL，则暂停
    if (route?.isActive == true && previousRoute?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true) {
      // 如果当前正在loading，则不pause
      if (!controller.player.state.buffering) {
        controller.player.pause();
      }
    }

    // 如果当前路由contains Routes.VIDEO_DETAIL，且操作类型是离开则resetBrightness
    if (route?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true && previousRoute?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == false) {
      ScreenBrightness().resetScreenBrightness();
    }
    

    // 如果是从detail到其他页面，且当前为 应用全屏状态，则恢复UI
    if (previousRoute != null &&
        previousRoute.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) ==
            false &&
        controller.isDesktopAppFullScreen.value) {
      if (route?.settings.name != null) {
        appService.showSystemUI();
      }
    }
  }

  @override
  void dispose() {
    // 移除路由变化回调
    HomeNavigationLayout.homeNavigatorObserver
        .removeRouteChangeCallback(_onRouteChange);

    // 尝试删除controller
    try {
      Get.delete<MyVideoStateController>(tag: uniqueTag);
      Get.delete<CommentController>(tag: uniqueTag);
      Get.delete<RelatedMediasController>(tag: uniqueTag);
    } catch (e) {
      LogUtils.e('删除控制器失败', error: e, tag: 'video_detail_page_v2');
    }

    super.dispose();
  }

  // 计算是否需要分两列
  bool _shouldUseWideScreenLayout(
      double screenHeight, double screenWidth, double videoRatio) {
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    // 视频的高度
    final videoHeight = screenWidth / effectiveVideoRatio;
    // 如果视频高度超过屏幕高度的70%，并且屏幕宽度足够
    return videoHeight > screenHeight * 0.7;
  }

  Size _calcVideoColumnWidthAndHeight(double screenWidth, double screenHeight,
      double videoRatio, double sideColumnMinWidth, double paddingTop) {
    LogUtils.d(
        '[DEBUG] screenWidth: $screenWidth, screenHeight: $screenHeight, videoRatio: $videoRatio, sideColumnMinWidth: $sideColumnMinWidth',
        'video_detail_page_v2');
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    // 先获取70%屏幕高度时的视频宽度
    double videoWidth = (screenHeight * 0.7) * effectiveVideoRatio;
    // 如果视频宽度加上侧边栏宽度小于屏幕宽度，就使用这个宽度
    double renderVideoWidth;
    double renderVideoHeight;
    if (videoWidth + sideColumnMinWidth < screenWidth) {
      renderVideoWidth = videoWidth;
      renderVideoHeight = renderVideoWidth / effectiveVideoRatio + paddingTop;
    } else {
      renderVideoWidth = screenWidth - sideColumnMinWidth;
      renderVideoHeight = renderVideoWidth / effectiveVideoRatio + paddingTop;
    }

    return Size(renderVideoWidth, renderVideoHeight);
  }

  void showCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final t = slang.Translations.of(context);
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
                      Text(
                        t.common.commentList,
                        style: const TextStyle(
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
                              title: t.common.sendComment,
                              submitText: t.common.send,
                              onSubmit: (text) async {
                                if (text.trim().isEmpty) {
                                  showToastWidget(MDToastWidget(
                                      message: t.errors.commentCanNotBeEmpty,
                                      type: MDToastType.error), position: ToastPosition.bottom);
                                  return;
                                }
                                final UserService userService = Get.find();
                                if (!userService.isLogin) {
                                  showToastWidget(MDToastWidget(
                                      message: t.errors.pleaseLoginFirst,
                                      type: MDToastType.error), position: ToastPosition.bottom);
                                  Get.toNamed(Routes.LOGIN);
                                  return;
                                }
                                await commentController.postComment(text);
                              },
                            ),
                            barrierDismissible: true,
                          );
                        },
                        icon: const Icon(Icons.add_comment),
                        label: Text(t.common.sendComment),
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
                      authorUserId: controller.videoInfo.value?.user?.id)),
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
    final t = slang.Translations.of(context);
    if (videoId.isEmpty) {
      return CommonErrorWidget(
        text: t.videoDetail.videoIdIsEmpty,
        children: [
          ElevatedButton(
            onPressed: () => AppService.tryPop,
            child: Text(t.common.back),
          ),
        ],
      );
    }

    // 将 MediaQuery 的值缓存下来，避免重复计算
    final Size screenSize = MediaQuery.sizeOf(context);
    final double paddingTop = MediaQuery.paddingOf(context).top;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // 使用 RepaintBoundary 包裹整个 Scaffold body
    return Scaffold(
      body: RepaintBoundary(
        child: Obx(() {
          // 添加画中画模式判断
          if (controller.isPiPMode.value) {
            return MyVideoScreen(
              myVideoStateController: controller,
              isFullScreen: false,
            );
          }
          if (controller.mainErrorWidget.value != null) {
            return controller.mainErrorWidget.value!;
          }
          bool isDesktopAppFullScreen = controller.isDesktopAppFullScreen.value;

          // 判断是否使用宽屏布局
          bool isWide = _shouldUseWideScreenLayout(
              screenHeight, screenWidth, controller.aspectRatio.value);
          // 分配视频详情与附列表的宽度
          const sideColumnMinWidth = 400.0;
          Size renderVideoSize = _calcVideoColumnWidthAndHeight(
              screenWidth,
              screenHeight,
              controller.aspectRatio.value,
              sideColumnMinWidth,
              paddingTop);

          if (isWide) {
            // 宽屏布局
            if (controller.isVideoInfoLoading.value) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧视频详情
                  SizedBox(
                    width: renderVideoSize.width,
                    child: const MediaDetailInfoSkeletonWidget(),
                  ),
                  // 右侧评论列表
                  const Expanded(child: MediaTileListSkeletonWidget()),
                ],
              );
            }

            // 如果videoInfo不为空且videoInfo!.isPrivate为true，则显示私有视频提示
            if (controller.videoInfo.value?.private == true) {
              return const SizedBox.shrink();
            }

            return PopScope(
              canPop: !controller.isCommentSheetVisible.value,
              onPopInvokedWithResult: (bool didPop, dynamic result) {
                if (controller.isCommentSheetVisible.value) {
                  controller.isCommentSheetVisible.toggle();
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧视频详情，使用SingleChildScrollView以确保内容可滚动
                  SizedBox(
                    width: isDesktopAppFullScreen
                        ? screenWidth
                        : renderVideoSize.width,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VideoDetailContent(
                            controller: controller,
                            paddingTop: paddingTop,
                            videoHeight: renderVideoSize.height,
                            videoWidth: renderVideoSize.width,
                          ),
                          if (!isDesktopAppFullScreen)...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: CommentEntryAreaButtonWidget(
                                  commentController: commentController,
                                  onClickButton: () {
                                    showCommentModal(context);
                                  }),
                            ),
                            const SafeArea(child: SizedBox.shrink()),
                          ]
                        ],
                      ),
                    ),
                  ),
                  if (!controller.isDesktopAppFullScreen.value)
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 相关视频
                                Container(
                                    height: paddingTop,
                                    color: Colors.transparent),
                                // 作者的其他视频
                                if (controller.otherAuthorzVideosController !=
                                        null &&
                                    controller.otherAuthorzVideosController!
                                        .isLoading.value) ...[
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(t.videoDetail.authorOtherVideos,
                                          style: const TextStyle(fontSize: 18))),
                                  const MediaTileListSkeletonWidget()
                                ] else if (controller
                                            .otherAuthorzVideosController !=
                                        null &&
                                    controller.otherAuthorzVideosController!
                                        .videos.isEmpty)
                                  const SizedBox.shrink()
                                else ...[
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(t.videoDetail.authorOtherVideos,
                                          style: const TextStyle(fontSize: 18))),
                                  // 构建作者的其他视频列表
                                  if (controller.otherAuthorzVideosController !=
                                      null)
                                    for (var video in controller
                                        .otherAuthorzVideosController!.videos)
                                      VideoTileListItem(video: video),
                                ],
                                if (relatedVideoController.isLoading.value) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(t.videoDetail.relatedVideos,
                                          style: const TextStyle(fontSize: 18))),
                                  const MediaTileListSkeletonWidget()
                                ] else if (relatedVideoController.videos.isEmpty)
                                  const SizedBox.shrink()
                                else ...[
                                  const SizedBox(height: 16),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(t.videoDetail.relatedVideos,
                                          style: const TextStyle(fontSize: 18))),
                                  // 构建相关视频列表
                                  for (var video in relatedVideoController.videos)
                                    VideoTileListItem(video: video),
                                ],
                                const SafeArea(child: SizedBox.shrink()),
                              ],
                            ),
                          ),
                          // SlidingCard 仅覆盖右侧区域
                          Obx(() => SlidingCard(
                                isVisible: controller.isCommentSheetVisible.value,
                                onDismiss: () =>
                                    controller.isCommentSheetVisible.toggle(),
                                title: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Text(
                                        t.common.commentList,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      // 添加发表评论按钮
                                      TextButton.icon(
                                        onPressed: () {
                                          Get.dialog(
                                            CommentInputDialog(
                                              title: t.common.sendComment,
                                              submitText: t.common.send,
                                              onSubmit: (text) async {
                                                if (text.trim().isEmpty) {
                                                  showToastWidget(MDToastWidget(
                                                      message: t.errors
                                                          .commentCanNotBeEmpty,
                                                      type: MDToastType.error), position: ToastPosition.bottom);
                                                  return;
                                                }
                                                final UserService userService =
                                                    Get.find();
                                                if (!userService.isLogin) {
                                                  showToastWidget(MDToastWidget(
                                                      message:
                                                          t.errors.pleaseLoginFirst,
                                                      type: MDToastType.error), position: ToastPosition.bottom);
                                                  Get.toNamed(Routes.LOGIN);
                                                  return;
                                                }
                                                await commentController
                                                    .postComment(text);
                                              },
                                            ),
                                            barrierDismissible: true,
                                          );
                                        },
                                        icon: const Icon(Icons.add_comment),
                                        label: Text(t.common.sendComment),
                                      ),
                                      // 关闭按钮
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => controller
                                            .isCommentSheetVisible
                                            .toggle(),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Obx(() => CommentSection(
                                    controller: commentController,
                                    authorUserId:
                                        controller.videoInfo.value?.user?.id)),
                              )),
                        ],
                      ),
                    )
                ],
              ),
            );
          } else {
            // 窄屏布局，使用Stack 覆盖整个屏幕
            if (controller.isVideoInfoLoading.value) {
              return const MediaDetailInfoSkeletonWidget();
            }
            return PopScope(
              canPop: !controller.isCommentSheetVisible.value,
              onPopInvokedWithResult: (bool didPop, dynamic result) {
                if (controller.isCommentSheetVisible.value) {
                  controller.isCommentSheetVisible.toggle();
                }
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 视频详情
                        VideoDetailContent(
                          controller: controller,
                          paddingTop: paddingTop,
                        ),
                        if (!controller.isDesktopAppFullScreen.value) ...[
                          // 评论区域
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: CommentEntryAreaButtonWidget(
                              commentController: commentController,
                              onClickButton: () {
                                showCommentModal(context);
                              },
                            ),
                          ),
                          // 作者的其他视频
                          if (controller.otherAuthorzVideosController != null &&
                              controller.otherAuthorzVideosController!.isLoading
                                  .value) ...[
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(t.videoDetail.authorOtherVideos,
                                    style: const TextStyle(fontSize: 18))),
                            const MediaTileListSkeletonWidget()
                          ] else if (controller.otherAuthorzVideosController !=
                                  null &&
                              controller
                                  .otherAuthorzVideosController!.videos.isEmpty)
                            const SizedBox.shrink()
                          else ...[
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(t.videoDetail.authorOtherVideos,
                                    style: const TextStyle(fontSize: 18))),
                            // 构建作者的其他视频列表
                            if (controller.otherAuthorzVideosController != null)
                              for (var video in controller
                                  .otherAuthorzVideosController!.videos)
                                VideoTileListItem(video: video),
                          ],
                          // 相关视频
                          if (relatedVideoController.isLoading.value) ...[
                            const SizedBox(height: 16),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(t.videoDetail.relatedVideos,
                                    style: const TextStyle(fontSize: 18))),
                            const MediaTileListSkeletonWidget()
                          ] else if (relatedVideoController.videos.isEmpty)
                            const SizedBox.shrink()
                          else ...[
                            const SizedBox(height: 16),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(t.videoDetail.relatedVideos,
                                    style: const TextStyle(fontSize: 18))),
                            // 构建相关视频列表
                            for (var video in relatedVideoController.videos)
                              VideoTileListItem(video: video),
                          ],
                          const SafeArea(child: SizedBox.shrink()),
                        ]
                      ],
                    ),
                  ),
                  if (!controller.isDesktopAppFullScreen.value)
                    Obx(() => SlidingCard(
                          isVisible: controller.isCommentSheetVisible.value,
                          onDismiss: () =>
                              controller.isCommentSheetVisible.toggle(),
                          title: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  t.common.commentList,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // 添加发表评论按钮
                                TextButton.icon(
                                  onPressed: () {
                                    Get.dialog(
                                      CommentInputDialog(
                                        title: t.common.sendComment,
                                        submitText: t.common.send,
                                        onSubmit: (text) async {
                                          if (text.trim().isEmpty) {
                                            showToastWidget(MDToastWidget(
                                                message:
                                                    t.errors.commentCanNotBeEmpty,
                                                type: MDToastType.error), position: ToastPosition.bottom);
                                            return;
                                          }
                                          final UserService userService =
                                              Get.find();
                                          if (!userService.isLogin) {
                                            showToastWidget(MDToastWidget(
                                                message:
                                                    t.errors.pleaseLoginFirst,
                                                type: MDToastType.error), position: ToastPosition.bottom);
                                            Get.toNamed(Routes.LOGIN);
                                            return;
                                          }
                                          await commentController
                                              .postComment(text);
                                        },
                                      ),
                                      barrierDismissible: true,
                                    );
                                  },
                                  icon: const Icon(Icons.add_comment),
                                  label: Text(t.common.sendComment),
                                ),
                                // 关闭按钮
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      controller.isCommentSheetVisible.toggle(),
                                ),
                              ],
                            ),
                          ),
                          child: Obx(() => CommentSection(
                              controller: commentController,
                              authorUserId:
                                  controller.videoInfo.value?.user?.id)),
                        )),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
