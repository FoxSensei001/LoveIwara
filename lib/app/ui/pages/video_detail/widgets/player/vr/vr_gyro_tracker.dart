import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, WidgetsBinding;
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/xr_capability.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/vr/vr_panorama_shader.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/rx_ever.dart';

/// 陀螺仪采样间隔。100Hz：50Hz 在 90/120Hz 屏上转得一顿一顿的，再快就是白耗
/// 平台通道（安卓 12 起超过 200Hz 还要额外权限）。
///
/// ⛔ 探测与正式订阅必须用**同一个**间隔：sensors_plus 的采样间隔是整条通道共用的，
/// 探测拿另一个值去订阅，会把正在跑的 tracker 一起改慢。
const Duration _kGyroInterval = Duration(milliseconds: 10);

/// 加速度计只用来校正倾角漂移，50Hz 足够。
const Duration _kAccelInterval = SensorInterval.gameInterval;

/// 「这台设备上要不要提供陀螺仪转视角」的统一问法。
///
/// 两级：[platformEligible] 是同步的平台判定（手机 / 平板、且不在头显的空间形态
/// 里）；[available] 是真的问过传感器之后的结果。设置项和首次提示都要两级都过。
class VrGyroSupport {
  const VrGyroSupport._();

  /// 平台上有没有可能用：只有安卓 / iOS，且不是 Quest（头显自己就是头部追踪，
  /// 2D 播放器在那边也不渲染）。桌面端没有陀螺仪。
  ///
  /// 还要跑得动环视着色器：跑不动时画面退回单眼裁切，那条路不读视角，开关摆
  /// 出来也不起作用。
  static bool get platformEligible =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) &&
      !xrSpatialFormFactor &&
      VrPanoramaShader.isSupported;

  /// 探测结果：null = 还没问过（或上次超时），true / false = 有没有陀螺仪。
  ///
  /// 是 Rx：设置项在 Obx 里读它，探测回来时自己露出 / 藏起。
  static final RxnBool available = RxnBool();

  static Future<bool>? _probing;

  /// 问一次传感器。结果缓存在 [available]，同一进程里只探一次。
  ///
  /// sensors_plus 没有「有没有这个传感器」的接口，只能真订阅一下：安卓上没有
  /// 陀螺仪时流会立刻报 `NO_SENSOR`；iOS 上没有就永远不回事件，所以要超时。
  /// 超时也记成「没有」：2 秒都等不来一包事件，当成有只会让开关摆在那里却不
  /// 起作用，还会每次进设置页都再订阅 2 秒。
  static Future<bool> ensureProbed() {
    if (!platformEligible) return Future.value(false);
    final known = available.value;
    if (known != null) return Future.value(known);
    return _probing ??= _probe().whenComplete(() => _probing = null);
  }

  static Future<bool> _probe() async {
    final completer = Completer<bool?>();
    StreamSubscription<GyroscopeEvent>? sub;
    try {
      sub = gyroscopeEventStream(samplingPeriod: _kGyroInterval).listen(
        (_) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (Object _) {
          if (!completer.isCompleted) completer.complete(false);
        },
        cancelOnError: true,
      );
    } catch (_) {
      if (!completer.isCompleted) completer.complete(false);
    }
    final result = await completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () => null,
    );
    await sub?.cancel();
    available.value = result ?? false;
    return result ?? false;
  }
}

/// 把手机的转动折算成环视视角的**增量**，交给 [onDelta]。
///
/// # 为什么报增量而不是绝对朝向
///
/// 视角状态只有一份（控制器上的 yaw / pitch），手指拖动往里加偏移、陀螺仪也往
/// 里加，两者天然叠加：拖动等于在手机朝向上再加一个偏移，不用另外记「拖了多少」。
/// 起点校准也因此是免费的——开始追踪那一刻手机朝哪，就以那里为正前方，画面停
/// 在当时的视角上不跳。
///
/// # 姿态怎么来
///
/// 陀螺仪角速度积分出姿态，加速度计（重力方向）以约 1 秒的时间常数校正倾角
/// 漂移。重力不可少：拿手机通常是往后仰着的，只积分陀螺仪的话「转身」那条转轴
/// 在机身坐标里是斜的，转半圈画面会凭空抬头 / 低头好几十度。偏航没有绝对参照
/// （不用磁力计，室内太不可靠），会极慢地漂，拖一下就回来了。
///
/// # 横竖屏
///
/// 视线方向恒为机身 -Z（屏幕背面朝外），与屏幕当前转到哪一边无关；偏航、俯仰
/// 都只从视线方向算，所以横竖屏切换既不用换坐标系、也不会让画面跳一下。只有
/// 「横滚」（手机绕屏幕法线拧）与屏幕方向有关，而着色器的视角没有横滚这一维，
/// 画面始终和屏幕边框对齐。
///
/// # 什么时候订阅传感器
///
/// 只有同时满足这些才订阅，任何一条不满足就立刻退订（省电）：
///   - 设置里开着 [ConfigKey.VR_GYRO_CONTROL_KEY]；
///   - 至少有一块环视画面挂在树上、且没被别的页面盖住（[setViewerActive]）；
///   - 应用在前台。
///
/// 一个播放控制器只有一只 tracker：内嵌播放器和全屏路由两块画面共用同一份
/// 视角，各订一份的话每次转动都会被加两遍。
class VrGyroTracker {
  VrGyroTracker({required this.onDelta});

  /// 视角增量，弧度：偏航正数向右转、俯仰正数抬头（与着色器的约定一致）。
  final void Function(double deltaYaw, double deltaPitch) onDelta;

  /// 视线接近竖直（|sin 俯仰| 超过它，约 75°）时偏航无从定义：这时手机稍微一拧，
  /// 算出来的偏航就能甩半圈。只报俯仰，偏航那一下丢掉。
  static const double _kYawReliableBelow = 0.966;

  /// 倾角校正的时间常数，秒。太小画面会被走路时的晃动带着抖，太大漂移收得慢。
  static const double _kTiltCorrectionTau = 1.0;

  static const double _kGravity = 9.81;

  /// 攒够这么多（弧度，约 0.06°）才往外报一次。手机放着不动时陀螺仪噪声和
  /// 重力校正每包都有一丝增量，逐包报的话画面会按陀螺仪频率（100Hz）空转重绘，
  /// 暂停时也停不下来。
  static const double _kEmitThreshold = 1e-3;

  final Set<Object> _viewers = <Object>{};
  bool _appVisible = true;
  bool _disposed = false;
  Worker? _configWorker;
  AppLifecycleListener? _lifecycle;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  /// 机身 → 世界的姿态（世界系 +Y 朝天，水平朝向任意）。null = 还没拿到第一包
  /// 重力，不知道哪边是上，陀螺仪先不积分。
  _Quat? _attitude;
  int? _lastGyroMicros;
  int? _lastAccelMicros;
  double? _lastYaw;
  double? _lastPitch;
  double _pendingYaw = 0;
  double _pendingPitch = 0;

  /// 一块环视画面的「我要不要陀螺仪」：挂上、且没被盖住时为 true。
  /// [viewer] 是画面自己的身份（传它的 State 即可），同一块画面重复报不会重复计。
  void setViewerActive(Object viewer, bool active) {
    if (_disposed) return;
    final changed = active ? _viewers.add(viewer) : _viewers.remove(viewer);
    if (!changed) return;
    _ensureWatching();
    _sync();
  }

  void dispose() {
    _disposed = true;
    _viewers.clear();
    _configWorker?.dispose();
    _configWorker = null;
    _lifecycle?.dispose();
    _lifecycle = null;
    _stop();
  }

  /// 第一次有画面来要时才挂开关监听和前后台监听：绝大多数视频不是 VR，
  /// 它们的控制器不该为这件事多挂任何东西。
  void _ensureWatching() {
    if (_configWorker == null && Get.isRegistered<ConfigService>()) {
      final rx =
          Get.find<ConfigService>().settings[ConfigKey.VR_GYRO_CONTROL_KEY];
      if (rx != null) _configWorker = rxEver(rx, (_) => _sync());
    }
    if (_lifecycle == null) {
      // 监听是懒挂的，挂上那一刻应用可能已经在后台（着色器头一回加载、还没回来
      // 用户就切走了）——先按当前状态初始化，否则会在后台一直订阅到下次切换。
      _appVisible = _isVisible(WidgetsBinding.instance.lifecycleState);
    }
    _lifecycle ??= AppLifecycleListener(
      onStateChange: (state) {
        _appVisible = _isVisible(state);
        _sync();
      },
    );
  }

  static bool _isVisible(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  bool get _enabledInSettings =>
      Get.isRegistered<ConfigService>() &&
      Get.find<ConfigService>()[ConfigKey.VR_GYRO_CONTROL_KEY] == true;

  void _sync() {
    final shouldRun =
        !_disposed &&
        _viewers.isNotEmpty &&
        _appVisible &&
        _enabledInSettings &&
        VrGyroSupport.platformEligible &&
        VrGyroSupport.available.value != false;
    if (shouldRun) {
      _start();
    } else {
      _stop();
    }
  }

  void _start() {
    if (_gyroSub != null) return;
    // 每次重新开始都重新校准：退到后台再回来、被别的页面盖住再露出来，手机
    // 朝向早就变了，接着上次的姿态积分只会让画面一下甩过去。
    _attitude = null;
    _lastGyroMicros = null;
    _lastAccelMicros = null;
    _lastYaw = null;
    _lastPitch = null;
    _pendingYaw = 0;
    _pendingPitch = 0;
    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: _kAccelInterval,
      ).listen(_onAccel, onError: _onSensorError, cancelOnError: true);
      _gyroSub = gyroscopeEventStream(
        samplingPeriod: _kGyroInterval,
      ).listen(_onGyro, onError: _onSensorError, cancelOnError: true);
    } catch (e) {
      _onSensorError(e);
    }
  }

  void _stop() {
    unawaited(_gyroSub?.cancel());
    unawaited(_accelSub?.cancel());
    _gyroSub = null;
    _accelSub = null;
  }

  void _onSensorError(Object error) {
    LogUtils.w('陀螺仪视角追踪的传感器流出错，本次停用: $error', 'VrGyroTracker');
    // 没有这个传感器：记下来，开关和底栏那枚图标跟着藏起，也不再反复重订。
    if (error is PlatformException && error.code == 'NO_SENSOR') {
      VrGyroSupport.available.value = false;
    }
    // 流已经因为 cancelOnError 断了，引用要清掉，否则 _start 会以为还在跑。
    _stop();
  }

  void _onAccel(AccelerometerEvent e) {
    final norm = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (norm < 1e-3) return;
    // 静止时加速度计读到的是「托住手机的那股力」，方向朝天。
    final up = _Vec3(e.x / norm, e.y / norm, e.z / norm);

    final micros = e.timestamp.microsecondsSinceEpoch;
    final lastMicros = _lastAccelMicros;
    _lastAccelMicros = micros;

    final attitude = _attitude;
    if (attitude == null) {
      // 第一包可信的重力：把机身里的「上」转到世界 +Y，水平朝向随它去（反正只
      // 报增量）。手机正晃着时读数偏离 1g，拿它定姿会让画面之后几秒慢慢滑回来，
      // 等下一包。
      if ((norm - _kGravity).abs() > _kGravity * 0.15) return;
      _attitude = _Quat.fromTo(up, const _Vec3(0, 1, 0));
      return;
    }

    // 正在甩手机（读数明显偏离 1g）时重力方向不可信，这一包不校正。
    if ((norm - _kGravity).abs() > _kGravity * 0.15) return;
    if (lastMicros == null) return;
    final dt = (micros - lastMicros) / 1e6;
    if (dt <= 0 || dt > 0.5) return;

    // 按当前估计，重力指的「上」在世界系里落在哪；把它往世界 +Y 掰一小步。
    // 转轴 m × Y 是水平的，所以这一步只修倾角，不碰偏航。
    final m = attitude.rotate(up);
    final axisX = -m.z;
    final axisZ = m.x;
    final sinAngle = math.sqrt(axisX * axisX + axisZ * axisZ);
    if (sinAngle < 1e-6) return;
    final angle = math.atan2(sinAngle, m.y);
    final gain = (dt / _kTiltCorrectionTau).clamp(0.0, 0.2);
    final correction = _Quat.fromAxisAngle(
      _Vec3(axisX / sinAngle, 0, axisZ / sinAngle),
      angle * gain,
    );
    _attitude = (correction * attitude).normalized();
  }

  void _onGyro(GyroscopeEvent e) {
    final micros = e.timestamp.microsecondsSinceEpoch;
    final lastMicros = _lastGyroMicros;
    _lastGyroMicros = micros;
    final attitude = _attitude;
    if (attitude == null || lastMicros == null) return;
    final dt = (micros - lastMicros) / 1e6;
    // 断流后的第一包（间隔异常大）不积分：那段时间里转了多少无从知道，
    // 硬积分只会拿一个瞬时角速度乘上一大段时间，画面猛甩一下。
    if (dt <= 0 || dt > 0.1) return;

    // 角速度是机身坐标系里的，所以右乘。
    _attitude =
        (attitude * _Quat.fromRotationVector(e.x * dt, e.y * dt, e.z * dt))
            .normalized();
    _emit();
  }

  void _emit() {
    final attitude = _attitude;
    if (attitude == null) return;
    // 视线 = 机身 -Z（从屏幕背面穿出去），转到世界系。
    final look = attitude.rotate(const _Vec3(0, 0, -1));
    final pitch = math.asin(look.y.clamp(-1.0, 1.0));
    // 世界系 Y 朝天、看向 -Z 时右手边是 +X，向右转时 x 分量变大，偏航为正。
    final yaw = math.atan2(look.x, -look.z);

    final lastPitch = _lastPitch;
    final lastYaw = _lastYaw;
    _lastPitch = pitch;
    _lastYaw = yaw;
    if (lastPitch == null || lastYaw == null) return;

    final deltaPitch = pitch - lastPitch;
    var deltaYaw = 0.0;
    if (look.y.abs() < _kYawReliableBelow) {
      deltaYaw = yaw - lastYaw;
      // 跨过 ±π 那条缝时折回来。
      if (deltaYaw > math.pi) deltaYaw -= 2 * math.pi;
      if (deltaYaw < -math.pi) deltaYaw += 2 * math.pi;
    }
    _pendingYaw += deltaYaw;
    _pendingPitch += deltaPitch;
    if (_pendingYaw.abs() < _kEmitThreshold &&
        _pendingPitch.abs() < _kEmitThreshold) {
      return;
    }
    final yawOut = _pendingYaw;
    final pitchOut = _pendingPitch;
    _pendingYaw = 0;
    _pendingPitch = 0;
    onDelta(yawOut, pitchOut);
  }
}

class _Vec3 {
  const _Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

/// 单位四元数，只放这里用得到的几样运算。
class _Quat {
  const _Quat(this.w, this.x, this.y, this.z);

  final double w;
  final double x;
  final double y;
  final double z;

  /// 绕单位轴 [axis] 转 [angle] 弧度。
  factory _Quat.fromAxisAngle(_Vec3 axis, double angle) {
    final half = angle / 2;
    final s = math.sin(half);
    return _Quat(math.cos(half), axis.x * s, axis.y * s, axis.z * s);
  }

  /// 旋转向量（方向 = 转轴，长度 = 角度）。陀螺仪一包的角速度 × dt 正是它。
  factory _Quat.fromRotationVector(double rx, double ry, double rz) {
    final angle = math.sqrt(rx * rx + ry * ry + rz * rz);
    if (angle < 1e-12) return const _Quat(1, 0, 0, 0);
    return _Quat.fromAxisAngle(
      _Vec3(rx / angle, ry / angle, rz / angle),
      angle,
    );
  }

  /// 把单位向量 [from] 转到单位向量 [to] 的最短旋转。
  factory _Quat.fromTo(_Vec3 from, _Vec3 to) {
    final dot = from.x * to.x + from.y * to.y + from.z * to.z;
    if (dot < -0.999999) {
      // 正好反向：随便找一根垂直于 from 的轴转半圈。
      final axis = from.x.abs() < 0.9
          ? _normalize(_Vec3(0, -from.z, from.y))
          : _normalize(_Vec3(from.z, 0, -from.x));
      return _Quat.fromAxisAngle(axis, math.pi);
    }
    final cx = from.y * to.z - from.z * to.y;
    final cy = from.z * to.x - from.x * to.z;
    final cz = from.x * to.y - from.y * to.x;
    return _Quat(1 + dot, cx, cy, cz).normalized();
  }

  static _Vec3 _normalize(_Vec3 v) {
    final n = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    return _Vec3(v.x / n, v.y / n, v.z / n);
  }

  _Quat operator *(_Quat o) => _Quat(
    w * o.w - x * o.x - y * o.y - z * o.z,
    w * o.x + x * o.w + y * o.z - z * o.y,
    w * o.y - x * o.z + y * o.w + z * o.x,
    w * o.z + x * o.y - y * o.x + z * o.w,
  );

  _Quat normalized() {
    final n = math.sqrt(w * w + x * x + y * y + z * z);
    if (n < 1e-12) return const _Quat(1, 0, 0, 0);
    return _Quat(w / n, x / n, y / n, z / n);
  }

  /// q · v · q*
  _Vec3 rotate(_Vec3 v) {
    // t = 2 · (q.xyz × v)；v' = v + w·t + q.xyz × t
    final tx = 2 * (y * v.z - z * v.y);
    final ty = 2 * (z * v.x - x * v.z);
    final tz = 2 * (x * v.y - y * v.x);
    return _Vec3(
      v.x + w * tx + (y * tz - z * ty),
      v.y + w * ty + (z * tx - x * tz),
      v.z + w * tz + (x * ty - y * tx),
    );
  }
}
