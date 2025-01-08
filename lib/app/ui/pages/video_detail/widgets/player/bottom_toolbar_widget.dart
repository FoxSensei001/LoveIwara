import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/volume_control_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:logger/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vibration/vibration.dart';
import 'package:i_iwara/app/ui/widgets/like_button_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';

import '../../../../../../utils/common_utils.dart';
import '../../../../../services/config_service.dart';
import '../../controllers/my_video_state_controller.dart';
import 'custom_slider_bar_shape_widget.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

class BottomToolbar extends StatelessWidget {
  final MyVideoStateController myVideoStateController;
  final Logger logger = Logger();
  final bool currentScreenIsFullScreen;
  final ConfigService _configService = Get.find();
  final AppService appService = Get.find();

  BottomToolbar({
    super.key,
    required this.myVideoStateController,
    required this.currentScreenIsFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 添加顶部互动控制层
        if (currentScreenIsFullScreen)
          SlideTransition(
            position: myVideoStateController.bottomBarAnimation,
            child: FadeTransition(
              opacity: myVideoStateController.animationController,
              child: MouseRegion(
                onEnter: (_) => myVideoStateController.setToolbarHovering(true),
                onExit: (_) => myVideoStateController.setToolbarHovering(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 点赞按钮
                      Obx(() {
                        final videoInfo = myVideoStateController.videoInfo.value;
                        if (videoInfo == null) return const SizedBox.shrink();
                        
                        return LikeButtonWidget(
                          mediaId: videoInfo.id,
                          liked: videoInfo.liked ?? false,
                          likeCount: videoInfo.numLikes ?? 0,
                          onLike: (id) async {
                            final result = await Get.find<VideoService>().likeVideo(id);
                            return result.isSuccess;
                          },
                          onUnlike: (id) async {
                            final result = await Get.find<VideoService>().unlikeVideo(id);
                            return result.isSuccess;
                          },
                          onLikeChanged: (liked) {
                            myVideoStateController.videoInfo.value = 
                              myVideoStateController.videoInfo.value?.copyWith(
                                liked: liked,
                                numLikes: (myVideoStateController.videoInfo.value?.numLikes ?? 0) + 
                                  (liked ? 1 : -1),
                              );
                          },
                        );
                      }),
                      const SizedBox(width: 16),
                      // 关注按钮
                      Obx(() {
                        final videoInfo = myVideoStateController.videoInfo.value;
                        if (videoInfo?.user == null) return const SizedBox.shrink();
                        
                        return SizedBox(
                          height: 32,
                          child: FollowButtonWidget(
                            user: videoInfo!.user!,
                            onUserUpdated: (updatedUser) {
                              myVideoStateController.videoInfo.value = 
                                myVideoStateController.videoInfo.value?.copyWith(
                                  user: updatedUser,
                                );
                            },
                          ),
                        );
                      }),
                      const SizedBox(width: 16),
                      // 作者头像和名称
                      Obx(() {
                        final videoInfo = myVideoStateController.videoInfo.value;
                        if (videoInfo?.user == null) return const SizedBox.shrink();
                        
                        return Row(
                          children: [
                            AvatarWidget(
                              avatarUrl: videoInfo?.user?.avatar?.avatarUrl,
                              defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                              headers: const {'referer': CommonConstants.iwaraBaseUrl},
                              radius: 16,
                              isPremium: videoInfo?.user?.premium ?? false,
                              isAdmin: videoInfo?.user?.isAdmin ?? false,
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: videoInfo?.user?.premium == true
                                ? ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.purple.shade300,
                                        Colors.blue.shade300,
                                        Colors.pink.shade300,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      videoInfo?.user?.name ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Text(
                                    videoInfo?.user?.name ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // 原有的底部工具栏
        SlideTransition(
          position: myVideoStateController.bottomBarAnimation,
          child: MouseRegion(
            onEnter: (_) => myVideoStateController.setToolbarHovering(true),
            onExit: (_) => myVideoStateController.setToolbarHovering(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // 阴影颜色
                    offset: const Offset(0, 60), // 阴影偏移，向上偏移60像素
                    blurRadius: 60.0, // 阴影模糊半径
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 第一行：进度条
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 添加水平内边距
                    child: CustomVideoProgressbar(
                      controller: myVideoStateController,
                    ),
                  ),
                  // 第二行：播放按钮、进度信息和其他控制按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧：播放/暂停按钮、音量控制和进度信息
                      Row(
                        children: [
                          // 播放/暂停按钮
                          Obx(() => _buildSwitchIconButton(
                                tooltip: myVideoStateController.videoPlaying.value
                                    ? slang.t.videoDetail.pause
                                    : slang.t.videoDetail.play,
                                icon: myVideoStateController.videoPlaying.value
                                    ? const Icon(
                                        Icons.pause,
                                        key: ValueKey('pause'),
                                        color: Colors.white,
                                      )
                                    : const Icon(
                                        Icons.play_arrow,
                                        key: ValueKey('play'),
                                        color: Colors.white,
                                      ),
                                onPressed: () async {
                                  // 添加震动反馈
                                  if (await Vibration.hasVibrator() ?? false) {
                                    await Vibration.vibrate(duration: 50);
                                  }
                                  
                                  if (myVideoStateController.videoPlaying.value) {
                                    myVideoStateController.videoController.player
                                        .pause();
                                  } else {
                                    myVideoStateController.videoController.player
                                        .play();
                                  }
                                },
                              )),
                          // 仅在桌面平台显示音量控制
                          if (GetPlatform.isDesktop)
                            VolumeControl(
                              configService: _configService,
                              myVideoStateController: myVideoStateController,
                            ),

                          const SizedBox(width: 8.0), // 播放按钮与进度信息之间的间距
                          // 进度信息，并添加点击事件
                          TextButton(
                            onPressed: () {
                              _showSeekDialog(context);
                            },
                            child: Obx(
                              () => Text(
                                '${CommonUtils.formatDuration(myVideoStateController.currentPosition.value)} / ${CommonUtils.formatDuration(myVideoStateController.totalDuration.value)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 右侧：播放速度切换、分辨率切换和全屏按钮
                      Row(
                        children: [
                          // 播放速度切换按钮
                          _buildPlaybackSpeedSwitcher(context),
                          // 分辨率切换按钮
                          _buildResolutionSwitcher(context),
                          // 桌面端的应用全屏
                          if (GetPlatform.isDesktop && !currentScreenIsFullScreen)
                            _buildIconButton(
                              tooltip:
                                  myVideoStateController.isDesktopAppFullScreen.value
                                      ? t.videoDetail.exitAppFullscreen
                                      : t.videoDetail.enterAppFullscreen,
                              icon: Obx(() {
                                return SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: (myVideoStateController
                                          .isDesktopAppFullScreen.value)
                                      ? SvgPicture.asset(
                                          'assets/svg/app_exit_fullscreen.svg',
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                          semanticsLabel: myVideoStateController
                                                  .isDesktopAppFullScreen.value
                                              ? t.videoDetail.exitAppFullscreen
                                              : t.videoDetail.enterAppFullscreen,
                                        )
                                      : SvgPicture.asset(
                                          'assets/svg/app_enter_fullscreen.svg',
                                          colorFilter: const ColorFilter.mode(
                                              Colors.white, BlendMode.srcIn),
                                          semanticsLabel: myVideoStateController
                                                  .isDesktopAppFullScreen.value
                                              ? t.videoDetail.exitAppFullscreen
                                              : t.videoDetail.enterAppFullscreen,
                                        ),
                                );
                              }),
                              onPressed: () {
                                if (myVideoStateController
                                    .isDesktopAppFullScreen.value) {
                                  myVideoStateController
                                      .isDesktopAppFullScreen.value = false;
                                  appService.showSystemUI();
                                } else {
                                  appService.hideSystemUI();
                                  myVideoStateController.isDesktopAppFullScreen.value =
                                      true;
                                }
                              },
                            ),
                          // 全屏按钮
                          if (!myVideoStateController.isDesktopAppFullScreen.value)
                            _buildIconButton(
                              tooltip: currentScreenIsFullScreen
                                  ? t.videoDetail.exitSystemFullscreen
                                  : t.videoDetail.enterSystemFullscreen,
                              icon: Icon(
                                currentScreenIsFullScreen
                                    ? Icons.fullscreen_exit
                                    : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (currentScreenIsFullScreen) {
                                  // 退出系统全屏
                                  myVideoStateController.exitFullscreen();
                                } else {
                                  // 进入系统全屏
                                  myVideoStateController.enterFullscreen();
                                  // 关闭toolbar
                                  myVideoStateController.setToolbarHovering(false);
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 显示跳转进度的对话框
  void _showSeekDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    // 获取当前和总时长
    final Duration currentPosition =
        myVideoStateController.currentPosition.value;
    final Duration totalDuration = myVideoStateController.totalDuration.value;

    // 将总时长拆分为小时、分钟和秒
    final int totalHours = totalDuration.inHours;
    final int totalMinutes = totalDuration.inMinutes.remainder(60);
    final int totalSeconds = totalDuration.inSeconds.remainder(60);

    // 初始化滑块的值为当前播放位置
    int selectedHours = currentPosition.inHours;
    int selectedMinutes = currentPosition.inMinutes.remainder(60);
    int selectedSeconds = currentPosition.inSeconds.remainder(60);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.videoDetail.seekTo),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 小时滑块
                  if (totalHours > 0)
                    Row(
                      children: [
                        Text(t.common.hour),
                        Expanded(
                          child: Slider(
                            value: selectedHours.toDouble(),
                            min: 0,
                            max: totalHours.toDouble(),
                            divisions: totalHours > 0 ? totalHours : 1,
                            label: '$selectedHours ${t.common.hour}',
                            onChanged: (double value) {
                              setState(() {
                                selectedHours = value.round();
                                // 确保总时长不被超过
                                if (selectedHours == totalHours &&
                                    (selectedMinutes > totalMinutes ||
                                        (selectedMinutes == totalMinutes &&
                                            selectedSeconds > totalSeconds))) {
                                  selectedMinutes = totalMinutes;
                                  selectedSeconds = totalSeconds;
                                }
                              });
                            },
                          ),
                        ),
                        Text('$selectedHours'),
                      ],
                    ),
                  // 分钟滑块
                  if (totalMinutes > 0)
                    Row(
                      children: [
                        Text(t.common.minute),
                        Expanded(
                          child: Slider(
                            value: selectedMinutes.toDouble(),
                            min: 0,
                            max: (selectedHours < totalHours)
                                ? 59
                                : totalMinutes.toDouble(),
                            divisions: (selectedHours < totalHours)
                                ? 59
                                : (totalMinutes > 0 ? totalMinutes : 1),
                            label: '$selectedMinutes ${t.common.minute}',
                            onChanged: (double value) {
                              setState(() {
                                selectedMinutes = value.round();
                                // 确保总时长不被超过
                                if (selectedHours == totalHours &&
                                    selectedMinutes == totalMinutes &&
                                    selectedSeconds > totalSeconds) {
                                  selectedSeconds = totalSeconds;
                                }
                              });
                            },
                          ),
                        ),
                        Text('$selectedMinutes'),
                      ],
                    ),
                  // 秒钟滑块
                  Row(
                    children: [
                      Text(t.common.seconds),
                      Expanded(
                        child: Slider(
                          value: selectedSeconds.toDouble(),
                          min: 0,
                          max: (selectedHours < totalHours ||
                                  selectedMinutes < totalMinutes)
                              ? 59
                              : totalSeconds.toDouble(),
                          divisions: (selectedHours < totalHours ||
                                  selectedMinutes < totalMinutes)
                              ? 59
                              : (totalSeconds > 0 ? totalSeconds : 1),
                          label: '$selectedSeconds ${t.common.seconds}',
                          onChanged: (double value) {
                            setState(() {
                              selectedSeconds = value.round();
                            });
                          },
                        ),
                      ),
                      Text('$selectedSeconds'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 关闭对话框
                Navigator.of(context).pop();
              },
              child: Text(t.common.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // 构建新的跳转时间
                final Duration newPosition = Duration(
                  hours: selectedHours,
                  minutes: selectedMinutes,
                  seconds: selectedSeconds,
                );

                // 确保跳转时间不超过总时长
                final Duration clampedPosition =
                    newPosition > totalDuration ? totalDuration : newPosition;

                // 执行跳转
                myVideoStateController.player.seek(clampedPosition);

                // 关闭对话框
                Navigator.of(context).pop();
              },
              child: Text(t.common.confirm),
            ),
          ],
        );
      },
    );
  }

  /// 创建一个IconButton
  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
    String? tooltip, // 可选的tooltip参数
  }) {
    Widget button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24.0),
      splashColor: Colors.white24,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon,
      ),
    );

    if (tooltip != null && tooltip.isNotEmpty) {
      button = Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: true,
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// 创建一个带切换动画的IconButton
  Widget _buildSwitchIconButton({
    required Icon icon,
    required VoidCallback onPressed,
    String? tooltip, // 添加tooltip参数
  }) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap, // 设置触发模式为点击
      preferBelow: true,
      message: tooltip, // 提示信息
      child: Material(
        color: Colors.transparent, // 使背景透明以显示水波纹效果
        child: InkWell(
          onTap: onPressed,
          onLongPress: () {
            // 可选：在此处添加长按时的逻辑
            // 例如显示更多选项或执行其他操作
          },
          borderRadius: BorderRadius.circular(32.0), // 设置圆角以匹配按钮形状
          child: Padding(
            padding: const EdgeInsets.all(12.0), // 增加内边距以增大点击区域
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: icon,
            ).animate().fadeIn(duration: 300.ms).scale(),
          ),
        ),
      ),
    );
  }

  /// 分辨率切换器
  Widget _buildResolutionSwitcher(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      String? currentResolution =
          myVideoStateController.currentResolutionTag.value;
      List<VideoResolution> resolutions =
          myVideoStateController.videoResolutions;

      Map<String, IconData> resolutionIcons = {
        '360': Icons.sd,
        '540': Icons.hd,
        '720': Icons.hd,
        '1080': Icons.high_quality,
        'Source': Icons.video_label,
      };

      return PopupMenuButton<String>(
        initialValue: currentResolution,
        tooltip: t.videoDetail.switchResolution,
        icon: Icon(
          resolutionIcons[currentResolution] ?? Icons.settings,
          color: Colors.white,
        ),
        onSelected: (String selected) {
          if (selected != currentResolution) {
            myVideoStateController.switchResolution(selected);
          }
        },
        itemBuilder: (BuildContext context) {
          return resolutions.map((VideoResolution resolution) {
            return PopupMenuItem<String>(
              value: resolution.label,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        resolutionIcons[resolution.label] ?? Icons.settings,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 8),
                      Text(resolution.label),
                    ],
                  ),
                  if (resolution.label == currentResolution)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }

  /// 播放速度切换器
  Widget _buildPlaybackSpeedSwitcher(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      double currentSpeed = myVideoStateController.playerPlaybackSpeed.value;
      List<double> speeds = [
        0.25,
        0.5,
        0.75,
        1.0,
        1.25,
        1.5,
        1.75,
        2.0,
        2.5,
        3.0
      ];

      // 只在全屏下显示
      if (!currentScreenIsFullScreen) {
        return const SizedBox.shrink();
      }

      return PopupMenuButton<double>(
        initialValue: currentSpeed,
        tooltip: t.videoDetail.switchPlaybackSpeed,
        icon: const Icon(
          Icons.speed,
          color: Colors.white,
        ),
        onSelected: (double selected) {
          if (selected != currentSpeed) {
            myVideoStateController.playerPlaybackSpeed.value = selected;
            myVideoStateController.videoController.player.setRate(selected);
          }
        },
        itemBuilder: (BuildContext context) {
          return speeds.map((double speed) {
            return PopupMenuItem<double>(
              value: speed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${speed}x'),
                  if (speed == currentSpeed)
                    const Icon(Icons.check, color: Colors.blue),
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }
}
