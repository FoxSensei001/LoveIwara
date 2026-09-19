import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_relocation_flow.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_actions.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_task_tile.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path/path.dart' as path;
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

class VideoDownloadTaskItem extends StatelessWidget {
  final DownloadTask task;

  const VideoDownloadTaskItem({
    super.key,
    required this.task,
    this.queueCategoryFilter = 'all',
    this.queueCategoryTitle,
  });

  /// 列表页当前的分类筛选（`'all'` / `'uncategorized'` / 分类 id）。**分类是
  /// 下载池身份的一部分**，所以点进播放器时要原样带过去——用户在「音乐」分类
  /// 里点开一条，接下来续播的当然也该是「音乐」那一批。
  final String queueCategoryFilter;

  /// 上面那个筛选的显示名，用于「接着看」胶囊上写清是哪一批（'all' 为 null）。
  final String? queueCategoryTitle;

  /// 卡片自己才会做的两件事：本地播放要带上列表页的分类池，进在线详情页
  /// 也要把下载池交过去。其余动作走 [runDownloadAction] 的通用实现。
  DownloadTaskActionHandlers _actionHandlers(BuildContext context) {
    final videoId = VideoDownloadExtData.fromJson(task.extData!.data).id;
    return DownloadTaskActionHandlers(
      onOpen: () => _playLocalVideo(context),
      onViewOnline: videoId == null ? null : () => _openVideoDetail(videoId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoData = VideoDownloadExtData.fromJson(task.extData!.data);

    return DownloadTaskTile(
      task: task,
      title: videoData.title ?? task.fileName,
      author: videoData.authorName == null
          ? null
          : DownloadTileAuthor(
              name: videoData.authorName!,
              onTap: videoData.authorUsername == null
                  ? null
                  : () => _navigateToAuthorProfile(videoData),
            ),
      cover: videoData.thumbnail == null
          ? const Center(child: Icon(Icons.video_library, size: 32))
          : CachedNetworkImage(
              imageUrl: videoData.thumbnail!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
      // 只留时长：清晰度是同一部片子不同下载之间的区别，收在详情里。
      coverBadges: [
        if (videoData.duration != null)
          Positioned(
            right: 6,
            bottom: 6,
            child: _CoverBadge(_formatDuration(videoData.duration!)),
          ),
      ],
      completedMeta: formatDownloadBytes(task.downloadedBytes),
      onTap: () => _onTap(context),
      handlers: _actionHandlers(context),
    );
  }

  void _navigateToAuthorProfile(VideoDownloadExtData videoData) {
    if (videoData.authorUsername != null) {
      NaviService.navigateToAuthorProfilePage(videoData.authorUsername!);
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds - minutes * 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 本地播放视频
  Future<void> _playLocalVideo(BuildContext context) async {
    final t = slang.Translations.of(context);
    try {
      final filePath = path.normalize(task.savePath);
      LogUtils.d('本地播放: $filePath', 'DownloadTaskItem');

      final file = File(filePath);
      if (!await file.exists()) {
        // 找不到不等于删掉了：让用户去别处找回，或自己确认删记录。
        if (context.mounted) await showMissingDownloadDialog(task);
        return;
      }

      // 获取同一视频的所有已下载清晰度任务
      final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
      List<DownloadTask> allQualityTasks = [];

      if (videoData.id != null) {
        final downloadService = Get.find<DownloadService>();
        allQualityTasks = await downloadService.repository.getVideoTasksByMedia(
          videoData.id!,
        );
        // 只保留已完成的任务
        allQualityTasks = allQualityTasks
            .where((t) => t.status == DownloadStatus.completed)
            .toList();
      }

      // 导航到本地视频播放页面。**把下载池一起交出去**：这样播放器里的
      // 「接着看」一开就落在「已下载」上，而且下一条同样用本地文件播
      // （见 DownloadsPlaybackQueue）。
      //
      // `localLibraryItemId` 也要给：同一个文件从「本机文件 › 下载完成视频」
      // 点开时进度记在 `local_media_progress` 里，从这儿点开却记在别处、还读
      // 不回来——详见 [LocalMediaRepository.getItemByDownloadTaskId] 的注释。
      // 查不到（同步还没跑到）就还是 null，行为与从前一字不差。
      NaviService.navigateToLocalVideoPlayerPage(
        localPath: filePath,
        task: task,
        allQualityTasks: allQualityTasks,
        localLibraryItemId: _resolveLocalLibraryItemId(),
        playbackQueueRef: await _openDownloadsQueueRef(videoData.id),
      );
    } catch (e) {
      LogUtils.e('本地播放失败', tag: 'DownloadTaskItem', error: e);
      if (context.mounted) {
        showAppToast(
          t.download.errors.playLocallyFailedWithMessage(message: e.toString()),
          type: AppToastType.error,
        );
      }
    }
  }

  void _onTap(BuildContext context) {
    if (task.status == DownloadStatus.completed) {
      _playLocalVideo(context);
    } else {
      // 如果是视频类型且有视频ID，可以跳转到视频详情页
      final videoData = VideoDownloadExtData.fromJson(task.extData!.data);
      if (videoData.id != null) {
        _openVideoDetail(videoData.id!);
      }
    }
  }

  /// 从下载列表进在线详情页，顺手把下载池交出去——「接着看」一开就落在
  /// 「已下载」上（用户要的"从哪进来就定位到哪"）。
  Future<void> _openVideoDetail(String videoId) async {
    NaviService.navigateToVideoDetailPage(
      videoId,
      playbackQueueRef: await _openDownloadsQueueRef(videoId),
    );
  }

  /// 建/取下载池，并给出指向 [mediaId] 的引用。
  ///
  /// 第一页先拉起来：池空着交过去的话，详情页那枚「下一个」会因为
  /// `loaded` 为空而缺席一小会儿。[mediaId] 为空（历史脏数据）就不给池——
  /// 池的游标就是 id，没有 id 定位不了自己。
  /// 这条下载任务在本地库里的 id，拿它当进度钥匙（见
  /// [LocalMediaRepository.getItemByDownloadTaskId]）。
  ///
  /// 读库失败不该拦住播放：吞掉异常、答 null，无非是这一次不续播。
  String? _resolveLocalLibraryItemId() {
    try {
      return LocalMediaRepository().getItemByDownloadTaskId(task.id)?.id;
    } catch (e) {
      LogUtils.w('查本地库条目失败: $e', 'DownloadTaskItem');
      return null;
    }
  }

  Future<PlaybackQueueRef?> _openDownloadsQueueRef(String? mediaId) async {
    final id = mediaId?.trim();
    if (id == null || id.isEmpty) return null;
    final queue = PlaybackQueueService.to.openDownloads(
      categoryFilter: queueCategoryFilter,
      title: queueCategoryTitle,
    );
    if (queue.loaded.isEmpty) {
      await queue.loadMore();
    }
    return PlaybackQueueRef(queueId: queue.queueId, currentItemId: id);
  }
}

/// 封面右下角的时长胶囊。
class _CoverBadge extends StatelessWidget {
  const _CoverBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
