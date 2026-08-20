import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/pages/follows/controllers/follows_controller.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/user_card.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 特别关注列表（本地数据，可拖拽排序）。
///
/// 卡片与关注 / 粉丝 tab 共用 [UserCardShell]——这里的数据是字段更少的
/// [UserDTO]（拼不出 `User`），所以不能直接用 [UserCard]，但外观必须一致，
/// 否则三个 tab 横滑过去卡片风格会明显打架。
class SpecialFollowsList extends StatelessWidget {
  final FollowsController controller;

  /// 列表顶部让出的高度（玻璃 header 悬浮在列表之上）。
  final double paddingTop;

  const SpecialFollowsList({
    super.key,
    required this.controller,
    this.paddingTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final userPreferenceService = Get.find<UserPreferenceService>();

    return Obx(() {
      final likedUsers = userPreferenceService.likedUsers;
      final double bottomInset = MediaQuery.paddingOf(context).bottom + 5;

      if (likedUsers.isEmpty) {
        return SingleChildScrollView(
          controller: controller.specialFollowsScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, paddingTop + 32, 16, bottomInset),
          child: MyEmptyWidget(
            message: t.common.noSpecialFollows,
            icon: Icons.stars_outlined,
          ),
        );
      }

      return ReorderableListView.builder(
        scrollController: controller.specialFollowsScrollController,
        padding: EdgeInsets.fromLTRB(5, paddingTop, 5, bottomInset),
        itemCount: likedUsers.length,
        buildDefaultDragHandles: false,
        header: _buildTip(context, t),
        onReorderItem: (oldIndex, newIndex) {
          final UserDTO item = likedUsers.removeAt(oldIndex);
          likedUsers.insert(newIndex, item);
          // 保存整个列表的新顺序
          userPreferenceService.saveLikedUsers();
        },
        itemBuilder: (context, index) {
          final user = likedUsers[index];
          return _SpecialFollowCard(
            // ReorderableListView 要求每一项带稳定 key
            key: ValueKey(user.id),
            user: user,
            index: index,
            onRemove: () => _confirmRemove(context, user),
          );
        },
      );
    });
  }

  Widget _buildTip(BuildContext context, slang.Translations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 8, 11, 12),
      child: Text(
        t.common.specialFollowsManagementTip,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 移除是不可撤销的本地删除，走一次二次确认（原来的向左滑没有确认，误触即删）。
  Future<void> _confirmRemove(BuildContext context, UserDTO user) async {
    final t = slang.Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(t.common.removeSpecialFollow)),
            GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.close),
              tooltip: t.common.close,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
          ],
        ),
        content: Text(
          t.common.removeSpecialFollowConfirm(
            name: user.name.isEmpty ? '@${user.username}' : user.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.common.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    Get.find<UserPreferenceService>().removeLikedUser(user);
  }
}

class _SpecialFollowCard extends StatelessWidget {
  const _SpecialFollowCard({
    super.key,
    required this.user,
    required this.index,
    required this.onRemove,
  });

  final UserDTO user;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return UserCardShell(
      onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
      leading: _buildAvatar(),
      actions: [
        GlassIconButton(
          standalone: true,
          size: 36,
          icon: const Icon(Icons.close, size: 20),
          tooltip: t.common.removeSpecialFollow,
          onPressed: onRemove,
        ),
        // 手柄本身不是按钮，只做拖拽起点；桌面端给个抓手光标
        ReorderableDragStartListener(
          index: index,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Icon(
                Icons.drag_handle,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CachedNetworkImage(
        imageUrl: user.avatarUrl,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(radius: 20, backgroundImage: imageProvider),
        httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
        errorWidget: (context, url, error) => const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(CommonConstants.defaultAvatarUrl),
        ),
      ),
    );
  }
}
