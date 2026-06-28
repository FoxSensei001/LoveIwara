import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'dart:convert';

enum DownloadTaskConflictType { id, media, savePath }

class DuplicateDownloadTaskException implements Exception {
  final DownloadTaskConflictType type;
  final String message;

  const DuplicateDownloadTaskException(this.type, this.message);

  @override
  String toString() => message;
}

class DownloadTaskRepository {
  final CommonDatabase _db;

  DownloadTaskRepository([CommonDatabase? database])
    : _db = database ?? DatabaseService().database;

  CommonDatabase get db => _db;

  static const _normalizedHistorySortExpression = '''
    CASE
      WHEN status = 'completed' AND completed_at IS NOT NULL THEN
        CASE WHEN completed_at < 1000000000000 THEN completed_at * 1000 ELSE completed_at END
      WHEN updated_at IS NOT NULL THEN
        CASE WHEN updated_at < 1000000000000 THEN updated_at * 1000 ELSE updated_at END
      ELSE created_at * 1000
    END
  ''';

  static String _escapeLikeQuery(String query) {
    return query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  static DuplicateDownloadTaskException? _mapConflictException(Object error) {
    if (error is! SqliteException) return null;

    final message = error.message;
    if (message.contains('duplicate_download_task_media')) {
      return const DuplicateDownloadTaskException(
        DownloadTaskConflictType.media,
        'duplicate download task media',
      );
    }
    if (message.contains('duplicate_download_task_save_path')) {
      return const DuplicateDownloadTaskException(
        DownloadTaskConflictType.savePath,
        'duplicate download task save path',
      );
    }
    if (message.contains('download_tasks.id') ||
        message.contains('UNIQUE constraint failed: download_tasks.id')) {
      return const DuplicateDownloadTaskException(
        DownloadTaskConflictType.id,
        'duplicate download task id',
      );
    }

    return null;
  }

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
        (id, url, save_path, file_name, total_bytes, downloaded_bytes, status, supports_range, error, ext_data, media_type, media_id, quality, category_id, updated_at, completed_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
          task.categoryId,
          DateTime.now().millisecondsSinceEpoch,
          task.completedAt?.millisecondsSinceEpoch,
        ],
      );
    } catch (e) {
      final conflict = _mapConflictException(e);
      if (conflict != null) {
        if (LogUtils.isInitialized) {
          LogUtils.w('插入下载任务冲突: ${conflict.message}', 'DownloadTaskRepository');
        }
        throw conflict;
      }
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
            category_id = ?,
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
          task.categoryId,
          DateTime.now().millisecondsSinceEpoch,
          task.completedAt?.millisecondsSinceEpoch,
          task.id,
        ],
      );
    } catch (e) {
      final conflict = _mapConflictException(e);
      if (conflict != null) {
        if (LogUtils.isInitialized) {
          LogUtils.w('更新下载任务冲突: ${conflict.message}', 'DownloadTaskRepository');
        }
        throw conflict;
      }
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

  /// 按创建时间区间获取任务（任意状态），用于“按日期批量删除”。
  ///
  /// [start]/[end] 均为闭区间边界（含端点），任一为 null 表示该侧不限。
  /// created_at 历史上以秒（strftime('%s')）存储，这里统一归一化为毫秒后再与
  /// 入参（毫秒时间戳）比较，兼容个别历史毫秒值，避免单位混用导致漏删/误删。
  Future<List<DownloadTask>> getTasksByCreatedDateRange({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      const normalizedCreatedAt =
          "(CASE WHEN created_at < 1000000000000 THEN created_at * 1000 ELSE created_at END)";
      final whereClauses = <String>[];
      final params = <Object?>[];

      if (start != null) {
        whereClauses.add('$normalizedCreatedAt >= ?');
        params.add(start.millisecondsSinceEpoch);
      }
      if (end != null) {
        whereClauses.add('$normalizedCreatedAt <= ?');
        params.add(end.millisecondsSinceEpoch);
      }

      final whereClause = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      final results = _db.select('''
        SELECT * FROM download_tasks
        $whereClause
        ORDER BY created_at DESC
      ''', params);
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('按日期区间获取下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
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
    final results = _db.select(
      '''
      SELECT * FROM download_tasks
      WHERE status = 'completed'
      ORDER BY $_normalizedHistorySortExpression DESC, created_at DESC
      LIMIT ? OFFSET ?
    ''',
      [limit, offset],
    );
    return results.map((row) => DownloadTask.fromRow(row)).toList();
  }

  // 获取任务总数
  Future<Map<String, int>> getTasksCount() async {
    final activeCount =
        _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status IN ('downloading', 'paused', 'pending')
    ''').first['count']
            as int;

    final completedCount =
        _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status = 'completed'
    ''').first['count']
            as int;

    final failedCount =
        _db.select('''
      SELECT COUNT(*) as count FROM download_tasks
      WHERE status = 'failed'
    ''').first['count']
            as int;

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
    final result = _db.select('SELECT * FROM download_tasks WHERE id = ?', [
      taskId,
    ]);

    if (result.isNotEmpty) {
      return DownloadTask.fromRow(result.first);
    }

    return null;
  }

  Future<void> updateTaskStatusById(String id, DownloadStatus status) async {
    try {
      _db.execute('UPDATE download_tasks SET status = ? WHERE id = ?', [
        status.name,
        id,
      ]);
    } catch (e) {
      LogUtils.e('更新下载任务状态失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 基于媒体信息判断任务是否存在（任意状态）
  Future<bool> existsTaskByMedia(String mediaType, String mediaId) async {
    try {
      final result = _db.select(
        '''
        SELECT 1 FROM download_tasks
        WHERE media_type = ? AND media_id = ?
        LIMIT 1
      ''',
        [mediaType, mediaId],
      );
      return result.isNotEmpty;
    } catch (e) {
      LogUtils.e('检查媒体任务是否存在失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 判断保存路径是否已被任意任务占用。
  Future<bool> existsTaskBySavePath(String savePath) async {
    try {
      final result = _db.select(
        '''
        SELECT 1 FROM download_tasks
        WHERE save_path = ?
        LIMIT 1
      ''',
        [savePath],
      );
      return result.isNotEmpty;
    } catch (e) {
      LogUtils.e('检查保存路径是否占用失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 获取指定视频ID的所有下载任务（任意状态）
  Future<List<DownloadTask>> getVideoTasksByMedia(String videoId) async {
    try {
      final results = _db.select(
        '''
        SELECT * FROM download_tasks
        WHERE media_type = 'video' AND media_id = ?
      ''',
        [videoId],
      );
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
      final results = _db.select(
        '''
        SELECT * FROM download_tasks
        WHERE media_type = ? AND media_id = ?
      ''',
        [mediaType, mediaId],
      );
      return results.map((row) => DownloadTask.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取媒体任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }

  /// 分页获取历史任务（paused/completed，不含failed），按完成/更新时间降序排列
  Future<List<DownloadTask>> getHistoryTasks({
    required int offset,
    required int limit,
  }) async {
    try {
      final results = _db.select(
        '''
        SELECT * FROM download_tasks
        WHERE status IN ('paused', 'completed')
        ORDER BY $_normalizedHistorySortExpression DESC, created_at DESC
        LIMIT ? OFFSET ?
      ''',
        [limit, offset],
      );
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
  /// [statusFilter] - Filter by status: 'all', 'history' (paused/completed),
  /// 'failed', 'downloaded' (completed)
  /// [typeFilter] - Filter by type: 'all', 'video', 'gallery', 'other'
  Future<List<DownloadTask>> searchTasks({
    required int offset,
    required int limit,
    String? searchQuery,
    String statusFilter = 'all',
    String typeFilter = 'all',
    String categoryFilter = 'all',
  }) async {
    try {
      final whereClauses = <String>[];
      final params = <Object?>[];

      // Search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add("file_name LIKE ? ESCAPE '\\'");
        params.add('%${_escapeLikeQuery(searchQuery.trim())}%');
      }

      // Status filter
      switch (statusFilter) {
        case 'failed':
          whereClauses.add("status = 'failed'");
          break;
        case 'downloaded':
          whereClauses.add("status = 'completed'");
          break;
        case 'history':
          whereClauses.add("status IN ('paused', 'completed')");
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

      // Category filter（自定义分类；'all' 不限，'uncategorized' 表示未分类(NULL)，
      // 否则为具体分类 id。分类 id 为 UUID，不会与上述字面量冲突。）
      switch (categoryFilter) {
        case 'all':
          break;
        case 'uncategorized':
          whereClauses.add('category_id IS NULL');
          break;
        default:
          whereClauses.add('category_id = ?');
          params.add(categoryFilter);
          break;
      }

      final whereClause = whereClauses.isNotEmpty
          ? 'WHERE ${whereClauses.join(' AND ')}'
          : '';

      final orderBy = switch (statusFilter) {
        'history' || 'downloaded' =>
          '$_normalizedHistorySortExpression DESC, created_at DESC',
        'failed' => 'updated_at DESC, created_at DESC',
        _ => 'created_at DESC',
      };

      final sql =
          '''
        SELECT * FROM download_tasks
        $whereClause
        ORDER BY $orderBy
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
    String categoryFilter = 'all',
  }) async {
    try {
      final whereClauses = <String>[];
      final params = <Object?>[];

      // Search query filter
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add("file_name LIKE ? ESCAPE '\\'");
        params.add('%${_escapeLikeQuery(searchQuery.trim())}%');
      }

      // Status filter
      switch (statusFilter) {
        case 'failed':
          whereClauses.add("status = 'failed'");
          break;
        case 'downloaded':
          whereClauses.add("status = 'completed'");
          break;
        case 'history':
          whereClauses.add("status IN ('paused', 'completed')");
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

      // Category filter（同 searchTasks）
      switch (categoryFilter) {
        case 'all':
          break;
        case 'uncategorized':
          whereClauses.add('category_id IS NULL');
          break;
        default:
          whereClauses.add('category_id = ?');
          params.add(categoryFilter);
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

  // ============================ 下载分类（download_categories）============================

  /// 获取所有分类，携带各分类下的任务数量（item_count），按自定义顺序排列。
  Future<List<DownloadCategory>> getAllCategories() async {
    try {
      final results = _db.select('''
        SELECT c.*, COUNT(t.id) AS item_count
        FROM download_categories c
        LEFT JOIN download_tasks t ON t.category_id = c.id
        GROUP BY c.id
        ORDER BY c.display_order ASC, c.created_at DESC
      ''');
      return results.map((row) => DownloadCategory.fromRow(row)).toList();
    } catch (e) {
      LogUtils.e('获取下载分类列表失败', tag: 'DownloadTaskRepository', error: e);
      return [];
    }
  }

  /// 「未分类」任务数量（category_id IS NULL）。
  Future<int> getUncategorizedCount() async {
    try {
      final result = _db.select(
        'SELECT COUNT(*) AS count FROM download_tasks WHERE category_id IS NULL',
      );
      return result.first['count'] as int;
    } catch (e) {
      LogUtils.e('获取未分类任务数量失败', tag: 'DownloadTaskRepository', error: e);
      return 0;
    }
  }

  /// 新建分类，display_order 自动追加到末尾。
  Future<DownloadCategory?> createCategory({
    required String title,
    String? description,
  }) async {
    try {
      final orderRow = _db.select(
        'SELECT COALESCE(MAX(display_order), -1) + 1 AS next FROM download_categories',
      );
      final nextOrder = orderRow.first['next'] as int;
      final category = DownloadCategory(
        title: title,
        description: description,
        displayOrder: nextOrder,
      );
      _db.execute(
        '''
        INSERT INTO download_categories (id, title, description, created_at, updated_at, display_order)
        VALUES (?, ?, ?, ?, ?, ?)
      ''',
        [
          category.id,
          category.title,
          category.description,
          category.createdAt.millisecondsSinceEpoch ~/ 1000,
          category.updatedAt.millisecondsSinceEpoch ~/ 1000,
          category.displayOrder,
        ],
      );
      return category;
    } catch (e) {
      LogUtils.e('创建下载分类失败', tag: 'DownloadTaskRepository', error: e);
      return null;
    }
  }

  /// 重命名 / 编辑分类。
  Future<bool> updateCategory(
    String id, {
    required String title,
    String? description,
  }) async {
    try {
      _db.execute(
        '''
        UPDATE download_categories
        SET title = ?, description = ?, updated_at = ?
        WHERE id = ?
      ''',
        [
          title,
          description,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          id,
        ],
      );
      return true;
    } catch (e) {
      LogUtils.e('更新下载分类失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }

  /// 删除分类（不删文件）：先把该分类下的任务退回「未分类」，再删分类行。
  Future<bool> deleteCategory(String id) async {
    try {
      _db.execute('BEGIN TRANSACTION');
      try {
        _db.execute(
          'UPDATE download_tasks SET category_id = NULL WHERE category_id = ?',
          [id],
        );
        _db.execute('DELETE FROM download_categories WHERE id = ?', [id]);
        _db.execute('COMMIT');
        return true;
      } catch (e) {
        _db.execute('ROLLBACK');
        rethrow;
      }
    } catch (e) {
      LogUtils.e('删除下载分类失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }

  /// 按给定顺序批量更新 display_order。
  Future<bool> updateCategoriesOrder(List<String> ids) async {
    try {
      _db.execute('BEGIN TRANSACTION');
      try {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        for (var i = 0; i < ids.length; i++) {
          _db.execute(
            'UPDATE download_categories SET display_order = ?, updated_at = ? WHERE id = ?',
            [i, now, ids[i]],
          );
        }
        _db.execute('COMMIT');
        return true;
      } catch (e) {
        _db.execute('ROLLBACK');
        rethrow;
      }
    } catch (e) {
      LogUtils.e('更新下载分类排序失败', tag: 'DownloadTaskRepository', error: e);
      return false;
    }
  }

  /// 分类是否存在（写入前防御悬空引用）。出错时保守返回 true（保留用户意图）。
  Future<bool> categoryExists(String id) async {
    try {
      final r = _db.select(
        'SELECT 1 FROM download_categories WHERE id = ? LIMIT 1',
        [id],
      );
      return r.isNotEmpty;
    } catch (e) {
      LogUtils.e('检查分类是否存在失败', tag: 'DownloadTaskRepository', error: e);
      return true;
    }
  }

  /// 把一批任务归入某分类（categoryId 为 null 表示退回未分类）。
  ///
  /// 只更新 category_id 与 updated_at，刻意不触碰 media/save_path 列，
  /// 从而不会触发 v17 的唯一性触发器。
  Future<void> assignTasksToCategory(
    List<String> taskIds,
    String? categoryId,
  ) async {
    if (taskIds.isEmpty) return;
    try {
      final placeholders = List.filled(taskIds.length, '?').join(', ');
      _db.execute(
        'UPDATE download_tasks SET category_id = ?, updated_at = ? WHERE id IN ($placeholders)',
        [
          categoryId,
          DateTime.now().millisecondsSinceEpoch,
          ...taskIds,
        ],
      );
    } catch (e) {
      LogUtils.e('归类下载任务失败', tag: 'DownloadTaskRepository', error: e);
      rethrow;
    }
  }
}
