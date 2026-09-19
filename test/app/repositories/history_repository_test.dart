import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/db/migrations/migration_v2.dart';
import 'package:i_iwara/db/migrations/migration_v45_history_last_viewed_indexes.dart';
import 'package:i_iwara/db/migrations/migration_v5.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// 浏览历史仓库的单测，钉住这套口径：
///
/// - 一切按「最后浏览时间」（`updated_at`）排序 / 筛选 / 删除；
/// - 删历史同事务带走视频的观看进度，恢复时原样带回来（含时间不被触发器刷新）；
/// - 关键字 LIKE 的转义（`%` / `_` 是字面量，不当通配符）；
/// - 时间参数走 [HistoryRepository.sqlTime]，UTC 字符串比较，「今天」不漏段。
///
/// 表结构用真实迁移建（v2 → v5 → v45），不复刻 DDL——v45 要改 v2 建的索引，
/// 少跑一步测出来的就不是生产 schema。
void main() {
  late CommonDatabase db;
  late HistoryRepository repo;
  bool enableHistoryBackup = false;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 迁移内部会调用 LogUtils.i，需先初始化 logger，否则会抛 LateInitializationError。
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV2History().up(db);
    MigrationV5PlaybackHistory().up(db);
    MigrationV45HistoryLastViewedIndexes().up(db);
    repo = HistoryRepository(database: db);
    enableHistoryBackup = CommonConstants.enableHistory;
    CommonConstants.enableHistory = true;
  });

  tearDown(() {
    CommonConstants.enableHistory = enableHistoryBackup;
    db.close();
  });

  /// 直接 INSERT（带显式时间戳）。INSERT 不触发 AFTER UPDATE 触发器，
  /// 时间戳可以精确钉住；触发器只该在「重新浏览」这条路上生效。
  void insertHistory(
    String itemId, {
    String itemType = 'video',
    String title = 't',
    required String updatedAt,
    String createdAt = '2020-01-01 00:00:00',
  }) {
    db.execute(
      '''
      INSERT INTO history_records
        (item_id, item_type, title, data, created_at, updated_at)
      VALUES (?, ?, ?, '{}', ?, ?)
      ''',
      [itemId, itemType, title, createdAt, updatedAt],
    );
  }

  void insertProgress(String videoId, int playedMs, int totalMs) {
    db.execute(
      'INSERT INTO video_playback_history (video_id, total_duration, played_duration) '
      'VALUES (?, ?, ?)',
      [videoId, totalMs, playedMs],
    );
  }

  int idOf(String itemId) => db
      .select('SELECT id FROM history_records WHERE item_id = ?', [itemId])
      .first['id'] as int;

  int historyCount(String itemId) => db
      .select(
        'SELECT COUNT(*) AS c FROM history_records WHERE item_id = ?',
        [itemId],
      ).first['c'] as int;

  int progressCount(String videoId) => db
      .select(
        'SELECT COUNT(*) AS c FROM video_playback_history WHERE video_id = ?',
        [videoId],
      ).first['c'] as int;

  Future<List<String>> listedIds() async => [
    for (final r in await repo.listRecords(itemType: 'video')) r.itemId,
  ];

  group('sqlTime', () {
    test('本地时间点转成与列同格式的 UTC 字符串', () {
      expect(
        HistoryRepository.sqlTime(DateTime.utc(2020, 3, 5, 7, 8, 9)),
        '2020-03-05 07:08:09',
      );
    });
  });

  group('排序', () {
    test('按最后浏览时间倒序；重新浏览的老记录浮到最前', () async {
      // 2020 年的种子，对真实时钟足够旧（触发器写的是 datetime('now')）。
      insertHistory('v1', updatedAt: '2020-01-01 00:00:00');
      insertHistory('v2', updatedAt: '2020-02-01 00:00:00');
      insertHistory('v3', updatedAt: '2020-03-01 00:00:00');
      expect(await listedIds(), ['v3', 'v2', 'v1']);

      // 重看 v1：upsert 走触发器把 updated_at 刷成 now → 浮到最前。
      await repo.addRecord(
        HistoryRecord(
          id: 0,
          itemId: 'v1',
          itemType: 'video',
          title: 't',
          data: '{}',
        ),
      );
      expect(await listedIds(), ['v1', 'v3', 'v2']);
      // 首次浏览时间保留（没有随重看重置）。
      final row = db.select(
        "SELECT created_at FROM history_records WHERE item_id = 'v1'",
      ).first;
      expect(row['created_at'], '2020-01-01 00:00:00');
    });

    test('分页 offset/limit 不重不漏', () async {
      for (var i = 0; i < 25; i++) {
        insertHistory(
          'v$i',
          updatedAt: '2020-01-01 00:00:${i.toString().padLeft(2, '0')}',
        );
      }
      final page1 = await repo.listRecords(itemType: 'video', limit: 20);
      final page2 = await repo.listRecords(
        itemType: 'video',
        limit: 20,
        offset: 20,
      );
      expect(page1, hasLength(20));
      expect(page2, hasLength(5));
      final all = [...page1, ...page2].map((r) => r.itemId).toSet();
      expect(all, hasLength(25));
      expect(page1.first.itemId, 'v24');
      expect(page2.first.itemId, 'v4');
    });
  });

  group('观看进度', () {
    test('视频带出进度；看完记 played == total；图库无进度', () async {
      insertHistory('v1', updatedAt: '2020-01-01 00:00:00');
      insertProgress('v1', 50000, 200000);
      insertHistory('v2', updatedAt: '2020-01-02 00:00:00');
      insertProgress('v2', 200000, 200000);
      insertHistory('g1', itemType: 'image', updatedAt: '2020-01-03 00:00:00');

      final records = await repo.listRecords(itemType: 'video');
      final v1 = records.firstWhere((r) => r.itemId == 'v1');
      final v2 = records.firstWhere((r) => r.itemId == 'v2');
      expect(v1.playedMs, 50000);
      expect(v1.totalMs, 200000);
      expect(v1.progress, 0.25);
      expect(v1.isFinished, isFalse);
      expect(v2.isFinished, isTrue);

      final g1 = (await repo.listRecords(itemType: 'image')).single;
      expect(g1.playedMs, isNull);
      expect(g1.progress, isNull);
    });
  });

  group('删除', () {
    test('删历史连同视频进度一起删；没删的进度原地不动', () async {
      insertHistory('v1', updatedAt: '2020-01-01 00:00:00');
      insertProgress('v1', 10000, 100000);
      insertHistory('v2', itemType: 'image', updatedAt: '2020-01-02 00:00:00');
      insertHistory('v3', updatedAt: '2020-01-03 00:00:00');
      insertProgress('v3', 30000, 100000);

      await repo.deleteRecords([idOf('v1'), idOf('v2')]);

      expect(historyCount('v1'), 0);
      expect(historyCount('v2'), 0);
      expect(progressCount('v1'), 0);
      expect(progressCount('v3'), 1);
    });

    test('按区间 + 关键字删除只删命中的；LIKE 通配符被转义', () async {
      insertHistory('pct', title: '100%_cool', updatedAt: '2020-03-10 12:00:00');
      insertHistory('plain', title: 'plain', updatedAt: '2020-03-11 12:00:00');
      insertHistory('us', title: 'under_score', updatedAt: '2020-04-01 12:00:00');
      insertHistory(
        'pctImage',
        itemType: 'image',
        title: '100%_cool',
        updatedAt: '2020-03-10 12:00:00',
      );

      // 转义生效：'%' / '_' 是字面量。不转义的话 '%' 命中全部、'_' 也命中 'plain'。
      expect(await repo.countRecords(itemType: 'video', keyword: '%'), 1);
      expect(await repo.countRecords(itemType: 'all', keyword: '%'), 2);
      expect(await repo.countRecords(itemType: 'video', keyword: '_'), 2);
      expect(await repo.countRecords(itemType: 'video', keyword: '100%'), 1);

      // 只删区间内、视频类、命中关键字的：'100%_cool'（03-10）。
      // 区间边界取整天，UTC 平移 ±14h 内断言都成立。
      final removed = await repo.deleteRecordsByTimeRange(
        itemType: 'video',
        keyword: '_',
        startDate: DateTime(2020, 3, 5),
        endDate: DateTime(2020, 3, 20, 23, 59, 59),
      );
      expect(removed, 1);
      expect(await listedIds(), ['us', 'plain']);
      expect(await repo.countRecords(itemType: 'all', keyword: '%'), 1);
    });

    test('deleteRecordsOlderThanDays 按最后浏览时间清理', () async {
      insertHistory('old', updatedAt: '2020-01-01 00:00:00');
      insertHistory(
        'recent',
        updatedAt: HistoryRepository.sqlTime(DateTime.now()),
      );

      expect(await repo.deleteRecordsOlderThanDays(7), 1);
      expect(await listedIds(), ['recent']);
      expect(await repo.deleteRecordsOlderThanDays(0), 0);
    });
  });

  group('恢复', () {
    test('原样放回：id、两个时间戳、观看进度都不变', () async {
      insertHistory(
        'v1',
        createdAt: '2020-01-01 00:00:00',
        updatedAt: '2020-06-01 12:00:00',
      );
      insertProgress('v1', 30000, 100000);

      final record = (await repo.listRecords(itemType: 'video')).single;
      await repo.deleteRecords([record.id]);
      expect(
        db.select('SELECT COUNT(*) AS c FROM history_records').first['c'],
        0,
      );
      expect(
        db.select(
          'SELECT COUNT(*) AS c FROM video_playback_history',
        ).first['c'],
        0,
      );

      await repo.restoreRecords([record]);

      final row = db.select(
        "SELECT * FROM history_records WHERE item_id = 'v1'",
      ).single;
      expect(row['id'], record.id);
      expect(row['created_at'], '2020-01-01 00:00:00');
      // INSERT 不触发 AFTER UPDATE 触发器，最后浏览时间没有被刷成 now。
      expect(row['updated_at'], '2020-06-01 12:00:00');

      final progress = db.select(
        "SELECT * FROM video_playback_history WHERE video_id = 'v1'",
      ).single;
      expect(progress['played_duration'], 30000);
      expect(progress['total_duration'], 100000);
    });

    test('撤销前又看了一遍：以新的为准，不重复', () async {
      insertHistory('v1', updatedAt: '2020-01-01 00:00:00');
      final record = (await repo.listRecords(itemType: 'video')).single;
      await repo.deleteRecords([record.id]);

      // 用户又看了一遍：新行、新时间。
      db.execute(
        '''
        INSERT INTO history_records (item_id, item_type, title, data, created_at, updated_at)
        VALUES ('v1', 'video', '再看一次', '{}', '2020-07-01 00:00:00', '2020-07-01 00:00:00')
        ''',
      );

      await repo.restoreRecords([record]);

      final rows = db.select(
        "SELECT * FROM history_records WHERE item_id = 'v1'",
      );
      expect(rows, hasLength(1));
      expect(rows.single['title'], '再看一次');
      expect(rows.single['updated_at'], '2020-07-01 00:00:00');
    });
  });

  group('「今天」边界', () {
    test('本地零点起的区间不漏今天刚看的、不含前天的', () async {
      final now = DateTime.now();
      insertHistory('today', updatedAt: HistoryRepository.sqlTime(now));
      insertHistory(
        'twoDaysAgo',
        updatedAt: HistoryRepository.sqlTime(
          now.subtract(const Duration(days: 2)),
        ),
      );

      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final todayOnly = await repo.listRecords(
        itemType: 'video',
        startDate: start,
        endDate: end,
      );
      expect(todayOnly.map((r) => r.itemId), ['today']);
      expect(await repo.countRecords(itemType: 'video', startDate: start), 1);
    });
  });
}
