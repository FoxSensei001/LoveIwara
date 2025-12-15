import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

/// 本地视频信息展示组件
/// 显示视频元数据（来自下载任务）或文件信息（纯本地文件）
class LocalVideoInfoWidget extends StatelessWidget {
  final MyVideoStateController controller;
  final DownloadTask? task;
  final List<DownloadTask> allQualityTasks;
  final String localPath;

  const LocalVideoInfoWidget({
    super.key,
    required this.controller,
    required this.task,
    required this.allQualityTasks,
    required this.localPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 视频信息卡片
          _buildVideoInfoCard(context),
          const SizedBox(height: 16),

          // 文件信息卡片
          _buildFileInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildVideoInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  t.videoDetail.localInfo.videoInfo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // 标题
            Obx(() {
              final videoInfo = controller.videoInfo.value;
              final title = videoInfo?.title ?? _getFileNameFromPath(localPath);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.subtitles_outlined,
                    size: 20,
                    color: theme.hintColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '标题',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          title,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),

            // 当前清晰度
            Obx(() {
              final quality = controller.currentResolutionTag.value ?? '未知';
              return _buildInfoRow(
                context,
                t.videoDetail.localInfo.currentQuality,
                quality,
                Icons.high_quality,
              );
            }),

            // 时长
            Obx(() {
              final duration = controller.totalDuration.value;
              if (duration.inSeconds > 0) {
                return _buildInfoRow(
                  context,
                  t.videoDetail.localInfo.duration,
                  _formatDuration(duration.inSeconds),
                  Icons.timer_outlined,
                );
              }
              return const SizedBox.shrink();
            }),

            // 分辨率
            Obx(() {
              final width = controller.sourceVideoWidth.value;
              final height = controller.sourceVideoHeight.value;
              if (width > 0 && height > 0) {
                return _buildInfoRow(
                  context,
                  t.videoDetail.localInfo.resolution,
                  '${width}x$height',
                  Icons.aspect_ratio,
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  t.videoDetail.localInfo.fileInfo,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // 文件名（支持换行）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 20,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.videoDetail.localInfo.fileName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _getFileNameFromPath(localPath),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 文件大小
            FutureBuilder<int>(
              future: _getFileSize(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildInfoRow(
                    context,
                    t.videoDetail.localInfo.fileSize,
                    _formatFileSize(snapshot.data!),
                    Icons.storage_outlined,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),

            // 文件路径（直接显示，支持换行）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 20,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.videoDetail.localInfo.filePath,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        localPath,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _copyPath(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(t.videoDetail.localInfo.copyPath),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _openFolder(context),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: Text(t.videoDetail.localInfo.openFolder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.hintColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileNameFromPath(String path) {
    return path.split('/').last.split('\\').last;
  }

  Future<int> _getFileSize() async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (_) {}
    return 0;
  }

  IconData _getQualityIcon(String quality) {
    switch (quality.toLowerCase()) {
      case 'source':
        return Icons.video_label;
      case '1080':
        return Icons.high_quality;
      case '720':
        return Icons.hd;
      case '540':
      case '360':
        return Icons.sd;
      default:
        return Icons.video_settings;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 复制路径到剪贴板
  void _copyPath(BuildContext context) {
    Clipboard.setData(ClipboardData(text: localPath));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.videoDetail.localInfo.pathCopiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 打开文件所在文件夹
  Future<void> _openFolder(BuildContext context) async {
    try {
      final dir = path.dirname(localPath);
      final result = await OpenFile.open(dir);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${t.videoDetail.localInfo.openFolderFailed}: ${result.message}')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${t.videoDetail.localInfo.openFolderFailed}: $e')));
      }
    }
  }
}
