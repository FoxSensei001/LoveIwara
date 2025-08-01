import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '推荐路径', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '选择一个推荐的下载位置', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            
            FutureBuilder<List<RecommendedPath>>(
              future: Get.find<DownloadPathService>().getRecommendedPaths(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final paths = snapshot.data ?? [];
                if (paths.isEmpty) {
                  return const Text('暂无推荐路径'); // TODO: 添加到国际化
                }

                return Column(
                  children: paths.map((recommendedPath) => 
                    _buildPathTile(recommendedPath)
                  ).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathTile(RecommendedPath recommendedPath) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：图标、名称和标签
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
                              child: const Text(
                                '推荐', // TODO: 添加到国际化
                                style: TextStyle(
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
                              child: const Text(
                                '需要权限', // TODO: 添加到国际化
                                style: TextStyle(
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
            const SizedBox(height: 8),
            
            // 描述
            Text(
              recommendedPath.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            
            // 路径
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
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            
            // 按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: recommendedPath.requiresPermission 
                    ? () => _requestPermissionAndSelect(recommendedPath)
                    : () => _selectPath(recommendedPath),
                child: Text(
                  recommendedPath.requiresPermission ? '授权并选择' : '选择', // TODO: 添加到国际化
                ),
              ),
            ),
          ],
        ),
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
    final permissionService = Get.find<PermissionService>();
    final granted = await permissionService.requestStoragePermission();
    
    if (granted) {
      await _selectPath(recommendedPath);
    } else {
      showToastWidget(
        MDToastWidget(
          message: '权限授权失败，无法选择此路径', // TODO: 添加到国际化
          type: MDToastType.error,
        ),
      );
    }
  }

  Future<void> _selectPath(RecommendedPath recommendedPath) async {
    try {
      // 验证路径
      final downloadPathService = Get.find<DownloadPathService>();
      final validationResult = await downloadPathService.validatePath(recommendedPath.path);
      
      if (!validationResult.isValid) {
        showToastWidget(
          MDToastWidget(
            message: '路径验证失败: ${validationResult.message}', // TODO: 添加到国际化
            type: MDToastType.error,
          ),
        );
        return;
      }
      
      // 设置路径
      await _configService.setSetting(ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH, true);
      await _configService.setSetting(ConfigKey.CUSTOM_DOWNLOAD_PATH, recommendedPath.path);
      
      showToastWidget(
        MDToastWidget(
          message: '下载路径已设置为: ${recommendedPath.name}', // TODO: 添加到国际化
          type: MDToastType.success,
        ),
      );
      
      widget.onPathSelected?.call();
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: '设置路径失败: $e', // TODO: 添加到国际化
          type: MDToastType.error,
        ),
      );
    }
  }
}
