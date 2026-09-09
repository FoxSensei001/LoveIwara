import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v27：给带分类筛选的本地视频墙补上排序分页索引。
///
/// v26 的排序索引在 `missing` 前没有 `category_id`，所以分类筛选会让 SQLite
/// 退回临时排序树。分类是卡片墙的常用筛选，单独补一组复合索引，保留 v26
/// 索引服务于不筛分类的查询。
class MigrationV27LocalMediaCategorySort extends Migration {
  @override
  int get version => 27;

  @override
  String get description => '本地视频墙按分类排序分页索引';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v27：本地视频墙分类排序索引');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category_duration
        ON local_media_items(
          kind, source_id, category_id, missing, duration_ms DESC, sort_name, id
        );
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category_size
        ON local_media_items(
          kind, source_id, category_id, missing, size_bytes DESC, sort_name, id
        );
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category_folder
        ON local_media_items(
          kind, source_id, category_id, missing, folder_path, sort_name, name, id
        );
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category_added
        ON local_media_items(
          kind, source_id, category_id, missing, added_at DESC, id
        );
    ''');
    LogUtils.i('已应用迁移v27：本地视频墙分类排序索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v27');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category_duration;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category_size;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category_folder;');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category_added;');
    LogUtils.i('已回滚v27：本地视频墙分类排序索引已删除');
  }
}
