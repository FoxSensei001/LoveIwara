import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v48：桌面端「每次询问保存位置」改用自己的配置项 `download_ask_every_time`
/// （默认关），出厂默认从「每次询问」改成固定目录（下载/LoveIwara）。
///
/// 此前桌面上「没开自定义路径」本身就等于每次询问，而那是出厂默认——每个桌面
/// 用户每次下载都弹系统「另存为」。Flutter 3.47 的 Windows 上那个对话框跑在
/// Dart 所在的线程上，一卡整个应用就「未响应」（2026-10-31 群友报障）。
///
/// 老用户一律切到固定目录（用户 2026-10-31 定）：已发布的版本（≤0.6.1）里
/// 根本没有「每次询问」这个选项，路径输入框与「启用自定义路径」开关各写各的，
/// 「存着路径但开关关着」只说明填过路径、没开开关，不能当成主动选了询问。
/// 所以询问开关一条都不写，默认值 false 即是新行为。
///
/// 这里只做一件事：给切过来的老安装（没开自定义路径）写一次性标记
/// `download_outside_quiet_pending`。他们以前每个文件都是在对话框里自己挑的
/// 位置，`DownloadPathService` 见到标记就对默认目录记一句「不搬」，免得下载
/// 列表冒出「旧目录里还有 N 项」；处理完即清掉标记。新装用户此时 app_config
/// 还是空的，什么都不写。
///
/// 幂等：条件不变时重跑结果相同。
class MigrationV48DownloadAskOwnKey extends Migration {
  @override
  int get version => 48;

  @override
  String get description => '下载「每次询问」改用独立配置项，桌面默认改固定目录';

  @override
  void up(CommonDatabase db) {
    reconcile(db);
    LogUtils.i('已应用迁移v48：桌面下载默认改固定目录', 'MigrationV48');
  }

  /// 导入 v48 之前导出的配置备份时也要补跑：导入是整表原样写回 app_config，
  /// 不动 user_version，迁移不会再跑。
  static void reconcile(CommonDatabase db) {
    db.execute('''
      INSERT OR REPLACE INTO app_config (key, value)
      SELECT 'download_outside_quiet_pending', 'true'
      WHERE EXISTS (
        SELECT 1 FROM app_config
        WHERE key = 'enable_custom_download_path'
          AND lower(value) <> 'true'
      )
    ''');
  }
}
