import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import '../../../../../common/constants.dart';

class ImageModelCardListItemWidget extends StatelessWidget {
  static const double _narrowScreenWidth = 600;
  
  final ImageModel imageModel;
  final double width;

  const ImageModelCardListItemWidget({
    super.key,
    required this.imageModel,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < _narrowScreenWidth;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double cardBorderRadius = isNarrowScreen ? 6 : 8;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius)
        ),
        child: InkWell(
          onTap: () => NaviService.navigateToGalleryDetailPage(imageModel.id),
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
          splashColor: Theme.of(context).splashColor.withOpacity(0.2),
          highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
          child: _CardContent(
            imageModel: imageModel,
            isNarrowScreen: isNarrowScreen,
            textTheme: textTheme,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final ImageModel imageModel;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _CardContent({
    required this.imageModel,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isNarrowScreen ? 16 / 12 : 220 / 160,
          child: _Thumbnail(imageModel: imageModel),
        ),
        Padding(
          padding: EdgeInsets.all(isNarrowScreen ? 6.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                title: imageModel.title,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              _TimeInfo(
                createdAt: imageModel.createdAt,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              SizedBox(height: isNarrowScreen ? 4 : 8),
              _AuthorInfo(
                user: imageModel.user,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ],
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

class _Thumbnail extends StatelessWidget {
  static const _tagBorderRadius = BorderRadius.only(
    topRight: Radius.circular(8),
    bottomLeft: Radius.circular(6),
  );

  static const _likeTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(6),
    bottomRight: Radius.circular(8),
  );

  static const _viewTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(8),
    bottomRight: Radius.circular(6),
  );

  static const _imageNumTagBorderRadius = BorderRadius.only(
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(8),
  );

  final ImageModel imageModel;

  const _Thumbnail({required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildImage(),
        ...buildTags(context),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
          borderRadius: _imageNumTagBorderRadius,
        ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numViews),
          icon: Icons.remove_red_eye,
          borderRadius: _viewTagBorderRadius,
        ),
      ),
      Positioned(
        left: 0,
        top: 0,
        child: _ImageTag(
          text: CommonUtils.formatFriendlyNumber(imageModel.numLikes),
          icon: Icons.favorite,
          borderRadius: _likeTagBorderRadius,
        ),
      ),
    ];
  }

  Widget _buildRatingTag(BuildContext context) {
    return ClipRRect(
      borderRadius: _tagBorderRadius,
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

class _Title extends StatelessWidget {
  final String title;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _Title({
    required this.title,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: textTheme.bodyLarge!.fontSize! * 3.0,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isNarrowScreen 
              ? textTheme.bodyLarge!.fontSize! * 0.9
              : textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final DateTime? createdAt;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _TimeInfo({
    required this.createdAt,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CommonUtils.formatFriendlyTimestamp(createdAt),
      style: textTheme.bodySmall?.copyWith(
        fontSize: isNarrowScreen ? 11 : textTheme.bodySmall?.fontSize,
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final User? user;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _AuthorInfo({
    required this.user,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(isNarrowScreen),
          const SizedBox(width: 4),
          Expanded(
            child: buildUserName(context, user, bold: true, fontSize: isNarrowScreen ? 12 : 14)
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isNarrowScreen) {
    return AvatarWidget(
      user: user,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      radius: isNarrowScreen ? 12 : 14,
    );
  }
}
