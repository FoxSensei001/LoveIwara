import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:oktoast/oktoast.dart' as ok;

/// # 液态玻璃轻提示（toast）
///
/// 全 App 唯一的「一句话反馈」出口：[showGlassToast]。页面不要再自己拼
/// `showToastWidget(Container(...))`，也不要为了一句「已复制」去开
/// `SnackBar`——那会同时出现两套形状/两套配色/两个出现位置。
///
/// 视觉沿用 `glass_surface.dart` 那套玻璃体（半透明底 + 细描边 + 柔和投影，
/// 无 BackdropFilter），只多做一件事：**按语义给整块玻璃上一层极淡的色染**，
/// 并在左侧放一枚同色图标钮。旧版 toast 是纯 `Colors.red.shade800` 这类饱和
/// 色块 + 白字，既不跟随主题种子色，深浅色模式下也长得一模一样，在玻璃化
/// 之后的界面里像是从另一个 App 贴过来的。
///
/// 三件事必须由这里统一，别在调用点各写各的：
/// - **位置**：默认 [GlassToastPosition.top]，落在 header 行下方（见 `_margin`）；
///   底部提示自动避开浮动底栏（[glassBottomBarObstruction]）。
/// - **时长**：按字数估算阅读时间（[_readingDuration]），一句「已复制」不必停
///   3 秒，一段带异常文本的报错也不该 2 秒就消失。
/// - **进出场**：淡入 + 轻微缩放 + 从所在边缘推入（[glassToastAnimationBuilder]），
///   与词汇表里其它玻璃形变同源；oktoast 默认只有 `Opacity`。
///
/// 同一时刻只留一条（`dismissOtherToast`）：oktoast 的多条 toast 是叠在同一
/// 个位置上的，连发两条会糊成一团。
enum GlassToastType { success, error, warning, info }

/// toast 停靠的位置。刻意不复用 oktoast 的 `ToastPosition`：调用点只描述
/// 「贴哪一边」，具体偏移量、安全区、避让底栏都由本文件负责。
enum GlassToastPosition { top, bottom, center }

/// 一条 toast 的默认进出场时长。
const Duration glassToastAnimationDuration = Duration(milliseconds: 240);

/// 展示一条轻提示。
///
/// [message] 为空串时直接忽略——上游常有 `error?.message ?? ''` 这种写法，
/// 弹一块空玻璃比不弹更莫名其妙。
///
/// 传了 [onAction] 才会让 toast 接收点击（oktoast 默认整块 toast 被
/// `IgnorePointer` 包着，不会挡住下面的内容）：
/// - 带 [actionLabel]：右侧出现一枚同色文字按钮（「查看下载列表」这类）；
/// - 只带 [actionIcon]：右侧是一枚指示图标，点击 toast 任意位置都触发。
void showGlassToast(
  String message, {
  GlassToastType type = GlassToastType.info,
  GlassToastPosition position = GlassToastPosition.top,
  Duration? duration,
  String? actionLabel,
  IconData? actionIcon,
  VoidCallback? onAction,
}) {
  if (message.trim().isEmpty) return;
  final bool interactive = onAction != null;
  ok.showToastWidget(
    GlassToastWidget(
      message: message,
      type: type,
      position: position,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      onAction: onAction,
    ),
    position: _toOkPosition(position),
    duration: duration ?? _readingDuration(message, interactive: interactive),
    handleTouch: interactive,
    dismissOtherToast: true,
    animationBuilder: glassToastAnimationBuilder(position),
    // 缓动全部放在 animationBuilder 里，这里保持线性，避免两处曲线叠加。
    animationCurve: Curves.linear,
    animationDuration: glassToastAnimationDuration,
  );
}

/// 立刻收起当前 toast（例如点了 toast 上的动作按钮之后）。
void dismissGlassToasts() => ok.dismissAllToast();

/// 玻璃 toast 的本体。
///
/// 一般不直接用，走 [showGlassToast]；单独暴露是为了让 OKToast 之外的宿主
/// （测试、预览页）也能渲染同一块玻璃。
class GlassToastWidget extends StatelessWidget {
  const GlassToastWidget({
    super.key,
    required this.message,
    this.type = GlassToastType.info,
    this.position,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String message;
  final GlassToastType type;

  /// 停靠位置，决定让出哪一侧的安全区。为 null 时从 oktoast 包在外层的
  /// `Align` 反推（见 [_resolvePosition]）。
  final GlassToastPosition? position;

  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final GlassToastPosition at = position ?? _resolvePosition(context);
    final Color accent = glassToastAccent(cs, type);
    final Color base = GlassTokens.fill(cs);

    // 玻璃体本身不变，只是被语义色轻轻染了一层：上浓下淡的竖向渐变让它看起来
    // 是「有厚度的一块」，而不是一张贴了背景色的纸。
    final BoxDecoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(accent.withValues(alpha: 0.14), base),
          Color.alphaBlend(accent.withValues(alpha: 0.05), base),
        ],
      ),
      borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
      border: Border.all(
        color: Color.alphaBlend(
          accent.withValues(alpha: 0.35),
          GlassTokens.stroke(cs),
        ),
        width: GlassTokens.strokeWidth,
      ),
      // ⛔ 不加 boxShadow：玻璃件一律不吐外投影，浮起来靠语义色染出的
      // 竖向渐变 + 描边（见 GlassTokens 里已删的 shadow token 注释）。
    );

    final Widget body = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TypeBadge(accent: accent, icon: _iconFor(type)),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 10),
          _ToastActionButton(
            label: actionLabel!,
            accent: accent,
            onPressed: () {
              dismissGlassToasts();
              onAction!.call();
            },
          ),
        ] else if (actionIcon != null) ...[
          const SizedBox(width: 8),
          Icon(actionIcon, size: 18, color: accent),
        ],
      ],
    );

    Widget toast = Container(
      constraints: BoxConstraints(
        maxWidth: _maxWidth(mq),
        minHeight: GlassTokens.pillHeight,
      ),
      padding: EdgeInsets.fromLTRB(8, 7, actionLabel != null ? 8 : 16, 7),
      decoration: decoration,
      child: body,
    );

    // 只有带动作的 toast 才可点（其余的 handleTouch=false，压根收不到事件）。
    if (onAction != null && actionLabel == null) {
      toast = GlassPressable(
        onTap: () {
          dismissGlassToasts();
          onAction!.call();
        },
        builder: (context, _) => toast,
      );
    }

    return Padding(
      padding: _margin(mq, at),
      child: Semantics(liveRegion: true, container: true, child: toast),
    );
  }

  double _maxWidth(MediaQueryData mq) =>
      math.max(240.0, math.min(mq.size.width - 32, 460.0));

  /// toast 挂在根 Overlay 上，拿不到页面那份被 Shell 改过的 MediaQuery，
  /// 安全区得自己算：
  /// - 顶部：状态栏 + 一个 header 行的高度，让它落在玻璃 header **下方**，
  ///   而不是盖住标题胶囊。没有 header 的页面只是显得稍微靠下一点。
  /// - 底部：系统手势条（[computeBottomSafeInset]，边到边模式下 padding.bottom
  ///   可能是 0）之上，再避开浮动底栏（[glassBottomBarObstruction]）。
  EdgeInsets _margin(MediaQueryData mq, GlassToastPosition at) {
    const double side = 16;
    switch (at) {
      case GlassToastPosition.top:
        return EdgeInsets.only(
          left: side,
          right: side,
          top:
              math.max(mq.padding.top, mq.viewPadding.top) +
              GlassTokens.headerRowHeight +
              8,
        );
      case GlassToastPosition.bottom:
        return EdgeInsets.only(
          left: side,
          right: side,
          // 安全区之上再留 32：oktoast 的 ToastPosition.bottom 原本自带 -30 的
          // 偏移，位置全部收归本文件自己算之后一度只剩 8，toast 直接贴到了手势
          // 条上——底部提示要浮在内容上方，不是压在屏幕边缘。
          bottom:
              math.max(computeBottomSafeInset(mq), glassBottomBarObstruction) +
              32,
        );
      case GlassToastPosition.center:
        return const EdgeInsets.symmetric(horizontal: side);
    }
  }

  /// oktoast 把内容包进 `Align(alignment: position.align)` 后才塞进 Overlay，
  /// 位置本身不会传给内容 widget。[showGlassToast] 总会显式传 [position]；
  /// 这里的反推只服务于「有人直接把 [GlassToastWidget] 交给
  /// `showToastWidget`」的情况，找不到就当作顶部。
  GlassToastPosition _resolvePosition(BuildContext context) {
    final Align? align = context.findAncestorWidgetOfExactType<Align>();
    final Alignment? resolved = align?.alignment.resolve(
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
    if (resolved == null) return GlassToastPosition.top;
    if (resolved.y <= -0.5) return GlassToastPosition.top;
    if (resolved.y >= 0.5) return GlassToastPosition.bottom;
    return GlassToastPosition.center;
  }
}

/// 左侧的语义图标钮：同色淡底 + 实心图标。
///
/// 语义色只出现在这一枚小圆钮和描边上，正文仍是 `onSurface`——整块染成
/// 高饱和红/绿会把一句提示变成一块警示牌，也读不出玻璃的通透。
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.16),
      ),
      child: Center(child: Icon(icon, size: 18, color: accent)),
    );
  }
}

/// toast 右侧的文字动作钮，形状与玻璃胶囊同族（圆角 + 同色淡底 + 按下缩放）。
class _ToastActionButton extends StatelessWidget {
  const _ToastActionButton({
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final String label;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPressable(
      onTap: onPressed,
      builder: (context, pressed) => AnimatedContainer(
        duration: GlassTokens.pressDuration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: pressed ? 0.28 : 0.16),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 语义色。
///
/// 成功 / 警告用固定色相，再用 [ColorHarmonization.harmonizeWith] 往当前主题
/// 的 primary 上拉一点——App 支持动态取色和自定义种子色，一枚死绿色在紫色
/// 主题里会很跳。报错和信息直接用配色方案里已经按明暗调过的 `error` /
/// `primary`。
Color glassToastAccent(ColorScheme cs, GlassToastType type) {
  final bool dark = cs.brightness == Brightness.dark;
  switch (type) {
    case GlassToastType.success:
      return (dark ? const Color(0xFF5CD68A) : const Color(0xFF1E7D42))
          .harmonizeWith(cs.primary);
    case GlassToastType.warning:
      return (dark ? const Color(0xFFF3B45E) : const Color(0xFF9A5B00))
          .harmonizeWith(cs.primary);
    case GlassToastType.error:
      return cs.error;
    case GlassToastType.info:
      return cs.primary;
  }
}

IconData _iconFor(GlassToastType type) {
  switch (type) {
    case GlassToastType.success:
      return Icons.check_circle_rounded;
    case GlassToastType.error:
      return Icons.error_rounded;
    case GlassToastType.warning:
      return Icons.warning_rounded;
    case GlassToastType.info:
      return Icons.info_rounded;
  }
}

/// 进出场：淡入 + 从 0.94 放大到 1 + 从所在边缘推入 14px。
///
/// 出场是同一段动画倒放（oktoast 用同一个 controller 回到 0），所以不需要
/// 单独写一套收起动效。[position] 决定推入方向：顶部的从上方压下来，底部的
/// 从下方顶上去，居中的只做缩放。
ok.OKToastAnimationBuilder glassToastAnimationBuilder(
  GlassToastPosition position,
) {
  final double dy = switch (position) {
    GlassToastPosition.top => -14,
    GlassToastPosition.bottom => 14,
    GlassToastPosition.center => 0,
  };
  return (context, child, controller, percent) =>
      _buildGlassToastAnimation(child, percent, dy);
}

/// OKToast 根部的兜底动效（不带方向），给没走 [showGlassToast] 的调用用。
Widget glassToastRootAnimationBuilder(
  BuildContext context,
  Widget child,
  AnimationController controller,
  double percent,
) => _buildGlassToastAnimation(child, percent, 0);

Widget _buildGlassToastAnimation(Widget child, double percent, double dy) {
  final double t = Curves.easeOutCubic.transform(percent.clamp(0.0, 1.0));
  return Opacity(
    opacity: t,
    child: Transform.translate(
      offset: Offset(0, dy * (1 - t)),
      child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
    ),
  );
}

ok.ToastPosition _toOkPosition(GlassToastPosition position) {
  // offset 一律为 0：与边缘的距离全部由 GlassToastWidget 自己的 margin 决定，
  // 否则安全区要在两个地方各算一半。
  switch (position) {
    case GlassToastPosition.top:
      return const ok.ToastPosition(align: Alignment.topCenter);
    case GlassToastPosition.bottom:
      return const ok.ToastPosition(align: Alignment.bottomCenter);
    case GlassToastPosition.center:
      return const ok.ToastPosition();
  }
}

/// 按字数估算停留时间。
///
/// 固定 2.3 秒对「已复制」太长、对一整段异常信息又根本读不完。带动作按钮的
/// toast 还要留出「看见 → 决定 → 抬手去点」的时间，所以起步更长。
Duration _readingDuration(String message, {required bool interactive}) {
  final int base = interactive ? 4200 : 2000;
  final int ms = base + message.runes.length * 45;
  return Duration(milliseconds: math.min(ms, interactive ? 7000 : 5000));
}
