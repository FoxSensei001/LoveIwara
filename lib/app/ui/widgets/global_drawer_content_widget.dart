import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/link_input_dialog_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';

import '../../../common/constants.dart';

import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/login_service.dart';
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
        Obx(() => _buildHeader(context)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSectionHeader(t.settings.interaction),
              _buildMenuItem(
                context,
                icon: Icons.notifications_outlined,
                title: t.notifications.notifications,
                onTap: () => _handleLoginRequiredNavi(
                  NaviService.navigateToNotificationListPage,
                  context,
                ),
                trailing: _buildNotificationBadge(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.chat_outlined,
                title: t.conversation.conversation,
                onTap: () => _handleLoginRequiredNavi(
                  NaviService.navigateToConversationPage,
                  context,
                ),
                trailing: _buildMessageBadge(),
              ),
              _buildMenuItem(
                context,
                icon: Icons.people_outline,
                title: t.common.friends,
                onTap: () => _handleLoginRequiredNavi(
                  NaviService.navigateToFriendsPage,
                  context,
                ),
                trailing: _buildFriendRequestBadge(),
              ),

              const Divider(indent: 16, endIndent: 16, height: 24),

              // --- Content Section ---
              _buildSectionHeader(t.common.history),
              _buildMenuItem(
                context,
                icon: Icons.history_outlined,
                title: t.common.history,
                onTap: () {
                  NaviService.navigateToHistoryListPage();
                  AppService.switchGlobalDrawer();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.download_outlined,
                title: t.download.downloadList,
                onTap: () {
                  NaviService.navigateToDownloadTaskListPage();
                  AppService.switchGlobalDrawer();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.favorite_outline,
                title: t.common.favorites,
                onTap: () => _handleLoginRequiredNavi(
                  NaviService.navigateToFavoritePage,
                  context,
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.bookmark_outline,
                title: t.favorite.localizeFavorite,
                onTap: () {
                  NaviService.navigateToLocalFavoritePage();
                  AppService.switchGlobalDrawer();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.playlist_play_outlined,
                title: t.common.playList,
                onTap: () => _handleLoginRequiredNavi(
                  () => NaviService.navigateToPlayListPage(
                    userService.currentUser.value!.id,
                    isMine: true,
                  ),
                  context,
                ),
              ),

              const Divider(indent: 16, endIndent: 16, height: 24),

              // --- Social Section ---
              _buildSectionHeader(t.common.followsAndFans),
              _buildMenuItem(
                context,
                icon: Icons.stars_outlined,
                title: t.common.specialFollow,
                onTap: () => _handleLoginRequiredNavi(
                  () => NaviService.navigateToSpecialFollowsListPage(
                    userService.currentUser.value!.id,
                    userService.currentUser.value!.name,
                    userService.currentUser.value!.username,
                  ),
                  context,
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.person_add_alt_1_outlined,
                title: t.common.followingList,
                onTap: () => _handleLoginRequiredNavi(
                  () => NaviService.navigateToFollowingListPage(
                    userService.currentUser.value!.id,
                    userService.currentUser.value!.name,
                    userService.currentUser.value!.username,
                  ),
                  context,
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.group_outlined,
                title: t.common.followersList,
                onTap: () => _handleLoginRequiredNavi(
                  () => NaviService.navigateToFollowersListPage(
                    userService.currentUser.value!.id,
                    userService.currentUser.value!.name,
                    userService.currentUser.value!.username,
                  ),
                  context,
                ),
              ),

              const Divider(indent: 16, endIndent: 16, height: 24),

              // --- Tools Section ---
              _buildSectionHeader(t.common.more),
              _buildMenuItem(
                context,
                icon: Icons.block_flipped,
                title: t.common.tagBlacklist,
                onTap: () => _handleLoginRequiredNavi(
                  NaviService.navigateToTagBlacklistPage,
                  context,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
        Obx(() => _buildBottomActions(context, t)),
      ],
    );
  }

  // Helper for login required navigation
  void _handleLoginRequiredNavi(VoidCallback naviCall, BuildContext context) {
    if (userService.isLogin) {
      naviCall();
      AppService.switchGlobalDrawer();
    } else {
      AppService.switchGlobalDrawer();
      _showLoginError(context);
    }
  }

  void _showLoginError(BuildContext context) {
    final t = slang.Translations.of(context);
    showToastWidget(
      MDToastWidget(
        message: t.errors.pleaseLoginFirst,
        type: MDToastType.error,
      ),
      position: ToastPosition.top,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Get.theme.colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Get.isDarkMode ? Colors.white70 : Colors.black87,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = slang.Translations.of(context);
    final user = userService.currentUser.value;
    // User模型目前没有headerId，暂时传null使用默认背景
    final headerUrl = CommonConstants.userProfileHeaderUrl(null);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          AppService.switchGlobalDrawer();
          if (!userService.isLogin) {
            LoginService.showLogin();
          } else {
            NaviService.navigateToAuthorProfilePage(user!.username);
          }
        },
        child: Container(
          height: 160 + MediaQuery.paddingOf(context).top,
          width: double.infinity,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: headerUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      Container(color: Theme.of(context).primaryColor),
                  httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: AvatarWidget(user: user, size: 60),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userService.isLogin) ...[
                            buildUserName(
                              context,
                              user,
                              fontSize: 18,
                              bold: true,
                              defaultNameColor: Colors.white,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user!.username}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            Text(
                              t.auth.notLoggedIn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.auth.clickToLogin,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildNotificationBadge() {
    return Obx(() {
      final count = userService.notificationCount.value;
      return count > 0 ? _buildCountBadge(count) : const SizedBox.shrink();
    });
  }

  Widget _buildMessageBadge() {
    return Obx(() {
      final count = userService.messagesCount.value;
      return count > 0 ? _buildCountBadge(count) : const SizedBox.shrink();
    });
  }

  Widget _buildFriendRequestBadge() {
    return Obx(() {
      final count = userService.friendRequestsCount.value;
      return count > 0 ? _buildCountBadge(count) : const SizedBox.shrink();
    });
  }

  Widget _buildCountBadge(int count) {
    return Badge(
      backgroundColor: Colors.redAccent,
      label: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, slang.Translations t) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            top: 4,
            bottom: 4 + MediaQuery.paddingOf(context).bottom,
            left: 12,
            right: 12,
          ),
          child: Row(
            children: [
              _BottomActionItem(
                icon: Icons.settings_outlined,
                label: t.common.settings,
                onTap: () {
                  AppService.switchGlobalDrawer();
                  NaviService.navigateToSettingsPage();
                },
              ),
              _BottomActionItem(
                icon: Icons.link_outlined,
                label: t.settings.jumpLink,
                onTap: () => LinkInputDialogWidget.show(),
              ),
              if (userService.isLogin)
                _BottomActionItem(
                  icon: Icons.logout_outlined,
                  label: t.common.logout,
                  onTap: () => _showLogoutDialog(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppService.switchGlobalDrawer();
    Get.dialog(
      LogoutDialog(userService: userService),
      barrierDismissible: true,
    );
  }
}

class _BottomActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: theme.colorScheme.primary.withOpacity(0.08),
        highlightColor: theme.colorScheme.primary.withOpacity(0.12),
        splashColor: theme.colorScheme.primary.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
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
