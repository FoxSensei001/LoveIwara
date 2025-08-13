import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/link_input_dialog_widget.dart';
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
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.top);
                }
              }),
              // 会话
              _buildMenuItem(Icons.message, t.conversation.conversation, () {
                if (userService.isLogin) {
                  NaviService.navigateToConversationPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.top);
                }
              }),
              // Tag黑名单
              _buildMenuItem(Icons.block, t.common.tagBlacklist, () {
                if (userService.isLogin) {
                  NaviService.navigateToTagBlacklistPage();
                  AppService.switchGlobalDrawer();
                } else {
                  AppService.switchGlobalDrawer();
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.top);
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
                  showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error), position: ToastPosition.top);
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
              // 留出底部空间
              const SizedBox(height: 8),
            ],
          ),
        ),
        // 底部固定按钮区域
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1),
              // 使用IconButton而不是ListTile
              Padding(
                padding: EdgeInsets.only(left: 6, right: 6, bottom: MediaQuery.paddingOf(context).bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 设置按钮
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.settings, 
                            color: Get.isDarkMode ? Colors.white : null,
                            size: 28,
                          ),
                          onPressed: () {
                            AppService.switchGlobalDrawer();
                            NaviService.navigateToSettingsPage();
                          },
                        ),
                        Text(t.common.settings, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                     // 自定义链接按钮
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.link, 
                            color: Get.isDarkMode ? Colors.white : null,
                            size: 28,
                          ),
                          onPressed: () => LinkInputDialogWidget.show(),
                        ),
                        Text(t.settings.jumpLink, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    // 退出按钮 - 仅在登录状态显示
                    Obx(() => userService.isLogin
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.exit_to_app, 
                                  color: Get.isDarkMode ? Colors.white : null,
                                  size: 28,
                                ),
                                onPressed: () => _showLogoutDialog(appService),
                              ),
                              Text(t.common.logout, style: const TextStyle(fontSize: 12)),
                            ],
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
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
    Get.dialog(
      LogoutDialog(userService: userService),
      barrierDismissible: true,
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
