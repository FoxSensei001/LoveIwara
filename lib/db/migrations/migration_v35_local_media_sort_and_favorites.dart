import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v35：为本地媒体聚合视图与两段式排序补齐索引，并增加精选与帧率列。
///
/// # 为什么兜底列必须带 `id`
///
/// 本地媒体列表是 DB 分页的（依靠 LIMIT / OFFSET）。如果排序字段的值存在重复，
/// SQLite 对相同值行的相对次序是不受控的，翻页时就会出现「上一页刚看过的条目在
/// 下一页又出现」或「某些条目在两页缝隙间被漏掉」的诡异 Bug。
/// 必须用全表唯一的 `id` 列做最终兜底，使 ORDER BY 形成严格的全序（Strict Total Order）。
///
/// # 为什么索引列不带方向（无 ASC/DESC 关键字）
///
/// SQLite 具备双向扫描（Bidirectional Scan）索引的能力：一个默认全 ASC 的复合索引，
/// 既能以正序支持全 ASC 的 ORDER BY，也能以反向扫描（Backward Scan）完整支持全 DESC 的 ORDER BY。
/// **前提是 ORDER BY 里涉及的每一列方向必须严格一致**（全升序或全降序）。
/// 如果在建索引时写死某列 DESC，或者在 ORDER BY 里混用 DESC 与 ASC，SQLite 就无法
/// 通过单向/双向线性遍历索引满足排序，只能静默回退到整表扫 + 内存/磁盘临时排序
/// （`USE TEMP B-TREE FOR ORDER BY`）。sqlite3 在 Flutter 主线程上同步运行，
/// 这类静默退化会直接造成滑动掉帧卡顿。
class MigrationV35LocalMediaSortAndFavorites extends Migration {
  @override
  int get version => 35;

  @override
  String get description => '本地媒体聚合视图索引、精选时间戳与帧率支持';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_items'],
    ).isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_items 尚不存在，跳过 v35', 'MigrationV35');
      return;
    }

    final columns = db
        .select('PRAGMA table_info(local_media_items)')
        .map((row) => row['name'] as String)
        .toSet();

    // 1.1 精选时间戳：使用时间戳（毫秒）而非布尔值，精选列表默认按「标记时间」倒序排列。
    if (!columns.contains('favorited_at')) {
      db.execute(
        'ALTER TABLE local_media_items ADD COLUMN favorited_at INTEGER;',
      );
      LogUtils.i('已为 local_media_items 添加 favorited_at', 'MigrationV35');
    } else {
      LogUtils.i('favorited_at 已存在，跳过添加', 'MigrationV35');
    }

    // 1.2 视频帧率：实数，为 NULL 表示尚未探测出来（图片永远是 NULL）。
    if (!columns.contains('fps')) {
      db.execute('ALTER TABLE local_media_items ADD COLUMN fps REAL;');
      LogUtils.i('已为 local_media_items 添加 fps', 'MigrationV35');
    } else {
      LogUtils.i('fps 已存在，跳过添加', 'MigrationV35');
    }

    // 1.3 补齐跨源聚合视图（source_id 为 null）所需的排序覆盖索引。
    // 索引列不设方向，同时服务全 ASC 与全 DESC 查询。
    const indexStatements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_modified '
          'ON local_media_items(kind, missing, modified_at, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_duration '
          'ON local_media_items(kind, missing, duration_ms, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_size '
          'ON local_media_items(kind, missing, size_bytes, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_added '
          'ON local_media_items(kind, missing, added_at, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_played '
          'ON local_media_items(kind, missing, last_played_at, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_ext '
          'ON local_media_items(kind, missing, ext, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_fps '
          'ON local_media_items(kind, missing, fps, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_pixels '
          'ON local_media_items(kind, missing, (width * height), sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_all_favorited '
          'ON local_media_items(kind, missing, favorited_at, id);',
    ];

    for (final sql in indexStatements) {
      db.execute(sql);
    }
    LogUtils.i('已为 local_media_items 创建聚合视图排序索引', 'MigrationV35');
  }
}
