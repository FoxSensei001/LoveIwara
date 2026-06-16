import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v17: 为下载任务补充数据库级冲突保护。
///
/// 旧库中可能已经存在重复任务，直接加 UNIQUE INDEX 会导致迁移失败。
/// 这里用触发器只拦截新写入/更新的重复媒体任务与重复保存路径。
class MigrationV17DownloadTaskConflictTriggers extends Migration {
  @override
  int get version => 17;

  @override
  String get description => '为 download_tasks 增加重复媒体和保存路径保护触发器';

  static void createTriggers(CommonDatabase db) {
    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_video_media_unique_insert
      BEFORE INSERT ON download_tasks
      WHEN NEW.media_type = 'video'
        AND NEW.media_id IS NOT NULL
        AND NEW.quality IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_media')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE media_type = 'video'
            AND media_id = NEW.media_id
            AND quality = NEW.quality
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_video_media_unique_update
      BEFORE UPDATE OF media_type, media_id, quality ON download_tasks
      WHEN NEW.media_type = 'video'
        AND NEW.media_id IS NOT NULL
        AND NEW.quality IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_media')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE media_type = 'video'
            AND media_id = NEW.media_id
            AND quality = NEW.quality
            AND id <> NEW.id
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_gallery_media_unique_insert
      BEFORE INSERT ON download_tasks
      WHEN NEW.media_type = 'gallery'
        AND NEW.media_id IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_media')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE media_type = 'gallery'
            AND media_id = NEW.media_id
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_gallery_media_unique_update
      BEFORE UPDATE OF media_type, media_id ON download_tasks
      WHEN NEW.media_type = 'gallery'
        AND NEW.media_id IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_media')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE media_type = 'gallery'
            AND media_id = NEW.media_id
            AND id <> NEW.id
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_save_path_unique_insert
      BEFORE INSERT ON download_tasks
      WHEN NEW.save_path IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_save_path')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE save_path = NEW.save_path
        );
      END;
    ''');

    db.execute('''
      CREATE TRIGGER IF NOT EXISTS trg_download_tasks_save_path_unique_update
      BEFORE UPDATE OF save_path ON download_tasks
      WHEN NEW.save_path IS NOT NULL
      BEGIN
        SELECT RAISE(ABORT, 'duplicate_download_task_save_path')
        WHERE EXISTS (
          SELECT 1 FROM download_tasks
          WHERE save_path = NEW.save_path
            AND id <> NEW.id
        );
      END;
    ''');
  }

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v17：为 download_tasks 增加冲突保护触发器');

    createTriggers(db);

    db.execute('PRAGMA user_version = 17;');
    LogUtils.i('已应用迁移v17：download_tasks 冲突保护触发器创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v17：移除 download_tasks 冲突保护触发器');
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_video_media_unique_insert;',
    );
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_video_media_unique_update;',
    );
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_gallery_media_unique_insert;',
    );
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_gallery_media_unique_update;',
    );
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_save_path_unique_insert;',
    );
    db.execute(
      'DROP TRIGGER IF EXISTS trg_download_tasks_save_path_unique_update;',
    );
    db.execute('PRAGMA user_version = 16;');
    LogUtils.i('已回滚迁移v17：数据库版本已回退到 v16');
  }
}
