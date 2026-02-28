import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/follow_button_widget.dart';
import 'package:i_iwara/app/ui/widgets/translation_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../../widgets/custom_markdown_body_widget.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailContent extends StatelessWidget {
  final PostDetailController controller;
  final int commentCount;
  final bool showOverviewCard;
  final bool showContentCard;
  final bool includeTopSpacing;
  final double horizontalPadding;
  final String? overviewHeroTag;

  const PostDetailContent({
    super.key,
    required this.controller,
    required this.commentCount,
    this.showOverviewCard = true,
    this.showContentCard = true,
    this.includeTopSpacing = true,
    this.horizontalPadding = 12,
    this.overviewHeroTag,
  });

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon, size: 20), onPressed: onPressed),
    );
  }

  Widget _buildMetaChip({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, PostModel post) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.sizeOf(context).width <= 600;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableText(
            post.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
              fontSize: isSmallScreen ? 20 : 22,
            ),
          ),
        ),
        if (post.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildActionButton(
              context: context,
              icon: Icons.translate,
              onPressed: () {
                showTranslationDialog(context, text: post.title);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAuthorInfo(BuildContext context, PostModel post) {
    final user = post.user;
    final followButton = FollowButtonWidget(
      user: user,
      onUserUpdated: (updatedUser) {
        controller.postInfo.value = controller.postInfo.value?.copyWith(
          user: updatedUser,
        );
      },
    );

    return LayoutBuilder(
      builder: (context, _) {
        final identity = _buildAuthorIdentity(context, user);
        return Row(
          children: [
            Expanded(child: identity),
            Align(alignment: Alignment.centerRight, child: followButton),
          ],
        );
      },
    );
  }

  Widget _buildAuthorIdentity(BuildContext context, User user) {
    return InkWell(
      onTap: () => NaviService.navigateToAuthorProfilePage(user.username),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            _buildAuthorAvatar(user),
            const SizedBox(width: 10),
            Expanded(child: _buildAuthorNameButton(context, user)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar(User user) {
    if (user.premium) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
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
        ),
        child: AvatarWidget(user: user, size: 42),
      );
    }

    return AvatarWidget(user: user, size: 42);
  }

  Widget _buildAuthorNameButton(BuildContext context, User user) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildUserName(context, user, bold: true, fontSize: 16),
        Text(
          '@${user.username}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(BuildContext context, PostModel post) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildMetaChip(
          context: context,
          icon: Icons.calendar_today_rounded,
          text: CommonUtils.formatFriendlyTimestamp(post.createdAt),
        ),
        if (post.updatedAt != post.createdAt)
          _buildMetaChip(
            context: context,
            icon: Icons.edit_calendar_rounded,
            text: CommonUtils.formatFriendlyTimestamp(post.updatedAt),
          ),
        _buildMetaChip(
          context: context,
          icon: Icons.forum_outlined,
          text: CommonUtils.formatFriendlyNumber(commentCount),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(BuildContext context, PostModel post) {
    final theme = Theme.of(context);
    final card = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context, post),
            const SizedBox(height: 12),
            _buildAuthorInfo(context, post),
            const SizedBox(height: 12),
            _buildTimeInfo(context, post),
          ],
        ),
      ),
    );
    if (overviewHeroTag == null) {
      return card;
    }
    return Hero(tag: overviewHeroTag!, child: card);
  }

  Widget _buildContentCard(BuildContext context, PostModel post) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  slang.t.common.content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CustomMarkdownBody(
              data: post.body,
              originalData: post.body,
              showTranslationButton: true,
              translationButtonAtTop: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = controller.postInfo.value;
    if (post == null) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    if (showOverviewCard) {
      children.add(_buildOverviewCard(context, post));
    }
    if (showOverviewCard && showContentCard) {
      children.add(const SizedBox(height: 12));
    }
    if (showContentCard) {
      children.add(_buildContentCard(context, post));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (includeTopSpacing) const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
