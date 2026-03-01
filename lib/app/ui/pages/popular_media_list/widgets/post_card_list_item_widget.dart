import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

class PostCardListItemWidget extends StatefulWidget {
  final PostModel post;

  const PostCardListItemWidget({super.key, required this.post});

  @override
  State<PostCardListItemWidget> createState() => _PostCardListItemWidgetState();
}

class _PostCardListItemWidgetState extends State<PostCardListItemWidget> {
  bool _isHovering = false;
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 220);
  String get _heroTag => 'post-card-${widget.post.id}';

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
                  onTap: _openPostDetail,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AuthorLine(post: widget.post),
                        const SizedBox(height: 9),
                        Text(
                          widget.post.title.isEmpty
                              ? slang.t.common.noTitle
                              : widget.post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                          ),
                        ),
                        if (widget.post.body.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final lines = constraints.maxWidth < 230 ? 2 : 4;
                              return Text(
                                widget.post.body,
                                maxLines: lines,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 9),
                        _MetaLine(post: widget.post),
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

  void _openPostDetail() {
    final historyRepo = Get.find<HistoryRepository>();
    final body = widget.post.body.length > 200
        ? widget.post.body.substring(0, 200)
        : widget.post.body;
    final postModel = widget.post.copyWith(body: body);
    historyRepo.addRecordWithCheck(HistoryRecord.fromPost(postModel));
    NaviService.navigateToPostDetailPage(widget.post.id, widget.post);
  }

  bool _isDesktopPlatform() {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);
  }
}

class _AuthorLine extends StatelessWidget {
  final PostModel post;

  const _AuthorLine({required this.post});

  @override
  Widget build(BuildContext context) {
    return _buildAuthorIdentity(context);
  }

  Widget _buildAuthorIdentity(BuildContext context) {
    return InkWell(
      onTap: () => NaviService.navigateToAuthorProfilePage(
        post.user.username,
        initialUser: post.user,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            AvatarWidget(user: post.user, size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: buildUserName(
                context,
                post.user,
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

class _MetaLine extends StatelessWidget {
  final PostModel post;

  const _MetaLine({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 220;
        final numberChipTextMaxWidth = ((constraints.maxWidth - 55) / 2).clamp(
          24.0,
          58.0,
        );
        final timeChipTextMaxWidth = (constraints.maxWidth - 32).clamp(
          96.0,
          220.0,
        );

        return Wrap(
          spacing: compact ? 5 : 6,
          runSpacing: 5,
          children: [
            _StatChip(
              icon: Icons.visibility,
              value: CommonUtils.formatFriendlyNumber(post.numViews ?? 0),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: numberChipTextMaxWidth,
            ),
            _TimeChip(
              icon: Icons.calendar_today_rounded,
              value: CommonUtils.formatFriendlyTimestamp(post.createdAt),
              color: theme.colorScheme.onSurfaceVariant,
              maxTextWidth: timeChipTextMaxWidth,
            ),
          ],
        );
      },
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final double maxTextWidth;

  const _TimeChip({
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
          Flexible(
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
