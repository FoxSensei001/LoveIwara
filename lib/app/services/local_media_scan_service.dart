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
import 'package:i_iwara/app/utils/natural_sort_key.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 认得的视频扩展名。`Download/` 是**混装**的（apk / exe / zip 与视频躺在一起），
/// 所以扩展名过滤不是优化，是必需。
const Set<String> kLocalVideoExtensions = <String>{
  'mp4', 'mkv', 'webm', 'avi', 'mov', 'm4v', 'wmv', 'flv', 'ts', '3gp', 'mpg',
  'mpeg', 'm2ts', 'rmvb', 'ogv',
};

/// 同目录同名封面认得的扩展名（⭐ sidecar，见 [_ScanWorker]）。
const Set<String> kSidecarImageExtensions = <String>{
  'jpg', 'jpeg', 'png', 'webp', 'avif',
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
  Completer<void>? _running;

  bool get isScanning => _running != null && !_running!.isCompleted;

  /// 扫一个源。同一时刻只跑一个——并发扫两个目录只会让两边都变慢，
  /// 而且写库那一侧本来就是串行的。
  Future<void> scanSource(LocalMediaSource source) async {
    final root = source.path;
    if (root == null || root.isEmpty) {
      LogUtils.w('源 ${source.id} 没有路径，跳过扫描', _tag);
      return;
    }
    if (isScanning) {
      LogUtils.i('已有扫描在跑，忽略本次请求', _tag);
      return;
    }

    final running = Completer<void>();
    _running = running;
    progress.value = LocalMediaScanProgress(
      sourceId: source.id,
      discovered: 0,
      finished: false,
    );
    _repository.upsertSource(
      source.copyWith(scanState: LocalMediaScanState.scanning),
    );

    final port = ReceivePort();
    _port = port;

    // 增量比对用的指纹：只有大小或修改时间变了的才需要重算内容派生字段。
    final known = _repository.fingerprints(source.id);
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
      // ⛔ isolate 意外死亡的两种形状必须接住，否则 `_running` 永远不完成、
      // 页面就一直卡在"扫描中"：
      //   - `onError` 送回来的是 [error, stackTrace] 这样一个 List；
      //   - `onExit` 送回来的是 null。
      if (message is List) {
        _finish(source, seen, discovered, truncated, '${message.first}', running);
        return;
      }
      if (message == null) {
        // 正常走完时 'done' 已经先到并完成了 running，这里就是个 no-op。
        _finish(source, seen, discovered, truncated, null, running);
        return;
      }
      if (message is! Map) return;
      subscription.pause();
      switch (message['type'] as String?) {
        case 'batch':
          final records = (message['files'] as List).cast<Map>();
          final items = <LocalMediaItem>[];
          final now = DateTime.now().millisecondsSinceEpoch;
          for (final record in records) {
            final path = record['path'] as String;
            final hash = _hashPath(path);
            seen.add(hash);
            final size = record['size'] as int?;
            final modified = record['modified'] as int?;
            final fingerprint = known[hash];
            // 没变过的老条目连 upsert 都不用发——省掉的是整批事务里最不值钱的那部分写。
            if (fingerprint != null &&
                fingerprint.sizeBytes == size &&
                fingerprint.modifiedAt == modified) {
              continue;
            }
            final name = p.basename(path);
            items.add(
              LocalMediaItem(
                id: LocalMediaItem.buildId(source.id, hash),
                sourceId: source.id,
                pathHash: hash,
                path: path,
                kind: LocalMediaItemKind.video,
                name: name,
                sortName: naturalSortKey(name),
                ext: (record['ext'] as String?)?.toLowerCase(),
                sizeBytes: size,
                modifiedAt: modified,
                sidecarImagePath: record['sidecar'] as String?,
                folderPath: p.dirname(path),
                addedAt: now,
              ),
            );
          }
          discovered += records.length;
          if (items.isNotEmpty) {
            try {
              _repository.upsertItems(items);
            } catch (e) {
              LogUtils.e('写入扫描批次失败', tag: _tag, error: e);
            }
          }
          progress.value = LocalMediaScanProgress(
            sourceId: source.id,
            discovered: discovered,
            finished: false,
          );
          // 让一帧出去，再放行下一批。
          await Future<void>.delayed(Duration.zero);
          // ⛔ 只有 batch 这一支才 resume：'done'/'error' 走 [_finish]，
          // 那里已经把 port 关掉了，再去 resume 一个已结束的订阅没有意义。
          if (subscription.isPaused) subscription.resume();
        case 'done':
          truncated = message['truncated'] as bool? ?? false;
          _finish(source, seen, discovered, truncated, null, running);
        case 'error':
          failure = message['message'] as String?;
          _finish(source, seen, discovered, truncated, failure, running);
      }
    });

    try {
      _isolate = await Isolate.spawn(
        _scanWorkerEntry,
        <String, Object?>{
          'send': port.sendPort,
          'root': root,
          'recursive': source.recursive,
          'maxDepth': kMaxScanDepth,
          'maxFiles': kMaxScanFiles,
          'batchSize': kScanBatchSize,
          'videoExts': kLocalVideoExtensions.toList(),
          'imageExts': kSidecarImageExtensions.toList(),
          'skipDirs': kSkippedDirectoryNames.toList(),
        },
        errorsAreFatal: true,
        onError: port.sendPort,
        onExit: port.sendPort,
      );
    } catch (e) {
      LogUtils.e('启动扫描 isolate 失败', tag: _tag, error: e);
      _finish(source, seen, discovered, truncated, '$e', running);
    }

    return running.future;
  }

  void _finish(
    LocalMediaSource source,
    Set<String> seen,
    int discovered,
    bool truncated,
    String? error,
    Completer<void> running,
  ) {
    if (running.isCompleted) return;

    // ⛔ 只有**扫完了**才收敛 missing。中途出错/被截断时不能收敛：没走到的那一半
    // 会被冤枉成"文件没了"，用户看到的是列表凭空少了一半。
    if (error == null && !truncated) {
      try {
        _repository.markMissingExcept(source.id, seen);
      } catch (e) {
        LogUtils.e('收敛 missing 失败', tag: _tag, error: e);
      }
    }

    try {
      _repository.upsertSource(
        source.copyWith(
          scanState: error == null
              ? LocalMediaScanState.idle
              : LocalMediaScanState.interrupted,
          lastScanAt: DateTime.now().millisecondsSinceEpoch,
          itemCount: _repository.countItems(sourceId: source.id),
          offline: false,
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
      error: error,
    );
    _teardown();
    running.complete();
  }

  /// 用户离开页面 / 换源：把 isolate 收掉，别让它在后台接着刨盘。
  void cancel() {
    if (!isScanning) return;
    LogUtils.i('用户取消扫描', _tag);
    final running = _running;
    _teardown();
    if (running != null && !running.isCompleted) running.complete();
  }

  void _teardown() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port?.close();
    _port = null;
    _running = null;
  }

  @override
  void onClose() {
    _teardown();
    super.onClose();
  }

  static String _hashPath(String path) =>
      sha1.convert(utf8.encode(path)).toString();
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

  final batch = <Map<String, Object?>>[];
  var total = 0;
  var truncated = false;

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
      } catch (_) {
        // ⛔ 单个目录读不动**不能**中断整次扫描：权限、坏扇区、Windows 超长路径
        // 都会让某一个目录抛，而用户要的是"其余的都扫到"。
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

      for (final file in files) {
        final ext = _extensionOf(file.path);
        if (!videoExts.contains(ext)) continue;
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
        final stat = file.statSync();
        if (stat.type != FileSystemEntityType.notFound) {
          size = stat.size;
          modified = stat.modified.millisecondsSinceEpoch;
        }
        batch.add(<String, Object?>{
          'path': file.path,
          'ext': ext,
          'size': size,
          'modified': modified,
          'sidecar':
              imagesByStem[p.basenameWithoutExtension(file.path).toLowerCase()],
        });
        total++;
        if (batch.length >= batchSize) flush();
        if (total >= maxFiles) {
          truncated = true;
          break;
        }
      }
      if (truncated) break;

      if (!recursive || current.depth >= maxDepth) continue;
      for (final dir in subdirs) {
        final name = p.basename(dir.path);
        if (name.startsWith('.')) continue;
        if (skipDirs.contains(name.toLowerCase())) continue;
        stack.add((dir: dir, depth: current.depth + 1));
      }
    }

    flush();
    send.send(<String, Object?>{'type': 'done', 'truncated': truncated});
  } catch (e) {
    flush();
    send.send(<String, Object?>{'type': 'error', 'message': '$e'});
  }
}

String _extensionOf(String path) {
  final ext = p.extension(path);
  if (ext.isEmpty) return '';
  return ext.substring(1).toLowerCase();
}
