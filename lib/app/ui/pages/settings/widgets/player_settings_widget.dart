import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/three_section_slider.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart';
import 'package:i_iwara/app/ui/widgets/anime4k_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 视频播放器设置列表。
///
/// 该组件只会出现在较窄的容器中（播放器内的底部弹窗、设置页的限宽列）。
/// 因此采用 Material 3 的「分组卡片 + 扁平列表项」布局：
/// - 每个分区由一个小标题 + 一张分组卡片组成；
/// - 卡片内部使用扁平的 [SwitchListTile] / [ListTile]，不再为每个条目单独叠加阴影容器；
/// - 描述信息下沉为副标题，避免大块的提示卡片挤占纵向空间；
/// - 颜色全部取自主题 [ColorScheme]，自动适配深浅色。
class PlayerSettingsWidget extends StatelessWidget {
  final ConfigService _configService = Get.find();

  PlayerSettingsWidget({super.key});

  void _onThreeSectionSliderChangeFinished(
    double leftRatio,
    double middleRatio,
    double rightRatio,
  ) {
    _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] =
        leftRatio;
  }

  // 可选的播放倍速档位（与播放器内倍速菜单保持一致）
  static const List<double> _playbackSpeedOptions = [
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

  // ---------------------------------------------------------------------------
  // 通用布局辅助方法
  // ---------------------------------------------------------------------------

  /// 分区小标题（位于分组卡片上方）。
  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// 将若干条目组合进一张分组卡片，并在条目之间插入细分隔线。
  Widget _groupCard(BuildContext context, List<Widget> tiles) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i != tiles.length - 1) {
        children.add(
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
        );
      }
    }
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  /// 开关条目。描述信息作为副标题显示。
  Widget _switchTile({
    required BuildContext context,
    required IconData iconData,
    required String label,
    String? description,
    required Rx<dynamic> rxValue,
    required ValueChanged<bool> onChanged,
    bool disabled = false,
  }) {
    final theme = Theme.of(context);
    return Obx(
      () => SwitchListTile(
        secondary: Icon(iconData, color: theme.colorScheme.onSurfaceVariant),
        title: Text(label, style: theme.textTheme.bodyLarge),
        subtitle: description == null
            ? null
            : Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        value: rxValue.value as bool,
        onChanged: disabled ? null : onChanged,
      ),
    );
  }

  /// 可选项条目：点击后弹出选择对话框。当前值显示为副标题。
  Widget _selectionTile({
    required BuildContext context,
    required IconData iconData,
    required String label,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    String? description,
    Map<String, String>? optionLabels,
  }) {
    final theme = Theme.of(context);
    final valueLabel = optionLabels?[currentValue] ?? currentValue;
    return ListTile(
      leading: Icon(iconData, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        valueLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showSelectionDialog(
        context: context,
        title: label,
        description: description,
        currentValue: currentValue,
        options: options,
        optionLabels: optionLabels,
        onChanged: onChanged,
      ),
    );
  }

  /// 默认播放倍速：尾部下拉选择。
  Widget _defaultSpeedTile(BuildContext context, String label) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.slow_motion_video,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Obx(() {
        final double current =
            (_configService[ConfigKey.DEFAULT_PLAYBACK_SPEED_KEY] as double)
                .clamp(0.1, 4.0)
                .toDouble();
        // 保证当前值始终出现在下拉项中，避免历史遗留的非标准值导致断言失败
        final List<double> options = [..._playbackSpeedOptions];
        if (!options.contains(current)) {
          options.add(current);
          options.sort();
        }
        return DropdownButton<double>(
          value: current,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(12),
          items: options
              .map(
                (speed) => DropdownMenuItem<double>(
                  value: speed,
                  child: Text('${speed}x'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _configService[ConfigKey.DEFAULT_PLAYBACK_SPEED_KEY] = value;
            }
          },
        );
      }),
    );
  }

  /// 重要提示横幅（例如剧院模式的性能警告）。
  Widget _warningBanner(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示选择对话框
  Future<void> _showSelectionDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    String? description,
    Map<String, String>? optionLabels,
  }) async {
    final t = slang.Translations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(title)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
              tooltip: t.common.close,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.only(top: 12, bottom: 16),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.6, // 限制最大高度为屏幕高度的60%
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  RadioGroup<String>(
                    groupValue: currentValue,
                    onChanged: (value) => Navigator.pop(context, value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: options
                          .map(
                            (option) => RadioListTile<String>(
                              title: Text(optionLabels?[option] ?? option),
                              value: option,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && result != currentValue) {
      onChanged(result);
    }
  }

  // ---------------------------------------------------------------------------
  // build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final isMobile = GetPlatform.isAndroid || GetPlatform.isIOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // -------- 播放控制：倍速相关 --------
        _sectionLabel(context, t.settings.playbackSpeedSettings),
        _groupCard(context, [
          // 快进时间
          Obx(
            () => _NumberSettingTile(
              iconData: Icons.fast_forward,
              label: t.settings.fastForwardTime,
              initialValue: _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]
                  .toString(),
              suffixText: t.common.seconds,
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return t.settings.fastForwardTimeMustBeAPositiveInteger;
                }
                return null;
              },
              onValid: (value) {
                _configService.setSetting(
                  ConfigKey.FAST_FORWARD_SECONDS_KEY,
                  int.parse(value),
                );
              },
            ),
          ),
          // 后退时间
          Obx(
            () => _NumberSettingTile(
              iconData: Icons.fast_rewind,
              label: t.settings.rewindTime,
              initialValue: _configService[ConfigKey.REWIND_SECONDS_KEY]
                  .toString(),
              suffixText: t.common.seconds,
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return t.settings.rewindTimeMustBeAPositiveInteger;
                }
                return null;
              },
              onValid: (value) {
                _configService.setSetting(
                  ConfigKey.REWIND_SECONDS_KEY,
                  int.parse(value),
                );
              },
            ),
          ),
          // 长按播放倍速
          Obx(
            () => _NumberSettingTile(
              iconData: Icons.speed,
              label: t.settings.longPressPlaybackSpeed,
              initialValue:
                  _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY]
                      .toString(),
              suffixText: 'x',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0.0) {
                  return t.settings.longPressPlaybackSpeedMustBeAPositiveNumber;
                }
                return null;
              },
              onValid: (value) {
                _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY] =
                    double.parse(value);
              },
            ),
          ),
          // 默认播放倍速（新视频自动应用）
          _defaultSpeedTile(context, t.settings.defaultPlaybackSpeed),
          // 记住播放倍速
          _switchTile(
            context: context,
            iconData: Icons.speed,
            label: t.settings.rememberPlaybackSpeed,
            description: t.settings.rememberPlaybackSpeedDesc,
            rxValue:
                _configService.settings[ConfigKey.REMEMBER_PLAYBACK_SPEED_KEY]!,
            onChanged: (value) {
              _configService[ConfigKey.REMEMBER_PLAYBACK_SPEED_KEY] = value;
            },
          ),
        ]),
        const SizedBox(height: 20),

        // -------- 播放控制：行为相关 --------
        _sectionLabel(context, t.settings.playbackBehaviorSettings),
        _groupCard(context, [
          // 循环播放
          _switchTile(
            context: context,
            iconData: Icons.loop,
            label: t.settings.repeat,
            rxValue: _configService.settings[ConfigKey.REPEAT_KEY]!,
            onChanged: (value) {
              _configService[ConfigKey.REPEAT_KEY] = value;
            },
          ),
          // 记住音量（仅限 PC）
          if (GetPlatform.isDesktop)
            _switchTile(
              context: context,
              iconData: Icons.volume_up,
              label: t.settings.rememberVolume,
              description: t
                  .settings
                  .thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain,
              rxValue:
                  _configService.settings[ConfigKey.KEEP_LAST_VOLUME_KEY]!,
              onChanged: (value) {
                _configService[ConfigKey.KEEP_LAST_VOLUME_KEY] = value;
              },
            ),
          // 记住亮度（仅限移动端）
          if (isMobile)
            _switchTile(
              context: context,
              iconData: Icons.brightness_medium,
              label: t.settings.rememberBrightness,
              description: t
                  .settings
                  .thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain,
              rxValue:
                  _configService.settings[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY]!,
              onChanged: (value) {
                _configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY] = value;
              },
            ),
          // 记录并恢复播放进度
          _switchTile(
            context: context,
            iconData: Icons.play_circle_outline,
            label: t.settings.recordAndRestorePlaybackProgress,
            rxValue: _configService
                .settings[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]!,
            onChanged: (value) {
              _configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS] =
                  value;
            },
          ),
          // 首次进入自动播放
          _switchTile(
            context: context,
            iconData: Icons.play_arrow,
            label: t.settings.autoPlayVideoOnFirstEnter,
            description: t.settings.autoPlayVideoOnFirstEnterDesc,
            rxValue: _configService
                .settings[ConfigKey.AUTO_PLAY_VIDEO_ON_FIRST_ENTER]!,
            onChanged: (value) {
              _configService[ConfigKey.AUTO_PLAY_VIDEO_ON_FIRST_ENTER] = value;
            },
          ),
          // 工具栏隐藏时显示底部进度条
          _switchTile(
            context: context,
            iconData: Icons.linear_scale,
            label: t.settings.showVideoProgressBottomBarWhenToolbarHidden,
            description:
                t.settings.showVideoProgressBottomBarWhenToolbarHiddenDesc,
            rxValue: _configService.settings[ConfigKey
                .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN]!,
            onChanged: (value) {
              _configService[ConfigKey
                      .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN] =
                  value;
            },
          ),
          // 屏幕中央播放/暂停按钮
          _switchTile(
            context: context,
            iconData: Icons.play_circle_outline,
            label: t.settings.showCenterPlayPauseButton,
            description: t.settings.showCenterPlayPauseButtonDesc,
            rxValue: _configService
                .settings[ConfigKey.SHOW_CENTER_PLAY_PAUSE_BUTTON]!,
            onChanged: (value) {
              _configService[ConfigKey.SHOW_CENTER_PLAY_PAUSE_BUTTON] = value;
            },
          ),
          // 全屏下一个提示
          _switchTile(
            context: context,
            iconData: Icons.queue_play_next,
            label: t.settings.showFullscreenUpNextHint,
            description: t.settings.showFullscreenUpNextHintDesc,
            rxValue:
                _configService.settings[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT]!,
            onChanged: (value) {
              _configService[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT] = value;
            },
          ),
          // 工具栏常驻
          _switchTile(
            context: context,
            iconData: Icons.visibility,
            label: t.settings.defaultKeepVideoToolbarVisible,
            description: t.settings.defaultKeepVideoToolbarVisibleDesc,
            rxValue: _configService
                .settings[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE]!,
            onChanged: (value) {
              _configService[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE] =
                  value;
            },
          ),
          // 鼠标悬浮显示工具栏
          _switchTile(
            context: context,
            iconData: Icons.mouse,
            label: t.settings.enableMouseHoverShowToolbar,
            description: t.settings.enableMouseHoverShowToolbarInfo,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR] = value;
            },
          ),
          // 以竖屏模式渲染竖屏视频（仅移动端）
          if (isMobile)
            _switchTile(
              context: context,
              iconData: Icons.smartphone,
              label: t.settings.renderVerticalVideoInVerticalScreen,
              description: t
                  .settings
                  .thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen,
              rxValue: _configService.settings[ConfigKey
                  .RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN]!,
              onChanged: (value) {
                _configService[ConfigKey
                        .RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN] =
                    value;
              },
            ),
          // 全屏方向（仅移动端）
          if (isMobile)
            Obx(
              () => _selectionTile(
                context: context,
                iconData: Icons.screen_rotation,
                label: t.settings.fullscreenOrientation,
                description: t.settings.fullscreenOrientationDesc,
                currentValue:
                    _configService[ConfigKey.FULLSCREEN_ORIENTATION] as String,
                options: const ['landscape_left', 'landscape_right'],
                optionLabels: {
                  'landscape_left':
                      t.settings.fullscreenOrientationLeftLandscape,
                  'landscape_right':
                      t.settings.fullscreenOrientationRightLandscape,
                },
                onChanged: (value) {
                  _configService[ConfigKey.FULLSCREEN_ORIENTATION] = value;
                },
              ),
            ),
        ]),
        const SizedBox(height: 20),

        // -------- 控制区域宽度 --------
        _sectionLabel(context, t.settings.playControlArea),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.settings.leftAndRightControlAreaWidth,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      preferBelow: false,
                      message: t
                          .settings
                          .thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer,
                      child: Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ThreeSectionSlider(
                  onSlideChangeCallback: _onThreeSectionSliderChangeFinished,
                  initialLeftRatio: _configService[ConfigKey
                      .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                  initialMiddleRatio:
                      (1 -
                              _configService[ConfigKey
                                      .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] *
                                  2)
                          .toDouble(),
                  initialRightRatio: _configService[ConfigKey
                      .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // -------- 手势控制 --------
        _sectionLabel(context, t.settings.gestureControl),
        _groupCard(context, [
          _switchTile(
            context: context,
            iconData: Icons.fast_rewind,
            label: t.settings.leftDoubleTapRewind,
            rxValue:
                _configService.settings[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND] = value;
            },
          ),
          _switchTile(
            context: context,
            iconData: Icons.fast_forward,
            label: t.settings.rightDoubleTapFastForward,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD] =
                  value;
            },
          ),
          _switchTile(
            context: context,
            iconData: Icons.pause,
            label: t.settings.doubleTapPause,
            rxValue:
                _configService.settings[ConfigKey.ENABLE_DOUBLE_TAP_PAUSE]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_DOUBLE_TAP_PAUSE] = value;
            },
          ),
          // 左侧上下滑动调整亮度（仅移动端）
          if (isMobile)
            _switchTile(
              context: context,
              iconData: Icons.brightness_medium,
              label: t.settings.leftVerticalSwipeBrightness,
              rxValue: _configService
                  .settings[ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS]!,
              onChanged: (value) {
                _configService[ConfigKey.ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS] =
                    value;
              },
            ),
          _switchTile(
            context: context,
            iconData: Icons.volume_up,
            label: t.settings.rightVerticalSwipeVolume,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME] =
                  value;
            },
          ),
          _switchTile(
            context: context,
            iconData: Icons.fast_forward,
            label: t.settings.longPressFastForward,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] = value;
            },
          ),
          _switchTile(
            context: context,
            iconData: Icons.swap_horiz,
            label: t.settings.enableHorizontalDragSeek,
            rxValue:
                _configService.settings[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] = value;
            },
          ),
          _switchTile(
            context: context,
            iconData: Icons.pinch,
            label: t.settings.enableVideoGestureZoom,
            description: t.settings.enableVideoGestureZoomInfo,
            rxValue:
                _configService.settings[ConfigKey.ENABLE_VIDEO_GESTURE_ZOOM]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_VIDEO_GESTURE_ZOOM] = value;
            },
          ),
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              t.videoDetail.gestureGuide.viewGuide,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => VideoGestureGuideDialog.show(context),
          ),
        ]),
        const SizedBox(height: 20),

        // -------- 剧院模式 & 画质增强 --------
        _sectionLabel(context, t.settings.enhancementSettings),
        _warningBanner(
          context,
          t
              .settings
              .theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt,
        ),
        const SizedBox(height: 8),
        _groupCard(context, [
          _switchTile(
            context: context,
            iconData: Icons.theater_comedy,
            label: t.settings.theaterMode,
            rxValue: _configService.settings[ConfigKey.THEATER_MODE_KEY]!,
            onChanged: (value) {
              _configService[ConfigKey.THEATER_MODE_KEY] = value;
            },
          ),
        ]),
        const SizedBox(height: 8),
        Anime4KSettingsWidget(
          showInfoCard: true,
          infoMessage: t.anime4k.realTimeVideoUpscalingAndDenoising,
        ),
        const SizedBox(height: 20),

        // -------- 音视频配置 --------
        _sectionLabel(context, t.settings.audioVideoConfig),
        _groupCard(context, [
          // 扩大缓冲区
          _switchTile(
            context: context,
            iconData: Icons.memory,
            label: t.settings.expandBuffer,
            description: t.settings.expandBufferInfo,
            rxValue: _configService.settings[ConfigKey.EXPAND_BUFFER]!,
            onChanged: (value) {
              _configService[ConfigKey.EXPAND_BUFFER] = value;
            },
          ),
          // 视频同步
          Obx(
            () => _selectionTile(
              context: context,
              iconData: Icons.sync,
              label: t.settings.videoSyncMode,
              description: t.settings.videoSyncModeSubtitle,
              currentValue: _configService[ConfigKey.VIDEO_SYNC],
              options: const [
                'audio',
                'display-resample',
                'display-resample-vdrop',
                'display-resample-desync',
                'display-tempo',
                'display-vdrop',
                'display-adrop',
                'display-desync',
                'desync',
              ],
              optionLabels: {
                'audio': t.settings.videoSyncAudio,
                'display-resample': t.settings.videoSyncDisplayResample,
                'display-resample-vdrop':
                    t.settings.videoSyncDisplayResampleVdrop,
                'display-resample-desync':
                    t.settings.videoSyncDisplayResampleDesync,
                'display-tempo': t.settings.videoSyncDisplayTempo,
                'display-vdrop': t.settings.videoSyncDisplayVdrop,
                'display-adrop': t.settings.videoSyncDisplayAdrop,
                'display-desync': t.settings.videoSyncDisplayDesync,
                'desync': t.settings.videoSyncDesync,
              },
              onChanged: (value) {
                _configService[ConfigKey.VIDEO_SYNC] = value;
              },
            ),
          ),
          // 硬解模式
          Obx(
            () => _selectionTile(
              context: context,
              iconData: Icons.hardware,
              label: t.settings.hardwareDecodingMode,
              description: t.settings.hardwareDecodingModeSubtitle,
              currentValue: _configService[ConfigKey.HARDWARE_DECODING],
              options: const ['auto', 'auto-copy', 'auto-safe', 'no', 'yes'],
              optionLabels: {
                'auto': t.settings.hardwareDecodingAuto,
                'auto-copy': t.settings.hardwareDecodingAutoCopy,
                'auto-safe': t.settings.hardwareDecodingAutoSafe,
                'no': t.settings.hardwareDecodingNo,
                'yes': t.settings.hardwareDecodingYes,
              },
              onChanged: (value) {
                _configService[ConfigKey.HARDWARE_DECODING] = value;
              },
            ),
          ),
          // 启用硬件加速
          _switchTile(
            context: context,
            iconData: Icons.speed,
            label: t.settings.enableHardwareAcceleration,
            description: t.settings.enableHardwareAccelerationInfo,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_HARDWARE_ACCELERATION]!,
            onChanged: (value) {
              _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION] = value;
            },
          ),
          // OpenSLES 音频输出（仅 Android）
          if (GetPlatform.isAndroid)
            _switchTile(
              context: context,
              iconData: Icons.audiotrack,
              label: t.settings.useOpenSLESAudioOutput,
              description: t.settings.useOpenSLESAudioOutputInfo,
              rxValue: _configService.settings[ConfigKey.USE_OPENSLES]!,
              onChanged: (value) {
                _configService[ConfigKey.USE_OPENSLES] = value;
              },
            ),
        ]),
        const SizedBox(height: 16),
        SizedBox(height: computeBottomSafeInset(MediaQuery.of(context))),
      ],
    );
  }
}

/// 数字输入条目：左侧图标 + 标题，右侧紧凑输入框，带即时校验。
///
/// 行为对齐原 `SettingItem`：校验通过即写回配置，校验失败在下方显示错误信息。
class _NumberSettingTile extends StatefulWidget {
  final IconData iconData;
  final String label;
  final String initialValue;
  final String suffixText;
  final TextInputType keyboardType;
  final String? Function(String) validator;
  final ValueChanged<String> onValid;

  const _NumberSettingTile({
    required this.iconData,
    required this.label,
    required this.initialValue,
    required this.suffixText,
    required this.keyboardType,
    required this.validator,
    required this.onValid,
  });

  @override
  State<_NumberSettingTile> createState() => _NumberSettingTileState();
}

class _NumberSettingTileState extends State<_NumberSettingTile> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _handleChanged(String value) {
    final error = widget.validator(value);
    setState(() => _errorText = error);
    if (error == null) {
      widget.onValid(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = _errorText != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.iconData, color: cs.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(widget.label, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 104,
                child: TextField(
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  textAlign: TextAlign.end,
                  onChanged: _handleChanged,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: widget.suffixText,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: hasError ? cs.error : cs.outline,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: hasError ? cs.error : cs.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 40),
              child: Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
              ),
            ),
        ],
      ),
    );
  }
}
