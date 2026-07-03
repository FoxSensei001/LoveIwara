import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/common/color_vision_filters.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

/// 通用的色觉辅助滤镜设置组件：一张可点击的卡片（显示当前档位），
/// 点击后弹出档位选择对话框；可选附带一条说明提示横幅。
///
/// 与 [Anime4KSettingsWidget] 保持一致的卡片交互风格，供设置页与
/// 首次启动引导页复用，避免逻辑重复。
class ColorVisionSettingsWidget extends StatelessWidget {
  final bool showInfoCard;
  final String? infoMessage;

  const ColorVisionSettingsWidget({
    super.key,
    this.showInfoCard = true,
    this.infoMessage,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

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

  Map<String, String> _optionLabels() {
    final t = slang.t;
    return {
      ColorVisionFilterType.none.id: t.colorVisionAssist.disable,
      ColorVisionFilterType.protanopia.id: t.colorVisionAssist.protanopia,
      ColorVisionFilterType.deuteranopia.id:
          t.colorVisionAssist.deuteranopia,
      ColorVisionFilterType.tritanopia.id: t.colorVisionAssist.tritanopia,
    };
  }

  Map<String, String> _optionDescriptions() {
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

    return Obx(() {
      final currentId =
          configService[ConfigKey.COLOR_VISION_FILTER_ID] as String;
      final currentType = ColorVisionFilterType.fromId(currentId);
      final isDark = Theme.of(context).brightness == Brightness.dark;

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
          onTap: () => _showSelectionDialog(context, configService),
          child: Row(
            children: [
              Icon(
                Icons.invert_colors,
                color: isDark ? Colors.white : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.colorVisionAssist.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      t.colorVisionAssist.description,
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

  Future<void> _showSelectionDialog(
    BuildContext context,
    ConfigService configService,
  ) async {
    final t = slang.t;
    final optionLabels = _optionLabels();
    final optionDescriptions = _optionDescriptions();

    await showAppDialog<void>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.invert_colors, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(child: Text(t.colorVisionAssist.title)),
            IconButton(
              onPressed: () => AppService.tryPop(),
              icon: const Icon(Icons.close),
              tooltip: t.common.close,
              visualDensity: VisualDensity.compact,
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
                      t.colorVisionAssist.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  ...ColorVisionFilterType.values.map((type) {
                    final isSelected =
                        (configService[ConfigKey.COLOR_VISION_FILTER_ID]
                            as String) ==
                        type.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: ListTile(
                        title: Text(
                          optionLabels[type.id] ?? type.id,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          optionDescriptions[type.id] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.8)
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey[400],
                              ),
                        onTap: () {
                          _applySelection(configService, type, optionLabels);
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
      ),
      barrierDismissible: true,
    );
  }

  void _applySelection(
    ConfigService configService,
    ColorVisionFilterType type,
    Map<String, String> optionLabels,
  ) {
    final t = slang.t;
    final previousId =
        configService[ConfigKey.COLOR_VISION_FILTER_ID] as String;
    if (previousId == type.id) return;

    configService[ConfigKey.COLOR_VISION_FILTER_ID] = type.id;
    // 滤镜即时作用于所有播放器画面，提示用户已生效
    showToastWidget(
      MDToastWidget(
        message: type == ColorVisionFilterType.none
            ? t.colorVisionAssist.disabledToast
            : t.colorVisionAssist.appliedToast(
                filterName: optionLabels[type.id] ?? type.id,
              ),
        type: MDToastType.success,
      ),
      position: ToastPosition.top,
    );
  }
}
