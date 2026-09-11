import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 视频来源切到设备文件时使用的卡片。
///
/// 本地文件不是一个缺少网络字段的 [Video]：扫描来的文件没有作者、官方标题或远端
/// 封面，所以这里直接用文件语义排版。下载条目才通过 `download_task_id` 补上任务
/// 保存的元数据作为装饰，不把假造的线上模型塞进线上操作菜单。
class LocalMediaCardListItemWidget extends StatefulWidget {
  const LocalMediaCardListItemWidget({
    super.key,
    required this.item,
    required this.width,
    required this.onOpen,
    this.onChanged,
  });

  final LocalMediaItem item;
  final double width;
  final Future<void> Function() onOpen;
  final VoidCallback? onChanged;

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    var value = bytes.toDouble();
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    final precision = index == 0
        ? 0
        : value >= 10
        ? 1
        : 2;
    return '${value.toStringAsFixed(precision)} ${units[index]}';
  }

  @override
  State<LocalMediaCardListItemWidget> createState() =>
      _LocalMediaCardListItemWidgetState();
}

class _LocalMediaCardListItemWidgetState
    extends State<LocalMediaCardListItemWidget> {
  DownloadTask? _task;
  LocalMediaItem? _derivedItem;
  bool _derivationRequested = false;

  LocalMediaItem get _item => _derivedItem ?? widget.item;

  VideoDownloadExtData? get _downloadData {
    final ext = _task?.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.video) return null;
    try {
      return VideoDownloadExtData.fromJson(ext.data);
    } catch (_) {
      return null;
    }
  }

  String get _title {
    final title = _downloadData?.title?.trim();
    return title == null || title.isEmpty ? widget.item.name : title;
  }

  String? get _author {
    final author = _downloadData?.authorName?.trim();
    return author == null || author.isEmpty ? null : author;
  }

  String? get _remoteCover {
    final cover = _downloadData?.thumbnail?.trim();
    return cover == null || cover.isEmpty ? null : cover;
  }

  String? _getCategoryName(String? categoryId) {
    if (categoryId == null || categoryId == kLocalMediaUncategorized) {
      return null;
    }
    if (!Get.isRegistered<DownloadService>()) {
      return null;
    }
    for (final cat in DownloadService.to.categories) {
      if (cat.id == categoryId) {
        return cat.title;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadDownloadTask();
  }

  @override
  void didUpdateWidget(covariant LocalMediaCardListItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.downloadTaskId != widget.item.downloadTaskId) {
      _task = null;
      _derivedItem = null;
      _derivationRequested = false;
      _loadDownloadTask();
    }
  }

  /// 卡片进入视野时把这一条缺的派生数据补上：封面（sidecar 与缓存缩略图都没有时
  /// 抓一帧）以及时长 / 宽高。
  ///
  /// ⛔ **不能只在"没有封面"时才问**：有 sidecar 的条目照样可能缺时长和分辨率
  /// （扫描器只写文件名、大小、mtime），只看封面的话那两枚角标永远要等下一次
  /// 自然刷新才出得来。
  Future<void> _ensureDerived() async {
    final item = widget.item;
    if (item.missing || !Get.isRegistered<LocalMediaDerivationService>()) {
      return;
    }
    final hasCover =
        await _fileExists(item.sidecarImagePath) ||
        await _fileExists(item.thumbPath);
    final needsMetadata =
        item.durationMs == null || item.width == null || item.height == null;
    // 封面有了、元数据也齐了，这张卡没有要补的——省掉一次派生队列的往返。
    if (hasCover && !needsMetadata) return;

    final updated = await LocalMediaDerivationService.to.ensureDerived(
      item,
      // 到底抓不抓帧由服务按**最新的库状态**判（它会重查 sidecar / 缩略图还在不在），
      // 这里只表达"允许抓"，不在调用点复制一份同样的判断。
      generateThumbnail: true,
    );
    if (!mounted || updated == null || updated.id != widget.item.id) return;
    // 派生结果是行内变化，就地 setState 重绘即可。
    // ⛔ 绝不能顺手喊 widget.onChanged：它会走 _refreshActiveLocalRepository()
    // → refresh(true)，在用户滚动时清空整面墙并把人弹回顶部。onChanged 只留给
    // 操作菜单那种**真的改了列表结构**的场合（改分类、删除）。
    setState(() => _derivedItem = updated);
  }

  static Future<bool> _fileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;
    try {
      return await File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadDownloadTask() async {
    final taskId = widget.item.downloadTaskId;
    if (taskId == null || taskId.isEmpty) return;
    if (!Get.isRegistered<DownloadService>()) return;
    final task = await DownloadService.to.repository.getTaskById(taskId);
    if (!mounted || task == null) return;
    setState(() => _task = task);
  }

  Future<void> _openPreview() async {
    final item = _item;
    final categoryName = _getCategoryName(item.categoryId);
    await showGlassAlertDialog<void>(
      title: _title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Cover(
            item: item,
            remoteCover: _remoteCover,
            borderRadius: BorderRadius.circular(14),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: <Widget>[
              if (item.durationMs != null)
                _MetaChip(
                  icon: Icons.schedule_outlined,
                  label: _formatDuration(item.durationMs!),
                ),
              if (item.sizeBytes != null)
                _MetaChip(
                  icon: Icons.storage_outlined,
                  label: _formatBytes(item.sizeBytes!),
                ),
              if (item.width != null && item.height != null)
                _MetaChip(
                  icon: Icons.aspect_ratio_outlined,
                  label: '${item.width}x${item.height}',
                ),
              if (categoryName != null)
                _MetaChip(icon: Icons.folder_outlined, label: categoryName),
              if (_author != null)
                _MetaChip(icon: Icons.person_outline, label: _author!),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.path,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final author = _author;
    final item = _item;
    final categoryName = _getCategoryName(item.categoryId);

    return SizedBox(
      width: widget.width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: () => widget.onOpen(),
          onLongPress: _openPreview,
          borderRadius: radius,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  VisibilityDetector(
                    key: ValueKey<String>('local-media-cover-${item.id}'),
                    onVisibilityChanged: (info) {
                      if (info.visibleFraction <= 0 || _derivationRequested) {
                        return;
                      }
                      _derivationRequested = true;
                      unawaited(_ensureDerived());
                    },
                    child: _Cover(item: item, remoteCover: _remoteCover),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 36,
                          child: Text(
                            _title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: <Widget>[
                            if (item.durationMs != null)
                              _MetaChip(
                                icon: Icons.schedule_outlined,
                                label: _formatDuration(item.durationMs!),
                              ),
                            if (item.sizeBytes != null)
                              _MetaChip(
                                icon: Icons.storage_outlined,
                                label: _formatBytes(item.sizeBytes!),
                              ),
                            if (item.width != null && item.height != null)
                              _MetaChip(
                                icon: Icons.aspect_ratio_outlined,
                                label: '${item.width}x${item.height}',
                              ),
                            if (categoryName != null)
                              _MetaChip(
                                icon: Icons.folder_outlined,
                                label: categoryName,
                              ),
                          ],
                        ),
                        if (author != null) ...[
                          const SizedBox(height: 7),
                          Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: LocalMediaActionMenuButton(
                  item: item,
                  onPreview: _openPreview,
                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(int milliseconds) {
    return CommonUtils.formatDuration(
      Duration(milliseconds: milliseconds.clamp(0, 864000000)),
    );
  }

  static String _formatBytes(int bytes) =>
      LocalMediaCardListItemWidget.formatBytes(bytes);
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.item,
    this.remoteCover,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(14)),
  });

  final LocalMediaItem item;
  final String? remoteCover;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sidecar = item.sidecarImagePath;
    final thumbnail = item.thumbPath;
    Widget child;
    if (sidecar != null && sidecar.isNotEmpty) {
      child = Image.file(
        File(sidecar),
        fit: BoxFit.cover,
        cacheWidth: 640,
        errorBuilder: (_, _, _) => thumbnail != null && thumbnail.isNotEmpty
            ? Image.file(
                File(thumbnail),
                fit: BoxFit.cover,
                cacheWidth: 640,
                errorBuilder: (_, _, _) => _remoteOrPlaceholder(scheme),
              )
            : _remoteOrPlaceholder(scheme),
      );
    } else if (thumbnail != null && thumbnail.isNotEmpty) {
      child = Image.file(
        File(thumbnail),
        fit: BoxFit.cover,
        cacheWidth: 640,
        errorBuilder: (_, _, _) => _remoteOrPlaceholder(scheme),
      );
    } else if (remoteCover != null) {
      child = CachedNetworkImage(
        imageUrl: remoteCover!,
        fit: BoxFit.cover,
        memCacheWidth: 640,
        errorWidget: (_, _, _) => _placeholder(scheme),
      );
    } else {
      child = _placeholder(scheme);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(aspectRatio: 16 / 9, child: child),
    );
  }

  Widget _remoteOrPlaceholder(ColorScheme scheme) {
    if (remoteCover != null) {
      return CachedNetworkImage(
        imageUrl: remoteCover!,
        fit: BoxFit.cover,
        memCacheWidth: 640,
        errorWidget: (_, _, _) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) => ColoredBox(
    color: scheme.surfaceContainerHighest,
    child: Center(
      child: Icon(Icons.movie_outlined, color: scheme.onSurfaceVariant),
    ),
  );
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
