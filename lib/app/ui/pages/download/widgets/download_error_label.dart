import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/services/download_file_health.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 失败任务的原因标签。
///
/// 此前这里直接把 `task.error` 甩出来——那是异常原文（往往是
/// `DioException [connection error]: ...` 这种），用户看不懂，也判断不出「该重试
/// 还是该去清理磁盘」。现在显示按 [DownloadErrorType] 归类后的人话，原文收进长按
/// 复制，排查时照样拿得到。
class DownloadErrorLabel extends StatelessWidget {
  const DownloadErrorLabel({super.key, required this.task});

  final DownloadTask task;

  static String describe(BuildContext context, DownloadErrorType type) {
    final t = slang.Translations.of(context).download.errorTypes;
    return switch (type) {
      DownloadErrorType.network => t.network,
      DownloadErrorType.serverRejected => t.serverRejected,
      DownloadErrorType.notFound => t.notFound,
      DownloadErrorType.diskFull => t.diskFull,
      DownloadErrorType.fileInUse => t.fileInUse,
      DownloadErrorType.permission => t.permission,
      DownloadErrorType.cancelled => t.cancelled,
      DownloadErrorType.unknown => t.unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    // 已完成的任务没有「失败原因」，这一格改报文件还在不在（见 DownloadFileHealth）。
    if (task.status == DownloadStatus.completed) {
      return _FileHealthLabel(task: task);
    }
    final raw = task.error;
    if (raw == null && task.errorType == null) return const SizedBox.shrink();

    final t = slang.Translations.of(context);
    final type = DownloadErrorType.parse(task.errorType);
    // 归不了类的老数据没有分类可显示，退回原文，总比什么都不说强。
    final label = type == DownloadErrorType.unknown && raw != null
        ? raw
        : describe(context, type);

    return Tooltip(
      message: raw ?? label,
      child: GestureDetector(
        onLongPress: raw == null
            ? null
            : () async {
                await Clipboard.setData(ClipboardData(text: raw));
                if (!context.mounted) return;
                showAppToast(
                  t.download.errorDetailCopied,
                  type: AppToastType.success,
                );
              },
        child: Text(
          label,
          style: const TextStyle(color: Colors.red),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// 已完成任务的「文件已不在 / 暂时找不到」标签。
///
/// 三张卡片都经过 [DownloadErrorLabel]，所以「可见卡片首次出现时检查」就挂在
/// 这里：建出来时报一次到文件健康缓存（只记账，IO 由缓存攒批去做），结果回来
/// 后这一格自己长出来。文件在的时候什么都不占。
class _FileHealthLabel extends StatelessWidget {
  const _FileHealthLabel({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    if (!DownloadFileHealth.isReady) return const SizedBox.shrink();
    final health = DownloadFileHealth.to;
    health.noteVisible(task);
    final t = slang.Translations.of(context).download.actions;
    final theme = Theme.of(context);

    return Obx(() {
      final state = health.stateOf(task.id);
      final Widget child = switch (state) {
        DownloadFileState.missing => Text(
          t.fileMissing,
          key: const ValueKey('missing'),
          style: TextStyle(color: theme.colorScheme.error),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        DownloadFileState.pending => Text(
          t.filePending,
          key: const ValueKey('pending'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        _ => const SizedBox(key: ValueKey('ok'), width: double.infinity),
      };
      // 出现与消失都要有过程：高度随内容伸缩，文字交叉淡入淡出。
      return AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topLeft,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topLeft,
            children: [...previous, ?current],
          ),
          child: child,
        ),
      );
    });
  }
}
