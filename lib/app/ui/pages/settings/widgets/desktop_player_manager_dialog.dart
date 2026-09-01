import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/services/desktop_external_player.dart';
import 'package:i_iwara/app/services/desktop_player_probe.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 桌面端外部播放器管理面板：列表 + 自动探测 + 手动添加 / 编辑 / 删除。
///
/// ⛔ 不回传「这趟有没有改过配置」。想过用返回值传，但 [GlassAlertDialog] 右上角
/// 那枚关闭钮走的是 `Navigator.pop()`——它绕过 `PopScope`，带回来的恒是 null，
/// 于是「改过」这个信号在最常用的那条关闭路径上必定丢失。调用方关掉之后无条件
/// 重读一遍即可：配置就在内存里，重读只是一次小 JSON 解码，比一个会漏的信号可靠。
Future<void> showDesktopPlayerManagerDialog(BuildContext context) {
  return showAppDialog<void>(
    const _DesktopPlayerManagerDialog(),
    dialogContext: context,
  );
}

/// 平台相关的文案分档。
///
/// ⛔ 这三个平台的差别不是"措辞不同"，是**说的根本不是同一件事**：Windows 上
/// 要选的是 `.exe`，macOS 上要选的是 `.app` 包（还要往里定位真正的可执行文件），
/// Linux 上则往往是 `/usr/bin` 下一个没有扩展名的文件。而 HereSphere / DeoVR /
/// Whirligig 这几个例子**只在 Windows 上存在**，摆到 macOS 的说明里是误导
/// （2026-08-30 用户报障：「没有针对各系统平台做定制优化调整，文案也是」）。
enum _PlatformFlavor {
  windows,
  macos,
  linux;

  static _PlatformFlavor get current {
    if (Platform.isWindows) return windows;
    if (Platform.isMacOS) return macos;
    return linux;
  }

  T pick<T>({required T windows, required T macos, required T linux}) {
    return switch (this) {
      _PlatformFlavor.windows => windows,
      _PlatformFlavor.macos => macos,
      _PlatformFlavor.linux => linux,
    };
  }
}

/// 本平台「这功能是干嘛的」那段说明。设置页那个入口的副标题也用它——同一句话
/// 不该在两处各写一份，更不该只在弹窗里分平台、在设置页里还是 Windows 那版。
String desktopPlayerManagerDescription(slang.Translations t) {
  final e = t.externalPlayer;
  return _PlatformFlavor.current.pick(
    windows: e.managePlayersDescWindows,
    macos: e.managePlayersDescMac,
    linux: e.managePlayersDescLinux,
  );
}

/// 本平台「该选哪个文件」那句提示。
String _pickHint(slang.Translations t) {
  final e = t.externalPlayer;
  return _PlatformFlavor.current.pick(
    windows: e.pickExecutableHintWindows,
    macos: e.pickExecutableHintMac,
    linux: e.pickExecutableHintLinux,
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

  Future<void> _persist() => DesktopPlayerStore.save(_entries);

  Future<void> _detect() async {
    final t = slang.Translations.of(context);
    setState(() => _detecting = true);
    try {
      final found = await DesktopPlayerProbe.detect(existing: _entries);
      if (!mounted) return;
      if (found.isEmpty) {
        // ⛔ 不能只丢一句「没探测到」就完事——那是条死路：探测本来就是尽力而为
        // （软件装在自定义目录、绿色版、改过名的都探不到），说完不给出路，用户
        // 就卡在这儿了。直接把手动添加接上。
        showAppToast(
          _entries.isEmpty
              ? t.externalPlayer.detectNothingFoundGuide
              : t.externalPlayer.detectNothingNew,
          type: AppToastType.warning,
        );
        return;
      }
      setState(() => _entries = [..._entries, ...found]);
      await _persist();
      if (!mounted) return;
      showAppToast(
        t.externalPlayer.detectFound(count: found.length),
        type: AppToastType.success,
      );
    } catch (e, s) {
      LogUtils.e('自动探测外部播放器失败', tag: 'DesktopPlayer', error: e, stackTrace: s);
      if (!mounted) return;
      showAppToast(t.externalPlayer.detectFailed, type: AppToastType.error);
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  /// 手动添加。
  ///
  /// ⛔ **先开表单，再让用户去选文件**，顺序不能反。上一版是点一下就直接弹系统
  /// 文件选择器：一个只筛 `*.exe` 的窗口凭空跳出来，既没说要选什么、也没说选完
  /// 会怎样，用户只会一脸茫然地关掉（2026-08-30 用户报障：「手动添加就打开了个
  /// 弹窗，我也不知道是干啥」）。表单里写清楚要选哪个文件，选择器由用户自己按
  /// 「浏览」触发，这一下就有上下文了。
  Future<void> _addManually() async {
    final entry = DesktopPlayerEntry(
      id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
      name: '',
      executablePath: '',
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
    showAppToast(
      ok ? t.externalPlayer.testLaunched : t.externalPlayer.testFailed,
      type: ok ? AppToastType.success : AppToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return GlassAlertDialog(
      title: t.externalPlayer.managePlayers,
      maxWidth: 620,
      scrollable: true,
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              desktopPlayerManagerDescription(t),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_entries.isEmpty)
              _EmptyState(detecting: _detecting)
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
          onPressed: _detecting ? null : _addManually,
        ),
      ],
    );
  }

  /// 选可执行文件。macOS 上选中的是 `.app` 包（一个目录），要往里定位真正的
  /// 可执行文件；Windows/Linux 选中的就是文件本身。
  static Future<String?> pickExecutable() async {
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
    final preferred = p.join(macOsDir.path, p.basenameWithoutExtension(path));
    if (File(preferred).existsSync()) return preferred;
    final files = macOsDir.listSync().whereType<File>().toList();
    return files.length == 1 ? files.first.path : path;
  }

  Future<DesktopPlayerEntry?> _editEntry(
    DesktopPlayerEntry entry, {
    required bool isNew,
  }) {
    return showAppDialog<DesktopPlayerEntry>(
      _PlayerEditDialog(entry: entry, isNew: isNew),
      dialogContext: context,
    );
  }
}

/// 一个都没配时的空态。
///
/// ⛔ 上一版这里只有一行「还没有配置任何外部播放器」——它把**状态**说了，却
/// 没说这功能是干嘛的、也没说下一步该干嘛，于是整只弹窗看上去就是"不知所谓"。
/// 现在补上本平台的常见播放器例子，让底下那两枚动作钮有个落脚点。
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.detecting});

  final bool detecting;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 例子直接从探测候选表里取本平台的前几个：说明里举的例子和探测器真正会去
    // 找的东西永远对得上，不会各说各的。
    final examples = DesktopPlayerProbe.candidatesForPlatform
        .take(4)
        .map((c) => c.name)
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            detecting ? Icons.search : Icons.smart_display_outlined,
            size: 28,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            t.externalPlayer.noPlayerConfigured,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            t.externalPlayer.emptyStateGuide(examples: examples),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
        missing ? t.externalPlayer.executableMissing : entry.executablePath,
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
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: cs.onSecondaryContainer),
      ),
    );
  }
}

/// 单个播放器的编辑弹窗（可执行文件 / 名称 / 启动参数）。
///
/// # 字段顺序按「用户实际怎么填」排
///
/// 先选可执行文件，名称由文件名自动带出来（多数时候不用改），启动参数收进
/// 「高级」里默认不展开——它是给少数需要额外命令行开关的播放器用的，摆在明面上
/// 只会让人以为"这里必须填点什么"。
class _PlayerEditDialog extends StatefulWidget {
  const _PlayerEditDialog({required this.entry, required this.isNew});

  final DesktopPlayerEntry entry;
  final bool isNew;

  @override
  State<_PlayerEditDialog> createState() => _PlayerEditDialogState();
}

class _PlayerEditDialogState extends State<_PlayerEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;
  late final TextEditingController _argsController;

  /// 名称有没有被用户亲手改过。没改过时，重新选可执行文件要把名称一起带新的
  /// ——选错了文件回头再选一次，名称却还停在上一个上，是很容易漏看的错配。
  bool _nameTouchedByUser = false;

  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.name);
    _pathController = TextEditingController(text: widget.entry.executablePath);
    _argsController = TextEditingController(text: widget.entry.argumentTemplate);
    _nameTouchedByUser = widget.entry.name.isNotEmpty;
    // 已经写过非默认参数的条目，进来就把「高级」摊开——否则用户看不到自己填过
    // 的东西，会以为丢了。
    _showAdvanced =
        widget.entry.argumentTemplate !=
        DesktopPlayerEntry.defaultArgumentTemplate;
    _nameController.addListener(() {
      if (_nameController.text.isNotEmpty) _nameTouchedByUser = true;
    });
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

  Future<void> _browse() async {
    final picked = await _DesktopPlayerManagerDialogState.pickExecutable();
    if (picked == null || !mounted) return;
    setState(() {
      _pathController.text = picked;
      if (!_nameTouchedByUser || _nameController.text.trim().isEmpty) {
        _nameController.text = p.basenameWithoutExtension(picked);
        _nameTouchedByUser = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

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
          // 可执行文件排第一：这是唯一必须由用户去磁盘上找的东西，也是这个表单
          // 存在的理由。上面那句提示说清楚本平台该选什么。
          Text(
            _pickHint(t),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _pathController,
            decoration: InputDecoration(
              labelText: t.externalPlayer.executablePath,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: t.externalPlayer.browse,
                icon: const Icon(Icons.folder_open),
                onPressed: _browse,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: t.externalPlayer.playerName,
              helperText: t.externalPlayer.playerNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
              icon: Icon(
                _showAdvanced ? Icons.expand_less : Icons.expand_more,
                size: 18,
              ),
              label: Text(t.externalPlayer.advancedOptions),
            ),
          ),
          if (_showAdvanced) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _argsController,
              decoration: InputDecoration(
                labelText: t.externalPlayer.argumentTemplate,
                helperText: t.externalPlayer.argumentTemplateHint,
                helperMaxLines: 4,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
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
            if (path.isEmpty) {
              showAppToast(
                t.externalPlayer.executablePathRequired,
                type: AppToastType.warning,
              );
              return;
            }
            Navigator.of(context).pop(
              widget.entry.copyWith(
                // 名称留空不该拦人——文件名本来就是个够用的默认值。
                name: name.isEmpty ? p.basenameWithoutExtension(path) : name,
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
