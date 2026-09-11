import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 让用户挑一个文件夹。返回选中的**绝对路径**；用户取消返回 null。
Future<String?> showLocalDirectoryPickerDialog({
  required BuildContext context,
}) {
  return showAppDialog<String>(
    const _LocalDirectoryPickerDialog(),
    dialogContext: context,
  );
}

class _VolumeEntry {
  final String name;
  final Directory directory;

  const _VolumeEntry({required this.name, required this.directory});
}

class _LocalDirectoryPickerDialog extends StatefulWidget {
  const _LocalDirectoryPickerDialog();

  @override
  State<_LocalDirectoryPickerDialog> createState() =>
      _LocalDirectoryPickerDialogState();
}

class _LocalDirectoryPickerDialogState
    extends State<_LocalDirectoryPickerDialog> {
  Directory? _current;
  bool _loading = false;
  int _generation = 0;

  List<_VolumeEntry> _volumes = const [];
  List<Directory> _subdirectories = const [];
  Set<String> _volumeRootPaths = const {};

  @override
  void initState() {
    super.initState();
    _loadVolumes();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  Future<void> _loadVolumes() async {
    final currentGen = ++_generation;
    setState(() => _loading = true);

    final defaultRoot = Directory('/storage/emulated/0');
    final volumes = <_VolumeEntry>[
      _VolumeEntry(
        name: slang.t.localMedia.browse.storageRoot,
        directory: defaultRoot,
      ),
    ];
    final roots = <String>{p.normalize(defaultRoot.path)};

    try {
      final storageDir = Directory('/storage');
      if (await storageDir.exists()) {
        final extraVolumes = <_VolumeEntry>[];
        await for (final entity in storageDir.list()) {
          if (entity is! Directory) continue;
          final name = p.basename(entity.path);
          if (name == 'emulated' || name == 'self' || name.startsWith('.')) {
            continue;
          }
          try {
            if (await entity.exists()) {
              extraVolumes.add(_VolumeEntry(name: name, directory: entity));
              roots.add(p.normalize(entity.path));
            }
          } catch (_) {
            // 单个卷探测失败则忽略
          }
        }
        extraVolumes.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        volumes.addAll(extraVolumes);
      }
    } catch (_) {
      // 枚举失败（抛异常）时只留固定第一项，不要让弹窗空掉
    }

    if (!mounted || _generation != currentGen) return;

    setState(() {
      _volumes = volumes;
      _volumeRootPaths = roots;
      _loading = false;
    });
  }

  Future<void> _loadDirectory(Directory dir) async {
    final currentGen = ++_generation;
    setState(() {
      _current = dir;
      _subdirectories = const [];
      _loading = true;
    });

    final list = <Directory>[];
    bool failed = false;

    try {
      await for (final entity in dir.list()) {
        if (entity is! Directory) continue;
        final name = p.basename(entity.path);
        if (name.startsWith('.')) continue;
        list.add(entity);
      }
    } catch (_) {
      failed = true;
    }

    if (!mounted || _generation != currentGen) return;

    if (failed) {
      setState(() {
        _subdirectories = const [];
        _loading = false;
      });
      showAppToast(
        slang.t.localMedia.browse.folderUnreadable,
        type: AppToastType.error,
      );
      return;
    }

    list.sort((a, b) {
      final aName = p.basename(a.path).toLowerCase();
      final bName = p.basename(b.path).toLowerCase();
      return aName.compareTo(bName);
    });

    setState(() {
      _subdirectories = list;
      _loading = false;
    });
  }

  /// 卷根往上是**卷列表**，不是禁用。
  ///
  /// ⛔ 一开始写成「在卷根就把返回钮置灰」，那等于把用户锁死在第一个进去的卷里：
  /// 想换一张 SD 卡只能关掉弹窗重开。往上一级的语义是「回到上一层选择」，
  /// 卷根的上一层就是那张卷列表。
  bool get _canGoUp => _current != null;

  void _goUp() {
    final current = _current;
    if (current == null) return;
    final currentPath = current.path;
    // 已经在某个卷的根上：回卷列表。
    for (final root in _volumeRootPaths) {
      if (p.equals(root, currentPath)) {
        _showVolumes();
        return;
      }
    }
    final parent = current.parent;
    // 父目录还落在某个卷里就进去；越界了（`/storage/emulated` 这种）同样回卷列表。
    for (final root in _volumeRootPaths) {
      if (p.equals(root, parent.path) || p.isWithin(root, parent.path)) {
        _loadDirectory(parent);
        return;
      }
    }
    _showVolumes();
  }

  void _showVolumes() {
    _generation++;
    setState(() {
      _current = null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPathText =
        _current?.path ?? slang.t.localMedia.browse.pickFolderTitle;

    return GlassAlertDialog(
      title: slang.t.localMedia.browse.pickFolderTitle,
      maxWidth: 520,
      scrollable: false,
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
        ),
        GlassDialogAction(
          label: slang.t.localMedia.browse.useThisFolder,
          emphasized: true,
          onPressed: _current == null
              ? null
              : () => Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop(_current!.path),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_upward),
                tooltip: slang.t.common.back,
                onPressed: _canGoUp ? _goUp : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentPathText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 320, child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_current == null) {
      return ListView.builder(
        itemCount: _volumes.length,
        itemBuilder: (context, index) {
          final vol = _volumes[index];
          return ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: Text(vol.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () => _loadDirectory(vol.directory),
          );
        },
      );
    }

    if (_subdirectories.isEmpty) {
      return Center(
        child: Text(
          slang.t.localMedia.browse.noSubfolders,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _subdirectories.length,
      itemBuilder: (context, index) {
        final dir = _subdirectories[index];
        return ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(
            p.basename(dir.path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _loadDirectory(dir),
        );
      },
    );
  }
}
