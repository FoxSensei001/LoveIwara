import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/my_video_state_controller.dart';
import '../../../../../../i18n/strings.g.dart' as slang;

/// 视频画面缩放 / 平移手势层（包裹整个播放器栈）。
///
/// 设计要点：作为整个播放器内容的**祖先** [Listener]。祖先 Listener 会收到所有
/// 派发给其子树的指针事件（无论暂停按钮、工具栏、手势区域是否也在处理），因此能
/// 可靠地侦测双指捏合，而不会被上层叠加的控件“挡住”手指。同时 Listener 不参与
/// 手势竞技场，不会抢夺现有单指手势；冲突由各单指入口在动作时刻读取
/// [MyVideoStateController.isPinchingVideo] / [MyVideoStateController.isVideoZoomed]
/// 主动让位来解决。
///
/// - 移动端：双指捏合缩放（可放大也可缩小到原始大小以下）；缩放后单指拖动平移。
/// - 桌面端：Ctrl + 鼠标滚轮以光标为中心缩放；缩放后鼠标拖动平移。
class VideoZoomGestureLayer extends StatefulWidget {
  final MyVideoStateController controller;
  final Widget child;

  /// 是否启用（关闭时直接透传 child）
  final bool enabled;

  /// 缩放上限
  final double maxScale;

  /// 缩放下限（允许缩小到原始大小以下，类似 PiliPlus）
  final double minScale;

  const VideoZoomGestureLayer({
    super.key,
    required this.controller,
    required this.child,
    this.enabled = true,
    this.maxScale = 3.0,
    this.minScale = 0.5,
  });

  @override
  State<VideoZoomGestureLayer> createState() => _VideoZoomGestureLayerState();
}

class _VideoZoomGestureLayerState extends State<VideoZoomGestureLayer>
    with SingleTickerProviderStateMixin {
  // 桌面端 Ctrl+滚轮缩放的灵敏度（数值越大缩放越慢）
  static const double _wheelScaleFactor = 200.0;
  // 桌面端 Shift+滚轮旋转的灵敏度（数值越大旋转越慢，单位：弧度/滚轮单位）
  static const double _wheelRotateFactor = 500.0;

  /// 当前活跃指针：id -> 最新本地坐标
  final Map<int, Offset> _pointers = {};

  // 双指捏合的上一帧状态
  Offset? _lastFocalPoint;
  double? _lastSpan;
  double? _lastAngle;

  // 触控板 pan/zoom 手势（onPointerPanZoom*）的累计基准
  Offset _trackpadFocal = Offset.zero;
  double _trackpadLastScale = 1.0;
  double _trackpadLastRotation = 0.0;

  // 还原动画
  late final AnimationController _resetController;
  Animation<double>? _resetScaleAnim;
  Animation<Offset>? _resetOffsetAnim;
  Animation<double>? _resetRotationAnim;
  Worker? _resetWorker;

  // 当前布局尺寸（由 LayoutBuilder 写入），用于焦点换算与边界钳制
  Size _size = Size.zero;

  MyVideoStateController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(_onResetTick);
    _resetWorker = ever<int>(_c.videoZoomResetSignal, (_) => _animateReset());
  }

  @override
  void didUpdateWidget(VideoZoomGestureLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 功能被关闭时立即复位：否则画面会残留缩放/旋转且失去还原入口，
    // 且若关闭发生在双指捏合中途，Listener 被移除后 isPinchingVideo 会卡住。
    if (oldWidget.enabled && !widget.enabled) {
      _pointers.clear();
      _lastFocalPoint = null;
      _lastSpan = null;
      _lastAngle = null;
      _c.resetVideoZoomImmediately();
    }
  }

  @override
  void dispose() {
    _resetWorker?.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onResetTick() {
    final scaleAnim = _resetScaleAnim;
    final offsetAnim = _resetOffsetAnim;
    final rotationAnim = _resetRotationAnim;
    if (scaleAnim == null || offsetAnim == null || rotationAnim == null) return;
    _c.applyVideoZoom(scaleAnim.value, offsetAnim.value, rotationAnim.value);
  }

  void _animateReset() {
    if (!mounted) return;
    _lastFocalPoint = null;
    _lastSpan = null;
    _lastAngle = null;
    final curve = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    );
    _resetScaleAnim = Tween<double>(
      begin: _c.videoZoomScale.value,
      end: 1.0,
    ).animate(curve);
    _resetOffsetAnim = Tween<Offset>(
      begin: _c.videoZoomOffset.value,
      end: Offset.zero,
    ).animate(curve);
    _resetRotationAnim = Tween<double>(
      begin: _c.videoZoomRotation.value,
      end: 0.0,
    ).animate(curve);
    _resetController.forward(from: 0);
  }

  // ---- 边界钳制 ----

  /// 计算 BoxFit.contain 下视频在该区域内的实际显示尺寸（scale=1 时）
  Size _fittedVideoSize() {
    final w = _size.width;
    final h = _size.height;
    if (w <= 0 || h <= 0) return Size.zero;
    final aspect = _c.aspectRatio.value;
    if (aspect <= 0) return Size(w, h);
    if (w / h > aspect) {
      // 受高度限制
      return Size(h * aspect, h);
    } else {
      // 受宽度限制
      return Size(w, w / aspect);
    }
  }

  /// 将偏移钳制在缩放后视频可平移的范围内，保证显示矩形始终被填满。
  /// 缩小（scale<1）时上限为 0，画面强制居中。
  Offset _clampOffset(Offset offset, double scale) {
    final fitted = _fittedVideoSize();
    final maxDx = math.max(0.0, fitted.width * (scale - 1) / 2);
    final maxDy = math.max(0.0, fitted.height * (scale - 1) / 2);
    return Offset(
      offset.dx.clamp(-maxDx, maxDx),
      offset.dy.clamp(-maxDy, maxDy),
    );
  }

  /// 将向量 [v] 旋转 [angle] 弧度
  static Offset _rotateVec(Offset v, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
  }

  /// 把角度增量归一化到 [-pi, pi]，避免 atan2 跨越 ±pi 时跳变
  static double _normalizeAngle(double a) {
    while (a > math.pi) {
      a -= 2 * math.pi;
    }
    while (a < -math.pi) {
      a += 2 * math.pi;
    }
    return a;
  }

  /// 以 [focal] 为锚点，同时调整缩放（[oldScale]→[newScale]）、旋转
  /// （[oldRotation]→[newRotation]）并叠加平移 [panDelta]，保持 focal 下内容不动。
  ///
  /// 显示映射： s = center + offset + R(rotation) · scale · (c - center)
  void _applyTransform({
    required Offset focal,
    required double oldScale,
    required double newScale,
    required double oldRotation,
    required double newRotation,
    Offset panDelta = Offset.zero,
  }) {
    if (_size == Size.zero) return;
    final center = Offset(_size.width / 2, _size.height / 2);
    final oldOffset = _c.videoZoomOffset.value;

    final clampedScale = newScale.clamp(widget.minScale, widget.maxScale);

    // newOffset = (focal-center) + panDelta
    //           - (newScale/oldScale)·R(newRot-oldRot)·(focal-center-oldOffset)
    final focalVec = focal - center - oldOffset;
    final rotated =
        _rotateVec(focalVec, newRotation - oldRotation) *
        (clampedScale / oldScale);
    Offset newOffset = (focal - center) + panDelta - rotated;
    newOffset = _clampOffset(newOffset, clampedScale);

    // 接近原始大小且未旋转时吸附到初始状态，干净退出
    if ((clampedScale - 1.0).abs() < 0.01 && newRotation.abs() < 0.01) {
      _c.applyVideoZoom(1.0, Offset.zero, 0.0);
    } else {
      _c.applyVideoZoom(clampedScale, newOffset, newRotation);
    }
  }

  // ---- 指针事件 ----

  void _onPointerDown(PointerDownEvent event) {
    _resetController.stop();
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length >= 2) {
      _beginPinch();
    }
  }

  void _beginPinch() {
    _c.isPinchingVideo = true;
    // 捏合开始时，取消可能已经开始的单指交互（如横滑进度预览）
    _c.setInteracting(false);
    _c.showSeekPreview(false);
    final pts = _pointers.values.toList();
    _lastFocalPoint = _averageOffset(pts);
    _lastSpan = _averageSpan(pts, _lastFocalPoint!);
    _lastAngle = _twoFingerAngle(pts);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length >= 2) {
      _handlePinch();
    } else if (_pointers.length == 1 &&
        _c.isVideoZoomed &&
        event.kind == PointerDeviceKind.mouse &&
        !_c.isLongPressing.value) {
      // 桌面端：缩放状态下鼠标拖动平移画面（移动端平移用双指拖动）；
      // 长按倍速进行中时不平移，避免调速时画面跟着移动。
      final newOffset = _clampOffset(
        _c.videoZoomOffset.value + event.delta,
        _c.videoZoomScale.value,
      );
      _c.applyVideoZoom(
        _c.videoZoomScale.value,
        newOffset,
        _c.videoZoomRotation.value,
      );
    }
  }

  void _handlePinch() {
    final pts = _pointers.values.toList();
    final focal = _averageOffset(pts);
    final span = _averageSpan(pts, focal);
    final angle = _twoFingerAngle(pts);

    if (_lastFocalPoint == null || _lastSpan == null || _lastSpan == 0) {
      _lastFocalPoint = focal;
      _lastSpan = span;
      _lastAngle = angle;
      return;
    }

    final scaleFactor = span / _lastSpan!;
    final oldScale = _c.videoZoomScale.value;
    final oldRotation = _c.videoZoomRotation.value;
    final panDelta = focal - _lastFocalPoint!;
    final rotationDelta = (_lastAngle == null || angle == null)
        ? 0.0
        : _normalizeAngle(angle - _lastAngle!);

    _applyTransform(
      focal: _lastFocalPoint!,
      oldScale: oldScale,
      newScale: oldScale * scaleFactor,
      oldRotation: oldRotation,
      newRotation: oldRotation + rotationDelta,
      panDelta: panDelta,
    );

    _lastFocalPoint = focal;
    _lastSpan = span;
    _lastAngle = angle;
  }

  void _onPointerUpOrCancel(PointerEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) {
      _c.isPinchingVideo = false;
      _lastFocalPoint = _pointers.isNotEmpty ? _pointers.values.first : null;
      _lastSpan = null;
      _lastAngle = null;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final keyboard = HardwareKeyboard.instance;
    final oldScale = _c.videoZoomScale.value;
    final oldRotation = _c.videoZoomRotation.value;

    if (keyboard.isControlPressed) {
      // Ctrl + 滚轮：以光标为中心缩放
      _resetController.stop();
      final scaleChange = math.exp(-event.scrollDelta.dy / _wheelScaleFactor);
      _applyTransform(
        focal: event.localPosition,
        oldScale: oldScale,
        newScale: oldScale * scaleChange,
        oldRotation: oldRotation,
        newRotation: oldRotation,
      );
    } else if (keyboard.isShiftPressed) {
      // Shift + 滚轮：以光标为中心旋转
      _resetController.stop();
      final rotationDelta = event.scrollDelta.dy / _wheelRotateFactor;
      _applyTransform(
        focal: event.localPosition,
        oldScale: oldScale,
        newScale: oldScale,
        oldRotation: oldRotation,
        newRotation: oldRotation + rotationDelta,
      );
    }
  }

  // ---- 触控板原生手势（捏合缩放 + 旋转 + 平移）----

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    _resetController.stop();
    _c.isPinchingVideo = true;
    _c.setInteracting(false);
    _c.showSeekPreview(false);
    _trackpadFocal = event.localPosition;
    _trackpadLastScale = 1.0;
    _trackpadLastRotation = 0.0;
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    final oldScale = _c.videoZoomScale.value;
    final oldRotation = _c.videoZoomRotation.value;
    final scaleFactor = _trackpadLastScale == 0
        ? 1.0
        : event.scale / _trackpadLastScale;
    final rotationDelta = event.rotation - _trackpadLastRotation;

    _applyTransform(
      focal: _trackpadFocal,
      oldScale: oldScale,
      newScale: oldScale * scaleFactor,
      oldRotation: oldRotation,
      newRotation: oldRotation + rotationDelta,
      panDelta: event.localPanDelta,
    );

    _trackpadLastScale = event.scale;
    _trackpadLastRotation = event.rotation;
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    _c.isPinchingVideo = false;
  }

  /// 两指连线的角度（弧度）；少于 2 指返回 null
  double? _twoFingerAngle(List<Offset> pts) {
    if (pts.length < 2) return null;
    final d = pts[1] - pts[0];
    return math.atan2(d.dy, d.dx);
  }

  static Offset _averageOffset(List<Offset> pts) {
    var dx = 0.0;
    var dy = 0.0;
    for (final p in pts) {
      dx += p.dx;
      dy += p.dy;
    }
    return Offset(dx / pts.length, dy / pts.length);
  }

  static double _averageSpan(List<Offset> pts, Offset focal) {
    var total = 0.0;
    for (final p in pts) {
      total += (p - focal).distance;
    }
    return total / pts.length;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUpOrCancel,
          onPointerCancel: _onPointerUpOrCancel,
          onPointerSignal: _onPointerSignal,
          onPointerPanZoomStart: _onPointerPanZoomStart,
          onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
          onPointerPanZoomEnd: _onPointerPanZoomEnd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              _buildRestoreButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestoreButton() {
    return Positioned(
      right: 12,
      bottom: 96,
      child: Obx(() {
        if (!_c.isVideoZoomed) return const SizedBox.shrink();
        final t = slang.Translations.of(context);
        return _RestorePill(
          label: t.videoDetail.restoreDefaultZoom,
          scale: _c.videoZoomScale.value,
          onTap: _c.requestResetVideoZoom,
        );
      }),
    );
  }
}

class _RestorePill extends StatelessWidget {
  final String label;
  final double scale;
  final VoidCallback onTap;

  const _RestorePill({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 图标提示「点一下会发生什么」：放大态显示缩小图标，缩小态显示放大图标，
    // 仅旋转/平移（scale≈1）时显示还原图标。
    final IconData icon;
    if (scale > 1.0001) {
      icon = Icons.zoom_out;
    } else if (scale < 0.9999) {
      icon = Icons.zoom_in;
    } else {
      icon = Icons.restart_alt;
    }
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '${scale.toStringAsFixed(1)}x · $label',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
