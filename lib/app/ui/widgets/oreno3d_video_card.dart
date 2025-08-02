import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/search_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class Oreno3dVideoCard extends StatefulWidget {
  final Oreno3dVideo video;
  final double width;

  const Oreno3dVideoCard({super.key, required this.video, required this.width});

  @override
  State<Oreno3dVideoCard> createState() => _Oreno3dVideoCardState();
}

class _Oreno3dVideoCardState extends State<Oreno3dVideoCard> {
  final SearchService _searchService = Get.find<SearchService>();
  bool _isLoading = false;

  @override
  void dispose() {
    // 如果组件销毁时还在loading，关闭dialog
    if (_isLoading && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: _isLoading ? null : () => _handleVideoTap(),
            hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
            splashColor: Theme.of(context).splashColor.withValues(alpha: 0.2),
            highlightColor: Theme.of(
              context,
            ).highlightColor.withValues(alpha: 0.1),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.375, // 11:8
          child: _buildThumbnail(),
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 4),
              _buildAuthor(),
              const SizedBox(height: 4),
              _buildStats(),
              if (widget.video.tags.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildTags(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.video.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
        // Oreno3D标识
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Oreno3D',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // 播放按钮
        Positioned.fill(
          child: Center(
            child: const Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.video.title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor() {
    return Text(
      widget.video.author,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Icon(
          Icons.remove_red_eye,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(widget.video.viewCount),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.favorite,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(widget.video.favoriteCount),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: widget.video.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  slang.t.oreno3d.loading.gettingVideoInfo,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(slang.t.oreno3d.loading.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleVideoTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 显示loading dialog
    _showLoadingDialog();

    try {
      // 获取oreno3d详情
      final detail = await _searchService.getOreno3dVideoDetail(
        widget.video.id,
      );

      // 关闭loading dialog
      if (mounted && _isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isLoading = false;
        });
      }

      if (detail == null) {
        // 视频不存在或获取失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(slang.t.oreno3d.messages.videoNotFoundOrDeleted),
            ),
          );
        }
        return;
      }

      // 提取iwara视频ID
      final iwaraId = detail.extractIwaraId();

      if (iwaraId == null || iwaraId.isEmpty) {
        // 无法提取iwara ID，显示错误
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(slang.t.oreno3d.messages.unableToGetVideoPlayLink),
            ),
          );
        }
        return;
      }

      // 跳转到视频详情页
      NaviService.navigateToVideoDetailPage(iwaraId, {
        'oreno3dVideoDetailInfo': detail.toJson(),
      });
    } catch (e) {
      // 关闭loading dialog
      if (mounted && _isLoading) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isLoading = false;
        });
      }

      // 处理错误
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${slang.t.oreno3d.messages.getVideoDetailFailed}: $e',
            ),
          ),
        );
      }
    }
  }
}
