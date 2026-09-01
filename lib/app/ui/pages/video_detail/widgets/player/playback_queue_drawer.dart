import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
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
  /// JOIN + GROUP BY）、`getCompletedVideoCounts()`、`getAllCategories()`——虽然
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

  void _selectItem(PlaybackQueueSelection selection) {
    if (_selected) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    _selected = true;
    Navigator.of(context).pop(selection);
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
    // ⛔ 图库这一路**不碰播放列表和下载**：Iwara 的播放列表只收视频，下载池里
    // 也只有视频。预取它们等于为一类根本不会出现的菜单项白打请求。
    if (_isGallery) return;
    final self = Get.find<UserService>().currentUser.value;
    final author = widget.author;
    if (self != null) _ownPlaylists.warmUp();
    if (author != null && author.id != self?.id) _authorPlaylists.warmUp();
    _downloadCategories.warmUp();
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
      // 本地收藏与已下载都是「我自己的本地库」，两条挨着；中间夹进别的东西
      // 会读成两回事。
      branchEntry(
        value: _QueuePick.localFolders,
        kind: PlaybackQueueKind.localFavorite,
        label: t.playbackQueue.localFavoriteFolders,
        knownEmpty: _localFolders.knownEmpty,
        icon: Icons.folder_open_outlined,
      ),
      // ⛔ 「已下载」是**视频专属**：下载池里只有视频文件，而图库即使下载过也
      // 没有离线浏览的入口。摆一条点进去恒为空的项比不摆更糟。
      if (!_isGallery)
        branchEntry(
          value: _QueuePick.downloads,
          kind: PlaybackQueueKind.downloads,
          label: t.playbackQueue.downloads,
          knownEmpty: _downloadsKnownEmpty,
          icon: Icons.download_done_outlined,
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
          sectionTitle: t.playbackQueue.localFavoriteFolders,
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
        showAppToast(
          t.watchLater.playlistLoadFailed,
          type: AppToastType.error,
        );
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
            trailing: choice.count == null ? null : '${choice.count}',
            selected: _isCurrentQueue('playlist:${choice.id}'),
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
            trailing: row.count == null ? null : '${row.count}',
            // 计数是**这个桶里可播的已下载视频**（见
            // `getCompletedVideoCounts`），所以 0 就是真的点进去什么都没有。
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

  void _useDownloads(String categoryFilter, String? title) {
    _useQueue(
      PlaybackQueueService.to.openDownloads(
        categoryFilter: categoryFilter,
        title: title,
      ),
    );
  }

  /// 下载分类清单。
  ///
  /// ⛔ 条数**不能用 `DownloadCategory.itemCount`**：那是这个分类下**所有**任务
  /// （含图库、含下载中/失败）的条数，而池里只装「已完成的视频、按 media_id
  /// 去重」。两个数对不上，菜单就会写着「5」而点进去是空的。
  Future<List<_MenuChoice>?> _fetchDownloadCategories() async {
    final t = slang.t;
    final service = DownloadService.to;
    final counts = await service.repository.getCompletedVideoCounts();
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
      showAppToast(
        t.watchLater.playlistLoadFailed,
        type: AppToastType.error,
      );
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
            trailing: _isGallery || choice.count == null
                ? null
                : '${choice.count}',
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
        // 加载态原位换沙漏 + 文案换「加载中」：胶囊自己会做宽度形变，
        // 不是两只钮硬切。
        icon: _loadingChoices ? Icons.hourglass_top : _pillIcon(),
        label: _loadingChoices ? t.common.loading : _pillLabel(context),
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
class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.item,
    required this.isCurrent,
    required this.onTap,
  });

  final InnerPlaylistItemSnapshot item;
  final bool isCurrent;
  final VoidCallback onTap;

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
            if (item.thumbnailUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.thumbnailUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => ColoredBox(
                  color: cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
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
    required this.child,
  });

  final bool isCurrent;
  final VoidCallback onTap;
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
      child: GlassTapArea(
        onTap: widget.onTap,
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
const String _kMenuBackValue = '\u0000back';

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
  localFolders,
  downloads,
  watchLater,
  authorVideos,

  /// 这个图库作者的全部图库。
  authorGalleries,

  /// 这条视频作者的播放列表。
  authorPlaylists,

  /// 既不是我的、也不是作者的那个人的播放列表（从别人的列表点进来时才在场）。
  otherPlaylists,
}
