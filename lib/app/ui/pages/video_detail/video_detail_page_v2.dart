import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/home/home_navigation_layout.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/media_tile_list_loading_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/video_detail_info_skeleton_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/video_info_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/comments_tab_widget.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/tabs/related_videos_tab_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../../../../common/enums/media_enums.dart';
import '../../widgets/error_widget.dart';
import '../comment/controllers/comment_controller.dart';
import 'controllers/my_video_state_controller.dart';
import 'controllers/related_media_controller.dart';
import '../../../../i18n/strings.g.dart' as slang;

class MyVideoDetailPage extends StatefulWidget {
  final String videoId;

  const MyVideoDetailPage({super.key, required this.videoId});

  @override
  MyVideoDetailPageState createState() => MyVideoDetailPageState();
}

class MyVideoDetailPageState extends State<MyVideoDetailPage> with TickerProviderStateMixin {
  final String uniqueTag = UniqueKey().toString();
  late String videoId;
  final AppService appService = Get.find();

  late MyVideoStateController controller;
  late CommentController commentController;
  late RelatedMediasController relatedVideoController;
  
  // Tab控制器
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    videoId = widget.videoId;
    
    // 初始化Tab控制器
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    if (videoId.isEmpty) {
      LogUtils.e('视频ID为空', tag: 'video_detail_page_v2');
      return;
    }

    LogUtils.i('初始化视频详情页 videoId: $videoId', 'video_detail_page_v2');

    // 初始化控制器
    try {
      controller = Get.put(
        MyVideoStateController(videoId),
        tag: uniqueTag,
      );
      LogUtils.d('MyVideoStateController 初始化成功', 'video_detail_page_v2');

      commentController = Get.put(
        CommentController(id: videoId, type: CommentType.video),
        tag: uniqueTag,
      );
      LogUtils.d('CommentController 初始化成功', 'video_detail_page_v2');

      relatedVideoController = Get.put(
        RelatedMediasController(mediaId: videoId, mediaType: MediaType.VIDEO),
        tag: uniqueTag,
      );
      LogUtils.d('RelatedMediasController 初始化成功', 'video_detail_page_v2');

      // 注册路由变化回调
      HomeNavigationLayout.homeNavigatorObserver
          .addRouteChangeCallback(_onRouteChange);
      LogUtils.d('注册路由变化回调成功', 'video_detail_page_v2');
    } catch (e) {
      LogUtils.e('初始化控制器失败', tag: 'video_detail_page_v2', error: e);
    }
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
      LogUtils.d('离开视频详情页，重置屏幕亮度', 'video_detail_page_v2');
      controller.setDefaultBrightness();
    }

    // 如果操作类型是进入，上一个路由contains Routes.VIDEO_DETAIL，则暂停
    if (route?.isActive == true && previousRoute?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true) {
      // 如果当前路由为null，则不pause
      if (route?.settings.name != null) {
        LogUtils.d('进入非视频详情页，暂停播放', 'video_detail_page_v2');
        controller.player.pause();
      }
    }

    // 如果当前路由contains Routes.VIDEO_DETAIL，且操作类型是离开则resetBrightness
    if (route?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true && 
        previousRoute?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == false) {
      LogUtils.d('进入视频详情页，重置屏幕亮度', 'video_detail_page_v2');
      ScreenBrightness().resetApplicationScreenBrightness();
    }
    
    // 如果是从detail到其他页面，且当前为 应用全屏状态，则恢复UI
    if (previousRoute != null &&
        previousRoute.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == true &&
        route?.settings.name?.contains(Routes.VIDEO_DETAIL_PREFIX) == false &&
        controller.isDesktopAppFullScreen.value) {
      if (route?.settings.name != null) {
        LogUtils.d('恢复系统UI', 'video_detail_page_v2');
        appService.showSystemUI();
      }
    }
  }

  @override
  void dispose() {
    LogUtils.i('销毁视频详情页', 'video_detail_page_v2');
    
    // 销毁Tab控制器
    tabController.dispose();
    
    // 移除路由变化回调
    try {
      HomeNavigationLayout.homeNavigatorObserver
          .removeRouteChangeCallback(_onRouteChange);
      LogUtils.d('移除路由变化回调成功', 'video_detail_page_v2');

      // 尝试删除controller
      Get.delete<MyVideoStateController>(tag: uniqueTag);
      Get.delete<CommentController>(tag: uniqueTag);
      Get.delete<RelatedMediasController>(tag: uniqueTag);
      LogUtils.d('删除控制器成功', 'video_detail_page_v2');
    } catch (e) {
      LogUtils.e('销毁视频详情页失败', error: e, tag: 'video_detail_page_v2');
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
          
          if (isWide) {
            return _buildWideScreenLayout(context, screenSize, paddingTop, isDesktopAppFullScreen);
          } else {
            return _buildNarrowScreenLayout(context, screenSize, paddingTop, isDesktopAppFullScreen);
          }
        }),
      ),
    );
  }

  // 宽屏布局：播放器在左侧，Tab内容在右侧
  Widget _buildWideScreenLayout(BuildContext context, Size screenSize, double paddingTop, bool isDesktopAppFullScreen) {
    const double tabsAreaWidth = 400.0; // 固定Tab区域宽度
    
    if (controller.isVideoInfoLoading.value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧视频播放器骨架
          Expanded(
            child: Container(
              height: screenSize.height,
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          // 右侧Tab内容骨架
          SizedBox(
            width: tabsAreaWidth,
            child: const MediaTileListSkeletonWidget(),
          ),
        ],
      );
    }

    // 如果videoInfo不为空且videoInfo!.isPrivate为true，则显示私有视频提示
    if (controller.videoInfo.value?.private == true) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧纯播放器区域（自适应宽度）
        Expanded(
          child: _buildPureVideoPlayer(screenSize.height, paddingTop),
        ),
        
        // 右侧Tab内容区域（固定宽度）
        if (!isDesktopAppFullScreen)
          SizedBox(
            width: tabsAreaWidth,
            child: _buildTabSection(context, paddingTop),
          ),
      ],
    );
  }

  // 窄屏布局：播放器在顶部，Tab内容在下方
  Widget _buildNarrowScreenLayout(BuildContext context, Size screenSize, double paddingTop, bool isDesktopAppFullScreen) {
    if (controller.isVideoInfoLoading.value) {
      return const MediaDetailInfoSkeletonWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部播放器区域
        _buildVideoPlayerWithAspectRatio(paddingTop),
        
        // 底部Tab内容区域
        if (!isDesktopAppFullScreen)
          Expanded(
            child: _buildTabSection(context, 0),
          ),
      ],
    );
  }

  // 构建纯播放器（宽屏时使用，占满整个容器）
  Widget _buildPureVideoPlayer(double screenHeight, double paddingTop) {
    return Container(
      height: screenHeight,
      color: Colors.black,
      child: Obx(() {
        // 如果视频加载出错，显示错误组件
        if (controller.videoErrorMessage.value != null) {
          return _buildVideoErrorWidget();
        }
        // 如果是站外视频，显示站外视频提示
        else if (controller.videoInfo.value?.isExternalVideo == true) {
          return _buildExternalVideoWidget();
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

  // 构建带宽高比的播放器（窄屏时使用）
  Widget _buildVideoPlayerWithAspectRatio(double paddingTop) {
    return Obx(() {
      final aspectRatio = controller.aspectRatio.value < 1 ? 16/9 : controller.aspectRatio.value;
      
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // 顶部安全区域
              Container(
                height: paddingTop,
                color: Colors.black,
              ),
              
              // 播放器内容
              Positioned.fill(
                top: 0,
                child: _buildVideoPlayerContent(),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 构建播放器内容
  Widget _buildVideoPlayerContent() {
    return Obx(() {
      // 如果视频加载出错，显示错误组件
      if (controller.videoErrorMessage.value != null) {
        return _buildVideoErrorWidget();
      }
      // 如果是站外视频，显示站外视频提示
      else if (controller.videoInfo.value?.isExternalVideo == true) {
        return _buildExternalVideoWidget();
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
  Widget _buildVideoErrorWidget() {
    return Center(
      child: controller.videoErrorMessage.value == 'resource_404'
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.not_interested, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                '资源已删除',
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => AppService.tryPop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
            ],
          )
        : CommonErrorWidget(
            text: controller.videoErrorMessage.value ?? '视频加载错误',
            children: [
              ElevatedButton.icon(
                onPressed: () => AppService.tryPop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => controller.fetchVideoDetail(controller.videoId ?? ''),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
    );
  }

  // 构建外链视频提示
  Widget _buildExternalVideoWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            '外链视频: ${controller.videoInfo.value?.externalVideoDomain}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => AppService.tryPop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('返回'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (controller.videoInfo.value?.embedUrl != null) {
                    // TODO: 实现打开浏览器功能
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('在浏览器中打开'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建Tab区域
  Widget _buildTabSection(BuildContext context, double paddingTop) {
    return Column(
      children: [
        Container(
          height: paddingTop,
          color: Colors.transparent,
        ),
        
        // Tab导航栏
        _buildTabBar(context),
        
        // Tab内容
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  // 构建Tab导航栏
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            text: '详情',
          ),
          Tab(
            text: '评论',
          ),
          Tab(
            text: '相关',
          ),
        ],
      ),
    );
  }

  // 构建Tab内容视图
  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        // 视频详情Tab
        VideoInfoTabWidget(
          controller: controller,
        ),
        
        // 评论Tab
        CommentsTabWidget(
          commentController: commentController,
          videoController: controller,
        ),
        
        // 相关视频Tab
        RelatedVideosTabWidget(
          videoController: controller,
          relatedVideoController: relatedVideoController,
        ),
      ],
    );
  }
}
