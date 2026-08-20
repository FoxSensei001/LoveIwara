import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
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
            // 选择态：角标勾选片 + 选中描边，不盖死封面（全站统一，
            // 见 GlassSelectableOverlay）。常驻挂载以获得进出两个方向的过渡。
            Positioned.fill(
              child: GlassSelectableOverlay(
                selectionMode: isMultiSelect,
                selected: isSelected,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // 删除进行中：压一层暗底 + 转圈，并吃掉点击
            if (isDeleting)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            // 选择态下点按 = 勾选/取消，而不是进详情
            if (isMultiSelect)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isDeleting ? null : onToggleSelect,
                    child: const SizedBox.expand(),
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
