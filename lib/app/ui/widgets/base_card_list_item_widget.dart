import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

class BaseCardListItem extends StatelessWidget {
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
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double borderRadius = 8;

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
          hoverColor: Theme.of(context).hoverColor.withValues(alpha: 0.1),
          splashColor: Theme.of(context).splashColor.withValues(alpha: 0.2),
          highlightColor: Theme.of(context).highlightColor.withValues(alpha: 0.1),
          child: _CardContent(
            thumbnail: thumbnail,
            title: title,
            createdAt: createdAt,
            user: user,
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
  final TextTheme textTheme;

  const _CardContent({
    required this.thumbnail,
    required this.title,
    required this.createdAt,
    required this.user,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.375, // 11:8
          child: thumbnail,
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title(
                title: title,
                textTheme: textTheme,
              ),
              _TimeInfo(
                createdAt: createdAt,
                textTheme: textTheme,
              ),
              const SizedBox(height: 4),
              _AuthorInfo(
                user: user,
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
  final TextTheme textTheme;

  const _Title({
    required this.title,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    // 统一控制两行标题的真实行高，避免缩放卡片时文字被裁剪
    final double baseFontSize = textTheme.bodyLarge!.fontSize!;
    final double fontSize = baseFontSize * 0.95;
    const int maxLines = 2;
    const double lineHeight = 1.25;
    final double textHeight = fontSize * lineHeight * maxLines;

    return SizedBox(
      height: textHeight,
      child: Text(
        title,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: fontSize,
          height: lineHeight,
          fontWeight: FontWeight.bold,
        ),
        strutStyle: const StrutStyle(
          height: lineHeight,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final DateTime? createdAt;
  final TextTheme textTheme;

  const _TimeInfo({
    required this.createdAt,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = textTheme.bodySmall?.fontSize ?? 12;
    return Text(
      CommonUtils.formatFriendlyTimestamp(createdAt),
      style: textTheme.bodySmall?.copyWith(
        fontSize: fontSize * 0.9,
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final User? user;
  final TextTheme textTheme;

  const _AuthorInfo({
    required this.user,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NaviService.navigateToAuthorProfilePage(
          user?.username ?? ''),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 4),
          Expanded(
            child: buildUserName(context, user, bold: true, fontSize: 13)
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return AvatarWidget(
      user: user,
      size: 24
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