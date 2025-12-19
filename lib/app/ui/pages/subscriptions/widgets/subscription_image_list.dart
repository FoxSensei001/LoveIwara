import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/utils/common_utils.dart' show CommonUtils;
import '../controllers/subscription_image_repository.dart';
import 'base_subscription_list.dart';

class SubscriptionImageList
    extends BaseSubscriptionList<ImageModel, SubscriptionImageRepository> {
  const SubscriptionImageList({
    super.key,
    required super.userId,
    super.isPaginated,
    super.paddingTop,
    super.showBottomPadding,
    super.isMultiSelectMode,
    super.selectedItemIds,
    super.onItemSelect,
  });

  @override
  State<SubscriptionImageList> createState() => _SubscriptionImageListState();
}

class _SubscriptionImageListState
    extends
        BaseSubscriptionListState<
          ImageModel,
          SubscriptionImageRepository,
          SubscriptionImageList
        > {
  @override
  SubscriptionImageRepository createRepository() {
    return SubscriptionImageRepository(userId: widget.userId);
  }

  @override
  IconData get emptyIcon => Icons.image_outlined;

  @override
  Widget buildListItem(BuildContext context, ImageModel image, int index) {
    return ImageModelCardListItemWidget(
      imageModel: image,
      width: CommonUtils.calculateCardWidth(MediaQuery.of(context).size.width),
      isMultiSelectMode: widget.isMultiSelectMode,
      isSelected: widget.selectedItemIds.contains(image.id),
      onSelect: () => widget.onItemSelect?.call(image),
    );
  }
}
