import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import '../controllers/subscription_video_repository.dart';

class SubscriptionVideoList extends StatefulWidget {
  final String userId;

  const SubscriptionVideoList({
    super.key,
    required this.userId,
  });

  @override
  SubscriptionVideoListState createState() => SubscriptionVideoListState();
}

class SubscriptionVideoListState extends State<SubscriptionVideoList> with AutomaticKeepAliveClientMixin {
  late SubscriptionVideoRepository listSourceRepository;

  @override
  void initState() {
    super.initState();
    listSourceRepository = SubscriptionVideoRepository(userId: widget.userId);
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    await listSourceRepository.refresh(true);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaListView<Video>(
      sourceList: listSourceRepository,
      emptyIcon: Icons.video_library_outlined,
      itemBuilder: (context, video, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
            vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
          ),
          child: VideoCardListItemWidget(
            video: video,
            width: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 - 8 : 200,
          ),
        );
      },
    );
  }
}