import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:sqlite3/common.dart';
import 'package:i_iwara/app/models/history_record.dart';

class HistoryRepository {
  late final CommonDatabase _db;

  HistoryRepository() {
    _db = DatabaseService().database;
  }

  // 添加单条记录
  Future<void> addRecord(HistoryRecord record) async {
    if (!CommonConstants.enableHistory) return;
    // 基于唯一键 (item_id, item_type) 的原子 upsert：
    // - 新记录：插入并由表默认值写入 created_at/updated_at
    // - 冲突：仅更新可变字段（title/thumbnail/author/author_id/data），保留 created_at，
    //         由触发器自动刷新 updated_at
    _db.prepare(
      '''
      INSERT INTO history_records 
        (item_id, item_type, title, thumbnail_url, author, author_id, data)
      VALUES 
        (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(item_id, item_type) DO UPDATE SET
        title = excluded.title,
        thumbnail_url = excluded.thumbnail_url,
        author = excluded.author,
        author_id = excluded.author_id,
        data = excluded.data
      '''
    ).execute([
      record.itemId,
      record.itemType,
      record.title,
      record.thumbnailUrl,
      record.author,
      record.authorId,
      record.data,
    ]);
  }

  // 批量添加记录
  Future<void> addRecords(List<HistoryRecord> records) async {
    _db.execute('BEGIN TRANSACTION');
    try {
      for (var record in records) {
        await addRecord(record);
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  // 按标题搜索记录
  Future<List<HistoryRecord>> searchByTitle(String keyword) async {
    final stmt = _db.prepare(
      '''
      SELECT * FROM history_records 
      WHERE title LIKE ? 
      ORDER BY created_at DESC
      '''
    );
    
    final results = stmt.select(['%$keyword%']);
    return results.map((row) => HistoryRecord.fromJson(row)).toList();
  }

  // 删除单条记录
  Future<void> deleteRecord(int id) async {
    _db.prepare(
      'DELETE FROM history_records WHERE id = ?'
    ).execute([id]);
  }

  // 批量删除记录
  Future<void> deleteRecords(List<int> ids) async {
    final placeholders = List.filled(ids.length, '?').join(',');
    _db.prepare(
      'DELETE FROM history_records WHERE id IN ($placeholders)'
    ).execute(ids);
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    _db.prepare('DELETE FROM history_records').execute();
  }

  // 清空指定类型的历史记录
  Future<void> clearHistoryByType(String itemType) async {
    _db.prepare('DELETE FROM history_records WHERE item_type = ?').execute([itemType]);
  }

  // 获取指定类型的历史记录
  Future<List<HistoryRecord>> getRecordsByType(
    String itemType, {
    int limit = 20,
    int offset = 0,
  }) async {
    String sql;
    List<Object?> params;
    
    if (itemType == 'all') {
      sql = '''
        SELECT * FROM history_records 
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''';
      params = [limit, offset];
    } else {
      sql = '''
        SELECT * FROM history_records 
        WHERE item_type = ? 
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
      ''';
      params = [itemType, limit, offset];
    }
    
    final stmt = _db.prepare(sql);
    final results = stmt.select(params);
    return results.map((row) => HistoryRecord.fromJson(row)).toList();
  }

  // 按标题搜索记录（分页）
  Future<List<HistoryRecord>> searchByTitlePaged(
    String keyword, {
    String? itemType,
    int limit = 20,
    int offset = 0,
  }) async {
    final List<Object?> params = ['%$keyword%'];
    String sql = '''
      SELECT * FROM history_records 
      WHERE title LIKE ? 
    ''';
    
    if (itemType != null) {
      sql += ' AND item_type = ?';
      params.add(itemType);
    }
    
    sql += '''
      ORDER BY created_at DESC
      LIMIT ? OFFSET ?
    ''';
    params.addAll([limit, offset]);
    
    final stmt = _db.prepare(sql);
    final results = stmt.select(params);
    return results.map((row) => HistoryRecord.fromJson(row)).toList();
  }

  // 添加新方法（对外接口保持不变）：统一走 upsert 逻辑
  Future<void> addRecordWithCheck(HistoryRecord record) async {
    if (!CommonConstants.enableHistory) return;
    await addRecord(record);
  }

  // 按时间范围和类型获取记录
  Future<List<HistoryRecord>> getRecordsByTypeAndTimeRange(
    String itemType, {
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
    bool orderByUpdated = false,
  }) async {
    final List<Object?> params = [];
    final List<String> conditions = [];
    
    // 构建查询条件
    if (itemType != 'all') {
      conditions.add('item_type = ?');
      params.add(itemType);
    }
    
    if (startDate != null) {
      conditions.add('created_at >= ?');
      params.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      conditions.add('created_at <= ?');
      params.add(endDate.toIso8601String());
    }
    
    // 组装SQL语句
    final String sql = '''
      SELECT * FROM history_records 
      ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
      ORDER BY ${orderByUpdated ? 'updated_at' : 'created_at'} DESC
      LIMIT ? OFFSET ?
    ''';
    
    params.addAll([limit, offset]);
    
    final stmt = _db.prepare(sql);
    final results = stmt.select(params);
    return results.map((row) => HistoryRecord.fromJson(row)).toList();
  }

  // 按标题和时间范围搜索记录（分页）
  Future<List<HistoryRecord>> searchByTitleAndTimeRange(
    String keyword, {
    String? itemType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
    bool orderByUpdated = false,
  }) async {
    final List<Object?> params = ['%$keyword%'];
    String sql = '''
      SELECT * FROM history_records 
      WHERE title LIKE ? 
    ''';
    
    if (itemType != null) {
      sql += ' AND item_type = ?';
      params.add(itemType);
    }
    
    if (startDate != null) {
      sql += ' AND created_at >= ?';
      params.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      sql += ' AND created_at <= ?';
      params.add(endDate.toIso8601String());
    }
    
    sql += '''
      ORDER BY ${orderByUpdated ? 'updated_at' : 'created_at'} DESC
      LIMIT ? OFFSET ?
    ''';
    params.addAll([limit, offset]);
    
    final stmt = _db.prepare(sql);
    final results = stmt.select(params);
    return results.map((row) => HistoryRecord.fromJson(row)).toList();
  }
}