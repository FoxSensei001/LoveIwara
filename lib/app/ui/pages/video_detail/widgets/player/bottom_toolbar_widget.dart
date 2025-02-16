import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/volume_control_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:logger/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // 缓存一些常用的组件
  final Widget _spacer4 = const SizedBox(width: 4.0);
  final Widget _spacer8 = const SizedBox(width: 8.0);

  BottomToolbar({
    super.key,
    required this.myVideoStateController,
    required this.currentScreenIsFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final double iconSize = isSmallScreen ? 18 : 20;

    // 用 RepaintBoundary 包裹整个工具条
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentScreenIsFullScreen)
            _buildTopInteractionLayer(context, isSmallScreen),
          _buildBottomToolbar(context, isSmallScreen, iconSize, t),
        ],
      ),
    );
  }

  Widget _buildTopInteractionLayer(BuildContext context, bool isSmallScreen) {
    return IgnorePointer(
      ignoring: myVideoStateController.animationController.value == 0,
      child: SlideTransition(
        position: myVideoStateController.bottomBarAnimation,
        child: FadeTransition(
          opacity: myVideoStateController.animationController,
          child: MouseRegion(
            onEnter: (_) => myVideoStateController.setToolbarHovering(true),
            onExit: (_) => myVideoStateController.setToolbarHovering(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildLikeButton(),
                  _spacer8,
                  _buildFollowButton(),
                  _spacer8,
                  _buildAuthorInfo(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context, bool isSmallScreen, double iconSize, slang.Translations t) {
    return SlideTransition(
      position: myVideoStateController.bottomBarAnimation,
      child: MouseRegion(
        onEnter: (_) => myVideoStateController.setToolbarHovering(true),
        onExit: (_) => myVideoStateController.setToolbarHovering(false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 60),
                blurRadius: 60.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (!myVideoStateController.showResumePositionTip.value) {
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.videoDetail.resumeFromLastPosition(
                                position: CommonUtils.formatDuration(
                                  myVideoStateController.resumePosition.value
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => myVideoStateController.hideResumePositionTip(),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 0.0 : 4.0),
                child: CustomVideoProgressbar(
                  controller: myVideoStateController,
                ),
              ),
              SizedBox(
                height: isSmallScreen ? 36.0 : 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLeftControls(context, isSmallScreen, iconSize, t),
                    _buildRightControls(context, isSmallScreen, iconSize, t),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      borderRadius: BorderRadius.circular(16.0),
      splashColor: Colors.white24,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
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
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
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

  Widget _buildLikeButton() {
    return Obx(() {
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
            numLikes:
                (myVideoStateController.videoInfo.value?.numLikes ?? 0) +
                    (liked ? 1 : -1),
          );
        },
      );
    });
  }

  Widget _buildFollowButton() {
    return Obx(() {
      final videoInfo = myVideoStateController.videoInfo.value;
      if (videoInfo?.user == null) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 28,
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
    });
  }

  Widget _buildAuthorInfo(bool isSmallScreen) {
    return Obx(() {
      final videoInfo = myVideoStateController.videoInfo.value;
      if (videoInfo?.user == null) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          AvatarWidget(
            user: videoInfo?.user,
            defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
            radius: 14,
          ),
          const SizedBox(width: 6),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Text(
                    videoInfo?.user?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildLeftControls(BuildContext context, bool isSmallScreen, double iconSize, slang.Translations t) {
    return Row(
      children: [
        Obx(() => _buildSwitchIconButton(
          tooltip: myVideoStateController.videoPlaying.value
              ? t.videoDetail.pause
              : t.videoDetail.play,
          icon: Icon(
            myVideoStateController.videoPlaying.value
                ? Icons.pause
                : Icons.play_arrow,
            key: ValueKey(myVideoStateController.videoPlaying.value
                ? 'pause'
                : 'play'),
            color: Colors.white,
            size: iconSize,
          ),
          onPressed: () async {
            VibrateUtils.vibrate();
            if (myVideoStateController.videoPlaying.value) {
              myVideoStateController.videoController.player.pause();
            } else {
              myVideoStateController.videoController.player.play();
            }
          },
        )),
        if (GetPlatform.isDesktop)
          VolumeControl(
            configService: _configService,
            myVideoStateController: myVideoStateController,
          ),
        _spacer4,
        TextButton(
          onPressed: () {
            _showSeekDialog(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 2.0 : 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Obx(
            () => Text(
              '${CommonUtils.formatDuration(myVideoStateController.currentPosition.value)} / ${CommonUtils.formatDuration(myVideoStateController.totalDuration.value)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightControls(BuildContext context, bool isSmallScreen, double iconSize, slang.Translations t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlaybackSpeedSwitcher(context),
        _buildResolutionSwitcher(context),
        if (GetPlatform.isDesktop && !currentScreenIsFullScreen)
          _buildIconButton(
            tooltip: myVideoStateController.isDesktopAppFullScreen.value
                ? t.videoDetail.exitAppFullscreen
                : t.videoDetail.enterAppFullscreen,
            icon: Obx(() {
              return SizedBox(
                width: iconSize,
                height: iconSize,
                child: (myVideoStateController.isDesktopAppFullScreen.value)
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
              if (myVideoStateController.isDesktopAppFullScreen.value) {
                myVideoStateController.isDesktopAppFullScreen.value = false;
                appService.showSystemUI();
              } else {
                appService.hideSystemUI();
                myVideoStateController.isDesktopAppFullScreen.value = true;
              }
            },
          ),
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
              size: iconSize,
            ),
            onPressed: () {
              if (currentScreenIsFullScreen) {
                myVideoStateController.exitFullscreen();
              } else {
                myVideoStateController.enterFullscreen();
                myVideoStateController.setToolbarHovering(false);
              }
            },
          ),
      ],
    );
  }
}
