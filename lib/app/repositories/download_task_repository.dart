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

  CommonDatabase get db => _db;

  // 获取所有任务
  Future<List<DownloadTask>> getAllTasks() async {
    // 使用 CommonDatabase.select 一次性查询，内部自动 prepare + dispose，避免 stmt 泄漏
    final results = _db.select('''
      SELECT * FROM download_tasks
      ORDER BY created_at DESC
    ''');
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 获取某状态的全部任务
  Future<List<DownloadTask>> getAllTasksByStatus(DownloadStatus status) async {
    final results = _db.select(
      'SELECT * FROM download_tasks WHERE status = ?',
      [status.name],
    );
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  /// 获取所有 downloading + pending 任务，按创建时间升序排列
  Future<List<DownloadTask>>
  getDownloadingAndPendingTasksOrderByCreatedAtAsc() async {
    try {
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE status IN ('downloading', 'pending')
        ORDER BY created_at ASC
      ''');
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
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE status = 'pending'
        ORDER BY created_at ASC
      ''');
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取等待中任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 插入任务
  Future<void> insertTask(DownloadTask task) async {
    try {
      final extDataJson = task.extData != null
          ? jsonEncode(task.extData!.toJson())
          : null;

      // updated_at 显式写入毫秒时间戳，避免依赖建表的秒级默认值导致单位混用
      _db.execute(
        '''
        INSERT INTO download_tasks
        (id, url, save_path, file_name, total_bytes, downloaded_bytes, status, supports_range, error, ext_data, media_type, media_id, quality, updated_at, completed_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          task.id,
          task.url,
          task.savePath,
          task.fileName,
          task.totalBytes,
          task.downloadedBytes,
          task.status.name,
          task.supportsRange ? 1 : 0,
          task.error,
          extDataJson,
          task.mediaType,
          task.mediaId,
          task.quality,
          DateTime.now().millisecondsSinceEpoch,
          task.completedAt?.millisecondsSinceEpoch,
        ],
      );
    } catch (e) {
      LogUtils.e('插入下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 更新任务
  Future<void> updateTask(DownloadTask task) async {
    try {
      final extDataJson = task.extData != null
          ? jsonEncode(task.extData!.toJson())
          : null;

      _db.execute(
        '''
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
            media_type = ?,
            media_id = ?,
            quality = ?,
            updated_at = ?,
            completed_at = ?
        WHERE id = ?
      ''',
        [
          task.url,
          task.savePath,
          task.fileName,
          task.totalBytes,
          task.downloadedBytes,
          task.status.name,
          task.supportsRange ? 1 : 0,
          task.error,
          extDataJson,
          task.mediaType,
          task.mediaId,
          task.quality,
          DateTime.now().millisecondsSinceEpoch,
          task.completedAt?.millisecondsSinceEpoch,
          task.id,
        ],
      );
    } catch (e) {
      LogUtils.e('更新下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  // 删除任务
  Future<bool> deleteTask(String taskId) async {
    try {
      _db.execute('DELETE FROM download_tasks WHERE id = ?', [taskId]);
      return true;
    } catch (e) {
      LogUtils.e('删除下载任务失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }

  // 删除所有任务
  Future<bool> deleteAllTasks() async {
    try {
      _db.execute('DELETE FROM download_tasks');
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
    try {
      final params = <Object?>[];
      String whereConditions = '';
      if (status != null) {
        whereConditions = 'WHERE status = ?';
        params.add(status.name);
      }
      params.addAll([limit, offset]);

      final results = _db.select('''
        SELECT * FROM download_tasks
        $whereConditions
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''', params);
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
    final results = _db.select('''
      SELECT * FROM download_tasks
      WHERE status = 'completed'
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    ''', [limit, offset]);
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 获取任务总数
  Future<Map<String, int>> getTasksCount() async {
    final activeCount = _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status IN ('downloading', 'paused', 'pending')
    ''').first['count'] as int;

    final completedCount = _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status = 'completed'
    ''').first['count'] as int;

    final failedCount = _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status = 'failed'
    ''').first['count'] as int;

    return {
      'active': activeCount,
      'completed': completedCount,
      'failed': failedCount,
    };
  }

  /// 根据状态获取任务数量
  Future<int> getCountByStatus(DownloadStatus status) async {
    final result = _db.select(
      'SELECT COUNT(*) as count FROM download_tasks WHERE status = ?',
      [status.name],
    );
    if (result.isEmpty) {
      return 0;
    }
    return result.first['count'] as int;
  }

  Future<DownloadTask?> getTaskById(String taskId) async {
    final result = _db.select(
      'SELECT * FROM download_tasks WHERE id = ?',
      [taskId],
    );

    if (result.isNotEmpty) {
      return DownloadTask.fromRow(result.first);
    }

    return null;
  }

  Future<void> updateTaskStatusById(String id, DownloadStatus status) async {
    try {
      _db.execute(
        'UPDATE download_tasks SET status = ? WHERE id = ?',
        [status.name, id],
      );
    } catch (e) {
      LogUtils.e('更新下载任务状态失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 基于媒体信息判断任务是否存在（任意状态）
  Future<bool> existsTaskByMedia(String mediaType, String mediaId) async {
    try {
      final result = _db.select('''
        SELECT 1 FROM download_tasks
        WHERE media_type = ? AND media_id = ?
        LIMIT 1
      ''', [mediaType, mediaId]);
      return result.isNotEmpty;
    } catch (e) {
      LogUtils.e('检查媒体任务是否存在失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 获取指定视频ID的所有下载任务（任意状态）
  Future<List<DownloadTask>> getVideoTasksByMedia(String videoId) async {
    try {
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE media_type = 'video' AND media_id = ?
      ''', [videoId]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取视频媒体任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 按媒体维度（media_type + media_id）获取任务，走 (media_type, media_id) 索引，
  /// 避免对全表/某状态全量扫描。
  Future<List<DownloadTask>> getTasksByMedia(
    String mediaType,
    String mediaId,
  ) async {
    try {
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE media_type = ? AND media_id = ?
      ''', [mediaType, mediaId]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取媒体任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 分页获取历史任务（paused/completed，不含failed），按创建时间降序排列
  Future<List<DownloadTask>> getHistoryTasks({
    required int offset,
    required int limit,
  }) async {
    try {
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE status IN ('paused', 'completed')
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''', [limit, offset]);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取历史任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 获取所有失败任务，按更新时间降序排列（最近失败的在前）
  Future<List<DownloadTask>> getFailedTasksOrderByUpdatedAtDesc() async {
    try {
      final results = _db.select('''
        SELECT * FROM download_tasks
        WHERE status = 'failed'
        ORDER BY updated_at DESC
      ''');
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取失败任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// Search and filter tasks with pagination
  /// [searchQuery] - Search in fileName (case-insensitive)
  /// [statusFilter] - Filter by status: 'all', 'failed', 'downloaded' (completed)
  /// [typeFilter] - Filter by type: 'all', 'video', 'gallery', 'other'
  Future<List<DownloadTask>> searchTasks({
    required int offset,
    required int limit,
    String? searchQuery,
    String statusFilter = 'all',
    String typeFilter = 'all',
  }) async {
    try {
      final whereClauses = <String>[];
      final params = <Object?>[];

      // Search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add("file_name LIKE ?");
        params.add('%${searchQuery.trim()}%');
      }

      // Status filter
      switch (statusFilter) {
        case 'failed':
          whereClauses.add("status = 'failed'");
          break;
        case 'downloaded':
          whereClauses.add("status = 'completed'");
          break;
        case 'all':
        default:
          // No status filter - include all statuses
          break;
      }

      // Type filter (based on ext_data JSON)
      switch (typeFilter) {
        case 'video':
          whereClauses.add("media_type = 'video'");
          break;
        case 'gallery':
          whereClauses.add("media_type = 'gallery'");
          break;
        case 'other':
          whereClauses.add(
            "(media_type IS NULL OR media_type NOT IN ('video', 'gallery'))",
          );
          break;
        case 'all':
        default:
          // No type filter
          break;
      }

      final whereClause = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      final sql =
          '''
        SELECT * FROM download_tasks
        $whereClause
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''';

      params.add(limit);
      params.add(offset);

      final results = _db.select(sql, params);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('搜索下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// Get count for filtered search
  Future<int> getFilteredTasksCount({
    String? searchQuery,
    String statusFilter = 'all',
    String typeFilter = 'all',
  }) async {
    try {
      final whereClauses = <String>[];
      final params = <Object?>[];

      // Search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add("file_name LIKE ?");
        params.add('%${searchQuery.trim()}%');
      }

      // Status filter
      switch (statusFilter) {
        case 'failed':
          whereClauses.add("status = 'failed'");
          break;
        case 'downloaded':
          whereClauses.add("status = 'completed'");
          break;
        case 'all':
        default:
          break;
      }

      // Type filter
      switch (typeFilter) {
        case 'video':
          whereClauses.add("media_type = 'video'");
          break;
        case 'gallery':
          whereClauses.add("media_type = 'gallery'");
          break;
        case 'other':
          whereClauses.add(
            "(media_type IS NULL OR media_type NOT IN ('video', 'gallery'))",
          );
          break;
        case 'all':
        default:
          break;
      }

      final whereClause = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      final sql =
          '''
        SELECT COUNT(*) as count FROM download_tasks
        $whereClause
      ''';

      final results = _db.select(sql, params);
      return results.first['count'] as int;
    } catch (e) {
      LogUtils.e('获取筛选任务数量失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }
}
