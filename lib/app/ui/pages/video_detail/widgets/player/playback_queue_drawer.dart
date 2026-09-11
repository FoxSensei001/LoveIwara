import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/app/models/local_media/local_media_folder.model.dart';
import 'package:i_iwara/app/models/local_media/local_media_item.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/gallery_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/local_media_scan_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/app/ui/widgets/media_preview_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 用户在抽屉里点播了一条。
class PlaybackQueueSelection {
  const PlaybackQueueSelection({
    required this.queue,
    required this.item,
    required this.skipWatched,
  });

  /// 被点播那一条所在的池——**它才是新的当前池**。
  final PlaybackQueue queue;
  final InnerPlaylistItemSnapshot item;

  /// 续播时跳不跳过已看完的。由点播时所在的筛选 tab 决定。
  final bool skipWatched;
}

/// 播放器的「接着看」抽屉。
///
/// # 从横向列表改成竖排侧边抽屉
///
/// 老版本是贴在播放器右侧的一条横向列表，而且**只在全屏时存在**。现在走全站
/// 统一的 [showGlassSideDrawer]（一条 root 路由，宽屏 380 / 窄屏 88%），
/// **全屏与非全屏都能开**——横屏移动端播放器的垂直空间很小，竖排抽屉盖在整页上
/// 反而比在画面里挤一条横向列表舒服。
///
/// # ⛔ 切 tab 只是浏览，点播才换池
///
/// 用户经常只是想「在源池自动连播的时候，打开抽屉瞄一眼稍后再看里有什么」。
/// 如果点一下 tab 就把当前池静默换掉，下一条会突然从另一个池冒出来。所以本
/// 抽屉**关闭时只回传"你点播了哪一条、它在哪个池"**（[PlaybackQueueSelection]）；
/// 只看不点，当前池一点不受影响。
///
/// # ⛔ 一只抽屉，两种媒体，但**一次只服务一种**
///
/// 图库详情页用的是同一只抽屉（[mediaType] 传 `gallery`）：结构完全一样，
/// 只有"能换到哪几类池"和"行尾角标写时长还是写张数"两处不同。
///
/// 但**池里不许混装**：视频和图库落在两个不同的详情页，一个池里混着两种的话
/// "下一条"会把用户从播放器扔进图库（稍后再看池一直排除图库正是这个道理）。
/// 所以类型是池的属性（[PlaybackQueue.mediaType]），抽屉只是照着它列菜单。
///
/// # ⛔ 抽屉在全屏里也开得出来，所以「跳页」这件事要格外小心
///
/// 行上长按能弹出预览弹窗，弹窗里又能去作者主页 / 标签列表。那两页推进的是
/// **shell**，而本抽屉是一条 **root** 弹层路由——不主动收掉的话它会原样浮在
/// 新页上面；全屏也一样，不交还就变成一个铺满显示器、拖不动的窗口。两件事都在
/// `_leaveForPreviewNavigation` 那条路上收口（兜底另见
/// `PlayerFullscreenGuard`）。
Future<PlaybackQueueSelection?> showPlaybackQueueDrawer({
  required BuildContext context,
  required List<PlaybackQueue> queues,
  required PlaybackQueue initialQueue,
  required String currentItemId,
  User? author,
  PlaybackMediaType mediaType = PlaybackMediaType.video,
}) {
  if (queues.isEmpty) return Future<PlaybackQueueSelection?>.value();
  return showGlassSideDrawer<PlaybackQueueSelection>(
    context: context,
    builder: (_) => _PlaybackQueueDrawer(
      queues: queues,
      initialQueue: initialQueue,
      currentItemId: currentItemId,
      author: author,
      mediaType: mediaType,
    ),
  );
}

class _PlaybackQueueDrawer extends StatefulWidget {
  const _PlaybackQueueDrawer({
    required this.queues,
    required this.initialQueue,
    required this.currentItemId,
    this.author,
    this.mediaType = PlaybackMediaType.video,
  });

  final List<PlaybackQueue> queues;
  final PlaybackQueue initialQueue;
  final String currentItemId;

  /// 这条视频的作者：既是「作者的播放列表」的主人，也是「作者的视频」那个池的主人。
  final User? author;

  /// 这只抽屉这一次服务的是视频还是图库（见 [showPlaybackQueueDrawer]）。
  final PlaybackMediaType mediaType;

  @override
  State<_PlaybackQueueDrawer> createState() => _PlaybackQueueDrawerState();
}

class _PlaybackQueueDrawerState extends State<_PlaybackQueueDrawer> {
  /// 这一次服务的是图库还是视频。菜单里能换到哪几类、行尾角标写什么，都看它。
  bool get _isGallery => widget.mediaType.isGallery;

  late List<PlaybackQueue> _queues;
  late int _selectedIndex;
  final ScrollController _scrollController = ScrollController();

  /// 稍后再看池的筛选。切它等于换一个池（筛选是池身份的一部分）。
  ///
  /// ⛔ 初值必须从**交接过来的那个池**上读（见 [initState]），不能一律 false：
  /// 从稍后再看页的「未看完」点进来时，抽屉开着的就是 `watchLater:unwatched`，
  /// 而胶囊和菜单里的勾都靠这个标记画——写死 false 的话它们会一致地说谎。
  bool _unwatchedOnly = false;

  /// 三份"点开才用得上"的清单。**抽屉一打开就在后台去拉**（见 [initState]）：
  ///
  /// 1. 用户点到「我的播放列表」时多半已经在手上了，第二张菜单当场就开；
  /// 2. 更要紧的是**置灰要准**——只有先查过，才知道"作者根本没有播放列表"，
  ///    菜单才敢把那一条灰掉（2026-08-29 用户提的正是这个）。没查过一律保持
  ///    可点，替用户断言一件还不知道的事比多点一次更糟。
  late final _MenuFeed _ownPlaylists = _MenuFeed(_fetchOwnPlaylists);
  late final _MenuFeed _authorPlaylists = _MenuFeed(_fetchAuthorPlaylists);
  late final _MenuFeed _localFolders = _MenuFeed(_fetchLocalFolders);

  /// 下载分类清单（全部 / 未分类 / 各自定义分类，各带**可播条数**）。
  late final _MenuFeed _downloadCategories = _MenuFeed(
    _fetchDownloadCategories,
  );

  /// 本机文件的源清单（各带**可播的视频条数**）。
  late final _MenuFeed _localSources = _MenuFeed(_fetchLocalSources);

  /// 用户到底加没加过本机来源——[_localSources] 拉回来之后填上。
  ///
  /// ⛔ 它决定的是「本机文件」这一条**在不在场**，而不是置不置灰，所以拉完必须
  /// `setState` 一次（见 [_warmUpChoices] 里那句 `.then`）。全站其它条目在"还没
  /// 查过"时的降级是"不置灰、照常可点"，唯独这一条降级成"不存在"——不重建的话，
  /// 预取（刻意推迟到抽屉入场动画之后，见 [_scheduleWarmUp]）完成前开菜单，
  /// 这一条会整只消失，而用户根本不知道自己错过了什么。
  ///
  /// ⛔ 也**不能**图省事在 [initState] 里同步读一次：那正是本文件里记着的那次
  /// 「点开接着看会卡一下」——同步查库压在抽屉第一帧上。
  bool _hasLocalSources = false;

  /// 「他人的播放列表」那份清单——**临时的**，只在当前正开着一张既不属于我、
  /// 也不属于这条视频作者的播放列表时才存在（从别人的播放列表进来的情形）。
  ///
  /// 它按主人建：主人换了（在抽屉里切到了另一个人的列表）就整只重建，否则
  /// 会拿着上一个人的清单不放。
  _MenuFeed? _otherPlaylists;
  String? _otherPlaylistsOwnerId;

  /// 当前池清单里那张「他人的」播放列表的主人。没有就返回 null。
  User? get _otherPlaylistOwner {
    final self = Get.find<UserService>().currentUser.value;
    final authorId = widget.author?.id;
    for (final queue in _queues) {
      if (queue is! PlaylistPlaybackQueue) continue;
      final owner = queue.owner;
      if (owner == null) continue;
      if (owner.id == self?.id || owner.id == authorId) continue;
      return owner;
    }
    return null;
  }

  _MenuFeed _otherPlaylistsFeed(User owner) {
    if (_otherPlaylistsOwnerId != owner.id || _otherPlaylists == null) {
      _otherPlaylistsOwnerId = owner.id;
      _otherPlaylists = _MenuFeed(() => _fetchPlaylistsOf(owner.id));
    }
    return _otherPlaylists!;
  }

  /// 正在拉播放列表（预取还没回来就被点到了）。
  ///
  /// ⛔ 转圈只能画在**胶囊**上，不能画在菜单里：玻璃菜单开出来之后尺寸就钉死了
  /// （液态档把量出来的尺寸直接喂给玻璃，"全程尺寸不变"是卷开动画的前提），
  /// 菜单开着时没有任何办法改一行。所以这里走全 App 统一的「按钮级 loading」
  /// 那套词汇：原位换沙漏 + 文案转「加载中」，钮本身按不动。
  bool _loadingChoices = false;

  @override
  void initState() {
    super.initState();
    _queues = List.of(widget.queues);
    _selectedIndex = _queues
        .indexOf(widget.initialQueue)
        .clamp(0, _queues.length - 1);
    _activeQueueId = _queues[_selectedIndex].queueId;
    final initial = widget.initialQueue;
    if (initial is WatchLaterPlaybackQueue) {
      _unwatchedOnly = initial.unwatchedOnly;
    }
    _current.addListener(_onQueueChanged);
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoaded();
      _scrollToCurrent();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleWarmUp();
  }

  /// 预取要等抽屉**滑完**再跑。
  ///
  /// ⛔ 「点开接着看会卡一下」的直接成因（2026-08-29 用户报的）：预取里的三份
  /// 本地清单——`FavoriteService.getAllFolders()`（favorite_items 上的
  /// JOIN + GROUP BY）、`getCompletedDownloadCounts()`、`getAllCategories()`——虽然
  /// 签名是 `Future`，函数体里却**一个 await 都没有**，sqlite 查询整段跑在调用
  /// 方这一轮里。`initState` 里发它们，等于把三次同步查库压在抽屉的**第一帧**
  /// 上，260ms 的滑入动画开头就丢帧。
  ///
  /// 挪到路由动画跑完之后：那时用户已经看到抽屉了，查库的几十毫秒落在静止画面
  /// 上，看不出来。代价只有"刚滑完的那一瞬还不知道某一类是不是空的"——而菜单
  /// 本来就把「还没查过」和「查过、真没有」分开处理（见 [_openQueuePicker] 的
  /// 三态），点进去也会补一枪。
  void _scheduleWarmUp() {
    if (_warmUpScheduled) return;
    _warmUpScheduled = true;
    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _warmUpChoices();
      return;
    }
    _warmUpAnimation = animation..addStatusListener(_onRouteAnimationStatus);
  }

  bool _warmUpScheduled = false;
  Animation<double>? _warmUpAnimation;

  void _onRouteAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _detachWarmUpListener();
    if (mounted) _warmUpChoices();
  }

  void _detachWarmUpListener() {
    _warmUpAnimation?.removeStatusListener(_onRouteAnimationStatus);
    _warmUpAnimation = null;
  }

  @override
  void dispose() {
    _detachWarmUpListener();
    _current.removeListener(_onQueueChanged);
    _scrollController.dispose();
    super.dispose();
  }

  PlaybackQueue get _current => _queues[_selectedIndex];

  /// 眼下正在浏览的这个池，是不是**播放器真正在用的那个**。
  ///
  /// ⛔ 「正在播」的标记只能挂在它身上（见 [_QueueRow.isCurrent] 的调用点）。
  /// 抽屉的规矩是「切池只是浏览，点播才换池」，而上一版按 id 一路标下去：在
  /// 来源池连播时切到「作者」，作者池里那条同一个视频也是一身高亮 + 「正在
  /// 播放」角标，看上去就像池已经换过去了——可这时按「下一个」出来的仍是来源
  /// 池的下一条（2026-08-30 用户报的正是这个错觉）。
  ///
  /// 按 **queueId** 比而不是 `identical`：换播放列表 / 换稍后再看的筛选都会
  /// 换出新实例，但 id 一样就是同一个池；反过来 `watchLater:all` 与
  /// `watchLater:unwatched` 是两个池，续播跟着的是当初那一个，标记也该跟着走。
  bool get _isBrowsingActiveQueue => _current.queueId == _activeQueueId;

  /// 打开这只抽屉时播放器正在用的那个池。整段生命周期里不变——抽屉自己**不会**
  /// 换池（换池是回传给详情页之后的事），所以在 `initState` 里定死。
  ///
  /// 取的是**落位之后**那一档而不是直接读 `widget.initialQueue`：万一交进来的
  /// 池不在清单里（`indexOf` 落空会被 clamp 到 0），至少还能保住「开局这一池
  /// 就是当前池」，不至于一进来满屏没有标记。
  late final String _activeQueueId;

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  /// 把当前池拉起来，并**翻到"正在播的那一条"为止**。
  ///
  /// ⛔ 第二步不是锦上添花：从「最爱」「已下载」这类深列表的中段点进播放器时，
  /// 池里只有第 0 页，当前这条可能在第 5 页——不翻的话高亮行根本不在列表里，
  /// 抽屉一开就是一份陌生的清单（用户要的"自动定位"正是这一下）。
  Future<void> _ensureLoaded() async {
    final queue = _current;
    if (queue.loaded.isEmpty && queue.hasMore && !queue.isLoading) {
      await queue.loadMore();
    }
    if (!mounted || !identical(queue, _current)) return;
    if (queue.contains(widget.currentItemId)) return;
    await queue.ensureContains(widget.currentItemId);
    if (!mounted || !identical(queue, _current)) return;
    // 只在用户还没自己滚过时才跳——他已经滑到别处去了就别抢方向盘。
    if (_scrollController.hasClients && _scrollController.offset > 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToCurrent();
    });
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      _ensureLoadedMore();
    }
  }

  void _ensureLoadedMore() {
    final queue = _current;
    if (queue.hasMore && !queue.isLoading) queue.loadMore();
  }

  /// 已经选过一条了。
  ///
  /// ⛔ 没有这道闸门的话，快速双击同一行会 pop 两次：第一次关抽屉，第二次
  /// 落到下面的**详情页**上，把正在看的视频页一起关掉（这个仓库踩过同款
  /// 「pop 两次连页面一起关」）。抽屉退场动画期间那一行仍然命中得到。
  bool _selected = false;

  void _selectItem(PlaybackQueueSelection selection) => _closeDrawer(selection);

  /// 关抽屉。带 [selection] 就是「点播了这一条」，不带就是单纯让开
  /// （预览弹窗要把用户带去作者页/标签页时会走这一条）。
  void _closeDrawer([PlaybackQueueSelection? selection]) {
    if (_selected || !mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    _selected = true;
    Navigator.of(context).pop(selection);
  }

  /// 长按 / 右键一行 → 那条媒体的**预览弹窗**（与卡片列表同一只）。
  ///
  /// # ⛔ 这里的条目常常只是一份种子
  ///
  /// 接口来的池（来源 / 播放列表 / 作者的作品 / 最爱）在建快照时把整个 `Video`
  /// 一起带上了（[InnerPlaylistItemSnapshot.sourceVideo]），直接给弹窗即可。
  /// 但本地库来的那几个池（稍后再看 / 本地收藏夹 / 已下载）只存了标题封面作者
  /// ——统计、标签、作者头像一概没有，图库那一路更是**从来没有** sourceVideo。
  ///
  /// 这些条目的 id **多数**仍是 iwara 的 id（下载池就是靠它去磁盘上找文件的），
  /// 所以拿种子先把弹窗开出来，同时按 id 去拉详情：封面标题当场在场，统计那一排
  /// 先摆骨架，拉到就地换成真的（见 [showMediaPreviewDialog]）。
  ///
  /// ⛔ **本机文件是唯一的例外，它的 id 不是 iwara 的**：那是
  /// `<源 uuid>-<路径 sha1>`。拿它去 `fetchVideoInfoResult` 必然 404
  /// （统计那一排永远停在骨架上），而且把用户本机路径的摘要发了出去。
  /// 它的封面也是 `file://`，[showMediaPreviewDialog] 那边只会走网络加载器，
  /// 画出来是一枚碎图。两样都得掐掉——与 [_playlistSources] 是同一条纪律。
  Future<void> _openPreview(
    PlaybackQueue queue,
    InnerPlaylistItemSnapshot item,
  ) {
    final selection = PlaybackQueueSelection(
      queue: queue,
      item: item,
      skipWatched: queue.kind == PlaybackQueueKind.watchLater && _unwatchedOnly,
    );

    // 本机文件：id 不是 iwara 的、封面是 file://，两条都不能交给联网那套（见方法
    // 注释）。图库那一路同样有本机文件（本机图片池），一样得掐掉。
    final bool isLocalFile = queue.kind == PlaybackQueueKind.localLibrary;

    if (queue.mediaType.isGallery) {
      return showMediaPreviewDialog(
        context: context,
        gallery: _seedGallery(item),
        coverUrl: isLocalFile ? null : item.thumbnailUrl,
        loadGalleryDetail: isLocalFile
            ? null
            : () async => (await Get.find<GalleryService>().fetchGalleryDetail(
                item.id,
              )).data,
        onOpenDetail: () async => _selectItem(selection),
        onWillLeavePage: _leaveForPreviewNavigation,
        remoteActionsAvailable: !isLocalFile,
      );
    }

    // 快照带着完整的那份就别再联网拉一遍——它正是列表页刚拿到的那个对象。
    final Video? known = item.sourceVideo;
    return showMediaPreviewDialog(
      context: context,
      video: known ?? _seedVideo(item),
      coverUrl: isLocalFile ? null : item.thumbnailUrl,
      loadVideoDetail: known != null || isLocalFile
          ? null
          : () async =>
                (await VideoService.to.fetchVideoInfoResult(item.id)).data,
      onOpenDetail: () async => _selectItem(selection),
      onWillLeavePage: _leaveForPreviewNavigation,
      // ⛔ 本机文件在 Iwara 上没有对应的东西：点赞会拿本地 id 打接口，稍后再看
      // 会把这一行**持久写进本地库**，之后点开必然 404。这条洞本机视频那一路
      // 早就有（`isLocalFile` 时 `loadVideoDetail` 也是 null，于是三枚钮照常
      // 可按），这次一起堵上。
      remoteActionsAvailable: !isLocalFile,
    );
  }

  /// 预览弹窗要把用户带去别的页面了（作者主页 / 标签列表 / 菜单里的作者）。
  ///
  /// ⛔ 抽屉自己也得收掉：它是一条 **root** 弹层路由，而那些页面推进的是 shell
  /// ——不收的话抽屉会原样浮在刚推进来的新页上面，还挡着它。
  Future<void> _leaveForPreviewNavigation() async => _closeDrawer();

  /// 用列表行手上那点信息拼一份「够先摆出来」的视频。见 [_openPreview]。
  ///
  /// ⛔ **只填拿得准的**：`file` / `embedUrl` / `tags` 一律不编——封面地址另走
  /// `coverUrl`，时长和外链角标等详情回来再显示。编一份假的出来，弹窗会在拉到
  /// 详情的那一刻当着用户的面改口。
  Video _seedVideo(InnerPlaylistItemSnapshot item) => Video(
    id: item.id,
    title: item.title,
    private: item.isPrivate,
    liked: item.liked,
    numLikes: item.numLikes,
    numViews: item.numViews,
    numComments: item.numComments,
    createdAt: item.createdAt,
    user: _seedUser(item),
  );

  /// [_seedVideo] 的图库版。
  ///
  /// ⛔ `rating` 必须显式给 `general`：模型默认是 `ecchi`，照默认走会让每一张
  /// 预览在拉到详情之前都先扣一枚 R18 角标。
  ImageModel _seedGallery(InnerPlaylistItemSnapshot item) => ImageModel(
    id: item.id,
    title: item.title,
    rating: 'general',
    liked: item.liked,
    numImages: item.numImages ?? 0,
    numLikes: item.numLikes ?? 0,
    numViews: item.numViews ?? 0,
    numComments: item.numComments ?? 0,
    createdAt: item.createdAt,
    user: _seedUser(item),
  );

  /// 种子里的作者：本地库那几个池也存着显示名与 username，够画出名字这一行，
  /// 头像要等详情回来。两样都没有就不编一个空作者出来。
  User? _seedUser(InnerPlaylistItemSnapshot item) {
    final String name = item.authorName?.trim() ?? '';
    final String username = item.authorUsername?.trim() ?? '';
    if (name.isEmpty && username.isEmpty) return null;
    return User(
      id: '',
      name: name.isEmpty ? username : name,
      username: username,
    );
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    final index = _current.loaded.indexWhere(
      (item) => item.id == widget.currentItemId,
    );
    if (index < 0) return;
    final target = (index * _rowExtent(context)).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(target);
  }

  /// 换到某个池上去。**所有换池路径都走这里**（选池、切筛选、换播放列表）。
  ///
  /// ⛔ 「稍后再看出现两个 tab」就是没有这道收口留下的：筛选换一档就是换一个
  /// 池实例（`watchLater:all` / `watchLater:unwatched` 是两个 id），上一版直接
  /// 把它塞进当前槽位、详情页回来再 append 一次，于是同一个池在列表里排了两条
  /// 同名 tab。这里按 **queueId 命中就复用、同 kind 就顶掉、都不是才追加**，
  /// 一种池永远只占一个槽。
  void _useQueue(PlaybackQueue queue, {bool? unwatchedOnly}) {
    _current.removeListener(_onQueueChanged);
    setState(() {
      if (unwatchedOnly != null) _unwatchedOnly = unwatchedOnly;
      final existing = _queues.indexWhere((q) => q.queueId == queue.queueId);
      if (existing >= 0) {
        // ⛔ 命中也要把实例顶掉，不能只挪选中下标：切走的池身上 0 监听，
        // 池总数超上限时会被 service dispose 掉并移出 map；再切回来 service
        // 给的是**新实例**，而我们这份列表里还攥着那具尸体。不顶掉的话下面
        // 那句 addListener 就落在已 dispose 的 ChangeNotifier 上（debug 抛
        // 「used after being disposed」，release 下这个 tab 变成永不加载的死池）。
        _queues[existing] = queue;
        _selectedIndex = existing;
        return;
      }
      final slot = _queues.indexWhere((q) => q.kind == queue.kind);
      if (slot >= 0) {
        _queues[slot] = queue;
        _selectedIndex = slot;
      } else {
        _queues.add(queue);
        _selectedIndex = _queues.length - 1;
      }
    });
    _current.addListener(_onQueueChanged);
    _ensureLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  /// 把三份清单先拉起来。见 [_ownPlaylists] 的说明：预取是为了**置灰准**，
  /// 顺带让第二张菜单不用等。拉不到就保持"未知"，下次点到时会重试。
  void _warmUpChoices() {
    _localFolders.warmUp();
    // 见 [_hasLocalSources]：拉完要重建一次，否则「本机文件」那一条在预取完成前
    // 开菜单是**整只不在**的（而不是像别的条目那样只是没置灰）。
    //
    // ⛔ 它在 `if (_isGallery) return` **之上**：图库这一路同样有本机文件（装的是
    // 本机图片），漏在下面的话那一条在图库里永远不出现。
    _localSources.get().then((rows) {
      if (!mounted) return;
      final has = rows != null && rows.isNotEmpty;
      if (has != _hasLocalSources) setState(() => _hasLocalSources = has);
    });
    // ⛔ 「已下载」的预取在 `if (_isGallery) return` **之上**：2026-09-11 起图库
    // 也有自己那一池（见下面 `_QueuePick.downloads` 那条上的注释），取数本来就
    // 按 `_isGallery` 分桶（[_fetchDownloadCategories]）。漏在下面的后果不是那
    // 一条不出现，而是它的 `knownEmpty` 恒 false——图库里那一条**永远不置灰**，
    // 一个图库都没下载过也得点进去才知道是空的。
    _downloadCategories.warmUp();
    // ⛔ 图库这一路**不碰播放列表**：Iwara 的播放列表只收视频，
    // [_playlistSources] 那边同样对 `_isGallery` 早退。预取它们等于为一类根本
    // 不会出现的菜单项白打请求。
    if (_isGallery) return;
    final self = Get.find<UserService>().currentUser.value;
    final author = widget.author;
    // ⛔ 本机文件那一路不预取播放列表：那两个 feed 会拿本机 id 去打 Iwara 接口，
    // 见 [_playlistSources] 里的说明。
    if (!_playingLocalFile) {
      if (self != null) _ownPlaylists.warmUp();
      if (author != null && author.id != self?.id) _authorPlaylists.warmUp();
    }
    final other = _otherPlaylistOwner;
    if (other != null) _otherPlaylistsFeed(other).warmUp();
  }

  /// 池选择菜单：**两级**。
  ///
  /// 第一级只列「池的**类别**」，一类一行；类别里还有分支的（播放列表 /
  /// 本地收藏 / 已下载 / 稍后再看）行尾挂一枚 `›`，点进去开第二张菜单。
  ///
  /// ⛔ 上一版把所有分支摊在同一张菜单里：稍后再看占两行（全部 / 未看完）、
  /// 三份播放列表各占一行、本地收藏夹再一行——下载带上自定义分类之后彻底摊不
  /// 下了，而且十几行挤在一张 380 宽的菜单里，"我现在在哪个池"反倒看不出来。
  /// 类别与类别里的分支是两个层次的问题，就该分两屏问（2026-08-29 用户提的）。
  ///
  /// # 条目的三态
  ///
  /// 每一条只有三种状态，**不知道**和**知道是空的**必须分开：
  ///
  ///   - 已经开着的池 → 照常可选；池**确定空了**（[PlaybackQueue.isKnownEmpty]）
  ///     就置灰，否则那是一条点了什么都不发生的死项；
  ///   - 有清单的类别（播放列表 / 本地收藏 / 已下载）→ 预取回来是空的才置灰，
  ///     拉失败或还没拉回来一律保持可点（点了会重试并给出提示）；
  ///   - 还没开过的池（作者的视频 / 最爱）→ 保持可点。开过一次之后就落到第一条
  ///     规则里，空的自然会灰掉。
  Future<void> _openQueuePicker(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final self = Get.find<UserService>().currentUser.value;
    final author = widget.author;

    // 预取多半在抽屉打开时就跑完了；这里补一枪，覆盖"开抽屉时还没登录/还没拿到
    // 作者"的情况。
    _warmUpChoices();

    int indexOfKind(PlaybackQueueKind kind) =>
        _queues.indexWhere((q) => q.kind == kind);

    /// 「这一类里现在开着的是哪一支」——写进副标题。没开着就返回 null。
    ///
    /// 二级菜单把分支收进去之后，第一级就只剩类别名了；不把当前那一支写出来
    /// 的话，用户得点进去才知道自己在「已下载」的哪个分类里。
    String? openVariant(PlaybackQueueKind kind) {
      final index = indexOfKind(kind);
      if (index < 0) return null;
      if (kind == PlaybackQueueKind.watchLater) {
        return _unwatchedOnly ? t.watchLater.filterUnwatched : t.common.all;
      }
      final title = _queues[index].title?.trim();
      if (title != null && title.isNotEmpty) return title;
      // 下载池没名字就是「全部」；播放列表/收藏夹没名字时不替它编一个。
      return kind == PlaybackQueueKind.downloads ? t.common.all : null;
    }

    /// 一个**还要再选一次**的类别：行尾一枚 `›`，点了开第二张菜单。
    ///
    /// [knownEmpty] 只有在**查过**之后才该是 true——「还没查」和「查过、真没有」
    /// 必须分开（见方法注释里的三态）。
    GlassMenuOption<_QueuePick> branchEntry({
      required _QueuePick value,
      required PlaybackQueueKind kind,
      required String label,
      required bool knownEmpty,
      IconData? icon,
      Widget? leading,
    }) {
      final index = indexOfKind(kind);
      return GlassMenuOption<_QueuePick>(
        value: value,
        label: label,
        description: knownEmpty
            ? t.playbackQueue.nothingHere
            : openVariant(kind),
        icon: icon,
        leading: leading,
        // 「点了还要再选一次」的记号。`trailing` 是 String 不是 Widget——
        // 液态档的面板尺寸靠 TextPainter 离线量，塞 Widget 会量不出宽度。
        trailing: _kSubmenuChevron,
        enabled: !knownEmpty,
        selected: index >= 0 && _selectedIndex == index,
        // 第一级说的是"我这一类里有正在播的东西"，真正被选中的那一支在第二张
        // 菜单里——那儿才该打勾。何况行尾已经有一枚 `›`，两个记号挤一块读不清。
        showCheck: false,
      );
    }

    /// 一个**点了就换过去**的池（来源 / 最爱 / 作者的视频），没有第二级。
    ///
    /// [requirePool] 为真时，池不在场就整只不出现（来源池：深链/通知/搜索单条
    /// 进来时压根没有来源，摆一条点了什么都没有的空项比不摆更糟）。
    GlassMenuOption<_QueuePick>? directEntry({
      required _QueuePick value,
      required PlaybackQueueKind kind,
      required String label,
      bool requirePool = false,
      IconData? icon,
      Widget? leading,
      String? description,
    }) {
      final index = indexOfKind(kind);
      if (requirePool && index < 0) return null;
      final empty = index >= 0 && _queues[index].isKnownEmpty;
      return GlassMenuOption<_QueuePick>(
        value: value,
        label: label,
        description: empty ? t.playbackQueue.nothingHere : description,
        icon: icon,
        leading: leading,
        enabled: !empty,
        selected: index >= 0 && _selectedIndex == index,
        // 与 [branchEntry] 同一条：第一级只做字体高亮，不打勾。
        showCheck: false,
      );
    }

    // 「播放列表」的三组（我的 / 作者的 / 他人的）现在是**三条各自的入口**。
    // 「他人的」是**临时**的：只在正开着一张既不是我的、也不是这条视频作者的
    // 播放列表时才在场（从别人的播放列表点进来的情形）。没有它的话，那个人的
    // 其它列表在播放器里根本够不着。
    final otherOwner = _otherPlaylistOwner;
    final sources = _playlistSources(
      self: self,
      author: author,
      other: otherOwner,
    );
    final openPlaylist = _openPlaylist;
    final openPlaylistGroup = _openPlaylistGroup;
    final playlistIndex = indexOfKind(PlaybackQueueKind.playlist);

    /// 「播放列表」那三条。
    ///
    /// 它们同属 [PlaybackQueueKind.playlist]——同一时刻只可能开着一张，所以
    /// 高亮和副标题都得先问一句"那张归谁"，不能像别的类别那样只看 kind
    /// （只看 kind 的话三条会一起亮）。
    ///
    /// 清单没拉过就不置灰（三态，见方法注释）；正开着一张的那一组更不能灰
    /// ——灰了就再也切不回去。
    GlassMenuOption<_QueuePick>? playlistEntry({
      required _QueuePick pick,
      required String label,
      IconData? icon,
      Widget? leading,
      String? fallbackDescription,
    }) {
      final source = sources[pick];
      final bool openHere = openPlaylist != null && openPlaylistGroup == pick;
      // 这一组既没有清单可拉、也没有正开着的列表 → 整条不出现。
      if (source == null && !openHere) return null;
      final bool knownEmpty = !openHere && (source?.feed.knownEmpty ?? false);
      return GlassMenuOption<_QueuePick>(
        value: pick,
        label: label,
        description: knownEmpty
            ? t.playbackQueue.nothingHere
            : openHere
            ? _playlistTitle(anchorContext, openPlaylist)
            : fallbackDescription,
        icon: icon,
        leading: leading,
        trailing: _kSubmenuChevron,
        enabled: !knownEmpty,
        selected: openHere && _selectedIndex == playlistIndex,
        showCheck: false,
      );
    }

    final entries = <GlassMenuEntry>[
      ?directEntry(
        value: _QueuePick.source,
        kind: PlaybackQueueKind.source,
        label: t.playbackQueue.sourceTab,
        requirePool: true,
        icon: Icons.subject,
      ),
      // 订阅动态。要登录——`subscribed=true` 未登录时会被服务端静默忽略、
      // 返回全站内容（见 `PlaybackQueueService.openSubscriptions`），所以
      // 没登录时整条不出现，而不是摆一条点进去是"全站热门"的「订阅」。
      if (self != null)
        ?directEntry(
          value: _QueuePick.subscriptions,
          kind: PlaybackQueueKind.subscriptions,
          label: t.common.subscriptions,
          icon: Icons.subscriptions_outlined,
        ),
      ?playlistEntry(
        pick: _QueuePick.playlists,
        label: t.playbackQueue.myPlaylists,
        icon: Icons.queue_music,
      ),
      if (self != null)
        ?directEntry(
          value: _QueuePick.favorites,
          kind: PlaybackQueueKind.favorites,
          label: t.common.favorites,
          icon: Icons.favorite_border,
        ),
      // 收藏夹 / 已下载 / 本机文件都是「我自己的东西」，三条挨着；中间夹进别的
      // 会读成两回事。
      //
      // ⛔ 这一条叫「收藏夹」而**不是「本地收藏夹」**：它拉的是
      // `FavoriteService.getAllFolders()`，是收藏关系不是磁盘目录。下面紧跟着
      // 的「本机文件」才是磁盘上的东西，两条都带"本地"必然读混。
      branchEntry(
        value: _QueuePick.localFolders,
        kind: PlaybackQueueKind.localFavorite,
        label: t.playbackQueue.favoriteFolders,
        knownEmpty: _localFolders.knownEmpty,
        icon: Icons.folder_open_outlined,
      ),
      // 「已下载」。**视频和图库各一池**（2026-09-11 起图库那一路补上了）：
      // 图库那一池一条 = 一个下载过的图库，点进去开图库详情页，见
      // `DownloadsPlaybackQueue`。
      //
      // ⛔ 这里原先有一句 `if (!_isGallery)`，理由写的是"图库即使下载过也没有
      // 离线浏览的入口"。那是把「接着看」当成了离线播放器：这一池的作用是
      // **顺着我下载过的东西往下翻**，和能不能离线看是两回事。别再加回去。
      branchEntry(
        value: _QueuePick.downloads,
        kind: PlaybackQueueKind.downloads,
        label: t.playbackQueue.downloads,
        knownEmpty: _downloadsKnownEmpty,
        icon: Icons.download_done_outlined,
      ),
      // 本机文件（扫描建库出来的源文件夹）。
      //
      // ⛔ 一个源都没加过时**整条不出现**，而不是摆一条灰的：本地库是个可选
      // 功能，绝大多数用户一个源都没有，给他们每次开菜单都多读一行没有意义。
      // 加过源的人才需要它（同"来源池没有就不摆"那条）。
      //
      // 图库这一路装的是本机**图片**（`kind = image`），点一条开大图页——与
      // 「已下载」不同，它在图库里是真的有东西可给（2026-09-11 用户要求）。
      // ⛔ `|| _playingLocalFile`：正在播的就是本机文件时这一条必须在场，哪怕
      // 源清单还没拉回来（预取是异步的）。少了它，用户从「本机文件」页点开一条
      // 视频、开抽屉，当前这一池所属的类别在菜单里**看不见**——切走就再也切不
      // 回来了。
      if (_hasLocalSources || _playingLocalFile)
        branchEntry(
          value: _QueuePick.localLibrary,
          kind: PlaybackQueueKind.localLibrary,
          label: t.playbackQueue.localFiles,
          knownEmpty: _localLibraryKnownEmpty,
          icon: Icons.devices_outlined,
        ),
      branchEntry(
        value: _QueuePick.watchLater,
        kind: PlaybackQueueKind.watchLater,
        label: t.watchLater.title,
        // 「全部」是「未看完」的超集：全部都空了，两支就都是空的。
        knownEmpty: _watchLaterKnownEmpty,
        icon: Icons.watch_later_outlined,
      ),
      // 「别人的东西」全挂在最下面，各自垫一条分隔线：上面那一片是「我的」。
      // 戴头像而不是一枚通用图标，那层归属关系才读得出来。
      //
      // ⛔ 作者的**视频和播放列表挨着摆**（用户一直要的就是这个）：作者的播放
      // 列表原来埋在「播放列表」二级菜单的第二节里，"我的"一多就再也看不见了。
      if (author != null) ...[
        const GlassMenuSeparator(),
        if (_isGallery)
          ?directEntry(
            value: _QueuePick.authorGalleries,
            kind: PlaybackQueueKind.authorGalleries,
            label: t.playbackQueue.authorGalleries,
            leading: AvatarWidget(user: author, size: 22),
            description: author.name,
          )
        else
          ?directEntry(
            value: _QueuePick.authorVideos,
            kind: PlaybackQueueKind.authorVideos,
            label: t.playbackQueue.authorVideos,
            leading: AvatarWidget(user: author, size: 22),
            description: author.name,
          ),
        ?playlistEntry(
          pick: _QueuePick.authorPlaylists,
          label: t.playbackQueue.authorPlaylists,
          leading: AvatarWidget(user: author, size: 22),
          fallbackDescription: author.name,
        ),
      ],
      if (otherOwner != null) ...[
        const GlassMenuSeparator(),
        ?playlistEntry(
          pick: _QueuePick.otherPlaylists,
          label: t.playbackQueue.otherPlaylists,
          leading: AvatarWidget(user: otherOwner, size: 22),
          fallbackDescription: otherOwner.name,
        ),
      ],
    ];

    final picked = await showGlassMenu<_QueuePick>(
      anchorContext: anchorContext,
      entries: entries,
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    switch (picked) {
      case _QueuePick.source:
        _useQueue(_queues[indexOfKind(PlaybackQueueKind.source)]);
      case _QueuePick.subscriptions:
        final queue = PlaybackQueueService.to.openSubscriptions(
          mediaType: widget.mediaType,
        );
        // 登录态是在开菜单那一刻读的，中途掉登录（401 被登出）时这里会拿到
        // null——静默什么都不做会被当成"点了没反应"，说一句。
        if (queue == null) {
          showAppToast(t.errors.pleaseLoginFirst, type: AppToastType.info);
        } else {
          _useQueue(queue);
        }
      case _QueuePick.favorites:
        _useQueue(
          _isGallery
              ? PlaybackQueueService.to.openFavoriteGalleries()
              : PlaybackQueueService.to.openFavorites(),
        );
      case _QueuePick.authorVideos:
        _useQueue(
          PlaybackQueueService.to.openAuthorVideos(
            author!.id,
            title: author.name,
          ),
        );
      case _QueuePick.authorGalleries:
        _useQueue(
          PlaybackQueueService.to.openAuthorGalleries(
            author!.id,
            title: author.name,
          ),
        );
      case _QueuePick.playlists:
      case _QueuePick.authorPlaylists:
      case _QueuePick.otherPlaylists:
        await _pickPlaylistFrom(anchorContext, picked, sources[picked]);
      case _QueuePick.localFolders:
        await _pickFromFeed(
          anchorContext,
          feed: _localFolders,
          sectionTitle: t.playbackQueue.favoriteFolders,
          onPicked: _useLocalFavorite,
          // ⛔ 判断用的串必须和登记用的串同源，否则加一个媒体后缀之后高亮就
          // 静默失效了（见 PlaybackQueueService 里那几个 id 拼法）。
          isCurrent: (id) => _isCurrentQueue(
            PlaybackQueueService.localFavoriteQueueId(
              id,
              mediaType: widget.mediaType,
            ),
          ),
        );
      case _QueuePick.downloads:
        await _pickDownloadCategory(anchorContext);
      case _QueuePick.localLibrary:
        await _pickLocalCategory(anchorContext);
      case _QueuePick.watchLater:
        await _pickWatchLaterFilter(anchorContext);
    }
  }

  /// 「播放列表」的三组：我的 / 作者的 / 他人的。
  ///
  /// ⛔ 从「一张菜单分三节」改成**三条各自的入口、各开各的第二张菜单**
  /// （2026-08-29 用户提的）：堆在一起时"我的"动辄几十行，作者的和别人的被挤到
  /// 最底下——从别人的播放列表点进来的人想切回去得滑很久，而作者的那一节干脆
  /// 没人看得见。
  Map<_QueuePick, _PlaylistSource> _playlistSources({
    required User? self,
    required User? author,
    required User? other,
  }) {
    final t = slang.t;
    // Iwara 的播放列表只收视频，图库这一路一条都不该出现。
    if (_isGallery) return const <_QueuePick, _PlaylistSource>{};
    // ⛔ 正在播的是**本机文件**时，这三条一条都不出现。
    //
    // `/light/playlists` 是必须带 `id` 的（[PlayListService.getLightPlaylists]），
    // 而本机文件手上只有 `local_media_items.id`——那是 `<源 uuid>-<路径 sha1>`，
    // Iwara 根本不认识。拿它去打接口既问了一个没有意义的问题，又把用户本机路径的
    // 摘要发了出去。
    //
    // 这与 `MyVideoStateController` 那道 `videoId == null` 闸门是同一条纪律：
    // **没有 Iwara 身份就不打 Iwara 接口**。抽屉原来绕过了那道闸门，因为它读的是
    // `widget.currentItemId` 而不是 controller 的 videoId。
    if (_playingLocalFile) return const <_QueuePick, _PlaylistSource>{};
    return <_QueuePick, _PlaylistSource>{
      if (self != null)
        _QueuePick.playlists: (
          title: t.playbackQueue.myPlaylists,
          feed: _ownPlaylists,
          owner: self,
        ),
      if (author != null && author.id != self?.id)
        _QueuePick.authorPlaylists: (
          title: t.playbackQueue.authorPlaylists,
          feed: _authorPlaylists,
          owner: author,
        ),
      if (other != null)
        _QueuePick.otherPlaylists: (
          title: t.playbackQueue.otherPlaylists,
          feed: _otherPlaylistsFeed(other),
          owner: other,
        ),
    };
  }

  /// 正开着的那张播放列表。`_useQueue` 按 kind 占槽，所以同一时刻只可能有一张。
  PlaylistPlaybackQueue? get _openPlaylist {
    for (final queue in _queues) {
      if (queue is PlaylistPlaybackQueue) return queue;
    }
    return null;
  }

  /// 正开着的那张归哪一组。取不到主人时算「我的」——总得给它留一条回头路，
  /// 否则切走之后那张列表在菜单里彻底消失。
  ///
  /// ⛔ 先比我、再比作者：自己看自己的视频时两边是同一个人，那种情况下
  /// [_playlistSources] 压根不排「作者的」那一组。
  _QueuePick? get _openPlaylistGroup {
    final queue = _openPlaylist;
    if (queue == null) return null;
    final owner = queue.owner;
    if (owner == null) return _QueuePick.playlists;
    final self = Get.find<UserService>().currentUser.value;
    if (owner.id == self?.id) return _QueuePick.playlists;
    if (owner.id == widget.author?.id) return _QueuePick.authorPlaylists;
    return _QueuePick.otherPlaylists;
  }

  /// 「已下载」确定是空的（一条可播的都没有）。查过才算数。
  bool get _downloadsKnownEmpty {
    final rows = _downloadCategories.value;
    if (rows == null) return false;
    return rows.every((row) => (row.count ?? 0) == 0);
  }

  /// 正在播的这一条是**本机文件**（`local_media_items` 里的），不是 Iwara 视频。
  ///
  /// ⛔ 判据取**进抽屉时那个池**而不是 `_current`：`_current` 会随用户在抽屉里
  /// 切池而变，但"正在播的是什么"整只抽屉的生命周期内不会变——切到「最爱」去逛
  /// 一圈并不会让播放器里那条本机文件变成 Iwara 视频。
  bool get _playingLocalFile =>
      widget.initialQueue.kind == PlaybackQueueKind.localLibrary;

  /// 「本机文件」确定是空的（源加了，但一条可播的都没扫到）。
  bool get _localLibraryKnownEmpty {
    final rows = _localSources.value;
    if (rows == null) return false;
    return rows.every((row) => (row.count ?? 0) == 0);
  }

  /// 「稍后再看」确定是空的。
  ///
  /// 只认「全部」那个池：`未看完` 是它的子集，全部空了两支就都空；反过来
  /// 「未看完」空了并不代表「全部」也空——拿它置灰会把一整类藏起来。
  bool get _watchLaterKnownEmpty {
    for (final queue in _queues) {
      if (queue is WatchLaterPlaybackQueue && !queue.unwatchedOnly) {
        return queue.isKnownEmpty;
      }
    }
    return false;
  }

  /// 二级菜单顶上那一行：**标题和返回是同一条**（`‹ 稍后再看`），下面紧跟一条
  /// 分隔线。
  ///
  /// ⛔ 原来是「返回」一行 + 小标题一行 + 选项若干，四行长得几乎一样——用户
  /// 看不出哪行是返回、哪行是标题、哪行才是能点的（2026-08-29 用户报的）。
  /// 合成一行之后：分隔线以上是"你在哪一层、点它回去"，以下才是可选的东西。
  /// 因此各二级菜单**不再单独摆一条与标题同名的 [GlassMenuSectionHeader]**，
  /// 那是在重复同一句话。
  List<GlassMenuEntry> _submenuHeader(String title) => [
    GlassMenuOption<String>(
      value: _kMenuBackValue,
      label: title,
      icon: Icons.chevron_left,
      submenuTitle: true,
    ),
    const GlassMenuSeparator(),
  ];

  /// 第二张菜单：从**某一个人**的播放列表里挑一张。
  ///
  /// ⛔ 三组各开各的（2026-08-29 用户提的）。原来是一张菜单分三节，"我的"动辄
  /// 几十行，作者的和别人的被挤到最底下——从别人的播放列表进来的人想切回去要滑
  /// 很久，作者的那一节干脆没人看得见。
  ///
  /// 「正开着的那张」即使不在拉回来的清单里也要摆出来（清单没拉回来、或者它不
  /// 在第一页），否则切走之后再也切不回来。
  Future<void> _pickPlaylistFrom(
    BuildContext anchorContext,
    _QueuePick pick,
    _PlaylistSource? source,
  ) async {
    final t = slang.Translations.of(anchorContext);
    final open = _openPlaylist;
    final bool openHere = open != null && _openPlaylistGroup == pick;

    List<_MenuChoice>? choices;
    if (source != null) {
      choices = await _fetchChoices(source.feed);
      if (!mounted || !anchorContext.mounted) return;
    }

    // 拉失败与「一张都没有」是两件事，别说成后者。两种情况下只要正开着一张就
    // 照常开菜单——至少让它回得去。
    if (!openHere) {
      if (choices == null) {
        showAppToast(t.watchLater.playlistLoadFailed, type: AppToastType.error);
        return;
      }
      if (choices.isEmpty) {
        showAppToast(t.playbackQueue.nothingHere, type: AppToastType.info);
        return;
      }
    }

    final owners = <String, User?>{};
    final titles = <String, String>{};
    final entries = <GlassMenuEntry>[
      ..._submenuHeader(source?.title ?? t.common.playList),
    ];

    final listed = {for (final choice in choices ?? const []) choice.id};
    if (openHere && !listed.contains(open.playlistId)) {
      owners[open.playlistId] = open.owner;
      titles[open.playlistId] = _playlistTitle(anchorContext, open);
      entries
        ..add(GlassMenuSectionHeader(t.playbackQueue.nowPlaying))
        ..add(
          GlassMenuOption<String>(
            value: open.playlistId,
            label: titles[open.playlistId]!,
            selected: _isCurrentQueue(open.queueId),
          ),
        );
    }

    if (source != null && choices != null && choices.isNotEmpty) {
      // 只有在「正在播放」置了顶的时候才需要这条小标题——那时菜单里有两节，
      // 得说清哪一节是哪一节；只有一节时它和上面的标题行一字不差。
      if (entries.length > 2) entries.add(GlassMenuSectionHeader(source.title));
      for (final choice in choices) {
        owners[choice.id] = source.owner;
        titles[choice.id] = choice.title;
        entries.add(
          GlassMenuOption<String>(
            value: choice.id,
            label: choice.title,
            trailing: _countLabel(choice.count),
            // ⛔ 走服务里的拼法，不手写字面量（同 PlaybackQueueService 里那段
            // 说明：判断用的串和登记用的串分头写，会静默丢高亮）。
            selected: _isCurrentQueue(
              PlaybackQueueService.playlistQueueId(choice.id),
            ),
          ),
        );
      }
    }

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: entries,
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      await _openQueuePicker(anchorContext);
      return;
    }
    _usePlaylist(picked, titles[picked] ?? '', owner: owners[picked]);
  }

  /// 第二张菜单：挑一个下载分类（全部 / 未分类 / 各自定义分类）。
  Future<void> _pickDownloadCategory(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final rows = await _loadChoices(anchorContext, _downloadCategories);
    if (rows == null || !mounted || !anchorContext.mounted) return;

    final currentFilter = _currentDownloadFilter;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        ..._submenuHeader(t.playbackQueue.downloads),
        for (final row in rows)
          GlassMenuOption<String>(
            value: row.id,
            label: row.title,
            trailing: _countLabel(row.count),
            // 计数是**这个桶里这一类的已下载条目**（见
            // `getCompletedDownloadCounts`），所以 0 就是真的点进去什么都没有。
            enabled: (row.count ?? 1) > 0,
            selected: row.id == currentFilter,
          ),
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      await _openQueuePicker(anchorContext);
      return;
    }
    final titles = {for (final row in rows) row.id: row.title};
    _useDownloads(picked, picked == 'all' ? null : titles[picked]);
  }

  /// 这一次抽屉服务的是本机**视频**还是本机**图片**。
  LocalMediaItemKind get _localItemKind =>
      _isGallery ? LocalMediaItemKind.image : LocalMediaItemKind.video;

  /// 「本机文件」的第二张菜单：**先分栏目，再往下钻**（2026-09-11 用户要求）。
  ///
  /// 原先点「本机文件」直接摊开所有来源，而「精选视频」「所有视频」「常用目录」
  /// 这几栏只在「本机文件」页的 tab 栏里有入口——在播放器里想切到"我精选的那些"
  /// 根本无路可走。两边现在对齐：这张菜单上的栏目就是那一页的 tab，同一批东西、
  /// 同一个口径（连排序和"排不排除内建「已下载」源"都一致，见
  /// `LocalLibraryPlaybackQueue.fetchPage` 上那段说明）。
  ///
  /// ⛔ 栏目按媒体类型分家：视频那一路不摆「所有图片」，图库那一路不摆「精选视频」
  /// （精选今天只对视频开放）。摆一条点进去恒为空的项比不摆更糟。
  ///
  /// ⛔ 这里**不摆「下载完成视频/图库」**，尽管页面上有那两个 tab：抽屉顶层已经
  /// 有一条「已下载」（`PlaybackQueueKind.downloads`，按 media_id 去重、带下载
  /// 分类）。两条同名不同数的条目并排站着，用户没有任何办法分辨该点哪一个。
  /// 菜单行尾那个数。
  ///
  /// ⛔ **一律压短**，不要直接 `'$count'`。本机目录动辄几千上万条，一个
  /// 「12345」会把行尾那一格撑到把标题挤成省略号——菜单面板有宽度上限，行尾多
  /// 占一分，标题就少一分。压成「1.2万 / 12k」之后，再大的库也只占五六个字符。
  ///
  /// 机制那一头在 `glass_menu.dart` 的 `_maxTrailingWidth`（不管来的是什么都
  /// 封顶），这里是约定那一头：让数字**本来就短**，好过让它被截断。
  static String? _countLabel(int? count) =>
      count == null ? null : CommonUtils.formatFriendlyNumber(count);

  /// 正开着的池是不是「本机文件 › 所有视频 / 精选视频」这两栏之一。
  ///
  /// # ⛔ 按**形状**比，不比 queueId
  ///
  /// 这两条原先拿 `_isCurrentQueue(localLibraryQueueId(sort: nameAsc, …))` 比，
  /// 也就是**连排序一起比**。可用户是从「本机文件」页那几栏点进来的，那几栏的
  /// 排序是他自己在栏目顶上现选的（按时长、按分辨率、按帧率…，见
  /// `LocalMediaWall.order`），拼出来的 id 几乎不可能正好等于 `nameAsc` 那一条
  /// ——结果就是：明明正在放「所有视频」里的一条，菜单里那一行却不亮，用户在
  /// 抽屉里找不到自己在哪一层。
  ///
  /// 排序是**池身份**的一部分（这条不变，池的顺序就是"接下来播什么"），但它不是
  /// **栏目身份**的一部分：按哪个字段排都还是同一栏。所以这里只比"装的是哪一批"
  /// ——不限源、不限目录、精不精选。目录 / 常用目录 / 来源那几条一直就是这么比的
  /// （`openHere.sourceId == row.id`、`openPath == rows[i].path`），这两条是漏网的。
  bool _isCurrentLocalCategory({bool favoritedOnly = false}) {
    final open = _current;
    return open is LocalLibraryPlaybackQueue &&
        open.sourceId == null &&
        open.folderPath == null &&
        open.categoryId == null &&
        open.favoritedOnly == favoritedOnly;
  }

  Future<void> _pickLocalCategory(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final repository = LocalMediaRepository();
    var allCount = 0;
    var favCount = 0;
    var pinnedCount = 0;
    try {
      // ⛔ `excludeBuiltInSource` 必须跟池里那一行同真同假，否则菜单上写的数和
      // 点进去那一池的条数对不上。
      allCount = repository.countItems(
        kind: _localItemKind,
        excludeBuiltInSource: true,
      );
      if (!_isGallery) {
        favCount = repository.countItems(
          kind: _localItemKind,
          favoritedOnly: true,
        );
      }
      pinnedCount = repository.getPinnedFolders().length;
    } catch (e) {
      LogUtils.w('读取本机栏目计数失败: $e', 'PlaybackQueueDrawer');
    }

    final open = _current;
    final openHere = open is LocalLibraryPlaybackQueue ? open : null;

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        ..._submenuHeader(t.playbackQueue.localFiles),
        GlassMenuOption<String>(
          value: _kLocalCatFolders,
          label: t.localMedia.tabFolders,
          icon: Icons.folder_outlined,
          trailing: _kSubmenuChevron,
          // 目录本身不是池，被选中的是它里面某一层。
          selected: openHere != null && openHere.folderPath != null,
          showCheck: false,
        ),
        // 常用目录一个都没置顶时整条不出现：点进去是一张空菜单，而空菜单上
        // 没有地方解释"去哪儿才能把一个目录设成常用"。
        if (pinnedCount > 0)
          GlassMenuOption<String>(
            value: _kLocalCatPinned,
            label: t.localMedia.browse.pinnedSection,
            icon: Icons.push_pin_outlined,
            trailing: '${_countLabel(pinnedCount)} $_kSubmenuChevron',
            showCheck: false,
          ),
        const GlassMenuSeparator(),
        if (!_isGallery)
          GlassMenuOption<String>(
            value: _kLocalCatFavorites,
            label: t.localMedia.tabFavoriteVideos,
            icon: Icons.star_outline,
            trailing: _countLabel(favCount),
            enabled: favCount > 0,
            selected: _isCurrentLocalCategory(favoritedOnly: true),
          ),
        GlassMenuOption<String>(
          value: _kLocalCatAll,
          label: _isGallery
              ? t.localMedia.tabAllImages
              : t.localMedia.tabAllVideos,
          icon: _isGallery
              ? Icons.photo_library_outlined
              : Icons.video_library_outlined,
          trailing: _countLabel(allCount),
          enabled: allCount > 0,
          selected: _isCurrentLocalCategory(),
        ),
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    switch (picked) {
      case _kMenuBackValue:
        await _openQueuePicker(anchorContext);
      case _kLocalCatFolders:
        await _pickLocalSource(anchorContext);
      case _kLocalCatPinned:
        await _pickLocalPinned(anchorContext);
      case _kLocalCatFavorites:
        _useLocalLibrary(
          favoritedOnly: true,
          title: t.localMedia.tabFavoriteVideos,
        );
      case _kLocalCatAll:
        _useLocalLibrary(
          title: _isGallery
              ? t.localMedia.tabAllImages
              : t.localMedia.tabAllVideos,
        );
    }
  }

  /// 「常用目录」那一栏：用户置顶过的那几个目录，点一个直接建池。
  ///
  /// ⛔ 建出来的池与从「文件目录」一层层走下去点到同一个目录时**是同一个池**
  /// （同 sourceId、同 folderPath、同 nameAsc 排序）——常用目录只是一条捷径，
  /// 不是另一种池。两边要是拼出不同的 id，用户从捷径进去之后，目录菜单里那一
  /// 行不会亮。
  Future<void> _pickLocalPinned(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final repository = LocalMediaRepository();
    final rows = <({String sourceId, String? path, String name, int count})>[];
    try {
      for (final pin in repository.getPinnedFolders()) {
        final folder = repository.getFolder(
          sourceId: pin.sourceId,
          relPath: pin.relPath,
        );
        final path = folder?.folderPath;
        if (path == null || path.isEmpty) {
          // ⛔ 查不到目录行**不等于**这条置顶没用了。
          //
          // 「已下载」和「设备视频」一行 `local_media_folders` 都不写（没有真实
          // 目录树），而来源根现在是可以设为常用的。这里原来一律 `continue`，
          // 结果就是：用户明明置顶了「已下载」，接着看的「常用目录」里却一条都
          // 没有——而且不报错，纯粹静默消失。
          //
          // 根那一层退化成「整个源」（`folderPath` 传 null），与 [_pickLocalFolder]
          // 对平铺源的处理同一个口径。更深的一层查不到目录行才是真的出了问题。
          if (pin.relPath.isNotEmpty) continue;
          if (repository.getSource(pin.sourceId) == null) continue;
          rows.add((
            sourceId: pin.sourceId,
            path: null,
            name: pin.displayName,
            count: repository.countItems(
              sourceId: pin.sourceId,
              kind: _localItemKind,
            ),
          ));
          continue;
        }
        rows.add((
          sourceId: pin.sourceId,
          path: path,
          name: pin.displayName,
          count: repository.countItems(
            sourceId: pin.sourceId,
            folderPath: path,
            kind: _localItemKind,
          ),
        ));
      }
    } catch (e) {
      LogUtils.w('读取常用目录失败: $e', 'PlaybackQueueDrawer');
      if (mounted) {
        showAppToast(
          slang.t.watchLater.queueLoadFailed,
          type: AppToastType.error,
        );
      }
      return;
    }
    if (!mounted || !anchorContext.mounted) return;

    final open = _current;
    final openHere = open is LocalLibraryPlaybackQueue ? open : null;
    final openPath = openHere?.folderPath;

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: <GlassMenuEntry>[
        ..._submenuHeader(t.localMedia.browse.pinnedSection),
        for (var i = 0; i < rows.length; i++)
          GlassMenuOption<String>(
            value: '$i',
            label: rows[i].name,
            // 退化成「整个源」的那一条（见上面）戴来源图标，别装成一个目录。
            icon: rows[i].path == null
                ? Icons.devices_outlined
                : Icons.folder_outlined,
            trailing: _countLabel(rows[i].count),
            // 这一栏里一条都没有的目录点进去是空池，置灰（同来源清单那条）。
            enabled: rows[i].count > 0,
            selected: rows[i].path == null
                ? (openHere != null &&
                      openHere.sourceId == rows[i].sourceId &&
                      openPath == null)
                : (openPath != null && openPath == rows[i].path),
          ),
        if (rows.isEmpty)
          GlassMenuOption<String>(
            value: _kLocalNothingHere,
            label: t.playbackQueue.nothingHere,
            enabled: false,
          ),
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      await _pickLocalCategory(anchorContext);
      return;
    }
    if (picked == _kLocalNothingHere) return;
    final index = int.tryParse(picked);
    if (index == null || index < 0 || index >= rows.length) return;
    final row = rows[index];
    _useLocalLibrary(
      sourceId: row.sourceId,
      folderPath: row.path,
      title: row.name,
    );
  }

  /// 第二张菜单：挑一个本机来源，点进去**逐层往下走目录**。
  ///
  /// # ⛔ 一个池 = 一个目录，不含子目录
  ///
  /// 原来这一层点一个源，建出来的池是**整个源递归摊平**的——用户在菜单里点的是
  /// 一个看得见的目录名，拿回来的却是它底下所有层的东西混在一起。目录结构是用户
  /// 自己整理出来的（一季一个文件夹），摊平等于把这份整理丢掉；千级条目的源还要
  /// 为此翻整张表。2026-09-11 用户明确要求：**点哪个目录就是哪个目录**。
  ///
  /// 所以这里只剩"挑源"，真正建池的动作全在 [_pickLocalFolder] 里，一层一张菜单。
  Future<void> _pickLocalSource(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final rows = await _loadChoices(anchorContext, _localSources);
    if (rows == null || !mounted || !anchorContext.mounted) return;

    final open = _current;
    final openHere = open is LocalLibraryPlaybackQueue ? open : null;
    final folder = _currentFolderChoice();

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        ..._submenuHeader(t.playbackQueue.localFiles),
        for (final row in rows)
          GlassMenuOption<String>(
            value: row.id,
            label: row.title,
            // 这个数是**整个源里有多少条**，不是点进去那一池的条数（那一池只装
            // 某一个目录）。它在这儿的作用只有一个：0 就是这个源里一条都没有，
            // 点进去是死路。
            trailing: row.count == null
                ? _kSubmenuChevron
                : '${_countLabel(row.count)} $_kSubmenuChevron',
            enabled: (row.count ?? 1) > 0,
            selected: openHere != null && openHere.sourceId == row.id,
            // 源本身不是池，真正被选中的那个目录在下一张菜单里。
            showCheck: false,
          ),
        // 「当前文件所在文件夹」：条件出现，见 [_currentFolderChoice]。
        if (folder != null) ...[
          const GlassMenuSeparator(),
          GlassMenuOption<String>(
            value: '$_kLocalFolderPrefix${folder.path}',
            label: folder.name,
            description: t.playbackQueue.currentFolder,
            trailing: _countLabel(folder.count),
            selected: openHere?.folderPath == folder.path,
          ),
        ],
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      // 上一层现在是栏目菜单，不再是顶层池清单。见 [_pickLocalCategory]。
      await _pickLocalCategory(anchorContext);
      return;
    }
    if (picked.startsWith(_kLocalFolderPrefix)) {
      final path = picked.substring(_kLocalFolderPrefix.length);
      _useLocalLibrary(
        sourceId: folder?.sourceId,
        folderPath: path,
        title: folder?.name,
      );
      return;
    }
    final titles = {for (final row in rows) row.id: row.title};
    await _pickLocalFolder(
      anchorContext,
      sourceId: picked,
      rootTitle: titles[picked] ?? t.playbackQueue.localFiles,
    );
  }

  /// 第三张（以及更深的每一张）菜单：某一个目录。
  ///
  /// 一张菜单只说两件事：
  ///
  ///   - **查看本目录下的视频池 / 图库池**——直属于这个目录的那些文件，就是一池
  ///     （不含子目录）；两条文案按媒体类型二选一，见下面的 `_isGallery`；
  ///   - 下面列它的**直接子目录**，点进去开下一张同样的菜单。
  ///
  /// ⛔ 子目录里已经没有更下一层时**直接建池**，不再多开一张只有一行的菜单：
  /// 那一行说的话和刚点的那一行一字不差，纯粹是多一次点击。
  ///
  /// # ⛔ 用循环 + 一根显式的栈走，不许递归调用自己
  ///
  /// 玻璃菜单是**一张替一张**开的，"返回上一层"在这里只是再开一张菜单而已。写成
  /// 递归的话，返回并不出栈：`await 子菜单 → 里面又 await 父菜单`，用户在两层之间
  /// 来回点几次，挂起的栈帧（连同各自那份目录清单和 BuildContext）就一直往上叠，
  /// 直到整趟菜单结束才一次性收掉。这里的 [trail] 就是那根栈，进一层压一条、返回
  /// 一层弹一条，深度永远等于用户所在的层数。
  Future<void> _pickLocalFolder(
    BuildContext anchorContext, {
    required String sourceId,
    required String rootTitle,
  }) async {
    final t = slang.Translations.of(anchorContext);
    // 走过的上层：每条是 (相对路径, 菜单标题)。空 = 现在就在源根，再返回就回源清单。
    final trail = <({String relPath, String title})>[];
    var relPath = '';
    var title = rootTitle;

    while (true) {
      final level = await _loadLocalLevel(sourceId: sourceId, relPath: relPath);
      if (level == null || !mounted || !anchorContext.mounted) return;
      final folder = level.folder;
      final children = level.children;
      final hereCount = level.hereCount;
      final flatSource = level.flatSource;

      final open = _current;
      final openHere = open is LocalLibraryPlaybackQueue ? open : null;
      final openPath = openHere?.folderPath;
      final herePath = folder?.folderPath;
      final canPlayHere = hereCount > 0 && (flatSource || herePath != null);

      final picked = await showGlassMenu<String>(
        anchorContext: anchorContext,
        entries: <GlassMenuEntry>[
          ..._submenuHeader(title),
          if (canPlayHere)
            GlassMenuOption<String>(
              value: _kLocalPlayHere,
              // 平铺的源没有"本目录"这回事，那一行说的是整个源。
              label: flatSource
                  ? t.common.all
                  : (_isGallery
                        ? t.playbackQueue.browseThisFolder
                        : t.playbackQueue.playThisFolder),
              icon: _isGallery
                  ? Icons.photo_library_outlined
                  : Icons.play_arrow_rounded,
              trailing: _countLabel(hereCount),
              selected: flatSource
                  ? (openHere != null &&
                        openHere.sourceId == sourceId &&
                        openPath == null)
                  : (openPath != null && openPath == herePath),
            ),
          if (canPlayHere && children.isNotEmpty) const GlassMenuSeparator(),
          for (final child in children)
            GlassMenuOption<String>(
              value: '$_kLocalChildPrefix${child.relPath}',
              label: child.name,
              trailing: _localFolderTrailing(child),
              // 展开过的那一层高亮，但不打勾：被选中的是里面某一个目录。
              selected: _localFolderOnPath(child, openPath),
              showCheck: _localFolderIsOpen(child, openPath),
            ),
          // 走到一个什么都没有的目录：说一句，而不是弹一张只有标题的空菜单。
          //
          // ⚠️ 这一行是**够得着的**：`child_folder_count` 不分媒体类型，所以
          // "子树里只有图片"的目录在视频菜单里照样带箭头，点进来才发现没东西
          // （见 `LocalMediaRepository.childFolders` 的说明）。分媒体类型传播那
          // 三个计数才能根治，代价比收益大。
          if (!canPlayHere && children.isEmpty)
            GlassMenuOption<String>(
              value: _kLocalNothingHere,
              label: t.playbackQueue.nothingHere,
              enabled: false,
            ),
        ],
      );
      if (picked == null || !mounted || !anchorContext.mounted) return;
      if (picked == _kMenuBackValue) {
        // 源根这一层的上一层是源清单；再深就是弹一条走一层。
        if (trail.isEmpty) {
          await _pickLocalSource(anchorContext);
          return;
        }
        final back = trail.removeLast();
        relPath = back.relPath;
        title = back.title;
        continue;
      }
      if (picked == _kLocalNothingHere) return;
      if (picked == _kLocalPlayHere) {
        _useLocalLibrary(
          sourceId: sourceId,
          folderPath: flatSource ? null : herePath,
          title: folder?.name ?? title,
        );
        return;
      }
      final childRelPath = picked.substring(_kLocalChildPrefix.length);
      final child = children.firstWhereOrNull((f) => f.relPath == childRelPath);
      if (child == null) return;
      final childPath = child.folderPath;
      final childCount = _isGallery ? child.imageCount : child.videoCount;
      // 没有下一层、而且这一层确实有东西 → 就是它了，不必再问一次。
      if (child.childFolderCount == 0 && childCount > 0 && childPath != null) {
        _useLocalLibrary(
          sourceId: sourceId,
          folderPath: childPath,
          title: child.name,
        );
        return;
      }
      trail.add((relPath: relPath, title: title));
      relPath = child.relPath;
      title = child.name;
    }
  }

  /// 读一层目录：需要时**先把这一层真的列一遍**（懒扫描），再从库里读。
  ///
  /// ⛔ 那次懒扫描不能省。`probed_at IS NULL` 的意思是"这一层从来没被列出来看过"，
  /// 三个计数此刻全是 0——不扫就读的话，一个其实装满了片子的目录会被这张菜单说成
  /// 「暂无内容」（目录浏览页进一层就扫一次，正是为了这个；两边不一致时用户看到的
  /// 就是"浏览页里点进去有东西、接着看里点进去是空的"）。
  ///
  /// 等待期间胶囊左边转一枚小弧（[_loadingChoices] → `GlassInlineBusy`）：玻璃
  /// 菜单开出来之后改不了行，所以这一步必须在开菜单**之前**做完。
  ///
  /// 返回 null = 读库出错（已经报过），调用方停手。
  Future<
    ({
      LocalMediaFolder? folder,
      List<LocalMediaFolder> children,
      int hereCount,
      bool flatSource,
    })?
  >
  _loadLocalLevel({required String sourceId, required String relPath}) async {
    try {
      final repository = LocalMediaRepository();
      var folder = repository.getFolder(sourceId: sourceId, relPath: relPath);
      if (folder != null &&
          folder.probedAt == null &&
          Get.isRegistered<LocalMediaScanService>()) {
        final source = repository.getSource(sourceId);
        if (source != null) {
          setState(() => _loadingChoices = true);
          try {
            await LocalMediaScanService.to.scanFolder(
              source: source,
              relPath: relPath,
            );
          } catch (e) {
            // 扫不动就按现有的库存往下走：菜单可能是空的，但不该整个点不开。
            LogUtils.w('目录级扫描失败: $e', 'PlaybackQueueDrawer');
          } finally {
            if (mounted) setState(() => _loadingChoices = false);
          }
          if (!mounted) return null;
          folder = repository.getFolder(sourceId: sourceId, relPath: relPath);
        }
      }
      final children = repository.childFolders(
        sourceId: sourceId,
        parentRelPath: relPath,
        mediaKind: _localItemKind,
      );
      // 这个源**没有目录树**（系统媒体索引那一类：`_scanMediaStoreSource` 只写
      // 条目，一行 `local_media_folders` 都不写）。那儿本来就没有"用户整理出来的
      // 目录"可分，整个源就是一层——与目录浏览页在同一情形下的退化一致（它那边
      // `folderPath` 传 null 就是整源平铺）。
      //
      // ⛔ 只在源根这一层退化：更深的一层查不到目录行是真的出了问题，不能悄悄把
      // 整个源端上来。
      final flatSource = folder == null && relPath.isEmpty && children.isEmpty;
      final path = folder?.folderPath;
      final hereCount = flatSource
          ? repository.countItems(sourceId: sourceId, kind: _localItemKind)
          : (path == null || path.isEmpty
                ? 0
                : repository.countItems(
                    sourceId: sourceId,
                    folderPath: path,
                    kind: _localItemKind,
                  ));
      return (
        folder: folder,
        children: children,
        hereCount: hereCount,
        flatSource: flatSource,
      );
    } catch (e) {
      LogUtils.w('读取本机目录失败: $e', 'PlaybackQueueDrawer');
      if (mounted) {
        showAppToast(
          slang.t.watchLater.queueLoadFailed,
          type: AppToastType.error,
        );
      }
      return null;
    }
  }

  /// 目录行的行尾：本目录直属条数 +（还有下一层时）一枚 `›`。
  ///
  /// 计数列是扫描收尾时回填的，还没探过的目录一律是 0——那时只画箭头，不写一个
  /// 会骗人的「0」。
  String? _localFolderTrailing(LocalMediaFolder folder) {
    final drill = folder.childFolderCount > 0;
    final count = _isGallery ? folder.imageCount : folder.videoCount;
    final text = folder.probedAt != null && count > 0 ? '$count' : null;
    if (!drill) return text;
    return text == null ? _kSubmenuChevron : '$text $_kSubmenuChevron';
  }

  /// 正开着的那一池就是这个目录。
  bool _localFolderIsOpen(LocalMediaFolder folder, String? openPath) {
    final path = folder.folderPath;
    return path != null && openPath != null && openPath == path;
  }

  /// 正开着的那一池在这个目录**里面**（含它自己）：这一行要高亮，指路用。
  bool _localFolderOnPath(LocalMediaFolder folder, String? openPath) {
    final path = folder.folderPath;
    if (path == null || openPath == null) return false;
    return openPath == path || openPath.startsWith('$path${p.separator}');
  }

  /// 正在播的这条本机文件所在的文件夹，值得单独摆一条时才返回非 null。
  ///
  /// ⛔ 出现条件是**它得比整个源更小、又不止一条**（工作线文档 §3.3）：
  /// 只有一条时点进去等于单曲循环；等于整个源时它和上面那一行一模一样。
  /// 两种情况下摆出来都只是噪音。
  ({String sourceId, String path, String name, int count})?
  _currentFolderChoice() {
    final queue = _current;
    if (queue is! LocalLibraryPlaybackQueue) return null;
    try {
      final repository = LocalMediaRepository();
      final item = repository.getItem(widget.currentItemId);
      final path = item?.folderPath;
      if (item == null || path == null || path.isEmpty) return null;
      final counts = repository.folderCounts(
        item.sourceId,
        kind: _localItemKind,
      );
      final here = counts.firstWhereOrNull((row) => row.folderPath == path);
      if (here == null || here.count < 2) return null;
      // 这个源只有这一个文件夹 → 它就是整个源，别重复摆一条。
      if (counts.length < 2) return null;
      return (
        sourceId: item.sourceId,
        path: path,
        name: p.basename(path),
        count: here.count,
      );
    } catch (e) {
      LogUtils.w('取当前文件夹失败: $e', 'PlaybackQueueDrawer');
      return null;
    }
  }

  /// 本机文件的源清单。
  ///
  /// ⛔ 条数**另查一次真数**（`countItems`），不能用 `local_media_sources.item_count`：
  /// 那一列是上次扫描结束时写的快照，含图片、也不排除 missing，而池里只装
  /// "可播的视频"。两个数对不上，菜单就会写着「12」而点进去是 3 条。
  Future<List<_MenuChoice>?> _fetchLocalSources() async {
    try {
      final repository = LocalMediaRepository();
      // ⛔ 内建的「已下载」不进这张清单：抽屉里**已经有**一条同名的「已下载」
      // （走 `PlaybackQueueKind.downloads`，按 media_id 去重、带下载分类）。
      // 两条同名不同数的条目并排站着，用户没有任何办法分辨该点哪一个。
      // 等 §10.6 把下载页拆完、两条并成一条时再放开。
      final sources = repository
          .getSources()
          .where((s) => !s.isBuiltIn)
          .toList();
      if (sources.isEmpty) return const <_MenuChoice>[];
      // ⛔ 没有「全部源」那一行了：它建出来的是一池**跨源递归摊平**的东西，正是
      // 2026-09-11 用户要求去掉的那种池（见 [_pickLocalSource]）。源这一层现在
      // 只是通往目录树的入口。
      return <_MenuChoice>[
        for (final source in sources)
          (
            id: source.id,
            title: source.displayName,
            count: repository.countItems(
              sourceId: source.id,
              kind: _localItemKind,
            ),
          ),
      ];
    } catch (e) {
      // 库还没建好 / 读库出错：返回 null（= 失败），与"一个源都没有"是两件事。
      LogUtils.w('读取本机来源失败: $e', 'PlaybackQueueDrawer');
      return null;
    }
  }

  /// **正在播的**那个池如果是下载池，它是哪个分类；否则 null。
  ///
  /// ⛔ 不能扫 `_queues` 找"开着的那个下载池"，更不能没找到就退回 `'all'`：
  /// 那样正在看「最爱」的时候点进「已下载」，「全部」那一行会平白打上勾——
  /// 说的是"你正在播这一支"，而其实没有（2026-08-29 用户报的）。
  String? get _currentDownloadFilter {
    final queue = _current;
    return queue is DownloadsPlaybackQueue ? queue.categoryFilter : null;
  }

  /// 第二张菜单：稍后再看的「全部 / 未看完」。
  ///
  /// 筛选是池身份的一部分（`watchLater:all` / `watchLater:unwatched` 是两个
  /// 池），所以它是"换一个池"而不是"给当前池加个过滤"。
  Future<void> _pickWatchLaterFilter(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final isCurrent = _current.kind == PlaybackQueueKind.watchLater;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        ..._submenuHeader(t.watchLater.title),
        GlassMenuOption<String>(
          value: 'all',
          label: t.watchLater.filterAll,
          selected: isCurrent && !_unwatchedOnly,
        ),
        GlassMenuOption<String>(
          value: 'unwatched',
          label: t.watchLater.filterUnwatched,
          selected: isCurrent && _unwatchedOnly,
        ),
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      await _openQueuePicker(anchorContext);
      return;
    }
    _useWatchLater(unwatchedOnly: picked == 'unwatched');
  }

  bool _isCurrentQueue(String queueId) => _current.queueId == queueId;

  String _queueTitle(
    BuildContext context,
    PlaybackQueue queue,
    String fallback,
  ) {
    final title = queue.title?.trim();
    return title == null || title.isEmpty ? fallback : title;
  }

  void _useWatchLater({required bool unwatchedOnly}) {
    _useQueue(
      PlaybackQueueService.to.openWatchLater(
        unwatchedOnly: unwatchedOnly,
        mediaType: widget.mediaType,
      ),
      unwatchedOnly: unwatchedOnly,
    );
  }

  /// 换到某一张播放列表上。[owner] 知道就带上——省掉池自己再去问一次
  /// `/playlist/{id}`（见 `PlaylistPlaybackQueue` 的构造函数）。
  void _usePlaylist(String playlistId, String title, {User? owner}) {
    _useQueue(
      PlaybackQueueService.to.openPlaylist(
        playlistId,
        title: title,
        owner: owner,
      ),
    );
  }

  void _useLocalFavorite(String folderId, String title) {
    _useQueue(
      PlaybackQueueService.to.openLocalFavorite(
        folderId,
        title: title,
        mediaType: widget.mediaType,
      ),
    );
  }

  /// 换到本机文件池上去。
  ///
  /// ⛔ 排序固定 `nameAsc`（自然序）：本机文件多半是一整季/一整套躺在同一个
  /// 目录里，"接下来播哪一条"用户期待的就是**第 2 集接第 3 集**。按添加时间
  /// 排会给出一个看上去随机的顺序。排序是池身份的一部分，见
  /// `PlaybackQueueService.localLibraryQueueId`。
  void _useLocalLibrary({
    String? sourceId,
    String? folderPath,
    bool favoritedOnly = false,
    String? title,
  }) {
    _useQueue(
      PlaybackQueueService.to.openLocalLibrary(
        sourceId: sourceId,
        folderPath: folderPath,
        sort: LocalMediaSort.nameAsc,
        // 图库这一路装的是本机**图片**，落点是大图页（见 PlaybackQueueNavigator）。
        mediaType: widget.mediaType,
        favoritedOnly: favoritedOnly,
        title: title,
      ),
    );
  }

  void _useDownloads(String categoryFilter, String? title) {
    _useQueue(
      PlaybackQueueService.to.openDownloads(
        categoryFilter: categoryFilter,
        // 图库那一路装的是已下载的**图库**，落点是图库详情页。它同时进 id，
        // 见 `PlaybackQueueService.downloadsQueueId`。
        mediaType: widget.mediaType,
        title: title,
      ),
    );
  }

  /// 下载分类清单。
  ///
  /// ⛔ 条数**不能用 `DownloadCategory.itemCount`**：那是这个分类下**所有**任务
  /// （不分媒体类型、含下载中/失败）的条数，而池里只装「已完成的某一类、按
  /// media_id 去重」。两个数对不上，菜单就会写着「5」而点进去是空的。
  Future<List<_MenuChoice>?> _fetchDownloadCategories() async {
    final t = slang.t;
    final service = DownloadService.to;
    // ⛔ 数的桶必须和列的池是同一种媒体，否则视频那一列的数会跑到图库菜单上。
    final counts = await service.repository.getCompletedDownloadCounts(
      mediaType: _isGallery ? 'gallery' : 'video',
    );
    final categories = await service.getAllCategories();
    return <_MenuChoice>[
      (id: 'all', title: t.common.all, count: counts.total),
      // 「未分类」只在真有分类时才有意义——一个分类都没有时它等同「全部」，
      // 摆出来只是让人多读一行（下载列表页也是这么判的）。
      if (categories.isNotEmpty)
        (
          id: 'uncategorized',
          title: t.download.category.uncategorized,
          count: counts.uncategorized,
        ),
      for (final category in categories)
        (
          id: category.id,
          title: category.title,
          count: counts.byCategory[category.id] ?? 0,
        ),
    ];
  }

  /// 取一份清单，等待期间把 loading 画在胶囊上。**不提示**——拿到 null（失败）
  /// 还是空表由调用方决定怎么说，播放列表那条路上"没拉到"未必就该报错
  /// （正开着的那张还得摆出来，见 [_pickPlaylistFrom]）。
  Future<List<_MenuChoice>?> _fetchChoices(_MenuFeed feed) async {
    if (!feed.ready) setState(() => _loadingChoices = true);
    List<_MenuChoice>? choices;
    try {
      choices = await feed.get();
    } catch (e) {
      // 请求层一般只用 ApiResult 表达失败，抛出来的是意料之外的那种；
      // 一样按"失败"处理，别让它冒到 zone 里变成一条红字。
      LogUtils.e('拉取清单抛异常', tag: 'PlaybackQueueDrawer', error: e);
      choices = null;
    }
    if (!mounted) return null;
    if (_loadingChoices) setState(() => _loadingChoices = false);
    return choices;
  }

  /// [_fetchChoices] 加上「失败 / 空」两句提示。清单类的二级菜单都走它。
  Future<List<_MenuChoice>?> _loadChoices(
    BuildContext anchorContext,
    _MenuFeed feed,
  ) async {
    final t = slang.Translations.of(anchorContext);
    final choices = await _fetchChoices(feed);
    if (!mounted || !anchorContext.mounted) return null;

    if (choices == null) {
      showAppToast(t.watchLater.playlistLoadFailed, type: AppToastType.error);
      return null;
    }
    if (choices.isEmpty) {
      // 空的这次会提示，**下次开菜单那一条就是灰的了**——feed 已经知道答案。
      showAppToast(t.playbackQueue.nothingHere, type: AppToastType.info);
      return null;
    }
    return choices;
  }

  Future<List<_MenuChoice>?> _fetchLocalFolders() async {
    final folders = await FavoriteService.to.getAllFolders();
    return [
      for (final folder in folders)
        (id: folder.id, title: folder.title, count: folder.itemCount ?? 0),
    ];
  }

  /// 拉「我的播放列表」。返回 null = 请求失败（与"一张都没有"是两件事）。
  Future<List<_MenuChoice>?> _fetchOwnPlaylists() async {
    final result = await Get.find<PlayListService>().getLightPlaylists(
      videoId: widget.currentItemId,
    );
    if (!result.isSuccess || result.data == null) {
      LogUtils.w('拉取自己的播放列表失败', 'PlaybackQueueDrawer');
      return null;
    }
    return [
      for (final playlist in result.data!)
        (id: playlist.id, title: playlist.title, count: playlist.numVideos),
    ];
  }

  /// 拉「作者的播放列表」。
  ///
  /// 别人的播放列表只有分页接口（lite 那条的入参是 videoId、只返回自己的）。
  /// 抽屉里先取第一页；真要翻更多，作者主页有完整列表。
  Future<List<_MenuChoice>?> _fetchAuthorPlaylists() async {
    final owner = widget.author;
    if (owner == null) return const [];
    return _fetchPlaylistsOf(owner.id);
  }

  /// 拉某个人的播放列表（第一页）。「作者的」和「他人的」共用同一条。
  Future<List<_MenuChoice>?> _fetchPlaylistsOf(String userId) async {
    final result = await Get.find<PlayListService>().getPlaylists(
      userId: userId,
      page: 0,
    );
    if (!result.isSuccess || result.data == null) {
      LogUtils.w('拉取播放列表失败：$userId', 'PlaybackQueueDrawer');
      return null;
    }
    return [
      for (final playlist in result.data!.results)
        (id: playlist.id, title: playlist.title, count: playlist.numVideos),
    ];
  }

  /// 开出第二张菜单：某一份清单（播放列表 / 本地收藏夹）。
  ///
  /// 预取没回来就用胶囊上的沙漏顶着等（[_loadingChoices]），**不**静默 return
  /// ——用户点了什么都不发生，分不清"没有内容"还是"网炸了"。
  Future<void> _pickFromFeed(
    BuildContext anchorContext, {
    required _MenuFeed feed,
    required String sectionTitle,
    required void Function(String id, String title) onPicked,
    required bool Function(String id) isCurrent,
  }) async {
    final choices = await _loadChoices(anchorContext, feed);
    if (choices == null || !mounted || !anchorContext.mounted) return;

    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        ..._submenuHeader(sectionTitle),
        for (final choice in choices)
          GlassMenuOption<String>(
            value: choice.id,
            label: choice.title,
            // ⛔ 夹子里的条数是**所有类型**加起来的（视频 + 图库 + 用户），
            // 而池只装其中一种。图库这一路写出来会和点进去看到的对不上，
            // 干脆不写（下载分类那边同一个坑，那儿是另查了一份真数）。
            trailing: _isGallery ? null : _countLabel(choice.count),
            selected: isCurrent(choice.id),
          ),
      ],
    );
    if (picked == null || !mounted || !anchorContext.mounted) return;
    if (picked == _kMenuBackValue) {
      await _openQueuePicker(anchorContext);
      return;
    }
    final titles = {for (final choice in choices) choice.id: choice.title};
    onPicked(picked, titles[picked] ?? '');
  }

  String _playlistTitle(BuildContext context, PlaybackQueue queue) {
    final title = queue.title?.trim();
    return title == null || title.isEmpty
        ? slang.Translations.of(context).common.playList
        : title;
  }

  /// 胶囊上那行字：当前在哪个池里。稍后再看还要带上筛选——「全部」和
  /// 「未看完」是两批不同的东西，只写"稍后再看"看不出接下来会连播哪一批。
  String _pillLabel(BuildContext context) {
    final t = slang.Translations.of(context);
    final label = switch (_current.kind) {
      PlaybackQueueKind.source => t.playbackQueue.sourceTab,
      PlaybackQueueKind.subscriptions => t.common.subscriptions,
      PlaybackQueueKind.playlist => _playlistTitle(context, _current),
      PlaybackQueueKind.authorVideos => _queueTitle(
        context,
        _current,
        t.playbackQueue.authorVideos,
      ),
      PlaybackQueueKind.authorGalleries => _queueTitle(
        context,
        _current,
        t.playbackQueue.authorGalleries,
      ),
      PlaybackQueueKind.favorites => t.common.favorites,
      PlaybackQueueKind.localFavorite => _queueTitle(
        context,
        _current,
        t.favorite.localizeFavorite,
      ),
      // 下载池带上分类名：「已下载」和「已下载 · 音乐」是两批不同的东西，
      // 只写前者看不出接下来会连播哪一批（同稍后再看的筛选）。
      PlaybackQueueKind.downloads =>
        _current.title?.trim().isNotEmpty == true
            ? '${t.playbackQueue.downloads} · ${_current.title!.trim()}'
            : t.playbackQueue.downloads,
      // 本机文件同理带上源名：「本机文件」和「本机文件 · Movies」是两批不同的
      // 东西（用户可能加了好几个源）。
      PlaybackQueueKind.localLibrary =>
        _current.title?.trim().isNotEmpty == true
            ? '${t.playbackQueue.localFiles} · ${_current.title!.trim()}'
            : t.playbackQueue.localFiles,
      PlaybackQueueKind.watchLater =>
        _unwatchedOnly
            ? '${t.watchLater.title} · ${t.watchLater.filterUnwatched}'
            : t.watchLater.title,
    };
    // ⛔ 截断是**必须**的，不是偷懒：胶囊按内容收缩（`GlassCapsuleMorph` 里是
    // 一条 min-size 的 Row），播放列表名可以很长，摆不下不会变省略号而是直接
    // 溢出成黄条。全名在菜单里看得到。
    return label.characters.length > 16
        ? '${label.characters.take(15).string}…'
        : label;
  }

  IconData _pillIcon() => switch (_current.kind) {
    PlaybackQueueKind.source => Icons.subject,
    PlaybackQueueKind.subscriptions => Icons.subscriptions_outlined,
    PlaybackQueueKind.playlist => Icons.queue_music,
    PlaybackQueueKind.authorVideos => Icons.video_library_outlined,
    PlaybackQueueKind.authorGalleries => Icons.photo_library_outlined,
    PlaybackQueueKind.favorites => Icons.favorite_border,
    PlaybackQueueKind.localFavorite => Icons.folder_special_outlined,
    PlaybackQueueKind.downloads => Icons.download_done_outlined,
    // ⛔ 用**设备类**图标，不能再用 folder：抽屉里「收藏夹」已经是 folder 了，
    // 两条都是"某某 + 文件夹图标"必然读混（工作线文档 §3.3）。
    PlaybackQueueKind.localLibrary => Icons.devices_outlined,
    PlaybackQueueKind.watchLater => Icons.watch_later_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassSideDrawerShell(
      title: t.playbackQueue.upNext,
      // ⛔ 切池胶囊**顶替标题文字**站在标题行里，不是标题下面再来一行。
      //
      // 胶囊上写的就是「当前在哪个池里」，标题那行「接着看」纯属重复，两行
      // chrome 白吃一行的高度（抽屉本来就窄，列表能露几条很值钱）。
      //
      // 它仍然是 **header** 的一部分，不是 body 的第一行：只有进了 header，它
      // 才会 ① 一起被量进 header 高度，于是 `contentPadding.top` 自动把它让
      // 开——列表的**起始**位置落在它下缘；② 一起被顶部蒙层收边，内容从它背
      // 后滚过去时是"溶"进去的。放进 body 的话两件事都得自己重做一遍，漏了
      // 第一件就是「列表一开局就压在控制行底下」（2026-08-29 用户报障）。
      titleWidget: GlassDropdownPill(
        // ⛔ 加载态**不动 icon、不动文案**：那两样是用户唯一能确认"我现在在哪
        // 个池里"的信息，拿它们去换一个状态提示是净亏。忙碌另起一枚小弧站在
        // 最左（[GlassInlineBusy]），胶囊自己做宽度形变把它让出来。
        icon: _pillIcon(),
        label: _pillLabel(context),
        busy: _loadingChoices,
        onTap: _loadingChoices ? (_) {} : _openQueuePicker,
      ),
      bodyBuilder: (context, contentPadding) =>
          _buildList(context, contentPadding),
    );
  }

  Widget _buildList(BuildContext context, EdgeInsets contentPadding) {
    final t = slang.Translations.of(context);
    // header（标题行 + 控制行）由外壳实测下发，列表照单让开这一段，内容便从
    // 它整只背后滚过去。
    final double topPadding = contentPadding.top;
    final queue = _current;
    final items = queue.loaded;

    if (items.isEmpty) {
      if (queue.isLoading) {
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      // ⛔ 「一条都没加载出来但还有下一页」= 上一次请求失败了，不是"这个池是空的"。
      // 说成空的会让用户以为这张单子没内容，而且没有任何重试办法。
      final failed = queue.hasMore;
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Center(
          child: GlassTapArea(
            onTap: failed ? _ensureLoadedMore : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (failed)
                    Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  if (failed) const SizedBox(height: 8),
                  Text(
                    failed
                        ? t.watchLater.queueLoadFailed
                        : _isGallery
                        ? t.playbackQueue.emptyGalleryQueue
                        : t.playbackQueue.emptyQueue,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: contentPadding.left,
        top: topPadding,
        right: contentPadding.right,
        bottom: contentPadding.bottom,
      ),
      // 多一行给"正在加载下一页"的转圈
      itemCount: items.length + (queue.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final item = items[index];
        return _QueueRow(
          item: item,
          // 只有正在被播放器使用的那个池才标「正在播」，见 [_isBrowsingActiveQueue]。
          isCurrent: _isBrowsingActiveQueue && item.id == widget.currentItemId,
          // 长按 / 右键 → 预览弹窗，与卡片列表同一套读法（点按 = 播这一条，
          // 长按 = 凑近看一眼）。见 [_openPreview]。
          onPreview: () => _openPreview(queue, item),
          onTap: () => _selectItem(
            PlaybackQueueSelection(
              queue: queue,
              item: item,
              // 「全部」不跳过已看完，「未看完」跳过——用户点播时所在的那一批
              // 就是他要的那一批。
              skipWatched:
                  queue.kind == PlaybackQueueKind.watchLater && _unwatchedOnly,
            ),
          ),
        );
      },
    );
  }
}

const double _kRowMarginVertical = 2;

/// 一行的高度。**同一份数据算两次**：行自己按它撑高，自动滚到当前项按它乘。
///
/// ⛔ 行高与内容无关（有没有作者、有没有统计都一样高，缺了就留白），但**与字号
/// 有关**：两行标题加一行 meta 在系统大字号下会顶出一个写死的框。所以这里跟着
/// [MediaQuery.textScalerOf] 算，而不是钉一个常数——钉常数的代价是无障碍字号下
/// 每一行都溢出。
///
/// 封面 [_kThumbHeight] 是地板：文字比它矮时行高由封面说了算。
double _rowHeight(BuildContext context) {
  final TextScaler scaler = MediaQuery.textScalerOf(context);
  // 标题两行（height 1.25 是写死的）+ 4 的间隔 + meta 一行。meta 那行没写
  // height，按 1.7 估——各家 CJK 回退字体的默认行高在 1.4~1.6 之间浮动，这里
  // **必须往大了估**：估小了就是每一行都溢出，估大了只是多几个像素留白。
  final double text =
      scaler.scale(13.5) * 1.25 * 2 + 4 + scaler.scale(11) * 1.7;
  return math.max(_kThumbHeight, text) + _kRowPaddingVertical * 2;
}

/// 一行**在列表里占的纵向空间**：行高 + 上下外边距。
///
/// ⛔ 自动滚到当前项是靠 `index * _rowExtent(context)` 硬算的，所以这里必须是
/// **含外边距的那个数**。上一版只写了行高、漏掉上下各 2 的 margin，滚到第 20 行
/// 就少滚了 80px，当前项根本不在视野中间。
double _rowExtent(BuildContext context) =>
    _rowHeight(context) + _kRowMarginVertical * 2;

/// 行的上下内边距。
const double _kRowPaddingVertical = 6;

/// 缩略图按 16:9 摆，贴边标签（时长 / 外链）与卡片列表是同一套读法。
const double _kThumbWidth = 112;

/// 「看到哪儿了」那条进度条的高度。底沿那排角标要按它抬高，否则进度条会
/// 横穿标签的下缘（它画在最上层）。
const double _kThumbProgressHeight = 3;
const double _kThumbHeight = _kThumbWidth * 9 / 16;

/// 「接着看」列表里的一条。
///
/// # 有什么就显示什么
///
/// 同一份 [InnerPlaylistItemSnapshot] 在不同的池里富裕程度差很多：接口来的池
/// （来源 / 播放列表 / 作者的视频 / 最爱）带着作者、时长、播放量、发布时间；
/// 本地库来的两个池（稍后再看 / 本地收藏夹）只存了标题封面作者，统计一概没有，
/// 稍后再看另外还带着「看到哪儿了」。
///
/// 所以这里每一段都是**有才画**：统计是 null 就整段不占地方，而不是显示
/// "0 次播放"——那会把「我们没这份数据」说成「没人看过」（见
/// [InnerPlaylistItemSnapshot.numViews]）。
///
/// # 点按播这一条，长按 / 右键看一眼
///
/// 与卡片列表同一套读法：长按（触摸）/ 右键（鼠标）弹出这一条的预览弹窗——
/// 大封面、完整标题、作者、统计、标签，还带着点赞 / 稍后再看 / 更多。行上装不下
/// 的东西全在那儿，而这张单子恰恰是全 App 最挤的一处。见
/// `_PlaybackQueueDrawerState._openPreview`。
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.item,
    required this.isCurrent,
    required this.onTap,
    required this.onPreview,
  });

  final InnerPlaylistItemSnapshot item;
  final bool isCurrent;
  final VoidCallback onTap;

  /// 长按 / 右键：弹出这一条的预览弹窗。
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = slang.Translations.of(context);
    return Semantics(
      // 「正在播放」的角标撤了（视觉上有整行高亮 + 主色标题），但读屏原来正是
      // 靠那枚角标的 semanticLabel 才知道自己在哪一条上，所以语义补在行上。
      selected: isCurrent,
      child: _QueueRowSurface(
        isCurrent: isCurrent,
        onTap: onTap,
        onPreview: onPreview,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildThumbnail(context, cs, t),
            const SizedBox(width: 10),
            Expanded(child: _buildText(context, cs, t)),
          ],
        ),
      ),
    );
  }

  /// 封面：贴边标签（时长 / 外链 / 播放量 / 清晰度）、看到哪儿了的进度条都压
  /// 在它上面——这些都是"关于这条片子本身"的信息，堆在文字区会把标题挤没。
  Widget _buildThumbnail(
    BuildContext context,
    ColorScheme cs,
    slang.Translations t,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: _kThumbWidth,
        height: _kThumbHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 骨架：**永远**垫在最底下，不是「没有图才画」。封面是网络来的，
            // 没垫底的那段时间封面区就是块透明的洞，一列卡片看上去像缺了一角
            // （2026-08-30 用户报障）；垫上之后图片只是在原位淡进来。
            ColoredBox(color: cs.surfaceContainerHighest),
            if (item.thumbnailUrl.isNotEmpty) _buildCover(context, cs),
            ?_buildBottomTags(t),
            ?_buildQualityTag(t),
            if (item.progressPermil > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ProgressBar(
                  permil: item.progressPermil,
                  color: cs.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 封面本体：**本机文件走磁盘、其余走网络**。
  ///
  /// ⛔ 不能一律 [CachedNetworkImage]：本机文件的封面是 ⭐ sidecar（同目录同名的
  /// 那张图，下载器普遍会写一张），地址是 `file://`。喂给网络加载器的结果不是
  /// "转圈转不出来"，而是当场落进 `errorWidget` **画一枚碎图图标**——用户看到的是
  /// "这条片子坏了"，而其实封面就在磁盘上躺着。
  Widget _buildCover(BuildContext context, ColorScheme cs) {
    Widget broken() => ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        size: 18,
        color: cs.onSurfaceVariant,
      ),
    );

    final url = item.thumbnailUrl;
    if (url.startsWith('file://')) {
      return Image.file(
        File(Uri.parse(url).toFilePath()),
        fit: BoxFit.cover,
        // 缩略图只有 [_kThumbWidth] 宽，整张原图解进内存是白烧几十兆——
        // 一列卡片就是几十张。
        cacheWidth: (_kThumbWidth * 3).round(),
        errorBuilder: (_, _, _) => broken(),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => broken(),
    );
  }

  /// 底沿那一排：左边时长，右边贴着播放量。
  ///
  /// 这一排在顶沿和底沿之间来回搬过两次（2026-08-30）。最后落在底沿，是因为
  /// **封面的主体信息在上半部**——人脸、标题字幕都在那儿，一排黑底标签压上去
  /// 挡的正是能帮人认出这条片子的部分；底沿则本来就是渐暗的边角。原先占着
  /// 左下角的清晰度角标因此换到顶沿（见 [_buildQualityTag]）。
  ///
  /// ⛔ 这里原来还有一枚「正在播放」的图标角标，2026-08-30 按用户要求撤掉：
  /// 那一条已经有整行高亮底色 + 主色标题，角标是第三遍说同一件事，还要跟时长
  /// 抢那 112 的宽度。读屏的那份信息挪到了行级 `Semantics(selected:)` 上。
  ///
  /// # 圆角只给露在外面的那两个角
  ///
  /// 左边这枚**贴着底沿与左沿**：左下角跟着封面走（6），右上角是它唯一悬在
  /// 画面里的角，收小一档（4）。右边那枚同理，只有右下（6）与左上（4）。
  ///
  /// # 两处躲让
  ///
  ///   - 有「看到哪儿了」的进度条时整排抬高 [_kThumbProgressHeight]：进度条画
  ///     在最上层，不让位的话它会横穿标签下缘；
  ///   - 宽度上时长最坏 50、播放量 56，加起来贴着封面的 112，所以时长那枚是
  ///     [Expanded]（吃掉播放量剩下的宽度）套 [FittedBox]，真挤到了缩一点，
  ///     不会撑破布局；播放量按自身宽度占位，永远贴着右下角。
  Widget? _buildBottomTags(slang.Translations t) {
    final Widget? duration = _buildDurationTag(t);
    final String? views = item.numViews == null
        ? null
        : CommonUtils.formatFriendlyNumber(item.numViews);
    if (duration == null && views == null) return null;

    return Positioned(
      bottom: item.progressPermil > 0 ? _kThumbProgressHeight : 0,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 没有时长的池（本地库来的那两个）也保留这只 Expanded：它是把播放量
          // 顶到右下角的那段空位。
          Expanded(
            child: duration == null
                ? const SizedBox.shrink()
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: duration,
                  ),
          ),
          if (views != null)
            _ThumbTag(
              icon: Icons.visibility,
              text: views,
              background: Colors.black54,
              foreground: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(6),
                topLeft: Radius.circular(4),
              ),
            ),
        ],
      ),
    );
  }

  /// 底沿左侧那一枚：站外视频报域名（它压根不在这个播放器里放），图库报张数，
  /// 视频报时长。都没有就不画。
  ///
  /// 「张数之于图库」＝「时长之于视频」：都是"这一条要花我多少工夫"的那个数，
  /// 所以占同一个位、同一套样式，不另开一处。
  Widget? _buildDurationTag(slang.Translations t) {
    final IconData icon;
    final String? text;
    if (item.isExternalVideo) {
      icon = Icons.link;
      text = t.common.externalVideo;
    } else if (item.numImages != null) {
      icon = Icons.photo_library_outlined;
      text = '${item.numImages}';
    } else {
      icon = Icons.access_time;
      text = item.durationSeconds == null
          ? null
          : CommonUtils.formatDuration(
              Duration(seconds: item.durationSeconds!),
            );
    }
    if (text == null) return null;
    return _ThumbTag(
      icon: icon,
      text: text,
      background: Colors.black54,
      foreground: Colors.white,
      // 贴着封面左下角：跟着封面倒 6；右上角是它唯一悬在画面里的角，收小
      // 一档。另外两个角在边沿上，不倒。
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(6),
        topRight: Radius.circular(4),
      ),
    );
  }

  /// 左下角那一枚：**本地存的是哪一档清晰度**。只有已下载池答得出来
  /// （见 [InnerPlaylistItemSnapshot.localQuality]），别的池一律不画。
  ///
  /// 占左上角：底沿整条让给了「时长 + 播放量」那一排（见 [_buildBottomTags]），
  /// 封面上只剩这里还空着。
  Widget? _buildQualityTag(slang.Translations t) {
    final quality = item.localQuality?.trim();
    if (quality == null || quality.isEmpty) return null;
    return Positioned(
      left: 0,
      top: 0,
      child: _ThumbTag(
        text: CommonUtils.getQualityDisplayLabel(t, quality),
        background: Colors.black54,
        foreground: Colors.white,
        // 贴着封面左上角：跟着封面倒 6，右下角是唯一悬在画面里的角，收小一档。
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          bottomRight: Radius.circular(4),
        ),
      ),
    );
  }

  /// 文字区只有两块：标题、以及一行「作者 · 点赞 · 时间」。
  ///
  /// 只读的播放量压到封面右上角去了（和卡片列表同一套读法），文字区因此能把
  /// 两行的位置全留给标题。⛔ 这里一共就两块是有意的：再加一行就得去改
  /// [_rowHeight] 的算式，两处对不上，滚动定位当场偏掉。
  Widget _buildText(
    BuildContext context,
    ColorScheme cs,
    slang.Translations t,
  ) {
    final String? author = item.authorName?.trim().isNotEmpty == true
        ? item.authorName!.trim()
        : (item.authorUsername?.trim().isNotEmpty == true
              ? '@${item.authorUsername!.trim()}'
              : null);
    final String time = CommonUtils.formatFriendlyTimestamp(
      item.createdAt,
      includeTime: false,
    );
    final TextStyle metaStyle = TextStyle(
      fontSize: 11,
      color: cs.onSurfaceVariant,
    );

    final List<Widget> meta = <Widget>[
      if (author != null)
        // 作者名最长，摆不下先由它省略——点赞与时间都是短的定长。
        Expanded(
          child: Text(
            author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: metaStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        )
      else
        const Spacer(),
      if (item.isPrivate) ...[
        const SizedBox(width: 6),
        Icon(Icons.lock_outline, size: 11, color: cs.onSurfaceVariant),
      ],
      if (item.numLikes != null) ...[
        const SizedBox(width: 6),
        _MetaStat(
          icon: Icons.favorite_border,
          value: CommonUtils.formatFriendlyNumber(item.numLikes),
        ),
      ],
      if (time.isNotEmpty) ...[
        const SizedBox(width: 6),
        Text(time, maxLines: 1, style: metaStyle),
      ],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.isEmpty ? t.common.noTitle : item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.25,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
            color: isCurrent ? cs.primary : null,
          ),
        ),
        // 整行都没东西可说（本地收藏夹里连作者都没存）时不留这段空隙。
        if (meta.length > 1) ...[
          const SizedBox(height: 4),
          Row(children: meta),
        ],
      ],
    );
  }
}

/// 一行的**可交互外壳**：光标、悬停、按下三件事都在这儿，行的内容只管画。
///
/// # ⛔ 为什么行自己要管悬停
///
/// [GlassTapArea] 是纯触摸实现（`Listener` + `RawGestureDetector`），整层
/// **没有 `MouseRegion`**——它不换光标，也不知道指针悬没悬在上面。所以桌面端
/// 鼠标划过这张单子时一点动静都没有，连"这一行能点"都读不出来
/// （2026-08-30 用户报障）。
///
/// 补在行这一层，不动 [GlassTapArea]：那是全 App 玻璃件共用的入口，给它加上
/// 悬停就等于一次性改掉每一枚玻璃钮的观感，不是这次该做的事。
///
/// # 三层底色叠上去，不是换掉
///
/// 与玻璃菜单的行同一套读法（见 `glass_menu.dart` 的 `_GlassMenuRow`）：正在
/// 播的那条常驻一层主色薄底，悬停 / 按下在**它之上再加深一档**。换掉薄底的话，
/// 鼠标一放反而像是"正在播的标记没了"。
class _QueueRowSurface extends StatefulWidget {
  const _QueueRowSurface({
    required this.isCurrent,
    required this.onTap,
    required this.onPreview,
    required this.child,
  });

  final bool isCurrent;
  final VoidCallback onTap;

  /// 长按（触摸）/ 右键（鼠标）都指向它，见 [_QueueRow.onPreview]。
  final VoidCallback onPreview;

  final Widget child;

  @override
  State<_QueueRowSurface> createState() => _QueueRowSurfaceState();
}

class _QueueRowSurfaceState extends State<_QueueRowSurface> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  /// 悬停 / 按下的底色。基色跟着"是不是正在播"走，于是高亮那条加深的是主色、
  /// 其余行加深的是中性色，不会让某一行悬停时看着像"变成正在播的那条了"。
  Color _surfaceColor(ColorScheme cs) {
    final Color base = widget.isCurrent ? cs.primary : cs.onSurface;
    if (_pressed) {
      return base.withValues(alpha: widget.isCurrent ? 0.24 : 0.10);
    }
    if (_hovered) {
      return base.withValues(alpha: widget.isCurrent ? 0.18 : 0.05);
    }
    // 正在播的那一条常驻高亮，进抽屉一眼就能定位自己在哪。
    return widget.isCurrent
        ? cs.primary.withValues(alpha: 0.12)
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      // 右键：[GlassTapArea] 是纯主键实现（`Listener` + 只认主键的识别器），
      // 副键得自己接。摆在外层不影响主键那套——两者跟的不是同一个按钮。
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTap: widget.onPreview,
        child: GlassTapArea(
          onTap: widget.onTap,
          // 长按开的是一条 `PageRoute`（预览弹窗），不是玻璃菜单，所以不声明
          // longPressOpensOverlay：那一套（震动 + 手指接力滑动取焦）是给菜单
          // 面板用的，弹窗接不住这根手指。
          onLongPress: widget.onPreview,
          // 按下态走的是不进竞技场的 Listener，按下那一帧就到；被列表滚动抢走时
          // 也会回落，不会留下一行"按住没松"的高亮。
          onPressedChanged: _setPressed,
          child: AnimatedContainer(
            duration: GlassTokens.pressDuration,
            curve: Curves.easeOut,
            height: _rowHeight(context),
            margin: const EdgeInsets.symmetric(vertical: _kRowMarginVertical),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: _kRowPaddingVertical,
            ),
            decoration: BoxDecoration(
              color: _surfaceColor(cs),
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 统计行里的一条（图标 + 数字）。
class _MetaStat extends StatelessWidget {
  const _MetaStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

/// 贴在封面角上的一枚小标签（时长 / 外链 / 正在播放）。
class _ThumbTag extends StatelessWidget {
  const _ThumbTag({
    this.icon,
    this.text,
    required this.background,
    required this.foreground,
    required this.borderRadius,
  }) : assert(icon != null || text != null, '空标签不该被画出来');

  /// 不给就只画文字（清晰度那一枚：`1080` / `原画` 自己就说清楚了，再配一枚
  /// 图标只会在 112 宽的封面上抢地方）。
  final IconData? icon;

  /// 不给就只画图标。
  final String? text;
  final Color background;
  final Color foreground;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 10, color: foreground),
              if (text != null) ...[
                if (icon != null) const SizedBox(width: 2),
                Text(
                  text!,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 封面底沿那条「看到哪儿了」。只有稍后再看这个池带得出进度。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.permil, required this.color});

  final int permil;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kThumbProgressHeight,
      child: ColoredBox(
        color: Colors.black38,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (permil / 1000).clamp(0.0, 1.0),
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}

/// 菜单里的一条可选项（播放列表 / 本地收藏夹）。
/// 第二级菜单里的一条。[count] 为 null = 这一类没有条数可显示（不是 0）。
typedef _MenuChoice = ({String id, String title, int? count});

/// 「播放列表」二级菜单里的一节：小标题 + 清单 + 这一节归谁。
typedef _PlaylistSource = ({String title, _MenuFeed feed, User? owner});

/// 「点了还要再选一次」的行尾记号。
const String _kSubmenuChevron = '\u203a';

/// 二级菜单第一行「返回」的取值。
///
/// ⛔ 玻璃菜单是**一张替一张**开的，不是压在上一层之上的浮层——没有这一行，
/// 点错了类别的人只能把菜单关掉、再点一次胶囊，两级菜单就成了单程票。
/// 真实取值是 uuid / `'all'` / `'uncategorized'` 一类，撞不上这个 NUL 前缀。
///
/// 同理还有下面几个：本机目录菜单里那几行"不是一个 id"的取值，一律用 NUL 前缀，
/// 和源 uuid / 目录相对路径 / 文件夹绝对路径都不会撞。
const String _kMenuBackValue = '\u0000back';

const String _kLocalFolderPrefix = '\u0000folder:';

/// 目录菜单里的「播放 / 浏览本目录」那一行。
const String _kLocalPlayHere = '\u0000here';

/// 目录菜单里的子目录行，后面跟的是那个子目录的**相对路径**。
const String _kLocalChildPrefix = '\u0000child:';

/// 走到一个空目录时，那一行不可点的占位。
const String _kLocalNothingHere = '\u0000nothing';

/// 「本机文件」栏目菜单里那四行（见 `_pickLocalCategory`）。同样是 NUL 前缀：
/// 常用目录那张菜单用下标当取值（`'0'`/`'1'`…），撞不上。
const String _kLocalCatFolders = '\u0000cat:folders';
const String _kLocalCatPinned = '\u0000cat:pinned';
const String _kLocalCatFavorites = '\u0000cat:favorites';
const String _kLocalCatAll = '\u0000cat:all';

/// 一份「点开才用得上、但抽屉一开就先去拉」的清单。
///
/// 只拉一次并把结果留着（抽屉活着的这段时间内不会变）；**拉失败不留缓存**，
/// 下次再点会重试——把一次网络抖动缓存成"这个人没有播放列表"是最难自证的那种
/// 假象，而且它会顺手把菜单里那一条**错误地置灰**。
class _MenuFeed {
  _MenuFeed(this._load);

  final Future<List<_MenuChoice>?> Function() _load;
  Future<List<_MenuChoice>?>? _inflight;
  List<_MenuChoice>? _value;

  /// 数据已经在手上了——用来决定要不要亮加载态（已经在手上就别闪那一下）。
  bool get ready => _value != null;

  /// 拉回来的那份（没拉过 / 拉失败为 null）。调用方要在**开菜单之前**据此
  /// 算置灰，见 `_downloadsKnownEmpty`。
  List<_MenuChoice>? get value => _value;

  /// **查过了，确实一条都没有**。菜单靠它置灰；「还没查」和「查失败」都不算。
  bool get knownEmpty => _value?.isEmpty ?? false;

  /// 预取：结果丢着，错误吞掉（真要用的时候会重试并给出提示）。
  void warmUp() {
    get().catchError((_) => null);
  }

  Future<List<_MenuChoice>?> get() {
    final existing = _inflight;
    if (existing != null) return existing;
    final future = _load();
    _inflight = future;
    future
        .then((value) {
          if (value == null) {
            _inflight = null; // 失败不缓存
          } else {
            _value = value;
          }
        })
        .catchError((_) {
          _inflight = null;
        });
    return future;
  }
}

/// 池选择菜单里的一条。
/// 第一级菜单的七个**类别**。分支（哪一张播放列表 / 哪个夹子 / 哪个下载分类 /
/// 全部还是未看完）全在第二级里选，这里一个都不出现。
enum _QueuePick {
  source,

  /// 订阅动态（已关注作者的全部作品）。
  subscriptions,

  /// 我的播放列表。
  playlists,
  favorites,

  /// 收藏夹（`FavoriteService` 的夹子）。⛔ 它**不是**磁盘目录。
  localFolders,
  downloads,

  /// 本机文件：扫描建库出来的那些源文件夹。
  localLibrary,
  watchLater,
  authorVideos,

  /// 这个图库作者的全部图库。
  authorGalleries,

  /// 这条视频作者的播放列表。
  authorPlaylists,

  /// 既不是我的、也不是作者的那个人的播放列表（从别人的列表点进来时才在场）。
  otherPlaylists,
}
