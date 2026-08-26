import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:i_iwara/utils/logger_utils.dart';

enum MobileDeviceType { phone, tablet }

class MobileDeviceFormFactorInfo {
  const MobileDeviceFormFactorInfo({
    required this.platformIsTablet,
    required this.smallestWidthDp,
    required this.source,
    required this.model,
  });

  factory MobileDeviceFormFactorInfo.fromPlatformMap(
    Map<dynamic, dynamic> map,
  ) {
    return MobileDeviceFormFactorInfo(
      platformIsTablet: map['platformIsTablet'] as bool?,
      smallestWidthDp: _readDouble(map['smallestWidthDp']),
      source: map['source'] as String?,
      model: map['model'] as String?,
    );
  }

  final bool? platformIsTablet;
  final double? smallestWidthDp;
  final String? source;
  final String? model;

  static double? _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }
}

class DeviceFormFactorUtils {
  static const MethodChannel _channel = MethodChannel(
    'i_iwara/device_form_factor',
  );

  static const MethodChannel _orientationChannel = MethodChannel(
    'i_iwara/orientation',
  );

  static MobileDeviceType? _cachedMobileDeviceType;
  static MobileDeviceFormFactorInfo? _cachedFormFactorInfo;

  static bool get isMobilePlatform =>
      GetPlatform.isAndroid || GetPlatform.isIOS;

  static Future<bool> isPhone({bool refresh = false}) async {
    final deviceType = await resolveMobileDeviceType(refresh: refresh);
    return deviceType == MobileDeviceType.phone;
  }

  static Future<MobileDeviceType> resolveMobileDeviceType({
    bool refresh = false,
  }) async {
    if (!isMobilePlatform) {
      return MobileDeviceType.tablet;
    }

    if (!refresh && _cachedMobileDeviceType != null) {
      return _cachedMobileDeviceType!;
    }

    final info = await _readPlatformFormFactorInfo();
    final deviceType = classifyMobileDisplay(
      platformReportsTablet: info?.platformIsTablet,
      fallbackLogicalTablet: _logicalViewportLooksTablet(),
    );

    _cachedFormFactorInfo = info;
    _cachedMobileDeviceType = deviceType;

    final smallestWidthText = info?.smallestWidthDp?.toStringAsFixed(0);
    LogUtils.d(
      '移动端设备类型: ${deviceType.name}, '
          'smallestWidthDp=${smallestWidthText ?? 'unknown'}, '
          'source=${info?.source ?? 'logical_viewport_fallback'}, '
          'model=${info?.model ?? 'unknown'}',
      'DeviceFormFactor',
    );

    return deviceType;
  }

  static Future<MobileDeviceFormFactorInfo?> getFormFactorInfo({
    bool refresh = false,
  }) async {
    if (!isMobilePlatform) return null;
    if (!refresh && _cachedFormFactorInfo != null) return _cachedFormFactorInfo;
    _cachedFormFactorInfo = await _readPlatformFormFactorInfo();
    return _cachedFormFactorInfo;
  }

  /// 恢复 App 的移动端方向策略：手机锁竖屏，平板交还给系统/平台配置。
  static Future<void> applyMobileOrientationPolicy({
    bool refresh = false,
  }) async {
    if (!isMobilePlatform) return;

    try {
      final deviceType = await resolveMobileDeviceType(refresh: refresh);
      await SystemChrome.setPreferredOrientations(
        deviceType == MobileDeviceType.phone
            ? const [DeviceOrientation.portraitUp]
            : const [],
      );
      // Android 原生同步基线：手机锁竖屏、平板放开（清除全屏施加的横屏强制）。
      await forceNativeOrientation(
        deviceType == MobileDeviceType.phone ? 'portrait' : 'unlock',
      );
    } catch (e, s) {
      LogUtils.e(
        '应用移动端屏幕方向策略失败',
        tag: 'DeviceFormFactor',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// 原生强制屏幕方向（仅 Android 生效；iOS/桌面 no-op）。
  /// mode: 'landscape_left' / 'landscape_right'（固定横屏方向，
  /// SCREEN_ORIENTATION_(REVERSE_)LANDSCAPE 无视系统自动旋转锁）/ 'portrait' / 'unlock'。
  /// ⚠️ 不要再传笼统的 'landscape'：原生侧曾经把它映射成 SENSOR_LANDSCAPE（方向交
  /// 给传感器决定），会整只吃掉用户在设置里选的左/右横屏方向。
  /// 兜底 setPreferredOrientations 在部分安卓机型 / 关闭自动旋转时不转屏的问题。
  static Future<void> forceNativeOrientation(String mode) async {
    if (!GetPlatform.isAndroid) return;
    try {
      await _orientationChannel.invokeMethod<void>('setOrientation', mode);
    } on MissingPluginException catch (e) {
      LogUtils.w('原生方向通道未注册（旧原生层）: $e', 'DeviceFormFactor');
    } catch (e, s) {
      LogUtils.e(
        '原生强制方向失败: $mode',
        tag: 'DeviceFormFactor',
        error: e,
        stackTrace: s,
      );
    }
  }

  @visibleForTesting
  static MobileDeviceType classifyMobileDisplay({
    required bool? platformReportsTablet,
    required bool fallbackLogicalTablet,
  }) {
    if (platformReportsTablet != null) {
      return platformReportsTablet
          ? MobileDeviceType.tablet
          : MobileDeviceType.phone;
    }

    return fallbackLogicalTablet
        ? MobileDeviceType.tablet
        : MobileDeviceType.phone;
  }

  @visibleForTesting
  static void resetCacheForTesting() {
    _cachedMobileDeviceType = null;
    _cachedFormFactorInfo = null;
  }

  static Future<MobileDeviceFormFactorInfo?>
  _readPlatformFormFactorInfo() async {
    try {
      final raw = await _channel.invokeMethod<Object?>(
        'getDeviceFormFactorInfo',
      );
      if (raw is Map) {
        return MobileDeviceFormFactorInfo.fromPlatformMap(raw);
      }
    } on MissingPluginException catch (e) {
      LogUtils.w('设备形态通道未注册: $e', 'DeviceFormFactor');
    } catch (e, s) {
      LogUtils.e('读取设备形态失败', tag: 'DeviceFormFactor', error: e, stackTrace: s);
    }
    return null;
  }

  static bool _logicalViewportLooksTablet() {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return false;

    final view = views.first;
    if (view.devicePixelRatio <= 0) return false;

    final logicalSize = view.physicalSize / view.devicePixelRatio;
    return logicalSize.shortestSide >= 600;
  }
}
