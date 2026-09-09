import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 列表排序。名称一档走预计算的 `sort_name`（自然序），见 `natural_sort_key.dart`。
enum LocalMediaSort { addedDesc, modifiedDesc, nameAsc, durationDesc, sizeDesc }

/// 增量扫描要用的「库里现在长什么样」的轻量快照。
class LocalMediaFingerprint {
  const LocalMediaFingerprint({this.sizeBytes, this.modifiedAt});
  final int? sizeBytes;
  final int? modifiedAt;
}

class LocalMediaRepository {
  LocalMediaRepository([CommonDatabase? database])
    : _db = database ?? DatabaseService().database;

  final CommonDatabase _db;

  static const String _tag = 'LocalMediaRepository';

  // ── 源 ──────────────────────────────────────────────────────────────────

  List<LocalMediaSource> getSources() {
    final rows = _db.select(
      'SELECT * FROM local_media_sources ORDER BY sort_order ASC, created_at ASC',
    );
    return rows.map(LocalMediaSource.fromRow).toList();
  }

  LocalMediaSource? getSource(String id) {
    final rows = _db.select(
      'SELECT * FROM local_media_sources WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return LocalMediaSource.fromRow(rows.first);
  }

  /// 这条路径是不是已经被某个源覆盖了（含父目录）。
  ///
  /// ⛔ 加源前必须问一次。源 A 是源 B 的父目录时，同一个文件会在两个源里各存一份，
  /// "按来源筛选"的结果就开始飘，而用户完全看不出为什么。宁可在加的时候拦一下。
  LocalMediaSource? findOverlappingSource(String path) {
    final normalized = _withTrailingSeparator(path);
    for (final source in getSources()) {
      final existing = source.path;
      if (existing == null || existing.isEmpty) continue;
      final other = _withTrailingSeparator(existing);
      if (normalized == other ||
          normalized.startsWith(other) ||
          other.startsWith(normalized)) {
        return source;
      }
    }
    return null;
  }

  static String _withTrailingSeparator(String path) =>
      path.endsWith('/') ? path : '$path/';

  void upsertSource(LocalMediaSource source) {
    final row = source.toRow();
    final columns = row.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final assignments = columns
        .where((c) => c != 'id')
        .map((c) => '$c = excluded.$c')
        .join(', ');
    _db.execute(
      'INSERT INTO local_media_sources (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $assignments',
      columns.map((c) => row[c]).toList(),
    );
  }

  /// 删源：条目与进度一并清掉。
  ///
  /// ⛔ 进度必须跟着删（§8.3 P4）。留着的话下次重新加同一个目录，会拿到一份
  /// 用户以为已经删掉的观看记录——那是隐私问题，不是"贴心"。
  void deleteSource(String id) {
    _db.execute('BEGIN');
    try {
      _db.execute(
        'DELETE FROM local_media_progress WHERE item_id IN '
        '(SELECT id FROM local_media_items WHERE source_id = ?)',
        [id],
      );
      _db.execute('DELETE FROM local_media_items WHERE source_id = ?', [id]);
      _db.execute('DELETE FROM local_media_sources WHERE id = ?', [id]);
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('删除本地源失败', tag: _tag, error: e);
      rethrow;
    }
  }

  // ── 条目 ────────────────────────────────────────────────────────────────

  /// 库里这个源现有条目的指纹，供增量扫描比对。
  ///
  /// 只取三列，千级条目也就几百 KB——比"每条去问一次库"便宜得多。
  Map<String, LocalMediaFingerprint> fingerprints(String sourceId) {
    final rows = _db.select(
      'SELECT path_hash, size_bytes, modified_at FROM local_media_items WHERE source_id = ?',
      [sourceId],
    );
    return <String, LocalMediaFingerprint>{
      for (final row in rows)
        row['path_hash'] as String: LocalMediaFingerprint(
          sizeBytes: row['size_bytes'] as int?,
          modifiedAt: row['modified_at'] as int?,
        ),
    };
  }

  /// 批量写入一批扫描结果。**一批一个显式事务**。
  ///
  /// ⛔ 真正的卡顿在写库这一侧，不在遍历：sqlite3 的 API 是同步的，逐条 INSERT
  /// 会让每条都各自提交一次事务，千级条目直接把帧吃光。调用方按 200~500 条一批
  /// 调这里，批与批之间让一帧出去。
  ///
  /// 冲突时**不是整行覆盖**：
  /// - `category_id` 是用户设的，扫描无权动它；
  /// - `thumb_path` 是我们生成并落盘的，重扫不该把它抹成 null 让缩略图白生成一遍；
  /// - `duration_ms/width/height/vr_format_json` 是从**文件内容**推出来的，只有在
  ///   大小或修改时间真的变了的时候才作废重算——否则每次重扫都要把整库重新解一遍。
  void upsertItems(List<LocalMediaItem> items) {
    if (items.isEmpty) return;
    final columns = items.first.toRow().keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    const contentDerived = <String>[
      'duration_ms',
      'width',
      'height',
      'thumb_path',
      'vr_format_json',
    ];
    // 扫描能看到的、且每次都该刷新的列。
    const rescanned = <String>[
      'path',
      'name',
      'sort_name',
      'ext',
      'folder_path',
      'sidecar_image_path',
    ];
    // ⛔ 指纹两列**只在量得到的时候才写**。
    //
    // 上游已经守住了"别把 statSync 的 (-1, 0) 当真值"（见
    // `LocalMediaScanService`），量不出来时给的是 null。但 `x = excluded.x` 会
    // 把这个 null **写到库里那个真值头上**——「不知道」覆盖掉「知道」。
    //
    // 后果和 §13.10 那次是同一个：`size_bytes/modified_at` 是"这还是不是同一个
    // 文件"的唯一判据，指纹一旦被抹成 null，下一轮 [_dropProgressOfReplacedItems]
    // 的 [_fingerprintTrustworthy] 就不成立，文件被换掉也认不出来，旧进度会安在
    // 一个新文件上。SD 卡扫到一半被拔、权限被回收都会走到这里。
    //
    // 所以：拿到真值就更新，拿不到就保留原样。**对没有备份的用户数据，
    // 「不知道」只能等于「保留」。**
    const fingerprint = <String>['size_bytes', 'modified_at'];
    // `IS NOT` 在 SQLite 里是 null 安全的比较，正是这里要的。
    // ⛔ 口径必须和上面那段 CASE 一致：这一轮没量到（excluded 为 null）时不能
    // 算"变了"，否则 duration/width/height/缩略图会被一次失败的 stat 全部作废。
    const changed =
        '((excluded.modified_at IS NOT NULL '
        'AND local_media_items.modified_at IS NOT excluded.modified_at) '
        'OR (excluded.size_bytes IS NOT NULL '
        'AND local_media_items.size_bytes IS NOT excluded.size_bytes))';
    final assignments = <String>[
      ...rescanned.map((c) => '$c = excluded.$c'),
      ...fingerprint.map(
        (c) =>
            '$c = CASE WHEN excluded.$c IS NULL '
            'THEN local_media_items.$c ELSE excluded.$c END',
      ),
      'missing = 0',
      ...contentDerived.map(
        (c) =>
            '$c = CASE WHEN $changed THEN NULL ELSE local_media_items.$c END',
      ),
    ].join(', ');

    final statement = _db.prepare(
      'INSERT INTO local_media_items (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $assignments',
    );
    _db.execute('BEGIN');
    try {
      // ⛔ 必须在 upsert **之前**：这一步靠比对库里那份旧的 size/mtime 判断
      //    「还是不是同一个文件」，写完就再也分不出来了。
      _dropProgressOfReplacedItems(items);
      for (final item in items) {
        final row = item.toRow();
        statement.execute(columns.map((c) => row[c]).toList());
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('批量写入本地条目失败（${items.length} 条）', tag: _tag, error: e);
      rethrow;
    } finally {
      statement.close();
    }
  }

  /// 同一个 id 底下换了一个**不同的文件**：把它的进度行清掉。
  ///
  /// # ⛔ 为什么不能挂在 `missing` 上
  ///
  /// 直觉的做法是「[markMissingExcept] 标记 missing 时顺手删进度」，那是错的，
  /// 而且是这个文件里已经写明的一条纪律：外置存储没挂上、目录临时不可读时，
  /// missing 是**假警报**，删进度等于让用户的观看记录凭空蒸发。
  ///
  /// 更要紧的是它**根本盖不住主要场景**：用户直接把文件覆盖掉（同名重下、
  /// 剪辑后另存、rsync 同步）时，那一行从头到尾没有 missing 过。
  ///
  /// # 判据：与 [upsertItems] 的 `changed` 同一条
  ///
  /// 条目 id 是 `<源 uuid>-<路径 sha1>`——**同源同路径就是同一个 id**。所以
  /// 「删掉再放一个同名文件」拿到的是同一把钥匙，旧进度会悄悄复活，用户点开
  /// 一个全新的文件却从中间开始放。真正能分辨"换没换文件"的只有内容指纹，
  /// 也就是 `size_bytes` / `modified_at`——`duration_ms/width/height/thumb_path`
  /// 那几列早就是按这条判据作废重算的，进度只是漏了。
  ///
  /// 大小与修改时间都没变则视为同一个文件，进度保留：这正是"外置盘重新挂上、
  /// 重扫一遍、接着看"该有的样子。
  /// 指纹可信吗。
  ///
  /// ⛔ `-1` / `0` 不是"小一点的数值"，是 `statSync()` 量不出来时的哨兵
  /// （它**不抛异常**，返回 `type = notFound` 的 `FileStat`）。历史上写进库的
  /// 脏数据也长这样。判"换没换文件"时，**不知道必须当成不知道**：这张表不进
  /// 配置备份（见 `ConfigBackupService._excludedTables`），删错了没有任何找回
  /// 的路，所以宁可留着一条陈旧进度，也不能凭一个假指纹把真记录删掉。
  static bool _fingerprintTrustworthy(int? sizeBytes, int? modifiedAt) =>
      sizeBytes != null && sizeBytes >= 0 && modifiedAt != null && modifiedAt > 0;

  void _dropProgressOfReplacedItems(List<LocalMediaItem> items) {
    const chunkSize = 400;
    // 整张表都空（新装 / 刚清过 / 从没播过本机文件）就不必回表了——首扫一个
    // 五万条的源会走到这里一百多次，而那正是最不该加活儿的时候。
    final anyProgress = _db.select(
      'SELECT 1 FROM local_media_progress LIMIT 1',
    );
    if (anyProgress.isEmpty) return;
    final incoming = <String, LocalMediaFingerprint>{
      for (final item in items)
        item.id: LocalMediaFingerprint(
          sizeBytes: item.sizeBytes,
          modifiedAt: item.modifiedAt,
        ),
    };
    final ids = incoming.keys.toList();
    final replaced = <String>[];
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        i + chunkSize > ids.length ? ids.length : i + chunkSize,
      );
      final marks = List.filled(chunk.length, '?').join(', ');
      // 只问有进度行的那些：绝大多数条目从没被播过，没必要为它们回表。
      final rows = _db.select(
        'SELECT i.id AS id, i.size_bytes AS size_bytes, i.modified_at AS modified_at '
        'FROM local_media_items i '
        'JOIN local_media_progress p ON p.item_id = i.id '
        'WHERE i.id IN ($marks)',
        chunk,
      );
      for (final row in rows) {
        final id = row['id'] as String;
        final now = incoming[id];
        if (now == null) continue;
        final oldSize = row['size_bytes'] as int?;
        final oldModified = row['modified_at'] as int?;
        // 两边都得量得准才敢下这个判断，见 [_fingerprintTrustworthy]。
        if (!_fingerprintTrustworthy(oldSize, oldModified) ||
            !_fingerprintTrustworthy(now.sizeBytes, now.modifiedAt)) {
          continue;
        }
        if (oldSize != now.sizeBytes || oldModified != now.modifiedAt) {
          replaced.add(id);
        }
      }
    }
    if (replaced.isEmpty) return;
    for (var i = 0; i < replaced.length; i += chunkSize) {
      final chunk = replaced.sublist(
        i,
        i + chunkSize > replaced.length ? replaced.length : i + chunkSize,
      );
      final marks = List.filled(chunk.length, '?').join(', ');
      _db.execute(
        'DELETE FROM local_media_progress WHERE item_id IN ($marks)',
        chunk,
      );
    }
    // ⛔ 带上前几个 id：用户报「进度全没了」时，光有个数字分不出这是一次正当的
    // 「文件被换掉」还是一次误删，日志得能自证。
    LogUtils.i(
      '本地条目内容已变，清掉 ${replaced.length} 条陈旧进度'
      '（${replaced.take(3).join(', ')}${replaced.length > 3 ? ' …' : ''}）',
      _tag,
    );
  }

  /// 一轮完整扫描结束后，把**这轮没再见到**的条目标记为 missing。
  ///
  /// ⛔ 标记而不是删除：外置存储没挂上、目录临时不可读时，删掉等于让用户的
  /// 观看记录连带蒸发。而且只在**扫描确实跑完**时才调（中途被杀不能调，否则
  /// 没扫到的那一半会被冤枉成"文件没了"）。
  int markMissingExcept(String sourceId, Set<String> seenHashes) {
    if (seenHashes.isEmpty) {
      _db.execute(
        'UPDATE local_media_items SET missing = 1 WHERE source_id = ?',
        [sourceId],
      );
      return _db.updatedRows;
    }

    // 分片进 IN(...)：SQLite 默认变量上限 999，整库一把梭会直接报错。
    const chunkSize = 400;
    final hashes = seenHashes.toList();
    var affected = 0;
    _db.execute('BEGIN');
    try {
      _db.execute(
        'UPDATE local_media_items SET missing = 1 WHERE source_id = ? AND missing = 0',
        [sourceId],
      );
      for (var i = 0; i < hashes.length; i += chunkSize) {
        final chunk = hashes.sublist(
          i,
          i + chunkSize > hashes.length ? hashes.length : i + chunkSize,
        );
        final marks = List.filled(chunk.length, '?').join(', ');
        _db.execute(
          'UPDATE local_media_items SET missing = 0 '
          'WHERE source_id = ? AND path_hash IN ($marks)',
          <Object?>[sourceId, ...chunk],
        );
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('收敛 missing 标记失败', tag: _tag, error: e);
      rethrow;
    }
    // 返回「现在有多少条是 missing」——调用方拿它决定要不要提示用户，
    // 用 hashes.length 是答非所问。
    affected =
        (_db.select(
                  'SELECT COUNT(*) AS c FROM local_media_items WHERE source_id = ? AND missing = 1',
                  [sourceId],
                ).first['c']
                as int?) ??
        0;
    return affected;
  }

  /// 按 id 取一条。播放前的"文件还在不在"与「接着看」的 [LocalPlaybackTarget]
  /// 都靠它**现查一次库**——池里那份快照可能是几分钟前的（同 `DownloadsPlaybackQueue`
  /// 那条注释：中间发生过一次重扫，快照里的 path 就指向一个已经不在的文件）。
  LocalMediaItem? getItem(String id) {
    final rows = _db.select('SELECT * FROM local_media_items WHERE id = ?', [
      id,
    ]);
    if (rows.isEmpty) return null;
    return LocalMediaItem.fromRow(rows.first);
  }

  /// 这个源下有哪些文件夹，各有多少条可播的。
  ///
  /// 「接着看」里「当前文件所在文件夹」那一支要用它判断值不值得出现
  /// （条目数 ≥2 且 ≠ 整个源，否则那一条就是纯噪音）。
  List<({String folderPath, int count})> folderCounts(
    String sourceId, {
    LocalMediaItemKind kind = LocalMediaItemKind.video,
  }) {
    final rows = _db.select(
      'SELECT folder_path AS f, COUNT(*) AS c FROM local_media_items '
      'WHERE source_id = ? AND kind = ? AND missing = 0 AND folder_path IS NOT NULL '
      'GROUP BY folder_path ORDER BY c DESC',
      [sourceId, kind.name],
    );
    return [
      for (final row in rows)
        (folderPath: row['f'] as String, count: (row['c'] as int?) ?? 0),
    ];
  }

  /// 分页查条目。列表永远走这里，**不整表进内存**。
  List<LocalMediaItem> queryItems({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    LocalMediaSort sort = LocalMediaSort.addedDesc,
    String? folderPath,
    bool includeMissing = false,
    required int offset,
    required int limit,
  }) {
    final where = <String>['kind = ?'];
    final params = <Object?>[kind.name];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    }
    if (folderPath != null) {
      where.add('folder_path = ?');
      params.add(folderPath);
    }
    if (!includeMissing) where.add('missing = 0');
    params
      ..add(limit)
      ..add(offset);
    final rows = _db.select(
      'SELECT * FROM local_media_items WHERE ${where.join(' AND ')} '
      'ORDER BY ${_orderBy(sort)} LIMIT ? OFFSET ?',
      params,
    );
    return rows.map(LocalMediaItem.fromRow).toList();
  }

  int countItems({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    bool includeMissing = false,
  }) {
    final where = <String>['kind = ?'];
    final params = <Object?>[kind.name];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    }
    if (!includeMissing) where.add('missing = 0');
    final rows = _db.select(
      'SELECT COUNT(*) AS c FROM local_media_items WHERE ${where.join(' AND ')}',
      params,
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  /// 排序表达式。
  ///
  /// ⛔ 每一档都要带一个**唯一的兜底列**（这里是 `id`）：分页靠 OFFSET，排序不稳定
  /// 时同一条会在两页里各出现一次、另一条则一次都不出现——表现是"往下翻着翻着
  /// 少了几个、又重复了几个"，很难查。
  static String _orderBy(LocalMediaSort sort) => switch (sort) {
    // 名称档再加一层 `name`：`sort_name` 会吃掉前导零，`ep01` 与 `ep1` 折出同一个 key。
    LocalMediaSort.nameAsc => 'sort_name ASC, name ASC, id ASC',
    LocalMediaSort.modifiedDesc => 'modified_at DESC, id ASC',
    LocalMediaSort.durationDesc => 'duration_ms DESC, id ASC',
    LocalMediaSort.sizeDesc => 'size_bytes DESC, id ASC',
    LocalMediaSort.addedDesc => 'added_at DESC, id ASC',
  };

  // ── 进度（永不清理，见 migration v23 的类注释） ──────────────────────────

  ({int positionMs, int? durationMs, bool completed})? getProgress(
    String itemId,
  ) {
    final rows = _db.select(
      'SELECT position_ms, duration_ms, completed FROM local_media_progress WHERE item_id = ?',
      [itemId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return (
      positionMs: row['position_ms'] as int? ?? 0,
      durationMs: row['duration_ms'] as int?,
      completed: (row['completed'] as int? ?? 0) != 0,
    );
  }

  /// 一次取一批的进度。
  ///
  /// ⛔ 「接着看」列表一页几十条，逐条 [getProgress] 就是几十次 select——
  /// sqlite3 是**同步**的，那几十次全落在 UI 线程上。分片进 IN(...)（变量上限 999）。
  Map<String, ({int positionMs, int? durationMs, bool completed})> progressFor(
    List<String> itemIds,
  ) {
    final result = <String, ({int positionMs, int? durationMs, bool completed})>{};
    if (itemIds.isEmpty) return result;
    const chunkSize = 400;
    for (var i = 0; i < itemIds.length; i += chunkSize) {
      final chunk = itemIds.sublist(
        i,
        i + chunkSize > itemIds.length ? itemIds.length : i + chunkSize,
      );
      final marks = List.filled(chunk.length, '?').join(', ');
      final rows = _db.select(
        'SELECT item_id, position_ms, duration_ms, completed '
        'FROM local_media_progress WHERE item_id IN ($marks)',
        chunk,
      );
      for (final row in rows) {
        result[row['item_id'] as String] = (
          positionMs: row['position_ms'] as int? ?? 0,
          durationMs: row['duration_ms'] as int?,
          completed: (row['completed'] as int? ?? 0) != 0,
        );
      }
    }
    return result;
  }

  void saveProgress({
    required String itemId,
    required int positionMs,
    int? durationMs,
    bool completed = false,
  }) {
    _db.execute(
      'INSERT INTO local_media_progress (item_id, position_ms, duration_ms, completed, updated_at) '
      'VALUES (?, ?, ?, ?, ?) '
      'ON CONFLICT(item_id) DO UPDATE SET '
      'position_ms = excluded.position_ms, duration_ms = excluded.duration_ms, '
      'completed = excluded.completed, updated_at = excluded.updated_at',
      [
        itemId,
        positionMs,
        durationMs,
        completed ? 1 : 0,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  /// 库里一共记着多少条本机观看记录。清除入口拿它决定「要不要露出来」
  /// 以及在确认框里说清楚这一下会删掉多少东西。
  int progressCount() =>
      (_db.select(
                'SELECT COUNT(*) AS c FROM local_media_progress',
              ).first['c']
              as int?) ??
      0;

  /// 清空本机观看记录（进度 + 「已看完」标记），返回删掉的条数。
  ///
  /// ⛔ **只删记录，条目和磁盘文件一个不动**——这是隐私入口，不是删片入口。
  ///
  /// 这张表按设计**永不自动清理**（见 migration v23 的类注释：本地文件不会消失，
  /// 「两周后回来接着看第 3 集」正是它存在的理由）。代价是它只增不减，而且现在
  /// 会以进度条的形式显示在列表上——那就必须有一个用户自己动手的清除口子，
  /// 否则唯一的清法是把整个源移除。
  int clearAllProgress() {
    _db.execute('DELETE FROM local_media_progress');
    final removed = _db.updatedRows;
    LogUtils.i('已清空本机观看记录：$removed 条', _tag);
    return removed;
  }
}
