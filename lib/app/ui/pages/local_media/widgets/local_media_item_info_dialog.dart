import 'package:flutter/material.dart';

import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/ui/pages/local_media/widgets/local_media_item_card.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 「文件信息」：这一条在哪、多大、什么规格、上次看到哪天。
///
/// 聚合栏（所有视频 / 精选）跨源平铺，卡片上只有文件名——同名文件到处都是，
/// 用户看不出它来自哪个来源、哪个目录。路径在这里给全、可选中复制。
///
/// 取数在打开这一刻做一次（同 `showLocalFolderInfoDialog` 的理由：sqlite 是主
/// isolate 上的同步 API，不能压在弹窗动画的每一帧上）。
Future<void> showLocalMediaItemInfoDialog({
  required BuildContext context,
  required LocalMediaItem item,
}) async {
  final repository = LocalMediaRepository();
  final source = repository.getSource(item.sourceId);
  final progress = repository.getProgress(item.id);
  final latest = repository.getItem(item.id) ?? item;
  if (!context.mounted) return;

  final t = slang.Translations.of(context);
  final browse = t.localMedia.browse;
  final info = t.localMedia.itemInfoLabels;

  String location() {
    if (!DavPath.isDav(latest.path)) return latest.path;
    // NAS：`dav:/` 是库内形状，给用户看「主机 + 服务端路径」。
    final host = Uri.tryParse(source?.uri ?? '')?.host ?? '';
    return '$host${DavPath.toServerPath(latest.path)}';
  }

  final width = latest.width;
  final height = latest.height;
  final durationMs = latest.durationMs;
  final lastPlayed = latest.lastPlayedAt;
  final rows = <(String, String)>[
    (browse.folderInfoName, latest.name),
    (browse.folderInfoPath, location()),
    (browse.folderInfoSource, source?.displayName ?? ''),
    if (latest.sizeBytes case final size? when size > 0)
      (info.size, LocalMediaItemCard.formatBytes(size)),
    if (width != null && height != null && width > 0 && height > 0)
      (info.resolution, '$width × $height'),
    if (durationMs != null && durationMs > 0)
      (
        info.duration,
        CommonUtils.formatDuration(Duration(milliseconds: durationMs)),
      ),
    if (latest.modifiedAt case final modified? when modified > 0)
      (
        info.modified,
        CommonUtils.formatFriendlyTimestamp(
          DateTime.fromMillisecondsSinceEpoch(modified),
        ),
      ),
    if (latest.kind == LocalMediaItemKind.video)
      (
        info.lastPlayed,
        lastPlayed == null
            ? info.neverPlayed
            : [
                CommonUtils.formatFriendlyTimestamp(
                  DateTime.fromMillisecondsSinceEpoch(lastPlayed),
                ),
                if (progress?.completed ?? false) info.completed,
              ].join(' · '),
      ),
  ];

  await showGlassAlertDialog<void>(
    title: t.localMedia.itemInfo,
    scrollable: true,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in rows)
          if (value.trim().isNotEmpty) _InfoRow(label: label, value: value),
      ],
    ),
    actions: <GlassDialogAction>[
      GlassDialogAction(
        label: t.common.confirm,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
