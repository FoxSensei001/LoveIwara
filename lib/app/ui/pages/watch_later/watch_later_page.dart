import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/playback_queue.dart';
import 'package:i_iwara/app/models/watch_later_item.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/playback_queue_service.dart';
import 'package:i_iwara/app/services/watch_later_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';

/// 「稍后再看」列表页。
///
/// # 版式
///
/// header 只有一行（与热门视频页同一条配方）：
///
///     [返回] [视频 ▾]        …………        [ ⚙ │ 清除 │ ☑ ]
///
/// 左边是**在看什么**（类型），右边那坨玻璃里是**对这批东西做的事**：一枚键
/// 管筛选 + 排序（点开是分两组的菜单）、一枚键清掉已看完的、一枚键进批量编辑。
///
/// ⛔ 五处刻意的选型：
/// - **没有标题**——左边的类型钮已经把页面身份讲清楚了，再挂一枚标题胶囊
///   只是白占地方；
/// - **类型在左、动作在右**：类型是「我现在看的是哪一堆」，和其它页 header 上
///   「当前是谁」的胶囊同一个位置；筛选/排序/清除/批量都是施加在这一堆上的
///   动作，归到右边那组去；
/// - 类型不是分段胶囊：只有两档、撑不起一整行 header。当前值用
///   [GlassFlipLabel] 接 `TabController.animation` **逐帧**跟着横滑
///   [TabBarView] 翻牌，分段胶囊那份「跟手」并没有丢；
/// - ⛔ **没有 `⋮`**：一个更多菜单里躺着两组毫不相干的东西读起来就是杂物
///   抽屉。筛选（全部 / 未看完）与排序（最近 / 最早）各只有两档，合并成一枚
///   `tune` 键、菜单里分两组各自打勾；清除已看完是**动作**不是选项，单独
///   成键（仍然先弹确认）；
/// - ⛔ **条目上没有横滑删除**：这一页的列表躺在 [TabBarView] 里，横向手势
///   属于「视频 ↔ 图库」。两者抢同一个方向，想切 tab 而手指落在某一条上，
///   切过去的同时那条就没了（2026-08-29 报障）。移除改由批量编辑承担。
///
/// # 批量编辑
///
/// 进选择态是一次**页面级的模式切换**（全站同一套表达，见 [GlassSelectionDock]
/// 那个文件头）：类型胶囊原壳换成「已选 N 项 + 全选」、筛选与清除两个位收走、
/// 批量键原位换成 ☒、底部浮起动作坞、系统返回先退选择态。两处本页特有的：
///
/// - **锁掉横滑**：选择态下换 tab 的入口本来就没了（胶囊被占着），手滑换成
///   另一类的话，勾着的还是上一类的东西；
/// - **给全选**：这一页的列表整份都在内存里，不像热门页那种懒加载的无限列表
///   ——那边够不着还没加载的部分所以刻意不给全选键，这边够得着。
///
/// 移除**不弹确认**，靠撤销兜（整批一个事务删、撤销整批还原，连加入时间一起）
/// ——确认是"每次都要多点一下"，撤销只在真的点错时才花那一下。
///
/// ⛔ 类型牌面必须 `stableWidth`：常驻胶囊里宽度不能再逐帧变，否则外壳的
/// `AnimatedSize` 追不上、easy 档锁死的宽度还会把字裁掉。
///
/// ⛔ **没有"全部（视频图库混排）"这个视图**：类型是硬分家的两个 tab。混排唯一
/// 的用处是"播放全部"，而那个按钮已经砍掉了。
///
/// ⛔ **没有「播放全部」按钮**：进播放器靠点某一条 + 池内续播。
class WatchLaterPage extends StatefulWidget {
  const WatchLaterPage({super.key});

  @override
  State<WatchLaterPage> createState() => _WatchLaterPageState();
}

class _WatchLaterPageState extends State<WatchLaterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _configService = Get.find<ConfigService>();

  /// 「全部 / 未看完」。刻意**不持久化**：它是"我现在想看哪一批"的临时意图，
  /// 排序才是长期偏好。
  bool _unwatchedOnly = false;

  /// 批量编辑（选择态）。
  ///
  /// ⛔ 这套东西是来**顶替横滑删除**的，不是加在它旁边：这一页的列表本身躺在
  /// [TabBarView] 里，横向手势属于「视频 ↔ 图库」。条目上再挂一个横滑删除，
  /// 用户想切 tab 却把手指落在了某一条上，切过去的同时那条就没了
  /// （2026-08-29 报障）。两个手势抢同一个方向，只能让出来一个。
  ///
  /// 参照热门视频页那套批量选择（`BatchSelectController` + [GlassSelectionDock]）
  /// 的表达，但**状态留在本页自己手里**：那份控制器按 `Video` / `ImageModel`
  /// 取 id，认不得 [WatchLaterItem]；而这一页的列表整份都在内存里（不是懒加载
  /// 的无限列表），几十行 `Set<String>` 就够，不值得为它去改公共控制器。
  bool _selecting = false;

  /// 已选中的条目键（`类型:id`，与 [WatchLaterItem] 的唯一约束一致）。
  final Set<String> _selectedKeys = <String>{};

  /// 两个 tab **各存各的**。
  ///
  /// ⛔ 原先只留一份 `_items`（当前 tab 的那份）喂给 [TabBarView] 的两个孩子，
  /// 于是横滑到一半时右边那页画的是**左边这页的数据**——视频躺在图库页上，
  /// 滑完 tab 监听器才重查一次把它抹掉。「滑动过程中图库里有视频」就是这么来的。
  List<WatchLaterItem> _videoItems = const [];
  List<WatchLaterItem> _imageItems = const [];

  @override
  void initState() {
    super.initState();
    // 默认落「视频」tab、不记忆上次：两个 tab 内容差异大，记忆会让人以为东西丢了。
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        // ⛔ 这只监听器在横滑 TabBarView 时**一帧一响**。原先每响一次就重查一遍
        // 库（还带排序）+ setState 重建整页，白白拖慢滑动。现在两个 tab 的数据
        // 各存各的、header 那两枚钮自己接 `_tabController.animation` 连续插值，
        // 这里只剩下记一个落位下标，不需要重建。
        _tabIndex = _tabController.index;
      });
    WatchLaterService.to.watchLaterChangedNotifier.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    WatchLaterService.to.watchLaterChangedNotifier.removeListener(_reload);
    _tabController.dispose();
    super.dispose();
  }

  /// 已落位的 tab 下标（横滑途中不跟着变，见 [initState] 里的监听器）。
  int _tabIndex = 0;

  WatchLaterItemType get _currentType =>
      _tabIndex == 0 ? WatchLaterItemType.video : WatchLaterItemType.image;

  WatchLaterSort get _sort => WatchLaterSort.fromConfigValue(
    _configService[ConfigKey.WATCH_LATER_SORT_KEY] as String?,
  );

  static String _keyOf(WatchLaterItem item) =>
      '${item.itemType.name}:${item.itemId}';

  List<WatchLaterItem> get _currentItems =>
      _tabIndex == 0 ? _videoItems : _imageItems;

  bool get _allSelected {
    final items = _currentItems;
    if (items.isEmpty) return false;
    return items.every((item) => _selectedKeys.contains(_keyOf(item)));
  }

  void _toggleSelection(WatchLaterItem item) {
    final key = _keyOf(item);
    setState(() {
      if (!_selectedKeys.remove(key)) _selectedKeys.add(key);
    });
  }

  void _toggleSelectAll() {
    final items = _currentItems;
    if (items.isEmpty) return;
    final allSelected = _allSelected;
    setState(() {
      for (final item in items) {
        final key = _keyOf(item);
        if (allSelected) {
          _selectedKeys.remove(key);
        } else {
          _selectedKeys.add(key);
        }
      }
    });
  }

  void _setSelecting(bool selecting) {
    setState(() {
      _selecting = selecting;
      // 退出即清空：留着上一轮的勾，下次进来会莫名其妙已经选中几条。
      if (!selecting) _selectedKeys.clear();
    });
  }

  /// 把选中的这些移出稍后再看。整批走一个事务，撤销把它们整批放回去
  /// （连加入时间一起还原，见 [WatchLaterService.restore]）。
  ///
  /// ⛔ 不弹确认框：撤销比确认好——确认是"每次都要多点一下"，撤销只在真的
  /// 点错时才花那一下。这也和它顶替掉的横滑删除保持一致。
  void _removeSelected(slang.Translations t) {
    final targets = _currentItems
        .where((item) => _selectedKeys.contains(_keyOf(item)))
        .toList(growable: false);
    if (targets.isEmpty) return;

    final removed = WatchLaterService.to.removeAll(targets);
    _setSelecting(false);
    if (removed <= 0) return;
    showAppToast(
      t.watchLater.removedCount(count: removed),
      type: AppToastType.info,
      actionLabel: t.watchLater.undo,
      // 点了「撤销」这条提示自己就收了（见 app_toast.dart 的动作钮），不用再
      // dismissAppToasts()——那会把同时挂着的其它提示一并抹掉。
      onAction: () {
        for (final item in targets) {
          WatchLaterService.to.restore(item);
        }
      },
    );
  }

  void _reload() {
    if (!mounted) return;
    final sort = _sort;
    setState(() {
      _videoItems = WatchLaterService.to.query(
        itemType: WatchLaterItemType.video,
        unwatchedOnly: _unwatchedOnly,
        sort: sort,
      );
      _imageItems = WatchLaterService.to.query(
        itemType: WatchLaterItemType.image,
        unwatchedOnly: _unwatchedOnly,
        sort: sort,
      );
      // 库变了（别处移除、筛选换了一批）之后，勾在已经不在列表里的条目上的
      // 选择必须一并去掉，否则「已选 3 项」里有两项根本看不见。
      if (_selectedKeys.isNotEmpty) {
        final alive = <String>{
          for (final item in _videoItems) _keyOf(item),
          for (final item in _imageItems) _keyOf(item),
        };
        _selectedKeys.removeWhere((key) => !alive.contains(key));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    const headerHeight = GlassTokens.headerRowHeight;

    return Scaffold(
      // 选择态下先吃掉一次返回（系统返回键 / iOS 侧滑 / Esc）：勾了几十项被
      // 一次误触整页弹掉太亏。
      body: SelectionPopScope(
        active: _selecting,
        onExit: () => _setSelecting(false),
        child: GlassHeaderOverlay(
          headerExtent: statusBarHeight + headerHeight,
          headerTop: statusBarHeight,
          headerHeight: headerHeight,
          solidExtent: statusBarHeight,
          liquid: true,
          header: _buildHeader(context, t),
          extra: [
            GlassSelectionDock(
              visible: _selecting,
              selectedCount: _selectedKeys.length,
              onClear: () => setState(_selectedKeys.clear),
              actions: [
                GlassSelectionAction(
                  icon: Icons.playlist_remove,
                  label: t.watchLater.removeFromWatchLater,
                  destructive: true,
                  onPressed: () => _removeSelected(t),
                ),
              ],
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            // ⛔ 选择态下锁掉横滑：类型胶囊此刻是「已选 N 项」，换 tab 的入口
            // 本来就没了；手一滑换成另一类，勾着的还是上一类的东西。
            physics: _selecting
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),
            children: [
              _buildList(
                context,
                t,
                statusBarHeight + headerHeight,
                WatchLaterItemType.video,
              ),
              _buildList(
                context,
                t,
                statusBarHeight + headerHeight,
                WatchLaterItemType.image,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, slang.Translations t) {
    final cs = Theme.of(context).colorScheme;
    // TabController 的 animation 是小数下标（横滑途中带小数）。理论上恒非空，
    // 兜一个静止值免得空断言。
    final ValueListenable<double> tabProgress =
        _tabController.animation ??
        AlwaysStoppedAnimation<double>(_tabIndex.toDouble());

    return SizedBox(
      height: GlassTokens.headerRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.arrow_back),
              tooltip: t.common.back,
              onPressed: () => AppService.tryPop(),
            ),
            const SizedBox(width: 8),
            // 类型（视频 / 图库）：**页面此刻在看什么**，所以挨着返回钮放在
            // 最左——和其它页 header 上「当前是谁」的胶囊同一个位置。
            // 独立一只胶囊（壳由 GlassCapsuleMorph 提供），不进右边那组。
            GlassCapsuleMorph(
              // 选择态下这只胶囊改报「已选 N 项」：进选择态是一次页面级的模式
              // 切换，header 不该毫无反应。壳还是同一只，所以进出是一次宽度
              // 形变而不是硬切（与热门页同一条配方）。
              child: _selecting
                  ? SizedBox(
                      key: const ValueKey('selection'),
                      // 「全选」在这一页是够得着的：列表整份都在内存里，不像
                      // 热门页那种懒加载的无限列表。
                      width: 208,
                      child: GlassSelectionSummary(
                        selectedCount: _selectedKeys.length,
                        allSelected: _allSelected,
                        onToggleAll: _currentItems.isEmpty
                            ? null
                            : _toggleSelectAll,
                      ),
                    )
                  : GlassDropdownTrigger(
                      key: const ValueKey('type'),
                      onTap: (anchorContext) => _openTypeMenu(anchorContext, t),
                      child: IconTheme.merge(
                        data: IconThemeData(color: cs.onSurface, size: 16),
                        child: GlassFlipLabel(
                          progress: tabProgress,
                          // 恒宽：翻牌途中胶囊宽度不跟着抖（见类注释）。
                          stableWidth: true,
                          labels: [t.common.video, t.common.gallery],
                          icons: const [
                            Icon(Icons.video_library_outlined),
                            Icon(Icons.photo_library_outlined),
                          ],
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
            const Spacer(),
            const SizedBox(width: 8),
            // 右边这一组全是**对当前这批东西做的事**：怎么筛怎么排、清掉哪些。
            // 两个位共处一坨玻璃。
            GlassButtonGroup(
              // 选择态会把前两个位收走，宽度跟着变——签名要带上它。
              touchFlexSignature: 'watch-later|$_selecting',
              children: [
                // 筛选与排序合并成**一枚**键：这页的筛选只有「全部 /
                // 未看完」两档、排序只有「最近 / 最早」两档，各占一个位是把
                // 一行 header 摊给了四个选项。点开是一张分两组的菜单
                // （筛选 / 排序），两组各自打勾。
                //
                // ⛔ 所以它是图标而不是带当前值的下拉钮：一枚钮管着两个维度，
                // 标签上只写其中一个（"未看完 ▾"）会读成"这只管筛选"。
                // 当前是否有非默认筛选生效改用小红点表达（全站同一套约定，
                // 见热门页的筛选键）。
                // 选择态下这两个位收走：此刻能做的只有「勾/取消勾」和底部
                // 那条坞里的动作，筛选与清除都不该在这时候插一脚。
                GlassGroupSlot(
                  visible: !_selecting,
                  child: Builder(
                    builder: (buttonContext) => GlassIconButton(
                      icon: const Icon(Icons.tune),
                      tooltip: '${t.common.filter} · ${t.common.sort}',
                      showBadge: _unwatchedOnly,
                      opensOverlay: true,
                      onPressed: () => _openFilterSortMenu(buttonContext, t),
                    ),
                  ),
                ),
                GlassGroupSlot(
                  visible: !_selecting,
                  child: GlassIconButton(
                    icon: const Icon(Icons.cleaning_services_outlined),
                    tooltip: t.watchLater.clearWatched,
                    onPressed: () => _clearWatched(t),
                  ),
                ),
                // 批量编辑 ↔ 退出：**同一枚键留在原位**做图标交叉过渡，
                // 不是「一枚消失、另一枚冒出来」（见 GlassIconButton 内的
                // GlassAnimatedIcon）。
                GlassIconButton(
                  icon: Icon(_selecting ? Icons.close : Icons.checklist),
                  tooltip: _selecting
                      ? t.common.exitEditMode
                      : t.common.editMode,
                  onPressed: () => _setSelecting(!_selecting),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 「视频 / 图库」的下拉。选中的那档打勾，选完滑到对应 tab（不是硬切：
  /// [TabController.animateTo] 走的还是那段横滑动画，牌面跟着一起翻）。
  Future<void> _openTypeMenu(
    BuildContext anchorContext,
    slang.Translations t,
  ) async {
    final picked = await showGlassMenu<int>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuOption<int>(
          value: 0,
          label: t.common.video,
          icon: Icons.video_library_outlined,
          selected: _tabIndex == 0,
        ),
        GlassMenuOption<int>(
          value: 1,
          label: t.common.gallery,
          icon: Icons.photo_library_outlined,
          selected: _tabIndex == 1,
        ),
      ],
    );
    if (picked == null || !mounted || picked == _tabController.index) return;
    _tabController.animateTo(picked);
  }

  static const String _filterAllValue = 'filter:all';
  static const String _filterUnwatchedValue = 'filter:unwatched';

  /// 筛选 + 排序的合并菜单：两组，各自打勾，选回原值不做事。
  ///
  /// 「全部 / 未看完」是**筛选**不是第三个 tab（它不换内容的种类，只把同一批
  /// 东西筛掉一半），所以和排序一样是菜单里的一组，而不是 header 上的 tab。
  Future<void> _openFilterSortMenu(
    BuildContext anchorContext,
    slang.Translations t,
  ) async {
    final sort = _sort;
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuSectionHeader(t.common.filter),
        GlassMenuOption<String>(
          value: _filterAllValue,
          label: t.watchLater.filterAll,
          icon: Icons.select_all,
          selected: !_unwatchedOnly,
        ),
        GlassMenuOption<String>(
          value: _filterUnwatchedValue,
          label: t.watchLater.filterUnwatched,
          icon: Icons.hourglass_bottom,
          selected: _unwatchedOnly,
        ),
        const GlassMenuSeparator(),
        GlassMenuSectionHeader(t.common.sort),
        GlassMenuOption<String>(
          value: WatchLaterSort.recentlyAdded.name,
          label: t.watchLater.sortRecentlyAdded,
          icon: Icons.arrow_downward,
          selected: sort == WatchLaterSort.recentlyAdded,
        ),
        GlassMenuOption<String>(
          value: WatchLaterSort.earliestAdded.name,
          label: t.watchLater.sortEarliestAdded,
          icon: Icons.arrow_upward,
          selected: sort == WatchLaterSort.earliestAdded,
        ),
      ],
    );
    if (picked == null || !mounted) return;

    if (picked == _filterAllValue || picked == _filterUnwatchedValue) {
      final unwatchedOnly = picked == _filterUnwatchedValue;
      if (unwatchedOnly == _unwatchedOnly) return;
      setState(() => _unwatchedOnly = unwatchedOnly);
      _reload();
      return;
    }

    if (picked == sort.name) return;
    _configService.setSetting(ConfigKey.WATCH_LATER_SORT_KEY, picked);
    _reload();
  }

  /// 一键清掉当前这一类里所有「已看完」的条目。
  Future<void> _clearWatched(slang.Translations t) async {
    // 批量物理删除、且没有 undo，必须先问一句——本项目的原则是"点一下东西
    // 就消失很惊悚"，批量版本只会更惊悚。这枚键从菜单里挪到 header 上之后
    // 更近了，这句确认也就更不能省。
    final confirmed = await showAppDialog<bool>(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: t.watchLater.clearWatched,
          content: Text(t.watchLater.clearWatchedConfirm),
          actions: [
            GlassDialogAction(
              label: t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            GlassDialogAction(
              label: t.common.confirm,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    final removed = WatchLaterService.to.clearWatched(itemType: _currentType);
    showAppToast(
      removed > 0
          ? t.watchLater.watchedCleared(count: removed)
          : t.watchLater.noWatchedToClear,
      type: removed > 0 ? AppToastType.success : AppToastType.info,
    );
  }

  Widget _buildList(
    BuildContext context,
    slang.Translations t,
    double topInset,
    WatchLaterItemType type,
  ) {
    final items = type == WatchLaterItemType.video ? _videoItems : _imageItems;
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: topInset),
        child: MyEmptyWidget(
          // 「未看完」筛掉之后的空，和"一条都没加过"不是一回事——
          // 后者说"还没有加入"是误导。
          message: _unwatchedOnly
              ? (type == WatchLaterItemType.video
                    ? t.watchLater.emptyUnwatchedVideo
                    : t.watchLater.emptyUnwatchedGallery)
              : (type == WatchLaterItemType.video
                    ? t.watchLater.emptyVideo
                    : t.watchLater.emptyGallery),
        ),
      );
    }

    return ListView.builder(
      // ⛔ 不写 padding 会白继承 MediaQuery 的竖直 padding，首屏被 header 盖住。
      padding: EdgeInsets.only(
        top: topInset,
        // 选择态下再让出一条坞的高度：动作坞浮在列表上方，不让位的话最后
        // 一两条永远压在坞底下，而它们恰恰是最可能要勾的那几条。
        bottom:
            MediaQuery.paddingOf(context).bottom + 24 + (_selecting ? 68 : 0),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // ⛔ 这里原先是 `Dismissible`（右滑删除）。删掉不是因为它不好用，而是
        // 它和这一页的 [TabBarView] 抢同一个方向的手势：想从「视频」滑到
        // 「图库」，手指落在某一条上就把那条删了（2026-08-29 报障）。同一件事
        // 现在由批量编辑承担——看得见勾、能撤销、也不会被手滑触发。
        return _WatchLaterTile(
          key: ValueKey(_keyOf(item)),
          item: item,
          unwatchedOnly: _unwatchedOnly,
          selectionMode: _selecting,
          selected: _selectedKeys.contains(_keyOf(item)),
          onToggleSelect: () => _toggleSelection(item),
        );
      },
    );
  }
}

/// 一条稍后再看。
///
/// 失效的条目**不会静默消失**：继续用本地快照把卡片画出来，整只压暗并挂一枚
/// 「已失效」角标，点它只弹提示而不进播放器。既然定了"只标记不自动删"，就得
/// 让人一眼看出这条是死的，否则列表里会躺着一堆点了没反应的卡片。
class _WatchLaterTile extends StatelessWidget {
  const _WatchLaterTile({
    super.key,
    required this.item,
    required this.unwatchedOnly,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelect,
  });

  final WatchLaterItem item;

  /// 页面处于批量编辑态：点这一条是「勾上 / 取消勾」，而不是打开它。
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelect;

  /// 列表页当前的筛选。**筛选是池身份的一部分**（`watchLater:all` /
  /// `watchLater:unwatched` 是两个池），所以点进播放器时要原样带过去——
  /// 用户在「未看完」里点开一条，接下来续播的当然也该是「未看完」那一批。
  final bool unwatchedOnly;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        if (selectionMode) {
          // 失效的条目照样能选——批量移除本来就是清理它们最顺手的路子。
          onToggleSelect();
          return;
        }
        if (item.isInvalid) {
          showAppToast(
            t.watchLater.invalidItem,
            type: AppToastType.warning,
          );
          return;
        }
        if (item.itemType == WatchLaterItemType.video) {
          // 把稍后再看池一起交出去：「接着看」一开就落在稍后再看上，而不是
          // 一个笼统的「来源」。
          final queue = PlaybackQueueService.to.openWatchLater(
            unwatchedOnly: unwatchedOnly,
          );
          NaviService.navigateToVideoDetailPage(
            item.itemId,
            playbackQueueRef: PlaybackQueueRef(
              queueId: queue.queueId,
              currentItemId: item.itemId,
            ),
            skipWatchedInQueue: unwatchedOnly,
          );
        } else {
          // 图库那一支是**另一个池**（`watchLater:*:gallery`），同样交出去。
          final queue = PlaybackQueueService.to.openWatchLater(
            unwatchedOnly: unwatchedOnly,
            mediaType: PlaybackMediaType.gallery,
          );
          NaviService.navigateToGalleryDetailPage(
            item.itemId,
            playbackQueueRef: PlaybackQueueRef(
              queueId: queue.queueId,
              currentItemId: item.itemId,
            ),
          );
        }
      },
      child: Opacity(
        // 失效项整只压暗。这里用 Opacity 是安全的：本行不是玻璃体，
        // 不存在"打断折射"的问题。
        opacity: item.isInvalid ? 0.45 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context, cs),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? t.common.noTitle : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if ((item.author ?? '').isNotEmpty)
                      Text(
                        item.author!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.isInvalid)
                          _Badge(
                            label: t.watchLater.invalidItem,
                            color: cs.error,
                          )
                        else if (item.isWatched)
                          // ⛔ 别拿「未看完」的文案划一道删除线来表示"已看完"：
                          // 读屏会直接念出"未看完"，语义正好相反。
                          _Badge(
                            label: t.watchLater.watched,
                            color: cs.onSurfaceVariant,
                          ),
                        if (item.numImages != null)
                          Text(
                            '${item.numImages}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, ColorScheme cs) {
    final radius = BorderRadius.circular(8);
    return SizedBox(
      width: 132,
      height: 74,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: cs.surfaceContainerHighest),
            if ((item.thumbnailUrl ?? '').isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                fit: BoxFit.cover,
                // 视频被删掉之后 CDN 上的封面也可能 404，得有占位兜底，
                // 否则失效项会变成一块破图。
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
            if (item.durationMs != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    child: Text(
                      CommonUtils.formatDuration(
                        Duration(milliseconds: item.durationMs!),
                      ),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
              ),
            // 观看进度条：贴着封面下沿，和播放器里的进度条读起来是同一件事。
            if (item.progressRatio > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: item.progressRatio,
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            // 选择态的勾与描边挂在封面上（而不是罩住整行）：批量移除最需要
            // 看清自己在删什么，标题作者一个字都不该被盖。
            GlassSelectableOverlay(
              selectionMode: selectionMode,
              selected: selected,
              borderRadius: radius,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(label, style: TextStyle(fontSize: 11, color: color)),
        ),
      ),
    );
  }
}
