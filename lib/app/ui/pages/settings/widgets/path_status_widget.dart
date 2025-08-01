import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/download_path_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

/// 路径状态显示组件
class PathStatusWidget extends StatefulWidget {
  final VoidCallback? onPathChanged;

  const PathStatusWidget({
    super.key,
    this.onPathChanged,
  });

  @override
  State<PathStatusWidget> createState() => _PathStatusWidgetState();
}

class _PathStatusWidgetState extends State<PathStatusWidget> {
  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return FutureBuilder<PathStatusInfo>(
      future: Get.find<DownloadPathService>().getPathStatusInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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

        final pathInfo = snapshot.data;
        if (pathInfo == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(16),
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
                  ],
                ),
                const SizedBox(height: 12),

                // 路径信息
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pathInfo.currentPath,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (pathInfo.selectedPath != null &&
                          pathInfo.selectedPath != pathInfo.currentPath) ...[
                        const SizedBox(height: 4),
                        Text(
                          t.settings.downloadSettings.actualPathDifferentFromSelected,
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
                      onPressed: () => _fixPathIssue(pathInfo.validationResult.reason),
                      icon: const Icon(Icons.build),
                      label: Text(_getFixButtonText(pathInfo.validationResult.reason)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
    final downloadPathService = Get.find<DownloadPathService>();
    final success = await downloadPathService.fixPathIssue(reason);

    if (success) {
      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.issueFixed,
          type: MDToastType.success,
        ),
      );
      setState(() {}); // 刷新状态
      widget.onPathChanged?.call();
    } else {
      showToastWidget(
        MDToastWidget(
          message: t.settings.downloadSettings.fixFailed,
          type: MDToastType.error,
        ),
      );
    }
  }
}
