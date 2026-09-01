import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/comment/controllers/comment_controller.dart';

import '../../../../models/comment.model.dart';
import '../../../../services/comment_service.dart';
import 'comment_item_widget.dart';
import 'comment_skeleton_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'comment_input_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

class CommentRepliesBottomSheet extends StatefulWidget {
  final Comment parentComment;
  final String? authorUserId;
  final CommentController? controller;
  final void Function(Duration position)? onTimestampSeek;

  const CommentRepliesBottomSheet({
    super.key,
    required this.parentComment,
    this.authorUserId,
    this.controller,
    this.onTimestampSeek,
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

  /// 子回复编辑成功：原地替换列表项（父评论 numReplies 不变）
  void _onReplyEdited(Comment updated) {
    if (!mounted) return;
    setState(() {
      final index = _replies.indexWhere((r) => r.id == updated.id);
      if (index != -1) {
        _replies[index] = updated;
      }
    });
  }

  /// 子回复删除成功：移除列表项 + 回复数减一，
  /// 并让主列表同步父评论的 numReplies
  void _onReplyDeleted(String commentId) {
    if (!mounted) return;
    setState(() {
      _replies.removeWhere((r) => r.id == commentId);
      if (_replyCount > 0) {
        _replyCount--;
      }
    });
    widget.controller?.onReplyDeleted(widget.parentComment.id);
  }

  void _showReplyDialog() {
    showGlassBottomSheet(
      context: context,
      builder: (context) => CommentInputBottomSheet(
        title: slang.t.common.replyComment,
        submitText: slang.t.common.reply,
        onSubmit: (text) async {
          if (text.trim().isEmpty) {
            showAppToast(
              slang.t.errors.commentCanNotBeEmpty,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
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
                showAppToast(
                  'Unknown comment type',
                  type: AppToastType.error,
                  position: AppToastPosition.bottom,
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
              showAppToast(
                slang.t.common.commentPostedSuccessfully,
                type: AppToastType.success,
              );
              // context 来自 showModalBottomSheet 的 builder，与 State 的 mounted 无关，
              // 需用该 context 自身的 mounted 判断。
              if (context.mounted) {
                Navigator.pop(context); // Close input sheet
              }
              if (mounted) {
                setState(() {
                  _replyCount++;
                });
                _loadReplies(refresh: true); // Refresh replies
              }
            } else {
              showAppToast(
                errorMessage ?? slang.t.common.commentPostedFailed,
                type: AppToastType.error,
                position: AppToastPosition.bottom,
              );
            }
          } catch (e) {
            showAppToast(
              slang.t.common.commentPostedFailed,
              type: AppToastType.error,
              position: AppToastPosition.bottom,
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

    // 外壳（玻璃材质 + 圆角 + 拖拽条 + 安全区）收口到 GlassDraggableBottomSheet，
    // 这里只负责标题行 + 可滚动内容；scrollController 由壳的
    // DraggableScrollableSheet 提供，接到内容的 ListView 上。
    return GlassDraggableBottomSheet(
      initialChildSize: 0.75, // 初始高度 75%
      minChildSize: 0.2, // 最小高度 20%
      maxChildSize: 0.92, // 最大高度 92%
      snap: true, // 启用吸附行为
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部标题栏
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              // 标题行：图标 + 回复数 …… 回复圆钮 / 关闭圆钮
              // 弹窗标题行的动作键一律玻璃圆钮，与全站其它弹窗同族
              child: Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      '$_replyCount ${t.common.replies}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.reply),
                    tooltip: t.common.reply,
                    onPressed: _showReplyDialog,
                  ),
                  const SizedBox(width: 8.0),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: t.common.close,
                    onPressed: () => Navigator.of(context).pop(),
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
            onTimestampSeek: widget.onTimestampSeek,
            onCommentEdited: _onReplyEdited,
            onCommentDeleted: _onReplyDeleted,
          );
        } else {
          return _buildLoadMoreIndicator();
        }
      },
    );
  }
}
