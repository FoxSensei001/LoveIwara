import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/db/migration_manager.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 「安全网」补建路径的测试。
///
/// 它的价值全在**真出事那天能不能报数**上——一条「发现漏洞就自动修」的路径
/// 如果自己没有测试、修了又不留痕，那它既救不了人，也无法被证伪。
/// 见 `DatabaseService.ensureCriticalSchema` 的文档。
void main() {
  late CommonDatabase db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() async {
    db = sqlite3.openInMemory();
    await MigrationManager(
      migrations: MigrationManager.defaultMigrations()
          .where((m) => m.version != 7)
          .toList(),
    ).runMigrations(db);
  });

  tearDown(() => db.close());

  bool tableExists(String name) => db.select(
    "SELECT name FROM sqlite_master WHERE type='table' AND name = ?;",
    [name],
  ).isNotEmpty;

  Set<String> columnsOf(String table) => db
      .select("PRAGMA table_info('$table')")
      .map((r) => r['name'] as String)
      .toSet();

  test('schema 完好时一个字都不动，返回空', () {
    final repairs = DatabaseService.ensureCriticalSchema(db);
    expect(repairs, isEmpty, reason: '迁移跑完之后就不该有可补的东西——若这里非空，说明某条迁移没把活干完');
  });

  test('表被删掉时补建出来，并报出补了什么', () {
    db.execute('DROP TABLE download_categories;');
    expect(tableExists('download_categories'), isFalse);

    final repairs = DatabaseService.ensureCriticalSchema(db);

    expect(tableExists('download_categories'), isTrue);
    expect(repairs, hasLength(1));
    expect(repairs.single, contains('download_categories'));
  });

  test('列缺失时补上，并报出补了什么', () {
    // SQLite 不支持 DROP COLUMN（老版本），这里整表重建成"缺列"的形态。
    db.execute('DROP TABLE download_tasks;');
    db.execute('CREATE TABLE download_tasks(id TEXT PRIMARY KEY);');
    expect(columnsOf('download_tasks'), isNot(contains('category_id')));

    final repairs = DatabaseService.ensureCriticalSchema(db);

    expect(columnsOf('download_tasks'), contains('category_id'));
    expect(repairs, hasLength(1));
    expect(repairs.single, contains('category_id'));
  });

  test('两项都缺时都补，且补完再跑一次就干净了', () {
    db.execute('DROP TABLE download_categories;');
    db.execute('DROP TABLE download_tasks;');
    db.execute('CREATE TABLE download_tasks(id TEXT PRIMARY KEY);');

    expect(DatabaseService.ensureCriticalSchema(db), hasLength(2));
    expect(
      DatabaseService.ensureCriticalSchema(db),
      isEmpty,
      reason: '补完之后必须归于安静，否则诊断页会永远显示"曾被补建"',
    );
  });

  test('⛔ download_tasks 整张表缺失时不许抛异常，如实记录后停手', () {
    // PRAGMA table_info 对不存在的表返回**空结果集**（不抛），于是"表没了"很容易
    // 被误判成"只是缺 category_id 这一列"，紧接着的 ALTER 抛 no such table，
    // 把整个安全网连同后面的索引一起带走。
    db.execute('DROP TABLE download_tasks;');

    late List<String> repairs;
    expect(
      () => repairs = DatabaseService.ensureCriticalSchema(db),
      returnsNormally,
    );
    expect(repairs, hasLength(1));
    expect(repairs.single, contains('download_tasks'));
    expect(
      tableExists('download_tasks'),
      isFalse,
      reason: '建表是迁移 v3 的职责，安全网不该越俎代庖',
    );
  });

  test('补建出的表能被正常写入（不是个空壳）', () {
    db.execute('DROP TABLE download_categories;');
    DatabaseService.ensureCriticalSchema(db);

    db.execute(
      "INSERT INTO download_categories(id, title) VALUES('c1', '测试分类');",
    );
    final rows = db.select(
      'SELECT id, title, display_order '
      'FROM download_categories;',
    );
    expect(rows, hasLength(1));
    expect(rows.first['title'], '测试分类');
    expect(rows.first['display_order'], 0, reason: 'display_order 应有默认值 0');
  });
}
