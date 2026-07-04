import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../services/player_keybinding/keybinding_service.dart';
import '../../../../../services/player_keybinding/shortcut_action.dart';

/// 手势演示插画的类型。与首次指引页（video_gesture_guide_page.dart）配套使用，
/// 逐帧还原对应的播放器手势动效：带固定顶/底控制栏的迷你播放器，缩放/旋转只
/// 作用于视频画面层，叠加动画手指与信息浮层。
enum GestureVisual {
  tap,
  doubleTap,
  hDrag,
  vDrag,
  longPress,
  pinch,
  rotate,
  keys,
  ctrlWheel,
  shiftWheel,
}

/// 由外部时钟（累计秒数）驱动的手势演示插画。多个插画共享同一个 [clock]，
/// 各自按自己的循环周期取模播放，互不干扰。
class AnimatedGestureIllustration extends StatelessWidget {
  final GestureVisual visual;
  final ValueListenable<double> clock;

  const AnimatedGestureIllustration({
    super.key,
    required this.visual,
    required this.clock,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 深色画面上的强调色：主题 primary 提亮，保证对比度。
    final Color accent = Color.lerp(cs.primary, Colors.white, 0.5)!;
    // 键盘卡按用户真实配置的快捷键展示（每次外层重建时取一次，不逐帧取）。
    final _KeyLabels? keyLabels =
        visual == GestureVisual.keys ? _resolveKeyLabels() : null;
    return LayoutBuilder(
      builder: (context, c) {
        final double w = c.maxWidth;
        final double h = c.maxHeight.isFinite ? c.maxHeight : w * 9 / 16;
        return ValueListenableBuilder<double>(
          valueListenable: clock,
          builder: (context, t, _) {
            return _Painter(
              visual: visual,
              w: w,
              h: h,
              t: t,
              accent: accent,
              keys: keyLabels,
            ).build();
          },
        );
      },
    );
  }
}

// ============================ 逐帧绘制 ============================

class _Painter {
  final GestureVisual visual;
  final double w;
  final double h;
  final double t;
  final Color accent;
  final _KeyLabels? keys;

  _Painter({
    required this.visual,
    required this.w,
    required this.h,
    required this.t,
    required this.accent,
    this.keys,
  });

  // 迷你播放器画面底色（始终深色，代表视频）。
  static const Color _box = Color(0xFF23262E);
  static const Color _mediaAccent = Color(0xFFA9C7FF);
  static const Color _mediaAccentStrong = Color(0xFFC6DBFF);
  static const Color _dim = Color(0xB3FFFFFF);
  static const double _barH = 24;
  static const double _fingerR = 30;

  // ---- 数学工具 ----
  static double _seg(double x, double a, double b) {
    final v = (x - a) / (b - a);
    return v < 0 ? 0 : (v > 1 ? 1 : v);
  }

  static double _ease(double x) =>
      x < .5 ? 2 * x * x : 1 - math.pow(-2 * x + 2, 2).toDouble() / 2;

  static double _pulse(double x, double a, double b) {
    final m = (a + b) / 2;
    return x < m ? _seg(x, a, m) : 1 - _seg(x, m, b);
  }

  static double _clamp(double v, double a, double b) =>
      v < a ? a : (v > b ? b : v);

  Widget build() {
    // 每种手势产出：画面变换 + 进度 + 播放态 + 叠加层。
    double scale = 1, rotation = 0;
    Offset translate = Offset.zero;
    double progress = 0.34;
    bool playing = true;
    bool topBarVisible = true;
    bool bottomBarVisible = true;
    final List<Widget> overlays = [];

    final Offset center = Offset(w / 2, h / 2);

    switch (visual) {
      case GestureVisual.tap:
        {
          final tt = t % 3.2;
          final tap = _pulse(tt, .25, 1.0);
          // 单击切换控制栏显隐：顶栏与底栏一起显隐
          topBarVisible = tt < 1.6;
          bottomBarVisible = tt < 1.6;
          overlays.add(_finger(center.dx, center.dy, tap));
          overlays.add(_ripple(center.dx, center.dy, _seg(tt, .3, 1.0)));
          break;
        }
      case GestureVisual.doubleTap:
        {
          final tt = t % 9.0;
          final phase = tt < 3
              ? 0
              : tt < 6
              ? 1
              : 2;
          final lt = tt - phase * 3;
          final tap = _pulse(lt, .2, .95);
          final zoneOn = lt > .2 && lt < 1.9 ? 1.0 : 0.0;
          final fx = phase == 0
              ? w * 0.10
              : phase == 1
              ? w * 0.5
              : w * 0.90;
          if (phase == 0) {
            overlays.add(_zone(0, zoneOn, Icons.fast_rewind, '10s'));
            if (lt > .55) progress = 0.34 - 0.09 * _ease(_seg(lt, .55, .9));
          } else if (phase == 1) {
            overlays.add(_zoneCenter(zoneOn, playing: (lt < .55)));
            playing = lt >= .55 ? false : true;
          } else {
            overlays.add(_zone(2, zoneOn, Icons.fast_forward, '10s'));
            if (lt > .55) progress = 0.34 + 0.09 * _ease(_seg(lt, .55, .9));
          }
          overlays.add(_finger(fx, h * 0.52, tap));
          break;
        }
      case GestureVisual.hDrag:
        {
          final tt = t % 5.0;
          final appear = _seg(tt, .2, .5) * (1 - _seg(tt, 4.3, 4.8));
          final drag = _pulse(tt, .5, 4.2);
          final fx = w * (0.3 + drag * 0.4);
          progress = 0.34 + drag * 0.26;
          overlays.add(_finger(fx, h * 0.52, appear));
          overlays.add(
            _centerPill(
              icon: Icons.swap_horiz,
              text: _fmtTime((progress * 220).round()),
              opacity: appear,
            ),
          );
          break;
        }
      case GestureVisual.vDrag:
        {
          final tt = t % 8.0;
          final bright = tt < 4;
          final lt = bright ? tt : tt - 4;
          final appear = _seg(lt, .2, .6) * (1 - _seg(lt, 3.4, 3.9));
          final travel = _pulse(lt, .55, 3.3);
          final fx = bright ? w * 0.12 : w * 0.88;
          final fy = h * (0.66 - travel * 0.40);
          overlays.add(_finger(fx, fy, appear));
          if (bright) {
            final v = (0.35 + travel * 0.45);
            overlays.add(
              _centerPill(
                icon: Icons.brightness_6,
                text: '亮度 ${(v * 100).round()}%',
                opacity: appear,
              ),
            );
          } else {
            final v = (0.25 + travel * 0.6);
            overlays.add(
              _centerPill(
                icon: Icons.volume_up,
                text: '音量 ${(v * 100).round()}%',
                opacity: appear,
              ),
            );
          }
          break;
        }
      case GestureVisual.longPress:
        {
          final tt = t % 7.5;
          final press = _seg(tt, .3, .8) * (1 - _seg(tt, 6.6, 7.1));
          double dragN;
          if (tt < 1.4) {
            dragN = 0;
          } else if (tt < 3.2) {
            dragN = _ease(_seg(tt, 1.4, 3.2));
          } else if (tt < 4.2) {
            dragN = 1 - _ease(_seg(tt, 3.2, 4.2)) * 0.6;
          } else if (tt < 5.6) {
            dragN = 0.4 - _ease(_seg(tt, 4.2, 5.6)) * 1.0;
          } else {
            dragN = -0.6 + _ease(_seg(tt, 5.6, 6.6)) * 0.6;
          }
          final fx = w * (0.5 + dragN * 0.28);
          overlays.add(_finger(fx, h * 0.54, press));
          double speed = 1.75 + (dragN > 0 ? dragN * 2.05 : dragN * 1.4);
          speed = _clamp((speed * 10).roundToDouble() / 10, 0.1, 4.0);
          // 倍速浮层固定在左下角（不跟手），带流动箭头 + 速度表 + ×倍速。
          overlays.add(_speedPill(speed, t, press));
          break;
        }
      case GestureVisual.pinch:
        {
          final tt = t % 5.0;
          final appear = _seg(tt, .15, .55) * (1 - _seg(tt, 3.5, 3.9));
          final spread = _ease(_seg(tt, .85, 2.5));
          final reset = _ease(_seg(tt, 3.95, 4.7));
          final r = w * 0.10 + spread * w * 0.20;
          scale = 1 + 0.8 * spread * (1 - reset);
          const ang = -0.62;
          final a = Offset(
            center.dx + math.cos(ang) * r,
            center.dy - 2 + math.sin(ang) * r,
          );
          final b = Offset(
            center.dx - math.cos(ang) * r,
            center.dy - 2 - math.sin(ang) * r,
          );
          overlays.add(_line(a, b, appear * 0.85));
          overlays.add(_finger(a.dx, a.dy, appear));
          overlays.add(_finger(b.dx, b.dy, appear));
          overlays.add(_hud('${scale.toStringAsFixed(2)}×'));
          break;
        }
      case GestureVisual.rotate:
        {
          final tt = t % 5.6;
          final appear = _seg(tt, .15, .55) * (1 - _seg(tt, 4.0, 4.4));
          final turn = _ease(_seg(tt, .85, 2.9));
          final reset = _ease(_seg(tt, 4.45, 5.3));
          final ang = -0.5 + turn * (38 * math.pi / 180) * 1.15;
          rotation = turn * (38 * math.pi / 180) * (1 - reset);
          final r = w * 0.22;
          final a = Offset(
            center.dx + math.cos(ang) * r,
            center.dy - 2 + math.sin(ang) * r,
          );
          final b = Offset(
            center.dx - math.cos(ang) * r,
            center.dy - 2 - math.sin(ang) * r,
          );
          overlays.add(_line(a, b, appear * 0.85));
          overlays.add(_finger(a.dx, a.dy, appear));
          overlays.add(_finger(b.dx, b.dy, appear));
          final deg = (rotation * 180 / math.pi).round();
          overlays.add(_hud('${deg >= 0 ? '+' : ''}$deg°'));
          break;
        }
      case GestureVisual.keys:
        {
          final kl = keys ?? const _KeyLabels();
          final tt = t % 9.0;
          // 高亮的按键槽位：0 后退 / 1 播放暂停 / 2 快进 / 3 减速 / 4 加速
          int lit = -1;
          bool holdSpeed = false; // 长按 seek 键 = 倍速播放
          double normalSpeed = 1.0; // 常速播放时的调速结果
          bool showNormalSpeed = false;
          if (tt < 1.3) {
            // 单点后退键：进度瞬间后退
            lit = 0;
            progress = 0.34 - 0.10 * _ease(_seg(tt, .3, 1.0));
          } else if (tt < 2.6) {
            // 单点快进键：进度瞬间前进
            lit = 2;
            progress = 0.34 + 0.10 * _ease(_seg(tt, 1.6, 2.3));
          } else if (tt < 5.0) {
            // 长按快进键：进入倍速播放（不再改变进度）
            lit = 2;
            holdSpeed = true;
          } else if (tt < 6.7) {
            // 加速键：常速播放下逐档提速
            lit = 4;
            showNormalSpeed = true;
            normalSpeed = 1.0 + 0.25 * _ease(_seg(tt, 5.2, 6.2));
          } else if (tt < 8.4) {
            // 减速键：常速播放下逐档减速
            lit = 3;
            showNormalSpeed = true;
            normalSpeed = 1.0 - 0.25 * _ease(_seg(tt, 6.9, 7.9));
          }
          overlays.add(_keyChips(kl, lit));
          if (holdSpeed) {
            overlays.add(_speedPill(1.75, t, _seg(tt, 2.6, 2.95)));
          }
          if (showNormalSpeed) {
            normalSpeed = (normalSpeed * 100).roundToDouble() / 100;
            overlays.add(_hud('常速 ×${normalSpeed.toStringAsFixed(2)}'));
          }
          break;
        }
      case GestureVisual.ctrlWheel:
        {
          final tt = t % 6.0;
          double s = 1;
          for (final tick in [0.9, 1.6, 2.3]) {
            s += 0.24 * _ease(_seg(tt, tick, tick + 0.35));
          }
          final back = _ease(_seg(tt, 4.6, 5.6));
          scale = 1 + (s - 1) * (1 - back);
          final on = tt > 0.5 && tt < 3.4;
          overlays.add(_modifierWheel('Ctrl', Icons.zoom_in, on, upward: true));
          overlays.add(_hud('${scale.toStringAsFixed(2)}×'));
          break;
        }
      case GestureVisual.shiftWheel:
        {
          final tt = t % 6.0;
          double r = 0;
          for (final tick in [0.9, 1.6, 2.3]) {
            r += 12 * _ease(_seg(tt, tick, tick + 0.35));
          }
          final back = _ease(_seg(tt, 4.6, 5.6));
          rotation = (r * (1 - back)) * math.pi / 180;
          final on = tt > 0.5 && tt < 3.4;
          overlays.add(
            _modifierWheel('Shift', Icons.rotate_right, on, upward: false),
          );
          final deg = (rotation * 180 / math.pi).round();
          overlays.add(_hud('+$deg°'));
          break;
        }
    }

    return ClipRect(
      child: ColoredBox(
        color: _box,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 视频画面层：仅此层应用平移/旋转/缩放（与真实播放器
            // _buildVideoPlayer 的嵌套 Transform 一致，顶/底栏不受影响）。
            Transform.translate(
              offset: translate,
              child: Transform.rotate(
                angle: rotation,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: _thumbnail(),
                ),
              ),
            ),
            // 固定顶栏
            _topBar(topBarVisible),
            // 固定底栏（进度）
            _bottomBar(progress, playing, bottomBarVisible),
            ...overlays,
          ],
        ),
      ),
    );
  }

  // ---- 画面缩略图（夜空 + 太阳 + 山影）----
  Widget _thumbnail() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A5680), Color(0xFF22344D), Color(0xFF16202E)],
          stops: [0, .55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: w * 0.12,
            top: h * 0.12,
            child: Container(
              width: h * 0.30,
              height: h * 0.30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFFFE0B0), Color(0x66FFD8A8), Color(0x00FFD8A8)],
                  stops: [0, .5, 1],
                ),
              ),
            ),
          ),
          // 山影
          Positioned(
            left: -w * 0.1,
            bottom: h * 0.14,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: w * 0.8,
                height: h * 0.5,
                color: const Color(0xFF1A2536),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 顶栏 ----
  Widget _topBar(bool visible) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: Container(
          height: _barH,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x8C000000), Color(0x00000000)],
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_new, size: 11, color: _dim),
              const SizedBox(width: 6),
              Text(
                '示例视频',
                style: TextStyle(color: _dim, fontSize: 9.5),
              ),
              const Spacer(),
              const Icon(Icons.more_vert, size: 12, color: _dim),
            ],
          ),
        ),
      ),
    );
  }

  // ---- 底栏（播放键 + 进度）----
  Widget _bottomBar(double progress, bool playing, bool visible) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: Container(
        height: _barH,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0x99000000), Color(0x00000000)],
          ),
        ),
        child: Row(
          children: [
            Icon(playing ? Icons.play_arrow : Icons.pause, size: 13, color: _dim),
            const SizedBox(width: 6),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: _mediaAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(progress.clamp(0.0, 1.0) * 2 - 1, 0),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _mediaAccentStrong,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        ),
      ),
    );
  }

  // ---- 手指 ----
  Widget _finger(double cx, double cy, double opacity) {
    return Positioned(
      left: cx - _fingerR / 2,
      top: cy - _fingerR / 2,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: _fingerR,
          height: _fingerR,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _mediaAccent.withValues(alpha: 0.18),
            border: Border.all(color: _mediaAccent, width: 2),
          ),
          child: Center(
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _mediaAccentStrong,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ripple(double cx, double cy, double p) {
    final size = 20 + p * 34;
    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - p).clamp(0.0, 1.0) * 0.6,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _mediaAccent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  // ---- 双指连线 ----
  Widget _line(Offset a, Offset b, double opacity) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final len = (b - a).distance;
    final angle = math.atan2(b.dy - a.dy, b.dx - a.dx);
    return Positioned(
      left: mid.dx - len / 2,
      top: mid.dy,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: len,
            height: 1.5,
            color: _mediaAccent.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }

  // ---- HUD（右上角倍率/角度）----
  Widget _hud(String text) {
    return Positioned(
      top: _barH + 6,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  // ---- 中央信息浮窗（亮度/音量/进度）----
  Widget _centerPill({
    required IconData icon,
    required String text,
    required double opacity,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      top: h * 0.42,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
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

  // ---- 双击分区高亮（左/右）----
  Widget _zone(int idx, double on, IconData icon, String label) {
    return Positioned(
      left: idx == 0 ? 0 : null,
      right: idx == 2 ? 0 : null,
      top: 0,
      bottom: 0,
      width: w * 0.2,
      child: IgnorePointer(
        child: Opacity(
          opacity: on,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _mediaAccent.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(color: _dim, fontSize: 8.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- 双击分区高亮（中央：暂停/播放）----
  Widget _zoneCenter(double on, {required bool playing}) {
    return Positioned(
      left: w * 0.2,
      right: w * 0.2,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: on,
          child: Center(
            child: Icon(
              playing ? Icons.play_arrow : Icons.pause,
              color: accent,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  // ---- 长按倍速浮层（固定左下角，不跟手）----
  Widget _speedPill(double speed, double clock, double opacity) {
    // 流动箭头透明度波动，倍速越大越快。
    final flow = clock * (1.1 + speed * 0.4);
    List<Widget> chevrons = List.generate(3, (i) {
      final ph = (flow + i / 3) % 1.0;
      final wave = 0.5 + 0.5 * math.sin(ph * 2 * math.pi);
      return Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Icon(
          Icons.chevron_right,
          size: 12,
          color: Colors.white.withValues(alpha: (0.25 + 0.75 * wave).clamp(0.0, 1.0)),
        ),
      );
    });
    final txt = (speed % 1).abs() < 1e-6
        ? '×${speed.toStringAsFixed(0)}'
        : '×${speed.toStringAsFixed(1)}';
    return Positioned(
      left: 8,
      bottom: _barH + 6,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: chevrons),
                const SizedBox(width: 3),
                const Icon(Icons.speed, size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  txt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- 键盘按键 chips（真实键位标签，两行：seek 行 + 调速行）----
  Widget _keyChips(_KeyLabels kl, int lit) {
    Widget chip(String label, int slot) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: lit == slot ? accent : Colors.white38,
          width: 1.2,
        ),
        color: lit == slot ? accent.withValues(alpha: 0.24) : Colors.white10,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: lit == slot ? accent : _dim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chip(kl.seekBack, 0),
                      chip(kl.playPause, 1),
                      chip(kl.seekFwd, 2),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chip(kl.speedDown, 3),
                      chip(kl.speedUp, 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- 修饰键 + 鼠标滚轮 ----
  Widget _modifierWheel(
    String label,
    IconData action,
    bool on, {
    required bool upward,
  }) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: on ? accent : Colors.white38, width: 1.2),
                  color: on ? accent.withValues(alpha: 0.22) : Colors.white10,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: on ? accent : _dim,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.mouse, color: _dim, size: 22),
              const SizedBox(width: 8),
              Icon(action, color: accent, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// 键盘卡展示用的真实键位标签。缺省值为出厂默认键位，仅在取不到
/// [KeybindingService] 时兜底。
class _KeyLabels {
  final String seekBack;
  final String seekFwd;
  final String speedDown;
  final String speedUp;
  final String playPause;
  const _KeyLabels({
    this.seekBack = '←',
    this.seekFwd = '→',
    this.speedDown = '[',
    this.speedUp = ']',
    this.playPause = 'Space',
  });
}

/// 从 [KeybindingService] 读取用户当前配置的按键，转成可读标签。
_KeyLabels _resolveKeyLabels() {
  String lab(ShortcutAction action, String fallback) {
    try {
      if (Get.isRegistered<KeybindingService>()) {
        final chords = Get.find<KeybindingService>().chordsOf(action);
        if (chords.isNotEmpty) return chords.first.displayLabel;
      }
    } catch (_) {
      // 取不到时用默认键位兜底
    }
    return fallback;
  }

  return _KeyLabels(
    seekBack: lab(ShortcutAction.seekBackward, '←'),
    seekFwd: lab(ShortcutAction.seekForward, '→'),
    speedDown: lab(ShortcutAction.speedDown, '['),
    speedUp: lab(ShortcutAction.speedUp, ']'),
    playPause: lab(ShortcutAction.playPause, 'Space'),
  );
}
