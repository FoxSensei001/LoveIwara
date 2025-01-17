import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/notifications/widgets/notification_content_items.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

class NotificationListItemWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final UserService _userService = Get.find<UserService>();
  final RxBool _isMarkingAsRead = false.obs;

  NotificationListItemWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final type = notification['type'] as String;
    final createdAt = DateTime.parse(notification['createdAt'] as String);
    final read = notification['read'] as bool? ?? false;

    return Obx(() => _isMarkingAsRead.value
        ? Shimmer.fromColors(
            baseColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3),
            highlightColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.6),
            child: _buildCard(context, type, createdAt, read),
          )
        : _buildCard(context, type, createdAt, read));
  }

  /// 通知点击事件
  void _handleNotificationTap(String type) {
    try {
      switch (type) {
        case 'newReply':
        case 'newComment':
          if (notification['comment'] != null) {
            // 视频评论
            if (notification['video'] != null) {
              final videoId = notification['video']['id'];
              NaviService.navigateToVideoDetailPage(videoId);
              return;
            }
            // 图库评论
            if (notification['image'] != null) {
              final imageId = notification['image']['id'];
              NaviService.navigateToGalleryDetailPage(imageId);
              return;
            }
            // 用户主页评论
            if (notification['profile'] != null) {
              final profileUserName = notification['profile']['username'];
              NaviService.navigateToAuthorProfilePage(profileUserName);
              return;
            }
            // 论坛帖子评论
            if (notification['thread'] != null) {
              final threadId = notification['thread']['id'];
              final categoryId = notification['thread']['section'];
              NaviService.navigateToForumThreadDetailPage(categoryId, threadId);
              return;
            }
            // 投稿评论
            if (notification['post'] != null) {
              final postId = notification['post']['id'];
              NaviService.navigateToPostDetailPage(postId, null);
              return;
            }
          }
          break;
        case 'reviewApproved':
          // 视频审核通过
          if (notification['video'] != null) {
            final videoId = notification['video']['id'];
            NaviService.navigateToVideoDetailPage(videoId);
            return;
          }
          // 图库审核通过
          if (notification['image'] != null) {
            final imageId = notification['image']['id'];
            NaviService.navigateToGalleryDetailPage(imageId);
            return;
          }
          // 论坛帖子审核通过
          if (notification['thread'] != null) {
            final threadId = notification['thread']['id'];
            final categoryId = notification['thread']['section'];
            NaviService.navigateToForumThreadDetailPage(categoryId, threadId);
            return;
          }
          // 投稿审核通过
          if (notification['post'] != null) {
            final postId = notification['post']['id'];
            NaviService.navigateToPostDetailPage(postId, null);
            return;
          }
          break;
      }
    } catch (e) {
      // 如果解析失败，不进行任何跳转
    }
  }

  /// 是否是已知类型
  bool _isKnownType(String type) {
    const knownTypes = {
      'newReply',    // 回复通知
      'newComment',  // 评论通知
      'reviewApproved', // 审核通过通知
    };
    return knownTypes.contains(type);
  }

  /// 复制通知数据
  void _copyNotificationData() {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(notification);
    Clipboard.setData(ClipboardData(text: jsonStr));
    showToastWidget(
      MDToastWidget(
        message: t.notifications.copySuccess,
        type: MDToastType.success,
      ),
    );
  }

  /// 通知卡片
  Widget _buildCard(
      BuildContext context, String type, DateTime createdAt, bool read) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        // 卡片点击事件
        onTap: () => _handleNotificationTap(type),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 通知内容
                  _buildNotificationContent(type, context, constraints),
                  const SizedBox(height: 12),
                  // 通知时间 & 通知操作按钮
                  constraints.maxWidth < 300
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CommonUtils.formatFriendlyTimestamp(createdAt),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildActionButtons(read, type, context),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 通知时间
                            Text(
                              CommonUtils.formatFriendlyTimestamp(createdAt),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            // 通知操作按钮
                            _buildActionButtons(read, type, context),
                          ],
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// 通知操作按钮
  Widget _buildActionButtons(bool read, String type, BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        if (!read)
          OutlinedButton.icon(
            icon: const Icon(Icons.mark_email_read, size: 16),
            label: Text(t.notifications.markAsRead,
                style: const TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _markAsRead,
          ),
        OutlinedButton.icon(
          icon: const Icon(Icons.copy, size: 16),
          label: Text(t.notifications.copy,
              style: const TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => _copyNotificationData(),
        ),
      ],
    );
  }

  /// 标记已读
  Future<void> _markAsRead() async {
    try {
      _isMarkingAsRead.value = true;
      final result =
          await _userService.markNotificationAsRead(notification['id']);
      if (result.isSuccess) {
        notification['read'] = true;
        await _userService.refreshNotificationCount();
        showToastWidget(
          MDToastWidget(
            message: t.notifications.markAsReadSuccess,
            type: MDToastType.success,
          ),
        );
      } else {
        showToastWidget(
          MDToastWidget(
            message: result.message,
            type: MDToastType.error,
          ),
        );
      }
    } finally {
      _isMarkingAsRead.value = false;
    }
  }

  /// 通知内容
  /// 由于接口信息被简化，所以可能如果直接fromJson，会报错
  /// profiel -> {@link User}
  /// image -> {@link ImageModel}
  /// thread -> {@link ForumThreadModel}
  /// video -> {@link Video}
  /// comment -> {@link Comment}
  Widget _buildNotificationContent(
      String type, BuildContext context, BoxConstraints constraints) {
    try {
      switch (type) {
        case 'newReply':
          if (notification['comment'] != null) {
            return NotificationContentItems.buildReplyNotification(context, notification);
          }
          break;
        case 'newComment':
          if (notification['comment'] != null) {
            return NotificationContentItems.buildCommentNotification(context, notification);
          }
          break;
        case 'reviewApproved':
          return NotificationContentItems.buildReviewApprovedNotification(context, notification);
      }
    } catch (e) {
      // 如果解析失败，返回不支持的通知类型
      return _buildUnsupportedNotification(type, context, constraints);
    }
    return _buildUnsupportedNotification(type, context, constraints);
  }

  /// 不支持的通知类型, 如果渲染时遇到空指针啊, 则也需要渲染这个
  Widget _buildUnsupportedNotification(
      String type, BuildContext context, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.notifications.errors.unsupportedNotificationType,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.notifications.errors
                .unsupportedNotificationTypeWithType(type: type),
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
