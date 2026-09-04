import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_video_controller.dart';
import 'package:i_iwara/app/ui/pages/gallery_detail/widgets/gallery_chrome_theme.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 画面正中那一组控件：**倒退 N 秒 · 播放/暂停 · 快进 N 秒**。
///
/// # ⛔ 它必须挂在 chrome 层，不能待在页内
///
/// 改造中期这枚钮长在 `PhotoViewGalleryPageOptions.customChild` 里头，也就是
/// `PhotoViewGallery` 的缩放变换**内部**——双指一放大，播放钮跟着一起变大、
/// 平移时还会被推出屏幕。控件没有理由跟着内容缩放。所以和顶栏、控件条一样，
/// 这一组钉在屏幕正中的 chrome 层上。
///
/// # 中间那枚在加载时是「形变」而不是「换一个」
///
/// 加载中**不另建一个转圈组件**：还是同一枚玻璃球，只是里头盛起了一汪液体——
///
///   - **液面高度就是缓冲进度**。拿不到时长时（刚 open、还没解出容器）液面自己
///     缓慢起伏，那就是「不确定」的表达，不必另找一套 UI 语言；
///   - **两道相位不同的正弦波**叠出厚度，慢的那道在下、快的那道在上，读起来是
///     一整块在晃而不是一条线在抖；
///   - **整只球跟着呼吸**（±3.5% 缩放），幅度刻意压得很小——是「活的」，不是
///     「在跳」；
///   - 播放三角同时**缩小并淡出**，与液面共用同一段过渡值 `liquid`，所以中间
///     不会有「液体没了、三角还没来」的空窗。
///
/// 转圈（`CircularProgressIndicator`）和这套材质没有任何关系，而且它只会转，
/// 说不出「缓冲了多少」。
class GalleryVideoCenterControls extends StatefulWidget {
  const GalleryVideoCenterControls({
    super.key,
    required this.controller,
    required this.present,
    required this.chromeVisible,
    required this.seekSeconds,
    required this.onInteraction,
  });

  final GalleryVideoController controller;

  /// 这一组此刻还在不在场。
  ///
  /// 从视频翻到图片时它先变 false、把退场演完，之后调用方才把整只摘掉
  /// （见大图页的 `_syncChromeVideo`）。**加载中的液体球也吃这一条**——不然
  /// 离开一条还在缓冲的视频时，那颗球会赖在图片页上。
  final bool present;

  /// chrome 此刻是否被用户呼出。
  ///
  /// **控件跟着它走，加载中的液体球不跟**：前者是控件，后者是状态——正在缓冲却把
  /// 唯一的进度指示藏掉，用户只会看见一片黑而不知道发生了什么。
  final bool chromeVisible;

  /// 一次跳多少秒；跟播放器设置走，所以钮面上的数字与它真正跳的秒数恒等。
  final ({int rewind, int forward}) seekSeconds;

  /// 按了这一组里的任何一枚。
  ///
  /// ⛔ 这三枚**不参与「点一下收起工具栏」**：点快进是想继续看，不是想让界面
  /// 消失。所以它们各自吃掉点击（比外层那只 tap 更深，竞技场上稳赢），并调这个
  /// 回调把自动收起的计时器往后推。
  final VoidCallback onInteraction;

  @override
  State<GalleryVideoCenterControls> createState() =>
      _GalleryVideoCenterControlsState();
}

class _GalleryVideoCenterControlsState extends State<GalleryVideoCenterControls>
    with SingleTickerProviderStateMixin {
  /// 中间那颗玻璃球的直径。比两侧大一档：它是这一页此刻的主动作。
  static const double _mainDiameter = 76;

  /// 两侧跳秒钮的直径。
  static const double _sideDiameter = 52;

  static const double _gap = 26;

  /// ⛔ **不能无条件 `repeat()`**。它被并进下面那只 `AnimatedBuilder`，一转起来
  /// 就是「只要图库里开着一条视频，这一组三块玻璃每帧重建一次」——不在加载、
  /// chrome 收起来了、整组根本不在场时照转不误。而这个项目量过：玻璃的开销全在
  /// 每块独立玻璃那次整屏背景采样上。液面只有加载时才画，那就只在加载时转。
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  /// 液面的过渡值退到 0 之前波形还在往外走，所以停表要比 `loading` 落回 false
  /// 晚一档（与 [_buildMainButton] 里那只 TweenAnimationBuilder 同长）。
  static const Duration _liquidFade = Duration(milliseconds: 420);
  Timer? _waveStopTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncWave);
    _syncWave();
  }

  @override
  void didUpdateWidget(covariant GalleryVideoCenterControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_syncWave);
      widget.controller.addListener(_syncWave);
    }
    // `present` 是从外面传进来的，翻到图片页时也要停表。
    _syncWave();
  }

  /// ⛔ 只能在生命周期钩子 / 通知回调里调，**不能在 build 里调**：那是在
  /// build 期间动一只 AnimationController。
  void _syncWave() {
    final controller = widget.controller;
    final bool wants =
        widget.present && controller.error == null && controller.loading;
    if (wants) {
      _waveStopTimer?.cancel();
      _waveStopTimer = null;
      if (!_wave.isAnimating) _wave.repeat();
      return;
    }
    if (!_wave.isAnimating || _waveStopTimer != null) return;
    _waveStopTimer = Timer(_liquidFade, () {
      _waveStopTimer = null;
      if (mounted) _wave.stop();
    });
  }

  @override
  void dispose() {
    _waveStopTimer?.cancel();
    widget.controller.removeListener(_syncWave);
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 深色底由 [GalleryDarkChrome] 统一供给（理由见那只类）。
    return GalleryDarkChrome(
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.controller, _wave]),
        builder: (context, _) => _build(context),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final t = slang.Translations.of(context);
    final controller = widget.controller;
    // 「加载中」不只是首次打开：中途卡顿、seek 后重新起缓冲都算，
    // 见 [GalleryVideoController.loading]。
    final bool loading = controller.loading;
    // 按住加速期间把这一组让开：手指正压在画面上，摆一堆钮只会挡着看。
    final bool boosting = controller.boosting;
    final bool showSides =
        widget.present &&
        controller.error == null &&
        controller.ready &&
        widget.chromeVisible &&
        !boosting;
    final bool showMain =
        widget.present &&
        controller.error == null &&
        !boosting &&
        (loading || widget.chromeVisible);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideSeekButton(
          visible: showSides,
          icon: Icons.rotate_left_rounded,
          seconds: widget.seekSeconds.rewind,
          tooltip: t.videoDetail.rewindSeconds(num: widget.seekSeconds.rewind),
          diameter: _sideDiameter,
          onPressed: () {
            widget.onInteraction();
            controller.seekBy(Duration(seconds: -widget.seekSeconds.rewind));
          },
        ),
        const SizedBox(width: _gap),
        _buildMainButton(context, loading: loading, visible: showMain),
        const SizedBox(width: _gap),
        _SideSeekButton(
          visible: showSides,
          icon: Icons.rotate_right_rounded,
          seconds: widget.seekSeconds.forward,
          tooltip: t.videoDetail.fastForwardSeconds(
            num: widget.seekSeconds.forward,
          ),
          diameter: _sideDiameter,
          onPressed: () {
            widget.onInteraction();
            controller.seekBy(Duration(seconds: widget.seekSeconds.forward));
          },
        ),
      ],
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required bool loading,
    required bool visible,
  }) {
    final t = slang.Translations.of(context);
    final controller = widget.controller;

    // 缓冲比例；拿不到时长时交给画笔自己起伏（不确定态）。
    final int totalMs = controller.duration.inMilliseconds;
    final double? level = totalMs > 0
        ? (controller.buffer.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : null;

    // ⛔ 尺寸放在 [GlassReveal] **里头**：搁在外面的话，钮全收起来之后这一组
    // 仍然在屏幕正中占着 232×76 的一块，而那块被 [_chromeHitKeys] 算作 chrome
    // ——桌面端把光标停在画面正中滚滚轮就翻不了页了。
    return GlassReveal(
      visible: visible,
      // 正中的东西不该从下方滑上来，只做材质淡入。
      slideFrom: Offset.zero,
      builder: (context, materialize) => SizedBox.square(
        dimension: _mainDiameter,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 420),
          curve: GlassTokens.motionCurve,
          tween: Tween<double>(begin: 0, end: loading ? 1 : 0),
          builder: (context, liquid, _) {
            // 呼吸：只有装着液体时才起伏，幅度小到「像活的」而不是「在跳」。
            final double breath =
                1 +
                0.035 *
                    liquid *
                    (0.5 + 0.5 * math.sin(_wave.value * 2 * math.pi));
            return Transform.scale(
              scale: breath,
              child: GlassChromeLayer(
                // 这一组里每枚都要各自做材质淡入，融合组会把 materialize 关掉。
                group: false,
                child: GlassSurface(
                  circle: true,
                  height: _mainDiameter,
                  materialize: materialize,
                  // 液面必须被球裁住，否则在传统档下会溢出成一个方块。
                  clipContent: true,
                  // 跟手形变会把这颗球拽变形，和「里头盛着液体」的读法冲突。
                  liquidTouch: false,
                  tooltip: controller.playing
                      ? t.videoDetail.pause
                      : t.videoDetail.play,
                  onTap: controller.ready
                      ? () {
                          widget.onInteraction();
                          controller.togglePlayPause();
                        }
                      : null,
                  child: SizedBox.square(
                    dimension: _mainDiameter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (liquid > 0)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _LiquidFillPainter(
                                phase: _wave.value,
                                level: level,
                                amount: liquid * materialize,
                              ),
                            ),
                          ),
                        // 图标随液体涨落**缩小并淡出**——同一枚钮在形变，而不是
                        // 被另一个组件替换掉。播/停之间走 GlassAnimatedIcon
                        // （全站统一的图标形变原语）。
                        Transform.scale(
                          scale: 1 - 0.35 * liquid,
                          child: GlassAnimatedIcon(
                            icon: Icon(
                              controller.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 38,
                              // 走颜色通道压透明度，不套 Opacity（那会 saveLayer
                              // 把液态档的折射打断，见 GlassSurface.materialize）。
                              color: Colors.white.withValues(
                                alpha: materialize * (1 - liquid),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 两侧那两枚跳秒钮：圆弧箭头里写着秒数（iOS / YouTube 的通用画法）。
class _SideSeekButton extends StatelessWidget {
  const _SideSeekButton({
    required this.visible,
    required this.icon,
    required this.seconds,
    required this.tooltip,
    required this.diameter,
    required this.onPressed,
  });

  final bool visible;
  final IconData icon;
  final int seconds;
  final String tooltip;
  final double diameter;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // 尺寸在 [GlassReveal] 里头，收起来就不占位，理由见主钮那段。
    return GlassReveal(
      visible: visible,
      slideFrom: Offset.zero,
      builder: (context, materialize) => SizedBox.square(
        dimension: diameter,
        child: GlassChromeLayer(
          group: false,
          child: GlassSurface(
            circle: true,
            height: diameter,
            materialize: materialize,
            liquidTouch: false,
            tooltip: tooltip,
            onTap: onPressed,
            child: SizedBox.square(
              dimension: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: Colors.white.withValues(alpha: materialize),
                  ),
                  // 秒数写在弧箭头正中，字号压到 10.5：这是标注不是标题。
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Text(
                      '$seconds',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: materialize),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 玻璃球里那汪液体。
class _LiquidFillPainter extends CustomPainter {
  const _LiquidFillPainter({
    required this.phase,
    required this.level,
    required this.amount,
  });

  /// 0→1 循环一圈的相位。
  final double phase;

  /// 液面高度（缓冲比例）。为 null 表示还不知道，液面自己缓慢起伏。
  final double? level;

  /// 整汪液体的「在场程度」：跟着就绪过渡与材质淡入一起收。
  final double amount;

  @override
  void paint(Canvas canvas, Size size) {
    if (amount <= 0) return;
    final double radius = size.shortestSide / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // 不确定态：在三成到六成之间来回荡，看得出「在动」但不会假装知道进度。
    final double fill =
        level ?? (0.45 + 0.15 * math.sin(phase * 2 * math.pi * 0.8));
    // 液面永远留一线在球里：真到 0 会读成「空的」，到 1 会读成「满溢」。
    final double baseY = size.height * (1 - fill.clamp(0.08, 0.94));

    void wave({
      required double amplitude,
      required double frequency,
      required double phaseShift,
      required double opacity,
    }) {
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, baseY);
      for (double x = 0; x <= size.width; x += 2) {
        final double t = x / size.width;
        path.lineTo(
          x,
          baseY +
              amplitude *
                  math.sin((t * frequency + phase + phaseShift) * 2 * math.pi),
        );
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Colors.white.withValues(alpha: opacity * amount),
      );
    }

    // 慢的那道在下、快的那道在上：两层叠出厚度，读起来是一整块在晃。
    wave(
      amplitude: radius * 0.11,
      frequency: 1.3,
      phaseShift: 0,
      opacity: 0.18,
    );
    wave(
      amplitude: radius * 0.075,
      frequency: 1.9,
      phaseShift: 0.45,
      opacity: 0.26,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LiquidFillPainter old) =>
      old.phase != phase || old.level != level || old.amount != amount;
}

/// 按住加速时浮在正中上方的倍速牌。
class GalleryVideoBoostBadge extends StatelessWidget {
  const GalleryVideoBoostBadge({super.key, required this.controller});

  final GalleryVideoController controller;

  @override
  Widget build(BuildContext context) {
    return GalleryDarkChrome(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => GlassReveal(
          visible: controller.boosting,
          builder: (context, materialize) => GlassChromeLayer(
            group: false,
            child: GlassSurface(
              height: 40,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              materialize: materialize,
              liquidTouch: false,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fast_forward_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: materialize),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.rate.toStringAsFixed(1)}×',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: materialize),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
