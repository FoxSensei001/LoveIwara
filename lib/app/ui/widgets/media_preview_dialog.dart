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
// # 两类调用点：手上是完整的一条，还是只有一份种子
//
//   - **卡片列表**（视频/图库卡片与列表行）手上本来就是完整的 `Video` /
//     `ImageModel`，直接传进来即可；
//   - **「接着看」抽屉**的条目是 `InnerPlaylistItemSnapshot`，本地库来的那几个
//     池（稍后再看 / 本地收藏夹 / 已下载）只存了标题封面作者。这类调用点传一份
//     种子 + 一个加载器：弹窗当场就开（封面标题立刻在场），同时按 id 去拉详情，
//     拉到就地替换，期间统计换成骨架、会写库的那几枚钮按住。
//
// # ⭐ 飞的是「整张卡片 → 整张面板」，不是缩略图
//
// 只飞缩略图的话，卡片的轮廓（那张带圆角和投影的白底）原地消失、面板凭空出现，
// 读起来是两件事。所以两端的 Hero 都包住**整只**：卡片那侧是带投影的整张卡，
// 弹窗这侧是整张面板。中途两端的内容谁都不能直接拿来用（塞进中途那个尺寸不是
// 溢出就是压扁），画的是一份两端都成立的最小公共形，见
// `_MediaPreviewDialogState._buildFlightShuttle`。
//
// 例外是**列表行**：行本身是页面背景上透明的一条，没有轮廓可以形变，所以那一侧
// 起飞的仍然只有缩略图（`MediaCardActionState.previewHeroBoxIsAllCover`）。
//
// # 图库翻的是整本，不是封面
//
// 图库那一路的封面位是一只翻页器（[MediaPreviewGalleryPager]）：一页一张，横滑 /
// 滚轮 / 悬停箭头都能翻，右下角那枚角标从「共几张」换成「第几张 / 共几张」。封面
// 在卡片上已经被裁成 16:9 看过一次了，长按想看的是「这本里面都有什么」。
//
// 列表接口给的 `ImageModel` 不一定带 `files`，不带就当场去拉一趟
// （[_MediaPreviewDialogState._ensureGalleryImages]）。⛔ 这一趟**不走**拉详情那
// 条路：那条会把 `_detailReady` 压下去，而卡片列表这一路只缺图、不缺数据，点赞与
// 稍后再看会白白被按住。
//
// 首页（卡片上那张封面所在的那一页）落地之前先**铺满**，等 Hero 落地再展开成完整
// 的那一张：飞过来的那一份画的是裁满整只盒子的封面，落地那一帧不铺满就会当着用户
// 的面缩一下。
//
// # 点开 / 往下拖出去 = 大图页
//
// 翻到某一张之后，**点它**或者**把它往下拖**，去处都是「图库详情页 + 正停在这张
// 的大图页」——标题和「打开」那枚钮仍旧只开详情页。两种起手式收在同一段形变里：
// 面板周围逐渐变黑、那张图逐渐长到铺满（[_MediaPreviewDialogState._buildPhotoMorphLayer]），
// 点按由动画一口气跑完，下拖跟着手指走、松手看拖没拖过门槛。
//
// 形变跑到头那一刻屏幕上已经和大图页长得一模一样，于是把这一帧**钉在 root
// overlay 上**，底下从容地退弹窗、推详情页、推大图页，钉的那张再撤——中间那一串
// 转场一帧都不会漏出来。⛔ 不能直接 push 大图页：它挂在 shell 里，而这只弹窗是
// root 上的一条路由，推进去只会落在弹窗底下。
//
// ⭐ 图这时候是**现成的**：预览为了摆出整本已经走过一趟 `fetchGalleryDetail`，
// 所以整份详情跟着 `preloadedDetail` 一起交给详情页，那边开局不再重复请求
// （见 `NaviService.navigateToGalleryDetailPage`）。
//
// # 动作行浮在内容上，不占文档流
//
// 点赞 / 稍后再看 / 更多 / 打开那一行是 `Positioned` 的一层，和封面右上角那枚
// 关闭钮同一个读法——它曾经是 `Column` 里的兄弟节点，等于在面板底下切出一条只
// 放钮的空带。底下垫一层与面板同色的 `EdgeFadeScrim`，内容滚到钮下面自然溶掉。
//
// # ⛔ Hero 标签只在弹窗开着时挂
//
// 同一条视频在一个路由里出现两次并不是不可能（详情页的相关推荐 + 侧边「接着看」
// 抽屉），而重复的 Hero tag 在 debug 下是直接炸断言。所以卡片那侧的 Hero 由
// `HeroMode` 控制，**只有正在打开预览的那张卡片**才把它打开（见
// `MediaCardActionState.openPreview`）——同时只可能有一张，重复从此不可能发生，
// 顺带也省掉了列表里几十个常驻 Hero 的开销。
//
// # ⛔ 「要去别的地方」的那种关闭不飞 Hero
//
// 回飞是「弹窗收回成那张卡片」，读得通的前提是那张卡片还在原地等着。点「打开」
// 进详情页（作者主页 / 标签列表 / 大图页同理）时它并不在：新页正推进来，而这只
// 弹窗挂在 root 上、比 shell 里那一页高，回飞的面板就成了一只横穿新页的幽灵。
// 所以凡是走 [_MediaPreviewDialogState._closeForNavigation] 的关闭都当场摘掉本侧
// 的 `HeroMode`，只剩弹窗自己那段淡出；只有纯粹的关掉（关闭钮 / 点遮罩 / 返回）
// 才飞回去。摘的是**弹窗**这一侧：`_allHeroesFor` 要首尾都找得到同一个 tag 才起
// 飞，少一边就没有飞行——而它在 pop 那一帧的 post-frame 回调里才去数，所以先
// `setState` 再 `pop` 来得及。

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/media_file.model.dart';
import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/page_departure_guard.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/pages/video_detail/widgets/detail/tags_display_widget.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/base_card_list_item_widget.dart'
    show BaseTag;
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dialog_motion.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_measured_box.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/liquid_glass_material.dart';
import 'package:i_iwara/app/ui/widgets/media_action_menu.dart';
import 'package:i_iwara/app/ui/widgets/media_card_meta.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 整张卡片 ↔ 整张弹窗面板之间的 Hero 标签。
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
class MediaPreviewRoute<T> extends PageRoute<T> implements TransientPageRoute {
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
    // ⛔ 这里**没有** SafeArea：安全区由 [MediaPreviewDialog] 自己罩在面板那一层
    // 上。「把图拖成大图页」那层形变要铺满整块屏幕（大图页就是铺满的），套在安全区
    // 里的话落地那一刻图会跳一下。
    return themes.wrap(Builder(builder: builder));
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
///
/// # 手上只有一份「种子」的调用点
///
/// 卡片列表手上的那条媒体本来就是完整的，直接传 [video] / [gallery] 即可。但
/// 「接着看」列表不是：它的条目是 `InnerPlaylistItemSnapshot`，本地库来的那几个
/// 池（稍后再看 / 本地收藏夹 / 已下载）只存了标题、封面、作者名——统计、标签、
/// 作者头像一概没有。
///
/// 这类调用点传一份**种子**（拿手上那点信息拼出来的 [video] / [gallery]）加一个
/// 加载器（[loadVideoDetail] / [loadGalleryDetail]）：弹窗当场就能开（标题封面
/// 立刻在场），同时去拉详情，拉到就地替换。[coverUrl] 是种子算不出
/// `thumbnailUrl` 时的封面地址——列表行手上那份。
///
/// ⛔ 详情没到手之前，点赞 / 稍后再看 / 更多这三枚钮是**按住的**：它们都会拿
/// 当前这条的标题封面往本地库里写，用种子写进去就是一行残缺数据。
///
/// [onWillLeavePage] 给**承载这只弹窗的那一层**用：弹窗里的动作要把用户带去别的
/// 页面（作者主页 / 标签列表 / 菜单里的作者）时，先跑它。「接着看」抽屉借它把
/// 自己也收掉——它是一条 root 弹层路由，不收的话会浮在刚推进来的新页上面。
Future<void> showMediaPreviewDialog({
  required BuildContext context,
  Video? video,
  ImageModel? gallery,
  bool? likedOverride,
  int? likeCountOverride,
  ValueChanged<bool>? onLikeChanged,
  required Future<void> Function() onOpenDetail,
  Future<void> Function(ImageModel gallery, String fileId)? onOpenGalleryImage,
  String? coverUrl,
  Future<Video?> Function()? loadVideoDetail,
  Future<ImageModel?> Function()? loadGalleryDetail,
  Future<void> Function()? onWillLeavePage,
  double heroSourceRadius = 8,
  bool heroSourceIsAllCover = true,
}) {
  assert(
    (video == null) != (gallery == null),
    'showMediaPreviewDialog 一次只处理一条媒体：video 与 gallery 二选一',
  );
  assert(
    loadVideoDetail == null || video != null,
    'loadVideoDetail 拉回来的是视频，种子也必须是视频',
  );
  assert(
    loadGalleryDetail == null || gallery != null,
    'loadGalleryDetail 拉回来的是图库，种子也必须是图库',
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
      onOpenGalleryImage: onOpenGalleryImage,
      coverUrl: coverUrl,
      loadVideoDetail: loadVideoDetail,
      loadGalleryDetail: loadGalleryDetail,
      onWillLeavePage: onWillLeavePage,
      heroSourceRadius: heroSourceRadius,
      heroSourceIsAllCover: heroSourceIsAllCover,
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
    this.onOpenGalleryImage,
    this.coverUrl,
    this.loadVideoDetail,
    this.loadGalleryDetail,
    this.onWillLeavePage,
    this.heroSourceRadius = 8,
    this.heroSourceIsAllCover = true,
  });

  final Video? video;
  final ImageModel? gallery;
  final bool? likedOverride;
  final int? likeCountOverride;
  final ValueChanged<bool>? onLikeChanged;
  final Future<void> Function() onOpenDetail;

  /// 图库：点开 / 拖出某一张图 —— 详情页要**直接开到那张大图**，并且拿走这里
  /// 已经拉到手的整份详情（详情页就不用再走一次网络）。
  ///
  /// 不给也行：弹窗自己按手上这份详情跳（「接着看」抽屉那一路就是这样——它的
  /// 「打开」是把这一条交给播放队列，带不了「开到第几张」）。
  final Future<void> Function(ImageModel gallery, String fileId)?
  onOpenGalleryImage;

  /// 种子算不出 `thumbnailUrl` 时的封面地址。见 [showMediaPreviewDialog]。
  final String? coverUrl;

  /// 给了它，[video] 只是种子：弹窗开局就去拉完整详情，拉到就地替换。
  final Future<Video?> Function()? loadVideoDetail;

  /// [loadVideoDetail] 的图库版。
  final Future<ImageModel?> Function()? loadGalleryDetail;

  /// 要把用户带去别的页面之前先跑它。见 [showMediaPreviewDialog]。
  final Future<void> Function()? onWillLeavePage;

  /// Hero 起点那只盒子的圆角与构图。见 `MediaCardActionState.previewHeroRadius`
  /// 与 [_buildFlightShuttle]。
  final double heroSourceRadius;
  final bool heroSourceIsAllCover;

  @override
  State<MediaPreviewDialog> createState() => _MediaPreviewDialogState();
}

class _MediaPreviewDialogState extends State<MediaPreviewDialog>
    with SingleTickerProviderStateMixin {
  /// 宽屏版式里封面那一栏的宽度。
  ///
  /// 420 × 9/16 = 236 的封面高度，正好和右栏「标题两行 + 作者 + 统计 + 动作行」
  /// 的自然高度对得上——再宽右栏就被挤成窄条，再窄封面就失去了「看清楚一点」
  /// 这个存在理由。
  static const double _wideCoverWidth = 420;

  /// 当前手上这条媒体。开局是构造参数给的那份（完整的，或者只是种子），拉到
  /// 详情之后原地换成完整的那份。
  late Video? _videoData = widget.video;
  late ImageModel? _galleryData = widget.gallery;

  /// 详情齐了没有。没有加载器就是「一开始就齐」。
  late bool _detailReady =
      widget.loadVideoDetail == null && widget.loadGalleryDetail == null;
  bool _detailLoading = false;
  bool _detailFailed = false;

  /// 图库那本图正在路上。见 [_ensureGalleryImages]。
  bool _imagesLoading = false;

  /// 「把图往下拖出去变成大图页」的进度：0 = 还老实待在弹窗里，1 = 已经是大图页
  /// 的样子（整屏纯黑 + 完整的那一张）。见 [_buildPhotoMorphLayer]。
  double _photoMorph = 0;

  /// 起手那一刻这张图在屏幕上的位置（全局坐标）。非 null 就说明形变层在场。
  Rect? _photoStartRect;

  /// 正在形变 / 交接的是第几张。
  int? _photoIndex;

  /// 已经在交接了：形变跑完 → 钉住这一帧 → 退弹窗 → 去详情页。
  /// 兼作重入闸门（交接期间再点再拖都不作数）。
  bool _photoHandingOff = false;

  /// 弹窗这一侧的 Hero 还挂不挂。见文件头「要去别的地方的那种关闭不飞 Hero」。
  bool _heroEnabled = true;

  late final AnimationController _photoMorphController = AnimationController(
    vsync: this,
  )..addListener(_onPhotoMorphTick);

  /// 手指要把图往下带多远才算「拖满」。按屏高折算，各尺寸手感一致。
  static const double _photoPullFactor = 0.26;

  /// 松手就走的门槛。拖过这个比例、或者甩得够快，就当用户是要看大图。
  static const double _photoCommitProgress = 0.3;
  static const double _photoCommitVelocity = 700;

  late bool _liked = widget.likedOverride ?? _sourceLiked;
  late int _likeCount = widget.likeCountOverride ?? _sourceLikeCount;
  late bool _inWatchLater = _readWatchLater();
  bool _likeBusy = false;

  /// 动作行的实测高度：浮层蒙层按它算。开局这个初值只影响第一帧的蒙层高度，
  /// 布局一落地 [GlassMeasuredBox] 就报回真值（见 [_buildFloatingActionBar]）。
  double _actionBarHeight = 64;

  /// 用户在这张弹窗里动过点赞了。动过之后**详情回来也不许覆盖**——他刚按的那
  /// 一下是最新的，服务端那份是按下之前拉的。
  bool _likeTouched = false;

  Video? get _video => _videoData;
  ImageModel? get _gallery => _galleryData;
  String get _mediaId => _video?.id ?? _gallery!.id;
  User? get _user => _video?.user ?? _gallery?.user;
  List<Tag> get _tags => _video?.tags ?? _gallery?.tags ?? const <Tag>[];

  /// 这本图库里翻得动的那些图。
  ///
  /// 图库里偶尔混着一条视频文件，那一条不进翻页器——预览这块位置放不了播放器，
  /// 摆张封面帧只会让人点了没反应。
  List<MediaFile> get _galleryImages {
    final ImageModel? gallery = _gallery;
    if (gallery == null || gallery.files.isEmpty) return const <MediaFile>[];
    return gallery.files.where(_isPreviewableImage).toList(growable: false);
  }

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

  @override
  void initState() {
    super.initState();
    // 拉详情那一趟会把图库的 `files` 一并带回来，所以两条路走一条就够。
    if (!_detailReady) {
      unawaited(_loadDetail());
    } else {
      unawaited(_ensureGalleryImages());
    }
  }

  /// 图库那本图还没在手上就去拉一趟。
  ///
  /// 列表接口给的 `ImageModel` 不一定带 `files`（带了就直接用，一次网络都不发）。
  /// ⛔ 不走 [_loadDetail]：那条路会把 [_detailReady] 压下去，而卡片列表这一路
  /// 手上的数据本来就是全的——只缺图，点赞 / 稍后再看 / 更多没理由跟着被按住。
  ///
  /// 拉不到就维持原样：封面还在，读起来就是加这只翻页器之前的那张弹窗。
  ///
  /// ⭐ **只有一张的图库照样拉**：那一张同样该完整显示（不再被裁成 16:9），也同样
  /// 要点得进大图页——这两件事都得先拿到文件 id 与尺寸。
  Future<void> _ensureGalleryImages() async {
    final ImageModel? gallery = _galleryData;
    if (gallery == null || _imagesLoading) return;
    if (gallery.files.isNotEmpty || gallery.numImages < 1) return;
    setState(() => _imagesLoading = true);
    List<MediaFile>? files;
    try {
      final res = await Get.find<GalleryService>().fetchGalleryDetail(
        gallery.id,
      );
      files = res.data?.files;
    } catch (e, s) {
      LogUtils.e(
        '预览弹窗拉图库图片失败: ${gallery.id}',
        tag: 'MediaPreviewDialog',
        error: e,
        stackTrace: s,
      );
    }
    if (!mounted) return;
    setState(() {
      _imagesLoading = false;
      if (files != null && files.isNotEmpty) {
        _galleryData = _galleryData?.copyWith(files: files);
      }
    });
  }

  /// 去把完整详情拉回来（手上那份只是种子，见 [showMediaPreviewDialog]）。
  Future<void> _loadDetail() async {
    if (_detailLoading) return;
    setState(() {
      _detailLoading = true;
      _detailFailed = false;
    });
    Video? video;
    ImageModel? gallery;
    try {
      video = await widget.loadVideoDetail?.call();
      gallery = await widget.loadGalleryDetail?.call();
    } catch (e, s) {
      LogUtils.e(
        '预览弹窗拉详情失败: $_mediaId',
        tag: 'MediaPreviewDialog',
        error: e,
        stackTrace: s,
      );
    }
    if (!mounted) return;
    setState(() {
      _detailLoading = false;
      if (video == null && gallery == null) {
        _detailFailed = true;
        return;
      }
      if (video != null) _videoData = video;
      if (gallery != null) _galleryData = gallery;
      _detailReady = true;
      _detailFailed = false;
      // 种子里的点赞数是列表行那份（本地池干脆没有），详情回来才是真的。
      // 但用户已经按过就不覆盖了——他那一下比服务端这份新。
      if (!_likeTouched) {
        _liked = widget.likedOverride ?? _sourceLiked;
        _likeCount = widget.likeCountOverride ?? _sourceLikeCount;
      }
      _inWatchLater = _readWatchLater();
    });
  }

  @override
  void dispose() {
    _photoMorphController.dispose();
    super.dispose();
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  /// 因为「要去别的地方」而关闭：摘掉本侧的 Hero，不回飞。
  ///
  /// 见文件头「⛔ 「要去别的地方」的那种关闭不飞 Hero」。
  void _closeForNavigation() {
    if (!mounted) return;
    if (_heroEnabled) setState(() => _heroEnabled = false);
    _close();
  }

  /// 关掉弹窗，再去干那件「离开这一页」的事。
  ///
  /// ⛔ 有承载层（[MediaPreviewDialog.onWillLeavePage]）时**必须等自己先退干净**
  /// 再动手：承载层是弹窗底下那条路由，它自己的 `pop` 会被还盖在上面的弹窗顶掉；
  /// 「打开」那条路更直接——「接着看」抽屉要重新成为栈顶，才能带着点播结果 pop。
  ///
  /// 没有承载层（卡片列表那一路）时不等：那边 [_close] 只是让弹窗飞回卡片，
  /// 白等一段退场动画只会让跳转慢半拍。
  ///
  /// [toAnotherPage] 区分的是两种「走」：真的去了别的页面（作者主页 / 标签
  /// 列表），还是只是把这一条交给当前这一页去播（「打开」）。**只有前者**要收掉
  /// 承载层、并把全屏交还。
  Future<void> _leaveThenRun(
    FutureOr<void> Function() go, {
    required bool toAnotherPage,
  }) async {
    final Future<void> Function()? host = widget.onWillLeavePage;
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    _closeForNavigation();
    if (host != null && route != null) await route.completed;
    if (toAnotherPage) {
      await host?.call();
      await _departForNavigation();
    }
    await go();
  }

  /// 跳去别的页面之前先收尾：全屏交还、播放页暂停。
  ///
  /// 这张弹窗在全屏里也开得出来（「接着看」抽屉全屏时照样能开），不交还的话作者页
  /// 会顶着一个满屏窗口 / 一张锁在横屏里的页面出现。[PageDepartureGuard] 那道
  /// 路由监控是兜底（toast 上的动作钮就够不到这里），这里是"先收再跳"——差别在于
  /// 兜底那条会先漏出一帧「新页已经画出来、弹窗还盖着」。
  Future<void> _departForNavigation() =>
      PageDepartureGuard.departForNavigation(reason: 'media preview');

  Future<void> _openDetail() =>
      // 「打开」自带去处（「接着看」那边是点播这一条，它会自己把抽屉收掉，
      // 而且全屏要留着交给下一条），再让承载层 pop 一次就把点播结果吞了。
      _leaveThenRun(widget.onOpenDetail, toAnotherPage: false);

  // ===========================================================================
  // 图库：从预览里「点开 / 拖出」某一张大图
  //
  // 点按与下拖是同一件事的两种起手式，收在同一段形变里：**面板周围逐渐变黑、那
  // 张图逐渐长到铺满** —— 也就是大图页的样子。跑到头之后把这一帧钉在 root
  // overlay 上，弹窗退场、详情页与大图页依次推进来，全程盖着；钉的那张和大图页
  // 长得一模一样，所以撤掉的那一刻什么都不会跳。
  //
  // ⛔ 为什么不直接 push 大图页：大图页挂在 **shell** 里（`/photo_view_wrapper`），
  // 而这只弹窗是 **root** 上的一条路由 —— 推进去只会落在弹窗底下，看起来像什么都
  // 没发生（`pushPhotoViewWrapperOverlay` 里那段 PopupRoute 判断就是同一个坑）。
  // 何况用户要的是「进详情页、并且正停在这张图上」，退出大图页得落在详情页。
  // ===========================================================================

  void _onPhotoMorphTick() {
    if (!mounted) return;
    setState(() => _photoMorph = _photoMorphController.value);
  }

  double? _fileAspect(MediaFile file) {
    final int? width = file.width;
    final int? height = file.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    return width / height;
  }

  /// 这张图在**大图页**里占的那块地方：整屏里按自己的比例完整摆下。
  Rect _photoTargetRect(MediaFile file, Size screen) {
    final Rect? start = _photoStartRect;
    final double aspect =
        _fileAspect(file) ??
        (start == null || start.height <= 0
            ? screen.width / screen.height
            : start.width / start.height);
    final Size fitted = _containedSize(screen, aspect);
    return Rect.fromCenter(
      center: Offset(screen.width / 2, screen.height / 2),
      width: fitted.width,
      height: fitted.height,
    );
  }

  Future<void> _animatePhotoMorphTo(double target, {Duration? duration}) async {
    _photoMorphController.value = _photoMorph;
    await _photoMorphController.animateTo(
      target,
      duration:
          duration ??
          Duration(
            milliseconds: (220 * (target - _photoMorph).abs() + 90).round(),
          ),
      curve: Curves.easeOutCubic,
    );
  }

  /// 手指按在某一张图上开始往下带。[rect] 是它此刻在屏幕上的位置。
  void _onGalleryImageDragStart(int index, Rect rect) {
    if (_photoHandingOff) return;
    _photoMorphController.stop();
    setState(() {
      _photoIndex = index;
      _photoStartRect = rect;
      _photoMorph = 0;
    });
  }

  /// [dy] 是从起手点算起的累计位移，只认往下的那一段。
  void _onGalleryImageDragUpdate(double dy) {
    if (_photoHandingOff || _photoStartRect == null) return;
    final double pull = MediaQuery.sizeOf(context).height * _photoPullFactor;
    final double progress = pull <= 0 ? 0 : (dy / pull).clamp(0.0, 1.0);
    if (progress == _photoMorph) return;
    setState(() => _photoMorph = progress);
  }

  Future<void> _onGalleryImageDragEnd(double velocity) async {
    if (_photoHandingOff || _photoStartRect == null) return;
    final int? index = _photoIndex;
    final bool commit =
        _photoMorph >= _photoCommitProgress ||
        (velocity >= _photoCommitVelocity && _photoMorph > 0.06);
    if (commit && index != null) {
      await _handoffToPhotoViewer(index);
      return;
    }
    await _cancelPhotoMorph();
  }

  Future<void> _cancelPhotoMorph() async {
    await _animatePhotoMorphTo(0);
    if (!mounted) return;
    // 形变层整只不建：留着一层 alpha 0 的黑和一张原位的图，等于在面板上白盖一层。
    setState(() {
      _photoStartRect = null;
      _photoIndex = null;
    });
  }

  /// 点一下某一张图 —— 和拖到底是同一段形变，只是这一下由动画自己跑完。
  Future<void> _onGalleryImageTap(int index, Rect rect) async {
    if (_photoHandingOff) return;
    setState(() {
      _photoIndex = index;
      _photoStartRect = rect;
      _photoMorph = 0;
    });
    await _handoffToPhotoViewer(
      index,
      morphDuration: const Duration(milliseconds: 280),
    );
  }

  Future<void> _handoffToPhotoViewer(
    int index, {
    Duration? morphDuration,
  }) async {
    if (_photoHandingOff) return;
    final ImageModel? gallery = _gallery;
    final List<MediaFile> images = _galleryImages;
    if (gallery == null || index < 0 || index >= images.length) {
      await _cancelPhotoMorph();
      return;
    }
    _photoHandingOff = true;
    final MediaFile file = images[index];
    // 交过去的那份要带上**弹窗里此刻**的点赞态：详情是进来之前拉的，用户可能
    // 刚在这张弹窗上点过心，照原样交过去详情页会当着他的面把心退回去。
    final ImageModel handoff = gallery.copyWith(
      liked: _liked,
      numLikes: _likeCount,
    );

    // 1. 先把形变跑完：这一刻屏幕上已经是大图页的样子。
    await _animatePhotoMorphTo(1, duration: morphDuration);
    if (!mounted) return;

    // 2. 把这一帧钉在 root overlay 上，接下来那一串转场全盖住。
    final OverlayEntry? snapshot = _pinHandoffFrame(file);

    // 3. 退弹窗 + 去详情页，沿用 [_leaveThenRun] 那套承载层规矩（「接着看」抽屉
    //    得先把自己收掉，它是 root 弹层、目标页推的是 shell）。
    //    ⛔ **导航本身不能等**：那个 future 要到用户从详情页回来才完成，钉着的
    //    那一帧会一直挂在屏幕上。但「退干净了没有」要等——所以只把导航甩出去。
    await _leaveThenRun(() {
      unawaited(_openGalleryImageDestination(handoff, file.id));
    }, toAnotherPage: true);

    // 4. 等目的地真的画出来再撤帧。大图页那一路是**不转场、不飞 Hero**地直接
    //    就位的（`instant`），所以这里等的只是「详情页推进来 + 大图页 push」那
    //    两三帧；撤早了会漏出底下还没盖满的详情页，撤晚了只是多钉一帧一模一样
    //    的画面，所以宁可宽裕。
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (snapshot != null && snapshot.mounted) snapshot.remove();
  }

  /// 把「已经是大图页的样子」那一帧钉在 root overlay 上。
  ///
  /// 它比所有路由都高，所以弹窗退场（连同 Hero 飞回卡片）、详情页推进来、大图页
  /// 淡入这一串全在它底下发生。
  OverlayEntry? _pinHandoffFrame(MediaFile file) {
    final OverlayState? overlay = Navigator.of(
      context,
      rootNavigator: true,
    ).overlay;
    if (overlay == null) return null;
    final Rect rect = _photoTargetRect(file, MediaQuery.sizeOf(context));
    final String url = file.getLargeImageUrl();
    final entry = OverlayEntry(
      builder: (context) => AbsorbPointer(
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            Positioned.fromRect(rect: rect, child: _buildMorphImage(url)),
          ],
        ),
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  /// 去详情页并直接开到那张大图。
  ///
  /// 调用点给了 [MediaPreviewDialog.onOpenGalleryImage] 就走它（卡片那一路要带上
  /// 自己的池引用与点赞回灌）；没给就按手上这份详情自己跳。
  Future<void> _openGalleryImageDestination(ImageModel gallery, String fileId) {
    final handler = widget.onOpenGalleryImage;
    if (handler != null) return handler(gallery, fileId);
    return NaviService.navigateToGalleryDetailPage(
      gallery.id,
      coverUrl: gallery.thumbnailUrl,
      title: gallery.title,
      imageCount: gallery.numImages,
      authorId: gallery.user?.id,
      authorName: gallery.user?.name,
      authorUsername: gallery.user?.username,
      authorAvatarUrl: gallery.user?.avatar?.avatarUrl,
      authorRole: gallery.user?.role,
      authorPremium: gallery.user?.premium,
      preloadedDetail: gallery,
      initialImageId: fileId,
    );
  }

  /// 形变 / 交接途中画的那张图。和翻页器里那张同一个地址、同一份缓存。
  Widget _buildMorphImage(String url) => CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    maxWidthDiskCache: 4096,
    maxHeightDiskCache: 4096,
    fadeInDuration: Duration.zero,
    placeholderFadeInDuration: Duration.zero,
    fadeOutDuration: Duration.zero,
    placeholder: (context, _) => const SizedBox.shrink(),
    errorWidget: (context, url, error) => const SizedBox.shrink(),
  );

  /// 面板之上、铺满整块屏幕的那一层：黑底随进度加深，图从原位长到大图页的位置。
  ///
  /// ⛔ 面板本身**不加透明度层**——它是被这层黑逐渐盖住的，不是被淡出的。玻璃件
  /// 套 `Opacity` 会把折射打断（全站规矩，见 `GlassSurface.materialize`）。
  Widget _buildPhotoMorphLayer() {
    final Rect? start = _photoStartRect;
    final int? index = _photoIndex;
    final List<MediaFile> images = _galleryImages;
    if (start == null || index == null || index >= images.length) {
      return const SizedBox.shrink();
    }
    final MediaFile file = images[index];
    final Size screen = MediaQuery.sizeOf(context);
    final double progress = _photoMorph.clamp(0.0, 1.0);
    // 位置走线性：手指带多远图就走多远，中途松手也对得上。
    final Rect rect = Rect.lerp(
      start,
      _photoTargetRect(file, screen),
      progress,
    )!;
    // 黑底走 easeOut：起手就给出明确反馈，尾段放缓（同大图页自己的拖拽消隐）。
    final double dim = Curves.easeOut.transform(progress);
    return Positioned.fill(
      child: AbsorbPointer(
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: dim)),
            ),
            Positioned.fromRect(
              rect: rect,
              child: _buildMorphImage(file.getLargeImageUrl()),
            ),
          ],
        ),
      ),
    );
  }

  void _applyLike(bool liked) {
    if (!mounted) return;
    setState(() {
      _likeTouched = true;
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
      // 菜单里的「作者主页」也是一次跳页：本弹窗（以及承载它的抽屉）都得先让开，
      // 否则它们会浮在刚推进来的作者页上面。
      onWillLeavePage: _leaveForMenuNavigation,
    );
    if (!mounted) return;
    setState(() => _inWatchLater = _readWatchLater());
  }

  /// 菜单里的动作要跳页了：弹窗先退干净，再把承载它的那一层也收掉，最后交还
  /// 全屏（与 [_leaveThenRun] 的 `toAnotherPage` 那一路同款，只是发起方在菜单）。
  Future<void> _leaveForMenuNavigation() async {
    if (!mounted) return;
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    _closeForNavigation();
    if (route != null) await route.completed;
    await widget.onWillLeavePage?.call();
    await _departForNavigation();
  }

  void _openAuthor() {
    final String username = (_user?.username ?? '').trim();
    if (username.isEmpty) return;
    final User? user = _user;
    unawaited(
      _leaveThenRun(
        () => NaviService.navigateToAuthorProfilePage(
          username,
          initialUser: user,
        ),
        toAnotherPage: true,
      ),
    );
  }

  void _openTag(Tag tag) {
    final bool isVideo = _video != null;
    unawaited(
      _leaveThenRun(
        () => isVideo
            ? NaviService.navigateToTagVideoListPage(tag)
            : NaviService.navigateToTagGalleryListPage(tag),
        toAnotherPage: true,
      ),
    );
  }

  /// 面板的圆角。Hero 飞行的终点圆角也是它。
  static const double _panelRadius = 28;

  /// 弹窗那侧「封面占面板宽度的几成」。窄屏是通栏（1），宽屏是左边那 420。
  ///
  /// 飞行途中要拿它当终点几何（见 [_buildFlightShuttle]），所以按面板**实际**
  /// 宽度算：面板是 `Center + ConstrainedBox + 左右外边距`，窄屏上撑不到 460。
  double _coverFractionAtPanel({required bool wide, required Size screen}) {
    if (!wide) return 1;
    final double panelWidth = math.min(880, screen.width - 80);
    if (panelWidth <= 0) return 1;
    return (_wideCoverWidth / panelWidth).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final bool wide = screen.width >= GlassTokens.dialogWideBreakpoint;
    final double coverFraction = _coverFractionAtPanel(
      wide: wide,
      screen: screen,
    );

    // 安全区罩在**面板这一层**上，不是整条路由上：形变层要铺满整块屏幕
    // （大图页就是铺满的），套进安全区里落地那一刻图会跳一下。
    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: _buildPanel(context, theme, screen, wide, coverFraction),
        ),
        if (_photoStartRect != null) _buildPhotoMorphLayer(),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    ThemeData theme,
    Size screen,
    bool wide,
    double coverFraction,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 40 : 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: wide ? 880 : 460,
            // 内容再多也不许顶到屏幕边——超出的部分在面板内部滚。
            maxHeight: screen.height * 0.86,
          ),
          // ⭐ Hero 包的是**整张面板**，不是封面。
          //
          // 上一版只飞封面：卡片的缩略图长成弹窗的封面，而卡片的轮廓（那张带
          // 圆角和投影的白底）原地消失、弹窗的面板凭空出现——读起来是两件事，
          // 不是一件。整只包住之后飞的是「这张卡片变成了这张面板」。
          //
          // 中途画什么见 [_buildFlightShuttle]：两端的内容谁都不能直接拿来用。
          child: HeroMode(
            enabled: _heroEnabled,
            child: Hero(
              tag: mediaPreviewHeroTag(video: _video, gallery: _gallery),
              flightShuttleBuilder:
                  (
                    flightContext,
                    animation,
                    direction,
                    fromContext,
                    toContext,
                  ) => _buildFlightShuttle(
                    animation: animation,
                    colorScheme: theme.colorScheme,
                    coverFractionAtPanel: coverFraction,
                    coverFillsHeightAtPanel: wide,
                  ),
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(_panelRadius),
                clipBehavior: Clip.antiAlias,
                elevation: 6,
                child: wide ? _buildWide(context) : _buildNarrow(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 「卡片轮廓 → 弹窗面板」飞行途中画的那一份。
  ///
  /// # ⛔ 两端的内容都不能直接拿来用
  ///
  /// 卡片那侧是列表里的一张卡（标题两行、作者行、三点钮都在里面），弹窗那侧是
  /// 一张几百像素高的面板（可滚动的详情 + 玻璃动作行）。把任何一侧塞进中途那个
  /// 尺寸，不是溢出就是被压扁。所以中途画一份**两端都成立的最小公共形**：一只
  /// 跟着圆角与投影过渡的面板底，加一块封面。
  ///
  /// # 封面摆哪儿，两端插值
  ///
  /// [animation] 的 0 恒是卡片那侧、1 恒是弹窗那侧（push 时它是新路由的动画、
  /// pop 时是本路由的反向动画，两种方向下这个约定都成立）。
  ///
  ///   - **t=0**：卡片是「封面顶上通栏 + 下面是文字」，所以封面占 `宽 × 宽*9/16`；
  ///     列表行那侧起飞的只有缩略图本身（行是页面背景上透明的一条，没有轮廓可
  ///     形变），此时 `heroSourceIsAllCover` 为真，封面铺满整只盒子。
  ///   - **t=1**：窄屏同样是顶上通栏那条 16:9；宽屏是左边 420 那一栏、**上下贴满**
  ///     （见 [_buildWide]），宽度按 [_coverFractionAtPanel] 折成比例。
  Widget _buildFlightShuttle({
    required Animation<double> animation,
    required ColorScheme colorScheme,
    required double coverFractionAtPanel,
    required bool coverFillsHeightAtPanel,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final double t = animation.value.clamp(0.0, 1.0);
        return Material(
          color: colorScheme.surface,
          elevation: lerpDouble(1, 6, t)!,
          borderRadius: BorderRadius.circular(
            lerpDouble(widget.heroSourceRadius, _panelRadius, t)!,
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double boxWidth = constraints.maxWidth;
              final double boxHeight = constraints.maxHeight;
              final double coverWidth =
                  boxWidth * lerpDouble(1, coverFractionAtPanel, t)!;
              final double startHeight = widget.heroSourceIsAllCover
                  ? boxHeight
                  : boxWidth * 9 / 16;
              // 宽屏那端封面贴满整条左栏（见 [_buildWide]），窄屏那端仍是顶上
              // 那条 16:9。
              final double endHeight = coverFillsHeightAtPanel
                  ? boxHeight
                  : coverWidth * 9 / 16;
              final double coverHeight = lerpDouble(startHeight, endHeight, t)!;
              return Stack(
                children: [
                  SizedBox(
                    width: coverWidth,
                    height: coverHeight,
                    // 外面那只 Material 已经按当前圆角裁过了，这里不要再裁一次
                    // ——两层圆角对不齐会在角上留一圈毛边。
                    child: MediaPreviewCover(
                      video: _video,
                      gallery: _gallery,
                      fallbackThumbnailUrl: widget.coverUrl,
                      borderRadius: BorderRadius.zero,
                      stretch: true,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 手机版式：封面在上、信息在下面滚，动作行**浮**在最底下。
  Widget _buildNarrow(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCoverSlot(
              const BorderRadius.vertical(top: Radius.circular(_panelRadius)),
            ),
            Flexible(
              child: SingleChildScrollView(
                // 底部让出动作行那一条：钮是浮着的，不让位的话滚到底的内容会被
                // 它压住，而且**再也划不出来**。
                padding: EdgeInsets.fromLTRB(20, 16, 20, _actionBarHeight),
                child: _buildDetails(context),
              ),
            ),
          ],
        ),
        _buildFloatingActionBar(context),
      ],
    );
  }

  /// PC / 平板版式：左封面右信息，动作行浮在右栏底下。
  ///
  /// # ⛔ 为什么是 Stack 而不是 Row
  ///
  /// 封面要**贴满面板的上下**。`Row` 做不到：`CrossAxisAlignment.start` 会让封面
  /// 按 16:9 停在顶上、下面留一大片白（内容长的时候尤其难看），而
  /// `CrossAxisAlignment.stretch` 会把 `maxHeight` 当成紧约束发下去——面板于是
  /// 恒等于屏高的 86%，短内容也一样。
  ///
  /// 改成「右栏定高、封面 `Positioned` 贴满左侧一条」：面板高度仍由右栏说了算
  /// （`minHeight = 封面高` 是地板，短内容时两栏齐平），封面拿到的是撑满的紧高度。
  Widget _buildWide(BuildContext context) {
    const double coverHeight = _wideCoverWidth * 9 / 16;
    return Stack(
      children: [
        // 非定位子节点：面板高度由它决定。
        Padding(
          padding: const EdgeInsets.only(left: _wideCoverWidth),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: coverHeight),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, _actionBarHeight),
                  child: _buildDetails(context, showCoverCornerTags: false),
                ),
                _buildFloatingActionBar(context),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _wideCoverWidth,
          // 封面贴满整条，所以按 BoxFit.cover 裁（[stretch]）；贴边的时长 / 张数 /
          // R18 那几枚角标一并让位——它们在右栏的统计行里有更好的位置，压在一张
          // 被裁过的竖长图上只会挤在角落里。
          child: _buildCoverSlot(
            const BorderRadius.horizontal(left: Radius.circular(_panelRadius)),
            stretch: true,
            showCornerTags: false,
          ),
        ),
      ],
    );
  }

  /// 动作行：**浮在内容之上，不占文档流**（同封面右上角那枚关闭钮）。
  ///
  /// 原来它是 `Column` 里的一个兄弟节点，等于在面板底下切出一条只放钮的空带，
  /// 把可滚动区域压矮了一整行。改成 `Positioned` 之后，详情区拿到的是面板的
  /// 整个高度，钮浮在上面——这也是全站玻璃 chrome 的读法（页面顶栏一直是这么
  /// 干的，见 `GlassHeaderOverlay`）。
  ///
  /// 底下垫一层与面板同色的渐进蒙层：内容滚到钮下面会自然溶掉，而不是从玻璃缝里
  /// 透出半行字。蒙层高度按**实测**的动作行高算（[_actionBarHeight]），别再手写
  /// 常数——玻璃钮的实际高度不等于它的名义尺寸，这个仓库为此栽过（见
  /// `GlassPickerDialog` 那次收口）。
  Widget _buildFloatingActionBar(BuildContext context) {
    final double barHeight = _actionBarHeight;
    // 平台段只盖钮那一圈的下半截，剩下的高度是淡出的一部分（同顶部蒙层的读法）。
    final double plateau = barHeight * 0.45;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          EdgeFadeScrim.bottom(
            height: EdgeFadeScrim.overlayHeight(
              headerExtent: barHeight,
              plateauExtent: plateau,
            ),
            solidExtent: plateau,
          ),
          GlassMeasuredBox(
            onSize: (size) {
              if (!mounted || size.height == _actionBarHeight) return;
              setState(() => _actionBarHeight = size.height);
            },
            child: _buildActionBar(context),
          ),
        ],
      ),
    );
  }

  /// 封面 + 压在右上角的关闭钮。图库有不止一张图时，封面那块位置换成翻页器。
  ///
  /// Hero 不在这一层——飞的是**整张面板**（见 [build]），封面只是飞行途中那份
  /// 画出来的一块，见 [_buildFlightShuttle]。
  Widget _buildCoverSlot(
    BorderRadius borderRadius, {
    bool stretch = false,
    bool showCornerTags = true,
  }) {
    final t = slang.Translations.of(context);
    final List<MediaFile> images = _galleryImages;
    final bool paged = images.isNotEmpty;
    return Stack(
      children: [
        // 非定位子节点：窄屏靠它（16:9）把这只 Stack 撑出高度；宽屏外面那层
        // Positioned 已经给了紧高度，[stretch] 让它照单填满。
        if (paged)
          MediaPreviewGalleryPager(
            gallery: _gallery!,
            images: images,
            fallbackThumbnailUrl: widget.coverUrl,
            borderRadius: borderRadius,
            stretch: stretch,
            showCornerTags: showCornerTags,
            onImageTap: _onGalleryImageTap,
            onImageDragStart: _onGalleryImageDragStart,
            onImageDragUpdate: _onGalleryImageDragUpdate,
            onImageDragEnd: _onGalleryImageDragEnd,
          )
        else
          MediaPreviewCover(
            video: _video,
            gallery: _gallery,
            fallbackThumbnailUrl: widget.coverUrl,
            borderRadius: borderRadius,
            stretch: stretch,
            showCornerTags: showCornerTags,
          ),
        // 点封面 = 进详情页。
        //
        // ⛔ 翻页器不许盖这一层：`Stack` 的命中测试自上而下、命中即停，盖上去
        // 等于把横滑整只吃掉。那一路的点按由翻页器在**每一页里面**接（手势竞技场
        // 里点按与横滑本来就分得开），所以这里让开。
        //
        // ⛔ 这里**不用 InkWell**：压在一张图上的水波纹既看不清又和「按下去要
        // 发生一件大事（整张图长成大图页）」的读法冲突，用户明确要求去掉。
        if (!paged)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openDetail,
            ),
          ),
        // 详情 / 图库那本图还在路上：贴着封面下沿走一条细进度条。
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: GlassTokens.pressDuration,
            child: _detailLoading || _imagesLoading
                ? const LinearProgressIndicator(minHeight: 3)
                : const SizedBox(height: 3, width: double.infinity),
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

  /// [showCoverCornerTags] 为假说明封面那侧不画角标了（宽屏），R18 / 私密 /
  /// 外链这三项得在统计行里补出来——否则它们整只消失。
  Widget _buildDetails(
    BuildContext context, {
    bool showCoverCornerTags = true,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题也是进详情页的入口：想看全文的人多半下一步就是点进去，而这一整块
        // 文字比那枚「打开」好瞄得多。
        InkWell(
          onTap: _openDetail,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              _title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAuthorRow(context),
        const SizedBox(height: 14),
        // 详情没到手之前统计一律不显示真数字：本地库来的池根本没有这几项，
        // 拿 0 顶上等于把「我们不知道」说成「没人看过」。
        if (_detailReady)
          _buildStats(context, showStatusBadges: !showCoverCornerTags)
        else
          _buildStatsPlaceholder(),
        if (_detailFailed) ...[
          const SizedBox(height: 10),
          _buildDetailRetry(context),
        ],
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          TagsDisplayWidget(tags: _tags, onTagTap: _openTag),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  /// 统计那一排的骨架：尺寸照着 [MediaCardStatChip] 来，拉到详情就原地换成真的。
  Widget _buildStatsPlaceholder() {
    final Color base = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.12);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (final double width in const <double>[64, 56, 52])
          Container(
            width: width,
            height: 22,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    );
  }

  /// 详情没拉回来：说一声并给一次重试。**不静默**——统计和标签整片缺着，
  /// 不给说法只会被当成"这条视频就是没数据"。
  Widget _buildDetailRetry(BuildContext context) {
    final t = slang.Translations.of(context);
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.error_outline, size: 16, color: cs.error),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            t.errors.errorWhileFetching,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        // group: false —— 孤零零一枚钮，收进融合层省不出采样，却会吃掉它按下时
        // 的底色加深（同一层玻璃只有一份材质）。
        GlassChromeLayer(
          group: false,
          child: GlassButtonGroup(
            children: [
              GlassTextActionButton(
                label: t.common.retry,
                onPressed: _loadDetail,
              ),
            ],
          ),
        ),
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

  Widget _buildStats(BuildContext context, {bool showStatusBadges = false}) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final Color neutral = cs.onSurfaceVariant;
    final bool isR18 = (_video?.rating ?? _gallery?.rating) == 'ecchi';
    final bool isPrivate = _video?.private == true;
    final bool isExternal = _video?.isExternalVideo == true;
    final int views = _video?.numViews ?? _gallery?.numViews ?? 0;
    final int comments = _video?.numComments ?? _gallery?.numComments ?? 0;
    final DateTime? createdAt = _video?.createdAt ?? _gallery?.createdAt;
    final String? duration = _video?.minutesDuration;
    final int? imageCount = _gallery?.numImages;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // 状态那几枚排在最前：它们是「这条是什么」，比数字更该先看到。
        if (showStatusBadges && isR18)
          MediaCardStatChip(
            icon: Icons.explicit,
            value: 'R18',
            color: Colors.red,
          ),
        if (showStatusBadges && isPrivate)
          MediaCardStatChip(
            icon: Icons.lock,
            value: t.common.private,
            color: neutral,
          ),
        if (showStatusBadges && isExternal)
          MediaCardStatChip(
            icon: Icons.link,
            value: t.common.externalVideo,
            color: neutral,
            maxTextWidth: 96,
          ),
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
          //
          // ⛔ 详情没到手之前三枚全部按住（[_detailReady]）：点赞要发这条的 id、
          // 稍后再看与下载要把标题封面写进本地库，而此刻手上只有一份种子——
          // 按下去写进去的就是一行残缺数据。「打开」不受影响，它只要 id。
          GlassChromeLayer(
            group: false,
            child: GlassButtonGroup(
              children: [
                GlassIconButton(
                  icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                  color: _liked ? Colors.pink : null,
                  loading: _likeBusy,
                  tooltip: _liked ? t.mediaMenu.unlike : t.mediaMenu.like,
                  onPressed: _detailReady ? _toggleLike : null,
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
                  onPressed: _detailReady ? _toggleWatchLater : null,
                ),
                Builder(
                  // 菜单要贴着这枚钮弹，所以得拿到它自己那一层的 context。
                  builder: (buttonContext) => GlassIconButton(
                    icon: const Icon(Icons.more_horiz),
                    tooltip: t.mediaPreview.moreActions,
                    opensOverlay: true,
                    onPressed: _detailReady
                        ? () => _openActionMenu(buttonContext)
                        : null,
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

/// 预览弹窗的封面。**飞行途中那份里也有它**，所以它必须自给自足：不读弹窗里的
/// 任何状态，贴边标签也只用自带完整 `TextStyle` 的 [BaseTag]。
///
/// 视频还会在静态缩略图之上叠一层动图预览（`preview.webp`）——「预览」这两个
/// 字的价值有一半在这儿；站外视频没有这份资源，就只有缩略图。
class MediaPreviewCover extends StatelessWidget {
  const MediaPreviewCover({
    super.key,
    this.video,
    this.gallery,
    this.fallbackThumbnailUrl,
    this.stretch = false,
    this.showCornerTags = true,
    required this.borderRadius,
  });

  final Video? video;
  final ImageModel? gallery;

  /// 模型自己算不出封面时用它——种子模型没有 `file` / `customThumbnail`，
  /// `thumbnailUrl` 只会返回空串（见 [showMediaPreviewDialog]）。
  final String? fallbackThumbnailUrl;

  /// 铺满给定的盒子，而不是自己套一层 16:9。
  ///
  /// Hero 飞行途中那份用它：中途的盒子既不是 16:9、每一帧还都在变，套死比例只会
  /// 让封面缩在盒子中间飘着（见 `_MediaPreviewDialogState._buildFlightShuttle`）。
  final bool stretch;

  /// 贴边的那几枚角标（时长 / 张数 / R18 / 私密 / 外链）画不画。
  ///
  /// 宽屏版式关掉：封面在那儿被裁成一条竖长图，角标挤在角落里既难认又和右栏的
  /// 统计行重复，那几项改由 `_MediaPreviewDialogState._buildStats` 一并列出。
  final bool showCornerTags;

  final BorderRadius borderRadius;

  String get _thumbnailUrl {
    final String url = video?.thumbnailUrl ?? gallery!.thumbnailUrl;
    return url.isNotEmpty ? url : (fallbackThumbnailUrl ?? '');
  }

  /// 动图预览地址；没有（图库 / 站外视频）时为 null。
  String? get _animatedUrl {
    final Video? v = video;
    if (v == null || v.isExternalVideo) return null;
    return v.previewUrl;
  }

  @override
  Widget build(BuildContext context) {
    final String? animated = _animatedUrl;

    final Widget content = Stack(
      fit: StackFit.expand,
      children: [
        // 底色跟翻页器保持一致：图库那一路图到手之后就换成翻页器，两边底色不同
        // 的话会当着用户的面闪一下。
        const ColoredBox(color: Colors.black),
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
        if (showCornerTags)
          ...buildMediaPreviewCornerTags(
            context,
            video: video,
            gallery: gallery,
          ),
      ],
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: stretch
          ? content
          : AspectRatio(aspectRatio: 16 / 9, child: content),
    );
  }
}

/// 角标贴在右下角时的那副圆角：贴边那两个角是直角，朝里的那个大一档。
const BorderRadius _cornerTagRightTail = BorderRadius.only(
  topLeft: Radius.circular(6),
  bottomRight: Radius.circular(4),
);

/// 贴边的那几枚角标（时长 / 张数 / R18 / 私密 / 外链）。
///
/// [MediaPreviewCover] 与 [MediaPreviewGalleryPager] 共用：翻页器右下角摆的是
/// 「第几张 / 共几张」，所以「共几张」那一枚由 [showImageCount] 关掉——同一个角上
/// 两枚数字叠着看谁都读不懂。
List<Widget> buildMediaPreviewCornerTags(
  BuildContext context, {
  Video? video,
  ImageModel? gallery,
  bool showImageCount = true,
}) {
  final t = slang.Translations.of(context);
  final ColorScheme cs = Theme.of(context).colorScheme;
  const BorderRadius leftTail = BorderRadius.only(
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(4),
  );

  final bool isR18 = (video?.rating ?? gallery?.rating) == 'ecchi';
  final bool isPrivate = video?.private == true;
  final String? duration = video?.minutesDuration;
  final bool isExternal = video?.isExternalVideo == true;
  final int? imageCount = showImageCount ? gallery?.numImages : null;

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
          borderRadius: _cornerTagRightTail,
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
          borderRadius: _cornerTagRightTail,
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
          borderRadius: _cornerTagRightTail,
        ),
      ),
  ];
}

/// 这份文件进不进翻页器。
///
/// 图库里偶尔混着一条视频文件（`type` / `mime` 任一说了算，两边都认一遍是因为
/// 老数据里 `type` 不一定填对）。预览这块位置放不了播放器，摆一帧封面上去只会
/// 让人点了没反应，所以视频那条整只让开——张数角标读的仍然是接口给的 `numImages`，
/// 与图库详情页一致。
bool _isPreviewableImage(MediaFile file) =>
    file.type != 'video' && !file.mime.startsWith('video/');

/// 图库预览的翻页器：把整本图库摆进封面那块位置。
///
/// # 为什么不是只摆封面
///
/// 封面只是这本里的其中一张，而且在卡片上已经被裁成 16:9 看过一次了。长按想看的
/// 是「这本里面都有什么」，所以这里翻的是整本：一页一张，横滑 / 滚轮 / 悬停箭头
/// 都能翻，右下角那枚角标从「共几张」换成「第几张 / 共几张」。
///
/// # ⛔ 起手那一页必须先铺满，落地之后再展开
///
/// Hero 飞过来的那一份画的是**裁满整只盒子**的封面（见
/// `_MediaPreviewDialogState._buildFlightShuttle`），所以落地那一帧这里也必须是
/// 铺满的，否则封面会当着用户的面缩一下。等路由动画跑完（Hero 落地）再展开成
/// 完整的那一张——这一下形变本身就是「凑近看清楚了」这句话。
///
/// 起手那一页也不一定是第 0 页：图库的封面允许是任意一张（`thumbnail` 独立于文件
/// 顺序），开在它上面 Hero 才接得住。所以**不重排**文件顺序（那会和图库详情页对
/// 不上），只是把初始页挪过去。
///
/// # 点开 / 往下拖 = 大图页
///
/// 点某一张、或者把它往下拖，去处都是「详情页 + 正停在这张的大图页」。翻页器
/// 这一侧只负责把「哪一张、它此刻在屏幕上的哪儿」报上去（[onImageTap] /
/// [onImageDragStart]），形变与交接由弹窗那边画——它才够得着整块屏幕。
///
/// # 让出来的边一律纯黑
///
/// 图库里竖图居多，铺满就等于把大半张裁掉；完整摆进这只盒子必然留边。那圈边跟
/// **大图页**用同一种底色——「往下拖就变成大图页」那一段中途才不会换底，读起来
/// 才是同一件事在长大。（试过垫自己的模糊放大版，用户要的是纯黑。）
class MediaPreviewGalleryPager extends StatefulWidget {
  const MediaPreviewGalleryPager({
    super.key,
    required this.gallery,
    required this.images,
    required this.borderRadius,
    required this.onImageTap,
    this.onImageDragStart,
    this.onImageDragUpdate,
    this.onImageDragEnd,
    this.fallbackThumbnailUrl,
    this.stretch = false,
    this.showCornerTags = true,
  });

  final ImageModel gallery;

  /// 这本里翻得动的那几张。空着就该摆 [MediaPreviewCover]（图还没到手 / 这条
  /// 压根没有图），翻页器在那儿只是白搭一层手势。
  final List<MediaFile> images;

  final BorderRadius borderRadius;

  /// 点了第 [index] 张。[imageRect] 是它此刻在屏幕上的位置（全局坐标）——弹窗
  /// 拿它当「长成大图页」那段形变的起点。
  ///
  /// ⛔ 点按由翻页器**自己**在每一页里接：盖一层 `Positioned.fill` 上去会把横滑
  /// 整只吃掉（`Stack` 命中即停）。点按与横滑在手势竞技场里本来就分得开。
  final void Function(int index, Rect imageRect) onImageTap;

  /// 手指把第 [index] 张往下带。参数同 [onImageTap]。
  final void Function(int index, Rect imageRect)? onImageDragStart;

  /// 从起手点算起的累计纵向位移（向下为正）。
  final ValueChanged<double>? onImageDragUpdate;

  /// 松手了，带的是纵向甩速（像素/秒）。
  final ValueChanged<double>? onImageDragEnd;

  /// 见 [MediaPreviewCover.fallbackThumbnailUrl]。
  final String? fallbackThumbnailUrl;

  /// 见 [MediaPreviewCover.stretch]。
  final bool stretch;

  /// 见 [MediaPreviewCover.showCornerTags]。「第几张 / 共几张」那一枚不受它管——
  /// 它说的是「你翻到哪儿了」，宽屏那份统计行里没有对应项。
  final bool showCornerTags;

  @override
  State<MediaPreviewGalleryPager> createState() =>
      _MediaPreviewGalleryPagerState();
}

class _MediaPreviewGalleryPagerState extends State<MediaPreviewGalleryPager> {
  /// 卡片上那张封面是这本里的第几张。见类注释。
  late final int _coverIndex = _resolveCoverIndex();
  late final PageController _controller = PageController(
    initialPage: _coverIndex,
  );
  late int _page = _coverIndex;

  /// 鼠标在这块位置上——翻页箭头只在这时候露出来。触摸设备永远不会进这个态，
  /// 那边横滑就够了，不该白占两个角。
  bool _hovering = false;

  /// Hero 落地了没有。见类注释「起手那一页必须先铺满」。
  bool _landed = false;
  Animation<double>? _routeAnimation;

  /// 还没画过第一帧。
  ///
  /// ⛔ 这只翻页器不一定在弹窗开场时就在场：图库那本图是拉回来的，拉到之前站在
  /// 这块位置上的是铺满的 [MediaPreviewCover]。换上来的第一帧要是直接摆完整的
  /// 那张，就是当着用户的面硬切一刀。所以第一帧一律铺满，下一帧才开始展开——
  /// 隐式动画得先见过起点，才知道自己要从哪儿走。
  bool _firstFrame = true;

  /// 铺满 ↔ 完整那一下形变的时长。比路由转场慢半拍：落地之后才开始，太快会和
  /// 弹窗自己的入场糊成一团。
  static const Duration _expandDuration = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _firstFrame = false);
    });
  }

  int _resolveCoverIndex() {
    final String? thumbnailId = widget.gallery.thumbnail?.id;
    if (thumbnailId == null) return 0;
    final int index = widget.images.indexWhere((f) => f.id == thumbnailId);
    return index < 0 ? 0 : index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (animation == null) {
      // 没有路由（单测 / 直接塞进别处）就当已经落地：那儿根本没有 Hero 要接。
      // ⛔ 这一支必须走在「没换过」那道闸门前面：两边都是 null 时 identical 为
      // 真，闸门会把它挡回去，整只翻页器从此停在铺满不动。
      _routeAnimation?.removeStatusListener(_onRouteStatus);
      _routeAnimation = null;
      _landed = true;
      return;
    }
    if (identical(animation, _routeAnimation)) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = animation;
    _landed = animation.isCompleted;
    animation.addStatusListener(_onRouteStatus);
  }

  void _onRouteStatus(AnimationStatus status) {
    if (!mounted) return;
    final bool landed = status == AnimationStatus.completed;
    if (landed == _landed) return;
    setState(() => _landed = landed);
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _controller.dispose();
    super.dispose();
  }

  void _setHovering(bool hovering) {
    if (_hovering == hovering || !mounted) return;
    setState(() => _hovering = hovering);
  }

  /// 当前这一页那张图此刻在屏幕上占的位置（全局坐标）。
  ///
  /// 图在盒子里居中、按自己的比例摆（[_buildPageContent]），所以从翻页器自己的
  /// 盒子加上「装得下的尺寸」就能算出来——展开动画还没跑完时那张图仍是铺满的，
  /// 这时候量的就是整只盒子。
  Rect? _currentImageRect() {
    final RenderObject? object = context.findRenderObject();
    if (object is! RenderBox || !object.hasSize) return null;
    if (_page < 0 || _page >= widget.images.length) return null;
    final Size slot = object.size;
    if (slot.isEmpty) return null;
    final Offset topLeft = object.localToGlobal(Offset.zero);
    final double? aspect = _mediaFileAspect(widget.images[_page]);
    final bool expanded = aspect != null && _landed && !_firstFrame;
    final Size fitted = expanded ? _containedSize(slot, aspect) : slot;
    return Rect.fromCenter(
      center: topLeft + Offset(slot.width / 2, slot.height / 2),
      width: fitted.width,
      height: fitted.height,
    );
  }

  /// 起手到现在的累计纵向位移。见 [MediaPreviewGalleryPager.onImageDragUpdate]。
  double _dragDy = 0;

  void _handleDragStart(DragStartDetails details) {
    final Rect? rect = _currentImageRect();
    if (rect == null) return;
    _dragDy = 0;
    widget.onImageDragStart?.call(_page, rect);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDy += details.delta.dy;
    widget.onImageDragUpdate?.call(_dragDy);
  }

  void _handleDragEnd(DragEndDetails details) {
    widget.onImageDragEnd?.call(details.velocity.pixelsPerSecond.dy);
  }

  void _handleDragCancel() => widget.onImageDragEnd?.call(0);

  void _handleTap() {
    final Rect? rect = _currentImageRect();
    if (rect == null) return;
    widget.onImageTap(_page, rect);
  }

  void _goTo(int page) {
    if (page < 0 || page >= widget.images.length) return;
    _controller.animateToPage(
      page,
      duration: GlassTokens.motionDuration,
      curve: GlassTokens.motionCurve,
    );
  }

  /// 封面那张缩略图的地址。见 [MediaPreviewCover.fallbackThumbnailUrl]。
  String get _coverThumbnailUrl {
    final String url = widget.gallery.thumbnailUrl;
    return url.isNotEmpty ? url : (widget.fallbackThumbnailUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Stack(
      fit: StackFit.expand,
      children: [
        // 每一页的底一律纯黑：竖图在这只盒子里必然留边，而黑边正是大图页的底色
        // ——留白会让「拖出去变成大图页」那一段中途换个底，读起来就断了。
        const ColoredBox(color: Colors.black),
        ScrollConfiguration(
          behavior: const _GalleryPagerScrollBehavior(),
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _page = index);
            },
            itemBuilder: _buildPage,
          ),
        ),
        if (widget.showCornerTags)
          ...buildMediaPreviewCornerTags(
            context,
            gallery: widget.gallery,
            // 只有一张时右下角还是照常摆「共几张」，多张才换成下面那枚计数。
            showImageCount: widget.images.length <= 1,
          ),
        // 右下角那一枚从「共几张」换成「第几张 / 共几张」：位置与读法都和卡片
        // 一致，只是现在它还告诉你自己翻到哪儿了。
        if (widget.images.length > 1)
          Positioned(
            right: 0,
            bottom: 0,
            child: BaseTag(
              text: '${_page + 1} / ${widget.images.length}',
              icon: Icons.image,
              backgroundColor: Colors.black54,
              borderRadius: _cornerTagRightTail,
            ),
          ),
        _buildArrow(forward: false),
        _buildArrow(forward: true),
      ],
    );

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: MouseRegion(
        onEnter: (_) => _setHovering(true),
        onExit: (_) => _setHovering(false),
        // 纵向拖拽 = 把这一张拖成大图页（弹窗那边接着这三个回调画形变）。
        // 和 PageView 的横滑同处一个竞技场：谁先够到自己方向的滑动阈值谁赢，
        // 所以横着翻页与竖着拖出去互不干扰。
        child: GestureDetector(
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          onVerticalDragCancel: _handleDragCancel,
          child: widget.stretch
              ? content
              : AspectRatio(aspectRatio: 16 / 9, child: content),
        ),
      ),
    );
  }

  /// 悬停才露的翻页箭头。
  ///
  /// 走 [GlassReveal] + `materialize` 而不是 `Opacity`：透明度层会把液态玻璃的
  /// 折射打断（全站规矩，见 `GlassSurface.materialize`）。
  Widget _buildArrow({required bool forward}) {
    final t = slang.Translations.of(context);
    final int target = forward ? _page + 1 : _page - 1;
    final bool visible =
        _hovering && target >= 0 && target < widget.images.length;
    return Positioned.fill(
      child: Align(
        alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GlassReveal(
            visible: visible,
            slideFrom: Offset(forward ? 0.4 : -0.4, 0),
            builder: (context, materialize) => GlassChromeLayer(
              // group: false —— 两枚箭头隔着整块画面，收进同一层融合省不出采样，
              // 却会吃掉它们按下时的底色加深（同一层玻璃只有一份材质）。
              group: false,
              child: GlassIconButton(
                standalone: true,
                materialize: materialize,
                icon: Icon(forward ? Icons.chevron_right : Icons.chevron_left),
                tooltip: forward
                    ? t.mediaPreview.nextImage
                    : t.mediaPreview.previousImage,
                onPressed: () => _goTo(target),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    final MediaFile file = widget.images[index];
    final String url = file.getLargeImageUrl();
    // 尺寸不知道就只能一直铺满：拿一个猜出来的比例把图摆歪，比裁一刀更难看。
    final double? aspect = _mediaFileAspect(file);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size box = Size(constraints.maxWidth, constraints.maxHeight);
          final double expanded = (aspect != null && _landed && !_firstFrame)
              ? 1
              : 0;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: expanded, end: expanded),
            duration: _expandDuration,
            curve: Curves.easeOutCubic,
            builder: (context, expand, _) => _buildPageContent(
              url: url,
              isCover: index == _coverIndex,
              box: box,
              aspect: aspect,
              expand: expand,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageContent({
    required String url,
    required bool isCover,
    required Size box,
    required double? aspect,
    required double expand,
  }) {
    final Size fitted = aspect == null ? box : _containedSize(box, aspect);
    // 底色由外面那层纯黑给，这里只管图本身从铺满长到完整。
    final double width = lerpDouble(box.width, fitted.width, expand)!;
    final double height = lerpDouble(box.height, fitted.height, expand)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: SizedBox(
            width: width,
            height: height,
            // 盒子本身就是按这张图的比例算出来的，所以 cover 到位那一刻恰好等于
            // contain：一路 cover 过去，形变途中也不会有黑边挤进来。
            child: _buildImage(url, isCover: isCover),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url, {required bool isCover}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      // 超大图全解码爆内存，同图库详情页的处置（`ImageWidget`）。这两处的上限
      // 必须一样，否则磁盘里存的是缩过的那份、详情页再也拿不到原尺寸。
      maxWidthDiskCache: 4096,
      maxHeightDiskCache: 4096,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholderFadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (context, _) => isCover
          // 封面那张缩略图列表里刚看过、还在内存里，拿它顶着大图那段空窗：
          // Hero 落地才不会先闪一格灰。
          ? CachedNetworkImage(
              imageUrl: _coverThumbnailUrl,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              placeholderFadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            )
          : const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 32,
          color: Color(0xFF9E9E9E),
        ),
      ),
    );
  }
}

/// 这份文件的宽高比（宽 / 高）。接口没给尺寸就是 null。
double? _mediaFileAspect(MediaFile file) {
  final int? width = file.width;
  final int? height = file.height;
  if (width == null || height == null || width <= 0 || height <= 0) return null;
  return width / height;
}

/// [box] 里完整装下比例为 [aspect]（宽 / 高）的那张图之后，图占多大。
Size _containedSize(Size box, double aspect) {
  if (box.isEmpty || aspect <= 0) return box;
  return box.width / box.height > aspect
      ? Size(box.height * aspect, box.height)
      : Size(box.width, box.width / aspect);
}

/// 桌面端也要能用鼠标拖着翻。
///
/// Flutter 默认只认触摸与触控笔的拖动（怕和文本选择打架），鼠标就只剩滚轮；而
/// 这块位置上滚轮是纵向的手势、翻的却是横向的页，读起来并不直觉。
class _GalleryPagerScrollBehavior extends MaterialScrollBehavior {
  const _GalleryPagerScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.mouse,
  };
}
