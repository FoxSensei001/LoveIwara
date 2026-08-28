import 'dart:io';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_state.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../../../models/video.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class VideoTileListItem extends StatefulWidget {
  final Video video;

  const VideoTileListItem({super.key, required this.video});

  @override
  State<VideoTileListItem> createState() => _VideoTileListItemState();
}

class _VideoTileListItemState extends State<VideoTileListItem>
    with MediaCardActionState<VideoTileListItem> {
  bool _showAnimatedPreview = false;
  Timer? _hoverTimer;

  @override
  Video get actionVideo => widget.video;
  @override
  String get actionMediaId => widget.video.id;
  @override
  bool get baseLiked => widget.video.liked == true;
  @override
  int get baseLikeCount => widget.video.numLikes ?? 0;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> _buildVideoDetailExtData() {
    final user = widget.video.user;
    return {
      'thumbnailUrl': widget.video.thumbnailUrl,
      'title': widget.video.title,
      'authorId': user?.id,
      'authorName': user?.name,
      'authorUsername': user?.username,
      'authorAvatarUrl': user?.avatar?.avatarUrl,
      'authorRole': user?.role,
      'authorPremium': user?.premium,
    };
  }

  Future<void> _openVideoDetail(
    String videoId, {
    Map<String, dynamic>? extData,
  }) async {
    await NaviService.navigateToVideoDetailPage(videoId, extData: extData);
    if (!mounted) return;
    applyLikePatchFromExtData(extData);
  }

  /// 格式化数字显示（如1.2K、1.5M等）
  String _formatNumber(int? number) {
    if (number == null || number == 0) return '0';

    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double k = number / 1000.0;
      return k >= 10 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      double m = number / 1000000.0;
      return m >= 10 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else {
      double b = number / 1000000000.0;
      return b >= 10 ? '${b.toInt()}B' : '${b.toStringAsFixed(1)}B';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopPlatform = _isDesktop();

    return InkWell(
      onTap: _navigateToDetailPage,
      // 长按 / 右键 / 三点钮 → 同一只媒体操作菜单。原来这两条指向的是只能看
      // 不能动手的预览弹窗，已整只移除。
      onLongPress: openActionMenu,
      onSecondaryTap: isDesktopPlatform ? openActionMenu : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThumbnail(context),
            const SizedBox(width: 16),
            _buildVideoInfo(context),
            // 行尾的三点钮。它在 InkWell 内部，但手势竞技场里更深的识别器
            // 稳赢，所以点它不会顺带把整行的"打开详情"也触发掉。
            MediaActionMenuButton(
              video: widget.video,
              busy: menuBusy,
              likedOverride: effectiveLiked,
              onLikeChanged: applyLikeToggle,
            ),
          ],
        ),
      ),
    );
  }

  /// 判断是否为桌面平台
  bool _isDesktop() {
    return !kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  /// 构建带有标签的缩略图，不包裹 Hero
  Widget _buildThumbnail(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _navigateToDetailPage,
          child: MouseRegion(
            onEnter: (_) {
              _hoverTimer?.cancel();
              _hoverTimer = Timer(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _showAnimatedPreview = true;
                  });
                }
              });
            },
            onExit: (_) {
              _hoverTimer?.cancel();
              if (mounted) {
                setState(() {
                  _showAnimatedPreview = false;
                });
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (_showAnimatedPreview && !widget.video.isExternalVideo)
                  ? CachedNetworkImage(
                      imageUrl: widget.video.previewUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.video.isExternalVideo
                          ? widget.video.externalVideoThumbnail
                          : widget.video.thumbnailUrl,
                      width: 120,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 90,
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // 点赞数和播放量标签组（左上角）
        _buildStatsTagsGroup(context),
        // Private标签和R18标签组
        ..._buildBottomLeftTagsGroup(context),
        if (widget.video.minutesDuration != null) _buildDurationTag(context),
        if (widget.video.isExternalVideo) _buildExternalVideoTag(context),
      ],
    );
  }

  /// 构建统计数据标签组
  Widget _buildStatsTagsGroup(BuildContext context) {
    return _buildStatsTagsGroupWithState(
      isLiked: effectiveLiked,
      likeCount: effectiveLikeCount,
    );
  }

  Widget _buildStatsTagsGroupWithState({
    required bool isLiked,
    required int likeCount,
  }) {
    final bool hasLikes = (likeCount > 0) || isLiked;
    final bool hasViews =
        widget.video.numViews != null && widget.video.numViews! > 0;

    if (!hasLikes && !hasViews) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasLikes) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 10,
                      color: isLiked ? Colors.pink : Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatNumber(likeCount),
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
            ],
            if (hasViews) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, size: 10, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      _formatNumber(widget.video.numViews),
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
            ],
          ],
        ),
      ),
    );
  }

  /// 构建左下角标签组（Private和R18）
  List<Widget> _buildBottomLeftTagsGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    bool isPrivate = widget.video.private == true;
    bool isR18 = widget.video.rating == 'ecchi';

    if (!isPrivate && !isR18) return [];

    // 如果有R18，整个标签组使用红色背景，否则使用黑色背景
    Color backgroundColor = isR18 ? Colors.red : Colors.black54;
    Color textColor = Colors.white;

    return [
      Positioned(
        left: 0,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isR18) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Text(
                    'R18',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
              if (isPrivate) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 10, color: textColor),
                      const SizedBox(width: 2),
                      Text(
                        t.common.private,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  /// 构建视频信息部分（标题、作者和创建时间）
  Widget _buildVideoInfo(BuildContext context) {
    final t = slang.Translations.of(context);
    // 格式化创建时间
    String formattedDate = '';
    if (widget.video.createdAt != null) {
      formattedDate = CommonUtils.formatFriendlyTimestamp(
        widget.video.createdAt,
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title ?? t.common.noTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16, // 调整标题字号
              fontWeight: FontWeight.bold, // 调整标题粗细
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.video.user?.name ?? t.common.unknownUser,
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

  /// 构建站外视频标签
  Widget _buildExternalVideoTag(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 0,
      bottom: 0,
      child: _buildTag(
        label: t.common.externalVideo,
        backgroundColor: Colors.black54,
        icon: Icons.link,
      ),
    );
  }

  /// 构建 Duration 标签
  Widget _buildDurationTag(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 10, color: Colors.white),
            const SizedBox(width: 2),
            Text(
              widget.video.minutesDuration!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 通用标签构建方法
  Widget _buildTag({
    required String label,
    required Color backgroundColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 10, color: Colors.white),
          if (icon != null) const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 导航到详情页
  Future<void> _navigateToDetailPage() async {
    await _openVideoDetail(
      widget.video.id,
      extData: _buildVideoDetailExtData(),
    );
  }
}
