import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_selector/file_selector.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/recommended_paths_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/download_test_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart' show showToastWidget, ToastPosition;

import '../../widgets/MDToastWidget.dart' show MDToastWidget, MDToastType;

class DownloadSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const DownloadSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<DownloadSettingsPage> createState() => _DownloadSettingsPageState();
}

class _DownloadSettingsPageState extends State<DownloadSettingsPage> {
  final ConfigService configService = Get.find<ConfigService>();
  late FilenameTemplateService filenameTemplateService;
  late DownloadPathService downloadPathService;
  late PermissionService permissionService;

  final TextEditingController _customPathController = TextEditingController();
  final TextEditingController _videoTemplateController =
      TextEditingController();
  final TextEditingController _galleryTemplateController =
      TextEditingController();
  final TextEditingController _imageTemplateController =
      TextEditingController();

  // 添加焦点节点和状态管理
  final FocusNode _customPathFocusNode = FocusNode();
  bool _isUpdatingFromConfig = false; // 防止循环更新的标志位

  @override
  void initState() {
    super.initState();

    // 获取文件命名模板服务
    filenameTemplateService = Get.find<FilenameTemplateService>();
    // 缓存服务实例
    downloadPathService = Get.find<DownloadPathService>();
    permissionService = Get.find<PermissionService>();

    // 初始化控制器值
    _customPathController.text =
        configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] ?? '';
    _videoTemplateController.text =
        configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] ?? '%title_%quality';
    _galleryTemplateController.text =
        configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] ?? '%title_%id';
    _imageTemplateController.text =
        configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] ?? '%title_%filename';

    // 添加焦点监听器
    _customPathFocusNode.addListener(_onCustomPathFocusChanged);
  }

  /// 处理自定义路径输入框焦点变化
  void _onCustomPathFocusChanged() {
    // 当输入框失去焦点时，检查是否需要同步配置
    if (!_customPathFocusNode.hasFocus && !_isUpdatingFromConfig) {
      _syncCustomPathFromConfig();
      // 失去焦点后进行路径验证刷新
      downloadPathService.refreshPathStatus();
    }
  }

  /// 从配置同步自定义路径到控制器
  void _syncCustomPathFromConfig() {
    final configPath = configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] ?? '';
    if (_customPathController.text != configPath) {
      _isUpdatingFromConfig = true;
      _customPathController.text = configPath;
      // 使用 PostFrameCallback 确保在下一帧重置标志位
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isUpdatingFromConfig = false;
      });
    }
  }

  @override
  void dispose() {
    _customPathFocusNode.removeListener(_onCustomPathFocusChanged);
    _customPathFocusNode.dispose();
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
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.downloadSettings.downloadSettings,
            isWideScreen: widget.isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 文件命名模板设置
                _buildFilenameTemplateSection(context),
                const SizedBox(height: 16),

                // 推荐路径选择
                RecommendedPathsWidget(
                  key: const ValueKey('recommended_paths'),
                  onPathSelected: () {
                    // 同步自定义路径控制器
                    _syncCustomPathFromConfig();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),

                // 权限状态显示
                _buildPermissionSection(context),
                const SizedBox(height: 16),

                // 路径状态显示
                _buildPathStatusWidget(context),
                const SizedBox(height: 16),

                // 自定义下载路径设置
                _buildCustomPathSection(context),
                const SizedBox(height: 16),

                // 功能测试
                const DownloadTestWidget(key: ValueKey('download_test')),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSection(BuildContext context) {
    if (!GetPlatform.isAndroid) {
      return const SizedBox.shrink(); // 非Android平台不显示权限状态
    }

    final t = slang.Translations.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t.settings.downloadSettings.storagePermissionStatus,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => DownloadTestWidget.showTestDialog(context),
                  icon: const Icon(Icons.bug_report, size: 18),
                  tooltip: t.settings.downloadSettings.functionalTest,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t
                  .settings
                  .downloadSettings
                  .accessPublicDirectoryNeedStoragePermission,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (downloadPathService.isStoragePermissionLoading) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(t.settings.downloadSettings.checkingPermissionStatus),
                  ],
                );
              }

              final hasPermission = downloadPathService.storagePermissionGranted;

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
                          hasPermission
                              ? t.settings.downloadSettings.storagePermissionGranted
                              : t.settings.downloadSettings.storagePermissionNotGranted,
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
                          await downloadPathService.refreshPermissionAndRelated();
                        },
                        icon: const Icon(Icons.security),
                        label: Text(
                          t.settings.downloadSettings.grantStoragePermission,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      permissionService.getPermissionDescription(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPathStatusWidget(BuildContext context) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final isLoading = downloadPathService.isPathStatusLoading;
      final pathInfo = downloadPathService.pathStatus;

      if (isLoading && pathInfo == null) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(t.settings.downloadSettings.checkingPathStatus),
              ],
            ),
          ),
        );
      }

      if (pathInfo == null) {
        final defaultPath = downloadPathService.defaultDownloadPath.isNotEmpty
            ? downloadPathService.defaultDownloadPath
            : '';
        return _buildPathStatusCard(
          context,
          PathStatusInfo(
            currentPath: defaultPath,
            isCustomPath: false,
            isValid: true,
            validationResult: PathValidationResult(
              isValid: true,
              reason: PathValidationReason.valid,
              message: t.settings.downloadSettings.usingDefaultAppDirectory,
              canFix: false,
            ),
          ),
        );
      }

      return _buildPathStatusCard(context, pathInfo);
    });
  }

  Widget _buildPathStatusCard(BuildContext context, PathStatusInfo pathInfo) {
    final t = slang.Translations.of(context);

    // Handle default path case
    if (!pathInfo.isCustomPath) {
      final defaultPath = downloadPathService.defaultDownloadPath.isNotEmpty
          ? downloadPathService.defaultDownloadPath
          : t.settings.downloadSettings.checkingPathStatus;
      final updatedPathInfo = PathStatusInfo(
        currentPath: defaultPath,
        isCustomPath: false,
        isValid: true,
        validationResult: pathInfo.validationResult,
      );
      return _buildPathInfoCard(context, updatedPathInfo);
    }

    return _buildPathInfoCard(context, pathInfo);
  }

  Widget _buildPathInfoCard(BuildContext context, PathStatusInfo pathInfo) {
    final t = slang.Translations.of(context);

    if (pathInfo.currentPath.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Text(t.settings.downloadSettings.unableToGetPathStatus),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  pathInfo.isValid ? Icons.folder : Icons.folder_off,
                  color: pathInfo.isValid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  t.settings.downloadSettings.currentDownloadPath,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => DownloadTestWidget.showTestDialog(context),
                  icon: const Icon(Icons.bug_report, size: 18),
                  tooltip: t.settings.downloadSettings.functionalTest,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 路径信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pathInfo.currentPath,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                    softWrap: true,
                  ),
                  if (pathInfo.selectedPath != null &&
                      pathInfo.selectedPath != pathInfo.currentPath) ...[
                    const SizedBox(height: 4),
                    Text(
                      t
                          .settings
                          .downloadSettings
                          .actualPathDifferentFromSelected,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 状态信息
            Row(
              children: [
                Icon(
                  _getStatusIcon(pathInfo.validationResult.reason),
                  size: 16,
                  color: _getStatusColor(pathInfo.validationResult),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pathInfo.validationResult.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getStatusColor(pathInfo.validationResult),
                    ),
                  ),
                ),
              ],
            ),

            // 操作按钮
            if (pathInfo.validationResult.canFix) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _fixPathIssue(pathInfo.validationResult.reason),
                  icon: const Icon(Icons.build),
                  label: Text(
                    _getFixButtonText(pathInfo.validationResult.reason),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(PathValidationReason reason) {
    switch (reason) {
      case PathValidationReason.valid:
        return Icons.check_circle;
      case PathValidationReason.noPermission:
      case PathValidationReason.noPublicDirectoryAccess:
        return Icons.security;
      case PathValidationReason.cannotCreate:
      case PathValidationReason.notWritable:
        return Icons.error;
      case PathValidationReason.lowSpace:
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(PathValidationResult result) {
    if (!result.isValid) {
      return Colors.red;
    } else if (result.isWarning) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getFixButtonText(PathValidationReason reason) {
    final t = slang.Translations.of(context);
    switch (reason) {
      case PathValidationReason.noPermission:
      case PathValidationReason.noPublicDirectoryAccess:
        return t.settings.downloadSettings.grantPermission;
      default:
        return t.settings.downloadSettings.fixIssue;
    }
  }

  Future<void> _fixPathIssue(PathValidationReason reason) async {
    final t = slang.Translations.of(context);
      final success = await downloadPathService.fixPathIssue(reason);

    if (success) {
      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.issueFixed,
          type: MDToastType.success,
        ),
      );
      await downloadPathService.refreshPathStatus();
    } else {
      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.fixFailed,
          type: MDToastType.error,
        ),
      );
    }
  }

  Widget _buildCustomPathSection(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t.settings.downloadSettings.customDownloadPath,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.customDownloadPathDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),

            // 通用提示信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.settings.downloadSettings.customDownloadPathTip,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (GetPlatform.isAndroid) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.5),
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
            Obx(
              () => SwitchListTile(
                title: Text(
                  t.settings.downloadSettings.enableCustomDownloadPath,
                ),
                subtitle: Text(
                  t.settings.downloadSettings.disableCustomDownloadPath,
                ),
                value:
                    configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] ??
                    false,
                onChanged: (value) async {
                  configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] = value;
                  await downloadPathService.refreshPathStatus();
                },
              ),
            ),

            // 路径选择
            Obx(() {
              final isEnabled =
                  configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] ?? false;
              final currentPath =
                  configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] ?? '';
              final isPublicDirectory =
                  GetPlatform.isAndroid &&
                  currentPath.isNotEmpty &&
                  _isPublicDirectory(currentPath);

              // 同步配置到控制器（仅在失去焦点且不是用户输入时）
              if (!_customPathFocusNode.hasFocus &&
                  !_isUpdatingFromConfig &&
                  _customPathController.text != currentPath) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _syncCustomPathFromConfig();
                });
              }

              return AnimatedOpacity(
                opacity: isEnabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customPathController,
                      focusNode: _customPathFocusNode,
                      enabled: isEnabled,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText:
                            t.settings.downloadSettings.customDownloadPathLabel,
                        hintText:
                            t.settings.downloadSettings.selectDownloadFolder,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        // 只有在不是从配置更新时才更新配置
                        if (!_isUpdatingFromConfig) {
                          configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = value;
                        }
                      },
                    ),

                    // 公共目录权限提示
                    if (isEnabled && isPublicDirectory) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t
                                        .settings
                                        .downloadSettings
                                        .publicDirectoryPermissionTip,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.orange.shade800,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Obx(() {
                                    final hasPermission = downloadPathService.storagePermissionGranted;
                                    if (!hasPermission) {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            final granted = await permissionService.requestStoragePermission();
                                            if (granted) {
                                              showToastWidget(
                                                MDToastWidget(
                                                  message: t.settings.downloadSettings.storagePermissionGrantSuccess,
                                                  type: MDToastType.success,
                                                ),
                                              );
                                            }
                                            await downloadPathService.refreshPermissionAndRelated();
                                          },
                                          icon: const Icon(
                                            Icons.security,
                                            size: 16,
                                          ),
                                          label: Text(
                                            t.settings.downloadSettings.grantStoragePermission,
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            t.settings.downloadSettings.storagePermissionGranted,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    // 推荐路径和选择文件夹按钮放在一行
                    Row(
                      children: [
                        if (GetPlatform.isAndroid && isEnabled)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _useRecommendedPath,
                              icon: const Icon(Icons.recommend, size: 18),
                              label: Text(
                                t.settings.downloadSettings.recommendedPath,
                              ),
                            ),
                          ),
                        if (GetPlatform.isAndroid && isEnabled)
                          const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isEnabled ? _selectDownloadPath : null,
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: Text(
                              t.settings.downloadSettings.selectFolder,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 运行测试按钮单独一行
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isEnabled
                            ? () => DownloadTestWidget.showTestDialog(context)
                            : null,
                        icon: const Icon(Icons.bug_report, size: 18),
                        label: Text(t.settings.downloadSettings.runTest),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_fields,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  t.settings.downloadSettings.filenameTemplate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
            const SizedBox(height: 16),

            // 查看支持的变量按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showVariableHelpDialog(context),
                icon: const Icon(Icons.help_outline, size: 18),
                label: Text(t.settings.downloadSettings.supportedVariables),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
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

  void _showVariableHelpDialog(BuildContext context) {
    final t = slang.Translations.of(context);
    final variables = filenameTemplateService.getSupportedVariables();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题栏
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.settings.downloadSettings.supportedVariables,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

                // 内容区域
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t
                              .settings
                              .downloadSettings
                              .supportedVariablesDescription,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
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
                                onTap: () => _copyVariableToClipboard(
                                  variable.variable,
                                  context,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              variable.variable,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () =>
                                                _copyVariableToClipboard(
                                                  variable.variable,
                                                  context,
                                                ),
                                            icon: const Icon(
                                              Icons.copy,
                                              size: 18,
                                            ),
                                            tooltip: t
                                                .settings
                                                .downloadSettings
                                                .copyVariable,
                                            visualDensity:
                                                VisualDensity.compact,
                                            style: IconButton.styleFrom(
                                              minimumSize: const Size(36, 36),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        variable.description,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDownloadPath() async {
    final t = slang.Translations.of(context);
    try {
      final String? directoryPath = await getDirectoryPath();
      if (directoryPath != null) {
        _isUpdatingFromConfig = true;
        _customPathController.text = directoryPath;
        configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = directoryPath;
        _isUpdatingFromConfig = false;

        // 检查是否为Android公共目录并给出相应提示
        if (GetPlatform.isAndroid && _isPublicDirectory(directoryPath)) {
          // 检查权限状态
      final hasPermission = await permissionService.hasStoragePermission();

          if (!hasPermission) {
            showToastWidget(
              MDToastWidget(
                message: t
                    .settings
                    .downloadSettings
                    .permissionRequiredForPublicDirectory,
                type: MDToastType.warning,
              ),
            );
          } else {
            showToastWidget(
              MDToastWidget(
                message: t.settings.downloadSettings.downloadPathUpdated,
                type: MDToastType.success,
              ),
              position: ToastPosition.bottom,
            );
          }
        } else {
          showToastWidget(
            MDToastWidget(
              message: t.settings.downloadSettings.downloadPathUpdated,
              type: MDToastType.success,
            ),
            position: ToastPosition.bottom,
          );
        }

        // 刷新路径状态
        await downloadPathService.refreshPathStatus();
      }
    } catch (e) {
      LogUtils.e('选择下载路径失败', error: e, tag: 'DownloadSettingsPage');
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
      final recommendedPath = await downloadPathService
          .getRecommendedDownloadPath();

      _isUpdatingFromConfig = true;
      _customPathController.text = recommendedPath;
      configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] = recommendedPath;
      _isUpdatingFromConfig = false;

      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.recommendedPathSet,
          type: MDToastType.success,
        ),
      );
      await downloadPathService.refreshPathStatus();
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message:
              '${t.settings.downloadSettings.setRecommendedPathFailed}: $e',
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

  void _copyVariableToClipboard(String variable, BuildContext context) {
    final t = slang.Translations.of(context);
    Clipboard.setData(ClipboardData(text: variable));
    showToastWidget(
      MDToastWidget(
        message: '${t.settings.downloadSettings.variableCopied}: $variable',
        type: MDToastType.success,
      ),
    );
  }
}
