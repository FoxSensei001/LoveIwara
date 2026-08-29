import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/services/vr_format_override_service.dart';
import 'package:i_iwara/db/migrations/migration_v22_vr_format_override.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/sqlite3.dart';

/// VR 片源格式的「用户手动覆盖」持久层。直接跑真 sqlite（内存库）：要验的就是
/// 写入/读回/覆盖/删除这套 SQL 本身，以及**这张表永不被清理**这条硬约束。
void main() {
  late Database db;
  late VrFormatOverrideService service;

  const vr180Sbs = VrSourceFormat(
    projection: VrProjection.equirect180,
    stereoLayout: VrStereoLayout.sideBySide,
  );
  const vr360Mono = VrSourceFormat(
    projection: VrProjection.equirect360,
    stereoLayout: VrStereoLayout.mono,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // 迁移与 service 内部都会写日志，未初始化 logger 会抛 LateInitializationError
    await LogUtils.init(enablePersistence: false);
  });

  setUp(() {
    db = sqlite3.openInMemory();
    MigrationV22VrFormatOverride().up(db);
    service = VrFormatOverrideService(database: db);
  });

  tearDown(() => db.close());

  test('写入后能原样读回（投影 + 左右眼编排都要对）', () async {
    await service.put('v1', vr180Sbs);

    final got = await service.get('v1');
    expect(got, vr180Sbs);
    expect(got!.projection, VrProjection.equirect180);
    expect(got.stereoLayout, VrStereoLayout.sideBySide);
  });

  test('同一个 videoId 再写一次直接顶掉旧值，不产生第二条', () async {
    await service.put('v1', vr180Sbs);
    await service.put('v1', vr360Mono);

    expect(await service.get('v1'), vr360Mono);

    final count = db
        .select('SELECT COUNT(*) AS c FROM video_vr_override WHERE video_id = ?', [
          'v1',
        ])
        .first['c'];
    expect(count, 1, reason: 'video_id 是主键，覆盖只该留一份');
  });

  test('删除后读回为 null；删不存在的行是无害 no-op', () async {
    await service.put('v1', vr180Sbs);
    await service.remove('v1');
    expect(await service.get('v1'), isNull);

    // 删一个从没写过的 id 不该抛错
    await service.remove('never-existed');
    expect(await service.get('never-existed'), isNull);
  });

  test('读一个没有覆盖的视频返回 null', () async {
    expect(await service.get('unknown'), isNull);
  });

  test('多个视频各存各的，互不串味', () async {
    await service.put('v1', vr180Sbs);
    await service.put('v2', vr360Mono);

    expect(await service.get('v1'), vr180Sbs);
    expect(await service.get('v2'), vr360Mono);
  });

  group('⛔ 永不清理：覆盖是永久纠错，不许被任何按时间的淘汰抹掉', () {
    test('把 updated_at 设成一年前，覆盖依旧读得回来', () async {
      await service.put('ancient', vr180Sbs);

      // 直接把时间戳改到一年前——若哪天有人手滑给这张表加了「清理 N 天前」的逻辑，
      // 这条会立刻变红。
      final oneYearAgo =
          DateTime.now()
              .subtract(const Duration(days: 365))
              .millisecondsSinceEpoch ~/
          1000;
      db.execute('UPDATE video_vr_override SET updated_at = ? WHERE video_id = ?', [
        oneYearAgo,
        'ancient',
      ]);

      expect(
        await service.get('ancient'),
        vr180Sbs,
        reason: '手动覆盖必须永久有效，绝不能像 video_playback_history 那样被 7 天清理吃掉',
      );
    });

    test('重建 service（模拟 App 重启）不会触发任何清空', () async {
      await service.put('ancient', vr360Mono);
      db.execute(
        'UPDATE video_vr_override SET updated_at = 0 WHERE video_id = ?',
        ['ancient'],
      );

      // PlaybackHistoryService 是在构造后 init() 里做 7 天清理的；这里刻意再造一个
      // 实例，验证 VrFormatOverrideService 连 init 都没有，构造不会碰任何数据。
      final restarted = VrFormatOverrideService(database: db);
      expect(
        await restarted.get('ancient'),
        vr360Mono,
        reason: '本服务没有任何清理入口，重启也不该丢覆盖',
      );

      // 表里仍然只有这一行，没被任何东西删掉。
      final count = db
          .select('SELECT COUNT(*) AS c FROM video_vr_override')
          .first['c'];
      expect(count, 1);
    });
  });
}
