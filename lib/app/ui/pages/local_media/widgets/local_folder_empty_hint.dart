import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/services/local_media_directory_policy.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 空目录页上「为什么是空的」的补充说明，挂在「这个文件夹是空的」下面。
///
/// 同样一句「空的」背后有三种完全不同的实情，给用户的出路也不一样：
/// - 里面有 `.` 开头的文件夹、只是这个来源没开扫描 → 告诉他有几个，一键开启；
/// - 目录压根读不动 → 说读不动；落在 `Android/data` 这类别的应用的私有目录里时，
///   换成那段系统限制的解释（任何权限都救不了，别让用户去翻设置）；
/// - 真的空 → 什么都不加，上面那句已经是实情。
///
/// 只探本机目录的**这一层**（一次 `list`，不递归），NAS 源不探：为一句提示多打
/// 一轮网络不值。探测是异步的，结果出来之前什么都不画，出来时带动画长出来。
class LocalFolderEmptyHint extends StatefulWidget {
  const LocalFolderEmptyHint({
    super.key,
    required this.source,
    required this.folderPath,
  });

  final LocalMediaSource? source;
  final String? folderPath;

  @override
  State<LocalFolderEmptyHint> createState() => _LocalFolderEmptyHintState();
}

enum _HintKind { none, dotSkipped, unreadable, otherAppsPrivate }

class _LocalFolderEmptyHintState extends State<LocalFolderEmptyHint> {
  _HintKind _kind = _HintKind.none;
  int _dotCount = 0;
  int _probeGeneration = 0;
  bool _enabling = false;

  @override
  void initState() {
    super.initState();
    unawaited(_probe());
  }

  @override
  void didUpdateWidget(LocalFolderEmptyHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.folderPath != widget.folderPath ||
        oldWidget.source?.includeDotEntries !=
            widget.source?.includeDotEntries) {
      unawaited(_probe());
    }
  }

  Future<void> _probe() async {
    final generation = ++_probeGeneration;
    final source = widget.source;
    final path = widget.folderPath;
    var kind = _HintKind.none;
    var dotCount = 0;
    if (source != null &&
        source.usesLocalFileSystem &&
        path != null &&
        path.isNotEmpty &&
        !path.startsWith('content://')) {
      try {
        await for (final entity in Directory(path).list(followLinks: false)) {
          if (entity is! Directory) continue;
          final name = p.basename(entity.path);
          if (source.includeDotEntries) continue;
          if (LocalDirectoryPolicy.isDotEntry(name) &&
              !LocalDirectoryPolicy.isJunk(name)) {
            dotCount++;
          }
        }
        if (dotCount > 0) kind = _HintKind.dotSkipped;
      } catch (_) {
        kind = LocalDirectoryPolicy.isUnderOtherAppsPrivate(path)
            ? _HintKind.otherAppsPrivate
            : _HintKind.unreadable;
      }
    }
    if (!mounted || generation != _probeGeneration) return;
    setState(() {
      _kind = kind;
      _dotCount = dotCount;
    });
  }

  Future<void> _enableDotFolders() async {
    final source = widget.source;
    if (source == null || !Get.isRegistered<LocalMediaScanService>()) return;
    setState(() => _enabling = true);
    // 不等整源重扫跑完：改库在 setIncludeDotEntries 的第一个 await 之前就同步
    // 做完了，页面这就会刷新；等整盘扫完再松按钮，大目录上会转上好几分钟。
    unawaited(
      LocalMediaScanService.to.setIncludeDotEntries(source.id, true).catchError(
        (Object e) {
          LogUtils.w('开启 . 开头文件夹扫描失败: $e', 'LocalFolderEmptyHint');
          showAppToast(
            slang.t.localMedia.scanFailed(reason: '$e'),
            type: AppToastType.error,
          );
        },
      ),
    );
    showAppToast(slang.t.localMedia.browse.dotFoldersIncluded);
    if (mounted) setState(() => _enabling = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.t.localMedia.browse;
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final Widget child = switch (_kind) {
      _HintKind.none => const SizedBox.shrink(key: ValueKey<String>('none')),
      _HintKind.dotSkipped => Column(
        key: const ValueKey<String>('dot'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.dotFoldersSkipped(count: _dotCount),
            style: textStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GlassButtonGroup(
            children: [
              GlassTextActionButton(
                label: t.scanDotFoldersAction,
                emphasized: true,
                onPressed: _enabling ? null : _enableDotFolders,
              ),
            ],
          ),
        ],
      ),
      _HintKind.unreadable => Text(
        t.folderUnreadable,
        key: const ValueKey<String>('unreadable'),
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      _HintKind.otherAppsPrivate => Row(
        key: const ValueKey<String>('private'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 8),
          Flexible(child: Text(t.otherAppsPrivateNotice, style: textStyle)),
        ],
      ),
    };

    // 出现与消失都走动画：探测结果晚到一拍，硬切会让空态整块往下一跳。
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _kind == _HintKind.none
            ? child
            : Padding(
                key: ValueKey<_HintKind>(_kind),
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: child,
                ),
              ),
      ),
    );
  }
}
