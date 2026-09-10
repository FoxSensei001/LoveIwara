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

  final LocalMediaRepository _repository;
  final Queue<String> _pendingIds = Queue<String>();
  final Map<String, _DerivationRequest> _pending =
      <String, _DerivationRequest>{};
  bool _draining = false;

  /// 派生作业失败的负缓存。
  /// Key 为 `itemId:size:mtime:job`，job 取 'meta' 或 'thumb'。
  /// 一个文件解不出元数据、或抓不出封面帧时记在这里；只要大小与修改时间没变，
  /// 就不再为它开 Player 白等原生解码超时（一次要等 [_metadataTimeout]）。
  ///
  /// ⛔ **有上限**：一个源可能有几万条，无上限的话这张表会随进程一直长。Dart 的
  /// `Set` 是插入序的，超了就从最旧的开始丢——丢掉的最坏结果只是那一条日后多重试
  /// 一次，而不是错误的结果。
  static const int _maxFailedJobKeys = 2048;
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

  /// 把这一条排进派生队列。缩略图是 opt-in 的：一次扫描不该为了填列表就把每个
  /// 文件都解一遍。
  ///
  /// 返回的 future 在这一轮跑完时完成，**不带结果**。"到底有没有变化"不是这里
  /// 能回答的问题，见 [ensureDerived]。
  Future<void> enqueue(LocalMediaItem item, {bool generateThumbnail = false}) {
    if (item.missing) return Future<void>.value();

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

  Future<void> _derive(_DerivationRequest request) async {
    final current = _repository.getItem(request.item.id);
    if (current == null || current.missing) return;

    final sidecarAvailable = await _exists(current.sidecarImagePath);
    final thumbAvailable = await _exists(current.thumbPath);
    final needDuration = current.durationMs == null;
    final needWidth = current.width == null;
    final needHeight = current.height == null;
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
        (!needDuration && !needWidth && !needHeight) ||
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

      final metadata = await Future.wait<Object?>([
        durationFuture,
        widthFuture,
        heightFuture,
      ]);
      final duration = metadata[0] as Duration?;
      final width = metadata[1] as int?;
      final height = metadata[2] as int?;

      Uint8List? thumbnailBytes;
      // A second request may upgrade a metadata-only request's generateThumbnail flag
      // while the player is open, so read request.generateThumbnail immediately before capturing.
      if (request.generateThumbnail && !sidecarAvailable && !thumbAvailable) {
        request.thumbnailHandled = true;
        thumbnailBytes = await _captureThumbnail(player);
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

      _repository.updateDerivedFields(
        itemId: current.id,
        expectedSizeBytes: current.sizeBytes,
        expectedModifiedAt: current.modifiedAt,
        durationMs: duration?.inMilliseconds,
        width: width,
        height: height,
        thumbPath: thumbPath,
        vrFormatJson: vrFormatJson,
      );

      // 这一行是留给真机核查的抓手：上一版「一件事都没做成」之所以能一直没被
      // 发现，就是因为整条派生链路成功时一声不吭，只有异常才有日志。
      LogUtils.d(
        '派生完成 ${current.name}：'
        'duration=${duration?.inMilliseconds} ${width}x$height '
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

  static Future<Uint8List?> _captureThumbnail(Player player) async {
    try {
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
