import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_tile.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class GalleryDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const GalleryDownloadTaskItem({super.key, required this.task});

  GalleryDownloadExtData? get galleryData {
    try {
      if (task.extData?.type == DownloadTaskExtDataType.gallery) {
        return GalleryDownloadExtData.fromJson(task.extData!.data);
      }
    } catch (e) {
      LogUtils.e('解析图库下载任务数据失败', tag: 'GalleryDownloadTaskItem', error: e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final extData = galleryData;
    if (extData == null) return const SizedBox.shrink();

    return DownloadTaskTile(
      task: task,
      title: extData.title ?? t.download.errors.unknown,
      // 图库与视频长得一样时，靠标题前这枚图标与封面上的张数分家。
      titleIcon: Icons.photo_library_outlined,
      author: DownloadTileAuthor(
        name: extData.authorName ?? t.download.errors.unknown,
        onTap: extData.authorUsername == null
            ? null
            : () => NaviService.navigateToAuthorProfilePage(
                extData.authorUsername!,
              ),
      ),
      cover: extData.previewUrls.isEmpty
          ? const Center(child: Icon(Icons.image_not_supported, size: 32))
          : CachedNetworkImage(
              // ⛔ 过一道 [iwaraPosterUrlFrom]：这张地址是**下载任务建起来那天**
              // 存进 ext_data 的，视频那几条指向原文件（webm），拿去当封面画不出来。
              // 那些数据库行不会因为代码改了就自己重写，只能在渲染这一侧改写。
              imageUrl: iwaraPosterUrlFrom(extData.previewUrls[0]),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
      coverBadges: [
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_outlined,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${extData.totalImages}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      progressUnit: DownloadProgressUnit.images,
      onTap: task.status == DownloadStatus.completed
          ? () => _onTap(context)
          : null,
    );
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      NaviService.navigateToGalleryDownloadTaskDetailPage(task.id);
    }
  }
}
