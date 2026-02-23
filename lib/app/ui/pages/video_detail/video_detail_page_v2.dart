import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/local_video_detail/widgets/local_video_info_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/skeletons/video_detail_info_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/skeletons/video_detail_wide_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/video_info_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/comments_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/related_videos_tab_widget.dart';
import 'package:i_iwara/app/ui/widgets/error_widget.dart'
    show CommonErrorWidget;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/enums/media_enums.dart';
import '../comment/controllers/comment_controller.dart';
import 'controllers/related_media_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class MyVideoDetailPage extends StatefulWidget {
  final String videoId;
  final Map<String, dynamic>? extData;

  // 本地视频模式参数
  final String? localPath;
  final DownloadTask? localTask;
  final List<DownloadTask>? localAllQualityTasks;

  const MyVideoDetailPage({
    super.key,
    required this.videoId,
    this.extData = const {},
    this.localPath,
    this.localTask,
    this.localAllQualityTasks,
  });

  @override
  MyVideoDetailPageState createState() => MyVideoDetailPageState();
}

class MyVideoDetailPageState extends State<MyVideoDetailPage>
    with TickerProviderStateMixin, RouteAware {
  final String uniqueTag = UniqueKey().toString();
  late String videoId;
  final AppService appService = Get.find();

  // 本地视频模式标识
  late bool isLocalMode;

  late MyVideoStateController controller;
  CommentController? commentController;
  RelatedMediasController? relatedVideoController;

  // Tab控制器
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    videoId = widget.videoId;
    isLocalMode = widget.localPath != null;

    // 初始化Tab控制器（本地模式只有1个tab，在线模式有3个tab）
    tabController = TabController(length: isLocalMode ? 1 : 3, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    if (videoId.isEmpty && !isLocalMode) {
      return;
    }

    // 初始化控制器
    try {
      if (isLocalMode) {
        // 本地视频模式：使用 forLocalVideo 构造函数
        controller = Get.put(
          MyVideoStateController.forLocalVideo(
            localPath: widget.localPath!,
            task: widget.localTask,
            allQualityTasks: widget.localAllQualityTasks,
          ),
          tag: uniqueTag,
        );
      } else {
        // 在线视频模式：使用普通构造函数
        controller = Get.put(
          MyVideoStateController(videoId, extData: widget.extData),
          tag: uniqueTag,
        );

        // 只在在线模式下初始化评论和相关视频控制器
        commentController = Get.put(
          CommentController(id: videoId, type: CommentType.video),
          tag: uniqueTag,
        );

        relatedVideoController = Get.put(
          RelatedMediasController(mediaId: videoId, mediaType: MediaType.VIDEO),
          tag: uniqueTag,
        );
      }

      // RouteAware 订阅在 didChangeDependencies 中完成
    } catch (e) {
      LogUtils.e('初始化控制器失败', tag: 'video_detail_page_v2', error: e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 订阅路由观察者
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  /// 另一个页面被推入覆盖当前页面时调用（等同于原来的"离开"）
  @override
  void didPushNext() {
    LogUtils.d('didPushNext', 'MyVideoDetailPage');
    // 暂停播放
    controller.player.pause();
    // 重置屏幕亮度
    controller.setDefaultBrightness();
    // 如果当前为应用全屏状态，则恢复UI
    if (controller.isDesktopAppFullScreen.value) {
      appService.showSystemUI();
    }
  }

  /// 从上层页面返回到当前页面时调用（等同于原来的"进入"）
  @override
  void didPopNext() {
    LogUtils.d('didPopNext', 'MyVideoDetailPage');
    // 返回到视频详情页，重置屏幕亮度
    ScreenBrightness().resetApplicationScreenBrightness();
  }

  @override
  void dispose() {
    LogUtils.w('dispose start: uniqueTag=$uniqueTag', 'MyVideoDetailPage');
    // 销毁Tab控制器
    tabController.dispose();

    // 取消订阅路由观察者
    routeObserver.unsubscribe(this);

    // 尝试删除controller
    try {
      Get.delete<MyVideoStateController>(tag: uniqueTag);
      Get.delete<CommentController>(tag: uniqueTag);
      Get.delete<RelatedMediasController>(tag: uniqueTag);
    } catch (e) {
      LogUtils.e('销毁视频详情页失败', error: e, tag: 'video_detail_page_v2');
    }

    super.dispose();
  }

  // 计算是否需要分两列
  bool _shouldUseWideScreenLayout(
    double screenHeight,
    double screenWidth,
    double videoRatio,
  ) {
    // 使用有效的视频比例，如果比例小于1，则使用1.7
    final effectiveVideoRatio = videoRatio < 1 ? 1.7 : videoRatio;
    // 视频的高度
    final videoHeight = screenWidth / effectiveVideoRatio;
    // 如果视频高度超过屏幕高度的70%，并且屏幕宽度足够
    return videoHeight > screenHeight * 0.7;
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

    return Obx(() {
      final fullscreenActive = controller.isFullscreen.value;

      return PopScope(
        // Fullscreen is now handled inside the same page route.
        // When fullscreen is active, back should first exit fullscreen.
        canPop: !fullscreenActive,
        onPopInvokedWithResult: (didPop, result) {
          LogUtils.d(
            'video detail PopScope: didPop=$didPop, '
                'controllerFullscreen=${controller.isFullscreen.value}, '
                'routeCurrent=${ModalRoute.of(context)?.isCurrent}',
            'MyVideoDetailPage',
          );

          if (didPop) return;

          if (controller.isFullscreen.value) {
            LogUtils.d(
              'video detail PopScope -> exit fullscreen',
              'MyVideoDetailPage',
            );
            unawaited(controller.exitFullscreen());
            return;
          }

          LogUtils.d(
            'video detail PopScope fallback -> AppService.tryPop',
            'MyVideoDetailPage',
          );
          AppService.tryPop(context: context);
        },
        child: Stack(
          children: [
            Scaffold(
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

                  // 优先处理应用内全屏
                  if (controller.isDesktopAppFullScreen.value) {
                    return _buildPureVideoPlayer(screenHeight, paddingTop);
                  }

                  // 判断是否使用宽屏布局
                  bool isWide = _shouldUseWideScreenLayout(
                    screenHeight,
                    screenWidth,
                    controller.aspectRatio.value,
                  );

                  if (isWide) {
                    return _buildWideScreenLayout(
                      context,
                      screenSize,
                      paddingTop,
                      t,
                    );
                  } else {
                    return _buildNarrowScreenLayout(
                      context,
                      screenSize,
                      paddingTop,
                      t,
                    );
                  }
                }),
              ),
            ),
            if (fullscreenActive)
              Positioned.fill(
                child: MyVideoScreen(
                  isFullScreen: true,
                  myVideoStateController: controller,
                ),
              ),
          ],
        ),
      );
    });
  }

  // 宽屏布局：播放器在左侧，Tab内容在右侧
  Widget _buildWideScreenLayout(
    BuildContext context,
    Size screenSize,
    double paddingTop,
    slang.Translations t,
  ) {
    const double tabsAreaWidth = 350.0; // 固定Tab区域宽度，适当缩窄以优化播放器显示区域

    if (controller.pageLoadingState.value ==
            VideoDetailPageLoadingState.loadingVideoInfo ||
        controller.pageLoadingState.value == VideoDetailPageLoadingState.init) {
      return VideoDetailWideSkeletonWidget(controller: controller);
    }

    // 如果是私有视频但没有fileUrl（无访问权限），则不显示内容
    if (controller.videoInfo.value?.private == true &&
        controller.videoInfo.value?.fileUrl == null) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧纯播放器区域（自适应宽度）
        Expanded(
          child: Obx(() {
            // 站外、站内视频都显示播放器
            if (controller.videoInfo.value?.isExternalVideo == true ||
                controller.videoPlayerReady.value) {
              return _buildPureVideoPlayer(screenSize.height, paddingTop);
            }
            // 否则显示播放器（包含加载状态）
            else {
              return MyVideoScreen(
                myVideoStateController: controller,
                isFullScreen: false,
              );
            }
          }),
        ),

        // 右侧Tab内容区域（固定宽度）
        SizedBox(
          width: tabsAreaWidth,
          child: _buildTabSection(context, paddingTop, t),
        ),
      ],
    );
  }

  // 窄屏布局：使用 ExtendedNestedScrollView 实现播放器固定效果
  Widget _buildNarrowScreenLayout(
    BuildContext context,
    Size screenSize,
    double paddingTop,
    slang.Translations t,
  ) {
    if (controller.pageLoadingState.value ==
            VideoDetailPageLoadingState.loadingVideoInfo ||
        controller.pageLoadingState.value == VideoDetailPageLoadingState.init) {
      return const MediaDetailInfoSkeletonWidget();
    }

    return Obx(() {
      // 使用 Obx 包装整个 ExtendedNestedScrollView，确保 videoPlaying 状态变化时重建
      LogUtils.d('${controller.videoPlaying.value}', 'refresh');
      return ExtendedNestedScrollView(
        key: controller.nestedScrollViewKey,
        controller: controller.scrollController,
        physics: const NeverScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          // 核心逻辑：播放时返回视频高度，暂停时返回工具栏高度
          if (controller.videoPlaying.value) {
            return controller.getCurrentVideoHeight(
              screenSize.width,
              screenSize.height,
              paddingTop,
            );
          } else {
            return kToolbarHeight + paddingTop;
          }
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Obx(
              () => SliverAppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                primary: false,
                automaticallyImplyLeading: false,
                pinned: true,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
                // 动态 pinned
                expandedHeight: controller.getCurrentVideoHeight(
                  screenSize.width,
                  screenSize.height,
                  paddingTop,
                ),
                flexibleSpace: Stack(
                  children: [
                    // 视频播放器
                    Obx(() {
                      // 站外、站内视频都显示播放器
                      if (controller.videoInfo.value?.isExternalVideo == true ||
                          controller.videoPlayerReady.value) {
                        return SizedBox(
                          width: screenSize.width,
                          height: controller.getCurrentVideoHeight(
                            screenSize.width,
                            screenSize.height,
                            paddingTop,
                          ),
                          child: _buildVideoPlayerContent(),
                        );
                      }
                      // 否则显示骨架屏
                      else {
                        return SizedBox(
                          width: screenSize.width,
                          height: controller.getCurrentVideoHeight(
                            screenSize.width,
                            screenSize.height,
                            paddingTop,
                          ),
                          child: MyVideoScreen(
                            myVideoStateController: controller,
                            isFullScreen: false,
                          ),
                        );
                      }
                    }),
                    // 顶部工具栏（根据滚动状态显示）
                    Obx(() => _buildTopToolbarOverlay(context, t)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _buildTabSection(context, 0, t),
      );
    });
  }

  // 构建纯播放器（宽屏时使用，占满整个容器）
  Widget _buildPureVideoPlayer(double screenHeight, double paddingTop) {
    return Container(
      height: screenHeight,
      color: Colors.black,
      child: Obx(() {
        // 如果视频加载出错，显示错误组件
        if (controller.videoErrorMessage.value != null) {
          return _buildVideoErrorWidget(context);
        }
        // 如果是站外视频，显示站外视频提示
        else if (controller.videoInfo.value?.isExternalVideo == true) {
          return _buildExternalVideoWidget(context);
        }
        // 正常显示播放器
        else if (!controller.isFullscreen.value) {
          return MyVideoScreen(
            isFullScreen: false,
            myVideoStateController: controller,
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  // 构建播放器内容
  Widget _buildVideoPlayerContent() {
    return Obx(() {
      // 如果视频加载出错，显示错误组件
      if (controller.videoErrorMessage.value != null) {
        return _buildVideoErrorWidget(context);
      }
      // 如果是站外视频，显示站外视频提示
      else if (controller.videoInfo.value?.isExternalVideo == true) {
        return _buildExternalVideoWidget(context);
      }
      // 正常显示播放器
      else if (!controller.isFullscreen.value) {
        return MyVideoScreen(
          isFullScreen: false,
          myVideoStateController: controller,
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  // 构建视频错误提示
  Widget _buildVideoErrorWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    return Center(
      child: controller.videoErrorMessage.value == 'resource_404'
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.not_interested, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  t.videoDetail.resourceNotFound,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.common.back),
                ),
              ],
            )
          : CommonErrorWidget(
              text:
                  controller.videoErrorMessage.value ??
                  t.videoDetail.videoLoadError,
              children: [
                ElevatedButton.icon(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(t.common.back),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.fetchVideoDetail(controller.videoId ?? ''),
                  icon: const Icon(Icons.refresh),
                  label: Text(t.common.retry),
                ),
              ],
            ),
    );
  }

  // 构建外链视频提示
  Widget _buildExternalVideoWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // 获取视频缩略图URL用于模糊背景
    final thumbnailUrl = controller.videoInfo.value?.thumbnailUrl;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        children: [
          // 模糊背景
          Positioned.fill(
            child: _buildExternalVideoBackground(thumbnailUrl, screenSize),
          ),
          // 前景内容
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.link, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    '${t.videoDetail.externalVideo}: ${controller.videoInfo.value?.externalVideoDomain}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // 使用 Obx 包裹，根据滚动比例隐藏按钮
                  Obx(() {
                    final isWide = _shouldUseWideScreenLayout(
                      screenHeight,
                      screenWidth,
                      controller.aspectRatio.value,
                    );
                    // 当 header 收缩时（scrollRatio > 0.8），隐藏按钮
                    final isCollapsed =
                        !isWide && controller.scrollRatio.value > 0.8;
                    return AnimatedOpacity(
                      opacity: isCollapsed ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isCollapsed,
                        child: Row(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => AppService.tryPop(),
                              icon: const Icon(Icons.arrow_back),
                              label: Text(t.common.back),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (controller.videoInfo.value?.embedUrl !=
                                    null) {
                                  launchUrl(
                                    Uri.parse(
                                      controller.videoInfo.value!.embedUrl!,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: Text(t.videoDetail.openInBrowser),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建站外视频的模糊背景
  Widget _buildExternalVideoBackground(String? thumbnailUrl, Size screenSize) {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      // 如果没有缩略图，返回纯黑背景
      return Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Colors.black,
      );
    }

    // 创建模糊背景
    return FutureBuilder<Widget>(
      future: _createBlurredBackground(thumbnailUrl, screenSize),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        }
        // 加载过程中显示纯黑背景
        return Container(
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.black,
        );
      },
    );
  }

  // 创建模糊背景的异步方法
  Future<Widget> _createBlurredBackground(
    String thumbnailUrl,
    Size size,
  ) async {
    try {
      // 1. 加载原始图片，使用较小的分辨率减少内存占用
      final NetworkImage networkImage = NetworkImage(thumbnailUrl);
      final ImageConfiguration config = ImageConfiguration(
        size: Size(size.width * 0.5, size.height * 0.5), // 使用一半分辨率
      );
      final ImageStream stream = networkImage.resolve(config);
      final Completer<ui.Image> completer = Completer<ui.Image>();

      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
        }),
      );

      final ui.Image originalImage = await completer.future;

      // 2. 计算适当的绘制尺寸以保持宽高比
      final double imageAspectRatio =
          originalImage.width / originalImage.height;
      final double screenAspectRatio = size.width / size.height;

      double targetWidth = size.width;
      double targetHeight = size.height;
      double offsetX = 0;
      double offsetY = 0;

      if (imageAspectRatio > screenAspectRatio) {
        // 图片比屏幕更宽，以高度为基准
        targetWidth = size.height * imageAspectRatio;
        offsetX = -(targetWidth - size.width) / 2;
      } else {
        // 图片比屏幕更高，以宽度为基准
        targetHeight = size.width / imageAspectRatio;
        offsetY = -(targetHeight - size.height) / 2;
      }

      // 3. 创建一个自定义画布，使用目标尺寸
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 4. 绘制图片并应用模糊效果
      final paint = Paint()
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20);

      // 使用计算后的偏移量和尺寸绘制图片
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(
          0,
          0,
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        ),
        Rect.fromLTWH(offsetX, offsetY, targetWidth, targetHeight),
        paint,
      );

      // 5. 将模糊后的图片转换为图像
      final blurredImage = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );

      // 6. 转换为字节数据
      final byteData = await blurredImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = byteData!.buffer.asUint8List();

      // 7. 创建最终的模糊背景Widget
      return Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.black)),
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.memory(
                buffer,
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      // 如果出现错误，返回纯黑背景
      return Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
      );
    }
  }

  // 构建Tab区域
  Widget _buildTabSection(
    BuildContext context,
    double paddingTop,
    slang.Translations t,
  ) {
    return Column(
      children: [
        Container(height: paddingTop, color: Colors.transparent),

        // 本地模式：直接显示 LocalVideoInfoWidget，不显示 Tab
        if (isLocalMode)
          Expanded(
            child: LocalVideoInfoWidget(
              controller: controller,
              task: widget.localTask,
              allQualityTasks: widget.localAllQualityTasks ?? [],
              localPath: widget.localPath!,
            ),
          )
        else ...[
          // 在线模式：显示 Tab 导航栏和内容
          _buildTabBar(context, t),
          Expanded(child: _buildTabBarView()),
        ],
      ],
    );
  }

  // 构建Tab导航栏
  Widget _buildTabBar(BuildContext context, slang.Translations t) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          // 点击Tab时滚动到顶部
          if (!tabController.indexIsChanging) {
            controller.animateToTop();
          }
        },
        tabs: isLocalMode
            ? [
                // 本地模式：只显示详情tab
                Tab(text: t.common.detail),
              ]
            : [
                // 在线模式：显示所有tab
                Tab(text: t.common.detail),
                Tab(text: t.common.commentList),
                Tab(text: t.videoDetail.relatedVideos),
              ],
      ),
    );
  }

  // 构建Tab内容视图
  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: isLocalMode
          ? [
              // 本地模式：只显示本地视频信息
              LocalVideoInfoWidget(
                controller: controller,
                task: widget.localTask,
                allQualityTasks: widget.localAllQualityTasks ?? [],
                localPath: widget.localPath!,
              ),
            ]
          : [
              // 在线模式：显示所有tab
              VideoInfoTabWidget(
                controller: controller,
                tabController: tabController,
              ),
              CommentsTabWidget(
                commentController: commentController!,
                videoController: controller,
              ),
              RelatedVideosTabWidget(
                videoController: controller,
                relatedVideoController: relatedVideoController!,
              ),
            ],
    );
  }

  // 构建顶部工具栏覆盖层
  Widget _buildTopToolbarOverlay(BuildContext context, slang.Translations t) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: controller.scrollRatio.value <= 0,
        child: SizedBox(
          height: kToolbarHeight + MediaQuery.paddingOf(context).top,
          child: Opacity(
            opacity: (controller.scrollRatio.value / 0.8).clamp(0.0, 1.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: AppBar(
                  title: Text(
                    controller.videoInfo.value?.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: IconButton(
                    onPressed: () => AppService.tryPop(context: context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    // 播放/暂停按钮
                    IconButton(
                      onPressed: () {
                        if (controller.videoPlaying.value) {
                          controller.player.pause();
                        } else {
                          controller.player.play();
                        }
                        controller.animateToTop();
                      },
                      icon: Icon(
                        controller.videoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ],
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
