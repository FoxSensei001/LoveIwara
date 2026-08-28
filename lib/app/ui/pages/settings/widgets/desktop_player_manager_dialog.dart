import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 桌面端外部播放器管理面板：列表 + 自动探测 + 手动添加 / 编辑 / 删除。
Future<void> showDesktopPlayerManagerDialog(BuildContext context) {
  return showAppDialog<void>(
    const _DesktopPlayerManagerDialog(),
    dialogContext: context,
  );
}

class _DesktopPlayerManagerDialog extends StatefulWidget {
  const _DesktopPlayerManagerDialog();

  @override
  State<_DesktopPlayerManagerDialog> createState() =>
      _DesktopPlayerManagerDialogState();
}

class _DesktopPlayerManagerDialogState
    extends State<_DesktopPlayerManagerDialog> {
  List<DesktopPlayerEntry> _entries = const [];
  bool _detecting = false;

  @override
  void initState() {
    super.initState();
    _entries = DesktopPlayerStore.load();
  }

  Future<void> _persist() async {
    await DesktopPlayerStore.save(_entries);
  }

  Future<void> _detect() async {
    final t = slang.Translations.of(context);
    setState(() => _detecting = true);
    try {
      final found = await DesktopPlayerProbe.detect(existing: _entries);
      if (!mounted) return;
      if (found.isEmpty) {
        showGlassToast(
          t.externalPlayer.detectNothingFound,
          type: GlassToastType.warning,
        );
        return;
      }
      setState(() => _entries = [..._entries, ...found]);
      await _persist();
      if (!mounted) return;
      showGlassToast(t.externalPlayer.detectFound(count: found.length));
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  Future<void> _addManually() async {
    final picked = await _pickExecutable();
    if (picked == null || !mounted) return;
    final entry = DesktopPlayerEntry(
      id: 'manual_${_entries.length}_${picked.hashCode}',
      name: _defaultNameOf(picked),
      executablePath: picked,
    );
    final edited = await _editEntry(entry, isNew: true);
    if (edited == null || !mounted) return;
    setState(() => _entries = [..._entries, edited]);
    await _persist();
  }

  Future<void> _edit(DesktopPlayerEntry entry) async {
    final edited = await _editEntry(entry, isNew: false);
    if (edited == null || !mounted) return;
    setState(() {
      _entries = _entries.map((e) => e.id == entry.id ? edited : e).toList();
    });
    await _persist();
  }

  Future<void> _remove(DesktopPlayerEntry entry) async {
    setState(() => _entries = _entries.where((e) => e.id != entry.id).toList());
    await _persist();
  }

  Future<void> _test(DesktopPlayerEntry entry) async {
    final t = slang.Translations.of(context);
    // 空手启动：只验证「这个可执行文件能不能跑起来」，不带任何片源。
    final ok = await DesktopPlayerLauncher.launchBare(entry);
    if (!mounted) return;
    showGlassToast(
      ok ? t.externalPlayer.testLaunched : t.externalPlayer.testFailed,
      type: ok ? GlassToastType.success : GlassToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return GlassAlertDialog(
      title: t.externalPlayer.managePlayers,
      maxWidth: 620,
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.externalPlayer.managePlayersDesc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  t.externalPlayer.noPlayerConfigured,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  itemBuilder: (context, index) => _PlayerRow(
                    entry: _entries[index],
                    onEdit: () => _edit(_entries[index]),
                    onRemove: () => _remove(_entries[index]),
                    onTest: () => _test(_entries[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        GlassDialogAction(
          label: _detecting
              ? t.externalPlayer.detecting
              : t.externalPlayer.autoDetect,
          emphasized: false,
          loading: _detecting,
          onPressed: _detecting ? null : _detect,
        ),
        GlassDialogAction(
          label: t.externalPlayer.addPlayer,
          emphasized: true,
          onPressed: _addManually,
        ),
      ],
    );
  }

  /// 选可执行文件。macOS 上选中的是 `.app` 包（一个目录），要往里定位真正的
  /// 可执行文件；Windows/Linux 选中的就是文件本身。
  Future<String?> _pickExecutable() async {
    try {
      final typeGroups = <fs.XTypeGroup>[
        if (Platform.isWindows)
          const fs.XTypeGroup(label: 'Executable', extensions: ['exe'])
        else if (Platform.isMacOS)
          const fs.XTypeGroup(label: 'Application', extensions: ['app']),
      ];
      final file = await fs.openFile(acceptedTypeGroups: typeGroups);
      if (file == null) return null;
      return _resolveMacAppBundle(file.path);
    } catch (e, s) {
      LogUtils.e('选择播放器可执行文件失败', tag: 'DesktopPlayer', error: e, stackTrace: s);
      return null;
    }
  }

  static String _resolveMacAppBundle(String path) {
    if (!Platform.isMacOS || !path.endsWith('.app')) return path;
    final macOsDir = Directory(p.join(path, 'Contents', 'MacOS'));
    if (!macOsDir.existsSync()) return path;
    final preferred = p.join(
      macOsDir.path,
      p.basenameWithoutExtension(path),
    );
    if (File(preferred).existsSync()) return preferred;
    final files = macOsDir.listSync().whereType<File>().toList();
    return files.length == 1 ? files.first.path : path;
  }

  static String _defaultNameOf(String executablePath) {
    return p.basenameWithoutExtension(executablePath);
  }

  Future<DesktopPlayerEntry?> _editEntry(
    DesktopPlayerEntry entry, {
    required bool isNew,
  }) {
    return showAppDialog<DesktopPlayerEntry>(
      _PlayerEditDialog(
        entry: entry,
        isNew: isNew,
        pickExecutable: _pickExecutable,
      ),
      dialogContext: context,
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.entry,
    required this.onEdit,
    required this.onRemove,
    required this.onTest,
  });

  final DesktopPlayerEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final missing = !File(entry.executablePath).existsSync();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        missing ? Icons.error_outline : Icons.smart_display_outlined,
        color: missing ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Row(
        children: [
          Flexible(child: Text(entry.name, overflow: TextOverflow.ellipsis)),
          if (entry.autoDetected) ...[
            const SizedBox(width: 6),
            _Tag(text: t.externalPlayer.autoDetectedTag),
          ],
        ],
      ),
      subtitle: Text(
        missing
            ? t.externalPlayer.executableMissing
            : entry.executablePath,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: missing
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: t.externalPlayer.testLaunch,
            icon: const Icon(Icons.play_arrow_outlined),
            onPressed: missing ? null : onTest,
          ),
          IconButton(
            tooltip: t.common.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: t.common.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// 单个播放器的编辑弹窗（名称 / 可执行文件 / 参数模板）。
class _PlayerEditDialog extends StatefulWidget {
  const _PlayerEditDialog({
    required this.entry,
    required this.isNew,
    required this.pickExecutable,
  });

  final DesktopPlayerEntry entry;
  final bool isNew;
  final Future<String?> Function() pickExecutable;

  @override
  State<_PlayerEditDialog> createState() => _PlayerEditDialogState();
}

class _PlayerEditDialogState extends State<_PlayerEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;
  late final TextEditingController _argsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _pathController = TextEditingController(text: widget.entry.executablePath);
    _argsController = TextEditingController(
      text: widget.entry.argumentTemplate,
    );
  }

  @override
  void dispose() {
    // ⛔ controller 必须由本弹窗自己回收：挂在 showDialog 的 whenComplete 上会在
    // 退场动画还没播完时就 dispose，触发 "used after being disposed"。
    _nameController.dispose();
    _pathController.dispose();
    _argsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassAlertDialog(
      title: widget.isNew
          ? t.externalPlayer.addPlayer
          : t.externalPlayer.editPlayer,
      maxWidth: 520,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: t.externalPlayer.playerName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pathController,
            decoration: InputDecoration(
              labelText: t.externalPlayer.executablePath,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: t.externalPlayer.browse,
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final picked = await widget.pickExecutable();
                  if (picked == null || !mounted) return;
                  _pathController.text = picked;
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _argsController,
            decoration: InputDecoration(
              labelText: t.externalPlayer.argumentTemplate,
              helperText: t.externalPlayer.argumentTemplateHint,
              helperMaxLines: 3,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassDialogAction(
          label: t.common.save,
          emphasized: true,
          onPressed: () {
            final name = _nameController.text.trim();
            final path = _pathController.text.trim();
            if (name.isEmpty || path.isEmpty) {
              showGlassToast(
                t.externalPlayer.nameAndPathRequired,
                type: GlassToastType.warning,
              );
              return;
            }
            Navigator.of(context).pop(
              widget.entry.copyWith(
                name: name,
                executablePath: path,
                argumentTemplate: _argsController.text.trim().isEmpty
                    ? DesktopPlayerEntry.defaultArgumentTemplate
                    : _argsController.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}
