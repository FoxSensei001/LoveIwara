import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/three_section_slider.dart';
import 'package:i_iwara/app/ui/widgets/anime4k_settings_widget.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

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

  // 创建开关设置项，并在上方显示信息提示卡片
  Widget _buildSwitchSetting({
    required IconData iconData,
    required String label,
    bool showInfoCard = false,
    String? infoMessage,
    required Rx<dynamic> rxValue,
    required Function(bool) onChanged,
    required BuildContext context,
    bool disabled = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showInfoCard && infoMessage != null)
          Card(
            color: Theme.of(Get.context!).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Get.isDarkMode ? Colors.white : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    // 使用 Expanded 确保文本不会溢出
                    child: Text(
                      infoMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (showInfoCard && infoMessage != null) const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(iconData, color: Get.isDarkMode ? Colors.white : null),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(Get.context!).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IgnorePointer(
                  ignoring: disabled,
                  child: Opacity(
                    opacity: disabled ? 0.5 : 1,
                    child: Switch(
                      value: rxValue.value as bool,
                      onChanged: disabled ? null : onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 构建选择设置项
  Widget _buildSelectionSetting({
    required IconData iconData,
    required String label,
    required String currentValue,
    required List<String> options,
    required Function(String) onChanged,
    required BuildContext context,
    String? subtitle,
    Map<String, String>? optionLabels,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSelectionDialog(
          context: context,
          title: label,
          currentValue: currentValue,
          options: options,
          optionLabels: optionLabels,
          onChanged: onChanged,
        ),
        child: Row(
          children: [
            Icon(iconData, color: Get.isDarkMode ? Colors.white : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(Get.context!).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(
                        Get.context!,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                ],
              ),
            ),
            Text(
              optionLabels?[currentValue] ?? currentValue,
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: Theme.of(Get.context!).primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Get.isDarkMode ? Colors.white : null,
            ),
          ],
        ),
      ),
    );
  }

  // 显示选择对话框
  Future<void> _showSelectionDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<String> options,
    required Function(String) onChanged,
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
                children: options
                    .map(
                      (option) => ListTile(
                        title: Text(optionLabels?[option] ?? option),
                        trailing: currentValue == option
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, option),
                      ),
                    )
                    .toList(),
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

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.playControl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 快进时间设置
                  Obx(
                    () => SettingItem(
                      label: t.settings.fastForwardTime,
                      initialValue:
                          _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY]
                              .toString(),
                      validator: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return t
                              .settings
                              .fastForwardTimeMustBeAPositiveInteger;
                        }
                        return null;
                      },
                      onValid: (value) {
                        final parsed = int.parse(value);
                        _configService.setSetting(
                          ConfigKey.FAST_FORWARD_SECONDS_KEY,
                          parsed,
                        );
                      },
                      icon: Icon(
                        Icons.fast_forward,
                        color: Get.isDarkMode ? Colors.white : null,
                      ),
                      inputDecoration: InputDecoration(
                        suffixText: t.common.seconds,
                        suffixStyle: TextStyle(
                          color: Get.isDarkMode ? Colors.white : null,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 后退时间设置
                  Obx(
                    () => SettingItem(
                      label: t.settings.rewindTime,
                      initialValue: _configService[ConfigKey.REWIND_SECONDS_KEY]
                          .toString(),
                      validator: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return t.settings.rewindTimeMustBeAPositiveInteger;
                        }
                        return null;
                      },
                      onValid: (value) {
                        final parsed = int.parse(value);
                        _configService.setSetting(
                          ConfigKey.REWIND_SECONDS_KEY,
                          parsed,
                        );
                      },
                      icon: Icon(
                        Icons.fast_rewind,
                        color: Get.isDarkMode ? Colors.white : null,
                      ),
                      inputDecoration: InputDecoration(
                        suffixText: t.common.seconds,
                        suffixStyle: TextStyle(
                          color: Get.isDarkMode ? Colors.white : null,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 长按播放倍速设置
                  Obx(
                    () => SettingItem(
                      label: t.settings.longPressPlaybackSpeed,
                      initialValue:
                          _configService[ConfigKey
                                  .LONG_PRESS_PLAYBACK_SPEED_KEY]
                              .toString(),
                      validator: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0.0) {
                          return t
                              .settings
                              .longPressPlaybackSpeedMustBeAPositiveNumber;
                        }
                        return null;
                      },
                      onValid: (value) {
                        final parsed = double.parse(value);
                        _configService[ConfigKey
                                .LONG_PRESS_PLAYBACK_SPEED_KEY] =
                            parsed;
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      icon: Icon(
                        Icons.speed,
                        color: Get.isDarkMode ? Colors.white : null,
                      ),
                      inputDecoration: InputDecoration(
                        suffixText: 'x',
                        suffixStyle: TextStyle(
                          color: Get.isDarkMode ? Colors.white : null,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.playControl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 循环播放
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.loop,
                    label: t.settings.repeat,
                    showInfoCard: false,
                    infoMessage: null,
                    rxValue: _configService.settings[ConfigKey.REPEAT_KEY]!,
                    onChanged: (value) {
                      _configService[ConfigKey.REPEAT_KEY] = value;
                    },
                  ),
                  // 记住音量
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.volume_up,
                    label: t.settings.rememberVolume,
                    showInfoCard: true,
                    infoMessage: t
                        .settings
                        .thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain,
                    rxValue: _configService
                        .settings[ConfigKey.KEEP_LAST_VOLUME_KEY]!,
                    onChanged: (value) {
                      _configService[ConfigKey.KEEP_LAST_VOLUME_KEY] = value;
                    },
                  ),
                  // 记住亮度（仅限特定平台）
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    _buildSwitchSetting(
                      context: context,
                      iconData: Icons.brightness_medium,
                      label: t.settings.rememberBrightness,
                      showInfoCard: true,
                      infoMessage: t
                          .settings
                          .thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain,
                      rxValue: _configService
                          .settings[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY]!,
                      onChanged: (value) {
                        _configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY] =
                            value;
                      },
                    ),
                  // 添加记录和恢复播放进度的设置
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.play_circle_outline,
                    label: t.settings.recordAndRestorePlaybackProgress,
                    showInfoCard: false,
                    infoMessage: null,
                    rxValue: _configService
                        .settings[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .RECORD_AND_RESTORE_VIDEO_PROGRESS] =
                          value;
                    },
                  ),
                  // 添加显示底部进度条的设置
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.linear_scale,
                    label:
                        t.settings.showVideoProgressBottomBarWhenToolbarHidden,
                    showInfoCard: true,
                    infoMessage: t
                        .settings
                        .showVideoProgressBottomBarWhenToolbarHiddenDesc,
                    rxValue:
                        _configService.settings[ConfigKey
                            .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN] =
                          value;
                    },
                  ),
                  // 添加工具栏常驻开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.visibility,
                    label: t.settings.defaultKeepVideoToolbarVisible,
                    showInfoCard: true,
                    infoMessage: t.settings.defaultKeepVideoToolbarVisibleDesc,
                    rxValue:
                        _configService.settings[ConfigKey
                            .DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE] =
                          value;
                    },
                  ),
                  // 添加鼠标悬浮显示工具栏开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.mouse,
                    // label: '鼠标悬浮时显示工具栏',
                    label: t.settings.enableMouseHoverShowToolbar,
                    showInfoCard: true,
                    // infoMessage: '开启后，当鼠标悬浮在播放器上移动时会自动显示工具栏，停止移动3秒后自动隐藏',
                    infoMessage: t.settings.enableMouseHoverShowToolbarInfo,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .ENABLE_MOUSE_HOVER_SHOW_TOOLBAR] =
                          value;
                    },
                  ),
                  // 添加锁定按钮位置设置
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lock,
                              color: Get.isDarkMode ? Colors.white : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t.settings.lockButtonPosition,
                                style: Theme.of(Get.context!)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final currentPosition =
                              _configService[ConfigKey
                                      .VIDEO_TOOLBAR_LOCK_BUTTON_POSITION]
                                  as int;
                          return RadioGroup<int>(
                            groupValue: currentPosition,
                            onChanged: (value) {
                              if (value != null) {
                                _configService[ConfigKey
                                        .VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] =
                                    value;
                              }
                            },
                            child: Column(
                              children: [
                                RadioListTile<int>(
                                  title: Text(
                                    t.settings.lockButtonPositionBothSides,
                                  ),
                                  value: 1,
                                ),
                                RadioListTile<int>(
                                  title: Text(
                                    t.settings.lockButtonPositionLeftSide,
                                  ),
                                  value: 2,
                                ),
                                RadioListTile<int>(
                                  title: Text(
                                    t.settings.lockButtonPositionRightSide,
                                  ),
                                  value: 3,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 以竖屏模式渲染竖屏视频
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    _buildSwitchSetting(
                      context: context,
                      iconData: Icons.smartphone,
                      label: t.settings.renderVerticalVideoInVerticalScreen,
                      showInfoCard: true,
                      infoMessage: t
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
                  // 全屏方向设置（仅移动端）
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(Get.context!).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.screen_rotation,
                                color: Get.isDarkMode ? Colors.white : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  t.settings.fullscreenOrientation,
                                  style: Theme.of(Get.context!)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.settings.fullscreenOrientationDesc,
                            style: Theme.of(Get.context!).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
                            final currentOrientation =
                                _configService[ConfigKey.FULLSCREEN_ORIENTATION]
                                    as String;
                            return RadioGroup<String>(
                              groupValue: currentOrientation,
                              onChanged: (value) {
                                if (value != null) {
                                  _configService[ConfigKey
                                          .FULLSCREEN_ORIENTATION] =
                                      value;
                                }
                              },
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text(
                                      t
                                          .settings
                                          .fullscreenOrientationLeftLandscape,
                                    ),
                                    value: 'landscape_left',
                                  ),
                                  RadioListTile<String>(
                                    title: Text(
                                      t
                                          .settings
                                          .fullscreenOrientationRightLandscape,
                                    ),
                                    value: 'landscape_right',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.playControlArea,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.settings.leftAndRightControlAreaWidth,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ThreeSectionSlider(
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // '手势控制',
                    t.settings.gestureControl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 左侧双击后退开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.fast_rewind,
                    // label: '左侧双击后退',
                    label: t.settings.leftDoubleTapRewind,
                    showInfoCard: false,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND]!,
                    onChanged: (value) {
                      _configService[ConfigKey.ENABLE_LEFT_DOUBLE_TAP_REWIND] =
                          value;
                    },
                  ),
                  // 右侧双击快进开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.fast_forward,
                    // label: '右侧双击快进',
                    label: t.settings.rightDoubleTapFastForward,
                    showInfoCard: false,
                    rxValue:
                        _configService.settings[ConfigKey
                            .ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .ENABLE_RIGHT_DOUBLE_TAP_FAST_FORWARD] =
                          value;
                    },
                  ),
                  // 双击暂停开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.pause,
                    // label: '双击暂停',
                    label: t.settings.doubleTapPause,
                    showInfoCard: false,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_DOUBLE_TAP_PAUSE]!,
                    onChanged: (value) {
                      _configService[ConfigKey.ENABLE_DOUBLE_TAP_PAUSE] = value;
                    },
                  ),
                  // 左侧上下滑动调整亮度开关（仅限移动设备）
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    _buildSwitchSetting(
                      context: context,
                      iconData: Icons.brightness_medium,
                      label: t.settings.leftVerticalSwipeBrightness,
                      showInfoCard: false,
                      rxValue:
                          _configService.settings[ConfigKey
                              .ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS]!,
                      onChanged: (value) {
                        _configService[ConfigKey
                                .ENABLE_LEFT_VERTICAL_SWIPE_BRIGHTNESS] =
                            value;
                      },
                    ),
                  // 右侧上下滑动调整音量开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.volume_up,
                    label: t.settings.rightVerticalSwipeVolume,
                    showInfoCard: false,
                    rxValue:
                        _configService.settings[ConfigKey
                            .ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME]!,
                    onChanged: (value) {
                      _configService[ConfigKey
                              .ENABLE_RIGHT_VERTICAL_SWIPE_VOLUME] =
                          value;
                    },
                  ),
                  // 长按快进开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.fast_forward,
                    // label: '长按快进',
                    label: t.settings.longPressFastForward,
                    showInfoCard: false,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD]!,
                    onChanged: (value) {
                      _configService[ConfigKey.ENABLE_LONG_PRESS_FAST_FORWARD] =
                          value;
                    },
                  ),
                  // 横向滑动调整进度开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.swap_horiz,
                    label: t.settings.enableHorizontalDragSeek,
                    showInfoCard: false,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK]!,
                    onChanged: (value) {
                      _configService[ConfigKey.ENABLE_HORIZONTAL_DRAG_SEEK] =
                          value;
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    t.settings.playControl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    t
                        .settings
                        .theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                  // 剧院模式开关
                  _buildSwitchSetting(
                    // disabled: true,
                    context: context,
                    iconData: Icons.theater_comedy,
                    label: t.settings.theaterMode,
                    showInfoCard: false,
                    infoMessage: t.settings.theaterModeDesc,
                    rxValue:
                        _configService.settings[ConfigKey.THEATER_MODE_KEY]!,
                    onChanged: (value) {
                      _configService[ConfigKey.THEATER_MODE_KEY] = value;
                    },
                  ),
                  // Anime4K 设置
                  Anime4KSettingsWidget(
                    showInfoCard: true,
                    infoMessage: t.anime4k.realTimeVideoUpscalingAndDenoising,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 音视频配置卡片
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.settings.audioVideoConfig,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 扩大缓冲区
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.memory,
                    label: t.settings.expandBuffer,
                    showInfoCard: true,
                    infoMessage: t.settings.expandBufferInfo,
                    rxValue: _configService.settings[ConfigKey.EXPAND_BUFFER]!,
                    onChanged: (value) {
                      _configService[ConfigKey.EXPAND_BUFFER] = value;
                    },
                  ),
                  // 视频同步
                  Obx(
                    () => _buildSelectionSetting(
                      iconData: Icons.sync,
                      label: t.settings.videoSyncMode,
                      subtitle: t.settings.videoSyncModeSubtitle,
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
                      context: context,
                    ),
                  ),
                  // 硬解模式
                  Obx(
                    () => _buildSelectionSetting(
                      iconData: Icons.hardware,
                      label: t.settings.hardwareDecodingMode,
                      subtitle: t.settings.hardwareDecodingModeSubtitle,
                      currentValue: _configService[ConfigKey.HARDWARE_DECODING],
                      options: const [
                        'auto',
                        'auto-copy',
                        'auto-safe',
                        'no',
                        'yes',
                      ],
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
                      context: context,
                    ),
                  ),
                  // 启用硬件加速
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.speed,
                    label: t.settings.enableHardwareAcceleration,
                    showInfoCard: true,
                    infoMessage: t.settings.enableHardwareAccelerationInfo,
                    rxValue: _configService
                        .settings[ConfigKey.ENABLE_HARDWARE_ACCELERATION]!,
                    onChanged: (value) {
                      _configService[ConfigKey.ENABLE_HARDWARE_ACCELERATION] =
                          value;
                    },
                  ),
                  // OpenSLES音频输出(仅Android)
                  if (GetPlatform.isAndroid)
                    _buildSwitchSetting(
                      context: context,
                      iconData: Icons.audiotrack,
                      label: t.settings.useOpenSLESAudioOutput,
                      showInfoCard: true,
                      infoMessage: t.settings.useOpenSLESAudioOutputInfo,
                      rxValue: _configService.settings[ConfigKey.USE_OPENSLES]!,
                      onChanged: (value) {
                        _configService[ConfigKey.USE_OPENSLES] = value;
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: Get.context != null
                ? MediaQuery.of(Get.context!).padding.bottom
                : 0,
          ),
        ],
      ),
    );
  }
}
