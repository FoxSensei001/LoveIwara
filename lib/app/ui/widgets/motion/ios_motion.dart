import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/common/constants.dart';

/// iOS 式动效积木：弹簧、按压缩放、出现 / 消失、数字滚动、触感。
///
/// 系统动效几乎全是弹簧，而不是「固定时长 + 缓动曲线」：弹簧能在半路换目标并
/// 接住当前速度（被打断时不会顿一下）。参数照 SwiftUI 的
/// `.spring(duration:bounce:)`，Flutter 的对应是
/// [SpringDescription.withDurationAndBounce]。
///
/// 数值是 2026-10-18 下载页原型里定下的默认值（见 docs/FEEDBACK_LOG.md 决定表）。
abstract final class IosSprings {
  /// 卡片展开 / 收起 / 挪位。
  static final SpringDescription layout =
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 420),
      );

  /// 手指按下：快、不回弹。
  static final SpringDescription pressDown =
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 160),
      );

  /// 手指抬起：带一点回弹。
  static final SpringDescription pressUp =
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 420),
        bounce: 0.18,
      );

  /// 数字逐位滚动。
  static final SpringDescription digit =
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 380),
      );

  /// 对勾这类「弹出来」的图标。
  static final SpringDescription pop = SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 380),
    bounce: 0.35,
  );
}

/// 系统「减少动态效果」开着没有。开着时一律退成淡入淡出。
bool reduceMotionOf(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// 让 unbounded 的 [controller] 用弹簧走到 [target]，接住当前速度。
/// [reduceMotion] 时换成 200ms 的线性过渡。
TickerFuture springTo(
  AnimationController controller,
  double target, {
  SpringDescription? spring,
  bool reduceMotion = false,
}) {
  if (reduceMotion) {
    return controller.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
  final future = controller.animateWith(
    SpringSimulation(
      spring ?? IosSprings.layout,
      controller.value,
      target,
      controller.velocity,
      tolerance: const Tolerance(distance: 0.001, velocity: 0.01),
    ),
  );
  // 弹簧停在「差不多到了」（容差内）而不是正好到：落定后补齐，否则高度差
  // 零点几像素、透明度停在 0.999，下游的「到了就撤掉包装」永远不触发。
  // 被半路打断时这个 then 不会执行。
  future.then((_) => controller.value = target);
  return future;
}

/// 把弹簧折成 0→1 的曲线，给只吃 [Curve] 的地方（如 `AnimatedSwitcher`）用。
/// 曲线会冲过 1，下游若接 `Interval` 之类只收 [0, 1] 的东西，先夹住。
class SpringCurve extends Curve {
  SpringCurve(SpringDescription spring, this.seconds)
    : _sim = SpringSimulation(spring, 0, 1, 0);

  final SpringSimulation _sim;

  /// 整条曲线对应的秒数（要和使用处的 duration 一致）。
  final double seconds;

  @override
  double transformInternal(double t) => _sim.x(t * seconds);
}

// =============================================================================
// 触感
// =============================================================================

/// 带语义的触感，对应 iOS 的 UIImpactFeedbackGenerator / UISelectionFeedback
/// Generator / UINotificationFeedbackGenerator。
enum IosHaptic { light, medium, selection, success, warning }

/// 触发一次触感。只在手机上发（桌面端引擎没实现这个通道），并受全局「振动」
/// 开关（[CommonConstants.enableVibration]）约束。
void iosHaptic(IosHaptic kind) {
  if (!CommonConstants.enableVibration) return;
  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  final Future<void> Function() fire = switch (kind) {
    IosHaptic.light => HapticFeedback.lightImpact,
    IosHaptic.medium => HapticFeedback.mediumImpact,
    IosHaptic.selection => HapticFeedback.selectionClick,
    IosHaptic.success => HapticFeedback.successNotification,
    IosHaptic.warning => HapticFeedback.warningNotification,
  };
  unawaited(fire().catchError((Object _) {}));
}

// =============================================================================
// 按压
// =============================================================================

/// iOS 式按压：按下用弹簧缩下去（列表里延迟 60ms 再亮，免得一滑动就闪），松手
/// 带一点回弹弹回来；手指挪出 12px 算放弃。代替 Material 的水波纹。
///
/// [builder] 拿到按压量 `press`（0＝松开，1＝按到底；回弹时会短暂小于 0），
/// 由调用方决定缩谁、压暗谁——卡片缩整张，封面只缩中间那枚钮。
///
/// 嵌套时只有最里层亮：[Listener] 按命中顺序由内向外派发，内层先 [claimPointer]
/// 认领这根手指，外层看到已被认领就不动。卡片里其它自己处理点击的小控件（⋮、
/// 作者名）也要在按下时 [claimPointer]，否则按它们时整张卡会一起缩。
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
  });

  final Widget Function(BuildContext context, double press) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static int? _claimed;

  /// 认领一根手指：外层的 [PressScale] 看到它就不再响应。
  static void claimPointer(int pointer) => _claimed = pointer;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController.unbounded(
    vsync: this,
  );
  Timer? _delay;
  Timer? _quickRelease;
  int? _pointer;
  Offset _downAt = Offset.zero;
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed == pressed || !mounted) return;
    _pressed = pressed;
    springTo(
      _press,
      pressed ? 1 : 0,
      spring: pressed ? IosSprings.pressDown : IosSprings.pressUp,
      reduceMotion: reduceMotionOf(context),
    );
  }

  void _cancel() {
    _delay?.cancel();
    _pointer = null;
    _set(false);
  }

  @override
  void dispose() {
    _delay?.cancel();
    _quickRelease?.cancel();
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null || widget.onLongPress != null;
    return Listener(
      onPointerDown: (event) {
        if (!interactive || PressScale._claimed == event.pointer) return;
        // 只认主键（触摸、左键）：右键是开菜单，不该先把卡片按下去。
        if (event.buttons & kPrimaryButton == 0) return;
        PressScale.claimPointer(event.pointer);
        _pointer = event.pointer;
        _downAt = event.position;
        _quickRelease?.cancel();
        _delay?.cancel();
        _delay = Timer(const Duration(milliseconds: 60), () => _set(true));
      },
      onPointerMove: (event) {
        if (event.pointer != _pointer) return;
        if ((event.position - _downAt).distance > 12) _cancel();
      },
      onPointerUp: (event) {
        if (event.pointer != _pointer) return;
        _pointer = null;
        if (_delay?.isActive ?? false) {
          // 点得太快、还没来得及亮：补一下按下态，轻点也要有反应。
          _delay!.cancel();
          _set(true);
          _quickRelease = Timer(
            const Duration(milliseconds: 90),
            () => _set(false),
          );
        } else {
          _set(false);
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _pointer) _cancel();
      },
      child: MouseRegion(
        cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedBuilder(
            animation: _press,
            builder: (context, _) => widget.builder(context, _press.value),
          ),
        ),
      ),
    );
  }
}

/// 按下时认领手指，让外层的 [PressScale] 不跟着缩（包在卡片里的小按钮外面）。
class PressScaleClaim extends StatelessWidget {
  const PressScaleClaim({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (event) => PressScale.claimPointer(event.pointer),
    child: child,
  );
}

// =============================================================================
// 出现 / 消失
// =============================================================================

/// 一列带「出现 / 消失 / 挪位」动画的 sliver 列表。
///
/// - 新来的从高度 0 展开、淡入；
/// - 被移走的留在原位收起、淡出，动画完才真正摘掉（定格在它最后的样子）。
///
/// 不做换位动画：sliver 里的子项是在布局阶段才 build 的，那时去量旧位置会读到
/// 正在重排的几何（实测直接抛空指针）。下载页按加入顺序固定排，换位几乎不发生。
///
/// 只适合单列：多列网格里删一张会让后面每张都换行，这种挪动不归它管。
class PresenceSliverList<T> extends StatefulWidget {
  const PresenceSliverList({
    super.key,
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
  });

  final List<T> items;
  final Object Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  State<PresenceSliverList<T>> createState() => _PresenceSliverListState<T>();
}

class _PresenceEntry<T> {
  _PresenceEntry(this.key, this.item, {this.animateIn = false});
  final Object key;
  T item;
  bool leaving = false;
  bool animateIn;
  Widget? lastChild;
  Timer? fallback;
}

class _PresenceSliverListState<T> extends State<PresenceSliverList<T>> {
  late List<_PresenceEntry<T>> _entries = [
    for (final item in widget.items) _PresenceEntry(widget.keyOf(item), item),
  ];

  @override
  void didUpdateWidget(PresenceSliverList<T> old) {
    super.didUpdateWidget(old);
    final items = widget.items;
    final newKeys = [for (final item in items) widget.keyOf(item)];
    final newSet = newKeys.toSet();
    // 正在收起的也算：同一个 key 半路回来（筛选来回切）就把它救回来，
    // 不能另起一条——两条同 key 的兄弟会让 sliver 把元素配错。
    final existing = <Object, _PresenceEntry<T>>{
      for (final e in _entries) e.key: e,
    };

    // 被移走的挂在它前面那个留下来的后面，原地收起。
    final leavingAfter = <Object?, List<_PresenceEntry<T>>>{};
    Object? prev;
    for (final e in _entries) {
      if (newSet.contains(e.key)) {
        if (e.leaving) {
          e.leaving = false;
          e.fallback?.cancel();
          e.fallback = null;
        }
        prev = e.key;
        continue;
      }
      if (!e.leaving) {
        e.leaving = true;
        // 不在屏幕上的那条永远不会被 build、也就收不到动画结束：到点直接摘。
        e.fallback = Timer(
          Duration(milliseconds: (900 * timeDilation).round()),
          () => _remove(e),
        );
      }
      leavingAfter.putIfAbsent(prev, () => []).add(e);
    }

    final added = <_PresenceEntry<T>>[];
    final result = <_PresenceEntry<T>>[...?leavingAfter[null]];
    for (var i = 0; i < items.length; i++) {
      final key = newKeys[i];
      var e = existing[key];
      if (e == null) {
        e = _PresenceEntry(key, items[i], animateIn: true);
        added.add(e);
      }
      e.item = items[i];
      result.add(e);
      result.addAll(leavingAfter[key] ?? const []);
    }
    _entries = result;

    // 插在屏幕外的那条，等以后滚到时就别再演入场了。
    if (added.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final e in added) {
          e.animateIn = false;
        }
      });
    }
  }

  void _remove(_PresenceEntry<T> e) {
    e.fallback?.cancel();
    if (!mounted || !_entries.contains(e)) return;
    setState(() => _entries.remove(e));
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.fallback?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: _entries.length,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<Object>) return null;
        final index = _entries.indexWhere((e) => e.key == key.value);
        return index < 0 ? null : index;
      },
      itemBuilder: (context, index) {
        final e = _entries[index];
        final Widget child;
        if (e.leaving && e.lastChild != null) {
          child = e.lastChild!;
        } else {
          child = e.lastChild = widget.itemBuilder(context, e.item);
        }
        return _PresenceItem(
          key: ValueKey<Object>(e.key),
          leaving: e.leaving,
          animateIn: e.animateIn,
          onGone: () => _remove(e),
          child: child,
        );
      },
    );
  }
}

class _PresenceItem extends StatefulWidget {
  const _PresenceItem({
    super.key,
    required this.leaving,
    required this.animateIn,
    required this.onGone,
    required this.child,
  });

  final bool leaving;
  final bool animateIn;
  final VoidCallback onGone;
  final Widget child;

  @override
  State<_PresenceItem> createState() => _PresenceItemState();
}

class _PresenceItemState extends State<_PresenceItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _v = AnimationController.unbounded(
    vsync: this,
    value: widget.animateIn ? 0 : 1,
  );

  /// 静止时把包装层撤掉（Opacity 即便是 1 也会多推一层合成），子树靠这把
  /// GlobalKey 平移过去，状态不丢。
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.animateIn || widget.leaving) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.leaving) {
          _leave();
        } else {
          springTo(_v, 1, reduceMotion: reduceMotionOf(context));
        }
      });
    }
  }

  void _leave() => springTo(
    _v,
    0,
    reduceMotion: reduceMotionOf(context),
  ).then((_) => widget.onGone());

  @override
  void didUpdateWidget(_PresenceItem old) {
    super.didUpdateWidget(old);
    if (widget.leaving && !old.leaving) _leave();
    if (!widget.leaving && old.leaving) {
      springTo(_v, 1, reduceMotion: reduceMotionOf(context));
    }
  }

  @override
  void dispose() {
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context);
    return AnimatedBuilder(
      animation: _v,
      child: KeyedSubtree(key: _childKey, child: widget.child),
      builder: (context, child) {
        final v = _v.value;
        // 静止时原样交出去，不留一层 Align / Opacity。
        if (v == 1) return child!;
        final t = v.clamp(0.0, 1.0);
        final scale = reduce ? 1.0 : (0.94 + 0.06 * v).clamp(0.85, 1.04);
        return ClipRect(
          child: Opacity(
            opacity: t,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// 一次性入场：挂上树时从无到有（行：高度展开 + 淡入；格：淡入 + 微缩放）。
/// [animateIn] 为 false 时直接就是终态——所以可以无条件包在每一项外面，
/// 只让「刚到」的那几条演，结构不会因此变来变去。
class PresenceIn extends StatefulWidget {
  const PresenceIn({
    super.key,
    required this.animateIn,
    this.expandHeight = true,
    required this.child,
  });

  final bool animateIn;

  /// 行要连高度一起展开；网格格子尺寸由网格定，只做淡入和缩放。
  final bool expandHeight;
  final Widget child;

  @override
  State<PresenceIn> createState() => _PresenceInState();
}

class _PresenceInState extends State<PresenceIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _v = AnimationController.unbounded(
    vsync: this,
    value: widget.animateIn ? 0 : 1,
  );

  /// 静止时把包装层撤掉（Opacity 即便是 1 也会多推一层合成），子树靠这把
  /// GlobalKey 平移过去，状态不丢。
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.animateIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) springTo(_v, 1, reduceMotion: reduceMotionOf(context));
      });
    }
  }

  @override
  void dispose() {
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = reduceMotionOf(context);
    return AnimatedBuilder(
      animation: _v,
      child: KeyedSubtree(key: _childKey, child: widget.child),
      builder: (context, child) {
        final v = _v.value;
        final t = v.clamp(0.0, 1.0);
        if (v == 1) return child!;
        final scale = reduce ? 1.0 : (0.94 + 0.06 * v).clamp(0.85, 1.04);
        Widget result = Transform.scale(scale: scale, child: child);
        if (widget.expandHeight) {
          result = ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: result,
            ),
          );
        }
        return Opacity(opacity: t, child: result);
      },
    );
  }
}

// =============================================================================
// 数字滚动
// =============================================================================

/// 数字逐位滚动（SwiftUI `.contentTransition(.numericText())` 的样子）：变大的
/// 往上滚、变小的往下滚，非数字字符直接换。字体须是等宽数字，否则逐位排开会
/// 和整串排版宽度不一样。
///
/// 位按「从右数第几位」配对：9% → 10% 时个位滚、十位新出现。
class RollingText extends StatefulWidget {
  const RollingText(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.countsDown = false,
  });

  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;

  /// 倒计时（剩余时间）：数值变小是正常走向，滚动方向反过来。
  final bool countsDown;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText> {
  int _dir = 1;

  static double _number(String s) =>
      double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  @override
  void didUpdateWidget(RollingText old) {
    super.didUpdateWidget(old);
    if (old.text == widget.text) return;
    _dir = _number(widget.text) >= _number(old.text) ? 1 : -1;
    if (widget.countsDown) _dir = -_dir;
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.text.characters.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < chars.length; i++)
          _RollingChar(
            key: ValueKey(chars.length - i),
            char: chars[i],
            dir: _dir,
            style: widget.style,
            strutStyle: widget.strutStyle,
          ),
      ],
    );
  }
}

class _RollingChar extends StatefulWidget {
  const _RollingChar({
    super.key,
    required this.char,
    required this.dir,
    this.style,
    this.strutStyle,
  });

  final String char;
  final int dir;
  final TextStyle? style;
  final StrutStyle? strutStyle;

  @override
  State<_RollingChar> createState() => _RollingCharState();
}

class _RollingCharState extends State<_RollingChar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );
  String? _previous;
  int _dir = 1;

  static final _digit = RegExp(r'\d');

  @override
  void didUpdateWidget(_RollingChar old) {
    super.didUpdateWidget(old);
    if (old.char == widget.char) return;
    final rolls =
        _digit.hasMatch(old.char) &&
        _digit.hasMatch(widget.char) &&
        !reduceMotionOf(context);
    if (!rolls) {
      _previous = null;
      _t.value = 1;
      return;
    }
    _previous = old.char;
    _dir = widget.dir;
    _t.value = 0;
    springTo(_t, 1, spring: IosSprings.digit);
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  Text _text(String s) =>
      Text(s, style: widget.style, strutStyle: widget.strutStyle);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final t = _t.value.clamp(0.0, 1.0);
        final previous = _previous;
        if (previous == null || t >= 1) return _text(widget.char);
        final h = (widget.style?.fontSize ?? 12) * 1.1;
        return ClipRect(
          child: Stack(
            children: [
              Transform.translate(
                offset: Offset(0, _dir * h * (1 - t)),
                child: Opacity(opacity: t, child: _text(widget.char)),
              ),
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, -_dir * h * t),
                  child: Opacity(opacity: 1 - t, child: _text(previous)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// 等待中
// =============================================================================

/// 排队等待：一小段弧匀速转（App Store 排队的样子），和「暂停」的静止圆环
/// 一眼分开。
class WaitingArc extends StatefulWidget {
  const WaitingArc({
    super.key,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 2.5,
  });

  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  State<WaitingArc> createState() => _WaitingArcState();
}

class _WaitingArcState extends State<WaitingArc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turns,
      child: CustomPaint(
        painter: _ArcPainter(
          color: widget.color,
          trackColor: widget.trackColor,
          strokeWidth: widget.strokeWidth,
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 0.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.color != color ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
