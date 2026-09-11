import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';
import 'migration_sql.dart';

/// v15: 为 download_tasks 增加 completed_at 字段，记录任务完成时间。
/// 历史已完成任务用 updated_at 近似回填完成时间。
class MigrationV15DownloadTaskCompletedAt extends Migration {
  @override
  int get version => 15;

  @override
  String get description => '为 download_tasks 增加 completed_at 字段并回填历史已完成任务';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v15：为 download_tasks 增加 completed_at 字段');

    // 增加可空字段，兼容旧数据（缺列才加）。
    addColumnIfMissing(db, 'download_tasks', 'completed_at', 'INTEGER');

    // 历史已完成任务没有精确完成时间，用 updated_at 近似回填（最近一次更新通常即完成时刻）
    try {
      db.execute('''
        UPDATE download_tasks
        SET completed_at = updated_at
        WHERE status = 'completed' AND completed_at IS NULL AND updated_at IS NOT NULL;
      ''');
    } catch (e) {
      LogUtils.w(
        '迁移v15：回填 completed_at 失败，error=$e',
        'MigrationV15DownloadTaskCompletedAt',
      );
    }

    LogUtils.i('已应用迁移v15：download_tasks.completed_at 字段创建完成');
  }
}
