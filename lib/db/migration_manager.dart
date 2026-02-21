// lib/migrations/migration_manager.dart

import 'package:i_iwara/db/migrations/migration_v3.dart';
import 'package:i_iwara/db/migrations/migration_v4.dart';
import 'package:i_iwara/db/migrations/migration_v5.dart';
import 'package:i_iwara/db/migrations/migration_v8_disable_theater.dart';
import 'package:i_iwara/db/migrations/migration_v9_emoji_library.dart';
import 'package:i_iwara/db/migrations/migration_v10_remove_logs.dart';
import 'package:i_iwara/db/migrations/migration_v11_emoji_removal.dart';
import 'package:i_iwara/db/migrations/migration_v12_linux_do_emoji_update.dart';
import 'package:i_iwara/db/migrations/migration_v13_download_task_media_index.dart';
import 'package:i_iwara/db/migrations/migration_v14_favorite_folder_order.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

import 'database_service.dart';
import 'migrations/migration.dart';
import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';
import 'migrations/migration_v6_config.dart';
import 'migrations/migration_v7_config_storage.dart';

/// 迁移管理器
class MigrationManager {
  /// 所有迁移列表，按版本排序
  final List<Migration> migrations = [
    MigrationV1Initial(),
    MigrationV2History(),
    MigrationV3DownloadTask(),
    MigrationV4Favorites(),
    MigrationV5PlaybackHistory(),
    MigrationV6Config(),
    MigrationV7ConfigStorage(),
    MigrationV8DisableTheater(),
    MigrationV9EmojiLibrary(),
    MigrationV10RemoveLogs(),
    MigrationV11EmojiRemoval(),
    MigrationV12LinuxDoEmojiUpdate(),
    MigrationV13DownloadTaskMediaIndex(),
    MigrationV14FavoriteFolderOrder(),
    // [TODO_PLACEHOLDER] 将来新增的迁移在这里添加
  ];

  /// 获取当前数据库版本
  int getCurrentVersion(CommonDatabase db) {
    final stmt = db.prepare('PRAGMA user_version;');
    final ResultSet result = stmt.select([]);
    stmt.close();
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
