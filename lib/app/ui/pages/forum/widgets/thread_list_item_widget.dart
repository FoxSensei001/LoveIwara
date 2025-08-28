import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

class ThreadListItemWidget extends StatelessWidget {
  final ForumThreadModel thread;
  final String categoryId;
  final VoidCallback? onTap;

  const ThreadListItemWidget({
    super.key,
    required this.thread,
    required this.categoryId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {
          NaviService.navigateToForumThreadDetailPage(categoryId, thread.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部区域：用户头像、名称和时间
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      NaviService.navigateToAuthorProfilePage(thread.user.username);
                    },
                    child: AvatarWidget(
                      user: thread.user,
                      size: 30
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            NaviService.navigateToAuthorProfilePage(thread.user.username);
                          },
                          child: buildUserName(context, thread.user, fontSize: 12, bold: true),
                        ),
                        Text(
                          CommonUtils.formatFriendlyTimestamp(thread.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 标题区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  if (thread.sticky)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (thread.locked)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.lock,
                        size: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      thread.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 统计信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CommonUtils.formatFriendlyNumber(thread.numViews),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        CommonUtils.formatFriendlyNumber(thread.numPosts),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 最后回复信息
            if (thread.lastPost != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        NaviService.navigateToAuthorProfilePage(thread.lastPost!.user.username);
                      },
                      child: AvatarWidget(
                        user: thread.lastPost!.user,
                        size: 30
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              NaviService.navigateToAuthorProfilePage(thread.lastPost!.user.username);
                            },
                            child: buildUserName(context, thread.lastPost!.user, fontSize: 12, bold: true),
                          ),
                          Text(
                            CommonUtils.formatFriendlyTimestamp(thread.lastPost!.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
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

} 