import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/local_media/local_vr_hints.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/utils/local_vr_filename_detector.dart';
import 'package:i_iwara/app/utils/mp4_stereo_box_reader.dart';
import 'package:i_iwara/app/utils/vr_format_detector.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// Derives metadata and on-demand thumbnails for local video files.
///
/// The queue is deliberately serialized. A media-kit [Player] owns native
/// decoder resources, and decoding/playing local files at once can
/// starve or disrupt the player the user is currently watching.
class LocalMediaDerivationService extends GetxService {
  LocalMediaDerivationService({LocalMediaRepository? repository})
    : _repository = repository ?? LocalMediaRepository();

  static LocalMediaDerivationService get to => Get.find();

  static const String _tag = 'LocalMediaDerivation';
  static const Duration _metadataTimeout = Duration(seconds: 8);
  static const Duration _nativeCallTimeout = Duration(seconds: 15);

  /// 单次 `getProperty` 的超时。IPC 往返而已，正常是微秒级；给到 600ms 已经
  /// 是"mpv 明显不对劲"的量级。⛔ 不要用 [_metadataTimeout]，理由见 [_readFps]。
  static const Duration _propertyProbeTimeout = Duration(milliseconds: 600);

  /// 帧率探测的总预算。轮询本身是 6 × 120ms ≈ 0.72s，这道闸只在 mpv 挂起、
  /// 单次查询走满超时时才咬合，防止一个文件把整条串行队列拖住。
  static const Duration _fpsProbeBudget = Duration(seconds: 3);

  final LocalMediaRepository _repository;
  final Queue<String> _pendingIds = Queue<String>();
  final Map<String, _DerivationRequest> _pending =
      <String, _DerivationRequest>{};
  bool _draining = false;

  final Queue<String> _pendingImageIds = Queue<String>();
  final Map<String, _ImageDerivationRequest> _pendingImages =
      <String, _ImageDerivationRequest>{};
  bool _drainingImages = false;

  /// 派生作业失败的负缓存。
  /// Key 为 `itemId:size:mtime:job`，job 取 'meta'、'thumb'、'fps' 或 'imgmeta'。
  /// 一个文件解不出元数据、或抓不出封面帧时记在这里；只要大小与修改时间没变，
  /// 就不再为它开 Player 白等原生解码超时（一次要等 [_metadataTimeout]）。
  ///
  /// ⛔ **有上限**：一个源可能有几万条，无上限的话这张表会随进程一直长。Dart 的
  /// `Set` 是插入序的，超了就从最旧的开始丢——丢掉的最坏结果只是那一条日后多重试
  /// 一次，而不是错误的结果。
  ///
  /// ⛔ 加新 job 种类时这个数要跟着涨：上限是按 **key 条数**算的，而一个条目最多
  /// 能占 job 种类那么多条 key。种类从 2（meta/thumb）涨到 4（+fps/imgmeta）时
  /// 这里忘了动，等于装得下的条目数当场减半、淘汰压力翻倍。
  static const int _maxFailedJobKeys = 4096;
  final Set<String> _failedJobKeys = <String>{};

  static String _jobKey(
    String itemId,
    int? size,
    int? modifiedAt,
    String job,
  ) => '$itemId:${size ?? -1}:${modifiedAt ?? -1}:$job';

  void _markJobFailed(String itemId, int? size, int? modifiedAt, String job) {
    _failedJobKeys.add(_jobKey(itemId, size, modifiedAt, job));
    while (_failedJobKeys.length > _maxFailedJobKeys) {
      _failedJobKeys.remove(_failedJobKeys.first);
    }
  }

  /// 把这一条图片排进独立的图片派生队列（读取文件头宽高，毫秒级，不占用视频播放器资源）。
  Future<void> enqueueImage(LocalMediaItem item) {
    if (item.missing) return Future<void>.value();

    final metaFailed = _failedJobKeys.contains(
      _jobKey(item.id, item.sizeBytes, item.modifiedAt, 'imgmeta'),
    );
    if (metaFailed) {
      return Future<void>.value();
    }

    final existing = _pendingImages[item.id];
    if (existing != null) {
      return existing.completer.future;
    }

    final request = _ImageDerivationRequest(item);
    _pendingImages[item.id] = request;
    _pendingImageIds.add(item.id);
    _trimImageQueue();
    unawaited(_drainImages());
    return request.completer.future;
  }

  /// 图片派生队列的长度上限。
  ///
  /// ⛔ 这条队列是 fire-and-forget 入的（扫描器逐批塞，见
  /// `local_media_scan_service` 的 `_enqueueDerivation`），本来就没有背压。
  /// 首扫一个五万张图的源会把五万个请求连同各自那份 [LocalMediaItem] 一起挂在
  /// 内存里，串行消费完之前一个都不释放——而这个 App 有原生层被系统杀掉的旧账。
  /// 视频那条队列同样无上限，只是视频的数量级小得多；把图片纳进来之后风险涨了
  /// 一个量级，先给这条封顶。
  ///
  /// 丢掉是安全的：被丢的条目 [LocalMediaItem.needsDerivedMetadata] 仍然为 true，
  /// 下次滚进视野照样会重新入队，只是晚一点补上分辨率。
  static const int _maxPendingImages = 3000;

  void _trimImageQueue() {
    while (_pendingImageIds.length > _maxPendingImages) {
      // ⛔ 丢最旧的那端。新入队的多半是用户正在看的那一屏，价值更高。
      final droppedId = _pendingImageIds.removeFirst();
      final dropped = _pendingImages.remove(droppedId);
      // ⛔ completer 必须收尾，否则 `await enqueueImage(...)` 的调用方永远挂着。
      if (dropped != null && !dropped.completer.isCompleted) {
        dropped.completer.complete();
      }
    }
  }

  /// 把这一条排进派生队列。缩略图是 opt-in 的：一次扫描不该为了填列表就把每个
  /// 文件都解一遍。
  ///
  /// 返回的 future 在这一轮跑完时完成，**不带结果**。"到底有没有变化"不是这里
  /// 能回答的问题，见 [ensureDerived]。
  Future<void> enqueue(LocalMediaItem item, {bool generateThumbnail = false}) {
    if (item.missing) return Future<void>.value();

    // 唯一分流点：图片走轻量文件头读取通道，不占用也不阻塞单条视频 Player 队列。
    if (item.kind == LocalMediaItemKind.image) {
      return enqueueImage(item);
    }

    final metaFailed = _failedJobKeys.contains(
      _jobKey(item.id, item.sizeBytes, item.modifiedAt, 'meta'),
    );
    final thumbFailed = _failedJobKeys.contains(
      _jobKey(item.id, item.sizeBytes, item.modifiedAt, 'thumb'),
    );
    // 这里只是一道**省事的预筛**：调用方手上的 [item] 可能是过期的行，判不准
    // "还剩哪些活"。真正的判据在 [_derive] 里（那儿重读了库），且这一道永远比
    // 那一道更保守——不会漏掉 [_derive] 还愿意干的活。
    if (generateThumbnail ? (metaFailed && thumbFailed) : metaFailed) {
      return Future<void>.value();
    }

    final existing = _pending[item.id];
    if (existing != null) {
      existing.generateThumbnail =
          existing.generateThumbnail || generateThumbnail;
      return existing.completer.future;
    }

    final request = _DerivationRequest(
      item,
      generateThumbnail: generateThumbnail,
    );
    _pending[item.id] = request;
    _pendingIds.add(item.id);
    unawaited(_drain());
    return request.completer.future;
  }

  Future<void> enqueueAll(Iterable<LocalMediaItem> items) async {
    await Future.wait<void>([for (final item in items) enqueue(item)]);
  }

  /// 把这一条缺的派生数据补齐：时长 / 宽高，以及（[generateThumbnail] 为真且
  /// 既没有 sidecar 也没有缓存缩略图时）抓一帧当封面。
  ///
  /// 返回值：库里那一行**比调用方手上这份更全**时返回它，否则返回 null。调用方据此
  /// 决定要不要**就地**重绘——⛔ 决定的不是"要不要刷新列表"：派生是行内变化，见
  /// [LocalMediaRepository.updateDerivedFields] 上的注释。
  ///
  /// ⛔ **判据是两份行的差，不能是"这一轮有没有写库"。** 后台扫描完全可能早在卡片
  /// 滚进视野之前就把派生结果写好了；那时这一轮确实什么都不用做，但调用方手上仍然
  /// 是入库那一刻的旧快照。按"有没有写库"判，那张卡会**永远**停在占位图和空角标上。
  Future<LocalMediaItem?> ensureDerived(
    LocalMediaItem item, {
    bool generateThumbnail = false,
  }) async {
    await enqueue(item, generateThumbnail: generateThumbnail);
    final latest = _repository.getItem(item.id);
    if (latest == null) return null;
    return _isRicherThan(latest, item) ? latest : null;
  }

  static bool _isRicherThan(LocalMediaItem latest, LocalMediaItem known) =>
      _gained(latest.durationMs, known.durationMs) ||
      _gained(latest.width, known.width) ||
      _gained(latest.height, known.height) ||
      _gained(latest.fps, known.fps) ||
      _gained(latest.thumbPath, known.thumbPath) ||
      _gained(latest.sidecarImagePath, known.sidecarImagePath);

  /// 「多出来了」= 现在有值，且和调用方手上那份不是同一个值。
  static bool _gained(Object? latest, Object? known) =>
      latest != null && latest != known;

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_pendingIds.isNotEmpty) {
        final id = _pendingIds.removeFirst();
        final request = _pending[id];
        if (request == null) continue;
        var threw = false;
        try {
          await _derive(request);
        } catch (error, stackTrace) {
          threw = true;
          // 整轮抛异常（基本只会来自 player.open 超时）＝这个文件根本打不开，
          // 两种作业都没戏，一起记。
          for (final job in const <String>['meta', 'thumb']) {
            _markJobFailed(
              request.item.id,
              request.item.sizeBytes,
              request.item.modifiedAt,
              job,
            );
          }
          LogUtils.e(
            '本地媒体派生失败：${request.item.path}',
            tag: _tag,
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          // ⛔ 这一轮跑到一半时才有人把 generateThumbnail 升上来（卡片滚进视野，
          // 正撞上扫描为同一条发起的元数据轮）——抓帧的决定点早就过去了，而两位
          // 调用方共享同一个 completer，那位会以为封面已经做过、再也不会来问第二
          // 次。补排一轮，且只补一轮。
          final needsThumbnailPass =
              !threw &&
              request.generateThumbnail &&
              !request.thumbnailHandled &&
              !request.requeuedForThumbnail;
          if (needsThumbnailPass) {
            request.requeuedForThumbnail = true;
            _pendingIds.add(id);
          } else {
            _pending.remove(id);
            if (!request.completer.isCompleted) request.completer.complete();
          }
        }
      }
    } finally {
      _draining = false;
      if (_pendingIds.isNotEmpty) unawaited(_drain());
    }
  }

  Future<void> _drainImages() async {
    if (_drainingImages) return;
    _drainingImages = true;
    try {
      while (_pendingImageIds.isNotEmpty) {
        final id = _pendingImageIds.removeFirst();
        final request = _pendingImages[id];
        if (request == null) continue;
        try {
          await _deriveImage(request);
        } catch (error, stackTrace) {
          _markJobFailed(
            request.item.id,
            request.item.sizeBytes,
            request.item.modifiedAt,
            'imgmeta',
          );
          LogUtils.e(
            '本地图片元数据派生失败：${request.item.path}',
            tag: _tag,
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          _pendingImages.remove(id);
          if (!request.completer.isCompleted) request.completer.complete();
        }
      }
    } finally {
      _drainingImages = false;
      if (_pendingImageIds.isNotEmpty) unawaited(_drainImages());
    }
  }

  Future<void> _deriveImage(_ImageDerivationRequest request) async {
    final current = _repository.getItem(request.item.id);
    if (current == null || current.missing) return;

    final needWidth = current.width == null;
    final needHeight = current.height == null;
    final metaBlocked =
        (!needWidth && !needHeight) ||
        _failedJobKeys.contains(
          _jobKey(current.id, current.sizeBytes, current.modifiedAt, 'imgmeta'),
        );
    if (metaBlocked) return;

    // ⛔ `ImmutableBuffer.fromFilePath` 不解码，但会把**整个文件**读进内存。
    // 一张几十 MB 的巨图就是几十 MB 的瞬时峰值，而这个 App 本来就有原生层被
    // 系统杀掉的旧账。宽高只是拿来排序的锦上添花，不值得为它冒 OOM 的风险：
    // 超过闸门的直接放弃，那一条的分辨率留空（排序时按"未知"排到最后）。
    //
    // 64MB 的取法：白名单里的格式（jpg/png/webp/avif）就算 8K 分辨率也很少
    // 超过 50MB，能越过这条线的基本是不该出现在图库里的东西。
    //
    // ⛔ 这道闸必须排在摸文件**之前**。`size_bytes` 库里就有，而下面那几步里
    // [_materializePath] 会为 content:// 条目拷贝整个文件、`_statFile` 还要
    // 两次系统调用——为一次注定被这道闸拦下的派生付这笔钱是纯浪费，而
    // [needsDerivedMetadata] 对这类条目恒为 true，每次滚进视野都要重付一遍。
    // 「太大」是文件指纹决定的确定性结论，进负缓存（与"拿不到路径"那种暂时性
    // 故障不同）。
    const int maxImageBytesForProbe = 64 * 1024 * 1024;
    if ((current.sizeBytes ?? 0) > maxImageBytesForProbe) {
      _markJobFailed(
        current.id,
        current.sizeBytes,
        current.modifiedAt,
        'imgmeta',
      );
      LogUtils.d('图片过大跳过分辨率派生 ${current.name}：${current.sizeBytes} 字节', _tag);
      return;
    }

    final playbackTarget = current.resolvePlaybackTarget();
    final playablePath = await _materializePath(playbackTarget);
    if (playablePath == null) return;
    final contentUri = _isContentUri(playbackTarget);
    final initialStat = await _statFile(playablePath);
    if (initialStat == null ||
        current.sizeBytes == null ||
        current.modifiedAt == null ||
        current.sizeBytes != initialStat.size ||
        (!contentUri &&
            current.modifiedAt !=
                initialStat.modified.millisecondsSinceEpoch)) {
      return;
    }

    int? width;
    int? height;
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    try {
      buffer = await ui.ImmutableBuffer.fromFilePath(playablePath);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      width = descriptor.width;
      height = descriptor.height;
    } catch (e) {
      _markJobFailed(
        current.id,
        current.sizeBytes,
        current.modifiedAt,
        'imgmeta',
      );
      LogUtils.w('读取图片分辨率失败：${current.path}: $e', _tag);
      return;
    } finally {
      descriptor?.dispose();
      buffer?.dispose();
    }

    final finalStat = await _statFile(playablePath);
    if (finalStat == null ||
        finalStat.size != initialStat.size ||
        (!contentUri &&
            finalStat.modified.millisecondsSinceEpoch !=
                initialStat.modified.millisecondsSinceEpoch)) {
      return;
    }

    if (width > 0 && height > 0) {
      _repository.updateDerivedFields(
        itemId: current.id,
        expectedSizeBytes: current.sizeBytes,
        expectedModifiedAt: current.modifiedAt,
        width: width,
        height: height,
      );
      LogUtils.d('图片派生完成 ${current.name}：${width}x$height', _tag);
    } else {
      _markJobFailed(
        current.id,
        current.sizeBytes,
        current.modifiedAt,
        'imgmeta',
      );
    }
  }

  Future<void> _derive(_DerivationRequest request) async {
    final current = _repository.getItem(request.item.id);
    if (current == null || current.missing) return;

    final sidecarAvailable = await _exists(current.sidecarImagePath);
    final thumbAvailable = await _exists(current.thumbPath);
    final needDuration = current.durationMs == null;
    final needWidth = current.width == null;
    final needHeight = current.height == null;
    // ⛔ 「探测过了」是**库里**的一列，不是内存负缓存。内存那份随进程清零，挡不住
    // 「每次冷启动都为容器不写帧率的文件重付一遍 0.72 秒轮询」——一个 138 条的库
    // 若有一半读不出，就是每次开 App 白占约 50 秒串行队列，期间用户滚到的卡片全在
    // 后面排队等缩略图。两道都留着：库里那列管跨重启，内存那份管本轮重复入队。
    final needFps =
        current.fps == null &&
        current.fpsProbedAt == null &&
        !_failedJobKeys.contains(
          _jobKey(current.id, current.sizeBytes, current.modifiedAt, 'fps'),
        );
    final needThumbnail =
        request.generateThumbnail && !sidecarAvailable && !thumbAvailable;
    // 这一轮已经对"抓不抓帧"做过决定了。之后再有人把 [_DerivationRequest
    // .generateThumbnail] 升上来，这一轮回不了头——由 [_drain] 补排一轮。
    if (request.generateThumbnail) request.thumbnailHandled = true;

    // ⛔ 负缓存的判据必须落在这里，不能只落在 [enqueue]：那边看到的是调用方手上
    // 那份可能过期的行，判不出"这一轮到底还有没有活要干"。于是
    // 「元数据齐全、但抓帧怎么都失败」的文件（封面帧解不出来的容器）会因为
    // meta 没失败过而永不跳过——每次滚进视野都白开一次 Player、白跑一次抓帧。
    // 规则：**这一轮要干的每件事都已经被堵死，才不干**。
    final metaBlocked =
        (!needDuration && !needWidth && !needHeight && !needFps) ||
        _failedJobKeys.contains(
          _jobKey(current.id, current.sizeBytes, current.modifiedAt, 'meta'),
        );
    final thumbBlocked =
        !needThumbnail ||
        _failedJobKeys.contains(
          _jobKey(current.id, current.sizeBytes, current.modifiedAt, 'thumb'),
        );
    if (metaBlocked && thumbBlocked) return;

    // ⛔ 摸文件必须排在上面那道闸后面。`content://` 条目的 [_materializePath] 会把
    // **整个视频文件**拷进缓存目录（mpv 放不了 content:// URI），为一次注定被跳过
    // 的派生付这笔钱是纯粹的浪费——几 GB 的片子还会把 15 秒超时耗光、在缓存里留下
    // 半截文件。
    // ⛔ 拿不到可播路径（provider 报错、磁盘满）**刻意不进负缓存**：那是暂时性
    // 故障，而负缓存的 key 是文件指纹——指纹不变就永远解不开，等于因为一次磁盘满
    // 把这个文件的封面永久判死。重试的代价被串行队列和 [_nativeCallTimeout] 兜着。
    final playbackTarget = current.resolvePlaybackTarget();
    final playablePath = await _materializePath(playbackTarget);
    if (playablePath == null) return;
    final contentUri = _isContentUri(playbackTarget);
    final initialStat = await _statFile(playablePath);
    // 指纹对不上 = 库里那份说的不是磁盘上这个文件，派生结果安不上去。
    // ⛔ 这条不算"派生失败"，不进负缓存：文件是被换掉了，新的那份还没试过。
    if (initialStat == null ||
        current.sizeBytes == null ||
        current.modifiedAt == null ||
        current.sizeBytes != initialStat.size ||
        (!contentUri &&
            current.modifiedAt !=
                initialStat.modified.millisecondsSinceEpoch)) {
      return;
    }

    final player = Player();
    try {
      // ⛔⭐ 没有这一句，这个服务**一件事都做不成**（真机实证 2026-09-10：库里
      // 每一条的 `width/height/thumb_path` 全是 NULL，缩略图缓存目录压根没被建出来）。
      //
      // media_kit 建 `Player()` 时默认下 `vid=no`，它自己的注释逐字写着
      // 「prevent redundant video decoding」，并注明 `VideoController` 挂上来时
      // 才会改成 `vid=auto`（`media_kit/lib/src/player/native/player/real.dart`）。
      // 而这里是**无头**派生，永远不会有 VideoController 来挂——于是视频轨从头到尾
      // 没被解码过：`stream.width/height` 一个值都不发，`screenshot-raw` 也没有帧
      // 可抓。唯一还能出结果的是时长，因为那来自解复用器、不需要解码——这正好
      // 解释了真机上「有时长、没分辨率、没封面」那个形状。
      //
      // ⛔ 不能改成挂一个 `VideoController` 了事：那会给每一次派生都建一块纹理，
      // 而这条队列是为了在后台批量过文件用的。只把解码打开，输出仍留在 `vo=null`。
      final platform = player.platform;
      if (platform is NativePlayer) {
        await platform.setProperty('vid', 'auto');
        // ⛔ 打开视频轨的同时必须关掉音频轨。抓帧路径在 `screenshot` 拿不到帧时
        // 会退回 `play()` 硬播一小段，而这里是**无头**的：用户可能正在听别的
        // 东西，那一小段会真的外放出来，并抢走系统音频焦点（安卓上表现为别家
        // App 被压低甚至暂停）。
        // 用 `ao=null` 而不是 `setVolume(0)`：后者只把音量调零，音频输出设备照样
        // 打开、焦点照样被抢；前者根本不建音频输出。
        await platform.setProperty('ao', 'null');
      }
      await player
          .open(Media(playablePath), play: false)
          .timeout(_nativeCallTimeout);

      final durationFuture = needDuration
          ? _readDuration(player)
          : Future<Duration?>.value();
      final needsVideoParams = needWidth || needHeight || needThumbnail;
      final widthFuture = needsVideoParams
          ? _readWidth(player)
          : Future<int?>.value();
      final heightFuture = needsVideoParams
          ? _readHeight(player)
          : Future<int?>.value();
      final fpsFuture = needFps ? _readFps(player) : Future<double?>.value();

      final metadata = await Future.wait<Object?>([
        durationFuture,
        widthFuture,
        heightFuture,
        fpsFuture,
      ]);
      final duration = metadata[0] as Duration?;
      final width = metadata[1] as int?;
      final height = metadata[2] as int?;
      final fps = metadata[3] as double?;

      // ⛔ 抓帧位置要用「这个文件的时长」，不是「这一轮读到的时长」。
      // 两者只在 needDuration 为真时相等：库里已有时长时 [durationFuture] 是
      // `Future.value()`，[duration] 恒为 null，[coverPositionFor] 的 totalMs
      // 算成 0 直接返回 null → 不 seek → 抓第 0 帧，也就是那一屏黑卡片。
      //
      // 真机上这条必然发生：扫描器先用 `enqueue`（generateThumbnail: false）
      // 把全库元数据补齐，缩略图要等下一次卡片滚进视野才生成——那时 duration
      // 早就在库里了。于是**第二次启动之后的所有自动封面都是黑的**，而
      // [coverPositionFor] 那一大段注释正是为了防这件事写的。
      final effectiveDuration =
          duration ??
          (current.durationMs != null
              ? Duration(milliseconds: current.durationMs!)
              : null);

      Uint8List? thumbnailBytes;
      // A second request may upgrade a metadata-only request's generateThumbnail flag
      // while the player is open, so read request.generateThumbnail immediately before capturing.
      if (request.generateThumbnail && !sidecarAvailable && !thumbAvailable) {
        request.thumbnailHandled = true;
        thumbnailBytes = await _captureThumbnail(
          player,
          at: coverPositionFor(current.id, effectiveDuration),
        );
      }

      String? vrFormatJson;
      if (current.vrFormatJson == null) {
        try {
          final hints = await _deriveVrHints(current.name, playablePath);
          vrFormatJson = hints.toJson();
        } catch (error) {
          LogUtils.w('本地媒体推断 VR 线索失败：${current.name}: $error', _tag);
        }
      }

      final finalStat = await _statFile(playablePath);
      if (finalStat == null ||
          finalStat.size != initialStat.size ||
          (!contentUri &&
              finalStat.modified.millisecondsSinceEpoch !=
                  initialStat.modified.millisecondsSinceEpoch)) {
        return;
      }

      String? thumbPath;
      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        final scaled = await _scaleThumbnail(
          thumbnailBytes,
          hintWidth: width,
          hintHeight: height,
        );
        thumbPath = await _writeThumbnail(
          current,
          sizeBytes: finalStat.size,
          modifiedAt: finalStat.modified.millisecondsSinceEpoch,
          bytes: scaled.bytes,
          extension: scaled.extension,
        );
      }

      final updated = _repository.updateDerivedFields(
        itemId: current.id,
        expectedSizeBytes: current.sizeBytes,
        expectedModifiedAt: current.modifiedAt,
        durationMs: duration?.inMilliseconds,
        width: width,
        height: height,
        fps: fps,
        // 这一轮真的去探过帧率就落标，**读没读出来都落**：读不出说明这个容器
        // 根本不写帧率，下次冷启动再试一遍也是同样的结果。
        fpsProbed: needFps,
        thumbPath: thumbPath,
        vrFormatJson: vrFormatJson,
      );

      // ⭐ 缩略图落库后回填目录封面：
      // 纯视频目录通常没有独立图片，借用本目录首个生成缩略图的视频作为封面；
      // 若回填成功，则沿父目录链逐级向上回填子目录封面，直到某一祖先目录已存在封面或已被 pin。
      if (thumbPath != null && thumbPath.isNotEmpty && updated) {
        try {
          final folderPath = current.folderPath;
          if (folderPath != null && folderPath.isNotEmpty) {
            final folder = _repository.findFolderByPath(
              sourceId: current.sourceId,
              folderPath: folderPath,
            );
            if (folder != null) {
              _repository.backfillFolderCoverFromItems(
                sourceId: folder.sourceId,
                relPath: folder.relPath,
              );
              // ⛔ 向上冒泡**不能**挂在「本级回填成功」这个条件下。
              //
              // 上一轮修的是循环体内部的 break，可整个循环的**入口条件**本身
              // 就是同一个停止信号，只是发生在第 0 级——下面那段注释骂的正是
              // 这件事，却被它自己包在了 `if (backfilled)` 里面。
              //
              // 本级回填失败只说明「本级已有封面或被 pin」，与祖辈有没有封面
              // 完全无关。真实场景：用户给 A/B 手动 pin 了封面，A 自己没有直属
              // 媒体；给 A/B 里的视频出了缩略图 → 本级返回 false → A 永远空封面。
              {
                // ⛔ 某一级没借到（已有封面或被 pin）**不能**当作停止信号：
                // 扫描器从直属图片填封面那条路径根本不向上冒泡，所以「这一级
                // 有封面」完全不保证它上面几级也有。就此打住会让祖辈目录永远
                // 停在空封面上。一路走到源根为止，每级都是带索引的 LIMIT 1，
                // 便宜得很。
                var currentParent = folder.parentRelPath;
                var depth = 0;
                while (currentParent != null && depth < 16) {
                  _repository.backfillFolderCoverFromChild(
                    sourceId: folder.sourceId,
                    relPath: currentParent,
                  );
                  // '' 是源根，_parentRelPath('') 恒为 ''，不 break 就是死循环。
                  if (currentParent.isEmpty) break;
                  currentParent = _parentRelPath(currentParent);
                  depth++;
                }
              }
            }
          }
        } catch (e) {
          LogUtils.w('缩略图落库后回填目录封面失败：${current.name}: $e', _tag);
        }
      }

      // 这一行是留给真机核查的抓手：上一版「一件事都没做成」之所以能一直没被
      // 发现，就是因为整条派生链路成功时一声不吭，只有异常才有日志。
      LogUtils.d(
        '派生完成 ${current.name}：'
        'duration=${duration?.inMilliseconds} ${width}x$height '
        'fps=$fps '
        'thumb=${thumbPath != null} '
        'vr=${vrFormatJson != null}',
        _tag,
      );

      if (needDuration || needWidth || needHeight) {
        final durationKnown = current.durationMs != null || duration != null;
        final widthKnown = current.width != null || width != null;
        final heightKnown = current.height != null || height != null;
        if (!(durationKnown && widthKnown && heightKnown)) {
          _markJobFailed(
            current.id,
            current.sizeBytes,
            current.modifiedAt,
            'meta',
          );
        }
      }

      if (needFps && (fps == null && current.fps == null)) {
        _markJobFailed(
          current.id,
          current.sizeBytes,
          current.modifiedAt,
          'fps',
        );
      }

      if (needThumbnail && (thumbnailBytes == null || thumbnailBytes.isEmpty)) {
        _markJobFailed(
          current.id,
          current.sizeBytes,
          current.modifiedAt,
          'thumb',
        );
      }
    } finally {
      try {
        await player.dispose().timeout(_nativeCallTimeout);
      } catch (_) {}
    }
  }

  static Future<Duration?> _readDuration(Player player) {
    final current = player.state.duration;
    if (current > Duration.zero) return Future<Duration?>.value(current);
    return _firstPositiveDuration(player.stream.duration);
  }

  static Future<int?> _readWidth(Player player) {
    final current = player.state.width;
    if (current != null && current > 0) return Future<int?>.value(current);
    return _firstPositiveInt(player.stream.width);
  }

  static Future<int?> _readHeight(Player player) {
    final current = player.state.height;
    if (current != null && current > 0) return Future<int?>.value(current);
    return _firstPositiveInt(player.stream.height);
  }

  /// 读取视频帧率。
  ///
  /// 优先读取 `container-fps`（容器元数据中声明的帧率，由解复用器直接提供，
  /// 无需解码实际视频帧即可极速获取）；若容器未声明、解析失败或数值非正（<= 0），
  /// 再退而尝试读取 `estimated-vf-fps`（基于视频滤镜/解码链估算的帧率）。
  /// 两者均无法获取有效正数时返回 null，绝不硬编码虚假默认值。
  /// 过程用 try-catch 兜底并施加超时，防止阻塞时长/宽高/缩略图等派生主流程。
  static Future<double?> _readFps(Player player) async {
    final platform = player.platform;
    if (platform is! NativePlayer) return null;

    double? parseFps(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      final value = double.tryParse(raw.trim());
      if (value == null || !value.isFinite || value <= 0) return null;
      return value;
    }

    // ⛔ 必须轮询，一次性查询查得太早。
    //
    // `player.open(play: false)` 的 future 完成时，mpv 只是接下了这个文件，
    // **未必已经解析完容器头**。时长和宽高读的是 stream（值到了自然会推过来），
    // 帧率没有对应的 stream，只能主动查——查早了就是空字符串。
    // 实证：不轮询的版本在真机上 138 个视频的 fps 一个都没读出来，日志里
    // 清一色 `fps=null`。
    //
    // 六轮 × 120ms 封顶 0.72 秒，只有在真读不到时才会走满；派生本来就是后台
    // 串行的活，这点代价换的是这个字段有没有值。读不到的那些会由调用方写下
    // `fps_probed_at`，**跨重启**不再重试（内存负缓存冷启动就清零，挡不住）。
    //
    // ⛔ 单次查询的超时不能用 [_metadataTimeout]（8 秒）。`getProperty` 是本地
    // IPC，正常是微秒级；8 秒那档是给"等解码器出结果"用的，安在这里意味着
    // mpv 一旦挂起，6 轮 × 2 个属性 = 最坏 96 秒——而这条串行队列后面还排着
    // 用户正在看的那一屏卡片的缩略图，Player 全程开着。这个仓库有 libmpv
    // 挂起/野指针的旧账，不能假设它不会发生。
    // 双保险：单次 [_propertyProbeTimeout]，整个函数再加一道总预算。
    final budget = Stopwatch()..start();
    String? lastRaw;
    for (var attempt = 0; attempt < 6; attempt++) {
      if (budget.elapsed > _fpsProbeBudget) break;
      for (final property in const <String>[
        'container-fps',
        'estimated-vf-fps',
      ]) {
        try {
          final raw = await platform
              .getProperty(property)
              .timeout(_propertyProbeTimeout);
          lastRaw = raw;
          final value = parseFps(raw);
          if (value != null) return value;
        } catch (_) {
          // 单个属性读失败不算数，还有下一个属性、下一轮。
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    // 留个抓手：读不到时把最后一次的原始返回记下来，否则下一个人只能看到
    // 一个光秃秃的 null，分不清是"容器没写"还是"我们查错了属性名"。
    LogUtils.d('读不到帧率，最后一次原始返回：${lastRaw ?? '(全部抛异常)'}', _tag);
    return null;
  }

  static Future<Duration?> _firstPositiveDuration(
    Stream<Duration> stream,
  ) async {
    try {
      return await stream
          .firstWhere((value) => value > Duration.zero)
          .timeout(_metadataTimeout);
    } catch (_) {
      return null;
    }
  }

  static Future<int?> _firstPositiveInt(Stream<int?> stream) async {
    try {
      return await stream
          .firstWhere((value) => value != null && value > 0)
          .timeout(_metadataTimeout);
    } catch (_) {
      return null;
    }
  }

  /// 自动抓封面时落在哪一帧。
  ///
  /// # ⛔ 不要抓第 0 帧
  ///
  /// 视频开头十有八九是黑场、渐入或者制作组片头，抓出来一屏全是黑卡片——真机上
  /// 就是这样（用户 2026-09-10 反馈）。
  ///
  /// # ⛔ 也不要用真随机
  ///
  /// 同一个文件每次重新派生都会换一张封面：用户刚认出来的那张下次就不见了，出了
  /// 问题也没法复现。这里拿 **id 当种子**，落在时长的 15%~45% 之间——同一个文件
  /// 永远是同一帧，不同文件又各不相同（一个目录里几十集同一部番不会全撞同一个
  /// 画面，这正是"随机"想要的那个效果）。
  ///
  /// 时长拿不到、或者短得只有几秒时返回 null：那种片子 seek 的收益还不如 seek
  /// 本身的开销和失败风险。
  static Duration? coverPositionFor(String id, Duration? duration) {
    final totalMs = duration?.inMilliseconds ?? 0;
    if (totalMs <= 3000) return null;
    var seed = 7;
    for (final unit in id.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    final fraction = 0.15 + (seed % 301) / 1000.0;
    return Duration(milliseconds: (totalMs * fraction).round());
  }

  static Future<Uint8List?> _captureThumbnail(
    Player player, {
    Duration? at,
  }) async {
    try {
      if (at != null) {
        try {
          await player.seek(at).timeout(_nativeCallTimeout);
          // ⛔ seek 之后必须等一下再截：解码器要时间把目标帧解出来，立刻截会拿到
          // seek 之前那一张（或者空）。这一档是实测够用的最小值。
          await Future<void>.delayed(const Duration(milliseconds: 250));
        } catch (_) {
          // seek 失败不致命：退回原来的行为，抓当前那一帧。
        }
      }
      var bytes = await player
          .screenshot(format: 'image/jpeg')
          .timeout(_nativeCallTimeout);
      if (bytes != null && bytes.isNotEmpty) return bytes;

      // Some containers do not expose a decoded frame until playback starts.
      await player.play().timeout(_nativeCallTimeout);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      bytes = await player
          .screenshot(format: 'image/jpeg')
          .timeout(_nativeCallTimeout);
      await player.pause().timeout(_nativeCallTimeout);
      return bytes;
    } catch (_) {
      try {
        await player.pause().timeout(_nativeCallTimeout);
      } catch (_) {}
      return null;
    }
  }

  static Future<FileStat?> _statFile(String path) async {
    try {
      final stat = await File(path).stat();
      return stat.type == FileSystemEntityType.file ? stat : null;
    } catch (_) {
      return null;
    }
  }

  static bool _isContentUri(String path) => path.startsWith('content://');

  static Future<String?> _materializePath(String path) async {
    if (!_isContentUri(path)) return path;
    try {
      return await DeepLinkService.copyContentUriToCache(
        path,
      ).timeout(_nativeCallTimeout);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _exists(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  /// 让用户自己挑封面的那一次会话：**整场只开一个播放器**，滑轨拖到哪儿就
  /// seek 到哪儿抓一帧。
  ///
  /// ⛔ 不要做成「每拖一下调一次一次性的抓帧函数」：那等于每一帧都重新
  /// `Player() + open()`，一次一两秒，滑轨会卡成幻灯片。开一次、复用到用户点完
  /// 确定为止，[close] 由调用方负责（放在弹窗的 dispose 里）。
  static Future<LocalCoverPickerSession?> openCoverPicker(
    String playablePath,
  ) async {
    final player = Player();
    try {
      // 同 [_derive] 里那段长注释：无头播放器默认 `vid=no`，不打开就一帧都抓不到。
      final platform = player.platform;
      if (platform is NativePlayer) {
        await platform.setProperty('vid', 'auto');
        // ⛔ 打开视频轨的同时必须关掉音频轨。抓帧路径在 `screenshot` 拿不到帧时
        // 会退回 `play()` 硬播一小段，而这里是**无头**的：用户可能正在听别的
        // 东西，那一小段会真的外放出来，并抢走系统音频焦点（安卓上表现为别家
        // App 被压低甚至暂停）。
        // 用 `ao=null` 而不是 `setVolume(0)`：后者只把音量调零，音频输出设备照样
        // 打开、焦点照样被抢；前者根本不建音频输出。
        await platform.setProperty('ao', 'null');
      }
      await player
          .open(Media(playablePath), play: false)
          .timeout(_nativeCallTimeout);
      final duration = await _readDuration(player);
      if (duration == null || duration <= Duration.zero) {
        await player.dispose();
        return null;
      }
      return LocalCoverPickerSession._(player, duration);
    } catch (error) {
      LogUtils.w('打开封面选择会话失败：$error', _tag);
      try {
        await player.dispose();
      } catch (_) {}
      return null;
    }
  }

  /// 把用户挑中的这一帧存成 [item] 的封面，并写回 `thumb_path`。
  ///
  /// 返回新封面的绝对路径；失败返回 null。
  ///
  /// ⛔ 文件名带一个**每次都不同**的后缀，不能沿用自动封面那个「路径+大小+mtime」
  /// 的 key：那个 key 对同一个文件永远算出同一个路径，用户重挑一次会写回同一个
  /// 文件名——Flutter 的 image cache 认路径不认内容，界面上会**继续显示旧封面**，
  /// 看着像"没保存成功"。
  Future<String?> saveCustomCover({
    required LocalMediaItem item,
    required Uint8List bytes,
  }) async {
    if (bytes.isEmpty) return null;
    try {
      final stat = File(item.path).statSync();
      if (stat.type != FileSystemEntityType.file) return null;
      final sizeBytes = stat.size;
      final modifiedAt = stat.modified.millisecondsSinceEpoch;

      final scaled = await _scaleThumbnail(
        bytes,
        hintWidth: item.width,
        hintHeight: item.height,
      );
      final directory = await _thumbnailPath();
      final key = sha1
          .convert(
            utf8.encode(
              '${item.path}\u0000$sizeBytes\u0000$modifiedAt'
              '\u0000custom-${DateTime.now().microsecondsSinceEpoch}',
            ),
          )
          .toString();
      final file = File(p.join(directory, '$key.${scaled.extension}'));
      await file.writeAsBytes(scaled.bytes, flush: true);

      // 上一张封面的路径要在写库**之前**记下来：写完 thumb_path 就再也问不出它了。
      final previousThumbPath = _repository.getItem(item.id)?.thumbPath;

      final ok = _repository.updateDerivedFields(
        itemId: item.id,
        expectedSizeBytes: sizeBytes,
        expectedModifiedAt: modifiedAt,
        thumbPath: file.path,
      );
      if (!ok) {
        // 指纹对不上（文件在这中间被换过了）：别留下一个没人引用的文件。
        try {
          await file.delete();
        } catch (_) {}
        return null;
      }

      // ⛔ 换下来的旧封面没人再引用了，删掉。上面那个「每次都不同的文件名」是为了
      // 绕开 Flutter image cache 认路径不认内容的毛病（见方法注释），代价就是用户
      // 每重挑一次封面就多一个孤儿文件——不清的话缓存目录会一直攒。
      // 只删确实换掉了的那个，且路径必须还落在缩略图目录里（sidecar 图片是用户
      // 自己的文件，绝不能碰）。
      if (previousThumbPath != null &&
          previousThumbPath.isNotEmpty &&
          previousThumbPath != file.path &&
          p.isWithin(directory, previousThumbPath)) {
        try {
          await File(previousThumbPath).delete();
        } catch (_) {}
      }
      return file.path;
    } catch (error) {
      LogUtils.w('保存自定义封面失败：$error', _tag);
      return null;
    }
  }

  static Future<String> _thumbnailPath() async {
    final cacheDirectory = await getApplicationCacheDirectory();
    final directory = Directory(
      p.join(cacheDirectory.path, 'local_media_thumbnails'),
    );
    await directory.create(recursive: true);
    final noMedia = File(p.join(directory.path, '.nomedia'));
    if (!await noMedia.exists()) await noMedia.writeAsString('');
    return directory.path;
  }

  static Future<String> _writeThumbnail(
    LocalMediaItem item, {
    required int sizeBytes,
    required int modifiedAt,
    required Uint8List bytes,
    String extension = 'png',
  }) async {
    final directory = await _thumbnailPath();
    final key = sha1
        .convert(utf8.encode('${item.path}\u0000$sizeBytes\u0000$modifiedAt'))
        .toString();
    final file = File(p.join(directory, '$key.$extension'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// 缩放缩略图至长边不超过 640 像素，并编码为 PNG。
  /// 遇到任何异常均退回原 bytes 并保持 JPEG。
  static Future<({Uint8List bytes, String extension})> _scaleThumbnail(
    Uint8List originalBytes, {
    int? hintWidth,
    int? hintHeight,
  }) async {
    try {
      int? targetWidth;
      int? targetHeight;

      var w = (hintWidth != null && hintWidth > 0) ? hintWidth : null;
      var h = (hintHeight != null && hintHeight > 0) ? hintHeight : null;

      if (w == null || h == null) {
        final probeCodec = await ui.instantiateImageCodec(originalBytes);
        final frame = await probeCodec.getNextFrame();
        w = frame.image.width;
        h = frame.image.height;
        frame.image.dispose();
      }

      const maxDimension = 640;
      if (w >= h) {
        if (w > maxDimension) {
          targetWidth = maxDimension;
        }
      } else {
        if (h > maxDimension) {
          targetHeight = maxDimension;
        }
      }

      final codec = await ui.instantiateImageCodec(
        originalBytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      try {
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          );
          return (bytes: pngBytes, extension: 'png');
        }
      } finally {
        image.dispose();
      }
      return (bytes: originalBytes, extension: 'jpg');
    } catch (e) {
      LogUtils.w('缩略图缩放失败，退回写原始 bytes: $e', _tag);
      return (bytes: originalBytes, extension: 'jpg');
    }
  }

  /// 推断本地视频的 VR 格式线索。
  /// 严格按 文件名 -> 文本模糊匹配 -> MP4 box 顺序合成。
  static Future<LocalVrHints> _deriveVrHints(
    String fileName,
    String playablePath,
  ) async {
    // 1. 文件名检测
    final fnSignals = LocalVrFileNameDetector.detect(fileName);
    var strength = fnSignals.strength;
    var projection = fnSignals.projectionHint;
    var stereo = fnSignals.stereoHint;
    final origins = <String>[];
    if (strength != LocalVrSignalStrength.none) {
      origins.add('filename');
    }

    // 2. 若第 1 步 strength 为 none，再用 VrFormatDetector.suspectFromMetadata(title: current.name)
    if (strength == LocalVrSignalStrength.none) {
      final suspicion = VrFormatDetector.suspectFromMetadata(title: fileName);
      if (suspicion.suspected) {
        strength = LocalVrSignalStrength.weak;
        projection = suspicion.projectionHint;
        stereo = suspicion.stereoHint;
        origins.add('text');
      }
    }

    // 3. Mp4StereoBoxReader.read(playablePath)——只在第 1、2 步都没拿到 projection 时才读
    if (projection == null) {
      final boxResult = await Mp4StereoBoxReader.read(playablePath);
      if (boxResult.hasSignal) {
        // 4. 合成规则：box 提供的字段压过文件名/文本的同名字段；
        // box 没提供的字段由文件名/文本补上。
        // strength 取三者里最高的一档，但 box 和 text 永远只能贡献到 weak，抬不到 strong。
        if (boxResult.projection != null) {
          projection = boxResult.projection;
        }
        if (boxResult.stereoLayout != null) {
          stereo = boxResult.stereoLayout;
        }
        if (strength == LocalVrSignalStrength.none) {
          strength = LocalVrSignalStrength.weak;
        }
        origins.add('box');
      }
    }

    return LocalVrHints(
      strength: strength,
      projection: projection,
      stereo: stereo,
      origins: origins,
    );
  }

  /// 'a/b/c' → 'a/b'；'a' → ''（源根）；'' → ''。
  ///
  /// 仅按 '/' 切割 relative path，不使用平台相关的路径分隔符。
  static String _parentRelPath(String relPath) {
    final index = relPath.lastIndexOf('/');
    return index < 0 ? '' : relPath.substring(0, index);
  }
}

class _DerivationRequest {
  _DerivationRequest(this.item, {required this.generateThumbnail});

  final LocalMediaItem item;
  final Completer<void> completer = Completer<void>();
  bool generateThumbnail;

  /// 这一轮是否已经对「抓不抓帧」做过决定。为 false 而 [generateThumbnail] 为 true，
  /// 说明抓帧的意图是在决定点之后才到的，见 [LocalMediaDerivationService._drain]。
  bool thumbnailHandled = false;

  /// 已经为「迟到的抓帧意图」补排过一轮了，不再补第二次。
  bool requeuedForThumbnail = false;
}

class _ImageDerivationRequest {
  _ImageDerivationRequest(this.item);

  final LocalMediaItem item;
  final Completer<void> completer = Completer<void>();
}

/// 「自己挑封面」弹窗持有的一次抓帧会话，见
/// [LocalMediaDerivationService.openCoverPicker]。
class LocalCoverPickerSession {
  LocalCoverPickerSession._(this._player, this.duration);

  final Player _player;

  /// 这条片子的总时长，滑轨的量程。
  final Duration duration;

  bool _closed = false;

  /// 抓 [at] 那一帧。同一时刻只允许有一次在飞：拖动滑轨会连着叫很多次，
  /// 排队跑完既慢又没意义——正在忙时直接返回 null，让调用方丢掉这一次。
  bool _busy = false;

  /// 正在飞的那一次抓帧。[close] 要等它落地才能 dispose，见那边的注释。
  Future<void>? _inFlight;

  Future<Uint8List?> frameAt(Duration at) async {
    if (_closed || _busy) return null;
    _busy = true;
    final completer = Completer<void>();
    _inFlight = completer.future;
    try {
      await _player.seek(at).timeout(const Duration(seconds: 10));
      // ⛔ seek 完要等解码器把目标帧解出来再截，否则拿到的是 seek 之前那一张。
      await Future<void>.delayed(const Duration(milliseconds: 220));
      return await _player
          .screenshot(format: 'image/jpeg')
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    } finally {
      _busy = false;
      _inFlight = null;
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// 关掉会话。
  ///
  /// # ⛔ 必须等在飞的那次抓帧落地才能 dispose
  ///
  /// [_closed] 只挡**后续**调用，挡不住已经进去的那一次：用户拖着滑轨（一次
  /// `screenshot` 正在 await）随手点掉弹窗 → dispose 与 mpv 里在飞的 screenshot
  /// 并发。这正是本仓库那笔旧账的形状——
  /// `runtime_entry.cc: error: Callback invoked after it has been deleted.`，
  /// 死在 mpv 线程上，SIGABRT，Dart 侧一行日志都没有。
  ///
  /// 超时是硬的：等不到就照 dispose 不误。挂住的 Player 比崩溃更难查，而
  /// `frameAt` 自己每一步都带 10 秒超时，正常不可能走满这里。
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final pending = _inFlight;
    if (pending != null) {
      try {
        await pending.timeout(const Duration(seconds: 12));
      } catch (_) {}
    }
    try {
      await _player.dispose();
    } catch (_) {}
  }
}
