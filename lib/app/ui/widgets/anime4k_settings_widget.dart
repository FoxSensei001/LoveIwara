import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/common/anime4k_presets.dart';
import '../pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';

/// 通用的 Anime4K 设置组件
class Anime4KSettingsWidget extends StatelessWidget {
  final bool showInfoCard;
  final String? infoMessage;
  final bool isNarrow;

  /// 嵌入模式：不再渲染自己的卡片外壳与提示横幅，只输出一个扁平的
  /// [ListTile]，供外部的分组卡片（如播放器设置页）直接内联，
  /// 与同卡片内的其它条目共用行高与留白。
  final bool embedded;

  const Anime4KSettingsWidget({
    super.key,
    this.showInfoCard = true,
    this.infoMessage,
    this.isNarrow = false,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    if (embedded) {
      return _buildPresetSelection(
        context: context,
        configService: configService,
      );
    }

    return Column(
      children: [
        if (showInfoCard && infoMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.amber.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      infoMessage!,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Anime4K 预设选择
        _buildPresetSelection(context: context, configService: configService),
      ],
    );
  }

  Widget _buildPresetSelection({
    required BuildContext context,
    required ConfigService configService,
  }) {
    return Obx(() {
      final currentPresetId =
          configService[ConfigKey.ANIME4K_PRESET_ID] as String;
      final currentPreset = Anime4KPresets.getPresetById(currentPresetId);

      if (embedded) {
        final theme = Theme.of(context);
        return ListTile(
          leading: Icon(Icons.tune, color: theme.colorScheme.onSurfaceVariant),
          title: Text(slang.t.anime4k.preset, style: theme.textTheme.bodyLarge),
          subtitle: Text(
            currentPreset?.name ?? slang.t.anime4k.disable,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: currentPresetId.isEmpty
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.primary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showPresetSelectionDialog(context, configService),
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
          onTap: () => _showPresetSelectionDialog(context, configService),
          child: Row(
            children: [
              Icon(
                Icons.tune,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slang.t.anime4k.preset,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentPreset != null)
                      Text(
                        currentPreset.description,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Text(
                currentPreset?.name ?? slang.t.anime4k.disable,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: currentPresetId.isEmpty
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 打开预设选择弹窗（不渲染任何行，只要弹窗）。
  ///
  /// 首次设置向导的播放器步用自己的设置行（与同卡片里的开关行同一套行高与
  /// 留白），但弹窗要和播放器设置页共用同一份，所以这里把入口露出来。
  static Future<void> showPresetDialog(BuildContext context) {
    return const Anime4KSettingsWidget()._showPresetSelectionDialog(
      context,
      Get.find<ConfigService>(),
    );
  }

  /// 当前预设的显示名（关闭时给出「关闭 Anime4K」）。
  static String currentPresetLabel() {
    final id = Get.find<ConfigService>()[ConfigKey.ANIME4K_PRESET_ID] as String;
    return Anime4KPresets.getPresetById(id)?.name ?? slang.t.anime4k.disable;
  }

  Future<void> _showPresetSelectionDialog(
    BuildContext context,
    ConfigService configService,
  ) async {
    final currentPresetId =
        configService[ConfigKey.ANIME4K_PRESET_ID] as String;

    await showAppDialog<String>(
      GlassAlertDialog(
        title: slang.t.anime4k.preset,
        maxWidth: 560,
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 性能提醒
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            slang.t.anime4k.performanceTip,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GPU 兼容性提醒：部分移动端 GPU 加载任何着色器都会黑屏（仅有声音），
                  // 此时用户看不到画面，只能靠这里的说明找回关闭入口
                  if (GetPlatform.isAndroid || GetPlatform.isIOS)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              slang.t.anime4k.compatibilityTip,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildDisableOption(context, currentPresetId),
                  // 按预设类型分组显示
                  _buildPresetGroup(
                    context,
                    '${Anime4KPresetGroup.highQuality.icon} ${slang.t.anime4k.presetGroups.highQuality}',
                    Anime4KPresets.getPresetsByGroup(
                      Anime4KPresetGroup.highQuality,
                    ),
                    currentPresetId,
                  ),
                  _buildPresetGroup(
                    context,
                    '${Anime4KPresetGroup.fast.icon} ${slang.t.anime4k.presetGroups.fast}',
                    Anime4KPresets.getPresetsByGroup(Anime4KPresetGroup.fast),
                    currentPresetId,
                  ),
                  _buildPresetGroup(
                    context,
                    '${Anime4KPresetGroup.lite.icon} ${slang.t.anime4k.presetGroups.lite}',
                    Anime4KPresets.getPresetsByGroup(Anime4KPresetGroup.lite),
                    currentPresetId,
                  ),
                  _buildPresetGroup(
                    context,
                    '${Anime4KPresetGroup.moreLite.icon} ${slang.t.anime4k.presetGroups.moreLite}',
                    Anime4KPresets.getPresetsByGroup(
                      Anime4KPresetGroup.moreLite,
                    ),
                    currentPresetId,
                  ),
                  _buildPresetGroup(
                    context,
                    '${Anime4KPresetGroup.custom.icon} ${slang.t.anime4k.presetGroups.custom}',
                    Anime4KPresets.getPresetsByGroup(Anime4KPresetGroup.custom),
                    currentPresetId,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildDisableOption(BuildContext context, String currentPresetId) {
    final isSelected = currentPresetId.isEmpty;

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
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          Icons.close,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
        title: Text(
          slang.t.anime4k.disable,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Text(
          slang.t.anime4k.disableDescription,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
        onTap: () async {
          final configService = Get.find<ConfigService>();
          configService[ConfigKey.ANIME4K_PRESET_ID] = '';

          // 如果有视频播放器控制器，立即应用新预设
          if (Get.isRegistered<MyVideoStateController>()) {
            final videoController = Get.find<MyVideoStateController>();
            await videoController.switchAnime4KPreset('');
          }

          AppService.tryPop();
        },
      ),
    );
  }

  Widget _buildPresetGroup(
    BuildContext context,
    String title,
    List<Anime4KPreset> presets,
    String currentPresetId,
  ) {
    if (presets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(_getGroupIcon(title), color: Colors.blue.shade600, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
        ...presets.map(
          (preset) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: currentPresetId == preset.id
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withValues(alpha: 0.3),
                width: currentPresetId == preset.id ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: currentPresetId == preset.id
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : null,
            ),
            child: ListTile(
              title: Text(
                preset.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: currentPresetId == preset.id
                      ? Theme.of(context).primaryColor
                      : null,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  preset.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: currentPresetId == preset.id
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                        : Colors.grey[600],
                  ),
                ),
              ),
              trailing: currentPresetId == preset.id
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
              onTap: () async {
                final configService = Get.find<ConfigService>();
                configService[ConfigKey.ANIME4K_PRESET_ID] = preset.id;

                // 如果有视频播放器控制器，立即应用新预设
                if (Get.isRegistered<MyVideoStateController>()) {
                  final videoController = Get.find<MyVideoStateController>();
                  await videoController.switchAnime4KPreset(preset.id);
                }

                AppService.tryPop();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getGroupIcon(String title) {
    if (title.contains(slang.t.anime4k.presetGroups.highQuality)) {
      return Icons.rocket_launch;
    }
    if (title.contains(slang.t.anime4k.presetGroups.fast)) {
      return Icons.flash_on;
    }
    if (title.contains(slang.t.anime4k.presetGroups.lite)) {
      return Icons.phone_android;
    }
    if (title.contains(slang.t.anime4k.presetGroups.custom)) return Icons.build;
    if (title.contains(slang.t.anime4k.presetGroups.moreLite)) {
      return Icons.category;
    }
    return Icons.rocket_launch;
  }
}
