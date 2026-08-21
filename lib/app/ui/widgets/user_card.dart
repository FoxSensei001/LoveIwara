import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 用户卡片的外壳：不透明 surface 底 + 发丝描边 + 圆角 14 的 Ink 卡片
/// （无 Material Card 的投影），桌面端悬停时投影浮起。
///
/// 与论坛贴子项、通知项同一套设计语言。[UserCard]（吃 [User]）和特别关注列表
/// （吃 `UserDTO`，字段不足以拼出 [User]）都套这一层，避免两处各画一套卡片。
class UserCardShell extends StatefulWidget {
  const UserCardShell({
    super.key,
    required this.leading,
    required this.child,
    this.actions,
    this.onTap,
    this.color,
  });

  /// 左侧头像。
  final Widget leading;

  /// 中间的信息列（会被 Expanded 包住）。
  final Widget child;

  /// 右侧动作区。
  final List<Widget>? actions;

  /// 卡片底色；不传用 surface。未读会话等场景传一层淡染主题色
  /// （与通知卡片的未读表达同一套）。
  final Color? color;

  final VoidCallback? onTap;

  @override
  State<UserCardShell> createState() => _UserCardShellState();
}

class _UserCardShellState extends State<UserCardShell> {
  bool _isHovering = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final enableHover = _isDesktopPlatform();
    final showHoverState = enableHover && _isHovering;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RepaintBoundary(
        child: MouseRegion(
          onEnter: enableHover
              ? (_) => setState(() => _isHovering = true)
              : null,
          onExit: enableHover
              ? (_) => setState(() => _isHovering = false)
              : null,
          child: AnimatedContainer(
            duration: _hoverAnimationDuration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(
                    alpha: showHoverState ? 0.2 : 0.08,
                  ),
                  blurRadius: showHoverState ? 18 : 8,
                  offset: Offset(0, showHoverState ? 8 : 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  color: widget.color ?? theme.colorScheme.surface,
                  borderRadius: radius,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: showHoverState ? 0.6 : 0.3,
                    ),
                  ),
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        widget.leading,
                        const SizedBox(width: 12),
                        Expanded(child: widget.child),
                        // 动作之间也留 8：关注钮 + 额外动作并排时不能贴在一起
                        for (final action in widget.actions ?? const <Widget>[])
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 用户列表项卡片（好友 / 关注 / 粉丝 / 搜索用户结果共用）。
class UserCard extends StatefulWidget {
  final User user;
  final List<Widget>? actions;
  final bool showFollowButton;

  const UserCard({
    super.key,
    required this.user,
    this.actions,
    this.showFollowButton = false,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  void didUpdateWidget(UserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 列表刷新后同一个位置换了人：不同步就会一直显示旧用户
    if (oldWidget.user != widget.user) user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return UserCardShell(
      onTap: () => NaviService.navigateToAuthorProfilePage(
        user.username,
        initialUser: user,
      ),
      leading: _buildAvatar(),
      actions: [
        ...?widget.actions,
        if (widget.showFollowButton)
          FollowButtonWidget(
            user: user,
            onUserUpdated: (updatedUser) {
              setState(() {
                user = updatedUser;
              });
            },
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildUserName(context, user, fontSize: 16),
          if (user.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildUserName(),
          ],
          const SizedBox(height: 8),
          _buildTags(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AvatarWidget(user: user, size: 40);
  }

  Widget _buildUserName() {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      '@${user.username}',
      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTags(BuildContext context) {
    final t = slang.Translations.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (user.premium)
          _buildChip(
            icon: Icons.stars,
            label: t.common.premium,
            color: Colors.purple,
          ),
        if (user.friend)
          _buildChip(
            icon: Icons.favorite,
            label: t.common.friends,
            color: Colors.green,
          ),
        if (user.following)
          _buildChip(
            icon: Icons.check_circle,
            label: t.common.followed,
            color: Colors.blue,
          ),
        if (user.followedBy)
          _buildChip(
            icon: Icons.person_add,
            label: t.common.fensi,
            color: Colors.orange,
          ),
      ],
    );
  }

  /// 软色 chip：12% 透明度的语义色打底、圆角 999、小图标 + 小号粗体字，
  /// 无投影（与论坛贴子项的 _StatChip / _StatusIconChip 同款）。
  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
