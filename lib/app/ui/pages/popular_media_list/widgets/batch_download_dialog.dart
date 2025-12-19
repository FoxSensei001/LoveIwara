import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/batch_download_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 批量下载对话框
/// 包含三个阶段：清晰度选择、下载进度、下载结果
/// 支持视频和图库两种媒体类型
class BatchDownloadDialog<T> extends StatefulWidget {
  final List<T> mediaItems;
  final VoidCallback? onComplete;

  const BatchDownloadDialog({
    super.key,
    required this.mediaItems,
    this.onComplete,
  });

  /// 显示批量下载对话框
  static Future<void> show<T>({
    required List<T> mediaItems,
    VoidCallback? onComplete,
  }) {
    return Get.dialog(
      BatchDownloadDialog<T>(mediaItems: mediaItems, onComplete: onComplete),
      barrierDismissible: false,
    );
  }

  @override
  State<BatchDownloadDialog<T>> createState() => _BatchDownloadDialogState<T>();
}

class _BatchDownloadDialogState<T> extends State<BatchDownloadDialog<T>> {
  final BatchDownloadService _batchDownloadService =
      Get.find<BatchDownloadService>();
  final ConfigService _configService = Get.find<ConfigService>();

  // 对话框阶段
  _DialogPhase _phase = _DialogPhase.selectQuality;

  // 选中的清晰度
  String _selectedQuality = 'Source';

  // 可选清晰度列表
  final List<String> _qualityOptions = ['Source', 'Preview', '540', '360'];

  // 下载结果
  BatchDownloadResult? _result;

  // 判断是否为视频下载
  bool get _isVideoDownload {
    if (T == Video) return true;
    if (T == ImageModel) return false;
    // 如果 T 是 dynamic 或 Object，则根据列表内容的真实类型判断
    if (widget.mediaItems.isNotEmpty) {
      final firstItem = widget.mediaItems.first;
      if (firstItem is Video) return true;
      if (firstItem is ImageModel) return false;
    }
    return true; // 默认视频
  }

  @override
  void initState() {
    super.initState();
    // 图库下载直接开始，不需要选择清晰度
    if (!_isVideoDownload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startDownload();
      });
    } else {
      // 视频下载：尝试读取上次选择的清晰度
      final lastQuality =
          _configService[ConfigKey.LAST_DOWNLOAD_QUALITY] as String?;
      if (lastQuality != null && lastQuality.isNotEmpty) {
        // 检查是否在可选列表中
        final matchIndex = _qualityOptions.indexWhere(
          (q) => q.toLowerCase() == lastQuality.toLowerCase(),
        );
        if (matchIndex != -1) {
          _selectedQuality = _qualityOptions[matchIndex];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final title = _getTitle(t);

    LogUtils.d('构建批量下载对话框, 阶段: $_phase, 标题: $title', 'BatchDownloadDialog');

    return AlertDialog(
      title: Text(title.isNotEmpty ? title : t.download.batchDownload.title),
      content: SizedBox(
        width: 400, // 给予一个基础宽度，防止 layout 问题
        child: SingleChildScrollView(child: _buildContent(context, t)),
      ),
      actions: _buildActions(t),
    );
  }

  String _getTitle(slang.Translations t) {
    switch (_phase) {
      case _DialogPhase.selectQuality:
        return t.download.batchDownload.selectQuality;
      case _DialogPhase.downloading:
        return t.download.batchDownload.downloading;
      case _DialogPhase.result:
        return t.download.batchDownload.downloadResult;
    }
  }

  Widget _buildContent(BuildContext context, slang.Translations t) {
    switch (_phase) {
      case _DialogPhase.selectQuality:
        return _buildQualitySelection(context, t);
      case _DialogPhase.downloading:
        return _buildDownloadProgress(context, t);
      case _DialogPhase.result:
        return _buildResult(context, t);
    }
  }

  Widget _buildQualitySelection(BuildContext context, slang.Translations t) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isVideoDownload
              ? t.download.batchDownload.selectedVideosCount(
                  count: widget.mediaItems.length,
                )
              : t.download.batchDownload.selectedGalleriesCount(
                  count: widget.mediaItems.length,
                ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Text(
          t.download.batchDownload.qualityNote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_qualityOptions.length, (index) {
          final quality = _qualityOptions[index];
          return RadioListTile<String>(
            title: Text(quality),
            value: quality,
            groupValue: _selectedQuality,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedQuality = value;
                });
              }
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }

  Widget _buildDownloadProgress(BuildContext context, slang.Translations t) {
    return Obx(() {
      final processed = _batchDownloadService.processedCount.value;
      final total = _batchDownloadService.totalCount.value;
      final success = _batchDownloadService.successCount.value;
      final failed = _batchDownloadService.failedCount.value;
      final skipped = _batchDownloadService.skippedCount.value;
      final currentTitle = _batchDownloadService.currentProcessingTitle.value;

      final progress = total > 0 ? processed / total : 0.0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text(
            t.download.batchDownload.progress(current: processed, total: total),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (currentTitle.isNotEmpty) ...[
            Text(
              currentTitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              _buildStatChip(
                context,
                Icons.check_circle,
                Colors.green,
                success.toString(),
                t.download.batchDownload.success,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                Icons.skip_next,
                Colors.orange,
                skipped.toString(),
                t.download.batchDownload.skipped,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                Icons.error,
                Colors.red,
                failed.toString(),
                t.download.batchDownload.failed,
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    Color color,
    String count,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, slang.Translations t) {
    if (_result == null) {
      LogUtils.w('结果阶段但 _result 为空', 'BatchDownloadDialog');
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(t.errors.howCouldThereBeNoDataItCantBePossible),
        ],
      );
    }

    final result = _result!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 统计概览
        Row(
          children: [
            _buildStatChip(
              context,
              Icons.check_circle,
              Colors.green,
              result.success.toString(),
              t.download.batchDownload.success,
            ),
            const SizedBox(width: 8),
            _buildStatChip(
              context,
              Icons.skip_next,
              Colors.orange,
              result.skipped.toString(),
              t.download.batchDownload.skipped,
            ),
            const SizedBox(width: 8),
            _buildStatChip(
              context,
              Icons.error,
              Colors.red,
              result.failed.toString(),
              t.download.batchDownload.failed,
            ),
          ],
        ),
        // 如果有失败/跳过的项目，显示详情
        if (result.failures.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            t.download.batchDownload.failureDetails,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          // 使用 Column 替代 ListView，因为已经在外层包装了 SingleChildScrollView
          Column(
            mainAxisSize: MainAxisSize.min,
            children: result.failures
                .map((failure) => _buildFailureTile(context, t, failure))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFailureTile(
    BuildContext context,
    slang.Translations t,
    BatchDownloadFailure failure,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _getFailureIcon(failure.reason),
        color: _getFailureColor(failure.reason),
        size: 20,
      ),
      title: Text(
        failure.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        _getFailureReason(t, failure.reason),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _getFailureColor(failure.reason),
        ),
      ),
    );
  }

  IconData _getFailureIcon(BatchDownloadFailureReason reason) {
    switch (reason) {
      case BatchDownloadFailureReason.privateVideo:
        return Icons.lock;
      case BatchDownloadFailureReason.alreadyExists:
        return Icons.file_copy;
      case BatchDownloadFailureReason.noSource:
        return Icons.cloud_off;
      case BatchDownloadFailureReason.noSavePath:
        return Icons.folder_off;
      case BatchDownloadFailureReason.other:
        return Icons.error;
    }
  }

  Color _getFailureColor(BatchDownloadFailureReason reason) {
    switch (reason) {
      case BatchDownloadFailureReason.privateVideo:
      case BatchDownloadFailureReason.alreadyExists:
        return Colors.orange;
      case BatchDownloadFailureReason.noSource:
      case BatchDownloadFailureReason.noSavePath:
      case BatchDownloadFailureReason.other:
        return Colors.red;
    }
  }

  String _getFailureReason(
    slang.Translations t,
    BatchDownloadFailureReason reason,
  ) {
    switch (reason) {
      case BatchDownloadFailureReason.privateVideo:
        return t.download.batchDownload.reasonPrivateVideo;
      case BatchDownloadFailureReason.alreadyExists:
        return t.download.batchDownload.reasonAlreadyExists;
      case BatchDownloadFailureReason.noSource:
        return t.download.batchDownload.reasonNoSource;
      case BatchDownloadFailureReason.noSavePath:
        return t.download.batchDownload.reasonNoSavePath;
      case BatchDownloadFailureReason.other:
        return t.download.batchDownload.reasonOther;
    }
  }

  List<Widget> _buildActions(slang.Translations t) {
    switch (_phase) {
      case _DialogPhase.selectQuality:
        return [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: _startDownload,
            child: Text(t.download.batchDownload.startDownload),
          ),
        ];
      case _DialogPhase.downloading:
        return [
          TextButton(onPressed: _cancelDownload, child: Text(t.common.cancel)),
        ];
      case _DialogPhase.result:
        return [
          TextButton(
            onPressed: () {
              AppService.tryPop();
              widget.onComplete?.call(); // 清空选择
              NaviService.navigateToDownloadTaskListPage();
            },
            child: Text(t.download.viewDownloadList),
          ),
          FilledButton(
            onPressed: () {
              AppService.tryPop();
              widget.onComplete?.call();
            },
            child: Text(t.common.confirm),
          ),
        ];
    }
  }

  Future<void> _startDownload() async {
    LogUtils.i(
      '开始批量下载, 媒体数量: ${widget.mediaItems.length}',
      'BatchDownloadDialog',
    );
    // 保存选择的清晰度
    _configService.setSetting(
      ConfigKey.LAST_DOWNLOAD_QUALITY,
      _selectedQuality,
    );

    setState(() {
      _phase = _DialogPhase.downloading;
    });

    try {
      final BatchDownloadResult result;
      if (_isVideoDownload) {
        result = await _batchDownloadService.batchDownloadVideos(
          videos: widget.mediaItems.cast<Video>(),
          quality: _selectedQuality,
        );
      } else {
        result = await _batchDownloadService.batchDownloadGalleries(
          galleries: widget.mediaItems.cast<ImageModel>(),
        );
      }

      LogUtils.i(
        '批量下载完成: 成功=${result.success}, 失败=${result.failed}, 跳过=${result.skipped}',
        'BatchDownloadDialog',
      );

      if (mounted) {
        setState(() {
          _result = result;
          _phase = _DialogPhase.result;
        });
      }
    } catch (e, stack) {
      LogUtils.e(
        '批量下载过程中发生致命异常',
        tag: 'BatchDownloadDialog',
        error: e,
        stack: stack,
      );
      if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.download.batchDownload
                .batchDownloadFailedWithException(exception: e.toString()),
            type: MDToastType.error,
          ),
          position: ToastPosition.top,
        );
        AppService.tryPop();
      }
    }
  }

  void _cancelDownload() {
    LogUtils.i('用户取消了批量下载', 'BatchDownloadDialog');
    _batchDownloadService.cancelBatchDownload();
    AppService.tryPop();
  }
}

enum _DialogPhase { selectQuality, downloading, result }
