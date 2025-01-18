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
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 4 : 6,
        horizontal: isSmallScreen ? 4 : 6,
      ),
      child: InkWell(
        onTap: () {
          // 添加历史记录
          final historyRepo = Get.find<HistoryRepository>();
          // post 判断如果body超过200个字符，则截断
          final body = post.body.length > 200 ? post.body.substring(0, 200) : post.body;
          final postModel = post.copyWith(body: body);
          historyRepo.addRecordWithCheck(HistoryRecord.fromPost(postModel));
          
          // 导航到帖子详情页
          NaviService.navigateToPostDetailPage(post.id, post);
        },
        child: SizedBox(
          height: isSmallScreen ? 180 : 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户信息
              ListTile(
                dense: isSmallScreen,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8,
                  vertical: isSmallScreen ? 4 : 8,
                ),
                leading: GestureDetector(
                  onTap: () => NaviService.navigateToAuthorProfilePage(
                    post.user.username,
                  ),
                  child: _buildAvatar(post.user, isSmallScreen),
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
                  style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
                ),
              ),
              // 帖子内容
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isSmallScreen ? 8 : 12,
                    0,
                    isSmallScreen ? 8 : 12,
                    isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      Expanded(
                        child: Text(
                          post.body,
                          maxLines: isSmallScreen ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isSmallScreen ? 12 : 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // 底部信息
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final viewsWidget = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.remove_red_eye, 
                                size: isSmallScreen ? 14 : 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Text(
                                CommonUtils.formatFriendlyNumber(post.numViews),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );

                          final timeWidget = Text(
                            CommonUtils.formatFriendlyTimestamp(post.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          );

                          // 计算所需的总宽度
                          final textSize = (isSmallScreen ? 11 : 12).toDouble();
                          final viewsWidth = (isSmallScreen ? 14 : 16) + 
                              (isSmallScreen ? 2 : 4) + // 图标和间距
                              (CommonUtils.formatFriendlyNumber(post.numViews).length * textSize);
                          final timeWidth = CommonUtils.formatFriendlyTimestamp(post.createdAt).length * 
                              textSize;
                          final totalWidth = viewsWidth + timeWidth + 20; // 额外留出一些边距

                          // 如果总宽度超过可用宽度，使用双行布局
                          if (totalWidth > constraints.maxWidth) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                viewsWidget,
                                SizedBox(height: isSmallScreen ? 2 : 4),
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

  Widget _buildAvatar(User user, bool isSmallScreen) {
    return AvatarWidget(
      user: user,
      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
      radius: isSmallScreen ? 16 : 20,
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