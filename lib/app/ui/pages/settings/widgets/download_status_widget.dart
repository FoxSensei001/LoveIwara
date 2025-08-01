import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/permission_service.dart';
import 'package:i_iwara/app/services/filename_template_service.dart';

/// 下载状态监控组件
class DownloadStatusWidget extends StatefulWidget {
  const DownloadStatusWidget({super.key});

  @override
  State<DownloadStatusWidget> createState() => _DownloadStatusWidgetState();
}

class _DownloadStatusWidgetState extends State<DownloadStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '下载配置概览', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            FutureBuilder<Map<String, dynamic>>(
              future: _getDownloadInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final info = snapshot.data ?? {};
                return Column(
                  children: [
                    _buildInfoRow(
                      context,
                      '当前路径策略',
                      info['pathStrategy'] ?? '未知',
                      Icons.folder,
                    ),
                    _buildInfoRow(
                      context,
                      '视频命名模板',
                      info['videoTemplate'] ?? '未设置',
                      Icons.video_file,
                    ),
                    _buildInfoRow(
                      context,
                      '图库命名模板',
                      info['galleryTemplate'] ?? '未设置',
                      Icons.photo_library,
                    ),
                    _buildInfoRow(
                      context,
                      '图片命名模板',
                      info['imageTemplate'] ?? '未设置',
                      Icons.image,
                    ),
                    if (info['warnings'] != null && (info['warnings'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildWarningsSection(context, info['warnings'] as List<String>),
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

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection(BuildContext context, List<String> warnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                '注意事项', // TODO: 添加到国际化
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $warning',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getDownloadInfo() async {
    final configService = Get.find<ConfigService>();
    final downloadPathService = Get.find<DownloadPathService>();
    
    final isCustomPathEnabled = configService[ConfigKey.ENABLE_CUSTOM_DOWNLOAD_PATH] as bool;
    final customPath = configService[ConfigKey.CUSTOM_DOWNLOAD_PATH] as String;
    final videoTemplate = configService[ConfigKey.VIDEO_FILENAME_TEMPLATE] as String;
    final galleryTemplate = configService[ConfigKey.GALLERY_FILENAME_TEMPLATE] as String;
    final imageTemplate = configService[ConfigKey.IMAGE_FILENAME_TEMPLATE] as String;
    
    final pathInfo = await downloadPathService.getPathStatusInfo();
    final warnings = <String>[];
    
    // 检查路径策略
    String pathStrategy;
    if (!isCustomPathEnabled) {
      pathStrategy = '应用专用目录';
    } else if (pathInfo.isValid) {
      pathStrategy = '自定义路径';
    } else {
      pathStrategy = '自定义路径（已回退到应用专用目录）';
      warnings.add('自定义路径无法访问，已自动使用应用专用目录');
    }
    
    // 检查模板有效性
    final filenameService = Get.find<FilenameTemplateService>();
    if (!filenameService.validateTemplate(videoTemplate)) {
      warnings.add('视频命名模板可能包含无效字符');
    }
    if (!filenameService.validateTemplate(galleryTemplate)) {
      warnings.add('图库命名模板可能包含无效字符');
    }
    if (!filenameService.validateTemplate(imageTemplate)) {
      warnings.add('图片命名模板可能包含无效字符');
    }
    
    // Android特定警告
    if (GetPlatform.isAndroid && isCustomPathEnabled && customPath.isNotEmpty) {
      // 检查是否为公共目录
      final publicPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/下载',
        '/storage/emulated/0/Pictures',
        '/storage/emulated/0/Movies',
      ];

      final isPublicDir = publicPaths.any((publicPath) => customPath.startsWith(publicPath));
      if (isPublicDir) {
        final permissionService = Get.find<PermissionService>();
        final canAccess = await permissionService.canAccessPublicDirectories();
        if (!canAccess) {
          warnings.add('选择的是公共目录但缺少相应权限');
        }
      }
    }
    
    return {
      'pathStrategy': pathStrategy,
      'videoTemplate': videoTemplate,
      'galleryTemplate': galleryTemplate,
      'imageTemplate': imageTemplate,
      'warnings': warnings,
    };
  }
}

/// 下载统计信息组件
class DownloadStatsWidget extends StatelessWidget {
  const DownloadStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '下载统计', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 这里可以添加下载统计信息
            // 比如总下载数量、成功率、存储使用情况等
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '总下载', '0', Icons.download),
                _buildStatItem(context, '成功', '0', Icons.check_circle),
                _buildStatItem(context, '失败', '0', Icons.error),
              ],
            ),
            
            const SizedBox(height: 12),
            Text(
              '注：统计功能将在后续版本中完善', // TODO: 添加到国际化
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
