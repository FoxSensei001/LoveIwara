
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class SpecialFollowsList extends StatelessWidget {
  final FollowsController controller;

  const SpecialFollowsList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final userPreferenceService = Get.find<UserPreferenceService>();

    return Obx(() {
      // 直接使用 likedUsers，不需要排序
      final likedUsers = userPreferenceService.likedUsers;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              t.common.specialFollowsManagementTip,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: likedUsers.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                // 更新列表顺序
                final UserDTO item = likedUsers.removeAt(oldIndex);
                likedUsers.insert(newIndex, item);

                // 保存整个列表的新顺序
                userPreferenceService.saveLikedUsers();
              },
              itemBuilder: (context, index) {
                final user = likedUsers[index];
                return Dismissible(
                  key: Key(user.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    userPreferenceService.removeLikedUser(user);
                  },
                  child: ListTile(
                    onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 20,
                          backgroundImage: imageProvider,
                        ),
                        httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                        errorWidget: (context, url, error) => const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(CommonConstants.defaultAvatarUrl),
                        ),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text('@${user.username}'),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
} 