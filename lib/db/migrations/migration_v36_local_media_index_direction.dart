import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v36：把 v30 那批**混向**分页索引重建成全 ASC，并补两列探测/来源标记。
///
/// # 为什么非改不可：v35 把 ORDER BY 统一成同向，v30 的索引当场全部失配
///
/// v30 建索引时，仓库里的 ORDER BY 是**混向**的，例如：
///
/// ```
/// duration_ms DESC, sort_name ASC, id ASC
/// ```
///
/// 于是索引也照着写死了方向：
///
/// ```
/// ON local_media_items(kind, source_id, missing, duration_ms DESC, sort_name, id)
/// ```
///
/// 两边严丝合缝。而 v35 那一轮把 SQL 生成收口到单一路径
/// （`_orderBy(LocalMediaSort)` 变成 `_orderByClause(sort.order)` 的薄封装），
/// 顺带把**所有**子句改成了全列同向：
///
/// ```
/// duration_ms DESC, sort_name DESC, id DESC
/// ```
///
/// 这是收口带来的、没人注意到的副作用：受影响的不只是新加的聚合排序，而是**每一个
/// 既有的单源查询**。混向索引正扫得到 `duration DESC, sort_name ASC, id ASC`，
/// 反扫得到 `duration ASC, sort_name DESC, id DESC`，**两个都不是**新子句要的那个。
///
/// 后果不是退化成 TEMP B-TREE（v35 那批全 ASC 的聚合索引把排序接住了），而是更隐蔽的
/// 一种：查询改去走聚合索引，`source_id` / `category_id` 从**索引前缀**掉成了逐行回表
/// 过滤。实测 EXPLAIN QUERY PLAN：
///
/// ```
/// per-source duration DESC → USING INDEX idx_local_items_all_duration (kind=? AND missing=?)
///                            ^ source_id 不在索引里，逐行回表对
/// ```
///
/// 用户库里有 3 万个视频、某个手动加的源只有 200 个时，进那个源按大小排、翻到第二页，
/// SQLite 要沿全库 3 万条的 size 序反扫、逐行回表比对 source_id。翻得越深越慢，
/// 而 sqlite3 是在 Flutter 主线程上**同步**跑的。
///
/// # 顺带：那 10 条混向索引现在没有任何查询在用
///
/// 它们仍然在每次 `upsertItems` 时被维护。大库全量扫描白付这份写放大，所以是 DROP
/// 重建而不是新增——不能两套都留着。
///
/// ⛔ 新增索引一律不写方向，理由见 [MigrationV35LocalMediaSortAndFavorites] 的类注释。
class MigrationV36LocalMediaIndexDirection extends Migration {
  @override
  int get version => 36;

  @override
  String get description => '重建本地媒体分页索引为同向，补 fps 探测标记与封面来源标记';

  @override
  void up(CommonDatabase db) {
    _upgradeItems(db);
    _upgradeFolders(db);
  }

  void _upgradeItems(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_items'],
    ).isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_items 尚不存在，跳过 v36 条目部分', 'MigrationV36');
      return;
    }

    final columns = db
        .select('PRAGMA table_info(local_media_items)')
        .map((row) => row['name'] as String)
        .toSet();

    // 1. 帧率探测标记。
    //
    // ⛔ 不能用 `fps IS NULL` 当「还没探测过」的判据：容器里本来就不写帧率的文件
    // 永远探不出值，于是每次冷启动后第一次滚到它都要重付一遍轮询（6 × 120ms）。
    // 内存里那份负缓存挡不住——它随进程清零。
    // 用独立的一列记「探测过了」，语义干净，不必往 fps 里塞哨兵值
    // （本仓库的纪律：不知道 ≠ 知道是空）。同 v33 给目录加 probed_at 的做法。
    if (!columns.contains('fps_probed_at')) {
      db.execute(
        'ALTER TABLE local_media_items ADD COLUMN fps_probed_at INTEGER;',
      );
      LogUtils.i('已为 local_media_items 添加 fps_probed_at', 'MigrationV36');
    } else {
      LogUtils.i('fps_probed_at 已存在，跳过添加', 'MigrationV36');
    }

    // 2. 丢掉 v30 那批混向索引。
    //
    // ⛔ `DROP INDEX IF EXISTS` 对全新安装（v30 之后从未建过这些索引）也是安全的。
    const staleIndexes = <String>[
      'idx_local_items_page_duration',
      'idx_local_items_page_size',
      'idx_local_items_page_folder',
      'idx_local_items_page_added',
      'idx_local_items_page_played',
      'idx_local_items_page_category_duration',
      'idx_local_items_page_category_size',
      'idx_local_items_page_category_folder',
      'idx_local_items_page_category_added',
      'idx_local_items_page_category_played',
    ];
    for (final name in staleIndexes) {
      db.execute('DROP INDEX IF EXISTS $name;');
    }
    LogUtils.i('已丢弃 ${staleIndexes.length} 条混向分页索引', 'MigrationV36');

    // 3. 用不带方向的同一批重建。
    //
    // ⛔ `source_id` 必须排在 `category_id` 前面：卡片墙的分页与分类计数都是按当前
    // 来源算的（数字必须和点进去看到的那张墙同口径），所以每一条真实查询都带着
    // `source_id`。反过来排会让 source_id 退化成逐行回表——这条是 v30 就写下的，
    // 重建时原样保留。
    const rebuiltIndexes = <String>[
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_duration '
          'ON local_media_items(kind, source_id, missing, duration_ms, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_size '
          'ON local_media_items(kind, source_id, missing, size_bytes, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_folder '
          'ON local_media_items(kind, source_id, missing, folder_path, sort_name, name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_added '
          'ON local_media_items(kind, source_id, missing, added_at, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_played '
          'ON local_media_items(kind, source_id, missing, last_played_at, sort_name, name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_duration '
          'ON local_media_items(kind, source_id, category_id, missing, duration_ms, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_size '
          'ON local_media_items(kind, source_id, category_id, missing, size_bytes, sort_name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_folder '
          'ON local_media_items(kind, source_id, category_id, missing, folder_path, sort_name, name, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_added '
          'ON local_media_items(kind, source_id, category_id, missing, added_at, id);',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_played '
          'ON local_media_items(kind, source_id, category_id, missing, last_played_at, sort_name, name, id);',
    ];
    for (final statement in rebuiltIndexes) {
      db.execute(statement);
    }
    LogUtils.i('已重建 ${rebuiltIndexes.length} 条同向分页索引', 'MigrationV36');
  }

  void _upgradeFolders(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_folders'],
    ).isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_folders 尚不存在，跳过 v36 目录部分', 'MigrationV36');
      return;
    }

    final columns = db
        .select('PRAGMA table_info(local_media_folders)')
        .map((row) => row['name'] as String)
        .toSet();

    // 封面「是不是借自子目录」。
    //
    // ⛔ 四层降级里「借用子目录封面」是最低一档，却往往最先落地（子目录的直属图片
    // 扫描器一眼看见，本目录视频的缩略图要等卡片滚进视野）。两个回填都只写「当前
    // 没封面」的行、先到先得的话，父目录会永远挂着子目录那张图，第 3 档（自己视频
    // 的缩略图）再也顶不上去——和声明的优先级正好相反。打了这个标才能分辨。
    if (!columns.contains('cover_borrowed')) {
      db.execute(
        'ALTER TABLE local_media_folders '
        'ADD COLUMN cover_borrowed INTEGER NOT NULL DEFAULT 0;',
      );
      LogUtils.i('已为 local_media_folders 添加 cover_borrowed', 'MigrationV36');
    } else {
      LogUtils.i('cover_borrowed 已存在，跳过添加', 'MigrationV36');
    }
  }

  @override
  void down(CommonDatabase db) {
    // ⛔ 不回滚。
    // 索引重建是纯性能改动，回滚成混向反而把慢查询装回去；两个新列留着是无害的
    // （旧代码不读它们）。SQLite 早期版本也不支持 DROP COLUMN，同 v31~v35 的做法。
    LogUtils.i('v36 无需回滚', 'MigrationV36');
  }
}
