// lib/migrations/migration_manager.dart

import 'package:i_iwara/db/migrations/migration_v3.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

import 'database_service.dart';
import 'migrations/migration.dart';
import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';

/// 迁移管理器
class MigrationManager {
  /// 所有迁移列表，按版本排序
  final List<Migration> migrations = [
    MigrationV1Initial(),
    MigrationV2History(),
    MigrationV3DownloadTask(),
    // [TODO_PLACEHOLDER] 将来新增的迁移在这里添加
  ];

  /// 获取当前数据库版本
  int getCurrentVersion(CommonDatabase db) {
    final stmt = db.prepare('PRAGMA user_version;');
    final ResultSet result = stmt.select([]);
    stmt.dispose();
    return result.first['user_version'] as int;
  }

  /// 运行所有需要的迁移
  void runMigrations(CommonDatabase db) {
    final currentVersion = getCurrentVersion(db);
    final pendingMigrations = migrations.where((m) => m.version > currentVersion).toList()
      ..sort((a, b) => a.version.compareTo(b.version));

    if (pendingMigrations.isEmpty) {
      LogUtils.i('当前数据库版本为 v$currentVersion，无需迁移');
      return;
    }

    db.execute('BEGIN TRANSACTION;');
    try {
      for (var migration in pendingMigrations) {
        LogUtils.i('正在应用迁移 v${migration.version}: ${migration.description}');
        migration.up(db);
      }
      db.execute('COMMIT;');
      LogUtils.i('所有迁移已成功应用');
    } catch (e) {
      db.execute('ROLLBACK;');
      throw DatabaseException("迁移失败: $e");
    }
  }
}
