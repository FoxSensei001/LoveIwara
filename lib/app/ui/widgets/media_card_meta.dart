import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/media_card_action_slot.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// 视频卡片与图库卡片共用的那几块「统计 / 作者 / 时间」积木。
///
/// # 为什么要挪位置
///
/// 卡片右下角压着一枚三点钮（见 [MediaCardActionSlot]），它 40×40 的可点面积
/// 正好盖住原来右对齐的发布时间。所以把**只读**的播放量与评论数从文字区的统计
/// 胶囊行搬到缩略图右上角聚成一组（[MediaCardStatsOverlay]），文字区那一行就
/// 只剩点赞，右边腾出来给发布时间（[MediaCardMetaRow]）；作者行则整行给作者名，
/// 只在右侧留出 [kMediaCardActionReserve] 给三点钮让位。
///
/// 点赞不能跟着上去：它是可写的（卡片自己维护一份覆盖态，见 MediaCardActionState），
/// 留在文字区里才有足够的对比度与点击语义。

/// 文字区右侧要给三点钮让出的宽度。
///
/// 钮本身 [kMediaCardActionSlotSize] 宽、贴着卡片右缘，而文字区自带 10 的右内边距，
/// 两者相减就是作者名必须停住的位置。
const double kMediaCardActionReserve = kMediaCardActionSlotSize - 10;

/// 缩略图上沿的圆角。贴在上面两角的标签要拿它当自己的外角，才严丝合缝。
const double kMediaCardThumbnailRadius = 14;

/// 缩略图右上角那组「播放量 / 评论数」标签。
///
/// 聚成**一只**标签而不是两只并排的小片：两条都是同一类只读数据，合在一起读起来
/// 是一组，也少占一份圆角与内边距。评论数为 0 时整段省掉。
///
/// 贴着缩略图右上角，和左下角的 R18、右下角的时长是同一套贴边规矩：**外角跟着
/// 缩略图自己的圆角走，内角固定 6**。缩略图上沿是 [kMediaCardThumbnailRadius]，
/// 所以这里的 topRight 必须是同一个数——小一点会被 ClipRRect 沿那条弧斜切掉一角，
/// 看起来像被裁断了。右内边距也因此比左边宽：那条弧会往里吃掉几个像素，不留够
/// 数字会被啃掉。
///
/// 和 ReblockChip 共用右上角这块地方，所以两者互斥——被屏蔽内容揭示之后统计组
/// 收走、让位给「重新屏蔽」，两个方向都有过渡（[GlassCapsuleReveal]）而不是硬切。
class MediaCardStatsOverlay extends StatelessWidget {
  const MediaCardStatsOverlay({
    super.key,
    required this.views,
    required this.comments,
    this.visible = true,
  });

  final int views;
  final int comments;

  /// 收走让位（例如「重新屏蔽」胶囊正占着同一块地方）。
  final bool visible;

  static const BorderRadius _radius = BorderRadius.only(
    topRight: Radius.circular(kMediaCardThumbnailRadius),
    bottomLeft: Radius.circular(6),
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: GlassCapsuleReveal(
        visible: visible,
        child: ClipRRect(
          borderRadius: _radius,
          child: ColoredBox(
            color: Colors.black54,
            child: Padding(
              // 右边多留几个像素给右上角那条弧（见类文档）。
              padding: const EdgeInsets.fromLTRB(4, 1, 8, 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OverlayStat(
                    icon: Icons.visibility,
                    value: CommonUtils.formatFriendlyNumber(
                      views < 0 ? 0 : views,
                    ),
                  ),
                  if (comments > 0) ...[
                    const _OverlayStatDivider(),
                    _OverlayStat(
                      icon: Icons.forum,
                      value: CommonUtils.formatFriendlyNumber(comments),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 统计组里的一条（图标 + 数字）。字号 / 图标尺寸跟缩略图上其它贴边标签
/// （BaseTag）保持一致。
class _OverlayStat extends StatelessWidget {
  const _OverlayStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: Colors.white),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 10,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

/// 组内两条之间那道发丝线：靠它把「一组」读成两项，而不是把数字挤成一串。
class _OverlayStatDivider extends StatelessWidget {
  const _OverlayStatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 9,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: Colors.white38,
    );
  }
}

/// 文字区里那颗统计胶囊（现在只剩点赞用它）。
class MediaCardStatChip extends StatelessWidget {
  const MediaCardStatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.maxTextWidth = 56,
  });

  final IconData icon;
  final String value;
  final Color color;
  final double maxTextWidth;

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

/// 标题下面那一行：左边点赞胶囊，右边发布时间。
///
/// 时间右对齐是接着卡片原来的读法（以前它在作者行的右端），只是往上挪了一行，
/// 躲开压在右下角的三点钮。
class MediaCardMetaRow extends StatelessWidget {
  const MediaCardMetaRow({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.createdAt,
  });

  final bool isLiked;
  final int likeCount;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontSize: 11,
    );
    final IconData likeIcon = isLiked ? Icons.favorite : Icons.favorite_border;
    final Color likeColor = isLiked
        ? Colors.pink
        : theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 窄卡片摆不下「年-月-日 时:分」，与其让省略号把时间截成半截，不如只留日期。
        final compact = constraints.maxWidth < 150;
        final createdAtText = CommonUtils.formatFriendlyTimestamp(
          createdAt,
          includeTime: !compact,
        );

        return Row(
          children: [
            MediaCardStatChip(
              icon: likeIcon,
              value: CommonUtils.formatFriendlyNumber(
                likeCount < 0 ? 0 : likeCount,
              ),
              color: likeColor,
              maxTextWidth: (constraints.maxWidth - 90).clamp(24.0, 56.0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                createdAtText,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: timeStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 卡片最下面那一行：头像 + 作者名，右侧给三点钮留位。
class MediaCardAuthorLine extends StatelessWidget {
  const MediaCardAuthorLine({
    super.key,
    required this.user,
    required this.isMultiSelectMode,
  });

  final User? user;
  final bool isMultiSelectMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isMultiSelectMode
                ? null
                : () {
                    final username = user?.username;
                    if (username != null && username.isNotEmpty) {
                      NaviService.navigateToAuthorProfilePage(
                        username,
                        initialUser: user,
                      );
                    }
                  },
            child: Row(
              children: [
                AvatarWidget(user: user, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: buildUserName(
                    context,
                    user,
                    bold: true,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 三点钮压在卡片右下角，不留这一段作者名会滑到它底下。
        const SizedBox(width: kMediaCardActionReserve),
      ],
    );
  }
}
