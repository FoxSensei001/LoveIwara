import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_bottom_sheet.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';

/// 表情选择器。
///
/// # 版式：与全站列表页同一套语言
///
/// 顶部不是「弹层名 + 一排钮」，而是**分组选项栏**——就是热门列表页 header 上
/// 那条 [GlassSegmentedControl]（`popular_video_list_page` 那一族）。理由很直白：
/// 「表情」两个字每次开弹层都重说一遍，而用户开这张弹层的时候本来就知道自己在
/// 干什么；那一格让给分组，横向一栏能装下的分组比标题多得多。每一段前面挂着
/// 这个分组的**缩略图**（[EmojiGroup.coverUrl]，没有就拿组里第一张顶上）——
/// 斗图的人记的是图不是组名。
///
/// 顶栏与底栏都**浮在网格之上**（[GlassFloatingHeaderSheet]，与视频详情页那张
/// 评论弹层同一只壳）：表情从它们背后滚过去，中间只有一层渐进蒙层，而不是上下
/// 分家的三段。
///
/// # 横滑换组
///
/// 在网格上横着一划就切到相邻分组，选项栏的指示器**跟着手指走**（喂给
/// [GlassSegmentedControl.progress] 的是一条逐帧更新的小数下标）。
///
/// ⛔ 这里不用 `PageView`：外壳是 [GlassDraggableBottomSheet]，它给的那只
/// `ScrollController` 必须接到**唯一一只**可滚动组件上（拖大弹层与列表滚到底
/// 是同一条手势链路）。`PageView` 里每页各有一只 `GridView`，只能接一只，另外
/// 几只要么抢控制器报错、要么让「按住网格往下拖收起弹层」当场失效。所以网格
/// 只有一只，横滑由外面一层手势识别器接管——竖滚归 `GridView`，横滑归它，
/// 两者方向正交不打架。
///
/// # 这一版之前改了什么
///
/// 更早的版本是「左侧 80px 分组 rail + 右侧固定 4 列网格」装在自建的
/// `DraggableScrollableSheet` 里：rail 在 360dp 屏上吃掉 22% 的宽度、列数写死 4、
/// 壳不走 [GlassBottomSheet] 所以材质对不上、骨架屏写死 `Colors.grey[300]`
/// 深色下是一片亮块。另外补了两件事，这一版继续保留：
///
/// - **最近用过**排在第一格（存 [ConfigKey.RECENT_EMOJIS_KEY]）。斗图是这个站的
///   核心玩法，「再发一次刚才那张」是最高频的动作。
/// - **选完不自动关**。连发三张表情不该开三次弹层；底栏实时显示这次插了几个。
class EmojiPickerSheet extends StatefulWidget {
  const EmojiPickerSheet({
    super.key,
    required this.onEmojiSelected,
    required this.onSizeChanged,
    this.initialSize = EmojiSize.medium,
  });

  /// 插入一个表情。⛔ **不要在这个回调里关闭弹层**——连选是刻意的。
  final void Function(String imageUrl, EmojiSize size) onEmojiSelected;
  final void Function(EmojiSize) onSizeChanged;
  final EmojiSize initialSize;

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet>
    with SingleTickerProviderStateMixin {
  /// 一个表情格子的目标边长。列数由可用宽度除以它算出来，而不是写死——
  /// 写死列数的话，同一份网格在 360dp 手机上挤成一团、在平板上又大得滑稽。
  static const double _cellTarget = 76;
  static const double _cellGap = 8;

  /// 「最近用过」最多记多少个。多了就不是「最近」了，还会把分组挤下去。
  static const int _recentLimit = 24;

  /// 横滑到屏宽的这个比例就算换组（松手时判）。低于它弹回原组。
  static const double _swipeCommitFraction = 0.22;

  /// 换组过渡的时长：与选项栏指示器那条（[GlassTokens.motionDuration]）同值，
  /// 网格和指示器要一起落位，不能一个到了另一个还在路上。
  static const Duration _switchDuration = Duration(milliseconds: 240);

  late final EmojiLibraryService _emojiService;
  late final ConfigService _configService;

  late EmojiSize _selectedSize;
  List<EmojiGroup> _groups = const [];
  List<String> _recent = const [];

  /// 当前选中的格子：0 是「最近」（有内容时才在），其余是分组。
  int _tab = 0;
  bool _loading = true;

  /// 这次开着弹层一共插了几个，显示在底部。连选没有这个反馈的话，用户不确定
  /// 刚才那一下到底有没有插进去（输入框被弹层盖住了看不见）。
  int _inserted = 0;

  /// 喂给选项栏的小数下标：横滑途中逐帧更新，指示器因此跟手。
  final ValueNotifier<double> _tabProgress = ValueNotifier<double>(0);

  /// 落位动画（松手之后 / 直接点段切换时，把 [_tabProgress] 与网格位移一起送到位）。
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: _switchDuration,
  );
  double _settleFrom = 0;
  double _settleTo = 0;

  /// 落位起跑那一刻的网格位移。⛔ 必须记下起点单独插值：拿上一帧的
  /// `_dragDx * (1 - f)` 往下乘是**连乘**，位移头两帧就塌到 0，动画等于没有。
  double _settleFromDx = 0;

  /// 网格这会儿横向偏了多少像素（跟手位移；落位动画期间由 [_settle] 插值）。
  double _dragDx = 0;

  /// 网格区最近一次量到的宽度。点选项栏换组时要用它算「新的一组从哪一边进来」
  /// ——那条路上没有手势，拿不到 `LayoutBuilder` 的约束。
  double _gridWidth = 0;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
    _emojiService = Get.find<EmojiLibraryService>();
    _configService = Get.find<ConfigService>();
    _recent = _readRecent();
    _settle.addListener(_onSettleTick);
    _load();
  }

  @override
  void dispose() {
    _settle.removeListener(_onSettleTick);
    _settle.dispose();
    _tabProgress.dispose();
    super.dispose();
  }

  void _load() {
    try {
      _groups = _emojiService.getEmojiGroups();
    } catch (_) {
      _groups = const [];
    }
    if (mounted) setState(() => _loading = false);
  }

  // ── 最近用过 ──────────────────────────────────────────────

  List<String> _readRecent() {
    try {
      final raw = _configService[ConfigKey.RECENT_EMOJIS_KEY] as String;
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return list.whereType<String>().toList(growable: false);
    } catch (_) {
      // 存坏了就当没有，不要因为一条历史记录把整个选择器炸掉
      return const [];
    }
  }

  void _pushRecent(String url) {
    final next = <String>[url, ..._recent.where((u) => u != url)];
    if (next.length > _recentLimit) next.removeRange(_recentLimit, next.length);
    _recent = next;
    _configService[ConfigKey.RECENT_EMOJIS_KEY] = jsonEncode(next);
  }

  // ── 事件 ────────────────────────────────────────────────

  void _pick(String url) {
    widget.onEmojiSelected(url, _selectedSize);
    setState(() {
      _inserted++;
      final hadRecent = _recent.isNotEmpty;
      _pushRecent(url);
      // 第一次用之后「最近」这一格才长出来，此时后面的分组整体右移一位，
      // 当前选中的那一格要跟着挪，否则用户会发现自己突然换了组。
      // ⛔ 不加 `_tab > 0` 的条件：第 0 格原先是第一个分组，长出「最近」之后
      // 第 0 格变成了「最近」，不挪的话用户正看着的那一组会当场被换掉。
      if (!hadRecent) _tab++;
      _tabProgress.value = _tab.toDouble();
    });
  }

  void _changeSize(EmojiSize size) {
    setState(() => _selectedSize = size);
    widget.onSizeChanged(size);
  }

  bool get _hasRecent => _recent.isNotEmpty;

  /// 一共几格（「最近」算一格）。
  int get _tabCount => (_hasRecent ? 1 : 0) + _groups.length;

  /// 当前这一格要显示哪些图（网格里放的是缩略图）。
  List<String> get _currentUrls => _urlsForTab(_tab);

  List<String> _urlsForTab(int tab) {
    if (_hasRecent && tab == 0) return _recent;
    final index = _hasRecent ? tab - 1 : tab;
    if (index < 0 || index >= _groups.length) return const [];
    return _emojiService
        .getEmojiImages(_groups[index].groupId)
        .map((e) => e.thumbnailUrl ?? e.url)
        .toList(growable: false);
  }

  /// 点格子时要插入的**原图** url（网格里显示的是缩略图）。
  List<EmojiImage>? get _currentImages {
    if (_hasRecent && _tab == 0) return null;
    final index = _hasRecent ? _tab - 1 : _tab;
    if (index < 0 || index >= _groups.length) return null;
    return _emojiService.getEmojiImages(_groups[index].groupId);
  }

  /// 选项栏里这一段前面挂的那张缩略图。
  ///
  /// 优先用分组自己的封面；没设封面就拿组里第一张顶上——一条**没有图**的分组段
  /// 和别的段长得不一样，那排看起来就是坏的。两样都没有（空分组）才退回图标。
  String? _stripThumbFor(int tab) {
    if (_hasRecent && tab == 0) return _recent.first;
    final index = _hasRecent ? tab - 1 : tab;
    if (index < 0 || index >= _groups.length) return null;
    final cover = _groups[index].coverUrl;
    if (cover != null && cover.trim().isNotEmpty) return cover;
    return _urlsForTab(tab).firstOrNull;
  }

  // ── 横滑换组 ──────────────────────────────────────────────

  void _onSettleTick() {
    if (!mounted) return;
    final double f = GlassTokens.motionCurve.transform(_settle.value);
    _tabProgress.value = _settleFrom + (_settleTo - _settleFrom) * f;
    setState(() => _dragDx = _settleFromDx * (1 - f));
  }

  /// 能不能往这个方向翻（-1 左 / +1 右）。两端不给跟手位移，免得读成「卡住了」。
  bool _canGo(int delta) {
    final next = _tab + delta;
    return next >= 0 && next < _tabCount;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (_tabCount <= 1) return;
    if (_settle.isAnimating) _settle.stop();
    final double next = _dragDx + details.delta.dx;
    // 往没有下一组的那一头拖：位移打三折，手感上是「到头了」而不是硬顶住。
    final bool overscroll = next > 0 ? !_canGo(-1) : !_canGo(1);
    _dragDx = overscroll ? next * 0.33 : next;
    // 小数下标与位移反号：手指往左推（dx < 0）是往后一组走。
    final double t = (_tab - _dragDx / width).clamp(
      0.0,
      (_tabCount - 1).toDouble(),
    );
    _tabProgress.value = t;
    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details, double width) {
    if (_tabCount <= 1) {
      _animateSettle(_tab);
      return;
    }
    // 甩一下也算：速度够快就按速度方向换组，不必真拖过那 22%。
    final double velocity = details.velocity.pixelsPerSecond.dx;
    final bool flung = velocity.abs() > 420;
    final int direction = flung
        ? (velocity < 0 ? 1 : -1)
        : (_dragDx.abs() >= width * _swipeCommitFraction
              ? (_dragDx < 0 ? 1 : -1)
              : 0);
    final bool commit = direction != 0 && _canGo(direction);
    final int target = commit ? _tab + direction : _tab;
    if (commit) {
      // ⛔ 换组那一刻网格内容当场变成新的一组，而位移还停在手指拉出来的地方。
      // 不把起点推到屏幕外的话，新的一组会从**手指来的那一侧**滑进来——方向
      // 正好反了，读成「拖左边却是左边的东西进来」。加一整屏宽把它挪到该来的
      // 那一边：往后翻就从右边进，往前翻就从左边进。
      _dragDx += width * direction;
    }
    setState(() => _tab = target);
    _animateSettle(target);
  }

  /// 把跟手位移与指示器一起送到 [target] 这一格。
  void _animateSettle(int target) {
    _settleFrom = _tabProgress.value;
    _settleTo = target.toDouble();
    _settleFromDx = _dragDx;
    _settle.forward(from: 0);
  }

  /// 直接点选项栏上的某一段。整屏宽的起点让新的一组照样是「滑进来」的
  /// ——项目约定：出现与消失都要有动画，硬切换内容不接受。
  void _selectTab(int index) {
    if (index == _tab) return;
    final double from = _gridWidth * (index > _tab ? 1 : -1);
    setState(() {
      _tab = index;
      _dragDx = from;
    });
    _animateSettle(index);
  }

  // ── 构建 ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return GlassFloatingHeaderSheet(
      // 标题只剩无障碍标签：可见的那一格让给分组选项栏。
      title: t.emoji.name,
      // ⛔ 不做「加载中先摆标题、好了再换成选项栏」：那是一次硬切。分组是本地库
      // 里同步读出来的（[EmojiLibraryService.getEmojiGroups]），空的那一帧让
      // 选项栏自己收成零宽即可。
      titleWidget: _buildGroupStrip(context, t),
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      actions: [
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.tune),
          tooltip: t.emoji.library,
          onPressed: () {
            Navigator.pop(context);
            NaviService.navigateToEmojiLibraryPage();
          },
        ),
      ],
      footer: _buildFooter(context, t),
      bodyBuilder: (context, scrollController, headerExtent, footerExtent) {
        if (_loading) {
          return _buildSkeleton(context, headerExtent, footerExtent);
        }
        return _buildSwipeableGrid(
          context,
          t,
          scrollController,
          headerExtent,
          footerExtent,
        );
      },
    );
  }

  /// 顶部分组选项栏。与热门列表页 header 上那条是同一只控件，所以它自带的东西
  /// 全都在：跟手高亮、长按拾起拖动、液态档的果冻指示器，以及——
  ///
  /// ⛔ **摆不下就退化成下拉钮**。这一条在表情选择器上比别处更要紧：分组是用户
  /// 自己在表情库里建的，可以有十几组，名字还可能很长。裸的
  /// [GlassSegmentedControl] 摆不下时不会报错，只会自己横滚成一条被裁掉的半截
  /// 胶囊。闸门见 `test/glass_style_guard_test.dart`。
  Widget _buildGroupStrip(BuildContext context, Translations t) {
    final labels = <String>[
      if (_hasRecent) t.emoji.recentlyUsed,
      for (final g in _groups) g.name,
    ];
    if (labels.isEmpty) return const SizedBox.shrink();

    return GlassAdaptiveSegmentedControl(
      selectedIndex: _tab.clamp(0, labels.length - 1),
      progress: _tabProgress,
      onChanged: _selectTab,
      items: [
        for (var i = 0; i < labels.length; i++)
          GlassSegmentItem(
            label: labels[i],
            icon: _buildStripThumb(context, i),
          ),
      ],
    );
  }

  /// 段首那枚缩略图。
  ///
  /// ⛔ 尺寸必须**正好**是 [GlassSegmentedControl.itemIconSize]：分段控件量段宽
  /// 时按这个常数给图标记账（`minWidthFor`），塞一张更大的图进去，量出来的宽度
  /// 就和真实排版对不上，高亮块会错位。
  Widget? _buildStripThumb(BuildContext context, int tab) {
    final String? url = _stripThumbFor(tab);
    const double size = GlassSegmentedControl.itemIconSize;
    if (url == null || url.isEmpty) {
      // 连一张图都没有的分组（空组）才退回图标；「最近」那一格有图时也走上面。
      return Icon(
        _hasRecent && tab == 0 ? Icons.history_rounded : Icons.folder_outlined,
        size: size,
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
          placeholder: (context, url) => const SizedBox.shrink(),
          // 取不到图就空着：这一格的宽度已经按 size 记过账，换成别的图标不会
          // 改宽度，但一枚「坏图」图标排在分组名前面比什么都不画更吵。
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// 网格 + 横滑换组。
  ///
  /// 手势只认横向（`onHorizontalDragUpdate`），竖向照常归身下的 `GridView`——
  /// 两个方向的识别器在竞技场里互不相让，正交手势不会抢。
  Widget _buildSwipeableGrid(
    BuildContext context,
    Translations t,
    ScrollController controller,
    double headerExtent,
    double footerExtent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        _gridWidth = width;
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onHorizontalDragUpdate: (d) => _onHorizontalDragUpdate(d, width),
          onHorizontalDragEnd: (d) => _onHorizontalDragEnd(d, width),
          onHorizontalDragCancel: () => _animateSettle(_tab),
          child: Transform.translate(
            offset: Offset(_dragDx, 0),
            child: _buildGrid(
              context,
              t,
              controller,
              constraints.maxWidth,
              headerExtent,
              footerExtent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    Translations t,
    ScrollController controller,
    double width,
    double headerExtent,
    double footerExtent,
  ) {
    final urls = _currentUrls;
    if (urls.isEmpty) {
      return _buildEmpty(context, t, headerExtent, footerExtent);
    }
    final images = _currentImages;
    final int columns = _columnsFor(width);

    return GridView.builder(
      controller: controller,
      // 顶栏与底栏浮在网格之上：这两段让位必须是列表**自己的** padding，
      // 在外面套 Padding 的话内容就滚不到它们背后去了。
      padding: EdgeInsets.fromLTRB(12, headerExtent, 12, footerExtent + 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: _cellGap,
        mainAxisSpacing: _cellGap,
      ),
      itemCount: urls.length,
      itemBuilder: (context, i) {
        // 网格里放缩略图，插进正文的是原图
        final String insertUrl = images != null && i < images.length
            ? images[i].url
            : urls[i];
        return _EmojiCell(thumbnailUrl: urls[i], onTap: () => _pick(insertUrl));
      },
    );
  }

  /// 列数按可用宽度算，不写死。
  int _columnsFor(double width) =>
      ((width - 24 + _cellGap) / (_cellTarget + _cellGap)).floor().clamp(4, 10);

  Widget _buildEmpty(
    BuildContext context,
    Translations t,
    double headerExtent,
    double footerExtent,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: headerExtent, bottom: footerExtent),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 44,
              color: cs.onSurface.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 12),
            Text(
              _groups.isEmpty ? t.emoji.noEmojis : t.emoji.noEmojisInGroup,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            if (_groups.isEmpty) ...[
              const SizedBox(height: 14),
              GlassButtonGroup(
                children: [
                  GlassTextActionButton(
                    label: t.emoji.addEmojis,
                    emphasized: true,
                    onPressed: () {
                      Navigator.pop(context);
                      NaviService.navigateToEmojiLibraryPage();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 骨架屏：用主题色的脉动，不用写死的灰。
  ///
  /// 旧版是 `Colors.grey[300]` / `Colors.grey[100]`，深色模式下是一片刺眼的
  /// 亮块；而且它把整套真实布局又抄了一遍（近 180 行），布局一改就对不上。
  Widget _buildSkeleton(
    BuildContext context,
    double headerExtent,
    double footerExtent,
  ) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _columnsFor(constraints.maxWidth);
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(12, headerExtent, 12, footerExtent + 10),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _cellGap,
            mainAxisSpacing: _cellGap,
          ),
          itemCount: columns * 4,
          itemBuilder: (context, i) => _SkeletonCell(
            color: cs.onSurface.withValues(alpha: 0.07),
            delayIndex: i,
          ),
        );
      },
    );
  }

  /// 浮在网格之上的底栏：左边尺寸、右边本次插入计数。
  ///
  /// 尺寸不在顶上——它是「插入时用多大」，属于动作的参数，和「这是什么弹层」
  /// 不是一类东西。
  Widget _buildFooter(BuildContext context, Translations t) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Builder(
          builder: (anchorContext) => GlassSurface(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            opensOverlay: true,
            onTap: () async {
              final picked = await showGlassMenu<EmojiSize>(
                anchorContext: anchorContext,
                entries: [
                  for (final size in EmojiSize.values)
                    GlassMenuOption<EmojiSize>(
                      value: size,
                      label: size.displayName,
                      selected: size == _selectedSize,
                    ),
                ],
              );
              if (picked != null) _changeSize(picked);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t.emoji.size} · ${_selectedSize.displayName}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more, size: 17, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        const Spacer(),
        // 插入反馈：连选时输入框被弹层盖着，没有这个就不确定插没插进去。
        // 「有出有入」：它是淡入 + 撑开的，不是硬切出现。
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _inserted == 0
              ? const SizedBox.shrink()
              : Text(
                  t.emoji.insertedCount(count: _inserted),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
        ),
      ],
    );
  }
}

/// 一枚表情格子。按下缩一点，给出「点到了」的反馈——连选时这个反馈尤其重要。
class _EmojiCell extends StatefulWidget {
  const _EmojiCell({required this.thumbnailUrl, required this.onTap});

  final String thumbnailUrl;
  final VoidCallback onTap;

  @override
  State<_EmojiCell> createState() => _EmojiCellState();
}

class _EmojiCellState extends State<_EmojiCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: widget.thumbnailUrl,
            fit: BoxFit.contain,
            httpHeaders: const {'referer': CommonConstants.iwaraBaseUrl},
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) => Icon(
              Icons.broken_image_outlined,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

/// 骨架格子：整片一起呼吸会像坏掉的闪烁，按索引错开相位才读得出「在加载」。
class _SkeletonCell extends StatefulWidget {
  const _SkeletonCell({required this.color, required this.delayIndex});

  final Color color;
  final int delayIndex;

  @override
  State<_SkeletonCell> createState() => _SkeletonCellState();
}

class _SkeletonCellState extends State<_SkeletonCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    // ⛔ 顺序不能倒过来：`value` 的 setter 自带一次 stop()，先 repeat 再错峰
    // 会把动画当场停死，整片骨架冻在各自的静态透明度上。
    _c.value = (widget.delayIndex % 7) / 7;
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_c),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
