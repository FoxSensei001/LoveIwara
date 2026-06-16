import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/player_keybinding/key_chord.dart';
import 'package:i_iwara/app/services/player_keybinding/player_action.dart';
import 'package:i_iwara/app/services/player_keybinding/player_keybinding_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

/// 播放器键盘快捷键自定义。
///
/// 提供两种入口：
/// - [open]：在设置页中作为独立页面（带 AppBar）推入导航栈；
/// - [openSheet]：在播放器内以底部抽屉（考虑底部安全区）弹出。
///
/// 两者共用 [PlayerKeybindingSettingsView] 渲染主体内容。
class PlayerKeybindingSettingsPage extends StatelessWidget {
  const PlayerKeybindingSettingsPage({super.key});

  /// 设置页：独立页面跳转。
  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlayerKeybindingSettingsPage()),
    );
  }

  /// 播放器：底部抽屉弹出。
  static Future<void> openSheet(BuildContext context) {
    return showAppBottomSheet(const _KeybindingSheet(), isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(slang.t.settings.keybinding.title)),
      body: const PlayerKeybindingSettingsView(),
    );
  }
}

/// 底部抽屉外壳：圆角顶部 + 拖拽指示条 + 标题栏 + 主体。
class _KeybindingSheet extends StatelessWidget {
  const _KeybindingSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.t.settings.keybinding;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
            child: Row(
              children: [
                Icon(Icons.keyboard, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: slang.t.common.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: const PlayerKeybindingSettingsView(shrinkWrap: true),
          ),
        ],
      ),
    );
  }
}

/// 快捷键设置主体内容（页面与抽屉共用）。
class PlayerKeybindingSettingsView extends StatelessWidget {
  /// 抽屉内需要 shrinkWrap 以便随内容收缩并在 [Flexible] 中滚动。
  final bool shrinkWrap;

  const PlayerKeybindingSettingsView({super.key, this.shrinkWrap = false});

  PlayerKeybindingService get _service => Get.find<PlayerKeybindingService>();

  slang.TranslationsSettingsKeybindingEn get _t => slang.t.settings.keybinding;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ListView(
      shrinkWrap: shrinkWrap,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + computeBottomSafeInset(mq)),
      children: [
        _buildInfoCard(context),
        const SizedBox(height: 16),
        for (final category in PlayerActionCategory.values)
          ..._buildCategory(context, category),
        if (GetPlatform.isDesktop) ..._buildZoomSection(context),
        _buildResetAllButton(context),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.keyboard, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _t.desktopHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategory(
    BuildContext context,
    PlayerActionCategory category,
  ) {
    final actions = PlayerAction.values
        .where((a) => a.category == category)
        .toList();
    if (actions.isEmpty) return const [];
    return [
      _sectionLabel(context, _categoryLabel(category)),
      Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              _buildActionRow(context, actions[i]),
              if (i != actions.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          ],
        ),
      ),
      // 进度分类下补充长按倍速说明。
      if (category == PlayerActionCategory.seek)
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Text(
            _t.seekLongPressHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildActionRow(BuildContext context, PlayerAction action) {
    final theme = Theme.of(context);
    return Obx(() {
      final chords = _service.chordsOf(action);
      final isDefault = _service.isDefault(action);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Icon(action.icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_actionLabel(action), style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  if (chords.isEmpty)
                    Text(
                      _t.notSet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final chord in chords)
                          _chordChip(context, action, chord),
                      ],
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: _t.addShortcut,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _addChord(context, action),
            ),
            if (!isDefault)
              IconButton(
                tooltip: _t.resetToDefault,
                icon: const Icon(Icons.restart_alt),
                onPressed: () => _service.resetAction(action),
              ),
          ],
        ),
      );
    });
  }

  Widget _chordChip(BuildContext context, PlayerAction action, KeyChord chord) {
    final theme = Theme.of(context);
    return InputChip(
      label: Text(chord.displayLabel),
      labelStyle: theme.textTheme.bodyMedium,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _service.removeBinding(action, chord),
      deleteButtonTooltipMessage: _t.removeShortcut,
      backgroundColor: theme.colorScheme.secondaryContainer,
    );
  }

  // ---------------------------------------------------------------------------
  // 画面缩放（固定快捷键，仅展示，桌面端）
  // ---------------------------------------------------------------------------

  List<Widget> _buildZoomSection(BuildContext context) {
    final theme = Theme.of(context);
    return [
      _sectionLabel(context, _t.zoomSectionTitle),
      Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _fixedHintRow(context, Icons.zoom_in, _t.zoomScaleLabel, _t.zoomScaleHint),
            const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
            _fixedHintRow(
              context,
              Icons.rotate_right,
              _t.zoomRotateLabel,
              _t.zoomRotateHint,
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Text(
          _t.zoomFixedNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _fixedHintRow(
    BuildContext context,
    IconData icon,
    String label,
    String hint,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Chip(
        label: Text(hint),
        labelStyle: theme.textTheme.bodyMedium,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildResetAllButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.restart_alt),
        label: Text(_t.resetAll),
        onPressed: () => _confirmResetAll(context),
      ),
    );
  }

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

  // ---------------------------------------------------------------------------
  // 交互
  // ---------------------------------------------------------------------------

  Future<void> _addChord(BuildContext context, PlayerAction action) async {
    final chord = await showDialog<KeyChord>(
      context: context,
      builder: (_) => _KeybindingCaptureDialog(service: _service),
    );
    if (chord == null) return;
    if (!context.mounted) return;

    final conflicts = _service.conflictsFor(chord, except: action);
    if (conflicts.isNotEmpty) {
      final conflictName = _actionLabel(conflicts.first);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_t.conflictTitle),
          content: Text(_t.conflictMessage(action: conflictName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(slang.t.common.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t.conflictContinue),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await _service.addBinding(action, chord);
  }

  Future<void> _confirmResetAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t.resetAll),
        content: Text(_t.resetAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(slang.t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_t.resetAll),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _service.resetAll();
      showToastWidget(
        MDToastWidget(message: _t.resetAll, type: MDToastType.success),
      );
    }
  }

  String _categoryLabel(PlayerActionCategory category) {
    switch (category) {
      case PlayerActionCategory.playback:
        return _t.categoryPlayback;
      case PlayerActionCategory.seek:
        return _t.categorySeek;
      case PlayerActionCategory.volume:
        return _t.categoryVolume;
      case PlayerActionCategory.display:
        return _t.categoryDisplay;
    }
  }

  String _actionLabel(PlayerAction action) {
    switch (action) {
      case PlayerAction.playPause:
        return _t.actionPlayPause;
      case PlayerAction.speedUp:
        return _t.actionSpeedUp;
      case PlayerAction.speedDown:
        return _t.actionSpeedDown;
      case PlayerAction.seekForward:
        return _t.actionSeekForward;
      case PlayerAction.seekBackward:
        return _t.actionSeekBackward;
      case PlayerAction.volumeUp:
        return _t.actionVolumeUp;
      case PlayerAction.volumeDown:
        return _t.actionVolumeDown;
      case PlayerAction.toggleMute:
        return _t.actionToggleMute;
      case PlayerAction.toggleFullscreen:
        return _t.actionToggleFullscreen;
    }
  }
}

/// 录制快捷键的对话框：捕获首个「非修饰键」按下，结合当前修饰键生成组合。
class _KeybindingCaptureDialog extends StatefulWidget {
  final PlayerKeybindingService service;

  const _KeybindingCaptureDialog({required this.service});

  @override
  State<_KeybindingCaptureDialog> createState() =>
      _KeybindingCaptureDialogState();
}

class _KeybindingCaptureDialogState extends State<_KeybindingCaptureDialog> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  String _preview = '';

  slang.TranslationsSettingsKeybindingEn get _t => slang.t.settings.keybinding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      // 松开修饰键时更新预览。
      setState(() => _preview = _modifierPreview());
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return;
    }
    final chord = KeyChord.fromEvent(event);
    if (chord == null) {
      // 仍是修饰键，刷新预览。
      setState(() => _preview = _modifierPreview());
      return;
    }
    if (widget.service.isReserved(chord)) {
      setState(() => _errorText = _t.reservedKey);
      return;
    }
    Navigator.of(context).pop(chord);
  }

  String _modifierPreview() {
    final keyboard = HardwareKeyboard.instance;
    final parts = <String>[];
    if (keyboard.isControlPressed) parts.add('Ctrl');
    if (keyboard.isAltPressed) parts.add('Alt');
    if (keyboard.isShiftPressed) parts.add('Shift');
    if (keyboard.isMetaPressed) parts.add('Meta');
    return parts.isEmpty ? '' : '${parts.join(' + ')} + …';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(_t.pressNewShortcut),
      // 用 Focus.onKeyEvent 并返回 handled，吞掉按键，避免 Esc 等被全局
      // Shortcuts/PopCoordinator 重复处理导致双重返回。
      content: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, event) {
          _onKey(event);
          return KeyEventResult.handled;
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _preview.isEmpty ? '…' : _preview,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorText ?? _t.recordingCancelHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(slang.t.common.cancel),
        ),
      ],
    );
  }
}
