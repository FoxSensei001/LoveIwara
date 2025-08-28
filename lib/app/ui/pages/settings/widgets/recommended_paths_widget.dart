import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

/// 推荐路径选择组件
class RecommendedPathsWidget extends StatefulWidget {
  final VoidCallback? onPathSelected;

  const RecommendedPathsWidget({
    super.key,
    this.onPathSelected,
  });

  @override
  State<RecommendedPathsWidget> createState() => _RecommendedPathsWidgetState();
}

class _RecommendedPathsWidgetState extends State<RecommendedPathsWidget> {
  final ConfigService _configService = Get.find<ConfigService>();
  late DownloadPathService _downloadPathService;
  late PermissionService _permissionService;

  @override
  void initState() {
    super.initState();
    _downloadPathService = Get.find<DownloadPathService>();
    _permissionService = Get.find<PermissionService>();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.downloadSettings.recommendedPaths,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.settings.downloadSettings.selectRecommendedDownloadLocation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            Obx(() {
              if (_downloadPathService.isRecommendedPathsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final paths = _downloadPathService.recommendedPaths;
              if (paths.isEmpty) {
                return Text(t.settings.downloadSettings.noRecommendedPaths);
              }
              return Column(
                children: paths
                    .map((recommendedPath) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPathTile(recommendedPath),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPathTile(RecommendedPath recommendedPath) {
    final t = slang.Translations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPathIcon(recommendedPath.type),
                color: recommendedPath.isRecommended ? Colors.green : 
                       recommendedPath.requiresPermission ? Colors.orange : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendedPath.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (recommendedPath.isRecommended || recommendedPath.requiresPermission)
                      const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (recommendedPath.isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t.settings.downloadSettings.recommended,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (recommendedPath.requiresPermission)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              t.settings.downloadSettings.requiresPermission,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            recommendedPath.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              recommendedPath.path,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: recommendedPath.requiresPermission 
                  ? () => _requestPermissionAndSelect(recommendedPath)
                  : () => _selectPath(recommendedPath),
              child: Text(
                recommendedPath.requiresPermission ? t.settings.downloadSettings.authorizeAndSelect : t.settings.downloadSettings.select,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPathIcon(RecommendedPathType type) {
    switch (type) {
      case RecommendedPathType.appPrivate:
        return Icons.security;
      case RecommendedPathType.publicDownload:
        return Icons.download;
      case RecommendedPathType.publicMovies:
        return Icons.movie;
      case RecommendedPathType.custom:
        return Icons.folder;
    }
  }

  Future<void> _requestPermissionAndSelect(RecommendedPath recommendedPath) async {
    final t = slang.Translations.of(context);
    final granted = await _permissionService.requestStoragePermission();

    if (granted) {
      await _selectPath(recommendedPath);
      await _downloadPathService.refreshPermissionAndRelated();
    } else {
      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.permissionAuthorizationFailed,
          type: MDToastType.error,
        ),
      );
    }
  }

  Future<void> _selectPath(RecommendedPath recommendedPath) async {
    final t = slang.Translations.of(context);
    try {
      // 验证路径
      final validationResult = await _downloadPathService.validatePath(recommendedPath.path);
      
      if (!validationResult.isValid) {
        showToastWidget(
          MDToastWidget(
            message: '${t.settings.downloadSettings.pathValidationFailed}: ${validationResult.message}',
            type: MDToastType.error,
          ),
        );
        return;
      }
      
      // 设置路径
      await _configService.setSetting(ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH, true);
      await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, recommendedPath.path);
      await _downloadPathService.refreshPathStatus();
      
      showToastWidget(
        MDToastWidget(
          message: '${t.settings.downloadSettings.downloadPathSetTo}: ${recommendedPath.name}',
          type: MDToastType.success,
        ),
      );
      
      widget.onPathSelected?.call();
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '${t.settings.downloadSettings.setPathFailed}: $e',
          type: MDToastType.error,
        ),
      );
    }
  }
}
