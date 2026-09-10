import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// Android MediaStore 视频索引返回的一行数据。
///
/// 条目身份优先尝试由 [volumeName]、[relativePath] 与 [displayName] 重建出的
/// 真实文件路径决定，无法重建或路径不可读时，[contentUri] 作为播放与身份兜底句柄。
class AndroidMediaStoreVideo {
  const AndroidMediaStoreVideo({
    required this.contentUri,
    required this.displayName,
    this.mediaStoreId,
    this.modifiedAtSeconds,
    this.mimeType,
    this.sizeBytes,
    this.modifiedAt,
    this.durationMs,
    this.width,
    this.height,
    this.relativePath,
    this.bucketName,
    this.volumeName,
    this.addedAt,
  });

  final String contentUri;
  final String displayName;
  final int? mediaStoreId;
  final int? modifiedAtSeconds;
  final String? mimeType;
  final int? sizeBytes;
  final int? modifiedAt;
  final int? durationMs;
  final int? width;
  final int? height;
  final String? relativePath;
  final String? bucketName;
  final String? volumeName;
  final int? addedAt;

  factory AndroidMediaStoreVideo.fromMap(Map<Object?, Object?> raw) {
    int? asInt(Object? value) => value is num ? value.toInt() : null;
    String? asString(Object? value) =>
        value is String && value.isNotEmpty ? value : null;

    final modifiedAtSeconds = asInt(raw['modifiedAtSeconds']);
    return AndroidMediaStoreVideo(
      contentUri: raw['contentUri'] as String? ?? '',
      displayName: raw['displayName'] as String? ?? 'video',
      mediaStoreId: asInt(raw['mediaStoreId']),
      modifiedAtSeconds: modifiedAtSeconds,
      mimeType: asString(raw['mimeType']),
      sizeBytes: asInt(raw['sizeBytes']),
      modifiedAt: modifiedAtSeconds == null || modifiedAtSeconds <= 0
          ? null
          : modifiedAtSeconds * 1000,
      durationMs: asInt(raw['durationMs']),
      width: asInt(raw['width']),
      height: asInt(raw['height']),
      relativePath: asString(raw['relativePath']),
      bucketName: asString(raw['bucketName']),
      volumeName: asString(raw['volumeName']),
      addedAt: asInt(raw['addedAtSeconds']) == null
          ? null
          : asInt(raw['addedAtSeconds'])! * 1000,
    );
  }
}

/// Flutter facade for Android MediaStore.
///
/// The channel is intentionally isolated from the generic file-handler
/// channel. MediaStore permission failures and provider changes have a
/// different lifecycle from opening one external file.
class AndroidMediaStoreService extends GetxService {
  static AndroidMediaStoreService get to => Get.find();

  static const int pageSize = 400;
  static const Duration _nativeCallTimeout = Duration(seconds: 15);

  final MethodChannel _channel = MethodChannel(
    CommonConstants.androidMediaStoreChannelName,
  );
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  @override
  void onInit() {
    super.onInit();
    if (!GetPlatform.isAndroid) return;
    _channel.setMethodCallHandler(_handleNativeCall);
    unawaited(_startObserver());
  }

  Future<void> _startObserver() async {
    try {
      await _channel
          .invokeMethod<void>('startObserver')
          .timeout(_nativeCallTimeout);
    } catch (e, s) {
      LogUtils.e(
        '启动 MediaStore 观察器失败',
        tag: 'AndroidMediaStore',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<Object?> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onMediaStoreChanged') {
      if (!_changes.isClosed) _changes.add(null);
      return null;
    }
    return null;
  }

  Future<List<AndroidMediaStoreVideo>> queryVideos({
    int? afterModifiedAtSeconds,
    int? afterMediaStoreId,
    int limit = pageSize,
  }) async {
    if (!GetPlatform.isAndroid) return const <AndroidMediaStoreVideo>[];
    final arguments = <String, Object?>{'limit': limit.clamp(1, pageSize)};
    if (afterModifiedAtSeconds != null && afterMediaStoreId != null) {
      arguments['afterModifiedAtSeconds'] = afterModifiedAtSeconds;
      arguments['afterMediaStoreId'] = afterMediaStoreId;
    }
    final raw = await _channel
        .invokeMethod<Object?>('queryVideos', arguments)
        .timeout(_nativeCallTimeout);
    if (raw is! Map) throw StateError('MediaStore query returned invalid data');
    final rawItems = raw['items'];
    if (rawItems is! List) {
      throw StateError('MediaStore query returned no item list');
    }
    return <AndroidMediaStoreVideo>[
      for (final item in rawItems)
        if (item is Map) _parseItem(item),
    ];
  }

  static AndroidMediaStoreVideo _parseItem(Map item) {
    final video = AndroidMediaStoreVideo.fromMap(item);
    if (video.contentUri.isEmpty ||
        video.mediaStoreId == null ||
        video.modifiedAtSeconds == null) {
      throw StateError('MediaStore item is missing its stable cursor key');
    }
    return video;
  }

  @override
  void onClose() {
    _channel.setMethodCallHandler(null);
    unawaited(_changes.close());
    super.onClose();
  }

  static void logQueryFailure(Object error, StackTrace stackTrace) {
    LogUtils.e(
      '查询 Android MediaStore 失败',
      tag: 'AndroidMediaStore',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
