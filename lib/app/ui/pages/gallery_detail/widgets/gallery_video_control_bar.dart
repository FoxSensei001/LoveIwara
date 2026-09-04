import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_corner_chips.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_chrome_theme.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_controller.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/player/seek_preview.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 图库大图页里那条视频的控件条：播放/暂停、进度、时长、静音。
///
/// # 为什么它挂在大图页而不是画面里
///
/// 画面那一层被 `PhotoViewGallery` 的缩放变换裹着。控件放进去会跟着画面一起
/// 放大、跟着平移一起跑出屏幕——和顶栏一样，chrome 必须待在变换**外面**。
///
/// # 为什么整条只有一块玻璃
///
/// 每块独立玻璃都要为自己整屏采样一次背景（见 `GlassChromeLayer` 的性能记录），
/// 而这条 chrome 浮在**正在播放的视频**上，每帧背景都在变，收成一块之后采样只有
/// 一次。这同时也是 [GlassSurface.materialize] 还能用的前提——融合组里同一层只有
/// 一份材质，淡入会被静默吃掉（debug 下有 assert 盯着），所以外面那只
/// `GlassChromeLayer` 必须传 `group: false`。
///
/// # ⛔ 三条容易踩空的约束
///
///   1. **玻璃必须拿到确定宽度**。[GlassSurface] 的 `width` 为 null 时按内容收缩，
///      里头的 `Expanded`（进度条）会拿到无界约束当场抛异常。所以外面套
///      `LayoutBuilder`，把可用宽度显式交给它。
///   2. **Seek Preview 不能待在玻璃里头**。两个液态档都由 shader 按形状裁 child，
///      浮到条**上方**的预览窗口会被整只裁掉。所以它挂在玻璃外面那只 `Stack` 上，
///      锚点由进度条把全局坐标报上来、这里换算成 Stack 内坐标。
///   3. **内容的淡入走颜色通道**。条里的图标与文字都是写死的白，[GlassSurface]
///      的 `dimContent` 管不到（它只压 IconTheme 与 DefaultTextStyle）。不压的话
///      淡入时读起来就是「文字先出现、玻璃后到」。这里把 [materialize] 乘进颜色
///      的 alpha 里——**不是**在外面包 `Opacity`，那会 saveLayer 把折射打断。
///
/// # 为什么强行按深色主题渲染
///
/// 这条 chrome 恒定浮在黑底的媒体查看器上，内容一律是白的（顶栏那几枚钮从来
/// 就是 `Colors.white`）。而 [GlassSurface] 在 `material` / `plain` 两档下是拿
/// **主题**的表面色填的——浅色主题下会填出一块近白的底，白图标当场消失。把子树
/// 的 colorScheme 换成深色，四个材质档就都是「深底白字」。
class GalleryVideoControlBar extends StatefulWidget {
  const GalleryVideoControlBar({
    super.key,
    required this.controller,
    required this.onInteraction,
    required this.scale,
    required this.onResetScale,
    required this.chromeVisible,
    this.materialize = 1.0,
    this.canRotate = false,
    this.landscape = false,
    this.onToggleRotation,
  });

  final GalleryVideoController controller;

  /// 这一页当前被放大到多少倍（1.0 = 原始）。
  final double scale;

  /// 把缩放复位。
  final VoidCallback onResetScale;

  /// 整套 chrome 此刻在不在场。
  ///
  /// 整条其实是被外层整块滑出屏幕的，本可以不用管；但缩放钮浮在条**上方**、
  /// 用户明确要求"收缩时真实地隐藏"，所以让它据此整只不建，而不是靠"滑出视野"
  /// 蒙混过去。
  final bool chromeVisible;

  /// 用户在这条上动了一下。大图页据此把「自动隐藏」的计时器推后，
  /// 免得正拖着进度条 chrome 自己收起来。
  final VoidCallback onInteraction;

  /// 材质的「在场程度」，由外层 [GlassReveal] 供给。
  final double materialize;

  /// 这台设备值不值得那枚旋转钮。
  ///
  /// 只有被 App 强制锁竖屏的手机需要它（平板/桌面/XR 本来就能自由横过来），
  /// 判定在大图页那边做，见 `_MyGalleryPhotoViewWrapperState`。
  final bool canRotate;

  /// 此刻是不是已经靠那枚钮把系统屏幕转成了横屏。决定这枚键是「转过去」
  /// 还是「回到竖屏」。
  final bool landscape;

  /// 按下那枚钮。
  final VoidCallback? onToggleRotation;

  @override
  State<GalleryVideoControlBar> createState() => _GalleryVideoControlBarState();
}

class _GalleryVideoControlBarState extends State<GalleryVideoControlBar> {
  static const double _barHeight = 56;

  final GlobalKey _stackKey = GlobalKey();

  bool _previewVisible = false;
  double _previewAnchorX = 0;
  double _previewTrackWidth = 0;
  Duration _previewTime = Duration.zero;

  /// 进度条把「锚点在全局哪儿」报上来，这里换算成外层 Stack 的坐标。
  /// 直接用进度条的局部坐标不行——它左边还隔着播放钮和时间戳，宽度随文案而变。
  void _onScrub({
    required bool visible,
    Offset? globalAnchor,
    double? trackWidth,
    Duration? time,
    bool keepAnchor = false,
  }) {
    if (keepAnchor) {
      // 只改显隐：退场那 200ms 里窗口该停在原地淡出，不是先瞬移到最左再淡出。
      if (_previewVisible == visible) return;
      setState(() => _previewVisible = visible);
      return;
    }
    final renderObject = _stackKey.currentContext?.findRenderObject();
    double anchorX = _previewAnchorX;
    if (renderObject is RenderBox &&
        renderObject.hasSize &&
        globalAnchor != null) {
      anchorX = renderObject.globalToLocal(globalAnchor).dx;
    }
    setState(() {
      _previewVisible = visible;
      _previewAnchorX = anchorX;
      _previewTrackWidth = trackWidth ?? _previewTrackWidth;
      _previewTime = time ?? _previewTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GalleryDarkChrome(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) => _buildBar(context),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    final t = slang.Translations.of(context);
    final controller = widget.controller;
    final double m = widget.materialize.clamp(0.0, 1.0);
    final bool enabled = controller.ready;
    final Color foreground = Colors.white.withValues(alpha: m);

    // ⛔ 缩放钮必须待在**真正参与布局**的一行里，不能像 Seek Preview 那样用
    // `Positioned` 溢出到条的上方——溢出到 `Stack` 边界之外的部分**收不到点击**
    // （父级的 hitTest 先做 `size.contains` 就已经失败了）。第一版正是这样，点
    // 在钮上其实点到了底下的画面，于是"点一下切 chrome"生效、复位反倒没生效
    // （用户 2026-09-04 报的）。Seek Preview 不受影响，它本来就不接受输入。
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 8),
            child: GalleryScaleChip(
              scale: widget.scale,
              visible: widget.chromeVisible && !_previewVisible,
              onReset: widget.onResetScale,
            ),
          ),
        ),
        Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => GlassChromeLayer(
                // 整条就是一块玻璃，成组没有对象可融，反而会把 materialize 关掉。
                group: false,
                child: GlassSurface(
                  height: _barHeight,
                  // ⛔ 必须显式给宽：不给的话玻璃按内容收缩，里头的 Expanded 会拿到
                  // 无界约束。
                  width: constraints.maxWidth,
                  borderRadius: BorderRadius.circular(_barHeight / 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  materialize: m,
                  // 跟手形变会和进度条的横向拖动抢同一根手指。
                  liquidTouch: false,
                  child: Row(
                    children: [
                      _BarIconButton(
                        icon: controller.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        tooltip: controller.playing
                            ? t.videoDetail.pause
                            : t.videoDetail.play,
                        foreground: foreground,
                        onPressed: enabled
                            ? () {
                                widget.onInteraction();
                                controller.togglePlayPause();
                              }
                            : null,
                      ),
                      const SizedBox(width: 2),
                      // 拖动中这里显示的就是落点时间，所以不再需要预览窗口也能读到
                      // 「要跳到哪」——预览窗口是锦上添花的那一份。
                      _TimeLabel(
                        duration: controller.displayPosition,
                        foreground: foreground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _GalleryVideoProgressBar(
                          controller: controller,
                          foreground: foreground,
                          onInteraction: widget.onInteraction,
                          onScrub: _onScrub,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TimeLabel(
                        duration: controller.duration,
                        foreground: foreground,
                      ),
                      const SizedBox(width: 2),
                      _BarIconButton(
                        icon: controller.muted
                            ? Icons.volume_off
                            : Icons.volume_up,
                        tooltip: controller.muted
                            ? t.mediaPlayer.unmute
                            : t.mediaPlayer.mute,
                        foreground: foreground,
                        onPressed: enabled
                            ? () {
                                widget.onInteraction();
                                controller.toggleMute();
                              }
                            : null,
                      ),
                      // 旋转钮。手机被 App 强制锁在竖屏（见
                      // `DeviceFormFactorUtils.applyMobileOrientationPolicy`），
                      // 图库里那条横视频于是只能缩在屏幕中间一条——这枚键把系统
                      // 屏幕真的转过去，再按一下（图标已经换成「回到竖屏」）转回来。
                      //
                      // ⛔ 它**不看** `enabled`：转屏与这条视频缓冲到没到没有关系，
                      // 加载中也该能先把设备横过来等。
                      GlassGroupSlot(
                        visible: widget.canRotate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 2),
                            _BarIconButton(
                              icon: widget.landscape
                                  ? Icons.screen_lock_portrait
                                  : Icons.screen_rotation,
                              tooltip: widget.landscape
                                  ? t.galleryDetail.backToPortrait
                                  : t.galleryDetail.rotateToLandscape,
                              foreground: foreground,
                              onPressed: () {
                                widget.onInteraction();
                                widget.onToggleRotation?.call();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 拖动中浮出的时间戳窗口，用的是播放器那只 [SeekPreview]（纯组件，几何、
            // 边界钳制、出入场过渡都在里头）。不带画面：图库不为一条穿插的短视频再起
            // 第二份 libmpv 实例，[SeekPreview] 自己会在没有画面时收成只有时间戳那么宽。
            Positioned(
              left: _previewAnchorX,
              bottom: _barHeight + 6,
              child: SeekPreview(
                time: _previewTime,
                videoAspectRatio: controller.aspectRatio,
                anchorX: _previewAnchorX,
                trackWidth: _previewTrackWidth,
                visible: _previewVisible,
                showFrame: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 条内的一枚键。
///
/// 这里刻意**不**用 [GlassIconButton]：整条已经是一块玻璃了，条里每枚键再各自
/// 长一层玻璃就是「玻璃套玻璃」，既多几次背景采样，视觉上也变成一排小胶囊挤在
/// 大胶囊里。条内的键是**内容**，与顶栏那几枚 `IconButton` 同族。
///
/// 图标换脸走 [GlassAnimatedIcon]（旧的缩小淡出、新的放大淡入）。收在这一层而
/// 不是各调用点各写一遍：条里三枚键（播放/暂停、静音、横竖屏）全都是「同一个
/// 位置换个图标」，本项目对这类切换的统一要求见 `GlassAnimatedIcon` 的文档。
class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.tooltip,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: GlassAnimatedIcon(icon: Icon(icon)),
      iconSize: 22,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      color: foreground,
      disabledColor: foreground.withValues(alpha: foreground.a * 0.38),
      onPressed: onPressed,
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.duration, required this.foreground});

  final Duration duration;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Text(
      CommonUtils.formatDuration(duration),
      style: TextStyle(
        color: foreground,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        // 数字等宽：不然秒数从 1 跳到 8 整条时间戳的宽度就变一次，
        // 进度条跟着左右抽动。
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

/// 进度条。
///
/// 自绘而不是复用播放器那条 `CustomVideoProgressbar`：那一只的构造函数直接吃
/// `MyVideoStateController`，搬过来等于把整套重状态一起搬过来。
class _GalleryVideoProgressBar extends StatefulWidget {
  const _GalleryVideoProgressBar({
    required this.controller,
    required this.foreground,
    required this.onInteraction,
    required this.onScrub,
  });

  final GalleryVideoController controller;
  final Color foreground;
  final VoidCallback onInteraction;

  /// 报一次预览窗口的状态。[keepAnchor] 为真时只改显隐，锚点与时间原样留着
  /// （松手退场用，理由见 [_GalleryVideoProgressBarState._report]）。
  final void Function({
    required bool visible,
    Offset? globalAnchor,
    double? trackWidth,
    Duration? time,
    bool keepAnchor,
  })
  onScrub;

  @override
  State<_GalleryVideoProgressBar> createState() =>
      _GalleryVideoProgressBarState();
}

class _GalleryVideoProgressBarState extends State<_GalleryVideoProgressBar> {
  final GlobalKey _trackKey = GlobalKey();
  bool _scrubbing = false;

  double _trackWidth() {
    final renderObject = _trackKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.width;
    }
    return 0;
  }

  Duration _durationAt(double dx, double width) {
    final total = widget.controller.duration;
    if (total <= Duration.zero || width <= 0) return Duration.zero;
    final ratio = (dx / width).clamp(0.0, 1.0);
    return Duration(milliseconds: (total.inMilliseconds * ratio).round());
  }

  /// 把预览窗口的落点报上去。
  ///
  /// [dx] 为 null 表示「位置不变，只改显隐」——松手那一下必须走这一支：
  /// ⛔ 传 0 的话会在 [SeekPreview] **正演退场**的当口把锚点改写成轨道最左、
  /// 时间改写成 00:00，读起来是预览窗口一边淡出一边瞬移到最左边显示 00:00。
  void _report({required bool visible, double? dx}) {
    if (dx == null) {
      // ⛔ 这一支要排在量尺寸**之前**：轨道此刻可能已经不在树上了（chrome 正在
      // 收起），量不到就 return 的话预览窗口会永远挂着。
      widget.onScrub(visible: visible, keepAnchor: true);
      return;
    }
    final renderObject = _trackKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final width = renderObject.size.width;
    final clamped = dx.clamp(0.0, width);
    widget.onScrub(
      visible: visible,
      globalAnchor: renderObject.localToGlobal(Offset(clamped, 0)),
      trackWidth: width,
      time: _durationAt(clamped, width),
    );
  }

  bool get _enabled =>
      widget.controller.ready && widget.controller.duration > Duration.zero;

  void _beginScrub(double dx) {
    if (!_enabled) return;
    widget.onInteraction();
    setState(() => _scrubbing = true);
    widget.controller.beginScrub(_durationAt(dx, _trackWidth()));
    _report(visible: true, dx: dx);
  }

  void _updateScrub(double dx) {
    if (!_scrubbing) return;
    widget.controller.updateScrub(_durationAt(dx, _trackWidth()));
    _report(visible: true, dx: dx);
  }

  void _endScrub() {
    if (!_scrubbing) return;
    setState(() => _scrubbing = false);
    widget.onInteraction();
    widget.controller.endScrub();
    _report(visible: false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final int totalMs = controller.duration.inMilliseconds;
    final double progress = totalMs > 0
        ? (controller.displayPosition.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;
    final double buffered = totalMs > 0
        ? (controller.buffer.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // ⛔ 点按只在**抬手**那一下跳过去，不要用 onTapDown 起 scrub：那样一次拖动
      // 会先 tapDown 起一段、被 tapCancel 结掉（真的 seek 一次到按下点），再由
      // 拖动重新起一段——白跳一次，网络视频上看得见地卡一下。
      onTapUp: (details) {
        if (!_enabled) return;
        widget.onInteraction();
        controller.seekTo(_durationAt(details.localPosition.dx, _trackWidth()));
      },
      onHorizontalDragStart: (d) => _beginScrub(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _updateScrub(d.localPosition.dx),
      onHorizontalDragEnd: (_) => _endScrub(),
      onHorizontalDragCancel: _endScrub,
      child: SizedBox(
        key: _trackKey,
        height: 40,
        width: double.infinity,
        child: CustomPaint(
          painter: _ProgressPainter(
            progress: progress,
            buffered: buffered,
            enabled: _enabled,
            scrubbing: _scrubbing,
            foreground: widget.foreground,
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({
    required this.progress,
    required this.buffered,
    required this.enabled,
    required this.scrubbing,
    required this.foreground,
  });

  final double progress;
  final double buffered;
  final bool enabled;
  final bool scrubbing;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final double trackHeight = scrubbing ? 5 : 3;
    final double cy = size.height / 2;
    final double radius = trackHeight / 2;
    // enabled 与 materialize 两笔衰减都乘在同一个 alpha 上。
    final double base = foreground.a * (enabled ? 1.0 : 0.4);

    void track(double to, double opacity) {
      if (to <= 0) return;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0, cy - radius, to, cy + radius),
          Radius.circular(radius),
        ),
        Paint()..color = foreground.withValues(alpha: base * opacity),
      );
    }

    track(size.width, 0.24);
    track(size.width * buffered, 0.38);
    track(size.width * progress, 1.0);

    if (!enabled) return;
    canvas.drawCircle(
      Offset(size.width * progress, cy),
      scrubbing ? 8 : 6,
      Paint()..color = foreground.withValues(alpha: base),
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.progress != progress ||
      old.buffered != buffered ||
      old.enabled != enabled ||
      old.scrubbing != scrubbing ||
      old.foreground != foreground;
}
