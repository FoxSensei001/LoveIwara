import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import '../controllers/subscription_image_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionImageList extends BaseSubscriptionList<ImageModel, SubscriptionImageRepository> {
  const SubscriptionImageList({
    super.key,
    required super.userId,
    super.isPaginated = false,
    super.paddingTop = 0,
  });
  
  @override
  State<SubscriptionImageList> createState() => SubscriptionImageListState();
}

class SubscriptionImageListState extends BaseSubscriptionListState<ImageModel, SubscriptionImageRepository, SubscriptionImageList> {
  @override
  SubscriptionImageRepository createRepository() {
    return SubscriptionImageRepository(userId: widget.userId);
  }
  
  @override
  IconData get emptyIcon => Icons.image_outlined;
  
  @override
  Widget buildListItem(BuildContext context, ImageModel image, int index) {
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
  }
}
