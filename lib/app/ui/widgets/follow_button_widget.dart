import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/models/user.model.dart';

import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/overlay_tracker.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/login_service.dart';
import 'package:i_iwara/app/ui/widgets/action_icon_button_scaffold.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/vibrate_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

class FollowButtonWidget extends StatefulWidget {
  final User user;
  final Function(User user)? onUserUpdated;

  /// 仅图标模式（用于空间有限的操作栏）。
  final bool iconOnly;

  const FollowButtonWidget({
    super.key,
    required this.user,
    this.onUserUpdated,
    this.iconOnly = false,
  });

  @override
  State<FollowButtonWidget> createState() => _FollowButtonWidgetState();
}

class _FollowButtonWidgetState extends State<FollowButtonWidget> {
  bool _isLoading = false;
  late User _currentUser;
  final UserService _userService = Get.find();
  final UserPreferenceService _userPreferenceService = Get.find();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  void didUpdateWidget(covariant FollowButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldSyncUser(oldWidget.user, widget.user)) {
      _currentUser = widget.user;
    }
  }

  bool _shouldSyncUser(User oldUser, User newUser) {
    if (oldUser.id != newUser.id) return true;
    if (oldUser.following != newUser.following) return true;
    if (oldUser.followedBy != newUser.followedBy) return true;
    if (oldUser.friend != newUser.friend) return true;
    return false;
  }

  // 构建加载中的按钮
  Widget _buildLoadingButton({
    bool isFollowing = false,
    required BuildContext context,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        // 标准按钮高度，可根据实际需求调整
        height: 48,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24), // 可调整边角弧度以匹配设计
        ),
      ),
    );
  }

  // 显示关注选项底部菜单
  void _showFollowOptionsSheet(BuildContext context) {
    final t = slang.Translations.of(context);
    final RxBool isProcessing = false.obs;
    final UserDTO? likedUser = _userPreferenceService.getLikedUser(
      _currentUser.id,
    );

    showAppBottomSheet(
      Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                enabled: !isProcessing.value,
                leading: Icon(
                  likedUser != null ? Icons.star : Icons.star_border,
                  color: likedUser != null ? Colors.amber : null,
                ),
                title: Text(
                  likedUser != null
                      ? t.common.cancelSpecialFollow
                      : t.common.specialFollow,
                ),
                trailing: isProcessing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () async {
                  VibrateUtils.vibrate();
                  final UserService userService = Get.find();
                  if (!userService.isLogin) {
                    showToastWidget(
                      MDToastWidget(
                        message: t.errors.pleaseLoginFirst,
                        type: MDToastType.error,
                      ),
                    );
                    LoginService.showLogin();
                    return;
                  }
                  if (likedUser != null) {
                    _userPreferenceService.removeLikedUser(likedUser);
                  } else {
                    _userPreferenceService.addLikedUser(
                      UserDTO(
                        id: _currentUser.id,
                        name: _currentUser.name,
                        username: _currentUser.username,
                        avatarUrl: _currentUser.avatar?.avatarUrl ?? '',
                        likedTime: DateTime.now(),
                      ),
                    );
                  }
                  final rootNavigator = Navigator.of(
                    context,
                    rootNavigator: true,
                  );
                  if (rootNavigator.canPop()) {
                    rootNavigator.pop();
                  }
                },
              ),
              ListTile(
                enabled: !isProcessing.value,
                leading: const Icon(Icons.notifications_off),
                title: Text(t.common.unfollow),
                trailing: isProcessing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () async {
                  VibrateUtils.vibrate();
                  final UserService userService = Get.find();
                  if (!userService.isLogin) {
                    showToastWidget(
                      MDToastWidget(
                        message: t.errors.pleaseLoginFirst,
                        type: MDToastType.error,
                      ),
                    );
                    LoginService.showLogin();
                    return;
                  }
                  isProcessing.value = true;
                  try {
                    final result = await _userService.unfollowUser(
                      _currentUser.id,
                    );
                    if (!mounted) return;
                    if (result.isSuccess) {
                      final likedUser = _userPreferenceService.getLikedUser(
                        _currentUser.id,
                      );
                      if (likedUser != null) {
                        _userPreferenceService.removeLikedUser(likedUser);
                      }

                      final updatedUser = _currentUser.copyWith(
                        following: false,
                        friend: false,
                      );
                      setState(() {
                        _currentUser = updatedUser;
                      });
                      widget.onUserUpdated?.call(updatedUser);
                      if (OverlayTracker.instance.hasOverlay) {
                        AppService.tryPop();
                      }
                    } else {
                      showToastWidget(
                        MDToastWidget(
                          message: result.message,
                          type: MDToastType.error,
                        ),
                        position: ToastPosition.top,
                      );
                    }
                  } catch (e) {
                    showToastWidget(
                      MDToastWidget(
                        message: t.errors.failedToOperate,
                        type: MDToastType.error,
                      ),
                      position: ToastPosition.top,
                    );
                  } finally {
                    isProcessing.value = false;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFollow(BuildContext context) async {
    final t = slang.Translations.of(context);
    VibrateUtils.vibrate();
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _userService.followUser(_currentUser.id);
      if (result.isSuccess) {
        final updatedUser = _currentUser.copyWith(following: true);
        setState(() {
          _currentUser = updatedUser;
        });
        widget.onUserUpdated?.call(updatedUser);
        final configService = Get.find<ConfigService>();
        final showFollowTipCount =
            configService[ConfigKey.SHOW_FOLLOW_TIP_COUNT] as int;
        final random = Random();
        if (showFollowTipCount > 0) {
          final shouldShow =
              showFollowTipCount > 0 && random.nextDouble() < 0.5;
          if (shouldShow) {
            final ctx = context;
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    "🔔 ${t.common.followSuccessClickAgainToSpecialFollow}",
                  ),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.green,
                ),
              );
            }

            final newCount = max(0, showFollowTipCount - 1);
            configService.setSetting(ConfigKey.SHOW_FOLLOW_TIP_COUNT, newCount);
          }
        }
      } else {
        showToastWidget(
          MDToastWidget(message: result.message, type: MDToastType.error),
          position: ToastPosition.top,
        );
      }
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: t.errors.failedToOperate,
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 如果是自己，不显示关注按钮
    if (_userService.currentUser.value?.id == _currentUser.id) {
      return const SizedBox.shrink();
    }

    if (widget.iconOnly) {
      return _buildIconOnly(context);
    }

    if (_isLoading) {
      return _buildLoadingButton(
        isFollowing: _currentUser.following,
        context: context,
      );
    }

    if (!_currentUser.following) {
      return ElevatedButton.icon(
        onPressed: () => _handleFollow(context),
        icon: const Icon(Icons.notifications_none, size: 18),
        label: Text(t.common.follow),
      );
    }

    return Obx(() {
      final isSpecialFollowed = _userPreferenceService.likedUsers.any(
        (u) => u.id == _currentUser.id,
      );
      return ElevatedButton.icon(
        style: isSpecialFollowed
            ? ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              )
            : null,
        onPressed: () {
          _showFollowOptionsSheet(context);
        },
        icon: Icon(
          isSpecialFollowed ? Icons.stars : Icons.notifications_active,
          size: 18,
        ),
        label: Text(t.common.followed),
      );
    });
  }

  Widget _buildIconOnly(BuildContext context) {
    final t = slang.Translations.of(context);
    if (_isLoading) {
      return ActionIconButtonScaffold.loading();
    }
    if (!_currentUser.following) {
      return ActionIconButtonScaffold(
        icon: Icons.notifications_none,
        tooltip: t.common.follow,
        filled: true,
        onPressed: () => _handleFollow(context),
      );
    }
    return Obx(() {
      final isSpecialFollowed = _userPreferenceService.likedUsers.any(
        (u) => u.id == _currentUser.id,
      );
      return ActionIconButtonScaffold(
        icon: isSpecialFollowed ? Icons.star : Icons.notifications_active,
        tooltip: t.common.followed,
        selected: true,
        highlightColor: isSpecialFollowed ? Colors.amber : null,
        onPressed: () => _showFollowOptionsSheet(context),
      );
    });
  }
}
