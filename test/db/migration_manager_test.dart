import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/db/database_service.dart' show DatabaseException;
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/db/migrations/migration.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 读取 PRAGMA user_version
int userVersion(CommonDatabase db) {
  final rs = db.select('PRAGMA user_version;');
  return rs.first['user_version'] as int;
}

/// 一个普通的同步迁移：建一张以版本号命名的表。
/// 故意**不**自己写 user_version——用于验证 manager 会兜底写入。
class _SyncMigration extends Migration {
  _SyncMigration(this.version);
  @override
  final int version;
  @override
  String get description => 'sync v$version';
  @override
  void up(CommonDatabase db) {
    db.execute('CREATE TABLE t_v$version (id INTEGER PRIMARY KEY);');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP TABLE IF EXISTS t_v$version;');
  }
}

/// 一个异步迁移：在真正的 await 之后才写入数据。
/// 用于验证 manager 会 await（写入落在事务内、COMMIT 后可见）。
class _AsyncMigration extends Migration {
  _AsyncMigration(this.version);
  @override
  final int version;
  @override
  String get description => 'async v$version';
  @override
  Future<void> up(CommonDatabase db) async {
    await Future<void>.delayed(Duration.zero);
    db.execute('CREATE TABLE t_async_v$version (id INTEGER PRIMARY KEY);');
  }

  @override
  void down(CommonDatabase db) {}
}

/// 一个会抛异常的迁移，用于验证回滚。
/// 先建表、再抛错——若未回滚，表会残留。
class _ThrowingMigration extends Migration {
  _ThrowingMigration(this.version, {this.async = false});
  @override
  final int version;
  final bool async;
  @override
  String get description => 'throwing v$version';
  @override
  FutureOr<void> up(CommonDatabase db) {
    db.execute('CREATE TABLE t_should_rollback_v$version (id INTEGER);');
    if (async) {
      return Future<void>.delayed(
        Duration.zero,
      ).then((_) => throw StateError('boom-async'));
    }
    throw StateError('boom-sync');
  }

  @override
  void down(CommonDatabase db) {}
}

bool tableExists(CommonDatabase db, String name) {
  final rs = db.select(
    "SELECT name FROM sqlite_master WHERE type='table' AND name=?;",
    [name],
  );
  return rs.isNotEmpty;
}

void main() {
  late CommonDatabase db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // runMigrations 内部会调用 LogUtils.i，需先初始化 logger，否则会抛
    // LateInitializationError。关闭持久化以避免触碰日志数据库。
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
  });

  tearDown(() {
    db.close();
  });

  group('MigrationManager - 版本号由 manager 统一兜底', () {
    test('新库跑完后 user_version = 最高版本，且每个迁移都执行', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _SyncMigration(2), _SyncMigration(3)],
      );
      await mgr.runMigrations(db);

      expect(userVersion(db), 3);
      expect(tableExists(db, 't_v1'), isTrue);
      expect(tableExists(db, 't_v2'), isTrue);
      expect(tableExists(db, 't_v3'), isTrue);
    });

    test('迁移自身不写 user_version 也能拿到正确版本（v10 式缺陷的兜底回归）', () async {
      // _SyncMigration 故意从不写 user_version——模拟 v10 漏写的情况。
      final mgr = MigrationManager(migrations: [_SyncMigration(10)]);
      // 起始版本设为 9，模拟“仅含到 v10 的发布”。
      db.execute('PRAGMA user_version = 9;');

      await mgr.runMigrations(db);

      expect(userVersion(db), 10, reason: 'manager 必须兜底写入版本号');
    });

    test('只执行高于当前版本的迁移', () async {
      db.execute('PRAGMA user_version = 2;');
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _SyncMigration(2), _SyncMigration(3)],
      );
      await mgr.runMigrations(db);

      expect(userVersion(db), 3);
      expect(tableExists(db, 't_v1'), isFalse, reason: 'v1 不应重复执行');
      expect(tableExists(db, 't_v2'), isFalse, reason: 'v2 不应重复执行');
      expect(tableExists(db, 't_v3'), isTrue);
    });

    test('幂等：连续两次 runMigrations，第二次为 no-op 且不抛错', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _SyncMigration(2)],
      );
      await mgr.runMigrations(db);
      expect(userVersion(db), 2);

      // 第二次不应抛错（若重跑会因 CREATE TABLE 重复而抛错）。
      await mgr.runMigrations(db);
      expect(userVersion(db), 2);
    });
  });

  group('MigrationManager - 异步迁移（v7 式）被正确 await', () {
    test('异步迁移的写入在 COMMIT 后可见，且版本号正确', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _AsyncMigration(2), _SyncMigration(3)],
      );
      await mgr.runMigrations(db);

      expect(userVersion(db), 3);
      expect(
        tableExists(db, 't_async_v2'),
        isTrue,
        reason: '异步迁移必须被 await，否则其建表不会落库',
      );
      expect(tableExists(db, 't_v3'), isTrue);
    });
  });

  group('MigrationManager - 失败时整体回滚', () {
    test('同步迁移抛错 → ROLLBACK，已建的表与版本号都不保留', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _ThrowingMigration(2)],
      );

      await expectLater(
        mgr.runMigrations(db),
        throwsA(isA<DatabaseException>()),
      );

      expect(userVersion(db), 0, reason: '回滚后版本号应保持初始值');
      expect(tableExists(db, 't_v1'), isFalse, reason: 'v1 的建表应随事务回滚');
      expect(tableExists(db, 't_should_rollback_v2'), isFalse);
    });

    test('异步迁移抛错 → 同样被捕获并 ROLLBACK', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _ThrowingMigration(2, async: true)],
      );

      await expectLater(
        mgr.runMigrations(db),
        throwsA(isA<DatabaseException>()),
      );

      expect(userVersion(db), 0);
      expect(tableExists(db, 't_v1'), isFalse);
      expect(tableExists(db, 't_should_rollback_v2'), isFalse);
    });
  });

  group('MigrationManager - 真实迁移（无平台依赖的 v1–v6）', () {
    test('跑真实 v1–v6 后建出核心表，版本号为 6', () async {
      // 仅取无平台依赖的真实迁移（v7 依赖 StorageService/GetStorage，跳过）。
      final real = MigrationManager.defaultMigrations()
          .where((m) => m.version <= 6)
          .toList();
      final mgr = MigrationManager(migrations: real);

      await mgr.runMigrations(db);

      expect(userVersion(db), 6);
      for (final table in const [
        'sign_in_records',
        'history_records',
        'download_tasks',
        'favorite_folders',
        'video_playback_history',
        'app_config',
      ]) {
        expect(tableExists(db, table), isTrue, reason: '$table 应被创建');
      }
    });
  });
}
