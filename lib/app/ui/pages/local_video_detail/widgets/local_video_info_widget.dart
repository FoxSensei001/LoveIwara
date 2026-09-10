import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/utils/common_utils.dart';

/// 本地视频信息展示组件
/// 显示视频元数据（来自下载任务）或文件信息（纯本地文件）
class LocalVideoInfoWidget extends StatefulWidget {
  final MyVideoStateController controller;
  final DownloadTask? task;
  final List<DownloadTask> allQualityTasks;
  final String localPath;
  final String? localLibraryItemId;

  const LocalVideoInfoWidget({
    super.key,
    required this.controller,
    required this.task,
    required this.allQualityTasks,
    required this.localPath,
    this.localLibraryItemId,
  });

  @override
  State<LocalVideoInfoWidget> createState() => _LocalVideoInfoWidgetState();
}

class _LocalVideoInfoWidgetState extends State<LocalVideoInfoWidget> {
  LocalMediaItem? _localItem;

  MyVideoStateController get controller => widget.controller;
  DownloadTask? get task => widget.task;
  List<DownloadTask> get allQualityTasks => widget.allQualityTasks;
  String get localPath => widget.localPath;

  String? get _remoteCover {
    final ext = task?.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.video) return null;
    try {
      final cover = VideoDownloadExtData.fromJson(ext.data).thumbnail?.trim();
      return cover == null || cover.isEmpty ? null : cover;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadLocalItem();
  }

  @override
  void didUpdateWidget(covariant LocalVideoInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localLibraryItemId != widget.localLibraryItemId ||
        oldWidget.localPath != widget.localPath) {
      _localItem = null;
      _loadLocalItem();
    }
  }

  void _loadLocalItem() {
    final itemId = widget.localLibraryItemId;
    if (itemId == null || itemId.isEmpty) return;
    try {
      final item = LocalMediaRepository().getItem(itemId);
      if (!mounted) return;
      setState(() => _localItem = item);
      if (item != null) _ensureThumbnail(item);
    } catch (_) {
      // The player remains usable even if a stale route points at a removed row.
    }
  }

  Future<void> _ensureThumbnail(LocalMediaItem item) async {
    if (!Get.isRegistered<LocalMediaDerivationService>()) return;
    final updated = await LocalMediaDerivationService.to.ensureThumbnail(item);
    if (!mounted ||
        updated == null ||
        updated.id != widget.localLibraryItemId) {
      return;
    }
    setState(() => _localItem = updated);
  }

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
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
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

            if (_localItem != null || _remoteCover != null) ...[
              _buildCover(context),
              const SizedBox(height: 16),
            ],

            // 标题
            Obx(() {
              final videoInfo = controller.videoInfo.value;
              final title =
                  videoInfo?.title ??
                  _localItem?.name ??
                  _getFileNameFromPath(localPath);
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
              final quality = CommonUtils.getQualityDisplayLabel(
                t,
                controller.currentResolutionTag.value,
              );
              return _buildInfoRow(
                context,
                t.videoDetail.localInfo.currentQuality,
                quality,
                Icons.high_quality,
              );
            }),

            // 时长
            Obx(() {
              final storedDuration = _localItem?.durationMs;
              final duration = storedDuration != null
                  ? Duration(milliseconds: storedDuration)
                  : controller.totalDuration.value;
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
              final width =
                  _localItem?.width ?? controller.sourceVideoWidth.value;
              final height =
                  _localItem?.height ?? controller.sourceVideoHeight.value;
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

  Widget _buildCover(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final item = _localItem;
    final sidecar = item?.sidecarImagePath;
    final thumbnail = item?.thumbPath;

    Widget placeholder() => ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
      ),
    );

    Widget remoteOrPlaceholder() {
      final cover = _remoteCover;
      if (cover == null) return placeholder();
      return CachedNetworkImage(
        imageUrl: cover,
        fit: BoxFit.cover,
        memCacheWidth: 960,
        errorWidget: (_, _, _) => placeholder(),
      );
    }

    Widget fromFile(String filePath, {Widget? fallback}) => Image.file(
      File(filePath),
      fit: BoxFit.cover,
      cacheWidth: 960,
      errorBuilder: (_, _, _) => fallback ?? remoteOrPlaceholder(),
    );

    final thumbnailFallback = thumbnail != null && thumbnail.isNotEmpty
        ? fromFile(thumbnail)
        : null;
    final child = sidecar != null && sidecar.isNotEmpty
        ? fromFile(
            sidecar,
            fallback: thumbnailFallback ?? remoteOrPlaceholder(),
          )
        : thumbnail != null && thumbnail.isNotEmpty
        ? thumbnailFallback!
        : remoteOrPlaceholder();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(aspectRatio: 16 / 9, child: child),
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
            if (_localItem?.sizeBytes != null)
              _buildInfoRow(
                context,
                t.videoDetail.localInfo.fileSize,
                _formatFileSize(_localItem!.sizeBytes!),
                Icons.storage_outlined,
              )
            else
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
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _copyPath(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(t.videoDetail.localInfo.copyPath),
                ),
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
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
    showAppToast(
      t.videoDetail.localInfo.pathCopiedToClipboard,
      type: AppToastType.success,
    );
  }

  /// 打开文件所在文件夹
  Future<void> _openFolder(BuildContext context) async {
    try {
      final dir = path.dirname(localPath);
      final result = await OpenFile.open(dir);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          showAppToast(
            '${t.videoDetail.localInfo.openFolderFailed}: ${result.message}',
            type: AppToastType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showAppToast(
          '${t.videoDetail.localInfo.openFolderFailed}: $e',
          type: AppToastType.error,
        );
      }
    }
  }
}
