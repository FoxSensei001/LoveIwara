import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../common/constants.dart';
import '../../../../models/video.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class VideoPreviewDetailModal extends StatelessWidget {
  final Video video;

  const VideoPreviewDetailModal({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    // 提前获取主题数据，避免多次调用 Theme.of(context)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final t = slang.Translations.of(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Hero(
                tag: 'card-${video.id}',
                child: GestureDetector(
                  onTap: () {}, // 防止点击卡片时关闭弹窗
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // 关闭弹窗
                                Navigator.of(context).pop();
                                NaviService.navigateToVideoDetailPage(video.id);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 220 / 160,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: video.previewUrl,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.grey[300]!,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey[200],
                                                child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])
                                              ),
                                            ),
                                          ),
                                        ),
                                        // 根据条件显示不同的标签
                                        if (video.rating == 'ecchi')
                                          Positioned(
                                            left: 0,
                                            bottom: 0,
                                            child: _buildRatingTag(
                                              label: 'R18',
                                              backgroundColor: Colors.red,
                                              textColor: colorScheme.onSecondary,
                                              theme: theme,
                                            ),
                                          ),
                                        if (video.private == true)
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: _buildPrivateTag(
                                              label: t.common.private,
                                              backgroundColor: Colors.black54,
                                              textColor: colorScheme.onPrimary,
                                              theme: theme,
                                              icon: Icons.lock,
                                            ),
                                          ),
                                        if (video.minutesDuration != null)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: _buildDurationTag(
                                              duration: video.minutesDuration!,
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                              theme: theme,
                                            ),
                                          ),
                                        if (video.isExternalVideo)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: _buildExternalVideoTag(
                                              label: t.common.externalVideo,
                                              backgroundColor: Colors.black54,
                                              textColor: Colors.white,
                                              theme: theme,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    video.title ?? '',
                                    style: textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                // 关闭弹窗
                                Navigator.of(context).pop();

                                // 跳转
                                NaviService.navigateToAuthorProfilePage(
                                  video.user?.username ?? '',
                                );
                              },
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Row(
                                children: [
                                  AvatarWidget(
                                    avatarUrl: video.user?.avatar?.avatarUrl,
                                    defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                                    headers: const {'referer': CommonConstants.iwaraBaseUrl},
                                    radius: 14,
                                    isPremium: video.user?.premium ?? false,
                                    isAdmin: video.user?.isAdmin ?? false,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      video.user?.name ?? t.common.unknownUser,
                                      style: textTheme.bodyLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                        icon: Icons.remove_red_eye,
                                        value: CommonUtils.formatFriendlyNumber(video.numViews),
                                        colorScheme: colorScheme,
                                        textTheme: textTheme,
                                      ),
                                      _buildStatItem(
                                        icon: Icons.thumb_up,
                                        value: CommonUtils.formatFriendlyNumber(video.numLikes),
                                        colorScheme: colorScheme,
                                        textTheme: textTheme,
                                      ),
                                      _buildStatItem(
                                        icon: Icons.comment,
                                        value: CommonUtils.formatFriendlyNumber(video.numComments),
                                        colorScheme: colorScheme,
                                        textTheme: textTheme,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        CommonUtils.formatFriendlyTimestamp(video.createdAt),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建评分标签
  Widget _buildRatingTag({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: theme.textTheme.bodySmall?.fontSize,
        ),
      ),
    );
  }

  /// 构建私密标签
  Widget _buildPrivateTag({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required ThemeData theme,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: theme.textTheme.bodySmall?.fontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建时长标签
  Widget _buildDurationTag({
    required String duration,
    required Color backgroundColor,
    required Color textColor,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            duration,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: theme.textTheme.bodySmall?.fontSize,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建外部视频标签
Widget _buildExternalVideoTag({
  required String label,
  required Color backgroundColor,
  required Color textColor,
  required ThemeData theme,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.link,
          size: 16,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: theme.textTheme.bodySmall?.fontSize,
          ),
        ),
      ],
    ),
  );
}

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

}
