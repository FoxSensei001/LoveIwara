import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ErrorStateWidget extends StatelessWidget {
  final MyVideoStateController controller;
  final double size;
  final VoidCallback? onShowErrorDetail;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.controller,
    required this.size,
    this.onShowErrorDetail,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                _getTruncatedErrorMessage(controller.videoSourceErrorMessage.value!),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onShowErrorDetail ?? () => _showErrorDetailSheet(context),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(slang.t.common.detail),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onRetry ?? () => controller.fetchVideoSource(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(slang.t.common.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 截取错误信息的前50个字符
  String _getTruncatedErrorMessage(String message) {
    if (message.length <= 50) {
      return message;
    }
    return '${message.substring(0, 50)}...';
  }

  // 显示错误详情底部弹窗
  void _showErrorDetailSheet(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: bottomPadding + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  slang.t.common.detail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                controller.videoSourceErrorMessage.value!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.fetchVideoSource();
                },
                icon: const Icon(Icons.refresh),
                label: Text(slang.t.common.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
