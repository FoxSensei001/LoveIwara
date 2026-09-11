import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v37：清掉图片上的精选标记——精选是视频独有的。
///
/// # 为什么要动数据，而不是只改界面
///
/// v35 加 `favorited_at` 时没有按 kind 分家，条目菜单对视频和图片出的是同一条
/// 「精选」。于是图片也能被标上——**而标完哪儿都看不见**：聚合 Tab 只有「精选
/// 视频」，图片的排序字段表里也从来没有精选那一档。
///
/// 2026-09-11 把那个入口摘掉之后，已经标过的图片就成了**没有任何界面能取消**的
/// 死状态：星标不画了、菜单里也不再出「取消精选」，那一行的 `favorited_at` 会
/// 永远留在库里。只改界面等于把脏数据锁死在库里，所以这里连数据一起清干净。
///
/// 写入口那边也钉了同一条不变量（`setItemFavorited` 的 SQL 带 `kind = 'video'`），
/// 两头一起，这份脏数据不会再长出来。
class MigrationV37LocalMediaImageFavorites extends Migration {
  @override
  int get version => 37;

  @override
  String get description => '清除图片上的精选标记（精选仅视频）';

  @override
  void up(CommonDatabase db) {
    final tableExists = db
        .select(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          <Object?>['local_media_items'],
        )
        .isNotEmpty;
    if (!tableExists) {
      LogUtils.i('local_media_items 尚不存在，跳过 v37', 'MigrationV37');
      return;
    }

    // 停在 v34 之前的开发机还没有这一列，ALTER 由 v35 负责；这里只清数据。
    final hasFavoritedAt = db
        .select('PRAGMA table_info(local_media_items)')
        .any((row) => row['name'] == 'favorited_at');
    if (!hasFavoritedAt) {
      LogUtils.i('favorited_at 尚不存在，跳过 v37', 'MigrationV37');
      return;
    }

    db.execute(
      "UPDATE local_media_items SET favorited_at = NULL "
      "WHERE kind = 'image' AND favorited_at IS NOT NULL",
    );
    LogUtils.i('已清除 ${db.updatedRows} 张图片的精选标记', 'MigrationV37');
  }

  @override
  void down(CommonDatabase db) {
    // ⛔ 回不去。清掉的是「哪几张图片被标过」，那份信息已经没了；就算留着也没有
    // 任何界面读得到它。同 v31~v36 的做法。
    LogUtils.i('v37 无需回滚', 'MigrationV37');
  }
}
