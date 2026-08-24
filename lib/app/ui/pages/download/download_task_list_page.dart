import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_task.model.dart';
import 'package:i_iwara/app/models/download/download_task_ext_data.model.dart';
import 'package:i_iwara/app/services/download/download_state_log.dart';
import 'package:i_iwara/app/services/download/download_task_store.dart';
import 'package:i_iwara/app/repositories/download_task_repository.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_category_picker.dart'
    show openDownloadCategoryManagePage;
import 'package:i_iwara/app/ui/pages/download/widgets/move_to_category_sheet.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/default_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/download_scale.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/video_download_task_item_widget.dart';
import 'package:i_iwara/app/ui/pages/download/widgets/gallery_download_task_item_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

/// Status filter options for download tasks
enum DownloadStatusFilter { all, failed, downloaded }

/// Type filter options for download tasks
enum DownloadTypeFilter { all, video, gallery, other }

/// 下载任务列表页（玻璃化）。
///
/// header 两行：第一行「返回 / 中间胶囊（搜索框 ↔ 已选计数）/ 动作胶囊」，
/// 第二行分类标签条。状态 / 类型筛选收进筛选弹窗，生效时动作胶囊上挂红点。
class DownloadTaskListPage extends StatefulWidget {
  const DownloadTaskListPage({super.key});

  @override
  State<DownloadTaskListPage> createState() => _DownloadTaskListPageState();
}

class _DownloadTaskListPageState extends State<DownloadTaskListPage> {
  /// 标题行与分类条之间的间距。
  static const double _headerRowGap = 6;

  /// 分类条与列表首屏之间的呼吸。
  ///
  /// 单行 header 的 56 里天然留了余量（胶囊只有 44 高），两行 header 的第二行
  /// 高度就是胶囊高度、一点余量都没有——不补这一段，第一张卡片会紧贴分类条下沿。
  static const double _headerBottomGap = 8;

  /// 分类条所占行高（与玻璃胶囊同高，标签本体略矮居中）。
  static const double _categoryStripHeight = GlassTokens.pillHeight;

  /// 分类标签本体高度。
  static const double _categoryChipHeight = 36;

  static const String _menuActionManageCategory = 'manageCategory';
  static const String _menuActionDeleteByDate = 'deleteByDate';
  static const String _menuActionResumeAll = 'resumeAll';
  static const String _menuActionPauseAll = 'pauseAll';

  final DownloadTaskRepository _downloadTaskRepository =
      DownloadTaskRepository();
  final ScrollController _scrollController = ScrollController();
  // 分类标签条的横向滚动控制器（用于鼠标滚轮转横向滑动）
  final ScrollController _categoryStripController = ScrollController();
  late _HistoryDownloadTasksSource _historySource;

  /// 列表滚过一段距离后显示右下角「回到顶部」浮钮。
  final ValueNotifier<bool> _showBackToTop = ValueNotifier<bool>(false);

  /// 搜索输入防抖：每敲一个字都要走三条本地 DB 查询 + 历史区串行刷新，
  /// 不防抖既浪费查询，也让筛选钮的沙漏态一路抽搐。
  Timer? _searchDebounce;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 300);

  /// 活跃任务（下载中 / 等待 / 暂停 / 失败）的内存单一真源。
  ///
  /// 这四个区不再各自查库、也不再有页面级快照：分区由 Store 按状态唯一决定，
  /// 页面只负责「订阅 + 筛选 + 渲染」。此前为了兜住「各区独立重查」带来的不一致，
  /// 这里曾经并存四套补丁（脏标记重跑、刷新串行化、删除墓碑、跨区去重集合），
  /// 随着真源合一它们全部失去存在意义，已一并删除。
  DownloadTaskStore get _store => DownloadService.to.store;

  // 历史区域（已完成任务，DB 分页）刷新串行化：LoadingMoreBase 不支持并发
  // refresh，并发会相互 clear/addAll 造成列表被清空或漏掉“刚完成”的任务。
  bool _isRefreshingHistory = false;
  bool _historyRefreshDirty = false;

  /// 历史区失效信号的订阅（任务完成 / 删除 / 改分类时由 Store 递增）。
  Worker? _completedRevisionWorker;

  // 批量删除模式
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};

  // Filter state
  String _searchQuery = '';
  DownloadStatusFilter _statusFilter = DownloadStatusFilter.all;
  DownloadTypeFilter _typeFilter = DownloadTypeFilter.all;
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterLoading = false;

  /// 分类筛选状态：`all` | `uncategorized` | 具体分类 id。
  ///
  /// 分类列表本身不再有页面快照——它是 [DownloadService.categories] 这个可观察
  /// 状态，标签条直接 Obx 读。这里只留「当前选中哪个」这一个纯 UI 状态。
  String _categoryFilter = 'all';

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedTaskIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTaskIds.clear();
    });
  }

  void _toggleItemSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  /// 批量删除确认：走全站统一的玻璃确认弹窗（含所选预览）。
  ///
  /// 原先这里是裸 `showDialog + AlertDialog`——没走 `showAppDialog`，出入场
  /// 动画与全站不是一套；主按钮还只写着「确认」，看不出按下去会发生什么。
  Future<void> _deleteSelectedTasks() async {
    if (_selectedTaskIds.isEmpty) return;

    final t = slang.Translations.of(context);
    final confirmed = await showBatchConfirmDialog(
      title: t.common.confirmDelete,
      // 删的是已经落盘的文件，不像取消最爱那样能点回来，措辞要说清楚
      message: t.download.deleteByDate.confirmContent(
        count: _selectedTaskIds.length,
      ),
      confirmLabel: t.common.delete,
      previewTitles: _selectedTaskTitles(),
      totalCount: _selectedTaskIds.length,
    );

    if (!confirmed || !mounted) return;
    await DownloadService.to.deleteTasks(_selectedTaskIds.toList());
    _exitSelectionMode();
  }

  /// 取所选任务的标题，供确认弹窗列出「到底要删哪几个」。
  List<String> _selectedTaskTitles() {
    final titles = <String>[];
    for (final task in [..._store.activeTasks, ..._historySource]) {
      if (!_selectedTaskIds.contains(task.id)) continue;
      final title = task.fileName.trim();
      titles.add(title.isEmpty ? task.id : title);
      if (titles.length >= 3) break;
    }
    return titles;
  }

  /// 入口：打开“按日期删除”弹窗，拿到用户选择的日期条件后进入确认与删除流程。
  Future<void> _showDeleteByDateDialog() async {
    final selection = await showModalBottomSheet<_DateDeletionSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _DeleteByDateDialog(),
    );
    if (selection == null || !mounted) return;
    await _confirmAndDeleteByDate(selection);
  }

  /// 查询匹配任务 -> 二次确认 -> 带进度删除 -> 结果提示 -> 刷新列表。
  Future<void> _confirmAndDeleteByDate(_DateDeletionSelection selection) async {
    final t = slang.Translations.of(context);

    // 1. 查询区间内的任务（任意状态）。
    List<DownloadTask> tasks;
    try {
      tasks = await _downloadTaskRepository.getTasksByCreatedDateRange(
        start: selection.start,
        end: selection.end,
      );
    } catch (_) {
      if (!mounted) return;
      showGlassToast(
        t.download.errors.failedToLoadTasks,
        type: GlassToastType.error,
      );
      return;
    }
    if (!mounted) return;

    if (tasks.isEmpty) {
      showGlassToast(
        t.download.deleteByDate.noMatch,
        type: GlassToastType.warning,
      );
      return;
    }

    // 2. 二次确认（明确告知数量与不可撤销）。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => GlassAlertDialog(
        title: t.download.deleteByDate.confirmTitle,
        content: Text(
          t.download.deleteByDate.confirmContent(count: tasks.length),
        ),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            emphasized: false,
            onPressed: () => Navigator.pop(context, false),
          ),
          GlassDialogAction(
            label: t.common.confirm,
            emphasized: false,
            destructive: true,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 3. 执行删除（耗时操作，弹出不可关闭的进度弹窗）。
    final result = await showDialog<DeleteTasksResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteProgressDialog(tasks: tasks),
    );
    if (!mounted || result == null) return;

    // 4. 结果提示：全部成功 / 部分被占用跳过。
    if (result.skipped == 0) {
      showGlassToast(
        t.download.deleteByDate.resultSuccess(count: result.deleted),
        type: GlassToastType.success,
      );
    } else {
      showGlassToast(
        t.download.deleteByDate.resultPartial(
          deleted: result.deleted,
          skipped: result.skipped,
        ),
        type: GlassToastType.warning,
      );
    }

    // 5. 刷新历史区（活跃区已由 Store 在删除时同步移除，无需刷新）。
    await _refreshHistory();
  }

  @override
  void initState() {
    super.initState();
    _historySource = _HistoryDownloadTasksSource(_downloadTaskRepository);
    // 分类条与活跃区都不需要订阅：它们直接 Obx 读服务里的可观察状态
    //（DownloadService.categories / store 的分区 id 列表）。这里只补一次分类装载，
    // 覆盖「服务启动早于本页、期间分类被别处改过」的情况。
    unawaited(DownloadService.to.refreshCategories());

    // 需要订阅的只剩一件事：历史区（已完成任务分页在 DB 里，不在内存真源）。
    _completedRevisionWorker = ever(_store.completedRevision, (int revision) {
      DownloadStateLog.receive(
        this,
        DownloadService.to,
        'completedRevision',
        detail: 'v=$revision',
      );
      _runAfterFrame(() {
        DownloadStateLog.apply(this, 'refreshHistory', detail: 'v=$revision');
        _refreshHistory();
      });
    });
  }

  /// 在下一帧结束后执行 [action]（仍挂载时），用于把 setState / DB 读等副作用移出
  /// build / 通知阶段。
  ///
  /// 关键：addPostFrameCallback 只是登记回调，本身不会请求新的一帧。应用空闲时
  /// （未在下载、无动画、无 setState 待处理）注册的回调会一直挂起不执行——这正是
  /// “没有下载任务时删除列表项不刷新、必须重进页面才看到被删除”的根因：删除是异步
  /// 的（文件 IO + DB），完成并广播时确认弹窗的关闭动画往往已结束、界面进入空闲，
  /// 于是回调永远等不到下一帧。这里追加 ensureVisualUpdate() 主动安排一帧，确保
  /// 回调及时执行；若当前正处于某一帧之中则它无操作（本帧的 postFrame 回调照常触发）。
  void _runAfterFrame(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _completedRevisionWorker?.dispose();
    _scrollController.dispose();
    _categoryStripController.dispose();
    _showBackToTop.dispose();
    _historySource.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        GlassTokens.headerRowHeight + _headerRowGap + _categoryStripHeight;
    final double headerExtent = statusBarHeight + headerHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 没有 AppBar 就没人管状态栏图标明暗，不显式声明会沿用上一页
      //（如视频详情页的白色图标），在浅色背景下看不见。
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: BatchSelectionScope(
          active: _isSelectionMode,
          selectedCount: _selectedTaskIds.length,
          actions: _batchActions(context),
          onClear: () => setState(_selectedTaskIds.clear),
          // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整页弹掉
          child: SelectionPopScope(
            active: _isSelectionMode,
            onExit: _exitSelectionMode,
            child: DownloadScaleScope(
              child: GlassHeaderOverlay(
                liquid: true,
                headerExtent: headerExtent,
                headerTop: statusBarHeight,
                headerHeight: headerHeight,
                solidExtent: statusBarHeight,
                body: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.depth == 0 &&
                        notification.metrics.axis == Axis.vertical) {
                      _showBackToTop.value = notification.metrics.pixels >= 300;
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    // 指示器从玻璃 header 下方弹出，而不是被 header 压住
                    displacement: headerExtent,
                    onRefresh: _refreshAll,
                    child: Obx(() {
                      // 只订阅活跃区的**结构**变化（新增 / 删除 / 换区）——读一下四个
                      // id 列表即可。进度、速度这类每秒多次的更新不走这里，它们由每行
                      // 自己的 progress trigger 承载，因此长列表不会被进度刷爆。
                      _store.downloadingIds.length;
                      _store.pendingIds.length;
                      _store.pausedIds.length;
                      _store.failedIds.length;
                      return _buildSingleList(headerExtent + _headerBottomGap);
                    }),
                  ),
                ),
                // header：第一行「返回 / 搜索或已选计数 / 动作胶囊」，第二行分类条
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
                              tooltip: slang.Translations.of(
                                context,
                              ).common.back,
                              onPressed: () => AppService.tryPop(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _buildCenterCapsule(context)),
                            const SizedBox(width: 8),
                            _buildActionGroup(context, isWide: isWide),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: _headerRowGap),
                    // 分类标签条：始终显示，便于发现并进入分类系统
                    // （无分类时显示「全部 + 管理分类」入口）。
                    _buildCategoryStrip(),
                  ],
                ),
                extra: [
                  _buildScrollToTopFab(context),
                  // 批量动作：下载列表是单列长列表、没有分页栏，永远走底部玻璃坞
                  const GlassSelectionDock(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 下拉刷新：历史区 + 分类计数重拉。
  ///
  /// 活跃区不在此列——它读的是内存真源，永远是最新的，没有「刷新」这个概念。
  Future<void> _refreshAll() async {
    await Future.wait([
      _refreshHistory(),
      DownloadService.to.refreshCategories(),
    ]);
  }

  /// header 中间的胶囊：普通模式是搜索框，多选模式换成「已选 N 条」。
  ///
  /// 两侧都是玻璃胶囊，走 [GlassCapsuleMorph] 单壳常驻、内容交接，
  /// 而不是两只胶囊硬切。
  Widget _buildCenterCapsule(BuildContext context) {
    return GlassCapsuleMorph(
      child: _isSelectionMode
          ? KeyedSubtree(
              key: const ValueKey('selection'),
              child: _buildSelectionSummary(context),
            )
          : KeyedSubtree(
              key: const ValueKey('search'),
              child: _buildSearchContent(context),
            ),
    );
  }

  /// 搜索胶囊的内容（无壳，玻璃壳由 [GlassCapsuleMorph] 提供）。
  Widget _buildSearchContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 14),
        Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: t.download.searchTasks,
              hintStyle: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // 有输入时右侧长出清空钮（跟输入框实时走，不等防抖）
        ValueListenableBuilder<TextEditingValue>(
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
        const SizedBox(width: 4),
      ],
    );
  }

  /// 多选模式下中间胶囊的内容：已选数量。
  Widget _buildSelectionSummary(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(width: 14),
        Icon(Icons.checklist, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t.common.selectedRecords(num: _selectedTaskIds.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }

  /// 右侧动作胶囊：[全部开始 · 全部暂停(宽屏)] 筛选(生效挂红点) · 多选
  /// [更多(管理分类 / 按日期删除，窄屏再收下全部开始 · 全部暂停)]。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    // 多选时「全部开始 / 全部暂停 / 更多」与当前语境无关，一并挤出胶囊
    final bool showBulkPlayback = isWide && !_isSelectionMode;

    return GlassButtonGroup(
      children: [
        GlassGroupSlot(
          visible: showBulkPlayback,
          child: GlassIconButton(
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: t.download.resumeAll,
            onPressed: () => DownloadService.to.resumeAll(),
          ),
        ),
        GlassGroupSlot(
          visible: showBulkPlayback,
          child: GlassIconButton(
            icon: const Icon(Icons.pause_outlined),
            tooltip: t.download.pauseAll,
            onPressed: () => DownloadService.to.pauseAll(),
          ),
        ),
        GlassIconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: t.searchFilter.filterSettings,
          // 状态 / 类型是收在弹窗里的条件，生效时用红点告诉用户「有东西在筛」。
          // 不挂 loading：这枚键自己的动作是「弹出筛选面板」，一瞬间的事；
          // 真正耗时的重查发生在列表里，由列表自己的加载指示器交代。
          showBadge: _hasSheetFilter,
          onPressed: _openFilterSheet,
        ),
        GlassIconButton(
          // 多选↔退出在同一按钮位上交叉过渡
          icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
          tooltip: _isSelectionMode ? t.common.exitEditMode : t.common.editMode,
          onPressed: _isSelectionMode
              ? _exitSelectionMode
              : _enterSelectionMode,
        ),
        GlassGroupSlot(
          visible: !_isSelectionMode,
          // "更多"菜单位：玻璃图标钮（放在按钮组里，非 standalone）+ 玻璃菜单
          child: Builder(
            builder: (anchorContext) => GlassIconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: t.download.moreOptions,
              // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
              // 松手选中（见 GlassTapArea.opensOverlay）。
              opensOverlay: true,
              onPressed: () => _openMoreMenu(anchorContext, isWide),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMoreMenu(BuildContext anchorContext, bool isWide) async {
    final t = slang.Translations.of(anchorContext);
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        // 窄屏胶囊塞不下批量播放控制，收进这里
        if (!isWide) ...[
          GlassMenuOption(
            value: _menuActionResumeAll,
            icon: Icons.play_arrow_outlined,
            label: t.download.resumeAll,
          ),
          GlassMenuOption(
            value: _menuActionPauseAll,
            icon: Icons.pause_outlined,
            label: t.download.pauseAll,
          ),
          const GlassMenuSeparator(),
        ],
        GlassMenuOption(
          value: _menuActionManageCategory,
          icon: Icons.folder_outlined,
          label: t.download.category.manageTitle,
        ),
        GlassMenuOption(
          value: _menuActionDeleteByDate,
          icon: Icons.auto_delete_outlined,
          label: t.download.deleteByDate.menuTitle,
          destructive: true,
        ),
      ],
    );
    if (picked == null) return;
    // 菜单是独立路由，选完这一帧触发件可能已不在树上，用到 State 前判 mounted。
    if (!mounted) return;
    switch (picked) {
      case _menuActionManageCategory:
        _openCategoryManagePage();
      case _menuActionDeleteByDate:
        _showDeleteByDateDialog();
      case _menuActionResumeAll:
        DownloadService.to.resumeAll();
      case _menuActionPauseAll:
        DownloadService.to.pauseAll();
    }
  }

  void _openCategoryManagePage() => openDownloadCategoryManagePage(context);

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    return Positioned(
      right: 16,
      bottom: computeBottomSafeInset(MediaQuery.of(context)) + 16,
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

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// 选择态下可用的批量动作：删除（主，error 实心）· 移至分类（次，图标位）。
  List<GlassSelectionAction> _batchActions(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool hasSelection = _selectedTaskIds.isNotEmpty;
    return [
      GlassSelectionAction(
        icon: Icons.delete,
        label: t.common.delete,
        destructive: true,
        onPressed: hasSelection ? _deleteSelectedTasks : null,
      ),
      GlassSelectionAction(
        icon: Icons.drive_file_move_outline,
        label: t.download.category.moveTo,
        onPressed: hasSelection ? _moveSelectedToCategory : null,
      ),
    ];
  }

  /// 状态 / 类型筛选是否生效（分类筛选有分类条直观呈现，不算在内）。
  bool get _hasSheetFilter =>
      _statusFilter != DownloadStatusFilter.all ||
      _typeFilter != DownloadTypeFilter.all;

  /// 是否存在任意筛选条件（用于区分「暂无任务」与「无匹配结果」）。
  bool get _hasAnyFilter =>
      _hasSheetFilter || _categoryFilter != 'all' || _searchQuery.isNotEmpty;

  /// 打开筛选弹窗：一次改完状态 + 类型再应用，不像原来两个下拉各触发一次重查。
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_DownloadFilterSelection>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DownloadFilterSheet(
        initial: _DownloadFilterSelection(
          status: _statusFilter,
          type: _typeFilter,
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (result.status == _statusFilter && result.type == _typeFilter) return;
    setState(() {
      _statusFilter = result.status;
      _typeFilter = result.type;
    });
    _applyFilters();
  }

  void _clearFilters() {
    // 防抖里可能还压着一次「旧关键字」的重查，先作废，否则清完又被写回来
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = DownloadStatusFilter.all;
      _typeFilter = DownloadTypeFilter.all;
      _categoryFilter = 'all';
    });
    _applyFilters();
  }

  /// 切换当前分类筛选。
  void _onCategorySelected(String value) {
    if (_categoryFilter == value) return;
    setState(() => _categoryFilter = value);
    _applyFilters();
  }

  /// 实际生效的分类筛选。
  ///
  /// 选中的分类可能已被删除（在管理页删掉、或被别处清空），此时按「全部」处理。
  /// 这里做成**纯计算**而不是去改 `_categoryFilter`：状态只有一份、由分类列表当场
  /// 决定，不需要一个「发现分类没了就回写筛选」的副作用——那种回写既要挑时机，
  /// 写错时机就会留下一个点不掉的空筛选。
  String get _effectiveCategoryFilter {
    final filter = _categoryFilter;
    if (filter == 'all') return 'all';
    final categories = DownloadService.to.categories;
    // 「未分类」只在有分类时才有意义（无分类时它等同「全部」）。
    if (filter == 'uncategorized') {
      return categories.isEmpty ? 'all' : 'uncategorized';
    }
    return categories.any((c) => c.id == filter) ? filter : 'all';
  }

  /// 批量「移至分类」：用已选任务打开移动弹窗，移动后退出多选。
  Future<void> _moveSelectedToCategory() async {
    if (_selectedTaskIds.isEmpty) return;
    final moved = await showMoveToCategorySheet(
      context,
      _selectedTaskIds.toList(),
    );
    if (moved == true) _exitSelectionMode();
  }

  /// 顶部分类标签条：管理入口 / 全部 / 未分类 / 各分类（带计数）。
  ///
  /// 标签本体是玻璃胶囊（选中态换成高亮底色），与 header 上的胶囊同族，
  /// 不再用 Material 的 ChoiceChip / ActionChip。
  ///
  /// 数据直接来自 [DownloadService.categories] 这个可观察状态：在管理页新建 /
  /// 删除 / 改名的那一刻，这里就已经是最新的了。此前它读的是页面自己的一份快照，
  /// 靠 worker + 帧回调去补——那条链断掉时没有任何报错，表现就是「返回列表页没有
  /// 新分类，下拉刷新才出来」。
  Widget _buildCategoryStrip() {
    return Obx(() => _buildCategoryStripContent(context));
  }

  Widget _buildCategoryStripContent(BuildContext context) {
    final t = slang.Translations.of(context);
    final categories = DownloadService.to.categories;
    final uncategorizedCount = DownloadService.to.uncategorizedCount.value;
    final activeFilter = _effectiveCategoryFilter;

    return SizedBox(
      height: _categoryStripHeight,
      child: Listener(
        // 鼠标悬浮在分类条上滚动滚轮时，把纵向滚轮增量转成横向滑动。
        // 仅当分类条确有横向可滚动空间时才接管事件，否则交还底层纵向列表。
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              _categoryStripController.hasClients) {
            final maxExtent = _categoryStripController.position.maxScrollExtent;
            if (maxExtent <= 0) return;
            final delta = event.scrollDelta.dy != 0
                ? event.scrollDelta.dy
                : event.scrollDelta.dx;
            GestureBinding.instance.pointerSignalResolver.register(event, (e) {
              if (!_categoryStripController.hasClients) return;
              final target = (_categoryStripController.offset + delta).clamp(
                0.0,
                _categoryStripController.position.maxScrollExtent,
              );
              _categoryStripController.jumpTo(target);
            });
          }
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView(
            controller: _categoryStripController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 管理 / 新建入口放在最前：无分类时用更醒目的「管理分类」标签。
              _buildCategoryChip(
                label: categories.isEmpty
                    ? t.download.category.manageTitle
                    : t.download.category.manage,
                icon: categories.isEmpty
                    ? Icons.create_new_folder_outlined
                    : Icons.settings_outlined,
                selected: false,
                onTap: _openCategoryManagePage,
              ),
              _buildCategoryChip(
                label: t.common.all,
                selected: activeFilter == 'all',
                onTap: () => _onCategorySelected('all'),
              ),
              // 「未分类」仅在已有分类时才有意义（无分类时等同「全部」）。
              if (categories.isNotEmpty)
                _buildCategoryChip(
                  label: t.download.category.uncategorized,
                  count: uncategorizedCount,
                  selected: activeFilter == 'uncategorized',
                  onTap: () => _onCategorySelected('uncategorized'),
                ),
              for (final c in categories)
                _buildCategoryChip(
                  label: c.title,
                  count: c.itemCount ?? 0,
                  selected: activeFilter == c.id,
                  onTap: () => _onCategorySelected(c.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 单枚分类标签：玻璃胶囊，选中态换高亮底色（底色 / 文字色都带过渡，
  /// 切分类时是「同一枚标签亮起来」，不是瞬间换一块颜色）。
  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    int? count,
    IconData? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final Color foreground = selected
        ? cs.onSecondaryContainer
        : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Center(
        child: GlassPressable(
          onTap: onTap,
          scale: 0.95,
          builder: (context, pressed) => AnimatedContainer(
            duration: GlassTokens.motionDuration,
            curve: GlassTokens.motionCurve,
            height: _categoryChipHeight,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected
                  ? GlassTokens.selectedHighlight(cs)
                  : (pressed
                        ? GlassTokens.pressedFill(cs)
                        : GlassTokens.fill(cs)),
              borderRadius: BorderRadius.circular(_categoryChipHeight / 2),
              border: Border.all(
                color: GlassTokens.stroke(cs),
                width: GlassTokens.strokeWidth,
              ),
              boxShadow: GlassTokens.shadow(cs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foreground),
                  const SizedBox(width: 6),
                ],
                AnimatedDefaultTextStyle(
                  duration: GlassTokens.motionDuration,
                  curve: GlassTokens.motionCurve,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                  child: Text(count != null ? '$label · $count' : label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 搜索输入：防抖后再落到筛选上。
  ///
  /// 每次 [_applyFilters] 都是三条本地 DB 查询 + 一轮串行历史刷新，逐字符触发
  /// 既浪费查询，也让筛选钮的沙漏态一路抽搐。
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value == _searchQuery) return;
    _searchDebounce = Timer(_searchDebounceDelay, () {
      if (!mounted || value == _searchQuery) return;
      setState(() {
        _searchQuery = value;
      });
      _applyFilters();
    });
  }

  /// 应用筛选条件。
  ///
  /// 活跃区是纯内存过滤（[_visibleTasksOf]），条件一改下一帧就生效；这里只需要把
  /// 条件同步给历史区的分页数据源并让它重拉。沙漏态因此只覆盖历史区这一次查询。
  void _applyFilters() async {
    final statusFilterStr = switch (_statusFilter) {
      DownloadStatusFilter.all => 'all',
      DownloadStatusFilter.failed => 'failed',
      DownloadStatusFilter.downloaded => 'downloaded',
    };
    final typeFilterStr = switch (_typeFilter) {
      DownloadTypeFilter.all => 'all',
      DownloadTypeFilter.video => 'video',
      DownloadTypeFilter.gallery => 'gallery',
      DownloadTypeFilter.other => 'other',
    };

    // Show loading indicator
    setState(() {
      _isFilterLoading = true;
    });

    _historySource.updateFilters(
      searchQuery: _searchQuery,
      statusFilter: statusFilterStr,
      typeFilter: typeFilterStr,
      categoryFilter: _categoryFilter,
    );
    // 历史区域通过串行刷新触发（updateFilters 不再自行 refresh，避免并发）
    await _refreshHistory();

    // Hide loading indicator
    if (mounted) {
      setState(() {
        _isFilterLoading = false;
      });
    }
  }

  /// Check if a task matches the current filter criteria
  bool _filterTask(DownloadTask task) {
    // Check if any filter is active
    final hasActiveFilter =
        _searchQuery.isNotEmpty ||
        _statusFilter != DownloadStatusFilter.all ||
        _typeFilter != DownloadTypeFilter.all ||
        _categoryFilter != 'all';

    // If no filter is active, show all
    if (!hasActiveFilter) return true;

    // Search query filter
    if (_searchQuery.isNotEmpty) {
      if (!task.fileName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
    }

    // Status filter - for active sections, we need different logic
    // 'all' shows everything, 'failed' shows only failed, 'downloaded' shows only completed
    switch (_statusFilter) {
      case DownloadStatusFilter.failed:
        if (task.status != DownloadStatus.failed) return false;
        break;
      case DownloadStatusFilter.downloaded:
        if (task.status != DownloadStatus.completed) return false;
        break;
      case DownloadStatusFilter.all:
        // Show all statuses
        break;
    }

    // Type filter
    switch (_typeFilter) {
      case DownloadTypeFilter.video:
        if (task.extData?.type != DownloadTaskExtDataType.video) return false;
        break;
      case DownloadTypeFilter.gallery:
        if (task.extData?.type != DownloadTaskExtDataType.gallery) return false;
        break;
      case DownloadTypeFilter.other:
        if (task.extData != null &&
            (task.extData!.type == DownloadTaskExtDataType.video ||
                task.extData!.type == DownloadTaskExtDataType.gallery)) {
          return false;
        }
        break;
      case DownloadTypeFilter.all:
        // Show all types
        break;
    }

    // Category filter
    switch (_categoryFilter) {
      case 'all':
        break;
      case 'uncategorized':
        if (task.categoryId != null) return false;
        break;
      default:
        if (task.categoryId != _categoryFilter) return false;
        break;
    }

    return true;
  }

  /// 构建空状态视图。
  /// - 存在搜索 / 筛选条件时：提示无匹配结果，并提供“清除筛选”入口。
  /// - 无任何任务时：提示暂无下载任务。
  Widget _buildEmptyState({required bool hasActiveFilter}) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilter ? Icons.search_off : Icons.download_done_outlined,
              size: 64 * DownloadUiScale.of(context),
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? t.download.noMatchingTasks
                  : t.download.emptyTaskList,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilter) ...[
              const SizedBox(height: 16),
              GlassButtonGroup(
                children: [
                  GlassTextActionButton(
                    label: t.download.clearFilters,
                    onPressed: _clearFilters,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 单列列表：顶部「下载中 / 失败 / 等待」活跃区 + 底部无限滚动的历史区。
  ///
  /// [topPadding] 是玻璃 header 需要让出的高度——留白必须由列表自身的
  /// SliverPadding 提供，不能在外面套 Padding，否则内容滚不到 header 背后。
  Widget _buildSingleList(double topPadding) {
    // 活跃区四个分区全部来自内存真源。分区由任务状态唯一决定，因此：
    // - 同一任务不可能同时出现在两个区（旧实现要靠 seenIds 跨区去重）；
    // - 也不可能与底部历史区重复（历史区只装 completed，见 _HistoryDownloadTasksSource）。
    // 这两条不变式让此前的跨区去重集合、删除墓碑一并成为多余，已删除。
    final downloadingTasks = _visibleTasksOf(_store.downloadingIds);
    final filteredFailedTasks = _visibleTasksOf(_store.failedIds);
    final filteredPausedTasks = _visibleTasksOf(_store.pausedIds);
    final filteredPendingTasks = _visibleTasksOf(_store.pendingIds);

    // 构建顶部活跃区域的 widgets
    final List<Widget> activeWidgets = [];

    void addSection(String title, List<DownloadTask> tasks) {
      if (tasks.isEmpty) return;
      activeWidgets.add(_buildSectionHeader(title: title, count: tasks.length));
      activeWidgets.addAll(tasks.map((task) => _buildActiveTaskItem(task.id)));
    }

    // 顺序：下载中 → 失败（方便快速重试）→ 暂停 → 等待中
    addSection(slang.t.download.downloading, downloadingTasks);
    addSection(slang.t.download.failed, filteredFailedTasks);
    addSection(slang.t.download.paused, filteredPausedTasks);
    addSection(slang.t.download.waiting, filteredPendingTasks);

    // 是否存在搜索 / 筛选条件（用于区分“暂无任务”与“无匹配结果”）
    final bool hasActiveFilter = _hasAnyFilter;
    // 顶部活跃区域是否有内容（决定 history 为空时是否接管为整页空状态）
    final bool hasActiveWidgets = activeWidgets.isNotEmpty;

    return LoadingMoreCustomScrollView(
      controller: _scrollController,
      // 空列表也要能下拉（否则筛不到结果时刷不了）
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // 顶部留白，为悬浮的玻璃 header（标题行 + 分类条）让出位置
        SliverPadding(padding: EdgeInsets.only(top: topPadding)),
        // 「上次未完成的任务已暂停」提示条（仅本次启动确有被暂停的任务时出现）
        SliverToBoxAdapter(child: _buildRestoredPausedBanner(context)),
        // 顶部活跃区域
        if (hasActiveWidgets)
          SliverList(delegate: SliverChildListDelegate(activeWidgets)),
        // 底部历史区域（无限滚动）
        LoadingMoreSliverList<DownloadTask>(
          SliverListConfig<DownloadTask>(
            itemBuilder: (context, task, index) {
              return _buildHistoryItemWithDateHeader(task, index);
            },
            sourceList: _historySource,
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              computeBottomSafeInset(MediaQuery.of(context)) +
                  (_isSelectionMode ? 80 : 0), // 多选模式下增加底部padding防止遮挡
            ),
            indicatorBuilder: (context, status) {
              // history 为空时：若顶部活跃区域也无内容，则用自定义整页空状态
              // 接管（区分“暂无任务”/“无匹配结果”）；否则保持默认指示器。
              if (status == IndicatorStatus.empty &&
                  !hasActiveWidgets &&
                  !_isFilterLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(hasActiveFilter: hasActiveFilter),
                );
              }
              return myLoadingMoreIndicator(
                context,
                status,
                isSliver: true,
                loadingMoreBase: _historySource,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建历史任务条目，按天插入日期标题。
  ///
  /// 历史区只装已完成任务，与活跃区没有交集，因此这里不再需要任何隐藏 / 去重判断
  /// （旧实现要跳过「已在活跃区展示」和「已删除墓碑」两类行，还得为此在找上一行时
  /// 跳过隐藏行才不漏日期标题）。
  Widget _buildHistoryItemWithDateHeader(DownloadTask task, int index) {
    final currentDate = task.createdAt;

    // 如果没有创建时间，直接渲染任务
    if (currentDate == null) {
      return _buildTaskItem(task);
    }

    final prevDate = index > 0 ? _historySource[index - 1].createdAt : null;
    final needHeader =
        index == 0 || prevDate == null || !_isSameDay(prevDate, currentDate);

    if (!needHeader) {
      return _buildTaskItem(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildDateHeader(currentDate), _buildTaskItem(task)],
    );
  }

  /// 构建日期标题
  Widget _buildDateHeader(DateTime date) {
    final textTheme = Theme.of(context).textTheme;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Text(
        dateString,
        style: textTheme.titleSmall?.copyWith(
          color: textTheme.bodySmall?.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 判断是否为同一天
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSectionHeader({required String title, required int count}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('($count)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  /// 「上次退出时有 N 个任务未完成，已暂停」提示条。
  ///
  /// 启动语义是「不自动续传，一律暂停」（见 DownloadService._loadActiveTasks）。
  /// 没有这条一键召回，用户上次下了 30 条就得手点 30 次继续——它是那条语义的
  /// 配套，不是装饰。点「全部继续」只叫醒这一批，不会波及用户很早以前手动暂停的
  /// 任务。
  Widget _buildRestoredPausedBanner(BuildContext context) {
    return Obx(() {
      final count = DownloadService.to.restoredPausedIds.length;
      if (count == 0) return const SizedBox.shrink();

      final t = slang.Translations.of(context);
      final cs = Theme.of(context).colorScheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: GlassSurface(
          height: 56,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.pause_circle_outline, size: 20, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.download.restoredPaused.banner(num: count),
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GlassButtonGroup(
                children: [
                  GlassTextActionButton(
                    label: t.download.restoredPaused.resume,
                    emphasized: true,
                    onPressed: () => DownloadService.to.resumeRestoredTasks(),
                  ),
                  GlassIconButton(
                    icon: const Icon(Icons.close),
                    tooltip: t.download.restoredPaused.dismiss,
                    onPressed: () => DownloadService.to.dismissRestoredPaused(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 取某个分区中通过当前筛选条件的任务。
  ///
  /// 活跃任务全在内存里，筛选是纯内存过滤——没有 DB 查询、没有异步、没有竞态，
  /// 因此筛选条件一改立刻生效，不再需要「筛选加载中」的沙漏态兜底。
  List<DownloadTask> _visibleTasksOf(List<String> ids) {
    final result = <DownloadTask>[];
    for (final id in ids) {
      final task = _store.taskOf(id);
      if (task == null) continue;
      if (!_filterTask(task)) continue;
      result.add(task);
    }
    return result;
  }

  /// 活跃区的一行：只订阅自己那条任务的句柄。
  ///
  /// 这样一条任务暂停 / 继续 / 失败时，只有它自己重建，其余行与底部历史区纹丝不动。
  Widget _buildActiveTaskItem(String taskId) {
    final handle = _store.handleOf(taskId);
    if (handle == null) return const SizedBox.shrink();
    return Obx(() {
      handle.revision.value; // 订阅这一行
      return _buildTaskItem(handle.task);
    });
  }

  Widget _buildTaskItem(DownloadTask task) {
    Widget item;
    if (task.extData?.type == DownloadTaskExtDataType.video) {
      item = VideoDownloadTaskItem(task: task);
    } else if (task.extData?.type == DownloadTaskExtDataType.gallery) {
      item = GalleryDownloadTaskItem(task: task);
    } else {
      item = DefaultDownloadTaskItem(task: task);
    }

    if (_isSelectionMode) {
      final isSelected = _selectedTaskIds.contains(task.id);
      return Stack(
        children: [
          // 列表项本身
          item,
          // 选择态：角标勾选片 + 选中描边（全站统一，见 GlassSelectableOverlay）。
          // 内边距与圆角对齐 Card 的样式（margin 8/4, radius 12）
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _toggleItemSelection(task.id),
                  child: GlassSelectableOverlay(
                    selectionMode: true,
                    selected: isSelected,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // 使用 GestureDetector 代替 InkWell，避免水波纹超出卡片（因为卡片有 margin，外层 InkWell 会是矩形且包括 margin）
      // 内部 Item 已经有自己的点击反馈（WaterRipple）
      return GestureDetector(
        onLongPress: () {
          _enterSelectionMode();
          _toggleItemSelection(task.id);
        },
        child: item,
      );
    }
  }

  /// 串行刷新历史区域（已完成任务）。
  ///
  /// 历史列表基于 LoadingMoreBase，并发 refresh 会相互 clear/addAll，造成列表被
  /// 清空或漏掉“刚完成”的任务；这里串行化并在刷新期间收到新的失效信号时重跑一轮。
  ///
  /// 与旧实现的差别：不再需要按全局状态版本比对，也不再需要删除墓碑——历史区只装
  /// 已完成任务，删除后的重拉一定读不到它，活跃任务也永远不会混进来。
  Future<void> _refreshHistory() async {
    if (!mounted) return;
    if (_isRefreshingHistory) {
      _historyRefreshDirty = true;
      return;
    }

    _isRefreshingHistory = true;
    try {
      do {
        _historyRefreshDirty = false;
        await _historySource.refresh(true);
        if (!mounted) return;
      } while (_historyRefreshDirty);
    } catch (e) {
      // 刷新历史失败时静默处理，避免影响主流程
    } finally {
      _isRefreshingHistory = false;
    }
  }
}

/// 历史任务数据源（仅 completed），用于无限滚动加载。
///
/// 活跃任务（下载中 / 等待 / 暂停 / 失败）不在这里，它们由内存真源
/// [DownloadTaskStore] 承载并显示在上方活跃区——两边没有交集，因此这个数据源
/// 不需要任何去重 / 隐藏逻辑。
class _HistoryDownloadTasksSource extends LoadingMoreBase<DownloadTask>
    with LoadingMoreRefreshGuard<DownloadTask> {
  final DownloadTaskRepository _repository;

  bool _hasMore = true;
  bool _forceRefresh = false;

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  String _categoryFilter = 'all';

  static const int pageSize = 20;

  _HistoryDownloadTasksSource(this._repository);

  @override
  bool get hasMore => _hasMore || _forceRefresh;

  /// Update filters and refresh the list
  void updateFilters({
    required String searchQuery,
    required String statusFilter,
    required String typeFilter,
    required String categoryFilter,
  }) {
    _searchQuery = searchQuery;
    _statusFilter = statusFilter;
    _typeFilter = typeFilter;
    _categoryFilter = categoryFilter;
    // 不在此处 refresh：由页面侧 _refreshHistory() 串行触发，
    // 避免与 worker 的历史刷新并发，导致列表被 clear/addAll 互相干扰。
  }

  @override
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    // 本源用 length 当 offset，清空列表即把分页游标打回 0。
    clear();
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      _forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        _forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 游标快照必须在 await 之前取：await 期间可能发生 refresh()（它会
    // clear() 把 length 打回 0），否则回来的这一页会被追加到已清空的列表里。
    final int generation = currentGeneration;
    final int offset = length;
    try {
      // Use searchTasks when filters are active, otherwise use getHistoryTasks
      final bool hasFilters =
          _searchQuery.isNotEmpty ||
          _statusFilter != 'all' ||
          _typeFilter != 'all' ||
          _categoryFilter != 'all';

      List<DownloadTask> tasks;
      if (_statusFilter == 'failed') {
        // 失败任务由顶部 failed section 负责展示，历史列表保持为空避免重复。
        tasks = const <DownloadTask>[];
      } else if (hasFilters) {
        final historyStatusFilter = _statusFilter == 'all'
            ? 'history'
            : _statusFilter;
        tasks = await _repository.searchTasks(
          offset: offset,
          limit: pageSize,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          statusFilter: historyStatusFilter,
          typeFilter: _typeFilter,
          categoryFilter: _categoryFilter,
        );
      } else {
        tasks = await _repository.getHistoryTasks(
          offset: offset,
          limit: pageSize,
        );
      }

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      addAll(tasks);

      _hasMore = tasks.length >= pageSize;
      isSuccess = true;
    } catch (e, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e(
        '加载下载历史任务失败',
        tag: '_HistoryDownloadTasksSource',
        error: e,
        stack: stack,
      );
    }
    return isSuccess;
  }
}

/// 状态 + 类型的筛选结果。
class _DownloadFilterSelection {
  const _DownloadFilterSelection({required this.status, required this.type});

  final DownloadStatusFilter status;
  final DownloadTypeFilter type;
}

/// 筛选弹窗：状态与类型一次改完再应用。
///
/// 原来这两项是 header 上并排的两个下拉菜单，各自触发一次全量重查；收进弹窗后
/// header 只留一枚带红点的筛选钮，条件是否生效一眼可见。
class _DownloadFilterSheet extends StatefulWidget {
  const _DownloadFilterSheet({required this.initial});

  final _DownloadFilterSelection initial;

  @override
  State<_DownloadFilterSheet> createState() => _DownloadFilterSheetState();
}

class _DownloadFilterSheetState extends State<_DownloadFilterSheet> {
  late DownloadStatusFilter _status = widget.initial.status;
  late DownloadTypeFilter _type = widget.initial.type;

  static const List<DownloadStatusFilter> _statuses =
      DownloadStatusFilter.values;
  static const List<DownloadTypeFilter> _types = DownloadTypeFilter.values;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题行：标题 + 玻璃关闭圆钮
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.searchFilter.filterSettings,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // 状态：所有状态 / 失败 / 已下载
          _buildSegmentRow(
            selectedIndex: _statuses.indexOf(_status),
            onChanged: (index) => setState(() => _status = _statuses[index]),
            items: [
              for (final s in _statuses)
                GlassSegmentItem(
                  label: _statusFilterLabel(s, t),
                  icon: Icon(_statusFilterIcon(s)),
                ),
            ],
          ),
          // 类型：所有类型 / 视频 / 图库 / 其他
          _buildSegmentRow(
            selectedIndex: _types.indexOf(_type),
            onChanged: (index) => setState(() => _type = _types[index]),
            items: [
              for (final type in _types)
                GlassSegmentItem(
                  label: _typeFilterLabel(type, t),
                  icon: Icon(_typeFilterIcon(type)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButtonGroup(
                  children: [
                    GlassTextActionButton(
                      label: t.searchFilter.clearAll,
                      onPressed: () => setState(() {
                        _status = DownloadStatusFilter.all;
                        _type = DownloadTypeFilter.all;
                      }),
                    ),
                    GlassTextActionButton(
                      label: t.common.confirm,
                      emphasized: true,
                      onPressed: () => Navigator.of(context).pop(
                        _DownloadFilterSelection(status: _status, type: _type),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 分段胶囊横向铺一行：段数固定但文案可长可短，胶囊自己能横向滚。
  Widget _buildSegmentRow({
    required List<GlassSegmentItem> items,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassSegmentedControl(
          items: items,
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// 弹窗标题行：标题 + 玻璃关闭圆钮（全局统一约定，见 dialog-close-button-glass）。
///
/// [context] 传弹窗自己的 context，默认关闭动作就是把它 pop 掉（确认类弹窗因此
/// 拿到 null，等同「取消」）；需要别的关闭语义时传 [onClose]。
Widget _dialogTitleRow(
  BuildContext context,
  String title, {
  VoidCallback? onClose,
}) {
  return Row(
    children: [
      Expanded(child: Text(title)),
      GlassIconButton(
        standalone: true,
        icon: const Icon(Icons.close),
        tooltip: slang.Translations.of(context).common.close,
        onPressed: onClose ?? () => Navigator.of(context).pop(),
      ),
    ],
  );
}

IconData _statusFilterIcon(DownloadStatusFilter filter) {
  return switch (filter) {
    DownloadStatusFilter.all => Icons.filter_list,
    DownloadStatusFilter.failed => Icons.error_outline,
    DownloadStatusFilter.downloaded => Icons.check_circle_outline,
  };
}

IconData _typeFilterIcon(DownloadTypeFilter filter) {
  return switch (filter) {
    DownloadTypeFilter.all => Icons.category_outlined,
    DownloadTypeFilter.video => Icons.videocam_outlined,
    DownloadTypeFilter.gallery => Icons.photo_library_outlined,
    DownloadTypeFilter.other => Icons.more_horiz,
  };
}

String _statusFilterLabel(DownloadStatusFilter filter, slang.Translations t) {
  return switch (filter) {
    DownloadStatusFilter.all => t.download.allStatus,
    DownloadStatusFilter.failed => t.download.failed,
    DownloadStatusFilter.downloaded => t.download.downloaded,
  };
}

String _typeFilterLabel(DownloadTypeFilter filter, slang.Translations t) {
  return switch (filter) {
    DownloadTypeFilter.all => t.download.allTypes,
    DownloadTypeFilter.video => t.download.video,
    DownloadTypeFilter.gallery => t.download.gallery,
    DownloadTypeFilter.other => t.download.other,
  };
}

void showDownloadDetailDialog(BuildContext context, DownloadTask task) async {
  final t = slang.Translations.of(context);
  final theme = Theme.of(context);
  final size = MediaQuery.of(context).size;

  // 获取相关任务信息
  final DownloadService downloadService = DownloadService.to;
  DownloadTask? currentActiveTask = downloadService.getMemoryActiveTaskById(
    task.id,
  );
  DownloadTask? currentCompletedTask = await DownloadService.to.repository
      .getTaskById(task.id);
  List<String> currentQueueIds = downloadService.getQueueIds();

  // 构建完整的任务信息
  final Map<String, dynamic> fullTaskInfo = {
    'mainTask': task.toJson(),
    'currentActiveTask': currentActiveTask?.toJson(),
    'currentCompletedTask': currentCompletedTask?.toJson(),
    'queueStatus': {
      'isInQueue': currentQueueIds.contains(task.id),
      'queuePosition': currentQueueIds.indexOf(task.id),
      'totalQueueSize': currentQueueIds.length,
      'queueIds': currentQueueIds,
    },
  };

  final String prettyJson = const JsonEncoder.withIndent(
    '  ',
  ).convert(fullTaskInfo);

  showAppDialog(
    Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.8,
          maxWidth: size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Builder(
                builder: (dialogContext) => DefaultTextStyle.merge(
                  style: theme.textTheme.titleLarge,
                  child: _dialogTitleRow(
                    dialogContext,
                    t.download.downloadDetail,
                    onClose: () => AppService.tryPop(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      prettyJson,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GlassButtonGroup(
                    children: [
                      GlassTextActionButton(
                        label: t.download.copy,
                        emphasized: true,
                        onPressed: () async {
                          final item = DataWriterItem();
                          item.add(Formats.plainText(prettyJson));
                          await SystemClipboard.instance?.write([item]);

                          if (context.mounted) {
                            showGlassToast(
                              t.download.copySuccess,
                              type: GlassToastType.success,
                            );
                          }
                        },
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

/// “按日期删除”弹窗的两种模式：日期区间 / 多少天以前。
enum _DeleteByDateMode { range, days }

/// 用户在“按日期删除”弹窗中确认后的选择结果。
///
/// [start]/[end] 为创建时间的闭区间边界（含端点），任一为 null 表示该侧不限。
/// - 日期区间模式：start=所选起始日 00:00:00，end=所选结束日 23:59:59。
/// - 多少天以前模式：start=null，end=（now - N 天）。
class _DateDeletionSelection {
  final DateTime? start;
  final DateTime? end;
  const _DateDeletionSelection({this.start, this.end});
}

/// “按日期删除”的条件选择弹窗。返回 [_DateDeletionSelection] 或 null（取消）。
class _DeleteByDateDialog extends StatefulWidget {
  const _DeleteByDateDialog();

  @override
  State<_DeleteByDateDialog> createState() => _DeleteByDateDialogState();
}

class _DeleteByDateDialogState extends State<_DeleteByDateDialog> {
  _DeleteByDateMode _mode = _DeleteByDateMode.range;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _daysController = TextEditingController(
    text: '30',
  );
  static const List<int> _dayPresets = [7, 30, 90, 180];

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 最大可输入的“多少天以前”。约 100 年，远小于 DateTime / Duration 的溢出边界，
  /// 防止超大值导致 Duration(days:) 溢出回绕成“未来”时间点而误删全部历史。
  static const int _maxDays = 36500;

  int? get _days {
    final v = int.tryParse(_daysController.text.trim());
    if (v == null || v < 1) return null;
    return v > _maxDays ? _maxDays : v;
  }

  bool get _canConfirm {
    if (_mode == _DeleteByDateMode.range) {
      return _startDate != null || _endDate != null;
    }
    return _days != null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(2015),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _onConfirm() {
    final t = slang.Translations.of(context);
    if (_mode == _DeleteByDateMode.range) {
      final start = _startDate;
      final end = _endDate;
      if (start != null && end != null && start.isAfter(end)) {
        showGlassToast(
          t.download.deleteByDate.invalidRange,
          type: GlassToastType.warning,
        );
        return;
      }
      final normalizedStart = start == null
          ? null
          : DateTime(start.year, start.month, start.day);
      final normalizedEnd = end == null
          ? null
          : DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
      Navigator.pop(
        context,
        _DateDeletionSelection(start: normalizedStart, end: normalizedEnd),
      );
    } else {
      final days = _days;
      if (days == null) return;
      final cutoff = DateTime.now().subtract(Duration(days: days));
      Navigator.pop(context, _DateDeletionSelection(start: null, end: cutoff));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 底部 sheet 布局：顶部由 showModalBottomSheet 的 dragHandle 处理；
    // 底部用 SafeArea(top:false) + viewInsets.bottom 让内边距兼顾系统导航条与键盘。
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.titleLarge,
                    child: _dialogTitleRow(
                      context,
                      t.download.deleteByDate.dialogTitle,
                    ),
                  ),
                ),
                GlassDropdownField<_DeleteByDateMode>(
                  value: _mode,
                  items: [
                    GlassDropdownItem(
                      value: _DeleteByDateMode.range,
                      icon: Icons.date_range,
                      label: t.download.deleteByDate.modeRange,
                    ),
                    GlassDropdownItem(
                      value: _DeleteByDateMode.days,
                      icon: Icons.history,
                      label: t.download.deleteByDate.modeDays,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _mode = value);
                  },
                ),
                const SizedBox(height: 16),
                if (_mode == _DeleteByDateMode.range) ...[
                  _buildDateTile(
                    label: t.download.deleteByDate.startDate,
                    value: _startDate,
                    notSet: t.download.deleteByDate.notSet,
                    onTap: () => _pickDate(isStart: true),
                    onClear: _startDate == null
                        ? null
                        : () => setState(() => _startDate = null),
                  ),
                  const SizedBox(height: 8),
                  _buildDateTile(
                    label: t.download.deleteByDate.endDate,
                    value: _endDate,
                    notSet: t.download.deleteByDate.notSet,
                    onTap: () => _pickDate(isStart: false),
                    onClear: _endDate == null
                        ? null
                        : () => setState(() => _endDate = null),
                  ),
                ] else ...[
                  Text(
                    t.download.deleteByDate.olderThanDaysHint(days: _days ?? 0),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // 限长 5 位，配合 _days 上的钳制，杜绝 Duration/DateTime 溢出。
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixText: t.download.deleteByDate.daysUnit,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _dayPresets.map((d) {
                      return ChoiceChip(
                        label: Text('$d'),
                        selected: _days == d,
                        onSelected: (_) {
                          setState(() {
                            _daysController.text = '$d';
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  t.download.deleteByDate.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButtonGroup(
                      children: [
                        GlassTextActionButton(
                          label: t.common.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        GlassTextActionButton(
                          label: t.common.delete,
                          destructive: true,
                          onPressed: _canConfirm ? _onConfirm : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? value,
    required String notSet,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          value != null ? _formatDate(value) : notSet,
          style: TextStyle(
            color: value != null
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 删除进度弹窗：进入即开始执行 [DownloadService.deleteTasksWithProgress]，
/// 完成后自动关闭并通过 [Navigator.pop] 返回 [DeleteTasksResult]。
/// 删除期间禁止返回键 / 点击外部关闭，避免中断耗时操作。
class _DeleteProgressDialog extends StatefulWidget {
  final List<DownloadTask> tasks;
  const _DeleteProgressDialog({required this.tasks});

  @override
  State<_DeleteProgressDialog> createState() => _DeleteProgressDialogState();
}

class _DeleteProgressDialogState extends State<_DeleteProgressDialog> {
  late final int _total = widget.tasks.length;
  int _done = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final result = await DownloadService.to.deleteTasksWithProgress(
      widget.tasks,
      onProgress: (done, total) {
        if (mounted) setState(() => _done = done);
      },
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return PopScope(
      canPop: false,
      // 进行中的进度弹窗：没有标题行也没有动作键（不许中途关），
      // 但壳仍走 GlassAlertDialog，配色/圆角/出入场与全站一致。
      child: GlassAlertDialog(
        title: null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: _total > 0 ? _done / _total : null),
            const SizedBox(height: 16),
            Text(t.download.deleteByDate.deleting(done: _done, total: _total)),
          ],
        ),
      ),
    );
  }
}
