import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';

import '../../../../models/comment.model.dart';
import '../../../../services/comment_service.dart';
import 'comment_item_widget.dart';
import 'comment_skeleton_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

class CommentRepliesBottomSheet extends StatefulWidget {
  final Comment parentComment;
  final String? authorUserId;
  final CommentController? controller;

  const CommentRepliesBottomSheet({
    super.key,
    required this.parentComment,
    this.authorUserId,
    this.controller,
  });

  @override
  State<CommentRepliesBottomSheet> createState() =>
      _CommentRepliesBottomSheetState();
}

class _CommentRepliesBottomSheetState extends State<CommentRepliesBottomSheet> {
  final CommentService _commentService = Get.find();

  final List<Comment> _replies = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String? _errorMessage;
  late int _replyCount;

  @override
  void initState() {
    super.initState();
    _replyCount = widget.parentComment.numReplies;
    _loadReplies(refresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadReplies({bool refresh = false}) async {
    if (!mounted) return;
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

      if (!mounted) return;

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
      if (!mounted) return;
      setState(() {
        _errorMessage = slang.t.errors.errorWhileFetchingReplies;
        _hasMore = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReplyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentInputBottomSheet(
        title: slang.t.common.replyComment,
        submitText: slang.t.common.reply,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showToastWidget(
              MDToastWidget(
                message: slang.t.errors.commentCanNotBeEmpty,
                type: MDToastType.error,
              ),
              position: ToastPosition.bottom,
            );
            return;
          }

          try {
            bool success = false;
            String? errorMessage;

            if (widget.controller != null) {
              final result = await widget.controller!.postComment(
                text,
                parentId: widget.parentComment.id,
              );
              if (result.isSuccess) {
                success = true;
              } else {
                errorMessage = result.message;
              }
            } else {
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
                showToastWidget(
                  MDToastWidget(
                    message: 'Unknown comment type',
                    type: MDToastType.error,
                  ),
                  position: ToastPosition.bottom,
                );
                return;
              }

              final result = await _commentService.postComment(
                type: type,
                id: id,
                body: text,
                parentId: widget.parentComment.id,
              );

              if (result.isSuccess) {
                success = true;
              } else {
                errorMessage = result.message;
              }
            }

            if (success) {
              showToastWidget(
                MDToastWidget(
                  message: slang.t.common.commentPostedSuccessfully,
                  type: MDToastType.success,
                ),
              );
              if (mounted) {
                Navigator.pop(context); // Close input sheet
              }
              setState(() {
                _replyCount++;
              });
              _loadReplies(refresh: true); // Refresh replies
            } else {
              showToastWidget(
                MDToastWidget(
                  message: errorMessage ?? slang.t.common.commentPostedFailed,
                  type: MDToastType.error,
                ),
                position: ToastPosition.bottom,
              );
            }
          } catch (e) {
            showToastWidget(
              MDToastWidget(
                message: slang.t.common.commentPostedFailed,
                type: MDToastType.error,
              ),
              position: ToastPosition.bottom,
            );
          }
        },
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
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
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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

    // DraggableScrollableSheet 需要我们使用它提供的 scrollController
    return DraggableScrollableSheet(
      initialChildSize: 0.75, // 初始高度 75%
      minChildSize: 0.2, // 最小高度 20%
      maxChildSize: 0.92, // 最大高度 92%
      expand: false, // 不强制填满剩余空间
      snap: true, // 启用吸附行为
      builder: (context, scrollController) {
        // 如果内部滚动控制器不同，应切换到使用此控制器。
        // 但由于在 build 中，可以直接将 scrollController 传递给 ListView。
        // 然而，initState 中已将 _onScroll 逻辑绑定到 _scrollController。
        // 可能需要将监听器绑定到此控制器或进行

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽条
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 头部标题栏
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.0),
                  ),
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
                      '$_replyCount ${t.common.replies}',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _showReplyDialog,
                      icon: const Icon(Icons.reply),
                      visualDensity: VisualDensity.compact,
                      tooltip: t.common.reply,
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // 内容区域
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200 &&
                        !_isLoading &&
                        _hasMore) {
                      _loadReplies();
                    }
                    return false;
                  },
                  child: _buildContent(scrollController),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_isLoading && _replies.isEmpty) {
      return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: 5,
        itemBuilder: (context, index) =>
            const CommentSkeletonItem(isReply: true),
        separatorBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      );
    } else if (_errorMessage != null && _replies.isEmpty) {
      return _buildErrorState();
    } else if (!_isLoading && _replies.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _replies.length + 1,
      separatorBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
