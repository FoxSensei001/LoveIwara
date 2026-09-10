import 'dart:convert';

import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v30：本地媒体库的**全量 schema**（源 / 条目 / 进度），外加历史下载任务的媒体索引补齐。
///
/// # 为什么是一版而不是七版
///
/// 这条工作线原先摊成 v23~v29 七个迁移，是"边做边加"的产物。App 还没有正式发版，
/// 库外只有开发机，没有任何真实用户的 `user_version` 卡在中间——继续往上摞版本号
/// 只会让后来的人以为这七步各自对应过一次线上升级。合成一版。
///
/// # ⛔ 它必须能把**已经跑过 v23~v29 的开发机**也带上来
///
/// 那些机器 `user_version` 已经是 29，而 `local_media_progress` **不进配置备份**
/// （`ConfigBackupService._excludedTables`），重建表等于把开发机上积攒的观看记录
/// 直接抹掉。所以这一版写成**幂等 + 就地补齐**：
///
/// - 表用 `CREATE TABLE IF NOT EXISTS`，列表是**最终形态**（新装一步到位）；
/// - 已经存在的表靠 [_ensureColumns] 按 `PRAGMA table_info` 补缺列（老机器补上来）；
/// - `last_played_at` 只回填 **still NULL** 的行，不动已经有值的；
/// - 索引一律 `IF NOT EXISTS`。
///
/// 版本号取 30（> 前面那一串）就是为了让停在中间任何一档的开发机也会跑到这一版。
///
/// ⚠️ 升级上来的库与新装的库，**列的顺序**会不一样（`ALTER TABLE ADD COLUMN` 只能
/// 往末尾追加）。列的**集合**和索引集是一致的（实测两条路径都是 23 列 / 15 条索引），
/// 而这个仓库全程按列名访问——`fromRow` 按名取，`INSERT` 带显式列清单——所以顺序
/// 不参与任何逻辑。⛔ **别为了"对齐顺序"去重建表**：那张进度表没有备份，重建一次
/// 就可能把开发机上积攒的观看记录赔进去，而换回来的只是 `PRAGMA table_info` 好看一点。
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
/// `id` 是这两者拼出来的单列主键，方便和 [local_media_progress] 直接对上；
/// 拼法只用 `-` 连接（**不能用 `:`**）：它会被 `localVideoRouteId()` 包成
/// `local_<id>` 再进 go_router 的路径段。
///
/// # ⭐ sort_name：自然序必须落在 SQL 里，不能在 Dart 里比
///
/// 列表是 **DB 分页**的（千级条目不整表进内存），所以"按名称排序"只能由
/// `ORDER BY` 完成——而 SQLite 的字符串序是码元序，`ep1, ep10, ep11, ep2…`。
/// 用户拿来接着看整季剧集的场景会第一个坏掉。解法是**入库时预计算一个可直接
/// 字典序比较的 key**（见 `NaturalSortKey`）。
///
/// # ⭐ last_played_at：为「最近播放」那一档冗余出来的列
///
/// 真实时间在永不清理的进度表里，但排序要走索引、分页要稳定。挂在进度表上的
/// 相关子查询排不动 `ORDER BY`，SQLite 会退回临时 B 树，每翻一页把整个匹配集
/// 重排一遍。所以把时间冗余到条目表并单独建索引，写入侧由
/// `LocalMediaRepository.saveProgress` 在同一个事务里维护。
///
/// # ⭐ media_store_uri：身份是真实路径，URI 只是播放句柄
///
/// Android MediaStore 源的条目**用重建出来的真实路径当 `path`**（也就是当身份），
/// `content://` 句柄放这一列。这样同一个物理文件在 MediaStore 源和目录源下拿到的
/// 是**同一条路径**，`adoptIdentityByPath` 与「一个文件只能有一个主人」那套让位
/// 规则才认得出它们是一回事——否则观看进度会按来源各记一份，用户在 A 源看了 20
/// 分钟、切到 B 源还是从头开始。
///
/// 保留 URI 而不是只留路径，是因为只授予 `READ_MEDIA_VIDEO`（没给「所有文件访问」）
/// 时，直接按路径读会被 scoped storage 挡住，那时只能拿 URI 播。
///
/// # ⛔ 索引：ORDER BY 的兜底列必须都在索引里
///
/// 分页靠 OFFSET，排序不稳定会让同一条在两页里各出现一次、另一条一次都不出现
/// （表现是"往下翻着翻着少了几个又重复了几个"，极难查）。所以每一档排序都带唯一
/// 兜底列 `id`，而索引必须把 ORDER BY 用到的列**一个不落**地包含进去——少一个
/// SQLite 就静默退回 `USE TEMP B-TREE FOR ORDER BY`。而 sqlite3 是**同步** API，
/// 这些全落在 UI 线程上。
class MigrationV30LocalMedia extends Migration {
  @override
  int get version => 30;

  @override
  String get description => '本地媒体库全量 schema（合并原 v23~v29）';

  /// 条目表的最终列形态。新装时由 CREATE TABLE 一次到位；老库靠
  /// [_ensureColumns] 逐列补齐。
  ///
  /// ⛔ 只能往后追加，不能改动已有列的定义：`ALTER TABLE ADD COLUMN` 补不了
  /// "改类型"，那需要重建表，而重建表会碰到没有备份的进度数据。
  static const Map<String, String> _itemColumns = <String, String>{
    'ext': 'TEXT',
    'size_bytes': 'INTEGER',
    'modified_at': 'INTEGER',
    'duration_ms': 'INTEGER',
    'width': 'INTEGER',
    'height': 'INTEGER',
    'thumb_path': 'TEXT',
    'sidecar_image_path': 'TEXT',
    'vr_format_json': 'TEXT',
    'folder_path': 'TEXT',
    'category_id': 'TEXT',
    'download_task_id': 'TEXT',
    'last_played_at': 'INTEGER',
    'media_store_uri': 'TEXT',
  };

  static const Map<String, String> _sourceColumns = <String, String>{
    'path': 'TEXT',
    'uri': 'TEXT',
    'scan_cursor': 'TEXT',
    'last_scan_at': 'INTEGER',
  };

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v30：本地媒体库全量 schema');

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
        last_played_at INTEGER,
        media_store_uri TEXT,
        added_at INTEGER NOT NULL,
        missing INTEGER NOT NULL DEFAULT 0,
        UNIQUE(source_id, path_hash)
      );
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

    // 老库（跑过 v23~v29 的开发机）就地补列。新装时上面的 CREATE 已经带全，
    // 这里全是 no-op。
    _ensureColumns(db, 'local_media_sources', _sourceColumns);
    final addedItemColumns = _ensureColumns(
      db,
      'local_media_items',
      _itemColumns,
    );

    // `last_played_at` 只回填还是 NULL 的行：已经有值的那些是运行时写进去的
    // 真实时间，比进度表那份更该被信任（进度表在同一个事务里更新，两者本该
    // 一致；万一不一致，覆盖回去等于把用户刚才的播放抹掉）。
    db.execute('''
      UPDATE local_media_items
      SET last_played_at = (
        SELECT updated_at FROM local_media_progress
        WHERE local_media_progress.item_id = local_media_items.id
      )
      WHERE last_played_at IS NULL
    ''');

    _createIndexes(db);
    final repaired = _repairLegacyDownloadTasks(db);

    LogUtils.i(
      '已应用迁移v30：本地媒体库 schema 就位'
      '（补列 ${addedItemColumns.isEmpty ? '无' : addedItemColumns.join('/')}，'
      '补齐历史下载媒体索引 $repaired 条）',
    );
  }

  /// 按 `PRAGMA table_info` 补齐缺的列，返回这次真的加上去的列名。
  ///
  /// ⛔ 不能无脑 `ALTER TABLE ADD COLUMN` 然后吞异常：那样分不清"本来就有"和
  /// "加失败了"，而后者会让整张表少一列却一声不响，直到某个查询在运行时炸掉。
  static List<String> _ensureColumns(
    CommonDatabase db,
    String table,
    Map<String, String> columns,
  ) {
    final existing = <String>{
      for (final row in db.select('PRAGMA table_info($table)'))
        row['name'] as String,
    };
    final added = <String>[];
    for (final entry in columns.entries) {
      if (existing.contains(entry.key)) continue;
      db.execute('ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}');
      added.add(entry.key);
    }
    return added;
  }

  static void _createIndexes(CommonDatabase db) {
    // ⛔ 先把老库上那两条**排不动任何 ORDER BY** 的索引丢掉，让升级上来的库和
    // 新装的库落到同一份 schema 上。
    //
    // 它们是这条线最早那一版留下的：`idx_local_items_sort_name(source_id,
    // missing, sort_name)` 和 `idx_local_items_modified(source_id, missing,
    // modified_at DESC)`。两条都**没有 `kind` 前缀**（列表每一条查询都带
    // `kind`），也**没有 ORDER BY 的兜底列 `id``**，所以 SQLite 一条都选不上，
    // 只会退回临时 B 树——`idx_local_items_page_name` 出现之后它们就是纯粹的
    // 死重量，而每一条索引都要在首扫那几万次插入上各交一份钱。
    //
    // 留着它们的唯一后果是"升级上来的库比新装的多两条没人走的索引"，而
    // schema 分叉正是以后最难查的那类问题。
    const dropped = <String>[
      'DROP INDEX IF EXISTS idx_local_items_sort_name',
      'DROP INDEX IF EXISTS idx_local_items_modified',
    ];
    for (final statement in dropped) {
      db.execute(statement);
    }

    const statements = <String>[
      // 认亲（同一路径换了主人时把进度/VR 覆盖搬过去）走这一条。
      'CREATE INDEX IF NOT EXISTS idx_local_items_path '
          'ON local_media_items(path)',
      // 「当前文件所在文件夹」那一支的计数，以及收敛时按目录排除。
      'CREATE INDEX IF NOT EXISTS idx_local_items_folder '
          'ON local_media_items(source_id, folder_path)',
      // ── 卡片墙分页：每一档排序各一条，尾部带齐 ORDER BY 的兜底列 ──
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_name '
          'ON local_media_items(kind, source_id, missing, sort_name, name, id)',
      // 不限定源的「全部」那一支；没有它这条查询是整表 SCAN。
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_name_all '
          'ON local_media_items(kind, missing, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_duration '
          'ON local_media_items(kind, source_id, missing, duration_ms DESC, sort_name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_size '
          'ON local_media_items(kind, source_id, missing, size_bytes DESC, sort_name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_folder '
          'ON local_media_items(kind, source_id, missing, folder_path, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_added '
          'ON local_media_items(kind, source_id, missing, added_at DESC, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_played '
          'ON local_media_items(kind, source_id, missing, last_played_at DESC, sort_name, name, id)',
      // ── 叠加分类筛选的同一批 ──
      // ⛔ `source_id` 必须排在 `category_id` 前面：卡片墙的分页与分类计数都是
      // 按当前来源算的（数字必须和点进去看到的那张墙同口径），所以每一条真实
      // 查询都带着 `source_id`。反过来排会让 source_id 退化成逐行回表。
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category '
          'ON local_media_items(kind, source_id, category_id, missing, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_duration '
          'ON local_media_items(kind, source_id, category_id, missing, duration_ms DESC, sort_name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_size '
          'ON local_media_items(kind, source_id, category_id, missing, size_bytes DESC, sort_name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_folder '
          'ON local_media_items(kind, source_id, category_id, missing, folder_path, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_added '
          'ON local_media_items(kind, source_id, category_id, missing, added_at DESC, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_items_page_category_played '
          'ON local_media_items(kind, source_id, category_id, missing, last_played_at DESC, sort_name, name, id)',
    ];
    for (final statement in statements) {
      db.execute(statement);
    }
  }

  /// 补齐 v13 那次没能解析出来的历史视频任务媒体索引。
  ///
  /// 只要 `ext_data` 里还留着视频类型和 id 就能安全补回，补回之后「已下载」同步
  /// 和播放队列才看得到它。
  ///
  /// ⛔ 这条 UPDATE 会触发 v17 的 `trg_download_tasks_video_media_unique_update`：
  /// 库里如果已经有一条同 `media_id + quality` 的任务，触发器会 `RAISE(ABORT)`。
  /// ABORT 只回滚**当前这一条语句**，不影响外层事务，所以逐条 try/catch 跳过即可
  /// ——那种行本来就是重复任务，补不进去是对的。
  static int _repairLegacyDownloadTasks(CommonDatabase db) {
    final rows = db.select(
      'SELECT id, ext_data FROM download_tasks '
      'WHERE media_type IS NULL AND ext_data IS NOT NULL',
    );
    var repaired = 0;
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row['ext_data'].toString());
        if (decoded is! Map<String, dynamic> || decoded['type'] != 'video') {
          continue;
        }
        final data = decoded['data'];
        if (data is! Map<String, dynamic>) continue;
        final mediaId = data['id'] as String?;
        if (mediaId == null || mediaId.isEmpty) continue;
        final quality = data['quality'] as String?;
        db.execute(
          'UPDATE download_tasks SET media_type = ?, media_id = ?, quality = ? '
          'WHERE id = ?',
          ['video', mediaId, quality, row['id']],
        );
        repaired++;
      } catch (e) {
        LogUtils.w(
          '迁移v30：补齐历史视频任务失败（多半是同 media_id+quality 已存在、'
              '撞上 v17 的唯一约束触发器），taskId=${row['id']}，error=$e',
          'MigrationV30LocalMedia',
        );
      }
    }
    return repaired;
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v30');
    db.execute('DROP TABLE IF EXISTS local_media_progress;');
    db.execute('DROP TABLE IF EXISTS local_media_items;');
    db.execute('DROP TABLE IF EXISTS local_media_sources;');
    LogUtils.i('已回滚迁移v30：本地媒体库三表已删除');
  }
}
