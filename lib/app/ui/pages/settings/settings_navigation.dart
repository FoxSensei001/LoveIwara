import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';

import 'settings_section.dart';

/// 设置树的导航动作。
///
/// 设置页的栈**唯一**由 go_router 持有：没有 `_currentInstance` 静态单例、
/// 没有手写 `_pageStack`、没有 `PopScope` 同步，也就没有它们带来的生命周期与
/// 「observer 回调里 setState」问题（那是上一版改造 fd84edf5 崩在 build 期、
/// 级联出一片 Obx 报错的根因）。
abstract final class SettingsNavigation {
  /// 当前是否为双栏（master-detail）布局。
  static bool isTwoPane(BuildContext context) =>
      MediaQuery.sizeOf(context).width > kSettingsTwoPaneBreakpoint;

  /// 当前 location。
  ///
  /// 必须走 [GoRouter.state]，**不能**用
  /// `routeInformationProvider.value.uri` —— 后者的 [RouteMatchList.uri]
  /// 明确「只反映非 ImperativeRouteMatch 的匹配」，而设置树全是 `push` 进来的
  /// （见 NaviService 里那串入口），于是它会一直停在进设置之前的那个地址。
  static String get currentLocation {
    try {
      return appRouter.state.uri.path;
    } catch (_) {
      return '';
    }
  }

  /// 打开一级分区。
  ///
  /// - 窄屏：`push` 到一级列表之上，返回即回到列表。
  /// - 宽屏：右栏永远从分区根开始——先把已推入的三级页收掉，再顶替当前分区。
  ///   用 `pushReplacement` 而不是 `replace`：后者会复用同一个 pageKey，
  ///   Navigator 看到相同 key 就只换内容、不跑转场（见 GoRouter.replace 文档），
  ///   而这里要的正是那段 200ms 横推。
  static void openSection(BuildContext context, SettingsSection section) {
    if (currentLocation == section.path) return;

    if (!isTwoPane(context)) {
      appRouter.push(section.path);
      return;
    }

    _collapseToSectionRoot();
    appRouter.pushReplacement(section.path);
  }

  /// 打开三级及更深的页面。宽窄一致，都是往当前栈上压一页。
  static Future<void> openSubPage(String path) {
    if (currentLocation == path) return Future<void>.value();
    return appRouter.push<void>(path).then((_) {});
  }

  /// 离开整个设置子树。
  ///
  /// 设置壳自身是宿主 Shell Navigator 上的一页，弹掉它就等于整棵设置树一起走，
  /// 只跑一次转场（逐层 pop 会连放好几段动画）。
  static void exitSettings() {
    shellNavigatorKey.currentState?.maybePop();
  }

  /// 把设置内部导航栈收回到分区根（深度 1）。
  static void _collapseToSectionRoot() {
    var safety = 8;
    while (safety-- > 0 &&
        (settingsShellNavigatorKey.currentState?.canPop() ?? false)) {
      appRouter.pop();
    }
  }
}
