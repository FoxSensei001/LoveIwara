import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/quoted_user_cache.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/custom_markdown_body_widget.dart';
import 'package:i_iwara/app/utils/comment_markup.dart';
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
/// ┃ (头像) Bob Smith  @bob              #7 ↗
/// ┃ 原文摘要…
/// ```
///
/// # 头像和昵称是查出来的，不是原文里的
///
/// 发出去的原文只有 `Reply #7: @bob`（格式契约见 [CommentMarkup]，⛔ 不要
/// 为了多画两样东西就往里塞字段——那串字会被 iwara 网页端原样显示）。头像和
/// 昵称由 [QuotedUserCache] 按 username 认：帖子每加载一页就把那页的用户喂进
/// 缓存，所以同页引用是零网络的，只有指向没加载过的楼层时才真去查一次。
///
/// 认不出来时（用户已注销 / 网络不通）就退回只有 `@username` 的样子——那正是
/// 这个组件改造前的全部内容，不是坏掉。
///
/// # 关于可点
///
/// 它曾经刻意做成不可点，理由是「楼层分页在别的页上，给不出可靠的跳转」。
/// 这条理由在 [onTapFloor] 落地后不再成立：楼层号 `replyNum` 是**服务端下发
/// 的全局序号**，第几页算得出来。但可点与否仍由调用方决定——评论区没有楼层
/// 这个概念，那里传 null，于是连手势带指示箭头一起不在场。
class CommentQuoteBlock extends StatefulWidget {
  const CommentQuoteBlock({
    super.key,
    required this.floor,
    required this.username,
    this.excerpt,
    this.padding = const EdgeInsets.only(bottom: 8),
    this.onTapFloor,
  });

  final int floor;
  final String username;
  final String? excerpt;
  final EdgeInsetsGeometry padding;

  /// 点这条引用要去哪儿。null＝不可点（连箭头都不画）。
  final VoidCallback? onTapFloor;

  @override
  State<CommentQuoteBlock> createState() => _CommentQuoteBlockState();
}

class _CommentQuoteBlockState extends State<CommentQuoteBlock> {
  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final excerpt = widget.excerpt;
    final hasExcerpt = excerpt != null && excerpt.isNotEmpty;
    final tappable = widget.onTapFloor != null;

    final card = Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          // 左侧竖条：markdown 引用块的通用形状，也和 composer 里那张
          // 引用卡片对上——写的时候和发出去之后长得一样。
          left: BorderSide(color: cs.primary.withValues(alpha: 0.55), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: QuotedIdentity(
                  username: widget.username,
                  avatarSize: 20,
                  nameColor: cs.primary,
                ),
              ),
              const SizedBox(width: 6),
              // 楼层号钉在行尾：它是「回的哪一楼」这件事里唯一精确的那部分，
              // 名字再长也不该把它挤掉。
              Text(
                '#${widget.floor}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: 0.9),
                  height: 1.2,
                ),
              ),
              if (tappable) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                  color: cs.primary.withValues(alpha: 0.75),
                ),
              ],
            ],
          ),
          if (hasExcerpt) ...[
            const SizedBox(height: 3),
            Text(
              excerpt,
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
    );

    return Padding(
      padding: widget.padding,
      child: Semantics(
        button: tappable,
        label: t.forum.replyToFloor(
          floor: widget.floor.toString(),
          username: widget.username,
        ),
        child: tappable
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTapFloor,
                  borderRadius: BorderRadius.circular(10),
                  child: card,
                ),
              )
            : card,
      ),
    );
  }
}

/// 引用里的那个人：头像 + 昵称 + `@username`，认不出来时只剩 `@username`。
///
/// 两处引用件（列表里的 [CommentQuoteBlock]、写作时的 `GlassQuoteCard`）共用
/// 这一只——⛔ 别再各写一遍。「写的时候和发出去之后长得一样」是引用条从一开始
/// 就立的约定，两份实现迟早会各自漂移。
///
/// 解析规则见 [QuotedUserCache]：命中缓存同步落位，落空才查一次接口。
class QuotedIdentity extends StatefulWidget {
  const QuotedIdentity({
    super.key,
    required this.username,
    this.avatarSize = 20,
    this.nameColor,
    this.dimmed = false,
  });

  final String username;
  final double avatarSize;

  /// 昵称那段用什么颜色。不给就用 primary。
  final Color? nameColor;

  /// 整只压暗（写作侧那张卡在「不带引用」时是灰的）。
  final bool dimmed;

  @override
  State<QuotedIdentity> createState() => _QuotedIdentityState();
}

class _QuotedIdentityState extends State<QuotedIdentity> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _resolveUser();
  }

  @override
  void didUpdateWidget(QuotedIdentity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _user = null;
      _resolveUser();
    }
  }

  void _resolveUser() {
    // 命中缓存就同步落位（不 setState）：列表滚动时重建是常态，走异步会让
    // 引用条每次重建都闪一下「先没有头像、再有头像」。
    final hit = QuotedUserCache.cached(widget.username);
    if (hit != null) {
      _user = hit;
      return;
    }
    if (QuotedUserCache.isMiss(widget.username)) return;

    QuotedUserCache.resolve(widget.username).then((user) {
      if (!mounted || user == null) return;
      setState(() => _user = user);
    });
  }

  void _openProfile() {
    final user = _user;
    if (user == null) return;
    NaviService.navigateToAuthorProfilePage(user.username);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatar(cs),
        SizedBox(width: widget.avatarSize * 0.35),
        Flexible(child: _buildName(cs)),
      ],
    );
  }

  /// 认出人之前画一枚**同尺寸**的静默圆，认出来之后淡入真头像。
  ///
  /// ⛔ 不要在「还没认出来」时缩成零宽：那会让引用条在解析回来的一刻整体跳一下
  /// 行宽。占位与真身同尺寸，换的只是内容（项目约定：出现与消失都要有过渡）。
  Widget _buildAvatar(ColorScheme cs) {
    final user = _user;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      child: user == null
          ? Container(
              key: const ValueKey('quote-avatar-placeholder'),
              width: widget.avatarSize,
              height: widget.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onSurfaceVariant.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.person_rounded,
                size: widget.avatarSize * 0.65,
                color: cs.onSurfaceVariant.withValues(alpha: 0.55),
              ),
            )
          : GestureDetector(
              key: ValueKey('quote-avatar-${user.username}'),
              onTap: _openProfile,
              child: AvatarWidget(user: user, size: widget.avatarSize),
            ),
    );
  }

  Widget _buildName(ColorScheme cs) {
    final handle = '@${widget.username}';
    final nickname = _user?.name.trim() ?? '';
    final Color primary = (widget.nameColor ?? cs.primary).withValues(
      alpha: widget.dimmed ? 0.6 : 1.0,
    );
    final Color muted = cs.onSurfaceVariant.withValues(
      alpha: widget.dimmed ? 0.5 : 0.75,
    );
    final nameStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.2,
    );

    // 昵称和 username 一样时不要写两遍——`user2228613` 这类默认账号在 iwara
    // 上是常态，重复一遍只是把本来就不宽的一行浪费掉。
    if (nickname.isEmpty || nickname == widget.username) {
      return Text(
        handle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: nameStyle,
      );
    }

    return Text.rich(
      TextSpan(
        text: nickname,
        style: nameStyle,
        children: [
          TextSpan(
            text: '  $handle',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: muted,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 正文末尾的小尾巴：**左侧一道细竖条** + 小灰字。
///
/// 旧版小尾巴是拼进正文的普通文字，和正文同样粗细、同样黑，一条两行的回复
/// 里签名能占掉一半视觉权重。这里把它降成脚注。
///
/// ## ⭐ 为什么是竖条，不是一道短横（2026-09-21 拿四个方案并排比过后定的）
///
/// 早先是「12px 短横 + 文字」。那道短横只标得住**第一行**：小尾巴可以是标题
/// 加引用块加分隔线加一排链接（用户模板想怎么排就怎么排），两三行一多，左边
/// 就整片悬空，整段没有边界，和正文末尾黏在一起。
///
/// 竖条随内容长，多行不散架；而且和 [CommentQuoteBlock] 同一套视觉语汇——
/// 「这段不是作者正文」这件事读得最快。比卡片（浅底色块）轻，不会让一屏十条
/// 评论显得沉。
///
/// 对照过的另外两个方案都被否了：全宽细线视觉重量最大，而且用户自排的 `hr`
/// 会和它并排出现两条线；纯卡片多一层背景，密集列表里太重。
///
/// ⚠️ 竖条与 markdown 引用块**会撞脸**（用户自己在小尾巴里写 `> 引用` 时出现
/// 「条中条」）。取舍是认的：那是少数写法，而多行散架是每条多行小尾巴都会有
/// 的问题。真撞上时内层引用块的竖条更粗、有缩进，仍分得出来。
///
/// ## 两条硬约束
///
/// ⛔ **不限行数，也不许把换行压成空格**。小尾巴是用户自己排的模板，可以是
/// 好几行、可以带多个数据源——早先这里写死 `maxLines: 1` 加
/// `replaceAll('\n', ' ')`，于是一条两行的小尾巴在列表里只看得见前半句加一个
/// 省略号（2026-09-21 用户截图）。降权重靠的是字号和颜色，不是把它截断。
///
/// ⛔ **按 markdown 渲染，不是纯文本**。小尾巴原样发到 iwara，网页端照
/// markdown 渲染——用户在模板里写的 `---`、加粗、链接都是**有意为之**。拿
/// `Text` 画的话那条分隔线会显示成三个字面横杠，既和网页端对不上，也把用户
/// 精心排的版拆成一坨（同上，用户截图）。
/// 渲染走 [CustomMarkdownBody] 的 `baseTextStyle` 降级档。
class CommentFooterLine extends StatelessWidget {
  const CommentFooterLine({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(top: 8),
    this.trailing,
  });

  final String text;
  final EdgeInsetsGeometry padding;

  /// 行尾挂一件东西（预览里那枚「换一句」）。列表里恒为 null——别人的评论
  /// 上没有可按的东西。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      // 外层 Row 用 center：[trailing]（预览里那枚「换一句」）比 11px 的字高，
      // 要和整段文字居中对齐，否则它会吊在第一行顶上。
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // ⭐ 竖条用 `Border(left:)` 画，不要「Row + 定高 Container」：
            // 边框天然长到 child 的高度，不必套 IntrinsicHeight 去量一遍。
            // 小尾巴的高度完全由用户模板决定（一行到十几行都可能），任何写死
            // 高度或先量后画的做法在这儿都是错的。
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: cs.outlineVariant, width: 2),
                ),
              ),
              padding: const EdgeInsets.only(left: 9),
              child: CustomMarkdownBody(
                data: text,
                baseTextStyle: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                // 脚注不参与翻译钮 / 长按选中那一套：那些都归正文。
                showTranslationButton: false,
                selectable: false,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// 「发出去之后长什么样」——写作侧的预览体。
///
/// ## ⛔ 预览不要拿 compose 的结果去跑 markdown
///
/// [CommentMarkup.compose] 产出的是**发给服务端的原文**。把那串字直接喂给
/// `CustomMarkdownBody`，引用头会渲染成一个 markdown 引用块、小尾巴会渲染成
/// 一条**全宽 `<hr>`** 加一行与正文同样大同样黑的字；而评论列表里这两段走的
/// 是 [CommentQuoteBlock] 和 [CommentFooterLine]——带左侧竖条的引用条，和
/// 同样带左竖条的 11px / alpha 0.6 脚注。
///
/// 于是同一条内容，用户在预览里看到的和发出去之后看到的是两个样子
/// （2026-09-21 用户报障）。预览要是不能预报结果，它就没有存在的理由。
///
/// 修法不是把两边的样式各调一遍——那种改法下次加一段结构又会裂开。写作侧
/// 手里本来就**有现成的三段**（正文在输入框里、引用和小尾巴是结构，见
/// `BaseInputWidget` 的类文档），根本不必先拼成一串再解析回来。这里就按那
/// 三段，调用与列表**完全相同**的呈现件，一致是结构上保证的。
class CommentStructurePreview extends StatelessWidget {
  const CommentStructurePreview({
    super.key,
    required this.body,
    this.quote,
    this.signature,
    this.signatureTrailing,
    this.showOriginalBody,
    this.onBodyProcessedChanged,
  });

  /// 作者自己写的那部分（输入框里的原文，不含引用与小尾巴）。
  final String body;

  final ReplyQuote? quote;

  /// 小尾巴**求值后**的样子。带 `{变量}` 的原始模板不该传到这儿来。
  final String? signature;

  /// 挂在小尾巴行尾的动作（「换一句」）。
  final Widget? signatureTrailing;

  /// 正文要不要显示未加工的原文。受控于外层标题行那枚玻璃圆钮。
  final bool? showOriginalBody;

  /// 正文有没有「加工痕迹」（决定那枚圆钮出不出现）。
  final ValueChanged<bool>? onBodyProcessedChanged;

  @override
  Widget build(BuildContext context) {
    final trimmedBody = body.trim();
    final trimmedSignature = signature?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (quote != null)
          CommentQuoteBlock(
            floor: quote!.floor,
            username: quote!.username,
            excerpt: quote!.excerpt,
          ),
        if (trimmedBody.isNotEmpty)
          CustomMarkdownBody(
            // 发送时正文会过一道 hardenLineBreaks（把软换行写死成硬换行），
            // 预览要预报的是那之后的样子，所以这里也走同一道。
            data: CommentMarkup.hardenLineBreaks(trimmedBody),
            padding: EdgeInsets.zero,
            selectable: false,
            clickInternalLinkByUrlLaunch: true,
            initialShowUnprocessedText: showOriginalBody,
            onProcessedContentChanged: onBodyProcessedChanged,
          ),
        if (trimmedSignature != null && trimmedSignature.isNotEmpty)
          CommentFooterLine(
            text: trimmedSignature,
            trailing: signatureTrailing,
          ),
      ],
    );
  }
}
