import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../../common/constants.dart';

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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isNarrowScreen ? 6 : 8)
        ),
        child: InkWell(
          onTap: () => _navigateToDetailPage(),
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
          splashColor: Theme.of(context).splashColor.withOpacity(0.2),
          highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
          child: _buildCardContent(textTheme, context),
        ),
      ),
    );
  }

  Widget _buildCardContent(TextTheme textTheme, BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isNarrowScreen ? 16 / 12 : 220 / 160,
          child: _buildThumbnail(context),
        ),
        Padding(
          padding: EdgeInsets.all(isNarrowScreen ? 6.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(textTheme, isNarrowScreen),
              const SizedBox(height: 2),
              _buildTimeInfo(textTheme, context),
              SizedBox(height: isNarrowScreen ? 4 : 8),
              _buildAuthorInfo(textTheme, context),
            ],
          ),
        ),
      ],
    );
  }

  // 视频缩略图
  Widget _buildThumbnail(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isNarrowScreen ? 8 : 12),
          child: CachedNetworkImage(
            imageUrl: imageModel.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])
                  ),
          ),
        ),
        if (imageModel.rating == 'ecchi')
          Positioned(
            left: 0,
            bottom: 0,
            child: _buildRatingTag(context),
          ),
        // 左下角显示图片数量
        Positioned(
            right: 0,
            top: 0,
            child: _buildImageNums(context, imageModel.numImages)),
        // 右下角显示观看数量
        Positioned(
          right: 0,
          bottom: 0,
          child: _buildViewsNums(context, imageModel.numViews),
        ),
        // 左上角显示点赞数量
        Positioned(
          left: 0,
          top: 0,
          child: _buildLikeNums(context, imageModel.numLikes),
        )
      ],
    );
  }

  Widget _buildPlaceholder() => Container(color: Colors.grey[300]);

  Widget _buildRatingTag(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(isNarrowScreen ? 10 : 14),
        bottomLeft: Radius.circular(isNarrowScreen ? 8 : 12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 6 : 8,
          vertical: isNarrowScreen ? 2 : 4,
        ),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: Text(
          'R18',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
            fontSize: isNarrowScreen ? 10 : 12,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLikeNums(BuildContext context, int likes) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isNarrowScreen ? 8 : 12),
        bottomRight: Radius.circular(isNarrowScreen ? 10 : 14),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 6 : 8,
          vertical: isNarrowScreen ? 2 : 4,
        ),
        decoration: const BoxDecoration(
          color: Color(0x99000000),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, 
              size: isNarrowScreen ? 12 : 16,
              color: Colors.white
            ),
            SizedBox(width: isNarrowScreen ? 2 : 4),
            Text(
              CommonUtils.formatFriendlyNumber(likes),
              style: TextStyle(
                color: Colors.white,
                fontSize: isNarrowScreen ? 11 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewsNums(BuildContext context, int views) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isNarrowScreen ? 10 : 14),
        bottomRight: Radius.circular(isNarrowScreen ? 8 : 12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 6 : 8,
          vertical: isNarrowScreen ? 2 : 4,
        ),
        decoration: const BoxDecoration(
          color: Color(0x99000000),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye,
              size: isNarrowScreen ? 12 : 16,
              color: Colors.white
            ),
            SizedBox(width: isNarrowScreen ? 2 : 4),
            Text(
              CommonUtils.formatFriendlyNumber(views),
              style: TextStyle(
                color: Colors.white,
                fontSize: isNarrowScreen ? 11 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageNums(BuildContext context, int numImages) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(isNarrowScreen ? 8 : 14),
        bottomLeft: Radius.circular(isNarrowScreen ? 10 : 12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrowScreen ? 6 : 8,
          vertical: isNarrowScreen ? 2 : 4,
        ),
        decoration: const BoxDecoration(
          color: Color(0x99000000),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image,
              size: isNarrowScreen ? 12 : 16,
              color: Colors.white
            ),
            SizedBox(width: isNarrowScreen ? 2 : 4),
            Text(
              '$numImages',
              style: TextStyle(
                color: Colors.white,
                fontSize: isNarrowScreen ? 11 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme, bool isNarrowScreen) {
    return SizedBox(
      height: isNarrowScreen 
          ? textTheme.bodyLarge!.fontSize! * 3.0
          : textTheme.bodyLarge!.fontSize! * 3.5,
      child: Text(
        imageModel.title,
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

  Widget _buildTimeInfo(TextTheme textTheme, BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return Text(
      CommonUtils.formatFriendlyTimestamp(imageModel.createdAt),
      style: textTheme.bodySmall?.copyWith(
        fontSize: isNarrowScreen 
            ? 11 
            : textTheme.bodySmall?.fontSize,
      ),
    );
  }

  Widget _buildAuthorInfo(TextTheme textTheme, BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          imageModel.user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(isNarrowScreen),
          const SizedBox(width: 4),
          Expanded(
            child: imageModel.user?.premium == true
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.purple.shade300,
                      Colors.blue.shade300,
                      Colors.pink.shade300,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    imageModel.user?.name ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: isNarrowScreen ? 12 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Text(
                  imageModel.user?.name ?? 'Unknown User',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: isNarrowScreen ? 12 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isNarrowScreen) {
    return AvatarWidget(
      user: imageModel.user,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      radius: isNarrowScreen ? 12 : 14,
    );
  }

  void _navigateToDetailPage() {
    NaviService.navigateToGalleryDetailPage(imageModel.id);
  }
}
