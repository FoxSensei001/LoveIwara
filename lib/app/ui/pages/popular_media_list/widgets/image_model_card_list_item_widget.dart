import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart';

class ImageModelCardListItemWidget extends StatelessWidget {
  final ImageModel imageModel;
  final double width;

  const ImageModelCardListItemWidget({
    super.key,
    required this.imageModel,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCardListItem(
      width: width,
      thumbnail: _Thumbnail(imageModel: imageModel),
      title: imageModel.title,
      createdAt: imageModel.createdAt,
      user: imageModel.user,
      onTap: () => NaviService.navigateToGalleryDetailPage(imageModel.id),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final ImageModel imageModel;

  const _Thumbnail({required this.imageModel});

  @override
  Widget build(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < BaseCardListItem.narrowScreenWidth;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(isNarrowScreen),
        ...buildTags(context),
      ],
    );
  }

  Widget _buildImage(bool isNarrowScreen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isNarrowScreen ? 6 : 8),
      child: CachedNetworkImage(
        imageUrl: imageModel.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[300]),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])
        ),
      ),
    );
  }

  List<Widget> buildTags(BuildContext context) {
    return [
      if (imageModel.rating == 'ecchi')
        Positioned(
          left: 0,
          bottom: 0,
          child: _buildRatingTag(context),
        ),
      Positioned(
        right: 0,
        top: 0,
        child: _ImageTag(
          text: '${imageModel.numImages}',
          icon: Icons.image,
          borderRadius: BaseTagBorderRadius.imageNumTagBorderRadius,
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numViews),
          icon: Icons.remove_red_eye,
          borderRadius: BaseTagBorderRadius.viewTagBorderRadius,
        ),
      ),
      Positioned(
        left: 0,
        top: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numLikes),
          icon: Icons.favorite,
          borderRadius: BaseTagBorderRadius.likeTagBorderRadius,
        ),
      ),
    ];
  }

  Widget _buildRatingTag(BuildContext context) {
    return ClipRRect(
      borderRadius: BaseTagBorderRadius.tagBorderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        color: Colors.red,
        child: Text(
          'R18',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _ImageTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final BorderRadius borderRadius;

  const _ImageTag({
    required this.text,
    required this.icon,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: const BoxDecoration(color: Colors.black54),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: Colors.white),
            const SizedBox(width: 2),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
