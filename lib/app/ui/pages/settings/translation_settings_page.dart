import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class TranslationSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const TranslationSettingsPage({super.key, this.isWideScreen = false});

  @override
  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: slang.t.translation.translation,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverToBoxAdapter(
            child: Obx(() => _buildServicesSection(context, configService)),
          ),
        ),
      ],
    );
  }

  // ⛔ 「当前服务」卡片已删：三行服务本身就是一张单选列表，选中态已经用
  // 底色 + 勾选图标画出来了，再摆一张概括卡片只是把同一件事说两遍。
  Widget _buildServicesSection(
    BuildContext context,
    ConfigService configService,
  ) {
    final cs = Theme.of(context).colorScheme;
    // 读取配置状态
    final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
    final useDeepLX = configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool;
    final isGoogleSelected = !useAI && !useDeepLX;
    final isAISelected = useAI;
    final isDeepLXSelected = useDeepLX;

    final aiService = Get.find<AiService>();
    // 副标题给「供应商 · 模型」两级：一家下面可以挂好几个模型，光说供应商名
    // 分不出翻译实际走的是哪一个。
    final translateModel = aiService.modelFor(AiTask.translate);
    final aiProfileName = translateModel == null
        ? slang.t.ai.notConfigured
        : (translateModel.modelName.isEmpty
              ? translateModel.providerName
              : '${translateModel.providerName} · ${translateModel.modelName}');

    return GlassSettingSection(
      title: slang.t.translation.translationService,
      children: [
        // Google 翻译
        _buildServiceTile(
          context: context,
          leading: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset('assets/svg/google.svg'),
          ),
          title: slang.t.translation.googleTranslation,
          subtitle: slang.t.translation.googleTranslationDescription,
          isSelected: isGoogleSelected,
          onTap: () {
            SettingsNavigation.openSubPage(SettingsSubRoutes.translationGoogle);
          },
        ),
        // AI 翻译
        // ⛔ 这一行必须和上下的 Google / DeepLX 走**同一只** _buildServiceTile：
        // 三行并排，样式一裂开就是一眼可见的不一致。AI 的配置页从翻译的三级
        // 子页升成了一级分区，但「点这一行去配置它」这个语义没变，所以外形
        // 不该变——副标题从一句固定说明换成当前绑定的档案名而已。
        // 「启不启用 AI 翻译」那个开关跟着配置一起搬到了 AI 分区的功能分配卡。
        // 图标不再跟着选中态换色：与 Google / DeepLX 那两枚品牌 svg 一样，
        // 它是这一行的「品牌标」，不是选中指示——选中态已经由 trailing 的
        // 勾选图标单独表达。
        _buildServiceTile(
          context: context,
          leading: Icon(Icons.auto_awesome, size: 20, color: cs.primary),
          title: slang.t.translation.aiTranslation,
          subtitle: aiProfileName,
          isSelected: isAISelected,
          onTap: () {
            SettingsNavigation.openSection(context, SettingsSection.ai);
          },
        ),
        // DeepLX 翻译
        _buildServiceTile(
          context: context,
          leading: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset('assets/svg/deepl.svg'),
          ),
          title: slang.t.translation.deeplxTranslation,
          subtitle: slang.t.translation.deeplxTranslationDescription,
          isSelected: isDeepLXSelected,
          onTap: () {
            SettingsNavigation.openSubPage(SettingsSubRoutes.translationDeeplx);
          },
        ),
      ],
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required Widget leading,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GlassSettingTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: isSelected,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected) ...[
            Icon(Icons.check_circle, color: cs.primary, size: 20),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, size: 20, color: cs.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}
