import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v16: 为 download_tasks 的高频列表查询补充索引。
/// 列表/历史/搜索几乎都是 `WHERE status IN (...) ORDER BY created_at DESC`，
/// 但 status / created_at 此前均无索引，任务量大时分页与统计会变慢。
class MigrationV16DownloadTaskStatusIndex extends Migration {
  @override
  int get version => 16;

  @override
  String get description => '为 download_tasks 增加 (status, created_at) 复合索引';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v16：为 download_tasks 增加 status/created_at 索引');

    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_download_tasks_status_created '
      'ON download_tasks(status, created_at);',
    );

    db.execute('PRAGMA user_version = 16;');
    LogUtils.i('已应用迁移v16：download_tasks 状态索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v16：移除 download_tasks 状态索引');
    db.execute('DROP INDEX IF EXISTS idx_download_tasks_status_created;');
    db.execute('PRAGMA user_version = 15;');
    LogUtils.i('已回滚迁移v16：数据库版本已回退到 v15');
  }
}
