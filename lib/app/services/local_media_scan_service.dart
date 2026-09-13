import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
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

/// 目录级懒扫描的深度：1 ＝ 这一层的文件 + 每个子目录再列一次。
///
/// 为什么必须是 1 而不是 0：0 只列当前目录，子目录里有没有东西一概不知，
/// 于是「藏空目录」那条规则会把它们**全部**藏掉（三个计数都是 0）。多列一层
/// 就能分清「探过、真的空」和「里面有东西」——你那个 Download 底下两千多个
/// 哈希缓存空目录正是靠这一层被判掉的。
const int kLazyProbeDepth = 1;

/// 单次扫描的文件数上限。撞上了就停，并如实告诉用户"这个目录太大只收了前 N 个"，
/// 而不是一声不吭地扫到内存爆掉。
const int kMaxScanFiles = 50000;

/// 单次扫描的目录数上限，与 [kMaxScanFiles] 同构：撞上了就停并标 truncated。
///
/// ⛔ 只封文件数封不住「几万个空目录」那种树（下载器的哈希缓存目录）：每个目录
/// 都要回传一行、主 isolate 都要写一行，文件数一直是 0，闸门永远不咬合。
const int kMaxScanFolders = 20000;

/// 每轮扫描通过「选出封面代表」路径入队的最大数量。
///
/// 大库一次可能扫出成百上千个纯视频目录；若全部送入派生队列，
/// 会把串行的派生队列堵塞极长时间。因此设置单轮上限 200，超过即止。
const int kMaxFolderCoverDerivationEnqueuedPerScan = 200;

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
/// `DatabaseService` 持有的那个 `CommonDatabase` 是主 isolate 的单例，**句柄本身
/// 跨不过 isolate 边界**——这一条就足以定死分工，与 journal 模式无关。
///
/// （2026-09-11 起 `openSqliteDb()` 会开 WAL，所以「第二条连接一写就锁住整库」
/// 这个旧理由已经不成立了；想让扫描 isolate 自己开一条连接写库在技术上变得可行。
/// 但那要另建连接、另管事务与 checkpoint，收益不明，暂不动。）
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
  bool _closed = false;

  /// 排队等闸门的目录级扫描，按 `(sourceId, relPath)` 去重、先来先扫。
  ///
  /// ⛔ 不能让多个等待者挂在同一个 `_running.future` 上：唤醒后只有第一个进得去，
  /// 其余看到 isScanning 直接 return，页面那边以为扫完了、显示一个空目录。
  final LinkedHashMap<String, _QueuedFolderScan> _pendingFolderScans =
      LinkedHashMap<String, _QueuedFolderScan>();
  bool _folderPumping = false;

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

    await _scanTree(
      source: source,
      scopeRelPath: '',
      maxDepth: kMaxScanDepth,
      scoped: false,
    );
  }

  /// 扫一个目录的**这一层**：它自己的直接子文件 + 每个直接子目录再浅探一层
  /// （只为判断那个子目录是不是空的、顺手取一张封面），不再往下。
  Future<void> scanFolder({
    required LocalMediaSource source,
    required String relPath,
  }) async {
    if (source.kind == LocalMediaSourceKind.mediastore) {
      return;
    }
    if (source.kind == LocalMediaSourceKind.downloads) {
      return;
    }
    // ⛔ 目录级扫描撞上别的扫描时**不能**静默丢弃，要排队等。
    //
    // 这一条是「进到这一层就把它重新列一遍」的唯一驱动力（见
    // `LocalFolderBrowsePage._scanThisFolder`）。丢掉它的后果是页面那边的
    // `finally` 照样把 `_scanning` 清成 false、以为扫完了，用户看到的是一个
    // **空目录**，而且再也不会自己扫——除非退出去重进。
    //
    // 真实路径：用户进目录 A（懒扫描起步），没等完就返回、马上点进没扫过的
    // 目录 B → B 撞上 A 那一轮，直接 return → B 永远空着。
    //
    // 所以一律进 [_pendingFolderScans]：同一目录重复请求合流到同一个 completer，
    // 闸门每放一次就取下一个出来跑，见 [_pumpFolderQueue]。
    final key = '${source.id}\u0000$relPath';
    final existing = _pendingFolderScans[key];
    if (existing != null) {
      existing.source = source;
      return existing.completer.future;
    }
    final job = _QueuedFolderScan(source, relPath);
    _pendingFolderScans[key] = job;
    if (isScanning) LogUtils.i('已有扫描在跑，目录扫描排队等待', _tag);
    unawaited(_pumpFolderQueue());
    return job.completer.future;
  }

  /// 闸门空出来就依次跑排队的目录扫描。每一处放闸（[_teardown] / releaseSlot）
  /// 都会经 [_scheduleFolderPump] 叫到这里。
  Future<void> _pumpFolderQueue() async {
    if (_folderPumping) return;
    _folderPumping = true;
    try {
      while (_pendingFolderScans.isNotEmpty && !isScanning && !_closed) {
        final key = _pendingFolderScans.keys.first;
        final job = _pendingFolderScans.remove(key)!;
        try {
          // 排队期间源可能被用户删掉了。
          if (_repository.getSource(job.source.id) == null) continue;
          await _scanTree(
            source: job.source,
            scopeRelPath: job.relPath,
            maxDepth: kLazyProbeDepth,
            scoped: true,
          );
        } catch (e) {
          LogUtils.e('排队的目录扫描失败', tag: _tag, error: e);
        } finally {
          if (!job.completer.isCompleted) job.completer.complete();
        }
      }
    } finally {
      _folderPumping = false;
    }
  }

  /// 放闸之后再取队列：放闸点都在同步代码中间（completer 还没 complete），
  /// 挪到微任务里等那一段跑完。
  void _scheduleFolderPump() {
    if (_pendingFolderScans.isEmpty || _closed) return;
    scheduleMicrotask(() => unawaited(_pumpFolderQueue()));
  }

  /// 把排队中的目录扫描丢掉（源被删 / 服务关闭），completer 一律收尾。
  void _dropQueuedFolderScans([String? sourceId]) {
    final dropped = <_QueuedFolderScan>[];
    _pendingFolderScans.removeWhere((_, job) {
      final match = sourceId == null || job.source.id == sourceId;
      if (match) dropped.add(job);
      return match;
    });
    for (final job in dropped) {
      if (!job.completer.isCompleted) job.completer.complete();
    }
  }

  Future<void> _scanTree({
    required LocalMediaSource source,

    /// 从源根算起的相对路径；'' 表示整源。
    required String scopeRelPath,
    required int maxDepth,

    /// true = 目录级懒扫描，收敛只在扫过的那一层里做。
    required bool scoped,
  }) async {
    var currentSource = source;
    var isBookmarkAccessActive = false;
    String? activeBookmark;

    // ⛔ 闸门必须在**任何 await 之前**占住，不能等到下面拿到 root 才占。
    //
    // bookmark 源要先 `await resolveBookmark` 再 `await startAccess`，两次调用
    // 落进这段窗口就会双双进来：后者覆盖 `_running`/`_scanGeneration`，前者的
    // [_finish] 被 [_isCurrent] 挡掉 → completer 永不完成 → 下面的
    // `await running.future` 永久挂起 → `finally` 里的 `stopAccess` 不执行
    // （安全作用域泄漏）、`_port` 不关，调用方的 `finally` 也一起被挂死。
    final running = Completer<void>();
    final generation = ++_scanGeneration;
    _running = running;
    _runningSourceId = source.id;

    // 早退时把闸门还回去。complete 掉的 completer 不再是 `_isCurrent`，
    // 所以重复调用是安全的。
    void releaseSlot() {
      if (!_isCurrent(generation, running)) return;
      _running = null;
      _runningSourceId = null;
      running.complete();
      _scheduleFolderPump();
    }

    // ⛔ 占闸之后的**每一句**都必须落在这个 try 里。upsertSource / fingerprints /
    // pathsOfSource 都是同步写读库，任何一句抛出去，闸门就永远不还——isScanning
    // 恒为 true，模块到重启前一次都扫不了，而且没有任何提示。
    try {
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
          releaseSlot();
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
          releaseSlot();
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
          releaseSlot();
          return;
        }
        isBookmarkAccessActive = true;
        activeBookmark = currentSource.uri;
      }

      try {
        final sourceRoot = currentSource.path;
        if (sourceRoot == null || sourceRoot.isEmpty) {
          LogUtils.w('源 ${currentSource.id} 没有路径，跳过扫描', _tag);
          releaseSlot();
          return;
        }
        final root = scopeRelPath.isEmpty
            ? sourceRoot
            : p.normalize(p.join(sourceRoot, scopeRelPath));

        // 闸门在函数开头就占住了（见那里的注释），这里只把源 id 对齐到
        // bookmark 解析后的那一份。
        _runningSourceId = currentSource.id;
        progress.value = LocalMediaScanProgress(
          sourceId: currentSource.id,
          discovered: 0,
          finished: false,
        );
        if (!scoped) {
          _repository.upsertSource(
            currentSource.copyWith(scanState: LocalMediaScanState.scanning),
          );
        }

        final port = ReceivePort();
        _port = port;

        // 增量比对用的指纹：只有大小或修改时间变了的才需要重算内容派生字段。
        // ⛔ 目录级扫描只读这棵子树的：懒扫描每进一层都走这里，整源全读＝每次点进
        // 目录都在主 isolate 上建一张几万项的 Map。
        final scopePath = scoped ? root : null;
        final known = _repository.fingerprints(
          currentSource.id,
          underPath: scopePath,
        );
        // 已经归「已下载」管的文件，这一轮一条都不收——同一条内容只能有一个主人，
        // 见 [LocalMediaRepository.pathsOfSource]。**也不进 `seen`**：以前误收进
        // 这个源的那些行会因此在收敛时被标成 missing，等于让出所有权。
        final ownedByDownloads = _repository.pathsOfSource(
          kDownloadsSourceId,
          underPath: scopePath,
        );
        final seen = <String>{};
        // 目录那侧的 seen：装的是 **rel_path**（源根是空字符串），不是 path_hash。
        // 两个集合口径不同但用途一样——收敛时"这轮没再见到的"就标 missing。
        final seenFolders = <String>{};

        /// 这一轮**真的 list 过**的目录（有效 rel_path）。只有它们够格被标成探过，
        /// 也只有它们的孩子够格参与收敛——没列过就没资格对它下结论。
        final listedRelPaths = <String>{};

        /// 同上，绝对路径版，条目收敛按它筛。
        final listedFolderPaths = <String>{};
        var discovered = 0;
        var truncated = false;
        String? failure;
        var enqueuedFolderCovers = 0;

        // ⛔ 背压是**拉取式**的：worker 每发一批就停下来等主 isolate 回一句 `next`，
        // 主 isolate 把这一批写完库、让出一帧之后才回。
        //
        // 以前是处理时 `subscription.pause()`：那只让主 isolate 这边不往下读，worker
        // 照样全速遍历、照样往 SendPort 里塞——几万个目录的树上，消息全堆在主 isolate
        // 的端口缓冲里，内存跟着涨，暂停等于没暂停。
        SendPort? workerControl;
        void requestNext() {
          if (_isCurrent(generation, running)) workerControl?.send('next');
        }

        port.listen((dynamic message) async {
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
              scoped: scoped,
              scopeRelPath: scopeRelPath,
              listedRelPaths: listedRelPaths,
              listedFolderPaths: listedFolderPaths,
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
              scoped: scoped,
              scopeRelPath: scopeRelPath,
              listedRelPaths: listedRelPaths,
              listedFolderPaths: listedFolderPaths,
            );
            return;
          }
          if (message is! Map) return;
          // ⛔ 整段 switch 必须兜住：这里全是同步写库，任何一处抛出去（写库、入队、
          // 进度赋值），worker 就永远等不到 `next`，闸门也永远不还。
          try {
            switch (message['type'] as String?) {
              case 'hello':
                workerControl = message['port'] as SendPort?;
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
                  // 视频与图片均需派生元数据：视频通过 media-kit 提取时长/宽高/帧率，
                  // 图片走独立的只读文件头通道获取宽高（毫秒级、互不阻塞）。
                  // ⛔ 视频「探测过但没读出来」（库里的 meta_probed）同样算齐：否则
                  // 解不出时长/宽高的文件每次冷启动都会重新排队、白开一次 Player。
                  final hasMetadata = switch (kind) {
                    LocalMediaItemKind.video =>
                      fingerprint != null &&
                          (fingerprint.hasMetadata || fingerprint.metaProbed),
                    LocalMediaItemKind.image =>
                      fingerprint?.hasImageMetadata ?? false,
                  };
                  if (!unchanged || !hasMetadata) {
                    derivationCandidates.add(item);
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
                // ⛔ 只有 batch / folders 这两支才回 `next`：'done'/'error' 走 [_finish]，
                // worker 那边已经不再等了。**任何新增的"worker 发完会等"的消息类型都
                // 必须自己回**——漏一处就是 worker 永久挂起，表现成「扫描卡在半路不动、
                // 进度条不再跳」，而且没有任何报错。
                requestNext();
              case 'folders':
                final records = (message['folders'] as List).cast<Map>();
                final folders = <LocalMediaFolder>[];
                // ⛔ 占位行要和列过的行分开写：前者走 `DO NOTHING`，不然它那两个
                // null（封面、修改时间）会把之前学到的值盖掉。见
                // [LocalMediaRepository.upsertFolderStubs] 的注释。
                final stubs = <LocalMediaFolder>[];
                // worker 列目录时就知道这一层有没有视频；没有视频的目录不可能挑出
                // 封面代表，下面那两道查询对它们一律不发。
                final foldersWithVideo = <String>{};
                for (final record in records) {
                  final rawRel = (record['rel'] as String?) ?? '';
                  final relPath = scopeRelPath.isEmpty
                      ? rawRel
                      : (rawRel.isEmpty
                            ? scopeRelPath
                            : '$scopeRelPath/$rawRel');
                  final isStub = (record['stub'] as bool?) ?? false;
                  if ((record['hasVideo'] as bool?) ?? false) {
                    foldersWithVideo.add(relPath);
                  }
                  seenFolders.add(relPath);
                  if (!isStub) {
                    listedRelPaths.add(relPath);
                    final abs = record['path'] as String?;
                    if (abs != null && abs.isNotEmpty) {
                      listedFolderPaths.add(abs);
                    }
                  }
                  // 源根那一行的名字用源的显示名（用户自己起的），而不是磁盘上那截
                  // 目录名——他在来源列表里看到的是哪个名字，进去之后就该还是哪个。
                  final name = relPath.isEmpty
                      ? currentSource.displayName
                      : relPath.split('/').last;
                  (isStub ? stubs : folders).add(
                    LocalMediaFolder(
                      id: LocalMediaFolder.buildId(currentSource.id, relPath),
                      sourceId: currentSource.id,
                      relPath: relPath,
                      // 源根是树顶，没有上一级：null 而不是空字符串。空字符串是
                      // 「我的父亲是源根」的意思，两者不能混。
                      parentRelPath: relPath.isEmpty
                          ? null
                          : _parentRelPath(relPath),
                      name: name,
                      sortName: naturalSortKey(name),
                      folderPath: record['path'] as String?,
                      coverPath: record['cover'] as String?,
                      modifiedAt: record['modified'] as int?,
                    ),
                  );
                }
                if (folders.isNotEmpty || stubs.isNotEmpty) {
                  try {
                    if (folders.isNotEmpty) _repository.upsertFolders(folders);
                    if (stubs.isNotEmpty) _repository.upsertFolderStubs(stubs);
                  } catch (e) {
                    LogUtils.e('写入扫描目录批次失败', tag: _tag, error: e);
                  }

                  // ⭐ 纯视频目录封面代表入队派生：
                  // 针对本轮真正扫描到的目录（排除 stub），若未 pin 且尚无封面，
                  // 挑出该目录下首个缺少缩略图的视频入队派生，生成缩略图后自动回填目录封面。
                  try {
                    final derivation = _derivationService;
                    if (derivation != null &&
                        foldersWithVideo.isNotEmpty &&
                        enqueuedFolderCovers <
                            kMaxFolderCoverDerivationEnqueuedPerScan) {
                      // ⛔ 一条 IN 查询问清「这批里谁还缺封面」，不要逐个 [getFolder]
                      // 点查：封顶常量只封入队数，封不住点查次数，几千目录的树就是
                      // 几千次同步 select 全压在主 isolate 上。
                      final needing = _repository.foldersNeedingCover(
                        sourceId: currentSource.id,
                        relPaths: [
                          for (final f in folders)
                            if (foldersWithVideo.contains(f.relPath)) f.relPath,
                        ],
                      );
                      for (final folder in folders) {
                        if (!foldersWithVideo.contains(folder.relPath)) {
                          continue;
                        }
                        if (enqueuedFolderCovers >=
                            kMaxFolderCoverDerivationEnqueuedPerScan) {
                          break;
                        }
                        // 不在 needing 里 = 已 pin / 已有封面，跳过。
                        // 在里面但值是空串 = 库里那一列空着，拿刚扫出来的路径兜底。
                        final known = needing[folder.relPath];
                        if (known == null) continue;
                        final absPath = known.isEmpty
                            ? folder.folderPath
                            : known;
                        if (absPath == null || absPath.isEmpty) continue;

                        final candidate = _repository
                            .firstVideoNeedingThumbInFolder(
                              sourceId: currentSource.id,
                              folderPath: absPath,
                            );
                        if (candidate != null) {
                          enqueuedFolderCovers++;
                          unawaited(
                            derivation.enqueue(
                              candidate,
                              generateThumbnail: true,
                              background: true,
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    LogUtils.w('挑选并入队目录封面代表失败: $e', _tag);
                  }
                }
                await Future<void>.delayed(Duration.zero);
                requestNext();
              case 'done':
                truncated = message['truncated'] as bool? ?? false;
                final failedFolders = (message['failedFolders'] as List?)
                    ?.cast<String>();
                final rawFailedFolderRels =
                    (message['failedFolderRels'] as List?)?.cast<String>();
                final failedFolderRels = rawFailedFolderRels?.map((rel) {
                  if (scopeRelPath.isEmpty) return rel;
                  return rel.isEmpty ? scopeRelPath : '$scopeRelPath/$rel';
                }).toList();
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
                  seenFolders: seenFolders,
                  failedFolderRels: failedFolderRels,
                  scoped: scoped,
                  scopeRelPath: scopeRelPath,
                  listedRelPaths: listedRelPaths,
                  listedFolderPaths: listedFolderPaths,
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
                  scoped: scoped,
                  scopeRelPath: scopeRelPath,
                  listedRelPaths: listedRelPaths,
                  listedFolderPaths: listedFolderPaths,
                );
            }
          } catch (e, st) {
            LogUtils.e('处理扫描消息失败，本轮按出错收尾', tag: _tag, error: e, stackTrace: st);
            _abortRun(
              currentSource,
              running,
              generation: generation,
              error: '$e',
              scoped: scoped,
              scopeRelPath: scopeRelPath,
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
              'maxDepth': maxDepth,
              'maxFiles': kMaxScanFiles,
              'maxFolders': kMaxScanFolders,
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
            scoped: scoped,
            scopeRelPath: scopeRelPath,
            listedRelPaths: listedRelPaths,
            listedFolderPaths: listedFolderPaths,
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
    } catch (e, s) {
      LogUtils.e('扫描过程抛出异常，收尾并还闸', tag: _tag, error: e, stackTrace: s);
      _abortRun(
        currentSource,
        running,
        generation: generation,
        error: '$e',
        scoped: scoped,
        scopeRelPath: scopeRelPath,
      );
    }
  }

  /// 异常路径的收尾：先尽量走 [_finish]（回写源状态、进度带错误），它自己再抛
  /// 也要把 isolate 收掉、闸门还回去。
  void _abortRun(
    LocalMediaSource source,
    Completer<void> running, {
    required int generation,
    required String error,
    bool scoped = false,
    String scopeRelPath = '',
  }) {
    try {
      _finish(
        source,
        const <String>{},
        progress.value?.discovered ?? 0,
        false,
        error,
        running,
        offline: false,
        generation: generation,
        scoped: scoped,
        scopeRelPath: scopeRelPath,
      );
    } catch (e) {
      LogUtils.e('异常收尾时 _finish 再次失败', tag: _tag, error: e);
    }
    if (_isCurrent(generation, running)) {
      _teardown();
      running.complete();
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
    final seen = <String>{};
    int? afterModifiedAtSeconds;
    int? afterMediaStoreId;
    var discovered = 0;
    String? failure;

    // ⛔ 占闸之后的同步写读库都要落在 try 里，抛出去就是闸门永远不还，见 [_scanTree]。
    try {
      _repository.upsertSource(
        source.copyWith(scanState: LocalMediaScanState.scanning),
      );
      final known = _repository.fingerprints(source.id);
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
        final resolvedPaths = <String?>[
          for (final record in records) _resolveMediaStorePath(record),
        ];
        // ⛔ 只问这一页的路径归不归别人管，不要一开头把「别的源全部路径」整张
        // 拉进内存：显式来源一大，那张 Set 就是几万条字符串常驻整轮扫描。
        final ownedElsewhere = _repository.pathsOwnedElsewhereAmong(source.id, [
          for (var i = 0; i < records.length; i++)
            resolvedPaths[i] ?? records[i].contentUri,
        ]);
        for (var i = 0; i < records.length; i++) {
          final record = records[i];
          final resolved = resolvedPaths[i];
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
          const kind = LocalMediaItemKind.video;
          final fingerprint = known[hash];
          final hasMetadata = switch (kind) {
            LocalMediaItemKind.video =>
              fingerprint != null &&
                  (fingerprint.hasMetadata || fingerprint.metaProbed),
            LocalMediaItemKind.image => fingerprint?.hasImageMetadata ?? false,
          };
          final item = LocalMediaItem(
            id: LocalMediaItem.buildId(source.id, hash),
            sourceId: source.id,
            pathHash: hash,
            path: identityPath,
            mediaStoreUri: record.contentUri,
            kind: kind,
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
  ///
  /// ⭐ 每个卷「哪个挂载点是对的」探明一次就记进 [_mountByVolume]，之后同卷的每条
  /// 只 existsSync 那一个候选；对不上（文件不在那儿、或挂载点变了）才回退把其余
  /// 候选重探一遍并更新缓存。以前每条都要把两三个候选挨个 stat，一页 400 条全压在
  /// 主 isolate 上。
  static final Map<String, String> _mountByVolume = <String, String>{};

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

      final volumeKey = volume ?? '';
      final cachedMount = _mountByVolume[volumeKey];
      if (cachedMount != null) {
        final candidate = p.normalize(
          p.join(cachedMount, relativePath, displayName),
        );
        if (File(candidate).existsSync()) return candidate;
      }
      for (final mount in candidates) {
        if (mount == cachedMount) continue;
        final candidate = p.normalize(p.join(mount, relativePath, displayName));
        if (File(candidate).existsSync()) {
          _mountByVolume[volumeKey] = mount;
          return candidate;
        }
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

    /// 这一轮走到过的目录（rel_path）。
    ///
    /// ⛔ **为 null 表示"这个源没有目录树"，不是"这轮一个目录都没走到"**。
    /// 「已下载」（从下载任务同步、没有稳定根路径）和 MediaStore（整机广播式索引、
    /// 压根没有单一根目录）都走这条：它们不传，于是下面的目录收敛与统计回填
    /// 整段跳过，不会平白给它们建出一棵假树来。
    Set<String>? seenFolders,
    List<String>? failedFolderRels,
    bool scoped = false,
    Set<String>? listedRelPaths,
    Set<String>? listedFolderPaths,
    String scopeRelPath = '',
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

    final effectiveListedFolderPaths = Set<String>.from(
      listedFolderPaths ?? const <String>{},
    );
    final effectiveListedRelPaths = Set<String>.from(
      listedRelPaths ?? const <String>{},
    );
    if (failedFolders != null && failedFolders.isNotEmpty) {
      effectiveListedFolderPaths.removeAll(failedFolders);
    }
    if (failedFolderRels != null && failedFolderRels.isNotEmpty) {
      effectiveListedRelPaths.removeAll(failedFolderRels);
    }

    // ⛔ 只有**扫完了**才收敛 missing。中途出错/被截断时不能收敛：没走到的那一半
    // 会被冤枉成"文件没了"，用户看到的是列表凭空少了一半。
    // ⭐ 有读不动的子目录时，**只把那几棵子树排除在收敛之外**，其余照常收敛。
    //
    // ⛔ 不能反过来写成"只收敛走到过的目录"：整个文件夹被用户删掉时，它既不在
    // 失败清单里、也不会出现在走到过的清单里（父目录列不出它了），于是那一整个
    // 目录的条目永远收敛不掉，变成一堆点不开的幽灵卡片。
    if (allowMissing && error == null && !truncated) {
      if (scoped) {
        // ⛔ 目录级扫描**绝不能**用整源的 markMissingExcept。
        //
        // 那个方法先把整源置 missing 再把见到的洗回来，前提是「这一轮走遍了全树」。
        // 一轮只看了一层还这么干，等于宣布「这个源里除了刚才那一层，其余全没了」——
        // 整个库当场清空。
        try {
          _repository.markItemsMissingExceptInFolders(
            sourceId: source.id,
            listedFolderPaths: effectiveListedFolderPaths,
            seenHashes: seen,
          );
        } catch (e) {
          LogUtils.e('目录级收敛条目 missing 失败', tag: _tag, error: e);
          effectiveError = '$e';
        }

        try {
          _repository.markChildFoldersMissingExceptUnder(
            sourceId: source.id,
            listedRelPaths: effectiveListedRelPaths,
            seenRelPaths: seenFolders ?? const <String>{},
          );
        } catch (e) {
          LogUtils.e('目录级收敛目录 missing 失败', tag: _tag, error: e);
          effectiveError = '$e';
        }
      } else {
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

        // 目录用**同一口径**收敛：整源先置 missing、这轮走到过的洗回来、读不动的
        // 子树整棵豁免。上面那段关于"不能只收敛走到过的"的血泪同样适用于目录——
        // 用户在文件管理器里整个删掉一个文件夹时，它既不在失败清单里也不在 seen 里。
        if (seenFolders != null) {
          try {
            _repository.markFoldersMissingExcept(
              source.id,
              seenFolders,
              excludeRelPathTrees: <String>{...?failedFolderRels},
            );
          } catch (e) {
            LogUtils.e('收敛目录 missing 失败', tag: _tag, error: e);
            effectiveError = '$e';
          }
        }
      }
    }

    // 只有真的列过的目录才算探过。占位记录进不来，所以它们的 probed_at 保持 NULL，
    // 「不知道里面有什么，先显示着」——正是我们要的。
    // ⛔ 必须排在两次收敛之后、backfillFolderCounts 之前：backfill 里判「这个目录有没有东西」
    // 要读 probed_at，读到旧值就会把刚探明的空目录又当成"不知道"留着。
    if (effectiveError == null && effectiveListedRelPaths.isNotEmpty) {
      try {
        _repository.markFoldersProbed(
          sourceId: source.id,
          relPaths: effectiveListedRelPaths,
        );
      } catch (e) {
        LogUtils.e('标记目录已探测失败', tag: _tag, error: e);
        effectiveError = '$e';
      }
    }

    // ⭐ 统计数（直接子视频数 / 图片数 / 子目录数）一次性回填，**绝不在扫描途中
    // 增量维护**：边扫边给每个父目录 +1，会把 300 条一批的写事务放大成上千次
    // 额外 UPDATE，而写库全在主 isolate、sqlite3 又是同步 API——那就是直接卡 UI。
    // 一条走覆盖索引的 GROUP BY 几十毫秒就够了。
    //
    // 必须排在两次 missing 收敛**之后**：它只数 missing = 0 的行，先收敛才数得准。
    if (seenFolders != null && effectiveError == null) {
      try {
        if (scoped) {
          // 目录级：只重算列过的目录和祖先链，见方法注释。
          _repository.backfillFolderCountsInScope(
            sourceId: source.id,
            scopeRelPath: scopeRelPath,
            listedRelPaths: effectiveListedRelPaths,
          );
        } else {
          _repository.backfillFolderCounts(source.id);
        }
      } catch (e) {
        LogUtils.e('回填目录统计数失败', tag: _tag, error: e);
      }
    }

    // ⭐ 封面沿树往上借。扫描器从直属图片 / sidecar 填的封面自己不冒泡，
    // 不补这一步，「A 里只有 B、B 有封面」的 A 永远空着，进出多少次都一样。
    // 读不动的目录也照做：借封面只看库里已有的行，不依赖这一轮是否扫完整。
    if (seenFolders != null && effectiveListedRelPaths.isNotEmpty) {
      try {
        _repository.propagateFolderCovers(
          sourceId: source.id,
          relPaths: effectiveListedRelPaths,
        );
      } catch (e) {
        LogUtils.e('向上传播目录封面失败', tag: _tag, error: e);
      }
    }

    try {
      if (scoped) {
        _repository.upsertSource(
          source.copyWith(
            itemCount: _repository.countItems(sourceId: source.id),
            offline: offline,
          ),
        );
      } else {
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
      }
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
    // 源被删时（带 sourceId 的调用只来自「移除来源」），它排着的目录扫描也一起丢。
    if (sourceId != null) _dropQueuedFolderScans(sourceId);
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
    _scheduleFolderPump();
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
    _closed = true;
    _dropQueuedFolderScans();
    _scanGeneration++;
    _teardown();
    super.onClose();
  }

  /// `'a/b/c'` → `'a/b'`；`'a'` → `''`（父亲是源根）。
  ///
  /// 只切 rel_path，不碰绝对路径——rel_path 一律是 `/` 分隔的，所以这里
  /// **不能**用 `p.dirname`：那玩意在 Windows 上认 `\`，会把整串原样还回来。
  static String _parentRelPath(String relPath) {
    final index = relPath.lastIndexOf('/');
    return index < 0 ? '' : relPath.substring(0, index);
  }

  static String _hashPath(String path) =>
      sha1.convert(utf8.encode(path)).toString();

  /// ⛔ 扫描发起的派生一律是**后台**优先级：卡片滚进视野的请求永远插在它们前面，
  /// 且后台那条队列有上限（见 [LocalMediaDerivationService.enqueue]）。
  ///
  /// 以前这里是前台同级、不封顶：进一次两千个视频的 Download，两千个「开 libmpv、
  /// 打开视频解码、读几个属性、关掉」连着排进同一条队列，跟用户这一屏毫无关系，
  /// 却把他正看着的那几张卡压在最后面，还让原生层持续高负荷。
  void _enqueueDerivation(Iterable<LocalMediaItem> items) {
    final service = _derivationService;
    if (service == null) return;
    unawaited(service.enqueueAll(items, background: true));
  }
}

class _QueuedFolderScan {
  _QueuedFolderScan(this.source, this.relPath);

  LocalMediaSource source;
  final String relPath;
  final Completer<void> completer = Completer<void>();
}

// ── isolate 侧 ────────────────────────────────────────────────────────────

/// 扫描 worker。**只碰文件系统**，不碰数据库、不碰 GetX。
///
/// 遍历是手写的显式栈而不是 `Directory.list(recursive: true)`，为的是三件
/// 后者给不了的东西：**深度上限**、**按目录整棵跳过**（`.` 开头目录 / 目录名黑名单，
/// ⛔ 不含 `.nomedia`，见下面 `files` 收集处）、
/// 以及 ⭐ **sidecar 匹配**——同名封面必须在"手上正好有这个目录的清单"时匹配，
/// 逐个文件去 `existsSync` 是一次白白多出来的 IO。
///
/// ⛔ 软链接：`listSync(followLinks: false)` 会把符号链接报成 [Link] 而不是
/// [Directory]，我们只往 [Directory] 里递归，于是循环目录天然走不进去，
/// 不需要另外记 realpath。
///
/// ⛔ 背压是拉取式的：每 flush 一批就停下等主 isolate 回 `next`（见主 isolate 那边
/// `requestNext` 的注释）。主 isolate 收掉这一轮时直接 kill 本 isolate，所以这边
/// 不需要处理「取消」消息——等 `next` 的那一下会连同 isolate 一起消失。
Future<void> _scanWorkerEntry(Map<String, Object?> args) async {
  final send = args['send'] as SendPort;
  final control = ReceivePort();
  final acks = StreamIterator<dynamic>(control);
  send.send(<String, Object?>{'type': 'hello', 'port': control.sendPort});

  /// 发出一批后等主 isolate 放行。返回 false = 端口已关，别再往下走。
  Future<bool> awaitNext() async {
    while (await acks.moveNext()) {
      if (acks.current == 'next') return true;
    }
    return false;
  }

  final root = args['root'] as String;
  final recursive = args['recursive'] as bool? ?? true;
  final maxDepth = args['maxDepth'] as int? ?? kMaxScanDepth;
  final maxFiles = args['maxFiles'] as int? ?? kMaxScanFiles;
  final maxFolders = args['maxFolders'] as int? ?? kMaxScanFolders;
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

  // ⭐ 走到过的目录**要**全量回传：目录自 v31 起是一张真表（`local_media_folders`），
  // 树形浏览每一次下钻都靠它做点查。这里回传的就是那张表的原料。
  //
  // ⛔ 但绝不能攒到 'done' 再一把送走——那正是这段代码上一版的写法（当时的注释是
  // 「只回传读不动的目录」），在几万个目录的树上是一大笔白白占住的内存加一次巨大的
  // SendPort 拷贝。规矩跟文件那侧完全一样：**满一批就 flush**，主 isolate 按批写库、
  // 批与批之间让一帧出去。谁要是又想把它改回"攒到最后"，先看这段。
  final folderBatch = <Map<String, Object?>>[];

  // 读不动的目录：收敛 missing 时这几棵子树连同底下的一切整棵豁免，
  // 见 [LocalMediaScanService._finish]。
  final failedFolders = <String>[];
  var total = 0;
  var folderTotal = 0;
  var truncated = false;
  var stopped = false;
  String? failure;
  var offline = false;

  Future<void> flush() async {
    if (batch.isEmpty || stopped) return;
    send.send(<String, Object?>{
      'type': 'batch',
      'files': List<Map<String, Object?>>.from(batch),
    });
    batch.clear();
    if (!await awaitNext()) stopped = true;
  }

  Future<void> flushFolders() async {
    if (folderBatch.isEmpty || stopped) return;
    // 文件先落库再发目录：主 isolate 收到目录批次时要按目录挑「缺封面的视频」，
    // 那几条视频还压在文件批次里没发的话，一条都挑不出来。
    await flush();
    if (stopped) return;
    send.send(<String, Object?>{
      'type': 'folders',
      'folders': List<Map<String, Object?>>.from(folderBatch),
    });
    folderBatch.clear();
    if (!await awaitNext()) stopped = true;
  }

  /// 目录记录进批次。撞上 [maxFolders] 返回 false，调用方就地停下。
  Future<bool> addFolder(Map<String, Object?> record) async {
    if (folderTotal >= maxFolders) {
      truncated = true;
      return false;
    }
    folderBatch.add(record);
    folderTotal++;
    if (folderBatch.length >= batchSize) await flushFolders();
    return !stopped;
  }

  /// 绝对路径 → **相对源根**的路径。源根本身是空字符串。
  ///
  /// ⛔ 一律用 `/` 分隔，哪怕在 Windows 上：`rel_path` 是目录树的**权威身份**
  /// （见 `migration_v31_local_media_folders.dart` 的表注释），它必须跨平台、
  /// 跨"源根路径变了"稳定——iOS 沙盒容器 UUID 每次升级都可能漂移，绝对路径会
  /// 整批失效，而相对路径一行都不用动。
  String relPathOf(String absolute) {
    final rel = p.relative(p.normalize(absolute), from: p.normalize(root));
    if (rel == '.' || rel.isEmpty) return '';
    return p.split(rel).join('/');
  }

  try {
    final stack = <({Directory dir, int depth})>[
      (dir: Directory(root), depth: 0),
    ];
    while (stack.isNotEmpty && !stopped) {
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
        final normalized = p.normalize(current.dir.path);
        failedFolders.add(normalized);

        // ⛔ 读不动的目录**也必须留一行占位**，不能只记进 failedFolders 就走。
        //
        // 父目录列得出它（它是父目录 entries 里的一个 Directory），所以它既不在
        // `seenFolders` 里也不会有自己的行——如果这里 `continue` 掉，这个目录在
        // `local_media_folders` 里**一行都没有**，浏览页的 `childFolders` 自然查
        // 不到它。表现就是用户在树里根本看不见这个文件夹，连点进去重试的机会都
        // 没有；而它上层那些能列出来的文件照旧入库，于是症状精确地长成
        // 「只有这一层的视频/图片被识别，子文件夹全部不见了」。
        //
        // Android 上这是**默认形态**而不是边角：只有 READ_MEDIA_* 而没有「所有文件
        // 访问」时，scoped storage 的 FUSE 会拦住对子目录的 list，Download 根能列、
        // 它下面每个子目录都抛 EACCES。整棵树就此消失。
        //
        // 占位行走 `stub: true`（upsert 是 DO NOTHING）：probed_at 保持 NULL，
        // 于是它照常出现在列表里，用户点进去会触发一次目录级扫描再试一次——这正是
        // 我们要的「读不动就先让人看见」，而不是静默抹掉。
        if (!await addFolder(<String, Object?>{
          'path': normalized,
          'rel': relPathOf(normalized),
          'modified': null, // 没列成，别猜
          'cover': null,
          'stub': true,
        })) {
          break;
        }
        continue;
      }

      final files = <File>[];
      final subdirs = <Directory>[];
      for (final entry in entries) {
        if (entry is Directory) {
          subdirs.add(entry);
        } else if (entry is File) {
          // ⛔ 这里**故意不认 `.nomedia`**（行为变更，之前是遇到就整棵子树跳过）。
          //
          // `.nomedia` 是**系统媒体扫描器（MediaStore / 系统相册）**的约定，不是
          // 文件浏览器的约定——VLC、MX Player、Solid Explorer 这些都不认它。而
          // 我们这个源是**用户自己指过来的目录**，他的意图就是「把这里的东西给我看」。
          //
          // 真机上的事故正是这条规则造成的：第三方下载器会在每集目录里塞一个
          // `.nomedia` 把内容挡在系统相册之外，于是 `Download/hanime_download/407963/`
          // 里的视频**永远进不了库**。更糟的是那个目录走的是"压栈"分支、**一行都不留**，
          // 于是父目录的目录级扫描收敛时把它判成 missing=1：
          // 用户看到的是一张点进去写着「这个文件夹是空的」的卡片，**且没有任何解释**。
          //
          // 隐私口径没有因此失守：`.` 开头的目录和 [kSkippedDirectoryNames] 照旧整棵
          // 跳过——那才是"隐藏"的通用约定，也是用户真正会用来藏东西的方式。应用自己的
          // 缩略图缓存仍然靠 `.nomedia` 挡系统相册（见 LocalMediaDerivationService），
          // 它在 cache 目录里，不在任何源下面，不受这里影响。
          //
          // `.nomedia` 本身不是媒体扩展名，落进 `files` 后会被扩展名过滤自然丢掉。
          files.add(entry);
        }
      }

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
        if (batch.length >= batchSize) await flush();
        if (total >= maxFiles) {
          truncated = true;
          break;
        }
        if (stopped) break;
      }
      if (truncated || stopped) break;

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
          if (batch.length >= batchSize) await flush();
          if (total >= maxFiles) {
            truncated = true;
            break;
          }
          if (stopped) break;
        }
        if (truncated || stopped) break;
      }

      // ⭐ 目录本身入表。
      //
      // 位置很关键：必须放在**文件都过完之后**，因为封面要挑一张「不是 sidecar」
      // 的图——sidecar 是某个视频的封面，不是这个目录的代表作，拿它当目录封面
      // 会让一个满是视频的文件夹显示成某一集的截图。
      String? cover;
      String? sidecarCover;
      for (final file in files) {
        if (!imageExts.contains(_extensionOf(file.path))) continue;
        final isSidecar = claimedSidecars.contains(file.path);
        final key = naturalSortKey(p.basename(file.path));
        if (isSidecar) {
          if (sidecarCover == null ||
              key.compareTo(naturalSortKey(p.basename(sidecarCover))) < 0) {
            sidecarCover = file.path;
          }
        } else if (cover == null ||
            key.compareTo(naturalSortKey(p.basename(cover))) < 0) {
          cover = file.path;
        }
      }
      cover ??= sidecarCover;

      // ⛔ `statSync()` 不抛异常（见上面文件那侧的长注释）：量不到时它返回一个
      // `type = notFound` 的 FileStat，`modified` 是纪元零点。所以判据是 **type**，
      // 不是 try/catch——把纪元零点当成"这个目录 1970 年改过"写进库，
      // 「最近修改」那一档排序就全乱了。
      int? folderModified;
      final dirStat = current.dir.statSync();
      if (dirStat.type == FileSystemEntityType.directory) {
        folderModified = dirStat.modified.millisecondsSinceEpoch;
      }

      if (!await addFolder(<String, Object?>{
        // 绝对路径必须 normalize：条目那侧的 folder_path 走的是
        // `p.dirname(file.path)`，两边对不上就 join 不起来（backfill 就是按它对齐的）。
        'path': p.normalize(current.dir.path),
        'rel': relPathOf(current.dir.path),
        'modified': folderModified,
        'cover': cover,
        // 主 isolate 只为有视频的目录挑封面代表，省掉对纯图片/空目录的点查。
        'hasVideo': collectVideos && videoStems.isNotEmpty,
      })) {
        break;
      }

      final visibleSubdirs = <Directory>[];
      for (final dir in subdirs) {
        final name = p.basename(dir.path);
        if (name.startsWith('.')) continue;
        if (skipDirs.contains(name.toLowerCase())) continue;
        visibleSubdirs.add(dir);
      }

      if (recursive && current.depth < maxDepth) {
        for (final dir in visibleSubdirs) {
          stack.add((dir: dir, depth: current.depth + 1));
        }
      } else {
        for (final dir in visibleSubdirs) {
          if (!await addFolder(<String, Object?>{
            'path': p.normalize(dir.path),
            'rel': relPathOf(dir.path),
            'modified': null, // 没 stat，别猜
            'cover': null, // 没列过，不知道封面
            'stub': true, // ← 新字段：只是「知道有这么个目录」，没看过里面
          })) {
            break;
          }
        }
        if (truncated || stopped) break;
      }
    }

    await flushFolders();
    await flush();
    if (stopped) {
      control.close();
      return;
    }
    send.send(<String, Object?>{
      'type': 'done',
      'truncated': truncated,
      'error': failure,
      'offline': offline,
      'failedFolders': failedFolders,
      // 目录那侧按 rel_path 收敛，所以豁免清单也得是 rel_path。在这里换算而不是
      // 让主 isolate 再算一遍：`root` 在这边，换算规则只该有一份。
      'failedFolderRels': <String>[
        for (final folder in failedFolders) relPathOf(folder),
      ],
    });
  } catch (e) {
    try {
      await flushFolders();
      await flush();
    } catch (_) {}
    send.send(<String, Object?>{
      'type': 'error',
      'message': '$e',
      'offline': !_directoryExistsInWorker(root),
    });
  }
  control.close();
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
