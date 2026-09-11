import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/db/migrations/migration.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 跑完全部迁移之后的 schema 黄金快照。
///
/// # ⛔ 这条闸门挡的是什么
///
/// **改动一条已经发布出去的迁移的 DDL。** 这是唯一一个能造成真实生产 drift 的
/// 机制：老用户的库是按旧 DDL 建的，`user_version` 已经越过那一版，改动永远不会
/// 在他们机器上生效——而新装用户拿到的是新 DDL。两拨人从此拿着不同的 schema，
/// 且双方都不报错。
///
/// git 历史显示这个项目**确实在发布后编辑过迁移**（v3/v4/v5/v7/v8/v9/v10/v11/
/// v12/v13/v14 都被改过），至今只是运气好，改的全是注释、格式和把
/// `PRAGMA user_version` 摘出去，没碰过 DDL。这个文件把运气变成闸门。
///
/// 快照红了不等于错了——加一条新迁移本来就会改变最终 schema。红的含义是
/// **「请确认这次改动是你想要的」**：如果是新迁移带来的，重新生成快照即可；
/// 如果你没加新迁移它却变了，那就是动了历史 DDL，停下来想清楚。
///
/// # 重新生成
///
/// ```bash
/// UPDATE_GOLDEN=1 flutter test test/db/schema_golden_test.dart
/// ```
///
/// # ⛔ 为什么比的是「集合」而不是 sqlite_master 原文
///
/// `ALTER TABLE ADD COLUMN` 会把列定义追加到 sqlite_master 里存的那段 CREATE
/// 文本末尾。于是「新装」与「从老版本升上来」两条路径建出的表，列的**集合**
/// 相同、**文本**不同。migration_v30_local_media.dart 的类注释明确说明了这个
/// 差异是故意接受的（全仓库按列名访问，顺序不参与任何逻辑），所以这里比排序后
/// 的列元组集合，不比原文。
const String _goldenPath = 'test/db/golden_schema.txt';

/// v7 不参与：它是唯一有平台依赖的一条（StorageService → GetStorage），
/// 而且**不做任何 DDL**（只把配置值搬进 v6 建好的 app_config 表），
/// 跳过它不影响最终 schema。
List<Migration> _migrationsForSchema() =>
    MigrationManager.defaultMigrations().where((m) => m.version != 7).toList();

/// 把当前库的 schema 规范化成一段可 diff 的文本。
String dumpSchema(CommonDatabase db) {
  final buffer = StringBuffer();

  final tables = db
      .select(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name;",
      )
      .map((r) => r['name'] as String)
      .toList();

  for (final table in tables) {
    buffer.writeln('TABLE $table');

    final columns =
        db
            .select("PRAGMA table_info('$table')")
            .map(
              (r) =>
                  '  COLUMN ${r['name']} ${r['type']}'
                  '${(r['notnull'] as int) == 1 ? ' NOT NULL' : ''}'
                  '${r['dflt_value'] == null ? '' : ' DEFAULT ${r['dflt_value']}'}'
                  '${(r['pk'] as int) > 0 ? ' PK${r['pk']}' : ''}',
            )
            .toList()
          ..sort();
    buffer.writeAll(columns, '\n');
    buffer.writeln();

    for (final kind in const ['index', 'trigger']) {
      final items =
          db
              .select(
                "SELECT name, sql FROM sqlite_master WHERE type=? AND tbl_name=?;",
                [kind, table],
              )
              .map((r) {
                final sql = r['sql'];
                // UNIQUE 约束产生的自动索引没有 sql，只有名字。
                final normalized = sql == null
                    ? '(auto)'
                    : (sql as String).replaceAll(RegExp(r'\s+'), ' ').trim();
                return '  ${kind.toUpperCase()} ${r['name']} :: $normalized';
              })
              .toList()
            ..sort();
      buffer.writeAll(items, '\n');
      if (items.isNotEmpty) buffer.writeln();
    }
  }

  return buffer.toString();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  test('⛔ 跑完全部迁移后的 schema 必须与黄金快照一致', () async {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);

    await MigrationManager(
      migrations: _migrationsForSchema(),
    ).runMigrations(db);
    final actual = dumpSchema(db);

    final goldenFile = File(_goldenPath);

    if (Platform.environment['UPDATE_GOLDEN'] == '1') {
      goldenFile.writeAsStringSync(actual);
      // ignore: avoid_print
      print('已重新生成 $_goldenPath（${actual.split('\n').length} 行）');
      return;
    }

    expect(
      goldenFile.existsSync(),
      isTrue,
      reason: '缺少 $_goldenPath，用 UPDATE_GOLDEN=1 flutter test 生成',
    );

    final expected = goldenFile.readAsStringSync();
    if (actual != expected) {
      // 把实际值落盘，方便用 diff 看清差在哪。
      File('$_goldenPath.actual').writeAsStringSync(actual);
    }

    expect(
      actual,
      expected,
      reason:
          'schema 与黄金快照不一致。\n'
          '· 如果这次**加了新迁移**：属预期，用 '
          '`UPDATE_GOLDEN=1 flutter test test/db/schema_golden_test.dart` 重新生成。\n'
          '· 如果这次**没加新迁移**：说明改动了某条已发布迁移的 DDL——'
          '那个改动在老用户机器上永远不会生效（user_version 已越过它），'
          '会让新装与升级上来的库拿到不同的 schema。停下来确认。\n'
          '实际结果已写到 $_goldenPath.actual，可 diff 对比。',
    );
  });
}
