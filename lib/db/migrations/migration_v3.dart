import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV3DownloadTask extends Migration {
  @override
  int get version => 3;

  @override
  String get description => "创建下载任务表";

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS download_tasks(
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        save_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        total_bytes INTEGER NOT NULL DEFAULT 0,
        downloaded_bytes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL,
        supports_range INTEGER NOT NULL DEFAULT 0,
        error TEXT,
        ext_data TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      );
    ''');

    db.execute('PRAGMA user_version = 3;');
    LogUtils.i('已应用迁移v3：创建下载任务表');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP TABLE IF EXISTS download_tasks;');
    db.execute('PRAGMA user_version = 2;');
    LogUtils.i('已回滚迁移v3：删除下载任务表');
  }
} 