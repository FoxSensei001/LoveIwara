import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV6Config extends Migration {
  @override
  int get version => 6;

  @override
  String get description => "创建或更新配置表";

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS app_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    LogUtils.i('已应用迁移v6：创建/更新配置表');
  }
}
