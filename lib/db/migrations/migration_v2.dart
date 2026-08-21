import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV2History extends Migration {
  @override
  int get version => 2;

  @override
  String get description => "创建历史记录表";

  @override
  void up(CommonDatabase db) {
    // 创建历史记录表
    db.execute('''
      CREATE TABLE IF NOT EXISTS history_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,           -- 记录ID (视频ID或图库ID)
        item_type TEXT NOT NULL,         -- 记录类型 (video/image)
        title TEXT NOT NULL,             -- 标题
        thumbnail_url TEXT,              -- 缩略图URL
        author TEXT,                     -- 作者名
        author_id TEXT,                  -- 作者ID
        data TEXT NOT NULL,              -- 完整数据JSON
        created_at TEXT NOT NULL DEFAULT(datetime('now')),
        updated_at TEXT NOT NULL DEFAULT(datetime('now')),
        UNIQUE(item_id, item_type)       -- 确保同一类型的记录不会重复
      );
    ''');

    // 创建索引
    db.execute('''
      CREATE INDEX idx_history_records_type_date 
      ON history_records(item_type, created_at);
    ''');

    db.execute('''
      CREATE INDEX idx_history_records_title
      ON history_records(title);
    ''');

    // 创建触发器：自动更新updated_at
    db.execute('''
      CREATE TRIGGER trigger_history_records_updated_at
      AFTER UPDATE ON history_records
      BEGIN
        UPDATE history_records 
        SET updated_at = datetime('now')
        WHERE id = NEW.id;
      END;
    ''');

    db.execute('PRAGMA user_version = 2;');
    LogUtils.i('已应用迁移v2：创建历史记录表');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP TRIGGER IF EXISTS trigger_history_records_updated_at;');
    db.execute('DROP INDEX IF EXISTS idx_history_records_type_date;');
    db.execute('DROP INDEX IF EXISTS idx_history_records_title;');
    db.execute('DROP TABLE IF EXISTS history_records;');
    db.execute('PRAGMA user_version = 1;');
    LogUtils.i('已回滚迁移v2：删除历史记录表');
  }
}
