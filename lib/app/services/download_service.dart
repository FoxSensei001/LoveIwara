import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class DownloadService extends GetxService {
  static DownloadService get to => Get.find<DownloadService>();
  
  static const int _pageSize = 20;
  
  final _activeTasks = <String, DownloadTask>{}.obs;
  final _completedTasks = <String, DownloadTask>{}.obs;
  final _activeDownloads = <String, CancelToken>{};
  final _downloadQueue = <String>[].obs;
  
  int _completedTasksOffset = 0;
  bool _hasMoreCompletedTasks = true;
  
  // 获取所有任务（包括活跃和已加载的已完成任务）
  Map<String, DownloadTask> get tasks => {
    ..._activeTasks,
    ..._completedTasks,
  };

  // 是否还有更多已完成的任务可以加载
  bool get hasMoreCompletedTasks => _hasMoreCompletedTasks;

  final _repository = DownloadTaskRepository();
  
  static const maxConcurrentDownloads = 3;
  final dio = Dio();
  
  List<String> get downloadQueue => _downloadQueue;
  
  // 添加任务专用的计时器映射
  final _taskTimers = <String, Timer>{};

  int get activeDownloadsCount => _activeDownloads.length;

  bool get hasActiveSlot => activeDownloadsCount < maxConcurrentDownloads;

  // 获取等待中的任务数
  int get pendingTasksCount => _downloadQueue.length;

  // 获取所有下载中的任务
  List<DownloadTask> get downloadingTasks => 
      _activeTasks.values.where((task) => task.status == DownloadStatus.downloading).toList();

  // 获取所有等待中的任务
  List<DownloadTask> get pendingTasks => 
      _activeTasks.values.where((task) => task.status == DownloadStatus.pending).toList();
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAllTasks();
  }

  // 修改加载逻辑
  Future<void> _loadAllTasks() async {
    try {
      // 加载活跃任务（包括失败的任务）
      final activeTasks = await _repository.getActiveTasks();
      _activeTasks.clear();
      _activeTasks.addAll({for (var task in activeTasks) task.id: task});
      
      // 恢复未完成的任务
      for (var task in activeTasks) {
        // 只将downloading状态的任务重置为pending并加入队列
        if (task.status == DownloadStatus.downloading) {
          task.status = DownloadStatus.pending;
          _downloadQueue.add(task.id);
        }
      }
      
      // 加载已完成任务的第一页
      final completedTasks = await _repository.getCompletedTasks(
        offset: 0,
        limit: _pageSize,
      );
      _completedTasks.clear();
      _completedTasks.addAll({for (var task in completedTasks) task.id: task});
      _completedTasksOffset = completedTasks.length;
      
      // 检查是否还有更多已完成任务
      final counts = await _repository.getTasksCount();
      _hasMoreCompletedTasks = counts['completed']! > completedTasks.length;

      LogUtils.i(
        '已加载 ${activeTasks.length} 个活跃任务（包括失败任务）, ${completedTasks.length} 个已完成任务',
        'DownloadService'
      );
      
      _processQueue();
    } catch (e) {
      LogUtils.e('加载下载任务失败', error: e);
    }
  }

  // 加载更多已完成的任务
  Future<void> loadMoreCompletedTasks() async {
    if (!_hasMoreCompletedTasks) return;

    try {
      final tasks = await _repository.getCompletedTasks(
        offset: _completedTasksOffset,
        limit: _pageSize,
      );
      
      if (tasks.isEmpty) {
        _hasMoreCompletedTasks = false;
        return;
      }

      _completedTasks.addAll({for (var task in tasks) task.id: task});
      _completedTasksOffset += tasks.length;
      
      // 如果获取的任务数少于页大小，说明没有更多任务了
      if (tasks.length < _pageSize) {
        _hasMoreCompletedTasks = false;
      }
    } catch (e) {
      LogUtils.e('加载已完成的下载任务失败', error: e);
    }
  }

  // 清理已完成任务的缓存
  void clearCompletedTasksCache() {
    _completedTasks.clear();
    _completedTasksOffset = 0;
    _hasMoreCompletedTasks = true;
  }

  Future<void> addTask(DownloadTask task) async {
    try {
      // 检查任务是否已存在
      if (_activeTasks.containsKey(task.id) || _completedTasks.containsKey(task.id)) {
        final existingTask = tasks[task.id]!;
        
        // 如果任务已完成，提示用户
        if (existingTask.status == DownloadStatus.completed) {
          throw Exception('该视频已下载');
        }
        
        // 如果任务失败或暂停，则恢复下载
        if (existingTask.status == DownloadStatus.failed || 
            existingTask.status == DownloadStatus.paused) {
          await resumeTask(task.id);
          return;
        }
        
        // 如果任务正在下载或等待下载，提示用户
        throw Exception('下载任务已存在');
      }

      // 使用事务插入任务
      await _repository.insertTaskWithTransaction(task);
      
      _activeTasks[task.id] = task;
      _downloadQueue.add(task.id);
      
      LogUtils.i('添加下载任务: ${task.fileName}', 'DownloadService');
      _processQueue();
      
    } catch (e) {
      LogUtils.e('添加下载任务失败', tag: 'DownloadService', error: e);
      _showError('添加下载任务失败: ${_getErrorMessage(e)}');
      rethrow;
    }
  }
  
  Future<void> pauseTask(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) return;
    
    if (task.status == DownloadStatus.downloading) {
      LogUtils.i('暂停下载任务: ${task.fileName}', 'DownloadService');
      _activeDownloads[taskId]?.cancel('用户暂停下载');
      _activeDownloads.remove(taskId);
      
      task.status = DownloadStatus.paused;
      _activeTasks[taskId] = task;
      await _repository.updateTask(task);
      
      // 处理等待队列中的下一个任务
      _processQueue();
    }
  }
  
  Future<void> resumeTask(String taskId) async {
    final task = _activeTasks[taskId];
    if(task == null) return;
    
    if(task.status == DownloadStatus.paused) {
      task.status = DownloadStatus.pending;
      _downloadQueue.add(taskId);
      _activeTasks[taskId] = task;
      
      _processQueue();
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    final task = _activeTasks[taskId];
    if(task == null) return;
    
    try {
      LogUtils.i('开始删除下载任务: ${task.fileName}', 'DownloadService');
      
      // 如果正在下载,先取消下载
      if(task.status == DownloadStatus.downloading) {
        await pauseTask(taskId);
      }
      
      // 删除已下载的文件
      try {
        final file = File(task.savePath);
        if(await file.exists()) {
          await file.delete();
          LogUtils.d('已删除文件: ${task.savePath}', 'DownloadService');
        }
      } catch(e) {
        LogUtils.e('删除文件失败: ${task.savePath}', tag: 'DownloadService', error: e);
      }
      
      // 从数据库中删除任务记录
      await _repository.deleteTask(taskId);
      LogUtils.d('已从数据库删除任务记录', 'DownloadService');
      
      // 从内存中移除任务
      _activeTasks.remove(taskId);
      _downloadQueue.remove(taskId);
      
      LogUtils.i('下载任务删除完成: ${task.fileName}', 'DownloadService');
    } catch(e) {
      LogUtils.e('删除下载任务失败', tag: 'DownloadService', error: e);
      rethrow;
    }
  }

  void _processQueue() async {
    // 检查当前活动下载数量是否达到上限
    if (_activeDownloads.length >= maxConcurrentDownloads) {
      LogUtils.d(
        '当前活动下载数: ${_activeDownloads.length}, 已达到最大并发数: $maxConcurrentDownloads',
        'DownloadService'
      );
      return;
    }

    // 检查下载队列是否为空
    if (_downloadQueue.isEmpty) {
      LogUtils.d('下载队列为空', 'DownloadService');
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
      'DownloadService'
    );
    
    await _startDownload(task);
  }
  
  Future<void> _startDownload(DownloadTask task) async {
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
          LogUtils.d('从content-length获取文件大小: ${task.totalBytes}', 'DownloadService');
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
            final match = RegExp(r'bytes \d+-\d+/(\d+)').firstMatch(contentRange);
            if (match != null) {
              task.totalBytes = int.parse(match.group(1)!);
              LogUtils.d('从content-range获取文件大小: ${task.totalBytes}', 'DownloadService');
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
          headers: task.downloadedBytes > 0 ? {
            'Range': 'bytes=${task.downloadedBytes}-'
          } : null
        ),
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
            'DownloadService'
          );
        } else {
          LogUtils.d(
            '[${task.fileName}] 已下载: ${task.downloadedBytes} bytes, '
            '速度: ${(task.speed / 1024 / 1024).toStringAsFixed(2)}MB/s',
            'DownloadService'
          );
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
      
    } catch(e) {
      if (e is DioException) {
        final errorMsg = _getErrorMessage(e);
        LogUtils.e('下载失败: $errorMsg', tag: 'DownloadService', error: e);
        _showError(errorMsg);
        
      } else if (e is FileSystemException) {
        final errorMsg = '文件系统错误: ${e.message}';
        LogUtils.e(errorMsg, tag: 'DownloadService', error: e);
        _showError(errorMsg);
        
      } else {
        final errorMsg = '未知错误: $e';
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
  Future<void> _cleanupDownload(
    DownloadTask task, 
    RandomAccessFile? raf, 
    StreamSubscription? subscription
  ) async {
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
  }

  Future<void> _updateTaskStatus(DownloadTask task) async {
    if (task.status == DownloadStatus.completed) {
      // 如果任务完成，从活跃任务移到已完成任务
      _activeTasks.remove(task.id);
      _completedTasks[task.id] = task;
    } else {
      _activeTasks[task.id] = task;
    }
    await _repository.updateTask(task);
  }

  String _getErrorMessage(dynamic error) {
    if(error is DioException) {
      switch(error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时';
        case DioExceptionType.sendTimeout:
          return '发送超时';
        case DioExceptionType.receiveTimeout:
          return '接收超时';
        case DioExceptionType.badResponse:
          return '服务器错误(${error.response?.statusCode})';
        default:
          return error.message ?? '未知网络错误';
      }
    } else if(error is FileSystemException) {
      return '文件系统错误: ${error.message}';
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
    final failedTasks = _activeTasks.values.where((task) => task.status == DownloadStatus.failed).toList();
    
    for (var task in failedTasks) {
      await deleteTask(task.id);
    }
  }

  @override
  void onClose() {
    // 取消所有下载
    for (var cancelToken in _activeDownloads.values) {
      cancelToken.cancel('Service is closing');
    }
    _activeDownloads.clear();

    // 清理所有计时器
    for (var timer in _taskTimers.values) {
      timer.cancel(); 
    }
    _taskTimers.clear();

    // 清理其他资源
    _activeTasks.clear();
    _completedTasks.clear();
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
} 