import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../models/comment.model.dart';
import '../../../../services/comment_service.dart';
import '../../../widgets/MDToastWidget.dart';
import 'comment_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

class CommentRepliesBottomSheet extends StatefulWidget {
  final Comment parentComment;
  final String? authorUserId;

  const CommentRepliesBottomSheet({
    super.key,
    required this.parentComment,
    this.authorUserId,
  });

  @override
  State<CommentRepliesBottomSheet> createState() => _CommentRepliesBottomSheetState();
}

class _CommentRepliesBottomSheetState extends State<CommentRepliesBottomSheet> {
  final CommentService _commentService = Get.find();
  final ScrollController _scrollController = ScrollController();
  
  final List<Comment> _replies = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadReplies(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading && _hasMore) {
      _loadReplies();
    }
  }

  Future<void> _loadReplies({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _replies.clear();
        _hasMore = true;
        _errorMessage = null;
      });
    }

    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String type;
      String id;
      if (widget.parentComment.videoId != null) {
        type = CommentType.video.name;
        id = widget.parentComment.videoId!;
      } else if (widget.parentComment.profileId != null) {
        type = CommentType.profile.name;
        id = widget.parentComment.profileId!;
      } else if (widget.parentComment.imageId != null) {
        type = CommentType.image.name;
        id = widget.parentComment.imageId!;
      } else if (widget.parentComment.postId != null) {
        type = CommentType.post.name;
        id = widget.parentComment.postId!;
      } else {
        throw Exception('未知的评论类型');
      }

      final result = await _commentService.getComments(
        type: type,
        id: id,
        parentId: widget.parentComment.id,
        page: _currentPage,
        limit: _pageSize,
      );

      if (result.isSuccess) {
        final pageData = result.data!;
        final fetchedReplies = pageData.results;

        setState(() {
          _replies.addAll(fetchedReplies);
          _currentPage++;
          _hasMore = fetchedReplies.length >= _pageSize;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result.message;
          _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = slang.t.errors.errorWhileFetchingReplies;
        _hasMore = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    final t = slang.Translations.of(context);
    if (_hasMore && _isLoading) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '加载中...',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!_hasMore && _replies.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16.0,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8.0),
                Text(
                  t.common.noMoreDatas,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorState() {
    final t = slang.Translations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              _errorMessage ?? t.errors.errorWhileFetchingReplies,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            FilledButton.icon(
              onPressed: () => _loadReplies(refresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.common.retry),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = slang.Translations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 64.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              t.common.tmpNoReplies,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部标题栏
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${widget.parentComment.numReplies} ${t.common.replies}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // 内容区域
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _replies.isEmpty) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: 5,
        itemBuilder: (context, index) => _buildShimmerItem(),
      );
    } else if (_errorMessage != null && _replies.isEmpty) {
      return _buildErrorState();
    } else if (!_isLoading && _replies.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _replies.length + 1,
      separatorBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      itemBuilder: (context, index) {
        if (index < _replies.length) {
          return CommentItem(
            key: ValueKey(_replies[index].id),
            comment: _replies[index],
            authorUserId: widget.authorUserId,
            controller: null,
            isReply: true,
          );
        } else {
          return _buildLoadMoreIndicator();
        }
      },
    );
  }
}