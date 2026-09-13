import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v39：补齐本地媒体几条「查询形状对不上索引」的洞，外加两列标记。
///
/// # 1. `download_task_id` 没有索引（分类删除确认框卡 29 秒）
///
/// `categoryMemberCount` 的第二半是「这个分类下、还没在本地库露过面的下载任务」：
/// 对 `download_tasks` 每一行做一次 `NOT EXISTS (… WHERE i.download_task_id = t.id)`。
/// 没有索引时每一次都是全表扫 `local_media_items`——3 万任务 × 6 万条目，实测 29s，
/// 而 sqlite3 是在主 isolate 上同步跑的。建上之后 3ms。
/// `getItemByDownloadTaskId` 与下载任务那边镜像分类的 UPDATE 同受益。
///
/// 写成**部分索引**：扫描来的条目恒为 NULL（占全库大头），不进树，写放大只落在
/// 下载来的那些行上。
///
/// # 2. v36 重建 `played` 两条时照抄了 v30 的列序，中间多了一个 `name`
///
/// v35 起 ORDER BY 是 `last_played_at, sort_name, id`（见仓库 `_orderByClause`），
/// 索引却是 `last_played_at, sort_name, name, id`。`name` 卡在 `sort_name` 和 `id`
/// 之间，索引序到 `sort_name` 为止还对得上、到 `id` 就断了——SQLite 只能退回
/// TEMP B-TREE 重排。DROP 重建成与子句逐列一致的形状。
///
/// # 3. 单源分页缺 modified / favorited / 分辨率 / 扩展名 / 帧率五档
///
/// v35 只给**跨源聚合**（source_id 为 NULL）建了 `idx_local_items_all_*`。而「下载
/// 完成视频」那一栏带着 `source_id = 'downloads'`，默认排序正是 modified，排序菜单里
/// 也有分辨率 / 文件类型 / 帧率。这些查询要么走 `all_*` 把 `source_id` 掉成逐行回表
/// （v36 类注释里描述的那种隐蔽退化），要么 TEMP B-TREE。按同一个前缀
/// `(kind, source_id, missing, …)` 补上。
///
/// ⛔ 方向一律不写，理由见 [MigrationV36LocalMediaIndexDirection]：同一条索引正扫
/// 服务全 ASC、反扫服务全 DESC。
///
/// EXPLAIN QUERY PLAN 实证（sqlite3 3.44.4，6 万条目的合成库，无 sqlite_stat1）：
/// ```
/// played DESC        → SEARCH USING INDEX idx_local_items_page_played (kind=? AND source_id=? AND missing=?)
/// 分类 + played DESC → SEARCH USING INDEX idx_local_items_page_category_played (kind=? AND source_id=? AND category_id=? AND missing=?)
/// modified DESC      → SEARCH USING INDEX idx_local_items_page_modified (kind=? AND source_id=? AND missing=?)
/// favorited DESC     → SEARCH USING INDEX idx_local_items_page_favorited (kind=? AND source_id=? AND missing=? AND favorited_at>?)
/// (width*height) DESC→ SEARCH USING INDEX idx_local_items_page_pixels (kind=? AND source_id=? AND missing=?)
/// ext ASC / fps DESC → SEARCH USING INDEX idx_local_items_page_ext / idx_local_items_page_fps (同上)
/// NOT EXISTS 子查询  → SEARCH i USING COVERING INDEX idx_local_items_download_task (download_task_id=?)
/// ```
/// 全部没有 `USE TEMP B-TREE`。
///
/// # 4. 两列标记
///
/// - `thumb_is_custom`：`thumb_path` 是用户手动指定的封面。挑封面的默认口径是
///   「sidecar 优先」，没有这个标的话用户挑的图会被下载器写的 sidecar 盖住。
/// - `meta_probed_at`：时长/宽高「探测过了」，同 v36 的 `fps_probed_at`——探不出
///   元数据的坏文件不能每次冷启动都重新排队。
class MigrationV39LocalMediaPerfIndexes extends Migration {
  @override
  int get version => 39;

  @override
  String get description =>
      '本地媒体：补 download_task_id / 单源分页索引，修 played 列序，加封面与元数据探测标记';

  static const _tag = 'MigrationV39';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_items'],
    ).isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_items 尚不存在，跳过 v39', _tag);
      return;
    }

    final columns = db
        .select('PRAGMA table_info(local_media_items)')
        .map((row) => row['name'] as String)
        .toSet();
    if (!columns.contains('thumb_is_custom')) {
      db.execute(
        'ALTER TABLE local_media_items '
        'ADD COLUMN thumb_is_custom INTEGER NOT NULL DEFAULT 0;',
      );
      LogUtils.i('已为 local_media_items 添加 thumb_is_custom', _tag);
    }
    if (!columns.contains('meta_probed_at')) {
      db.execute(
        'ALTER TABLE local_media_items ADD COLUMN meta_probed_at INTEGER;',
      );
      LogUtils.i('已为 local_media_items 添加 meta_probed_at', _tag);
    }

    // 列序错位的两条：先 DROP 再建（`IF NOT EXISTS` 不会替换同名的旧形状）。
    const staleIndexes = <String>[
      'idx_local_items_page_played',
      'idx_local_items_page_category_played',
    ];
    for (final name in staleIndexes) {
      db.execute('DROP INDEX IF EXISTS $name;');
    }

    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_local_items_download_task '
          'ON local_media_items(download_task_id) '
          'WHERE download_task_id IS NOT NULL;',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_played '
          'ON local_media_items(kind, source_id, missing, last_played_at, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_played '
          'ON local_media_items(kind, source_id, category_id, missing, last_played_at, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_modified '
          'ON local_media_items(kind, source_id, missing, modified_at, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_favorited '
          'ON local_media_items(kind, source_id, missing, favorited_at, id);',
      // ⛔ 表达式必须与 `_orderByClause` 里的 `(width * height)` 逐字一致，
      // SQLite 按表达式树匹配，写成 `height * width` 就用不上。
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_pixels '
          'ON local_media_items(kind, source_id, missing, (width * height), sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_ext '
          'ON local_media_items(kind, source_id, missing, ext, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_fps '
          'ON local_media_items(kind, source_id, missing, fps, sort_name, id);',
    ];
    for (final statement in statements) {
      db.execute(statement);
    }
    LogUtils.i('已应用迁移v39：本地媒体索引补齐 + 两列标记', _tag);
  }
}
