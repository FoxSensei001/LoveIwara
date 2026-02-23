import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 统一的返回键协调器。
/// 用一个基于优先级的返回链替代 AppService.tryPop()：
///   1. 全局 Drawer 打开时 → 先关闭 Drawer
///   2. 有遮罩层（对话框 / BottomSheet 等）→ 关闭最顶部遮罩层
///   3. SettingsPage 内部导航栈可返回 → 先做内部返回
///   4a. 根 GoRouter 路由可返回 → 优先弹出（全屏页等顶层包装）
///   4b. Shell Navigator 可返回 → 弹出 Shell 内部详情页
///   4c. GoRouter 还能返回 → 弹出其他根级路由
///   5. 都不能返回 → 退出应用
class PopCoordinator {
  PopCoordinator._();

  static ChildBackButtonDispatcher? _backDispatcher;

  /// 初始化系统返回键拦截。
  /// 必须在 [appRouter] 可用后调用一次（例如在 MyApp.initState 中）。
  ///
  /// 将一个 [ChildBackButtonDispatcher] 挂载到 GoRouter 的
  /// [RootBackButtonDispatcher] 上。子 dispatcher 会在自身回调 **之前**
  /// 先被检查，这样我们关闭遮罩层/抽屉的逻辑会先于 GoRouter 的路由弹出逻辑执行。
  static void init() {
    if (_backDispatcher != null) return; // already initialized
    _backDispatcher = ChildBackButtonDispatcher(appRouter.backButtonDispatcher);
    _backDispatcher!.addCallback(_handleSystemBack);
    // Defer takePriority() until after the first frame, because the Router
    // widget registers its callback on the BackButtonDispatcher during build.
    // Calling takePriority() before that triggers an assertion failure.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backDispatcher?.takePriority();
    });
  }

  /// 在路由切换之后重新确认 ChildBackButtonDispatcher 的优先级。
  /// 某些根级路由切换（例如全屏页面的 push/pop）可能会临时抢走这个协调器的优先级。
  static void ensureDispatcherPriority(String reason) {
    final dispatcher = _backDispatcher;
    if (dispatcher == null) return;
    dispatcher.takePriority();
    LogUtils.d('ensureDispatcherPriority: reason=$reason', 'PopCoordinator');
  }

  /// 系统返回键的回调，在 GoRouter 处理之前触发。
  static Future<bool> _handleSystemBack() async {
    final consumed = tryCloseOverlayOrDrawer();
    LogUtils.d(
      '系统返回键：已消费=$consumed, overlayCount=${OverlayTracker.instance.overlayCount}, '
          'rootCanPop=${rootNavigatorKey.currentState?.canPop() ?? false}, '
          'shellCanPop=${shellNavigatorKey.currentState?.canPop() ?? false}',
      'PopCoordinator',
    );
    return consumed;
  }

  /// ESC/返回键是否应该显示“再按一次退出”的二次确认。
  /// 仅在真正的首页根路由上为 true（没有遮罩层、也没有内部可弹出的栈）。
  static bool shouldConfirmExitAtHomeRoot() {
    final scaffoldState = AppService.globalDrawerKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) return false;
    if (OverlayTracker.instance.hasOverlay) return false;
    if (SettingsPage.canPopInternally()) return false;

    final shellNav = shellNavigatorKey.currentState;
    if (shellNav != null && shellNav.canPop()) return false;

    return !appRouter.canPop();
  }

  /// 按照优先级链执行一次返回动作。
  static void handleBack(BuildContext context) {
    LogUtils.d(
      'handleBack 开始：overlayCount=${OverlayTracker.instance.overlayCount}, '
          'rootCanPop=${rootNavigatorKey.currentState?.canPop() ?? false}, '
          'shellCanPop=${shellNavigatorKey.currentState?.canPop() ?? false}',
      'PopCoordinator',
    );

    // 1. 如果全局 Drawer 打开，优先关闭
    final scaffoldState = AppService.globalDrawerKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState!.closeDrawer();
      LogUtils.d('handleBack -> 关闭全局 Drawer', 'PopCoordinator');
      return;
    }

    // 2. 关闭遮罩层（对话框 / BottomSheet 等）
    if (_tryPopOverlayRoute(context: context)) {
      LogUtils.d('handleBack -> 关闭遮罩层', 'PopCoordinator');
      return;
    }

    // 3. SettingsPage 内部导航返回
    if (SettingsPage.canPopInternally()) {
      SettingsPage.popInternally();
      LogUtils.d('handleBack -> SettingsPage 内部返回', 'PopCoordinator');
      return;
    }

    final rootNav = rootNavigatorKey.currentState;
    final shellNav = shellNavigatorKey.currentState;

    // 4a. 当 root & shell 都可以返回时，优先弹出根路由。
    // 这样可以避免在有顶层全屏页（例如全屏播放器）覆盖 shell 时，错误地关闭 shell 里的详情页。
    if (rootNav != null && rootNav.canPop()) {
      // 使用 maybePop，以尊重 PopScope/WillPopScope（例如页内全屏的拦截）。
      unawaited(rootNav.maybePop());
      LogUtils.d('handleBack -> 根 Navigator maybePop', 'PopCoordinator');
      return;
    }

    // 4b. Shell Navigator 可返回（Shell 内部推入的详情页）
    if (shellNav != null && shellNav.canPop()) {
      // 使用 maybePop，以尊重 PopScope/WillPopScope（例如页内全屏的拦截）。
      unawaited(shellNav.maybePop());
      LogUtils.d('handleBack -> Shell Navigator maybePop', 'PopCoordinator');
      return;
    }

    // 4c. GoRouter 还能 pop（根级全屏页等）
    if (appRouter.canPop()) {
      appRouter.pop();
      LogUtils.d('handleBack -> GoRouter pop', 'PopCoordinator');
      return;
    }

    // 5. 已经没有可弹出的页面 → 退出应用
    LogUtils.d('handleBack -> 触发 SystemNavigator.pop 退出应用', 'PopCoordinator');
    SystemNavigator.pop();
  }

  /// 检查在走 GoRouter 默认返回逻辑之前，是否有需要先关闭的遮罩层或 Drawer。
  /// 如果关闭了遮罩层/Drawer（即消费了返回事件）则返回 true。
  static bool tryCloseOverlayOrDrawer() {
    // 1. 如果全局 Drawer 打开，优先关闭
    final scaffoldState = AppService.globalDrawerKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState!.closeDrawer();
      LogUtils.d('tryCloseOverlayOrDrawer -> 关闭全局 Drawer', 'PopCoordinator');
      return true;
    }

    // 2. 关闭挂在根 Navigator 上的遮罩层（对话框 / BottomSheet 等）
    if (_tryPopOverlayRoute(context: rootNavigatorKey.currentContext)) {
      LogUtils.d('tryCloseOverlayOrDrawer -> 关闭遮罩层', 'PopCoordinator');
      return true;
    }

    // 3. SettingsPage 内部导航返回
    if (SettingsPage.canPopInternally()) {
      SettingsPage.popInternally();
      LogUtils.d(
        'tryCloseOverlayOrDrawer -> SettingsPage 内部返回',
        'PopCoordinator',
      );
      return true;
    }

    return false;
  }

  /// 在正常页面 pop 之前，尝试优先关闭最顶部的遮罩路由。
  static bool _tryPopOverlayRoute({BuildContext? context}) {
    if (_tryPopFocusedPopupRoute()) {
      return true;
    }

    final rootNav = rootNavigatorKey.currentState;
    if (_tryPopPopupRoute(rootNav)) {
      return true;
    }

    // Some popup routes can be mounted on Shell navigator.
    final shellNav = shellNavigatorKey.currentState;
    if (_tryPopPopupRoute(shellNav)) {
      return true;
    }

    // 兜底：OverlayTracker 认为有遮罩层，但无法可靠判断顶部路由的类型时，
    // 尝试对根 Navigator 做一次 pop。
    if (OverlayTracker.instance.hasOverlay && _tryPopNavigator(rootNav)) {
      return true;
    }

    // 基于 context 的兜底（适用于弹窗挂在内部 Navigator 上的情况）
    if (context != null) {
      final contextNav = Navigator.maybeOf(context);
      if (OverlayTracker.instance.hasOverlay && _tryPopNavigator(contextNav)) {
        return true;
      }
    }

    return false;
  }

  static bool _tryPopFocusedPopupRoute() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null) {
      return false;
    }

    final focusedRoute = ModalRoute.of(focusedContext);
    if (focusedRoute is! PopupRoute) {
      return false;
    }

    final focusedNav = Navigator.maybeOf(focusedContext);
    if (_tryPopNavigator(focusedNav)) {
      LogUtils.d(
        '关闭当前焦点的 PopupRoute：${focusedRoute.runtimeType}',
        'PopCoordinator',
      );
      return true;
    }

    final focusedRootNav = Navigator.maybeOf(
      focusedContext,
      rootNavigator: true,
    );
    if (_tryPopNavigator(focusedRootNav)) {
      LogUtils.d(
        '在根 Navigator 上关闭当前焦点的 PopupRoute：${focusedRoute.runtimeType}',
        'PopCoordinator',
      );
      return true;
    }

    return false;
  }

  static bool _tryPopPopupRoute(NavigatorState? navigator) {
    if (navigator == null || !navigator.canPop()) {
      return false;
    }

    final topRoute = _peekTopRoute(navigator);
    if (topRoute is PopupRoute) {
      navigator.pop();
      return true;
    }

    return false;
  }

  static Route<dynamic>? _peekTopRoute(NavigatorState navigator) {
    Route<dynamic>? topRoute;
    navigator.popUntil((route) {
      topRoute = route;
      return true;
    });
    return topRoute;
  }

  static bool _tryPopNavigator(NavigatorState? navigator) {
    if (navigator == null || !navigator.canPop()) {
      return false;
    }
    navigator.pop();
    return true;
  }
}
