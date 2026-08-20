import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

    // 视频回复
    if (notification['video'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText: ' ${t.notifications.kReplied} ${t.notifications.kVideo} ',
        link: _buildVideoLink(
          notification['video']['title'],
          notification['video']['id'],
        ),
        tail: t.notifications.kCommentSection,
      );
    }

    // 用户主页回复
    if (notification['profile'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText: ' ${t.notifications.kReplied} ',
        link: _buildTextLink(
          notification['profile']['name'],
          () => NaviService.navigateToAuthorProfilePage(
            notification['profile']['username'],
          ),
        ),
        tail: ' ${t.notifications.kProfile}${t.notifications.kCommentSection}',
      );
    }

    // 图库回复
    if (notification['image'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText: ' ${t.notifications.kReplied} ${t.notifications.kGallery} ',
        link: _buildGalleryLink(
          notification['image']['title'],
          notification['image']['id'],
        ),
        tail: t.notifications.kCommentSection,
      );
    }

    // 论坛帖子回复
    if (notification['thread'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText: ' ${t.notifications.kReplied} ${t.notifications.kThread} ',
        link: _buildThreadLink(
          notification['thread']['title'],
          notification['thread']['section'],
          notification['thread']['id'],
        ),
        tail: t.notifications.kCommentSection,
      );
    }

    // 投稿回复
    if (notification['post'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText: ' ${t.notifications.kReplied} ${t.notifications.kPost} ',
        link: _buildPostLink(
          notification['post']['title'],
          notification['post']['id'],
        ),
        tail: t.notifications.kCommentSection,
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

    // 用户主页评论
    if (notification['profile'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText:
            ' ${t.notifications.kCommented} ${t.notifications.kProfile}',
      );
    }

    // 图库评论
    if (notification['image'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText:
            ' ${t.notifications.kCommented} ${t.notifications.kGallery} ',
        link: _buildGalleryLink(
          notification['image']['title'],
          notification['image']['id'],
        ),
      );
    }

    // 论坛帖子评论
    if (notification['thread'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText:
            ' ${t.notifications.kCommented} ${t.notifications.kThread} ',
        link: _buildThreadLink(
          notification['thread']['title'],
          notification['thread']['section'],
          notification['thread']['id'],
        ),
      );
    }

    // 视频评论
    if (notification['video'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText:
            ' ${t.notifications.kCommented} ${t.notifications.kVideo} ',
        link: _buildVideoLink(
          notification['video']['title'],
          notification['video']['id'],
        ),
      );
    }

    // 投稿评论
    if (notification['post'] != null) {
      return _buildCommentNotice(
        context,
        comment: comment,
        actionText:
            ' ${t.notifications.kCommented} ${t.notifications.kPost} ',
        link: _buildPostLink(
          notification['post']['title'],
          notification['post']['id'],
        ),
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
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedComment,
        detail: comment.body.isNotEmpty
            ? _buildQuotedBody(context, comment.body)
            : null,
      );
    }

    // 图库审核通过
    if (notification['image'] != null) {
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedGallery,
        detail: _buildTitledLinkBox(
          context,
          icon: Icons.photo_library_outlined,
          title: notification['image']['title'],
          onTap: () =>
              NaviService.navigateToGalleryDetailPage(notification['image']['id']),
        ),
      );
    }

    // 帖子审核通过
    if (notification['thread'] != null) {
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedThread,
        detail: _buildTitledLinkBox(
          context,
          icon: Icons.forum_outlined,
          title: notification['thread']['title'],
          onTap: () => NaviService.navigateToForumThreadDetailPage(
            notification['thread']['section'],
            notification['thread']['id'],
          ),
        ),
      );
    }

    // 视频审核通过
    if (notification['video'] != null) {
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedVideo,
        detail: _buildTitledLinkBox(
          context,
          icon: Icons.play_circle_outline,
          title: notification['video']['title'],
          onTap: () =>
              NaviService.navigateToVideoDetailPage(notification['video']['id']),
        ),
      );
    }

    // 投稿审核通过
    if (notification['post'] != null) {
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedPost,
        detail: _buildTitledLinkBox(
          context,
          icon: Icons.article_outlined,
          title: notification['post']['title'],
          onTap: () =>
              NaviService.navigateToPostDetailPage(notification['post']['id'], null),
        ),
      );
    }

    // 论坛发言审核通过
    if (notification['forumPost'] != null) {
      final forumPost = notification['forumPost'];
      final String forumPostBody = forumPost['body'] ?? '';
      return _buildApprovedColumn(
        context,
        label: t.notifications.kApprovedForumPost,
        detail: forumPostBody.isNotEmpty
            ? _buildQuotedBody(
                context,
                forumPostBody,
                onTap: () => NaviService.navigateToForumThreadDetailPage(
                  forumPost['threadId'],
                  forumPost['id'],
                ),
              )
            : null,
      );
    }

    return Text(t.notifications.kUnknownType);
  }

  /// 构建审核被拒绝通知内容
  static Widget buildReviewRejectedNotification(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部提醒
        Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 16,
              color: colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              t.notifications.kRejectedContent,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // 说明文本
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.notifications.errors.unsupportedNotificationType,
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 「某人 动词了 对象(可选链接) 尾巴」+ 可选评论正文 的通用结构。
  static Widget _buildCommentNotice(
    BuildContext context, {
    required Comment comment,
    required String actionText,
    InlineSpan? link,
    String? tail,
  }) {
    final commentUser = comment.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClickableText(
          context: context,
          children: [
            _buildUserLink(commentUser.name, commentUser.username),
            TextSpan(text: actionText),
            ?link,
            if (tail != null) TextSpan(text: tail),
          ],
        ),
        if (comment.body.isNotEmpty) _buildCommentBody(context, comment.body),
      ],
    );
  }

  /// 审核通过通知的通用结构：顶部「已通过」横幅 + 可选详情块。
  static Widget _buildApprovedColumn(
    BuildContext context, {
    required String label,
    Widget? detail,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (detail != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: detail),
      ],
    );
  }

  /// 引用块：评论 / 论坛发言正文（最多两行）。
  static Widget _buildQuotedBody(
    BuildContext context,
    String body, {
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget box = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              body,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      box = box.asButton(onTap);
    }
    return box;
  }

  /// 标题链接块：审核通过的作品标题，点击跳转详情。
  static Widget _buildTitledLinkBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
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
    ).asButton(onTap);
  }

  /// 构建可点击的文本
  static Widget _buildClickableText({
    required BuildContext context,
    required List<InlineSpan> children,
  }) {
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              body,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建纯文字链接（无图标前缀）
  static TextSpan _buildTextLink(String title, VoidCallback onTap) {
    return TextSpan(
      text: title,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()..onTap = onTap,
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
