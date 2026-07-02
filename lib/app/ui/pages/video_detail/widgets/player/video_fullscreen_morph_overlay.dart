import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/my_video_screen.dart';

/// 应用内伪横屏的 MediaQuery 适配：把窗口的 MediaQueryData 按 [quarterTurns]
/// 旋转后提供给子树，使全屏播放器以为自己处于横屏窗口——尺寸互换（orientation
/// 随之变为 landscape）、安全区各内边距重映射到旋转后的正确边上。
///
/// 与 RotatedBox 配套使用：RotatedBox 负责布局/绘制/命中测试的旋转，本组件负责
/// 让子树里所有 MediaQuery 消费者（SafeArea、paddingOf 等）读到旋转后的值。
class FakeRotatedMediaQuery extends StatelessWidget {
  final int quarterTurns;

  /// 强制（旋转后坐标系的）顶部 inset 为 0：全屏播放器从第一帧起就按
  /// 「状态栏已隐藏」的最终布局渲染，等状态栏真正消失时只是浮层淡出，
  /// 播放器不会再发生二次重排（否则收尾帧会「弹一下」——进入形变期间
  /// 状态栏刻意保持可见，其 padding 若被播放器消费，隐藏瞬间必然重排）。
  /// 仅剥离顶部；侧边/底部安全区（旋转帧下的刘海、Home 指示条）保持不动。
  final bool stripTopInset;
  final Widget child;

  const FakeRotatedMediaQuery({
    super.key,
    required this.quarterTurns,
    this.stripTopInset = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final int q = quarterTurns % 4;
    if (q == 0 && !stripTopInset) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: rotateMediaQueryData(mq, q, stripTopInset: stripTopInset),
      child: child,
    );
  }

  static MediaQueryData rotateMediaQueryData(
    MediaQueryData mq,
    int q, {
    bool stripTopInset = false,
  }) {
    final Size size = q.isOdd ? Size(mq.size.height, mq.size.width) : mq.size;

    // RotatedBox(quarterTurns: 1) 将子树顺时针旋转 90°：子树 left 边落在窗口
    // top、top 边落在窗口 right、right 边落在窗口 bottom、bottom 边落在窗口 left。
    // quarterTurns: 3（逆时针 90°）为其镜像。据此把窗口安全区映射到子树坐标系。
    EdgeInsets rotate(EdgeInsets e) {
      switch (q) {
        case 1:
          return EdgeInsets.fromLTRB(e.top, e.right, e.bottom, e.left);
        case 2:
          return EdgeInsets.fromLTRB(e.right, e.bottom, e.left, e.top);
        case 3:
          return EdgeInsets.fromLTRB(e.bottom, e.left, e.top, e.right);
        default:
          return e;
      }
    }

    EdgeInsets finish(EdgeInsets e) => stripTopInset ? e.copyWith(top: 0) : e;

    return mq.copyWith(
      size: size,
      padding: finish(rotate(mq.padding)),
      viewPadding: finish(rotate(mq.viewPadding)),
      viewInsets: rotate(mq.viewInsets),
      systemGestureInsets: rotate(mq.systemGestureInsets),
      // 刘海等 display features 坐标无法随伪旋转变换，清空以免子树按错误位置避让。
      displayFeatures: const <ui.DisplayFeature>[],
    );
  }
}

/// 视频全屏 Hero 形变层（仅移动端使用），挂载在根 Overlay 上，覆盖整个窗口
/// （包括宽屏布局下的侧边导航栏）。
///
/// 职责：在 [MyVideoStateController.fullscreenMorphPhase] 进入 expanding /
/// collapsing 时，通过同一个 GlobalKey 接管共享播放器实例，把它从内联槽位矩形
/// 几何形变（平移 + 缩放 + 必要时旋转 90°）到铺满窗口，或反向收回。静止全屏态
/// 与非全屏态本层渲染空占位，播放器分别寄宿在详情页的全屏宿主 / 内联槽位中。
///
/// 关键时序（防闪烁的核心，勿轻易调整）：
/// - 进入：形变期间不隐藏系统 UI / 侧边栏，底层布局零变化；动画完成回调里才
///   hideSystemUI，并与「形变层退场 + 页面内全屏宿主进场」发生在同一帧。
/// - 退出：exitFullscreen 已在收缩开始前恢复系统 UI，状态栏/侧边栏引发的底层
///   重排在本层全窗口遮盖下完成；收缩动画每帧实时读取内联槽位矩形作为落点
///   （moving target），保证布局怎么变都能精确落位。
class VideoFullscreenMorphLayer extends StatefulWidget {
  final MyVideoStateController controller;
  final InnerPlaylistContext? Function() innerPlaylistContextResolver;

  const VideoFullscreenMorphLayer({
    super.key,
    required this.controller,
    required this.innerPlaylistContextResolver,
  });

  @override
  State<VideoFullscreenMorphLayer> createState() =>
      _VideoFullscreenMorphLayerState();
}

class _VideoFullscreenMorphLayerState extends State<VideoFullscreenMorphLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeInOutCubic,
  );
  Worker? _phaseWorker;

  /// 本次形变的旋转方向快照，动画过程中保持稳定。
  int _turns = 0;

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener(_onAnimStatus);
    _phaseWorker = ever(widget.controller.fullscreenMorphPhase, (
      FullscreenMorphPhase phase,
    ) {
      if (!mounted) return;
      setState(() => _syncToPhase(phase));
    });
    // 形变层是懒插入的：若插入时形变已在进行（例如首帧前就触发了全屏），补跑同步。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final phase = widget.controller.fullscreenMorphPhase.value;
      if (phase != FullscreenMorphPhase.none) {
        setState(() => _syncToPhase(phase));
      }
    });
  }

  @override
  void dispose() {
    _phaseWorker?.dispose();
    _curved.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _syncToPhase(FullscreenMorphPhase phase) {
    switch (phase) {
      case FullscreenMorphPhase.none:
        _anim.stop();
        break;
      case FullscreenMorphPhase.expanding:
        // 中断收缩再进入时保留原方向快照，避免动画中途跳变。
        if (!_anim.isAnimating && _anim.value == 0.0) {
          _turns = widget.controller.resolveActiveFullscreenQuarterTurns(
            context,
          );
        }
        _anim.forward();
        break;
      case FullscreenMorphPhase.collapsing:
        if (!_anim.isAnimating) {
          // 从静止全屏态（含未经形变的接力全屏）直接收起：动画值置满，
          // 并重新解析方向快照，与静止态宿主当前渲染保持一致
          // （全屏期间用户可能改过方向配置 / 宽高比迟到修正过）。
          if (_anim.value == 0.0) {
            _anim.value = 1.0;
          }
          if (_anim.value == 1.0) {
            _turns = widget.controller.resolveActiveFullscreenQuarterTurns(
              context,
            );
          }
        }
        _anim.reverse();
        break;
    }
  }

  void _onAnimStatus(AnimationStatus status) {
    final controller = widget.controller;
    if (status == AnimationStatus.completed &&
        controller.fullscreenMorphPhase.value ==
            FullscreenMorphPhase.expanding) {
      controller.onFullscreenMorphExpandCompleted();
    } else if (status == AnimationStatus.dismissed &&
        controller.fullscreenMorphPhase.value ==
            FullscreenMorphPhase.collapsing) {
      controller.onFullscreenMorphCollapseCompleted();
    }
  }

  /// aspect 比例的矩形在 outer 内 contain 居中后的区域（与播放器 BoxFit.contain 一致）。
  static Rect _containRect(Rect outer, double aspect) {
    if (outer.width <= 0 || outer.height <= 0 || aspect <= 0) return outer;
    final outerAspect = outer.width / outer.height;
    if (outerAspect > aspect) {
      final width = outer.height * aspect;
      return Rect.fromCenter(
        center: outer.center,
        width: width,
        height: outer.height,
      );
    }
    final height = outer.width / aspect;
    return Rect.fromCenter(
      center: outer.center,
      width: outer.width,
      height: height,
    );
  }

  /// 全屏布局盒内一点在「静止全屏态」（RotatedBox 居中旋转铺满窗口）下的屏幕位置。
  static Offset _restMapToScreen(
    Offset point,
    Size boxSize,
    Size winSize,
    int turns,
  ) {
    final Offset boxCenter = Offset(boxSize.width / 2, boxSize.height / 2);
    final Offset winCenter = Offset(winSize.width / 2, winSize.height / 2);
    final Offset d = point - boxCenter;
    final Offset rotated = switch (turns % 4) {
      1 => Offset(-d.dy, d.dx), // 顺时针 90°
      2 => Offset(-d.dx, -d.dy),
      3 => Offset(d.dy, -d.dx), // 逆时针 90°
      _ => d,
    };
    return winCenter + rotated;
  }

  /// 把全局坐标矩形换算到本层坐标系（正常情况下两者一致，做兜底换算保证正确）。
  Rect _toLocal(Rect globalRect) {
    final ro = context.findRenderObject();
    if (ro is RenderBox && ro.attached) {
      final origin = ro.localToGlobal(Offset.zero);
      return globalRect.shift(-origin);
    }
    return globalRect;
  }

  Rect _fallbackSlotRect(Rect winRect, double aspect) {
    final width = winRect.width;
    final height = aspect > 0
        ? (width / aspect).clamp(1.0, winRect.height)
        : winRect.height / 3;
    return Rect.fromLTWH(winRect.left, winRect.top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    // Obx 只订阅形变阶段；动画每帧重建由 AnimatedBuilder 驱动。
    return Obx(() {
      final phase = widget.controller.fullscreenMorphPhase.value;
      if (phase == FullscreenMorphPhase.none) {
        return const SizedBox.shrink();
      }
      return AnimatedBuilder(
        animation: _curved,
        builder: (context, _) => _buildMorph(context),
      );
    });
  }

  Widget _buildMorph(BuildContext context) {
    final controller = widget.controller;
    final mq = MediaQuery.of(context);
    final Size winSize = mq.size;
    final Rect winRect = Offset.zero & winSize;
    final int turns = _turns;
    final Size boxSize = turns.isOdd
        ? Size(winSize.height, winSize.width)
        : winSize;
    final double t = _curved.value.clamp(0.0, 1.0);

    final double rawAspect = controller.aspectRatio.value;
    final double aspect = (rawAspect.isFinite && rawAspect > 0)
        ? rawAspect
        : 16 / 9;

    // 内联端：每帧实时测量槽位矩形。退出全屏时侧边栏/状态栏恢复引发的布局变化
    // 会即时体现在这里，动画自然收敛到最终落点。
    final Rect slotRect = _toLocal(
      controller.measureInlinePlayerSlotRect() ??
          _fallbackSlotRect(winRect, aspect),
    );
    // 内联播放器内容区在其槽位内部避开了状态栏（MyVideoScreen 内的 top padding），
    // 对齐必须以实际视频矩形为准，否则落点会差一个状态栏高度。
    final double slotPadTop = math.min(
      mq.padding.top,
      math.max(0.0, slotRect.height - 1),
    );
    final Rect startInner = Rect.fromLTRB(
      slotRect.left,
      slotRect.top + slotPadTop,
      slotRect.right,
      slotRect.bottom,
    );
    final Rect startVideo = _containRect(startInner, aspect);

    // 全屏端一律按「状态栏已隐藏」的最终布局渲染（stripTopInset 剥离顶部 inset，
    // 视频在整个布局盒内 contain 居中）：收尾帧即最终布局，状态栏随后消失时只是
    // 浮层淡出，播放器不会再发生二次重排（“弹一下”）。
    final Rect endVideoLocal = _containRect(Offset.zero & boxSize, aspect);

    final double angleEnd = turns == 1
        ? math.pi / 2
        : (turns == 3 ? -math.pi / 2 : 0.0);
    final double angle = angleEnd * t;
    // 分子分母双保护：槽位矩形退化（如布局切换瞬间高度为 0）时避免 scale 归零
    // 造成整段动画从 0 突然弹出。
    final double startScale =
        (endVideoLocal.width <= 0 || startVideo.width <= 0)
        ? 1.0
        : (startVideo.width / endVideoLocal.width).clamp(0.01, 10.0);
    final double scale = ui.lerpDouble(startScale, 1.0, t) ?? 1.0;
    // 终点中心 = 全屏布局盒内视频中心经「静止态旋转映射」后的屏幕位置。这样
    // t=1 时整个矩阵严格等于 RotatedBox 的静止渲染（逐像素一致），与页面内
    // 全屏宿主的同帧交接不会有任何跳动。
    final Offset endCenterScreen = _restMapToScreen(
      endVideoLocal.center,
      boxSize,
      winSize,
      turns,
    );
    final Offset center =
        Offset.lerp(startVideo.center, endCenterScreen, t) ?? endCenterScreen;

    // 以「视频矩形中心」为锚点插值：平移到目标中心 → 旋转 → 缩放 → 把全屏布局盒
    // 内的视频中心移到原点。两端点分别与内联视频矩形、静止全屏渲染精确重合。
    final Matrix4 matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..rotateZ(angle)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(
        -endVideoLocal.center.dx,
        -endVideoLocal.center.dy,
        0,
        1,
      );

    return AbsorbPointer(
      child: Stack(
        children: [
          // 渐显黑幕：遮住旋转过程中形变矩形四角露出的底层页面。
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: t)),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: boxSize.width,
            height: boxSize.height,
            child: Transform(
              transform: matrix,
              filterQuality: FilterQuality.low,
              child: FakeRotatedMediaQuery(
                quarterTurns: turns,
                stripTopInset: true,
                child: MyVideoScreen(
                  key: controller.playerViewKey,
                  isFullScreen: true,
                  myVideoStateController: controller,
                  innerPlaylistContext: widget.innerPlaylistContextResolver(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
