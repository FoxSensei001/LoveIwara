import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/path_status_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/recommended_paths_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart' show showToastWidget, ToastPosition;

import '../../widgets/MDToastWidget.dart' show MDToastWidget, MDToastType;

class DownloadSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const DownloadSettingsPage({
    super.key,
    this.isWideScreen = false,
  });

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  final ConfigService configService = Get.find<ConfigService>();
  late FilenameTemplateService filenameTemplateService;

  final TextEditingController _customPathController = TextEditingController();
  final TextEditingController _videoTemplateController = TextEditingController();
  final TextEditingController _galleryTemplateController = TextEditingController();
  final TextEditingController _imageTemplateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 获取文件命名模板服务
    filenameTemplateService = Get.find<FilenameTemplateService>();

    // 初始化控制器值
    _customPathController.text = configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] ?? '';
    _videoTemplateController.text = configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] ?? '%title_%quality';
    _galleryTemplateController.text = configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] ?? '%title_%id';
    _imageTemplateController.text = configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] ?? '%title_%filename';
  }

  @override
  void dispose() {
    _customPathController.dispose();
    _videoTemplateController.dispose();
    _galleryTemplateController.dispose();
    _imageTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Scaffold(
      appBar: widget.isWideScreen ? null : AppBar(
        title: Text(
          t.settings.downloadSettings.downloadSettings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isWideScreen) ...[
              Text(
                t.settings.downloadSettings.downloadSettings,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 权限状态显示
            _buildPermissionSection(context),
            const SizedBox(height: 24),

            // 路径状态显示
            PathStatusWidget(
              onPathChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),

            // 推荐路径选择
            RecommendedPathsWidget(
              onPathSelected: () => setState(() {}),
            ),
            const SizedBox(height: 24),

            // 自定义下载路径设置
            _buildCustomPathSection(context),
            const SizedBox(height: 24),

            // 文件命名模板设置
            _buildFilenameTemplateSection(context),
            const SizedBox(height: 24),

            // 支持的变量说明
            _buildVariableHelpSection(context),
            const SizedBox(height: 24),

            // 功能测试
            const DownloadTestWidget(),
            const SafeArea(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(BuildContext context) {
    if (!GetPlatform.isAndroid) {
      return const SizedBox.shrink(); // 非Android平台不显示权限状态
    }

    final t = slang.Translations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( 
              t.settings.downloadSettings.storagePermissionStatus,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.accessPublicDirectoryNeedStoragePermission,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<bool>(
              future: Get.find<PermissionService>().hasStoragePermission(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(t.settings.downloadSettings.checkingPermissionStatus),
                    ],
                  );
                }

                final hasPermission = snapshot.data ?? false;

                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasPermission ? Icons.check_circle : Icons.error,
                          color: hasPermission ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasPermission ? t.settings.downloadSettings.storagePermissionGranted : t.settings.downloadSettings.storagePermissionNotGranted,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: hasPermission ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (!hasPermission) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final permissionService = Get.find<PermissionService>();
                            final granted = await permissionService.requestStoragePermission();

                            if (granted) {
                              showToastWidget(
                                MDToastWidget(
                                  message: t.settings.downloadSettings.storagePermissionGrantSuccess,
                                  type: MDToastType.success,
                                ),
                              );
                            } else {
                              showToastWidget(
                                MDToastWidget(
                                  message: t.settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited,
                                  type: MDToastType.warning,
                                ),
                              );
                            }

                            // 刷新状态
                            setState(() {});
                          },
                          icon: const Icon(Icons.security),
                          label: Text(t.settings.downloadSettings.grantStoragePermission),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Get.find<PermissionService>().getPermissionDescription(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPathSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.customDownloadPath,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.customDownloadPathDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (GetPlatform.isAndroid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.settings.downloadSettings.androidWarning,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // 启用开关
            Obx(() => SwitchListTile(
              title: Text(t.settings.downloadSettings.enableCustomDownloadPath),
              subtitle: Text(t.settings.downloadSettings.disableCustomDownloadPath),
              value: configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] ?? false,
              onChanged: (value) {
                configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] = value;
              },
            )),
            
            // 路径选择
            Obx(() {
              final isEnabled = configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] ?? false;
              return AnimatedOpacity(
                opacity: isEnabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customPathController,
                      enabled: isEnabled,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: t.settings.downloadSettings.customDownloadPathLabel,
                        hintText: t.settings.downloadSettings.selectDownloadFolder,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (GetPlatform.isAndroid && isEnabled)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _useRecommendedPath,
                              icon: const Icon(Icons.recommend, size: 18),
                              label: Text(t.settings.downloadSettings.recommendedPath),
                            ),
                          ),
                        if (GetPlatform.isAndroid && isEnabled)
                          const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isEnabled ? _selectDownloadPath : null,
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: Text(t.settings.downloadSettings.selectFolder),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilenameTemplateSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.filenameTemplate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.filenameTemplateDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            // 视频文件命名模板
            _buildTemplateField(
              context,
              controller: _videoTemplateController,
              label: t.settings.downloadSettings.videoFilenameTemplate,
              hint: t.settings.downloadSettings.suchAsTitleQuality,
              configKey: ConfigKey.VIDEO_FILENAME_TEMPLATE,
            ),
            const SizedBox(height: 16),

            // 图库文件夹命名模板
            _buildTemplateField(
              context,
              controller: _galleryTemplateController,
              label: t.settings.downloadSettings.galleryFolderTemplate,
              hint: t.settings.downloadSettings.suchAsTitleId,
              configKey: ConfigKey.GALLERY_FILENAME_TEMPLATE,
            ),
            const SizedBox(height: 16),

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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
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
    );
  }

  Widget _buildVariableHelpSection(BuildContext context) {
    final t = slang.Translations.of(context);
    final variables = filenameTemplateService.getSupportedVariables();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.supportedVariables,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.supportedVariablesDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            ...variables.map((variable) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          variable.variable,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          variable.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDownloadPath() async {
    final t = slang.Translations.of(context);
    try {
      final String? directoryPath = await getDirectoryPath();
      if (directoryPath != null) {
        // 检查是否为Android公共目录
        if (GetPlatform.isAndroid && _isPublicDirectory(directoryPath)) {
          showToastWidget(
            MDToastWidget(
              message: t.settings.downloadSettings.warningPublicDirectory,
              type: MDToastType.warning,
            ),
          );
        }

        _customPathController.text = directoryPath;
        configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = directoryPath;

        showToastWidget(
          MDToastWidget(
            message: t.settings.downloadSettings.downloadPathUpdated,
            type: MDToastType.success,
          ),
          position: ToastPosition.bottom,
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '${t.settings.downloadSettings.selectPathFailed}: $e',
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  /// 检查是否为Android公共目录
  bool _isPublicDirectory(String dirPath) {
    final publicPaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/下载',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Documents',
      '/sdcard/Download',
      '/sdcard/下载',
      '/sdcard/Pictures',
      '/sdcard/Movies',
      '/sdcard/Music',
      '/sdcard/Documents',
    ];

    return publicPaths.any((publicPath) => dirPath.startsWith(publicPath));
  }

  Future<void> _useRecommendedPath() async {
    final t = slang.Translations.of(context);
    try {
      if (!Get.isRegistered<DownloadPathService>()) {
        Get.put(DownloadPathService());
      }
      final downloadPathService = Get.find<DownloadPathService>();
      final recommendedPath = await downloadPathService.getRecommendedDownloadPath();

      _customPathController.text = recommendedPath;
      configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = recommendedPath;

      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.recommendedPathSet,
          type: MDToastType.success,
        ),
      );
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '${t.settings.downloadSettings.setRecommendedPathFailed}: $e',
          type: MDToastType.error,
        ),
      );
    }
  }

  void _resetTemplate(TextEditingController controller, ConfigKey configKey) {
    final t = slang.Translations.of(context);
    final defaultValue = configKey.defaultValue as String;
    controller.text = defaultValue;
    configService[configKey] = defaultValue;

    showToastWidget(
      MDToastWidget(
        message: t.settings.downloadSettings.templateResetToDefault,
        type: MDToastType.success,
      ),
    );
  }
}
