import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class DownloadService extends GetxService {
  static DownloadService get to => Get.find();
  
  final _tasks = <String, DownloadTask>{}.obs;
  final _activeDownloads = <String, CancelToken>{};
  final _downloadQueue = <String>[].obs;
  final _repository = DownloadTaskRepository();
  
  static const maxConcurrentDownloads = 3;
  final dio = Dio();
  
  Map<String, DownloadTask> get tasks => _tasks;
  List<String> get downloadQueue => _downloadQueue;
  
  // 添加节流控制相关属性
  Timer? _progressUpdateTimer;
  final _pendingProgressUpdates = <String>{};
  
  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAllTasks();
      _tasks.addAll({for (var task in tasks) task.id: task});
      
      // 恢复未完成的任务
      for (var task in tasks) {
        if (task.status == DownloadStatus.downloading) {
          task.status = DownloadStatus.pending;
          _downloadQueue.add(task.id);
        }
      }
      
      _processQueue();
    } catch (e) {
      LogUtils.e('加载下载任务失败', error: e);
    }
  }

  Future<void> addTask(DownloadTask task) async {
    // 检查任务是否已存在
    if(_tasks.containsKey(task.id)) {
      final existingTask = _tasks[task.id]!;
      // 如果任务已完成，提示用户
      if(existingTask.status == DownloadStatus.completed) {
        throw Exception('该视频已下载');
      }
      // 如果任务失败或暂停，则恢复下载
      if(existingTask.status == DownloadStatus.failed || 
         existingTask.status == DownloadStatus.paused) {
        await resumeTask(task.id);
        return;
      }
      throw Exception('下载任务已存在');
    }
    
    LogUtils.d('添加下载任务: ${task.fileName}', 'DownloadService');
    await _repository.insertTask(task);
    _tasks[task.id] = task;
    _downloadQueue.add(task.id);
    
    _processQueue();
  }
  
  Future<void> pauseTask(String taskId) async {
    final task = _tasks[taskId];
    if(task == null) return;
    
    if(task.status == DownloadStatus.downloading) {
      _activeDownloads[taskId]?.cancel('用户暂停下载');
      _activeDownloads.remove(taskId);
    }
    
    task.status = DownloadStatus.paused;
    _tasks[taskId] = task;
  }
  
  Future<void> resumeTask(String taskId) async {
    final task = _tasks[taskId];
    if(task == null) return;
    
    if(task.status == DownloadStatus.paused) {
      task.status = DownloadStatus.pending;
      _downloadQueue.add(taskId);
      _tasks[taskId] = task;
      
      _processQueue();
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    final task = _tasks[taskId];
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
      _tasks.remove(taskId);
      _downloadQueue.remove(taskId);
      
      LogUtils.i('下载任务删除完成: ${task.fileName}', 'DownloadService');
    } catch(e) {
      LogUtils.e('删除下载任务失败', tag: 'DownloadService', error: e);
      rethrow;
    }
  }

  void _processQueue() async {
    if(_activeDownloads.length >= maxConcurrentDownloads || _downloadQueue.isEmpty) {
      return;
    }

    final taskId = _downloadQueue.first;
    final task = _tasks[taskId];

    if(task == null || task.status != DownloadStatus.pending) {
      _downloadQueue.removeAt(0);
      _processQueue();
      return;
    }

    _downloadQueue.removeAt(0);
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

      // 设置1秒的节流间隔
      _progressUpdateTimer?.cancel();
      _progressUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if(_pendingProgressUpdates.isNotEmpty) {
          task.updateSpeed();
          _repository.updateTask(task);
          if (task.totalBytes > 0) {
            LogUtils.d(
              '下载进度: ${task.downloadedBytes}/${task.totalBytes} (${(task.downloadedBytes / task.totalBytes * 100).toStringAsFixed(2)}%), '
              '速度: ${(task.speed / 1024 / 1024).toStringAsFixed(2)}MB/s',
              'DownloadService'
            );
          } else {
            LogUtils.d(
              '已下载: ${task.downloadedBytes} bytes, '
              '速度: ${(task.speed / 1024 / 1024).toStringAsFixed(2)}MB/s',
              'DownloadService'
            );
          }
          _pendingProgressUpdates.clear();
        }
      });

      final completer = Completer();
      
      subscription = response.data.stream.listen(
        (chunk) {
          try {
            raf?.writeFromSync(chunk);
            task.downloadedBytes = (task.downloadedBytes + chunk.length) as int;
            _tasks[task.id] = task;
            _pendingProgressUpdates.add(task.id);
          } catch (e) {
            LogUtils.e('写入文件失败: $e', tag: 'DownloadService', error: e);
            throw e;
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
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // 用户主动取消,不需要额外处理
        LogUtils.d('用户暂停下载: ${task.fileName}', 'DownloadService');
      } else {
        // 其他错误需要正常处理
        LogUtils.e('下载任务执行失败: $e', tag: 'DownloadService', error: e);
        await _cleanupDownload(task, raf, subscription);
        task.status = DownloadStatus.failed;
        task.error = _getErrorMessage(e);
        await _updateTaskStatus(task);
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
    await raf?.close();
    _activeDownloads.remove(task.id);
    _progressUpdateTimer?.cancel();
    _progressUpdateTimer = null;
  }

  Future<void> _updateTaskStatus(DownloadTask task) async {
    _tasks[task.id] = task;
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
} 