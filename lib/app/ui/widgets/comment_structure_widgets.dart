import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 评论 / 楼层正文里那些**不是作者本人写的字**的呈现件。
///
/// 一条回复的原文实际是三段结构（引用头 + 正文 + 小尾巴，契约见
/// `CommentMarkup`），但过去它们在渲染侧完全不被识别——我们自己插进去的引用
/// 头就那样以一行大标题的样子混在正文里，小尾巴也和正文一样重。
///
/// 这里把这两段从正文里提出来单画：引用头成为正文上方的引用条，小尾巴降级成
/// 末行小灰字。识别由 `CommentMarkup.parse` 负责，它同时认得新旧两种格式，
/// 所以**早就发出去的历史回复**一样受益，不需要迁移数据。

/// 正文上方的引用条：这条回复是冲着哪一楼去的。
///
/// ```
/// ┃ ↩ 回复 #7 @bob
/// ┃ 原文摘要…
/// ```
///
/// 刻意**不可点**：楼层分页在别的页上，给不出可靠的跳转，做成看起来能点
/// 却点不动比不做还糟。它只负责把「回的是谁」一眼说清。
class CommentQuoteBlock extends StatelessWidget {
  const CommentQuoteBlock({
    super.key,
    required this.floor,
    required this.username,
    this.excerpt,
    this.padding = const EdgeInsets.only(bottom: 8),
  });

  final int floor;
  final String username;
  final String? excerpt;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final hasExcerpt = excerpt != null && excerpt!.isNotEmpty;

    return Padding(
      padding: padding,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            // 左侧竖条：markdown 引用块的通用形状，也和 composer 里那张
            // 引用卡片对上——写的时候和发出去之后长得一样。
            left: BorderSide(
              color: cs.primary.withValues(alpha: 0.55),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.reply_rounded, size: 13, color: cs.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    t.forum.replyToFloor(
                      floor: floor.toString(),
                      username: username,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            if (hasExcerpt) ...[
              const SizedBox(height: 3),
              Text(
                excerpt!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.25,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 正文末尾的小尾巴行：一条细分隔 + 一行小灰字。
///
/// 旧版小尾巴是拼进正文的普通文字，和正文同样粗细、同样黑，一条两行的回复
/// 里签名能占掉一半视觉权重。这里把它降成脚注。
class CommentFooterLine extends StatelessWidget {
  const CommentFooterLine({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(top: 6),
  });

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 1,
            margin: const EdgeInsets.only(right: 6),
            color: cs.outlineVariant.withValues(alpha: 0.6),
          ),
          Flexible(
            child: Text(
              text.replaceAll('\n', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
