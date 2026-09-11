import 'package:sqlite3/common.dart';
import 'migration.dart';

/// 移除日志表和相关功能
class MigrationV10RemoveLogs extends Migration {
  @override
  int get version => 10;

  @override
  String get description => '移除日志表和相关功能';

  @override
  void up(CommonDatabase db) {
    // 删除日志相关的配置项
    db.execute('''
      DELETE FROM app_config 
      WHERE key IN ('ENABLE_LOG_PERSISTENCE', 'MAX_LOG_DATABASE_SIZE')
    ''');

    // 注意：这里不删除 app_logs 表，因为它在独立的日志数据库中
    // 日志数据库的清理将在 DatabaseService 中处理
  }
}
