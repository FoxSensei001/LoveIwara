import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/google_translation_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/deeplx_translation_setting_widget.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.translation.translation,
            isWideScreen: isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + bottomInset,
            ),
            sliver: SliverToBoxAdapter(
              child: Obx(
                () => Column(
                  children: [
                    _buildCurrentServiceCard(context, configService),
                    const SizedBox(height: 16),
                    _buildServicesCard(context, configService),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentServiceCard(
    BuildContext context,
    ConfigService configService,
  ) {
    final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
    final useDeepLX = configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool;

    String currentService;
    Widget icon;
    Color color;

    if (useAI) {
      currentService = slang.t.translation.aiTranslation;
      icon = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF6B8DE3), Color(0xFF8B5CF6)],
        ).createShader(bounds),
        child: const Icon(Icons.auto_awesome, size: 24, color: Colors.white),
      );
      color = const Color(0xFF8B5CF6);
    } else if (useDeepLX) {
      currentService = slang.t.translation.deeplxTranslation;
      icon = SvgPicture.asset('assets/svg/deepl.svg', width: 24, height: 24);
      color = Colors.blue;
    } else {
      currentService = slang.t.translation.googleTranslation;
      icon = SvgPicture.asset('assets/svg/google.svg', width: 24, height: 24);
      color = Colors.green;
    }

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slang.t.translation.currentService,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentService,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, ConfigService configService) {
    // 读取配置状态
    final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
    final useDeepLX = configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool;
    final isGoogleSelected = !useAI && !useDeepLX;
    final isAISelected = useAI;
    final isDeepLXSelected = useDeepLX;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.translation.translationService,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          // Google 翻译
          _buildServiceTile(
            context: context,
            icon: SvgPicture.asset(
              'assets/svg/google.svg',
              width: 24,
              height: 24,
            ),
            title: slang.t.translation.googleTranslation,
            subtitle: slang.t.translation.googleTranslationDescription,
            isSelected: isGoogleSelected,
            onTap: () {
              SettingsPage.navigateToNestedPage(
                GoogleTranslationSettingsPage(isWideScreen: isWideScreen),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          // AI 翻译
          _buildServiceTile(
            context: context,
            icon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6B8DE3), Color(0xFF8B5CF6)],
              ).createShader(bounds),
              child: const Icon(
                Icons.auto_awesome,
                size: 24,
                color: Colors.white,
              ),
            ),
            title: slang.t.translation.aiTranslation,
            subtitle: slang.t.translation.aiTranslationDescription,
            isSelected: isAISelected,
            onTap: () {
              SettingsPage.navigateToNestedPage(
                AITranslationSettingsPage(isWideScreen: isWideScreen),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          // DeepLX 翻译
          _buildServiceTile(
            context: context,
            icon: SvgPicture.asset(
              'assets/svg/deepl.svg',
              width: 24,
              height: 24,
            ),
            title: slang.t.translation.deeplxTranslation,
            subtitle: slang.t.translation.deeplxTranslationDescription,
            isSelected: isDeepLXSelected,
            isLast: true,
            onTap: () {
              SettingsPage.navigateToNestedPage(
                DeepLXTranslationSettingsPage(isWideScreen: isWideScreen),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
      shape: isLast
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            )
          : null,
    );
  }
}
