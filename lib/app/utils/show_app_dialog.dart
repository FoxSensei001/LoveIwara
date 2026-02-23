import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';

/// Get.dialog() 的直接替代实现。
/// 使用全局 root navigator key 的 context 来展示对话框。
Future<T?> showAppDialog<T>(
  Widget dialog, {
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) {
    return Future.value(null);
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (_) => dialog,
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
