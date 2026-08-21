import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';

/// Get.dialog() 的直接替代实现。
/// 使用全局 root navigator key 的 context 来展示对话框。
///
/// 与 `showDialog` 的差别只在出入场动画：这里走 [GlassDialogRoute]，
/// 宽屏居中卡片淡入 + 轻微放大、窄屏整页淡入 + 自下而上位移，
/// 而不是 Material 默认那条 150ms 纯淡入（整页弹窗上等于硬切）。
/// 其余行为（安全区、遮罩、主题继承、返回值）与 `showDialog` 保持一致。
Future<T?> showAppDialog<T>(
  Widget dialog, {
  BuildContext? dialogContext,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  GlassDialogMotion motion = GlassDialogMotion.auto,
}) {
  final context = dialogContext ?? rootNavigatorKey.currentContext;
  if (context == null) {
    return Future.value(null);
  }

  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  // 弹窗路由挂在（root）Navigator 下，与调用方不共享子树；显式把调用处的
  // 主题类 InheritedWidget 带过去，行为对齐 showDialog。
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final dismissLabel =
      barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel;

  return navigator.push<T>(
    GlassDialogRoute<T>(
      motion: motion,
      barrierDismissible: barrierDismissible,
      barrierColor:
          barrierColor ??
          Theme.of(context).dialogTheme.barrierColor ??
          Colors.black54,
      barrierLabel: dismissLabel,
      settings: routeSettings,
      pageBuilder: (_, _, _) {
        final wrapped = themes.wrap(dialog);
        return useSafeArea ? SafeArea(child: wrapped) : wrapped;
      },
    ),
  );
}

/// Get.bottomSheet() 的直接替代实现。
/// 使用全局 root navigator key 的 context 来展示底部弹窗（BottomSheet）。
Future<T?> showAppBottomSheet<T>(
  Widget sheet, {
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  bool isScrollControlled = false,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return Future.value(null);
  }
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: backgroundColor ?? Colors.transparent,
    elevation: elevation,
    shape: shape,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (_) => sheet,
  );
}
