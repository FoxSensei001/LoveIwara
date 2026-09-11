import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'migration.dart';

class MigrationV1Initial extends Migration {
  @override
  int get version => 1;

  @override
  String get description => "初始迁移：创建戒律签到表";

  @override
  void up(CommonDatabase db) {
    // 创建戒律签到记录表
    db.execute('''
      CREATE TABLE IF NOT EXISTS sign_in_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status INTEGER NOT NULL, -- 1为成功签到，0为未能坚持
        reason TEXT, -- 破戒原因，可以为空
        created_at TEXT NOT NULL DEFAULT(datetime('now')),
        updated_at TEXT NOT NULL DEFAULT(datetime('now')),
        FOREIGN KEY(user_id) REFERENCES users(id),
        UNIQUE(user_id, date)
      );
    ''');

    // 创建索引
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sign_in_records_user_date
      ON sign_in_records(user_id, date);
    ''');

    // 创建触发器：自动更新updated_at
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trigger_sign_in_records_updated_at
      AFTER UPDATE ON sign_in_records
      BEGIN
        UPDATE sign_in_records
        SET updated_at = datetime('now')
        WHERE id = NEW.id;
      END;
    ''');

    // 创建通用配置表
    db.execute('''
      CREATE TABLE IF NOT EXISTS commons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT(datetime('now')),
        updated_at TEXT NOT NULL DEFAULT(datetime('now'))
      );
    ''');

    // 创建commons表的触发器
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trigger_commons_updated_at
      AFTER UPDATE ON commons
      BEGIN
        UPDATE commons
        SET updated_at = datetime('now')
        WHERE id = NEW.id;
      END;
    ''');

    LogUtils.i('已应用迁移v1：创建戒律签到表和通用配置表');
  }
}
