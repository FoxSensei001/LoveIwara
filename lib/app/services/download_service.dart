import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart' as path_lib;
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class DownloadService extends GetxService {
  static DownloadService get to => Get.find<DownloadService>();

  // 活跃任务列表，只包含等待中和下载中的任务
  final _activeTasks = <String, DownloadTask>{}.obs;
  final _activeDownloads = <String, CancelToken>{};
  final _downloadQueue = <String>[].obs;

  // 添加任务专用的计时器映射
  final _taskTimers = <String, Timer>{};

  // 添加图库下载相关的字段
  final _galleryDownloadProgress = <String, Map<String, bool>>{}.obs;

  // 用于通知任务状态变更的 RxInt
  final _taskStatusChangedNotifier = 0.obs;

  // 获取所有活跃任务（仅包含等待中和下载中的任务）
  Map<String, DownloadTask> get tasks => _activeTasks;

  // 获取任务状态变更通知器 [仅在任务状态变更时，进行通知，用于刷新UI列表数据]
  RxInt get taskStatusChangedNotifier => _taskStatusChangedNotifier;

  final _repository = DownloadTaskRepository();

  static const maxConcurrentDownloads = 3;
  final dio = Dio();

  DownloadTaskRepository get repository => _repository;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadActiveTasks();
  }

  /// 加载活跃任务（仅加载下载中的任务）
  Future<void> _loadActiveTasks() async {
    try {
      // 只加载下载中的任务，将其重置为等待状态
      final downloadingTasks = await _repository.getTasksByStatus(DownloadStatus.downloading);
      
      for (var task in downloadingTasks) {
        task.status = DownloadStatus.pending;
        _activeTasks[task.id] = task;
        _downloadQueue.add(task.id);
      }

      LogUtils.i(
          '已加载 ${downloadingTasks.length} 个下载中任务',
          'DownloadService');

      _processQueue();
    } catch (e) {
      LogUtils.e('加载下载任务失败', error: e);
    }
  }

  // 获取内存中的活跃任务
  DownloadTask? getActiveTaskById(String taskId) {
    return _activeTasks[taskId];
  }

  // 从数据库获取任务
  Future<DownloadTask?> getTaskById(String taskId) async {
    // 先检查内存中是否存在
    final activeTask = _activeTasks[taskId];
    if (activeTask != null) {
      return activeTask;
    }
    // 否则从数据库加载
    return await _repository.getTaskById(taskId);
  }

  // 重试下载图库中失败的图片
  Future<void> retryGalleryImageDownload(String taskId, String imageId) async {
    final task = _activeTasks[taskId];
    if (task == null || task.extData?.type != DownloadTaskExtDataType.gallery) {
      return;
    }

    final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);
    final imageInfo =
        galleryData.imageList.firstWhere((img) => img['id'] == imageId);

    // 更新状态为未下载
    _galleryDownloadProgress[taskId]?[imageId] = false;

    // 开始下载这个图片
    await _downloadGalleryImage(
      task,
      imageInfo['url']!,
      imageId,
      galleryData.imageList.length,
    );
  }

  // 下载单张图片
  Future<bool> _downloadGalleryImage(
    DownloadTask task,
    String url,
    String imageId,
    int totalImages,
  ) async {
    final fileName = '$imageId${path_lib.extension(url)}';
    final savePath = path_lib.normalize(path_lib.join(task.savePath, fileName));

    try {
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);

      // 更新进度
      _galleryDownloadProgress[task.id]?[imageId] = true;

      // 计算总进度
      final downloadedCount = _galleryDownloadProgress[task.id]
              ?.values
              .where((downloaded) => downloaded)
              .length ??
          0;

      // 更新任务进度
      task.downloadedBytes = downloadedCount;
      task.totalBytes = totalImages;

      // 更新GalleryDownloadExtData中的localPaths
      if (task.extData?.type == DownloadTaskExtDataType.gallery) {
        final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);
        final updatedData = GalleryDownloadExtData(
          id: galleryData.id,
          title: galleryData.title,
          previewUrls: galleryData.previewUrls,
          authorName: galleryData.authorName,
          authorUsername: galleryData.authorUsername,
          authorAvatar: galleryData.authorAvatar,
          totalImages: galleryData.totalImages,
          imageList: galleryData.imageList,
          localPaths: {
            ...galleryData.localPaths,
            imageId: savePath,
          },
        );
        task.extData = DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: updatedData.toJson(),
        );
      }

      await _repository.updateTask(task);

      return true;
    } catch (e) {
      LogUtils.e('下载图片失败: $url', tag: 'DownloadService', error: e);
      _galleryDownloadProgress[task.id]?[imageId] = false;
      return false;
    }
  }

  // 添加新任务
  Future<void> addTask(DownloadTask task) async {
    // 格式化task的下载路径
    task.savePath = CommonUtils.formatSavePathUriByPath(task.savePath);
    try {
      // 先从数据库中查询任务是否存在
      DownloadTask? existingTask = await _repository.getTaskById(task.id);
      
      if (existingTask != null) {
        // 如果任务已存在且已完成，直接拒绝并提示用户
        if (existingTask.status == DownloadStatus.completed) {
          _showError(slang.t.download.errors.taskAlreadyCompletedDoNotAdd);
          return;
        }

        // 如果任务已存在且为暂停或失败状态，则更新状态为等待中
        if (existingTask.status == DownloadStatus.paused ||
            existingTask.status == DownloadStatus.failed) {
          // 如果是视频任务，需要验证链接有效性
          if (existingTask.extData?.type == DownloadTaskExtDataType.video) {
            VideoDownloadExtData videoExtData =
                VideoDownloadExtData.fromJson(existingTask.extData!.data);
            final videoLink = task.url;
            final expireTime = CommonUtils.getVideoLinkExpireTime(videoLink);
            if (expireTime != null) {
              if (DateTime.now()
                  .isAfter(expireTime.subtract(const Duration(minutes: 1)))) {
                showToastWidget(MDToastWidget(
                    message: slang.t.download.errors.linkExpiredTryAgain,
                    type: MDToastType.error));
                String? newVideoDownloadUrl = await VideoService.to
                    .getVideoDownloadUrlByIdAndQuality(
                        videoExtData.id ?? '', videoExtData.quality!);
                if (newVideoDownloadUrl != null) {
                  existingTask.url = newVideoDownloadUrl;
                  existingTask.status = DownloadStatus.pending;
                  await _repository.updateTask(existingTask);
                  task = existingTask;
                  showToastWidget(MDToastWidget(
                      message: slang.t.download.errors.linkExpiredTryAgainSuccess,
                      type: MDToastType.success));
                } else {
                  showToastWidget(MDToastWidget(
                      message: slang.t.download.errors.linkExpiredTryAgainFailed,
                      type: MDToastType.error));
                  return;
                }
              } else {
                existingTask.status = DownloadStatus.pending;
                await _repository.updateTask(existingTask);
                task = existingTask;
              }
            }
          } else {
            existingTask.status = DownloadStatus.pending;
            await _repository.updateTask(existingTask);
            task = existingTask;
          }
        }
      } else {
        // 如果数据库任务不存在，则插入数据库
        task.status = DownloadStatus.pending;
        await _repository.insertTask(task);
      }

      // 添加到活跃任务列表和下载队列
      _activeTasks[task.id] = task;
      _downloadQueue.add(task.id);

      LogUtils.i('添加下载任务: ${task.fileName}', 'DownloadService');
      _processQueue();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'DownloadService', error: e);
      _showError(slang.t.download.errors
          .downloadFailedForMessage(errorInfo: _getErrorMessage(e)));
      rethrow;
    }
  }

  // 暂停任务
  Future<void> pauseTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) return;

    if (task.status == DownloadStatus.downloading) {
      LogUtils.i('暂停下载任务: ${task.fileName}', 'DownloadService');
      _activeDownloads[taskId]?.cancel(slang.t.download.errors.userPausedDownload);
      _activeDownloads.remove(taskId);

      task.status = DownloadStatus.paused;
      await _repository.updateTask(task);
      
      // 从内存中移除
      _activeTasks.remove(taskId);
      _downloadQueue.remove(taskId);

      // 通知任务状态变更
      _taskStatusChangedNotifier.value++;

      // 处理等待队列中的下一个任务
      _processQueue();
    }
  }

  // 恢复任务
  Future<void> resumeTask(String taskId) async {
    // 从数据库加载任务
    final task = await _repository.getTaskById(taskId);
    if (task == null) return;

    if (task.status == DownloadStatus.paused || task.status == DownloadStatus.failed) {
      task.status = DownloadStatus.pending;
      await _repository.updateTask(task);
      
      // 添加到内存中的活跃任务
      _activeTasks[taskId] = task;
      _downloadQueue.add(taskId);

      // 通知任务状态变更
      _taskStatusChangedNotifier.value++;

      _processQueue();
    }
  }

  // 删除任务，并更新持久化信息
  Future<void> deleteTask(String taskId) async {
    LogUtils.i('开始删除下载任务: $taskId', 'DownloadService');
    DownloadTask? activeTask = _activeTasks[taskId];
    if (activeTask != null) {
      // 如果正在下载,先取消下载
      if (activeTask.status == DownloadStatus.downloading) {
        await pauseTask(taskId);
      }

      // 删除已下载的文件
      try {
        final file = File(activeTask.savePath);
        if (await file.exists()) {
          await file.delete();
          LogUtils.d('已删除文件: ${activeTask.savePath}', 'DownloadService');
        }
      } catch (e) {
        LogUtils.e('删除文件失败: ${activeTask.savePath}',
            tag: 'DownloadService', error: e);
      }
    } else {
      // 活跃任务不存在，则判断持久化任务是否存在
      DownloadTask? taskFromRepo = await _repository.getTaskById(taskId);
      if (taskFromRepo != null) {
        // 清理文件
        try {
          final file = File(taskFromRepo.savePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          LogUtils.e('删除文件失败: ${taskFromRepo.savePath}',
              tag: 'DownloadService', error: e);
        }
      }
    }

    // 从数据库中删除任务记录
    await _repository.deleteTask(taskId);

    // 从内存中移除任务
    _activeTasks.remove(taskId);
    _downloadQueue.remove(taskId);

    // cancel
    _activeDownloads[taskId]?.cancel(slang.t.download.errors.taskDeleted);
    _activeDownloads.remove(taskId);
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);
  }

  // 处理下载队列
  void _processQueue() async {
    // 检查当前活动下载数量是否达到上限
    if (_activeDownloads.length >= maxConcurrentDownloads) {
      return;
    }

    // 检查下载队列是否为空
    if (_downloadQueue.isEmpty) {
      return;
    }

    final taskId = _downloadQueue.first;
    final task = _activeTasks[taskId];

    if (task == null || task.status != DownloadStatus.pending) {
      _downloadQueue.removeAt(0);
      _processQueue(); // 继续处理队列中的下一个任务
      return;
    }

    _downloadQueue.removeAt(0);

    // 记录开始下载的时间
    LogUtils.i(
        '开始下载任务: ${task.fileName} (当前活动下载数: ${_activeDownloads.length + 1}/$maxConcurrentDownloads)',
        'DownloadService');

    await _startDownload(task);
  }

  Future<void> _startDownload(DownloadTask task) async {
    // 如果是图库下载
    if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      await _startGalleryDownload(task);
      return;
    }

    // 原有的下载逻辑保持不变
    final cancelToken = CancelToken();
    _activeDownloads[task.id] = cancelToken;

    RandomAccessFile? raf;
    StreamSubscription? subscription;

    try {
      LogUtils.i('开始下载任务: ${task.fileName}', 'DownloadService');
      task.status = DownloadStatus.downloading;
      await _updateTaskStatus(task);

      // 获取文件大小
      try {
        // 先尝试发送 HEAD 请求
        final headResponse = await dio.head(task.url, cancelToken: cancelToken);
        final contentLength = headResponse.headers.value('content-length');
        if (contentLength != null) {
          task.totalBytes = int.parse(contentLength);
          LogUtils.d(
              '从content-length获取文件大小: ${task.totalBytes}', 'DownloadService');
        }
      } catch (e) {
        LogUtils.w('HEAD请求获取文件大小失败: $e', 'DownloadService');

        // HEAD 请求失败,尝试发送 GET range 请求
        try {
          final rangeResponse = await dio.get(
            task.url,
            cancelToken: cancelToken,
            options: Options(
                responseType: ResponseType.stream,
                headers: {'Range': 'bytes=0-0'} // 只请求第一个字节
                ),
          );

          // 从 content-range 头获取总大小
          final contentRange = rangeResponse.headers.value('content-range');
          if (contentRange != null) {
            // 格式: bytes 0-0/total_size
            final match =
                RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
            if (match != null) {
              task.totalBytes = int.parse(match.group(1)!);
              LogUtils.d('从content-range获取文件大小: ${task.totalBytes}',
                  'DownloadService');
            }
          }
        } catch (e) {
          LogUtils.w('Range请求获取文件大小失败: $e', 'DownloadService');
        }
      }

      final response = await dio.get(
        task.url,
        cancelToken: cancelToken,
        options: Options(
            responseType: ResponseType.stream,
            followRedirects: true,
            headers: task.downloadedBytes > 0
                ? {'Range': 'bytes=${task.downloadedBytes}-'}
                : null),
      );

      // 如果还没获取到总大小,尝试从响应头获取
      if (task.totalBytes == 0) {
        final contentLength = response.headers.value('content-length');
        if (contentLength != null) {
          task.totalBytes = int.parse(contentLength);
          LogUtils.d('从下载响应获取文件大小: ${task.totalBytes}', 'DownloadService');
        }
      }

      final file = File(task.savePath);
      await file.parent.create(recursive: true);
      raf = await file.open(mode: FileMode.writeOnlyAppend);

      LogUtils.d('开始接收数据流', 'DownloadService');

      // 为当前任务创建专用的计时器
      _taskTimers[task.id]?.cancel();
      _taskTimers[task.id] = Timer.periodic(const Duration(seconds: 1), (_) {
        task.updateSpeed();
        _repository.updateTask(task);
        if (task.totalBytes > 0) {
          LogUtils.d(
              '[${task.fileName}] 下载进度: ${task.downloadedBytes}/${task.totalBytes} '
                  '(${(task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(2)}%), '
                  '速度: ${(task.speed / 1024 / 1024).toStringAsFixed(2)}MB/s',
              'DownloadService');
        } else {
          LogUtils.d(
              '[${task.fileName}] 已下载: ${task.downloadedBytes} bytes, '
                  '速度: ${(task.speed / 1024 / 1024).toStringAsFixed(2)}MB/s',
              'DownloadService');
        }
      });

      final completer = Completer();

      subscription = response.data.stream.listen(
        (chunk) {
          try {
            raf?.writeFromSync(chunk);
            task.downloadedBytes = (task.downloadedBytes + chunk.length) as int;
            _activeTasks[task.id] = task;
          } catch (e) {
            LogUtils.e('写入文件失败: $e', tag: 'DownloadService', error: e);
            rethrow;
          }
        },
        onDone: () async {
          LogUtils.i('下载完成: ${task.fileName}', 'DownloadService');
          await _cleanupDownload(task, raf, subscription);
          task.status = DownloadStatus.completed;
          task.downloadedBytes = task.totalBytes;
          await _updateTaskStatus(task);
          completer.complete();
          _processQueue();
        },
        onError: (error) async {
          LogUtils.e('下载出错: $error', tag: 'DownloadService', error: error);
          await _cleanupDownload(task, raf, subscription);
          task.status = DownloadStatus.failed;
          task.error = _getErrorMessage(error);
          await _updateTaskStatus(task);
          completer.completeError(error);
          _processQueue();
        },
        cancelOnError: true,
      );

      cancelToken.whenCancel.then((_) async {
        LogUtils.i('下载已取消: ${task.fileName}', 'DownloadService');
        await _cleanupDownload(task, raf, subscription);
        // 不要在这里调用 _processQueue()，因为暂停不应该触发下一个任务
      });

      try {
        await completer.future;
      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.cancel) {
          // 用户主动取消,不需要额外处理
          LogUtils.d('用户暂停下载: ${task.fileName}', 'DownloadService');
        } else {
          // 其他错误需要重新抛出
          rethrow;
        }
      }
    } catch (e) {
      if (e is DioException) {
        final errorMsg = _getErrorMessage(e);
        LogUtils.e('下载失败: $errorMsg', tag: 'DownloadService', error: e);
        _showError(errorMsg);
      } else if (e is FileSystemException) {
        final errorMsg =
            slang.t.download.errors.fileSystemError(errorInfo: e.message);
        LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
        _showError(errorMsg);
      } else {
        final errorMsg =
            slang.t.download.errors.unknownError(errorInfo: e.toString());
        LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
        _showError(errorMsg);
      }

      await _cleanupDownload(task, raf, subscription);
      task.status = DownloadStatus.failed;
      task.error = _getErrorMessage(e);
      await _updateTaskStatus(task);
      _processQueue();
    } finally {
      // 确保在任务结束时（无论成功还是失败）都会检查队列
      if (_activeDownloads.length < maxConcurrentDownloads &&
          _downloadQueue.isNotEmpty) {
        _processQueue();
      }
    }
  }

  // 添加辅助方法
  Future<void> _cleanupDownload(DownloadTask task, RandomAccessFile? raf,
      StreamSubscription? subscription) async {
    await subscription?.cancel();
    try {
      await raf?.close();
    } catch (e) {
      LogUtils.e('关闭文件失败: $e', tag: 'DownloadService', error: e);
    }
    _activeDownloads.remove(task.id);

    // 清理任务专用的计时器
    _taskTimers[task.id]?.cancel();
    _taskTimers.remove(task.id);

    // 从内存中移除任务
    _activeTasks.remove(task.id);
    _downloadQueue.remove(task.id);

    // 通知任务状态变更
    _taskStatusChangedNotifier.value++;
  }

  Future<void> _updateTaskStatus(DownloadTask task) async {
    if (task.status == DownloadStatus.completed) {
      // 如果任务完成，从活跃任务移到已完成任务
      _activeTasks.remove(task.id);
    } else {
      _activeTasks[task.id] = task;
    }
    await _repository.updateTaskStatusById(task.id, task.status);

    // 通知任务状态变更
    _taskStatusChangedNotifier.value++;
  }

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return slang.t.download.errors.connectionTimeout;
        case DioExceptionType.sendTimeout:
          return slang.t.download.errors.sendTimeout;
        case DioExceptionType.receiveTimeout:
          return slang.t.download.errors.receiveTimeout;
        case DioExceptionType.badResponse:
          return slang.t.download.errors.serverError(
              errorInfo: error.response?.statusCode.toString() ?? '');
        default:
          return error.message ?? slang.t.download.errors.unknownNetworkError;
      }
    } else if (error is FileSystemException) {
      return slang.t.download.errors.fileSystemError(errorInfo: error.message);
    }
    return error.toString();
  }

  // 添加重试方法
  Future<void> retryTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) return;

    if (task.status == DownloadStatus.failed) {
      LogUtils.i('重试下载任务: ${task.fileName}', 'DownloadService');
      task.error = null;
      task.status = DownloadStatus.pending;
      _downloadQueue.add(taskId);
      _activeTasks[taskId] = task;
      await _repository.updateTask(task);

      _processQueue();
    }
  }

  // 清除所有失败的任务
  Future<void> clearFailedTasks() async {
    final failedTasks = await _repository.getTasksByStatus(DownloadStatus.failed);
    for (var task in failedTasks) {
      await deleteTask(task.id);
    }
    // 通知任务状态变更
    _taskStatusChangedNotifier.value++;
  }

  // 获取已完成的任务（分页）
  Future<List<DownloadTask>> getCompletedTasks({
    required int offset,
    required int limit,
  }) async {
    return await _repository.getCompletedTasks(
      offset: offset,
      limit: limit,
    );
  }

  @override
  void onClose() {
    // 取消所有下载
    for (var cancelToken in _activeDownloads.values) {
      cancelToken.cancel(slang.t.download.errors.serviceIsClosing);
    }
    _activeDownloads.clear();

    // 清理所有计时器
    for (var timer in _taskTimers.values) {
      timer.cancel();
    }
    _taskTimers.clear();

    // 清理其他资源
    _activeTasks.clear();
    _downloadQueue.clear();

    super.onClose();
  }

  void _showError(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 添加图库下载的方法
  Future<void> _startGalleryDownload(DownloadTask task) async {
    try {
      final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);

      // 格式化保存路径，统一使用平台特定的路径分隔符
      final savePath = path_lib.normalize(task.savePath);

      // 创建保存目录
      final directory = Directory(savePath);
      if (await directory.exists()) {
        // 如果目录已存在，先删除它
        await directory.delete(recursive: true);
      }
      await directory.create(recursive: true);

      // 初始化下载进度跟踪
      _galleryDownloadProgress[task.id] = {
        for (var image in galleryData.imageList) image['id']!: false
      };

      task.status = DownloadStatus.downloading;
      await _updateTaskStatus(task);

      // 并发下载所有图片
      final futures = galleryData.imageList
          .map((image) => _downloadGalleryImage(
                task,
                image['url']!,
                image['id']!,
                galleryData.imageList.length,
              ))
          .toList();

      final results = await Future.wait(futures);

      // 检查是否所有图片都下载成功
      final allSuccess = results.every((success) => success);

      task.status =
          allSuccess ? DownloadStatus.completed : DownloadStatus.failed;
      task.error =
          allSuccess ? null : slang.t.download.errors.partialDownloadFailed;
      await _updateTaskStatus(task);
    } catch (e) {
      LogUtils.e('下载图库失败', tag: 'DownloadService', error: e);
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      await _updateTaskStatus(task);
    }
  }
}
