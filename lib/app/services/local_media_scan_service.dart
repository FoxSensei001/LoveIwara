import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/android_media_store_service.dart';
import 'package:i_iwara/app/services/ios_folder_picker_service.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/utils/natural_sort_key.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 认得的视频扩展名。`Download/` 是**混装**的（apk / exe / zip 与视频躺在一起），
/// 所以扩展名过滤不是优化，是必需。
const Set<String> kLocalVideoExtensions = <String>{
  'mp4',
  'mkv',
  'webm',
  'avi',
  'mov',
  'm4v',
  'wmv',
  'flv',
  'ts',
  '3gp',
  'mpg',
  'mpeg',
  'm2ts',
  'rmvb',
  'ogv',
};

/// 同目录同名封面认得的扩展名（⭐ sidecar，见 [_ScanWorker]）。
const Set<String> kSidecarImageExtensions = <String>{
  'jpg',
  'jpeg',
  'png',
  'webp',
  'avif',
};

/// 默认跳过的目录名。
///
/// - `.` 开头：隐藏目录，用户不想被看到的东西多半在这儿（§8.3 P3）；
/// - `Android`：`Android/data` 与 `Android/obb` 本来就读不到，白走一趟；
/// - 回收站 / 缩略图缓存：全是垃圾，还特别多。
const Set<String> kSkippedDirectoryNames = <String>{
  'Android',
  'LOST.DIR',
  r'$RECYCLE.BIN',
  'System Volume Information',
  '.thumbnails',
  '.trash',
  '.trashed',
};

/// 递归深度上限。够深到覆盖 `<下载器>/<id>/<文件>` 这类三层布局，
/// 又不至于在一棵病态目录树上走到天荒地老。
const int kMaxScanDepth = 8;

/// 单次扫描的文件数上限。撞上了就停，并如实告诉用户"这个目录太大只收了前 N 个"，
/// 而不是一声不吭地扫到内存爆掉。
const int kMaxScanFiles = 50000;

/// 一批回推多少条。批太小则事务开销占比高，太大则一次事务卡住的时间可感。
const int kScanBatchSize = 300;

/// 扫描进度。UI 拿它显示"已发现 N 个"，**不阻塞列表**——列表始终直接读库。
class LocalMediaScanProgress {
  const LocalMediaScanProgress({
    required this.sourceId,
    required this.discovered,
    required this.finished,
    this.truncated = false,
    this.error,
  });

  final String sourceId;
  final int discovered;
  final bool finished;

  /// 撞上 [kMaxScanFiles] 提前停了。
  final bool truncated;
  final String? error;
}

/// 本地媒体扫描。
///
/// # ⛔ 为什么 isolate 里只走文件系统、不碰数据库
///
/// `openSqliteDb()` 就是一句 `sqlite3.open(path)`——**没有开 WAL**。默认的
/// `journal_mode=delete` 下，第二条连接一写就把整库锁住，扫描 isolate 和主
/// isolate 会互相顶。而 `DatabaseService` 持有的那个 `CommonDatabase` 是主
/// isolate 的单例、句柄本身也跨不过去。
///
/// 所以分工是死的：**isolate 只做遍历与 stat，把结果分批发回来；写库全部在主
/// isolate**，按批开显式事务，批与批之间让一帧出去。
///
/// # ⛔ 真正的卡顿在写库那一侧
///
/// 直觉会以为瓶颈是遍历，其实 sqlite3 的 API 是同步的：逐条 INSERT 等于每条各自
/// 提交一次事务，千级条目直接把帧吃光。[kScanBatchSize] 那一批一个事务才是关键。
class LocalMediaScanService extends GetxService {
  LocalMediaScanService({LocalMediaRepository? repository})
    : _repository = repository ?? LocalMediaRepository();

  static LocalMediaScanService get to => Get.find();

  final LocalMediaRepository _repository;

  static const String _tag = 'LocalMediaScan';

  final Rxn<LocalMediaScanProgress> progress = Rxn<LocalMediaScanProgress>();

  Isolate? _isolate;
  ReceivePort? _port;
  StreamSubscription<void>? _mediaStoreChanges;
  Completer<void>? _running;
  String? _runningSourceId;
  int _scanGeneration = 0;
  bool _mediaStoreRescanQueued = false;
  bool _mediaStoreChangePending = false;

  bool get isScanning => _running != null && !_running!.isCompleted;

  LocalMediaDerivationService? get _derivationService =>
      Get.isRegistered<LocalMediaDerivationService>()
      ? Get.find<LocalMediaDerivationService>()
      : null;

  AndroidMediaStoreService? get _mediaStoreService =>
      Get.isRegistered<AndroidMediaStoreService>()
      ? Get.find<AndroidMediaStoreService>()
      : null;

  /// MediaStore 变更的去抖窗口。
  ///
  /// ⛔ 这道去抖不是优化，是必需：`ContentObserver.onChange` 在多数 ROM 上是
  /// **逐行**回调——用户经 MTP 往机器里拷 200 个文件，就是 200 次通知。而每一次
  /// 通知触发的是**整张 MediaStore 重扫**（400 条一页过 method channel + 逐批
  /// upsert）。`_mediaStoreChangePending` 那个布尔只能把"扫描期间"到达的通知并成
  /// 一次，并不能拦住"扫完了又来一批"，于是拷贝过程中会一轮接一轮地空转。
  static const Duration _mediaStoreDebounce = Duration(seconds: 3);
  Timer? _mediaStoreDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    final mediaStore = _mediaStoreService;
    if (mediaStore != null) {
      _mediaStoreChanges = mediaStore.changes.listen((_) {
        _mediaStoreChangePending = true;
        _scheduleMediaStoreRescan();
      });
    }
  }

  /// 所有"该重扫 MediaStore 了"的路口都走这里，别在调用点直接 `_drain…`：
  /// 去抖只有收口成一处才拦得住（见 [_mediaStoreDebounce]）。
  void _scheduleMediaStoreRescan() {
    if (!_mediaStoreChangePending) return;
    _mediaStoreDebounceTimer?.cancel();
    _mediaStoreDebounceTimer = Timer(_mediaStoreDebounce, () {
      _mediaStoreDebounceTimer = null;
      if (!isScanning) unawaited(_drainMediaStoreRescans());
    });
  }

  /// 扫一个源。同一时刻只跑一个——并发扫两个目录只会让两边都变慢，
  /// 而且写库那一侧本来就是串行的。
  Future<void> scanSource(LocalMediaSource source) async {
    if (source.kind == LocalMediaSourceKind.mediastore) {
      await _scanMediaStoreSource(source);
      return;
    }
    if (source.kind == LocalMediaSourceKind.downloads) {
      // ⛔ 「已下载」不是靠走目录树建起来的：它从 `download_tasks` 同步过来
      // （下载目录是可改的设置，改之前下的片子还留在老地方，盯着当前目录扫会
      // 让它们整批消失）。见 `DownloadsLibrarySyncService` 的类文档。
      LogUtils.w('「已下载」源不走目录扫描，请改叫 DownloadsLibrarySyncService', _tag);
      return;
    }
    if (isScanning) {
      LogUtils.i('已有扫描在跑，忽略本次请求', _tag);
      return;
    }

    var currentSource = source;
    var isBookmarkAccessActive = false;
    String? activeBookmark;

    if (source.kind == LocalMediaSourceKind.bookmark) {
      final bookmark = source.uri;
      if (bookmark == null || bookmark.isEmpty) {
        LogUtils.w(
          'iOS bookmark 源 ${source.id} 缺少 bookmark 数据，标记为 offline',
          _tag,
        );
        _repository.upsertSource(
          source.copyWith(offline: true, scanState: LocalMediaScanState.idle),
        );
        return;
      }

      final resolved = await IosFolderPickerService.to.resolveBookmark(
        bookmark,
      );
      if (resolved == null) {
        LogUtils.w('iOS bookmark 源 ${source.id} 无法解析书签，标记为 offline', _tag);
        _repository.upsertSource(
          source.copyWith(offline: true, scanState: LocalMediaScanState.idle),
        );
        return;
      }

      final newPath = resolved.path;
      final newBookmark =
          (resolved.stale &&
              resolved.bookmark != null &&
              resolved.bookmark!.isNotEmpty)
          ? resolved.bookmark!
          : bookmark;

      if (newPath != source.path ||
          newBookmark != source.uri ||
          source.offline) {
        currentSource = source.copyWith(
          path: newPath,
          uri: newBookmark,
          offline: false,
        );
        _repository.upsertSource(currentSource);
      }

      final accessed = await IosFolderPickerService.to.startAccess(
        currentSource.uri!,
      );
      if (!accessed) {
        LogUtils.w(
          'iOS bookmark 源 ${currentSource.id} 启动访问失败，标记为 offline',
          _tag,
        );
        _repository.upsertSource(
          currentSource.copyWith(
            offline: true,
            scanState: LocalMediaScanState.idle,
          ),
        );
        return;
      }
      isBookmarkAccessActive = true;
      activeBookmark = currentSource.uri;
    }

    try {
      final root = currentSource.path;
      if (root == null || root.isEmpty) {
        LogUtils.w('源 ${currentSource.id} 没有路径，跳过扫描', _tag);
        return;
      }

      final running = Completer<void>();
      final generation = ++_scanGeneration;
      _running = running;
      _runningSourceId = currentSource.id;
      progress.value = LocalMediaScanProgress(
        sourceId: currentSource.id,
        discovered: 0,
        finished: false,
      );
      _repository.upsertSource(
        currentSource.copyWith(scanState: LocalMediaScanState.scanning),
      );

      final port = ReceivePort();
      _port = port;

      // 增量比对用的指纹：只有大小或修改时间变了的才需要重算内容派生字段。
      final known = _repository.fingerprints(currentSource.id);
      // 已经归「已下载」管的文件，这一轮一条都不收——同一条内容只能有一个主人，
      // 见 [LocalMediaRepository.pathsOfSource]。**也不进 `seen`**：以前误收进
      // 这个源的那些行会因此在收敛时被标成 missing，等于让出所有权。
      final ownedByDownloads = _repository.pathsOfSource(kDownloadsSourceId);
      final seen = <String>{};
      var discovered = 0;
      var truncated = false;
      String? failure;

      // ⛔ 背压：处理一批时把订阅**暂停**掉，处理完再 resume。
      //
      // 只在处理末尾 `await Future.delayed(Duration.zero)` 是不够的——`listen` 不会
      // 等回调返回，下一条消息照样进来，于是"让一帧"根本没让出去，扫大目录时
      // UI 仍然一顿一顿。暂停订阅才是真的把速度交还给消费端（SendPort 自己会缓冲）。
      late final StreamSubscription<dynamic> subscription;
      subscription = port.listen((dynamic message) async {
        if (!_isCurrent(generation, running)) return;
        // ⛔ isolate 意外死亡的两种形状必须接住，否则 `_running` 永远不完成、
        // 页面就一直卡在"扫描中"：
        //   - `onError` 送回来的是 [error, stackTrace] 这样一个 List；
        //   - `onExit` 送回来的是 null。
        if (message is List) {
          final error = message.isEmpty
              ? '扫描 isolate 意外退出'
              : '${message.first}';
          _finish(
            currentSource,
            seen,
            discovered,
            truncated,
            error,
            running,
            offline: false,
            generation: generation,
          );
          return;
        }
        if (message == null) {
          // 正常走完时 'done' 已经先到并完成了 running，这里就是个 no-op。
          // 如果没有 done 就退出，不能把半次扫描当成成功，否则会错误收敛
          // missing。
          _finish(
            currentSource,
            seen,
            discovered,
            truncated,
            '扫描 isolate 意外退出',
            running,
            offline: false,
            generation: generation,
          );
          return;
        }
        if (message is! Map) return;
        subscription.pause();
        switch (message['type'] as String?) {
          case 'batch':
            final records = (message['files'] as List).cast<Map>();
            final items = <LocalMediaItem>[];
            final derivationCandidates = <LocalMediaItem>[];
            final now = DateTime.now().millisecondsSinceEpoch;
            for (final record in records) {
              final path = record['path'] as String;
              if (ownedByDownloads.contains(path)) continue;
              final hash = _hashPath(path);
              seen.add(hash);
              final size = record['size'] as int?;
              final modified = record['modified'] as int?;
              final fingerprint = known[hash];
              final name = p.basename(path);
              final kind = (record['kind'] as String?) == 'image'
                  ? LocalMediaItemKind.image
                  : LocalMediaItemKind.video;
              final item = LocalMediaItem(
                id: LocalMediaItem.buildId(currentSource.id, hash),
                sourceId: currentSource.id,
                pathHash: hash,
                path: path,
                kind: kind,
                name: name,
                sortName: naturalSortKey(name),
                ext: (record['ext'] as String?)?.toLowerCase(),
                sizeBytes: size,
                modifiedAt: modified,
                sidecarImagePath: record['sidecar'] as String?,
                folderPath: p.dirname(path),
                addedAt: now,
              );
              final unchanged =
                  fingerprint != null &&
                  !fingerprint.missing &&
                  fingerprint.sizeBytes == size &&
                  fingerprint.modifiedAt == modified &&
                  fingerprint.sidecarImagePath == item.sidecarImagePath;
              // 没变过的老条目连 upsert 都不用发，但仍要补跑尚未完成的
              // 内容派生（例如升级前已经扫过的旧条目）。
              if (!unchanged) items.add(item);
              // ⛔ 派生服务开的是 media-kit 的 Player，喂图片进去纯属白等超时，只收视频。
              if (kind == LocalMediaItemKind.video) {
                final hasMetadata = fingerprint?.hasMetadata ?? false;
                if (!unchanged || !hasMetadata) {
                  derivationCandidates.add(item);
                }
              }
            }
            discovered += records.length;
            if (items.isNotEmpty) {
              try {
                _repository.upsertItems(items);
                _enqueueDerivation(derivationCandidates);
              } catch (e) {
                LogUtils.e('写入扫描批次失败', tag: _tag, error: e);
              }
            } else {
              _enqueueDerivation(derivationCandidates);
            }
            progress.value = LocalMediaScanProgress(
              sourceId: currentSource.id,
              discovered: discovered,
              finished: false,
            );
            // 让一帧出去，再放行下一批。
            await Future<void>.delayed(Duration.zero);
            // ⛔ 只有 batch 这一支才 resume：'done'/'error' 走 [_finish]，
            // 那里已经把 port 关掉了，再去 resume 一个已结束的订阅没有意义。
            if (_isCurrent(generation, running) && subscription.isPaused) {
              subscription.resume();
            }
          case 'done':
            truncated = message['truncated'] as bool? ?? false;
            final failedFolders = (message['failedFolders'] as List?)
                ?.cast<String>();
            _finish(
              currentSource,
              seen,
              discovered,
              truncated,
              message['error'] as String?,
              running,
              offline: message['offline'] as bool? ?? false,
              generation: generation,
              failedFolders: failedFolders,
            );
          case 'error':
            failure = message['message'] as String? ?? '扫描失败';
            _finish(
              currentSource,
              seen,
              discovered,
              truncated,
              failure,
              running,
              offline: message['offline'] as bool? ?? false,
              generation: generation,
            );
        }
      });

      try {
        final collectImages =
            currentSource.mediaKinds == LocalMediaKinds.image ||
            currentSource.mediaKinds == LocalMediaKinds.both;
        final collectVideos =
            currentSource.mediaKinds == LocalMediaKinds.video ||
            currentSource.mediaKinds == LocalMediaKinds.both;
        final isolate = await Isolate.spawn(
          _scanWorkerEntry,
          <String, Object?>{
            'send': port.sendPort,
            'root': root,
            'recursive': currentSource.recursive,
            'maxDepth': kMaxScanDepth,
            'maxFiles': kMaxScanFiles,
            'batchSize': kScanBatchSize,
            'videoExts': kLocalVideoExtensions.toList(),
            'imageExts': kSidecarImageExtensions.toList(),
            'skipDirs': kSkippedDirectoryNames.toList(),
            'collectImages': collectImages,
            'collectVideos': collectVideos,
          },
          errorsAreFatal: true,
          onError: port.sendPort,
          onExit: port.sendPort,
        );
        if (_isCurrent(generation, running)) {
          _isolate = isolate;
        } else {
          isolate.kill(priority: Isolate.immediate);
        }
      } catch (e) {
        LogUtils.e('启动扫描 isolate 失败', tag: _tag, error: e);
        _finish(
          currentSource,
          seen,
          discovered,
          truncated,
          '$e',
          running,
          offline: !_directoryExists(root),
          generation: generation,
        );
      }

      await running.future;
    } finally {
      if (isBookmarkAccessActive && activeBookmark != null) {
        try {
          await IosFolderPickerService.to.stopAccess(activeBookmark);
        } catch (e) {
          LogUtils.w('停止 iOS bookmark 访问权失败: $e', _tag);
        }
      }
    }
  }

  /// 跑**一轮**MediaStore 重扫。
  ///
  /// ⛔ 这里绝不能套 `while (_mediaStoreChangePending)` 重来：拷贝文件的过程中
  /// 变更是持续到达的，那个循环会在上一轮扫完的瞬间原地开下一轮，把
  /// [_mediaStoreDebounce] 整个架空。扫描期间又变脏了就交回给去抖排队。
  Future<void> _drainMediaStoreRescans() async {
    if (_mediaStoreRescanQueued || isScanning) return;
    _mediaStoreRescanQueued = true;
    try {
      _mediaStoreChangePending = false;
      for (final source in _repository.getSources()) {
        if (source.kind != LocalMediaSourceKind.mediastore) continue;
        await scanSource(source);
      }
    } finally {
      _mediaStoreRescanQueued = false;
      _scheduleMediaStoreRescan();
    }
  }

  Future<void> _scanMediaStoreSource(LocalMediaSource source) async {
    final mediaStore = _mediaStoreService;
    if (mediaStore == null) {
      LogUtils.w('MediaStore 服务未注册，跳过源 ${source.id}', _tag);
      return;
    }
    if (isScanning) {
      LogUtils.i('已有扫描在跑，忽略 MediaStore 刷新', _tag);
      return;
    }

    final running = Completer<void>();
    final generation = ++_scanGeneration;
    _running = running;
    _runningSourceId = source.id;
    progress.value = LocalMediaScanProgress(
      sourceId: source.id,
      discovered: 0,
      finished: false,
    );
    _repository.upsertSource(
      source.copyWith(scanState: LocalMediaScanState.scanning),
    );

    final known = _repository.fingerprints(source.id);
    final ownedElsewhere = _repository.pathsOwnedElsewhere(source.id);
    final seen = <String>{};
    int? afterModifiedAtSeconds;
    int? afterMediaStoreId;
    var discovered = 0;
    String? failure;

    try {
      while (_isCurrent(generation, running)) {
        final records = await mediaStore.queryVideos(
          afterModifiedAtSeconds: afterModifiedAtSeconds,
          afterMediaStoreId: afterMediaStoreId,
          limit: AndroidMediaStoreService.pageSize,
        );
        if (records.isEmpty) break;

        final now = DateTime.now().millisecondsSinceEpoch;
        final items = <LocalMediaItem>[];
        final derivationCandidates = <LocalMediaItem>[];
        for (final record in records) {
          final resolved = _resolveMediaStorePath(record);
          final identityPath = resolved ?? record.contentUri;
          if (identityPath.isEmpty) continue;

          // ⛔ MediaStore 是兜底来源，给每一个显式来源让位：
          // MediaStore 是"把机器上所有视频都列出来"的兜底来源；用户手动加的目录源和「已下载」都是
          // 显式表达。同一个文件只能有一个主人，规则定为：MediaStore 给所有非 MediaStore 的源让位。
          // 让掉的路径也不要 seen.add(hash)——理由同目录扫描给「已下载」让位那处：不进 seen，
          // 以前误收进这个源的行才会在收敛时被标成 missing，等于把所有权交出去。
          if (ownedElsewhere.contains(identityPath)) continue;

          final hash = _hashPath(identityPath);
          seen.add(hash);
          final name = record.displayName.trim().isEmpty
              ? 'video'
              : record.displayName;
          final fingerprint = known[hash];
          final hasMetadata = fingerprint == null
              ? false
              : fingerprint.hasMetadata;
          final item = LocalMediaItem(
            id: LocalMediaItem.buildId(source.id, hash),
            sourceId: source.id,
            pathHash: hash,
            path: identityPath,
            mediaStoreUri: record.contentUri,
            kind: LocalMediaItemKind.video,
            name: name,
            sortName: naturalSortKey(name),
            ext: _extensionOf(name, record.mimeType),
            sizeBytes: record.sizeBytes,
            modifiedAt: record.modifiedAt,
            durationMs: record.durationMs,
            width: record.width,
            height: record.height,
            folderPath: resolved != null
                ? p.dirname(resolved)
                : _mediaStoreFolder(record),
            addedAt: record.addedAt ?? now,
          );
          final unchanged =
              fingerprint != null &&
              !fingerprint.missing &&
              fingerprint.sizeBytes == item.sizeBytes &&
              fingerprint.modifiedAt == item.modifiedAt &&
              fingerprint.durationMs == item.durationMs &&
              fingerprint.width == item.width &&
              fingerprint.height == item.height &&
              // ⛔ 句柄也要比：用户在系统设置里清一次「媒体存储」的数据，
              // MediaStore 会把所有 _ID 重新分配一遍——文件没动，size/mtime
              // 一模一样，但每一条的 content:// 都换了。不比这一列的话，库里
              // 会留着一个已经失效的句柄，而只授予 READ_MEDIA_VIDEO（没给
              // 「所有文件访问」）时那条就再也播不了了。
              fingerprint.mediaStoreUri == item.mediaStoreUri;
          if (!unchanged) items.add(item);
          if (!unchanged || !hasMetadata) {
            derivationCandidates.add(item);
          }
        }

        if (items.isNotEmpty) _repository.upsertItems(items);
        _enqueueDerivation(derivationCandidates);
        discovered += records.length;
        progress.value = LocalMediaScanProgress(
          sourceId: source.id,
          discovered: discovered,
          finished: false,
        );
        if (records.length < AndroidMediaStoreService.pageSize) break;
        final last = records.last;
        final lastModifiedAtSeconds = last.modifiedAtSeconds;
        final lastMediaStoreId = last.mediaStoreId;
        if (lastModifiedAtSeconds == null || lastMediaStoreId == null) {
          throw StateError('MediaStore page is missing its cursor key');
        }
        afterModifiedAtSeconds = lastModifiedAtSeconds;
        afterMediaStoreId = lastMediaStoreId;
        await Future<void>.delayed(Duration.zero);
      }

      if (_isCurrent(generation, running)) {
        final changedDuringScan = _mediaStoreChangePending;
        _finish(
          source,
          seen,
          discovered,
          false,
          null,
          running,
          offline: false,
          generation: generation,
          allowMissing: !changedDuringScan,
        );
      }
    } catch (e, s) {
      failure = '$e';
      AndroidMediaStoreService.logQueryFailure(e, s);
      _finish(
        source,
        seen,
        discovered,
        false,
        failure,
        running,
        offline: false,
        generation: generation,
      );
    }

    return running.future;
  }

  static String? _extensionOf(String name, String? mimeType) {
    final fromName = p.extension(name).replaceFirst('.', '').toLowerCase();
    if (fromName.isNotEmpty) return fromName;
    final fromMime = mimeType?.split('/').last.toLowerCase();
    return fromMime == null || fromMime.isEmpty ? null : fromMime;
  }

  static String? _mediaStoreFolder(AndroidMediaStoreVideo record) {
    final relative = record.relativePath?.replaceAll('\\', '/').trim();
    if (relative != null && relative.isNotEmpty) {
      return relative.replaceFirst(RegExp(r'/+$'), '');
    }
    final bucket = record.bucketName?.trim();
    return bucket == null || bucket.isEmpty ? null : bucket;
  }

  /// 把 MediaStore 的 (volumeName, relativePath, displayName) 拼回真实文件路径。
  ///
  /// ⛔ 拼完**必须 existsSync 验一下**再采信：卷名到挂载点的映射是约定不是契约。
  /// 主卷是 `external_primary` → `/storage/emulated/0`；SD 卡的 volumeName 形如
  /// `1a2b-3c4d`（小写），而挂载点在多数 ROM 上是 `/storage/1A2B-3C4D`（大写）
  /// ——两种都试。一个都对不上就返回 null，那一条继续用 content:// 当身份。
  static String? _resolveMediaStorePath(AndroidMediaStoreVideo record) {
    try {
      final relativePath = record.relativePath?.trim();
      if (relativePath == null || relativePath.isEmpty) return null;
      final displayName = record.displayName.trim();
      if (displayName.isEmpty) return null;

      final volume = record.volumeName?.trim();
      final candidates = <String>[];
      if (volume == null || volume.isEmpty || volume == 'external_primary') {
        candidates.add('/storage/emulated/0');
      } else {
        candidates.add('/storage/$volume');
        final upper = volume.toUpperCase();
        if (upper != volume) {
          candidates.add('/storage/$upper');
        }
        candidates.add('/storage/emulated/0');
      }

      for (final mount in candidates) {
        final candidate = p.normalize(p.join(mount, relativePath, displayName));
        if (File(candidate).existsSync()) return candidate;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _finish(
    LocalMediaSource source,
    Set<String> seen,
    int discovered,
    bool truncated,
    String? error,
    Completer<void> running, {
    required bool offline,
    required int generation,
    bool allowMissing = true,
    List<String>? failedFolders,
  }) {
    if (!_isCurrent(generation, running)) return;

    var effectiveError = error;

    if (failedFolders != null && failedFolders.isNotEmpty) {
      LogUtils.w(
        '扫描完成，但有 ${failedFolders.length} 个子目录无法读取（已跳过并不误标 missing）: '
        '${failedFolders.take(3).join(', ')}${failedFolders.length > 3 ? ' …' : ''}',
        _tag,
      );
    }

    // ⛔ 只有**扫完了**才收敛 missing。中途出错/被截断时不能收敛：没走到的那一半
    // 会被冤枉成"文件没了"，用户看到的是列表凭空少了一半。
    // ⭐ 有读不动的子目录时，**只把那几棵子树排除在收敛之外**，其余照常收敛。
    //
    // ⛔ 不能反过来写成"只收敛走到过的目录"：整个文件夹被用户删掉时，它既不在
    // 失败清单里、也不会出现在走到过的清单里（父目录列不出它了），于是那一整个
    // 目录的条目永远收敛不掉，变成一堆点不开的幽灵卡片。
    if (allowMissing && error == null && !truncated) {
      try {
        _repository.markMissingExcept(
          source.id,
          seen,
          excludeFolderTrees: failedFolders,
        );
      } catch (e) {
        LogUtils.e('收敛 missing 失败', tag: _tag, error: e);
        effectiveError = '$e';
      }
    }

    try {
      _repository.upsertSource(
        source.copyWith(
          scanState: allowMissing && effectiveError == null && !truncated
              ? LocalMediaScanState.idle
              : LocalMediaScanState.interrupted,
          lastScanAt: DateTime.now().millisecondsSinceEpoch,
          itemCount: _repository.countItems(sourceId: source.id),
          offline: offline,
        ),
      );
    } catch (e) {
      LogUtils.e('回写源状态失败', tag: _tag, error: e);
    }

    progress.value = LocalMediaScanProgress(
      sourceId: source.id,
      discovered: discovered,
      finished: true,
      truncated: truncated,
      error: effectiveError,
    );
    _teardown();
    running.complete();
    // 扫描期间到达的变更：同样走去抖，别扫完立刻再扫一遍。
    _scheduleMediaStoreRescan();
  }

  /// 用户离开页面 / 换源：把 isolate 收掉，别让它在后台接着刨盘。
  void cancel([String? sourceId]) {
    if (!isScanning) return;
    if (sourceId != null && sourceId != _runningSourceId) return;
    LogUtils.i('用户取消扫描', _tag);
    final runningSourceId = _runningSourceId;
    final running = _running;
    _scanGeneration++;
    _teardown();
    if (runningSourceId != null) {
      try {
        final source = _repository.getSource(runningSourceId);
        if (source != null) {
          _repository.upsertSource(
            source.copyWith(scanState: LocalMediaScanState.interrupted),
          );
        }
      } catch (e) {
        LogUtils.w('回写取消后的扫描状态失败: $e', _tag);
      }
    }
    if (running != null && !running.isCompleted) running.complete();
    // ⛔ 取消不走 [_finish]，所以那边的重排在这条路上不会发生。挂起的 MediaStore
    // 变更如果不在这里重新排队，就会一直等到"下一次系统通知"——而那可能永远不来。
    _scheduleMediaStoreRescan();
  }

  void _teardown() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port?.close();
    _port = null;
    _running = null;
    _runningSourceId = null;
  }

  bool _isCurrent(int generation, Completer<void> running) =>
      generation == _scanGeneration &&
      identical(_running, running) &&
      !running.isCompleted;

  static bool _directoryExists(String path) {
    try {
      return Directory(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  void onClose() {
    _mediaStoreDebounceTimer?.cancel();
    _mediaStoreDebounceTimer = null;
    _mediaStoreChanges?.cancel();
    _mediaStoreChanges = null;
    _scanGeneration++;
    _teardown();
    super.onClose();
  }

  static String _hashPath(String path) =>
      sha1.convert(utf8.encode(path)).toString();

  void _enqueueDerivation(Iterable<LocalMediaItem> items) {
    final service = _derivationService;
    if (service == null) return;
    unawaited(service.enqueueAll(items));
  }
}

// ── isolate 侧 ────────────────────────────────────────────────────────────

/// 扫描 worker。**只碰文件系统**，不碰数据库、不碰 GetX。
///
/// 遍历是手写的显式栈而不是 `Directory.list(recursive: true)`，为的是三件
/// 后者给不了的东西：**深度上限**、**按目录整棵跳过**（`.nomedia` / 黑名单）、
/// 以及 ⭐ **sidecar 匹配**——同名封面必须在"手上正好有这个目录的清单"时匹配，
/// 逐个文件去 `existsSync` 是一次白白多出来的 IO。
///
/// ⛔ 软链接：`listSync(followLinks: false)` 会把符号链接报成 [Link] 而不是
/// [Directory]，我们只往 [Directory] 里递归，于是循环目录天然走不进去，
/// 不需要另外记 realpath。
void _scanWorkerEntry(Map<String, Object?> args) {
  final send = args['send'] as SendPort;
  final root = args['root'] as String;
  final recursive = args['recursive'] as bool? ?? true;
  final maxDepth = args['maxDepth'] as int? ?? kMaxScanDepth;
  final maxFiles = args['maxFiles'] as int? ?? kMaxScanFiles;
  final batchSize = args['batchSize'] as int? ?? kScanBatchSize;
  final videoExts = (args['videoExts'] as List).cast<String>().toSet();
  final imageExts = (args['imageExts'] as List).cast<String>().toSet();
  final skipDirs = (args['skipDirs'] as List)
      .cast<String>()
      .map((e) => e.toLowerCase())
      .toSet();
  final collectImages = args['collectImages'] as bool? ?? false;
  final collectVideos = args['collectVideos'] as bool? ?? true;

  final batch = <Map<String, Object?>>[];
  // 只回传**读不动的**目录。走到过的目录全量回传曾经是另一种写法，在几万个目录的
  // 树上是一大笔白花的内存与 SendPort 开销，而收敛只需要知道"哪几棵没看到"。
  final failedFolders = <String>[];
  var total = 0;
  var truncated = false;
  String? failure;
  var offline = false;

  void flush() {
    if (batch.isEmpty) return;
    send.send(<String, Object?>{
      'type': 'batch',
      'files': List<Map<String, Object?>>.from(batch),
    });
    batch.clear();
  }

  try {
    final stack = <({Directory dir, int depth})>[
      (dir: Directory(root), depth: 0),
    ];
    while (stack.isNotEmpty) {
      if (total >= maxFiles) {
        truncated = true;
        break;
      }
      final current = stack.removeLast();
      final List<FileSystemEntity> entries;
      try {
        entries = current.dir.listSync(followLinks: false);
      } catch (e) {
        // ⛔ 单个目录读不动**不能**中断整次扫描：权限、坏扇区、Windows 超长路径
        // 都会让某一个目录抛，而用户要的是「其余的都扫到」。跳过它并记进
        // failedFolders，主 isolate 收敛 missing 时会把这几棵子树排除在外——既不
        // 让一个读不动的子目录一票否决整个源的收敛，也不把没走到的条目冤枉成
        // 「文件没了」。
        if (current.depth == 0) {
          failure ??= '无法读取根目录 ${current.dir.path}: $e';
          offline = true;
          break;
        }
        // ⛔ 必须 normalize：条目落库时 folder_path 走的是 p.dirname(file.path)，
        // 而根路径带尾斜杠时 Directory('/a/b/').path 就是 '/a/b/'，两边对不上，
        // 排除范围会静默失效。
        failedFolders.add(p.normalize(current.dir.path));
        continue;
      }

      final files = <File>[];
      final subdirs = <Directory>[];
      var blocked = false;
      for (final entry in entries) {
        if (entry is Directory) {
          subdirs.add(entry);
        } else if (entry is File) {
          if (p.basename(entry.path).toLowerCase() == '.nomedia') {
            // 这个目录（连同子树）明确不想被媒体扫描看到，整棵跳过。
            blocked = true;
            break;
          }
          files.add(entry);
        }
      }
      if (blocked) continue;

      // ⭐ sidecar：先把本目录的图片按「去扩展名的文件名」索引起来，
      // 视频再来对号入座。整个目录只建一次表，比每个视频 existsSync 便宜得多。
      final imagesByStem = <String, String>{};
      for (final file in files) {
        final ext = _extensionOf(file.path);
        if (imageExts.contains(ext)) {
          imagesByStem[p.basenameWithoutExtension(file.path).toLowerCase()] =
              file.path;
        }
      }

      final claimedSidecars = <String>{};
      final videoStems = <String>{};
      for (final file in files) {
        final ext = _extensionOf(file.path);
        if (!videoExts.contains(ext)) continue;
        final stem = p.basenameWithoutExtension(file.path).toLowerCase();
        videoStems.add(stem);
        final sidecar = imagesByStem[stem];
        if (sidecar != null) {
          claimedSidecars.add(sidecar);
        }
        if (!collectVideos) continue;

        int? size;
        int? modified;
        // ⛔ `statSync()` **不抛异常**：stat 不动时它返回一个
        // `type = notFound` 的 `FileStat`，`size = -1`、`modified` 是纪元零点。
        // 所以这里必须**看 type**，光包个 try/catch 是自欺——那个 catch 从来
        // 没有执行过，而 `(-1, 0)` 会被当成真元数据写进库。
        //
        // 后果不止是一行脏数据：`size_bytes/modified_at` 是"这还是不是同一个
        // 文件"的唯一判据（见 [LocalMediaRepository.upsertItems] 与
        // `_dropProgressOfReplacedItems`），一个假指纹会让下一次扫描认定文件被
        // 换过，连带**删掉用户的观看进度**——而那张表不进配置备份，删了就没了。
        //
        // 量不出来就一个都不写：null 是"不知道"，`-1` 是一句谎话。
        FileStat stat;
        try {
          stat = file.statSync();
        } catch (_) {
          // 单个文件读取失败（例如被其他进程短暂加锁），跳过即可，不影响整源收敛
          continue;
        }
        if (stat.type != FileSystemEntityType.file) {
          // 文件可能在 listSync 后被删除，或者路径已经不再是普通文件。
          // 这类记录既不能入库，也不能算 seen。
          continue;
        }
        size = stat.size;
        modified = stat.modified.millisecondsSinceEpoch;
        batch.add(<String, Object?>{
          'path': file.path,
          'kind': 'video',
          'ext': ext,
          'size': size,
          'modified': modified,
          'sidecar': sidecar,
        });
        total++;
        if (batch.length >= batchSize) flush();
        if (total >= maxFiles) {
          truncated = true;
          break;
        }
      }
      if (truncated) break;

      if (collectImages) {
        for (final file in files) {
          final ext = _extensionOf(file.path);
          if (!imageExts.contains(ext)) continue;
          final stem = p.basenameWithoutExtension(file.path).toLowerCase();
          // ⛔ sidecar 必须继续被排除在条目之外：同目录下被视频用作封面的图片不是图库里的一张图。
          if (claimedSidecars.contains(file.path) ||
              videoStems.contains(stem)) {
            continue;
          }

          int? size;
          int? modified;
          FileStat stat;
          try {
            stat = file.statSync();
          } catch (_) {
            // 单个文件读取失败（例如被其他进程短暂加锁），跳过即可，不影响整源收敛
            continue;
          }
          if (stat.type != FileSystemEntityType.file) {
            continue;
          }
          size = stat.size;
          modified = stat.modified.millisecondsSinceEpoch;
          batch.add(<String, Object?>{
            'path': file.path,
            'kind': 'image',
            'ext': ext,
            'size': size,
            'modified': modified,
            'sidecar': null,
          });
          total++;
          if (batch.length >= batchSize) flush();
          if (total >= maxFiles) {
            truncated = true;
            break;
          }
        }
        if (truncated) break;
      }

      if (!recursive || current.depth >= maxDepth) continue;
      for (final dir in subdirs) {
        final name = p.basename(dir.path);
        if (name.startsWith('.')) continue;
        if (skipDirs.contains(name.toLowerCase())) continue;
        stack.add((dir: dir, depth: current.depth + 1));
      }
    }

    flush();
    send.send(<String, Object?>{
      'type': 'done',
      'truncated': truncated,
      'error': failure,
      'offline': offline,
      'failedFolders': failedFolders,
    });
  } catch (e) {
    flush();
    send.send(<String, Object?>{
      'type': 'error',
      'message': '$e',
      'offline': !_directoryExistsInWorker(root),
    });
  }
}

bool _directoryExistsInWorker(String path) {
  try {
    return Directory(path).existsSync();
  } catch (_) {
    return false;
  }
}

String _extensionOf(String path) {
  final ext = p.extension(path);
  if (ext.isEmpty) return '';
  return ext.substring(1).toLowerCase();
}
