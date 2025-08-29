import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isNarrow = screenWidth < 400;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 16 : (isDesktop ? 48 : 24)),
      child: isDesktop
          ? _buildDesktopLayout(context, theme)
          : _buildMobileLayout(context, theme, isNarrow),
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
      children: [
        SizedBox(height: isNarrow ? 16 : 24),
        _buildSubtitle(context, theme, isNarrow),
        SizedBox(height: isNarrow ? 20 : 32),
        _buildSettingsContainer(context, theme, isNarrow),
        SizedBox(height: isNarrow ? 16 : 20),
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.theater_comedy,
            title: '剧院模式',
            subtitle: '以剧院模式渲染播放器背景',
            value: theaterMode,
            onChanged: (v) => _setBool(ConfigKey.THEATER_MODE_KEY, v, (x) => theaterMode = x),
          ),
          _buildDivider(theme),
          _buildNumberTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.fast_forward,
            title: '快进时间',
            subtitle: '单位：秒',
            valueText: '$fastForwardSeconds',
            onTap: () async {
              final v = await _showNumberInputDialog(context, '设置快进时间(秒)', initial: fastForwardSeconds.toString());
              if (v != null) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setInt(ConfigKey.FAST_FORWARD_SECONDS_KEY, parsed, (x) => fastForwardSeconds = x);
                }
              }
            },
          ),
          _buildDivider(theme),
          _buildNumberTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.fast_rewind,
            title: '后退时间',
            subtitle: '单位：秒',
            valueText: '$rewindSeconds',
            onTap: () async {
              final v = await _showNumberInputDialog(context, '设置后退时间(秒)', initial: rewindSeconds.toString());
              if (v != null) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setInt(ConfigKey.REWIND_SECONDS_KEY, parsed, (x) => rewindSeconds = x);
                }
              }
            },
          ),
          _buildDivider(theme),
          _buildNumberTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.speed,
            title: '长按倍速播放',
            subtitle: '例如：1.5 表示 1.5x',
            valueText: '${longPressPlaybackSpeed}',
            onTap: () async {
              final v = await _showNumberInputDialog(context, '设置长按倍速', initial: longPressPlaybackSpeed.toString());
              if (v != null) {
                final parsed = double.tryParse(v);
                if (parsed != null && parsed > 0) {
                  _setDouble(ConfigKey.LONG_PRESS_PLAYBACK_SPEED_KEY, parsed, (x) => longPressPlaybackSpeed = x);
                }
              }
            },
          ),
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.loop,
            title: '循环播放',
            subtitle: '播放结束后自动重新播放',
            value: repeat,
            onChanged: (v) => _setBool(ConfigKey.REPEAT_KEY, v, (x) => repeat = x),
          ),
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.volume_up,
            title: '记住音量',
            subtitle: '再次播放时沿用上次音量',
            value: rememberVolume,
            onChanged: (v) => _setBool(ConfigKey.KEEP_LAST_VOLUME_KEY, v, (x) => rememberVolume = x),
          ),
          if (GetPlatform.isAndroid || GetPlatform.isIOS) ...[
            _buildDivider(theme),
            _buildSwitchTile(
              context: context,
              theme: theme,
              isNarrow: isNarrow,
              icon: Icons.brightness_medium,
              title: '记住亮度',
              subtitle: '再次播放时沿用上次亮度',
              value: rememberBrightness,
              onChanged: (v) => _setBool(ConfigKey.KEEP_LAST_BRIGHTNESS_KEY, v, (x) => rememberBrightness = x),
            ),
          ],
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.play_circle_outline,
            title: '记录和恢复播放进度',
            subtitle: '下次进入时自动恢复进度',
            value: recordAndRestoreProgress,
            onChanged: (v) => _setBool(ConfigKey.RECORD_AND_RESTORE_VIDEO_PROGRESS, v, (x) => recordAndRestoreProgress = x),
          ),
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.linear_scale,
            title: '显示底部进度条',
            subtitle: '当工具栏隐藏时仍显示进度条',
            value: showBottomProgressBarWhenToolbarHidden,
            onChanged: (v) => _setBool(ConfigKey.SHOW_VIDEO_PROGRESS_BOTTOM_BAR_WHEN_TOOLBAR_HIDDEN, v, (x) => showBottomProgressBarWhenToolbarHidden = x),
          ),
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.visibility,
            title: '保持工具栏常驻',
            subtitle: '进入页面时默认显示工具栏',
            value: keepToolbarVisibleByDefault,
            onChanged: (v) => _setBool(ConfigKey.DEFAULT_KEEP_VIDEO_TOOLBAR_VISABLE, v, (x) => keepToolbarVisibleByDefault = x),
          ),
          _buildDivider(theme),
          _buildSwitchTile(
            context: context,
            theme: theme,
            isNarrow: isNarrow,
            icon: Icons.mouse,
            title: '鼠标悬浮时显示工具栏',
            subtitle: '将鼠标移至播放器上方时自动显示工具栏',
            value: enableMouseHoverShowToolbar,
            onChanged: (v) => _setBool(ConfigKey.ENABLE_MOUSE_HOVER_SHOW_TOOLBAR, v, (x) => enableMouseHoverShowToolbar = x),
          ),
        ],
      ),
    );
  }

  Widget _buildTipContainer(BuildContext context, ThemeData theme, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tips_and_updates,
            color: theme.colorScheme.onPrimaryContainer,
            size: isNarrow ? 16 : 20,
          ),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: Text(
              '这些设置稍后可在应用设置中随时修改',
              style: (isNarrow ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required ThemeData theme,
    required bool isNarrow,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 16 : 20,
        vertical: isNarrow ? 8 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isNarrow ? 6 : 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(isNarrow ? 6 : 8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: isNarrow ? 16 : 20,
            ),
          ),
          SizedBox(width: isNarrow ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: isNarrow ? 1 : 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
            materialTapTargetSize: isNarrow ? MaterialTapTargetSize.shrinkWrap : MaterialTapTargetSize.padded,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberTile({
    required BuildContext context,
    required ThemeData theme,
    required bool isNarrow,
    required IconData icon,
    required String title,
    required String subtitle,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 16 : 20,
          vertical: isNarrow ? 8 : 12,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isNarrow ? 6 : 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(isNarrow ? 6 : 8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: isNarrow ? 16 : 20,
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isNarrow ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: isNarrow ? 1 : 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(valueText, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
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
          TextButton(onPressed: () => AppService.tryPop(), child: const Text('取消')),
          TextButton(onPressed: () { Get.back(result: controller.text.trim()); }, child: const Text('确定')),
        ],
      ),
      barrierDismissible: true,
    );
  }
}


