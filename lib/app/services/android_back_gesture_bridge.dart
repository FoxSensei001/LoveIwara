import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// Android 预测返回/返回动画相关的能力桥接。
///
/// 目标（方案 1）：
/// - 对支持预测返回动画的系统：Home root 交回系统处理，从而获得系统手势返回动画；
/// - 对不支持/已关闭预测返回动画的系统：仍由 Flutter 接管返回，以便执行 exit confirm 等拦截逻辑。
class AndroidBackGestureBridge {
  AndroidBackGestureBridge._();

  static const MethodChannel _channel = MethodChannel(
    'i_iwara/system_settings',
  );

  static bool? _backAnimationEnabled;
  static Future<bool>? _loadBackAnimationEnabledFuture;

  static bool? _lastFrameworkHandlesBack;
  static bool? _lastFlutterBackCallbackEnabled;

  /// 是否启用了系统预测返回动画（Settings.Global.enable_back_animation）。
  ///
  /// - `true`：系统层面允许预测返回动画（若系统实现支持）
  /// - `false`：系统不支持/已关闭
  /// - `null`：尚未加载（默认按 false 处理更安全：保留 exit confirm）
  static bool? get backAnimationEnabled => _backAnimationEnabled;

  static Future<bool> loadBackAnimationEnabledOnce() {
    if (!GetPlatform.isAndroid) {
      _backAnimationEnabled = false;
      return Future.value(false);
    }
    if (_backAnimationEnabled != null) {
      return Future.value(_backAnimationEnabled!);
    }
    return _loadBackAnimationEnabledFuture ??= _loadBackAnimationEnabled();
  }

  static Future<bool> _loadBackAnimationEnabled() async {
    try {
      final int? v = await _channel.invokeMethod<int>('getEnableBackAnimation');
      _backAnimationEnabled = (v ?? 0) == 1;
      LogUtils.d(
        'loadBackAnimationEnabledOnce: enable_back_animation=$v -> enabled=$_backAnimationEnabled',
        'AndroidBackGestureBridge',
      );
      return _backAnimationEnabled!;
    } on PlatformException catch (e) {
      LogUtils.w(
        'loadBackAnimationEnabledOnce failed: ${e.code} ${e.message}',
        'AndroidBackGestureBridge',
      );
      _backAnimationEnabled = false;
      return false;
    } catch (e) {
      LogUtils.w(
        'loadBackAnimationEnabledOnce failed: $e',
        'AndroidBackGestureBridge',
      );
      _backAnimationEnabled = false;
      return false;
    } finally {
      _loadBackAnimationEnabledFuture = null;
    }
  }

  /// 同步 Android 预测返回链路应由 Flutter 还是系统接管。
  ///
  /// 该方法会：
  /// - 调用 [SystemNavigator.setFrameworkHandlesBack]（Flutter 框架侧）；
  /// - 通过 MethodChannel 控制 MainActivity 的 OnBackInvokedCallback（native 兜底）。
  ///
  /// 内部带简单去重：当目标状态与上次一致时不会重复写入。
  static void syncFrameworkHandlesBack({
    required bool shouldHandleBack,
    required String reason,
  }) {
    if (!GetPlatform.isAndroid) return;

    final needFrameworkSync = _lastFrameworkHandlesBack != shouldHandleBack;
    final needNativeSync = _lastFlutterBackCallbackEnabled != shouldHandleBack;

    if (!needFrameworkSync && !needNativeSync) return;

    if (needFrameworkSync) {
      try {
        SystemNavigator.setFrameworkHandlesBack(shouldHandleBack);
        _lastFrameworkHandlesBack = shouldHandleBack;
      } on PlatformException catch (e) {
        LogUtils.w(
          'syncFrameworkHandlesBack framework failed: ${e.code} ${e.message}, '
              'shouldHandleBack=$shouldHandleBack, reason=$reason',
          'AndroidBackGestureBridge',
        );
      } catch (e) {
        LogUtils.w(
          'syncFrameworkHandlesBack framework failed: $e, '
              'shouldHandleBack=$shouldHandleBack, reason=$reason',
          'AndroidBackGestureBridge',
        );
      }
    }

    if (needNativeSync) {
      unawaited(
        _setFlutterBackCallbackEnabledInternal(shouldHandleBack).then((
          success,
        ) {
          if (success) {
            _lastFlutterBackCallbackEnabled = shouldHandleBack;
          }
        }),
      );
    }
  }

  /// 启用/禁用 MainActivity 中的 OnBackInvokedCallback → Flutter popRoute 的兜底。
  ///
  /// - `true`：确保返回交给 Flutter（避免 OEM 走 TYPE_RETURN_TO_HOME 直接 finish）
  /// - `false`：Home root 交回系统（允许系统返回桌面动画/行为）
  static Future<bool> setFlutterBackCallbackEnabled(bool enabled) async {
    return _setFlutterBackCallbackEnabledInternal(enabled);
  }

  static Future<bool> _setFlutterBackCallbackEnabledInternal(
    bool enabled,
  ) async {
    if (!GetPlatform.isAndroid) return false;
    try {
      await _channel.invokeMethod<void>(
        'setFlutterBackCallbackEnabled',
        <String, dynamic>{'enabled': enabled},
      );
      return true;
    } catch (_) {
      // Best-effort only.
      return false;
    }
  }
}
