import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/path_status_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/recommended_paths_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_status_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/utils/widget_extensions.dart';
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
          '下载设置', // TODO: 添加到国际化
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
                '下载设置', // TODO: 添加到国际化
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

            // 下载状态监控
            const DownloadStatusWidget(),
            const SizedBox(height: 24),

            // 下载统计
            const DownloadStatsWidget(),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '存储权限状态', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '访问公共目录需要存储权限', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<bool>(
              future: Get.find<PermissionService>().hasStoragePermission(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('检查权限状态...'), // TODO: 添加到国际化
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
                            hasPermission ? '已授权存储权限' : '需要存储权限', // TODO: 添加到国际化
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
                                  message: '权限授权成功', // TODO: 添加到国际化
                                  type: MDToastType.success,
                                ),
                              );
                            } else {
                              showToastWidget(
                                MDToastWidget(
                                  message: '权限授权失败，部分功能可能受限', // TODO: 添加到国际化
                                  type: MDToastType.warning,
                                ),
                              );
                            }

                            // 刷新状态
                            setState(() {});
                          },
                          icon: const Icon(Icons.security),
                          label: const Text('授权存储权限'), // TODO: 添加到国际化
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自定义下载位置', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '启用后可以为下载的文件选择自定义保存位置', // TODO: 添加到国际化
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
                            'Android提示：避免选择公共目录（如下载文件夹），建议使用应用专用目录以确保访问权限。', // TODO: 添加到国际化
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
              title: const Text('启用自定义下载路径'), // TODO: 添加到国际化
              subtitle: const Text('关闭时使用应用默认路径'), // TODO: 添加到国际化
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
                        labelText: '自定义下载路径', // TODO: 添加到国际化
                        hintText: '选择下载文件夹', // TODO: 添加到国际化
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
                              label: const Text('推荐路径'), // TODO: 添加到国际化
                            ),
                          ),
                        if (GetPlatform.isAndroid && isEnabled)
                          const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isEnabled ? _selectDownloadPath : null,
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: const Text('选择文件夹'), // TODO: 添加到国际化
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '文件命名模板', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '自定义下载文件的命名规则，支持变量替换', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            // 视频文件命名模板
            _buildTemplateField(
              context,
              controller: _videoTemplateController,
              label: '视频文件命名模板', // TODO: 添加到国际化
              hint: '例如: %title_%quality',
              configKey: ConfigKey.VIDEO_FILENAME_TEMPLATE,
            ),
            const SizedBox(height: 16),

            // 图库文件夹命名模板
            _buildTemplateField(
              context,
              controller: _galleryTemplateController,
              label: '图库文件夹命名模板', // TODO: 添加到国际化
              hint: '例如: %title_%id',
              configKey: ConfigKey.GALLERY_FILENAME_TEMPLATE,
            ),
            const SizedBox(height: 16),

            // 单张图片命名模板
            _buildTemplateField(
              context,
              controller: _imageTemplateController,
              label: '单张图片命名模板', // TODO: 添加到国际化
              hint: '例如: %title_%filename',
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _resetTemplate(controller, configKey),
          tooltip: '重置为默认值', // TODO: 添加到国际化
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
    final variables = filenameTemplateService.getSupportedVariables();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支持的变量', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '在文件命名模板中可以使用以下变量：', // TODO: 添加到国际化
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
    try {
      final String? directoryPath = await getDirectoryPath();
      if (directoryPath != null) {
        // 检查是否为Android公共目录
        if (GetPlatform.isAndroid && _isPublicDirectory(directoryPath)) {
          showToastWidget(
            MDToastWidget(
              message: '警告：选择的是公共目录，可能无法访问。建议选择应用专用目录。', // TODO: 添加到国际化
              type: MDToastType.warning,
            ),
          );
        }

        _customPathController.text = directoryPath;
        configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = directoryPath;

        showToastWidget(
          MDToastWidget(
            message: '下载路径已更新', // TODO: 添加到国际化
            type: MDToastType.success,
          ),
          position: ToastPosition.bottom,
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '选择路径失败: $e', // TODO: 添加到国际化
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
          message: '已设置为推荐路径', // TODO: 添加到国际化
          type: MDToastType.success,
        ),
      );
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '设置推荐路径失败: $e', // TODO: 添加到国际化
          type: MDToastType.error,
        ),
      );
    }
  }

  void _resetTemplate(TextEditingController controller, ConfigKey configKey) {
    final defaultValue = configKey.defaultValue as String;
    controller.text = defaultValue;
    configService[configKey] = defaultValue;

    showToastWidget(
      MDToastWidget(
        message: '已重置为默认模板', // TODO: 添加到国际化
        type: MDToastType.success,
      ),
    );
  }
}
