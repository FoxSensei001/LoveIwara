import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v26：本地视频墙新增排序档的分页索引。
///
/// 这些索引只覆盖来源切换后的卡片墙查询（查询总是带 `source_id`）。不为
/// 「最近播放」伪造冗余的最后播放列：它要从永不清理的进度表读真实时间，
/// 相关子查询会通过进度主键完成点查，排序本身保留 SQLite 的临时树。
class MigrationV26LocalMediaSort extends Migration {
  @override
  int get version => 26;

  @override
  String get description => '本地视频墙排序分页索引';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v26：本地视频墙排序索引');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_duration
        ON local_media_items(kind, source_id, missing, duration_ms DESC, sort_name, id);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_size
        ON local_media_items(kind, source_id, missing, size_bytes DESC, sort_name, id);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_folder
        ON local_media_items(kind, source_id, missing, folder_path, sort_name, name, id);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_added
        ON local_media_items(kind, source_id, missing, added_at DESC, id);
    ''');
    LogUtils.i('已应用迁移v26：本地视频墙排序索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v26');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_duration;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_size;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_folder;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_added;');
    LogUtils.i('已回滚迁移v26：本地视频墙排序索引已删除');
  }
}
