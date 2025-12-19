import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:path/path.dart' as path_lib;
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 任务模型
/// enum DownloadStatus {
///   pending,      // 等待中
///   downloading,  // 下载中
///   paused,       // 暂停
///   completed,    // 完成
///   failed,       // 失败
/// }
class DownloadService extends GetxService {
  static DownloadService get to => Get.find<DownloadService>();

  /// =============================== 对外暴露的接口, 对当前的业务无影响 ===============================

  // 用于通知任务状态变更的 RxInt
  final _taskStatusChangedNotifier = 0.obs;

  // 获取所有活跃任务（仅包含下载中的任务）
  Map<String, DownloadTask> get tasks => _activeTasks;

  // 获取任务状态变更通知器 [仅在任务状态变更时，进行通知，用于刷新UI列表数据]
  RxInt get taskStatusChangedNotifier => _taskStatusChangedNotifier;

  final _repository = DownloadTaskRepository();

  static const maxConcurrentDownloads = 3;
  final dio = Dio()..options.persistentConnection = false;

  DownloadTaskRepository get repository => _repository;

  // 获取图库下载进度
  Map<String, bool>? getGalleryDownloadProgress(String taskId) {
    return _galleryDownloadProgress[taskId];
  }

  // 获取单个图片下载进度
  Map<String, double>? getGalleryImageProgress(String taskId) {
    return _galleryImageProgress[taskId];
  }

  // 获取下载队列的id列表
  List<String> getQueueIds() {
    return _downloadQueue.toList();
  }

  // =============================== 内部方法 ===============================
  // 活跃任务列表，只包含下载中的任务
  // 活跃任务列表，key是任务的id，value是任务对象，此处是最新的任务信息状态,
  // 当变更内容时，会通知_taskStatusChangedNotifier，用于刷新UI列表数据
  // 理论来说，如果任务的状态发生变更，则应该同步给持久化数据库
  final _activeTasks = <String, DownloadTask>{}.obs;
  // 活跃下载列表，key是任务的id，value是下载任务的CancelToken
  final _activeDownloads = <String, CancelToken>{};
  // 下载队列，存储的是任务的id
  final _downloadQueue = <String>[].obs;

  // 任务计时器映射，key是任务的id，value是任务的计时器，用于计时更新任务的下载进度UI
  final _taskTimers = <String, Timer>{};

  // 进度通知器映射，key是任务的id，value是RxInt，用于高频通知单个Item刷新进度
  final _progressTriggers = <String, RxInt>{};
  // 上次通知时间映射，用于节流
  final _lastNotifyTime = <String, int>{};

  // 获取特定任务的进度通知器
  RxInt getProgressTrigger(String taskId) {
    return _progressTriggers.putIfAbsent(taskId, () => 0.obs);
  }

  // 通知进度更新（带节流）
  void _notifyProgress(String taskId) {
    const throttleDuration = 200; // 200ms节流
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastNotifyTime[taskId] ?? 0;

    if (now - lastTime > throttleDuration) {
      _lastNotifyTime[taskId] = now;
      _progressTriggers[taskId]?.value++;
    }
  }

  // 队列处理锁，防止并发调用 _processQueue 导致超过最大并发数
  bool _isProcessingQueue = false;

  // 正在处理中的任务ID集合（用于 loading 状态）
  final _processingTaskIds = <String>{}.obs;

  // 检查任务是否正在处理中（用于 UI 显示 loading）
  bool isTaskProcessing(String taskId) => _processingTaskIds.contains(taskId);

  // =============================== 图库下载相关的字段(图库需要特殊处理，因为它需要下载多个图片而非单个文件) ===============================
  // 图库下载相关的字段, key是任务的id，value是图库下载进度
  final _galleryDownloadProgress = <String, Map<String, bool>>{}.obs;
  // 单个图片下载进度跟踪, key是任务的id，value是单个图片下载进度
  final _galleryImageProgress = <String, Map<String, double>>{}.obs;

  // 更新进度的辅助方法
  void _updateGalleryProgress(String taskId, String imageId, bool downloaded) {
    final progress = Map<String, bool>.from(
      _galleryDownloadProgress[taskId] ?? {},
    );
    progress[imageId] = downloaded;
    _galleryDownloadProgress[taskId] = progress;
  }

  void _updateImageProgress(String taskId, String imageId, double progress) {
    final imageProgress = Map<String, double>.from(
      _galleryImageProgress[taskId] ?? {},
    );
    imageProgress[imageId] = progress;
    _galleryImageProgress[taskId] = imageProgress;
  }

  // =============================== 初始化 ===============================
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadActiveTasks();
  }

  // =============================== 加载活跃任务（仅加载下载中的任务） ===============================
  // 获取downloading、pending状态的全部任务，
  // 通过_downloadQueue来存储任务的id，供_processQueue()方法使用
  // 注意：内存中的 _activeTasks 只保存 downloading 任务
  Future<void> _loadActiveTasks() async {
    try {
      // 拉取所有 downloading + pending 任务，按创建时间升序
      final tasks = await _repository
          .getDownloadingAndPendingTasksOrderByCreatedAtAsc();
      int restoredDownloadingCount = 0;
      int pendingCount = 0;

      for (var task in tasks) {
        if (task.status == DownloadStatus.downloading) {
          // 启动时遇到 downloading 任务，一律恢复为 pending 并仅持久化到数据库
          restoredDownloadingCount++;
          await _repository.updateTaskStatusById(
            task.id,
            DownloadStatus.pending,
          );
        } else if (task.status == DownloadStatus.pending) {
          pendingCount++;
        }

        // 队列中仅维护任务 id，顺序即为 created_at 升序
        _downloadQueue.add(task.id);
      }

      LogUtils.d(
        '已加载 $restoredDownloadingCount 个历史下载中任务, $pendingCount 个等待中任务',
        'DownloadService',
      );

      _processQueue();
    } catch (e) {
      LogUtils.e('加载下载任务失败', error: e);
      _showMessage(slang.t.download.errors.failedToLoadTasks, Colors.red);
    }
  }

  // 获取内存中的活跃任务
  DownloadTask? getMemoryActiveTaskById(String taskId) {
    return _activeTasks[taskId];
  }

  // 获取数据库中的活跃任务
  Future<DownloadTask?> getDatabaseActiveTaskById(String taskId) async {
    return await _repository.getTaskById(taskId);
  }

  // 添加任务
  Future<void> addTask(DownloadTask task) async {
    LogUtils.d('添加任务: ${task.id}', 'DownloadService');

    // 格式化task的下载路径
    task.savePath = CommonUtils.formatSavePathUriByPath(task.savePath);
    try {
      // 自动补全媒体索引字段，便于后续通过 media_type/media_id/quality 做高效查询
      try {
        final ext = task.extData;
        if (ext != null) {
          if (ext.type == DownloadTaskExtDataType.video) {
            final videoData = VideoDownloadExtData.fromJson(ext.data);
            task.mediaType ??= 'video';
            task.mediaId ??= videoData.id;
            task.quality ??= videoData.quality;
          } else if (ext.type == DownloadTaskExtDataType.gallery) {
            final galleryData = GalleryDownloadExtData.fromJson(ext.data);
            task.mediaType ??= 'gallery';
            task.mediaId ??= galleryData.id;
            // 图库任务目前不区分 quality，保持为 null
          }
        }
      } catch (e) {
        LogUtils.w('自动填充下载任务媒体索引字段失败: $e', 'DownloadService');
      }

      // 直接插入数据库，因为ID是唯一的
      task.status = DownloadStatus.pending;
      await _repository.insertTask(task);

      // 仅添加到下载队列，pending 任务不常驻内存
      _downloadQueue.add(task.id);

      LogUtils.i('添加下载任务: ${task.fileName}', 'DownloadService');
      _processQueue();
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'DownloadService', error: e);
      _showMessage(
        slang.t.download.errors.downloadFailedForMessage(
          errorInfo: _getErrorMessage(e),
        ),
        Colors.red,
      );
      rethrow;
    }
  }

  // 暂停任务 [内存 -> 数据库]
  Future<void> pauseTask(String taskId) async {
    LogUtils.d('暂停任务: $taskId', 'DownloadService');

    // 优先从内存中获取下载中任务，如不存在则从数据库获取
    final task = _activeTasks[taskId] ?? await _repository.getTaskById(taskId);
    if (task == null) {
      LogUtils.d('任务不存在: $taskId', 'DownloadService');
      return;
    }

    task.status = DownloadStatus.paused;
    // [优先更新持久化信息]
    await _repository.updateTask(task);

    // 从内存/队列中移除、取消下载、移除计时器
    _clearMemoryTask(taskId, '用户暂停下载');

    // 通知UI变更
    _taskStatusChangedNotifier.value++;

    // 处理等待队列中的下一个任务
    _processQueue();
  }

  // 恢复任务 [数据库 -> 内存]
  Future<void> resumeTask(String taskId) async {
    // 防止重复点击
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    try {
      LogUtils.d('恢复任务: $taskId', 'DownloadService');
      // 从数据库加载任务
      DownloadTask? task = await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('任务不存在于数据库，无法恢复: $taskId', 'DownloadService');
        _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        return;
      }

      if (task.status == DownloadStatus.paused ||
          task.status == DownloadStatus.failed) {
        LogUtils.d('任务状态为暂停或失败，需要验证链接有效性: $taskId', 'DownloadService');
        // 如果是视频任务，需要验证链接有效性
        if (task.extData?.type == DownloadTaskExtDataType.video) {
          DownloadTask? newTask = await refreshVideoTask(task);
          if (newTask != null) {
            LogUtils.d('刷新视频任务成功: $taskId', 'DownloadService');
            newTask.status = DownloadStatus.pending;
            task = newTask;
            await _repository.updateTask(newTask); // [更新持久化信息]
          } else {
            _showMessage(
              slang.t.download.errors.canNotRefreshVideoTask,
              Colors.red,
            );
            // 让任务变为失败状态，并记录错误信息
            task.status = DownloadStatus.failed;
            task.error = slang.t.download.errors.canNotRefreshVideoTask;
            await _repository.updateTask(task); // [更新持久化信息]
            _clearMemoryTask(taskId, '刷新视频任务失败，无法处理');
            LogUtils.d('刷新视频任务失败，无法处理: $taskId', 'DownloadService');
            return;
          }
        } else {
          task.status = DownloadStatus.pending;
          await _repository.updateTask(task);
        }

        // 仅将任务 id 加入等待队列，pending 任务不常驻内存
        _downloadQueue.add(taskId);

        // 通知任务状态变更
        _taskStatusChangedNotifier.value++;

        _processQueue();
      }
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  void _clearMemoryTask(String taskId, String message) {
    // 从内存中移除
    _activeTasks.remove(taskId);
    _downloadQueue.remove(taskId);
    // 取消下载
    _activeDownloads[taskId]?.cancel(message);
    _activeDownloads.remove(taskId);
    // 移除计时器和进度追踪器
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);
    // 不立即移除 _progressTriggers，因为 UI 可能还在监听，让它自然回收或在适当时候清理
  }

  // 删除任务
  // 此任务可能在内存中，也可能在数据库中，需要先从内存中获取，如果获取不到，则从数据库中获取
  Future<void> deleteTask(
    String taskId, {
    bool ignoreFileDeleteError = false,
  }) async {
    // 防止重复删除
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    try {
      LogUtils.i('开始删除下载任务: $taskId', 'DownloadService');
      DownloadTask? task;
      // 获取任务信息
      task = _activeTasks[taskId] ?? await _repository.getTaskById(taskId);

      // 如果内存和数据库中都没有任务信息，则直接返回
      if (task == null) {
        LogUtils.e('任务不存在: $taskId', tag: 'DownloadService');
        _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        // 防止内存问题，清理内存中的信息
        _clearMemoryTask(taskId, '任务不存在时的清理');
        return;
      }

      // 如果任务正在下载中，先取消下载并等待资源释放
      if (task.status == DownloadStatus.downloading ||
          _activeDownloads.containsKey(taskId)) {
        LogUtils.d('任务正在下载中，先取消下载: $taskId', 'DownloadService');
        _clearMemoryTask(taskId, '删除任务前取消下载');
        // 等待文件资源释放
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 尝试删除文件，支持重试
      bool isDeleteSuccess = false;
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 300);

      while (!isDeleteSuccess && retryCount < maxRetries) {
        final fileOrDir = FileSystemEntity.typeSync(task.savePath);

        if (fileOrDir == FileSystemEntityType.notFound) {
          // 目标不存在，视为已删除
          LogUtils.w('目标不存在，无需删除: ${task.savePath}', 'DownloadService');
          isDeleteSuccess = true;
        } else if (fileOrDir == FileSystemEntityType.directory) {
          // 如果是文件夹则删除整个文件夹
          final dir = Directory(task.savePath);
          if (await dir.exists()) {
            try {
              await dir.delete(recursive: true);
              LogUtils.d('已删除文件夹: ${task.savePath}', 'DownloadService');
              isDeleteSuccess = true;
            } catch (e) {
              // 若并发导致此时目录已不存在，也视为成功
              if (!await dir.exists()) {
                LogUtils.w('删除时目录已不存在: ${task.savePath}', 'DownloadService');
                isDeleteSuccess = true;
              } else {
                LogUtils.e(
                  '删除文件夹失败，可能被占用: ${task.savePath} (重试 $retryCount/$maxRetries)',
                  tag: 'DownloadService',
                  error: e,
                );
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                } else {
                  retryCount++;
                }
              }
            }
          } else {
            // 不存在也当做成功
            LogUtils.w('目录不存在，无需删除: ${task.savePath}', 'DownloadService');
            isDeleteSuccess = true;
          }
        } else {
          // 如果是文件则删除文件（包含符号链接等情况）
          final file = File(task.savePath);
          if (await file.exists()) {
            try {
              await file.delete();
              LogUtils.d('已删除文件: ${task.savePath}', 'DownloadService');
              isDeleteSuccess = true;
            } catch (e) {
              // 若并发导致此时文件已不存在，也视为成功
              if (!await file.exists()) {
                LogUtils.w('删除时文件已不存在: ${task.savePath}', 'DownloadService');
                isDeleteSuccess = true;
              } else {
                LogUtils.e(
                  '删除文件失败，可能被占用: ${task.savePath} (重试 $retryCount/$maxRetries)',
                  tag: 'DownloadService',
                  error: e,
                );
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                } else {
                  retryCount++;
                }
              }
            }
          } else {
            // 不存在也当做成功
            LogUtils.w('文件不存在，无需删除: ${task.savePath}', 'DownloadService');
            isDeleteSuccess = true;
          }
        }
      }

      if (!isDeleteSuccess && !ignoreFileDeleteError) {
        LogUtils.e('删除文件失败: ${task.savePath}', tag: 'DownloadService');
        _showMessage(slang.t.download.errors.deleteFileError, Colors.red);
        return;
      }

      // 从数据库删除任务记录
      await _repository.deleteTask(taskId);

      _clearMemoryTask(taskId, '任务已删除');

      // 通知任务状态变更，触发UI刷新
      _taskStatusChangedNotifier.value++;
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  // 处理下载队列
  void _processQueue() async {
    // 防止并发调用导致超过最大并发数
    if (_isProcessingQueue) {
      return;
    }
    _isProcessingQueue = true;

    try {
      // 使用 while 循环持续处理队列，直到达到并发上限或队列为空
      while (_activeDownloads.length < maxConcurrentDownloads &&
          _downloadQueue.isNotEmpty) {
        // 取出队首任务 id
        final taskId = _downloadQueue.first;

        // 通过数据库获取最新任务信息，pending 任务不常驻内存
        final task = await _repository.getTaskById(taskId);

        // 仅对仍为 pending 的任务进行下载；否则跳过
        if (task == null || task.status != DownloadStatus.pending) {
          _downloadQueue.removeAt(0);
          continue; // 继续处理队列中的下一个任务
        }

        // 从下载队列中移除任务
        _downloadQueue.removeAt(0);

        // 记录开始下载的时间
        LogUtils.i(
          '开始下载任务: ${task.fileName} (当前活动下载数: ${_activeDownloads.length + 1}/$maxConcurrentDownloads)',
          'DownloadService',
        );

        // 注意：这里不使用 await，让下载任务异步执行
        // 但需要在调用 _startRealDownload 之前就预占位置，防止超过并发数
        final cancelToken = CancelToken();
        _activeDownloads[task.id] = cancelToken;

        // 异步执行下载任务
        _startRealDownload(task, cancelToken);
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // 真正的下载任务
  Future<void> _startRealDownload(
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    // CancelToken 已在 _processQueue 中创建并添加到 _activeDownloads

    // 如果是图库下载
    if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      await _startGalleryDownload(task, cancelToken);
      return;
    }

    RandomAccessFile? raf;
    StreamSubscription? subscription;
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 3);

    while (retryCount < maxRetries) {
      try {
        LogUtils.i(
          '开始下载任务: ${task.fileName} (重试次数: $retryCount)',
          'DownloadService',
        );

        // 验证已下载的部分
        final file = File(task.savePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > task.downloadedBytes) {
            // 已下载的文件比记录的大，说明可能有问题，重新下载
            task.downloadedBytes = 0;
            await file.delete();
          } else if (fileSize < task.downloadedBytes) {
            // 实际文件比记录的小，更新已下载大小
            task.downloadedBytes = fileSize;
          }
        } else {
          task.downloadedBytes = 0;
        }

        task.status = DownloadStatus.downloading;
        await _updateTaskStatus(task);

        // 获取文件大小 - 直接使用 Range 请求获取文件大小
        try {
          final rangeResponse = await dio.get(
            task.url,
            cancelToken: cancelToken,
            options: Options(
              responseType: ResponseType.stream,
              headers: {'Range': 'bytes=0-0'}, // 只请求第一个字节
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

          // 从 content-range 头获取总大小
          final contentRange = rangeResponse.headers.value('content-range');
          if (contentRange != null) {
            // 格式: bytes 0-0/total_size
            final match = RegExp(
              r'bytes \d+-\d+/(\d+)',
            ).firstMatch(contentRange);
            if (match != null) {
              task.totalBytes = int.parse(match.group(1)!);
              LogUtils.d(
                '从Range请求获取文件大小: ${task.totalBytes}',
                'DownloadService',
              );
            }
          }
        } catch (e) {
          // 如果是取消操作，直接返回
          if (e is DioException && e.type == DioExceptionType.cancel) {
            // 取消操作，更新状态
            task.status = DownloadStatus.paused; // [更新内存状态]
            await _updateTaskStatus(task); // [更新持久化信息]
            return;
          }
          LogUtils.w('Range请求获取文件大小失败: $e', 'DownloadService');
        }

        final response = await dio.get(
          task.url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.stream,
            followRedirects: true,
            // 仅接受 2xx，避免将 4xx 的错误页当做有效响应来写入
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
            headers: task.downloadedBytes > 0
                ? {
                    'Range': 'bytes=${task.downloadedBytes}-',
                    'Accept-Encoding': 'identity',
                    'Referer': 'https://www.iwara.tv/',
                    'Accept': '*/*',
                    'Connection': 'keep-alive',
                  }
                : {
                    'Accept-Encoding': 'identity',
                    'Referer': 'https://www.iwara.tv/',
                    'Accept': '*/*',
                    'Connection': 'keep-alive',
                  },
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        // 对视频下载进行响应类型校验，避免把 HTML 挑战页/错误页当成视频写入
        final contentType = response.headers.value('content-type') ?? '';
        if (task.extData?.type == DownloadTaskExtDataType.video) {
          if (!contentType.toLowerCase().startsWith('video')) {
            LogUtils.w('下载响应类型异常: $contentType', 'DownloadService');
            throw FileSystemException(
              message: 'Request Response Type Error: $contentType',
              type: FileErrorType.ioError,
            );
          }
        }

        // 验证服务器是否支持断点续传
        if (task.downloadedBytes > 0) {
          final contentRange = response.headers.value('content-range');
          if (contentRange == null || response.statusCode != 206) {
            // 服务器不支持断点续传，需要重新下载
            task.downloadedBytes = 0;
            await file.delete();
            throw DioException(
              requestOptions: response.requestOptions,
              error: '服务器不支持断点续传，需要重新下载',
            );
          }
        }

        // 如果还没获取到总大小,尝试从响应头获取
        if (task.totalBytes == 0) {
          final contentLength = response.headers.value('content-length');
          if (contentLength != null) {
            task.totalBytes = int.parse(contentLength);
            LogUtils.d('从下载响应获取文件大小: ${task.totalBytes}', 'DownloadService');
          }
        }

        await file.parent.create(recursive: true);
        raf = await file.open(
          mode: task.downloadedBytes > 0
              ? FileMode.writeOnlyAppend
              : FileMode.writeOnly,
        );

        LogUtils.d('开始接收数据流', 'DownloadService');

        // 为当前任务创建专用的计时器
        _taskTimers[task.id]?.cancel();
        _taskTimers[task.id] = Timer.periodic(const Duration(seconds: 1), (_) {
          // 如果是图库类型，则用不到taskTimer，因为图库里的图片下载完成会自动触发数据库的更新和内存状态的更新
          if (task.extData?.type == DownloadTaskExtDataType.gallery) {
            return;
          }
          task.updateSpeed(); // [更新下载速度]
          _repository.updateTask(task); // 每隔1秒 [更新一次持久化信息]
        });

        final completer = Completer();

        // 数据流处理
        subscription = response.data.stream.listen(
          (chunk) {
            try {
              final localRaf = raf;
              if (localRaf != null) {
                localRaf.writeFromSync(chunk);
                task.downloadedBytes =
                    (task.downloadedBytes + chunk.length) as int;
                // 不再直接更新 _activeTasks以避免触发整个列表的重建
                // _activeTasks[task.id] = task;

                // 而是触发单个任务的进度通知
                _notifyProgress(task.id);
              }
            } catch (e) {
              LogUtils.e('写入文件失败: $e', tag: 'DownloadService', error: e);
              subscription?.cancel();
              throw FileSystemException(
                message: '写入文件失败: $e',
                type: FileErrorType.ioError,
              );
            }
          },
          onDone: () async {
            LogUtils.i('下载完成: ${task.fileName}', 'DownloadService');

            try {
              // 确保缓冲区写入磁盘后再校验大小
              final localRaf = raf;
              try {
                await localRaf?.flush();
              } catch (_) {}
              final finalSize = localRaf != null
                  ? await localRaf.length()
                  : await file.length();
              if (task.totalBytes > 0 && finalSize != task.totalBytes) {
                final integrityError = FileSystemException(
                  message: '文件大小不匹配，预期: ${task.totalBytes}，实际: $finalSize',
                  type: FileErrorType.ioError,
                );

                // 先释放资源，再把错误交给外层处理（重试或失败）
                await _cleanupDownload(task, raf, subscription);
                completer.completeError(integrityError);
                return; // 必须 return，避免继续走“成功完成”的逻辑
              }
            } catch (e) {
              await _cleanupDownload(task, raf, subscription);
              completer.completeError(e);
              return;
            }

            // 正常完成路径
            await _cleanupDownload(task, raf, subscription);
            task.status = DownloadStatus.completed;
            task.downloadedBytes = task.totalBytes;
            await _updateTaskStatus(task);
            completer.complete();
            _processQueue();
          },
          onError: (error) async {
            LogUtils.e('下载出错: $error', tag: 'DownloadService', error: error);
            try {
              await _cleanupDownload(task, raf, subscription);

              // 如果是连接中断错误，尝试重试
              if (error is HttpException &&
                  error.message.contains('Connection closed')) {
                if (retryCount < maxRetries - 1) {
                  retryCount++;
                  await Future.delayed(retryDelay);
                  completer.completeError(error); // 通过completer传递错误
                  return;
                }
              }

              task.status = DownloadStatus.failed;
              task.error = _getErrorMessage(error);
              await _updateTaskStatus(task);
              completer.completeError(error);
            } catch (e) {
              LogUtils.e('处理下载错误时发生异常: $e', tag: 'DownloadService', error: e);
              task.status = DownloadStatus.failed;
              task.error = _getErrorMessage(e);
              await _updateTaskStatus(task);
              completer.completeError(e);
            } finally {
              _processQueue();
            }
          },
          cancelOnError: true,
        );

        cancelToken.whenCancel.then((_) async {
          LogUtils.i('下载已取消: ${task.fileName}', 'DownloadService');
          await _cleanupDownload(task, raf, subscription);
          task.status = DownloadStatus.paused; // [更新内存状态]
          await _updateTaskStatus(task); // [更新持久化信息]
        });

        try {
          await completer.future;
          break; // 下载成功，跳出重试循环
        } catch (e) {
          // 如果是取消操作，completer.future会抛出DioException(cancel)
          // 但我们已经在whenCancel中处理了取消操作，这里直接返回
          if (e is DioException && e.type == DioExceptionType.cancel) {
            return;
          }

          // 如果是最后一次重试或不是连接中断错误，则抛出错误
          if (retryCount >= maxRetries - 1 ||
              !(e is HttpException &&
                  e.message.contains('Connection closed'))) {
            rethrow;
          }

          // 否则继续重试
          retryCount++;
          await Future.delayed(retryDelay);
          continue;
        }
      } catch (e) {
        // 针对网络类错误做一点「智能重试」：
        // 1) 403: 可能是签名/鉴权过期，视频任务需要强制刷新下载链接再重试
        // 2) 连接中断: 尝试像 resumeTask 一样刷新下载链接后再重试一次。
        final isDio403Error =
            e is DioException && e.response?.statusCode == 403;
        final isConnectionClosedError =
            e is HttpException && e.message.contains('Connection closed');

        if (isDio403Error &&
            retryCount < maxRetries - 1 &&
            task.extData?.type == DownloadTaskExtDataType.video) {
          try {
            final refreshed = await refreshVideoTask(task, force: true);
            if (refreshed != null) {
              LogUtils.w(
                '检测到403，已强制刷新视频下载链接，准备重试: ${task.id}',
                'DownloadService',
              );
              task = refreshed;
              retryCount++;
              await Future.delayed(retryDelay);
              continue;
            }
          } catch (refreshError) {
            LogUtils.w(
              '403 时刷新视频任务链接失败，将按照普通错误处理: $refreshError',
              'DownloadService',
            );
          }
        }

        if (isConnectionClosedError &&
            retryCount < maxRetries - 1 &&
            task.extData?.type == DownloadTaskExtDataType.video) {
          try {
            final refreshed = await refreshVideoTask(task);
            if (refreshed != null) {
              LogUtils.d(
                '检测到连接中断，已刷新视频下载链接，准备重试: ${task.id}',
                'DownloadService',
              );
              task = refreshed;
              retryCount++;
              await Future.delayed(retryDelay);
              continue;
            }
          } catch (refreshError) {
            LogUtils.w(
              '连接中断时刷新视频任务链接失败，将按照普通错误处理: $refreshError',
              'DownloadService',
            );
          }
        }

        // 针对 mikoto/phoebe 服务器故障，自动切换到 hime
        final isMikotoPhoebeError = _isMikotoPhoebeServerError(e, task.url);
        if (isMikotoPhoebeError && retryCount < maxRetries - 1) {
          LogUtils.w(
            '检测到 mikoto/phoebe 服务器故障，尝试切换到 hime 服务器并重试: ${task.id}',
            'DownloadService',
          );

          // 替换服务器
          final newUrl = _replaceServerToHime(task.url);
          if (newUrl != task.url) {
            task.url = newUrl;
            await _repository.updateTask(task);

            _showMessage(
              slang.t.videoDetail.player.serverFaultDetectedAutoSwitched,
              Colors.orange,
            );

            retryCount++;
            await Future.delayed(retryDelay);
            continue;
          }
        }

        if (retryCount >= maxRetries - 1) {
          if (e is DioException) {
            final errorMsg = _getErrorMessage(e);
            LogUtils.e('下载失败: $errorMsg', tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          } else if (e is FileSystemException) {
            final errorMsg = slang.t.download.errors.fileSystemError(
              errorInfo: e.message,
            );
            LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          } else {
            final errorMsg = slang.t.download.errors.unknownError(
              errorInfo: e.toString(),
            );
            LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
            _showMessage(errorMsg, Colors.red);
          }

          await _cleanupDownload(task, raf, subscription);
          task.status = DownloadStatus.failed;
          task.error = _getErrorMessage(e);
          await _updateTaskStatus(task);
          _processQueue();
          return;
        }

        // 继续重试
        retryCount++;
        await Future.delayed(retryDelay);
        continue;
      }
    }

    // 确保在任务结束时（无论成功还是失败）都会检查队列
    if (_activeDownloads.length < maxConcurrentDownloads &&
        _downloadQueue.isNotEmpty) {
      _processQueue();
    }
  }

  // 添加辅助方法
  Future<void> _cleanupDownload(
    DownloadTask task,
    RandomAccessFile? raf,
    StreamSubscription? subscription,
  ) async {
    await subscription?.cancel();

    if (raf != null) {
      try {
        await raf.close();
      } catch (e) {
        // 可能已被提前关闭，降级为警告，避免误导
        LogUtils.w('关闭文件失败(可能已关闭): $e', 'DownloadService');
      }
    }

    _activeDownloads.remove(task.id);

    // 清理任务专用的计时器
    _taskTimers[task.id]?.cancel();
    _taskTimers.remove(task.id);

    // 清理进度节流记录
    _lastNotifyTime.remove(task.id);

    // 从内存中移除下载中的任务（pending 不会进入 _activeTasks）
    _activeTasks.remove(task.id);

    // 通知任务状态变更
    _taskStatusChangedNotifier.value++;
  }

  Future<void> _updateTaskStatus(DownloadTask task) async {
    // 仅在任务处于下载中时保留在内存活跃列表中
    if (task.status == DownloadStatus.downloading) {
      _activeTasks[task.id] = task;
    } else {
      _activeTasks.remove(task.id);
    }
    // 使用完整更新，确保 error、downloadedBytes 等字段也能持久化
    await _repository.updateTask(task);

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
            errorInfo: error.response?.statusCode.toString() ?? '',
          );
        case DioExceptionType.connectionError:
          // 处理连接错误，包括 SSL/TLS 握手失败
          final innerError = error.error;
          if (innerError is HandshakeException) {
            return slang.t.download.errors.sslHandshakeFailed;
          } else if (innerError is SocketException) {
            return slang.t.download.errors.connectionFailed;
          }
          return slang.t.download.errors.connectionFailed;
        case DioExceptionType.unknown:
          // 处理未知错误，尝试提取内部错误信息
          final innerError = error.error;
          if (innerError is HandshakeException) {
            return slang.t.download.errors.sslHandshakeFailed;
          } else if (innerError is SocketException) {
            return slang.t.download.errors.connectionFailed;
          } else if (innerError is HttpException) {
            return innerError.message;
          }
          // 如果有消息就返回消息，否则返回未知网络错误
          if (error.message != null && error.message!.isNotEmpty) {
            return error.message!;
          }
          return slang.t.download.errors.unknownNetworkError;
        default:
          return error.message ?? slang.t.download.errors.unknownNetworkError;
      }
    } else if (error is FileSystemException) {
      return slang.t.download.errors.fileSystemError(errorInfo: error.message);
    } else if (error is HandshakeException) {
      return slang.t.download.errors.sslHandshakeFailed;
    } else if (error is SocketException) {
      return slang.t.download.errors.connectionFailed;
    } else if (error is HttpException) {
      return error.message;
    }
    return error.toString();
  }

  // 添加重试方法
  Future<void> retryTask(String taskId) async {
    // 防止重复点击
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    try {
      // 1) 优先从内存取（如果当前正在下载），否则从数据库取
      DownloadTask? task =
          _activeTasks[taskId] ?? await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('重试失败：任务不存在: $taskId', 'DownloadService');
        _showMessage(slang.t.download.errors.taskNotFound, Colors.red);
        return;
      }

      // 2) 仅允许对失败任务重试
      if (task.status != DownloadStatus.failed) {
        LogUtils.d('重试忽略：任务非失败状态: $taskId / ${task.status}', 'DownloadService');
        return;
      }

      // 3) 如为视频任务，校验/刷新链接
      if (task.extData?.type == DownloadTaskExtDataType.video) {
        final refreshed = await refreshVideoTask(task);
        if (refreshed == null) {
          // 刷新失败，维持失败状态并提示
          _showMessage(
            slang.t.download.errors.canNotRefreshVideoTask,
            Colors.red,
          );
          await _repository.updateTask(task);
          return;
        }
        task = refreshed;
      }

      // 4) 清理错误信息，入队并持久化
      LogUtils.i('重试下载任务: ${task.fileName}', 'DownloadService');
      task.error = null;
      task.status = DownloadStatus.pending;
      if (!_downloadQueue.contains(taskId)) {
        _downloadQueue.add(taskId);
      }
      await _repository.updateTask(task);

      // 通知UI并处理队列
      _taskStatusChangedNotifier.value++;
      _processQueue();
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  // 获取已完成的任务（分页）
  Future<List<DownloadTask>> getCompletedTasks({
    required int offset,
    required int limit,
  }) async {
    return await _repository.getCompletedTasks(offset: offset, limit: limit);
  }

  /// =============================== 重复检查相关接口 ===============================
  /// 检查视频任务是否重复
  /// 返回检查结果，包括是否存在相同视频不同清晰度或相同清晰度的任务
  Future<VideoTaskDuplicateCheckResult> checkVideoTaskDuplicate(
    String videoId,
    String quality,
  ) async {
    try {
      // 使用基于 media_type/media_id 的索引查询，不再做全表遍历
      final mediaTasks = await _repository.getVideoTasksByMedia(videoId);
      bool hasSameVideoDifferentQuality = false;
      bool hasSameVideoSameQuality = false;
      final existingQualities = <String>[];

      for (var task in mediaTasks) {
        final q = task.quality ?? '';
        if (q.isNotEmpty) {
          existingQualities.add(q);
        }

        if (q == quality) {
          hasSameVideoSameQuality = true;
        } else if (q.isNotEmpty) {
          hasSameVideoDifferentQuality = true;
        }
      }

      return VideoTaskDuplicateCheckResult(
        hasSameVideoDifferentQuality: hasSameVideoDifferentQuality,
        hasSameVideoSameQuality: hasSameVideoSameQuality,
        existingQualities: existingQualities.toSet().toList(),
      );
    } catch (e) {
      LogUtils.e('检查视频任务重复失败', tag: 'DownloadService', error: e);
      // 发生异常时返回无重复的结果，降级处理
      return VideoTaskDuplicateCheckResult(
        hasSameVideoDifferentQuality: false,
        hasSameVideoSameQuality: false,
        existingQualities: [],
      );
    }
  }

  /// 检查指定视频是否存在任何下载任务（任意清晰度）
  /// 返回 true 表示存在至少一个下载任务，false 表示不存在
  Future<bool> hasAnyVideoDownloadTask(String videoId) async {
    try {
      // 直接使用基于媒体索引的查询，避免全表遍历
      return await _repository.existsTaskByMedia('video', videoId);
    } catch (e) {
      LogUtils.e('检查视频下载任务失败', tag: 'DownloadService', error: e);
      // 发生异常时返回 false，降级处理
      return false;
    }
  }

  /// 获取已完成的下载任务的本地文件路径
  /// [videoId] 视频ID
  /// [quality] 视频清晰度（如 "Source", "1080", "720" 等）
  /// 返回本地文件路径，如果没有找到或文件不存在则返回 null
  Future<String?> getCompletedVideoLocalPath(
    String videoId,
    String quality,
  ) async {
    try {
      // 获取该视频的所有下载任务
      final tasks = await _repository.getVideoTasksByMedia(videoId);

      // 同一清晰度可能被重复下载，优先选择最新完成且文件存在的任务
      tasks.sort((a, b) {
        final aTs = a.createdAt?.millisecondsSinceEpoch;
        final bTs = b.createdAt?.millisecondsSinceEpoch;
        if (aTs != null && bTs != null) return bTs.compareTo(aTs); // 新的在前
        if (aTs != null) return -1; // 只有 a 有时间戳，a 在前
        if (bTs != null) return 1; // 只有 b 有时间戳，b 在前

        // 没有时间戳时使用雪花 ID 作为时间序排序（ID 越大越新）
        final aId = int.tryParse(a.id);
        final bId = int.tryParse(b.id);
        if (aId != null && bId != null) return bId.compareTo(aId);
        return b.id.compareTo(a.id);
      });

      // 找到匹配清晰度且已完成的任务
      for (final task in tasks) {
        // 不区分大小写比较清晰度
        if (task.quality?.toLowerCase() == quality.toLowerCase() &&
            task.status == DownloadStatus.completed &&
            task.savePath.isNotEmpty) {
          // 验证文件是否存在
          final file = File(task.savePath);
          if (await file.exists()) {
            LogUtils.d(
              '找到本地下载文件: videoId=$videoId, quality=$quality, path=${task.savePath}',
              'DownloadService',
            );
            return task.savePath;
          } else {
            LogUtils.w('本地文件不存在: ${task.savePath}', 'DownloadService');
          }
        }
      }

      LogUtils.d(
        '未找到本地下载文件: videoId=$videoId, quality=$quality',
        'DownloadService',
      );
      return null;
    } catch (e) {
      LogUtils.e(
        '查询本地视频文件失败: videoId=$videoId, quality=$quality',
        tag: 'DownloadService',
        error: e,
      );
      return null;
    }
  }

  /// 检查指定图库是否存在任何下载任务
  /// 返回 true 表示存在至少一个下载任务，false 表示不存在
  Future<bool> hasAnyGalleryDownloadTask(String galleryId) async {
    try {
      // 直接使用基于媒体索引的查询，避免全表遍历
      return await _repository.existsTaskByMedia('gallery', galleryId);
    } catch (e) {
      LogUtils.e('检查图库下载任务失败', tag: 'DownloadService', error: e);
      // 发生异常时返回 false，降级处理
      return false;
    }
  }

  /// 获取已完成的图库下载的本地图片路径映射
  /// [galleryId] 图库ID
  /// 返回 Map<String, String>，key 为图片ID，value 为本地文件路径
  /// 如果没有找到已完成的下载任务或文件不存在则返回空 Map
  Future<Map<String, String>> getCompletedGalleryLocalPaths(
    String galleryId,
  ) async {
    try {
      // 获取该图库的所有下载任务
      final tasks = await _repository.getAllTasksByStatus(
        DownloadStatus.completed,
      );

      // 找到匹配图库ID且已完成的任务
      for (final task in tasks) {
        if (task.mediaType == 'gallery' &&
            task.mediaId == galleryId &&
            task.status == DownloadStatus.completed &&
            task.extData?.type == DownloadTaskExtDataType.gallery) {
          final galleryData = GalleryDownloadExtData.fromJson(
            task.extData!.data,
          );
          final validLocalPaths = <String, String>{};

          // 验证每个本地文件是否存在
          for (final entry in galleryData.localPaths.entries) {
            final imageId = entry.key;
            final localPath = entry.value;

            if (localPath.isNotEmpty) {
              final file = File(localPath);
              if (await file.exists()) {
                validLocalPaths[imageId] = localPath;
              } else {
                LogUtils.w(
                  '本地图片文件不存在: imageId=$imageId, path=$localPath',
                  'DownloadService',
                );
              }
            }
          }

          if (validLocalPaths.isNotEmpty) {
            LogUtils.d(
              '找到图库本地文件: galleryId=$galleryId, 图片数量=${validLocalPaths.length}',
              'DownloadService',
            );
            return validLocalPaths;
          }
        }
      }

      LogUtils.d('未找到图库本地文件: galleryId=$galleryId', 'DownloadService');
      return {};
    } catch (e) {
      LogUtils.e(
        '查询图库本地文件失败: galleryId=$galleryId',
        tag: 'DownloadService',
        error: e,
      );
      return {};
    }
  }

  /// =============================== 统计相关接口 ===============================
  /// 获取下载中 Tab 需要展示的任务数量（downloading + paused + pending）
  Future<int> getActiveTasksCountForTab() async {
    try {
      final counts = await _repository.getTasksCount();
      return counts['active'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// 获取失败任务数量
  Future<int> getFailedTasksCount() async {
    try {
      return await _repository.getCountByStatus(DownloadStatus.failed);
    } catch (_) {
      return 0;
    }
  }

  /// 获取已完成任务数量
  Future<int> getCompletedTasksCount() async {
    try {
      return await _repository.getCountByStatus(DownloadStatus.completed);
    } catch (_) {
      return 0;
    }
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

    _progressTriggers.clear();
    _lastNotifyTime.clear();

    // 清理其他资源
    _activeTasks.clear();
    _downloadQueue.clear();

    super.onClose();
  }

  void _showMessage(String message, Color color) {
    // 改用 Flutter 自带的 ScaffoldMessenger + 当前 context 来展示 SnackBar，
    // 避免依赖 Overlay 直接抛出 “No Overlay widget found”。
    final context = Get.context ?? Get.key.currentContext;
    if (context == null) {
      LogUtils.w(
        '当前没有可用的 BuildContext，跳过 SnackBar 提示: $message',
        'DownloadService',
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      LogUtils.w(
        '当前 context 下没有 ScaffoldMessenger，跳过 SnackBar 提示: $message',
        'DownloadService',
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: color,
      ),
    );
  }

  // 图库下载的方法
  Future<void> _startGalleryDownload(
    DownloadTask task,
    CancelToken cancelToken,
  ) async {
    try {
      final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);
      final savePath = path_lib.normalize(task.savePath);

      // 创建保存目录
      final directory = Directory(savePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 初始化下载进度跟踪
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);

      // 初始化进度跟踪状态
      _galleryDownloadProgress[task.id] = {
        for (var image in galleryData.imageList.entries) image.key: false,
      };
      _galleryImageProgress[task.id] = {
        for (var image in galleryData.imageList.entries) image.key: 0,
      };

      // 更新任务状态为下载中
      task.status = DownloadStatus.downloading;
      task.totalBytes = galleryData.imageList.length;

      // 计算已下载的图片数量
      task.downloadedBytes = galleryData.imageList.entries.where((entry) {
        final imageId = entry.key;
        final localPath = galleryData.localPaths[imageId];
        return localPath != null && File(localPath).existsSync();
      }).length;

      await _updateTaskStatus(task);

      // 获取待下载的图片列表
      final pendingImages = galleryData.imageList.entries.where((entry) {
        final imageId = entry.key;
        final localPath = galleryData.localPaths[imageId];
        // 如果本地路径不存在，或者文件不存在，则需要下载
        return localPath == null || !File(localPath).existsSync();
      }).toList();

      // 串行下载每个图片
      for (var entry in pendingImages) {
        // 如果任务被取消，则退出循环
        if (_activeDownloads[task.id]?.isCancelled ?? true) {
          LogUtils.i('图库下载任务已取消: ${task.fileName}', 'DownloadService');
          break;
        }

        final imageId = entry.key;
        final imageUrl = entry.value;

        // 下载单个图片，支持重试一次
        bool success = false;
        for (int retry = 0; retry < 2 && !success; retry++) {
          try {
            success = await _downloadGalleryImage(
              task,
              imageUrl,
              imageId,
              galleryData.imageList.length,
            );

            if (success) {
              // 验证文件确实下载成功
              final localPath = galleryData.localPaths[imageId];
              if (localPath != null && File(localPath).existsSync()) {
                task.downloadedBytes = galleryData.imageList.entries.where((
                  entry,
                ) {
                  final imgId = entry.key;
                  final path = galleryData.localPaths[imgId];
                  return path != null && File(path).existsSync();
                }).length;
                await _repository.updateTask(task);
                // _activeTasks[task.id] = task; // 移除此行
                _notifyProgress(task.id);
              }
            } else if (retry == 1) {
              // 第二次尝试也失败，记录错误
              LogUtils.e('图片下载失败，已重试: $imageUrl', tag: 'DownloadService');
              task.error = slang.t.download.errors.partialDownloadFailed;
            }
          } catch (e) {
            LogUtils.e('下载图片出错: $imageUrl', tag: 'DownloadService', error: e);
            if (retry == 1) {
              task.error = slang.t.download.errors
                  .partialDownloadFailedWithMessage(
                    message: _getErrorMessage(e),
                  );
            }
          }

          // 如果是第一次失败，等待后重试
          if (!success && retry == 0) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      // 检查最终状态
      if (_activeDownloads[task.id]?.isCancelled ?? true) {
        // 任务被取消，更新状态为暂停
        task.status = DownloadStatus.paused;
      } else {
        // 重新获取最新的任务数据（因为可能在下载过程中已经更新）
        final galleryData = GalleryDownloadExtData.fromJson(task.extData!.data);

        // 检查是否所有图片都下载成功
        final allSuccess = galleryData.imageList.entries.every((entry) {
          final imageId = entry.key;
          final localPath = galleryData.localPaths[imageId];
          return localPath != null && File(localPath).existsSync();
        });

        task.downloadedBytes = galleryData.localPaths.entries
            .where((entry) => File(entry.value).existsSync())
            .length;

        task.status = allSuccess
            ? DownloadStatus.completed
            : DownloadStatus.failed;
        if (!allSuccess) {
          task.error = slang.t.download.errors.partialDownloadFailed;
          LogUtils.e(
            '图库下载未完全成功: ${task.downloadedBytes}/${task.totalBytes}',
            tag: 'DownloadService',
          );
        } else {
          LogUtils.i(
            '图库下载完成: ${task.downloadedBytes}/${task.totalBytes}',
            'DownloadService',
          );
        }
      }

      // 更新任务状态
      await _repository.updateTask(task);
      if (task.status == DownloadStatus.downloading) {
        _activeTasks[task.id] = task;
      } else {
        _activeTasks.remove(task.id);
      }
      _taskStatusChangedNotifier.value++; // 状态变更，通知列表刷新
      _notifyProgress(task.id); // 确保最后一次进度被更新

      // 等待一段时间后清理进度状态
      await Future.delayed(const Duration(seconds: 1));
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);
    } catch (e) {
      LogUtils.e('下载图库失败', tag: 'DownloadService', error: e);
      task.status = DownloadStatus.failed;
      task.error = _getErrorMessage(e);
      await _updateTaskStatus(task);

      // 清理进度状态
      _galleryDownloadProgress.remove(task.id);
      _galleryImageProgress.remove(task.id);
    } finally {
      // 如果不是暂停状态，清理活跃下载状态
      if (task.status != DownloadStatus.paused) {
        _activeDownloads.remove(task.id);
        _activeTasks.remove(task.id);
      }
    }
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
      // 更新下载状态为下载中
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      task.status = DownloadStatus.downloading;
      await _repository.updateTask(task);

      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: {'Accept': '*/*'}, // 接受所有类型的响应
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _updateImageProgress(task.id, imageId, received / total);
            // 这里可以考虑 notifyProgress，但图库下载通常图片较小，
            // 且 _startGalleryDownload 外层循环也会调用 notify，
            // 或者在这里也调用但要注意节流
            _notifyProgress(task.id);
          }
        },
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);

      // 更新进度
      _updateGalleryProgress(task.id, imageId, true);
      _updateImageProgress(task.id, imageId, 1.0);
      _notifyProgress(task.id); // 通知 UI 更新

      // 计算总进度
      final downloadedCount =
          _galleryDownloadProgress[task.id]?.values
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
          localPaths: {...galleryData.localPaths, imageId: savePath},
        );
        task.extData = DownloadTaskExtData(
          type: DownloadTaskExtDataType.gallery,
          data: updatedData.toJson(),
        );

        // 立即更新到数据库和内存
        await _repository.updateTask(task);
        if (task.status == DownloadStatus.downloading) {
          _activeTasks[task.id] = task;
        }
      }

      return true;
    } catch (e) {
      LogUtils.e('下载图片失败: $url', tag: 'DownloadService', error: e);
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      return false;
    }
  }

  /// 检测是否是 mikoto/phoebe 服务器错误
  bool _isMikotoPhoebeServerError(dynamic error, String url) {
    // 检查错误消息中是否包含 mikoto 或 phoebe
    if (error is DioException) {
      final message = error.message?.toLowerCase() ?? '';
      if (message.contains('mikoto') || message.contains('phoebe')) {
        return true;
      }
    } else if (error is HttpException) {
      final message = error.message.toLowerCase();
      if (message.contains('mikoto') || message.contains('phoebe')) {
        return true;
      }
    }

    // 检查 URL 中是否包含 mikoto 或 phoebe
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('mikoto.iwara.tv') ||
        lowerUrl.contains('phoebe.iwara.tv');
  }

  /// 将下载 URL 中的 mikoto/phoebe 服务器替换为 hime
  String _replaceServerToHime(String url) {
    String newUrl = url;

    // 替换 mikoto 为 hime
    if (newUrl.contains('mikoto.iwara.tv')) {
      newUrl = newUrl.replaceAll('mikoto.iwara.tv', 'hime.iwara.tv');
      LogUtils.d('已将下载链接从 mikoto 替换为 hime', 'DownloadService');
    }

    // 替换 phoebe 为 hime
    if (newUrl.contains('phoebe.iwara.tv')) {
      newUrl = newUrl.replaceAll('phoebe.iwara.tv', 'hime.iwara.tv');
      LogUtils.d('已将下载链接从 phoebe 替换为 hime', 'DownloadService');
    }

    return newUrl;
  }

  // 刷新视频任务
  // 用于更新任务的url
  // @return 返回新的任务信息，如果刷新失败则返回null
  Future<DownloadTask?> refreshVideoTask(
    DownloadTask task, {
    bool force = false,
  }) async {
    VideoDownloadExtData videoExtData = VideoDownloadExtData.fromJson(
      task.extData!.data,
    );
    final videoLink = task.url;
    final expireTime = CommonUtils.getVideoLinkExpireTime(videoLink);
    final shouldForceRefresh = force || expireTime == null;

    final isNearlyExpired =
        expireTime != null &&
        DateTime.now().isAfter(expireTime.subtract(const Duration(minutes: 1)));

    if (shouldForceRefresh || isNearlyExpired) {
      // 需要刷新链接
      String? newVideoDownloadUrl = await VideoService.to
          .getVideoDownloadUrlByIdAndQuality(
            videoExtData.id ?? '',
            videoExtData.quality!,
          );

      // 如果获取到新的链接，则更新任务信息
      if (newVideoDownloadUrl != null) {
        task.url = newVideoDownloadUrl;
        return task;
      } else {
        _showMessage(
          slang.t.download.errors.linkExpiredTryAgainFailed,
          Colors.red,
        );
        return null;
      }
    }

    // 链接尚未过期，且无需强制刷新
    return task;
  }
}

/// 视频任务重复检查结果
class VideoTaskDuplicateCheckResult {
  /// 是否存在相同视频ID但不同清晰度的任务
  final bool hasSameVideoDifferentQuality;

  /// 是否存在相同视频ID且相同清晰度的任务
  final bool hasSameVideoSameQuality;

  /// 已存在的清晰度列表
  final List<String> existingQualities;

  VideoTaskDuplicateCheckResult({
    required this.hasSameVideoDifferentQuality,
    required this.hasSameVideoSameQuality,
    required this.existingQualities,
  });
}
