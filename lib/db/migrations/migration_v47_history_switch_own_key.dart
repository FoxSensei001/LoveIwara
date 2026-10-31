import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v47：「自动记录浏览历史」改读它自己的配置项 `auto_record_history`。
///
/// 此前启动时 `CommonConstants.enableHistory` 读的是
/// `record_and_restore_video_progress`（记录并恢复播放进度），首启引导里的
/// 「自动记录历史」也写的是它；设置页那枚开关写 `auto_record_history`，只在当次
/// 运行里生效。于是：
/// - 在播放器设置里关了「记录并恢复播放进度」的人，重启后浏览历史一条都不再记，
///   设置页的历史开关却还亮着；
/// - 在设置页关了历史的人，重启后又开始记。
///
/// 换键之后要让「实际行为」不意外地变：迁移前重启后实际生效的是进度开关，
/// 所以 `auto_record_history := auto_record_history AND record_and_restore_video_progress`。
/// - 进度关着的人：历史保持不记（隐私上不能突然开始记），但设置页如实显示「关」，
///   想要历史的人在那里打开就能持久生效；
/// - 进度开着、历史开关被显式关掉的人：照他的意思关掉（以前重启就失效）。
///
/// 幂等：再跑一遍结果不变。新装用户此时 app_config 还是空的，什么都不发生。
class MigrationV47HistorySwitchOwnKey extends Migration {
  @override
  int get version => 47;

  @override
  String get description => '浏览历史开关改用独立配置项';

  @override
  void up(CommonDatabase db) {
    reconcile(db);
    LogUtils.i('已应用迁移v47：浏览历史开关改用独立配置项', 'MigrationV47');
  }

  /// 导入 v47 之前导出的配置备份时也要补跑：导入是整表原样写回 app_config，
  /// 不动 user_version，迁移不会再跑，旧的那对值会把这里的修正冲掉。
  static void reconcile(CommonDatabase db) {
    db.execute('''
      INSERT OR REPLACE INTO app_config (key, value)
      SELECT 'auto_record_history', 'false'
      WHERE EXISTS (
        SELECT 1 FROM app_config
        WHERE key = 'record_and_restore_video_progress'
          AND lower(value) <> 'true'
      )
    ''');
  }
}
