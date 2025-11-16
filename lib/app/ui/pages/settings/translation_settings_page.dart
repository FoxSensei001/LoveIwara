import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/deeplx_translation_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class TranslationSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const TranslationSettingsPage({
    super.key,
    this.isWideScreen = false,
  });

  @override
  State<TranslationSettingsPage> createState() => _TranslationSettingsPageState();
}

class _TranslationSettingsPageState extends State<TranslationSettingsPage> {
  final RxString _selectedService = 'google'.obs;

  // 翻译服务选项
  final List<Map<String, dynamic>> _translationServices = [
    {
      'key': 'google',
      'name': slang.t.translation.googleTranslation,
      'description': slang.t.translation.googleTranslationDescription,
      'icon': 'google',
    },
    {
      'key': 'ai',
      'name': slang.t.translation.aiTranslation,
      'description': slang.t.translation.aiTranslationDescription,
      'icon': 'ai',
    },
    {
      'key': 'deeplx',
      'name': slang.t.translation.deeplxTranslation,
      'description': slang.t.translation.deeplxTranslationDescription,
      'icon': 'deeplx',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 1000;
          final EdgeInsets pagePadding = EdgeInsets.all(isWide ? 24 : 16);

          return Obx(() {
            if (_selectedService.value == 'ai') {
              // AI翻译页面
              return CustomScrollView(
                slivers: [
                  BlurredSliverAppBar(
                    title: t.translation.translation,
                    isWideScreen: widget.isWideScreen,
                  ),
                  SliverPadding(
                    padding: pagePadding,
                    sliver: SliverToBoxAdapter(
                      child: _buildServiceSelector(context),
                    ),
                  ),
                  const AITranslationSettingsWidget(),
                ],
              );
            } else if (_selectedService.value == 'deeplx') {
              // DeepLX翻译页面
              return CustomScrollView(
                slivers: [
                  BlurredSliverAppBar(
                    title: t.translation.translation,
                    isWideScreen: widget.isWideScreen,
                  ),
                  SliverPadding(
                    padding: pagePadding,
                    sliver: SliverToBoxAdapter(
                      child: _buildServiceSelector(context),
                    ),
                  ),
                  const DeepLXTranslationSettingsWidget(),
                ],
              );
            } else {
              // Google翻译页面
              return CustomScrollView(
                slivers: [
                  BlurredSliverAppBar(
                    title: t.translation.translation,
                    isWideScreen: widget.isWideScreen,
                  ),
                  SliverPadding(
                    padding: pagePadding,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildServiceSelector(context),
                        const SizedBox(height: 16),
                        _buildGoogleTranslationContent(context),
                      ]),
                    ),
                  ),
                ],
              );
            }
          });
        },
      ),
    );
  }



  Widget _buildServiceSelector(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  slang.t.translation.translationService,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
              initialValue: _selectedService.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixIcon: _buildServiceIcon(_selectedService.value),
              ),
              items: _translationServices.map((service) {
                return DropdownMenuItem<String>(
                  value: service['key'],
                  child: Text(service['name']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _selectedService.value = value;
                }
              },
            )),
            const SizedBox(height: 8),
            Obx(() {
              final service = _translationServices
                  .firstWhere((service) => service['key'] == _selectedService.value);
              return Text(
                service['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(String serviceKey) {
    switch (serviceKey) {
      case 'google':
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/google.svg',
            width: 20,
            height: 20,
          ),
        );
      case 'deeplx':
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/deepl.svg',
            width: 20,
            height: 20,
          ),
        );
      case 'ai':
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6B8DE3), Color(0xFF8B5CF6)],
            ).createShader(bounds),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: Colors.white,
            ),
          ),
        );
    }
  }

  Widget _buildGoogleTranslationContent(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Obx(() {
      final useAI = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
      final useDeepLX = configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool;
      final isGoogleEnabled = !useAI && !useDeepLX;

      return Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/google.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    slang.t.translation.googleTranslation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isGoogleEnabled
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGoogleEnabled
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGoogleEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isGoogleEnabled ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isGoogleEnabled ? slang.t.translation.enabledDefaultService : slang.t.translation.notEnabled,
                      style: TextStyle(
                        color: isGoogleEnabled ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!isGoogleEnabled)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 禁用其他翻译服务，启用Google翻译
                          configService[ConfigKey.USE_AI_TRANSLATION] = false;
                          configService[ConfigKey.USE_DEEPLX_TRANSLATION] = false;
                        },
                        icon: SvgPicture.asset(
                          'assets/svg/google.svg',
                          width: 16,
                          height: 16,
                        ),
                        label: Text(slang.t.translation.enableGoogleTranslation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              Text(
                slang.t.translation.googleTranslationFeatures,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(context, slang.t.translation.freeToUse, slang.t.translation.freeToUseDescription),
              _buildFeatureItem(context, slang.t.translation.fastResponse, slang.t.translation.fastResponseDescription),
              _buildFeatureItem(context, slang.t.translation.stableAndReliable, slang.t.translation.stableAndReliableDescription),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
