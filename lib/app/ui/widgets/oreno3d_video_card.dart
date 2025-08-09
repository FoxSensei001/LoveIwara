import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
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
  CancelToken? _cancelToken;

  @override
  void dispose() {
    // 如果组件销毁时还在loading，取消请求并关闭dialog
    if (_isLoading && mounted) {
      _cancelToken?.cancel('组件销毁');
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
    return CachedNetworkImage(
      imageUrl: widget.video.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) =>
          Container(color: Colors.grey[300], child: const Icon(Icons.error)),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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
      barrierDismissible: true,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            // 用户点击返回键或点击弹窗外面时取消操作
            _cancelToken?.cancel('用户取消');
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 加载动画容器
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题文本
                  Text(
                    slang.t.oreno3d.loading.gettingVideoInfo,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // 取消按钮
                  OutlinedButton(
                    onPressed: () {
                      // 取消网络请求
                      _cancelToken?.cancel('用户取消');
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      slang.t.oreno3d.loading.cancel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
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

    // 创建新的 CancelToken
    _cancelToken = CancelToken();

    // 显示loading dialog
    _showLoadingDialog();

    try {
      // 获取oreno3d详情，传入 CancelToken
      final detail = await _searchService.getOreno3dVideoDetail(
        widget.video.id,
        cancelToken: _cancelToken,
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
      // 如果是取消请求，不显示错误信息
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // 请求被取消，不需要显示错误
        return;
      }

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
