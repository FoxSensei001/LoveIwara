import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v38：给「按目录取一批条目」的两条查询补上带 ORDER BY 兜底列的索引。
///
/// # 为什么 v30 那条 `idx_local_items_folder` 不够
///
/// `idx_local_items_folder(source_id, folder_path)` 只覆盖 WHERE，不覆盖
/// `ORDER BY sort_name, name, id`。SQLite 于是静默退回 TEMP B-TREE：**每调一次
/// 都要把该目录的全部行排一遍**，加了 LIMIT 也救不回来（LIMIT 是排完之后才
/// 生效的）。这正是 v35/v36 那两轮反复钉的同一条纪律，目录那两条查询漏了。
///
/// 两条真实查询：
/// - `folderCoverCandidates`：不限定 kind（图片和视频都要），所以 kind 不能
///   排进索引中段，用 `idx_local_items_folder_sort`。
/// - `firstVideoNeedingThumbInFolder`：带 `kind = 'video'`，用
///   `idx_local_items_folder_kind_sort`。
///
/// `idx_local_items_folder` 是新索引 `idx_local_items_folder_sort` 的严格前缀，
/// 留着纯属写入时的死重，一并删掉（同 v30 删 `idx_local_items_sort_name` 的做法）。
///
/// EXPLAIN QUERY PLAN 实证（sqlite3 3.44.4，两条查询表现一致）：
/// ```
/// 改前 SEARCH local_media_items USING INDEX idx_local_items_folder (source_id=? AND folder_path=?)
///      USE TEMP B-TREE FOR ORDER BY
/// 改后 SEARCH local_media_items USING INDEX idx_local_items_folder_sort (source_id=? AND folder_path=? AND missing=?)
///      SEARCH local_media_items USING INDEX idx_local_items_folder_kind_sort (source_id=? AND folder_path=? AND kind=? AND missing=?)
/// ```
class MigrationV38LocalMediaFolderScanIndexes extends Migration {
  @override
  int get version => 38;

  @override
  String get description => '本地媒体：按目录取条目的两条查询补齐排序索引';

  static const _tag = 'MigrationV38';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_items'],
    ).isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_items 尚不存在，跳过 v38', _tag);
      return;
    }

    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_local_items_folder_sort '
          'ON local_media_items(source_id, folder_path, missing, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_folder_kind_sort '
          'ON local_media_items(source_id, folder_path, kind, missing, sort_name, name, id)',
      // 被上面第一条完全前缀覆盖，留着只是白付写入成本。
      'DROP INDEX IF EXISTS idx_local_items_folder',
    ];
    for (final statement in statements) {
      db.execute(statement);
    }
    LogUtils.i('已应用迁移v38：目录条目查询索引补齐', _tag);
  }
}
