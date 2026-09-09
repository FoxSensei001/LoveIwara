import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v29：把最近播放时间复制到本地条目表，支持索引排序。
class MigrationV29LocalMediaLastPlayed extends Migration {
  @override
  int get version => 29;

  @override
  String get description => '本地库最近播放排序索引';

  @override
  void up(CommonDatabase db) {
    db.execute(
      'ALTER TABLE local_media_items ADD COLUMN last_played_at INTEGER',
    );
    db.execute('''
      UPDATE local_media_items
      SET last_played_at = (
        SELECT updated_at FROM local_media_progress
        WHERE local_media_progress.item_id = local_media_items.id
      )
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_played
        ON local_media_items(
          kind, source_id, missing, last_played_at DESC, sort_name, name, id
        );
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_page_category_played
        ON local_media_items(
          kind, source_id, category_id, missing,
          last_played_at DESC, sort_name, name, id
        );
    ''');
    LogUtils.i('已应用迁移v29：本地库最近播放排序索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_played');
    db.execute('DROP INDEX IF EXISTS idx_local_items_page_category_played');
  }
}
