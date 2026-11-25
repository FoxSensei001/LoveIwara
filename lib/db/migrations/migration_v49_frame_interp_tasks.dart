import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v49：离线补帧任务 `frame_interp_tasks`。
///
/// 一条记录 = 「把某个本地视频补成两倍帧率」这件事，从排队到产出成品的全程。
/// 它和 `download_tasks` / `local_media_items` 都**只按路径松耦合**，不建外键：
///
/// - 片源可能来自下载列表，也可能来自本机文件，还可能两边都登记着同一个文件；
///   认路径才能让两处的卡片对上同一条任务。
/// - 成品是一个新文件，本机媒体库扫到它时会给它建自己的 `local_media_items`
///   行。卡片上的「补帧」标识靠 `output_path` 反查这张表，而不是往媒体库表里
///   加一列——那张表由扫描器整行重写，塞进去的标记迟早被冲掉。
///
/// `source_key` / `output_key` 是规范化后的路径（Windows 上不分大小写），专门
/// 用来比对；原样路径另存，用来打开文件和展示。
class MigrationV49FrameInterpTasks extends Migration {
  @override
  int get version => 49;

  @override
  String get description => '离线补帧任务 frame_interp_tasks';

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS frame_interp_tasks(
        id TEXT PRIMARY KEY,
        source_path TEXT NOT NULL,
        source_key TEXT NOT NULL,
        output_path TEXT NOT NULL,
        output_key TEXT NOT NULL,
        title TEXT NOT NULL,
        thumbnail TEXT,
        status TEXT NOT NULL,
        progress REAL NOT NULL DEFAULT 0,
        error_code INTEGER NOT NULL DEFAULT 0,
        error TEXT,
        width INTEGER NOT NULL DEFAULT 0,
        height INTEGER NOT NULL DEFAULT 0,
        source_fps REAL NOT NULL DEFAULT 0,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        source_size INTEGER NOT NULL DEFAULT 0,
        output_size INTEGER NOT NULL DEFAULT 0,
        encoder TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        completed_at INTEGER
      );
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_frame_interp_tasks_source_key
      ON frame_interp_tasks(source_key);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_frame_interp_tasks_output_key
      ON frame_interp_tasks(output_key);
    ''');
    LogUtils.i('已应用迁移v49：补帧任务表就位', 'MigrationV49');
  }
}
