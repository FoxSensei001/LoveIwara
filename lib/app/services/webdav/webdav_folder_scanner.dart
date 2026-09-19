import 'dart:async';

import 'package:i_iwara/app/models/local_media/dav_path.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart'
    show kLocalVideoExtensions, kMaxScanFiles, kSidecarImageExtensions;
import 'package:i_iwara/app/services/local_media_directory_policy.dart';
import 'package:i_iwara/app/services/webdav/webdav_client.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';
import 'package:i_iwara/app/services/webdav/webdav_service.dart';
import 'package:i_iwara/app/utils/natural_sort_key.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// NAS 源的「进到这一层就重列一遍」：列目录 → 落库 → 按本地懒扫描**同一口径**收敛。
///
/// 语义对齐本地 `scanFolder`（`kLazyProbeDepth = 1`）：这一层的文件入库 + 每个
/// 直接子目录再列一次（子目录卡片的封面与计数靠这一层），孙目录只留占位行。
///
/// # 与本地扫描的差别
///
/// - **网络请求在任何闸门之外**：NAS 卡住不拖本地扫描。落库是同步的
///   （中间只在分批之间让帧），与本地扫描写的是不同的 source_id，互不干扰；同一
///   目录的并发请求合流成一个。
/// - **子目录重探看 mtime**：父目录的 PROPFIND 本来就带每个子目录的
///   `getlastmodified`。子目录已探过、mtime 没变就不再发请求，1+N 多数退化成 1。
///   mtime 缺失的实现退回「每次都探」。
/// - 目录封面此处一律不写：远端图片路径不能交给 `Image.file`，封面要等拉进本机
///   缓存之后由派生那一侧回填。
/// 列一个 NAS 目录（`dav:/…`）。失败抛 [WebDavFailure] / [WebDavUnavailable]。
typedef WebDavFolderLister =
    Future<List<DavEntry>> Function(LocalMediaSource source, String davFolder);

class WebDavFolderScanner {
  WebDavFolderScanner(this._repository, {WebDavFolderLister? lister})
    : _list = lister ?? WebDavService.instance.listFolder;

  final LocalMediaRepository _repository;
  final WebDavFolderLister _list;
  static const String _tag = 'WebDavFolderScanner';

  /// 一次最多探多少个子目录。再多的留作占位行，用户点进去时再列。
  static const int maxProbedChildren = 48;

  /// 子目录并发探测数。家用 NAS 的 WebDAV 服务并发能力很弱。
  static const int probeConcurrency = 2;

  static const int _batchSize = 300;

  final Map<String, Future<void>> _inFlight = {};

  /// 列一层。同一 (源, 目录) 的并发调用合流。失败不抛：源状态落库，由 UI 读。
  Future<void> scanFolder(LocalMediaSource source, String relPath) {
    final key = '${source.id}\u0000$relPath';
    // ⛔ 回调必须是块体、不返回值：`() => _inFlight.remove(key)` 会把 remove 的
    // 返回值（正是这个 future 自己）交给 whenComplete，而 whenComplete 要等回调
    // 返回的 future 完成——自己等自己，永远不完成（测试里实测卡死）。
    return _inFlight[key] ??= _scan(source, relPath).whenComplete(() {
      _inFlight.remove(key);
    });
  }

  Future<void> _scan(LocalMediaSource source, String relPath) async {
    final root = source.path;
    if (!source.isRemote || root == null || !DavPath.isDav(root)) return;
    // 同本地 `LocalMediaScanService.scanFolder`：开关关着时，落在 `.` 路径下的
    // 范围根不扫，否则常用目录 / 播放队列会把收敛掉的 `.` 目录洗回来。
    final latestSource = _repository.getSource(source.id) ?? source;
    if (!latestSource.includeDotEntries &&
        LocalDirectoryPolicy.relPathHasDotSegment(relPath)) {
      return;
    }
    final hidden = _repository.hiddenRelPaths(source.id);
    // ⛔ 读库里的最新值，别信 [source]：调用方手里可能是开关切换前的旧对象。
    final includeDot = latestSource.includeDotEntries;

    // ── 1. 这一层 ────────────────────────────────────────────────────────
    final List<DavEntry> entries;
    try {
      entries = await _list(source, _davFolderOf(root, relPath));
    } on WebDavUnavailable catch (e) {
      _markSource(source.id, e.state);
      return;
    } on WebDavFailure catch (failure) {
      WebDavService.logFailure('列 NAS 目录', failure);
      // 404 之类只说明这一个目录有问题，不代表整台 NAS 不可用。
      if (failure.kind != WebDavFailureKind.protocol || relPath.isEmpty) {
        _markSource(source.id, WebDavService.remoteStateOf(failure));
      }
      return;
    }

    // ── 2. 该重探的子目录 ─────────────────────────────────────────────────
    final existingChildren = <String, LocalMediaFolder>{
      for (final folder in _repository.childFolders(
        sourceId: source.id,
        parentRelPath: relPath,
        includeMissing: true,
        includeEmpty: true,
        includeHidden: true,
      ))
        folder.relPath: folder,
    };
    final toProbe = <DavEntry>[];
    for (final entry in _visibleSubfolders(entries, includeDot)) {
      final childRel = _childRel(relPath, entry.name);
      if (hidden.contains(childRel)) continue;
      final known = existingChildren[childRel];
      final unchanged =
          known != null &&
          known.probedAt != null &&
          !known.missing &&
          entry.modifiedMs != null &&
          known.modifiedAt == entry.modifiedMs;
      if (!unchanged) toProbe.add(entry);
      if (toProbe.length >= maxProbedChildren) break;
    }
    // ── 2½. 先把这一层落库，再慢慢探子目录 ─────────────────────────────────
    //
    // 子目录最多 48 个、并发 2、单次超时 20 秒：慢 NAS 上探完要几十秒。这一层的
    // 文件名第一步就拿到了，不该陪着一起等——先写进去（子目录只留占位行），
    // 页面按库变化信号当场出内容；探完之后下面那次 [_apply] 再补计数与封面。
    // 没有要探的就省掉这一次（下面那次就是全部）。
    if (toProbe.isNotEmpty) {
      final early = _repository.getSource(source.id);
      if (early == null) return;
      await _apply(
        source: early,
        root: root,
        scopeRelPath: relPath,
        scopeEntries: entries,
        childListings: const {},
        existingScopeFolder: _repository.getFolder(
          sourceId: source.id,
          relPath: relPath,
        ),
      );
    }

    final childListings = <String, List<DavEntry>>{};
    final queue = [...toProbe];
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final entry = queue.removeAt(0);
        try {
          childListings[_childRel(relPath, entry.name)] = await _list(
            source,
            DavPath.fromServerPath(entry.serverPath),
          );
        } catch (e) {
          // 单个子目录列不出来：它留作占位行、不参与收敛，不拖累这一层。
          WebDavService.logFailure('探 NAS 子目录', e);
        }
      }
    }

    await Future.wait([for (var i = 0; i < probeConcurrency; i++) worker()]);

    // 探测期间源可能被删了。
    final current = _repository.getSource(source.id);
    if (current == null) return;

    // ── 3. 落库 ──────────────────────────────────────────────────────────
    await _apply(
      source: current,
      root: root,
      scopeRelPath: relPath,
      scopeEntries: entries,
      childListings: childListings,
      existingScopeFolder: _repository.getFolder(
        sourceId: source.id,
        relPath: relPath,
      ),
    );
  }

  Future<void> _apply({
    required LocalMediaSource source,
    required String root,
    required String scopeRelPath,
    required List<DavEntry> scopeEntries,
    required Map<String, List<DavEntry>> childListings,
    required LocalMediaFolder? existingScopeFolder,
  }) async {
    // 调用点传进来的都是刚从库里读的源，开关值可信。
    final includeDot = source.includeDotEntries;
    // ⛔ [childListings] 是按探测**开始**时的开关挑的。慢 NAS 上探一轮几十秒，
    // 用户这期间关掉开关的话，不在这里按最新值再滤一遍，探回来的 `.` 子目录会被
    // 整批写库、洗回 missing = 0（关掉时那次整源扫描被 `_inFlight` 合流到这一轮
    // 旧的上面，不会另起一轮来纠正）。
    final probed = includeDot
        ? childListings
        : <String, List<DavEntry>>{
            for (final MapEntry(key: rel, value: entries)
                in childListings.entries)
              if (!LocalDirectoryPolicy.relPathHasDotSegment(rel)) rel: entries,
          };
    final collectVideos =
        source.mediaKinds == LocalMediaKinds.video ||
        source.mediaKinds == LocalMediaKinds.both;
    final collectImages =
        source.mediaKinds == LocalMediaKinds.image ||
        source.mediaKinds == LocalMediaKinds.both;

    final listings = <String, List<DavEntry>>{
      scopeRelPath: scopeEntries,
      ...probed,
    };
    // 子目录的 mtime 取自父目录的列表（它自己的 PROPFIND 不回自身那一条）。
    final childModified = <String, int?>{
      for (final entry in _visibleSubfolders(scopeEntries, includeDot))
        _childRel(scopeRelPath, entry.name): entry.modifiedMs,
    };

    final known = _repository.fingerprints(
      source.id,
      underPath: _davFolderOf(root, scopeRelPath),
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    final items = <LocalMediaItem>[];
    final seen = <String>{};
    final seenFolders = <String>{};
    final listedRelPaths = <String>{};
    final listedFolderPaths = <String>{};
    final folders = <LocalMediaFolder>[];
    final stubs = <LocalMediaFolder>[];

    for (final MapEntry(key: rel, value: entries) in listings.entries) {
      final davFolder = _davFolderOf(root, rel);
      listedRelPaths.add(rel);
      listedFolderPaths.add(davFolder);
      seenFolders.add(rel);

      // 同名图配对：与本地 worker 同一规则（按去扩展名、小写的文件名）。
      // `._xxx` 是 macOS 往网络盘上写的 AppleDouble 附属文件，扩展名和正片一样、
      // 内容却不是媒体——NAS 上远比本机常见，一律不收。
      // 单目录条目数与本地扫描同一上限。
      final files = entries
          .where((e) => !e.isDirectory && !e.name.startsWith('._'))
          .take(kMaxScanFiles)
          .toList();
      final imagesByStem = <String, DavEntry>{};
      for (final file in files) {
        if (kSidecarImageExtensions.contains(_ext(file.name))) {
          imagesByStem[_stem(file.name)] = file;
        }
      }
      final videoStems = <String>{};
      final claimed = <String>{};
      for (final file in files) {
        if (!kLocalVideoExtensions.contains(_ext(file.name))) continue;
        final stem = _stem(file.name);
        videoStems.add(stem);
        final sidecar = imagesByStem[stem];
        if (sidecar != null) claimed.add(sidecar.serverPath);
        if (!collectVideos) continue;
        _addItem(
          items: items,
          seen: seen,
          known: known,
          source: source,
          file: file,
          kind: LocalMediaItemKind.video,
          davFolder: davFolder,
          sidecarDavPath: sidecar == null
              ? null
              : DavPath.fromServerPath(sidecar.serverPath),
          now: now,
        );
      }
      if (collectImages) {
        for (final file in files) {
          if (!kSidecarImageExtensions.contains(_ext(file.name))) continue;
          if (claimed.contains(file.serverPath) ||
              videoStems.contains(_stem(file.name))) {
            continue;
          }
          _addItem(
            items: items,
            seen: seen,
            known: known,
            source: source,
            file: file,
            kind: LocalMediaItemKind.image,
            davFolder: davFolder,
            sidecarDavPath: null,
            now: now,
          );
        }
      }

      // 这一层自己的目录行（列过的）。
      final name = rel.isEmpty ? source.displayName : rel.split('/').last;
      folders.add(
        LocalMediaFolder(
          id: LocalMediaFolder.buildId(source.id, rel),
          sourceId: source.id,
          relPath: rel,
          parentRelPath: rel.isEmpty ? null : _parentRelPath(rel),
          name: name,
          sortName: naturalSortKey(name),
          folderPath: davFolder,
          // 子目录：父目录列表里的 mtime（下次据此决定要不要重探）。
          // 这一层自己：列表里没有自身那条，沿用库里已有的。
          modifiedAt: rel == scopeRelPath
              ? existingScopeFolder?.modifiedAt
              : childModified[rel],
        ),
      );

      // 它的子目录：没列过的只留占位行（不覆盖已学到的封面与 mtime）。
      for (final sub in _visibleSubfolders(entries, includeDot)) {
        final subRel = _childRel(rel, sub.name);
        seenFolders.add(subRel);
        if (listings.containsKey(subRel)) continue;
        stubs.add(
          LocalMediaFolder(
            id: LocalMediaFolder.buildId(source.id, subRel),
            sourceId: source.id,
            relPath: subRel,
            parentRelPath: rel,
            name: sub.name,
            sortName: naturalSortKey(sub.name),
            folderPath: DavPath.fromServerPath(sub.serverPath),
            modifiedAt: sub.modifiedMs,
          ),
        );
      }
    }
    // 分批写，批间让一帧。
    for (var i = 0; i < items.length; i += _batchSize) {
      final end = (i + _batchSize).clamp(0, items.length);
      _repository.upsertItems(items.sublist(i, end));
      if (end < items.length) await Future<void>.delayed(Duration.zero);
    }
    if (folders.isNotEmpty) _repository.upsertFolders(folders);
    if (stubs.isNotEmpty) _repository.upsertFolderStubs(stubs);

    // ⛔ 顺序照抄 `LocalMediaScanService._finish` 的目录级那一支：
    // 收敛 → 标探过 → 回填计数 → 封面冒泡。后三步必须在收敛之后，否则
    // 计数数进了刚被判 missing 的行，「藏空目录」的判断跟着错。
    _repository.markItemsMissingExceptInFolders(
      sourceId: source.id,
      listedFolderPaths: listedFolderPaths,
      seenHashes: seen,
    );
    _repository.markChildFoldersMissingExceptUnder(
      sourceId: source.id,
      listedRelPaths: listedRelPaths,
      seenRelPaths: seenFolders,
    );
    _repository.markFoldersProbed(
      sourceId: source.id,
      relPaths: listedRelPaths,
    );
    _repository.backfillFolderCountsInScope(
      sourceId: source.id,
      scopeRelPath: scopeRelPath,
      listedRelPaths: listedRelPaths,
    );
    // NAS 目录的封面只能来自已经拉进本机的缩略图：扫描器不写封面，派生回填
    // 只在「刚生成缩略图」那一刻发生。这里对列过的每一层补一次，重启后、封面
    // 被清过之后再进来都能接上。
    // 范围 = 列过的 + 这一层的全部直接子目录（mtime 没变、这次没重探的子目录
    // 也要补：它们的卡片就摆在用户眼前）。全是本地 SQL，不发网络请求。
    for (final rel in {...listedRelPaths, ...childModified.keys}) {
      _repository.backfillFolderCoverFromItems(
        sourceId: source.id,
        relPath: rel,
      );
    }
    _repository.propagateFolderCovers(
      sourceId: source.id,
      relPaths: {...listedRelPaths, ...childModified.keys},
    );

    final latest = _repository.getSource(source.id) ?? source;
    _repository.upsertSource(
      latest.copyWith(
        itemCount: _repository.countItems(sourceId: source.id),
        offline: false,
        remoteState: LocalMediaRemoteState.ok,
        lastScanAt: now,
      ),
    );
  }

  void _addItem({
    required List<LocalMediaItem> items,
    required Set<String> seen,
    required Map<String, LocalMediaFingerprint> known,
    required LocalMediaSource source,
    required DavEntry file,
    required LocalMediaItemKind kind,
    required String davFolder,
    required String? sidecarDavPath,
    required int now,
  }) {
    final path = DavPath.fromServerPath(file.serverPath);
    final hash = LocalMediaItem.hashPath(path);
    seen.add(hash);
    final fingerprint = known[hash];
    final unchanged =
        fingerprint != null &&
        !fingerprint.missing &&
        fingerprint.sizeBytes == file.size &&
        fingerprint.modifiedAt == file.modifiedMs &&
        fingerprint.sidecarImagePath == sidecarDavPath;
    // 没变过的老条目连 upsert 都不发（它的 missing 由收敛那一步洗回来）。
    if (unchanged) return;
    items.add(
      LocalMediaItem(
        id: LocalMediaItem.buildId(source.id, hash),
        sourceId: source.id,
        pathHash: hash,
        path: path,
        kind: kind,
        name: file.name,
        sortName: naturalSortKey(file.name),
        ext: _ext(file.name),
        sizeBytes: file.size,
        modifiedAt: file.modifiedMs,
        sidecarImagePath: sidecarDavPath,
        folderPath: davFolder,
        addedAt: now,
      ),
    );
  }

  void _markSource(String sourceId, LocalMediaRemoteState state) {
    final latest = _repository.getSource(sourceId);
    if (latest == null) return;
    LogUtils.w('NAS 源不可用：${state.name}', _tag);
    _repository.upsertSource(
      latest.copyWith(offline: true, remoteState: state),
    );
  }

  /// 与本地 worker 同一套跳过规则，见 [LocalDirectoryPolicy.skipListedChild]。
  static Iterable<DavEntry> _visibleSubfolders(
    List<DavEntry> entries,
    bool includeDot,
  ) => entries.where(
    (e) =>
        e.isDirectory &&
        !LocalDirectoryPolicy.skipListedChild(e.name, includeDot: includeDot),
  );

  static String _davFolderOf(String root, String relPath) => relPath.isEmpty
      ? root
      : DavPath.fromServerPath('${DavPath.toServerPath(root)}/$relPath');

  static String _childRel(String parentRel, String name) =>
      parentRel.isEmpty ? name : '$parentRel/$name';

  /// rel_path 一律 `/` 分隔，不能用 `p.dirname`（Windows 上认 `\`）。
  static String _parentRelPath(String relPath) {
    final index = relPath.lastIndexOf('/');
    return index < 0 ? '' : relPath.substring(0, index);
  }

  static String _ext(String name) {
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  }

  static String _stem(String name) {
    final dot = name.lastIndexOf('.');
    return (dot < 0 ? name : name.substring(0, dot)).toLowerCase();
  }
}
