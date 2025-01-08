import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/routes/app_routes.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/author_profile/author_profile_page.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shimmer/shimmer.dart';

class PrivateVideoWidget extends StatefulWidget {
  final User author;

  const PrivateVideoWidget({
    super.key,
    required this.author,
  });

  @override
  State<PrivateVideoWidget> createState() => _PrivateVideoWidgetState();
}

class _PrivateVideoWidgetState extends State<PrivateVideoWidget> {
  final UserService _userService = Get.find();
  bool _isFriendRequestPending = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkRelationshipStatus();
  }

  Future<void> _checkRelationshipStatus() async {
    if (!_userService.isLogin) return;

    try {
      final response = await Get.find<ApiService>()
          .get(ApiConstants.userRelationshipStatus(widget.author.id));
      if (mounted) {
        setState(() {
          _isFriendRequestPending = response.data['status'] == 'pending';
        });
      }
    } catch (e) {
      LogUtils.e('获取关系状态失败', tag: 'PrivateVideoWidget', error: e);
    }
  }

  Future<void> _handleFriendRequest() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isFriendRequestPending) {
        final result = await _userService.cancelFriendRequest(widget.author.id);
        if (result.isSuccess) {
          setState(() => _isFriendRequestPending = false);
        } else {
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
        }
      } else {
        final result = await _userService.addFriend(widget.author.id);
        if (result.isSuccess) {
          setState(() => _isFriendRequestPending = true);
        } else {
          showToastWidget(MDToastWidget(message: result.message, type: MDToastType.error),position: ToastPosition.top);
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 作者头像
            Container(
              decoration: widget.author.premium
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade200,
                          Colors.blue.shade200,
                          Colors.pink.shade200,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : null,
              child: GestureDetector(
                onTap: () {
                  if (widget.author.username.isNotEmpty) {
                    AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
                      settings: RouteSettings(name: Routes.AUTHOR_PROFILE(widget.author.username)),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return AuthorProfilePage(
                          username: widget.author.username,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ));
                  }
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: widget.author.premium
                        ? const EdgeInsets.all(4.0)
                        : EdgeInsets.zero,
                    child: AvatarWidget(
                      avatarUrl: widget.author.avatar?.avatarUrl,
                      defaultAvatarUrl: CommonConstants.defaultAvatarUrl,
                      headers: const {'referer': CommonConstants.iwaraBaseUrl},
                      radius: 40,
                      isPremium: widget.author.premium,
                      isAdmin: widget.author.isAdmin,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 作者名称和标签
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (widget.author.premium)
                  GestureDetector(
                    onTap: () {
                      if (widget.author.username.isNotEmpty) {
                        AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
                          settings: RouteSettings(name: Routes.AUTHOR_PROFILE(widget.author.username)),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return AuthorProfilePage(
                              username: widget.author.username,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ));
                      }
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.purple.shade300,
                            Colors.blue.shade300,
                            Colors.pink.shade300,
                          ],
                        ).createShader(bounds),
                        child: SelectableText(
                          widget.author.name,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      if (widget.author.username.isNotEmpty) {
                        AppService.homeNavigatorKey.currentState?.push(PageRouteBuilder(
                          settings: RouteSettings(name: Routes.AUTHOR_PROFILE(widget.author.username)),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return AuthorProfilePage(
                              username: widget.author.username,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ));
                      }
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SelectableText(
                        widget.author.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                if (widget.author.premium)
                  Tooltip(
                    message: t.common.premium,
                    preferBelow: false,
                    child: Icon(
                      Icons.verified,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 用户名
            if (widget.author.username.isNotEmpty)
              SelectableText(
                '@${widget.author.username}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 16),

            // 私密视频提示
            Text(
              t.videoDetail.privateVideo,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 按钮行
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_userService.currentUser.value?.id != widget.author.id) ...[
                    _buildFriendButton(),
                    const SizedBox(width: 16),
                  ],
                  FilledButton.icon(
                    onPressed: () => AppService.tryPop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(t.common.back),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendButton() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Get.theme.colorScheme.primary.withOpacity(0.3),
        highlightColor: Get.theme.colorScheme.primary.withOpacity(0.6),
        child: FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.person_add),
          label: Text(_isFriendRequestPending ? t.common.cancelFriendRequest : t.common.addFriend),
        ),
      );
    }

    if (widget.author.friend) {
      return FilledButton.icon(
        onPressed: () async {
          final result = await _userService.removeFriend(widget.author.id);
          if (!result.isSuccess) {
            showToastWidget(
              MDToastWidget(message: result.message, type: MDToastType.error),
              position: ToastPosition.top,
            );
          }
        },
        icon: const Icon(Icons.person_remove),
        label: Text(t.common.removeFriend),
      );
    }

    if (_isFriendRequestPending) {
      return FilledButton.icon(
        onPressed: _handleFriendRequest,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        icon: const Icon(Icons.person_remove),
        label: Text(t.common.cancelFriendRequest),
      );
    }

    return FilledButton.icon(
      onPressed: _handleFriendRequest,
      icon: const Icon(Icons.person_add),
      label: Text(t.common.addFriend),
    );
  }
} 