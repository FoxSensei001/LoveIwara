import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v33：`local_media_folders.probed_at`——「这个目录到底看过没有」。
///
/// # 为什么必须有这一列
///
/// 目录浏览改成**懒扫描**（进哪个目录才扫哪一层）之后，一个目录的
/// `video_count / image_count / child_folder_count` 全是 0 有两种含义：
///
/// - **看过了，里面确实什么都没有** —— 该藏（你的 `Download` 底下两千多个哈希
///   缓存空目录就是这一种，不藏的话第一屏全是灰块）；
/// - **压根还没走到过** —— 不知道，必须显示。
///
/// 全量扫描时这两种不用分：扫完一遍，0 就是真的 0。懒扫描下分不开就会出人命——
/// 「藏空目录」那条残余过滤会把所有还没走到的子目录一并藏掉，用户点进一个大目录
/// 看到的是一片空白，而里面明明有东西。
///
/// 所以 `childFolders` 的过滤口径变成：
/// `(video_count > 0 OR image_count > 0 OR child_folder_count > 0 OR probed_at IS NULL)`。
///
/// # ⛔ 老行一律留 NULL
///
/// 不要给既有的行填一个时间戳"当作看过了"。那些行是全量扫描留下的，计数是准的，
/// 但把它们标成"探过"没有任何好处，反倒会让**真的空**和**曾经扫过现在不确定**
/// 混在一起。NULL 的语义是"不知道，先显示着"，对老数据恰好是最安全的默认。
class MigrationV33LocalFolderProbedAt extends Migration {
  @override
  int get version => 33;

  @override
  String get description => '目录探测时间戳（懒扫描判空用）';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_folders'],
    ).isNotEmpty;
    if (!tableExists) {
      // v31 会按新 DDL（已含 probed_at）把表建出来，这里没有要补的。
      LogUtils.i('local_media_folders 尚不存在，跳过 v33', 'MigrationV33');
      return;
    }

    final hasColumn = db
        .select('PRAGMA table_info(local_media_folders)')
        .any((row) => row['name'] == 'probed_at');
    if (hasColumn) {
      LogUtils.i('probed_at 已存在，跳过 v33', 'MigrationV33');
      return;
    }

    db.execute('ALTER TABLE local_media_folders ADD COLUMN probed_at INTEGER;');
    LogUtils.i('已为 local_media_folders 添加 probed_at', 'MigrationV33');
  }

  /// ⛔ 回滚**不删列**。
  ///
}
