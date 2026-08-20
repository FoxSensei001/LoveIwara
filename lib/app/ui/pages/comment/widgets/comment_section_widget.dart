import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_more_list/loading_more_list.dart';

import '../../../../models/comment.model.dart';
import '../controllers/comment_controller.dart';
import 'comment_item_widget.dart';
import 'comment_skeleton_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class CommentSection extends StatefulWidget {
  final CommentController controller;
  final String? authorUserId;
  final double topPadding;
  final ScrollController? scrollController;
  final void Function(Duration position)? onTimestampSeek;

  const CommentSection({
    super.key,
    required this.controller,
    this.authorUserId,
    this.topPadding = 0.0,
    this.scrollController,
    this.onTimestampSeek,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late CommentListSource _listSource;

  @override
  void initState() {
    super.initState();
    _listSource = widget.controller.createListSource();
  }

  @override
  void dispose() {
    _listSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading.value &&
          widget.controller.comments.isEmpty) {
        // 初始加载时显示Shimmer骨架屏
        return _buildShimmerList();
      } else if (widget.controller.errorMessage.value.isNotEmpty &&
          widget.controller.comments.isEmpty) {
        // 如果有错误且没有评论，显示错误信息和重试按钮
        return _buildErrorState(context);
      } else if (!widget.controller.isLoading.value &&
          widget.controller.comments.isEmpty) {
        // 如果没有评论，显示空状态
        return _buildEmptyState(context);
      } else {
        // 显示评论列表
        return _buildCommentList();
      }
    });
  }

  /// 列表内边距：扁平线程流，条目间用细分隔线分组。
  EdgeInsets get _listPadding =>
      EdgeInsets.fromLTRB(16.0, widget.topPadding + 4.0, 16.0, 8.0);

  /// 评论间的细分隔线。
  Widget _buildItemDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
  }

  // 构建Shimmer骨架屏列表（与正式列表同一套扁平布局）
  Widget _buildShimmerList() {
    return ListView.separated(
      padding: _listPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => const CommentSkeletonItem(),
      separatorBuilder: (context, index) => _buildItemDivider(context),
    );
  }

  // 构建错误状态视图
  Widget _buildErrorState(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: colorScheme.error,
                size: 44.0,
              ),
              const SizedBox(height: 12.0),
              Text(
                widget.controller.errorMessage.value,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              FilledButton.tonalIcon(
                onPressed: widget.controller.refreshComments,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(t.common.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建空状态视图
  Widget _buildEmptyState(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 56.0,
              ),
              const SizedBox(height: 14.0),
              Text(
                t.common.tmpNoComments,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建评论列表视图
  Widget _buildCommentList() {
    return LoadingMoreList<Comment>(
      ListConfig<Comment>(
        controller: widget.scrollController,
        padding: _listPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, comment, index) {
          return Column(
            children: [
              CommentItem(
                key: ValueKey(comment.id),
                comment: comment,
                authorUserId: widget.authorUserId,
                controller: widget.controller,
                onTimestampSeek: widget.onTimestampSeek,
              ),
              if (index < _listSource.length - 1) _buildItemDivider(context),
            ],
          );
        },
        indicatorBuilder: _buildLoadingIndicator,
        sourceList: _listSource,
      ),
    );
  }

  // 构建 LoadingMoreList 的指示器
  Widget? _buildLoadingIndicator(BuildContext context, IndicatorStatus status) {
    final t = slang.Translations.of(context);

    switch (status) {
      case IndicatorStatus.none:
        return null;
      case IndicatorStatus.loadingMoreBusying:
        return Container(
          padding: const EdgeInsets.all(24.0),
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
                const SizedBox(height: 12.0),
                Text(
                  t.common.loading,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      case IndicatorStatus.fullScreenBusying:
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case IndicatorStatus.error:
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: FilledButton.icon(
              onPressed: () => _listSource.errorRefresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.common.retry),
            ),
          ),
        );
      case IndicatorStatus.fullScreenError:
        return _buildErrorState(context);
      case IndicatorStatus.noMoreLoad:
        return Container(
          padding: const EdgeInsets.all(24.0),
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
      case IndicatorStatus.empty:
        return _buildEmptyState(context);
    }
  }
}
