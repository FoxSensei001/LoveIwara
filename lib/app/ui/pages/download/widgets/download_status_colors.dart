import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';

/// 根据当前主题（Material 3 动态配色）为下载状态返回适配的颜色。
///
/// 替代各处硬编码的 `Colors.green/red/orange/blue`，
/// 以便在暗色模式 / 动态配色下保持可读性与一致性。
Color downloadStatusColor(BuildContext context, DownloadStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case DownloadStatus.completed:
      return colorScheme.primary;
    case DownloadStatus.downloading:
      return colorScheme.tertiary;
    case DownloadStatus.pending:
      return colorScheme.onSurfaceVariant;
    case DownloadStatus.paused:
      // 暖色警示色：在 tertiary 上混入一定比例的 error，得到与主题协调的“橙色”
      return Color.alphaBlend(
        colorScheme.error.withValues(alpha: 0.4),
        colorScheme.tertiary,
      );
    case DownloadStatus.failed:
      return colorScheme.error;
  }
}
