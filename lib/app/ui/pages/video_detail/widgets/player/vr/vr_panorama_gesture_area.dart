import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/utils/vr_geometry.dart';

/// 平面环视模式下的画面区手势：拖动＝转头，捏合／滚轮＝改视野角。
///
/// # 为什么它要把常规手势整只顶掉
///
/// 环视模式下画面区的拖动**只能有一个含义**。常规模式里横拖是快进快退、竖拖是
/// 亮度／音量，三者和「转头」争的是同一条手势，谁也不肯让谁的结果就是三样都不
/// 准。业界的做法一致：YouTube 的 360 播放器里画面区拖动只管环视，快进只在进度
/// 条上；第三方手势增强工具遇到全景视频也是直接把自己关掉。Quest 那边同样——
/// 内容表面上的按住拖动永远归「操作这个内容」，进度控制从来不在内容表面上。
///
/// 所以这里的取舍是明写的：**环视激活时，画面区不再提供快进／亮度／音量／缩放**
/// （进度条、音量键、快捷键一律照常，功能没有消失，只是不在这块区域上）。切回
/// 平面模式立刻恢复原样。长按倍速同理让位。
class VrPanoramaGestureArea extends StatefulWidget {
  const VrPanoramaGestureArea({
    super.key,
    required this.controller,
    required this.onTap,
    required this.onDoubleTap,
  });

  final MyVideoStateController controller;

  /// 单击：沿用常规模式的「显示／隐藏工具栏」。
  final VoidCallback onTap;

  /// 双击：播放／暂停。中央区双击本来就是这个含义，环视里保持一致。
  final VoidCallback onDoubleTap;

  @override
  State<VrPanoramaGestureArea> createState() => _VrPanoramaGestureAreaState();
}

class _VrPanoramaGestureAreaState extends State<VrPanoramaGestureArea> {
  /// 上一次回调里的累计缩放。`ScaleUpdateDetails.scale` 是相对手势起点的累计值，
  /// 直接拿去除会让视野角每帧被重复缩放一次，越拖越飞。
  double _lastScale = 1;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastScale = 1;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    final controller = widget.controller;

    if (details.pointerCount >= 2 && details.scale > 0) {
      controller.scaleVrFov(details.scale / _lastScale);
      _lastScale = details.scale;
    }

    final delta = details.focalPointDelta;
    if (delta == Offset.zero || size.width <= 0 || size.height <= 0) return;

    // 灵敏度标定：横拖过整个播放区正好转过一个水平视野，竖拖过整个高度正好转过
    // 一个竖直视野。手指走的距离和画面转过的角度对得上，这就是「跟手」。
    // 视野收窄（放大）时同样的位移转过的角度更小，细看时更好对准。
    final fovY = controller.vrFovY.value;
    final fovX = VrGeometry.horizontalFov(fovY, size.width / size.height);
    controller.nudgeVrView(
      // 向右拖＝把画面往右推＝看向更左边，所以偏航取负。
      deltaYaw: -delta.dx / size.width * fovX,
      // 向下拖＝把画面往下拉＝露出上方的内容＝抬头，俯仰取正。
      deltaPitch: delta.dy / size.height * fovY,
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    // 桌面端滚轮：上滚放大（视野收窄），下滚缩小。每格 1.1 倍，与常见看图软件一致。
    widget.controller.scaleVrFov(event.scrollDelta.dy > 0 ? 1 / 1.1 : 1.1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerSignal: _handlePointerSignal,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onDoubleTap: widget.onDoubleTap,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: (details) => _handleScaleUpdate(details, size),
            // 桌面端把光标换成「可抓」，否则没人知道这块画面是能拖的。
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}
