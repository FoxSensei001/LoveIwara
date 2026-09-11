import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_source.model.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/local_media_derivation_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/utils/natural_sort_key.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 把「已下载」同步成本地库里的一个**真实源**。
///
/// # ⛔ 它不扫目录，它是从 `download_tasks` 同步过来的
///
/// 别的源靠 [LocalMediaScanService] 走一遍目录树；这个源不走。理由是四条，
/// 每一条单独都够：
///
/// 1. **没有"那个目录"**。`save_path` 是每个任务各自的绝对路径，而下载目录是
///    用户可以随时改的设置——改之前下的片子还留在老地方。盯着"当前下载目录"
///    扫，等于用户一改设置，从前下的东西就整批从库里消失。
/// 2. **关联是精确的**。同步天然拿得到 `task.id`，不必事后拿路径去回猜；而
///    `download_task_id` 正是标题/作者/封面/「退回在线播」这些装饰的来源。
/// 3. **图集是目录不是文件**。图库任务的 `save_path` 指向一个文件夹，扫描器
///    没有办法把它和"一个视频文件"区分开，这里一句 `mediaType` 就分掉了。
/// 4. **即时**。刚下完的片子应该立刻出现在「已下载」里，而不是等下一次重扫。
///
/// 文件系统只用来做一件事：**stat**（大小/修改时间），而这正是"这还是不是同一
/// 个文件"的唯一判据。
///
/// # ⛔ 绝不反向写 `download_tasks`
///
/// 关联是单向的：本地条目挂一个 `download_task_id` 当装饰。往任务表里塞假任务
/// 会撞 v17 的冲突触发器，还会让下载页的暂停/重试/删除作用在一个没有下载的
/// 东西上（工作线文档 §2.3）。
class DownloadsLibrarySyncService extends GetxService {
  DownloadsLibrarySyncService({
    LocalMediaRepository? repository,
    DownloadTaskRepository? downloads,
  }) : _repository = repository ?? LocalMediaRepository(),
       _downloads = downloads ?? DownloadTaskRepository();

  static DownloadsLibrarySyncService get to => Get.find();

  static const String _tag = 'DownloadsLibrarySync';

  /// 一批处理多少条。同 [kScanBatchSize] 的理由：批太小则事务开销占比高，
  /// 太大则一次事务卡住的时间可感（sqlite3 是同步 API，全在 UI 线程上）。
  static const int _batchSize = 200;

  final LocalMediaRepository _repository;
  final DownloadTaskRepository _downloads;

  Future<void>? _running;

  LocalMediaDerivationService? get _derivationService =>
      Get.isRegistered<LocalMediaDerivationService>()
      ? Get.find<LocalMediaDerivationService>()
      : null;

  /// 全量同步**跑到一半**时才入库的那些条目的 path_hash。
  ///
  /// ⛔ 少了它会出这么一档事：`_sync` 在开头就把任务清单和 `seen` 定死了，中间
  /// 让帧的那一下（[_batchSize] 满一批时）刚好有一条下载完成 → [syncTask] 同步
  /// 插进一行 → `_sync` 回来收敛 missing，而这个 hash 不在 `seen` 里 → **刚下完
  /// 的片子当场被标成"文件没了"**，列表里根本看不见。下一次全量同步会把它救
  /// 回来，但"刚下完的东西不见了"正是这条线反复要治的那个毛病。
  final Set<String> _lateHashes = <String>{};

  /// 同步一次。并发调用会**合流到同一次**——页面进来、下载完成、用户点刷新
  /// 三处都会叫它，各跑一遍纯属白费。
  Future<void> sync() {
    final running = _running;
    if (running != null) return running;
    final future = _sync().whenComplete(() => _running = null);
    _running = future;
    return future;
  }

  /// 等当前同步结束后，再基于最新的任务表跑一轮。
  ///
  /// 删除下载任务时不能直接复用一个已经在运行的旧快照：那一轮可能在删
  /// 除发生前就拿完了任务清单，完成后仍会把刚删的文件当成有效条目。调用方
  /// 用这个入口可保证删除动作最终被反映到本地源。
  Future<void> syncAfterPending() async {
    while (true) {
      final running = _running;
      if (running != null) {
        await running;
        continue;
      }
      await sync();
      return;
    }
  }

  Future<void> _sync() async {
    try {
      final tasks = _downloads.completedVideoTasks();

      // 同一个路径可能挂着不止一个任务（同名重下、任务表里留了旧行）。
      // 条目 id 由路径决定，所以这里必须先去重，否则同一条会在一个批次里被
      // 写两遍——留**最后完成的那一个**，它的元数据是最新的。
      final byPath = <String, DownloadTask>{};
      for (final task in tasks) {
        final path = task.savePath.trim();
        if (path.isEmpty) continue;
        // 认不出扩展名的一律不收：`save_path` 也可能指向 `.part` 之类的中间
        // 产物，或者一个我们根本播不了的容器。
        final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
        if (!kLocalVideoExtensions.contains(ext)) continue;
        final existing = byPath[path];
        if (existing != null &&
            _completedAtOf(existing) >= _completedAtOf(task)) {
          continue;
        }
        byPath[path] = task;
      }

      // ⛔ 一条都没有时**不要把源建出来**。建了的话，从没下载过任何东西的用户
      // 打开本地库会看到一枚空的「已下载」胶囊，而"添加文件夹"那张引导空态
      // （它是这一页唯一的上手入口）从此再也不出现。
      final source = _ensureSource(create: byPath.isNotEmpty);
      if (source == null) return;

      if (byPath.isEmpty) {
        // 源已经存在但所有完成任务都被删除时，仍要收敛旧条目；否则最后一个
        // 下载删除后，本地墙会永远保留一张旧卡片。全量同步期间刚完成的任务
        // 通过 [_lateHashes] 保留下来，不能被这次空清单覆盖成 missing。
        final late = Set<String>.from(_lateHashes);
        _lateHashes.clear();
        _repository.markMissingExcept(source.id, late);
        _repository.upsertSource(
          source.copyWith(
            lastScanAt: DateTime.now().millisecondsSinceEpoch,
            itemCount: _repository.countItems(sourceId: source.id),
            offline: false,
          ),
        );
        return;
      }

      // 这个源现在长什么样，用来跳过没变过的那些。同 [LocalMediaScanService]
      // 的理由，而且这里更要紧：本页每次打开都会同步一次，不跳过就等于每次把
      // 整张表重写一遍，连带 `_dropProgressOfReplacedItems` 也要对全量 id 做
      // JOIN——而 sqlite3 是同步 API，全落在 UI 线程上。
      final known = _repository.fingerprints(kDownloadsSourceId);

      final now = DateTime.now().millisecondsSinceEpoch;
      final seen = <String>{};
      final pending = <LocalMediaItem>[];
      final derivationCandidates = <LocalMediaItem>[];
      // 新出现的条目：要在写库之前把同一路径下别的源留下的观看进度搬过来。
      final adopting = <String, String>{};
      var written = 0;
      var unreadable = 0;

      for (final entry in byPath.entries) {
        final path = entry.key;
        final task = entry.value;
        final hash = _hashPath(path);

        int? size;
        int? modified;
        // ⛔ `statSync()` 不抛异常：stat 不动时返回 `type = notFound`、
        // `size = -1`、`modified` 是纪元零点。量不出来就一个都不写——null 是
        // 「不知道」，`-1` 是一句谎话，而这两列是"文件被换过没有"的唯一判据，
        // 一个假指纹会连带删掉用户的观看进度（见 `LocalMediaScanService`）。
        FileStat? stat;
        try {
          stat = File(path).statSync();
        } catch (_) {
          // 统一在下面按 readable 计数，避免同一条任务被记两次。
        }
        final readableStat = stat;
        final readable = readableStat?.type == FileSystemEntityType.file;
        if (readable) {
          final fileStat = readableStat!;
          size = fileStat.size;
          modified = fileStat.modified.millisecondsSinceEpoch;
        } else {
          unreadable++;
        }
        // ⛔ 只有**真的摸到了文件**才算"见过"。任务行还在但文件被用户在文件
        // 管理器里删掉了，是这个源最常见的一种漂移；不这么分的话
        // [LocalMediaRepository.markMissingExcept] 永远收敛不到它，卡片墙上会
        // 一直摆着一张点开只弹「文件已不在」的卡。
        if (readable) seen.add(hash);

        final id = LocalMediaItem.buildId(source.id, hash);
        final fingerprint = known[hash];
        if (fingerprint == null && readable) {
          adopting[path] = id;
        } else if (!readable) {
          // ⛔ 摸不到文件、而库里已经有这一行：**一个字都别写**。
          //
          // 这一趟能写进去的东西一样都没有——指纹量不出来（写了也会被那段
          // `CASE WHEN excluded IS NULL` 挡回去），其余列全来自没变过的任务行。
          // 唯一会真的落下去的是 `missing = 0`，而那恰恰是错的：整卷不可达时
          // 本轮不收敛（见下面 [volumeOffline]），这一下就会把上一轮认定的
          // "文件没了"悄悄擦回"文件还在"。
          continue;
        } else if (fingerprint != null &&
            !fingerprint.missing &&
            fingerprint.sizeBytes == size &&
            fingerprint.modifiedAt == modified) {
          // 库里那份和磁盘上这份一模一样，连 upsert 都不用发。
          if (!fingerprint.hasMetadata) {
            derivationCandidates.add(
              _itemOf(
                task,
                path: path,
                hash: hash,
                size: size,
                modified: modified,
                fallbackAddedAt: now,
              ),
            );
          }
          continue;
        }

        final item = _itemOf(
          task,
          path: path,
          hash: hash,
          size: size,
          modified: modified,
          fallbackAddedAt: now,
        );
        pending.add(item);

        if (pending.length >= _batchSize) {
          written += _flushWithAdoption(pending, adopting, source.id);
          // 让一帧出去，别把整批写库堆在一个 tick 里。
          await Future<void>.delayed(Duration.zero);
        }
      }
      written += _flushWithAdoption(pending, adopting, source.id);
      _enqueueDerivation(derivationCandidates);

      // ⛔ 一条都读不到 = **整卷不可达**（外置存储没挂上、权限被回收），不是
      // "文件都没了"。这时候收敛 missing 会把整个「已下载」一次抹平，用户看到
      // 的是列表凭空空掉。同 [LocalMediaScanService._finish] 里"出错就不收敛"
      // 的那条纪律，只是这里的信号是 stat 全军覆没。
      final volumeOffline = byPath.isNotEmpty && unreadable == byPath.length;
      // 本轮进行中才入库的那些，一并算作"见过"，见 [_lateHashes]。
      seen.addAll(_lateHashes);
      _lateHashes.clear();
      if (!volumeOffline) {
        // 任务被删掉 / 文件被删掉的那些收敛成 missing，而不是删行——删行会把
        // 观看进度一起带走。
        _repository.markMissingExcept(source.id, seen);
      }
      _repository.upsertSource(
        source.copyWith(
          lastScanAt: now,
          itemCount: _repository.countItems(sourceId: source.id),
          offline: volumeOffline,
        ),
      );
      _refreshRootFolder(source);
      LogUtils.i(
        '「已下载」同步完成：${byPath.length} 个任务，写了 $written 条'
        '${unreadable > 0 ? '，$unreadable 条读不到文件' : ''}'
        '${volumeOffline ? '（整卷不可达，本次不收敛 missing）' : ''}',
        _tag,
      );
    } catch (e, s) {
      LogUtils.e('「已下载」同步失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  /// 一个已完成的下载任务 → 一条本地条目。全量同步与单条即时入库共用。
  static LocalMediaItem _itemOf(
    DownloadTask task, {
    required String path,
    required String hash,
    required int? size,
    required int? modified,
    required int fallbackAddedAt,
  }) {
    final name = p.basename(path);
    return LocalMediaItem(
      id: LocalMediaItem.buildId(kDownloadsSourceId, hash),
      sourceId: kDownloadsSourceId,
      pathHash: hash,
      path: path,
      kind: LocalMediaItemKind.video,
      // ⛔ 名字用**文件名**而不是任务里的标题：这一列同时喂 `sort_name`，而
      // 排序必须和别的源一致（自然序、同一套折叠规则）。官方标题走
      // `download_task_id` 那条装饰线，卡片上照样显示得出来。
      name: name,
      sortName: naturalSortKey(name),
      ext: p.extension(path).replaceFirst('.', '').toLowerCase(),
      sizeBytes: size,
      modifiedAt: modified,
      durationMs: _durationMsOf(task),
      folderPath: p.dirname(path),
      // 分类只在**新建那一行**上生效：[LocalMediaRepository.upsertItems] 冲突时
      // 不动 `category_id`。那一列从此是本地库说了算（§10.7），下载模块改分类
      // 时由 [DownloadTaskRepository.assignTasksToCategory] 镜像过来。
      categoryId: task.categoryId,
      downloadTaskId: task.id,
      addedAt: task.completedAt?.millisecondsSinceEpoch ?? fallbackAddedAt,
    );
  }

  /// 一条下载**刚刚完成**：当场把它放进库里，不等下一次全量同步。
  ///
  /// # ⛔ 为什么这一步是分类升格的前置，而不是"顺手优化"
  ///
  /// 分类从此挂在 `local_media_items.category_id` 上（§10.7）。要让"刚下完的
  /// 片子"也能被归类、被按分类查到，它就必须**在完成那一刻**已经有一行——
  /// 否则从下载完成到用户下次打开本地库之间，这条内容在分类这个维度上根本
  /// 不存在。
  ///
  /// 全量 [sync] 仍然保留：它是修复通道（漏掉的、被绕过的、手动删过文件的），
  /// 两者都幂等，重复跑无害。
  ///
  /// ⚠️ 本方法**全程没有 await**：调用点那个 `unawaited(...)` 只是为了满足 lint，
  /// 它一个字都不会推迟。这是有意的——同步执行才使得"下载完成"与"库里有这一行"
  /// 之间没有窗口，代价是几次写库落在 UI 线程上（都是主键命中，很便宜）。
  Future<void> syncTask(DownloadTask task) async {
    try {
      if (task.mediaType != 'video') return;
      final path = task.savePath.trim();
      if (path.isEmpty) return;
      final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
      if (!kLocalVideoExtensions.contains(ext)) return;

      final stat = File(path).statSync();
      // 刚下完却 stat 不到，说明这一刻并不适合入库（外置存储掉了、路径不对）。
      // 不写半条，交给下一次全量同步。
      if (stat.type != FileSystemEntityType.file) {
        LogUtils.w('下载刚完成却读不到文件，暂不入库：$path', _tag);
        return;
      }

      // 建源那一条判据在这里天然成立：手上就有一个已完成的任务。
      final source = _ensureSource(create: true);
      if (source == null) return;

      final hash = _hashPath(path);
      final item = _itemOf(
        task,
        path: path,
        hash: hash,
        size: stat.size,
        modified: stat.modified.millisecondsSinceEpoch,
        fallbackAddedAt: DateTime.now().millisecondsSinceEpoch,
      );
      // 同全量同步：写库之前先认亲，别让换主人把观看进度变成孤儿。
      _repository.adoptIdentityByPath(
        newSourceId: source.id,
        pathToNewId: <String, String>{path: item.id},
        fingerprints: <String, LocalMediaFingerprint>{
          path: LocalMediaFingerprint(
            sizeBytes: stat.size,
            modifiedAt: stat.modified.millisecondsSinceEpoch,
          ),
        },
      );
      _repository.upsertItems(<LocalMediaItem>[item]);
      _enqueueDerivation(<LocalMediaItem>[item]);
      // 正在跑的那次全量同步不认识这条（它的清单是开头定死的），给它留个条。
      if (_running != null) _lateHashes.add(hash);
      _repository.upsertSource(
        source.copyWith(itemCount: _repository.countItems(sourceId: source.id)),
      );
      _refreshRootFolder(source);
      LogUtils.d('下载完成即入库：${item.name}', _tag);
    } catch (e) {
      // 入库失败绝不能反过来影响下载本身——它已经成功了。
      LogUtils.e('下载完成入库失败', tag: _tag, error: e);
    }
  }

  /// 先把同一路径下别的源留着的观看进度/VR 覆盖搬到新 id 上，再写这一批。
  ///
  /// ⛔ 顺序不能颠倒：[LocalMediaRepository.upsertItems] 里的
  /// `_dropProgressOfReplacedItems` 是拿库里那份旧指纹判断"文件还是不是同一个"
  /// 的，写完就再也分不出来了。
  int _flushWithAdoption(
    List<LocalMediaItem> pending,
    Map<String, String> adopting,
    String sourceId,
  ) {
    if (pending.isEmpty) return 0;
    if (adopting.isNotEmpty) {
      final batch = <String, String>{
        for (final item in pending)
          if (adopting.containsKey(item.path)) item.path: item.id,
      };
      if (batch.isNotEmpty) {
        _repository.adoptIdentityByPath(
          newSourceId: sourceId,
          pathToNewId: batch,
          fingerprints: <String, LocalMediaFingerprint>{
            for (final item in pending)
              if (batch.containsKey(item.path))
                item.path: LocalMediaFingerprint(
                  sizeBytes: item.sizeBytes,
                  modifiedAt: item.modifiedAt,
                ),
          },
        );
        for (final path in batch.keys) {
          adopting.remove(path);
        }
      }
    }
    return _flush(pending);
  }

  int _flush(List<LocalMediaItem> pending) {
    if (pending.isEmpty) return 0;
    final count = pending.length;
    final writtenItems = List<LocalMediaItem>.from(pending);
    try {
      _repository.upsertItems(writtenItems);
      _enqueueDerivation(writtenItems);
    } catch (e) {
      LogUtils.e('写入「已下载」批次失败（$count 条）', tag: _tag, error: e);
      return 0;
    } finally {
      pending.clear();
    }
    return count;
  }

  /// 把「已下载」那一行源根目录记录跟上当前内容（计数 + 自动封面）。
  ///
  /// # ⛔ 为什么这个源也要有目录行
  ///
  /// 封面、置顶、「设为封面 / 恢复自动封面」全挂在 `local_media_folders` 上。这个
  /// 源以前一行都不写，于是卡片上永远是一张空夹子，右键菜单里连「设为封面」都没
  /// 有——用户报的原话是「里面明明有视频，点进去再出来还是没封面，也没法自己设」。
  ///
  /// 这一行的 `folder_path` 是 NULL，「这个源是平的」这件事由它表达（见
  /// [LocalMediaRepository.ensureSourceRootFolder]），所以目录浏览页、播放队列
  /// 抽屉那边的平铺退化照旧成立。
  void _refreshRootFolder(LocalMediaSource source) {
    try {
      _repository.ensureSourceRootFolder(
        sourceId: source.id,
        displayName: source.displayName,
        videoCount: _repository.countItems(
          sourceId: source.id,
          kind: LocalMediaItemKind.video,
        ),
        imageCount: _repository.countItems(
          sourceId: source.id,
          kind: LocalMediaItemKind.image,
        ),
      );
      _repository.backfillSourceRootCoverFromItems(source.id);
    } catch (e) {
      // 封面不是主线：写不进去也不能影响这次同步的结果。
      LogUtils.w('刷新「已下载」源根目录行失败: $e', _tag);
    }
  }

  void _enqueueDerivation(Iterable<LocalMediaItem> items) {
    final service = _derivationService;
    if (service == null) return;
    unawaited(service.enqueueAll(items));
  }

  /// 内建源那一行：没有就建，有就把显示名跟上当前语言。
  ///
  /// ⛔ `path` **刻意留空**。这个源没有"一个目录"——`save_path` 是每个任务各自
  /// 的绝对路径，下载目录还是用户随时能改的设置（见类文档）。填一个"当前下载
  /// 目录"进去只会得到一个随时过期、而且没有任何人读的值。
  ///
  /// [create] 为 false 时只认已经存在的那一行，绝不新建（见调用点的说明）。
  LocalMediaSource? _ensureSource({required bool create}) {
    final name = slang.t.localMedia.downloadsSource;
    final existing = _repository.getSource(kDownloadsSourceId);
    if (existing != null) {
      if (existing.displayName == name) return existing;
      final updated = existing.copyWith(displayName: name);
      _repository.upsertSource(updated);
      return updated;
    }
    if (!create) return null;
    final created = LocalMediaSource(
      id: kDownloadsSourceId,
      kind: LocalMediaSourceKind.downloads,
      displayName: name,
      // 负数：内建源永远排在用户自己加的文件夹前面（来源下拉里「已下载」
      // 就在「Iwara 线上」下面那一条，见 §3.1）。
      sortOrder: -1,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _repository.upsertSource(created);
    LogUtils.i('已建立内建源「$name」', _tag);
    return created;
  }

  static int _completedAtOf(DownloadTask task) =>
      task.completedAt?.millisecondsSinceEpoch ??
      task.updatedAt?.millisecondsSinceEpoch ??
      0;

  /// 下载任务自带的时长（秒），能省掉一次抽帧。拿不到就留 null 等 P1b。
  static int? _durationMsOf(DownloadTask task) {
    final ext = task.extData;
    if (ext == null || ext.type != DownloadTaskExtDataType.video) return null;
    try {
      final seconds = VideoDownloadExtData.fromJson(ext.data).duration;
      if (seconds == null || seconds <= 0) return null;
      return seconds * 1000;
    } catch (_) {
      return null;
    }
  }

  static String _hashPath(String path) =>
      sha1.convert(utf8.encode(path)).toString();
}
