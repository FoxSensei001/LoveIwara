import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import '../../../common/constants.dart';

class BaseCardListItem extends StatelessWidget {
  static const double narrowScreenWidth = 600;

  final double width;
  final Widget thumbnail;
  final String title;
  final DateTime? createdAt;
  final User? user;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;

  const BaseCardListItem({
    super.key,
    required this.width,
    required this.thumbnail,
    required this.title,
    required this.createdAt,
    required this.user,
    required this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNarrowScreen = MediaQuery.of(context).size.width < narrowScreenWidth;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double borderRadius = isNarrowScreen ? 6 : 8;

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius)
        ),
        child: InkWell(
          onTap: onTap,
          onSecondaryTap: onSecondaryTap,
          onLongPress: onLongPress,
          hoverColor: Theme.of(context).hoverColor.withOpacity(0.1),
          splashColor: Theme.of(context).splashColor.withOpacity(0.2),
          highlightColor: Theme.of(context).highlightColor.withOpacity(0.1),
          child: _CardContent(
            thumbnail: thumbnail,
            title: title,
            createdAt: createdAt,
            user: user,
            isNarrowScreen: isNarrowScreen,
            textTheme: textTheme,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Widget thumbnail;
  final String title;
  final DateTime? createdAt;
  final User? user;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _CardContent({
    required this.thumbnail,
    required this.title,
    required this.createdAt,
    required this.user,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: isNarrowScreen ? 16 / 12 : 220 / 160,
          child: thumbnail,
        ),
        Padding(
          padding: EdgeInsets.all(isNarrowScreen ? 6.0 : 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                title: title,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              _TimeInfo(
                createdAt: createdAt,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
              SizedBox(height: isNarrowScreen ? 4 : 8),
              _AuthorInfo(
                user: user,
                isNarrowScreen: isNarrowScreen,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BaseTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Color? textColor;

  const BaseTag({
    super.key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.borderRadius,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(color: backgroundColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 10, color: textColor),
              const SizedBox(width: 2),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _Title({
    required this.title,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: textTheme.bodyLarge!.fontSize! * 3.0,
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isNarrowScreen 
              ? textTheme.bodyLarge!.fontSize! * 0.9
              : textTheme.bodyLarge!.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final DateTime? createdAt;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _TimeInfo({
    required this.createdAt,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CommonUtils.formatFriendlyTimestamp(createdAt),
      style: textTheme.bodySmall?.copyWith(
        fontSize: isNarrowScreen ? 11 : textTheme.bodySmall?.fontSize,
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final User? user;
  final bool isNarrowScreen;
  final TextTheme textTheme;

  const _AuthorInfo({
    required this.user,
    required this.isNarrowScreen,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(isNarrowScreen),
          const SizedBox(width: 4),
          Expanded(
            child: buildUserName(context, user, bold: true, fontSize: isNarrowScreen ? 12 : 14)
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isNarrowScreen) {
    return AvatarWidget(
      user: user,
      size: 30
    );
  }
}

class BaseTagBorderRadius {
  static const tagBorderRadius = BorderRadius.only(
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(4),
  );

  static const likeTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(4),
    bottomRight: Radius.circular(6),
  );

  static const viewTagBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(6),
    bottomRight: Radius.circular(4),
  );

  static const imageNumTagBorderRadius = BorderRadius.only(
    topRight: Radius.circular(4),
    bottomLeft: Radius.circular(6),
  );
} 