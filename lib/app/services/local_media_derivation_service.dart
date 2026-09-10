import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// Derives metadata and on-demand thumbnails for local video files.
///
/// The queue is deliberately serialized. A media-kit [Player] owns native
/// decoder resources, and opening a large number of local files at once can
/// starve the player the user is currently watching.
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

  /// Queues metadata work. Thumbnail generation is opt-in because a scan
  /// should not decode every file just to populate a list.
  Future<void> enqueue(LocalMediaItem item, {bool generateThumbnail = false}) {
    if (item.missing) return Future<void>.value();

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

  /// Ensures that the item has a cached thumbnail when it has no sidecar.
  /// Returns the latest database row so callers can repaint with derived data.
  Future<LocalMediaItem?> ensureThumbnail(LocalMediaItem item) async {
    await enqueue(item, generateThumbnail: true);
    return _repository.getItem(item.id);
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_pendingIds.isNotEmpty) {
        final id = _pendingIds.removeFirst();
        final request = _pending[id];
        if (request == null) continue;
        try {
          await _derive(request);
        } catch (error, stackTrace) {
          LogUtils.e(
            '本地媒体派生失败：${request.item.path}',
            tag: _tag,
            error: error,
            stackTrace: stackTrace,
          );
        } finally {
          _pending.remove(id);
          if (!request.completer.isCompleted) request.completer.complete();
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

    final initialStat = await _statFile(current.path);
    if (initialStat == null ||
        current.sizeBytes != initialStat.size ||
        current.modifiedAt != initialStat.modified.millisecondsSinceEpoch) {
      return;
    }

    final sidecarAvailable = await _exists(current.sidecarImagePath);
    final thumbAvailable = await _exists(current.thumbPath);
    final needDuration = current.durationMs == null;
    final needWidth = current.width == null;
    final needHeight = current.height == null;
    final needThumbnail =
        request.generateThumbnail && !sidecarAvailable && !thumbAvailable;
    if (!needDuration && !needWidth && !needHeight && !needThumbnail) return;

    final player = Player();
    try {
      await player
          .open(Media(current.path), play: false)
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
      // A second request may upgrade a metadata-only request while the player
      // is open, so read the mutable flag immediately before capturing.
      if (request.generateThumbnail && !sidecarAvailable && !thumbAvailable) {
        thumbnailBytes = await _captureThumbnail(player);
      }

      final finalStat = await _statFile(current.path);
      if (finalStat == null ||
          finalStat.size != initialStat.size ||
          finalStat.modified.millisecondsSinceEpoch !=
              initialStat.modified.millisecondsSinceEpoch) {
        return;
      }

      String? thumbPath;
      if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
        thumbPath = await _writeThumbnail(
          current,
          sizeBytes: finalStat.size,
          modifiedAt: finalStat.modified.millisecondsSinceEpoch,
          bytes: thumbnailBytes,
        );
      }

      _repository.updateDerivedFields(
        itemId: current.id,
        expectedSizeBytes: finalStat.size,
        expectedModifiedAt: finalStat.modified.millisecondsSinceEpoch,
        durationMs: duration?.inMilliseconds,
        width: width,
        height: height,
        thumbPath: thumbPath,
      );
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
  }) async {
    final directory = await _thumbnailPath();
    final key = sha1
        .convert(utf8.encode('${item.path}\u0000$sizeBytes\u0000$modifiedAt'))
        .toString();
    final file = File(p.join(directory, '$key.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

class _DerivationRequest {
  _DerivationRequest(this.item, {required this.generateThumbnail});

  final LocalMediaItem item;
  final Completer<void> completer = Completer<void>();
  bool generateThumbnail;
}
