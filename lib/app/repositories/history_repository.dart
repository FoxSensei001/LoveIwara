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
    _db.prepare(
      '''
      INSERT OR REPLACE INTO history_records 
      (item_id, item_type, title, thumbnail_url, author, author_id, data)
      VALUES (?, ?, ?, ?, ?, ?, ?)
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
    print('成功批量删除: $ids');
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    _db.prepare('DELETE FROM history_records').execute();
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
}