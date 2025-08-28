import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ForumPostsSearchCard extends StatefulWidget {
  final ThreadCommentModel comment;

  const ForumPostsSearchCard({
    super.key,
    required this.comment,
  });

  @override
  State<ForumPostsSearchCard> createState() => _ForumPostsSearchCardState();
}

class _ForumPostsSearchCardState extends State<ForumPostsSearchCard> {
  final UserService _userService = Get.find<UserService>();

  Widget _buildCommentTag(String text, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    Color tagColor;
    if (text == slang.t.common.me) {
      tagColor = colorScheme.primary;
    } else if (text == slang.t.forum.pendingReview) {
      tagColor = colorScheme.error;
    } else {
      tagColor = colorScheme.primary;
    }
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: tagColor.withValues(alpha: 0.8)),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: tagColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = _userService.currentUser.value?.id == widget.comment.user.id;
    final thread = widget.comment.thread;
    ForumThreadModel? threadModel;
    
    // 安全地解析thread数据
    if (thread != null && thread is Map<String, dynamic>) {
      try {
        threadModel = ForumThreadModel.fromJson(thread);
      } catch (e) {
        // 如果解析失败，threadModel保持为null
        LogUtils.e('Failed to parse thread data', error: e, tag: 'ForumPostsSearchCard');
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 帖子信息头部 - 简化显示
          if (threadModel != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    NaviService.navigateToForumThreadDetailPage(threadModel!.section, threadModel.id);
                  },
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.forum,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            threadModel.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 评论内容 - 简化显示
          InkWell(
            onTap: () {
              if (threadModel != null) {
                NaviService.navigateToForumThreadDetailPage(threadModel.section, threadModel.id);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.comment.body,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 评论信息头部 - 简化布局
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 头像
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      NaviService.navigateToAuthorProfilePage(widget.comment.user.username);
                    },
                    child: AvatarWidget(
                      user: widget.comment.user,
                      size: 32
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 用户信息 - 简化显示
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户名和楼层号
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  NaviService.navigateToAuthorProfilePage(widget.comment.user.username);
                                },
                                child: buildUserName(context, widget.comment.user,
                                    fontSize: 14, bold: true),
                              ),
                            ),
                          ),
                          Text(
                            '#${widget.comment.replyNum + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // 发布时间和标签
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            CommonUtils.formatFriendlyTimestamp(widget.comment.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 标签
                          if (!widget.comment.approved || isCurrentUser)
                            ...(!widget.comment.approved
                                ? [_buildCommentTag(slang.t.forum.pendingReview, Icons.pending_outlined)]
                                : []),
                          if (isCurrentUser)
                            _buildCommentTag(slang.t.common.me, Icons.person_outline),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

