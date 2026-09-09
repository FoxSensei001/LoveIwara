import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v23：本地媒体库（源 / 条目 / 进度）三张表。
///
/// # ⛔ 进度为什么不能复用 `video_playback_history`
///
/// 那张表的 `init()` 里有一句 `DELETE ... WHERE created_at < 7天前`，而且「看完」
/// 是靠删行表达的——"没有这一行"同时代表从没看过 / 已看完 / 被清掉，三义。
/// 本地文件**不会消失**，"两周后回来接着看第 3 集"正是它最该记住的场景，
/// 一周就过期等于这个功能白做。所以另起 [local_media_progress]：**永不清理**，
/// `completed` 用显式列表达。（同 v22 对 `video_vr_override` 的处置，理由一模一样。）
///
/// # ⛔ 条目主键为什么是 (source_id, path_hash) 而不是 hash(path)
///
/// 源 A 完全可能是源 B 的父目录（用户先加了 `Download/`，后来又加了
/// `Download/Anim/`）。只按路径哈希做主键的话，同一个文件会在两个源之间
/// **互相顶掉 `source_id`**，"按来源筛选"随之飘忽不定。
///
/// [id] 是这两者拼出来的单列主键，方便和 [local_media_progress] 直接对上；
/// 拼法只用 `-` 连接（**不能用 `:`**）：它会被
/// `localVideoRouteId()` 包成 `local_<id>` 再进 go_router 的路径段。
///
/// # ⭐ sort_name：自然序必须落在 SQL 里，不能在 Dart 里比
///
/// 列表是 **DB 分页**的（千级条目不整表进内存），所以"按名称排序"只能由
/// `ORDER BY` 完成——而 SQLite 的字符串序是码元序，`ep1, ep10, ep11, ep2…`。
/// 用户拿来接着看整季剧集的场景会第一个坏掉。
///
/// 解法是**入库时预计算一个可直接字典序比较的 key**：数字段零填充到定长、
/// 大小写折叠、全角折半角（见 `NaturalSortKey`）。这样 `ORDER BY sort_name`
/// 就是自然序，分页也稳定。
class MigrationV23LocalMedia extends Migration {
  @override
  int get version => 23;

  @override
  String get description =>
      '新建本地媒体库三表（local_media_sources / local_media_items / local_media_progress）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v23：本地媒体库');

    // ── 源 ────────────────────────────────────────────────────────────────
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_sources(
        id TEXT PRIMARY KEY,
        kind TEXT NOT NULL,
        display_name TEXT NOT NULL,
        path TEXT,
        uri TEXT,
        media_kinds TEXT NOT NULL DEFAULT 'video',
        recursive INTEGER NOT NULL DEFAULT 1,
        auto_rescan INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0,
        scan_state TEXT NOT NULL DEFAULT 'idle',
        scan_cursor TEXT,
        offline INTEGER NOT NULL DEFAULT 0,
        last_scan_at INTEGER,
        item_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');

    // ── 条目 ──────────────────────────────────────────────────────────────
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_items(
        id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        path_hash TEXT NOT NULL,
        path TEXT NOT NULL,
        kind TEXT NOT NULL,
        name TEXT NOT NULL,
        sort_name TEXT NOT NULL,
        ext TEXT,
        size_bytes INTEGER,
        modified_at INTEGER,
        duration_ms INTEGER,
        width INTEGER,
        height INTEGER,
        thumb_path TEXT,
        sidecar_image_path TEXT,
        vr_format_json TEXT,
        folder_path TEXT,
        category_id TEXT,
        download_task_id TEXT,
        added_at INTEGER NOT NULL,
        missing INTEGER NOT NULL DEFAULT 0,
        UNIQUE(source_id, path_hash)
      );
    ''');

    // 列表的三种主排序各一条索引；`missing` 进前缀是因为列表默认滤掉不在的文件。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_sort_name
        ON local_media_items(source_id, missing, sort_name);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_modified
        ON local_media_items(source_id, missing, modified_at DESC);
    ''');
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_folder
        ON local_media_items(source_id, folder_path);
    ''');
    // 「这个路径已经在库里了吗」——增量扫描每条都要问一次。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_local_items_path
        ON local_media_items(path);
    ''');

    // ── 进度（永不清理） ──────────────────────────────────────────────────
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_progress(
        item_id TEXT PRIMARY KEY,
        position_ms INTEGER NOT NULL,
        duration_ms INTEGER,
        completed INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL
      );
    ''');

    LogUtils.i('已应用迁移v23：本地媒体库三表创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v23');
    db.execute('DROP TABLE IF EXISTS local_media_progress;');
    db.execute('DROP TABLE IF EXISTS local_media_items;');
    db.execute('DROP TABLE IF EXISTS local_media_sources;');
    LogUtils.i('已回滚迁移v23：本地媒体库三表已删除');
  }
}
