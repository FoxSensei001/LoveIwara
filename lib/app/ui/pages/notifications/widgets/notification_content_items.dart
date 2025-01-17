import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/comment.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/widget_extensions.dart';

/// 通知内容项组件
class NotificationContentItems {
  /// 构建回复通知内容
  static Widget buildReplyNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final comment = Comment.fromJson(notification['comment']);
    final commentUser = comment.user!;

    // 视频回复
    if (notification['video'] != null) {
      final videoId = notification['video']['id'];
      final videoTitle = notification['video']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kReplied} ${t.notifications.kVideo} '),
              _buildVideoLink(videoTitle, videoId),
              TextSpan(text: t.notifications.kCommentSection),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 用户主页回复
    if (notification['profile'] != null) {
      final profileUserName = notification['profile']['name'];
      final profileUsername = notification['profile']['username'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kReplied} '),
              TextSpan(
                text: profileUserName,
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => NaviService.navigateToAuthorProfilePage(profileUsername),
              ),
              TextSpan(text: ' ${t.notifications.kProfile}${t.notifications.kCommentSection}'),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 图库回复
    if (notification['image'] != null) {
      final imageId = notification['image']['id'];
      final imageTitle = notification['image']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kReplied} ${t.notifications.kGallery} '),
              _buildGalleryLink(imageTitle, imageId),
              TextSpan(text: t.notifications.kCommentSection),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 论坛帖子回复
    if (notification['thread'] != null) {
      final threadId = notification['thread']['id'];
      final threadTitle = notification['thread']['title'];
      final categoryId = notification['thread']['section'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kReplied} ${t.notifications.kThread} '),
              _buildThreadLink(threadTitle, categoryId, threadId),
              TextSpan(text: t.notifications.kCommentSection),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 投稿回复
    if (notification['post'] != null) {
      final postId = notification['post']['id'];
      final postTitle = notification['post']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kReplied} ${t.notifications.kPost} '),
              _buildPostLink(postTitle, postId),
              TextSpan(text: t.notifications.kCommentSection),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    return Text(t.notifications.kUnknownType);
  }

  /// 构建评论通知内容
  static Widget buildCommentNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final comment = Comment.fromJson(notification['comment']);
    final commentUser = comment.user!;

    // 用户主页评论
    if (notification['profile'] != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kCommented} ${t.notifications.kProfile}'),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 图库评论
    if (notification['image'] != null) {
      final imageId = notification['image']['id'];
      final imageTitle = notification['image']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kCommented} ${t.notifications.kGallery} '),
              _buildGalleryLink(imageTitle, imageId),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 论坛帖子评论
    if (notification['thread'] != null) {
      final threadId = notification['thread']['id'];
      final threadTitle = notification['thread']['title'];
      final categoryId = notification['thread']['section'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kCommented} ${t.notifications.kThread} '),
              _buildThreadLink(threadTitle, categoryId, threadId),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 视频评论
    if (notification['video'] != null) {
      final videoId = notification['video']['id'];
      final videoTitle = notification['video']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kCommented} ${t.notifications.kVideo} '),
              _buildVideoLink(videoTitle, videoId),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    // 投稿评论
    if (notification['post'] != null) {
      final postId = notification['post']['id'];
      final postTitle = notification['post']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildClickableText(
            context: context,
            children: [
              _buildUserLink(commentUser.name, commentUser.username),
              TextSpan(text: ' ${t.notifications.kCommented} ${t.notifications.kPost} '),
              _buildPostLink(postTitle, postId),
            ],
          ),
          if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
        ],
      );
    }

    return Text(t.notifications.kUnknownType);
  }

  /// 构建审核通过通知内容
  static Widget buildReviewApprovedNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    // 评论审核通过
    if (notification['comment'] != null) {
      final comment = Comment.fromJson(notification['comment']);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提醒
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.notifications.kApprovedComment,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 评论内容
          if (comment.body.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.body,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // 图库审核通过
    if (notification['image'] != null) {
      final imageId = notification['image']['id'];
      final imageTitle = notification['image']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提醒
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.notifications.kApprovedGallery,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 图库标题
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    imageTitle,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).asButton(() => NaviService.navigateToGalleryDetailPage(imageId)),
        ],
      );
    }

    // 帖子审核通过
    if (notification['thread'] != null) {
      final threadId = notification['thread']['id'];
      final threadTitle = notification['thread']['title'];
      final categoryId = notification['thread']['section'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提醒
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.notifications.kApprovedThread,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 帖子标题
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.forum_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    threadTitle,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).asButton(() => NaviService.navigateToForumThreadDetailPage(categoryId, threadId)),
        ],
      );
    }

    // 视频审核通过
    if (notification['video'] != null) {
      final videoId = notification['video']['id'];
      final videoTitle = notification['video']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提醒
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.notifications.kApprovedVideo,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 视频标题
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    videoTitle,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).asButton(() => NaviService.navigateToVideoDetailPage(videoId)),
        ],
      );
    }

    // 投稿审核通过
    if (notification['post'] != null) {
      final postId = notification['post']['id'];
      final postTitle = notification['post']['title'];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部提醒
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                t.notifications.kApprovedPost,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // 投稿标题
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    postTitle,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).asButton(() => NaviService.navigateToPostDetailPage(postId, null)),
        ],
      );
    }

    return Text(t.notifications.kUnknownType);
  }

  /// 构建可点击的文本
  static Widget _buildClickableText({
    required BuildContext context,
    required List<InlineSpan> children,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text.rich(
          TextSpan(
            children: children,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  /// 构建用户名链接
  static TextSpan _buildUserLink(String name, String username) {
    return TextSpan(
      children: [
        const WidgetSpan(
          child: Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.person_outline, size: 14, color: Colors.blue),
          ),
          alignment: PlaceholderAlignment.middle,
        ),
        TextSpan(
          text: name,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => NaviService.navigateToAuthorProfilePage(username),
        ),
      ],
    );
  }

  /// 构建评论内容
  static Widget _buildCommentBody(BuildContext context, String body) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  body,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建通用链接
  static TextSpan _buildCommonLink({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextSpan(
      children: [
        WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(icon, size: 14, color: Colors.blue),
          ),
          alignment: PlaceholderAlignment.middle,
        ),
        TextSpan(
          text: title,
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()..onTap = onTap,
        ),
      ],
    );
  }

  /// 构建视频链接
  static TextSpan _buildVideoLink(String title, String id) {
    return _buildCommonLink(
      title: title,
      icon: Icons.play_circle_outline,
      onTap: () => NaviService.navigateToVideoDetailPage(id),
    );
  }

  /// 构建图库链接
  static TextSpan _buildGalleryLink(String title, String id) {
    return _buildCommonLink(
      title: title,
      icon: Icons.photo_library_outlined,
      onTap: () => NaviService.navigateToGalleryDetailPage(id),
    );
  }

  /// 构建帖子链接
  static TextSpan _buildThreadLink(String title, String categoryId, String threadId) {
    return _buildCommonLink(
      title: title,
      icon: Icons.forum_outlined,
      onTap: () => NaviService.navigateToForumThreadDetailPage(categoryId, threadId),
    );
  }

  /// 构建投稿链接
  static TextSpan _buildPostLink(String title, String id) {
    return _buildCommonLink(
      title: title,
      icon: Icons.article_outlined,
      onTap: () => NaviService.navigateToPostDetailPage(id, null),
    );
  }
} 