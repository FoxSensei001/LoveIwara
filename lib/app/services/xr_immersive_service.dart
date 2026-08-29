import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 把当前视频交给 XR 沉浸空间去呈现。
///
/// # 它对接的是什么
///
/// Quest（`quest` flavor）上，整个应用常驻在自建的沉浸空间里，现有 Flutter UI 是
/// 悬浮其中的一块面板。选中视频后，视频不再画在面板里，而是作为**独立的空间对象**
/// 呈现：平面片走幕布，180/360 片走球幕，配一条空间化的控制条。
///
/// 原生侧落点：`android/app/src/quest/kotlin/**/xr/XrBridge.kt`
/// 与 `**/vr/ImmersiveActivity.kt`。
///
/// # 为什么没有 `if (isQuest)`
///
/// `XrBridge` 在 `standard` / `quest` 两个源集里各有一份同名实现，standard 那份是
/// 空壳、**不注册这个通道**。于是在普通安卓/桌面上调用会直接抛
/// `MissingPluginException`，被这里吃掉并回报「不可用」。
/// 调用点只需要问 [isAvailable]，不需要知道自己跑在什么设备上。
class XrImmersiveService extends GetxService {
  static const MethodChannel _channel = MethodChannel('i_iwara/immersive');

  /// 供 UI 直接 Obx 的可用性。⚠️ 它是**缓存值**，进入播放器时刷一次即可 ——
  /// 沉浸场景的生死只会随「进/出沉浸空间」变化，不会在页面停留期间反复抖动。
  final RxBool available = false.obs;

  Future<void> refreshAvailability() async {
    available.value = await isAvailable();
  }

  /// 沉浸空间当前是否活着。
  ///
  /// ⚠️ 这不是「设备是不是 Quest」——沉浸场景可能还没就绪（例如面板里的 Flutter
  /// 比场景先跑起来）。入口按钮应当用它来决定露不露，并在状态变化时重查。
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('XR 沉浸空间不可用: $e', 'XrImmersive');
      return false;
    }
  }

  /// 把这个视频交给沉浸空间呈现。
  ///
  /// [format] 直接用播放器已有的 L1 判定结果（`MyVideoStateController.vrFormat`）——
  /// ⛔ 那是「默认档」不是判决，用户在播放器里选过就以用户的为准，这里原样透传即可。
  ///
  /// @return true 表示已投递给场景；false 表示场景没就绪（原生侧会暂存，就绪后补投）。
  Future<bool> present({
    required String url,
    required VrSourceFormat format,
    int width = 0,
    int height = 0,
    int positionMs = 0,
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('present', {
        'url': url,
        'shape': _shapeOf(format.projection),
        'stereo': _stereoOf(format.stereoLayout),
        'w': width,
        'h': height,
        'positionMs': positionMs,
      });
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.e('交给沉浸空间失败', tag: 'XrImmersive', error: e);
      return false;
    }
  }

  /// 收起幕布与控制条，把 UI 面板还回来。
  Future<bool> dismiss() async {
    try {
      return await _channel.invokeMethod<bool>('dismiss') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      LogUtils.d('收起沉浸幕布失败: $e', 'XrImmersive');
      return false;
    }
  }

  /// ⛔ 鱼眼映射到 `flat`：Spatial SDK 的面板形状只有
  /// Quad / Equirect180 / Equirect360 / Cylinder，**没有鱼眼**（官方 API reference
  /// 逐字确认过）。强行按球面放会得到一幅变形画面，不如按平面放还能看，
  /// 并在 UI 上如实提示不支持。
  static String _shapeOf(VrProjection projection) => switch (projection) {
    VrProjection.equirect180 => '180',
    VrProjection.equirect360 => '360',
    VrProjection.flat || VrProjection.fisheye => 'flat',
  };

  static String _stereoOf(VrStereoLayout layout) => switch (layout) {
    VrStereoLayout.sideBySide => 'lr',
    VrStereoLayout.topBottom => 'tb',
    VrStereoLayout.mono => 'none',
  };
}
