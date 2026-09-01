import 'dart:math' as math;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:toastification/toastification.dart';

/// # 应用轻提示（toast）
///
/// 全 App 唯一的「一句话反馈」出口：[showAppToast]。页面不要再自己拼
/// `Overlay` / `showToastWidget(Container(...))`，也不要为了一句「已复制」去开
/// `SnackBar`——那会同时出现两套形状、两套配色、两个出现位置。
///
/// ## 为什么是 Material 而不是玻璃
///
/// 提示是**系统在说话**，不是页面的一部分：它压在所有路由之上、和当前页面没有
/// 层级关系，做成半透明玻璃反而会和底下的内容糊在一起、读不清字。所以这一层
/// 刻意退回 Material 3 的「浮起卡片」语义——`surfaceContainerHigh` 的实心底、
/// `outlineVariant` 的细描边、一层很浅的投影，语义色只出现在左侧那枚图标上。
/// 其余玻璃件（header / 底栏 / 菜单 / 弹窗）不受影响。
///
/// ## 三件事必须由这里统一，别在调用点各写各的
///
/// - **位置**：默认 [AppToastPosition.top]，落在 header 行下方（见
///   [_appToastMargin]）；底部提示自动避开浮动底栏（[glassBottomBarObstruction]）。
/// - **时长**：按字数估算阅读时间（[_readingDuration]），一句「已复制」不必停
///   3 秒，一段带异常文本的报错也不该 2 秒就消失。
/// - **进出场**：交给 toastification 的默认转场（沿所在边缘滑入 + 淡入），
///   连带把「多条堆叠、横向滑走关掉、鼠标悬停暂停计时」一起接管。
///
/// 宿主是 [AppToastHost]，挂在 `MaterialApp.builder` 里（见 `my_app.dart`）。
enum AppToastType { success, error, warning, info }

/// toast 停靠的位置。调用点只描述「贴哪一边」，具体偏移量、安全区、避让底栏
/// 都由本文件负责。
enum AppToastPosition { top, bottom, center }

/// 一条 toast 的进出场时长。
///
/// toastification 默认 600ms 对一条轻提示太拖沓；这里按 Material 的
/// `medium2` 量级收到 300ms。
const Duration appToastAnimationDuration = Duration(milliseconds: 300);

/// 同屏最多堆几条。超过后最早的那条会被挤掉。
const int appToastMaxVisible = 3;

/// 展示一条轻提示。
///
/// [message] 为空串时直接忽略——上游常有 `error?.message ?? ''` 这种写法，
/// 弹一块空卡片比不弹更莫名其妙。
///
/// 传了 [onAction] 才会让 toast 接收点击：
/// - 带 [actionLabel]：右侧出现一枚文字按钮（「查看下载列表」这类），只有按钮
///   本身可点；
/// - 只带 [actionIcon]：右侧是一枚指示图标，点击 toast 任意位置都触发。
void showAppToast(
  String message, {
  AppToastType type = AppToastType.info,
  AppToastPosition position = AppToastPosition.top,
  Duration? duration,
  String? actionLabel,
  IconData? actionIcon,
  VoidCallback? onAction,
}) {
  if (message.trim().isEmpty) return;
  final bool interactive = onAction != null;
  toastification.showCustom(
    alignment: _alignmentOf(position),
    animationDuration: appToastAnimationDuration,
    autoCloseDuration:
        duration ?? _readingDuration(message, interactive: interactive),
    builder: (context, item) => AppToastWidget(
      item: item,
      message: message,
      type: type,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      onAction: onAction,
    ),
  );
}

/// 立刻收起所有 toast（例如点了 toast 上的动作按钮之后）。
void dismissAppToasts() => toastification.dismissAll(delayForAnimation: false);

/// toast 的宿主，必须挂在 `MaterialApp` **内部**。
///
/// toastification 把提示插进它往下找到的第一个 `Navigator` 的 Overlay，也就是
/// 根导航器的 Overlay——于是 toast 恒在所有路由、弹窗、抽屉之上，同时又能拿到
/// 真实的 `Theme` / `MediaQuery`（放到 `MaterialApp` 外面时 `Theme.of` 只能拿到
/// Flutter 的 fallback 主题，深色模式下整块提示会是一片亮白）。
///
/// ⚠️ 「所有路由之上」不含 `MyAppLayout` 里和整棵路由树做兄弟的那几层
/// （应用锁 / 隐私遮罩 / 桌面拖放提示）——它们在 Stack 上排在根 Navigator
/// **后面**，因此盖得住 toast。这是想要的：锁屏亮着的时候不该有提示漏出来。
class AppToastHost extends StatelessWidget {
  const AppToastHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(config: _appToastConfig, child: child);
  }
}

const ToastificationConfig _appToastConfig = ToastificationConfig(
  alignment: Alignment.topCenter,
  // itemWidth 会被父级约束夹住（`BoxConstraints.tightFor` 走的是 `enforce`），
  // 所以窄屏上它就是「撑满减去左右边距」，宽屏上停在 460。
  itemWidth: 460,
  animationDuration: appToastAnimationDuration,
  marginBuilder: _appToastMargin,
  maxToastLimit: appToastMaxVisible,
  // 报错文案常常是一整段异常信息，2 行截断读不出发生了什么。
  maxTitleLines: 4,
);

/// toast 整体的外边距。
///
/// toastification 会在这份边距之上再叠一份 `viewPadding`（状态栏 / 手势条）与
/// 键盘的 `viewInsets`，所以这里只负责「安全区之外还要再让多少」：
/// - 顶部：一个 header 行的高度，让提示落在玻璃 header **下方**而不是盖住标题
///   胶囊。没有 header 的页面只是显得稍微靠下一点。
/// - 底部：避开浮动底栏（[glassBottomBarObstruction] 自身已含底部安全区，所以
///   要把已经叠过的那份减掉，否则安全区被算两遍）。
EdgeInsetsGeometry _appToastMargin(
  BuildContext context,
  AlignmentGeometry alignment,
) {
  const double side = 12;
  final double y = alignment.resolve(Directionality.of(context)).y;
  if (y <= -0.5) {
    return const EdgeInsets.fromLTRB(
      side,
      GlassTokens.headerRowHeight + 8,
      side,
      0,
    );
  }
  if (y >= 0.5) {
    final double safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final double bar = math.max(0, glassBottomBarObstruction - safeBottom);
    return EdgeInsets.fromLTRB(side, 0, side, bar + 16);
  }
  return const EdgeInsets.symmetric(horizontal: side);
}

Alignment _alignmentOf(AppToastPosition position) {
  switch (position) {
    case AppToastPosition.top:
      return Alignment.topCenter;
    case AppToastPosition.bottom:
      return Alignment.bottomCenter;
    case AppToastPosition.center:
      return Alignment.center;
  }
}

/// 一条 toast 的本体。
///
/// 视觉直接用 toastification 的 [ToastificationStyle.flat]（中性底 + 语义色图标
/// 的 Material 卡片），只是把配色换成当前 `ColorScheme` 的值——包里那套
/// 硬编码的白底 / `#EBEBEB` 描边在深色模式下会亮瞎眼，也不跟随动态取色。
///
/// 一般不直接用，走 [showAppToast]；单独暴露是给测试和预览页渲染同一块卡片。
class AppToastWidget extends StatelessWidget {
  const AppToastWidget({
    super.key,
    required this.item,
    required this.message,
    this.type = AppToastType.info,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final ToastificationItem item;
  final String message;
  final AppToastType type;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// 整块可点：只带图标（没有独立按钮）的动作型提示才走这条，否则点击面积会和
  /// 「滑走关掉」抢手势。
  bool get _tapAnywhere => onAction != null && actionLabel == null;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color accent = appToastAccent(cs, type);

    return BuiltInContainer(
      item: item,
      // 堆叠时两条之间的呼吸；左右边距由 marginBuilder 统一给。
      margin: const EdgeInsets.symmetric(vertical: 5),
      closeOnClick: _tapAnywhere,
      pauseOnHover: true,
      dragToClose: true,
      dismissDirection: DismissDirection.horizontal,
      onHoverMouseCursor: _tapAnywhere ? SystemMouseCursors.click : null,
      callbacks: ToastificationCallbacks(
        onTap: _tapAnywhere ? (_) => onAction!.call() : null,
      ),
      child: BuiltInToastBuilder(
        item: item,
        type: ToastificationType.custom(type.name, accent, _iconFor(type)),
        style: ToastificationStyle.flat,
        direction: Directionality.of(context),
        title: Text(message),
        primaryColor: accent,
        backgroundColor: cs.surfaceContainerHigh,
        foregroundColor: cs.onSurface,
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
        // 包里默认 minHeight 64 是给「标题 + 正文」两行卡片的，一句话提示会显得
        // 中间空一大块。
        constraints: const BoxConstraints(minHeight: 52),
        showIcon: true,
        showProgressBar: false,
        closeButton: _closeButton(accent),
        onCloseTap: () => toastification.dismiss(item),
      ),
    );
  }

  /// 右侧那个槽位。三种可能：
  /// - 文字动作钮（[actionLabel]）：一直显示，只有它自己可点；
  /// - 指示图标（[actionIcon]）：一直显示，点击交给整块 toast；
  /// - 什么都没有：桌面端悬停时露出关闭「×」，触摸端不占位（触摸端靠自动消失
  ///   或横向滑走）。
  ToastCloseButton _closeButton(Color accent) {
    if (actionLabel != null && onAction != null) {
      return ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, _) => _trailingSlot(
          _ToastActionButton(
            label: actionLabel!,
            accent: accent,
            onPressed: () {
              toastification.dismiss(item);
              onAction!.call();
            },
          ),
        ),
      );
    }
    if (actionIcon != null) {
      return ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, _) => _trailingSlot(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(actionIcon, size: 18, color: accent),
          ),
        ),
      );
    }
    return const ToastCloseButton(showType: CloseButtonShowType.onHover);
  }

  /// ⛔ 右侧槽位里的东西必须自己撑满高度再居中，不能直接放一个比槽位矮的 widget。
  ///
  /// 包里那个槽位（`ToastCloseButtonHolder`）是 `SizedBox(height: 30)` 套一层
  /// `AnimatedSwitcher`，而它的 transitionBuilder 里有
  /// `SizeTransition(axis: Axis.horizontal, axisAlignment: 1)`——横向的
  /// `SizeTransition` 内部是 `Align(alignment: AlignmentDirectional(1, -1))`，
  /// 只设了 `widthFactor` 没设 `heightFactor`，于是**竖直方向恒为顶端对齐**。
  /// 包自带的关闭钮正好是 30×30 填满槽位，所以从没暴露过；我们这枚 15 高的
  /// 文字钮直接被顶到卡片上沿（实测偏上 8.5px）。
  ///
  /// [Align] 不给 heightFactor 就会撑满传进来的高度，再把孩子居中。
  Widget _trailingSlot(Widget child) =>
      Align(alignment: Alignment.center, widthFactor: 1, child: child);
}

/// toast 右侧的文字动作钮。
///
/// 用 [TextButton] 而不是自绘：这是 Material 里「通知卡片上的动作」的标准形状，
/// 涟漪、按压态、无障碍语义都免费。外层槽位高 30，所以要把默认的 40 高、
/// 64 最小宽压掉。
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: accent,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// 语义色。
///
/// 成功 / 警告用固定色相，再用 [ColorHarmonization.harmonizeWith] 往当前主题的
/// primary 上拉一点——App 支持动态取色和自定义种子色，一枚死绿色在紫色主题里
/// 会很跳。报错和信息直接用配色方案里已经按明暗调过的 `error` / `primary`。
Color appToastAccent(ColorScheme cs, AppToastType type) {
  final bool dark = cs.brightness == Brightness.dark;
  switch (type) {
    case AppToastType.success:
      return (dark ? const Color(0xFF5CD68A) : const Color(0xFF1E7D42))
          .harmonizeWith(cs.primary);
    case AppToastType.warning:
      return (dark ? const Color(0xFFF3B45E) : const Color(0xFF9A5B00))
          .harmonizeWith(cs.primary);
    case AppToastType.error:
      return cs.error;
    case AppToastType.info:
      return cs.primary;
  }
}

IconData _iconFor(AppToastType type) {
  switch (type) {
    case AppToastType.success:
      return Icons.check_circle_rounded;
    case AppToastType.error:
      return Icons.error_rounded;
    case AppToastType.warning:
      return Icons.warning_rounded;
    case AppToastType.info:
      return Icons.info_rounded;
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
