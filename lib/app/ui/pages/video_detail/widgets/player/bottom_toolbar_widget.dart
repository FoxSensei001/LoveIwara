import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/volume_control_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:logger/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:i_iwara/app/ui/widgets/like_button_widget.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/server_selector_dialog.dart';

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
  final UserService _userService = Get.find<UserService>();

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
    // 如果是非全屏，图标更小一些
    final double iconSize = currentScreenIsFullScreen
        ? (isSmallScreen ? 18 : 20)
        : (isSmallScreen ? 16 : 18);

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
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 在全屏且未登录时隐藏点赞和关注按钮
                  if (_userService.isLogin) ...[
                    _buildLikeButton(),
                    _spacer8,
                    _buildFollowButton(),
                    _spacer8,
                  ],
                  _buildAuthorInfo(isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
  ) {
    return SlideTransition(
      position: myVideoStateController.bottomBarAnimation,
      child: MouseRegion(
        onEnter: (_) => myVideoStateController.setToolbarHovering(true),
        onExit: (_) => myVideoStateController.setToolbarHovering(false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.videoDetail.resumeFromLastPosition(
                                position: CommonUtils.formatDuration(
                                  myVideoStateController.resumePosition.value,
                                ),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: currentScreenIsFullScreen ? 14 : 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => myVideoStateController
                                  .hideResumePositionTip(),
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
                  horizontal: isSmallScreen ? 0.0 : 4.0,
                ),
                child: CustomVideoProgressbar(
                  controller: myVideoStateController,
                ),
              ),
              SizedBox(
                height: currentScreenIsFullScreen
                    ? (isSmallScreen ? 36.0 : 40.0)
                    : (isSmallScreen ? 32.0 : 36.0),
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
    final Duration currentPosition = myVideoStateController.currentPosition;
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
                          max:
                              (selectedHours < totalHours ||
                                  selectedMinutes < totalMinutes)
                              ? 59
                              : totalSeconds.toDouble(),
                          divisions:
                              (selectedHours < totalHours ||
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
                final Duration clampedPosition = newPosition > totalDuration
                    ? totalDuration
                    : newPosition;

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
    // 固定的点击区域大小，或者根据 iconSize 稍微大一点
    // 这里使用 fixed size 策略来替代 padding
    final double touchSize = currentScreenIsFullScreen ? 40.0 : 32.0;

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          width: touchSize,
          height: touchSize,
          alignment: Alignment.center,
          child: icon,
        ),
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
    required Widget icon,
    required VoidCallback onPressed,
    String? tooltip, // 添加tooltip参数
  }) {
    // 固定的点击区域大小
    final double touchSize = currentScreenIsFullScreen ? 40.0 : 32.0;

    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            width: touchSize,
            height: touchSize,
            alignment: Alignment.center,
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

  /// 获取分辨率对应的 SVG 资源路径
  String _getResolutionIconAsset(String? label) {
    if (label == null) return 'assets/svg/res_unknown.svg';
    switch (label) {
      case '360':
        return 'assets/svg/res_360p.svg';
      case '540':
        return 'assets/svg/res_540p.svg';
      case '720':
        return 'assets/svg/res_720p.svg';
      case '1080':
        return 'assets/svg/res_1080p.svg';
      case 'Source':
        return 'assets/svg/res_source.svg';
      default:
        return 'assets/svg/res_unknown.svg';
    }
  }

  /// 分辨率切换器
  Widget _buildResolutionSwitcher(BuildContext context, double iconSize) {
    final t = slang.Translations.of(context);
    return Obx(() {
      String? currentResolution =
          myVideoStateController.currentResolutionTag.value;
      List<VideoResolution> resolutions =
          myVideoStateController.videoResolutions;

      // 如果没有获取到分辨率，不显示
      if (resolutions.isEmpty) {
        return const SizedBox.shrink();
      }

      // 去重：只保留每个清晰度标签的第一个分辨率
      final Map<String, VideoResolution> uniqueResolutionsMap = {};
      for (final resolution in resolutions) {
        if (!uniqueResolutionsMap.containsKey(resolution.label)) {
          uniqueResolutionsMap[resolution.label] = resolution;
        }
      }
      final uniqueResolutions = uniqueResolutionsMap.values.toList();

      final double touchSize = currentScreenIsFullScreen ? 40.0 : 32.0;
      return PopupMenuButton<String>(
        initialValue: currentResolution,
        tooltip: t.videoDetail.switchResolution,
        child: Container(
          width: touchSize,
          height: touchSize,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            _getResolutionIconAsset(currentResolution),
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: iconSize,
            height: iconSize,
          ),
        ),
        onSelected: (String selected) {
          if (selected != currentResolution) {
            // 保存用户手动选择的清晰度到新配置
            _configService.setSetting(ConfigKey.DEFAULT_QUALITY_KEY, selected);
            myVideoStateController.switchResolution(selected);
          }
        },
        itemBuilder: (BuildContext context) {
          return uniqueResolutions.map((VideoResolution resolution) {
            final isSelected = resolution.label == currentResolution;
            return PopupMenuItem<String>(
              value: resolution.label,
              child: Row(
                children: [
                  SvgPicture.asset(
                    _getResolutionIconAsset(resolution.label),
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(resolution.label),
                  if (isSelected) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.blue),
                  ],
                ],
              ),
            );
          }).toList();
        },
      );
    });
  }

  /// 播放速度切换器
  Widget _buildPlaybackSpeedSwitcher(BuildContext context, double iconSize) {
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
        3.0,
      ];

      // 只在全屏下显示
      if (!currentScreenIsFullScreen) {
        return const SizedBox.shrink();
      }

      final double touchSize = currentScreenIsFullScreen ? 40.0 : 32.0;
      return PopupMenuButton<double>(
        initialValue: currentSpeed,
        tooltip: t.videoDetail.switchPlaybackSpeed,
        child: Container(
          width: touchSize,
          height: touchSize,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/svg/playback_speed.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            width: iconSize,
            height: iconSize,
          ),
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
          myVideoStateController.videoInfo.value = myVideoStateController
              .videoInfo
              .value
              ?.copyWith(
                liked: liked,
                numLikes:
                    (myVideoStateController.videoInfo.value?.numLikes ?? 0) +
                    (liked ? 1 : -1),
              );
          // 更新缓存中的点赞信息
          myVideoStateController.updateCachedVideoLikeInfo(
            videoInfo.id,
            liked,
            myVideoStateController.videoInfo.value?.numLikes ?? 0,
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
          onUserUpdated: myVideoStateController.handleAuthorUpdated,
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
          AvatarWidget(user: videoInfo?.user, size: 30),
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

  Widget _buildLeftControls(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
  ) {
    return Row(
      children: [
        Obx(
          () => _buildSwitchIconButton(
            tooltip: myVideoStateController.videoPlaying.value
                ? t.videoDetail.pause
                : t.videoDetail.play,
            icon: SvgPicture.asset(
              myVideoStateController.videoPlaying.value
                  ? 'assets/svg/pause.svg'
                  : 'assets/svg/play.svg',
              key: ValueKey(
                myVideoStateController.videoPlaying.value ? 'pause' : 'play',
              ),
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
            ),
            onPressed: () async {
              VibrateUtils.vibrate();
              if (myVideoStateController.videoPlaying.value) {
                myVideoStateController.videoController.player.pause();
              } else {
                myVideoStateController.videoController.player.play();
                myVideoStateController.animateToTop();
              }
            },
          ),
        ),
        if (GetPlatform.isDesktop)
          VolumeControl(
            configService: _configService,
            myVideoStateController: myVideoStateController,
            iconSize: iconSize,
          ),
        _spacer4,
        TextButton(
          onPressed: () {
            _showSeekDialog(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 2.0 : 4.0,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Obx(
            () => Text(
              '${CommonUtils.formatDuration(myVideoStateController.toShowCurrentPosition.value)} / ${CommonUtils.formatDuration(myVideoStateController.totalDuration.value)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: currentScreenIsFullScreen
                    ? (isSmallScreen ? 11 : 12)
                    : (isSmallScreen ? 10 : 11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightControls(
    BuildContext context,
    bool isSmallScreen,
    double iconSize,
    slang.Translations t,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlaybackSpeedSwitcher(context, iconSize),
        _buildResolutionSwitcher(context, iconSize),
        _buildServerSelectorButton(context, iconSize),
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
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                        semanticsLabel: t.videoDetail.exitAppFullscreen,
                      )
                    : SvgPicture.asset(
                        'assets/svg/app_enter_fullscreen.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                        semanticsLabel: t.videoDetail.enterAppFullscreen,
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
            icon: SvgPicture.asset(
              currentScreenIsFullScreen
                  ? 'assets/svg/fullscreen_exit.svg'
                  : 'assets/svg/fullscreen_enter.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: iconSize,
              height: iconSize,
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

  /// 服务器选择按钮
  Widget _buildServerSelectorButton(BuildContext context, double iconSize) {
    // 只在本地视频模式下隐藏此按钮
    if (myVideoStateController.isLocalVideoMode) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      // 没获取到分辨率（也就意味着没获取到视频源）时隐藏
      if (myVideoStateController.videoResolutions.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildIconButton(
        tooltip: slang.t.mediaPlayer.serverSelector,
        icon: SvgPicture.asset(
          'assets/svg/server_selector.svg',
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          width: iconSize,
          height: iconSize,
        ),
        onPressed: () {
          _showServerSelectorDialog(context);
        },
      );
    });
  }

  /// 显示服务器选择对话框
  void _showServerSelectorDialog(BuildContext context) {
    final currentUrl = myVideoStateController.getCurrentVideoUrl();
    if (currentUrl == null || currentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(slang.t.mediaPlayer.cannotGetSource),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Get.dialog(
      ServerSelectorDialog(
        currentUrl: currentUrl,
        onServerSelected: (newUrl, serverName) {
          myVideoStateController.switchServerForCurrentResolution(
            newUrl,
            serverName,
          );
        },
      ),
      barrierDismissible: true,
    );
  }
}
