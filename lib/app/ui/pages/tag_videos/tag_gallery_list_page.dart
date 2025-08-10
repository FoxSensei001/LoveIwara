import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_media_list_page.dart';
import 'package:i_iwara/common/enums/media_enums.dart';

/// 标签画廊列表页面 - 精简版本
class TagGalleryListPage extends StatelessWidget {
  final Tag tag;

  const TagGalleryListPage({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return TagMediaListPage(
      tag: tag,
      mediaType: MediaType.IMAGE,
    );
  }
}