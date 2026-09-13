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
import 'package:i_iwara/db/migrations/migration_v15_download_task_completed_at.dart';
import 'package:i_iwara/db/migrations/migration_v16_download_task_status_index.dart';
import 'package:i_iwara/db/migrations/migration_v17_download_task_conflict_triggers.dart';
import 'package:i_iwara/db/migrations/migration_v18_download_category.dart';
import 'package:i_iwara/db/migrations/migration_v19_download_task_error_type.dart';
import 'package:i_iwara/db/migrations/migration_v20_oreno3d_match_cache.dart';
import 'package:i_iwara/db/migrations/migration_v21_watch_later.dart';
import 'package:i_iwara/db/migrations/migration_v22_vr_format_override.dart';
import 'package:i_iwara/db/migrations/migration_v30_local_media.dart';
import 'package:i_iwara/db/migrations/migration_v31_local_media_folders.dart';
import 'package:i_iwara/db/migrations/migration_v32_local_source_media_kinds.dart';
import 'package:i_iwara/db/migrations/migration_v33_local_folder_probed_at.dart';
import 'package:i_iwara/db/migrations/migration_v34_local_folder_cover_pinned.dart';
import 'package:i_iwara/db/migrations/migration_v35_local_media_sort_and_favorites.dart';
import 'package:i_iwara/db/migrations/migration_v36_local_media_index_direction.dart';
import 'package:i_iwara/db/migrations/migration_v37_local_media_image_favorites.dart';
import 'package:i_iwara/db/migrations/migration_v38_local_media_folder_scan_indexes.dart';
import 'package:i_iwara/db/migrations/migration_v39_local_media_perf_indexes.dart';
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
  /// 应用默认的迁移列表，按版本排序
  static List<Migration> defaultMigrations() => [
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
    MigrationV15DownloadTaskCompletedAt(),
    MigrationV16DownloadTaskStatusIndex(),
    MigrationV17DownloadTaskConflictTriggers(),
    MigrationV18DownloadCategory(),
    MigrationV19DownloadTaskErrorType(),
    MigrationV20Oreno3dMatchCache(),
    MigrationV21WatchLater(),
    MigrationV22VrFormatOverride(),
    // 本地媒体库整条线合成了一版（原 v23~v29）。App 还没正式发版，库外只有开发机，
    // 没必要把"边做边加"的七步当成七次线上升级留在这里；v30 自己是幂等的，停在
    // 23~29 任何一档的开发机都能被它带上来。见该文件的类注释。
    MigrationV30LocalMedia(),
    MigrationV31LocalMediaFolders(),
    MigrationV32LocalSourceMediaKinds(),
    MigrationV33LocalFolderProbedAt(),
    MigrationV34LocalFolderCoverPinned(),
    MigrationV35LocalMediaSortAndFavorites(),
    MigrationV36LocalMediaIndexDirection(),
    MigrationV37LocalMediaImageFavorites(),
    MigrationV38LocalMediaFolderScanIndexes(),
    MigrationV39LocalMediaPerfIndexes(),
    // [TODO_PLACEHOLDER] 将来新增的迁移在这里添加。
    // ⛔ 新迁移的版本号必须**大于当前最大值**（现在是 38，下一条就是 39）。
    //    绝不要回填 23~29 那段空洞：runMigrations 只跑 version > user_version
    //    的迁移，回填的那条在版本号已经越过它的设备上永远不会执行，且不报错。
    //    MigrationManager 的构造函数里有 assert 会在开发期挡下重复版本号。
  ];

  /// 所有迁移列表，按版本排序。
  /// 默认使用 [defaultMigrations]；测试可注入自定义列表。
  final List<Migration> migrations;

  MigrationManager({List<Migration>? migrations})
    : migrations = migrations ?? defaultMigrations() {
    assert(() {
      final problem = validateVersions(this.migrations);
      if (problem != null) throw StateError(problem);
      return true;
    }());
  }

  /// 校验迁移列表的版本号：必须存在、严格递增、不得重复。
  ///
  /// 为什么要有这道闸门：[runMigrations] 的取舍是 `m.version > currentVersion`，
  /// 也就是说**新加一条编号不大于当前库版本的迁移，在老设备上永远不会执行，
  /// 而且不报任何错**。这个仓库的版本号正好有个 23~29 的空洞（见
  /// [defaultMigrations] 里的注释），照着"找个没人用的号"回填是很自然的动作，
  /// 后果却是静默失效——只能靠开发期把它挡下来。
  ///
  /// 返回 `null` 表示没问题，否则返回问题描述。抽成静态方法是为了能单测。
  static String? validateVersions(List<Migration> migrations) {
    if (migrations.isEmpty) return null;
    final sorted = [...migrations]
      ..sort((a, b) => a.version.compareTo(b.version));
    if (sorted.first.version < 1) {
      return '迁移版本号必须 >= 1，发现 v${sorted.first.version}'
          '（${sorted.first.description}）；v0 是"空库"的含义，不能被占用';
    }
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].version == sorted[i - 1].version) {
        return '迁移版本号重复：v${sorted[i].version} 同时被 '
            '「${sorted[i - 1].description}」与「${sorted[i].description}」占用。'
            '新迁移的版本号必须大于现有的最大值，绝不能回填历史空洞——'
            '回填的那条在版本号已经越过它的设备上永远不会执行。';
      }
    }
    return null;
  }

  /// 本次构建已知的最高迁移版本。
  int get highestVersion => migrations.isEmpty
      ? 0
      : migrations.map((m) => m.version).reduce((a, b) => a > b ? a : b);

  /// 获取当前数据库版本
  int getCurrentVersion(CommonDatabase db) {
    final stmt = db.prepare('PRAGMA user_version;');
    try {
      final ResultSet result = stmt.select([]);
      return result.first['user_version'] as int;
    } finally {
      stmt.close();
    }
  }

  /// 运行所有需要的迁移
  ///
  /// 事务粒度是**每条迁移一个事务**，不是整批一个。整批一个事务看起来更"原子"，
  /// 实际效果是全新安装必须 v1→v39 一次全过，任何一条失败就整批回滚、版本号停在
  /// 原地，下次启动重跑同一批、同样失败——用户只能看着一个确定性失败的错误页，
  /// 卸载重装也救不回来。逐条事务保住已成功的进度，把爆炸半径收到失败的那一条：
  /// 下次启动从它继续，而不是从头再来。
  ///
  /// 注意：版本号（PRAGMA user_version）由本方法统一在每个迁移成功后写入，
  /// 迁移实现内部无需、也不应再负责写入版本号——即使迁移忘写或写错，
  /// 这里也会兜底为正确值，从根上杜绝"忘写版本号导致重复执行"的问题。
  Future<void> runMigrations(CommonDatabase db) async {
    final currentVersion = getCurrentVersion(db);
    final pendingMigrations =
        migrations.where((m) => m.version > currentVersion).toList()
          ..sort((a, b) => a.version.compareTo(b.version));

    if (pendingMigrations.isEmpty) {
      if (currentVersion > highestVersion) {
        // 装回了旧版（本项目是侧载分发，这是常见操作）。新 schema 通常是老
        // schema 的超集所以多半还能跑，但必须在日志里留下痕迹——否则真出事
        // 时，现场看不出这台机器的库比代码新。
        LogUtils.w(
          '数据库版本 v$currentVersion 高于本次构建已知的最高迁移版本 '
              'v$highestVersion：本次启动不做任何迁移，应用将以旧代码读写新 schema。'
              '（通常意味着装回了旧版本的安装包）',
          'MigrationManager',
        );
      } else {
        LogUtils.i('当前数据库版本为 v$currentVersion，无需迁移');
      }
      return;
    }

    LogUtils.i(
      '待应用的迁移：v${pendingMigrations.first.version} '
      '→ v${pendingMigrations.last.version}（共 ${pendingMigrations.length} 条），'
      '当前库版本 v$currentVersion',
    );

    for (final migration in pendingMigrations) {
      await _runOne(db, migration);
    }
    LogUtils.i('所有迁移已成功应用，当前数据库版本 v${getCurrentVersion(db)}');
  }

  /// 在独立事务里跑一条迁移。成功则提交并前进版本号，失败则回滚并抛出。
  Future<void> _runOne(CommonDatabase db, Migration migration) async {
    LogUtils.i('正在应用迁移 v${migration.version}: ${migration.description}');
    try {
      // ⛔ BEGIN 也要在 try 里。它自己也会抛（比如上一条的 COMMIT 失败、
      // ROLLBACK 也失败，事务还开着 → "cannot start a transaction within a
      // transaction"）。放在 try 外面的话，那条裸 SqliteException 会绕过下面的
      // 包装，恰好丢掉「是哪条迁移」这个信息——而那正是最需要它的场景。
      db.execute('BEGIN TRANSACTION;');
      // await 以正确纳入事务：同步迁移立即完成，异步迁移（如 v7）也会
      // 在事务内被等待，其异常同样能被下方 catch 捕获并触发回滚。
      //
      // ⚠️ 异步迁移在 await 期间事务是开着的，而 DatabaseService 是全局单例、
      // `_db` 在跑迁移之前就已赋值——这期间任何碰 `.database` 的代码都会挤进
      // 这个事务。新增异步迁移时，`up()` 里除了 db 之外不要再 await 任何可能
      // 回头读写数据库的东西。
      await migration.up(db);
      // 由 manager 统一、强制写入版本号（migration.version 为本地 int，拼接安全）。
      db.execute('PRAGMA user_version = ${migration.version};');
      db.execute('COMMIT;');
      LogUtils.i('迁移 v${migration.version} 已提交');
    } catch (e, stackTrace) {
      _rollbackQuietly(db, migration);
      // 用原始 stackTrace 重抛：否则调用方只拿到一句字符串，看不出是哪条 SQL
      // 炸的。同时把版本号和描述写进消息里——DatabaseService 会原样放行这条
      // DatabaseException（不再套一层），现场直接能看到是哪条迁移死的。
      Error.throwWithStackTrace(
        DatabaseException(
          '迁移 v${migration.version}（${migration.description}）失败: $e',
        ),
        stackTrace,
      );
    }
  }

  /// 回滚，且**绝不让回滚自身的异常顶掉真正的死因**。
  ///
  /// SQLite 在 SQLITE_FULL / IOERR / BUSY / NOMEM 这几种错误下可能已经自动
  /// 回滚了整个事务，这时再显式 ROLLBACK 会报 "cannot rollback - no
  /// transaction is active"。如果不吞掉，这条新异常会顶替掉 [_runOne] 接下来
  /// 要抛的那条，调用方看到的是"无法回滚"，而真因（比如磁盘满）当场蒸发。
  void _rollbackQuietly(CommonDatabase db, Migration migration) {
    try {
      db.execute('ROLLBACK;');
    } catch (rollbackError) {
      LogUtils.w(
        '迁移 v${migration.version} 失败后回滚未能执行'
            '（事务可能已被 SQLite 自动回滚）: $rollbackError',
        'MigrationManager',
      );
    }
  }
}
