import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/desktop_player_manager_dialog.dart';
import 'package:i_iwara/app/ui/pages/settings/keybinding_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/three_section_slider.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/video_gesture_guide.dart';
import 'package:i_iwara/app/ui/widgets/anime4k_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 视频播放器设置列表。
///
/// 该组件只会出现在较窄的容器中（播放器内的底部弹窗、设置页的限宽列）。
/// 因此采用 Material 3 的「分组卡片 + 扁平列表项」布局：
/// - 每个分区由一个小标题 + 一张分组卡片组成；
/// - 所有卡片统一由 [_card] 产出（同一圆角/阴影/裁剪），不再各处手写 [Card]；
/// - 卡片内部只使用四种条目：开关 [_switchTile]、选择 [_selectionTile]、
///   跳转 [_navigationTile]、数字输入 [_NumberSettingTile]，四者共用
///   `ListTile` 的图标位与文字层级，保证行高与左右留白一致；
/// - 描述信息一律下沉为副标题，避免大块的提示卡片挤占纵向空间；
/// - 颜色全部取自主题 [ColorScheme]，自动适配深浅色。
class PlayerSettingsWidget extends StatelessWidget {
  final ConfigService _configService = Get.find();

  /// 在播放器内（底部弹窗）展示时为 true：快捷键配置改用底部抽屉；
  /// 在设置页中为 false：快捷键配置仍跳转独立页面。
  final bool openKeybindingAsSheet;

  /// 从播放器内呼出时传入当前播放器的控制器，用于展示只作用于该播放器的
  /// 会话级选项（如「画面尺寸」）；从设置页进入时为 null，不显示这些选项。
  final MyVideoStateController? playerController;

  PlayerSettingsWidget({
    super.key,
    this.openKeybindingAsSheet = false,
    this.playerController,
  });

  /// 分区之间（大标题+分组卡片 之间）的统一间距。
  static const double _kGroupGap = 20;

  /// 所有卡片统一的圆角。
  static const BorderRadius _kCardRadius = BorderRadius.all(
    Radius.circular(16),
  );

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

  /// 统一的卡片外壳，页面内所有卡片都从这里产出。
  Widget _card({required Widget child}) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: _kCardRadius),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// 将若干条目组合进一张分组卡片，并在条目之间插入细分隔线。
  Widget _groupCard(List<Widget> tiles) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i != tiles.length - 1) {
        children.add(
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
        );
      }
    }
    return _card(
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
      () => GlassSwitchItem(
        icon: iconData,
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

  /// 点击型条目的统一样式：左图标 + 标题 + 右箭头。
  ///
  /// [valueLabel] 用于展示当前值（主色强调），[description] 用于展示说明
  /// （次要色）；两者都为空时只显示标题。选择类条目 [_selectionTile] 与
  /// 跳转类入口都走这里，保证箭头颜色、文字层级一致。
  Widget _navigationTile({
    required BuildContext context,
    required IconData iconData,
    required String label,
    required VoidCallback onTap,
    String? valueLabel,
    String? description,
  }) {
    final theme = Theme.of(context);
    Widget? subtitle;
    if (valueLabel != null) {
      subtitle = Text(
        valueLabel,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      );
    } else if (description != null) {
      subtitle = Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return ListTile(
      leading: Icon(iconData, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: subtitle,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
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
    Map<String, String>? optionDescriptions,
  }) {
    return _navigationTile(
      context: context,
      iconData: iconData,
      label: label,
      valueLabel: optionLabels?[currentValue] ?? currentValue,
      onTap: () => _showSelectionDialog(
        context: context,
        title: label,
        description: description,
        currentValue: currentValue,
        options: options,
        optionLabels: optionLabels,
        optionDescriptions: optionDescriptions,
        onChanged: onChanged,
      ),
    );
  }

  /// 默认播放倍速：与其它可选项条目共用同一套「当前值 + 选择对话框」交互。
  Widget _defaultSpeedTile(BuildContext context, String label) {
    return Obx(() {
      final double current =
          (_configService[ConfigKey.DEFAULT_PLAYBACK_SPEED_KEY] as double)
              .clamp(0.1, 4.0)
              .toDouble();
      // 保证当前值始终出现在选项中，避免历史遗留的非标准值无法回显
      final List<double> options = [..._playbackSpeedOptions];
      if (!options.contains(current)) {
        options.add(current);
        options.sort();
      }
      return _selectionTile(
        context: context,
        iconData: Icons.slow_motion_video,
        label: label,
        currentValue: current.toString(),
        options: options.map((speed) => speed.toString()).toList(),
        optionLabels: {
          for (final speed in options) speed.toString(): '${speed}x',
        },
        onChanged: (value) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            _configService[ConfigKey.DEFAULT_PLAYBACK_SPEED_KEY] = parsed;
          }
        },
      );
    });
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
    Map<String, String>? optionDescriptions,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => GlassAlertDialog(
        title: title,
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
                              subtitle: optionDescriptions?[option] == null
                                  ? null
                                  : Text(optionDescriptions![option]!),
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
    final theme = Theme.of(context);
    final isMobile = GetPlatform.isAndroid || GetPlatform.isIOS;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // -------- 画面尺寸（仅从播放器呼出时显示） --------
        if (playerController != null) ...[
          _sectionLabel(context, t.settings.screenFit),
          _groupCard([
            Obx(
              () => _selectionTile(
                context: context,
                iconData: Icons.aspect_ratio,
                label: t.settings.screenFit,
                description: t.settings.screenFitDesc,
                currentValue: playerController!.screenFitMode.value.name,
                options: PlayerScreenFitMode.values
                    .map((mode) => mode.name)
                    .toList(),
                optionLabels: {
                  PlayerScreenFitMode.fit.name: t.settings.screenFitFit,
                  PlayerScreenFitMode.stretch.name: t.settings.screenFitStretch,
                  PlayerScreenFitMode.cover.name: t.settings.screenFitCover,
                  PlayerScreenFitMode.ratio16x9.name: '16:9',
                  PlayerScreenFitMode.ratio4x3.name: '4:3',
                },
                optionDescriptions: {
                  PlayerScreenFitMode.fit.name: t.settings.screenFitFitDesc,
                  PlayerScreenFitMode.stretch.name:
                      t.settings.screenFitStretchDesc,
                  PlayerScreenFitMode.cover.name: t.settings.screenFitCoverDesc,
                  PlayerScreenFitMode.ratio16x9.name:
                      t.settings.screenFitRatioDesc,
                  PlayerScreenFitMode.ratio4x3.name:
                      t.settings.screenFitRatioDesc,
                },
                onChanged: (value) {
                  playerController!.setScreenFitMode(
                    PlayerScreenFitMode.values.byName(value),
                    persistAsDefault: true,
                  );
                },
              ),
            ),
            _switchTile(
              context: context,
              iconData: Icons.bookmark_outline,
              label: t.settings.rememberScreenFit,
              description: t.settings.rememberScreenFitDesc,
              rxValue: _configService
                  .settings[ConfigKey.REMEMBER_SCREEN_FIT_MODE_KEY]!,
              onChanged: (value) {
                if (value) {
                  // 先提交当前模式，避免开关已开启但默认值仍是旧值。
                  _configService[ConfigKey.DEFAULT_SCREEN_FIT_MODE_KEY] =
                      playerController!.screenFitMode.value.name;
                }
                _configService[ConfigKey.REMEMBER_SCREEN_FIT_MODE_KEY] = value;
              },
            ),
          ]),
          const SizedBox(height: _kGroupGap),
        ],

        // -------- 播放控制：倍速相关 --------
        _sectionLabel(context, t.settings.playbackSpeedSettings),
        _groupCard([
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
            iconData: Icons.bookmark_outline,
            label: t.settings.rememberPlaybackSpeed,
            description: t.settings.rememberPlaybackSpeedDesc,
            rxValue:
                _configService.settings[ConfigKey.REMEMBER_PLAYBACK_SPEED_KEY]!,
            onChanged: (value) {
              _configService[ConfigKey.REMEMBER_PLAYBACK_SPEED_KEY] = value;
            },
          ),
        ]),
        const SizedBox(height: _kGroupGap),

        // -------- 播放控制：行为相关 --------
        _sectionLabel(context, t.settings.playbackBehaviorSettings),
        _groupCard([
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
              rxValue: _configService.settings[ConfigKey.KEEP_LAST_VOLUME_KEY]!,
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
            iconData: Icons.restore,
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
            rxValue:
                _configService.settings[ConfigKey
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
            rxValue: _configService
                .settings[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT]!,
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
              rxValue:
                  _configService.settings[ConfigKey
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
        const SizedBox(height: _kGroupGap),

        // -------- 控制区域宽度 --------
        // 滑杆需要整行宽度，因此不放进 ListTile 的 trailing，而是以
        // 「标题条目 + 下方滑杆」的形式放进同一张分组卡片，保持左右留白一致。
        _sectionLabel(context, t.settings.playControlArea),
        _card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.view_column,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  t.settings.leftAndRightControlAreaWidth,
                  style: theme.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  t
                      .settings
                      .thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ThreeSectionSlider(
                  onSlideChangeCallback: _onThreeSectionSliderChangeFinished,
                  initialLeftRatio:
                      _configService[ConfigKey
                          .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                  initialMiddleRatio:
                      (1 -
                              _configService[ConfigKey
                                      .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] *
                                  2)
                          .toDouble(),
                  initialRightRatio:
                      _configService[ConfigKey
                          .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _kGroupGap),

        // -------- 手势控制 --------
        _sectionLabel(context, t.settings.gestureControl),
        _groupCard([
          _switchTile(
            context: context,
            iconData: Icons.fast_rewind,
            label: t.settings.leftDoubleTapRewind,
            rxValue: _configService
                .settings[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND]!,
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
                _configService[ConfigKey
                        .ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS] =
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
            iconData: Icons.touch_app,
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
          _navigationTile(
            context: context,
            iconData: Icons.help_outline,
            label: t.videoDetail.gestureGuide.viewGuide,
            onTap: () => VideoGestureGuideDialog.show(context),
          ),
          // 快捷键设置入口：播放器内以底部抽屉弹出（默认视频作用域），
          // 在整体设置页内则整页打开（全部作用域）。改动经 KeybindingService 的
          // 响应式 bindings 即时生效，作用于当前已打开的播放器/图库。
          _navigationTile(
            context: context,
            iconData: Icons.keyboard,
            label: t.settings.keybinding.title,
            onTap: () => openKeybindingAsSheet
                ? KeybindingSettingsPage.openSheet(context)
                : KeybindingSettingsPage.open(context),
          ),
        ]),
        const SizedBox(height: _kGroupGap),

        // -------- 剧院模式 & 画质增强 --------
        // Anime4K / 色觉辅助以嵌入模式渲染，去掉各自的独立卡片与提示横幅，
        // 与剧院模式开关同处一张分组卡片。
        _sectionLabel(context, t.settings.enhancementSettings),
        _groupCard([
          _switchTile(
            context: context,
            iconData: Icons.theater_comedy,
            label: t.settings.theaterMode,
            description: t.settings.theaterModeDesc,
            rxValue: _configService.settings[ConfigKey.THEATER_MODE_KEY]!,
            onChanged: (value) {
              _configService[ConfigKey.THEATER_MODE_KEY] = value;
            },
          ),
          const Anime4KSettingsWidget(embedded: true),
          // 色觉辅助滤镜（作用于所有播放器画面，与 Anime4K 可同时开启）
          const ColorVisionSettingsWidget(embedded: true),
        ]),
        const SizedBox(height: _kGroupGap),

        // -------- 音视频配置 --------
        _sectionLabel(context, t.settings.audioVideoConfig),
        _groupCard([
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
            iconData: Icons.bolt,
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
        // -------- 外部播放器（仅桌面端） --------
        // PCVR 播放器（HereSphere / DeoVR / Whirligig 等）都不是系统默认关联
        // 程序，「用系统默认播放器打开」对头显用户等于没用；指定可执行文件后，
        // 播放器里的「用其他应用打开」就能直接把本地文件或在线直链甩过去。
        if (GetPlatform.isDesktop) ...[
          const SizedBox(height: _kGroupGap),
          _sectionLabel(context, t.externalPlayer.desktopSectionTitle),
          _groupCard([
            Obx(() {
              final count = DesktopPlayerStore.decode(
                _configService.settings[ConfigKey.EXTERNAL_PLAYERS_JSON]!.value
                    as String,
              ).length;
              return _navigationTile(
                context: context,
                iconData: Icons.smart_display_outlined,
                label: t.externalPlayer.managePlayers,
                valueLabel: count > 0
                    ? t.externalPlayer.playerCount(count: count)
                    : null,
                description: count > 0
                    ? null
                    : t.externalPlayer.managePlayersDesc,
                onTap: () => showDesktopPlayerManagerDialog(context),
              );
            }),
          ]),
        ],
        const SizedBox(height: _kGroupGap),
        SizedBox(height: computeBottomSafeInset(MediaQuery.of(context))),
      ],
    );
  }
}

/// 数字输入条目：左侧图标 + 标题，右侧紧凑输入框，带即时校验。
///
/// 结构与其它条目一致（同为 `ListTile`），因此行高、图标位、左右留白都对齐；
/// 校验失败时错误信息占用副标题位置。
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
    return ListTile(
      leading: Icon(widget.iconData, color: cs.onSurfaceVariant),
      title: Text(widget.label, style: theme.textTheme.bodyLarge),
      subtitle: hasError
          ? Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            )
          : null,
      trailing: SizedBox(
        width: 104,
        child: GlassInputSurface(
          borderRadius: 10,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          error: hasError,
          child: TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.end,
            onChanged: _handleChanged,
            style: theme.textTheme.bodyLarge,
            decoration: glassFieldDecoration(context).copyWith(
              isDense: true,
              suffixText: widget.suffixText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
