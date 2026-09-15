import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v41：本机文件的「隐藏目录」表（`local_media_hidden_folders`）。
///
/// 被隐藏的目录**不在目录树里出现，扫描也不往里走**（见
/// `LocalMediaScanService` 的 `skipPaths`）。用户可以在 ⋮ 菜单里打开「显示隐藏的
/// 文件夹」把它们临时请回来，再逐个取消隐藏。
///
/// # 为什么是一张表，不是 `local_media_folders` 上的一列
///
/// 1. **它必须比目录行活得久**。目录行会被扫描器收敛成 missing、会被
///    `deleteFolderSubtree` 删掉、重扫时又重新 upsert；而「用户说过不想看见这个
///    目录」是一句**用户意图**，不该跟着目录行的生命周期一起没。列在
///    `_folderPreservedColumns` 上打补丁能救一半，救不了"行整个不在"的那一半。
/// 2. 懒扫描下一个目录可能**还没有行**（走到深度尽头只发了占位行，或者连占位行都
///    没有），而用户完全可能在这时就想隐藏它。
///
/// 形状照抄 `local_media_pinned_folders`（v31）——那张表解决的是同一类问题
/// （"用户对某个目录的一句话"），两者也必须在 `deleteSource` 里一起级联。
///
/// ⛔ 没有 `sort_order`：隐藏目录没有顺序可言，它们平时根本不出现。
class MigrationV41LocalMediaHiddenFolders extends Migration {
  @override
  int get version => 41;

  @override
  String get description => '本机文件：隐藏目录表 local_media_hidden_folders';

  @override
  void up(CommonDatabase db) {
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_hidden_folders(
        id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        rel_path TEXT NOT NULL,
        display_name TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        UNIQUE(source_id, rel_path)
      );
    ''');
    // ⛔ 不另建索引：`UNIQUE(source_id, rel_path)` 本身就是一条
    // `(source_id, rel_path)` 的索引，而这张表的查法只有两种——按源取整份、
    // 按（源 + 相对路径）点查，两种它都覆盖得到。再建一条是纯写入开销。

    LogUtils.i('已应用迁移v41：本机文件隐藏目录表就位', 'MigrationV41');
  }
}
