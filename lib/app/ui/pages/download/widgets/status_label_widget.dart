import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';

class StatusLabel extends StatelessWidget {
  final DownloadStatus status;
  final String text;

  const StatusLabel({
    super.key,
    this.status = DownloadStatus.downloading,
    this.text = '',
  });

  Color _getStatusColor() {
    switch (status) {
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.paused:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
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
