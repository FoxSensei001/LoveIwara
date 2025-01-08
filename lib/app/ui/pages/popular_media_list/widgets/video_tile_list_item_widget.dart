import 'dart:io';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_preview_modal.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:vibration/vibration.dart';

import '../../../../models/video.model.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class VideoTileListItem extends StatefulWidget {
  final Video video;

  const VideoTileListItem({super.key, required this.video});

  @override
  State<VideoTileListItem> createState() => _VideoTileListItemState();
}

class _VideoTileListItemState extends State<VideoTileListItem> {
  bool _showAnimatedPreview = false;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopPlatform = _isDesktop();

    return InkWell(
      onTap: () => _navigateToDetailPage(context),
      onLongPress: () => _handleLongPress(context),
      onSecondaryTap:
          isDesktopPlatform ? () => _handleLongPress(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThumbnail(context),
            const SizedBox(width: 16),
            _buildVideoInfo(context),
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
          onTap: () => _navigateToDetailPage(context),
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
                    placeholder: (context, url) =>
                        Container(width: 120, height: 90, color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[600])
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.video.isExternalVideo ? widget.video.externalVideoThumbnail : widget.video.thumbnailUrl,
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
        ),
        // 添加标签
        if (widget.video.rating == 'ecchi') _buildRatingTag(context),
        if (widget.video.private == true) _buildPrivateTag(context),
        if (widget.video.minutesDuration != null) _buildDurationTag(context),
        if (widget.video.isExternalVideo) _buildExternalVideoTag(context),
      ],
    );
  }

  /// 构建视频信息部分（标题、作者和创建时间）
  Widget _buildVideoInfo(BuildContext context) {
    final t = slang.Translations.of(context);
    // 格式化创建时间
    String formattedDate = '';
    if (widget.video.createdAt != null) {
      formattedDate = CommonUtils.formatFriendlyTimestamp(widget.video.createdAt);
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

  /// 构建 Private 标签
  Widget _buildPrivateTag(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      left: 0,
      top: 0,
      child: _buildTag(
        label: t.common.private,
        backgroundColor: Colors.black54,
        icon: Icons.lock,
      ),
    );
  }

  /// 构建站外视频标签
  Widget _buildExternalVideoTag(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 0,
      bottom: 0,
      child: _buildTag(label: t.common.externalVideo, backgroundColor: Colors.black54, icon: Icons.link),
    );
  }

  /// 构建 Duration 标签
  Widget _buildDurationTag(BuildContext context) {
    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 12, color: Colors.white),
            const SizedBox(width: 2),
            Text(
              widget.video.minutesDuration!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 通用标签构建方法
  Widget _buildTag({required String label, required Color backgroundColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// 导航到详情页
  void _navigateToDetailPage(BuildContext context) {
    NaviService.navigateToVideoDetailPage(widget.video.id);
  }

  /// 处理长按和右键事件
  void _handleLongPress(BuildContext context) async {
    // 震动反馈
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [500]);
    }

    if (!context.mounted) return;

    // 显示预览模态框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoPreviewDetailModal(video: widget.video);
      },
    );
  }
}
