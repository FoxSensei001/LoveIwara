import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/dev/liquid_glass_lab_page.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/link_input_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/iwara_site_switcher.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';

import '../../../common/constants.dart';

import 'package:i_iwara/app/models/iwara_site.dart';
import '../../services/user_service.dart';
import '../../services/login_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 底部悬浮圆按钮尺寸与留白（渐变高度、列表底部留白都由此派生）
const double _kActionButtonSize = 44;
const double _kActionIconSize = 24;
const double _kActionBottomMargin = 16;
const double _kActionFadeExtent = 48;

class GlobalDrawerColumns extends StatelessWidget {
  GlobalDrawerColumns({super.key});

  final UserService userService = Get.find();
  final AppService appService = Get.find();

  IwaraSite _alternateSite(IwaraSite site) {
    return site == IwaraSite.ai ? IwaraSite.main : IwaraSite.ai;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              Obx(() => _buildHeader(context)),
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      // 底部留白让最后一项能完整滚到悬浮按钮上方
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom:
                            _kActionBottomMargin +
                            _kActionButtonSize +
                            bottomInset,
                      ),
                      children: [
                        _buildSectionHeader(
                          context,
                          slang.t.settings.interaction,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.notifications_outlined,
                          title: slang.t.notifications.notifications,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToNotificationListPage,
                            context,
                          ),
                          trailing: _buildNotificationBadge(),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.chat_outlined,
                          title: slang.t.conversation.conversation,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToConversationPage,
                            context,
                          ),
                          trailing: _buildMessageBadge(),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.people_outline,
                          title: slang.t.common.friends,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToFriendsPage,
                            context,
                          ),
                          trailing: _buildFriendRequestBadge(),
                        ),

                        const Divider(indent: 16, endIndent: 16, height: 24),

                        // --- Content Section ---
                        _buildSectionHeader(context, slang.t.common.history),
                        _buildMenuItem(
                          context,
                          icon: Icons.history_outlined,
                          title: slang.t.common.history,
                          onTap: () {
                            NaviService.navigateToHistoryListPage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.download_outlined,
                          title: slang.t.download.downloadList,
                          onTap: () {
                            NaviService.navigateToDownloadTaskListPage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite_outline,
                          title: slang.t.common.favorites,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToFavoritePage,
                            context,
                          ),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.bookmark_outline,
                          title: slang.t.favorite.localizeFavorite,
                          onTap: () {
                            NaviService.navigateToLocalFavoritePage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.playlist_play_outlined,
                          title: slang.t.common.playList,
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
                        _buildSectionHeader(
                          context,
                          slang.t.common.followsAndFans,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.stars_outlined,
                          title: slang.t.common.specialFollow,
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
                          title: slang.t.common.followingList,
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
                          title: slang.t.common.followersList,
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
                        _buildSectionHeader(context, slang.t.common.more),
                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline,
                          title: slang.t.personalProfile.personalProfile,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToPersonalProfilePage,
                            context,
                          ),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.block_flipped,
                          title: slang.t.common.tagBlacklist,
                          onTap: () => _handleLoginRequiredNavi(
                            NaviService.navigateToTagBlacklistPage,
                            context,
                          ),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.favorite_outline,
                          title: slang.t.favoriteTags.iwaraTitle,
                          onTap: () {
                            NaviService.navigateToFavoriteIwaraTagsPage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.view_in_ar_outlined,
                          title: slang.t.favoriteTags.oreno3dTitle,
                          onTap: () {
                            NaviService.navigateToFavoriteOreno3dTagsPage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.block,
                          title: slang.t.settings.blockSettings.title,
                          onTap: () {
                            NaviService.navigateToBlockSettingsPage();
                            AppService.switchGlobalDrawer();
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.link_outlined,
                          title: slang.t.settings.jumpLink,
                          onTap: () => LinkInputDialogWidget.show(),
                        ),
                        // 临时调试入口：liquid_glass_easy 能力速览（未接 i18n，看完可整条删）
                        _buildMenuItem(
                          context,
                          icon: Icons.science_outlined,
                          title: '液态玻璃实验室',
                          // 抽屉挂在 Navigator 之外，context 里没有 Navigator，
                          // 只能走 router 的 rootNavigatorKey。
                          onTap: () {
                            AppService.switchGlobalDrawer();
                            rootNavigatorKey.currentState?.push(
                              MaterialPageRoute<void>(
                                builder: (_) => const LiquidGlassLabPage(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                    // 渐变承托：列表全程透出，仅在按钮背后逐渐压暗（不随滚动变化）
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height:
                          _kActionBottomMargin +
                          _kActionButtonSize +
                          _kActionFadeExtent +
                          bottomInset,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _bottomFadeGradient(context),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: _kActionBottomMargin + bottomInset,
                      height: _kActionButtonSize,
                      child: _buildFloatingActions(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _bottomFadeGradient(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerLow;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        base.withValues(alpha: 0),
        base.withValues(alpha: 0.35),
        base.withValues(alpha: 0.70),
        base.withValues(alpha: 0.92),
      ],
      stops: const [0, 0.3, 0.6, 1],
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DrawerCircleButton(
              icon: Icons.settings_outlined,
              onTap: () {
                AppService.switchGlobalDrawer();
                NaviService.navigateToSettingsPage();
              },
            ),
            const SizedBox(width: 8),
            Obx(() {
              final site = appService.currentSiteMode;
              return _DrawerCircleButton(
                icon: site.isAi ? Icons.auto_awesome : Icons.public,
                onTap: () => _showSiteModeDialog(
                  context,
                  initialSite: _alternateSite(site),
                ),
              );
            }),
          ],
        ),
        // 未登录时右侧留空，左侧位置不变
        Obx(
          () => userService.hasLoadedProfile
              ? _DrawerCircleButton(
                  icon: Icons.logout_outlined,
                  onTap: () => _showLogoutDialog(context),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Helper for login required navigation
  void _handleLoginRequiredNavi(VoidCallback naviCall, BuildContext context) {
    if (!userService.isAuthenticated) {
      AppService.switchGlobalDrawer();
      _showLoginError(context);
      return;
    }
    // 已认证但资料尚未加载完成：导航目标需要 currentUser 字段，
    // 先提示稍候而非 NPE（naviCall 内部会解引用 currentUser.value!）。
    if (userService.currentUser.value == null) {
      AppService.switchGlobalDrawer();
      showGlassToast(
        slang.t.auth.loginSuccessProfilePending,
        type: GlassToastType.warning,
      );
      return;
    }
    naviCall();
    AppService.switchGlobalDrawer();
  }

  void _showLoginError(BuildContext context) {
    final t = slang.Translations.of(context);
    showGlassToast(
      t.errors.pleaseLoginFirst,
      type: GlassToastType.error,
      position: GlassToastPosition.top,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
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
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = userService.currentUser.value;
    final headerUrl = CommonConstants.userProfileHeaderUrl(user?.header?.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          AppService.switchGlobalDrawer();
          if (!userService.isAuthenticated) {
            LoginService.showLogin();
          } else if (user == null) {
            // 已认证但资料尚未加载完成：跳转需要 username，先提示稍候而非 NPE。
            showGlassToast(
              slang.t.auth.loginSuccessProfilePending,
              type: GlassToastType.warning,
            );
          } else {
            NaviService.navigateToAuthorProfilePage(user.username);
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
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
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
                          if (userService.hasLoadedProfile) ...[
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
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            Text(
                              slang.t.auth.notLoggedIn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              slang.t.auth.clickToLogin,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
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

  void _showSiteModeDialog(BuildContext context, {IwaraSite? initialSite}) {
    AppService.switchGlobalDrawer();
    showAppDialog(
      _SiteModeConfirmDialog(
        currentSite: appService.currentSiteMode,
        initialSite: initialSite,
        onConfirm: (site) async {
          await appService.applyGlobalSiteMode(site);
        },
      ),
      barrierDismissible: true,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AppService.switchGlobalDrawer();
    showAppDialog(
      LogoutDialog(userService: userService),
      barrierDismissible: true,
    );
  }
}

class _DrawerCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: _kActionButtonSize,
      child: IconButton.filledTonal(
        onPressed: onTap,
        iconSize: _kActionIconSize,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
          hoverColor: colorScheme.primary.withValues(alpha: 0.08),
          focusColor: colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: colorScheme.primary.withValues(alpha: 0.12),
          padding: EdgeInsets.zero,
          fixedSize: const Size.square(_kActionButtonSize),
          minimumSize: const Size.square(_kActionButtonSize),
          maximumSize: const Size.square(_kActionButtonSize),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _SiteModeConfirmDialog extends StatefulWidget {
  final IwaraSite currentSite;
  final IwaraSite? initialSite;
  final Future<void> Function(IwaraSite site) onConfirm;

  const _SiteModeConfirmDialog({
    required this.currentSite,
    this.initialSite,
    required this.onConfirm,
  });

  @override
  State<_SiteModeConfirmDialog> createState() => _SiteModeConfirmDialogState();
}

class _SiteModeConfirmDialogState extends State<_SiteModeConfirmDialog> {
  late IwaraSite _selectedSite;

  String _siteLabel(slang.Translations t, IwaraSite site) {
    return site == IwaraSite.ai ? t.siteMode.aiSite : t.siteMode.mainSite;
  }

  @override
  void initState() {
    super.initState();
    _selectedSite = widget.initialSite ?? widget.currentSite;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassAlertDialog(
      title: t.siteMode.dialogTitle,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.siteMode.dialogDescription),
              const SizedBox(height: 12),
              IwaraSiteSwitcher(
                currentSite: _selectedSite,
                forceCompact: false,
                compactBreakpoint: 0,
                onChanged: (site) {
                  setState(() {
                    _selectedSite = site;
                  });
                },
              ),
              const SizedBox(height: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedSite == widget.currentSite
                        ? t.siteMode.alreadyUsing
                        : t.siteMode.confirmUsing(
                            site: _siteLabel(t, _selectedSite),
                          ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        GlassDialogAction(
          label: t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        GlassDialogAction(
          label: t.common.confirm,
          onPressed: _selectedSite == widget.currentSite
              ? null
              : () async {
                  Navigator.of(context).pop();
                  await widget.onConfirm(_selectedSite);
                },
        ),
      ],
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final UserService userService;

  const LogoutDialog({required this.userService, super.key});

  @override
  Widget build(BuildContext context) {
    return GlassAlertDialog(
      title: slang.t.auth.logout,
      content: Text(slang.t.auth.logoutConfirmation),
      actions: [
        GlassDialogAction(
          label: slang.t.common.cancel,
          emphasized: false,
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: slang.t.common.confirm,
          onPressed: () async {
            Navigator.pop(context);
            try {
              userService.clearAllNotificationCounts();
              await userService.logout();
              showGlassToast(
                slang.t.auth.logoutSuccess,
                type: GlassToastType.success,
              );
            } catch (e) {
              showGlassToast(
                '${slang.t.auth.logoutFailed}: $e',
                type: GlassToastType.error,
              );
            }
          },
        ),
      ],
    );
  }
}
