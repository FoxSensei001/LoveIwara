import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class AITranslationToggleButton extends StatelessWidget {
  final bool closeDialogsBeforeNavigate;
  final bool compact;

  const AITranslationToggleButton({
    super.key,
    this.closeDialogsBeforeNavigate = false,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final configService = Get.find<ConfigService>();

    return Obx(() {
      final isAIEnabled = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
      if (!isAIEnabled) {
        if (compact) {
          return ElevatedButton.icon(
            onPressed: () {
              if (closeDialogsBeforeNavigate) {
                Get.closeAllDialogs();
              }
              Get.toNamed(Routes.AI_TRANSLATION_SETTINGS_PAGE);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              Icons.auto_awesome,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              t.translation.enableAITranslation,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 10,
              ),
            ),
          );
        } else {
          return ElevatedButton.icon(
            onPressed: () {
              if (closeDialogsBeforeNavigate) {
                Get.closeAllDialogs();
              }
              Get.toNamed(Routes.AI_TRANSLATION_SETTINGS_PAGE);
            },
            icon: Icon(
              Icons.auto_awesome,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              t.translation.enableAITranslation,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          );
        }
      } else {
        if (compact) {
          return Tooltip(
            message: t.translation.disableAITranslation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: true,
                    onChanged: (value) {
                      configService[ConfigKey.USE_AI_TRANSLATION] = false;
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Tooltip(
            message: t.translation.disableAITranslation,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: true,
                  onChanged: (value) {
                    configService[ConfigKey.USE_AI_TRANSLATION] = false;
                  },
                ),
              ],
            ),
          );
        }
      }
    });
  }
} 