import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:get/get.dart';
import 'package:sqlite3/common.dart';

/// 列表排序。名称一档走预计算的 `sort_name`（自然序），见 `natural_sort_key.dart`。
enum LocalMediaSort {
  nameAsc,
  durationDesc,
  sizeDesc,
  folderAsc,
  addedDesc,
  playedDesc,

  /// 旧池身份仍可能在进程内引用这一档，保留它作为兼容项；新 UI 不展示。
  modifiedDesc,
}

/// 「只看未分类」的筛选值。分类 id 是 uuid，撞不上这个字面量——与
/// `DownloadTaskRepository` 里那套筛选串同一个约定，两边读起来是一回事。
const String kLocalMediaUncategorized = 'uncategorized';

/// 增量扫描要用的「库里现在长什么样」的轻量快照。
class LocalMediaFingerprint {
  const LocalMediaFingerprint({
    this.sizeBytes,
    this.modifiedAt,
    this.missing = false,
  });
  final int? sizeBytes;
  final int? modifiedAt;
  final bool missing;
}

class LocalMediaRepository {
  LocalMediaRepository([CommonDatabase? database])
    : _db = database ?? DatabaseService().database;

  final CommonDatabase _db;

  /// 所有本地库实例共享的变更信号。
  ///
  /// 页面、队列和来源管理页各自持有仓库实例；只在某个实例上挂监听会漏掉
  /// 另一个实例的写入，所以信号必须归到类级别。值只表示「重新读取」，不承诺
  /// 具体写入了哪一行。
  static final RxInt changeRevision = 0.obs;

  static void notifyChanged() => changeRevision.value++;

  static const String _tag = 'LocalMediaRepository';

  // ── 源 ──────────────────────────────────────────────────────────────────

  List<LocalMediaSource> getSources() {
    final rows = _db.select(
      'SELECT * FROM local_media_sources ORDER BY sort_order ASC, created_at ASC',
    );
    return rows.map(LocalMediaSource.fromRow).toList();
  }

  LocalMediaSource? getSource(String id) {
    final rows = _db.select('SELECT * FROM local_media_sources WHERE id = ?', [
      id,
    ]);
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
      // ⛔ 内建源（「已下载」）不参与：它的 `path` 是当前下载目录，只是一条
      // 参考信息。拿它拦人的话，用户会被一个**他既删不掉、也改不了路径**的源
      // 挡在自己的下载目录（以及它的任何上级目录）之外。真正防重复的是
      // [pathsOfSource] 那条逐路径让位规则，不是这里。
      if (source.isBuiltIn) continue;
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
    notifyChanged();
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
      notifyChanged();
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
      'SELECT path_hash, size_bytes, modified_at, missing '
      'FROM local_media_items WHERE source_id = ?',
      [sourceId],
    );
    return <String, LocalMediaFingerprint>{
      for (final row in rows)
        row['path_hash'] as String: LocalMediaFingerprint(
          sizeBytes: row['size_bytes'] as int?,
          modifiedAt: row['modified_at'] as int?,
          missing: (row['missing'] as int? ?? 0) != 0,
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
  /// - `category_id` 是用户设的，扫描无权动它——唯一例外是这条路径换了个不同的
  ///   下载任务（删了重下），见下面 [adoptCategory] 那段；
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
      'download_task_id',
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
    // ⛔ `category_id` 平时不动（那是用户设的，扫描/同步无权覆盖），**只有一种
    // 例外**：这条路径换了一个**不同的下载任务**。
    //
    // 场景是真实的：用户删掉一条下载（文件跟着删，行留在库里 missing=1，分类还
    // 挂着），再重新下同一个视频、同一个清晰度——文件名模板一样 ⇒ 路径一样 ⇒
    // **条目 id 一样**，于是走到这条 UPDATE 上。新任务带着用户刚在下载弹窗里选
    // 的分类，而库里那一行还留着上一条命的分类。不认这次接管的话，
    // `local_media_items` 和 `download_tasks` 会各说各的，而且**没有任何一条路
    // 能把它们再拉回来**——两个镜像入口都不经过这里（`insertTask` 是整行写）。
    //
    // 扫描来的条目 `download_task_id` 恒为 null，条件不成立，一如既往不受影响。
    const adoptCategory =
        'category_id = CASE '
        'WHEN excluded.download_task_id IS NOT NULL '
        'AND local_media_items.download_task_id IS NOT excluded.download_task_id '
        'THEN excluded.category_id ELSE local_media_items.category_id END';
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
      adoptCategory,
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
      // 认亲发生在写条目之前；新 id 此时才刚插入，所以在同一事务里把迁移后
      // 的进度时间反映到条目表。没有进度的条目也要写回 null，避免旧 id 的
      // last_played_at 残留在同一条路径的重建行上。
      const chunkSize = 400;
      final ids = [for (final item in items) item.id];
      for (var i = 0; i < ids.length; i += chunkSize) {
        final chunk = ids.sublist(
          i,
          i + chunkSize > ids.length ? ids.length : i + chunkSize,
        );
        final marks = List.filled(chunk.length, '?').join(', ');
        _db.execute(
          'UPDATE local_media_items SET last_played_at = '
          '(SELECT updated_at FROM local_media_progress WHERE item_id = local_media_items.id) '
          'WHERE id IN ($marks)',
          chunk,
        );
      }
      _db.execute('COMMIT');
      notifyChanged();
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
      sizeBytes != null &&
      sizeBytes >= 0 &&
      modifiedAt != null &&
      modifiedAt > 0;

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
      notifyChanged();
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
      notifyChanged();
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

  /// 同一个文件换了主人时，把挂在**旧 id** 上的记忆搬到新 id 上。
  ///
  /// # ⛔ 为什么非搬不可
  ///
  /// 条目 id 是 `<源 id>-<路径 sha1>`（见 [LocalMediaItem.buildId]），所以
  /// **同一个文件在两个源下是两个不同的 id**。而观看进度（`local_media_progress`）
  /// 与 VR 格式覆盖（`video_vr_override`）都只认 id。
  ///
  /// 「已下载」升格成真实源那一刻，这件事就会真实发生：用户从前把下载目录也当成
  /// 一个普通文件夹加过，在里面看了三集；升级之后同样这三个文件被 `downloads`
  /// 源重新认领，旧行随即让位（见 [pathsOfSource]）。不搬的话，那三条进度会变成
  /// **谁也查不到的孤儿**——点开同一集从 0:00 开始，而 `local_media_progress`
  /// 不进配置备份，用户没有任何找回的办法。
  ///
  /// # 规则
  ///
  /// - 按**路径**认亲（走 v23 的 `idx_local_items_path`），不按 id；
  /// - 新 id 上**已经有**记忆时不覆盖：那是用户在新主人下真看过的，比旧的新；
  /// - 搬完把旧行删掉，免得下一次又搬一遍（以及避免"清除记录"数出幽灵条数）。
  ///
  /// 返回搬走了几条进度。调用方必须在 [upsertItems] **之前**调它。
  int adoptIdentityByPath({
    required String newSourceId,
    required Map<String, String> pathToNewId,
    required Map<String, LocalMediaFingerprint> fingerprints,
  }) {
    if (pathToNewId.isEmpty) return 0;
    var moved = 0;
    const chunkSize = 200;
    final paths = pathToNewId.keys.toList();
    _db.execute('BEGIN');
    try {
      for (var i = 0; i < paths.length; i += chunkSize) {
        final chunk = paths.sublist(
          i,
          i + chunkSize > paths.length ? paths.length : i + chunkSize,
        );
        final marks = List.filled(chunk.length, '?').join(', ');
        final rows = _db.select(
          'SELECT id, path, missing, size_bytes, modified_at '
          'FROM local_media_items '
          'WHERE path IN ($marks) AND source_id != ?',
          <Object?>[...chunk, newSourceId],
        );
        for (final row in rows) {
          final oldId = row['id'] as String;
          final path = row['path'] as String;
          final newId = pathToNewId[path];
          if (newId == null || newId == oldId) continue;
          final incoming = fingerprints[path];
          final oldSize = row['size_bytes'] as int?;
          final oldModified = row['modified_at'] as int?;
          // 认亲只适用于仍然活着、且两边指纹完全一致的条目。仅凭路径会把
          // 同名重下或已被替换的文件的观看记录错误地转移给新来源。
          if ((row['missing'] as int? ?? 0) != 0 ||
              incoming == null ||
              !_fingerprintTrustworthy(oldSize, oldModified) ||
              !_fingerprintTrustworthy(
                incoming.sizeBytes,
                incoming.modifiedAt,
              ) ||
              oldSize != incoming.sizeBytes ||
              oldModified != incoming.modifiedAt) {
            continue;
          }
          // `OR IGNORE`：新 id 已经有一行就保留新的那份，旧的直接丢。
          _db.execute(
            'UPDATE OR IGNORE local_media_progress SET item_id = ? WHERE item_id = ?',
            [newId, oldId],
          );
          moved += _db.updatedRows;
          _db.execute('DELETE FROM local_media_progress WHERE item_id = ?', [
            oldId,
          ]);
          _db.execute(
            'UPDATE OR IGNORE video_vr_override SET video_id = ? WHERE video_id = ?',
            [newId, oldId],
          );
          _db.execute('DELETE FROM video_vr_override WHERE video_id = ?', [
            oldId,
          ]);
          _db.execute(
            'UPDATE local_media_items SET last_played_at = '
            '(SELECT updated_at FROM local_media_progress WHERE item_id = ?) '
            'WHERE id = ?',
            [newId, newId],
          );
          _db.execute(
            'UPDATE local_media_items SET last_played_at = NULL WHERE id = ?',
            [oldId],
          );
        }
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('迁移本地条目记忆失败', tag: _tag, error: e);
      return 0;
    }
    if (moved > 0) {
      notifyChanged();
      LogUtils.i('同一文件换了来源，搬走 $moved 条观看进度', _tag);
    }
    return moved;
  }

  /// 某个源名下所有条目的绝对路径。
  ///
  /// 目录扫描拿它避开**已经归「已下载」管的文件**：用户把下载目录也手动加成
  /// 一个文件夹源时，同一个文件会在两个源里各存一份（id 不同，进度也各记一份），
  /// 而"按来源筛选"从此开始飘。同一条内容只允许有一个主人，且优先是「已下载」
  /// ——它那份带标题/作者/封面，还能退回在线播。
  Set<String> pathsOfSource(String sourceId) {
    // ⛔ `missing = 0` 不能省：所有权是一份**活的**主张，不是墓碑。带上已经
    // missing 的行的话，「已下载」里那条早就没了的记录会永远把这个路径挡在
    // 目录扫描外面——文件明明躺在一个被扫的目录里，却再也没有任何源认领它。
    final rows = _db.select(
      'SELECT path FROM local_media_items WHERE source_id = ? AND missing = 0',
      [sourceId],
    );
    return <String>{for (final row in rows) row['path'] as String};
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

  /// 分类筛选：null 不筛，[kLocalMediaUncategorized] 只看未分类，其余按 id。
  static void _addCategoryFilter(
    String? categoryId,
    List<String> where,
    List<Object?> params,
  ) {
    if (categoryId == null) return;
    if (categoryId == kLocalMediaUncategorized) {
      where.add('category_id IS NULL');
      return;
    }
    where.add('category_id = ?');
    params.add(categoryId);
  }

  /// 每个分类底下有多少条可播的，外加「未分类」那一堆。
  ///
  /// ⛔ 不能拿 `DownloadTaskRepository.getAllCategories()` 那个 `item_count`：
  /// 那是**下载任务**的条数（含图库、含下载中/失败、同一视频两档清晰度算两条），
  /// 而这里数的是本地库里的**文件**。两个数不一样是应该的，混用会让菜单出现
  /// 「显示 5 条、点进去 3 条」。
  /// ⛔ [sourceId] 不是可选的装饰：菜单上的数字必须和用户**点进去之后看到的那张
  /// 墙**同口径。墙是按来源筛过的，数字却数全库的话，就会出现「显示 5 条、点进去
  /// 2 条」——和上面那条不能拿下载任务数是同一个毛病。
  ({int uncategorized, Map<String, int> byCategory}) categoryCounts({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
  }) {
    final where = <String>['kind = ?', 'missing = 0'];
    final params = <Object?>[kind.name];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    }
    final rows = _db.select(
      'SELECT category_id AS c, COUNT(*) AS n FROM local_media_items '
      'WHERE ${where.join(' AND ')} GROUP BY category_id',
      params,
    );
    var uncategorized = 0;
    final byCategory = <String, int>{};
    for (final row in rows) {
      final id = row['c'] as String?;
      final n = (row['n'] as int?) ?? 0;
      if (id == null) {
        uncategorized = n;
      } else {
        byCategory[id] = n;
      }
    }
    return (uncategorized: uncategorized, byCategory: byCategory);
  }

  /// 删掉一个分类会波及多少**内容**（用于删除确认框）。
  ///
  /// ⛔ 不能只数 `download_tasks`：分类升格之后，同一个桶里还装着用户手动归类的
  /// 扫描文件（它们根本没有下载任务）。只报下载数的话，确认框会说「1 个下载」
  /// 而实际上两个文件丢了分类——用户是照着那个数字做决定的。
  ///
  /// 两边有重叠（下载来的文件在两张表里各有一行），所以任务那一半要**扣掉已经
  /// 在本地库里露过面的**，否则又变成数两遍。
  int categoryMemberCount(String categoryId) {
    final rows = _db.select(
      'SELECT '
      '(SELECT COUNT(*) FROM local_media_items WHERE category_id = ?) AS files, '
      '(SELECT COUNT(*) FROM download_tasks t WHERE t.category_id = ? '
      ' AND NOT EXISTS (SELECT 1 FROM local_media_items i '
      '                 WHERE i.download_task_id = t.id)) AS orphanTasks',
      [categoryId, categoryId],
    );
    if (rows.isEmpty) return 0;
    final row = rows.first;
    return ((row['files'] as int?) ?? 0) + ((row['orphanTasks'] as int?) ?? 0);
  }

  /// 把一批本地条目归入某个分类（null = 退回未分类）。
  ///
  /// # ⭐ 分类跟着**文件**走，不跟着下载任务走（§10.7）
  ///
  /// 分类原本是下载模块的概念（v18 挂在 `download_tasks` 上）。那样的话本地库里
  /// 会并排站着两种条目：**下载来的能分类、拷进来的不能**——而这个"为什么"没有
  /// 任何用户能理解的答案，它只反映了我们的实现顺序。所以权威挪到这一列。
  ///
  /// ⛔ 下载来的那些要**镜像回 `download_tasks`**：下载中心那张列表的分类筛选、
  /// 分类计数今天还全跑在它自己那一列上（它会随 §10.6 的拆分一起退休）。不镜像
  /// 的话，同一个文件在两个界面里显示两个分类，而用户没有任何办法知道哪个算数。
  /// 反方向的镜像在 [DownloadTaskRepository.assignTasksToCategory] 里。
  int setItemsCategory(List<String> itemIds, String? categoryId) {
    if (itemIds.isEmpty) return 0;
    const chunkSize = 400;
    var affected = 0;
    _db.execute('BEGIN');
    try {
      for (var i = 0; i < itemIds.length; i += chunkSize) {
        final chunk = itemIds.sublist(
          i,
          i + chunkSize > itemIds.length ? itemIds.length : i + chunkSize,
        );
        final marks = List.filled(chunk.length, '?').join(', ');
        _db.execute(
          'UPDATE local_media_items SET category_id = ? WHERE id IN ($marks)',
          <Object?>[categoryId, ...chunk],
        );
        affected += _db.updatedRows;
        // 镜像：只动这一批里真的挂着下载任务的那些。
        _db.execute(
          'UPDATE download_tasks SET category_id = ?, updated_at = ? '
          'WHERE id IN (SELECT download_task_id FROM local_media_items '
          'WHERE id IN ($marks) AND download_task_id IS NOT NULL)',
          <Object?>[
            categoryId,
            DateTime.now().millisecondsSinceEpoch,
            ...chunk,
          ],
        );
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('设置本地条目分类失败', tag: _tag, error: e);
      rethrow;
    }
    return affected;
  }

  /// 分页查条目。列表永远走这里，**不整表进内存**。
  List<LocalMediaItem> queryItems({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    LocalMediaSort sort = LocalMediaSort.addedDesc,
    String? folderPath,
    String? categoryId,
    bool excludeBuiltInSource = false,
    bool includeMissing = false,
    required int offset,
    required int limit,
  }) {
    final where = <String>['kind = ?'];
    final params = <Object?>[kind.name];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    } else if (excludeBuiltInSource) {
      where.add('source_id != ?');
      params.add(kDownloadsSourceId);
    }
    if (folderPath != null) {
      where.add('folder_path = ?');
      params.add(folderPath);
    }
    _addCategoryFilter(categoryId, where, params);
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
    String? categoryId,
    bool excludeBuiltInSource = false,
    bool includeMissing = false,
  }) {
    final where = <String>['kind = ?'];
    final params = <Object?>[kind.name];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    } else if (excludeBuiltInSource) {
      where.add('source_id != ?');
      params.add(kDownloadsSourceId);
    }
    _addCategoryFilter(categoryId, where, params);
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
    LocalMediaSort.durationDesc => 'duration_ms DESC, sort_name ASC, id ASC',
    LocalMediaSort.sizeDesc => 'size_bytes DESC, sort_name ASC, id ASC',
    LocalMediaSort.folderAsc =>
      'folder_path ASC, sort_name ASC, name ASC, id ASC',
    LocalMediaSort.addedDesc => 'added_at DESC, id ASC',
    LocalMediaSort.playedDesc =>
      'last_played_at DESC, sort_name ASC, name ASC, id ASC',
    LocalMediaSort.modifiedDesc => 'modified_at DESC, id ASC',
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
    final result =
        <String, ({int positionMs, int? durationMs, bool completed})>{};
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
    final now = DateTime.now().millisecondsSinceEpoch;
    _db.execute('BEGIN');
    try {
      _db.execute(
        'INSERT INTO local_media_progress (item_id, position_ms, duration_ms, completed, updated_at) '
        'VALUES (?, ?, ?, ?, ?) '
        'ON CONFLICT(item_id) DO UPDATE SET '
        'position_ms = excluded.position_ms, duration_ms = excluded.duration_ms, '
        'completed = excluded.completed, updated_at = excluded.updated_at',
        [itemId, positionMs, durationMs, completed ? 1 : 0, now],
      );
      _db.execute(
        'UPDATE local_media_items SET last_played_at = ? WHERE id = ?',
        [now, itemId],
      );
      _db.execute('COMMIT');
      notifyChanged();
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// 库里一共记着多少条本机观看记录。清除入口拿它决定「要不要露出来」
  /// 以及在确认框里说清楚这一下会删掉多少东西。
  int progressCount() =>
      (_db.select('SELECT COUNT(*) AS c FROM local_media_progress').first['c']
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
    _db.execute('BEGIN');
    late final int removed;
    late final int clearedTimestamps;
    try {
      _db.execute('DELETE FROM local_media_progress');
      removed = _db.updatedRows;
      _db.execute('UPDATE local_media_items SET last_played_at = NULL');
      clearedTimestamps = _db.updatedRows;
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      rethrow;
    }
    if (removed > 0 || clearedTimestamps > 0) notifyChanged();
    LogUtils.i('已清空本机观看记录：$removed 条', _tag);
    return removed;
  }
}
