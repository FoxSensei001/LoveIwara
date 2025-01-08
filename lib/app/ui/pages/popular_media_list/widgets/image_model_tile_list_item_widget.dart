import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../models/image.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ImageModelTileListItem extends StatelessWidget {
  final ImageModel imageModel;

  const ImageModelTileListItem({super.key, required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToDetailPage(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThumbnail(context),
            const SizedBox(width: 16),
            _buildImageModelInfo(context),
          ],
        ),
      ),
    );
  }

  /// 构建带有标签的缩略图，不包裹 Hero
  Widget _buildThumbnail(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _navigateToDetailPage(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageModel.thumbnailUrl,
              width: 120,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: 120, height: 90, color: Colors.grey[300]),
              errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])
                    ),
            ),
          ),
        ),
        // 添加标签
        if (imageModel.rating == 'ecchi') _buildRatingTag(context),
        // 左上角显示图片数量
        if (imageModel.numImages > 0)
          _buildImageNums(context, imageModel.numImages),
        // 右下角显示观看数量
        if (imageModel.numViews > 0)
          _buildViewsNums(context, imageModel.numViews),
        // 左上角显示点赞数量
        if (imageModel.numLikes > 0)
          _buildLikeNums(context, imageModel.numLikes)
      ],
    );
  }

  /// 构建 R18 标签
  Widget _buildRatingTag(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: _buildTag(
        label: 'R18',
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 构建图片数量标签
  Widget _buildImageNums(BuildContext context, int numImages) {
    return Positioned(
      right: 0,
      top: 0,
      child: _buildTag(
        label: '$numImages',
        icon: const Icon(Icons.image, size: 12, color: Colors.white),
        backgroundColor: Colors.black54,
      ),
    );
  }

  /// 构建观看数量标签
  Widget _buildViewsNums(BuildContext context, int views) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: _buildTag(
        label: CommonUtils.formatFriendlyNumber(views),
        icon: const Icon(Icons.remove_red_eye, size: 12, color: Colors.white),
        backgroundColor: Colors.black54,
      ),
    );
  }

  /// 构建点赞数量标签
  Widget _buildLikeNums(BuildContext context, int likes) {
    return Positioned(
      left: 0,
      top: 0,
      child: _buildTag(
        label: '$likes',
        icon: const Icon(Icons.favorite, size: 12, color: Colors.white),
        backgroundColor: Colors.black54,
      ),
    );
  }

  /// 通用标签构建方法
  Widget _buildTag(
      {required String label, required Color backgroundColor, Widget? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 构建图片信息部分（标题、作者和创建时间）
  Widget _buildImageModelInfo(BuildContext context) {
    final t = slang.Translations.of(context);
    // 格式化创建时间
    String formattedDate = '';
    if (imageModel.createdAt != null) {
      formattedDate = CommonUtils.formatFriendlyTimestamp(imageModel.createdAt);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            imageModel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16, // 调整标题字号
              fontWeight: FontWeight.bold, // 调整标题粗细
            ),
          ),
          const SizedBox(height: 4),
          Text(
            imageModel.user?.name ?? t.common.unknownUser,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14, // 调整作者名字号
              fontWeight: FontWeight.w500, // 调整作者名粗细
            ),
          ),
          if (formattedDate.isNotEmpty)
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 12, // 创建时间字号
                color: Colors.grey, // 创建时间字体颜色
              ),
            ),
        ],
      ),
    );
  }

  /// 导航到详情页
  void _navigateToDetailPage() {
    NaviService.navigateToGalleryDetailPage(imageModel.id);
  }
}
