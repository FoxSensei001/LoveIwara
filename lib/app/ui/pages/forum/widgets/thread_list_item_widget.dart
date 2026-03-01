import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

class ThreadListItemWidget extends StatefulWidget {
  final ForumThreadModel thread;
  final String categoryId;
  final VoidCallback? onTap;

  const ThreadListItemWidget({
    super.key,
    required this.thread,
    required this.categoryId,
    this.onTap,
  });

  @override
  State<ThreadListItemWidget> createState() => _ThreadListItemWidgetState();
}

class _ThreadListItemWidgetState extends State<ThreadListItemWidget> {
  bool _isHovering = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);
  String get _heroTag => 'forum-thread-card-${widget.thread.id}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);
    final enableHover = _isDesktopPlatform();
    final showHoverState = enableHover && _isHovering;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: enableHover ? (_) => setState(() => _isHovering = true) : null,
        onExit: enableHover ? (_) => setState(() => _isHovering = false) : null,
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
          child: Hero(
            tag: _heroTag,
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: radius,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: showHoverState ? 0.6 : 0.3,
                    ),
                  ),
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap:
                      widget.onTap ??
                      () {
                        NaviService.navigateToForumThreadDetailPage(
                          widget.categoryId,
                          widget.thread.id,
                          initialThread: widget.thread,
                        );
                      },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AuthorLine(thread: widget.thread),
                        const SizedBox(height: 8),
                        _TitleLine(thread: widget.thread),
                        const SizedBox(height: 8),
                        _MetaLine(thread: widget.thread),
                        if (widget.thread.lastPost != null) ...[
                          const SizedBox(height: 8),
                          _LastReplyLine(thread: widget.thread),
                        ],
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

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}

class _AuthorLine extends StatelessWidget {
  final ForumThreadModel thread;

  const _AuthorLine({required this.thread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 11,
    );
    final createdAtText = CommonUtils.formatFriendlyTimestamp(thread.createdAt);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 230;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthorIdentity(context),
              const SizedBox(height: 4),
              Text(
                createdAtText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: timeStyle,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildAuthorIdentity(context)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                createdAtText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: timeStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthorIdentity(BuildContext context) {
    return InkWell(
      onTap: () => NaviService.navigateToAuthorProfilePage(
        thread.user.username,
        initialUser: thread.user,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            AvatarWidget(user: thread.user, size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: buildUserName(
                context,
                thread.user,
                bold: true,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleLine extends StatelessWidget {
  final ForumThreadModel thread;

  const _TitleLine({required this.thread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      thread.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.22,
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final ForumThreadModel thread;

  const _MetaLine({required this.thread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;
        final chipTextMaxWidth = ((constraints.maxWidth - 55) / 2).clamp(
          24.0,
          58.0,
        );

        return Wrap(
          spacing: compact ? 5 : 6,
          runSpacing: 5,
          children: [
            if (thread.sticky)
              _StatusIconChip(
                icon: Icons.push_pin_rounded,
                color: theme.colorScheme.primary,
              ),
            if (thread.locked)
              _StatusIconChip(
                icon: Icons.lock_rounded,
                color: theme.colorScheme.error,
              ),
            _StatChip(
              icon: Icons.visibility,
              value: CommonUtils.formatFriendlyNumber(thread.numViews),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: chipTextMaxWidth,
            ),
            _StatChip(
              icon: Icons.forum_outlined,
              value: CommonUtils.formatFriendlyNumber(thread.numPosts),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: chipTextMaxWidth,
            ),
          ],
        );
      },
    );
  }
}

class _LastReplyLine extends StatelessWidget {
  final ForumThreadModel thread;

  const _LastReplyLine({required this.thread});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastPost = thread.lastPost!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.34,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => NaviService.navigateToAuthorProfilePage(
              lastPost.user.username,
              initialUser: lastPost.user,
            ),
            borderRadius: BorderRadius.circular(99),
            child: AvatarWidget(user: lastPost.user, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => NaviService.navigateToAuthorProfilePage(
                          lastPost.user.username,
                          initialUser: lastPost.user,
                        ),
                        child: buildUserName(
                          context,
                          lastPost.user,
                          bold: true,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (lastPost.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lastPost.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIconChip extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatusIconChip({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 19, minWidth: 27),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final double maxTextWidth;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.maxTextWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxTextWidth + 24),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxTextWidth),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
