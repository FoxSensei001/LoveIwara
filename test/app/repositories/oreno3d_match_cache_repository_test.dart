import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/repositories/oreno3d_match_cache_repository.dart';
import 'package:i_iwara/db/migrations/migration_v20_oreno3d_match_cache.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart';

/// oreno3d 匹配缓存仓库的单测。
///
/// 重点不在「能不能存取」，而在三道防堆积闸门：TTL、行数封顶、清理节流。
/// 这张表是本功能唯一会随使用时长增长的东西，上界必须由测试钉死。
void main() {
  late CommonDatabase db;
  late Oreno3dMatchCacheRepository repo;

  /// 固定「现在」，避免依赖真实时钟。
  final now = DateTime.utc(2026, 8, 27, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 迁移内部会调用 LogUtils.i，需先初始化 logger，否则会抛 LateInitializationError。
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV20Oreno3dMatchCache().up(db);
    repo = Oreno3dMatchCacheRepository(database: db);
    Oreno3dMatchCacheRepository.resetSweepThrottle();
  });

  tearDown(() => db.close());

  int rowCount() =>
      db.select('SELECT COUNT(*) AS c FROM oreno3d_match_cache').first['c']
          as int;

  void insertRow(String iwaraId, String? oreno3dId, DateTime updatedAt) {
    db.execute(
      'INSERT INTO oreno3d_match_cache (iwara_id, oreno3d_id, updated_at) VALUES (?, ?, ?)',
      [iwaraId, oreno3dId, updatedAt.millisecondsSinceEpoch],
    );
  }

  group('存取', () {
    test('没查过的视频返回 null', () {
      expect(repo.lookup('wZnIuPmUg9UoIX', now: now), isNull);
    });

    test('正结果存得下、取得回', () {
      repo.remember('wZnIuPmUg9UoIX', '356315', now: now);
      final entry = repo.lookup('wZnIuPmUg9UoIX', now: now);
      expect(entry, isNotNull);
      expect(entry!.oreno3dId, '356315');
      expect(entry.isMissingOnOreno3d, isFalse);
    });

    test('负结果与「没查过」是两回事', () {
      repo.remember('KEHrdmtkdjEfeL', null, now: now);
      final entry = repo.lookup('KEHrdmtkdjEfeL', now: now);
      expect(entry, isNotNull);
      expect(entry!.isMissingOnOreno3d, isTrue);
    });

    test('重复写入是覆盖而不是堆叠', () {
      repo.remember('wZnIuPmUg9UoIX', null, now: now);
      repo.remember('wZnIuPmUg9UoIX', '356315', now: now);
      expect(rowCount(), 1);
      expect(repo.lookup('wZnIuPmUg9UoIX', now: now)!.oreno3dId, '356315');
    });

    test('forget 丢掉对不上的缓存', () {
      repo.remember('wZnIuPmUg9UoIX', '356315', now: now);
      repo.forget('wZnIuPmUg9UoIX');
      expect(repo.lookup('wZnIuPmUg9UoIX', now: now), isNull);
    });

    test('空 ID 既不写也不查', () {
      repo.remember('', '356315', now: now);
      expect(rowCount(), 0);
      expect(repo.lookup('', now: now), isNull);
    });
  });

  group('闸门一：TTL', () {
    test('负结果过期后视同没查过（oreno3d 新入库有索引延迟）', () {
      insertRow(
        'KEHrdmtkdjEfeL',
        null,
        now.subtract(Oreno3dMatchCacheRepository.negativeTtl).subtract(
          const Duration(minutes: 1),
        ),
      );
      expect(repo.lookup('KEHrdmtkdjEfeL', now: now), isNull);
    });

    test('同样年龄下正结果仍然有效（正负 TTL 不是一个量级）', () {
      insertRow(
        'wZnIuPmUg9UoIX',
        '356315',
        now.subtract(Oreno3dMatchCacheRepository.negativeTtl).subtract(
          const Duration(minutes: 1),
        ),
      );
      expect(repo.lookup('wZnIuPmUg9UoIX', now: now)!.oreno3dId, '356315');
    });

    test('正结果超过 TTL 后也会过期（对面条目可能被删或换 ID）', () {
      insertRow(
        'wZnIuPmUg9UoIX',
        '356315',
        now.subtract(Oreno3dMatchCacheRepository.positiveTtl).subtract(
          const Duration(days: 1),
        ),
      );
      expect(repo.lookup('wZnIuPmUg9UoIX', now: now), isNull);
    });

    test('sweep 把过期行真正从磁盘上删掉', () {
      insertRow('expiredNeg', null, now.subtract(const Duration(days: 1)));
      insertRow('expiredPos', '1', now.subtract(const Duration(days: 60)));
      insertRow('freshNeg', null, now.subtract(const Duration(hours: 1)));
      insertRow('freshPos', '2', now.subtract(const Duration(days: 1)));

      final deleted = repo.sweep(now: now);

      expect(deleted, 2);
      expect(rowCount(), 2);
      expect(repo.lookup('freshNeg', now: now), isNotNull);
      expect(repo.lookup('freshPos', now: now), isNotNull);
    });
  });

  group('闸门二：行数封顶', () {
    test('超出上限 + slack 时裁到上限，保留最新的行', () {
      const overflow = Oreno3dMatchCacheRepository.maxRows + 700;
      for (var i = 0; i < overflow; i++) {
        // updated_at 递增：i 越大越新，裁剪后应当留下最大的那批。
        insertRow('id_$i', '$i', now.subtract(Duration(seconds: overflow - i)));
      }
      expect(rowCount(), overflow);

      repo.sweep(now: now);

      expect(rowCount(), Oreno3dMatchCacheRepository.maxRows);
      // 最老的被删，最新的还在。
      expect(repo.lookup('id_0', now: now), isNull);
      expect(repo.lookup('id_${overflow - 1}', now: now), isNotNull);
    });

    test('只超一点点（在 slack 内）不触发裁剪，避免贴着上限反复删', () {
      const slightlyOver = Oreno3dMatchCacheRepository.maxRows + 100;
      for (var i = 0; i < slightlyOver; i++) {
        insertRow('id_$i', '$i', now.subtract(Duration(seconds: i)));
      }

      repo.sweep(now: now);

      expect(rowCount(), slightlyOver);
    });
  });

  group('闸门三：清理节流', () {
    test('一小时内的第二次写入不再扫表', () {
      insertRow('expired', null, now.subtract(const Duration(days: 1)));

      // 第一次写入触发清理，过期行被删。
      repo.remember('a', '1', now: now);
      expect(repo.lookup('expired', now: now), isNull);

      // 再插一条过期行，紧接着写入——节流内，不应再清。
      insertRow('expired2', null, now.subtract(const Duration(days: 1)));
      repo.remember('b', '2', now: now.add(const Duration(minutes: 5)));
      expect(
        db.select(
          'SELECT COUNT(*) AS c FROM oreno3d_match_cache WHERE iwara_id = ?',
          ['expired2'],
        ).first['c'],
        1,
      );

      // 超过节流间隔后恢复清理。
      repo.remember('c', '3', now: now.add(const Duration(hours: 2)));
      expect(
        db.select(
          'SELECT COUNT(*) AS c FROM oreno3d_match_cache WHERE iwara_id = ?',
          ['expired2'],
        ).first['c'],
        0,
      );
    });
  });

  group('迁移', () {
    test('up 可重复执行，down 清干净', () {
      MigrationV20Oreno3dMatchCache().up(db); // 幂等
      repo.remember('a', '1', now: now);
      expect(rowCount(), 1);

      MigrationV20Oreno3dMatchCache().down(db);
      expect(
        db
            .select(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='oreno3d_match_cache'",
            )
            .isEmpty,
        isTrue,
      );
    });
  });
}
