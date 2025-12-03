import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:loading_more_list/loading_more_list.dart';

class DownloadTaskRepository {
  late final CommonDatabase _db;

  DownloadTaskRepository() {
    _db = DatabaseService().database;
  }

  CommonDatabase get db => _db;

  // 获取所有任务
  Future<List<DownloadTask>> getAllTasks() async {
    final stmt = _db.prepare('''
      SELECT * FROM download_tasks 
      ORDER BY created_at DESC
    ''');

    final results = stmt.select([]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 获取某状态的全部任务
  Future<List<DownloadTask>> getAllTasksByStatus(DownloadStatus status) async {
    final stmt = _db.prepare('''
      SELECT * FROM download_tasks WHERE status = ?
    ''');
    final results = stmt.select([status.name]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  /// 获取所有 downloading + pending 任务，按创建时间升序排列
  Future<List<DownloadTask>> getDownloadingAndPendingTasksOrderByCreatedAtAsc()
      async {
    try {
      final stmt = _db.prepare('''
        SELECT * FROM download_tasks 
        WHERE status IN ('downloading', 'pending')
        ORDER BY created_at ASC
      ''');

      final results = stmt.select([]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e(
        '获取 downloading/pending 任务失败',
        tag: 'DownloadTaskRepository',
        error: e,
      );
      rethrow;
    }
  }

  /// 获取所有等待中(pending)任务，按创建时间升序排列
  Future<List<DownloadTask>> getPendingTasksOrderByCreatedAtAsc() async {
    try {
      final stmt = _db.prepare('''
        SELECT * FROM download_tasks 
        WHERE status = 'pending'
        ORDER BY created_at ASC
      ''');

      final results = stmt.select([]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e(
        '获取等待中任务失败',
        tag: 'DownloadTaskRepository',
        error: e,
      );
      rethrow;
    }
  }

  // 插入任务
  Future<void> insertTask(DownloadTask task) async {
    try {
      final extDataJson =
          task.extData != null ? jsonEncode(task.extData!.toJson()) : null;

      _db.prepare('''
        INSERT INTO download_tasks 
        (id, url, save_path, file_name, total_bytes, downloaded_bytes, status, supports_range, error, ext_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''').execute([
        task.id,
        task.url,
        task.savePath,
        task.fileName,
        task.totalBytes,
        task.downloadedBytes,
        task.status.name,
        task.supportsRange ? 1 : 0,
        task.error,
        extDataJson
      ]);
    } catch (e) {
      LogUtils.e('插入下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 更新任务
  Future<void> updateTask(DownloadTask task) async {
    try {
      final extDataJson =
          task.extData != null ? jsonEncode(task.extData!.toJson()) : null;

      _db.prepare('''
        UPDATE download_tasks 
        SET url = ?, 
            save_path = ?, 
            file_name = ?, 
            total_bytes = ?, 
            downloaded_bytes = ?, 
            status = ?, 
            supports_range = ?, 
            error = ?, 
            ext_data = ?,
            updated_at = ?
        WHERE id = ?
      ''').execute([
        task.url,
        task.savePath,
        task.fileName,
        task.totalBytes,
        task.downloadedBytes,
        task.status.name,
        task.supportsRange ? 1 : 0,
        task.error,
        extDataJson,
        DateTime.now().millisecondsSinceEpoch,
        task.id
      ]);
    } catch (e) {
      LogUtils.e('更新下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 删除任务
  Future<bool> deleteTask(String taskId) async {
    try {
      _db.prepare('DELETE FROM download_tasks WHERE id = ?').execute([taskId]);
      return true;
    } catch (e) {
      LogUtils.e('删除下载任务失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }

  // 删除所有任务
  Future<bool> deleteAllTasks() async {
    try {
      _db.prepare('DELETE FROM download_tasks').execute();
      return true;
    } catch (e) {
      LogUtils.e('删除所有下载任务失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }
  Future<List<DownloadTask>> getTasksByStatus(
    DownloadStatus? status, {
    int offset = 0,
    int limit = 20,
  }) async {
    String whereConditions = '';
    if (status != null) {
      whereConditions = "WHERE status = '${status.name}'";
    }
    try {
      final stmt = _db.prepare('''
        SELECT * FROM download_tasks 
        $whereConditions
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''');

      final results = stmt.select([limit, offset]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 分页获取已完成的任务
  Future<List<DownloadTask>> getCompletedTasks({
    int offset = 0,
    int limit = 20,
  }) async {
    final stmt = _db.prepare('''
      SELECT * FROM download_tasks 
      WHERE status = 'completed'
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    ''');

    final results = stmt.select([limit, offset]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 获取任务总数
  Future<Map<String, int>> getTasksCount() async {
    final activeStmt = _db.prepare('''
      SELECT COUNT(*) as count FROM download_tasks 
      WHERE status IN ('downloading', 'paused', 'pending')
    ''');

    final completedStmt = _db.prepare('''
      SELECT COUNT(*) as count FROM download_tasks 
      WHERE status = 'completed'
    ''');

    final failedStmt = _db.prepare('''
      SELECT COUNT(*) as count FROM download_tasks 
      WHERE status = 'failed'
    ''');

    final activeCount = activeStmt.select([]).first['count'] as int;
    final completedCount = completedStmt.select([]).first['count'] as int;
    final failedCount = failedStmt.select([]).first['count'] as int;

    return {
      'active': activeCount,
      'completed': completedCount,
      'failed': failedCount,
    };
  }

  /// 根据状态获取任务数量
  Future<int> getCountByStatus(DownloadStatus status) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM download_tasks 
      WHERE status = ?
    ''');
    final result = stmt.select([status.name]);
    if (result.isEmpty) {
      return 0;
    }
    return result.first['count'] as int;
  }

  Future<DownloadTask?> getTaskById(String taskId) async {
    final stmt = _db.prepare('SELECT * FROM download_tasks WHERE id = ?');
    final result = stmt.select([taskId]);

    if (result.isNotEmpty) {
      return DownloadTask.fromRow(result.first);
    }

    return null;
  }

  Future<void> updateTaskStatusById(String id, DownloadStatus status) async {
    try {
      final stmt =
          _db.prepare('UPDATE download_tasks SET status = ? WHERE id = ?');
      stmt.execute([status.name, id]);
    } catch (e) {
      LogUtils.e('更新下载任务状态失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }
}

class CompletedDownloadTaskRepository extends LoadingMoreBase<DownloadTask> {
  final DownloadService _downloadService = Get.find<DownloadService>();
  
  bool _hasMore = true;
  bool forceRefresh = false;
  
  static const int pageSize = 20;
  
  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    forceRefresh = !notifyStateChanged;
    clear();
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final tasks = await _downloadService.getCompletedTasks(
        // 使用当前列表长度作为偏移量，避免删除任务后分页错位
        offset: length,
        limit: pageSize,
      );

      addAll(tasks);

      _hasMore = tasks.length >= pageSize;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
}

class FailedDownloadTaskRepository extends LoadingMoreBase<DownloadTask> {
  final DownloadTaskRepository _repository = DownloadTaskRepository();
  
  bool _hasMore = true;
  bool forceRefresh = false;
  
  static const int pageSize = 20;
  
  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    forceRefresh = !notifyStateChanged;
    clear();
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final tasks = await _repository.getTasksByStatus(
        DownloadStatus.failed,
        // 使用当前列表长度作为偏移量，避免删除任务后分页错位
        offset: length,
        limit: pageSize,
      );

      addAll(tasks);

      _hasMore = tasks.length >= pageSize;
      isSuccess = true;
    } catch (e) {
      isSuccess = false;
      LogUtils.e('加载失败任务失败', tag: 'FailedDownloadTaskRepository', error: e);
    }
    return isSuccess;
  }
}
