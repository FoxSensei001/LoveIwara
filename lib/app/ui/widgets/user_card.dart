import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
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
              ),
              if (widget.actions != null) ...[
                const SizedBox(width: 8),
                ...widget.actions!,
              ],
              if (widget.showFollowButton) ...[
                const SizedBox(width: 8),
                FollowButtonWidget(
                  user: user,
                  onUserUpdated: (updatedUser) {
                    setState(() {
                      user = updatedUser;
                    });
                  },
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return AvatarWidget(
      user: user,
      size: 40
    );
  }

  Widget _buildUserName() {
    if (user.name.isEmpty) {
      return Text(
        '@${user.username}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      '@${user.username}',
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
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
          _buildTag(
            label: t.common.premium,
            color: Colors.purple.shade100,
            textColor: Colors.purple,
            key: 'premium',
          ),
        if (user.friend)
          _buildTag(
            label: t.common.friends,
            color: Colors.green.shade100,
            textColor: Colors.green,
            key: 'friend',
          ),
        if (user.following)
          _buildTag(
            label: t.common.followed,
            color: Colors.blue.shade100,
            textColor: Colors.blue,
            key: 'following',
          ),
        if (user.followedBy)
          _buildTag(
            label: t.common.fensi,
            color: Colors.orange.shade100,
            textColor: Colors.orange,
            key: 'followedBy',
          ),
      ],
    );
  }

  Widget _buildTag({
    required String label,
    required Color color,
    required Color textColor,
    required String key,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (key == 'premium')
            Icon(Icons.stars, size: 14, color: textColor)
          else if (key == 'friend')
            Icon(Icons.favorite, size: 14, color: textColor)
          else if (key == 'following')
            Icon(Icons.check_circle, size: 14, color: textColor)
          else if (key == 'followedBy')
            Icon(Icons.person_add, size: 14, color: textColor),
          if (label != '') const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
