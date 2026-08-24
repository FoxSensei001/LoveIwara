import 'package:get/get.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/routes/home_shell_navigation.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/deep_link_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/theme_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:flutter/material.dart';

/// 一次性提醒该拿它怎么办。
enum GlassIntroAction {
  /// 现在就弹。
  show,

  /// 现在不合适（有链接在路上 / 不在首页 / 上面压着别的弹窗），等等再看。
  waitAndRetry,

  /// 用户正在走首次引导——那里已经有一份同样的选择，别再弹一次。
  guideWillAsk,

  /// 已经问过了（用户见过提醒，或引导页里选过），永远不再问。
  alreadyDone,
}

/// 「玻璃质感」的一次性提醒：告诉老用户这一版的玻璃可以关，并当场给他选。
///
/// # 三类用户，三条路
///
///   1. **升级上来的老用户**：首次设置早就完成过，引导页不会再走一遍——他们只能
///      靠这个提醒知道有这么个开关。这是本文件存在的唯一理由。
///   2. **全新安装的用户**：先进首次引导，主题那一步里就有同一份选择
///      （`theme_step_widget.dart`）。引导一完成就把这里标记成「问过了」
///      （见 `SetupController.completeSetup`），永远不会再弹。
///   3. **引导走到一半被杀掉的用户**：首次设置仍未完成，下次启动还会回到引导页。
///      这时 [decide] 返回 [GlassIntroAction.guideWillAsk]：交给引导页，同样不弹。
///
/// # 为什么要等，而不是启动就弹
///
/// 冷启动那几秒里有三件事会和它抢屏幕，都不是「弹出来盖住就行」的：
///
///   - **DeepLink**：被一条链接拉起来时，`DeepLinkService` 是在 markReady 之后
///     **延迟 1.5s** 才导航的。那 1.5s 里首页看着一切正常，弹窗这时冒出来，下一秒
///     就被视频详情页盖掉——用户看见一个一闪而过的东西，还不知道是什么。
///   - **首次引导**：新用户此刻正在引导页里，弹窗会盖在引导流程上。
///   - **别的弹窗**：自动更新检查（`VersionService.doAutoCheckUpdate`）、崩溃恢复
///     提示都可能在启动那几秒里弹出来。
///
/// 所以这里是「延迟 + 复查 + 有限重试」：条件不满足就再等 2s 看一次，最多 5 次
/// （约 13s）。始终等不到就**这次不弹、也不标记**——下次正常启动还会再试。
/// 这条很关键：宁可下次再弹，也不要弹在一个会被立刻盖掉的时机上。
class GlassMaterialIntro {
  GlassMaterialIntro._();

  static const String _tag = 'GlassMaterialIntro';

  /// 首帧之后先让路由 / 首页把自己安顿好，再开始复查。比 DeepLink 那 1.5s 晚。
  static const Duration firstDelay = Duration(seconds: 3);

  /// 每次复查之间隔多久。
  static const Duration retryInterval = Duration(seconds: 2);

  /// 最多复查几次；用完还没等到时机就放弃（不标记，下次启动再试）。
  static const int maxAttempts = 5;

  /// 本次运行是否已经排过队——[MyApp] 有可能因为切站重建而 initState 两次。
  static bool _scheduled = false;

  @visibleForTesting
  static void resetForTest() => _scheduled = false;

  /// 纯判断：拿当前这些状态，这个提醒现在该怎么办。
  ///
  /// 抽成纯函数是为了能单测——真实触发链路（Get / go_router / Overlay）在
  /// 单测里搭不起来，但「什么时候该弹」这件事本身全在这几个入参里。
  @visibleForTesting
  static GlassIntroAction decide({
    required bool introShown,
    required bool firstTimeSetupCompleted,
    required bool hasPendingDeepLink,
    required bool hasOverlay,
    required String? currentLocation,
  }) {
    if (introShown) return GlassIntroAction.alreadyDone;
    // 引导页里有同一份选择，别抢它的活。
    if (!firstTimeSetupCompleted) return GlassIntroAction.guideWillAsk;
    // 链接还在路上：现在的首页是「过路的」，马上会被链接目标页顶掉。
    if (hasPendingDeepLink) return GlassIntroAction.waitAndRetry;
    // 上面压着别的弹窗（自动更新提示、崩溃恢复提示……）。
    if (hasOverlay) return GlassIntroAction.waitAndRetry;
    // 只在首页四个 tab 根上弹：详情页 / 播放器 / 设置页里冒出来都是打断。
    if (!isHomeTabRoot(currentLocation)) return GlassIntroAction.waitAndRetry;
    return GlassIntroAction.show;
  }

  /// 是不是首页那四个 tab 根之一（`/`、`/gallery`、`/subscriptions`、`/community`）。
  @visibleForTesting
  static bool isHomeTabRoot(String? location) {
    if (location == null || location.isEmpty) return false;
    final String path = location.length > 1 && location.endsWith('/')
        ? location.substring(0, location.length - 1)
        : location;
    return HomeShellNavigation.pathByKey.containsValue(path);
  }

  /// 启动时排一次队（[MyApp] 的 initState 调用，fire-and-forget）。
  static void scheduleAfterStartup() {
    if (_scheduled) return;
    _scheduled = true;
    Future<void>.delayed(firstDelay, () => _attempt(1));
  }

  static Future<void> _attempt(int attempt) async {
    try {
      final configService = Get.find<ConfigService>();
      final action = decide(
        introShown: configService[ConfigKey.GLASS_MATERIAL_INTRO_SHOWN] == true,
        firstTimeSetupCompleted:
            configService[ConfigKey.FIRST_TIME_SETUP_COMPLETED] == true,
        hasPendingDeepLink: Get.isRegistered<DeepLinkService>()
            ? Get.find<DeepLinkService>().hasPendingInitialLink
            : false,
        hasOverlay: OverlayTracker.instance.hasOverlay,
        currentLocation: _currentLocation(),
      );

      switch (action) {
        case GlassIntroAction.alreadyDone:
          return;
        case GlassIntroAction.guideWillAsk:
          // 引导页负责问；这里顺手记账，免得引导中途被杀、下次又落到这条路上。
          await markAsked();
          return;
        case GlassIntroAction.waitAndRetry:
          if (attempt >= maxAttempts) {
            LogUtils.d('玻璃质感提醒：$maxAttempts 次都没等到合适时机，留到下次启动', _tag);
            return;
          }
          Future<void>.delayed(retryInterval, () => _attempt(attempt + 1));
          return;
        case GlassIntroAction.show:
          // 先记账再弹：弹窗过程中被杀 / 被系统回收也算问过了，不要反复骚扰。
          await markAsked();
          await _showDialog();
          return;
      }
    } catch (e, s) {
      LogUtils.e('玻璃质感提醒失败', tag: _tag, error: e, stackTrace: s);
    }
  }

  static String? _currentLocation() {
    try {
      // ⛔ 必须走 GoRouter.state：`routeInformationProvider.value.uri` 读不到
      // imperative push 出来的地址（见 `settings_navigation.dart` 那段说明）。
      return appRouter.state.uri.path;
    } catch (_) {
      return null;
    }
  }

  /// 记下「已经问过」。引导页完成时也调它。
  static Future<void> markAsked() async {
    final configService = Get.find<ConfigService>();
    if (configService[ConfigKey.GLASS_MATERIAL_INTRO_SHOWN] == true) return;
    await configService.setSetting(
      ConfigKey.GLASS_MATERIAL_INTRO_SHOWN,
      true,
    );
  }

  static Future<void> _showDialog() async {
    final themeService = Get.find<ThemeService>();
    await showAppDialog(
      GlassAlertDialog(
        title: t.settings.glassEffectIntroTitle,
        // 两条带副标题的选项 + 说明，窄屏横屏时会顶到边——让正文自己能滚。
        scrollable: true,
        content: Builder(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(t.settings.glassEffectIntroContent),
              ),
              // 就地选、立刻生效：关掉弹窗看到的就是选好的样子。
              Obx(() {
                final bool enabled = themeService.enableLiquidGlass;
                return Column(
                  children: [
                    GlassChoiceItem<bool>(
                      value: true,
                      groupValue: enabled,
                      onChanged: themeService.setLiquidGlassEnabled,
                      title: Text(t.settings.liquidGlassEffect),
                      subtitle: Text(t.settings.liquidGlassEffectDesc),
                    ),
                    GlassChoiceItem<bool>(
                      value: false,
                      groupValue: enabled,
                      onChanged: themeService.setLiquidGlassEnabled,
                      title: Text(t.settings.plainGlassEffect),
                      subtitle: Text(t.settings.plainGlassEffectDesc),
                    ),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  t.settings.glassEffectIntroHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GlassDialogAction(
            label: t.settings.glassEffectIntroDone,
            onPressed: () => AppService.tryPop(),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
