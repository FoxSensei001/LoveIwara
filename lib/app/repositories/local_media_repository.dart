import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/utils/natural_sort_key.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
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

extension LocalMediaSortOrderExtension on LocalMediaSort {
  LocalMediaOrder get order => switch (this) {
    LocalMediaSort.nameAsc => const LocalMediaOrder(
      LocalMediaSortField.name,
      ascending: true,
    ),
    LocalMediaSort.durationDesc => const LocalMediaOrder(
      LocalMediaSortField.duration,
      ascending: false,
    ),
    LocalMediaSort.sizeDesc => const LocalMediaOrder(
      LocalMediaSortField.size,
      ascending: false,
    ),
    LocalMediaSort.folderAsc => const LocalMediaOrder(
      LocalMediaSortField.folder,
      ascending: true,
    ),
    LocalMediaSort.addedDesc => const LocalMediaOrder(
      LocalMediaSortField.added,
      ascending: false,
    ),
    LocalMediaSort.playedDesc => const LocalMediaOrder(
      LocalMediaSortField.played,
      ascending: false,
    ),
    LocalMediaSort.modifiedDesc => const LocalMediaOrder(
      LocalMediaSortField.modified,
      ascending: false,
    ),
  };
}

/// 可以拿来排序的字段。UI 上的「按 XX 排序」就是这一串。
enum LocalMediaSortField {
  name, // sort_name, name
  modified, // modified_at
  duration, // duration_ms
  size, // size_bytes
  resolution, // width * height
  fileType, // ext
  fps, // fps
  folder, // folder_path
  added, // added_at
  played, // last_played_at
  favorited, // favorited_at
}

/// 一次排序 ＝ 一个字段 + 一个方向。
class LocalMediaOrder {
  const LocalMediaOrder(this.field, {this.ascending = false});

  final LocalMediaSortField field;
  final bool ascending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalMediaOrder &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          ascending == other.ascending;

  @override
  int get hashCode => Object.hash(field, ascending);

  @override
  String toString() => 'LocalMediaOrder($field, ascending: $ascending)';
}

/// 「只看未分类」的筛选值。分类 id 是 uuid，撞不上这个字面量——与
/// `DownloadTaskRepository` 里那套筛选串同一个约定，两边读起来是一回事。
const String kLocalMediaUncategorized = 'uncategorized';

/// 增量扫描要用的「库里现在长什么样」的轻量快照。
class LocalMediaFingerprint {
  const LocalMediaFingerprint({
    this.sizeBytes,
    this.modifiedAt,
    this.durationMs,
    this.width,
    this.height,
    this.sidecarImagePath,
    this.mediaStoreUri,
    this.missing = false,
    this.metaProbed = false,
  });
  final int? sizeBytes;
  final int? modifiedAt;
  final int? durationMs;
  final int? width;
  final int? height;
  final String? sidecarImagePath;
  final String? mediaStoreUri;
  final bool missing;

  /// 这个文件版本的时长/宽高**探测过了**（`meta_probed_at` 非 NULL），不论探没探出值。
  ///
  /// 调用方拿 `hasMetadata || metaProbed` 判要不要入队：探不出元数据的坏文件不能
  /// 每次冷启动都重开一次 Player。指纹一变 `upsertItems` 就把它清掉，换了文件照样重探。
  final bool metaProbed;

  bool get hasMetadata => durationMs != null && width != null && height != null;

  /// 图片只有宽高，没有时长——拿 [hasMetadata] 判图片会永远返回 false，
  /// 于是每一轮扫描都把全部图片重新入队。
  bool get hasImageMetadata => width != null && height != null;
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

  /// 目录行的变更信号（封面、pin、目录本身的增删），**与条目集合无关**。
  ///
  /// # ⛔ 为什么必须和 [changeRevision] 分家
  ///
  /// [updateDerivedFields] 上那条「派生字段是行内变化，绝不能发全局
  /// notifyChanged()」的纪律，只在它自己那一个方法里生效——紧跟在它后面执行的
  /// 目录封面回填照发不误，等于把刚堵上的口子从旁边开了回来：用户在「所有视频」
  /// 滚到第 300 条，视野里每张卡片生成缩略图都可能触发一次目录封面回填，
  /// 400ms 后卡片墙被 debounce 重载、清空列表、弹回顶部。
  /// （`f9670012 "Stop the local wall from throwing users back to the top"`
  /// 修的就是这个症状，从这条路上又漏了回来。）
  ///
  /// 分家之后：**卡片墙只听 [changeRevision]**，目录卡片那几页两个都听。
  /// 封面回填是目录行的事，与哪一页的条目集合都无关。
  static final RxInt folderRevision = 0.obs;

  static void notifyFolderChanged() => folderRevision.value++;

  static const String _tag = 'LocalMediaRepository';

  /// 把 [items] 按 [chunkSize] 切片，每片连同拼好的 `?, ?, …` 占位串交给 [body]。
  ///
  /// SQLite 默认变量上限 999，整批一把梭进 `IN (…)` 会直接报错；400 给同一条语句里
  /// 的其它参数留足余量。
  static void _inChunks<T>(
    List<T> items,
    void Function(String marks, List<T> chunk) body, {
    int chunkSize = 400,
  }) {
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = i + chunkSize > items.length ? items.length : i + chunkSize;
      final chunk = items.sublist(i, end);
      body(List.filled(chunk.length, '?').join(', '), chunk);
    }
  }

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

  /// 这条路径落在哪个**已添加的文件夹源**里（含与源根相同），以及它相对源根的
  /// rel_path（`/` 分隔，源根为空串，与扫描器 `relPathOf` 同一口径）。
  ///
  /// # 为什么「子文件夹」不再拦（2026-09-13 用户反馈）
  ///
  /// 在用户眼里「添加文件夹」就是加一个快捷入口。A 已经加过，再挑 A/B 时真正想要的
  /// 是「首页直接点进 B」，而不是第二个源——后者正是 [findOverlappingSource] 要防的
  /// 「同一个文件两个 id、进度各记一份」。所以这种情况改由调用方把 B 加进常用目录，
  /// 数据仍只归 A 这一个源。
  ({LocalMediaSource source, String relPath})? locateInSources(String path) {
    final target = p.normalize(path);
    for (final source in getSources()) {
      if (source.isBuiltIn) continue;
      if (source.kind != LocalMediaSourceKind.directory &&
          source.kind != LocalMediaSourceKind.bookmark) {
        continue;
      }
      final root = source.path;
      if (root == null || root.isEmpty) continue;
      final normalizedRoot = p.normalize(root);
      if (p.equals(normalizedRoot, target)) {
        return (source: source, relPath: '');
      }
      if (p.isWithin(normalizedRoot, target)) {
        final rel = p.split(p.relative(target, from: normalizedRoot)).join('/');
        return (source: source, relPath: rel);
      }
    }
    return null;
  }

  /// 保证从源根到 [relPath] 这一路的目录行都在（缺的补占位行，已有的一个字不动）。
  ///
  /// 常用目录卡片、浏览页都按目录行取名字、计数和封面；一个从没被扫到过的深层目录
  /// 直接加进常用目录的话，首页那张卡查不到行。占位行 `probed_at` 为 NULL，
  /// 于是它「不知道里面有什么，先显示着」，点进去就会触发目录级扫描。
  void ensureFolderChain({
    required LocalMediaSource source,
    required String relPath,
  }) {
    final root = source.path;
    if (root == null || root.isEmpty || relPath.isEmpty) return;
    final segments = relPath.split('/');
    final stubs = <LocalMediaFolder>[];
    for (var i = 1; i <= segments.length; i++) {
      final rel = segments.take(i).join('/');
      final name = segments[i - 1];
      stubs.add(
        LocalMediaFolder(
          id: LocalMediaFolder.buildId(source.id, rel),
          sourceId: source.id,
          relPath: rel,
          parentRelPath: i == 1 ? '' : segments.take(i - 1).join('/'),
          name: name,
          sortName: naturalSortKey(name),
          folderPath: p.normalize(
            p.joinAll(<String>[root, ...segments.take(i)]),
          ),
        ),
      );
    }
    upsertFolderStubs(stubs);
  }

  /// 给绝对路径补一个尾部分隔符，供前缀比较用。
  ///
  /// ⛔ **不能写死 `/`**。这里比的是 `local_media_sources.path` /
  /// `local_media_items.folder_path`，存的都是**平台原样**的绝对路径——Windows
  /// 上是 `C:\a\b`。补成 `C:\a\b/` 的话：
  /// - [findOverlappingSource] 的三个比较一个都不成立 → 重叠源检测在 Windows
  ///   上等于从不生效；
  /// - [markMissingExcept] 的 `substr(folder_path, 1, ?) <> ?` 永远成立 →
  ///   「读不到的子树」豁免不掉，整棵被标 missing。
  ///
  /// 只有 `rel_path` 那一族是归一化过的（`relPathOf` 强制成 `/`），那边不走这里。
  static String _withTrailingSeparator(String path) {
    if (path.isEmpty) return path;
    if (path.endsWith('/') || path.endsWith('\\')) return path;
    // 路径自己用的是哪种分隔符就补哪种；一个都没有（单段）时用平台默认的。
    final backslash = path.lastIndexOf('\\');
    final slash = path.lastIndexOf('/');
    if (backslash > slash) return '$path\\';
    if (slash > backslash) return '$path/';
    return '$path${p.separator}';
  }

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
      // 目录树和常用目录必须跟着源一起走，而且必须在**同一个事务**里。
      //
      // 漏掉的话不是「多几行垃圾」这么轻：移除来源后常用目录那一排还在，点进去
      // 是一棵条目已经被删空的目录树——看着有目录、进去什么都没有。而且重新添加
      // 同一个文件夹会拿到新的 UUID 源 id，老行永远不会被复用或覆盖，只会一直攒着。
      _db.execute('DELETE FROM local_media_folders WHERE source_id = ?', [id]);
      _db.execute(
        'DELETE FROM local_media_pinned_folders WHERE source_id = ?',
        [id],
      );
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
  ///
  /// [underPath] 给了就只取这个绝对目录**及其子树**里的条目。目录级懒扫描每进一层
  /// 都要调一次，整源全读的话，五万条的源每次点进目录都要在主 isolate 上建一张
  /// 五万项的 Map（2026-09-13 排查）；而这一轮只可能碰到这棵子树里的文件。
  Map<String, LocalMediaFingerprint> fingerprints(
    String sourceId, {
    String? underPath,
  }) {
    final scope = _pathScopeClause('folder_path', underPath);
    final rows = _db.select(
      'SELECT path_hash, size_bytes, modified_at, duration_ms, width, height, '
      'sidecar_image_path, media_store_uri, missing, meta_probed_at '
      'FROM local_media_items WHERE source_id = ?${scope.sql}',
      <Object?>[sourceId, ...scope.args],
    );
    return <String, LocalMediaFingerprint>{
      for (final row in rows)
        row['path_hash'] as String: LocalMediaFingerprint(
          sizeBytes: row['size_bytes'] as int?,
          modifiedAt: row['modified_at'] as int?,
          durationMs: row['duration_ms'] as int?,
          width: row['width'] as int?,
          height: row['height'] as int?,
          sidecarImagePath: row['sidecar_image_path'] as String?,
          mediaStoreUri: row['media_store_uri'] as String?,
          missing: (row['missing'] as int? ?? 0) != 0,
          metaProbed: row['meta_probed_at'] != null,
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
      // 帧率与「探测过帧率」同样只对那一个文件版本成立，换了文件就得重探。
      'fps',
      'fps_probed_at',
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
      // 「探测过了」跟着它说的那个文件版本走：换了文件就得重探。
      'meta_probed_at = CASE WHEN $changed THEN NULL '
          'ELSE local_media_items.meta_probed_at END',
      // ⛔ 必须和上面 thumb_path 同一条件归零：thumb_path 被清空后若这个标还留着 1，
      // 下一张**自动**抽出来的帧会被当成用户挑的，从此压过 sidecar。
      'thumb_is_custom = CASE WHEN $changed THEN 0 '
          'ELSE local_media_items.thumb_is_custom END',
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
      _inChunks<String>([for (final item in items) item.id], (marks, chunk) {
        _db.execute(
          'UPDATE local_media_items SET last_played_at = '
          '(SELECT updated_at FROM local_media_progress WHERE item_id = local_media_items.id) '
          'WHERE id IN ($marks)',
          chunk,
        );
      });
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
    final replaced = <String>[];
    _inChunks<String>(incoming.keys.toList(), (marks, chunk) {
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
    });
    if (replaced.isEmpty) return;
    _inChunks<String>(replaced, (marks, chunk) {
      _db.execute(
        'DELETE FROM local_media_progress WHERE item_id IN ($marks)',
        chunk,
      );
    });
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
  ///
  /// ⛔ [excludeFolderTrees] 是这一轮**确实没能走进去**的目录（权限、坏道、Windows
  /// 超长路径）。这几棵子树连同底下的一切都被排除在收敛之外——没看到不等于不存在。
  /// 有了它，一个读不动的子目录就不会再一票否决整个源的收敛。
  ///
  /// ⛔ 反过来写成「只收敛走到过的目录」是**错的**，虽然直觉上更自然：用户把某个
  /// 文件夹整个删掉时，它既不在失败清单里、也不会出现在走到过的清单里（父目录已经
  /// 列不出它了），于是那一整个目录的条目永远收敛不掉，在墙上留下一堆点不开的幽灵
  /// 卡片。「排除没看到的」才覆盖得住这一种。
  int markMissingExcept(
    String sourceId,
    Set<String> seenHashes, {
    Iterable<String>? excludeFolderTrees,
  }) {
    final excluded = <String>[
      for (final folder in excludeFolderTrees ?? const <String>[])
        if (folder.trim().isNotEmpty) folder,
    ];
    // 每棵被排除的子树 = 它自己 + 它底下的一切。
    //
    // 前缀比较用 `substr` 而不是 `LIKE`：目录名里的 `%` 和 `_` 在 LIKE 里是通配符，
    // 得转义——而转义正是这类代码最容易漏的地方，漏了就是静默地少排除或多排除。
    final exclusionSql = <String>[];
    final exclusionParams = <Object?>[];
    for (final folder in excluded) {
      // ⛔ 走 [_withTrailingSeparator]，别就地写 `'$folder/'`：Windows 上
      // `folder_path` 是反斜杠的，拼出来的前缀永远匹配不上。
      final prefix = _withTrailingSeparator(folder);
      exclusionSql.add(
        '(folder_path IS NULL OR '
        '(folder_path <> ? AND substr(folder_path, 1, ?) <> ?))',
      );
      exclusionParams
        ..add(folder)
        ..add(prefix.runes.length)
        ..add(prefix);
    }
    final exclusion = exclusionSql.isEmpty
        ? ''
        : ' AND ${exclusionSql.join(' AND ')}';

    // 返回这一轮**真的翻了状态**的行数（0↔1 两个方向加起来）。
    final changed = _convergeMissing(
      table: 'local_media_items',
      keyColumn: 'path_hash',
      sourceId: sourceId,
      seenKeys: seenHashes,
      markExtraSql: exclusion,
      markExtraParams: exclusionParams,
      errorLabel: '收敛 missing 标记失败',
    );
    if (changed > 0) notifyChanged();
    return changed;
  }

  /// seen 键的临时表。连接级 TEMP，一张表反复用，每次收敛完清空。
  static const String _seenKeysTable = 'temp.lm_seen_keys';

  /// 「范围」键的临时表（目录级收敛里那串列过的目录）。
  static const String _scopeKeysTable = 'temp.lm_scope_keys';

  /// 往临时键表里批量灌一批键（预编译语句逐条插，不走 IN 分片）。
  void _fillKeysTable(String table, Iterable<String> keys) {
    _db.execute(
      'CREATE TABLE IF NOT EXISTS $table(k TEXT PRIMARY KEY) WITHOUT ROWID',
    );
    _db.execute('DELETE FROM $table');
    final insert = _db.prepare('INSERT OR IGNORE INTO $table(k) VALUES (?)');
    try {
      for (final key in keys) {
        insert.execute(<Object?>[key]);
      }
    } finally {
      insert.close();
    }
  }

  /// 四个 missing 收敛方法共用的实现：条目与目录只差表名、键列和「标记范围」。
  ///
  /// # ⛔ 为什么不再「整源置 1、再按 IN 洗回 0」
  ///
  /// 那种写法每一行都要写两次，而条目表挂着二十来棵索引树、`missing` 又在几乎每一棵
  /// 里——29k 行的源一次全量收敛实测 7 秒，全落在主 isolate 上，而真正变了的通常
  /// 只有几行。现在两条 UPDATE 都只碰**状态确实要翻**的行：
  ///
  /// - `SET missing = 1`：范围内、当前为 0、键**不在** seen 里（外加 [markExtraSql]）；
  /// - `SET missing = 0`：整源内、当前为 1、键**在** seen 里。
  ///
  /// 最终状态与旧写法逐行相同（旧写法的洗回那步同样不受 [markExtraSql] 约束）。
  /// seen 键先进 TEMP 表（有主键），`IN (SELECT …)` 走主键查找，也不再受 999 变量上限。
  ///
  /// [scopeKeys] 非 null 时，标记那一步额外要求 `scopeColumn IN (scopeKeys)`。
  int _convergeMissing({
    required String table,
    required String keyColumn,
    required String sourceId,
    required Iterable<String> seenKeys,
    String markExtraSql = '',
    List<Object?> markExtraParams = const <Object?>[],
    String? scopeColumn,
    Iterable<String>? scopeKeys,
    required String errorLabel,
  }) {
    var changed = 0;
    _db.execute('BEGIN');
    try {
      _fillKeysTable(_seenKeysTable, seenKeys);
      var scopeSql = '';
      if (scopeColumn != null && scopeKeys != null) {
        _fillKeysTable(_scopeKeysTable, scopeKeys);
        scopeSql = ' AND $scopeColumn IN (SELECT k FROM $_scopeKeysTable)';
      }
      _db.execute(
        'UPDATE $table SET missing = 1 '
        'WHERE source_id = ? AND missing = 0$scopeSql '
        'AND $keyColumn NOT IN (SELECT k FROM $_seenKeysTable)$markExtraSql',
        <Object?>[sourceId, ...markExtraParams],
      );
      changed += _db.updatedRows;
      _db.execute(
        'UPDATE $table SET missing = 0 '
        'WHERE source_id = ? AND missing = 1 '
        'AND $keyColumn IN (SELECT k FROM $_seenKeysTable)',
        <Object?>[sourceId],
      );
      changed += _db.updatedRows;
      _db.execute('DELETE FROM $_seenKeysTable');
      if (scopeSql.isNotEmpty) _db.execute('DELETE FROM $_scopeKeysTable');
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e(errorLabel, tag: _tag, error: e);
      rethrow;
    }
    return changed;
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
    _db.execute('BEGIN');
    try {
      _inChunks<String>(pathToNewId.keys.toList(), chunkSize: 200, (
        marks,
        chunk,
      ) {
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
      });
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('迁移本地条目记忆失败', tag: _tag, error: e);
      // ⛔ 不能吞成 `return 0`：调用方紧接着就 upsertItems，而那一步会按旧指纹
      // 清陈旧进度——认亲没搬成还照常往下写，旧 id 上的进度就成了孤儿，而日志里
      // 看起来只是「搬了 0 条」。抛出去让这一批停下，交给下一次同步重来。
      rethrow;
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
  Set<String> pathsOfSource(String sourceId, {String? underPath}) {
    final scope = _pathScopeClause('folder_path', underPath);
    // ⛔ `missing = 0` 不能省：所有权是一份**活的**主张，不是墓碑。带上已经
    // missing 的行的话，「已下载」里那条早就没了的记录会永远把这个路径挡在
    // 目录扫描外面——文件明明躺在一个被扫的目录里，却再也没有任何源认领它。
    final rows = _db.select(
      'SELECT path FROM local_media_items WHERE source_id = ? AND missing = 0'
      '${scope.sql}',
      <Object?>[sourceId, ...scope.args],
    );
    return <String>{for (final row in rows) row['path'] as String};
  }

  /// 「这个绝对目录或它底下」的 WHERE 片段。[underPath] 为空时不加限制。
  ///
  /// 前缀比较必须带尾分隔符，否则 `/a/b` 会把 `/a/bc` 也算进来；分隔符的取法见
  /// [_withTrailingSeparator]（Windows 上不能写死 `/`）。
  static ({String sql, List<Object?> args}) _pathScopeClause(
    String column,
    String? underPath,
  ) {
    if (underPath == null || underPath.isEmpty) {
      return (sql: '', args: const <Object?>[]);
    }
    final exact = p.normalize(underPath);
    final prefix = _withTrailingSeparator(exact);
    // 「以 prefix 打头」＝ `[prefix, 上界)` 这段 BINARY 序区间，上界是把末尾那个
    // 分隔符换成码点 +1 的字符（`/`→`0`、`\`→`]`）。分隔符是 ASCII，不会撞上代理对。
    final sep = prefix.codeUnitAt(prefix.length - 1);
    final upper =
        prefix.substring(0, prefix.length - 1) + String.fromCharCode(sep + 1);
    return (
      // ⛔ 写成「外层区间 + 残余 OR」，不写成 `= ? OR (>= ? AND < ?)`。
      //
      // 旧写法 `substr(col, 1, ?) = ?` 是函数调用，任何索引都用不上；而裸 OR 形状
      // SQLite 也不肯拆，EXPLAIN 只剩 `USING INDEX …(source_id=?)`，照样把整源
      // 逐行比一遍。外层 `[exact, upper)` 能直接落到
      // `(source_id, folder_path, …)` 的区间搜索上；区间里夹着的 `exact` 与 `prefix`
      // 之间那几行（`/a/b.bak`、`/a/b-x` 这类同前缀兄弟）由残余条件滤掉。
      sql:
          ' AND ($column >= ? AND $column < ? '
          'AND ($column = ? OR $column >= ?))',
      args: <Object?>[exact, upper, exact, prefix],
    );
  }

  /// 这些路径里哪些已经有别的源认领了。只问 [paths] 这一批。
  ///
  /// 旧版把全库其它源的活路径整个读进一张 Set（全表 SCAN），而调用方手上其实只有
  /// 这一轮扫到的那几百个路径。这里分片 `path IN (…)`，走 `idx_local_items_path`。
  /// ⛔ 必须带 `missing = 0`，理由同 [pathsOfSource]：所有权是一份**活的**主张，不是墓碑。
  Set<String> pathsOwnedElsewhereAmong(
    String sourceId,
    Iterable<String> paths,
  ) {
    final result = <String>{};
    final list = paths.toSet().toList();
    _inChunks<String>(list, (marks, chunk) {
      final rows = _db.select(
        'SELECT path FROM local_media_items '
        'WHERE path IN ($marks) AND source_id != ? AND missing = 0',
        <Object?>[...chunk, sourceId],
      );
      for (final row in rows) {
        result.add(row['path'] as String);
      }
    });
    return result;
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

  /// 这个下载任务落盘的那个文件，在本地库里是哪一条。
  ///
  /// # ⛔ 一个已下载的文件只能有**一把进度钥匙**
  ///
  /// 观看进度按 `local_media_items.id` 存（`local_media_progress`）。同一个已下载
  /// 的视频有两个入口——「本机文件 › 下载完成视频」那张墙，和下载列表里的条目
  /// ——而下载列表那头手上只有 `DownloadTask`，2026-09-11 之前它就直接传 null
  /// 过去了。后果不是"少记一次"，是**两套进度各记各的，其中一套还只写不读**：
  /// 下载列表那条路把进度按 Iwara videoId 写进 `video_playback_history`，而本地
  /// 播放器的续播只问 `local_media_progress`（`_resolveLocalLibraryResumePosition`），
  /// 从下载列表点开永远从头放，用户在另一栏里明明看得见进度条。
  ///
  /// 所以下载列表那条路也要先来这儿换一把同样的钥匙，见
  /// `video_download_task_item_widget._playLocalVideo`。
  ///
  /// 查不到就答 null（同步服务还没跑到、任务行是历史脏数据），调用方照旧退回
  /// 「这一次没有续播」——比拿一把错钥匙去写别人的进度强。
  LocalMediaItem? getItemByDownloadTaskId(String taskId) {
    if (taskId.isEmpty) return null;
    final rows = _db.select(
      'SELECT * FROM local_media_items WHERE download_task_id = ? LIMIT 1',
      [taskId],
    );
    if (rows.isEmpty) return null;
    return LocalMediaItem.fromRow(rows.first);
  }

  /// Writes only successful content derivations for the exact file version
  /// that was inspected. A late result for a replaced or missing file is
  /// discarded by the fingerprint predicates.
  bool updateDerivedFields({
    required String itemId,
    required int? expectedSizeBytes,
    required int? expectedModifiedAt,
    int? durationMs,
    int? width,
    int? height,
    double? fps,
    bool fpsProbed = false,
    String? thumbPath,
    String? vrFormatJson,
    // 非 null 才写：自动抽帧的调用方不传，不会把用户挑的标误清。
    bool? thumbIsCustom,
  }) {
    if (expectedSizeBytes == null || expectedModifiedAt == null) return false;

    final assignments = <String>[];
    final values = <Object?>[];
    void add(String column, Object? value) {
      if (value == null) return;
      assignments.add('$column = ?');
      values.add(value);
    }

    add('duration_ms', durationMs);
    add('width', width);
    add('height', height);
    add('fps', fps);
    // ⛔ 「探测过了」必须能在**没读出值**时也落库——这正是它存在的理由。
    // 走 add() 的话 null 会被跳过，容器不写帧率的文件就永远标不上，每次冷启动
    // 重新排队白开一次 Player。所以单独写，不经过那道 null 过滤。
    if (fpsProbed) {
      assignments.add('fps_probed_at = ?');
      values.add(DateTime.now().millisecondsSinceEpoch);
    }
    add('thumb_path', thumbPath);
    add('vr_format_json', vrFormatJson);
    if (thumbIsCustom != null) add('thumb_is_custom', thumbIsCustom ? 1 : 0);
    if (assignments.isEmpty) return false;

    values.addAll(<Object?>[itemId, expectedSizeBytes, expectedModifiedAt]);
    _db.execute(
      'UPDATE local_media_items SET ${assignments.join(', ')} '
      'WHERE id = ? AND missing = 0 AND size_bytes IS ? AND modified_at IS ?',
      values,
    );
    final updated = _db.updatedRows > 0;
    // ⛔ 派生字段是行内变化，绝不能发全局 notifyChanged()！
    // 发全局 changeRevision 会让卡片墙走 refresh(true)，在用户滚动时清空列表并弹回顶部；
    // 需要重绘的调用方自己就地 setState。
    return updated;
  }

  /// 记下「这一条的时长/宽高探测过了」，不论探没探出值。
  ///
  /// 与 `fps_probed_at` 同一个理由：探不出元数据的文件只靠内存负缓存挡，冷启动一清零
  /// 就要重新排队开 Player。指纹变了时 [upsertItems] 会把它清回 NULL。
  /// 行内变化，不发信号（同 [updateDerivedFields]）。
  void markMetaProbed(String itemId) {
    _db.execute(
      'UPDATE local_media_items SET meta_probed_at = ? WHERE id = ?',
      <Object?>[DateTime.now().millisecondsSinceEpoch, itemId],
    );
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
    var affected = 0;
    _db.execute('BEGIN');
    try {
      _inChunks<String>(itemIds, (marks, chunk) {
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
      });
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('设置本地条目分类失败', tag: _tag, error: e);
      rethrow;
    }
    return affected;
  }

  /// [queryItems] / [itemPathsPage] / [countItems] 三边共用的 FROM 之后、ORDER BY
  /// 之前那一段（含前导空格与 `WHERE`）。「三边同口径」从此由这一处代码保证，不再靠
  /// 三份手抄的 WHERE 互相对齐。
  ///
  /// # ⛔ 目录内查询必须钉 `INDEXED BY idx_local_items_folder_kind_sort`
  ///
  /// 带 `folder_path` 时 SQLite 默认挑的是**排序序**的分页索引
  /// （`(kind, source_id, missing, <排序列>, …)`）：它以为顺着排序扫、凑够 LIMIT 就停
  /// 很划算，实际上要沿着整个源的排序序一路扫、逐行回表比 `folder_path`——30 条的
  /// 目录实测 58~152ms。钉到 `(source_id, folder_path, kind, missing, sort_name, name, id)`
  /// 上是直接定位到这一层的几十行，非名称档再 TEMP B-TREE 排这几十行，约 3ms。
  ///
  /// 只在 `sourceId` 也给了时才钉：索引以 `source_id` 打头，缺它就只剩整棵索引扫。
  static ({String sql, List<Object?> params}) _itemFilter({
    required String? sourceId,
    required LocalMediaItemKind kind,
    required String? folderPath,
    required String? categoryId,
    required bool includeMissing,
    required bool favoritedOnly,
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
    _addCategoryFilter(categoryId, where, params);
    if (!includeMissing) where.add('missing = 0');
    if (favoritedOnly) where.add('favorited_at IS NOT NULL');
    final indexed = sourceId != null && folderPath != null
        ? ' INDEXED BY idx_local_items_folder_kind_sort'
        : '';
    return (sql: '$indexed WHERE ${where.join(' AND ')}', params: params);
  }

  /// 分页查条目。列表永远走这里，**不整表进内存**。
  List<LocalMediaItem> queryItems({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    LocalMediaSort sort = LocalMediaSort.addedDesc,
    LocalMediaOrder? order,
    String? folderPath,
    String? categoryId,
    bool includeMissing = false,
    bool favoritedOnly = false,
    required int offset,
    required int limit,
  }) {
    final filter = _itemFilter(
      sourceId: sourceId,
      kind: kind,
      folderPath: folderPath,
      categoryId: categoryId,
      includeMissing: includeMissing,
      favoritedOnly: favoritedOnly,
    );
    final orderBy = order != null ? _orderByClause(order) : _orderBy(sort);
    final rows = _db.select(
      'SELECT * FROM local_media_items${filter.sql} '
      'ORDER BY $orderBy LIMIT ? OFFSET ?',
      <Object?>[...filter.params, limit, offset],
    );
    return rows.map(LocalMediaItem.fromRow).toList();
  }

  /// 只取 `id` + `path` 的轻量版 [queryItems]。
  ///
  /// # ⛔ 为什么要单独有它
  ///
  /// 大图页收的是**整个目录**那一叠图（它自己左右翻页），所以取数不能像池那样
  /// 一页 32 条——但也不该为此把上千行整行读出来再各建一个 [LocalMediaItem]：
  /// sqlite3 是同步 API，这一下全落在点击那一帧的 UI 线程上。这里只读两列。
  ///
  /// ⛔ 筛选与排序口径必须和 [queryItems] 一一对应（同 [countItems] 那条）：
  /// 两边一旦分头改，大图页开出来的顺序就和抽屉里数的对不上——不报错，只是
  /// "点第 3 条开在第 7 张"。
  List<({String id, String path})> itemPathsPage({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    LocalMediaSort sort = LocalMediaSort.addedDesc,
    // ⛔ [order] 和 [favoritedOnly] 不是可选的门面：[queryItems] 里 `order`
    // **优先于** `sort`。以前这两个参数在签名上不存在，调用方传了也只是编译不过
    // ——但视频墙已经在给池传 `order` 了，图片墙接上同一条路的那天就会当场错位，
    // 而且编译器一句话都不会说。
    LocalMediaOrder? order,
    String? folderPath,
    String? categoryId,
    bool includeMissing = false,
    bool favoritedOnly = false,
    required int limit,
  }) {
    final filter = _itemFilter(
      sourceId: sourceId,
      kind: kind,
      folderPath: folderPath,
      categoryId: categoryId,
      includeMissing: includeMissing,
      favoritedOnly: favoritedOnly,
    );
    final orderBy = order != null ? _orderByClause(order) : _orderBy(sort);
    final rows = _db.select(
      'SELECT id, path FROM local_media_items${filter.sql} '
      'ORDER BY $orderBy LIMIT ?',
      <Object?>[...filter.params, limit],
    );
    return [
      for (final row in rows)
        (id: row['id'] as String, path: row['path'] as String),
    ];
  }

  /// ⛔ 筛选口径必须和 [queryItems] 保持一一对应。
  ///
  /// 这两个方法并列摆着、只差一个参数时，下一个人拿 [countItems] 给目录页做总数
  /// 会**静默**拿到整个源的数字——不报错、不越界，就是数字不对，而且要等用户
  /// 数着卡片来发现。加参数时两边一起加。
  int countItems({
    String? sourceId,
    LocalMediaItemKind kind = LocalMediaItemKind.video,
    String? folderPath,
    String? categoryId,
    bool includeMissing = false,
    bool favoritedOnly = false,
  }) {
    final filter = _itemFilter(
      sourceId: sourceId,
      kind: kind,
      folderPath: folderPath,
      categoryId: categoryId,
      includeMissing: includeMissing,
      favoritedOnly: favoritedOnly,
    );
    final rows = _db.select(
      'SELECT COUNT(*) AS c FROM local_media_items${filter.sql}',
      filter.params,
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  /// 这一层里那些文件加起来占多少字节（`folder_path` 精确匹配，**不含子目录**）。
  ///
  /// ⛔ 口径必须与 [countItems] 一致：卡片上写「128 个视频」、信息弹窗里写
  /// 「共 12 GB」，两个数说的得是同一批文件，否则用户会以为哪个数算错了。
  /// 所以这里同样按 `folder_path` 精确匹配、同样滤掉 `missing`，而不是按路径
  /// 前缀把整棵子树加起来。
  ///
  /// `size_bytes` 可空（MediaStore 句柄、还没探到的行），`SUM` 会自动跳过；
  /// 一行都没有时 `SUM` 返回 NULL，这里折成 0。
  int sumItemBytes({String? sourceId, String? folderPath}) {
    final where = <String>['missing = 0'];
    final params = <Object?>[];
    if (sourceId != null) {
      where.add('source_id = ?');
      params.add(sourceId);
    }
    if (folderPath != null) {
      where.add('folder_path = ?');
      params.add(folderPath);
    }
    final rows = _db.select(
      'SELECT SUM(size_bytes) AS s FROM local_media_items '
      'WHERE ${where.join(' AND ')}',
      params,
    );
    return (rows.first['s'] as int?) ?? 0;
  }

  // ── 精选 ────────────────────────────────────────────────────────────────

  /// 标记 / 取消标记「精选」。[favorited] 为 true 时写入当前时间戳。
  ///
  /// ⛔ **不发全局信号**，同 [updateDerivedFields]。在「所有视频」里给一张卡片加个
  /// 星只是那一行的角标变了，发 [changeRevision] 会把整墙清空重拉、用户滚动位置
  /// 当场丢失——为一个角标付这个代价荒谬。
  ///
  /// 需要重绘的调用方自己就地处理；只有「精选视频」那一页取消精选才是真正的集合
  /// 变化（那一条要从列表里消失），由那一页自己决定怎么收拾。
  /// ⛔ 只有视频能被精选，见 [LocalMediaItem.supportsFavorite]。这条 `kind` 判据
  /// 写在 SQL 里而不是靠调用方自觉：菜单那边已经不出这一条了，但把不变量钉在**写
  /// 入口**上，以后不管谁调，图片都标不上——标上了就是一份哪儿都显示不出来的死状态。
  bool setItemFavorited({required String itemId, required bool favorited}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      "UPDATE local_media_items SET favorited_at = ? WHERE id = ? AND kind = 'video'",
      [favorited ? now : null, itemId],
    );
    return _db.updatedRows > 0;
  }

  /// 这一条现在是不是精选。
  bool isItemFavorited(String itemId) {
    final rows = _db.select(
      'SELECT favorited_at FROM local_media_items WHERE id = ?',
      [itemId],
    );
    if (rows.isEmpty) return false;
    return rows.first['favorited_at'] != null;
  }

  /// 精选条目数（按 kind 分）。
  int countFavorited({LocalMediaItemKind kind = LocalMediaItemKind.video}) {
    final rows = _db.select(
      'SELECT COUNT(*) AS c FROM local_media_items WHERE kind = ? AND missing = 0 AND favorited_at IS NOT NULL',
      [kind.name],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  // ── 失效标记 ────────────────────────────────────────────────────────────

  /// 把这一批条目标成「已失效」（文件在系统里被删掉/移走了）。
  ///
  /// 现有的 [markMissingExcept] 只在整轮扫描收敛时才跑得到，用户在系统里删掉
  /// 一个文件之后、下次扫描之前，列表里那一格一直是活的，点下去才发现没了。
  /// 这个方法让上层在翻到某一页时就地把失效的那几条落库。
  ///
  /// [notify] 为 false 时不发 [changeRevision]：调用方正在就地把这几格从当前页里
  /// 摘掉，再发全局信号就是让整墙清空重拉、滚动位置归零（同 [updateDerivedFields]
  /// 那条纪律）。
  int markItemsMissing(List<String> itemIds, {bool notify = true}) {
    if (itemIds.isEmpty) return 0;
    var totalUpdated = 0;
    _db.execute('BEGIN');
    try {
      _inChunks<String>(itemIds, (marks, chunk) {
        _db.execute(
          'UPDATE local_media_items SET missing = 1 '
          'WHERE missing = 0 AND id IN ($marks)',
          chunk,
        );
        totalUpdated += _db.updatedRows;
      });
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('标记条目失效失败', tag: _tag, error: e);
      rethrow;
    }
    if (notify && totalUpdated > 0) {
      notifyChanged();
    }
    return totalUpdated;
  }

  /// 排序表达式。
  ///
  /// ⛔ 每一档都要带一个**唯一的兜底列**（这里是 `id`）：分页靠 OFFSET，排序不稳定
  /// 时同一条会在两页里各出现一次、另一条则一次都不出现——表现是"往下翻着翻着
  /// 少了几个、又重复了几个"，很难查。
  ///
  /// 保持与既有调用兼容的薄封装，内部统一委托给 [_orderByClause]。
  static String _orderBy(LocalMediaSort sort) => _orderByClause(sort.order);

  /// 统一的 ORDER BY SQL 生成逻辑。
  ///
  /// # 规则与约束
  /// 1. 同一条 ORDER BY 里所有列方向必须一致（全 ASC 或全 DESC），兜底列跟着主字段方向走，
  ///    以吃满 SQLite 的索引反向扫描特性，避免静默退化为临时 B 树（`USE TEMP B-TREE FOR ORDER BY`）。
  /// 2. NULL 永远排在最后：DESC 时裸列天然将 NULL 排在最后；ASC 时可空字段添加 `(col IS NULL) ASC` 前缀。
  /// 3. NOT NULL 或实际非空字段（name, folder, fileType, added）不加 `IS NULL` 前缀，
  ///    避免破坏索引直查。
  ///
  /// # ⛔ 升序那几档的 `USE TEMP B-TREE` 是量过之后有意留下的，别再来"优化"
  ///
  /// 带 `(col IS NULL)` 前缀的升序档吃不到索引，`EXPLAIN QUERY PLAN` 里会显示
  /// `USE TEMP B-TREE FOR ORDER BY`。这看着刺眼，但实测过：5 万行的表上，
  ///
  /// - 降序（裸列，索引反扫）：约 0.0003 ms
  /// - 升序（临时 B 树）：约 2.4 ms
  /// - 升序 + `OFFSET 10000` 深翻页：约 5.3 ms
  ///
  /// 折到中端安卓上按最坏 5 倍算也就一帧左右。要彻底消掉它，得为每个可空字段
  /// 再建一条 `((col IS NULL), col, sort_name, id)` 表达式索引，索引数从 9 条涨到
  /// 16 条——扫描时每插一行都要多维护 7 棵树，大库全量扫描的代价远大于这几毫秒。
  ///
  /// 所以：**这里不是漏建索引，是权衡过的**。真要改，先拿真实库量一遍再说。
  static String _orderByClause(LocalMediaOrder order) {
    final asc = order.ascending;
    return switch (order.field) {
      // 名称档：name 与 sort_name 均为 NOT NULL，不加 IS NULL 前缀；
      // sort_name 折叠前导零，二次排序用 name，兜底列 id 保持同向。
      LocalMediaSortField.name =>
        asc
            ? 'sort_name ASC, name ASC, id ASC'
            : 'sort_name DESC, name DESC, id DESC',

      // 修改时间：modified_at 可空；ASC 添加 (modified_at IS NULL) ASC 确保未知排最后；
      // DESC 裸列对齐 idx_local_items_all_modified 索引。
      LocalMediaSortField.modified =>
        asc
            ? '(modified_at IS NULL) ASC, modified_at ASC, sort_name ASC, id ASC'
            : 'modified_at DESC, sort_name DESC, id DESC',

      // 时长：duration_ms 可空（图片和未探测视频为 NULL）；ASC 添加 (duration_ms IS NULL) ASC 确保未知排最后；
      // DESC 裸列走 idx_local_items_all_duration 索引。
      LocalMediaSortField.duration =>
        asc
            ? '(duration_ms IS NULL) ASC, duration_ms ASC, sort_name ASC, id ASC'
            : 'duration_ms DESC, sort_name DESC, id DESC',

      // 大小：size_bytes 可空；ASC 添加 (size_bytes IS NULL) ASC 确保未知排最后；
      // DESC 裸列走 idx_local_items_all_size 索引。
      LocalMediaSortField.size =>
        asc
            ? '(size_bytes IS NULL) ASC, size_bytes ASC, sort_name ASC, id ASC'
            : 'size_bytes DESC, sort_name DESC, id DESC',

      // 分辨率：(width * height) 可空；ASC 添加 ((width * height) IS NULL) ASC 确保未知排最后；
      // DESC 裸列走表达式索引 idx_local_items_all_pixels。
      LocalMediaSortField.resolution =>
        asc
            ? '((width * height) IS NULL) ASC, (width * height) ASC, sort_name ASC, id ASC'
            : '(width * height) DESC, sort_name DESC, id DESC',

      // 文件类型：ext 视为实际非空，不加 IS NULL 前缀，全列同向走 idx_local_items_all_ext 索引。
      LocalMediaSortField.fileType =>
        asc
            ? 'ext ASC, sort_name ASC, id ASC'
            : 'ext DESC, sort_name DESC, id DESC',

      // 帧率：fps 可空（图片和未探测视频为 NULL）；ASC 添加 (fps IS NULL) ASC 确保未知排最后；
      // DESC 裸列走 idx_local_items_all_fps 索引。
      LocalMediaSortField.fps =>
        asc
            ? '(fps IS NULL) ASC, fps ASC, sort_name ASC, id ASC'
            : 'fps DESC, sort_name DESC, id DESC',

      // 文件夹：folder_path 视为非空，不加 IS NULL 前缀；保留与原版层级一致的细分列，兜底同向。
      LocalMediaSortField.folder =>
        asc
            ? 'folder_path ASC, sort_name ASC, name ASC, id ASC'
            : 'folder_path DESC, sort_name DESC, name DESC, id DESC',

      // 添加时间：added_at 在 DDL 中明确定义为 NOT NULL，不加 IS NULL 前缀，全列同向走 idx_local_items_all_added 索引。
      LocalMediaSortField.added =>
        asc ? 'added_at ASC, id ASC' : 'added_at DESC, id DESC',

      // 最近播放：last_played_at 可空；ASC 添加 (last_played_at IS NULL) ASC 确保未播排最后；
      // DESC 裸列走 idx_local_items_all_played 索引。
      LocalMediaSortField.played =>
        asc
            ? '(last_played_at IS NULL) ASC, last_played_at ASC, sort_name ASC, id ASC'
            : 'last_played_at DESC, sort_name DESC, id DESC',

      // 精选标记：favorited_at 可空；ASC 添加 (favorited_at IS NULL) ASC 确保未收藏排最后；
      // DESC 裸列对齐 idx_local_items_all_favorited 索引。
      LocalMediaSortField.favorited =>
        asc
            ? '(favorited_at IS NULL) ASC, favorited_at ASC, id ASC'
            : 'favorited_at DESC, id DESC',
    };
  }

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
    _inChunks<String>(itemIds, (marks, chunk) {
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
    });
    return result;
  }

  /// 落一次播放进度，顺带把 `last_played_at` 记到条目上（「最近播放」那一档
  /// 靠它走索引排序，见 migration v29）。
  ///
  /// ⛔ **这里不发 [notifyChanged]**。播放期间这个方法每 5 秒被调一次，而
  /// `changeRevision` 会让卡片墙走 `refresh(true)`——清空列表、重拉第 0 页、
  /// 滚动位置归零。用户从播放器退回墙上时会发现自己被弹回了顶部。
  ///
  /// 代价是「最近播放」的排序不会在你眼皮底下自己重排：刚看完的那一条要等下一次
  /// 自然刷新（下拉刷新 / 重新进页面）才跳到最前面。这是**故意的**——在用户
  /// 手指底下重排列表比排序慢一拍更糟。
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

  // ── 目录实体 ────────────────────────────────────────────────────────────

  /// 查询某目录下的直接子目录。
  ///
  /// # ⛔ 默认藏掉"空叶子"
  ///
  /// 真实设备上的 `Download` 底下躺着几百个哈希命名的缓存目录，一个媒体文件都没有、
  /// 也没有下级——不藏的话整个首屏全是它们，真正有内容的目录被挤到看不见的地方。
  /// 这三个计数都为 0 意味着"点进去只会看到『这个文件夹是空的』"，对一个**媒体**
  /// 浏览器来说它就是不存在。
  ///
  /// 覆盖不到的一种：本身有子目录、但子目录全是空叶子的目录，`child_folder_count`
  /// 不为 0 所以留在列表里，点进去才发现是空的。要根治得在 [backfillFolderCounts]
  /// 里算"子树里有没有媒体"并向上传播，代价比收益大，先按一层算。
  ///
  /// ⛔ 这三列由 [backfillFolderCounts] 在扫描收尾时才写。扫描进行中它们都是 0，
  /// 此刻查会一个子目录都返回不了——这是**过渡态**，扫完那一下就对了。
  ///
  /// [mediaKind] 收窄"非空"的口径：给了它就只看那一种媒体的计数列（视频菜单里
  /// 一个只有图片的目录点进去是死路一条，反之亦然）。不给则沿用"有任何媒体就算
  /// 数"的原口径——目录浏览页要的是全部。
  ///
  /// ⛔ 它只挡得住**叶子**：`child_folder_count` 不分媒体类型，所以"子树里全是
  /// 图片"的目录在视频口径下仍会留在列表里。根治同样要在 [backfillFolderCounts]
  /// 里按 kind 各传播一次，代价比收益大。
  List<LocalMediaFolder> childFolders({
    required String sourceId,
    required String parentRelPath,
    bool includeMissing = false,
    bool includeEmpty = false,
    LocalMediaItemKind? mediaKind,
  }) {
    final where = <String>['source_id = ?', 'parent_rel_path = ?'];
    final params = <Object?>[sourceId, parentRelPath];
    if (!includeMissing) {
      where.add('missing = 0');
    }
    if (!includeEmpty && mediaKind != null) {
      final column = mediaKind == LocalMediaItemKind.image
          ? 'image_count'
          : 'video_count';
      where.add('($column > 0 OR child_folder_count > 0 OR probed_at IS NULL)');
    } else if (!includeEmpty) {
      // 写成对索引友好的残余过滤：前导列还是 source_id / parent_rel_path /
      // missing，索引照样能顺着 sort_name 走，不会退回 TEMP B-TREE。
      //
      // ⛔ `probed_at IS NULL` 这一项不能省。懒扫描下三个计数全 0 有两种含义：
      // 「探过、真的空」和「还没探过、不知道」。少了它，用户点进一个还没走到的
      // 目录会看到一片空白——里面明明有东西。见 v33 迁移。
      where.add(
        '(video_count > 0 OR image_count > 0 OR child_folder_count > 0 '
        'OR probed_at IS NULL)',
      );
    }
    final rows = _db.select(
      'SELECT * FROM local_media_folders '
      'WHERE ${where.join(' AND ')} '
      'ORDER BY sort_name ASC, name ASC, id ASC',
      params,
    );
    return rows.map(LocalMediaFolder.fromRow).toList();
  }

  /// 获取指定目录。
  LocalMediaFolder? getFolder({
    required String sourceId,
    required String relPath,
  }) {
    final rows = _db.select(
      'SELECT * FROM local_media_folders '
      'WHERE source_id = ? AND rel_path = ? LIMIT 1',
      [sourceId, relPath],
    );
    if (rows.isEmpty) return null;
    return LocalMediaFolder.fromRow(rows.first);
  }

  /// 从源根到该目录的面包屑链，含两端，按层级顺序。
  ///
  /// ⛔ 不走递归查询，直接切开 relPath 拼出各级相对路径，一条 WHERE rel_path IN (...) 查回。
  List<LocalMediaFolder> breadcrumb({
    required String sourceId,
    required String relPath,
  }) {
    final normalized = relPath.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    final paths = <String>[''];
    if (normalized.isNotEmpty) {
      final segments = normalized.split('/');
      var current = '';
      for (final seg in segments) {
        if (seg.isEmpty) continue;
        current = current.isEmpty ? seg : '$current/$seg';
        paths.add(current);
      }
    }

    final marks = List.filled(paths.length, '?').join(', ');
    final rows = _db.select(
      'SELECT * FROM local_media_folders '
      'WHERE source_id = ? AND rel_path IN ($marks)',
      <Object?>[sourceId, ...paths],
    );

    final map = <String, LocalMediaFolder>{
      for (final row in rows)
        (row['rel_path'] as String): LocalMediaFolder.fromRow(row),
    };

    final result = <LocalMediaFolder>[];
    for (final p in paths) {
      final folder = map[p];
      if (folder != null) {
        result.add(folder);
      }
    }
    return result;
  }

  /// 统计某目录下的直接有效子目录数。
  int childFolderCount({
    required String sourceId,
    required String parentRelPath,
  }) {
    final rows = _db.select(
      'SELECT COUNT(*) AS c FROM local_media_folders '
      'WHERE source_id = ? AND parent_rel_path = ? AND missing = 0',
      [sourceId, parentRelPath],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  /// 这几列**不归扫描器管**，upsert 冲突时一律保留库里原值。
  ///
  /// ⛔ 三个计数列：扫描器构造 [LocalMediaFolder] 时它们都是默认的 0，照盖的话
  /// 每次重扫都会先把全库目录的计数清零，直到扫完回填才恢复——扫一个大目录要
  /// 几十秒，这几十秒里用户看到的是满屏「0 视频 · 0 图」。计数的主人只有一个，
  /// 就是 [backfillFolderCounts]。
  ///
  /// ⛔ `probed_at` 同理，而且后果更重：它的主人是 [markFoldersProbed]，扫描器
  /// 构造出来的值永远是 null。跟着盖的话，**每次扫描都会把沿途所有目录重新变回
  /// 「没探过」**，于是空目录再也藏不住——第一屏又变回两千个灰块。
  static const Set<String> _folderPreservedColumns = <String>{
    'video_count',
    'image_count',
    'child_folder_count',
    'probed_at',
    // 「这张封面是谁挑的」只有 [setFolderCover] 说了算，扫描器构造出来永远是 false。
    'cover_pinned',
  };

  /// 批量 upsert 目录。
  void upsertFolders(List<LocalMediaFolder> folders) {
    if (folders.isEmpty) return;
    final firstRow = folders.first.toRow();
    final columns = firstRow.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final assignments = columns
        .where((c) => c != 'id' && !_folderPreservedColumns.contains(c))
        .map((c) {
          // ⛔ 用户自己挑过的封面，扫描器不许覆盖。
          //
          // 不能简单地把 cover_path 也放进 [_folderPreservedColumns]：那样扫描器
          // **永远**改不了封面，目录里的内容都换完了封面还是第一次扫到的那张。
          // 判据是「谁挑的」，所以只能写成条件更新。
          if (c == 'cover_path') {
            // ⛔ 扫描器算不出封面时（excluded 为 NULL）必须保留库里已有的那张。
            //
            // 扫描器只认目录直属的图片文件，纯视频目录它永远算出 NULL。而这类
            // 目录的封面是事后由派生服务回填的（视频缩略图 / 借子目录）。不写
            // 这一条的话，用户每做一次全量扫描，所有靠回填得来的封面就被抹光
            // 一次，然后再慢慢长回来——封面凭空消失是比没有封面更糟的观感。
            return 'cover_path = CASE '
                'WHEN local_media_folders.cover_pinned = 1 '
                'THEN local_media_folders.cover_path '
                'WHEN excluded.cover_path IS NULL '
                'THEN local_media_folders.cover_path '
                'ELSE excluded.cover_path END';
          }
          // ⛔ 这个标必须和 cover_path **逐分支**同步，否则两列会说不同的话。
          //
          // 扫描器构造出来的 folder 恒为 false（它只会从直属图片挑封面，那是第 2
          // 档、不是借的）。可它算不出封面时上面那条 CASE 保留的是**旧封面**——
          // 若旧封面是借来的，标却被这一轮盖成 0，第 3 档就再也认不出它可以换，
          // 借来的图从此钉死。所以 cover_path 保留时它也保留，cover_path 真被
          // 直属图片覆盖时它才归 0。
          if (c == 'cover_borrowed') {
            return 'cover_borrowed = CASE '
                'WHEN local_media_folders.cover_pinned = 1 '
                'THEN local_media_folders.cover_borrowed '
                'WHEN excluded.cover_path IS NULL '
                'THEN local_media_folders.cover_borrowed '
                'ELSE 0 END';
          }
          return '$c = excluded.$c';
        })
        .join(', ');
    final statement = _db.prepare(
      'INSERT INTO local_media_folders (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $assignments',
    );
    var changed = 0;
    _db.execute('BEGIN');
    try {
      for (final folder in folders) {
        final row = folder.toRow();
        statement.execute(columns.map((c) => row[c]).toList());
        changed += _db.updatedRows;
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('批量 upsert 本地媒体目录失败', tag: _tag, error: e);
      rethrow;
    } finally {
      statement.close();
    }
    // 目录行的事，发目录信号（分工见 [folderRevision]）。
    if (changed > 0) notifyFolderChanged();
  }

  /// 收敛目录的 missing 标记。
  ///
  /// 口径与 [markMissingExcept] 完全一致：本轮没遍历到的置 missing = 1，遍历到的洗回 0，
  /// [excludeRelPathTrees] 中的子树整棵豁免。返回真的翻了状态的行数。
  int markFoldersMissingExcept(
    String sourceId,
    Set<String> seenRelPaths, {
    Set<String> excludeRelPathTrees = const {},
  }) {
    final excluded = <String>[
      for (final tree in excludeRelPathTrees)
        if (tree.trim().isNotEmpty) tree.trim(),
    ];
    final exclusionSql = <String>[];
    final exclusionParams = <Object?>[];
    for (final tree in excluded) {
      // ⛔ 这里**可以**写死 `/`，[markMissingExcept] 那边不行——两条长得一样，
      // 差别全在比的是哪一列：这里是 `rel_path`（`relPathOf` 已强制归一成 `/`，
      // 见 `LocalMediaScanService`），那边是 `folder_path`（平台原样的绝对路径，
      // Windows 上是反斜杠）。照抄这一行到绝对路径上就是静默失效。
      final prefix = tree.endsWith('/') ? tree : '$tree/';
      exclusionSql.add('(rel_path <> ? AND substr(rel_path, 1, ?) <> ?)');
      exclusionParams
        ..add(tree)
        ..add(prefix.runes.length)
        ..add(prefix);
    }
    final exclusion = exclusionSql.isEmpty
        ? ''
        : ' AND ${exclusionSql.join(' AND ')}';

    final changed = _convergeMissing(
      table: 'local_media_folders',
      keyColumn: 'rel_path',
      sourceId: sourceId,
      seenKeys: seenRelPaths,
      markExtraSql: exclusion,
      markExtraParams: exclusionParams,
      errorLabel: '收敛本地媒体目录 missing 标记失败',
    );
    if (changed > 0) notifyFolderChanged();
    return changed;
  }

  /// 从库里删掉这些条目，连同它们的观看进度。
  ///
  /// # ⛔ 这个方法**不动磁盘上的文件**
  ///
  /// 删文件是调用方的事（`File.delete()`），而且必须**先删文件、成功了再删库行**。
  /// 反过来的话，文件删失败（只读卷、权限没了、正被别的进程占着）你已经把行删了，
  /// 结果是：磁盘上东西还在，库里没有，用户在应用里再也看不到它、也删不掉它——
  /// 只能等下一次扫描把它重新收进来，而目录源不会自己重扫。
  ///
  /// 反过来「文件删了、库行没删掉」是可以自愈的：那一行会在下一次扫这一层时被
  /// 收敛成 missing。所以顺序只有一种是对的。
  int deleteItems(List<String> ids) {
    if (ids.isEmpty) return 0;
    var removed = 0;
    _db.execute('BEGIN');
    try {
      _inChunks<String>(ids, (marks, chunk) {
        _db.execute(
          'DELETE FROM local_media_progress WHERE item_id IN ($marks)',
          chunk,
        );
        _db.execute(
          'DELETE FROM local_media_items WHERE id IN ($marks)',
          chunk,
        );
        removed += _db.updatedRows;
      });
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('删除本地条目失败', tag: _tag, error: e);
      rethrow;
    }
    if (removed > 0) notifyChanged();
    return removed;
  }

  /// 只是「知道有这么个目录」的占位行：**有则不动，无则插入**。
  ///
  /// 懒扫描走到深度尽头时，对那些不再往下走的子目录只发一条占位记录——我们知道
  /// 它存在，但没列过它，不知道里面有什么（`probed_at` 因此保持 NULL）。
  ///
  /// # ⛔ 为什么不能走 [upsertFolders]
  ///
  /// 那个方法冲突时会把 `cover_path` / `modified_at` 一起盖成 excluded 的值，而
  /// 占位记录这两个字段都是 null。于是会出这么一档事：用户进了 C 目录（C 被列过，
  /// 学到了封面），退回上一级再进来，C 又以占位身份被写一遍，**封面当场被抹掉**。
  /// 上下翻几次目录，卡片上的封面就掉光了。
  void upsertFolderStubs(List<LocalMediaFolder> folders) {
    if (folders.isEmpty) return;
    final columns = folders.first.toRow().keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final statement = _db.prepare(
      'INSERT INTO local_media_folders (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO NOTHING',
    );
    var inserted = 0;
    _db.execute('BEGIN');
    try {
      for (final folder in folders) {
        final row = folder.toRow();
        statement.execute(columns.map((c) => row[c]).toList());
        // `DO NOTHING` 撞上已有行时 changes() 为 0，只数真插进去的。
        inserted += _db.updatedRows;
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('插入本地媒体目录占位行失败', tag: _tag, error: e);
      rethrow;
    } finally {
      statement.close();
    }
    // ⛔ 懒扫描每进一层都会把沿途子目录再发一遍占位，绝大多数早就在库里。无条件
    // 发信号的话，每次点进目录首页与浏览页都要整个重查一遍。
    if (inserted > 0) notifyFolderChanged();
  }

  /// 把 [coverPath] 定成这个目录的封面，并记下「是用户挑的」。
  ///
  /// 之后扫描器再怎么重扫都不会把它换掉（见 [upsertFolders] 里那段 CASE）。
  bool setFolderCover({
    required String sourceId,
    required String relPath,
    required String coverPath,
  }) {
    _db.execute(
      'UPDATE local_media_folders '
      'SET cover_path = ?, cover_pinned = 1, cover_borrowed = 0 '
      'WHERE source_id = ? AND rel_path = ?',
      <Object?>[coverPath, sourceId, relPath],
    );
    final ok = _db.updatedRows > 0;
    if (ok) {
      // 上面几级若挂着从这里借走的旧图，跟着换。
      if (relPath.isNotEmpty) {
        propagateFolderCovers(
          sourceId: sourceId,
          relPaths: <String>[_parentRelPathOf(relPath)],
        );
      }
      notifyFolderChanged();
    }
    return ok;
  }

  /// 当目录未固定封面且当前无封面时，借用该目录直属首个有缩略图的视频的缩略图作为目录封面。
  ///
  /// 解决纯视频目录下因缺少独立图片而长期无封面的问题。
  bool backfillFolderCoverFromItems({
    required String sourceId,
    required String relPath,
  }) {
    _db.execute(
      '''
      WITH candidate AS (
        SELECT i.thumb_path FROM local_media_items i
        WHERE i.source_id = ?
          AND i.folder_path = (SELECT f.folder_path FROM local_media_folders f
                               WHERE f.source_id = ? AND f.rel_path = ?)
          AND i.kind = 'video' AND i.missing = 0
          AND i.thumb_path IS NOT NULL AND i.thumb_path != ''
        ORDER BY i.sort_name ASC, i.name ASC, i.id ASC LIMIT 1
      )
      UPDATE local_media_folders
      SET cover_path = (SELECT thumb_path FROM candidate), cover_borrowed = 0
      WHERE source_id = ? AND rel_path = ? AND cover_pinned = 0
        AND (cover_path IS NULL OR cover_path = '' OR cover_borrowed = 1)
        AND (SELECT thumb_path FROM candidate) IS NOT NULL
      ''',
      <Object?>[sourceId, sourceId, relPath, sourceId, relPath],
    );
    final ok = _db.updatedRows > 0;
    if (ok) notifyFolderChanged();
    return ok;
  }

  /// 让 [relPaths] 以及它们的**全部祖先**按「借子目录封面」重算一遍，自深向浅。
  ///
  /// # ⛔ 为什么必须收口成这一个方法（2026-09-13 用户报：A 里只有 B，B 有封面、A 永远没有）
  ///
  /// 封面有三个写入口：扫描器（直属图片 / sidecar）、派生服务（视频缩略图）、
  /// 用户手动挑。以前只有派生服务那一个口子会往上冒泡，于是：
  /// - B 的封面来自**直属图片或 sidecar**（下载器目录的常态）→ 扫描器写完就走，A 永远空着；
  /// - B 的视频缩略图**早就生成过** → 这一轮没有新缩略图，冒泡那段根本不跑；
  /// - 进出 A 多少次都一样：扫描器对 A 算出 NULL，而没有任何一处去问 B。
  ///
  /// 现在扫描收尾、派生回填、手动设 / 清封面都走这里，而且它是**幂等**的修复：
  /// 库里已经坏掉的那些目录，用户进一次那一层（或它的父目录）就会被补上。
  ///
  /// # 规则（四层降级的第 4 档：借排序最靠前、有封面的直接子目录）
  ///
  /// - 借来的封面要打标（`cover_borrowed = 1`）。这一档**最低**却往往**最先**落地
  ///   （子目录的直属图片扫描器一眼看见，本目录视频的缩略图要等卡片滚进视野），
  ///   不打标的话 [backfillFolderCoverFromItems]（第 3 档）认不出「这张是借的，可以换」。
  /// - 借来的封面遇到子目录封面换了会**跟着换**，否则 B 被用户换了封面，A 还挂着旧图；
  ///   子目录一张封面都没有了（删空 / 整个没了）就**清掉**，不留一张指向旧文件的图。
  /// - 第 2/3 档（`cover_borrowed = 0`）与手动封面（`cover_pinned = 1`）一概不碰。
  /// - `folder_path IS NULL` 的源根（「已下载」「设备视频」）不清：它们借的是整个
  ///   来源里的图（[backfillSourceRootCoverFromItems]），本来就没有子目录可比。
  ///
  /// 自深向浅一趟就够：处理某一级时，它的孩子这一轮已经算过了。
  void propagateFolderCovers({
    required String sourceId,
    required Iterable<String> relPaths,
  }) {
    final targets = <String>{};
    for (final relPath in relPaths) {
      var current = relPath;
      while (targets.add(current)) {
        if (current.isEmpty) break;
        final index = current.lastIndexOf('/');
        current = index < 0 ? '' : current.substring(0, index);
      }
    }
    if (targets.isEmpty) return;
    final ordered = targets.toList()
      ..sort((a, b) => _relPathDepth(b).compareTo(_relPathDepth(a)));

    final statement = _db.prepare('''
      WITH candidate AS (
        SELECT c.cover_path FROM local_media_folders c
        WHERE c.source_id = ?1 AND c.parent_rel_path = ?2
          AND c.missing = 0 AND c.cover_path IS NOT NULL AND c.cover_path != ''
        ORDER BY c.sort_name ASC, c.rel_path ASC LIMIT 1
      )
      UPDATE local_media_folders
      SET cover_path = (SELECT cover_path FROM candidate), cover_borrowed = 1
      WHERE source_id = ?1 AND rel_path = ?2 AND cover_pinned = 0
        AND (SELECT cover_path FROM candidate) IS NOT NULL
        AND (cover_path IS NULL OR cover_path = ''
             OR (cover_borrowed = 1
                 AND cover_path <> (SELECT cover_path FROM candidate)))
    ''');
    final clearStatement = _db.prepare('''
      UPDATE local_media_folders SET cover_path = NULL, cover_borrowed = 0
      WHERE source_id = ?1 AND rel_path = ?2 AND cover_pinned = 0
        AND cover_borrowed = 1 AND folder_path IS NOT NULL
        AND NOT EXISTS (
          SELECT 1 FROM local_media_folders c
          WHERE c.source_id = ?1 AND c.parent_rel_path = ?2
            AND c.missing = 0 AND c.cover_path IS NOT NULL AND c.cover_path != ''
        )
    ''');
    var changed = 0;
    _db.execute('BEGIN');
    try {
      for (final relPath in ordered) {
        statement.execute(<Object?>[sourceId, relPath]);
        changed += _db.updatedRows;
        clearStatement.execute(<Object?>[sourceId, relPath]);
        changed += _db.updatedRows;
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('向上传播目录封面失败', tag: _tag, error: e);
      return;
    } finally {
      statement.close();
      clearStatement.close();
    }
    // 一整趟只发一次：逐行发的话，一次全量扫描就是上万次 folderRevision。
    if (changed > 0) notifyFolderChanged();
  }

  /// 把 [cover_pinned] 置 0 且 [cover_path] 置 NULL，供用户恢复自动封面时使用。
  ///
  /// ⛔ 清完必须**当场**重跑一遍自动降级。只清不填的话，用户点「恢复自动封面」
  /// 看到的是卡片当场退化成灰色文件夹图标，要等下次重扫该目录、或等某个视频
  /// 恰好生成缩略图才长回来——用户会以为这个菜单项是「删除封面」。
  bool clearFolderCoverPin({
    required String sourceId,
    required String relPath,
  }) {
    _db.execute(
      'UPDATE local_media_folders '
      'SET cover_pinned = 0, cover_path = NULL, cover_borrowed = 0 '
      'WHERE source_id = ? AND rel_path = ?',
      <Object?>[sourceId, relPath],
    );
    final ok = _db.updatedRows > 0;
    if (!ok) return false;
    // 按声明的优先级重来一遍：直属视频缩略图（第 3 档）优先于借用子目录（第 4 档）。
    // 第 2 档（直属图片）归扫描器管，这里够不着，下次扫描会顶上来。
    // 第 4 档连同祖先一起走 [propagateFolderCovers]：上面几级借的可能正是刚清掉的那张。
    backfillFolderCoverFromItems(sourceId: sourceId, relPath: relPath);
    propagateFolderCovers(sourceId: sourceId, relPaths: <String>[relPath]);
    notifyFolderChanged();
    return true;
  }

  /// `'a/b'` → `'a'`；`'a'` → `''`。rel_path 恒为 `/` 分隔，不能用 `p.dirname`。
  static String _parentRelPathOf(String relPath) {
    final index = relPath.lastIndexOf('/');
    return index < 0 ? '' : relPath.substring(0, index);
  }

  /// 批量筛出「未 pin 封面且当前没有封面」的目录，返回 rel_path → 绝对路径。
  ///
  /// ⛔ 扫描服务每收到一批目录就要判一次这件事。一批一批地 [getFolder] 点查
  /// 等于几千次同步 select 全压在主 isolate 上（`kMaxFolderCoverDerivationEnqueuedPerScan`
  /// 只封顶入队数，封不住点查次数）。这里一条 IN 查询解决。
  ///
  /// 值是库里的 `folder_path`，**可能是空串**：调用方那边手上还有刚扫出来的
  /// 绝对路径可以兜底，所以这里不把这种行滤掉——滤掉的话调用方分不清是"已经
  /// 有封面了"还是"库里那一列恰好空着"。
  Map<String, String> foldersNeedingCover({
    required String sourceId,
    required List<String> relPaths,
  }) {
    if (relPaths.isEmpty) return const <String, String>{};
    final result = <String, String>{};
    // SQLite 的变量上限是 999，分片查。
    _inChunks<String>(relPaths, (marks, chunk) {
      final rows = _db.select(
        'SELECT rel_path, folder_path FROM local_media_folders '
        'WHERE source_id = ? AND rel_path IN ($marks) '
        '  AND cover_pinned = 0 '
        '  AND (cover_path IS NULL OR cover_path = \'\')',
        <Object?>[sourceId, ...chunk],
      );
      for (final row in rows) {
        final rel = row['rel_path'] as String?;
        if (rel == null) continue;
        result[rel] = (row['folder_path'] as String?) ?? '';
      }
    });
    return result;
  }

  /// 返回该目录直属的、尚未生成缩略图且没有同名 sidecar 图片的首个视频条目。
  ///
  /// 供扫描服务在发现纯视频目录无封面时，选出"封面代表"送入派生队列。
  LocalMediaItem? firstVideoNeedingThumbInFolder({
    required String sourceId,
    required String folderPath,
  }) {
    final rows = _db.select(
      'SELECT * FROM local_media_items '
      'WHERE source_id = ? AND folder_path = ? '
      '  AND kind = ? AND missing = 0 '
      '  AND (thumb_path IS NULL OR thumb_path = \'\') '
      '  AND (sidecar_image_path IS NULL OR sidecar_image_path = \'\') '
      'ORDER BY sort_name ASC, name ASC, id ASC LIMIT 1',
      <Object?>[sourceId, folderPath, LocalMediaItemKind.video.name],
    );
    if (rows.isEmpty) return null;
    return LocalMediaItem.fromRow(rows.first);
  }

  /// 返回该目录直属的可用封面图候选路径。
  ///
  /// 图片取自身 [path]，视频按 [_videoCoverOf]（手动指定 > sidecar > 自动抽帧）。
  /// 仅限未缺失条目，去重后最多返回 [limit] 条。
  ///
  /// ⛔ [limit] 必须落在 SQL 里，不能只在 Dart 那侧的循环里 break——调用方
  /// （封面选择弹窗）是在 `initState` 里同步跑的，几千张图的目录会把那一帧
  /// 整个卡住。同理 `ORDER BY` 的三列必须有索引兜底，否则 SQLite 退回
  /// TEMP B-TREE 全排，加了 LIMIT 也还是要先排完整张表（见 v38）。
  ///
  /// 「取不出候选的行」（既无 sidecar 又无 thumb 的视频）在 SQL 里就滤掉，
  /// 这样 LIMIT 的每一行都真的产出一个候选，不会出现「取够 60 行但一个候选
  /// 都没有」。
  List<String> folderCoverCandidates({
    required String sourceId,
    required String folderPath,
    int limit = 60,
  }) {
    final rows = _db.select(
      'SELECT kind, path, sidecar_image_path, thumb_path, thumb_is_custom '
      'FROM local_media_items '
      'WHERE source_id = ? AND folder_path = ? AND missing = 0 '
      '  AND (kind = ? '
      '       OR (sidecar_image_path IS NOT NULL AND sidecar_image_path <> \'\') '
      '       OR (thumb_path IS NOT NULL AND thumb_path <> \'\')) '
      'ORDER BY sort_name ASC, name ASC, id ASC '
      'LIMIT ?',
      <Object?>[sourceId, folderPath, LocalMediaItemKind.image.name, limit],
    );
    final result = <String>[];
    final seen = <String>{};
    for (final row in rows) {
      final kind = row['kind'] as String?;
      String? candidate;
      if (kind == LocalMediaItemKind.image.name || kind == 'image') {
        candidate = row['path'] as String?;
      } else if (kind == LocalMediaItemKind.video.name || kind == 'video') {
        candidate = _videoCoverOf(row);
      }
      if (candidate != null && candidate.isNotEmpty && seen.add(candidate)) {
        result.add(candidate);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  /// 给「没有真实目录树」的源（「已下载」「设备视频」）补上**源根那一行**目录记录。
  ///
  /// # 为什么它必须存在
  ///
  /// 封面、置顶、「设为封面 / 恢复自动封面」全都挂在 `local_media_folders` 上。
  /// 这两个源一行都不写，于是 [setFolderCover] 永远更新 0 行——用户在「已下载」
  /// 上既看不到自动封面，也**没有任何入口**手动挑一张（2026-09-11 用户报的）。
  ///
  /// # ⛔ 这一行的 `folder_path` 必须是 NULL
  ///
  /// 它是"源根"而不是"某个目录"：文件散在各个下载目录里。判断一个源是不是平的，
  /// 判据从此是**这一行有没有 folder_path**，不再是"查不查得到行"——调用点
  /// （目录浏览页、播放队列抽屉、目录信息弹窗）都按这个口径写。
  ///
  /// 计数每次调用都跟着更新，封面那几列一个字都不动（那是 [setFolderCover] 与
  /// [backfillSourceRootCoverFromItems] 的地盘）。
  void ensureSourceRootFolder({
    required String sourceId,
    required String displayName,
    required int videoCount,
    required int imageCount,
  }) {
    // ⛔ 没变化就一个字都不要写：这个方法每次同步、每条下载完成都会被调用，
    // 无脑 upsert 就是一次 `notifyFolderChanged()`，而那条信号会把首页的来源卡
    // 与常用目录整个重查一遍。
    final existing = getFolder(sourceId: sourceId, relPath: '');
    if (existing != null &&
        existing.name == displayName &&
        existing.videoCount == videoCount &&
        existing.imageCount == imageCount &&
        !existing.missing) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    _db.execute(
      'INSERT INTO local_media_folders '
      '(id, source_id, rel_path, parent_rel_path, name, sort_name, '
      ' folder_path, video_count, image_count, child_folder_count, '
      ' missing, probed_at) '
      'VALUES (?, ?, \'\', NULL, ?, ?, NULL, ?, ?, 0, 0, ?) '
      'ON CONFLICT(id) DO UPDATE SET '
      '  name = excluded.name, sort_name = excluded.sort_name, '
      '  video_count = excluded.video_count, '
      '  image_count = excluded.image_count, '
      '  missing = 0, probed_at = excluded.probed_at',
      <Object?>[
        LocalMediaFolder.buildId(sourceId, ''),
        sourceId,
        displayName,
        displayName.toLowerCase(),
        videoCount,
        imageCount,
        now,
      ],
    );
    notifyFolderChanged();
  }

  /// 用整个来源里最新的那张图回填**源根**的封面。
  ///
  /// [backfillFolderCoverFromItems] 按 `folder_path` 找候选，平的源没有那条路径，
  /// 于是永远回填不到。用户挑过的封面（`cover_pinned`）不动，自己借来的那张
  /// （`cover_borrowed`）可以换成更新的一张。
  bool backfillSourceRootCoverFromItems(String sourceId) {
    final candidates = sourceCoverCandidates(sourceId: sourceId, limit: 1);
    if (candidates.isEmpty) return false;
    _db.execute(
      'UPDATE local_media_folders '
      'SET cover_path = ?, cover_borrowed = 1 '
      'WHERE source_id = ? AND rel_path = \'\' AND cover_pinned = 0 '
      '  AND (cover_path IS NULL OR cover_path = \'\' OR cover_borrowed = 1) '
      '  AND (cover_path IS NULL OR cover_path <> ?)',
      <Object?>[candidates.first, sourceId, candidates.first],
    );
    final ok = _db.updatedRows > 0;
    if (ok) notifyFolderChanged();
    return ok;
  }

  /// 整个来源里能当封面的图，新的在前。
  ///
  /// # ⛔ 为什么不能沿用 [folderCoverCandidates]
  ///
  /// 那个按 `folder_path` 收口，前提是这个源有一棵真实的目录树。「已下载」没有
  /// （文件散在各个下载目录里，源根本身没有路径），「设备视频」也没有。于是这两个
  /// 源既选不出封面、也挑不了封面——用户看到的就是一张永远空着的夹子，右键菜单里
  /// 连「设为封面」都没有（2026-09-11 用户报的）。
  ///
  /// # ⛔ 判据是「有没有图」，不是「是不是最新那一条」
  ///
  /// 首页原先的兜底是"取最新的一个视频，用它的缩略图"。缩略图是**滚进视野才生成**
  /// 的（见 `LocalMediaDerivationService.enqueue` 的 `generateThumbnail`），最新那条
  /// 十有八九还没有——于是明明有几十条带图的条目，卡片照样空着。这里把「有图」写进
  /// WHERE，取的是**最新的有图的那一条**。
  List<String> sourceCoverCandidates({
    required String sourceId,
    int limit = 60,
  }) {
    // ⛔ 必须按 kind 分两条查，不能写成一条 `kind = ? OR 有图` 的 OR。
    // 本表的分页索引一律以 `kind` 打头（见 v36 迁移里那串 `idx_local_items_page_*`），
    // 不带 kind 的查询用不上任何一条，会退化成全表扫 + TEMP B-TREE 重排——数据量小时
    // 完全隐形，几千条之后就是每 400ms 一次的卡顿。分开查，两条都走
    // `(kind, source_id, missing, added_at, id)`，「有没有图」只是顺着索引扫的残余过滤，
    // 找到 LIMIT 条就停。
    List<Map<String, Object?>> pick(String kind, String extraWhere) => _db
        .select(
          'SELECT kind, path, sidecar_image_path, thumb_path, thumb_is_custom, '
          'added_at FROM local_media_items '
          'WHERE kind = ? AND source_id = ? AND missing = 0$extraWhere '
          // ⛔ 兜底列必须和主列同向：`added_at DESC, id ASC` 这种混向子句索引正反扫
          // 都给不出，SQLite 会在找到的每一段 added_at 相同的行上再 TEMP B-TREE 一次。
          'ORDER BY added_at DESC, id DESC '
          'LIMIT ?',
          <Object?>[kind, sourceId, limit],
        )
        .map((row) => <String, Object?>{for (final k in row.keys) k: row[k]})
        .toList();

    final rows =
        <Map<String, Object?>>[
          ...pick(
            LocalMediaItemKind.video.name,
            ' AND ((sidecar_image_path IS NOT NULL AND sidecar_image_path <> \'\') '
            'OR (thumb_path IS NOT NULL AND thumb_path <> \'\'))',
          ),
          ...pick(LocalMediaItemKind.image.name, ''),
        ]..sort((a, b) {
          final aAdded = (a['added_at'] as int?) ?? 0;
          final bAdded = (b['added_at'] as int?) ?? 0;
          return bAdded.compareTo(aAdded);
        });

    final result = <String>[];
    final seen = <String>{};
    for (final row in rows) {
      final kind = row['kind'] as String?;
      String? candidate;
      if (kind == LocalMediaItemKind.image.name || kind == 'image') {
        candidate = row['path'] as String?;
      } else {
        candidate = _videoCoverOf(row);
      }
      if (candidate != null && candidate.isNotEmpty && seen.add(candidate)) {
        result.add(candidate);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  /// 一行视频条目（至少带 `sidecar_image_path` / `thumb_path` / `thumb_is_custom`）
  /// 该拿哪张图当封面。
  ///
  /// ⛔ 优先级与 [LocalMediaItem.coverImagePath] 逐字一致：用户手动指定的缩略图 >
  /// 同名 sidecar > 自动抽的帧。少了第一档，用户挑的图会被下载器写的 sidecar 盖住。
  static String? _videoCoverOf(Map<String, Object?> row) {
    final thumb = row['thumb_path'] as String?;
    final custom = (row['thumb_is_custom'] as int? ?? 0) != 0;
    if (custom && thumb != null && thumb.isNotEmpty) return thumb;
    final sidecar = row['sidecar_image_path'] as String?;
    if (sidecar != null && sidecar.isNotEmpty) return sidecar;
    return thumb;
  }

  /// 按来源及绝对路径反查目录实体。
  LocalMediaFolder? findFolderByPath({
    required String sourceId,
    required String folderPath,
  }) {
    final rows = _db.select(
      'SELECT * FROM local_media_folders '
      'WHERE source_id = ? AND folder_path = ? LIMIT 1',
      <Object?>[sourceId, folderPath],
    );
    if (rows.isEmpty) return null;
    return LocalMediaFolder.fromRow(rows.first);
  }

  /// 把这一轮**真的把目录列出来看过**的那些目录标上探测时间。
  ///
  /// 只有这个方法和全量扫描收尾会写 `probed_at`。它的语义窄得刻意：不是"扫过这个
  /// 源"，是"我把这个目录 list 了一遍，所以它的直接内容我说得准"。见 v33 迁移。
  void markFoldersProbed({
    required String sourceId,
    required Iterable<String> relPaths,
    int? probedAt,
  }) {
    final paths = relPaths.toList();
    if (paths.isEmpty) return;
    final at = probedAt ?? DateTime.now().millisecondsSinceEpoch;
    var changed = 0;
    _db.execute('BEGIN');
    try {
      _inChunks<String>(paths, (marks, chunk) {
        _db.execute(
          'UPDATE local_media_folders SET probed_at = ? '
          'WHERE source_id = ? AND rel_path IN ($marks)',
          <Object?>[at, sourceId, ...chunk],
        );
        changed += _db.updatedRows;
      });
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('标记目录已探测失败', tag: _tag, error: e);
      rethrow;
    }
    // 探测时间是目录行的事，条目集合没变。
    if (changed > 0) notifyFolderChanged();
  }

  /// 目录级扫描收尾：**只在这一轮真的列过的目录里**收敛条目的 missing。
  ///
  /// # ⛔ 和整源的 [markMissingExcept] 不是同一件事，别混用
  ///
  /// 那个方法先把整源置 missing、再把见到的洗回来，靠的是"这一轮走遍了全树"。
  /// 懒扫描一轮只看了一层，用它就等于宣布"这个源里除了刚才那一层，其余全没了"
  /// ——整个库当场清空。
  ///
  /// 这里的口径是：`folder_path` 落在 [listedFolderPaths] 里的行才参与收敛，
  /// 范围外一行都不碰。所以"用户在文件管理器里删掉一个文件"能被收敛到（它的目录
  /// 这一轮列过了），而"还没走到的那半棵树"保持原样。
  int markItemsMissingExceptInFolders({
    required String sourceId,
    required Set<String> listedFolderPaths,
    required Set<String> seenHashes,
  }) {
    if (listedFolderPaths.isEmpty) return 0;
    // 返回真的翻了状态的行数（旧版只数了置 1 那一步，且把随后洗回 0 的也算了进去）。
    final changed = _convergeMissing(
      table: 'local_media_items',
      keyColumn: 'path_hash',
      sourceId: sourceId,
      seenKeys: seenHashes,
      scopeColumn: 'folder_path',
      scopeKeys: listedFolderPaths,
      errorLabel: '目录级收敛条目 missing 失败',
    );
    if (changed > 0) notifyChanged();
    return changed;
  }

  /// 目录级扫描收尾：只收敛 [listedRelPaths] 这些目录的**直接子目录**。
  ///
  /// 口径与 [markItemsMissingExceptInFolders] 一致——列过谁，才敢对谁的孩子下
  /// 结论。没列过的那些目录的孩子一行不碰。
  int markChildFoldersMissingExceptUnder({
    required String sourceId,
    required Set<String> listedRelPaths,
    required Set<String> seenRelPaths,
  }) {
    if (listedRelPaths.isEmpty) return 0;
    final changed = _convergeMissing(
      table: 'local_media_folders',
      keyColumn: 'rel_path',
      sourceId: sourceId,
      seenKeys: seenRelPaths,
      scopeColumn: 'parent_rel_path',
      scopeKeys: listedRelPaths,
      errorLabel: '目录级收敛目录 missing 失败',
    );
    if (changed > 0) notifyFolderChanged();
    return changed;
  }

  /// 删除某源下的全部目录。
  void deleteFoldersForSource(String sourceId) {
    _db.execute('DELETE FROM local_media_folders WHERE source_id = ?', [
      sourceId,
    ]);
    if (_db.updatedRows > 0) notifyFolderChanged();
  }

  /// `rel_path` 的层级：源根（空串）是 0，`a` 是 1，`a/b` 是 2。
  static int _relPathDepth(String relPath) =>
      relPath.isEmpty ? 0 : relPath.split('/').length;

  /// 扫完后一次性回填统计数：一条 GROUP BY 把 items 的直接子文件数灌进 folders。
  void backfillFolderCounts(String sourceId) {
    _db.execute('BEGIN');
    CommonPreparedStatement? updateStmt;
    var changed = 0;
    try {
      // 1. 条目计数：按 folder_path 和 kind 聚合直接子文件数
      final itemCountsRows = _db.select(
        'SELECT folder_path, kind, COUNT(*) AS c '
        'FROM local_media_items '
        'WHERE source_id = ? AND missing = 0 AND folder_path IS NOT NULL '
        'GROUP BY folder_path, kind',
        [sourceId],
      );

      final countsByFolderPath = <String, ({int video, int image})>{};
      for (final row in itemCountsRows) {
        final fp = row['folder_path'] as String;
        final kind = row['kind'] as String;
        final count = (row['c'] as int?) ?? 0;
        final current = countsByFolderPath[fp] ?? (video: 0, image: 0);
        if (kind == LocalMediaItemKind.video.name) {
          countsByFolderPath[fp] = (
            video: current.video + count,
            image: current.image,
          );
        } else if (kind == LocalMediaItemKind.image.name) {
          countsByFolderPath[fp] = (
            video: current.video,
            image: current.image + count,
          );
        }
      }

      // 2. 查出该源所有的 folder，在 Dart 侧按 folder_path / rel_path 对齐
      final folderRows = _db.select(
        'SELECT id, rel_path, parent_rel_path, folder_path, probed_at, '
        'video_count, image_count, child_folder_count '
        'FROM local_media_folders WHERE source_id = ? AND missing = 0',
        [sourceId],
      );

      final videoByRel = <String, int>{};
      final imageByRel = <String, int>{};
      final childrenByRel = <String, List<String>>{};
      final probedAtByRel = <String, int?>{};
      final storedByRel = <String, (int, int, int)>{};
      final allRelPaths = <String>[];
      for (final row in folderRows) {
        final relPath = (row['rel_path'] as String?) ?? '';
        final folderPath = row['folder_path'] as String?;
        final parentRel = row['parent_rel_path'] as String?;
        allRelPaths.add(relPath);
        probedAtByRel[relPath] = row['probed_at'] as int?;
        storedByRel[relPath] = (
          (row['video_count'] as int?) ?? 0,
          (row['image_count'] as int?) ?? 0,
          (row['child_folder_count'] as int?) ?? 0,
        );

        final itemCounts = folderPath != null
            ? countsByFolderPath[folderPath]
            : null;
        videoByRel[relPath] = itemCounts?.video ?? 0;
        imageByRel[relPath] = itemCounts?.image ?? 0;

        if (parentRel != null) {
          (childrenByRel[parentRel] ??= <String>[]).add(relPath);
        }
      }

      // 3. `child_folder_count` 只数**子树里真有东西**的子目录，自下而上算一遍。
      //
      // ⛔ 数全部子目录是不行的：`childFolders` 会把空目录挡在外面（见那边的
      // 注释），两边口径不一致就会出现「卡片上写着『2 个文件夹』，点进去说
      // 『这个文件夹是空的』」——同一屏上自相矛盾。
      //
      // 一个目录"有东西"的定义是递归的（自己有媒体，或者某个子目录有东西），
      // 所以按层级从深到浅算：算到某一层时，它的子目录都已经定好了。
      // 这样一整条只有空目录的链会从最深处一路判空上来，整条链都不再露面。
      final meaningfulChildCount = <String, int>{};
      final byDepthDesc = allRelPaths.toList()
        ..sort((a, b) => _relPathDepth(b).compareTo(_relPathDepth(a)));
      // ⛔ 没探过的目录一律算「有东西」。
      //
      // 这不是保守估计，是唯一正确的答案：懒扫描下它的三个计数是 0 只因为没人
      // 去看过，把它当空的就会在父目录里把它藏掉——用户从此点不进去，也就永远
      // 没机会去探它。口径必须和 [childFolders] 的残余过滤一字不差。
      bool hasAnything(String rel) =>
          probedAtByRel[rel] == null ||
          (videoByRel[rel] ?? 0) > 0 ||
          (imageByRel[rel] ?? 0) > 0 ||
          (meaningfulChildCount[rel] ?? 0) > 0;
      for (final relPath in byDepthDesc) {
        final children = childrenByRel[relPath];
        if (children == null) {
          meaningfulChildCount[relPath] = 0;
          continue;
        }
        meaningfulChildCount[relPath] = children.where(hasAnything).length;
      }

      updateStmt = _db.prepare(
        'UPDATE local_media_folders '
        'SET video_count = ?, image_count = ?, child_folder_count = ? '
        'WHERE source_id = ? AND rel_path = ?',
      );

      // ⛔ 只写**真的变了**的行。
      //
      // 懒扫描下这个方法每进一个目录就跑一次，而它遍历的是**整个源**的目录表。
      // 一个两千多个目录的源，无条件重写就是每次导航两千多条 UPDATE 落在主
      // isolate 上（sqlite3 是同步 API）。实际每次变的通常只有一两行。
      for (final relPath in allRelPaths) {
        final video = videoByRel[relPath] ?? 0;
        final image = imageByRel[relPath] ?? 0;
        final children = meaningfulChildCount[relPath] ?? 0;
        final stored = storedByRel[relPath];
        if (stored != null &&
            stored.$1 == video &&
            stored.$2 == image &&
            stored.$3 == children) {
          continue;
        }
        updateStmt.execute([video, image, children, sourceId, relPath]);
        changed += _db.updatedRows;
      }

      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('回填目录统计数失败', tag: _tag, error: e);
      rethrow;
    } finally {
      updateStmt?.close();
    }
    // 计数是目录行的事，条目集合没变。
    if (changed > 0) notifyFolderChanged();
  }

  /// [backfillFolderCounts] 的**目录级懒扫描**版：只重算这一轮列过的目录，
  /// 外加范围根的祖先链。
  ///
  /// # ⛔ 为什么不能每进一层都跑整源版
  ///
  /// 整源版要把整个源的条目 GROUP BY 一遍、把整张目录表读进 Dart 建五张 Map，
  /// 而懒扫描是**每进一个目录**就收尾一次。两万个目录的源上，那是每次点进去都在
  /// 主 isolate 同步分配几十 MB、卡上几百毫秒（2026-09-13 排查）。
  ///
  /// 一轮懒扫描真正可能改动计数的只有：列过的目录（它们的条目与子目录刚收敛过）
  /// 和它们的祖先（「子树里有没有东西」会一路往上传）。其余目录的计数在库里就是
  /// 对的，这里直接读库里的值当孩子的状态——口径与整源版、[childFolders] 一字不差：
  /// 没探过（`probed_at IS NULL`）算有东西。
  void backfillFolderCountsInScope({
    required String sourceId,
    required String scopeRelPath,
    required Set<String> listedRelPaths,
  }) {
    final listed = listedRelPaths.toList();
    _db.execute('BEGIN');
    CommonPreparedStatement? updateStmt;
    CommonPreparedStatement? childCountStmt;
    var changed = 0;
    try {
      // 1. 列过的目录：库里存的计数 + 绝对路径。
      final stored = <String, (int, int, int)>{};
      final relByFolderPath = <String, String>{};
      _inChunks<String>(listed, (marks, chunk) {
        final rows = _db.select(
          'SELECT rel_path, folder_path, video_count, image_count, '
          'child_folder_count FROM local_media_folders '
          'WHERE source_id = ? AND missing = 0 '
          'AND rel_path IN ($marks)',
          <Object?>[sourceId, ...chunk],
        );
        for (final row in rows) {
          final rel = (row['rel_path'] as String?) ?? '';
          stored[rel] = (
            (row['video_count'] as int?) ?? 0,
            (row['image_count'] as int?) ?? 0,
            (row['child_folder_count'] as int?) ?? 0,
          );
          final folderPath = row['folder_path'] as String?;
          if (folderPath != null && folderPath.isNotEmpty) {
            relByFolderPath[folderPath] = rel;
          }
        }
      });

      // 2. 列过的目录的直属条目数（走 idx_local_items_folder）。
      final video = <String, int>{};
      final image = <String, int>{};
      _inChunks<String>(relByFolderPath.keys.toList(), (marks, chunk) {
        final rows = _db.select(
          'SELECT folder_path, kind, COUNT(*) AS c FROM local_media_items '
          'WHERE source_id = ? AND missing = 0 '
          'AND folder_path IN ($marks) '
          'GROUP BY folder_path, kind',
          <Object?>[sourceId, ...chunk],
        );
        for (final row in rows) {
          final rel = relByFolderPath[row['folder_path'] as String];
          if (rel == null) continue;
          final count = (row['c'] as int?) ?? 0;
          final kind = row['kind'] as String?;
          if (kind == LocalMediaItemKind.video.name) {
            video[rel] = (video[rel] ?? 0) + count;
          } else if (kind == LocalMediaItemKind.image.name) {
            image[rel] = (image[rel] ?? 0) + count;
          }
        }
      });

      updateStmt = _db.prepare(
        'UPDATE local_media_folders '
        'SET video_count = ?, image_count = ?, child_folder_count = ? '
        'WHERE source_id = ? AND rel_path = ?',
      );

      // 3. 列过的目录按层级自深向浅：同一层的「有东西的子目录数」一条 GROUP BY 查完，
      // 写回之后上一层读到的就是新值。
      const hasAnything =
          '(probed_at IS NULL OR video_count > 0 OR image_count > 0 '
          'OR child_folder_count > 0)';
      final byDepth = <int, List<String>>{};
      for (final rel in stored.keys) {
        (byDepth[_relPathDepth(rel)] ??= <String>[]).add(rel);
      }
      final depths = byDepth.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final depth in depths) {
        final rels = byDepth[depth]!;
        final childCounts = <String, int>{};
        _inChunks<String>(rels, (marks, chunk) {
          final rows = _db.select(
            'SELECT parent_rel_path, COUNT(*) AS c FROM local_media_folders '
            'WHERE source_id = ? AND missing = 0 AND $hasAnything '
            'AND parent_rel_path IN ($marks) '
            'GROUP BY parent_rel_path',
            <Object?>[sourceId, ...chunk],
          );
          for (final row in rows) {
            childCounts[row['parent_rel_path'] as String] =
                (row['c'] as int?) ?? 0;
          }
        });
        for (final rel in rels) {
          final next = (
            video[rel] ?? 0,
            image[rel] ?? 0,
            childCounts[rel] ?? 0,
          );
          if (next == stored[rel]) continue;
          updateStmt.execute(<Object?>[
            next.$1,
            next.$2,
            next.$3,
            sourceId,
            rel,
          ]);
          changed++;
        }
      }

      // 4. 范围根的祖先：直属条目这一轮没动过，只有子目录数可能跟着变。
      childCountStmt = _db.prepare(
        'SELECT COUNT(*) AS c FROM local_media_folders '
        'WHERE source_id = ? AND parent_rel_path = ? AND missing = 0 '
        'AND $hasAnything',
      );
      var ancestor = scopeRelPath;
      while (ancestor.isNotEmpty) {
        ancestor = _parentRelPathOf(ancestor);
        final rows = childCountStmt.select(<Object?>[sourceId, ancestor]);
        final children = rows.isEmpty ? 0 : ((rows.first['c'] as int?) ?? 0);
        _db.execute(
          'UPDATE local_media_folders SET child_folder_count = ? '
          'WHERE source_id = ? AND rel_path = ? AND child_folder_count <> ?',
          <Object?>[children, sourceId, ancestor, children],
        );
        changed += _db.updatedRows;
      }

      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('回填目录统计数（目录级）失败', tag: _tag, error: e);
      rethrow;
    } finally {
      updateStmt?.close();
      childCountStmt?.close();
    }
    // 计数是目录行的事，条目集合没变。
    if (changed > 0) notifyFolderChanged();
  }

  // ── 常用目录 ────────────────────────────────────────────────────────────

  /// 获取常用目录列表，按 sort_order 升序、创建时间升序排列。
  List<LocalPinnedFolder> getPinnedFolders() {
    final rows = _db.select(
      'SELECT * FROM local_media_pinned_folders '
      'ORDER BY sort_order ASC, created_at ASC',
    );
    return rows.map(LocalPinnedFolder.fromRow).toList();
  }

  /// 检查指定相对路径目录是否已被置顶。
  bool isPinned({required String sourceId, required String relPath}) {
    final rows = _db.select(
      'SELECT 1 FROM local_media_pinned_folders '
      'WHERE source_id = ? AND rel_path = ? LIMIT 1',
      [sourceId, relPath],
    );
    return rows.isNotEmpty;
  }

  /// 置顶一个目录。
  void pinFolder(LocalPinnedFolder folder) {
    final row = folder.toRow();
    final columns = row.keys.toList();
    final placeholders = List.filled(columns.length, '?').join(', ');
    final assignments = columns
        .where((c) => c != 'id')
        .map((c) => '$c = excluded.$c')
        .join(', ');
    _db.execute(
      'INSERT INTO local_media_pinned_folders (${columns.join(', ')}) '
      'VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $assignments',
      columns.map((c) => row[c]).toList(),
    );
    if (_db.updatedRows > 0) notifyFolderChanged();
  }

  /// 取消置顶目录。
  void unpinFolder({required String sourceId, required String relPath}) {
    _db.execute(
      'DELETE FROM local_media_pinned_folders '
      'WHERE source_id = ? AND rel_path = ?',
      [sourceId, relPath],
    );
    if (_db.updatedRows > 0) notifyFolderChanged();
  }

  /// 重排常用目录。
  void reorderPinnedFolders(List<String> orderedIds) {
    if (orderedIds.isEmpty) return;
    _db.execute('BEGIN');
    CommonPreparedStatement? stmt;
    var changed = 0;
    try {
      // `sort_order <> ?`：顺序没动的行不算变化，拖回原位就一个信号都不发。
      stmt = _db.prepare(
        'UPDATE local_media_pinned_folders SET sort_order = ? '
        'WHERE id = ? AND sort_order IS NOT ?',
      );
      for (var i = 0; i < orderedIds.length; i++) {
        stmt.execute([i, orderedIds[i], i]);
        changed += _db.updatedRows;
      }
      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
      LogUtils.e('重排常用目录失败', tag: _tag, error: e);
      rethrow;
    } finally {
      stmt?.close();
    }
    if (changed > 0) notifyFolderChanged();
  }
}
