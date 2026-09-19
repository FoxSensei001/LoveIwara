import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v45：浏览历史改按「最后一次浏览」（`updated_at`）排序 / 分组 / 筛选。
///
/// 原先两条索引都用不上：
/// - `(item_type, created_at)`：列表默认按 created_at 排，但「全部」tab 没有
///   item_type 条件，首列缺失；改按 updated_at 之后更是整条作废。
/// - `(title)`：搜索是 `LIKE '%kw%'`，前缀通配符让 B-Tree 永远用不上，只剩写入开销。
///
/// 新建的两条都以 updated_at 结尾。索引项天然按 (updated_at, rowid) 排，
/// `ORDER BY updated_at DESC, id DESC` 直接倒序扫索引，不再落 TEMP B-TREE。
///
/// 顺手把可能存在的 ISO 格式时间（带 `T`、来自旧备份）统一成 SQLite 的
/// `YYYY-MM-DD HH:MM:SS`（UTC）——查询参数按这个格式做字符串比较，混着两种格式
/// 就会整段漏查。
class MigrationV45HistoryLastViewedIndexes extends Migration {
  @override
  int get version => 45;

  @override
  String get description => '浏览历史：按最后浏览时间建索引，统一时间格式';

  @override
  void up(CommonDatabase db) {
    db.execute('DROP INDEX IF EXISTS idx_history_records_title');
    db.execute('DROP INDEX IF EXISTS idx_history_records_type_date');
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_records_updated '
      'ON history_records(updated_at)',
    );
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_history_records_type_updated '
      'ON history_records(item_type, updated_at)',
    );

    // datetime() 吃 ISO（含 T / 时区后缀）吐 UTC 的空格格式；解析不了的返回 NULL，
    // 用 COALESCE 原样保留，不让一行坏数据把整列 NOT NULL 约束炸掉。
    // 只改时间列，不能让 AFTER UPDATE 触发器把 updated_at 刷成 now——
    // 触发器是 `UPDATE ... SET updated_at = datetime('now')`，所以先摘再装。
    final trigger = db.select(
      "SELECT sql FROM sqlite_master WHERE type = 'trigger' "
      "AND name = 'trigger_history_records_updated_at'",
    );
    db.execute('DROP TRIGGER IF EXISTS trigger_history_records_updated_at');
    db.execute('''
      UPDATE history_records SET
        created_at = COALESCE(datetime(created_at), created_at),
        updated_at = COALESCE(datetime(updated_at), updated_at)
      WHERE created_at LIKE '%T%' OR updated_at LIKE '%T%'
    ''');
    if (trigger.isNotEmpty && trigger.first['sql'] is String) {
      db.execute(trigger.first['sql'] as String);
    }

    LogUtils.i('已应用迁移v45：浏览历史改按 updated_at 建索引', 'MigrationV45');
  }
}
