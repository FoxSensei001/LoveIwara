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
}

/// 一个"先把事务提交掉、再抛错"的迁移。
/// 用来确定性地复现「manager 的 ROLLBACK 自身会失败」那一类情形。
class _SelfCommittingThrowingMigration extends Migration {
  _SelfCommittingThrowingMigration(this.version);
  @override
  final int version;
  @override
  String get description => 'self-committing throwing v$version';
  @override
  void up(CommonDatabase db) {
    db.execute('COMMIT;'); // 事务没了，之后的 ROLLBACK 必然报错
    throw StateError('boom-real-cause');
  }
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

  group('MigrationManager - 逐条事务：失败只回滚失败的那一条', () {
    test('同步迁移抛错 → 只回滚它自己，之前成功的迁移与版本号都保留', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _ThrowingMigration(2)],
      );

      await expectLater(
        mgr.runMigrations(db),
        throwsA(isA<DatabaseException>()),
      );

      expect(userVersion(db), 1, reason: 'v1 已提交，版本号应停在 1 而不是退回 0');
      expect(tableExists(db, 't_v1'), isTrue, reason: 'v1 的建表不该被 v2 的失败牵连');
      expect(
        tableExists(db, 't_should_rollback_v2'),
        isFalse,
        reason: 'v2 自己的写入必须随它自己的事务回滚',
      );
    });

    test('异步迁移抛错 → 同样只回滚它自己', () async {
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _ThrowingMigration(2, async: true)],
      );

      await expectLater(
        mgr.runMigrations(db),
        throwsA(isA<DatabaseException>()),
      );

      expect(userVersion(db), 1);
      expect(tableExists(db, 't_v1'), isTrue);
      expect(tableExists(db, 't_should_rollback_v2'), isFalse);
    });

    test('失败后重启：从失败的那一条继续，不从头再来', () async {
      // 第一次：v2 炸了。
      await expectLater(
        MigrationManager(
          migrations: [_SyncMigration(1), _ThrowingMigration(2)],
        ).runMigrations(db),
        throwsA(isA<DatabaseException>()),
      );
      expect(userVersion(db), 1);

      // 第二次（模拟修好后的下一次启动）：只跑 v2、v3，不会因为重跑 v1 的
      // CREATE TABLE 而炸。整批一个事务的旧实现在这里是跑不通的——版本号会
      // 退回 0，v1 每次都要重来。
      await MigrationManager(
        migrations: [_SyncMigration(1), _SyncMigration(2), _SyncMigration(3)],
      ).runMigrations(db);

      expect(userVersion(db), 3);
      expect(tableExists(db, 't_v2'), isTrue);
      expect(tableExists(db, 't_v3'), isTrue);
    });

    test('回滚自身失败时，不许顶掉真正的死因', () async {
      // _SelfCommittingThrowingMigration 会先把事务提交掉再抛错，于是 manager
      // 的 ROLLBACK 必然报 "cannot rollback - no transaction is active"。
      // 这是 SQLite 在 FULL/IOERR/BUSY/NOMEM 下自动回滚整个事务那一类情形的
      // 确定性复现：若不吞掉回滚异常，调用方拿到的会是"无法回滚"，真因蒸发。
      final mgr = MigrationManager(
        migrations: [_SelfCommittingThrowingMigration(1)],
      );

      await expectLater(
        mgr.runMigrations(db),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.message,
            'message',
            allOf(contains('boom-real-cause'), contains('v1')),
          ),
        ),
      );
    });
  });

  group('MigrationManager - 版本号闸门', () {
    test('重复版本号被 validateVersions 挡下', () {
      final problem = MigrationManager.validateVersions([
        _SyncMigration(1),
        _SyncMigration(2),
        _SyncMigration(2),
      ]);
      expect(problem, isNotNull);
      expect(problem, contains('重复'));
    });

    test('v0 被挡下（0 是"空库"的含义）', () {
      expect(MigrationManager.validateVersions([_SyncMigration(0)]), isNotNull);
    });

    test('严格递增的列表通过', () {
      // 允许有空洞（本仓库的 23~29 就是），只要不重复、不小于 1。
      expect(
        MigrationManager.validateVersions([
          _SyncMigration(1),
          _SyncMigration(22),
          _SyncMigration(30),
        ]),
        isNull,
      );
      expect(MigrationManager.validateVersions([]), isNull);
    });

    test('真实的 defaultMigrations() 自身合法', () {
      expect(
        MigrationManager.validateVersions(MigrationManager.defaultMigrations()),
        isNull,
      );
    });

    test('构造 MigrationManager 时 assert 会挡下重复版本号', () {
      expect(
        () => MigrationManager(
          migrations: [_SyncMigration(5), _SyncMigration(5)],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('MigrationManager - 装回旧版（库比代码新）', () {
    test('user_version 高于已知最高版本时不抛错、不改动数据库', () async {
      db.execute('PRAGMA user_version = 99;');
      final mgr = MigrationManager(
        migrations: [_SyncMigration(1), _SyncMigration(2)],
      );

      await mgr.runMigrations(db);

      expect(userVersion(db), 99, reason: '不得把版本号往回写');
      expect(tableExists(db, 't_v1'), isFalse, reason: '不得重跑历史迁移');
      expect(mgr.highestVersion, 2);
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

  group('⭐ MigrationManager - 全新安装跑完整条链路', () {
    // 在此之前，**v8~v38 没有被任何测试执行过**：唯一的真实迁移用例只跑到 v6。
    // 全新安装恰恰要把这 30 条一次跑完，其中任何一条在空库上跑不通都会让
    // 「装上就打不开」——而这正是最难在开发机上发现的一类故障，因为开发机的
    // user_version 早就越过它们了。

    /// 除 v7 外的全部真实迁移。
    ///
    /// v7 是唯一有平台依赖的一条（`StorageService` → GetStorage，要 plugin
    /// channel），单测里起不来。它只做一件事：把配置**值**从旧存储搬进
    /// `app_config` 表（表本身由 v6 建），不改任何 schema，所以跳过它不影响
    /// 后面 30 条的前置条件。
    List<Migration> realMigrationsWithoutV7() =>
        MigrationManager.defaultMigrations()
            .where((m) => m.version != 7)
            .toList();

    test('空库上跑完 v1→v39 不抛错，版本号到达最高版', () async {
      final mgr = MigrationManager(migrations: realMigrationsWithoutV7());

      await mgr.runMigrations(db);

      expect(userVersion(db), mgr.highestVersion);
      expect(userVersion(db), 39, reason: '当前最高迁移版本是 39，加了新迁移要同步改这里');
    });

    test('跑完后各条工作线的核心表都在', () async {
      await MigrationManager(
        migrations: realMigrationsWithoutV7(),
      ).runMigrations(db);

      for (final table in const [
        // v1~v6 的地基
        'sign_in_records', 'history_records', 'download_tasks',
        'favorite_folders', 'video_playback_history', 'app_config',
        // v9 表情库
        'EmojiGroups', 'EmojiImages',
        // v18 下载分类 —— database_service 里那张"安全网"补的就是它
        'download_categories',
        // v20~v22
        'oreno3d_match_cache', 'watch_later', 'video_vr_override',
        // v30~v31 本地媒体
        'local_media_sources', 'local_media_items', 'local_media_progress',
        'local_media_folders', 'local_media_pinned_folders',
      ]) {
        expect(tableExists(db, table), isTrue, reason: '$table 应被创建');
      }
    });

    test('v18 的 category_id 列确实建出来了（否则启动期安全网会默默补建）', () async {
      await MigrationManager(
        migrations: realMigrationsWithoutV7(),
      ).runMigrations(db);

      final columns = db
          .select("PRAGMA table_info('download_tasks')")
          .map((r) => r['name'] as String)
          .toSet();
      expect(columns, contains('category_id'));
      // v13/v15/v19 加的列一并核一下，它们都是 ALTER TABLE ADD COLUMN
      expect(
        columns,
        containsAll(<String>[
          'media_type',
          'media_id',
          'quality',
          'completed_at',
          'error_type',
        ]),
      );
    });

    test('⭐ v30~v39 声称幂等：把版本号退回 29 再跑一遍，不许抛错', () async {
      // v30 的类文档明写这一版必须能把「已经跑过旧 v23~v29 的开发机」带上来，
      // 做法是 CREATE TABLE IF NOT EXISTS + 按 table_info 补列。这条测试直接
      // 钉住那个承诺：在一个**已经有全部表**的库上重跑 v30~v39。
      final migrations = realMigrationsWithoutV7();
      await MigrationManager(migrations: migrations).runMigrations(db);

      db.execute('PRAGMA user_version = 29;');
      await MigrationManager(migrations: migrations).runMigrations(db);

      expect(userVersion(db), 39);
      expect(tableExists(db, 'local_media_items'), isTrue);
    });

    test('⛔ 每一条迁移都必须能在"已经跑完"的库上重跑而不抛错', () async {
      // # 为什么要这条闸门
      //
      // 幂等不是为了"可以随便重跑"——正常路径上有 user_version 闸门，每条只跑
      // 一次。它是为了在**版本号与实际 schema 对不上**的时候还能被救回来，而不是
      // 每次启动都撞同一句 `duplicate column name`。
      // `DatabaseService._ensureDownloadCategorySchema` 的注释承认这种状态发生过，
      // 那块补丁本身就是一次手工急救。
      //
      // 2026-09-11 首次跑这条测试时 30 条里有 7 条不过，成因三类：
      // CREATE INDEX/TRIGGER 漏了 IF NOT EXISTS（v1/v2）、ALTER TABLE ADD COLUMN
      // 没查 table_info（v13/v14/v15）、种子数据直接 INSERT 撞 UNIQUE（v4/v9）。
      // 全部已修，见 lib/db/migrations/migration_sql.dart。
      //
      // ⚠️ 重跑"不抛错"是底线，不是全部。真正危险的是**静默改坏数据**：
      // v14 重跑会按 created_at 冲掉用户自己调的收藏夹顺序，v9 重跑会复活
      // v11 删掉的表情。这两条已经分别加了"只在真的加了列时才回填"和
      // "表已存在就整只跳过"的守卫——新增迁移时请一并考虑这一面。
      final migrations = realMigrationsWithoutV7();
      await MigrationManager(migrations: migrations).runMigrations(db);

      final offenders = <String>[];
      for (final m in migrations) {
        try {
          await m.up(db);
        } catch (e) {
          offenders.add(
            'v${m.version}（${m.description}）→ ${'$e'.split('\n').first}',
          );
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            '以下迁移在已迁移完的库上重跑会抛错，需要补幂等守卫'
            '（可用 migration_sql.dart 的 addColumnIfMissing / tableExists）：\n'
            '${offenders.join('\n')}',
      );
    });

    test('v14 重跑不许冲掉用户自己调过的收藏夹排序', () async {
      // 这条盯的是"重跑不抛错"之外的那一半：静默改坏数据。
      final migrations = realMigrationsWithoutV7();
      await MigrationManager(migrations: migrations).runMigrations(db);

      // 造两个收藏夹，并给出一个**与 created_at 次序相反**的自定义排序。
      db.execute(
        "INSERT INTO favorite_folders (id, title, created_at, display_order) "
        "VALUES ('a', 'A', 100, 0), ('b', 'B', 200, 1);",
      );

      final v14 = migrations.firstWhere((m) => m.version == 14);
      await v14.up(db);

      final rows = db.select(
        "SELECT id, display_order FROM favorite_folders "
        "WHERE id IN ('a','b') ORDER BY id;",
      );
      expect(rows.map((r) => r['display_order']).toList(), [
        0,
        1,
      ], reason: 'v14 重跑按 created_at DESC 重排会把 a/b 变成 1/0');
    });

    test('⛔ v9 遇到「组在、图表没了」的半套状态要补表，且不灌种子', () async {
      final migrations = realMigrationsWithoutV7();
      await MigrationManager(migrations: migrations).runMigrations(db);

      db.execute('DROP TABLE EmojiImages;');
      final groupsBefore = db
          .select('SELECT COUNT(*) AS c FROM EmojiGroups;')
          .first['c'];

      await migrations.firstWhere((m) => m.version == 9).up(db);

      expect(
        tableExists(db, 'EmojiImages'),
        isTrue,
        reason: '只看 EmojiGroups 的闸门会整只跳过，应用随后撞 no such table',
      );
      expect(
        db.select('SELECT COUNT(*) AS c FROM EmojiImages;').first['c'],
        0,
        reason: '补表**不灌种子**：种子会复活 v11 删掉的表情',
      );
      expect(
        db.select('SELECT COUNT(*) AS c FROM EmojiGroups;').first['c'],
        groupsBefore,
        reason: '分组表不该被再插一遍',
      );
    });

    test('v9 重跑不许复活 v11 删掉的表情', () async {
      final migrations = realMigrationsWithoutV7();
      await MigrationManager(migrations: migrations).runMigrations(db);

      final before = db
          .select('SELECT COUNT(*) AS c FROM EmojiGroups;')
          .first['c'];
      final imagesBefore = db
          .select('SELECT COUNT(*) AS c FROM EmojiImages;')
          .first['c'];

      await migrations.firstWhere((m) => m.version == 9).up(db);

      expect(
        db.select('SELECT COUNT(*) AS c FROM EmojiGroups;').first['c'],
        before,
        reason: 'v9 重跑会把 senkosan/neko 两个分组再插一遍',
      );
      expect(
        db.select('SELECT COUNT(*) AS c FROM EmojiImages;').first['c'],
        imagesBefore,
        reason: 'v9 重跑会把 v11 删掉的表情整批复活',
      );
    });
  });
}
