import 'dart:async';

import 'package:flutter/services.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 进入画中画失败的原因，对应原生 `PipBridge.enter` 回传的 `reason`。
enum AndroidPipFailure {
  /// 设备或系统不支持画中画。
  unsupported,

  /// Activity 不在 resumed：系统要求 resumed 才能主动进入画中画。
  notResumed,

  /// 系统返回 false（例如锁屏任务模式）。
  refused,

  /// 其他异常，或通道本身调用失败。
  error,
}

class AndroidPipEnterResult {
  const AndroidPipEnterResult.entered()
    : failure = null,
      detail = null,
      sdkInt = null;

  const AndroidPipEnterResult.failed(this.failure, this.detail, this.sdkInt);

  final AndroidPipFailure? failure;

  /// 失败时的原生异常信息与当时的 Activity 生命周期，只用于日志。
  final String? detail;

  /// 设备的 Android SDK 版本；通道本身失败时为 null。
  final int? sdkInt;

  bool get entered => failure == null;

  /// 能否改设「离开应用时自动进入」来兜底。
  ///
  /// 只有 Android 12+ 行：那里由系统服务端在切走时触发；更早的版本得在
  /// onUserLeaveHint 里再调一次 enterPictureInPictureMode，拦住它的还是同一道
  /// 客户端闸门，当场失败了那里照样失败。
  bool get canDeferToLeave =>
      failure == AndroidPipFailure.notResumed && (sdkInt ?? 0) >= 31;
}

/// 安卓画中画（小窗），原生那半见 `PipBridge.kt`。
///
/// 进入状态由系统的 `onPictureInPictureModeChanged` 推过来（[modeChanges]），
/// 不轮询。
class AndroidPip {
  AndroidPip._();

  static const MethodChannel _channel = MethodChannel('i_iwara/pip');
  static const String _tag = 'AndroidPip';

  static final StreamController<bool> _modeChanges =
      StreamController<bool>.broadcast(onListen: _ensureHandler);
  static bool _handlerInstalled = false;

  /// 进出画中画时推送 true / false。
  static Stream<bool> get modeChanges => _modeChanges.stream;

  static void _ensureHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPipModeChanged' && call.arguments is bool) {
        _modeChanges.add(call.arguments as bool);
      }
      return null;
    });
  }

  static Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (e) {
      LogUtils.w('查询画中画支持失败: $e', _tag);
      return false;
    }
  }

  static Future<bool> isInPip() async {
    try {
      return await _channel.invokeMethod<bool>('isInPip') ?? false;
    } catch (e) {
      LogUtils.w('查询画中画状态失败: $e', _tag);
      return false;
    }
  }

  /// 立即进入画中画。宽高比超出系统范围时原生侧会夹到边界上。
  static Future<AndroidPipEnterResult> enter({
    required int width,
    required int height,
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>('enter', {
        'width': width,
        'height': height,
      });
      if (result?['entered'] == true) {
        return const AndroidPipEnterResult.entered();
      }
      final failure = switch (result?['reason']) {
        'unsupported' => AndroidPipFailure.unsupported,
        'notResumed' => AndroidPipFailure.notResumed,
        'refused' => AndroidPipFailure.refused,
        _ => AndroidPipFailure.error,
      };
      final sdkInt = result?['sdk'];
      return AndroidPipEnterResult.failed(
        failure,
        'sdk=$sdkInt, lifecycle=${result?['lifecycle']}, '
        'message=${result?['message']}',
        sdkInt is int ? sdkInt : null,
      );
    } catch (e) {
      return AndroidPipEnterResult.failed(AndroidPipFailure.error, '$e', null);
    }
  }

  /// 离开应用时自动进入画中画；`width` / `height` 传 null 撤销。返回是否生效。
  static Future<bool> setAutoEnter({int? width, int? height}) async {
    final enabled = width != null && height != null;
    try {
      return await _channel.invokeMethod<bool>('setAutoEnter', {
            'enabled': enabled,
            if (enabled) 'width': width,
            if (enabled) 'height': height,
          }) ??
          false;
    } catch (e) {
      LogUtils.w('设置离开时自动画中画失败: $e', _tag);
      return false;
    }
  }
}
