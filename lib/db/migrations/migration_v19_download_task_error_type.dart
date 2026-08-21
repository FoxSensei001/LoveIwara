import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v19: 为下载任务增加「失败原因分类」列 error_type。
///
/// 此前失败只有一段自由文本 error（而且往往是异常的 toString），用户看不懂、
/// 程序也用不了：想做「只重试网络类失败」就得去解析字符串，而文案还会随语言变，
/// 永远解析不准。这里把原因归成有限的几类落库，UI 说人话、批量操作可查询。
///
/// 取值见 DownloadErrorType（network / serverRejected / notFound / diskFull /
/// fileInUse / permission / cancelled / unknown）。历史数据为 NULL，视为 unknown。
class MigrationV19DownloadTaskErrorType extends Migration {
  @override
  int get version => 19;

  @override
  String get description => '为 download_tasks 增加 error_type 字段（失败原因分类）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v19：下载任务失败原因分类 error_type');

    // 幂等：仅当列缺失时才添加，避免异常状态下重跑迁移抛 duplicate column。
    final columns = db.select("PRAGMA table_info('download_tasks')");
    final hasErrorType = columns.any((row) => row['name'] == 'error_type');
    if (!hasErrorType) {
      db.execute('ALTER TABLE download_tasks ADD COLUMN error_type TEXT;');
    }

    db.execute('PRAGMA user_version = 19;');
    LogUtils.i('已应用迁移v19：error_type 字段创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v19');
    // SQLite 不支持 DROP COLUMN，error_type 列保留即可
    db.execute('PRAGMA user_version = 18;');
    LogUtils.i('已回滚迁移v19：数据库版本已回退到 v18');
  }
}
