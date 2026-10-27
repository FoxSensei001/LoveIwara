import 'package:material_ui/material_ui.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/ui/pages/tag_videos/tag_media_list_page.dart';
import 'package:i_iwara/common/enums/media_enums.dart';

/// 标签视频列表页面 - 精简版本
class TagVideoListPage extends StatelessWidget {
  final Tag tag;

  const TagVideoListPage({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return TagMediaListPage(
      tag: tag,
      mediaType: MediaType.VIDEO,
    );
  }
}
