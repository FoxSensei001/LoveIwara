import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v34：`local_media_folders.cover_pinned`——用户自己指定过这个目录的封面。
///
/// # 为什么要一个单独的标志位，而不是"有 cover_path 就别覆盖"
///
/// 目录封面平时是**扫描器挑的**（这一层里第一张图 / 第一个视频的缩略图），它每次扫
/// 都会重挑一次。用户手动设过之后如果没有任何标记，下一次进这一层就被扫描器换回去，
/// 表现成「设置没生效」——而且用户根本猜不到是被谁改的。
///
/// 反过来，「有 cover_path 就不覆盖」也不行：扫描器挑的那张本来就一直在 cover_path
/// 里，那条规则等于**第一次扫完就再也不更新封面**，目录里的内容换了封面还是老的。
///
/// 所以必须把「谁挑的」记下来。
class MigrationV34LocalFolderCoverPinned extends Migration {
  @override
  int get version => 34;

  @override
  String get description => '目录封面锁定标记';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_folders'],
    ).isNotEmpty;
    if (!tableExists) {
      // v31 会按新 DDL（已含 cover_pinned）把表建出来。
      LogUtils.i('local_media_folders 尚不存在，跳过 v34', 'MigrationV34');
      return;
    }

    final hasColumn = db
        .select('PRAGMA table_info(local_media_folders)')
        .any((row) => row['name'] == 'cover_pinned');
    if (hasColumn) {
      LogUtils.i('cover_pinned 已存在，跳过 v34', 'MigrationV34');
      return;
    }

    db.execute(
      'ALTER TABLE local_media_folders '
      'ADD COLUMN cover_pinned INTEGER NOT NULL DEFAULT 0;',
    );
    LogUtils.i('已为 local_media_folders 添加 cover_pinned', 'MigrationV34');
  }
}
