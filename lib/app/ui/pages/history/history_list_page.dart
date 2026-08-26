import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/history_record.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/forum/widgets/thread_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/image_model_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/video_card_list_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/utils/media_layout_utils.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'controllers/history_list_controller.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/post_card_list_item_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// 历史记录页（玻璃化 + 瀑布/分页双模式）。
///
/// header 两行：第一行「返回 / 玻璃搜索框 / 动作胶囊」，第二行五段类型胶囊。
class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage>
    with SingleTickerProviderStateMixin {
  /// 标题行与分段行之间的间距。
  static const double _headerRowGap = 6;

  /// 分段行与列表首屏之间的呼吸。
  ///
  /// 单行 header 的 56 里天然留了 6 的余量（胶囊只有 44 高），两行 header 的
  /// 第二行高度就是胶囊高度、一点余量都没有——不补这一段，第一排卡片会紧贴
  /// 分段胶囊下沿。
  static const double _headerBottomGap = 8;

  static const List<String> _tags = ['all', 'video', 'image', 'post', 'thread'];

  static const String _menuActionTogglePagination = 'toggle_pagination';
  static const String _menuActionClear = 'clear_history';

  late TabController _tabController;
  late final List<HistoryListController> _controllers;

  final List<ScrollController> _scrollControllers = List.generate(
    _tags.length,
    (_) => ScrollController(),
  );

  /// 每个 tab 一个刷新信号：分页模式必须由 MediaListView 自己刷新，
  /// 直接 `repository.refresh()` 只会动数据源、不会换掉当前显示的那一页。
  final List<ValueNotifier<int>> _refreshSignals = List.generate(
    _tags.length,
    (_) => ValueNotifier<int>(0),
  );

  /// 搜索框：整页共用一个 controller，切 tab 时同步成该 tab 的关键字。
  final TextEditingController _searchController = TextEditingController();

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  /// 瀑布 ↔ 分页；初值取全局默认，切换后写回（跨页面、跨启动生效）。
  late bool _isPaginated = CommonConstants.isPaginated;

  HistoryListController get _currentController =>
      _controllers[_tabController.index];

  ScrollController get _currentScrollController =>
      _scrollControllers[_tabController.index];

  @override
  void initState() {
    super.initState();
    final historyRepo = HistoryRepository();

    _controllers = [
      for (final tag in _tags)
        Get.put(
          HistoryListController(historyRepository: historyRepo, itemType: tag),
          tag: tag,
        ),
    ];

    _tabController = TabController(length: _tags.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    for (final signal in _refreshSignals) {
      signal.dispose();
    }
    _searchController.dispose();
    _showBackToTop.dispose();
    for (final tag in _tags) {
      Get.delete<HistoryListController>(tag: tag);
    }
    super.dispose();
  }

  void _handleTabChange() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次
    if (_tabController.indexIsChanging) return;
    final controller = _currentController;
    // 搜索框跟随当前 tab 的关键字（各 tab 的筛选条件是分开的）
    final keyword = controller.searchKeyword.value;
    if (_searchController.text != keyword) {
      _searchController.text = keyword;
    }
    if (mounted) setState(() {});
    _syncBackToTop();
  }

  void _syncBackToTop() {
    final active = _currentScrollController;
    _showBackToTop.value = active.hasClients && active.position.pixels >= 300;
  }

  void _scrollToTop() {
    final active = _currentScrollController;
    if (active.hasClients) {
      active.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _togglePaginationMode() {
    setState(() => _isPaginated = !_isPaginated);
    persistPaginationMode(_isPaginated);
    // 分页与瀑布的下标口径不同，模式一换就把选择清掉
    _currentController.clearSelection();
  }

  void _onSearchChanged(String value) {
    _currentController.search(value);
    if (_isPaginated) {
      // 分页模式下数据源换了条件也得让 MediaListView 回到第一页重载
      _refreshSignals[_tabController.index].value++;
    }
  }

  /// 筛选条件变化后（排序 / 时间区间 / 删除区间记录）让当前页重新取数。
  void _notifyFilterChanged() {
    if (!_isPaginated) return;
    for (final signal in _refreshSignals) {
      signal.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + GlassTokens.pillHeight;
    final double headerExtent = statusBarHeight + headerHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    final tabItems = [
      GlassSegmentItem(label: t.common.all),
      GlassSegmentItem(label: t.common.video),
      GlassSegmentItem(label: t.common.gallery),
      GlassSegmentItem(label: t.common.post),
      GlassSegmentItem(label: t.forum.forum),
    ];

    return Scaffold(
      body: Obx(() {
        final controller = _currentController;
        final bool active = controller.isMultiSelect.value;
        final int count = controller.selectedRecords.length;
        return BatchSelectionScope(
          active: active,
          selectedCount: count,
          actions: [
            GlassSelectionAction(
              icon: Icons.delete,
              label: slang.t.common.delete,
              destructive: true,
              onPressed: count == 0
                  ? null
                  : () => _showDeleteConfirmDialog(controller),
            ),
          ],
          onClear: controller.clearSelection,
          // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
          child: SelectionPopScope(
            active: active,
            onExit: controller.toggleMultiSelect,
            child: _buildScaffoldBody(
              context,
              headerExtent: headerExtent,
              headerHeight: headerHeight,
              statusBarHeight: statusBarHeight,
              isWide: isWide,
              tabItems: tabItems,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScaffoldBody(
    BuildContext context, {
    required double headerExtent,
    required double headerHeight,
    required double statusBarHeight,
    required bool isWide,
    required List<GlassSegmentItem> tabItems,
  }) {
    final t = slang.Translations.of(context);
    return GlassHeaderOverlay(
      headerExtent: headerExtent,
      headerTop: statusBarHeight,
      headerHeight: headerHeight,
      solidExtent: statusBarHeight,
      liquid: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            _showBackToTop.value = notification.metrics.pixels >= 300;
          }
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            for (var i = 0; i < _tags.length; i++)
              _buildHistoryList(i, headerExtent),
          ],
        ),
      ),
      // header：第一行「返回 / 搜索 / 动作胶囊」，第二行五段类型胶囊
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
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
                  // 选择态下搜索框换成「已选 N 项」：单壳常驻、只换内容，
                  // 与下载列表页同一配方
                  Expanded(
                    child: Obx(
                      () => GlassCapsuleMorph(
                        child: _currentController.isMultiSelect.value
                            ? KeyedSubtree(
                                key: const ValueKey('selection'),
                                child: GlassSelectionSummary(
                                  selectedCount:
                                      _currentController.selectedRecords.length,
                                  allSelected: false,
                                  onToggleAll: null,
                                ),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('search'),
                                child: _buildSearchField(context, flat: true),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionGroup(context, isWide: isWide),
                ],
              ),
            ),
          ),
          const SizedBox(height: _headerRowGap),
          SizedBox(
            height: GlassTokens.pillHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GlassSegmentedControl(
                  selectedIndex: _tabController.index,
                  progress: _tabController.animation,
                  onChanged: _tabController.animateTo,
                  items: tabItems,
                ),
              ),
            ),
          ),
        ],
      ),
      extra: [
        _buildScrollToTopFab(context),
        // 批量动作：瀑布流模式下的底部玻璃坞；分页模式下动作行由分页栏
        // 自己承载（见 BatchSelectionScope），底部不会出现第二条玻璃。
        GlassSelectionDock(paginated: _isPaginated),
      ],
    );
  }

  /// 玻璃搜索框：胶囊底 + 细描边，有输入时右侧长出清空钮。
  /// [flat] = true 时不自带玻璃壳：壳由外层的 [GlassCapsuleMorph] 常驻提供，
  /// 搜索框与「已选 N 项」之间才是同一只胶囊在换内容，而不是两只胶囊硬切。
  Widget _buildSearchField(BuildContext context, {bool flat = false}) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: GlassTokens.pillHeight,
      decoration: flat
          ? null
          : BoxDecoration(
              color: GlassTokens.fill(colorScheme),
              borderRadius: BorderRadius.circular(GlassTokens.pillHeight / 2),
              border: Border.all(
                color: GlassTokens.stroke(colorScheme),
                width: GlassTokens.strokeWidth,
              ),
            ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          hintText: t.common.searchHistoryRecords,
          hintStyle: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) => GlassGroupSlot(
              visible: value.text.isNotEmpty,
              child: IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: t.common.clear,
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// 右侧动作胶囊：[瀑布/分页(宽屏)] 筛选(生效时挂红点) · 多选
  /// [清空历史(宽屏)] [更多(窄屏，收分页切换 + 清空历史)]。
  ///
  /// 没有刷新键：历史记录是本地库，只会被 App 自己的操作改动（浏览、删除、
  /// 清空都会就地刷新列表），留一个手动刷新纯属占位；真要重拉还有下拉刷新。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    return Obx(() {
      final controller = _currentController;
      final bool filterActive =
          controller.selectedDateRange.value != null ||
          controller.orderByUpdated.value;
      final bool isMultiSelect = controller.isMultiSelect.value;

      return GlassButtonGroup(
        children: [
          GlassGroupSlot(
            visible: isWide,
            child: GlassIconButton(
              icon: Icon(_isPaginated ? Icons.grid_view : Icons.view_stream),
              tooltip: _isPaginated
                  ? t.common.pagination.waterfall
                  : t.common.pagination.pagination,
              onPressed: _togglePaginationMode,
            ),
          ),
          GlassIconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: t.common.selectDateRange,
            // 有筛选条件生效时挂小红点
            showBadge: filterActive,
            onPressed: _showFilterSheet,
          ),
          GlassIconButton(
            // 多选↔退出在同一按钮位上交叉过渡
            icon: Icon(isMultiSelect ? Icons.close : Icons.checklist),
            tooltip: isMultiSelect ? t.common.exitEditMode : t.common.editMode,
            onPressed: controller.toggleMultiSelect,
          ),
          GlassGroupSlot(
            visible: isWide,
            child: GlassIconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: t.common.clearAllHistory,
              onPressed: _showClearHistoryDialog,
            ),
          ),
          // 窄屏胶囊塞不下五个键，分页切换与清空历史收进这里
          GlassGroupSlot(
            visible: !isWide,
            child: Builder(
              builder: (anchorContext) => GlassIconButton(
                icon: const Icon(Icons.more_vert),
                tooltip: t.common.more,
                // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
                // 松手选中（见 GlassTapArea.opensOverlay）。
                opensOverlay: true,
                onPressed: () => _openMoreMenu(anchorContext),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 窄屏「更多」菜单：分页切换 + 清空历史。
  Future<void> _openMoreMenu(BuildContext anchorContext) async {
    final t = slang.Translations.of(anchorContext);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuOption(
          value: _menuActionTogglePagination,
          icon: _isPaginated ? Icons.grid_view : Icons.view_stream,
          // 文案与图标一致：显示将要切换到的模式
          label: _isPaginated
              ? t.common.pagination.waterfall
              : t.common.pagination.pagination,
        ),
        GlassMenuOption(
          value: _menuActionClear,
          icon: Icons.delete_sweep,
          label: t.common.clearAllHistory,
          destructive: true,
        ),
      ],
    );
    if (picked == null) return;
    switch (picked) {
      case _menuActionTogglePagination:
        _togglePaginationMode();
      case _menuActionClear:
        _showClearHistoryDialog();
    }
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮；分页模式下抬到分页栏之上。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom:
          computeBottomSafeInset(MediaQuery.of(context)) +
          16 +
          (_isPaginated ? PaginationBar.barHeight : 0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showBackToTop,
        builder: (context, visible, _) => GlassReveal(
          visible: visible,
          builder: (context, m) => GlassIconButton(
            materialize: m,
            standalone: true,
            icon: const Icon(Icons.vertical_align_top),
            tooltip: t.common.scrollToTop,
            onPressed: _scrollToTop,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(int index, double headerExtent) {
    final controller = _controllers[index];
    return MediaListView<HistoryRecord>(
      sourceList: controller.repository,
      isPaginated: _isPaginated,
      refreshSignal: _refreshSignals[index],
      scrollController: _scrollControllers[index],
      paddingTop: headerExtent + _headerBottomGap,
      emptyIcon: Icons.history,
      // 换页后原来勾的已经不在屏幕上了，留着只会误删
      onPageChanged: controller.clearSelection,
      itemBuilder: (context, record, _) =>
          _buildHistoryItem(context, record, controller),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    HistoryRecord record,
    HistoryListController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaLayoutUtils.calculateCardWidth(
                MediaQuery.sizeOf(context).width,
              );

        return Obx(() {
          final bool isSelected = controller.selectedRecords.contains(
            record.id,
          );
          final bool isMultiSelect = controller.isMultiSelect.value;
          final dynamic originalData = record.getOriginalData();

          return SizedBox(
            width: itemWidth,
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(itemWidth < 220 ? 6 : 8),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.itemType == 'video')
                        VideoCardListItemWidget(
                          video: originalData,
                          width: itemWidth,
                        )
                      else if (record.itemType == 'image')
                        ImageModelCardListItemWidget(
                          imageModel: originalData,
                          width: itemWidth,
                        )
                      else if (record.itemType == 'post')
                        PostCardListItemWidget(post: originalData)
                      else if (record.itemType == 'thread')
                        ThreadListItemWidget(
                          thread: originalData,
                          categoryId: originalData.section,
                        ),
                      _buildHistoryItemFooter(record, controller),
                    ],
                  ),
                  // 选择态：角标勾选片 + 选中描边（全站统一，
                  // 见 GlassSelectableOverlay）。常驻挂载以获得进出过渡。
                  Positioned.fill(
                    child: GlassSelectableOverlay(
                      selectionMode: isMultiSelect,
                      selected: isSelected,
                      borderRadius: BorderRadius.circular(
                        itemWidth < 220 ? 6 : 8,
                      ),
                    ),
                  ),
                  if (isMultiSelect)
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.toggleSelection(record.id),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildHistoryItemFooter(
    HistoryRecord record,
    HistoryListController controller,
  ) {
    // 获取类型对应的颜色和图标
    final (color, icon) = _getItemTypeStyle(record.itemType);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示时间
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Obx(() {
                final useUpdated = controller.orderByUpdated.value;
                final dt = useUpdated ? record.updatedAt : record.createdAt;
                return Text(
                  CommonUtils.formatFriendlyTimestamp(dt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // 显示类型
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      _getItemTypeText(record.itemType),
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 删除按钮
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _showDeleteRecordDialog(record, controller),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getItemTypeStyle(String type) {
    switch (type) {
      case 'video':
        return (Colors.blue, Icons.play_circle_outline);
      case 'image':
        return (Colors.green, Icons.image_outlined);
      case 'post':
        return (Colors.orange, Icons.article_outlined);
      case 'thread':
        return (Colors.purple, Icons.forum_outlined);
      default:
        return (Colors.grey, Icons.help_outline);
    }
  }

  String _getItemTypeText(String type) {
    switch (type) {
      case 'video':
        return slang.t.common.video;
      case 'image':
        return slang.t.common.gallery;
      case 'post':
        return slang.t.common.post;
      case 'thread':
        return slang.t.forum.forum;
      default:
        return type;
    }
  }

  Future<void> _selectDateRange() async {
    final controller = _currentController;
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.selectedDateRange.value,
    );

    if (picked != null && picked != controller.selectedDateRange.value) {
      controller.setDateRange(picked);
      _notifyFilterChanged();
    }
  }

  void _clearDateRange() {
    _currentController.setDateRange(null);
    _notifyFilterChanged();
  }

  void _showFilterSheet() {
    final controller = _currentController;
    showAppBottomSheet(
      _FilterSheet(
        controller: controller,
        onSelectDateRange: _selectDateRange,
        onClearDateRange: _clearDateRange,
        onOrderChanged: (v) {
          controller.setOrderByUpdated(v);
          _notifyFilterChanged();
        },
        onDeleteRange: () => _confirmDeleteSelectedRange(controller),
      ),
      isScrollControlled: true,
    );
  }

  /// 删除前确认：先统计数量，无记录则提示，否则弹出确认框。
  Future<void> _confirmDeleteSelectedRange(
    HistoryListController controller,
  ) async {
    final count = await controller.countRecordsInSelectedRange();
    if (count == 0) {
      showGlassToast(
        slang.t.common.noHistoryRecordsInRange,
        type: GlassToastType.info,
      );
      return;
    }
    if (!mounted) return;
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.common.confirmDelete,
        content: Text(
          slang.t.common.deleteRecordsInDateRangeConfirm(num: count),
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.delete,
            emphasized: false,
            destructive: true,
            onPressed: () async {
              AppService.tryPop(); // 关闭确认框
              await controller.deleteRecordsInSelectedRange();
              _notifyFilterChanged();
              AppService.tryPop(); // 关闭筛选面板
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteRecordDialog(
    HistoryRecord record,
    HistoryListController controller,
  ) {
    showAppDialog(
      GlassAlertDialog(
        title: slang.t.common.confirmDelete,
        content: Text(
          slang.t.common.areYouSureYouWantToDeleteSelectedItems(num: 1),
        ),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.delete,
            emphasized: false,
            destructive: true,
            onPressed: () async {
              AppService.tryPop();
              await controller.historyDatabaseRepository.deleteRecord(
                record.id,
              );
              await controller.repository.refresh(true);
              _notifyFilterChanged();
              showGlassToast(
                slang.t.common.success,
                type: GlassToastType.success,
              );
            },
          ),
        ],
      ),
    );
  }

  /// 批量删除确认：走全站统一的玻璃确认弹窗（含所选预览）。
  Future<void> _showDeleteConfirmDialog(
    HistoryListController controller,
  ) async {
    final count = controller.selectedRecords.length;
    if (count == 0) return;
    final confirmed = await showBatchConfirmDialog(
      title: slang.t.common.confirmDelete,
      message: slang.t.common.areYouSureYouWantToDeleteSelectedItems(
        num: count,
      ),
      confirmLabel: slang.t.common.delete,
      previewTitles: _selectedHistoryTitles(controller),
      totalCount: count,
    );
    if (!confirmed || !mounted) return;
    await controller.deleteSelected();
    _notifyFilterChanged();
  }

  /// 取所选历史项的标题，供确认弹窗列出「到底要删哪几条」。
  List<String> _selectedHistoryTitles(HistoryListController controller) {
    final selected = controller.selectedRecords;
    final titles = <String>[];
    for (final record in controller.repository) {
      if (!selected.contains(record.id)) continue;
      final title = record.title.trim();
      titles.add(title.isEmpty ? slang.t.common.noTitle : title);
      if (titles.length >= 3) break;
    }
    return titles;
  }

  void _showClearHistoryDialog() {
    final controller = _currentController;
    final itemType = controller.itemType;

    showAppDialog(
      GlassAlertDialog(
        title: slang.t.common.clearAllHistory,
        content: Text(slang.t.common.clearAllHistoryConfirm),
        actions: [
          GlassDialogAction(
            label: slang.t.common.cancel,
            emphasized: false,
            onPressed: () => AppService.tryPop(),
          ),
          GlassDialogAction(
            label: slang.t.common.confirm,
            emphasized: false,
            destructive: true,
            onPressed: () async {
              await controller.clearHistoryByType(itemType);
              _notifyFilterChanged();
              AppService.tryPop();
            },
          ),
        ],
      ),
    );
  }
}

/// 筛选面板：排序开关 + 时间区间 + 按区间删除。
class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.controller,
    required this.onSelectDateRange,
    required this.onClearDateRange,
    required this.onOrderChanged,
    required this.onDeleteRange,
  });

  final HistoryListController controller;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClearDateRange;
  final ValueChanged<bool> onOrderChanged;
  final VoidCallback onDeleteRange;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          // 底部一律走统一入口，别自己拼 viewInsets + 安全区
          padding: EdgeInsets.only(
            left: 20,
            right: 16,
            top: 12,
            bottom: computeSheetBottomInset(context) + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行：标题 + 玻璃关闭圆钮
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.common.selectDateRange,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.close,
                    onPressed: () => AppService.tryPop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 排序开关：创建时间/更新时间（倒序）
              Obx(
                () => GlassSwitchItem(
                  icon: Icons.swap_vert,
                  title: Text(
                    controller.orderByUpdated.value
                        ? t.common.updatedAt
                        : t.common.publishedAt,
                  ),
                  subtitle: const Text('(DESC)'),
                  value: controller.orderByUpdated.value,
                  onChanged: onOrderChanged,
                ),
              ),
              const SizedBox(height: 8),
              // 时间区间：按钮一行 + 结果单独下一行
              Obx(() {
                final dateRange = controller.selectedDateRange.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 8),
                        Expanded(child: Text(t.common.selectDateRange)),
                        if (dateRange != null)
                          IconButton(
                            tooltip: t.common.clearDateRange,
                            icon: const Icon(Icons.clear),
                            onPressed: onClearDateRange,
                          ),
                        FilledButton(
                          onPressed: onSelectDateRange,
                          child: Text(t.common.selectDateRange),
                        ),
                      ],
                    ),
                    if (dateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 32),
                        child: Text(
                          '${CommonUtils.formatDate(dateRange.start)} - ${CommonUtils.formatDate(dateRange.end)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              // 删除当前所选时间范围内的历史记录（仅在已选范围时可用）
              Obx(() {
                final hasRange = controller.selectedDateRange.value != null;
                final errorColor = colorScheme.error;
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: hasRange ? onDeleteRange : null,
                    icon: const Icon(Icons.delete_sweep),
                    label: Text(t.common.deleteRecordsInDateRange),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: BorderSide(
                        color: hasRange
                            ? errorColor.withValues(alpha: 0.5)
                            : Theme.of(
                                context,
                              ).disabledColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
