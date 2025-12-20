import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量下载失败原因
enum BatchDownloadFailureReason {
  privateVideo, // 私人视频
  alreadyExists, // 已存在相同任务
  noSource, // 无可用下载源
  noSavePath, // 无法获取保存路径
  other, // 其他错误
}

/// 批量下载失败记录
class BatchDownloadFailure {
  final String videoId;
  final String title;
  final BatchDownloadFailureReason reason;
  final String? message;

  BatchDownloadFailure({
    required this.videoId,
    required this.title,
    required this.reason,
    this.message,
  });
}

/// 批量下载结果
class BatchDownloadResult {
  final int total;
  final int success;
  final int failed;
  final int skipped;
  final List<BatchDownloadFailure> failures;

  BatchDownloadResult({
    required this.total,
    required this.success,
    required this.failed,
    required this.skipped,
    required this.failures,
  });
}

/// 私人视频异常
class PrivateVideoException implements Exception {
  final String message;
  PrivateVideoException([this.message = 'Private video']);
  @override
  String toString() => message;
}

/// 重复任务异常
class DuplicateTaskException implements Exception {
  final String message;
  DuplicateTaskException([this.message = 'Duplicate task']);
  @override
  String toString() => message;
}

/// 批量下载服务
class BatchDownloadService extends GetxService {
  static BatchDownloadService get to => Get.find<BatchDownloadService>();

  final VideoService _videoService = Get.find<VideoService>();
  final GalleryService _galleryService = Get.find<GalleryService>();
  final DownloadService _downloadService = Get.find<DownloadService>();
  final DownloadPathService _downloadPathService =
      Get.find<DownloadPathService>();
  final ApiService _apiService = Get.find<ApiService>();

  // 批量下载进度状态
  final RxInt totalCount = 0.obs;
  final RxInt processedCount = 0.obs;
  final RxInt successCount = 0.obs;
  final RxInt failedCount = 0.obs;
  final RxInt skippedCount = 0.obs;
  final RxBool isProcessing = false.obs;
  final RxString currentProcessingTitle = ''.obs;

  // 失败列表
  final RxList<BatchDownloadFailure> failures = <BatchDownloadFailure>[].obs;

  // 取消令牌
  CancelToken? _cancelToken;

  /// 批量下载视频入口
  /// [videos] 要下载的视频列表
  /// [quality] 目标清晰度
  /// [onProgress] 进度回调
  /// [onComplete] 完成回调
  Future<BatchDownloadResult> batchDownloadVideos({
    required List<Video> videos,
    required String quality,
    Function(int current, int total, String title)? onProgress,
    Function(BatchDownloadResult result)? onComplete,
  }) async {
    if (isProcessing.value) {
      throw Exception(
        slang.t.download.batchDownload.downloadTaskAlreadyRunning,
      );
    }

    _cancelToken = CancelToken();
    isProcessing.value = true;
    totalCount.value = videos.length;
    processedCount.value = 0;
    successCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;
    failures.clear();

    try {
      for (int i = 0; i < videos.length; i++) {
        // 检查是否取消
        if (_cancelToken?.isCancelled ?? false) {
          LogUtils.i('批量下载已取消', 'BatchDownloadService');
          break;
        }

        final video = videos[i];
        currentProcessingTitle.value = video.title ?? '';
        onProgress?.call(
          processedCount.value,
          videos.length,
          video.title ?? '',
        );

        try {
          await _downloadSingleVideo(video, quality);
          successCount.value++;
        } on PrivateVideoException {
          skippedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: video.id,
              title: video.title ?? '',
              reason: BatchDownloadFailureReason.privateVideo,
            ),
          );
        } on DuplicateTaskException {
          skippedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: video.id,
              title: video.title ?? '',
              reason: BatchDownloadFailureReason.alreadyExists,
            ),
          );
        } catch (e) {
          failedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: video.id,
              title: video.title ?? '',
              reason: BatchDownloadFailureReason.other,
              message: e.toString(),
            ),
          );
          LogUtils.e(
            '批量下载单个视频失败: ${video.id}',
            tag: 'BatchDownloadService',
            error: e,
          );
        }

        // 更新已完成数量（成功 + 失败 + 跳过）
        processedCount.value =
            successCount.value + failedCount.value + skippedCount.value;
      }

      final result = BatchDownloadResult(
        total: totalCount.value,
        success: successCount.value,
        failed: failedCount.value,
        skipped: skippedCount.value,
        failures: List.from(failures),
      );

      onComplete?.call(result);
      return result;
    } finally {
      isProcessing.value = false;
      currentProcessingTitle.value = '';
      _cancelToken = null;
    }
  }

  /// 取消批量下载
  void cancelBatchDownload() {
    _cancelToken?.cancel(slang.t.download.batchDownload.userCancelled);
  }

  /// 下载单个视频
  Future<void> _downloadSingleVideo(Video video, String quality) async {
    // 1. 获取视频详情（检查是否私人视频）
    Video? videoInfo;
    try {
      final response = await _apiService.get(
        '/video/${video.id}',
        cancelToken: _cancelToken,
      );
      videoInfo = Video.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data != null && data['message'] == 'errors.privateVideo') {
          throw PrivateVideoException();
        }
      }
      rethrow;
    }

    if (videoInfo.fileUrl == null) {
      throw Exception(slang.t.download.batchDownload.failedToGetVideoInfo);
    }

    // 2. 检查重复任务（视频：检查持久化数据库，使用 id + 清晰度）
    final duplicateCheck = await _downloadService.checkVideoTaskDuplicate(
      video.id,
      quality,
    );

    if (duplicateCheck.hasSameVideoSameQuality) {
      throw DuplicateTaskException();
    }

    // 3. 获取视频源
    final sources = await _videoService.getVideoSourcesBy(videoInfo.fileUrl);
    if (sources.isEmpty) {
      throw Exception(slang.t.download.batchDownload.failedToGetVideoSource);
    }

    // 4. 查找目标清晰度，如果不存在则选择最佳可用清晰度
    VideoSource? targetSource = sources.firstWhereOrNull(
      (s) => s.name?.toLowerCase() == quality.toLowerCase(),
    );
    targetSource ??= _selectBestAvailableQuality(sources, quality);

    if (targetSource == null || targetSource.download == null) {
      throw Exception(slang.t.download.batchDownload.reasonNoSource);
    }

    // 5. 获取保存路径（批量下载专用，不弹对话框）
    final savePath = await _downloadPathService.getVideoDownloadPathForBatch(
      video: videoInfo,
      quality: targetSource.name ?? quality,
      downloadUrl: targetSource.download!,
    );

    if (savePath == null) {
      failures.add(
        BatchDownloadFailure(
          videoId: video.id,
          title: video.title ?? '',
          reason: BatchDownloadFailureReason.noSavePath,
        ),
      );
      skippedCount.value++;
      return;
    }

    // 6. 创建下载任务
    final videoExtData = VideoDownloadExtData(
      id: videoInfo.id,
      title: videoInfo.title,
      thumbnail: videoInfo.thumbnailUrl,
      authorName: videoInfo.user?.name,
      authorUsername: videoInfo.user?.username,
      authorAvatar: videoInfo.user?.avatar?.avatarUrl,
      duration: videoInfo.file?.duration,
      quality: targetSource.name,
    );

    final task = DownloadTask(
      url: targetSource.download!,
      savePath: savePath,
      fileName: '${videoInfo.title ?? 'video'}_${targetSource.name}.mp4',
      supportsRange: true,
      extData: DownloadTaskExtData(
        type: DownloadTaskExtDataType.video,
        data: videoExtData.toJson(),
      ),
      mediaType: 'video',
      mediaId: videoInfo.id,
      quality: targetSource.name,
    );

    await _downloadService.addTask(task);
    LogUtils.d('批量下载：添加任务成功 - ${videoInfo.title}', 'BatchDownloadService');
  }

  /// 选择最佳可用清晰度
  VideoSource? _selectBestAvailableQuality(
    List<VideoSource> sources,
    String preferredQuality,
  ) {
    // 清晰度优先级列表
    final priorityList = ['source', '1080', '720', '540', '360'];

    // 找到首选清晰度在优先级列表中的位置
    final preferredIndex = priorityList.indexWhere(
      (q) => q.toLowerCase() == preferredQuality.toLowerCase(),
    );

    if (preferredIndex != -1) {
      // 从首选清晰度开始，依次降级查找
      for (int i = preferredIndex; i < priorityList.length; i++) {
        final source = sources.firstWhereOrNull(
          (s) => s.name?.toLowerCase() == priorityList[i].toLowerCase(),
        );
        if (source != null && source.download != null) {
          return source;
        }
      }
    }

    // 如果没找到，尝试从最高清晰度开始查找
    for (final q in priorityList) {
      final source = sources.firstWhereOrNull(
        (s) => s.name?.toLowerCase() == q.toLowerCase(),
      );
      if (source != null && source.download != null) {
        return source;
      }
    }

    // 最后返回第一个有下载链接的源
    return sources.firstWhereOrNull((s) => s.download != null);
  }

  /// 批量下载图库入口
  /// [galleries] 要下载的图库列表
  /// [onProgress] 进度回调
  /// [onComplete] 完成回调
  Future<BatchDownloadResult> batchDownloadGalleries({
    required List<ImageModel> galleries,
    Function(int current, int total, String title)? onProgress,
    Function(BatchDownloadResult result)? onComplete,
  }) async {
    if (isProcessing.value) {
      throw Exception(
        slang.t.download.batchDownload.downloadTaskAlreadyRunning,
      );
    }

    _cancelToken = CancelToken();
    isProcessing.value = true;
    totalCount.value = galleries.length;
    processedCount.value = 0;
    successCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;
    failures.clear();

    try {
      for (int i = 0; i < galleries.length; i++) {
        // 检查是否取消
        if (_cancelToken?.isCancelled ?? false) {
          LogUtils.i('批量下载已取消', 'BatchDownloadService');
          break;
        }

        final gallery = galleries[i];
        currentProcessingTitle.value = gallery.title;
        onProgress?.call(processedCount.value, galleries.length, gallery.title);

        try {
          await _downloadSingleGallery(gallery);
          successCount.value++;
        } on PrivateVideoException {
          skippedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: gallery.id,
              title: gallery.title,
              reason: BatchDownloadFailureReason.privateVideo,
            ),
          );
        } on DuplicateTaskException {
          skippedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: gallery.id,
              title: gallery.title,
              reason: BatchDownloadFailureReason.alreadyExists,
            ),
          );
        } catch (e) {
          failedCount.value++;
          failures.add(
            BatchDownloadFailure(
              videoId: gallery.id,
              title: gallery.title,
              reason: BatchDownloadFailureReason.other,
              message: e.toString(),
            ),
          );
          LogUtils.e(
            '批量下载单个图库失败: ${gallery.id}',
            tag: 'BatchDownloadService',
            error: e,
          );
        }

        // 更新已完成数量（成功 + 失败 + 跳过）
        processedCount.value =
            successCount.value + failedCount.value + skippedCount.value;
      }

      final result = BatchDownloadResult(
        total: totalCount.value,
        success: successCount.value,
        failed: failedCount.value,
        skipped: skippedCount.value,
        failures: List.from(failures),
      );

      onComplete?.call(result);
      return result;
    } finally {
      isProcessing.value = false;
      currentProcessingTitle.value = '';
      _cancelToken = null;
    }
  }

  /// 下载单个图库
  Future<void> _downloadSingleGallery(ImageModel gallery) async {
    // 1. 获取图库详情
    final result = await _galleryService.fetchGalleryDetail(gallery.id);
    if (!result.isSuccess || result.data == null) {
      throw Exception(slang.t.download.batchDownload.failedToGetGalleryInfo);
    }

    final galleryInfo = result.data!;

    // 2. 检查图库是否有图片
    if (galleryInfo.files.isEmpty) {
      throw Exception(slang.t.download.batchDownload.galleryNoImages);
    }

    // 3. 检查重复任务（图库：检查持久化数据库）
    final hasExistingTask = await _downloadService.hasAnyGalleryDownloadTask(
      gallery.id,
    );
    if (hasExistingTask) {
      throw DuplicateTaskException();
    }

    // 4. 获取保存路径
    final savePath = await _downloadPathService.getGalleryDownloadPath(
      gallery: galleryInfo,
    );

    if (savePath == null) {
      throw Exception(slang.t.download.batchDownload.failedToGetSavePath);
    }

    // 4. 准备图片列表和预览图
    final imageList = <String, String>{};
    for (var file in galleryInfo.files) {
      imageList[file.id] = file.getOriginalImageUrl();
    }

    final previewUrls = galleryInfo.files
        .take(3)
        .map((f) => f.getLargeImageUrl())
        .toList();

    // 6. 创建下载任务
    final galleryExtData = GalleryDownloadExtData(
      id: galleryInfo.id,
      title: galleryInfo.title,
      previewUrls: previewUrls,
      authorName: galleryInfo.user?.name,
      authorUsername: galleryInfo.user?.username,
      authorAvatar: galleryInfo.user?.avatar?.avatarUrl,
      totalImages: galleryInfo.files.length,
      imageList: imageList,
      localPaths: {},
    );

    final task = DownloadTask(
      url: galleryInfo.files.first.getOriginalImageUrl(), // 使用第一张图片的原图URL
      downloadedBytes: 0, // 已下载图片数量
      totalBytes: galleryInfo.files.length, // 总图片数量
      savePath: savePath,
      fileName: '${galleryInfo.title}_${galleryInfo.id}',
      extData: DownloadTaskExtData(
        type: DownloadTaskExtDataType.gallery,
        data: galleryExtData.toJson(),
      ),
      mediaType: 'gallery',
      mediaId: galleryInfo.id,
    );

    await _downloadService.addTask(task);
    LogUtils.d('批量下载：添加图库任务成功 - ${galleryInfo.title}', 'BatchDownloadService');
  }

  /// 重置状态
  void reset() {
    totalCount.value = 0;
    processedCount.value = 0;
    successCount.value = 0;
    failedCount.value = 0;
    skippedCount.value = 0;
    isProcessing.value = false;
    currentProcessingTitle.value = '';
    failures.clear();
  }
}
