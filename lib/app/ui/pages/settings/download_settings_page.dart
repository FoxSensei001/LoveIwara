import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/download_notification_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_location_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/downloads_outside_folder_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import 'package:i_iwara/app/ui/widgets/glass/glass_slider.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

/// 下载设置页。
///
/// ```
/// [保存位置]  当前位置卡（DownloadLocationCard） + 目录外的已下载内容
/// [下载行为]  并发数、通知
/// [文件命名]  三个模板 + 支持的变量
/// [高级]      可折叠：写入诊断
/// ```
///
/// 保存位置整块由 [DownloadLocationCard] 负责（状态、授权、修复、更改、手输、
/// 恢复默认都在那里），本页不再有常驻的路径输入框、「启用自定义路径」开关、
/// 独立的权限卡——改位置只有「更改位置」一个入口，走同一条检查 → 确认 → 写配置
/// 流程（见 change_download_location_sheet.dart）。
class DownloadSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const DownloadSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  final ConfigService configService = Get.find<ConfigService>();
  late FilenameTemplateService filenameTemplateService;

  final TextEditingController _videoTemplateController =
      TextEditingController();
  final TextEditingController _galleryTemplateController =
      TextEditingController();
  final TextEditingController _imageTemplateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    // 获取文件命名模板服务
    filenameTemplateService = Get.find<FilenameTemplateService>();

    // 初始化控制器值
    _videoTemplateController.text =
        configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] ?? '%title_%quality';
    _galleryTemplateController.text =
        configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] ?? '%title_%id';
    _imageTemplateController.text =
        configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] ?? '%title_%filename';
  }

  @override
  void dispose() {
    _videoTemplateController.dispose();
    _galleryTemplateController.dispose();
    _imageTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: t.settings.downloadSettings.downloadSettings,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // [保存位置]
              const DownloadLocationCard(),
              const SizedBox(height: 16),

              // 当前目录之外的已下载内容 · 移到这里（没有时不占位，自带底部间距）
              const DownloadsOutsideFolderCard(),

              // [下载行为]
              _buildBehaviorSection(context),
              const SizedBox(height: 16),

              // [文件命名]
              _buildFilenameTemplateSection(context),
              const SizedBox(height: 16),

              // [高级]
              _buildAdvancedSection(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final current =
        ((configService[ConfigKey.MAX_CONCURRENT_DOWNLOADS] as int?) ?? 3)
            .clamp(1, 5);
    return GlassSettingSection(
      title: t.download.location.behaviorSection,
      children: [
        // 最大并发下载数
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.downloading_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.download.maxConcurrentDownloads,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '$current',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  t.download.maxConcurrentDownloadsDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              GlassSlider(
                value: current.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$current',
                onChanged: (value) {
                  setState(() {
                    configService[ConfigKey.MAX_CONCURRENT_DOWNLOADS] = value
                        .round();
                  });
                  // 调高并发后立即让队列补充启动更多等待中的任务
                  if (Get.isRegistered<DownloadService>()) {
                    DownloadService.to.kickQueue();
                  }
                },
              ),
            ],
          ),
        ),
        // 下载完成/失败通知
        Obx(
          () => GlassSwitchItem(
            icon: Icons.notifications_outlined,
            title: Text(
              t.settings.downloadSettings.enableDownloadNotifications,
            ),
            subtitle: Text(
              t
                  .settings
                  .downloadSettings
                  .enableDownloadNotificationsDescription,
            ),
            value:
                configService[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED] ?? true,
            onChanged: (value) async {
              configService[ConfigKey.DOWNLOAD_NOTIFICATIONS_ENABLED] = value;
              // 开启时请求系统通知权限；被拒绝时提示（应用内通知仍可用）。
              if (value && Get.isRegistered<DownloadNotificationService>()) {
                final granted = await DownloadNotificationService.to
                    .requestPermission();
                if (!granted) {
                  showAppToast(
                    t.settings.downloadSettings.notificationPermissionDenied,
                    type: AppToastType.warning,
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassExpansionCard(
      icon: Icons.tune,
      title: Text(t.download.location.advancedSection),
      subtitle: Text(t.download.location.advancedSubtitle),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: DownloadTestWidget(key: ValueKey('download_test')),
        ),
      ],
    );
  }

  Widget _buildFilenameTemplateSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    return GlassSettingSection(
      title: t.download.location.namingSection,
      divided: false,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            t.settings.downloadSettings.filenameTemplateDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // 视频文件命名模板
              _buildTemplateField(
                context,
                controller: _videoTemplateController,
                label: t.settings.downloadSettings.videoFilenameTemplate,
                hint: t.settings.downloadSettings.suchAsTitleQuality,
                configKey: ConfigKey.VIDEO_FILENAME_TEMPLATE,
              ),
              const SizedBox(height: 12),

              // 图库文件夹命名模板
              _buildTemplateField(
                context,
                controller: _galleryTemplateController,
                label: t.settings.downloadSettings.galleryFolderTemplate,
                hint: t.settings.downloadSettings.suchAsTitleId,
                configKey: ConfigKey.GALLERY_FILENAME_TEMPLATE,
              ),
              const SizedBox(height: 12),

              // 单张图片命名模板
              _buildTemplateField(
                context,
                controller: _imageTemplateController,
                label: t.settings.downloadSettings.imageFilenameTemplate,
                hint: t.settings.downloadSettings.suchAsTitleFilename,
                configKey: ConfigKey.IMAGE_FILENAME_TEMPLATE,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 查看支持的变量
        GlassSettingTile(
          icon: Icons.help_outline,
          title: Text(t.settings.downloadSettings.supportedVariables),
          trailing: Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onTap: () => _showVariableHelpDialog(context),
        ),
      ],
    );
  }

  Widget _buildTemplateField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required ConfigKey configKey,
  }) {
    final t = slang.Translations.of(context);
    return GlassInputSurface(
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        decoration: glassFieldDecoration(context, hint: hint, label: label)
            .copyWith(
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _resetTemplate(controller, configKey),
                tooltip: t.settings.downloadSettings.resetToDefault,
              ),
            ),
        onChanged: (value) {
          if (filenameTemplateService.validateTemplate(value)) {
            configService[configKey] = value;
          }
        },
      ),
    );
  }

  void _showVariableHelpDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    final variables = filenameTemplateService.getSupportedVariables();

    showAppDialog(
      GlassAlertDialog(
        title: t.settings.downloadSettings.supportedVariables,
        maxWidth: 600,
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.supportedVariablesDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),

            ...variables.map(
              (variable) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () =>
                        _copyVariableToClipboard(variable.variable, context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  variable.variable,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _copyVariableToClipboard(
                                  variable.variable,
                                  context,
                                ),
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip:
                                    t.settings.downloadSettings.copyVariable,
                                visualDensity: VisualDensity.compact,
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(36, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            variable.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetTemplate(TextEditingController controller, ConfigKey configKey) {
    final t = slang.Translations.of(context);
    final defaultValue = configKey.defaultValue as String;
    controller.text = defaultValue;
    configService[configKey] = defaultValue;

    showAppToast(
      t.settings.downloadSettings.templateResetToDefault,
      type: AppToastType.success,
    );
  }

  void _copyVariableToClipboard(String variable, BuildContext context) {
    final t = slang.Translations.of(context);
    Clipboard.setData(ClipboardData(text: variable));
    showAppToast(
      '${t.settings.downloadSettings.variableCopied}: $variable',
      type: AppToastType.success,
    );
  }
}
