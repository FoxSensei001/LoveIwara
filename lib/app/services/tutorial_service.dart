import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/subscriptions/subscriptions_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class TutorialService {
  /// 显示订阅页面教程指导
  void showSubscriptionTutorial(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final shouldShow =
        configService[ConfigKey.SHOW_SUBSCRIPTION_TUTORIAL] as bool;

    if (!shouldShow) return;

    // 创建教程目标列表
    final List<TargetFocus> targets = [
      // 目标1：用户选择器
      TargetFocus(
        identify: "user_selector",
        keyTarget:
            SubscriptionsPage.globalKey.currentState?.userSelectorKey ??
            GlobalKey(),
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Builder(
              builder: (context) {
                final screenSize = MediaQuery.of(context).size;
                return Container(
                  width: 320,
                  constraints: BoxConstraints(
                    maxHeight: screenSize.height * 0.6,
                    maxWidth: screenSize.width * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slang.t.tutorial.specialFollowFeature,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slang.t.tutorial.specialFollowDescription,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 作者信息示例
                          _buildAuthorInfoExample(),

                          const SizedBox(height: 12),

                          // 页面位置说明（简化版）
                          _buildPageLocations(),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber[300],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    slang.t.tutorial.afterSpecialFollow,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 特别关注列表管理提示
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[300],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    slang.t.tutorial.specialFollowManagementTip,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 12,
      ),
    ];

    // 创建并显示教程
    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      textSkip: '', // 移除 skip 按钮
      paddingFocus: 10,
      focusAnimationDuration: const Duration(milliseconds: 500),
      unFocusAnimationDuration: const Duration(milliseconds: 500),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      pulseEnable: true,
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

  /// 构建作者信息示例组件
  Widget _buildAuthorInfoExample() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slang.t.tutorial.exampleAuthorInfoRow,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // 模拟头像
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              // 作者信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slang.t.tutorial.authorName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "@username",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // 关注按钮
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.green[300], size: 12),
                    const SizedBox(width: 3),
                    Text(
                      slang.t.tutorial.followed,
                      style: TextStyle(
                        color: Colors.green[300],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            slang.t.tutorial.specialFollowInstruction,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建页面位置说明（简化版）
  Widget _buildPageLocations() {
    return Container(
      width: double.infinity, // 添加宽度百分百
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slang.t.tutorial.followButtonLocations,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLocationItem(
                Icons.play_circle_outline,
                slang.t.tutorial.videoDetailPage,
              ),
              _buildLocationItem(
                Icons.photo_library,
                slang.t.tutorial.galleryDetailPage,
              ),
              _buildLocationItem(
                Icons.person,
                slang.t.tutorial.authorDetailPage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建位置项
  Widget _buildLocationItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
