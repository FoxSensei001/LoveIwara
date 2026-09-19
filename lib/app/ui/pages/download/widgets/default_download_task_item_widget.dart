import 'dart:io';

import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_tile.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:path/path.dart' as path;

class DefaultDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const DefaultDownloadTaskItem({super.key, required this.task});

  IconData _getFileIcon() {
    final extension = path.extension(task.fileName).toLowerCase();

    // 图片文件
    if ([
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
    ].contains(extension)) {
      return Icons.image;
    }
    // 音频文件
    else if (['.mp3', '.wav', '.aac', '.ogg', '.m4a'].contains(extension)) {
      return Icons.audio_file;
    }
    // 视频文件
    else if ([
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
    ].contains(extension)) {
      return Icons.video_file;
    }
    // 压缩文件
    else if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(extension)) {
      return Icons.folder_zip;
    }
    // 文档文件
    else if (['.pdf', '.doc', '.docx', '.txt', '.md'].contains(extension)) {
      return Icons.description;
    }
    // 默认文件图标
    return Icons.file_present;
  }

  bool _isImageFile() {
    if (task.status != DownloadStatus.completed) return false;
    final extension = path.extension(task.fileName).toLowerCase();
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
    ].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final scale = DownloadUiScale.of(context);
    final cs = Theme.of(context).colorScheme;
    final extension = path.extension(task.fileName);
    final icon = Center(
      child: Icon(_getFileIcon(), size: 30 * scale, color: cs.onSurfaceVariant),
    );
    final isImage = _isImageFile();
    return DownloadTaskTile(
      task: task,
      // 扩展名挪到封面角上，标题只留名字。
      title: extension.isEmpty
          ? task.fileName
          : path.basenameWithoutExtension(task.fileName),
      cover: isImage
          ? LayoutBuilder(
              builder: (context, constraints) => Image.file(
                File(task.savePath),
                fit: BoxFit.cover,
                // ⛔ 必须限制解码尺寸：Image.file 默认按**原图分辨率**解码。i 站
                // 图库里 4000×6000 的 PNG 一张就是 ~96MB 位图，列表里几条下载完的
                // 图片任务就能把原生堆撑爆，表现为「下载完之后应用直接没了」——
                // Dart 侧什么都抓不到，因为是被系统杀的。
                cacheWidth:
                    (constraints.maxWidth *
                            MediaQuery.devicePixelRatioOf(context))
                        .round()
                        .clamp(1, 1024),
                errorBuilder: (context, error, stackTrace) => icon,
              ),
            )
          : icon,
      coverBadges: [
        if (extension.length > 1)
          Positioned(
            right: 6,
            bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  extension.substring(1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
      completedMeta: formatDownloadBytes(task.downloadedBytes),
      onTap: task.status == DownloadStatus.completed
          ? () => _onTap(context)
          : null,
    );
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      openDownloadedFile(task);
    }
  }
}
