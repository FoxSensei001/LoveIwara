import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_folder_card.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_card.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 「文件夹信息」弹窗：这个目录到底是什么、在哪儿、里面有多少东西。
///
/// # 为什么要有它
///
/// 本机文件这一整套都在**回避**绝对路径：卡片上只有名字，菜单里也只有动作。
/// 平时这是对的（`/storage/emulated/0/Android/data/...` 这种串读起来毫无意义），
/// 但有两件事非要路径不可——「我到底加进来的是哪个目录」（同名子目录到处都是），
/// 以及「把这个路径贴到别的地方去用」（电脑上的文件管理器、adb、另一个 App）。
/// 所以路径在这里给全，而且**可以复制**。
///
/// # ⛔ 取数只在打开这一刻做一次
///
/// 里面那两个数字（条目数、占用空间）是现查库的。sqlite3 在本项目是**主 isolate
/// 上的同步 API**，所以它们必须在 [showLocalFolderInfoDialog] 里一次性查完、
/// 存进 [_FolderInfo] 带进弹窗，绝不能写成弹窗 build 里现查——弹窗有出入场动画，
/// 那等于每帧几次同步查询压在动画上。
Future<void> showLocalFolderInfoDialog({
  required BuildContext context,
  required String sourceId,
  required String relPath,
  String? folderPath,
  String displayName = '',
}) async {
  final info = _FolderInfo.load(
    sourceId: sourceId,
    relPath: relPath,
    folderPath: folderPath,
    displayName: displayName,
  );
  if (!context.mounted) return;
  final t = slang.Translations.of(context);
  await showGlassAlertDialog<void>(
    title: t.localMedia.browse.folderInfo,
    scrollable: true,
    content: _FolderInfoBody(info: info),
    actions: <GlassDialogAction>[
      GlassDialogAction(
        label: t.common.confirm,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    ],
  );
}

/// 弹窗要显示的全部东西，打开那一刻一次性查完（见 [showLocalFolderInfoDialog]）。
class _FolderInfo {
  const _FolderInfo({
    required this.name,
    required this.path,
    required this.sourceName,
    required this.childFolderCount,
    required this.videoCount,
    required this.imageCount,
    required this.probed,
    required this.sizeBytes,
    required this.scannedAt,
  });

  final String name;

  /// 绝对路径。null ＝ 这个源压根没有真实目录树（「已下载」按下载任务同步、
  /// 「设备视频」是系统媒体索引），此时显示一句解释而不是留白。
  final String? path;

  final String sourceName;
  final int childFolderCount;
  final int videoCount;
  final int imageCount;
  final bool probed;
  final int sizeBytes;
  final DateTime? scannedAt;

  static _FolderInfo load({
    required String sourceId,
    required String relPath,
    String? folderPath,
    String displayName = '',
  }) {
    final repository = LocalMediaRepository();
    final source = repository.getSource(sourceId);
    final folder = repository.getFolder(sourceId: sourceId, relPath: relPath);

    // 路径三级回退：调用点给的 → 目录行里的 → 源根那条。来源根这一层在
    // 「已下载 / 设备视频」上三级全空，那就是真的没有路径。
    var resolvedPath = folderPath?.trim();
    if (resolvedPath == null || resolvedPath.isEmpty) {
      resolvedPath = folder?.folderPath?.trim();
    }
    if ((resolvedPath == null || resolvedPath.isEmpty) && relPath.isEmpty) {
      resolvedPath = source?.path?.trim();
    }
    if (resolvedPath != null && resolvedPath.isEmpty) resolvedPath = null;

    final name = displayName.trim().isNotEmpty
        ? displayName.trim()
        : (folder?.name ?? source?.displayName ?? '');

    // ⛔ 计数优先用目录行里那份（扫描时算好的，与卡片上写的是同一个数）。
    // 没有目录行的源（同上）才回表现查——那种源是平的，按 sourceId 数就对。
    final int videoCount;
    final int imageCount;
    if (folder != null) {
      videoCount = folder.videoCount;
      imageCount = folder.imageCount;
    } else {
      videoCount = repository.countItems(
        sourceId: sourceId,
        kind: LocalMediaItemKind.video,
      );
      imageCount = repository.countItems(
        sourceId: sourceId,
        kind: LocalMediaItemKind.image,
      );
    }

    // 占用空间同样按「这一层」算：有真实目录就按 folder_path 精确匹配，
    // 没有就整个源加起来。判据与上面那两个计数一一对应。
    final sizeBytes = resolvedPath != null && folder != null
        ? repository.sumItemBytes(sourceId: sourceId, folderPath: resolvedPath)
        : repository.sumItemBytes(sourceId: sourceId);

    final probedAt = folder?.probedAt;
    return _FolderInfo(
      name: name,
      path: resolvedPath,
      sourceName: source?.displayName ?? '',
      childFolderCount: folder?.childFolderCount ?? 0,
      videoCount: videoCount,
      imageCount: imageCount,
      // 没有目录行的源不存在"扫没扫过"这回事，当已知处理（它的数是现查的）。
      probed: folder == null || probedAt != null,
      sizeBytes: sizeBytes,
      scannedAt: probedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(probedAt),
    );
  }
}

class _FolderInfoBody extends StatelessWidget {
  const _FolderInfoBody({required this.info});

  final _FolderInfo info;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final browse = t.localMedia.browse;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _row(context, label: browse.folderInfoName, value: info.name),
        _pathRow(context),
        if (info.sourceName.isNotEmpty)
          _row(context, label: browse.folderInfoSource, value: info.sourceName),
        _row(
          context,
          label: browse.folderInfoContents,
          // 这一行给的是完整句子（「3 个文件夹 · 128 个视频」），不是卡片上那排
          // 图标：弹窗里不缺宽度，把话说全比省几个字有用。
          value: formatLocalFolderCounts(
            childFolderCount: info.childFolderCount,
            videoCount: info.videoCount,
            imageCount: info.imageCount,
            probed: info.probed,
          ),
        ),
        if (info.sizeBytes > 0)
          _row(
            context,
            label: browse.folderInfoSize,
            value: LocalMediaItemCard.formatBytes(info.sizeBytes),
          ),
        _row(
          context,
          label: browse.folderInfoScannedAt,
          value: info.scannedAt == null
              ? browse.folderInfoNeverScanned
              : CommonUtils.formatFriendlyTimestamp(info.scannedAt),
        ),
      ],
    );
  }

  /// 路径那一行：可选中、可复制，右边一枚复制钮。
  ///
  /// ⛔ 路径**不省略**（`softWrap`，行数不限）。它正是用户打开这张弹窗要看的
  /// 东西，截成「/storage/emulated/0/Android/…」等于白开一次。
  Widget _pathRow(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final path = info.path;
    if (path == null) {
      return _row(
        context,
        label: t.localMedia.browse.folderInfoPath,
        value: t.localMedia.browse.folderInfoNoPath,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            t.localMedia.browse.folderInfoPath,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SelectableText(
                  path,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['Courier'],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ⛔ 弹窗里的动作钮一律玻璃圆钮（本项目已有明确要求），不要
              // 随手放一枚裸 IconButton。
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.copy_rounded),
                iconSize: 18,
                size: 36,
                tooltip: t.localMedia.browse.copyPath,
                onPressed: () => _copy(context, path),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String path) async {
    final t = slang.Translations.of(context);
    await Clipboard.setData(ClipboardData(text: path));
    showAppToast(t.localMedia.browse.pathCopied);
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
