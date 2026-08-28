import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_side_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_touch.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
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
/// # ⛔ 稍后再看池只装视频
///
/// 抽屉的契约是"接下来能在这个播放器里看的东西"。图库点了要退出播放器跳走，
/// 塞进待播队列是个陷阱（见 [WatchLaterPlaybackQueue]）。
Future<PlaybackQueueSelection?> showPlaybackQueueDrawer({
  required BuildContext context,
  required List<PlaybackQueue> queues,
  required PlaybackQueue initialQueue,
  required String currentItemId,
  User? playlistOwner,
}) {
  if (queues.isEmpty) return Future<PlaybackQueueSelection?>.value();
  return showGlassSideDrawer<PlaybackQueueSelection>(
    context: context,
    builder: (_) => _PlaybackQueueDrawer(
      queues: queues,
      initialQueue: initialQueue,
      currentItemId: currentItemId,
      playlistOwner: playlistOwner,
    ),
  );
}

class _PlaybackQueueDrawer extends StatefulWidget {
  const _PlaybackQueueDrawer({
    required this.queues,
    required this.initialQueue,
    required this.currentItemId,
    this.playlistOwner,
  });

  final List<PlaybackQueue> queues;
  final PlaybackQueue initialQueue;
  final String currentItemId;
  final User? playlistOwner;

  @override
  State<_PlaybackQueueDrawer> createState() => _PlaybackQueueDrawerState();
}

class _PlaybackQueueDrawerState extends State<_PlaybackQueueDrawer> {
  late List<PlaybackQueue> _queues;
  late int _selectedIndex;
  final ScrollController _scrollController = ScrollController();

  /// 稍后再看池的筛选。切它等于换一个池（筛选是池身份的一部分）。
  bool _unwatchedOnly = false;

  @override
  void initState() {
    super.initState();
    _queues = List.of(widget.queues);
    _selectedIndex = _queues.indexOf(widget.initialQueue).clamp(
      0,
      _queues.length - 1,
    );
    _current.addListener(_onQueueChanged);
    _scrollController.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureLoaded();
      _scrollToCurrent();
    });
  }

  @override
  void dispose() {
    _current.removeListener(_onQueueChanged);
    _scrollController.dispose();
    super.dispose();
  }

  PlaybackQueue get _current => _queues[_selectedIndex];

  void _onQueueChanged() {
    if (mounted) setState(() {});
  }

  void _ensureLoaded() {
    final queue = _current;
    if (queue.loaded.isEmpty && queue.hasMore && !queue.isLoading) {
      queue.loadMore();
    }
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
    final target = (index * _kRowExtent).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(target);
  }

  void _switchQueue(int index) {
    if (index == _selectedIndex) return;
    _current.removeListener(_onQueueChanged);
    setState(() => _selectedIndex = index);
    _current.addListener(_onQueueChanged);
    _ensureLoaded();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  void _switchWatchLaterFilter(bool unwatchedOnly) {
    if (unwatchedOnly == _unwatchedOnly) return;
    final replacement = PlaybackQueueService.to.openWatchLater(
      unwatchedOnly: unwatchedOnly,
    );
    _current.removeListener(_onQueueChanged);
    setState(() {
      _unwatchedOnly = unwatchedOnly;
      _queues[_selectedIndex] = replacement;
    });
    _current.addListener(_onQueueChanged);
  }

  String _labelFor(BuildContext context, PlaybackQueue queue) {
    final t = slang.Translations.of(context);
    return switch (queue.kind) {
      PlaybackQueueKind.source => t.playbackQueue.sourceTab,
      PlaybackQueueKind.playlist => queue.title?.trim().isNotEmpty == true
          ? queue.title!.trim()
          : t.common.playList,
      PlaybackQueueKind.watchLater => t.watchLater.title,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassSideDrawerShell(
      title: t.playbackQueue.upNext,
      bodyBuilder: (context, contentPadding) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 池切换。**左对齐**：它统辖的是下面那列，居右会让两者在视觉上对不上。
            if (_queues.length > 1)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPadding.left,
                  0,
                  contentPadding.right,
                  8,
                ),
                child: GlassAdaptiveSegmentedControl(
                  selectedIndex: _selectedIndex,
                  onChanged: _switchQueue,
                  items: [
                    for (final queue in _queues)
                      GlassSegmentItem(label: _labelFor(context, queue)),
                  ],
                ),
              ),
            if (_current.kind == PlaybackQueueKind.playlist)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPadding.left,
                  0,
                  contentPadding.right,
                  8,
                ),
                child: _PlaylistPickerRow(
                  owner: widget.playlistOwner,
                  currentVideoId: widget.currentItemId,
                  currentTitle: _current.title,
                  onPicked: (playlistId, title) {
                    final queue = PlaybackQueueService.to.openPlaylist(
                      playlistId,
                      title: title,
                    );
                    _current.removeListener(_onQueueChanged);
                    setState(() => _queues[_selectedIndex] = queue);
                    _current.addListener(_onQueueChanged);
                    _ensureLoaded();
                  },
                ),
              ),
            // 稍后再看池的 `全部 | 未看完`。它是**载荷性**的：切它同时决定了续播
            // 在哪一批里迭代。排序入口不放这儿——那是"整理"动作，属于列表页。
            if (_current.kind == PlaybackQueueKind.watchLater)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPadding.left,
                  0,
                  contentPadding.right,
                  8,
                ),
                child: GlassAdaptiveSegmentedControl(
                  selectedIndex: _unwatchedOnly ? 1 : 0,
                  onChanged: (index) => _switchWatchLaterFilter(index == 1),
                  items: [
                    GlassSegmentItem(label: t.watchLater.filterAll),
                    GlassSegmentItem(label: t.watchLater.filterUnwatched),
                  ],
                ),
              ),
            Expanded(child: _buildList(context, contentPadding)),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext context, EdgeInsets contentPadding) {
    final t = slang.Translations.of(context);
    final queue = _current;
    final items = queue.loaded;

    if (items.isEmpty) {
      if (queue.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      // ⛔ 「一条都没加载出来但还有下一页」= 上一次请求失败了，不是"这个池是空的"。
      // 说成空的会让用户以为这张单子没内容，而且没有任何重试办法。
      final failed = queue.hasMore;
      return Center(
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
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: contentPadding.left,
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
          isCurrent: item.id == widget.currentItemId,
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

/// 一行**在列表里占的纵向空间**：行高 + 上下外边距。
///
/// ⛔ 自动滚到当前项是靠 `index * _kRowExtent` 硬算的，所以这里必须是**含外边距
/// 的那个数**。上一版只写了行高 84、漏掉上下各 2 的 margin，滚到第 20 行就少滚
/// 了 80px，当前项根本不在视野中间。
const double _kRowHeight = 84;
const double _kRowMarginVertical = 2;
const double _kRowExtent = _kRowHeight + _kRowMarginVertical * 2;

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
    return GlassTapArea(
      onTap: onTap,
      child: Container(
        height: _kRowHeight,
        margin: const EdgeInsets.symmetric(
          vertical: _kRowMarginVertical,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          // 正在播的那一条常驻高亮，进抽屉一眼就能定位自己在哪。
          color: isCurrent ? cs.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 106,
                height: 60,
                child: item.thumbnailUrl.isEmpty
                    ? ColoredBox(color: cs.surfaceContainerHighest)
                    : CachedNetworkImage(
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
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
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
                      fontWeight: isCurrent
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isCurrent ? cs.primary : null,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 4),
                    Text(
                      t.playbackQueue.nowPlaying,
                      style: TextStyle(fontSize: 11, color: cs.primary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 播放列表选择器：两枚头像 + 一条当前列表名。
///
/// 两枚头像分别是「我的播放列表」与「这条视频所属列表的作者的播放列表」——
/// 用户常常是从别人的播放列表点进详情页的，这时他既可能想在别人那张单子里
/// 接着看，也可能想切回自己的。
///
/// ⛔ **别人那枚头像在没有 owner 时整只不出现**（不是灰着）：一个点了没反应的
/// 灰头像比没有更让人困惑。
class _PlaylistPickerRow extends StatelessWidget {
  const _PlaylistPickerRow({
    required this.owner,
    required this.currentVideoId,
    required this.currentTitle,
    required this.onPicked,
  });

  final User? owner;
  final String currentVideoId;
  final String? currentTitle;
  final void Function(String playlistId, String title) onPicked;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final self = Get.find<UserService>().currentUser.value;

    return Row(
      children: [
        if (self != null)
          _AvatarPickerButton(
            user: self,
            tooltip: t.playbackQueue.myPlaylists,
            onTap: () => _pickOwn(context),
          ),
        if (owner != null && owner!.id != self?.id) ...[
          const SizedBox(width: 6),
          _AvatarPickerButton(
            user: owner!,
            tooltip: t.playbackQueue.authorPlaylists,
            onTap: () => _pickOther(context, owner!),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: GlassSurface(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 36,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  // 播放列表名可能很长，滚起来而不是截断——抽屉只有 380 宽，
                  // 截断之后好几张单子看起来会一模一样。
                  child: _MarqueeText(
                    text: currentTitle?.trim().isNotEmpty == true
                        ? currentTitle!.trim()
                        : t.common.playList,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickOwn(BuildContext context) async {
    final t = slang.Translations.of(context);
    final result = await Get.find<PlayListService>().getLightPlaylists(
      videoId: currentVideoId,
    );
    if (!context.mounted) return;
    if (!result.isSuccess || result.data == null) {
      showGlassToast(
        t.watchLater.playlistLoadFailed,
        type: GlassToastType.error,
      );
      return;
    }
    if (result.data!.isEmpty) {
      showGlassToast(t.watchLater.noPlaylists, type: GlassToastType.info);
      return;
    }
    final picked = await showGlassMenu<String>(
      anchorContext: context,
      entries: [
        GlassMenuSectionHeader(t.playbackQueue.myPlaylists),
        for (final playlist in result.data!)
          GlassMenuOption<String>(
            value: playlist.id,
            label: playlist.title,
            trailing: '${playlist.numVideos}',
          ),
      ],
    );
    _emitById(picked, {
      for (final playlist in result.data!) playlist.id: playlist.title,
    });
  }

  Future<void> _pickOther(BuildContext context, User user) async {
    final t = slang.Translations.of(context);
    // 别人的播放列表只有分页接口（lite 那条的入参是 videoId、只返回自己的）。
    // 抽屉里先取第一页；真要翻更多，作者主页有完整列表。
    final result = await Get.find<PlayListService>().getPlaylists(
      userId: user.id,
      page: 0,
    );
    if (!context.mounted) return;
    if (!result.isSuccess || result.data == null) {
      // ⛔ 别静默 return：用户点了头像什么都不发生，分不清"没有列表"还是"网炸了"。
      LogUtils.w('拉取作者播放列表失败', 'PlaybackQueueDrawer');
      showGlassToast(
        t.watchLater.playlistLoadFailed,
        type: GlassToastType.error,
      );
      return;
    }
    final playlists = result.data!.results;
    if (playlists.isEmpty) {
      showGlassToast(t.watchLater.noPlaylists, type: GlassToastType.info);
      return;
    }
    final picked = await showGlassMenu<String>(
      anchorContext: context,
      entries: [
        GlassMenuSectionHeader(t.playbackQueue.authorPlaylists),
        for (final playlist in playlists)
          GlassMenuOption<String>(
            value: playlist.id,
            label: playlist.title,
            trailing: '${playlist.numVideos}',
          ),
      ],
    );
    _emitById(picked, {
      for (final playlist in playlists) playlist.id: playlist.title,
    });
  }

  /// 菜单项的 value 只放 **playlist id**，标题另用一张表回查。
  ///
  /// ⛔ 上一版把两者拼成 `'<id> <title>'` 再按空格 split —— 播放列表名里几乎
  /// 必然有空格，切出来超过 2 段就被整条丢弃，用户看到的是"点了没反应"。
  void _emitById(String? pickedId, Map<String, String> titles) {
    if (pickedId == null) return;
    onPicked(pickedId, titles[pickedId] ?? '');
  }
}

class _AvatarPickerButton extends StatelessWidget {
  const _AvatarPickerButton({
    required this.user,
    required this.tooltip,
    required this.onTap,
  });

  final User user;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassTapArea(
      onTap: onTap,
      opensOverlay: true,
      child: Semantics(
        label: tooltip,
        button: true,
        child: AvatarWidget(user: user, size: 32),
      ),
    );
  }
}

/// 一条会滚动的单行文字（摆不下才滚）。
///
/// 没引第三方包：这里只需要"摆不下就来回滚"这一件事，而 marquee 一类的包会
/// 连着一套自己的滚动/淡出/间隔配置一起进来。
class _MarqueeText extends StatefulWidget {
  const _MarqueeText({required this.text});

  final String text;

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();
        final textWidth = painter.width;
        painter.dispose();

        // ⛔ 启停动画要挪到帧后：在 build 里调 `repeat()` / `stop()` 会在布局
        // 期间 notifyListeners，属于"build 中改状态"的脆弱写法。
        final overflows = textWidth > constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (overflows && !_controller.isAnimating) {
            _controller.repeat();
          } else if (!overflows && _controller.isAnimating) {
            _controller.stop();
          }
        });

        // 摆得下就老老实实静止——没必要为了动而动。
        if (!overflows) {
          return Text(widget.text, style: style, maxLines: 1);
        }

        final overflow = textWidth - constraints.maxWidth;
        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // 三角波：滚到头再滚回来，比"绕圈重来"更容易读完整个标题。
              final t = _controller.value;
              final progress = t < 0.5 ? t * 2 : (1 - t) * 2;
              return Transform.translate(
                offset: Offset(-overflow * progress, 0),
                child: child,
              );
            },
            child: Text(
              widget.text,
              style: style,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      },
    );
  }
}
