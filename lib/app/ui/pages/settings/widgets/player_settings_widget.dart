import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/three_section_slider.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../../services/config_service.dart';

class PlayerSettingsWidget extends StatelessWidget {
  final ConfigService _configService = Get.find();

  PlayerSettingsWidget({super.key});

  void _onThreeSectionSliderChangeFinished(
      double leftRatio, double middleRatio, double rightRatio) {
    _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] = leftRatio;
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
        Obx(() => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    iconData,
                    color: Get.isDarkMode ? Colors.white : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(Get.context!)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
            )),
        const SizedBox(height: 16),
      ],
    );
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
                  Obx(() => SettingItem(
                    label: t.settings.fastForwardTime,
                    initialValue: _configService[ConfigKey.FAST_FORWARD_SECONDS_KEY].toString(),
                    validator: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return t.settings.fastForwardTimeMustBeAPositiveInteger;
                      }
                      return null;
                    },
                    onValid: (value) {
                      final parsed = int.parse(value);
                      _configService.setSetting(ConfigKey.FAST_FORWARD_SECONDS_KEY, parsed);
                    },
                    icon: Icon(Icons.fast_forward, color: Get.isDarkMode ? Colors.white : null),
                    inputDecoration: InputDecoration(
                      suffixText: t.common.seconds,
                      suffixStyle: TextStyle(color: Get.isDarkMode ? Colors.white : null),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(height: 16),
                  // 后退时间设置
                  Obx(() => SettingItem(
                    label: t.settings.rewindTime,
                    initialValue: _configService[ConfigKey.REWIND_SECONDS_KEY].toString(),
                    validator: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed == null || parsed <= 0) {
                        return t.settings.rewindTimeMustBeAPositiveInteger;
                      }
                      return null;
                    },
                    onValid: (value) {
                      final parsed = int.parse(value);
                      _configService.setSetting(ConfigKey.REWIND_SECONDS_KEY, parsed);
                    },
                    icon: Icon(Icons.fast_rewind, color: Get.isDarkMode ? Colors.white : null),
                    inputDecoration: InputDecoration(
                      suffixText: t.common.seconds,
                      suffixStyle: TextStyle(color: Get.isDarkMode ? Colors.white : null),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  )),
                  const SizedBox(height: 16),
                  // 长按播放倍速设置
                  Obx(() => SettingItem(
                    label: t.settings.longPressPlaybackSpeed,
                    initialValue: _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY].toString(),
                    validator: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0.0) {
                        return t.settings.longPressPlaybackSpeedMustBeAPositiveNumber;
                      }
                      return null;
                    },
                    onValid: (value) {
                      final parsed = double.parse(value);
                      _configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY] = parsed;
                    },
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    icon: Icon(Icons.speed, color: Get.isDarkMode ? Colors.white : null),
                    inputDecoration: InputDecoration(
                      suffixText: 'x',
                      suffixStyle: TextStyle(color: Get.isDarkMode ? Colors.white : null),
                      border: const OutlineInputBorder(),
                    ),
                  )),
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
                  // 以竖屏模式渲染竖屏视频
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    _buildSwitchSetting(
                      context: context,
                      iconData: Icons.smartphone,
                      label: t.settings.renderVerticalVideoInVerticalScreen,
                      showInfoCard: true,
                      infoMessage: t.settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen,
                      rxValue: _configService.settings[ConfigKey.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN]!,
                      onChanged: (value) {
                        _configService[ConfigKey.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN] = value;
                      },
                    ),
                  // 记住音量
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.volume_up,
                    label: t.settings.rememberVolume,
                    showInfoCard: true,
                    infoMessage: t.settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain,
                    rxValue: _configService.settings[ConfigKey.KEEP_LAST_VOLUME_KEY]!,
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
                      infoMessage: t.settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain,
                      rxValue: _configService.settings[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY]!,
                      onChanged: (value) {
                      _configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY] = value;
                    },
                  ),
                  // 添加记录和恢复播放进度的设置
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.play_circle_outline,
                    label: t.settings.recordAndRestorePlaybackProgress,
                    showInfoCard: false,
                    infoMessage: null,
                    rxValue: _configService.settings[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS]!,
                    onChanged: (value) {
                      _configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS] = value;
                    },
                  ),
                  // 添加显示底部进度条的设置
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.linear_scale,
                    label: t.settings.showVideoProgressBottomBarWhenToolbarHidden,
                    showInfoCard: true,
                    infoMessage: t.settings.showVideoProgressBottomBarWhenToolbarHiddenDesc,
                    rxValue: _configService.settings[ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN]!,
                    onChanged: (value) {
                      _configService[ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN] = value;
                    },
                  ),
                  // 添加工具栏常驻开关
                  _buildSwitchSetting(
                    context: context,
                    iconData: Icons.visibility,
                    label: t.settings.defaultKeepVideoToolbarVisible,
                    showInfoCard: true,
                    infoMessage: t.settings.defaultKeepVideoToolbarVisibleDesc,
                    rxValue: _configService.settings[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE]!,
                    onChanged: (value) {
                      _configService[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE] = value;
                    },
                  ),
                  // 添加锁定按钮位置设置
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(Get.context!).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final currentPosition = _configService[ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] as int;
                          return Column(
                            children: [
                              RadioListTile<int>(
                                title: Text(t.settings.lockButtonPositionBothSides),
                                value: 1,
                                groupValue: currentPosition,
                                onChanged: (value) {
                                  if (value != null) {
                                    _configService[ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] = value;
                                  }
                                },
                              ),
                              RadioListTile<int>(
                                title: Text(t.settings.lockButtonPositionLeftSide),
                                value: 2,
                                groupValue: currentPosition,
                                onChanged: (value) {
                                  if (value != null) {
                                    _configService[ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] = value;
                                  }
                                },
                              ),
                              RadioListTile<int>(
                                title: Text(t.settings.lockButtonPositionRightSide),
                                value: 3,
                                groupValue: currentPosition,
                                onChanged: (value) {
                                  if (value != null) {
                                    _configService[ConfigKey.VIDEO_TOOLBAR_LOCK_BUTTON_POSITION] = value;
                                  }
                                },
                              ),
                            ],
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
                        message: t.settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer,
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
                    initialLeftRatio: _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                    initialMiddleRatio: (1 - _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] * 2).toDouble(),
                    initialRightRatio: _configService[ConfigKey.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
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
                  Text(t.settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt, style: const TextStyle(fontSize: 14, color: Colors.red),),
                  // 剧院模式开关
                  _buildSwitchSetting(
                    // disabled: true,
                    context: context,
                    iconData: Icons.theater_comedy,
                    label: t.settings.theaterMode,
                    showInfoCard: false,
                    infoMessage: t.settings.theaterModeDesc,
                    rxValue: _configService.settings[ConfigKey.THEATER_MODE_KEY]!,
                    onChanged: (value) {
                      _configService[ConfigKey.THEATER_MODE_KEY] = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Get.context != null ? MediaQuery.of(Get.context!).padding.bottom : 0),
        ],
      ),
    );
  }
}
