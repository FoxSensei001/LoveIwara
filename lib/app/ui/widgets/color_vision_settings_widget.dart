import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/color_vision_filters.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 通用的色觉辅助滤镜设置组件：一张可点击的卡片（显示当前档位），
/// 点击后弹出档位选择对话框；可选附带一条说明提示横幅。
///
/// 与 [Anime4KSettingsWidget] 保持一致的卡片交互风格，供设置页与
/// 首次启动引导页复用，避免逻辑重复。
///
/// [configKey] 指定读写的配置键：默认播放器 [ConfigKey.COLOR_VISION_FILTER_ID]，
/// 图库设置页传入 [ConfigKey.GALLERY_COLOR_VISION_FILTER_ID] 使用独立开关；
/// [descriptionOverride] 可覆盖默认说明文案（如图库场景改为「图片」措辞）。
class ColorVisionSettingsWidget extends StatelessWidget {
  final bool showInfoCard;
  final String? infoMessage;
  final ConfigKey configKey;
  final String? descriptionOverride;

  /// 嵌入模式：不再渲染自己的卡片外壳与提示横幅，只输出一个扁平的
  /// [ListTile]，供外部的分组卡片（如播放器设置页）直接内联，
  /// 与同卡片内的其它条目共用行高与留白。
  final bool embedded;

  const ColorVisionSettingsWidget({
    super.key,
    this.showInfoCard = true,
    this.infoMessage,
    this.configKey = ConfigKey.COLOR_VISION_FILTER_ID,
    this.descriptionOverride,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    if (embedded) {
      return _buildSelector(context, configService);
    }

    return Column(
      children: [
        if (showInfoCard && infoMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.accessibility_new,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        _buildSelector(context, configService),
      ],
    );
  }

  static Map<String, String> _optionLabels() {
    final t = slang.t;
    return {
      ColorVisionFilterType.none.id: t.colorVisionAssist.disable,
      ColorVisionFilterType.protanopia.id: t.colorVisionAssist.protanopia,
      ColorVisionFilterType.deuteranopia.id: t.colorVisionAssist.deuteranopia,
      ColorVisionFilterType.tritanopia.id: t.colorVisionAssist.tritanopia,
    };
  }

  static Map<String, String> _optionDescriptions() {
    final t = slang.t;
    return {
      ColorVisionFilterType.none.id: t.colorVisionAssist.disableDescription,
      ColorVisionFilterType.protanopia.id:
          t.colorVisionAssist.protanopiaDescription,
      ColorVisionFilterType.deuteranopia.id:
          t.colorVisionAssist.deuteranopiaDescription,
      ColorVisionFilterType.tritanopia.id:
          t.colorVisionAssist.tritanopiaDescription,
    };
  }

  Widget _buildSelector(BuildContext context, ConfigService configService) {
    final t = slang.t;
    final optionLabels = _optionLabels();
    final description = descriptionOverride ?? t.colorVisionAssist.description;

    return Obx(() {
      final currentId = configService[configKey] as String;
      final currentType = ColorVisionFilterType.fromId(currentId);
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (embedded) {
        final theme = Theme.of(context);
        return ListTile(
          leading: Icon(
            Icons.invert_colors,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            t.colorVisionAssist.title,
            style: theme.textTheme.bodyLarge,
          ),
          subtitle: Text(
            optionLabels[currentId] ?? currentId,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: currentType == ColorVisionFilterType.none
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () => showSelectionDialog(
            context,
            configKey: configKey,
            description: description,
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showSelectionDialog(
            context,
            configKey: configKey,
            description: description,
          ),
          child: Row(
            children: [
              Icon(Icons.invert_colors, color: isDark ? Colors.white : null),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.colorVisionAssist.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                optionLabels[currentId] ?? currentId,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: currentType == ColorVisionFilterType.none
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: isDark ? Colors.white : null),
            ],
          ),
        ),
      );
    });
  }

  /// 弹出色觉辅助档位选择对话框（可复用于设置卡片与图库三点菜单）。
  ///
  /// [configKey] 决定读写哪个开关（播放器 / 图库），[description] 覆盖顶部说明文案。
  static Future<void> showSelectionDialog(
    BuildContext context, {
    ConfigKey configKey = ConfigKey.COLOR_VISION_FILTER_ID,
    String? description,
  }) async {
    final t = slang.t;
    final configService = Get.find<ConfigService>();
    final optionLabels = _optionLabels();
    final optionDescriptions = _optionDescriptions();
    final headerText = description ?? t.colorVisionAssist.description;

    await showAppDialog<void>(
      Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          return AlertDialog(
            // 标题行关闭钮走全局约定的玻璃圆钮
            title: Row(
              children: [
                Icon(Icons.invert_colors, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(t.colorVisionAssist.title)),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => AppService.tryPop(),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          headerText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      ...ColorVisionFilterType.values.map((type) {
                        final isSelected =
                            (configService[configKey] as String) == type.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? cs.primary
                                  : cs.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? cs.primaryContainer.withValues(alpha: 0.4)
                                : null,
                          ),
                          child: ListTile(
                            title: Text(
                              optionLabels[type.id] ?? type.id,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? cs.primary : null,
                              ),
                            ),
                            subtitle: Text(
                              optionDescriptions[type.id] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? cs.primary.withValues(alpha: 0.8)
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: cs.primary)
                                : Icon(
                                    Icons.radio_button_unchecked,
                                    color: cs.outline,
                                  ),
                            onTap: () {
                              _applySelection(
                                configService,
                                type,
                                configKey,
                                optionLabels,
                              );
                              AppService.tryPop();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  static void _applySelection(
    ConfigService configService,
    ColorVisionFilterType type,
    ConfigKey configKey,
    Map<String, String> optionLabels,
  ) {
    final t = slang.t;
    final previousId = configService[configKey] as String;
    if (previousId == type.id) return;

    configService[configKey] = type.id;
    // 滤镜即时作用于目标画面，提示用户已生效
    showGlassToast(
      type == ColorVisionFilterType.none
          ? t.colorVisionAssist.disabledToast
          : t.colorVisionAssist.appliedToast(
              filterName: optionLabels[type.id] ?? type.id,
            ),
      type: GlassToastType.success,
      position: GlassToastPosition.top,
    );
  }
}
