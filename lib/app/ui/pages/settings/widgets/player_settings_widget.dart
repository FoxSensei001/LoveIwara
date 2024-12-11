import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/three_section_slider.dart';

import '../../../../services/config_service.dart';

class PlayerSettingsWidget extends StatelessWidget {
  final ConfigService _configService = Get.find();

  PlayerSettingsWidget({super.key});

  void _onThreeSectionSliderChangeFinished(
      double leftRatio, double middleRatio, double rightRatio) {
    _configService[ConfigService.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] = leftRatio;
  }

  // 创建开关设置项，并在上方显示信息提示卡片
  Widget _buildSwitchSetting({
    required IconData iconData,
    required String label,
    bool showInfoCard = false,
    String? infoMessage,
    required RxBool rxValue,
    required Function(bool) onChanged,
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
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    // 使用 Expanded 确保文本不会溢出
                    child: Text(
                      '此配置决定当你之后播放视频时是否会沿用之前的配置。',
                      style: TextStyle(
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
                    color: Theme.of(Get.context!).primaryColor,
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
                  Switch(
                    value: rxValue.value,
                    onChanged: onChanged,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 播放控制部分
          const Text(
            '播放控制',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 快进时间设置
          Obx(() => SettingItem(
                label: '快进时间',
                initialValue:
                    _configService[ConfigService.FAST_FORWARD_SECONDS_KEY]
                        .toString(),
                validator: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return '快进时间必须是一个正整数。';
                  }
                  return null;
                },
                onValid: (value) {
                  final parsed = int.parse(value);
                  _configService.setSetting(
                      ConfigService.FAST_FORWARD_SECONDS_KEY, parsed);
                },
                icon: Icon(Icons.fast_forward,
                    color: Theme.of(context).primaryColor),
                inputDecoration: InputDecoration(
                  suffixText: '秒',
                  suffixStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              )),
          const SizedBox(height: 16),

          // 后退时间设置
          Obx(() => SettingItem(
                label: '后退时间',
                initialValue:
                    _configService[ConfigService.REWIND_SECONDS_KEY].toString(),
                validator: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return '后退时间必须是一个正整数。';
                  }
                  return null;
                },
                onValid: (value) {
                  final parsed = int.parse(value);
                  _configService.setSetting(
                      ConfigService.REWIND_SECONDS_KEY, parsed);
                },
                icon: Icon(Icons.fast_rewind,
                    color: Theme.of(context).primaryColor),
                inputDecoration: InputDecoration(
                  suffixText: '秒',
                  suffixStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              )),
          const SizedBox(height: 16),

          // 长按播放倍速设置
          Obx(() => SettingItem(
                label: '长按播放倍速',
                initialValue:
                    _configService[ConfigService.LONG_PRESS_PLAYBACK_SPEED_KEY]
                        .toString(),
                validator: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0.0) {
                    return '长按播放倍速必须是一个正数。';
                  }
                  return null;
                },
                onValid: (value) {
                  final parsed = double.parse(value);
                  _configService[ConfigService.LONG_PRESS_PLAYBACK_SPEED_KEY] =
                      parsed;
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                icon: Icon(Icons.speed, color: Theme.of(context).primaryColor),
                inputDecoration: InputDecoration(
                  suffixText: 'x',
                  suffixStyle: TextStyle(color: Theme.of(context).primaryColor),
                  border: const OutlineInputBorder(),
                ),
              )),
          const SizedBox(height: 16),

          // 循环播放
          _buildSwitchSetting(
            iconData: Icons.loop,
            label: '循环播放',
            showInfoCard: false,
            infoMessage: null,
            rxValue: _configService.settings[ConfigService.REPEAT_KEY],
            onChanged: (value) {
              _configService[ConfigService.REPEAT_KEY] = value;
            },
          ),

          // 以竖屏模式渲染竖屏视频
          if (GetPlatform.isAndroid || GetPlatform.isIOS)
            _buildSwitchSetting(
              iconData: Icons.smartphone,
              label: '全屏播放时以竖屏模式渲染竖屏视频',
              showInfoCard: true,
              infoMessage: '此配置决定当你在全屏播放时是否以竖屏模式渲染竖屏视频。',
              rxValue: _configService
                  .settings[ConfigService.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN],
              onChanged: (value) {
                _configService[
                    ConfigService.RENDER_VERTICAL_VIDEO_IN_VERTICAL_SCREEN] = value;
              },
            ),

          // 记住音量
          _buildSwitchSetting(
            iconData: Icons.volume_up,
            label: '记住音量',
            showInfoCard: true,
            infoMessage: '此配置决定当你之后播放视频时是否会沿用之前的音量设置。',
            rxValue: _configService.settings[ConfigService.KEEP_LAST_VOLUME_KEY],
            onChanged: (value) {
              _configService[ConfigService.KEEP_LAST_VOLUME_KEY] = value;
            },
          ),

          // 记住亮度（仅限特定平台）
          if (!GetPlatform.isDesktop && !GetPlatform.isWeb)
            _buildSwitchSetting(
              iconData: Icons.brightness_medium,
              label: '记住亮度',
              showInfoCard: true,
              infoMessage: '此配置决定当你之后播放视频时是否会沿用之前的亮度设置。',
              rxValue:
                  _configService.settings[ConfigService.KEEP_LAST_BRIGHTNESS_KEY],
              onChanged: (value) {
                _configService[ConfigService.KEEP_LAST_BRIGHTNESS_KEY] = value;
              },
            ),

          const SizedBox(height: 16),

          // 播放控制区域设置部分
          const Text(
            '播放控制区域',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和帮助图标
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '左右控制区域宽度',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      preferBelow: false,
                      message: "指定播放器左右两侧的控制区域宽度",
                      child: Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 三段滑块设置
                ThreeSectionSlider(
                  onSlideChangeCallback: _onThreeSectionSliderChangeFinished,
                  initialLeftRatio: _configService[
                      ConfigService.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                  initialMiddleRatio: (1 -
                          _configService[ConfigService
                                  .VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO] *
                              2)
                      .toDouble(),
                  initialRightRatio: _configService[
                      ConfigService.VIDEO_LEFT_AND_RIGHT_CONTROL_AREA_RATIO],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
