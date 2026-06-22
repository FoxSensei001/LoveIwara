import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
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

  /// 已派发「终态通知」（完成/失败）的任务 id 集合，用于去重：
  /// 同一次终态转换只通知一次。当任务重新回到非终态（pending/downloading/
  /// paused）时会从集合移除，从而允许「续传后再次失败」「重下后再次完成」等
  /// 真正的新一次终态再次通知。
  final Set<String> _notifiedTerminalTaskIds = <String>{};

  /// 允许的并发下载数范围
  static const minConcurrentDownloads = 1;
  static const maxConcurrentDownloadsLimit = 5;
  static const defaultConcurrentDownloads = 3;

  /// 最大并发下载数，可在设置中调整（[minConcurrentDownloads]~[maxConcurrentDownloadsLimit]）。
  /// 读取配置失败时回退默认值，保证下载流程不被配置异常阻断。
  int get maxConcurrentDownloads {
    try {
      if (Get.isRegistered<ConfigService>()) {
        final v =
            Get.find<ConfigService>()[ConfigKey.MAX_CONCURRENT_DOWNLOADS]
                as int;
        return v.clamp(minConcurrentDownloads, maxConcurrentDownloadsLimit);
      }
    } catch (e) {
      LogUtils.w('读取最大并发下载数配置失败，使用默认值: $e', 'DownloadService');
    }
    return defaultConcurrentDownloads;
  }

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
  // 取消后的资源清理 Future，key 是任务 id。
  // 取消（pause/delete）会触发 whenCancel 异步关闭 raf/取消订阅，
  // deleteTask 删除文件前需要 await 它，确保文件句柄已真正释放（尤其 Windows）。
  final _cancelCleanupFutures = <String, Future<void>>{};
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

  bool _enqueueTaskId(String taskId) {
    if (_downloadQueue.contains(taskId) ||
        _activeDownloads.containsKey(taskId)) {
      LogUtils.d('任务已在队列或下载中，跳过重复入队: $taskId', 'DownloadService');
      return false;
    }
    _downloadQueue.add(taskId);
    return true;
  }

  bool _galleryImageExists(GalleryDownloadExtData galleryData, String imageId) {
    final localPath = galleryData.localPaths[imageId];
    return localPath != null && File(localPath).existsSync();
  }

  int _countDownloadedGalleryImages(GalleryDownloadExtData galleryData) {
    return galleryData.imageList.keys
        .where((imageId) => _galleryImageExists(galleryData, imageId))
        .length;
  }

  void _syncGalleryProgressFromData(
    String taskId,
    GalleryDownloadExtData galleryData,
  ) {
    final previousImageProgress = _galleryImageProgress[taskId] ?? {};
    _galleryDownloadProgress[taskId] = {
      for (final imageId in galleryData.imageList.keys)
        imageId: _galleryImageExists(galleryData, imageId),
    };
    _galleryImageProgress[taskId] = {
      for (final imageId in galleryData.imageList.keys)
        imageId: _galleryImageExists(galleryData, imageId)
            ? 1.0
            : previousImageProgress[imageId] ?? 0.0,
    };
  }

  void _refreshGalleryTaskProgress(
    DownloadTask task,
    GalleryDownloadExtData galleryData,
  ) {
    _syncGalleryProgressFromData(task.id, galleryData);
    task.totalBytes = galleryData.imageList.length;
    task.downloadedBytes = _countDownloadedGalleryImages(galleryData);
  }

  static String _safeExtensionFromUrl(String url) {
    String extension = '';
    try {
      extension = path_lib.extension(Uri.parse(url).path);
    } catch (_) {
      extension = path_lib.extension(url.split('?').first);
    }

    if (!RegExp(r'^\.[A-Za-z0-9]{1,10}$').hasMatch(extension)) {
      return '.jpg';
    }
    return extension;
  }

  static String buildGalleryImageSavePath({
    required String galleryDirectory,
    required String imageId,
    required String url,
  }) {
    final fileName =
        '${FilenameTemplateService.sanitizePathSegment(imageId, fallback: 'image')}${_safeExtensionFromUrl(url)}';
    return DownloadPathService.safeJoinUnderBase(galleryDirectory, [fileName]);
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
        _enqueueTaskId(task.id);
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

    final requestedSavePath = CommonUtils.formatSavePathUriByPath(
      task.savePath,
    );
    task.savePath = requestedSavePath;
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

      task.savePath = await _resolveUniqueTaskSavePath(task, requestedSavePath);

      task.status = DownloadStatus.pending;
      await _insertTaskWithSavePathRetry(task, requestedSavePath);

      // 仅添加到下载队列，pending 任务不常驻内存
      _enqueueTaskId(task.id);

      LogUtils.i('添加下载任务: ${task.fileName}', 'DownloadService');
      _processQueue();
    } on DuplicateDownloadTaskException catch (e) {
      final message = switch (e.type) {
        DownloadTaskConflictType.media =>
          slang.t.download.errors.downloadTaskAlreadyExists,
        DownloadTaskConflictType.savePath =>
          slang.t.download.errors.downloadTaskSavePathConflict,
        DownloadTaskConflictType.id =>
          slang.t.download.errors.downloadFailedForMessage(
            errorInfo: _getErrorMessage(e),
          ),
      };
      _showMessage(message, Colors.orange);
      throw Exception(message);
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

  bool _taskUsesDirectorySavePath(DownloadTask task) {
    return task.extData?.type == DownloadTaskExtDataType.gallery;
  }

  Future<String> _resolveUniqueTaskSavePath(
    DownloadTask task,
    String requestedSavePath,
  ) {
    return DownloadPathService.resolveAvailablePath(
      requestedSavePath,
      isDirectory: _taskUsesDirectorySavePath(task),
      isReserved: (candidate) {
        final normalized = CommonUtils.formatSavePathUriByPath(candidate);
        return _repository.existsTaskBySavePath(normalized);
      },
    );
  }

  Future<void> _insertTaskWithSavePathRetry(
    DownloadTask task,
    String requestedSavePath,
  ) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _repository.insertTask(task);
        return;
      } on DuplicateDownloadTaskException catch (e) {
        if (e.type == DownloadTaskConflictType.savePath && attempt < 2) {
          task.savePath = await _resolveUniqueTaskSavePath(
            task,
            requestedSavePath,
          );
          continue;
        }
        rethrow;
      }
    }
  }

  // 暂停任务 [内存 -> 数据库]
  Future<void> pauseTask(String taskId) async {
    if (_processingTaskIds.contains(taskId)) {
      return;
    }
    _processingTaskIds.add(taskId);

    LogUtils.d('暂停任务: $taskId', 'DownloadService');

    try {
      // 优先从内存中获取下载中任务，如不存在则从数据库获取
      final task =
          _activeTasks[taskId] ?? await _repository.getTaskById(taskId);
      if (task == null) {
        LogUtils.d('任务不存在: $taskId', 'DownloadService');
        return;
      }

      task.status = DownloadStatus.paused;
      // [优先更新持久化信息]
      await _repository.updateTask(task);

      // 清理内存前先判断是否真有进行中的下载，供取消等待判断是否需要兜底延时。
      final hadActiveDownload = _activeDownloads.containsKey(taskId);

      // 从内存/队列中移除、取消下载、移除计时器
      _clearMemoryTask(taskId, '用户暂停下载');
      await _waitForCancelCleanup(taskId, hadActiveDownload: hadActiveDownload);

      // 通知UI变更
      _taskStatusChangedNotifier.value++;

      // 处理等待队列中的下一个任务
      _processQueue();
    } finally {
      _processingTaskIds.remove(taskId);
    }
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
            // 此路径不经过 _updateTaskStatus，需显式派发终态通知。
            await _dispatchTerminalNotification(task);
            _clearMemoryTask(taskId, '刷新视频任务失败，无法处理');
            LogUtils.d('刷新视频任务失败，无法处理: $taskId', 'DownloadService');
            return;
          }
        } else {
          task.status = DownloadStatus.pending;
          await _repository.updateTask(task);
        }

        // 重新回到等待队列，解除终态通知去重，允许后续真正的新终态再次通知。
        _notifiedTerminalTaskIds.remove(taskId);
        // 仅将任务 id 加入等待队列，pending 任务不常驻内存
        _enqueueTaskId(taskId);

        // 通知任务状态变更
        _taskStatusChangedNotifier.value++;

        _processQueue();
      }
    } finally {
      _processingTaskIds.remove(taskId);
    }
  }

  /// 全部暂停：暂停所有「下载中」+「等待中」的任务
  Future<void> pauseAll() async {
    LogUtils.i('全部暂停', 'DownloadService');
    final ids = <String>{};
    ids.addAll(_activeTasks.keys);
    ids.addAll(_downloadQueue);
    try {
      final tasks = await _repository
          .getDownloadingAndPendingTasksOrderByCreatedAtAsc();
      ids.addAll(tasks.map((t) => t.id));
    } catch (e) {
      LogUtils.w('全部暂停时获取待暂停任务失败: $e', 'DownloadService');
    }
    for (final id in ids) {
      await pauseTask(id);
    }
  }

  /// 全部开始：恢复所有「已暂停」的任务
  Future<void> resumeAll() async {
    LogUtils.i('全部开始', 'DownloadService');
    try {
      final paused = await _repository.getAllTasksByStatus(
        DownloadStatus.paused,
      );
      for (final task in paused) {
        await resumeTask(task.id);
      }
    } catch (e) {
      LogUtils.w('全部开始失败: $e', 'DownloadService');
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
    // 释放终态通知去重令牌：删除/暂停等清理后，集合不再无界增长；任务若再次
    // 进入终态（如重下）会被当作一次新的终态正常通知。
    _notifiedTerminalTaskIds.remove(taskId);
    // 不立即移除 _progressTriggers，因为 UI 可能还在监听，让它自然回收或在适当时候清理
  }

  /// 等待被取消任务的资源（文件句柄/订阅）真正释放后再返回。
  ///
  /// [hadActiveDownload] 表示调用方在清理内存前该任务确有进行中的下载。
  /// 若任务原本就处于 pending/已暂停（没有 dio/stream 在跑），则无需等待，
  /// 直接返回，避免对图库等无清理回调的任务白等 500ms。
  Future<void> _waitForCancelCleanup(
    String taskId, {
    required bool hadActiveDownload,
  }) async {
    if (!hadActiveDownload) return;

    for (var i = 0; i < 3; i++) {
      final cleanup = _cancelCleanupFutures[taskId];
      if (cleanup != null) {
        try {
          await cleanup;
        } catch (_) {}
        return;
      }
      await Future<void>.delayed(Duration.zero);
    }

    // 图库下载没有 RandomAccessFile 清理回调；视频回调若尚未注册，也给
    // dio/stream 取消路径一个短暂窗口，避免立即重启或删除同一路径。
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  static String _deleteComparisonPath(String rawPath) {
    final normalized = path_lib.normalize(path_lib.absolute(rawPath));
    return Platform.isWindows ? normalized.toLowerCase() : normalized;
  }

  static bool _sameDeletePath(String left, String right) {
    return _deleteComparisonPath(left) == _deleteComparisonPath(right);
  }

  /// 用户主目录：*nix 走 HOME，Windows 走 USERPROFILE（Windows 上通常没有 HOME）。
  static String? get _userHomeDirectory {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) return home;
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null && userProfile.isNotEmpty) return userProfile;
    return null;
  }

  static bool _isProtectedRecursiveDeletePath(String targetPath) {
    final protectedPaths = <String>[
      path_lib.separator,
      // 文件系统根（含 Windows 盘符根，如 C:\）也视为受保护，避免误删整个磁盘。
      path_lib.rootPrefix(targetPath),
      if (_userHomeDirectory case final home?) ...[
        home,
        path_lib.join(home, 'Desktop'),
        path_lib.join(home, 'Documents'),
        path_lib.join(home, 'Downloads'),
        path_lib.join(home, 'Pictures'),
        path_lib.join(home, 'Movies'),
        path_lib.join(home, 'Music'),
      ],
    ];

    return protectedPaths.any((protectedPath) {
      return protectedPath.isNotEmpty &&
          _sameDeletePath(targetPath, protectedPath);
    });
  }

  static bool isSafeDeleteTarget(
    String rawPath,
    FileSystemEntityType entityType,
  ) {
    if (rawPath.trim().isEmpty) return false;

    final targetPath = _deleteComparisonPath(rawPath);
    final basename = path_lib.basename(targetPath);
    if (basename.isEmpty || basename == '.' || basename == '..') {
      return false;
    }

    final parent = path_lib.dirname(targetPath);
    if (parent == targetPath) return false;

    if (entityType == FileSystemEntityType.directory &&
        _isProtectedRecursiveDeletePath(targetPath)) {
      return false;
    }

    return true;
  }

  Future<List<String>> _knownDownloadRoots() async {
    final roots = <String>[];

    try {
      final defaultDir = await CommonUtils.getAppDirectory(
        pathSuffix: 'downloads',
      );
      roots.add(defaultDir.path);
    } catch (e) {
      LogUtils.w('获取默认下载根目录失败: $e', 'DownloadService');
    }

    try {
      if (Get.isRegistered<ConfigService>()) {
        final configService = Get.find<ConfigService>();
        final isCustomPathEnabled =
            configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
        final customPath =
            configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
        if (isCustomPathEnabled && customPath.trim().isNotEmpty) {
          roots.add(customPath);
        }
      }
    } catch (e) {
      LogUtils.w('获取自定义下载根目录失败: $e', 'DownloadService');
    }

    return roots.toSet().toList();
  }

  Future<bool> _isSafeDeleteTargetForTask(
    DownloadTask task,
    FileSystemEntityType entityType,
  ) async {
    if (!isSafeDeleteTarget(task.savePath, entityType)) return false;
    if (entityType != FileSystemEntityType.directory) return true;

    final roots = await _knownDownloadRoots();
    if (roots.isEmpty) return true;

    return roots.any((root) {
      return DownloadPathService.isPathInsideBase(root, task.savePath);
    });
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
        // 等待 whenCancel 真正关闭文件句柄/取消订阅再删文件，避免「句柄未释放」
        // 导致删除失败（Windows 上尤为明显）。拿不到清理 Future 时退回短延时兜底。
        await _waitForCancelCleanup(taskId, hadActiveDownload: true);
      }

      // 尝试删除文件，支持重试
      bool isDeleteSuccess = false;
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 300);
      final deleteTargetType = FileSystemEntity.typeSync(task.savePath);

      if (!await _isSafeDeleteTargetForTask(task, deleteTargetType)) {
        LogUtils.e('拒绝删除不安全的下载目标: ${task.savePath}', tag: 'DownloadService');
        if (!ignoreFileDeleteError) {
          _showMessage(slang.t.download.errors.deleteFileError, Colors.red);
          return;
        }
        isDeleteSuccess = true;
      }

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

  // 批量删除任务
  Future<void> deleteTasks(
    List<String> taskIds, {
    bool ignoreFileDeleteError = false,
  }) async {
    for (final taskId in taskIds) {
      await deleteTask(taskId, ignoreFileDeleteError: ignoreFileDeleteError);
    }
  }

  /// 外部（如设置页调高并发数后）主动触发队列检查，立即启动更多等待中任务。
  void kickQueue() => _processQueue();

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
        // 先「同步」从队首取出并移除任务 id，再去 await 查库。
        // 关键：不能「读队首 -> await -> removeAt(0)」，因为 await 期间用户
        // pause/delete 会按值 _downloadQueue.remove(taskId)，队首可能已前移，
        // 此时 removeAt(0) 会误删另一个 pending 任务，导致其永不下载（卡死）。
        final taskId = _downloadQueue.removeAt(0);

        // 通过数据库获取最新任务信息，pending 任务不常驻内存
        final task = await _repository.getTaskById(taskId);

        // 仅对仍为 pending 的任务进行下载；否则跳过（已被取出，无需再移除）
        if (task == null ||
            task.status != DownloadStatus.pending ||
            _activeDownloads.containsKey(taskId)) {
          continue; // 继续处理队列中的下一个任务
        }

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

    // 取消处理只注册一次。绝不能放进重试循环：否则每轮重试都会注册一个
    // whenCancel 回调，取消时会触发 N 次清理与状态写入，造成状态抖动。
    // 闭包按引用捕获 raf/subscription，取消触发时读到的是最新一轮的值。
    bool cancelHandled = false;
    cancelToken.whenCancel.then((_) {
      if (cancelHandled) return;
      cancelHandled = true;
      final cleanup = () async {
        LogUtils.i('下载已取消: ${task.fileName}', 'DownloadService');
        await _cleanupDownload(task, raf, subscription);
        // 取消即视为暂停。pauseTask 可能已先把状态写成 paused，这里幂等确保一次；
        // 但若调用方已将其置为 completed/failed 等终态，则不覆盖。
        if (task.status != DownloadStatus.completed &&
            task.status != DownloadStatus.failed) {
          task.status = DownloadStatus.paused;
          await _updateTaskStatus(task);
        }
      }();
      _cancelCleanupFutures[task.id] = cleanup;
      cleanup.whenComplete(() => _cancelCleanupFutures.remove(task.id));
    });

    while (retryCount < maxRetries) {
      try {
        LogUtils.i(
          '开始下载任务: ${task.fileName} (重试次数: $retryCount)',
          'DownloadService',
        );

        // 验证已下载的部分。
        // downloadedBytes 是每秒节流写库的，崩溃/被杀时磁盘实际字节往往比库里
        // 记录的「多」一点。因此一律以磁盘实际大小为准来续传，而不是因为
        // 「磁盘比记录大」就删档从头下——否则节流写库会让断点续传几乎永远失效。
        final file = File(task.savePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (task.totalBytes > 0 && fileSize > task.totalBytes) {
            // 磁盘文件比总大小还大，说明文件确实损坏，删档重下
            LogUtils.w(
              '本地文件($fileSize)大于总大小(${task.totalBytes})，删档重下: ${task.fileName}',
              'DownloadService',
            );
            task.downloadedBytes = 0;
            await file.delete();
          } else {
            // 以磁盘实际大小为准续传（含 fileSize 大于/小于记录两种情况）
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
            // 用 tryParse 兜底：content-length 异常/非法时保持 totalBytes=0（按未知大小处理），
            // 而非抛 FormatException 让整个下载以"未知错误"失败
            final parsed = int.tryParse(contentLength.trim());
            if (parsed != null) {
              task.totalBytes = parsed;
              LogUtils.d('从下载响应获取文件大小: ${task.totalBytes}', 'DownloadService');
            } else {
              LogUtils.w(
                '无法解析 content-length: $contentLength',
                'DownloadService',
              );
            }
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
          (chunk) async {
            try {
              final localRaf = raf;
              if (localRaf != null) {
                // 暂停流背压：异步写盘期间不投递下一个 chunk，保证写入顺序，
                // 同时避免 writeFromSync 同步写大块时卡住 UI 线程（Windows 上
                // 杀毒实时扫描会让同步写偶发阻塞数秒）。
                subscription?.pause();
                try {
                  await localRaf.writeFrom(chunk);
                } finally {
                  subscription?.resume();
                }
                // chunk.length 在该 stream 中被推断为 num，需显式转 int
                task.downloadedBytes += (chunk.length as int);
                // 不再直接更新 _activeTasks以避免触发整个列表的重建
                // _activeTasks[task.id] = task;

                // 而是触发单个任务的进度通知
                _notifyProgress(task.id);
              }
            } catch (e) {
              LogUtils.e('写入文件失败: $e', tag: 'DownloadService', error: e);
              // 释放资源后再通过 completer 传递错误（与 onDone 错误路径一致）。
              // 不能直接 throw：onData 中抛出的异常不会进入 stream 的 onError，
              // 会变成 zone 未捕获错误，且 completer 永不完成 → 任务卡在
              // downloading 状态、raf 与 _taskTimers 泄漏。
              await _releaseResources(task, raf, subscription);
              if (!completer.isCompleted) {
                completer.completeError(
                  FileSystemException(
                    message: slang.t.download.errors.writeFileFailedForMessage(
                      errorInfo: '$e',
                    ),
                    type: FileErrorType.ioError,
                  ),
                );
              }
            }
          },
          onDone: () async {
            LogUtils.i('下载完成: ${task.fileName}', 'DownloadService');

            int finalSize;
            try {
              // 确保缓冲区写入磁盘后再校验大小
              final localRaf = raf;
              try {
                await localRaf?.flush();
              } catch (_) {}
              finalSize = localRaf != null
                  ? await localRaf.length()
                  : await file.length();
              if (task.totalBytes > 0 && finalSize != task.totalBytes) {
                final integrityError = FileSystemException(
                  message: '文件大小不匹配，预期: ${task.totalBytes}，实际: $finalSize',
                  type: FileErrorType.ioError,
                );

                // 先释放资源，再把错误交给外层处理（重试或失败）
                await _releaseResources(task, raf, subscription);
                completer.completeError(integrityError);
                return; // 必须 return，避免继续走“成功完成”的逻辑
              }
            } catch (e) {
              await _releaseResources(task, raf, subscription);
              completer.completeError(e);
              return;
            }

            // 正常完成路径
            await _cleanupDownload(task, raf, subscription);
            task.status = DownloadStatus.completed;
            // 若服务端未提供大小（totalBytes==0，无法做完整性校验），以磁盘
            // 实际写入大小作为最终大小，避免把 downloadedBytes/totalBytes 错误
            // 清零，否则 UI 会显示「0 字节」、缓存判定也会异常。
            if (task.totalBytes > 0) {
              task.downloadedBytes = task.totalBytes;
            } else {
              task.totalBytes = finalSize;
              task.downloadedBytes = finalSize;
              LogUtils.w(
                '下载完成但服务端未提供大小，按实际写入大小记录: $finalSize (${task.fileName})',
                'DownloadService',
              );
            }
            task.completedAt = DateTime.now();
            await _updateTaskStatus(task);
            completer.complete();
            _processQueue();
          },
          onError: (error) async {
            // 取消（pause/delete）会让 stream 抛出 DioException(cancel)。
            // 取消的状态写入统一交给上面的 whenCancel 路径处理，这里绝不能把
            // 取消当成 failed 写库——否则会与 whenCancel 写 paused 形成竞态，
            // 最终状态不确定（“取消后却显示失败”）。
            if (error is DioException &&
                error.type == DioExceptionType.cancel) {
              await _releaseResources(task, raf, subscription);
              if (!completer.isCompleted) {
                completer.completeError(error);
              }
              return;
            }
            LogUtils.e('下载出错: $error', tag: 'DownloadService', error: error);
            try {
              await _releaseResources(task, raf, subscription);

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

  // 释放资源（不移除 activeDownloads）
  Future<void> _releaseResources(
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

    // 清理任务专用的计时器
    _taskTimers[task.id]?.cancel();
    _taskTimers.remove(task.id);
  }

  // 完全清理下载任务（移除 activeDownloads）
  Future<void> _cleanupDownload(
    DownloadTask task,
    RandomAccessFile? raf,
    StreamSubscription? subscription,
  ) async {
    await _releaseResources(task, raf, subscription);

    _activeDownloads.remove(task.id);

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

    // 统一的终态通知派发入口（视频完成/失败、图库 outer-catch 失败均走此处）。
    await _dispatchTerminalNotification(task);
  }

  /// 取任务的展示标题：优先用扩展数据里的媒体标题，回退到文件名。
  String _noticeTitleFor(DownloadTask task) {
    try {
      final ext = task.extData;
      if (ext != null) {
        final title = ext.data['title'] as String?;
        if (title != null && title.trim().isNotEmpty) {
          return title;
        }
      }
    } catch (_) {
      // 忽略解析异常，回退到文件名
    }
    return task.fileName;
  }

  /// 在任务进入终态（完成/失败）时，统一派发：应用内通知中心记录 + 即时 toast +
  /// 系统通知。通过 [_notifiedTerminalTaskIds] 去重，保证每次终态转换仅触发一次；
  /// 非终态调用则重新「武装」该任务，允许后续真正的新终态再次通知。
  ///
  /// 该方法可能从多个站点被调用（_updateTaskStatus、图库主完成路径、续传刷新失败
  /// 路径），去重集合使重复路由无害。
  Future<void> _dispatchTerminalNotification(DownloadTask task) async {
    final isCompleted = task.status == DownloadStatus.completed;
    final isFailed = task.status == DownloadStatus.failed;

    if (!isCompleted && !isFailed) {
      // 非终态：重新武装，允许后续真正的新终态再次通知。
      _notifiedTerminalTaskIds.remove(task.id);
      return;
    }

    // 总开关：统一控制系统通知 + 应用内通知 + toast。
    // 注意要在去重 add 之前判断——关闭时直接返回，不消费去重令牌，
    // 这样后续真正开启后该任务的新终态仍能正常通知。
    try {
      if (Get.isRegistered<ConfigService>()) {
        final enabled =
            Get.find<ConfigService>()[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED]
                as bool? ??
            true;
        if (!enabled) return;
      }
    } catch (e) {
      LogUtils.w('读取下载通知开关失败，按开启处理: $e', 'DownloadService');
    }

    // 去重：同一次终态转换只通知一次。
    if (!_notifiedTerminalTaskIds.add(task.id)) {
      return;
    }

    final title = _noticeTitleFor(task);

    try {
      // 1) 即时应用内 toast
      if (Get.isRegistered<MessageService>()) {
        Get.find<MessageService>().showMessage(
          isCompleted
              ? slang.t.downloadNotifications.completedToast(name: title)
              : slang.t.downloadNotifications.failedToast(name: title),
          isCompleted ? MDToastType.success : MDToastType.error,
        );
      }

      // 2) 系统通知（不 await：Android 首次可能弹权限框，避免阻塞下载队列推进）
      if (Get.isRegistered<DownloadNotificationService>()) {
        final svc = Get.find<DownloadNotificationService>();
        unawaited(
          isCompleted
              ? svc.showDownloadComplete(taskId: task.id, title: title)
              : svc.showDownloadFailed(
                  taskId: task.id,
                  title: title,
                  error: task.error,
                ),
        );
      }
    } catch (e) {
      LogUtils.e('派发下载终态通知失败', tag: 'DownloadService', error: e);
    }
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
      // 解除终态通知去重，重下完成/失败时可再次通知。
      _notifiedTerminalTaskIds.remove(taskId);
      _enqueueTaskId(taskId);
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
  /// 返回 `Map<String, String>`，key 为图片ID，value 为本地文件路径
  /// 如果没有找到已完成的下载任务或文件不存在则返回空 Map
  Future<Map<String, String>> getCompletedGalleryLocalPaths(
    String galleryId,
  ) async {
    try {
      // 走 (media_type, media_id) 索引精确取该图库的任务，避免全表扫描已完成任务
      final tasks = await _repository.getTasksByMedia('gallery', galleryId);

      // 找到匹配图库ID且已完成的任务
      for (final task in tasks) {
        if (task.status == DownloadStatus.completed &&
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
    _notifiedTerminalTaskIds.clear();

    super.onClose();
  }

  /// 统一通过 [MessageService]（oktoast）展示提示，替代散落的原生 SnackBar。
  /// 沿用旧签名（含 [Color]）以免改动十余处调用点：红色映射为 error，其余为 info。
  void _showMessage(String message, Color color) {
    final type = color == Colors.red ? MDToastType.error : MDToastType.info;
    if (Get.isRegistered<MessageService>()) {
      Get.find<MessageService>().showMessage(message, type);
    } else {
      LogUtils.w('MessageService 未注册，跳过提示: $message', 'DownloadService');
    }
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

      // 更新任务状态为下载中
      task.status = DownloadStatus.downloading;
      _refreshGalleryTaskProgress(task, galleryData);

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
              cancelToken,
            );

            if (success) {
              // 验证文件确实下载成功
              final latestGalleryData = GalleryDownloadExtData.fromJson(
                task.extData!.data,
              );
              if (_galleryImageExists(latestGalleryData, imageId)) {
                _refreshGalleryTaskProgress(task, latestGalleryData);
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
        final latestGalleryData = GalleryDownloadExtData.fromJson(
          task.extData!.data,
        );

        // 检查是否所有图片都下载成功
        final allSuccess = latestGalleryData.imageList.keys.every((imageId) {
          return _galleryImageExists(latestGalleryData, imageId);
        });

        _refreshGalleryTaskProgress(task, latestGalleryData);

        task.status = allSuccess
            ? DownloadStatus.completed
            : DownloadStatus.failed;
        if (allSuccess) {
          task.completedAt = DateTime.now();
        }
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

      // 图库主完成/部分失败路径不经过 _updateTaskStatus，需显式派发终态通知。
      await _dispatchTerminalNotification(task);

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
    CancelToken cancelToken,
  ) async {
    final savePath = buildGalleryImageSavePath(
      galleryDirectory: task.savePath,
      imageId: imageId,
      url: url,
    );

    RandomAccessFile? raf;
    try {
      // 更新下载状态为下载中
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      task.status = DownloadStatus.downloading;
      await _repository.updateTask(task);

      // 使用流式下载并直接写盘，避免把整张原图（可能数十 MB）读进内存；
      // 同时传入 cancelToken，使暂停能立即中断当前图片下载而非等整张下完。
      final response = await dio.get(
        url,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: true,
          headers: {'Accept': '*/*'}, // 接受所有类型的响应
        ),
      );

      final total =
          int.tryParse(response.headers.value('content-length') ?? '') ?? -1;
      final file = File(savePath);
      await file.parent.create(recursive: true);
      raf = await file.open(mode: FileMode.writeOnly);
      int received = 0;
      await for (final chunk in (response.data.stream as Stream<List<int>>)) {
        // 异步写入，避免同步写盘在 Windows 上被杀毒实时扫描卡住 UI
        await raf.writeFrom(chunk);
        received += chunk.length;
        if (total > 0) {
          _updateImageProgress(task.id, imageId, received / total);
          _notifyProgress(task.id);
        }
      }
      await raf.close();
      raf = null;

      // 更新进度
      _updateGalleryProgress(task.id, imageId, true);
      _updateImageProgress(task.id, imageId, 1.0);
      _notifyProgress(task.id); // 通知 UI 更新

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
        _refreshGalleryTaskProgress(task, updatedData);

        // 立即更新到数据库和内存
        await _repository.updateTask(task);
        if (task.status == DownloadStatus.downloading) {
          _activeTasks[task.id] = task;
        }
      }

      return true;
    } catch (e) {
      // 关闭可能未关闭的文件句柄，避免泄漏
      if (raf != null) {
        try {
          await raf.close();
        } catch (_) {}
      }
      LogUtils.e('下载图片失败: $url', tag: 'DownloadService', error: e);
      _updateGalleryProgress(task.id, imageId, false);
      _updateImageProgress(task.id, imageId, 0);
      return false;
    }
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
