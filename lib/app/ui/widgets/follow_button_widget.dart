import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/dto/user_dto.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';
import 'package:vibration/vibration.dart';

class FollowButtonWidget extends StatefulWidget {
  final User user;
  final Function(User user)? onUserUpdated;

  const FollowButtonWidget({
    super.key,
    required this.user,
    this.onUserUpdated,
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

  // 构建加载中的按钮
  Widget _buildLoadingButton({bool isFollowing = false, required BuildContext context}) {
    final t = slang.Translations.of(context);
    return ElevatedButton.icon(
      onPressed: null,
      icon: isFollowing ? const Icon(Icons.check, size: 18) : const Icon(Icons.person_add, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 4),
          Text(isFollowing ? t.common.followed : t.common.follow),
        ],
      ),
    );
  }

  // 显示关注选项底部菜单
  void _showFollowOptionsSheet(BuildContext context) {
    final t = slang.Translations.of(context);
    final RxBool isProcessing = false.obs;
    final UserDTO? likedUser =
        _userPreferenceService.getLikedUser(_currentUser.id);

    Get.bottomSheet(
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
                title: Text(likedUser != null ? t.common.cancelSpecialFollow : t.common.specialFollow),
                trailing: isProcessing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () async {
                  final UserService userService = Get.find();
                  if (!userService.isLogin) {
                    showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                    Get.toNamed(Routes.LOGIN);
                    return;
                  }
                  if (likedUser != null) {
                    _userPreferenceService.removeLikedUser(likedUser);
                  } else {
                    _userPreferenceService.addLikedUser(UserDTO(
                      id: _currentUser.id,
                      name: _currentUser.name,
                      username: _currentUser.username,
                      avatarUrl: _currentUser.avatar?.avatarUrl ?? '',
                    ));
                  }
                  if (Get.isBottomSheetOpen ?? false) {
                    Get.closeAllBottomSheets();
                  }
                  // 震动
                  if (await Vibration.hasVibrator() ?? false) {
                    await Vibration.vibrate(pattern: [500]);
                  }
                },
              ),
              ListTile(
                enabled: !isProcessing.value,
                leading: const Icon(Icons.person_remove),
                title: Text(t.common.unfollow),
                trailing: isProcessing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () async {
                  final UserService userService = Get.find();
                  if (!userService.isLogin) {
                    showToastWidget(MDToastWidget(message: t.errors.pleaseLoginFirst, type: MDToastType.error));
                    Get.toNamed(Routes.LOGIN);
                    return;
                  }
                  isProcessing.value = true;
                  try {
                    final result =
                        await _userService.unfollowUser(_currentUser.id);
                    if (result.isSuccess) {
                      final likedUser =
                          _userPreferenceService.getLikedUser(_currentUser.id);
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
                      if (Get.isBottomSheetOpen ?? false) {
                        Get.closeAllBottomSheets();
                      }
                    } else {
                      showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
                    }
                  } catch (e) {
                    showToastWidget(MDToastWidget(message: t.errors.failedToOperate, type: MDToastType.error),position: ToastPosition.top);
                  } finally {
                    isProcessing.value = false;
                    // 震动
                    if (await Vibration.hasVibrator() ?? false) {
                      await Vibration.vibrate(pattern: [500]);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      isDismissible: !isProcessing.value,
      enableDrag: !isProcessing.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 如果是自己，不显示关注按钮
    if (_userService.currentUser.value?.id == _currentUser.id) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return _buildLoadingButton(isFollowing: _currentUser.following, context: context);
    }

    if (!_currentUser.following) {
      return ElevatedButton.icon(
        onPressed: () async {
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
            } else {
              showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
            }
          } catch (e) {
            showToastWidget(MDToastWidget(message: t.errors.failedToOperate, type: MDToastType.error),position: ToastPosition.top);
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        },
        icon: const Icon(Icons.person_add, size: 18),
        label: Text(t.common.follow),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showFollowOptionsSheet(context),
      icon: const Icon(Icons.check, size: 18),
      label: Text(t.common.followed),
    );
  }
}
