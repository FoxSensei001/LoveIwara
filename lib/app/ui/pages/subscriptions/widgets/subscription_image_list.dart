import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import '../controllers/subscription_image_repository.dart';

class SubscriptionImageList extends StatefulWidget {
  final String userId;
  final bool isPaginated;
  final ScrollController? scrollController;

  const SubscriptionImageList({
    super.key,
    required this.userId,
    this.isPaginated = false,
    this.scrollController,
  });

  @override
  SubscriptionImageListState createState() => SubscriptionImageListState();
}

class SubscriptionImageListState extends State<SubscriptionImageList> with AutomaticKeepAliveClientMixin {
  late SubscriptionImageRepository listSourceRepository;

  @override
  void initState() {
    super.initState();
    listSourceRepository = SubscriptionImageRepository(userId: widget.userId);
  }

  @override
  void didUpdateWidget(SubscriptionImageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      listSourceRepository = SubscriptionImageRepository(userId: widget.userId);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    listSourceRepository.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    if (widget.isPaginated) {
      setState(() {});
    } else {
      await listSourceRepository.refresh(true);
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final mediaListView = MediaListView<ImageModel>(
      sourceList: listSourceRepository,
      emptyIcon: Icons.image_outlined,
      isPaginated: widget.isPaginated,
      scrollController: widget.scrollController,
      itemBuilder: (context, image, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width <= 600 ? 2 : 0,
            vertical: MediaQuery.of(context).size.width <= 600 ? 2 : 3,
          ),
          child: ImageModelCardListItemWidget(
            imageModel: image,
            width: MediaQuery.of(context).size.width <= 600 ? MediaQuery.of(context).size.width / 2 - 8 : 200,
          ),
        );
      },
    );
    
    return RefreshIndicator(
      onRefresh: refresh,
      child: mediaListView,
    );
  }
}
