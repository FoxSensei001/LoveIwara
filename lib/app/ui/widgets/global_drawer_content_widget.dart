import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';

import '../../../common/constants.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class GlobalDrawerColumns extends StatelessWidget {
  GlobalDrawerColumns({super.key});

  final UserService userService = Get.find();
  final AuthService authService = Get.find();
  final AppService appService = Get.find();

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Column(
      children: [
        Obx(() => _buildHeader(context, appService)),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // 通知
              _buildMenuItem(Icons.notifications, t.notifications.notifications, () {
                if (userService.isLogin) {
                  NaviService.navigateToNotificationListPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                }
              }),
              // 会话
              _buildMenuItem(Icons.message, t.conversation.conversation, () {
                if (userService.isLogin) {
                  NaviService.navigateToConversationPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                }
              }),
              // Tag黑名单
              _buildMenuItem(Icons.block, t.common.tagBlacklist, () {
                if (userService.isLogin) {
                  NaviService.navigateToTagBlacklistPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                }
              }),
              // 下载管理
              _buildMenuItem(Icons.download, t.download.downloadList, () {
                NaviService.navigateToDownloadTaskListPage();
                AppService.switchGlobalDrawer();
              }),
              // 历史记录
              _buildMenuItem(Icons.history, t.common.history, () {
                NaviService.navigateToHistoryListPage();
                AppService.switchGlobalDrawer();
              }),
              // 最爱
              _buildMenuItem(Icons.favorite_border, t.common.favorites, () {
                if (userService.isLogin) {
                  NaviService.navigateToFavoritePage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                }
              }),
              // 本地收藏
              _buildMenuItem(Icons.bookmark_border, t.favorite.localizeFavorite, () {
                NaviService.navigateToLocalFavoritePage();
                AppService.switchGlobalDrawer();
              }),
              // 好友
              _buildMenuItem(Icons.face, t.common.friends, () {
                if (userService.isLogin) {
                  NaviService.navigateToFriendsPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToast(t.errors.pleaseLoginFirst);
                }
              }),
              // 关注列表
              _buildMenuItem(Icons.people, t.common.followingList, () {
                if (userService.isLogin) {
                  NaviService.navigateToFollowingListPage(userService.currentUser.value!.id, userService.currentUser.value!.name, userService.currentUser.value!.username);
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToast(t.errors.pleaseLoginFirst);
                }
              }),
              // 粉丝列表
              _buildMenuItem(Icons.supervised_user_circle, t.common.followersList, () {
                if (userService.isLogin) {
                  NaviService.navigateToFollowersListPage(userService.currentUser.value!.id, userService.currentUser.value!.name, userService.currentUser.value!.username);
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToast(t.errors.pleaseLoginFirst);
                }
              }),
              // 播放列表
              _buildMenuItem(Icons.playlist_play, t.common.playList, () {
                if (userService.isLogin) {
                  NaviService.navigateToPlayListPage(
                      userService.currentUser.value!.id,
                      isMine: true);
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToast(t.errors.pleaseLoginFirst);
                }
              }),
              // 戒律签到
              _buildMenuItem(Icons.calendar_today, t.signIn.signIn, () {
                NaviService.navigateToSignInPage();
                AppService.switchGlobalDrawer();
              }),
              // 设置
              _buildMenuItem(Icons.settings, t.common.settings, () {
                AppService.switchGlobalDrawer();
                Get.toNamed(Routes.SETTINGS_PAGE);
              }),
              // // 关于
              // _buildMenuItem(Icons.info, '关于', () {
              //   userService.fetchUserProfile();
              //   Get.snackbar('操作', '你点击了关于');
              // }),
              Obx(() => userService.isLogin
                  ? Column(
                      children: [
                        const Divider(),
                        _buildMenuItem(Icons.exit_to_app, t.common.logout,
                            () => _showLogoutDialog(appService)),
                      ],
                    )
                  : const SizedBox.shrink()),
              const SafeArea(child: SizedBox.shrink()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppService globalDrawerService) {
    final t = slang.Translations.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!userService.isLogin) {
            AppService.switchGlobalDrawer();
            Get.toNamed(Routes.LOGIN);
          } else {
            AppService.switchGlobalDrawer();
            NaviService.navigateToAuthorProfilePage(
                userService.currentUser.value!.username);
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.paddingOf(context).top + 16, 16, 16),
          decoration: BoxDecoration(
            color: Get.theme.primaryColor,
            image: DecorationImage(
              image: const CachedNetworkImageProvider(
                CommonConstants.defaultAvatarUrl,
                headers: {'referer': CommonConstants.iwaraBaseUrl},
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AvatarWidget(
                user: userService.currentUser.value,
                size: 70
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: userService.isLogin 
                          ? buildUserName(
                              context,
                              userService.currentUser.value,
                              fontSize: 22,
                              bold: true,
                              defaultNameColor: Colors.white,
                            )
                          : Text(
                              t.auth.notLoggedIn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userService.isLogin
                          ? '@${userService.currentUser.value!.username}'
                          : t.auth.clickToLogin,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(icon, color: Get.isDarkMode ? Colors.white : null),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
        trailing: _buildMenuItemBadge(title),
      ),
    );
  }

  Widget? _buildMenuItemBadge(String title) {
    final t = slang.Translations.of(Get.context!);
    if (title == t.notifications.notifications) {
      return Obx(() {
        final count = userService.notificationCount.value;
        if (count > 0) {
          return Badge(
            backgroundColor: Theme.of(Get.context!).colorScheme.error,
            label: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onError,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }
        return const SizedBox.shrink();
      });
    } else if (title == t.common.friends) {
      return Obx(() {
        final count = userService.friendRequestsCount.value;
        if (count > 0) {
          return Badge(
            backgroundColor: Theme.of(Get.context!).colorScheme.error,
            label: Text(
              count.toString(),
              style: TextStyle(
                color: Theme.of(Get.context!).colorScheme.onError,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }
        return const SizedBox.shrink();
      });
    } else if (title == t.conversation.conversation) {
      return Obx(() {
        final count = userService.messagesCount.value;
        if (count > 0) {
          return Badge(
            backgroundColor: Theme.of(Get.context!).colorScheme.error,
            label: Text(count.toString(), style: TextStyle(color: Theme.of(Get.context!).colorScheme.onError, fontSize: 12, fontWeight: FontWeight.w500)),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }
        return const SizedBox.shrink();
      });
    }
    return null;
  }

  void _showLogoutDialog(AppService globalDrawerService) {
    AppService.switchGlobalDrawer();
    showDialog(
      context: Get.context!,
      builder: (context) => LogoutDialog(userService: userService),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final UserService userService;

  const LogoutDialog({required this.userService, super.key});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return AlertDialog(
      title: Text(t.auth.logout),
      content: Text(t.auth.logoutConfirmation),
      actions: [
        TextButton(
          child: Text(t.common.cancel),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text(t.common.confirm),
          onPressed: () async {
            Navigator.pop(context);
            try {
              userService.clearAllNotificationCounts();
              await userService.logout();
              showToast(t.auth.logoutSuccess);
            } catch (e) {
              showToast('${t.auth.logoutFailed}: $e');
            }
          },
        ),
      ],
    );
  }
}
