import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';

class PostTileListItemWidget extends StatelessWidget {
  final PostModel post;

  const PostTileListItemWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          NaviService.navigateToPostDetailPage(post.id, post);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息行
              Row(
                children: [
                  // 用户头像
                  GestureDetector(
                    onTap: () => NaviService.navigateToAuthorProfilePage(
                      post.user.username,
                    ),
                    child: _buildAvatar(post.user),
                  ),
                  const SizedBox(width: 12),
                  // 用户名和发布时间
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => NaviService.navigateToAuthorProfilePage(
                            post.user.username,
                          ),
                          child: _buildDisplayName(post.user),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${post.user.username} · ${CommonUtils.formatFriendlyTimestamp(post.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 帖子标题
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 帖子内容
              Text(
                post.body,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // 浏览量
              Row(
                children: [
                  const Icon(Icons.remove_red_eye, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    CommonUtils.formatFriendlyNumber(post.numViews),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return AvatarWidget(
      avatarUrl: user.avatar?.avatarUrl,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      headers: const {'referer': CommonConstants.iwaraBaseUrl},
      radius: 20,
      isPremium: user.premium ?? false,
      isAdmin: user.isAdmin ?? false,
    );
  }

  Widget _buildDisplayName(User user) {
    if (!user.premium) {
      return Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.purple.shade300,
          Colors.blue.shade300,
          Colors.pink.shade300,
        ],
      ).createShader(bounds),
      child: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
} 