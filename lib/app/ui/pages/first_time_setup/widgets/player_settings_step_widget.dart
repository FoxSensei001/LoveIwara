import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/anime4k_settings_widget.dart';
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
  State<PlayerSettingsStepWidget> createState() => _PlayerSettingsStepWidgetState();
}

class _PlayerSettingsStepWidgetState extends State<PlayerSettingsStepWidget> {
  late ConfigService configService;

  late bool theaterMode;
  late int fastForwardSeconds;
  late int rewindSeconds;
  late double longPressPlaybackSpeed;
  late bool repeat;
  late bool rememberVolume;
  late bool rememberBrightness;
  late bool recordAndRestoreProgress;
  late bool showBottomProgressBarWhenToolbarHidden;
  late bool keepToolbarVisibleByDefault;
  late bool enableMouseHoverShowToolbar;

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
    longPressPlaybackSpeed = configService[ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY];
    repeat = configService[ConfigKey.REPEAT_KEY];
    rememberVolume = configService[ConfigKey.KEEP_LAST_VOLUME_KEY];
    rememberBrightness = configService[ConfigKey.KEEP_LAST_BRIGHTNESS_KEY];
    recordAndRestoreProgress = configService[ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS];
    showBottomProgressBarWhenToolbarHidden = configService[ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN];
    keepToolbarVisibleByDefault = configService[ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE];
    enableMouseHoverShowToolbar = configService[ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR];
  }

  Future<void> _setBool(ConfigKey key, bool value, void Function(bool) localSet) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }

  Future<void> _setInt(ConfigKey key, int value, void Function(int) localSet) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }

  Future<void> _setDouble(ConfigKey key, double value, void Function(double) localSet) async {
    setState(() => localSet(value));
    await configService.setSetting(key, value);
  }


  @override
  Widget build(BuildContext context) {
    return StepResponsiveScaffold(
      desktopBuilder: (context, theme) => _buildDesktopLayout(context, theme),
      mobileBuilder: (context, theme, isNarrow) => _buildMobileLayout(context, theme, isNarrow),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLeftContent(context, theme),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: _buildSettingsContainer(context, theme, false),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isNarrow ? 16 : 24,
      children: [
        _buildSubtitle(context, theme, isNarrow),
        _buildSettingsContainer(context, theme, isNarrow),
        _buildTipContainer(context, theme, isNarrow),
      ],
    );
  }

  Widget _buildLeftContent(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subtitle,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildTipContainer(context, theme, false),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme, bool isNarrow) {
    return Text(
      widget.subtitle,
      style: (isNarrow ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context, ThemeData theme, bool isNarrow) {
    return StepSectionCard(
      isNarrow: isNarrow,
      child: Column(
        children: [
          SwitchSettingTile(
            icon: Icons.theater_comedy,
            title: slang.t.settings.theaterMode,
            subtitle: slang.t.settings.theaterModeDesc,
            value: theaterMode,
            onChanged: (v) => _setBool(ConfigKey.THEATER_MODE_KEY, v, (x) => theaterMode = x),
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          // Anime4K 设置
          const Anime4KSettingsWidget(
            showInfoCard: false,
            isNarrow: false,
          ),
          const StepDivider(),
          NumberSettingTile(
            icon: Icons.fast_forward,
            title: slang.t.settings.fastForwardTime,
            subtitle: slang.t.common.seconds,
            valueText: '$fastForwardSeconds',
            onTap: () async {
              final v = await _showNumberInputDialog(context, slang.t.settings.fastForwardTime, initial: fastForwardSeconds.toString());
              if (v != null) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setInt(ConfigKey.FAST_FORWARD_SECONDS_KEY, parsed, (x) => fastForwardSeconds = x);
                }
              }
            },
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          NumberSettingTile(
            icon: Icons.fast_rewind,
            title: slang.t.settings.rewindTime,
            subtitle: slang.t.common.seconds,
            valueText: '$rewindSeconds',
            onTap: () async {
              final v = await _showNumberInputDialog(context, slang.t.settings.rewindTime, initial: rewindSeconds.toString());
              if (v != null) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setInt(ConfigKey.REWIND_SECONDS_KEY, parsed, (x) => rewindSeconds = x);
                }
              }
            },
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          NumberSettingTile(
            icon: Icons.speed,
            title: slang.t.settings.longPressPlaybackSpeed,
            subtitle: '1.5 = 1.5x',
            valueText: '${longPressPlaybackSpeed}',
            onTap: () async {
              final v = await _showNumberInputDialog(context, slang.t.settings.longPressPlaybackSpeed, initial: longPressPlaybackSpeed.toString());
              if (v != null) {
                final parsed = double.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setDouble(ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY, parsed, (x) => longPressPlaybackSpeed = x);
                }
              }
            },
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.loop,
            title: slang.t.settings.repeat,
            subtitle: slang.t.videoDetail.autoRewind,
            value: repeat,
            onChanged: (v) => _setBool(ConfigKey.REPEAT_KEY, v, (x) => repeat = x),
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.volume_up,
            title: slang.t.settings.rememberVolume,
            subtitle: slang.t.settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain,
            value: rememberVolume,
            onChanged: (v) => _setBool(ConfigKey.KEEP_LAST_VOLUME_KEY, v, (x) => rememberVolume = x),
            isNarrow: isNarrow,
          ),
          if (GetPlatform.isAndroid || GetPlatform.isIOS) ...[
            const StepDivider(),
            SwitchSettingTile(
              icon: Icons.brightness_medium,
              title: slang.t.settings.rememberBrightness,
              subtitle: slang.t.settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain,
              value: rememberBrightness,
              onChanged: (v) => _setBool(ConfigKey.KEEP_LAST_BRIGHTNESS_KEY, v, (x) => rememberBrightness = x),
              isNarrow: isNarrow,
            ),
          ],
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.play_circle_outline,
            title: slang.t.settings.recordAndRestorePlaybackProgress,
            subtitle: slang.t.videoDetail.resumeFromLastPosition(position: '10'),
            value: recordAndRestoreProgress,
            onChanged: (v) => _setBool(ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS, v, (x) => recordAndRestoreProgress = x),
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.linear_scale,
            title: slang.t.settings.showVideoProgressBottomBarWhenToolbarHidden,
            subtitle: slang.t.settings.showVideoProgressBottomBarWhenToolbarHiddenDesc,
            value: showBottomProgressBarWhenToolbarHidden,
            onChanged: (v) => _setBool(ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN, v, (x) => showBottomProgressBarWhenToolbarHidden = x),
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.visibility,
            title: slang.t.settings.defaultKeepVideoToolbarVisible,
            subtitle: slang.t.settings.defaultKeepVideoToolbarVisibleDesc,
            value: keepToolbarVisibleByDefault,
            onChanged: (v) => _setBool(ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE, v, (x) => keepToolbarVisibleByDefault = x),
            isNarrow: isNarrow,
          ),
          const StepDivider(),
          SwitchSettingTile(
            icon: Icons.mouse,
            title: slang.t.settings.enableMouseHoverShowToolbar,
            subtitle: slang.t.settings.enableMouseHoverShowToolbarInfo,
            value: enableMouseHoverShowToolbar,
            onChanged: (v) => _setBool(ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR, v, (x) => enableMouseHoverShowToolbar = x),
            isNarrow: isNarrow,
          ),
        ],
      ),
    );
  }

  Widget _buildTipContainer(BuildContext context, ThemeData theme, bool isNarrow) {
    return StepTipBanner(
      icon: Icons.tips_and_updates,
      text: slang.t.firstTimeSetup.common.settingsChangeableTip,
      isNarrow: isNarrow,
    );
  }

  Future<String?> _showNumberInputDialog(BuildContext context, String title, {required String initial}) async {
    final controller = TextEditingController(text: initial);
    return Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => AppService.tryPop(), child: Text(slang.t.common.cancel)),
          TextButton(onPressed: () { Get.back(result: controller.text.trim()); }, child: Text(slang.t.common.confirm)),
        ],
      ),
      barrierDismissible: true,
    );
  }

}


