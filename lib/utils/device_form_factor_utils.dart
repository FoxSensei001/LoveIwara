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
    this.isXr = false,
  });

  factory MobileDeviceFormFactorInfo.fromPlatformMap(
    Map<dynamic, dynamic> map,
  ) {
    return MobileDeviceFormFactorInfo(
      platformIsTablet: map['platformIsTablet'] as bool?,
      smallestWidthDp: _readDouble(map['smallestWidthDp']),
      source: map['source'] as String?,
      model: map['model'] as String?,
      isXr: map['isXr'] as bool? ?? false,
    );
  }

  final bool? platformIsTablet;
  final double? smallestWidthDp;
  final String? source;
  final String? model;

  /// 是否运行在 XR 头显（Meta Quest / Horizon OS、Android XR）上。
  final bool isXr;

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
  static bool _cachedIsXrDevice = false;

  /// 是否运行在 XR 头显上（同步读，需先经过一次 [resolveMobileDeviceType]，
  /// 启动时 main.dart 的 [applyMobileOrientationPolicy] 已经完成这次解析）。
  ///
  /// XR 上 App 是一块用户可任意拖拽宽高的 2D 面板：只要 App 请求了固定方向，
  /// 系统就按那个方向给面板加信箱边，面板拖宽到一定程度画面不再变宽——只有进
  /// 播放器全屏（那时请求的是横屏）才是真实宽高。所以 XR 上一律不请求方向。
  static bool get isXrDevice => _cachedIsXrDevice;

  /// 指针的 hover（进入/离开）语义是否可信。
  ///
  /// XR 头显上 App 是一块 2D 面板，指针来自手柄射线：射线扫过面板会派发
  /// hover，但射线移开面板、或应用失去焦点时**收不到对应的 exit**——
  /// `MouseRegion` 于是永远停在「还在里面」。所有「悬停期间常驻」的 UI
  /// （Seek Preview、悬停时不自动收起工具栏）因此会一直挂在屏幕上不消失。
  ///
  /// 所以这些地方一律按「这台设备没有 hover」处理：XR 上射线本来就是点按
  /// 设备而不是停驻的鼠标，悬停态对它没有意义。
  static bool get supportsPointerHover => !isXrDevice;

  /// [isXrDevice] 的异步版本：确保平台信息已读取。
  static Future<bool> resolveIsXrDevice() async {
    if (!isMobilePlatform) return false;
    await resolveMobileDeviceType();
    return _cachedIsXrDevice;
  }

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
      isXr: info?.isXr ?? false,
    );

    _cachedFormFactorInfo = info;
    _cachedMobileDeviceType = deviceType;
    _cachedIsXrDevice = info?.isXr ?? false;

    final smallestWidthText = info?.smallestWidthDp?.toStringAsFixed(0);
    LogUtils.d(
      '移动端设备类型: ${deviceType.name}, '
          'isXr=${info?.isXr ?? false}, '
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
    // XR 头显唯一允许的方向请求是「不请求」：任何固定方向都会让系统按该方向
    // 给面板加信箱边，用户把面板拖宽也不会真的变宽。
    if (_cachedIsXrDevice && mode != 'unlock') {
      LogUtils.d('XR 头显忽略方向请求: $mode -> unlock', 'DeviceFormFactor');
      mode = 'unlock';
    }
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
    bool isXr = false,
  }) {
    // XR 头显的窗口是可拖拽的 2D 面板，smallestWidthDp 常常 < 600 会被判成手机
    // 而锁竖屏，进而被系统加信箱边锁死宽度。这里直接按「不锁方向」的那一档处理。
    if (isXr) return MobileDeviceType.tablet;

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
    _cachedIsXrDevice = false;
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
