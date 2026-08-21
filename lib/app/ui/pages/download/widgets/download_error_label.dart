import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
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
                showGlassToast(
                  t.download.errorDetailCopied,
                  type: GlassToastType.success,
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
