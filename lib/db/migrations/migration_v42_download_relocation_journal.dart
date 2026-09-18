import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v42：「移动已下载文件」的过程账本 `download_relocation_journal`。
///
/// 搬一个文件分三步：动磁盘（rename 或 复制→校验→删源）→ 改库 → 销账。
/// 任何一步之间都可能被杀进程，而「文件在新位置、库还指着旧位置」和反过来
/// 那种，在用户眼里都是「文件没了」。账本每行记一次**尚未收尾**的搬运，
/// 下次启动由 `DownloadRelocationService.recoverJournal` 按磁盘现状收尾：
/// 能认定搬完了就补改库，没搬完就清掉半截临时文件，一行都不留。
///
/// 一个任务同一时刻至多一次搬运，所以 `task_id` 当主键。
class MigrationV42DownloadRelocationJournal extends Migration {
  @override
  int get version => 42;

  @override
  String get description => '下载文件移动过程账本 download_relocation_journal';

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS download_relocation_journal(
        task_id TEXT PRIMARY KEY,
        src_path TEXT NOT NULL,
        dest_path TEXT NOT NULL,
        temp_path TEXT,
        created_at INTEGER NOT NULL
      );
    ''');
    LogUtils.i('已应用迁移v42：下载文件移动账本就位', 'MigrationV42');
  }
}
