import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import '../../../../../../utils/proxy/proxy_util.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../services/config_service.dart';
import '../../../settings/widgets/player_settings_widget.dart';
import '../../../settings/widgets/proxy_setting_widget.dart';
import '../../controllers/my_video_state_controller.dart';

class TopToolbar extends StatelessWidget {
  final MyVideoStateController myVideoStateController;
  final bool currentScreenIsFullScreen;

  const TopToolbar(
      {super.key,
      required this.myVideoStateController,
      required this.currentScreenIsFullScreen});

  @override
  Widget build(BuildContext context) {
    // 获取状态栏高度
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SlideTransition(
      position: myVideoStateController.topBarAnimation,
      child: FadeTransition(
        opacity: myVideoStateController.animationController, // 使用透明度动画
        child: Container(
          // 容器高度包括状态栏高度
          height: 60 + statusBarHeight,
          // 添加顶部内边距以避免内容覆盖状态栏
          padding: EdgeInsets.only(top: statusBarHeight),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7), // 顶部为不透明黑色
                Colors.transparent, // 底部为透明
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 左侧: 返回、主页按钮和标题
              Expanded(
                // 使用 Expanded 包裹左侧的内容
                child: Row(
                  children: [
                    // 返回按钮
                    IconButton(
                      tooltip: '返回',
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (currentScreenIsFullScreen) {
                          myVideoStateController.exitFullscreen();
                        } else {
                          AppService.tryPop();
                        }
                      },
                    ),
                    // 主页按钮
                    // 如果当前是fullScreen，则不显示主页按钮
                    if (!currentScreenIsFullScreen && !myVideoStateController.isDesktopAppFullScreen.value)
                      IconButton(
                        tooltip: '主页',
                        icon: const Icon(Icons.home, color: Colors.white),
                        onPressed: () {
                          AppService appService = Get.find();
                          int currentIndex = appService.currentIndex;
                          final routes = [
                            Routes.POPULAR_VIDEOS,
                            Routes.GALLERY,
                            Routes.SUBSCRIPTIONS,
                          ];
                          AppService.homeNavigatorKey.currentState!
                              .pushNamedAndRemoveUntil(
                            routes[currentIndex],
                            (route) => false,
                          );
                        },
                      ),
                    // 使用 Expanded 包裹标题，避免超出
                    Expanded(
                      child: Obx(() => Text(
                            myVideoStateController.videoInfo.value?.title ??
                                '视频播放器',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                    ),
                  ],
                ),
              ),
              // 右侧: 问号按钮和更多按钮
              Row(
                children: [
                  // 问号信息按钮
                  IconButton(
                    tooltip: '播放器信息',
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    onPressed: () {
                      showInfoModal(context);
                    },
                  ),
                  // 更多设置按钮
                  IconButton(
                    tooltip: '更多设置',
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      showSettingsModal(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示设置模态框
  void showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许模态框占据更多空间
      shape: const RoundedRectangleBorder(
        // 添加圆角
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.80,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SettingsContent(
                  myVideoStateController: myVideoStateController),
            );
          },
        );
      },
    );
  }

  // 显示信息模态框
  void showInfoModal(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('播放器功能介绍'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              // 自动重播
              const Row(
                children: [
                  Icon(Icons.repeat),
                  SizedBox(width: 8),
                  Expanded(child: Text('自动重播')),
                ],
              ),
              const SizedBox(height: 8),
              // 左右两侧双击快进或后退
              const Row(
                children: [
                  Icon(Icons.fast_forward),
                  SizedBox(width: 8),
                  Expanded(child: Text('左右两侧双击快进或后退')),
                ],
              ),
              const SizedBox(height: 8),
              // 左右两侧垂直滑动调整音量、亮度
              const Row(
                children: [
                  Icon(Icons.volume_up),
                  SizedBox(width: 8),
                  Expanded(child: Text('左右两侧垂直滑动调整音量、亮度')),
                ],
              ),
              const SizedBox(height: 8),
              // 中心区域双击暂停或播放
              const Row(
                children: [
                  Icon(Icons.pause_circle_filled),
                  SizedBox(width: 8),
                  Expanded(child: Text('中心区域双击暂停或播放')),
                ],
              ),
              const SizedBox(height: 8),
              // 在全屏时可以以竖屏方式显示竖屏视频（仅限Android和iOS）
              if (GetPlatform.isAndroid || GetPlatform.isIOS)
                const Row(
                  children: [
                    Icon(Icons.screen_rotation),
                    SizedBox(width: 8),
                    Expanded(child: Text('在全屏时可以以竖屏方式显示竖屏视频')),
                  ],
                ),
              if (GetPlatform.isAndroid || GetPlatform.isIOS)
                const SizedBox(height: 8),
              // 保持上次调整的音量、亮度
              const Row(
                children: [
                  Icon(Icons.settings_backup_restore),
                  SizedBox(width: 8),
                  Expanded(child: Text('保持上次调整的音量、亮度')),
                ],
              ),
              // 设置代理（如果支持平台）
              if (ProxyUtil.isSupportedPlatform()) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.laptop),
                    SizedBox(width: 8),
                    Expanded(child: Text('设置代理')),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.thumb_up),
                  SizedBox(width: 8),
                  Expanded(child: Text('更多功能待发现...')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('关闭'),
            onPressed: () {
              AppService.tryPop();
            },
          ),
        ],
      ),
    );
  }
}

// 设置内容组件
class SettingsContent extends StatelessWidget {
  final MyVideoStateController myVideoStateController;
  final ConfigService _configService = Get.find();

  SettingsContent({super.key, required this.myVideoStateController});

  /// 三段式滑块的回调方法
  void _onThreeSectionSliderChangeFinished(
      double leftRatio, double middleRatio, double rightRatio) {
    _configService[ConfigService.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] =
        leftRatio;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖动条
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题
          Text(
            '播放器设置',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 24),
          PlayerSettingsWidget(),
          const SizedBox(height: 16),
          if (ProxyUtil.isSupportedPlatform()) ProxySettingsWidget(),
        ],
      ),
    );
  }
}
