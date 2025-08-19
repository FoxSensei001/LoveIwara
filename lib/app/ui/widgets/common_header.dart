import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';


class CommonHeader extends StatelessWidget {
  final double avatarRadius;
  final SearchSegment searchSegment;

  const CommonHeader({
    super.key,
    required this.searchSegment,
    this.avatarRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = Get.find<UserService>();
    final translations = slang.Translations.of(context);
    return Row(
      children: [
        Obx(() {
          if (userService.isLogining.value) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  AppService.switchGlobalDrawer();
                },
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      highlightColor: Theme.of(context).colorScheme.surface,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else if (userService.isLogin) {
            return Stack(
              children: [
               AvatarWidget(
                  user: userService.currentUser.value,
                  size: 48,
                  onTap: () {
                    AppService.switchGlobalDrawer();
                  }
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Obx(() {
                    final count = userService.notificationCount.value +
                        userService.messagesCount.value;
                    if (count > 0) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ),
              ],
            );
          } else {
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              splashRadius: 24,
              icon: const Icon(Icons.account_circle, size: 24),
              onPressed: () {
                AppService.switchGlobalDrawer();
              },
            );
          }
        }),
        Expanded(
          child: Material(
            elevation: 0,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: TextField(
              readOnly: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: translations.common.search,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              onTap: () {
                Get.dialog(
                  SearchDialog(
                    userInputKeywords: '',
                    initialSegment: searchSegment,
                    onSearch: (searchInfo, segment, filters, sort) {
                      NaviService.toSearchPage(
                          searchInfo: searchInfo, segment: segment, filters: filters, sort: sort);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
} 