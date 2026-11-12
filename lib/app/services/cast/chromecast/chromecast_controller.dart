import 'dart:async';
import 'dart:io';

import 'package:i_iwara/utils/logger_utils.dart';

import '../cast_device.dart';
import '../dlna/dlna_controller.dart' show guessVideoMime;
import 'cast_channel.dart';

const _tag = 'Chromecast';

abstract interface class ChromecastTransport {
  /// 在设备上启动默认媒体接收器并开始播放 [url]。返回接收器会话 id，停止时用。
  Future<String> load(ChromecastDevice device, String url, {String? title});

  /// 停掉 [sessionId] 对应的接收器应用；它已经不在跑了（被别的 App 接管）就什么也不做。
  Future<void> stop(ChromecastDevice device, String? sessionId);
}

/// 用 Google 的默认媒体接收器（Default Media Receiver）播放直链。
///
/// 无状态：每次 load / stop 各连一次、做完就断开。默认媒体接收器在发送端断开后
/// 会继续播放，所以不需要一直挂着连接（也就不怕 App 进后台被系统掐网络）。
class CastV2ChromecastTransport implements ChromecastTransport {
  const CastV2ChromecastTransport();

  /// Default Media Receiver。
  static const String defaultReceiverAppId = 'CC1AD845';

  @override
  Future<String> load(
    ChromecastDevice device,
    String url, {
    String? title,
  }) async {
    final channel = await _open(device);
    try {
      channel.connectTo(CastChannel.receiver);

      // 1. 启动默认媒体接收器，等它出现在 RECEIVER_STATUS 里并给出 transportId。
      //    只认带自己 requestId 的回应；回应里还没有应用（仍在启动）时，才接受
      //    之后的广播状态——否则 LAUNCH 生效前别的发送端触发的一条旧状态会被
      //    当成结果，拿到旧会话的 transportId。
      var ownResponseSeen = false;
      final launched = await channel.request(
        namespace: CastChannel.nsReceiver,
        destinationId: CastChannel.receiver,
        payload: {'type': 'LAUNCH', 'appId': defaultReceiverAppId},
        timeout: const Duration(seconds: 20),
        accept: (m, requestId) {
          if (m.namespace != CastChannel.nsReceiver) return false;
          final own = m.requestId == requestId;
          if (own && m.type != 'RECEIVER_STATUS') return true; // 各种错误
          if (m.type != 'RECEIVER_STATUS') return false;
          if (own) ownResponseSeen = true;
          return _findApp(m) != null && (own || ownResponseSeen);
        },
      );
      if (launched.type != 'RECEIVER_STATUS') {
        throw CastException(
          CastFailure.deviceRejected,
          '${launched.type} ${launched.payload['reason'] ?? ''}',
        );
      }
      final app = _findApp(launched)!;
      final transportId = app['transportId'] as String;
      final sessionId = app['sessionId'] as String?;

      // 2. 连上接收器应用，发 LOAD。
      channel.connectTo(transportId);
      final loaded = await channel.request(
        namespace: CastChannel.nsMedia,
        destinationId: transportId,
        payload: {
          'type': 'LOAD',
          'autoplay': true,
          'currentTime': 0,
          'media': {
            'contentId': url,
            'contentUrl': url,
            'contentType': guessVideoMime(url),
            'streamType': 'BUFFERED',
            'metadata': {
              'type': 0,
              'metadataType': 0,
              'title': (title == null || title.isEmpty) ? 'Video' : title,
            },
          },
        },
        timeout: const Duration(seconds: 25),
        accept: (m, requestId) =>
            m.namespace == CastChannel.nsMedia && m.requestId == requestId,
      );
      switch (loaded.type) {
        case 'MEDIA_STATUS':
          LogUtils.i('Chromecast 开始播放：${device.name}', _tag);
          return sessionId ?? '';
        case 'LOAD_FAILED':
          throw CastException(CastFailure.mediaRejected, 'LOAD_FAILED');
        case 'LOAD_CANCELLED':
          throw CastException(CastFailure.mediaRejected, 'LOAD_CANCELLED');
        default:
          throw CastException(
            CastFailure.deviceRejected,
            '${loaded.type} ${loaded.payload['reason'] ?? ''}',
          );
      }
    } on TimeoutException {
      throw CastException(CastFailure.timeout, 'Cast 请求超时');
    } on CastException {
      rethrow;
    } on IOException catch (e) {
      // 中途断开（SocketException / TLS 错误）。
      throw CastException(CastFailure.unreachable, '$e');
    } catch (e) {
      throw CastException(CastFailure.deviceRejected, '$e');
    } finally {
      await channel.close();
    }
  }

  @override
  Future<void> stop(ChromecastDevice device, String? sessionId) async {
    final channel = await _open(device);
    try {
      channel.connectTo(CastChannel.receiver);
      final status = await channel.request(
        namespace: CastChannel.nsReceiver,
        destinationId: CastChannel.receiver,
        payload: {'type': 'GET_STATUS'},
        accept: (m, requestId) =>
            m.namespace == CastChannel.nsReceiver &&
            m.type == 'RECEIVER_STATUS',
      );
      final app = _findApp(status);
      if (app == null) return;
      final runningSession = app['sessionId'] as String?;
      // 别人后来又投了别的东西（同一个默认接收器、不同会话）就不去关。
      if (sessionId != null &&
          sessionId.isNotEmpty &&
          runningSession != sessionId) {
        return;
      }
      await channel.request(
        namespace: CastChannel.nsReceiver,
        destinationId: CastChannel.receiver,
        payload: {'type': 'STOP', 'sessionId': runningSession},
        accept: (m, requestId) =>
            m.namespace == CastChannel.nsReceiver &&
            m.type == 'RECEIVER_STATUS',
      );
    } on TimeoutException {
      throw CastException(CastFailure.timeout, 'Cast 请求超时');
    } on CastException {
      rethrow;
    } on IOException catch (e) {
      // 中途断开（SocketException / TLS 错误）。
      throw CastException(CastFailure.unreachable, '$e');
    } catch (e) {
      throw CastException(CastFailure.deviceRejected, '$e');
    } finally {
      await channel.close();
    }
  }

  static Future<CastChannel> _open(ChromecastDevice device) async {
    try {
      return await CastChannel.connect(device.address, device.port);
    } catch (e) {
      LogUtils.w('连接 Chromecast 失败 ${device.address}:${device.port}: $e', _tag);
      throw CastException(CastFailure.unreachable, '${device.address}: $e');
    }
  }

  static Map<String, dynamic>? _findApp(CastMessage m) {
    final status = m.payload['status'];
    if (status is! Map) return null;
    final apps = status['applications'];
    if (apps is! List) return null;
    for (final app in apps) {
      if (app is Map<String, dynamic> &&
          app['appId'] == defaultReceiverAppId &&
          app['transportId'] is String) {
        return app;
      }
    }
    return null;
  }
}
