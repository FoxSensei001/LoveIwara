import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v46：作者首见名缓存 `author_folder_cache`。
///
/// 下载子文件夹归档（issue #126）用 `%authorcache` 变量给每位作者一个稳定的
/// 文件夹名：key 是**作者 ID**（永不漂移），value 是**第一次下载该作者内容时的
/// 显示名**（可读）。作者之后改昵称，新下载仍落进同一个首见名文件夹，归档不裂。
///
/// 回退值不进表：作者数据缺失（或显示名清洗后为空）时渲染为 `unknown`，但那
/// 只是「这一条的兜底」，不是「首见」——写进去会把 unknown 钉死成永久文件夹名。
/// 该表是纯加速缓存，随清数据/换设备丢失可接受：丢了的后果只是「改名作者再下
/// 载时另起新文件夹」，v2.1 整理工具可收敛。
class MigrationV46AuthorFolderCache extends Migration {
  @override
  int get version => 46;

  @override
  String get description => '作者首见名缓存 author_folder_cache';

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS author_folder_cache(
        author_id TEXT PRIMARY KEY,
        folder_name TEXT NOT NULL
      );
    ''');
    LogUtils.i('已应用迁移v46：作者首见名缓存就位', 'MigrationV46');
  }
}
