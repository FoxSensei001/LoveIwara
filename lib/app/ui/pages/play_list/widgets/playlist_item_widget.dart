import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class PlaylistItemWidget extends StatelessWidget {
  final PlaylistModel playlist;

  /// 自定义点击行为；不传时按「别人的播放列表」跳详情。
  final VoidCallback? onTap;

  /// 多选（编辑）态：卡片盖一层勾选蒙版，点按变成选中/取消而不是进详情。
  final bool isMultiSelect;

  /// 当前是否已勾选（仅 [isMultiSelect] 为真时有意义）。
  final bool isSelected;

  /// 勾选切换回调。
  final VoidCallback? onToggleSelect;

  /// 删除请求进行中：蒙版上换成转圈，禁止再点。
  final bool isDeleting;

  const PlaylistItemWidget({
    super.key,
    required this.playlist,
    this.onTap,
    this.isMultiSelect = false,
    this.isSelected = false,
    this.onToggleSelect,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            onTap ??
            () => NaviService.navigateToPlayListDetail(
              playlist.id,
              isMine: false,
            ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: playlist.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => _buildShimmerPlaceholder(),
                    errorWidget: (context, url, error) =>
                        _buildErrorPlaceholder(),
                    fadeInDuration: const Duration(milliseconds: 50),
                    placeholderFadeInDuration: const Duration(milliseconds: 0),
                    fadeOutDuration: const Duration(milliseconds: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.common.videoCount(num: playlist.numVideos),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 多选蒙版：进出编辑态时淡入淡出，别硬切
            if (isMultiSelect)
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('playlist-select-overlay'),
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: GlassTokens.motionDuration,
                  curve: GlassTokens.motionCurve,
                  builder: (context, value, child) =>
                      Opacity(opacity: value, child: child),
                  child: Material(
                    color: Colors.black26,
                    child: InkWell(
                      onTap: isDeleting ? null : onToggleSelect,
                      child: Center(
                        child: isDeleting
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: Colors.white,
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 32,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
