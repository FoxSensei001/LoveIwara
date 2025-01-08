import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'dart:convert';

class DownloadTaskRepository {
  late final CommonDatabase _db;

  DownloadTaskRepository() {
    _db = DatabaseService().database;
  }

  // 获取所有任务
  Future<List<DownloadTask>> getAllTasks() async {
    final stmt = _db.prepare('''
      SELECT * FROM download_tasks 
      ORDER BY created_at DESC
    ''');
    
    final results = stmt.select([]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 插入任务
  Future<void> insertTask(DownloadTask task) async {
    try {
      final extDataJson = task.extData != null ? jsonEncode(task.extData!.toJson()) : null;
      
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
      final extDataJson = task.extData != null ? jsonEncode(task.extData!.toJson()) : null;
      
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
  Future<void> deleteTask(String taskId) async {
    _db.prepare('DELETE FROM download_tasks WHERE id = ?')
      .execute([taskId]);
  }

  // 删除所有任务
  Future<void> deleteAllTasks() async {
    _db.prepare('DELETE FROM download_tasks').execute();
  }

  // 获取活跃任务（下载中、暂停、等待中、失败的任务）
  Future<List<DownloadTask>> getActiveTasks() async {
    try {
      final stmt = _db.prepare('''
        SELECT * FROM download_tasks 
        WHERE status IN ('downloading', 'paused', 'pending', 'failed')
        ORDER BY created_at DESC
      ''');
      
      final results = stmt.select([]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取活跃任务失败', tag: 'DownloadTaskRepository', error: e);
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

    final activeCount = activeStmt.select([]).first['count'] as int;
    final completedCount = completedStmt.select([]).first['count'] as int;

    return {
      'active': activeCount,
      'completed': completedCount,
    };
  }

  // 使用事务插入任务
  Future<void> insertTaskWithTransaction(DownloadTask task) async {
    _db.execute('BEGIN TRANSACTION');
    try {
      await insertTask(task);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('插入下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 使用事务更新任务
  Future<void> updateTaskWithTransaction(DownloadTask task) async {
    _db.execute('BEGIN TRANSACTION');
    try {
      await updateTask(task);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('更新下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }
} 