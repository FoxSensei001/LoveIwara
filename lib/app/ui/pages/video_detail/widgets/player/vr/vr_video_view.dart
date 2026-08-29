import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/vr/vr_panorama_shader.dart';
import 'package:i_iwara/app/ui/widgets/color_vision_filter_wrapper.dart';
import 'package:i_iwara/app/utils/vr_geometry.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// VR / 立体片源的画面呈现层（后端①，全平台零包体）。
///
/// 只在 [MyVideoStateController.needsVrPresentation] 为真时顶掉常规画面路径，
/// 平面单目视频完全走不到这里，渲染开销为零。
///
/// 两级能力，按片源与设备递进：
///
///   **①-a 单眼裁切**（保底，一定能用）——立体片是把左右两眼压进同一帧的，
///   直接放就是「两个挤扁的画面」。这里只取一只眼并**把宽高比拉回来**，得到一幅
///   正常的画面。只裁不拉等于白裁，还原比例是必须的一步。
///
///   **①-b 平面环视**（[_VrPanoramaVideo]）——球面片源额外走等距→透视的实时
///   重映射，拖动即转头。着色器跑不动时自动落回 ①-a。
class VrVideoView extends StatelessWidget {
  const VrVideoView({super.key, required this.controller});

  final MyVideoStateController controller;

  @override
  Widget build(BuildContext context) {
    // 自带 Obx：本 widget 是从 _buildFittedVideo 里 return 出去的，它的 build
    // 不在外层那只 Obx 的闭包内跑，格式/宽高比/尺寸档的读取登记不到那边去。
    return Obx(() {
      final format = controller.vrFormat;
      if (format.projection == VrProjection.flat) {
        return _VrCroppedVideo(
          controller: controller,
          layout: format.stereoLayout,
        );
      }
      return _VrPanoramaVideo(controller: controller, format: format);
    });
  }
}

/// 单眼裁切：取半幅 + 还原宽高比，再按「画面尺寸」档塞进播放区。
class _VrCroppedVideo extends StatelessWidget {
  const _VrCroppedVideo({required this.controller, required this.layout});

  final MyVideoStateController controller;
  final VrStereoLayout layout;

  @override
  Widget build(BuildContext context) {
    // 自带 Obx：本 widget 的 build 不在 VrVideoView 那只 Obx 的闭包里跑，
    // 「画面尺寸」和宽高比的读取登记不到那边去——少了它，切档或起播后宽高比
    // 更新时这层不会重建。
    return Obx(() => _build(context));
  }

  Widget _build(BuildContext context) {
    final fitMode = controller.screenFitMode.value;
    final eyeAspect = VrGeometry.eyeAspectRatio(
      controller.aspectRatio.value,
      layout,
    );
    final eye = buildEyeContent(controller, layout);

    switch (fitMode) {
      case PlayerScreenFitMode.fit:
        return AspectRatio(aspectRatio: eyeAspect, child: eye);
      case PlayerScreenFitMode.stretch:
        return SizedBox.expand(child: eye);
      case PlayerScreenFitMode.cover:
        // 单眼画面自己没有内在尺寸（它填满给它的任何盒子），FittedBox 需要一个
        // 有确定比例的孩子才能算出 cover 的缩放，这里用一个纯比例占位盒给它。
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(width: eyeAspect * 1000, height: 1000, child: eye),
          ),
        );
      case PlayerScreenFitMode.ratio16x9:
        return AspectRatio(aspectRatio: 16 / 9, child: eye);
      case PlayerScreenFitMode.ratio4x3:
        return AspectRatio(aspectRatio: 4 / 3, child: eye);
    }
  }
}

/// 取单眼那一幅并填满给定的盒子。
///
/// [FractionallySizedBox] 把**整帧**撑到盒子的 1/取景比例 那么大（左右并排是两
/// 倍宽、上下堆叠是两倍高），再靠 `topLeft` 对齐让左眼／上半幅落在盒子里，外面
/// 一层 [ClipRect] 切掉另一只眼。
///
/// 这样做而不是「缩放两倍再平移」有两个好处：不用手算平移量（那是最容易错的
/// 一步）；以及被切掉的那半幅仍然按真实分辨率渲染，可见的这只眼因此拿得到满
/// 分辨率，而不是先降采样再放大。
Widget buildEyeContent(
  MyVideoStateController controller,
  VrStereoLayout layout,
) {
  final rect = VrGeometry.eyeRect(layout);
  final frame = ColorVisionFilterWrapper(
    child: Video(
      controller: controller.videoController,
      controls: null,
      fit: BoxFit.fill,
    ),
  );
  if (layout == VrStereoLayout.mono) {
    return frame;
  }
  return ClipRect(
    child: FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: 1 / rect.width,
      heightFactor: 1 / rect.height,
      child: frame,
    ),
  );
}

/// 平面环视：等距柱状 → 透视投影的实时重映射。
class _VrPanoramaVideo extends StatefulWidget {
  const _VrPanoramaVideo({required this.controller, required this.format});

  final MyVideoStateController controller;
  final VrSourceFormat format;

  @override
  State<_VrPanoramaVideo> createState() => _VrPanoramaVideoState();
}

class _VrPanoramaVideoState extends State<_VrPanoramaVideo> {
  /// 两只 shader 轮流用，**不是**为了并发，是为了保证重绘。
  ///
  /// `ImageFiltered` 只在新旧 filter `!=` 时才 markNeedsPaint，而
  /// `_FragmentShaderImageFilter` 的判等第一条就是「是不是同一只 shader 实例」。
  /// 一直复用同一只的话，暂停状态下拖动视角有可能一帧都不重画（播放中侥幸能动，
  /// 是因为视频纹理自己每帧在刷）。轮换实例让两次 filter 必定不等。
  ///
  /// 顺带解决另一个隐患：上一帧的 filter 可能还在合成里被用着，此时去改它引用的
  /// uniform 是在动别人手上的东西；轮换保证我们改的永远是空闲的那只。
  final List<ui.FragmentShader> _shaders = <ui.FragmentShader>[];
  int _shaderIndex = 0;
  bool _loadAttempted = false;

  @override
  void initState() {
    super.initState();
    // 已经加载过就同步取用：等一个已完成的 Future 也要等到下一个微任务，那一帧
    // 会先闪一下单眼裁切再切成环视。第一次进 VR 视频闪一下无所谓，之后每一次都
    // 闪就是明显的毛病了。
    final cached = VrPanoramaShader.programOrNull;
    if (cached != null) {
      _loadAttempted = true;
      _shaders
        ..add(cached.fragmentShader())
        ..add(cached.fragmentShader());
      return;
    }
    _ensureShaders();
  }

  Future<void> _ensureShaders() async {
    if (_loadAttempted || !VrPanoramaShader.isSupported) return;
    _loadAttempted = true;
    final program = await VrPanoramaShader.load();
    if (!mounted || program == null) return;
    setState(() {
      _shaders
        ..add(program.fragmentShader())
        ..add(program.fragmentShader());
    });
  }

  @override
  void dispose() {
    for (final shader in _shaders) {
      shader.dispose();
    }
    _shaders.clear();
    super.dispose();
  }

  ui.FragmentShader _takeShader() {
    _shaderIndex = (_shaderIndex + 1) % _shaders.length;
    return _shaders[_shaderIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (_shaders.isEmpty) {
      // 三种情况共用这条降级：本机没有 Impeller（`ImageFilter.shader` 会直接抛
      // UnsupportedError）、着色器加载失败、以及加载还没回来的头几帧。
      // 全部退回单眼裁切——等距图被摊平、边缘会畸变，但画面完整、一定能看，
      // 比留一块黑或者干脆崩掉强得多。
      return _VrCroppedVideo(
        controller: widget.controller,
        layout: widget.format.stereoLayout,
      );
    }

    return SizedBox.expand(
      child: ClipRect(
        child: Obx(() {
          final controller = widget.controller;
          final rect = VrGeometry.eyeRect(widget.format.stereoLayout);
          final span = VrGeometry.angularSpan(widget.format.projection);
          final shader = _takeShader();

          // 浮点下标必须与 .frag 里的 uniform 声明顺序严格对齐。
          // 0/1 是 uSize，由引擎写成输入贴图尺寸，这里**不能**碰。
          shader
            ..setFloat(2, rect.left)
            ..setFloat(3, rect.top)
            ..setFloat(4, rect.width)
            ..setFloat(5, rect.height)
            ..setFloat(6, controller.vrYaw.value)
            ..setFloat(7, controller.vrPitch.value)
            ..setFloat(8, controller.vrFovY.value)
            ..setFloat(9, span.horizontal)
            ..setFloat(10, span.vertical);

          return ImageFiltered(
            imageFilter: ui.ImageFilter.shader(shader),
            // BoxFit.fill：整帧铺满这只盒子，于是「整帧」正好占满输入贴图的
            // [0,1]²，着色器可以直接按归一化坐标寻址。拉伸带来的形变无所谓——
            // 重映射本来就是按角度取样，不看贴图本身的比例。
            child: ColorVisionFilterWrapper(
              child: Video(
                controller: controller.videoController,
                controls: null,
                fit: BoxFit.fill,
              ),
            ),
          );
        }),
      ),
    );
  }
}
