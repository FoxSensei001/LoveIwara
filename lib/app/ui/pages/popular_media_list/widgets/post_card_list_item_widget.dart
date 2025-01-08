import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:get/get.dart';

class PostCardListItemWidget extends StatelessWidget {
  final PostModel post;

  const PostCardListItemWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 添加历史记录
          final historyRepo = Get.find<HistoryRepository>();
          historyRepo.addRecord(HistoryRecord.fromPost(post));
          
          // 导航到帖子详情页
          NaviService.navigateToPostDetailPage(post.id, post);
        },
        child: SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息
              ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: GestureDetector(
                  onTap: () => NaviService.navigateToAuthorProfilePage(
                    post.user.username,
                  ),
                  child: _buildAvatar(post.user),
                ),
                title: GestureDetector(
                  onTap: () => NaviService.navigateToAuthorProfilePage(
                    post.user.username,
                  ),
                  child: _buildDisplayName(post.user),
                ),
                subtitle: Text(
                  '@${post.user.username}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 帖子内容
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          post.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // 底部信息
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final viewsWidget = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.remove_red_eye, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                CommonUtils.formatFriendlyNumber(post.numViews),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );

                          final timeWidget = Text(
                            CommonUtils.formatFriendlyTimestamp(post.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          );

                          // 计算所需的总宽度
                          final textSize = (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12);
                          final viewsWidth = 16 + 4 + // 图标和间距
                              (CommonUtils.formatFriendlyNumber(post.numViews).length * textSize);
                          final timeWidth = CommonUtils.formatFriendlyTimestamp(post.createdAt).length * 
                              textSize;
                          final totalWidth = viewsWidth + timeWidth + 20; // 额外留出一些边距

                          // 如果总宽度超过可用宽度，使用双行布局
                          if (totalWidth > constraints.maxWidth) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                viewsWidget,
                                const SizedBox(height: 4),
                                timeWidget,
                              ],
                            );
                          }

                          // 否则使用单行布局
                          return Row(
                            children: [
                              viewsWidget,
                              const Spacer(),
                              timeWidget,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
} 