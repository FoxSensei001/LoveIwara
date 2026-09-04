// 长按 / 右键卡片弹出的**媒体预览弹窗**（视频与图库共用）。
//
// # 它和操作菜单的分工
//
// 2026-08-29 那次收口把长按 / 右键 / 三点钮**全部**指向了操作菜单，同时删掉了
// 只能看不能动手的 `VideoPreviewDetailModal`。现在重新分家，但分法变了：
//
//   - **长按 / 右键 → 预览弹窗**：想「凑近看一眼」——大封面（视频还会自动放
//     动图预览）、完整标题、作者、统计、标签，不用离开列表。
//   - **三点钮 → 操作菜单**：想「对它做点什么」。菜单里第一条就是「预览」，
//     所以从三点钮也够得到这张弹窗。
//   - 预览弹窗自己带一行快捷操作（点赞 / 稍后再看 / 更多），「更多」原地吐出
//     同一只操作菜单——两层不重复实现，只是入口不同。
//
// # ⛔ 为什么不是 `showAppDialog`
//
// Hero 飞行的硬门槛：`HeroController._maybeStartHeroTransition` 要求**首尾都是
// `PageRoute`**。`showAppDialog` 走的 `GlassDialogRoute` 是 `RawDialogRoute`
// （`PopupRoute`），Hero 在它身上一次都不会飞——被删掉的那只旧预览弹窗里就写着
// `Hero(tag: 'card-...')`，那句从来没生效过。
//
// 所以这里自起一条 [MediaPreviewRoute]：`PageRoute` 的子类，但 `opaque` 关掉、
// 带遮罩、`canTransitionFrom` 返回 false（否则身后那一页会跟着跑自己的「被盖住」
// 转场，读起来像换了页而不是弹出一层）。出入场仍然复用 [GlassDialogTransition]
// ——液态档、`GlassDialogMotionScope`、以及「不许有透明度层」那条规矩都在它里面，
// 这条新路由一条都不绕。
//
// # ⛔ Hero 标签只在弹窗开着时挂
//
// 同一条视频在一个路由里出现两次并不是不可能（详情页的相关推荐 + 侧边「接着看」
// 抽屉），而重复的 Hero tag 在 debug 下是直接炸断言。所以卡片那侧的 Hero 由
// `HeroMode` 控制，**只有正在打开预览的那张卡片**才把它打开（见
// `MediaCardActionState.openPreview`）——同时只可能有一张，重复从此不可能发生，
// 顺带也省掉了列表里几十个常驻 Hero 的开销。

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/tags_display_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 卡片缩略图 ↔ 弹窗封面之间的 Hero 标签。
///
/// 两侧必须算出同一个值，所以由这里统一给，别在调用点各拼各的。
String mediaPreviewHeroTag({Video? video, ImageModel? gallery}) {
  assert(
    (video == null) != (gallery == null),
    'mediaPreviewHeroTag 一次只处理一条媒体：video 与 gallery 二选一',
  );
  final String kind = video != null ? 'video' : 'gallery';
  return 'media-preview:$kind:${video?.id ?? gallery!.id}';
}

/// 预览弹窗的路由。见文件头「为什么不是 showAppDialog」。
class MediaPreviewRoute<T> extends PageRoute<T> {
  MediaPreviewRoute({
    required this.builder,
    required this.themes,
    required this.barrierLabel,
  }) : super(barrierDismissible: true);

  final WidgetBuilder builder;
  final CapturedThemes themes;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => Colors.black54;

  /// 身后那一页要一直看得见——这是一层浮在列表上的卡片，不是新的一页。
  @override
  bool get opaque => false;

  @override
  bool get maintainState => true;

  /// ⛔ 关掉「上一页被盖住」那段转场。
  ///
  /// `TransitionRoute._updateSecondaryAnimation` 要首尾双方都点头才会驱动
  /// `secondaryAnimation`；上一页是 `PageRoute`，它的 `canTransitionTo` 恒真，
  /// 只能由这边否掉。不否的话身后整页会跟着缩/滑一次，而它明明还全须全尾地
  /// 在那儿——预览是浮上来的一层，不是翻了一页。
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;

  @override
  Duration get transitionDuration => GlassTokens.dialogEnterDuration;

  @override
  Duration get reverseTransitionDuration => GlassTokens.dialogExitDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return themes.wrap(SafeArea(child: Builder(builder: builder)));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 面板恒是一张带外边距的卡片（两种版式都不铺满），所以固定走 scale：
    // 窄屏那条 page 档是给整页承载的弹窗用的，这里用它会和 Hero 抢方向。
    return GlassDialogTransition(
      animation: animation,
      motion: GlassDialogMotion.scale,
      child: child,
    );
  }
}

/// 打开媒体预览弹窗。
///
/// [onOpenDetail] 是「打开」那枚主按钮要走的路——各卡片打开详情页的参数不一样
/// （图库要带封面/张数，视频要带 extData 回灌点赞），所以由卡片自己给。
///
/// [onLikeChanged] 让卡片把点赞态跟上（列表不一定重建）。
Future<void> showMediaPreviewDialog({
  required BuildContext context,
  Video? video,
  ImageModel? gallery,
  bool? likedOverride,
  int? likeCountOverride,
  ValueChanged<bool>? onLikeChanged,
  required Future<void> Function() onOpenDetail,
}) {
  assert(
    (video == null) != (gallery == null),
    'showMediaPreviewDialog 一次只处理一条媒体：video 与 gallery 二选一',
  );

  final navigator = Navigator.of(context, rootNavigator: true);
  // 弹窗路由挂在 root Navigator 下，与调用方不共享子树；显式把主题类
  // InheritedWidget 带过去，同 showAppDialog。
  final themes = InheritedTheme.capture(from: context, to: navigator.context);

  final route = MediaPreviewRoute<void>(
    themes: themes,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    builder: (_) => MediaPreviewDialog(
      video: video,
      gallery: gallery,
      likedOverride: likedOverride,
      likeCountOverride: likeCountOverride,
      onLikeChanged: onLikeChanged,
      onOpenDetail: onOpenDetail,
    ),
  );
  navigator.push<void>(route);
  // 交结果的时机是 completed（路由销毁、Hero 回飞跑完）而不是 popped，
  // 卡片那侧的 HeroMode 要一直开到这一刻，同 showAppDialog 的理由。
  return route.completed;
}

/// 预览弹窗的面板。用 [showMediaPreviewDialog] 打开，别直接塞进别的路由。
class MediaPreviewDialog extends StatefulWidget {
  const MediaPreviewDialog({
    super.key,
    this.video,
    this.gallery,
    this.likedOverride,
    this.likeCountOverride,
    this.onLikeChanged,
    required this.onOpenDetail,
  });

  final Video? video;
  final ImageModel? gallery;
  final bool? likedOverride;
  final int? likeCountOverride;
  final ValueChanged<bool>? onLikeChanged;
  final Future<void> Function() onOpenDetail;

  @override
  State<MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<MediaPreviewDialog> {
  /// 宽屏版式里封面那一栏的宽度。
  ///
  /// 420 × 9/16 = 236 的封面高度，正好和右栏「标题两行 + 作者 + 统计 + 动作行」
  /// 的自然高度对得上——再宽右栏就被挤成窄条，再窄封面就失去了「看清楚一点」
  /// 这个存在理由。
  static const double _wideCoverWidth = 420;

  late bool _liked = widget.likedOverride ?? _sourceLiked;
  late int _likeCount = widget.likeCountOverride ?? _sourceLikeCount;
  late bool _inWatchLater = _readWatchLater();
  bool _likeBusy = false;

  Video? get _video => widget.video;
  ImageModel? get _gallery => widget.gallery;
  String get _mediaId => _video?.id ?? _gallery!.id;
  User? get _user => _video?.user ?? _gallery?.user;
  List<Tag> get _tags => _video?.tags ?? _gallery?.tags ?? const <Tag>[];

  bool get _sourceLiked => _video?.liked ?? _gallery?.liked ?? false;
  int get _sourceLikeCount => _video?.numLikes ?? _gallery?.numLikes ?? 0;

  WatchLaterItemType get _watchLaterType =>
      _video != null ? WatchLaterItemType.video : WatchLaterItemType.image;

  bool _readWatchLater() {
    try {
      return WatchLaterService.to.contains(_mediaId, _watchLaterType);
    } catch (_) {
      // 服务没注册（单测 / 极早期启动）时当作「不在」，这一枚钮照常能按。
      return false;
    }
  }

  String get _title {
    final String title = (_video?.title ?? _gallery?.title ?? '').trim();
    return title.isEmpty ? slang.t.common.noTitle : title;
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _openDetail() async {
    _close();
    await widget.onOpenDetail();
  }

  void _applyLike(bool liked) {
    if (!mounted) return;
    setState(() {
      _liked = liked;
      _likeCount = (_likeCount + (liked ? 1 : -1)).clamp(0, 1 << 31);
    });
    widget.onLikeChanged?.call(liked);
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);
    try {
      await toggleMediaLike(
        slang.Translations.of(context),
        video: _video,
        gallery: _gallery,
        currentlyLiked: _liked,
        onLikeChanged: _applyLike,
      );
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  void _toggleWatchLater() {
    toggleMediaWatchLater(
      slang.Translations.of(context),
      video: _video,
      gallery: _gallery,
      currentlyIn: _inWatchLater,
    );
    if (!mounted) return;
    setState(() => _inWatchLater = _readWatchLater());
  }

  /// 「更多」→ 原地吐出那只玻璃操作菜单。
  ///
  /// 不传 `onPreview`：预览弹窗自己就是预览，菜单里再挂一条「预览」等于让人
  /// 在自己身上打转。
  Future<void> _openActionMenu(BuildContext buttonContext) async {
    await showMediaActionMenu(
      anchorContext: buttonContext,
      video: _video,
      gallery: _gallery,
      likedOverride: _liked,
      onLikeChanged: _applyLike,
      onChanged: () {
        if (mounted) setState(() => _inWatchLater = _readWatchLater());
      },
    );
    if (!mounted) return;
    setState(() => _inWatchLater = _readWatchLater());
  }

  void _openAuthor() {
    final String username = (_user?.username ?? '').trim();
    if (username.isEmpty) return;
    _close();
    NaviService.navigateToAuthorProfilePage(username, initialUser: _user);
  }

  void _openTag(Tag tag) {
    _close();
    if (_video != null) {
      NaviService.navigateToTagVideoListPage(tag);
    } else {
      NaviService.navigateToTagGalleryListPage(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final bool wide = screen.width >= GlassTokens.dialogWideBreakpoint;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: wide ? 880 : 460,
            // 内容再多也不许顶到屏幕边——超出的部分在面板内部滚。
            maxHeight: screen.height * 0.86,
          ),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            elevation: 6,
            child: wide ? _buildWide(context) : _buildNarrow(context),
          ),
        ),
      ),
    );
  }

  /// 手机版式：封面在上、信息在中间滚动、动作行钉在底。
  Widget _buildNarrow(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCoverSlot(
          const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: _buildDetails(context),
          ),
        ),
        _buildActionBar(context),
      ],
    );
  }

  /// PC / 平板版式：左封面右信息。
  ///
  /// 右栏用 `minHeight = 封面高` + `spaceBetween` 把动作行压到和封面同底：
  /// 信息短的时候两栏齐平，长的时候右栏自己长高、内部滚动。
  Widget _buildWide(BuildContext context) {
    const double coverHeight = _wideCoverWidth * 9 / 16;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _wideCoverWidth,
          child: _buildCoverSlot(
            const BorderRadius.horizontal(left: Radius.circular(28)),
          ),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: coverHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: _buildDetails(context),
                  ),
                ),
                _buildActionBar(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 封面 + 压在右上角的关闭钮。
  ///
  /// 关闭钮**在 Hero 外面**：它属于弹窗，不属于那张卡片，跟着飞会在飞行途中
  /// 凭空多出一枚钮。
  Widget _buildCoverSlot(BorderRadius borderRadius) {
    final t = slang.Translations.of(context);
    return Stack(
      children: [
        Hero(
          tag: mediaPreviewHeroTag(video: _video, gallery: _gallery),
          // 来回两个方向都画**弹窗这侧的封面**，而不是默认的「画目的地那一侧」。
          //
          // 两个理由：
          //   1. 列表行那侧的缩略图是 120×90 的死尺寸，回飞时被塞进弹窗那么大
          //      一只盒子里，只会缩在左上角——16:9 的封面配 BoxFit.cover 才是
          //      两端都成立的那一份。
          //   2. 飞行发生在 Navigator 的 Overlay 里，那儿没有 Material 祖先，
          //      而贴边标签是 `Text`——少了这层透明 Material，debug 下会被画成
          //      黄底红双下划线。
          flightShuttleBuilder: (_, _, _, _, _) => Material(
            type: MaterialType.transparency,
            child: MediaPreviewCover(
              video: _video,
              gallery: _gallery,
              borderRadius: borderRadius,
            ),
          ),
          child: MediaPreviewCover(
            video: _video,
            gallery: _gallery,
            borderRadius: borderRadius,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          // group: false —— 单独一枚圆钮，收进融合层省不出采样，却会吃掉它
          // 按下时的底色加深（同一层玻璃只有一份材质）。
          child: GlassChromeLayer(
            group: false,
            child: GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.close),
              tooltip: t.common.close,
              onPressed: _close,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildAuthorRow(context),
        const SizedBox(height: 14),
        _buildStats(context),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          TagsDisplayWidget(tags: _tags, onTagTap: _openTag),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    final t = slang.Translations.of(context);
    final User? user = _user;
    return InkWell(
      onTap: user == null ? null : _openAuthor,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            AvatarWidget(user: user, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: user == null
                  ? Text(
                      t.common.unknownUser,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : buildUserName(context, user, bold: true, fontSize: 14),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color neutral = cs.onSurfaceVariant;
    final int views = _video?.numViews ?? _gallery?.numViews ?? 0;
    final int comments = _video?.numComments ?? _gallery?.numComments ?? 0;
    final DateTime? createdAt = _video?.createdAt ?? _gallery?.createdAt;
    final String? duration = _video?.minutesDuration;
    final int? imageCount = _gallery?.numImages;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        MediaCardStatChip(
          icon: Icons.visibility,
          value: CommonUtils.formatFriendlyNumber(views),
          color: neutral,
        ),
        MediaCardStatChip(
          icon: _liked ? Icons.favorite : Icons.favorite_border,
          value: CommonUtils.formatFriendlyNumber(_likeCount),
          color: _liked ? Colors.pink : neutral,
        ),
        MediaCardStatChip(
          icon: Icons.forum,
          value: CommonUtils.formatFriendlyNumber(comments),
          color: neutral,
        ),
        if (duration != null)
          MediaCardStatChip(
            icon: Icons.access_time,
            value: duration,
            color: neutral,
          ),
        if (imageCount != null && imageCount > 0)
          MediaCardStatChip(
            icon: Icons.image,
            value: CommonUtils.formatFriendlyNumber(imageCount),
            color: neutral,
          ),
        if (createdAt != null)
          MediaCardStatChip(
            icon: Icons.calendar_today_rounded,
            value: CommonUtils.formatFriendlyTimestamp(createdAt),
            color: neutral,
            maxTextWidth: 140,
          ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final t = slang.Translations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          // 三枚快捷键共处一坨玻璃：按住会一起蠕动，和全站动作行同一套手感。
          GlassChromeLayer(
            group: false,
            child: GlassButtonGroup(
              children: [
                GlassIconButton(
                  icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                  color: _liked ? Colors.pink : null,
                  loading: _likeBusy,
                  tooltip: _liked ? t.mediaMenu.unlike : t.mediaMenu.like,
                  onPressed: _toggleLike,
                ),
                GlassIconButton(
                  icon: Icon(
                    _inWatchLater
                        ? Icons.watch_later
                        : Icons.watch_later_outlined,
                  ),
                  color: _inWatchLater
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  tooltip: _inWatchLater
                      ? t.watchLater.removeFromWatchLater
                      : t.watchLater.addToWatchLater,
                  onPressed: _toggleWatchLater,
                ),
                Builder(
                  // 菜单要贴着这枚钮弹，所以得拿到它自己那一层的 context。
                  builder: (buttonContext) => GlassIconButton(
                    icon: const Icon(Icons.more_horiz),
                    tooltip: t.mediaPreview.moreActions,
                    opensOverlay: true,
                    onPressed: () => _openActionMenu(buttonContext),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GlassChromeLayer(
            group: false,
            child: GlassButtonGroup(
              children: [
                GlassTextActionButton(
                  label: t.mediaPreview.openDetail,
                  emphasized: true,
                  onPressed: _openDetail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 预览弹窗的封面。**同时是 Hero 飞行途中画的那一份**，所以它必须自给自足：
/// 不读弹窗里的任何状态，贴边标签也只用自带完整 `TextStyle` 的 [BaseTag]。
///
/// 视频还会在静态缩略图之上叠一层动图预览（`preview.webp`）——「预览」这两个
/// 字的价值有一半在这儿；站外视频没有这份资源，就只有缩略图。
class MediaPreviewCover extends StatelessWidget {
  const MediaPreviewCover({
    super.key,
    this.video,
    this.gallery,
    required this.borderRadius,
  });

  final Video? video;
  final ImageModel? gallery;
  final BorderRadius borderRadius;

  String get _thumbnailUrl => video?.thumbnailUrl ?? gallery!.thumbnailUrl;

  /// 动图预览地址；没有（图库 / 站外视频）时为 null。
  String? get _animatedUrl {
    final Video? v = video;
    if (v == null || v.isExternalVideo) return null;
    return v.previewUrl;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final String? animated = _animatedUrl;

    return ClipRRect(
      borderRadius: borderRadius,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFFE0E0E0)),
            CachedNetworkImage(
              imageUrl: _thumbnailUrl,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 50),
              placeholderFadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 32,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
            if (animated != null)
              CachedNetworkImage(
                imageUrl: animated,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                // 还没到就让下面那张缩略图顶着，不要占位灰块——那会在
                // Hero 落地的瞬间闪一下白。
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ..._buildCornerTags(context, t, cs),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerTags(
    BuildContext context,
    slang.Translations t,
    ColorScheme cs,
  ) {
    const BorderRadius leftTail = BorderRadius.only(
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(4),
    );
    const BorderRadius rightTail = BorderRadius.only(
      topLeft: Radius.circular(6),
      bottomRight: Radius.circular(4),
    );

    final bool isR18 = (video?.rating ?? gallery?.rating) == 'ecchi';
    final bool isPrivate = video?.private == true;
    final String? duration = video?.minutesDuration;
    final bool isExternal = video?.isExternalVideo == true;
    final int? imageCount = gallery?.numImages;

    return <Widget>[
      if (isR18 || isPrivate)
        Positioned(
          left: 0,
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isR18)
                BaseTag(
                  text: 'R18',
                  backgroundColor: Colors.red,
                  textColor: cs.onSecondary,
                  borderRadius: leftTail,
                ),
              if (isPrivate)
                BaseTag(
                  text: t.common.private,
                  icon: Icons.lock,
                  backgroundColor: Colors.black54,
                  borderRadius: leftTail,
                ),
            ],
          ),
        ),
      if (isExternal)
        Positioned(
          right: 0,
          bottom: 0,
          child: BaseTag(
            text: t.common.externalVideo,
            icon: Icons.link,
            backgroundColor: Colors.black54,
            borderRadius: rightTail,
          ),
        )
      else if (duration != null)
        Positioned(
          right: 0,
          bottom: 0,
          child: BaseTag(
            text: duration,
            icon: Icons.access_time,
            backgroundColor: Colors.black54,
            borderRadius: rightTail,
          ),
        )
      else if (imageCount != null && imageCount > 0)
        Positioned(
          right: 0,
          bottom: 0,
          child: BaseTag(
            text: CommonUtils.formatFriendlyNumber(imageCount),
            icon: Icons.image,
            backgroundColor: Colors.black54,
            borderRadius: rightTail,
          ),
        ),
    ];
  }
}
