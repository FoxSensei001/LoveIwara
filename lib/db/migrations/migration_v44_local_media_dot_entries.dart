import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v44：本机文件 / NAS 源可以按源决定要不要扫 `.` 开头的子文件夹。
///
/// `include_dot_entries`：0 = 照旧跳过（默认，共用设备上 `.private` 这类目录
/// 不该因为别的源打开了开关而曝光，所以是**每个源**一份，不是全局设置）。
///
/// ⛔ 只管源**里面**的子目录：扫描根自己是 `.` 开头的目录时一向照扫，与这一列无关。
class MigrationV44LocalMediaDotEntries extends Migration {
  @override
  int get version => 44;

  @override
  String get description => '本机文件：每源是否扫描 . 开头的子文件夹';

  @override
  void up(CommonDatabase db) {
    final existing = db
        .select('PRAGMA table_info(local_media_sources)')
        .map((row) => row['name'] as String)
        .toSet();
    if (!existing.contains('include_dot_entries')) {
      db.execute(
        'ALTER TABLE local_media_sources '
        'ADD COLUMN include_dot_entries INTEGER NOT NULL DEFAULT 0',
      );
    }
    LogUtils.i('已应用迁移v44：include_dot_entries 就位', 'MigrationV44');
  }
}
