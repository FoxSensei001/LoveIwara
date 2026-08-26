import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/anime4k_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_settings_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/color_vision_filters.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlayerSettingsStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const PlayerSettingsStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<PlayerSettingsStepWidget> createState() =>
      _PlayerSettingsStepWidgetState();
}

class _PlayerSettingsStepWidgetState extends State<PlayerSettingsStepWidget> {
  late ConfigService configService;

  late bool theaterMode;
  late int fastForwardSeconds;
  late int rewindSeconds;
  late double longPressPlaybackSpeed;
  late bool repeat;
  late bool rememberBrightness;
  late bool recordAndRestoreProgress;
  late bool autoPlayVideoOnFirstEnter;
  late bool showBottomProgressBarWhenToolbarHidden;
  late bool showFullscreenUpNextHint;
  late bool keepToolbarVisibleByDefault;
  late bool enableMouseHoverShowToolbar;
  late bool enableVideoGestureZoom;

  @override
  void initState() {
    super.initState();
    configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    theaterMode = configService[ConfigKey.THEATER_MODE_KEY];
    fastForwardSeconds = configService[ConfigKey.FAST_FORWARD_SECONDS_KEY];
    rewindSeconds = configService[ConfigKey.REWIND_SECONDS_KEY];
    longPressPlaybackSpeed =
        configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY];
    repeat = configService[ConfigKey.REPEAT_KEY];
    rememberBrightness = configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY];
    recordAndRestoreProgress =
        configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS];
    autoPlayVideoOnFirstEnter =
        configService[ConfigKey.AUTO_PLAY_VIDEO_ON_FIRST_ENTER];
    showBottomProgressBarWhenToolbarHidden =
        configService[ConfigKey
            .SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN];
    showFullscreenUpNextHint =
        configService[ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT];
    keepToolbarVisibleByDefault =
        configService[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE];
    enableMouseHoverShowToolbar =
        configService[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR];
    enableVideoGestureZoom = configService[ConfigKey.ENABLE_VIDEO_GESTURE_ZOOM];
  }

  Future<void> _setBool(
    ConfigKey key,
    bool value,
    void Function(bool) localSet,
  ) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }

  Future<void> _setInt(
    ConfigKey key,
    int value,
    void Function(int) localSet,
  ) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }

  Future<void> _setDouble(
    ConfigKey key,
    double value,
    void Function(double) localSet,
  ) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return StepPageLayout(
      subtitle: widget.subtitle,
      description: widget.description,
      content: StepSectionList(
        children: [
          _buildPictureSection(),
          _buildPlaybackSection(),
          _buildToolbarSection(),
        ],
      ),
      tip: StepTipBanner.info(
        slang.t.firstTimeSetup.common.settingsChangeableTip,
      ),
    );
  }

  /// 画面：影院模式 + 两个画质增强入口。
  ///
  /// Anime4K 与色觉辅助过去是直接把通用组件塞进来（各自带一层投影卡片，
  /// 色觉辅助还额外顶着一条说明横幅），于是卡里套卡。现在只借它们的弹窗，
  /// 行本身走与同卡片其它行一样的 [StepActionTile]。
  Widget _buildPictureSection() {
    return GlassSettingSection(
      children: [
        GlassSwitchItem(
          icon: Icons.theater_comedy,
          title: Text(slang.t.settings.theaterMode),
          subtitle: Text(slang.t.settings.theaterModeDesc),
          value: theaterMode,
          onChanged: (v) =>
              _setBool(ConfigKey.THEATER_MODE_KEY, v, (x) => theaterMode = x),
        ),
        Obx(
          () => StepActionTile(
            icon: Icons.tune,
            title: slang.t.anime4k.preset,
            subtitle: slang.t.anime4k.realTimeVideoUpscalingAndDenoising,
            value: Anime4KSettingsWidget.currentPresetLabel(),
            valueHighlighted:
                (configService[ConfigKey.ANIME4K_PRESET_ID] as String)
                    .isNotEmpty,
            onTap: () => Anime4KSettingsWidget.showPresetDialog(context),
          ),
        ),
        Obx(
          () => StepActionTile(
            icon: Icons.invert_colors,
            title: slang.t.colorVisionAssist.title,
            subtitle: slang.t.colorVisionAssist.description,
            value: ColorVisionSettingsWidget.currentLabel(),
            valueHighlighted:
                (configService[ConfigKey.COLOR_VISION_FILTER_ID] as String) !=
                ColorVisionFilterType.none.id,
            onTap: () => ColorVisionSettingsWidget.showSelectionDialog(context),
          ),
        ),
      ],
    );
  }

  /// 播放：快进/快退/倍速与循环、亮度、进度。
  Widget _buildPlaybackSection() {
    return GlassSettingSection(
      children: [
        StepActionTile(
          icon: Icons.fast_forward,
          title: slang.t.settings.fastForwardTime,
          subtitle: slang.t.common.seconds,
          value: '$fastForwardSeconds',
          onTap: () async {
            final text = await _askNumber(
              slang.t.settings.fastForwardTime,
              initial: fastForwardSeconds.toString(),
            );
            final value = text == null ? null : int.tryParse(text);
            if (value != null && value > 0) {
              _setInt(
                ConfigKey.FAST_FORWARD_SECONDS_KEY,
                value,
                (x) => fastForwardSeconds = x,
              );
            }
          },
        ),
        StepActionTile(
          icon: Icons.fast_rewind,
          title: slang.t.settings.rewindTime,
          subtitle: slang.t.common.seconds,
          value: '$rewindSeconds',
          onTap: () async {
            final text = await _askNumber(
              slang.t.settings.rewindTime,
              initial: rewindSeconds.toString(),
            );
            final value = text == null ? null : int.tryParse(text);
            if (value != null && value > 0) {
              _setInt(
                ConfigKey.REWIND_SECONDS_KEY,
                value,
                (x) => rewindSeconds = x,
              );
            }
          },
        ),
        StepActionTile(
          icon: Icons.speed,
          title: slang.t.settings.longPressPlaybackSpeed,
          subtitle: '1.5 = 1.5x',
          value: '$longPressPlaybackSpeed',
          onTap: () async {
            final text = await _askNumber(
              slang.t.settings.longPressPlaybackSpeed,
              initial: longPressPlaybackSpeed.toString(),
            );
            final value = text == null ? null : double.tryParse(text);
            if (value != null && value > 0) {
              _setDouble(
                ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY,
                value,
                (x) => longPressPlaybackSpeed = x,
              );
            }
          },
        ),
        GlassSwitchItem(
          icon: Icons.loop,
          title: Text(slang.t.settings.repeat),
          subtitle: Text(slang.t.videoDetail.autoRewind),
          value: repeat,
          onChanged: (v) =>
              _setBool(ConfigKey.REPEAT_KEY, v, (x) => repeat = x),
        ),
        if (GetPlatform.isAndroid || GetPlatform.isIOS)
          GlassSwitchItem(
            icon: Icons.brightness_medium,
            title: Text(slang.t.settings.rememberBrightness),
            subtitle: Text(
              slang
                  .t
                  .settings
                  .thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain,
            ),
            value: rememberBrightness,
            onChanged: (v) => _setBool(
              ConfigKey.KEEP_LAST_BRIGHTNESS_KEY,
              v,
              (x) => rememberBrightness = x,
            ),
          ),
        GlassSwitchItem(
          icon: Icons.play_circle_outline,
          title: Text(slang.t.settings.recordAndRestorePlaybackProgress),
          subtitle: Text(
            slang.t.videoDetail.resumeFromLastPosition(position: '10'),
          ),
          value: recordAndRestoreProgress,
          onChanged: (v) => _setBool(
            ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS,
            v,
            (x) => recordAndRestoreProgress = x,
          ),
        ),
        GlassSwitchItem(
          icon: Icons.play_arrow,
          title: Text(slang.t.settings.autoPlayVideoOnFirstEnter),
          subtitle: Text(slang.t.settings.autoPlayVideoOnFirstEnterDesc),
          value: autoPlayVideoOnFirstEnter,
          onChanged: (v) => _setBool(
            ConfigKey.AUTO_PLAY_VIDEO_ON_FIRST_ENTER,
            v,
            (x) => autoPlayVideoOnFirstEnter = x,
          ),
        ),
      ],
    );
  }

  /// 控制栏与手势。
  Widget _buildToolbarSection() {
    return GlassSettingSection(
      children: [
        GlassSwitchItem(
          icon: Icons.linear_scale,
          title: Text(
            slang.t.settings.showVideoProgressBottomBarWhenToolbarHidden,
          ),
          subtitle: Text(
            slang.t.settings.showVideoProgressBottomBarWhenToolbarHiddenDesc,
          ),
          value: showBottomProgressBarWhenToolbarHidden,
          onChanged: (v) => _setBool(
            ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN,
            v,
            (x) => showBottomProgressBarWhenToolbarHidden = x,
          ),
        ),
        GlassSwitchItem(
          icon: Icons.queue_play_next,
          title: Text(slang.t.settings.showFullscreenUpNextHint),
          subtitle: Text(slang.t.settings.showFullscreenUpNextHintDesc),
          value: showFullscreenUpNextHint,
          onChanged: (v) => _setBool(
            ConfigKey.SHOW_FULLSCREEN_UP_NEXT_HINT,
            v,
            (x) => showFullscreenUpNextHint = x,
          ),
        ),
        GlassSwitchItem(
          icon: Icons.visibility,
          title: Text(slang.t.settings.defaultKeepVideoToolbarVisible),
          subtitle: Text(slang.t.settings.defaultKeepVideoToolbarVisibleDesc),
          value: keepToolbarVisibleByDefault,
          onChanged: (v) => _setBool(
            ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE,
            v,
            (x) => keepToolbarVisibleByDefault = x,
          ),
        ),
        GlassSwitchItem(
          icon: Icons.mouse,
          title: Text(slang.t.settings.enableMouseHoverShowToolbar),
          subtitle: Text(slang.t.settings.enableMouseHoverShowToolbarInfo),
          value: enableMouseHoverShowToolbar,
          onChanged: (v) => _setBool(
            ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR,
            v,
            (x) => enableMouseHoverShowToolbar = x,
          ),
        ),
        GlassSwitchItem(
          icon: Icons.pinch,
          title: Text(slang.t.settings.enableVideoGestureZoom),
          subtitle: Text(slang.t.settings.enableVideoGestureZoomInfo),
          value: enableVideoGestureZoom,
          onChanged: (v) => _setBool(
            ConfigKey.ENABLE_VIDEO_GESTURE_ZOOM,
            v,
            (x) => enableVideoGestureZoom = x,
          ),
        ),
      ],
    );
  }

  /// 数字输入弹窗。返回 null 表示取消；返回的字符串由调用方按整数 / 小数解析。
  Future<String?> _askNumber(String title, {required String initial}) {
    return showAppDialog<String>(
      _NumberInputDialog(title: title, initial: initial),
      barrierDismissible: true,
    );
  }
}

/// 数字输入弹窗。
///
/// `TextEditingController` 由弹窗自己的 State 回收：`showAppDialog` 的 future
/// 在 pop 那一刻就完成，而弹窗还要播退场动画，在 `whenComplete` 里 dispose
/// 会踩到「controller used after being disposed」。
class _NumberInputDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _NumberInputDialog({required this.title, required this.initial});

  @override
  State<_NumberInputDialog> createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<_NumberInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassAlertDialog(
      title: widget.title,
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => AppService.tryPop(context: context),
        ),
        GlassDialogAction(
          label: slang.t.common.confirm,
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
        ),
      ],
    );
  }
}
