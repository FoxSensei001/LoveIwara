import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:sqlite3/common.dart';
import 'package:i_iwara/app/models/history_record.dart';

/// 浏览历史（`history_records`）。
///
/// # 口径：一切都按「最后一次浏览」
///
/// 排序、日期分组、时间区间筛选、按区间删除、自动清理——全部看 `updated_at`
/// （upsert 冲突时由触发器刷成 now）。以前列表按 created_at（首次浏览）排，重看一个
/// 老视频不会回到顶部；删除却又可能按 updated_at，两边口径不一致删掉的不是看到的。
///
/// # ⛔ 时间参数必须用 [sqlTime]
///
/// 列里存的是 SQLite `datetime('now')`：`YYYY-MM-DD HH:MM:SS`，**UTC**，中间是空格。
/// 比较是纯字符串比较——拿 `toIso8601String()`（本地时间、中间是 `T`）去比，
/// 格式和时区两头都错，「今天」这一段整段漏查。
///
/// # 观看进度
///
/// 列表查询 LEFT JOIN `video_playback_history` 带出进度（只对视频），不在本表重复存。
/// 删除视频历史时同一事务里把对应进度一起删掉——删历史就该连「看到哪」一起忘。
class HistoryRepository {
  late final CommonDatabase _db;

  /// [database] 供单测注入内存库（与 `VrFormatOverrideService` 同一先例）；
  /// 生产调用方一律不传。
  HistoryRepository({CommonDatabase? database}) {
    _db = database ?? DatabaseService().database;
  }

  /// 本地时间点 → 与列值同格式的 UTC 字符串。
  static String sqlTime(DateTime time) {
    final u = time.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)} '
        '${two(u.hour)}:${two(u.minute)}:${two(u.second)}';
  }

  // 添加单条记录
  Future<void> addRecord(HistoryRecord record) async {
    if (!CommonConstants.enableHistory) return;
    // 基于唯一键 (item_id, item_type) 的原子 upsert：
    // - 新记录：插入并由表默认值写入 created_at/updated_at
    // - 冲突：仅更新可变字段（title/thumbnail/author/author_id/data），保留 created_at，
    //         由触发器自动刷新 updated_at
    // 使用 CommonDatabase.execute 一次性执行，内部自动 prepare + dispose，避免 stmt 泄漏
    _db.execute(
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
      ''',
      [
        record.itemId,
        record.itemType,
        record.title,
        record.thumbnailUrl,
        record.author,
        record.authorId,
        record.data,
      ],
    );
  }

  // 对外接口保持不变：统一走 upsert 逻辑
  Future<void> addRecordWithCheck(HistoryRecord record) => addRecord(record);

  /// 类型 + 关键字 + 时间区间（按 updated_at）→ WHERE 子句与参数。
  /// 列表、计数、按区间删除共用这一份，口径不会再分叉。
  (String, List<Object?>) _where({
    String itemType = 'all',
    String keyword = '',
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final List<Object?> params = [];
    final List<String> conditions = [];
    if (itemType != 'all') {
      conditions.add('item_type = ?');
      params.add(itemType);
    }
    if (keyword.isNotEmpty) {
      conditions.add("title LIKE ? ESCAPE '\\'");
      final escaped = keyword
          .replaceAll('\\', '\\\\')
          .replaceAll('%', '\\%')
          .replaceAll('_', '\\_');
      params.add('%$escaped%');
    }
    if (startDate != null) {
      conditions.add('updated_at >= ?');
      params.add(sqlTime(startDate));
    }
    if (endDate != null) {
      conditions.add('updated_at <= ?');
      params.add(sqlTime(endDate));
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return (where, params);
  }

  /// 列表一页：按最后浏览时间倒序，视频带出观看进度。
  Future<List<HistoryRecord>> listRecords({
    String itemType = 'all',
    String keyword = '',
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    final (where, params) = _where(
      itemType: itemType,
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
    );
    // 先在 history_records 上按索引分页，再对这一页 JOIN 进度：
    // 子查询里没有 JOIN，ORDER BY 直接倒序扫 (item_type,)updated_at 索引。
    final rows = _db.select(
      '''
      SELECT h.*,
             p.played_duration AS progress_played_ms,
             p.total_duration AS progress_total_ms
      FROM (
        SELECT * FROM history_records
        $where
        ORDER BY updated_at DESC, id DESC
        LIMIT ? OFFSET ?
      ) h
      LEFT JOIN video_playback_history p
        ON h.item_type = 'video' AND p.video_id = h.item_id
      ORDER BY h.updated_at DESC, h.id DESC
      ''',
      [...params, limit, offset],
    );
    return rows.map(HistoryRecord.fromJson).toList();
  }

  /// 与 [listRecords] 同条件的总数（分页栏算页数、删除前确认数量）。
  Future<int> countRecords({
    String itemType = 'all',
    String keyword = '',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final (where, params) = _where(
      itemType: itemType,
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
    );
    final result = _db.select(
      'SELECT COUNT(*) AS cnt FROM history_records $where',
      params,
    );
    return result.isEmpty ? 0 : (result.first['cnt'] as int);
  }

  /// 在一个事务里：先删命中行对应的视频进度，再删历史行。返回删掉的历史条数。
  int _deleteWhere(String where, List<Object?> params) {
    final videoFilter = where.isEmpty
        ? "WHERE item_type = 'video'"
        : "$where AND item_type = 'video'";
    _db.execute('BEGIN');
    try {
      _db.execute(
        'DELETE FROM video_playback_history WHERE video_id IN '
        '(SELECT item_id FROM history_records $videoFilter)',
        params,
      );
      _db.execute('DELETE FROM history_records $where', params);
      final removed = _db.updatedRows;
      _db.execute('COMMIT');
      return removed;
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  // 删除单条记录
  Future<void> deleteRecord(int id) => deleteRecords([id]);

  // 批量删除记录
  Future<void> deleteRecords(List<int> ids) async {
    if (ids.isEmpty) return;
    // SQLite 默认最多 999 个绑定参数，分批删。
    const chunk = 500;
    for (var i = 0; i < ids.length; i += chunk) {
      final part = ids.sublist(
        i,
        i + chunk > ids.length ? ids.length : i + chunk,
      );
      final placeholders = List.filled(part.length, '?').join(',');
      _deleteWhere('WHERE id IN ($placeholders)', part);
    }
  }

  /// 撤销删除：把刚删掉的行原样放回去（原 id、原首次 / 最后浏览时间），
  /// 视频连同 [listRecords] 带出来的进度一起放回。
  ///
  /// INSERT 不会触发 `AFTER UPDATE` 那个刷 updated_at 的触发器，时间能原样保住；
  /// 用 OR IGNORE：撤销前用户又看了一遍、行已经被新写回来时，以新的为准。
  Future<void> restoreRecords(List<HistoryRecord> records) async {
    if (records.isEmpty) return;
    _db.execute('BEGIN');
    try {
      for (final r in records) {
        final now = DateTime.now();
        _db.execute(
          '''
          INSERT OR IGNORE INTO history_records
            (id, item_id, item_type, title, thumbnail_url, author, author_id,
             data, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            r.id,
            r.itemId,
            r.itemType,
            r.title,
            r.thumbnailUrl,
            r.author,
            r.authorId,
            r.data,
            sqlTime(r.createdAt ?? now),
            sqlTime(r.updatedAt ?? now),
          ],
        );
        final played = r.playedMs, total = r.totalMs;
        if (r.itemType == 'video' && played != null && total != null) {
          _db.execute(
            '''
            INSERT OR IGNORE INTO video_playback_history
              (video_id, total_duration, played_duration)
            VALUES (?, ?, ?)
            ''',
            [r.itemId, total, played],
          );
        }
      }
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  // 清空历史记录
  Future<void> clearHistory() async => _deleteWhere('', const []);

  // 清空指定类型的历史记录
  Future<void> clearHistoryByType(String itemType) async {
    if (itemType == 'all') return clearHistory();
    _deleteWhere('WHERE item_type = ?', [itemType]);
  }

  /// 按类型 + 关键字 + 时间区间（最后浏览时间）删除，返回删除条数。
  Future<int> deleteRecordsByTimeRange({
    String itemType = 'all',
    String keyword = '',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final (where, params) = _where(
      itemType: itemType,
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
    );
    return _deleteWhere(where, params);
  }

  /// 删除超过 [days] 天没再看过（按 updated_at）的历史记录，返回被删除的条数。
  /// 供「自动清理历史记录」功能在启动时调用；[days] <= 0 时不做任何操作。
  Future<int> deleteRecordsOlderThanDays(int days) async {
    if (days <= 0) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _deleteWhere('WHERE updated_at < ?', [sqlTime(cutoff)]);
  }
}
