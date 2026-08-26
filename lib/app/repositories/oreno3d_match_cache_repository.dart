import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sqlite3/common.dart';

import 'package:i_iwara/db/database_service.dart';

/// 一条 iwara ↔ oreno3d 匹配结果缓存。
///
/// [oreno3dId] 为 null 表示「已确认 oreno3d 上没有这条视频」（负结果），
/// 与「没查过」是两回事 —— 后者在 [Oreno3dMatchCacheRepository.lookup] 里返回 null。
class Oreno3dMatchCacheEntry {
  const Oreno3dMatchCacheEntry({
    required this.iwaraId,
    required this.oreno3dId,
    required this.updatedAt,
  });

  final String iwaraId;
  final String? oreno3dId;
  final DateTime updatedAt;

  /// 是否为「确认不存在」的负结果。
  bool get isMissingOnOreno3d => oreno3dId == null;
}

/// iwara ↔ oreno3d 匹配结果缓存。
///
/// 只存 ID 映射，不存详情内容 —— 详情那一坨 JSON 一条 1~2KB，一万条就是十几 MB；
/// 这里一行约 40 字节，再加上下面三道闸门，整张表大小有上界，不随使用时长增长：
///
///   1. **TTL**：负结果 [negativeTtl]（oreno3d 新入库有索引延迟，负结果不能长期有效），
///      正结果 [positiveTtl]（对面条目可能被删除或换 ID）。过期的行读取时视同未命中。
///   2. **行数封顶** [maxRows]：超出 [maxRows] + [_sweepSlack] 时按 updated_at
///      保留最新的 [maxRows] 行。留 slack 是为了避免「每写一行删一行」的抖动。
///   3. **清理节流** [_sweepInterval]：过期清理与行数检查每进程每小时最多做一次。
///      TTL 判断在读取时已各自完成，清理只关乎磁盘占用，不需要每次写入都扫表。
///      因此行数上界是「最多滞后一小时收敛」而不是逐行即时生效的硬顶：理论上一小时内
///      连写几千行可以短暂超出，但一次匹配只写一行，人不可能一小时开几千个详情页。
class Oreno3dMatchCacheRepository {
  Oreno3dMatchCacheRepository({CommonDatabase? database})
    : _db = database ?? DatabaseService().database;

  final CommonDatabase _db;

  /// 匹配成功的结果保留多久。
  static const Duration positiveTtl = Duration(days: 30);

  /// 「确认没有」的负结果保留多久。
  ///
  /// 必须短：oreno3d 收录新视频后索引有延迟（实测当天新增的视频连按作者名都搜不到），
  /// 负结果如果长期有效，新视频会永远匹配不上。
  static const Duration negativeTtl = Duration(hours: 12);

  /// 表的行数上限。按一行约 100 字节（含 SQLite 页与索引开销）估算，约 0.5MB 封顶。
  static const int maxRows = 5000;

  /// 超过上限多少行才真正触发裁剪，避免贴着上限反复删。
  static const int _sweepSlack = 512;

  /// 两次清理之间的最小间隔。
  static const Duration _sweepInterval = Duration(hours: 1);

  /// 进程级节流时间戳。只有一个 DateTime，不随缓存条数增长。
  static DateTime? _lastSweepAt;

  /// 查缓存。返回 null 表示「没查过或已过期」，需要重新走匹配流程。
  Oreno3dMatchCacheEntry? lookup(String iwaraId, {DateTime? now}) {
    if (iwaraId.isEmpty) return null;
    final rows = _db.select(
      'SELECT iwara_id, oreno3d_id, updated_at FROM oreno3d_match_cache WHERE iwara_id = ?',
      [iwaraId],
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final oreno3dId = row['oreno3d_id'] as String?;
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(
      row['updated_at'] as int,
    );
    final ttl = oreno3dId == null ? negativeTtl : positiveTtl;
    final current = now ?? DateTime.now();
    if (current.difference(updatedAt) > ttl) return null;

    return Oreno3dMatchCacheEntry(
      iwaraId: row['iwara_id'] as String,
      oreno3dId: oreno3dId,
      updatedAt: updatedAt,
    );
  }

  /// 记下匹配结论。[oreno3dId] 传 null 表示「确认 oreno3d 上没有」。
  void remember(String iwaraId, String? oreno3dId, {DateTime? now}) {
    if (iwaraId.isEmpty) return;
    final current = now ?? DateTime.now();
    _db.execute(
      '''
      INSERT INTO oreno3d_match_cache (iwara_id, oreno3d_id, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(iwara_id) DO UPDATE SET
        oreno3d_id = excluded.oreno3d_id,
        updated_at = excluded.updated_at
      ''',
      [iwaraId, oreno3dId, current.millisecondsSinceEpoch],
    );
    _maybeSweep(current);
  }

  /// 丢弃某条缓存（缓存里的 oreno3d ID 已经对不上时调用）。
  void forget(String iwaraId) {
    if (iwaraId.isEmpty) return;
    _db.execute('DELETE FROM oreno3d_match_cache WHERE iwara_id = ?', [
      iwaraId,
    ]);
  }

  /// 清理过期行并按 [maxRows] 裁剪，返回删除的总行数。
  ///
  /// 正常由 [remember] 按 [_sweepInterval] 节流触发；测试与手动清理可直接调用。
  int sweep({DateTime? now}) {
    final current = now ?? DateTime.now();
    var deleted = 0;

    // 两条分开写而不是用 OR：各自都能走 updated_at 索引的范围扫描。
    _db.execute(
      'DELETE FROM oreno3d_match_cache WHERE oreno3d_id IS NULL AND updated_at < ?',
      [current.subtract(negativeTtl).millisecondsSinceEpoch],
    );
    deleted += _db.updatedRows;

    _db.execute(
      'DELETE FROM oreno3d_match_cache WHERE oreno3d_id IS NOT NULL AND updated_at < ?',
      [current.subtract(positiveTtl).millisecondsSinceEpoch],
    );
    deleted += _db.updatedRows;

    final countRows = _db.select(
      'SELECT COUNT(*) AS c FROM oreno3d_match_cache',
    );
    final count = countRows.isEmpty ? 0 : (countRows.first['c'] as int);
    if (count > maxRows + _sweepSlack) {
      _db.execute('''
        DELETE FROM oreno3d_match_cache
        WHERE iwara_id IN (
          SELECT iwara_id FROM oreno3d_match_cache
          ORDER BY updated_at DESC
          LIMIT -1 OFFSET $maxRows
        )
      ''');
      deleted += _db.updatedRows;
    }

    _lastSweepAt = current;
    return deleted;
  }

  void _maybeSweep(DateTime now) {
    final last = _lastSweepAt;
    if (last != null && now.difference(last) < _sweepInterval) return;
    sweep(now: now);
  }

  /// 让下一次 [remember] 必定触发清理。仅供测试使用。
  @visibleForTesting
  static void resetSweepThrottle() {
    _lastSweepAt = null;
  }
}
