import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import '../controllers/subscription_video_repository.dart';

class SubscriptionVideoList extends StatefulWidget {
  final String userId;
  final bool isPaginated;

  const SubscriptionVideoList({
    super.key,
    required this.userId,
    this.isPaginated = false,
  });

  @override
  SubscriptionVideoListState createState() => SubscriptionVideoListState();
}

class SubscriptionVideoListState extends State<SubscriptionVideoList> with AutomaticKeepAliveClientMixin {
  late SubscriptionVideoRepository listSourceRepository;
  late MediaListView<Video> _mediaListView;

  @override
  void initState() {
    super.initState();
    listSourceRepository = SubscriptionVideoRepository(userId: widget.userId);
    _updateMediaListView();
  }

  void _updateMediaListView() {
    _mediaListView = MediaListView<Video>(
      sourceList: listSourceRepository,
      emptyIcon: Icons.video_library_outlined,
      isPaginated: widget.isPaginated,
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

  @override
  void didUpdateWidget(SubscriptionVideoList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaginated != widget.isPaginated || oldWidget.userId != widget.userId) {
      if (oldWidget.userId != widget.userId) {
        listSourceRepository = SubscriptionVideoRepository(userId: widget.userId);
      }
      _updateMediaListView();
      setState(() {});
    }
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    if (widget.isPaginated) {
      setState(() {
        _updateMediaListView();
      });
    } else {
      await listSourceRepository.refresh(true);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: refresh,
      child: _mediaListView,
    );
  }
}