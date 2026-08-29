import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:i_iwara/app/models/vr_format.model.dart';

/// 片源格式的几何换算：单眼取景矩形、单眼宽高比、球面角度跨度、视角钳制。
///
/// 摆在 utils 而不是播放器 widget 目录下，是因为两头都要用：widget 层拿它算
/// 裁切和 shader 的 uniform，控制器拿它钳制 yaw/pitch/fov。全是纯函数，不碰
/// Flutter 之外的任何东西。
class VrGeometry {
  const VrGeometry._();

  // ── 单眼取景 ─────────────────────────────────────────────────────────────

  /// 单眼在**整帧**里占的归一化矩形。
  ///
  /// 立体片是把左右两眼压进同一帧的，我们在平面屏上只能显示一只眼——显示两只
  /// 眼就是「两个挤扁的画面」，也就是用户今天看到的那个没法看的样子。取左眼／
  /// 上半幅是行业惯例（左眼是主视角）。
  static Rect eyeRect(VrStereoLayout layout) {
    switch (layout) {
      case VrStereoLayout.mono:
        return const Rect.fromLTWH(0, 0, 1, 1);
      case VrStereoLayout.sideBySide:
        return const Rect.fromLTWH(0, 0, 0.5, 1);
      case VrStereoLayout.topBottom:
        return const Rect.fromLTWH(0, 0, 1, 0.5);
    }
  }

  /// 单眼画面的真实宽高比 = 整帧宽高比 × (取景宽 / 取景高)。
  ///
  /// 半幅左右并排的 3840×1080（整帧 3.56:1）取左眼后是 1920×1080（1.78:1）；
  /// 上下堆叠的 1920×2160（0.89:1）取上半幅后同样回到 1.78:1。**还原宽高比这一
  /// 步不能省**——只裁不拉的话画面仍然是挤扁的，等于白裁。
  static double eyeAspectRatio(double frameAspectRatio, VrStereoLayout layout) {
    if (!frameAspectRatio.isFinite || frameAspectRatio <= 0) return 16 / 9;
    final rect = eyeRect(layout);
    return frameAspectRatio * (rect.width / rect.height);
  }

  // ── 球面跨度 ─────────────────────────────────────────────────────────────

  /// 单眼等距图覆盖的角度跨度（水平, 竖直），弧度。
  ///
  /// 竖直恒为 π（半个球从天顶到地底）；水平 180° 片是 π、360° 片是 2π。
  /// [VrProjection.flat] 不该走到这里（平面没有球面跨度），保守返回 360° 的值。
  static ({double horizontal, double vertical}) angularSpan(
    VrProjection projection,
  ) {
    switch (projection) {
      case VrProjection.equirect180:
        return (horizontal: math.pi, vertical: math.pi);
      case VrProjection.equirect360:
      case VrProjection.fisheye:
      case VrProjection.flat:
        return (horizontal: math.pi * 2, vertical: math.pi);
    }
  }

  // ── 视角（yaw / pitch / fov） ─────────────────────────────────────────────

  /// 默认竖直视野角：75°。
  ///
  /// 比头显里的真实视野窄，但平面屏上看全景本来就不是「身临其境」而是「透过一
  /// 扇窗看」——视野开太大边缘透视畸变会很难看，开太小又要拖半天才转得过来。
  static const double defaultFovY = 75 * math.pi / 180;

  /// 视野角下限（放到最大时）。
  static const double minFovY = 30 * math.pi / 180;

  /// 视野角上限（缩到最小时）。
  static const double maxFovY = 110 * math.pi / 180;

  /// 抬头/低头的上限：±80°。
  ///
  /// 不放到 ±90° 是因为正对天顶时等距图的所有经线挤在一个点上，画面会糊成一
  /// 团麻花，而那一点内容量约等于零，挡住没有损失。
  static const double maxPitch = 80 * math.pi / 180;

  static double clampFovY(double fovY) => fovY.clamp(minFovY, maxFovY);

  static double clampPitch(double pitch) => pitch.clamp(-maxPitch, maxPitch);

  /// 钳制偏航角。
  ///
  /// 360° 片是**绕回**而不是钳死（转一圈回到原地才是对的）；180° 片只有半个球，
  /// 视线中心超出 ±90° 就整屏全黑，所以钳在跨度的一半上。
  static double normalizeYaw(double yaw, VrProjection projection) {
    if (!yaw.isFinite) return 0;
    final span = angularSpan(projection).horizontal;
    if (projection == VrProjection.equirect360) {
      const twoPi = math.pi * 2;
      var wrapped = (yaw + math.pi) % twoPi;
      if (wrapped < 0) wrapped += twoPi;
      return wrapped - math.pi;
    }
    final limit = span / 2;
    return yaw.clamp(-limit, limit);
  }

  /// 由竖直视野角与画面宽高比推出水平视野角。拖动灵敏度按它标定：横拖过整个
  /// 播放区，视角正好转过一个水平视野——手指划过的距离和画面转过的角度对得上，
  /// 这是「跟手」的定义。
  static double horizontalFov(double fovY, double viewportAspect) {
    if (!viewportAspect.isFinite || viewportAspect <= 0) return fovY;
    return 2 * math.atan(math.tan(fovY / 2) * viewportAspect);
  }
}
