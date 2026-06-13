import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../popular_media_list/widgets/media_description_widget.dart';

class VideoDescriptionWidget extends StatelessWidget {
  final String? description;
  final RxBool isDescriptionExpanded;
  final VoidCallback onToggleDescription;
  final int defaultMaxLines;
  final void Function(Duration position)? onTimestampSeek;

  const VideoDescriptionWidget({
    super.key,
    required this.description,
    required this.isDescriptionExpanded,
    required this.onToggleDescription,
    this.defaultMaxLines = 3,
    this.onTimestampSeek,
  });

  @override
  Widget build(BuildContext context) {
    return MediaDescriptionWidget(
      description: description,
      isDescriptionExpanded: isDescriptionExpanded,
      defaultMaxLines: defaultMaxLines,
      onTimestampSeek: onTimestampSeek,
    );
  }
}
