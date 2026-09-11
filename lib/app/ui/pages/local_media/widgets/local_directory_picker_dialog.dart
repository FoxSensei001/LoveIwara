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

    // ⛔ 卷列表必须按平台来：写死 `/storage/emulated/0` 的版本在 macOS /
    // Windows / Linux 上点开只有一条「设备存储」，点进去还是一句「这个文件夹读
    // 不动」——那条路在桌面上根本不存在。
    final volumes = Platform.isAndroid
        ? await _androidVolumes()
        : await _desktopVolumes();

    if (!mounted || _generation != currentGen) return;

    setState(() {
      _volumes = volumes;
      _volumeRootPaths = {
        for (final volume in volumes) p.normalize(volume.directory.path),
      };
      _loading = false;
    });
  }

  /// Android / Quest：内置存储 + `/storage` 下挂着的外置卷（SD、U 盘）。
  Future<List<_VolumeEntry>> _androidVolumes() async {
    final defaultRoot = Directory('/storage/emulated/0');
    final volumes = <_VolumeEntry>[
      _VolumeEntry(
        name: slang.t.localMedia.browse.storageRoot,
        directory: defaultRoot,
      ),
    ];

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
    return volumes;
  }

  /// 桌面（macOS / Windows / Linux）与其余平台的兜底卷列表。
  ///
  /// 这条路平时走不到——桌面点「添加文件夹」走的是系统原生选择器，只有原生那个
  /// 起不来时才退到这张弹窗。所以它要能自己站住：个人文件夹打头（用户的东西九
  /// 成在这儿），然后是盘符 / 挂载点，最后给一条根目录。
  Future<List<_VolumeEntry>> _desktopVolumes() async {
    final volumes = <_VolumeEntry>[];
    final seen = <String>{};

    Future<void> add(String name, String path) async {
      final normalized = p.normalize(path);
      if (!seen.add(normalized)) return;
      final dir = Directory(normalized);
      try {
        if (await dir.exists()) {
          volumes.add(_VolumeEntry(name: name, directory: dir));
        }
      } catch (_) {
        // 探测不了的卷（未插入的光驱、断了的网络盘）直接跳过
      }
    }

    final home = _homeDirectoryPath();
    if (home != null) {
      await add(slang.t.localMedia.browse.homeFolder, home);
    }

    if (Platform.isWindows) {
      // 盘符只能挨个探：Dart 没有枚举驱动器的 API。
      for (
        var letter = 'A'.codeUnitAt(0);
        letter <= 'Z'.codeUnitAt(0);
        letter++
      ) {
        final drive = '${String.fromCharCode(letter)}:\\';
        await add(drive, drive);
      }
      return volumes;
    }

    // macOS 的外置卷、镜像、网络盘全挂在 /Volumes 下；Linux 在 /media/<user>、
    // /run/media/<user> 或 /mnt。
    final mountRoots = <String>[
      if (Platform.isMacOS) '/Volumes',
      if (Platform.isLinux) ...[
        if (home != null) '/media/${p.basename(home)}',
        if (home != null) '/run/media/${p.basename(home)}',
        '/media',
        '/mnt',
      ],
    ];
    for (final root in mountRoots) {
      try {
        final dir = Directory(root);
        if (!await dir.exists()) continue;
        await for (final entity in dir.list()) {
          if (entity is! Directory) continue;
          final name = p.basename(entity.path);
          if (name.startsWith('.')) continue;
          await add(name, entity.path);
        }
      } catch (_) {
        // 挂载点列不出来就算了，根目录那条还在
      }
    }

    await add(slang.t.localMedia.browse.filesystemRoot, '/');
    return volumes;
  }

  /// 当前用户的主目录；取不到返回 null。
  String? _homeDirectoryPath() {
    final env = Platform.environment;
    final candidates = <String?>[
      env['HOME'],
      env['USERPROFILE'],
      if (env['HOMEDRIVE'] != null && env['HOMEPATH'] != null)
        '${env['HOMEDRIVE']}${env['HOMEPATH']}',
    ];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) return candidate;
    }
    return null;
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
