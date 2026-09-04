import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/subscriptions_page.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/widgets/special_follow_intro_card.dart';

/// 首次引导（目前只有订阅页的「特别关注」一处）。
///
/// 这里只负责取目标、配遮罩、记住「看过了」；卡片长什么样归
/// [SpecialFollowIntroCard]。
class TutorialService {
  /// 显示订阅页面教程指导
  void showSubscriptionTutorial(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final userService = Get.find<UserService>();

    final shouldShow =
        configService[ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL] as bool;

    // 只有在用户已登录且配置允许的情况下才显示教程
    if (!shouldShow || !userService.isAuthenticated) return;

    // 拿不到已挂载的目标就别开：包内部会抛 NotFoundTargetException 然后
    // 走 skip()，屏幕上闪一层黑而已，不如这次不显示、下次再来。
    final GlobalKey? targetKey =
        SubscriptionsPage.globalKey.currentState?.userSelectorKey;
    if (targetKey?.currentContext == null) return;

    // 尊重系统「减弱动态效果」：关掉聚焦圈的脉冲呼吸。
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // 卡片上的「知道了」要关掉整个遮罩，而遮罩对象此刻还没造出来——
    // 闭包里晚一步读它。
    late final TutorialCoachMark tutorial;

    final List<TargetFocus> targets = [
      TargetFocus(
        identify: 'special_follow_selector',
        keyTarget: targetKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: SpecialFollowIntroCard(onDismiss: () => tutorial.finish()),
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 14,
      ),
    ];

    tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      // 原来是 0.8 纯黑，除了被挖空的那一小块以外整页全黑，用户根本认不出
      // 高亮的是页面上的哪个位置。压到 0.55 再加一层轻模糊：底下的订阅页
      // 仍认得出，注意力照样落在挖空处。
      opacityShadow: 0.55,
      imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      textSkip: '', // 移除 skip 按钮（收尾走卡片上的「知道了」）
      hideSkip: true,
      paddingFocus: 8,
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: const Duration(milliseconds: 500),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      pulseEnable: !reduceMotion,
      onFinish: () {
        // 教程完成后，不再显示
        configService.setSetting(ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL, false);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        tutorial.show(context: context);
      }
    });
  }

  /// 重置教程状态（用于测试或重新显示）
  void resetSubscriptionTutorial() {
    final configService = Get.find<ConfigService>();
    configService.setSetting(ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL, true);
  }

  /// 强制显示教程（用于测试）
  void forceShowSubscriptionTutorial(BuildContext context) {
    final configService = Get.find<ConfigService>();
    configService.setSetting(ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL, true);
    showSubscriptionTutorial(context);
  }
}
