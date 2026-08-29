import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v21：「稍后再看」本地队列。
///
/// # 为什么是独立一张表，而不是本地收藏的一个内置文件夹
///
/// 两者语义不同：本地收藏是**长期保存**（多文件夹、可分类、可打标签），
/// 稍后再看是**临时队列**（有容量上限、会被淘汰、带"看完没看完"）。把
/// `watched_at` / `progress_permil` / `invalid_at` 这些只对队列有意义的列塞进
/// `favorite_items`，会把收藏模型污染成"什么都装"。
///
/// # ⛔ 为什么"已看完"落在本表，而不是去 join video_playback_history
///
/// `video_playback_history` **算不出"已看完"**：它只在「总时长 >8s 且剩余 >7s」
/// 时留行，看完（剩余 ≤7s）会**直接删记录**，而且 `init()` 每次启动还会清掉
/// 7 天前的所有行。于是"表里没有这一行"同时代表三件事——从没打开过 / 已经
/// 看完了 / 看过但超过 7 天被清掉了，三者不可区分。稍后再看必须自己记。
///
/// # 列的用途
///
/// - `watched_at`：NULL = 未看完；有值 = 已看完。只有**应用在前台**时的观看才
///   会写它（后台挂着自动连播划过的不算），否则下面的淘汰会把用户从没真看过
///   的东西静默吃掉。
/// - `progress_permil`：千分比，给卡片画进度条用。与 `watched_at` 是两件事，
///   看到 30% 也有进度条。
/// - `invalid_at`：撞到"私有无权限 / 已删除"时打点。**只标记不自动删**——点一下
///   东西就消失，在没有 undo 的情况下很惊悚。
///
/// # 淘汰（500 条上限）
///
/// 放在**写路径**（插入之后跑一次），不要在读路径算。淘汰序是
/// `watched_at IS NULL ASC, added_at ASC`：先淘汰已看完的、同组内最旧优先。
/// 纯 FIFO 会静默删掉用户攒了很久还没看的那一条，是这个功能最伤的失败模式。
class MigrationV21WatchLater extends Migration {
  @override
  int get version => 21;

  @override
  String get description => '新建 watch_later 表（稍后再看本地队列）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v21：稍后再看（watch_later）');

    db.execute('''
      CREATE TABLE IF NOT EXISTS watch_later(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id TEXT NOT NULL,
        item_type TEXT NOT NULL,
        title TEXT,
        thumbnail_url TEXT,
        author TEXT,
        author_id TEXT,
        author_username TEXT,
        duration_ms INTEGER,
        num_images INTEGER,
        is_external INTEGER NOT NULL DEFAULT 0,
        external_domain TEXT,
        added_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        watched_at INTEGER,
        progress_permil INTEGER NOT NULL DEFAULT 0,
        invalid_at INTEGER,
        UNIQUE(item_id, item_type)
      );
    ''');

    // 覆盖最常见的组合：「按类型筛选 + 按加入时间排序」。两种排序方向共用同一
    // 条索引（SQLite 的索引可反向扫描）。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_watch_later_type_added
      ON watch_later(item_type, added_at);
    ''');

    // 「未看完」筛选与淘汰查询都要按 watched_at 分组，单独给一条。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_watch_later_watched
      ON watch_later(watched_at);
    ''');

    LogUtils.i('已应用迁移v21：watch_later 表与索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v21');
    db.execute('DROP INDEX IF EXISTS idx_watch_later_watched;');
    db.execute('DROP INDEX IF EXISTS idx_watch_later_type_added;');
    db.execute('DROP TABLE IF EXISTS watch_later;');
    LogUtils.i('已回滚迁移v21：watch_later 表已删除');
  }
}
