import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_status_colors.dart';

class StatusLabel extends StatelessWidget {
  final DownloadStatus status;
  final String text;

  const StatusLabel({
    super.key,
    this.status = DownloadStatus.downloading,
    this.text = '',
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = downloadStatusColor(context, status);
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
