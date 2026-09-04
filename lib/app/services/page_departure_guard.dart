import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:i_iwara/app/routes/app_router.dart' show rootNavigatorKey;
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 「用户被带去了别的页面」——这件事该收的尾，全在这里。
///
/// # 为什么要有它
///
/// 浮在页面之上的那些临时层（侧边抽屉、弹窗、预览弹窗、菜单）几乎都挂在 **root**
/// Navigator 上，而绝大多数页面推的是 **shell** Navigator。两者是父子关系，所以
/// 一次 shell 跳页**不会动到任何一层临时层**——它们原样浮在刚推进来的新页上面，
/// 背景却已经换了人。
///
/// 触发它的不只是我们自己写的跳转。提示条上那些动作钮就够了：
/// 「已加入稍后再看 · 查看稍后再看列表」「下载已开始 · 查看下载列表」——按一下就
/// 推一页 shell 路由，而按钮所在的 toast 是从预览弹窗里发出来的。2026-09-04 用户
/// 报障的就是这一幕：跳过去之后**预览弹窗还盖在最顶层、「接着看」抽屉还开着、
/// 视频还在播**，弹窗背面换成了另一个页面。
///
/// 这类缺陷**不该一个入口一个入口地修**：今天是这两条 toast，明天新加一条动作钮
/// 就又漏一个。所有跳页最终都会在某个 Navigator 上落一次 `didPush`，所以监控挂在
/// 那里——路由是这件事唯一的收口点。见到真页面路由就做三件事：
///
///   1. **收掉浮着的临时层**（[TransientPageRoute] 与 `PopupRoute`）；
///   2. **交还全屏**：否则桌面端留下一个铺满显示器、藏掉标题栏和侧边导航、拖不动
///      的窗口，移动端留下一张锁在横屏里的页面；
///   3. **让被盖住的播放页收尾**（暂停 / 复位亮度）。
///
/// # ⛔ 第 3 件为什么要由这里补
///
/// 播放页自己有 `didPushNext`，可它有两个够不着的角落：
///
///   - 那道 `OverlayTracker.hasOverlay` 闸门数的是**全局**弹层数，分不清「浮在我
///     上面的抽屉」和「盖住我的新页面」——抽屉开着时它恒真，收尾整只被跳过；
///   - `routeObserver` 只挂在 shell 上，**root 上的页面 push**（登录页、首启页）
///     那边根本不会响。
///
/// 所以本监控在 [_guard] 里判一次「这一次 push 播放页自己收不收得到」，收不到的
/// 才补发，避免同一件事做两遍（[PageDepartureAware] 那侧照样要求幂等）。
///
/// # ⛔ 判据在 didPush 那一刻就定死，不能推迟到回调里再问
///
/// 「全屏连播换片」是一次**故意保住全屏**的跳转：旧页在 `pushReplacement` 之前
/// 就调了 `relinquishFullscreenForRouteHandoff()`（`isFullscreen` 已置 false），
/// 新页随后接手。所以 push 那一刻没有任何演出者自称在全屏里，本监控天然不插手。
///
/// 但真正的动手必须推迟到本帧之后（退全屏会写一串 Rx、pop 会改另一棵 Navigator 的
/// 状态，而 go_router 的路由变更跑在 `didUpdateWidget` 里，也就是 build 期间）。
/// 推迟之后**新页的 controller 可能已经登记、强制全屏可能已经生效**，那时再问一遍
/// 「谁在场」就会把刚接手的新页一起退掉、一起暂停。所以名单在 [_guard] 里同步
/// 拍下来，回调只执行。
///
/// # 不管「应用全屏」
///
/// 桌面端的 `isDesktopAppFullScreen` 只藏侧边导航、保留标题栏，收尾那一步里会把
/// 系统 UI 放回来。它不会把人锁在一个出不去的窗口里，不在交还全屏的范围内。
class PageDepartureGuard extends NavigatorObserver {
  PageDepartureGuard._(this.scope);

  /// 一个 [NavigatorObserver] 实例只能挂在一个 Navigator 上，所以按 root /
  /// shell 各给一只，登记表是静态的、两只共用（与 `OverlayTracker` 同一套做法）。
  ///
  /// 两边都要挂：详情页、作者页、标签页、下载页在 shell 里，登录页与首启页在
  /// root 上。
  static final PageDepartureGuard root = PageDepartureGuard._('root');
  static final PageDepartureGuard shell = PageDepartureGuard._('shell');

  final String scope;

  static final Set<PageDepartureAware> _pages = <PageDepartureAware>{};

  /// 登记一个「会被别的页面盖住」的页面（播放页 controller）。幂等。
  static void attach(PageDepartureAware page) => _pages.add(page);

  static void detach(PageDepartureAware page) => _pages.remove(page);

  /// 立刻收尾：临时层让开 + 交还全屏 + 播放页暂停。**幂等**，没什么好收的就
  /// 什么都不做。
  ///
  /// 已经知道下一步一定要跳页的调用点可以显式用它——那样临时层是在跳转**之前**
  /// 让开的，不会有「新页已经画出来、弹窗还盖着」的那一帧。见
  /// `media_preview_dialog.dart`。此时暂停留给紧接着那次 push 上的
  /// `didPushNext`（临时层已经让开，那道闸门不会再挡），所以不重复发。
  static Future<void> departForNavigation({required String reason}) =>
      _depart(_pages.toList(growable: false), reason, notifyCovered: false);

  static Future<void> _depart(
    List<PageDepartureAware> pages,
    String reason, {
    required bool notifyCovered,
  }) async {
    dismissTransientOverlays();

    for (final page in pages.where((page) => page.isPresentingFullscreen)) {
      try {
        await page.releaseFullscreen();
      } catch (e, s) {
        LogUtils.e(
          '交还全屏失败: $reason',
          tag: 'PageDepartureGuard',
          error: e,
          stackTrace: s,
        );
      }
    }

    if (!notifyCovered) return;
    for (final page in pages) {
      try {
        page.onCoveredByAnotherPage();
      } catch (e, s) {
        LogUtils.e(
          '页面覆盖收尾失败: $reason',
          tag: 'PageDepartureGuard',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  /// 把 root Navigator 顶上那些临时层依次收掉。返回**有没有真的收掉东西**。
  ///
  /// 只收顶上连着的那一段：底下压着真页面路由（登录页这类 root 级页面）时就停手
  /// ——它们已经把临时层盖住了，硬 pop 反而会在返回时留下一个空荡荡的栈。
  static bool dismissTransientOverlays() {
    final NavigatorState? navigator = rootNavigatorKey.currentState;
    if (navigator == null) return false;
    bool dismissed = false;
    navigator.popUntil((route) {
      if (!_isTransientOverlay(route)) return true;
      dismissed = true;
      return false;
    });
    if (dismissed) LogUtils.d('跳页前收掉浮着的临时层', 'PageDepartureGuard');
    return dismissed;
  }

  /// 这条路由算不算「把用户带去了别的页面」。
  ///
  /// - 弹窗 / 菜单 / 底部弹层 / 侧边抽屉都是 `PopupRoute`（不是 `PageRoute`），
  ///   它们浮在当前页上，不算离开；
  /// - [TransientPageRoute] 是那种**身份上是页面路由、语义上是弹层**的例外
  ///   （预览弹窗要 `PageRoute` 才飞得动 Hero），同样不算。
  static bool _isLeavingPage(Route<dynamic> route) {
    if (route is! PageRoute) return false;
    if (route is TransientPageRoute) return false;
    return true;
  }

  /// 这条路由是不是「浮在页面之上的临时层」——跳页时该跟着让开的那一类。
  static bool _isTransientOverlay(Route<dynamic> route) =>
      route is PopupRoute || route is TransientPageRoute;

  void _guard(Route<dynamic>? route) {
    if (route == null || !_isLeavingPage(route)) return;
    // ⛔ 名单在这里拍下来，见类注释。
    final pages = _pages.toList(growable: false);
    final String reason =
        '$scope push ${route.settings.name ?? route.runtimeType}';
    // 这一次 push，播放页自己的 `didPushNext` 收不收得到？
    //
    //   - **root 上的 push**（登录页、首启页）：`routeObserver` 挂在 shell 上，
    //     那边根本不会响；
    //   - **shell 上的 push 但此刻有弹层浮着**：`didPushNext` 开头那道
    //     `OverlayTracker.hasOverlay` 闸门会把它整只挡掉。
    //
    // 这两种情形下的收尾由本监控补发；其余交给 `didPushNext`，别发两遍。
    final bool handledByPage =
        scope == 'shell' && !OverlayTracker.instance.hasOverlay;
    // pop 别的 Navigator、退全屏写一串 Rx——两件都不能跑在路由提交的同步窗口里
    // （go_router 的路由变更就发生在 build 期间）。push 一定会带来下一帧，
    // post-frame 回调不会悬着。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_depart(pages, reason, notifyCovered: !handledByPage));
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _guard(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _guard(newRoute);
}

/// 「会被别的页面盖住、盖住时要收尾」的页面。播放页 controller 实现它。
abstract class PageDepartureAware {
  /// 此刻是不是真的占着全屏（系统 / 原生窗口全屏，不含桌面「应用全屏」）。
  bool get isPresentingFullscreen;

  /// 交还全屏。**必须幂等**：不在全屏里时应当什么都不做。
  Future<void> releaseFullscreen();

  /// 有别的页面盖上来了：暂停播放、复位亮度、把系统 UI 放回来。
  ///
  /// **必须幂等**：页面自己的 `didPushNext` 走的是同一条收尾，两边可能都调到。
  void onCoveredByAnotherPage();
}

/// 身份上是 `PageRoute`、语义上却是「浮在当前页之上的一层」的路由。
///
/// 目前只有媒体预览弹窗：它必须是 `PageRoute` 才飞得动 Hero（见
/// `media_preview_dialog.dart` 文件头），但它并没有把用户带去别的页面——
/// [PageDepartureGuard] 见了它不当作离开，而是当作该跟着让开的临时层。
abstract class TransientPageRoute {}
