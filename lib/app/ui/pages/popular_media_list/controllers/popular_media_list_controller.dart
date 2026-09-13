import 'package:flutter/material.dart' show Curves, ScrollController;
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

/// 流行媒体列表控制器：统一管理分页/瀑布流切换和数据加载逻辑
class PopularMediaListController extends GetxController {
  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;

  // 用于强制刷新的状态键
  final RxInt rebuildKey = 0.obs;

  // 当前激活 tab 的滚动状态（用于 UI 联动）
  //
  // ⛔ 这两个**不是** Rx，别改回去。它们每帧都在变（见 updateScrollInfo），
  // 而唯一真正的读者是「回到顶部」浮钮的可见性判断。做成 Rx 的代价是每帧一次
  // 通知 + 每帧重建浮钮那棵子树——实测浮钮本身在滚动期间是不建的（GlassReveal
  // 退场后不建 child），所以那点重建纯属白干。真正需要响应式的只有**阈值化之后**
  // 的 [canScrollToTop]，它一整个滚动过程里只会变两次。
  double currentScrollOffset = 0.0;
  ScrollDirection lastScrollDirection = ScrollDirection.idle;

  /// 「回到顶部」浮钮是否该出现。只在跨越 [scrollToTopThreshold] 时翻转，
  /// 所以它驱动的重建是「一次」而不是「每帧」。
  final RxBool canScrollToTop = false.obs;

  /// 浮钮的出现阈值。原先这个 800 散落在各页面的 `Obx` 里，现在收在这里，
  /// 让「偏移量 → 是否显示」这条判断只有一个出处。
  static const double scrollToTopThreshold = 800.0;

  final RxDouble headerOffset = 0.0.obs;
  final RxBool showHeader = true.obs;

  SortId? _activeSortId;
  double _maxHeaderOffset = 0.0;

  // 每个 tab 的滚动快照（切换 tab 时同步 Header 折叠状态）
  final Map<SortId, double> _tabScrollOffsets = {};
  final Map<SortId, ScrollDirection> _tabScrollDirections = {};
  final RxSet<SortId> _loadedSorts = <SortId>{}.obs;
  final RxSet<SortId> _pendingReloadSorts = <SortId>{}.obs;
  final RxMap<SortId, int> _sortReloadVersions = <SortId, int>{}.obs;

  void configureHeaderExtent(double maxOffset) {
    _maxHeaderOffset = maxOffset;
    _syncShowHeader();
  }

  void _syncShowHeader() {
    if (_maxHeaderOffset <= 0) {
      showHeader.value = true;
      return;
    }
    showHeader.value = headerOffset.value < _maxHeaderOffset - 0.5;
  }

  void resetHeaderState() {
    headerOffset.value = 0.0;
    showHeader.value = true;
  }

  void _applyHeaderDelta(double delta) {
    if (_maxHeaderOffset <= 0 || delta == 0) {
      _syncShowHeader();
      return;
    }

    final double nextOffset = (headerOffset.value + delta)
        .clamp(0.0, _maxHeaderOffset)
        .toDouble();
    if ((nextOffset - headerOffset.value).abs() >= 0.01) {
      headerOffset.value = nextOffset;
    }
    _syncShowHeader();
  }

  // 设置分页模式
  void setPaginatedMode(bool value) {
    if (isPaginated.value != value) {
      isPaginated.value = value;
      CommonConstants.isPaginated = value;
      Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = value;
      rebuildKey.value++;
    }
  }

  // 刷新列表
  void refreshPageUI() {
    rebuildKey.value++;
  }

  void setActiveSort(SortId sortId) {
    _activeSortId = sortId;
    _consumePendingReload(sortId);

    final offset = _tabScrollOffsets[sortId] ?? 0.0;
    final direction = _tabScrollDirections[sortId] ?? ScrollDirection.idle;

    currentScrollOffset = offset;
    lastScrollDirection = direction;
    _syncCanScrollToTop(offset);
    _syncShowHeader();
  }

  /// 偏移量 → 浮钮可见性。**只在翻转时**写 Rx，所以静止滚动期间一次通知都没有。
  void _syncCanScrollToTop(double offset) {
    final bool next = offset > scrollToTopThreshold;
    if (canScrollToTop.value != next) {
      canScrollToTop.value = next;
    }
  }

  void markSortLoaded(SortId sortId) {
    _loadedSorts.add(sortId);
    _sortReloadVersions.putIfAbsent(sortId, () => 0);
  }

  void invalidateLoadedSorts({required SortId activeSortId}) {
    _activeSortId = activeSortId;
    final loadedSorts = _loadedSorts.toList(growable: false);
    for (final sortId in loadedSorts) {
      if (sortId == activeSortId) {
        _bumpReloadVersion(sortId);
        _pendingReloadSorts.remove(sortId);
      } else {
        _pendingReloadSorts.add(sortId);
      }
    }
  }

  int reloadVersionFor(SortId sortId) => _sortReloadVersions[sortId] ?? 0;

  /// 已加载（已访问）过的子 tab 集合的快照。
  List<SortId> get loadedSorts => _loadedSorts.toList(growable: false);

  void _consumePendingReload(SortId sortId) {
    if (_pendingReloadSorts.remove(sortId)) {
      _bumpReloadVersion(sortId);
    }
  }

  void _bumpReloadVersion(SortId sortId) {
    _sortReloadVersions[sortId] = (_sortReloadVersions[sortId] ?? 0) + 1;
  }

  // 更新某个 tab 的滚动状态
  void updateScrollInfo({
    required SortId sortId,
    required double offset,
    required ScrollDirection direction,
    double delta = 0.0,
  }) {
    _tabScrollOffsets[sortId] = offset;
    _tabScrollDirections[sortId] = direction;

    // 仅当前激活 tab 驱动 UI
    if (_activeSortId == sortId) {
      currentScrollOffset = offset;
      lastScrollDirection = direction;
      _syncCanScrollToTop(offset);
      _applyHeaderDelta(delta);
    }
  }

  // 每个 tab 的滚动控制器，用于控制当前 tab 滚动到顶部
  final Map<SortId, ScrollController> _scrollControllers = {};

  // 注册滚动控制器
  void registerScrollController(SortId sortId, ScrollController controller) {
    _scrollControllers[sortId] = controller;
  }

  // 移除滚动控制器
  void unregisterScrollController(SortId sortId, ScrollController controller) {
    // rebuildKey 等触发重建时，旧 state dispose 可能晚于新 state init，
    // 这里用实例校验避免误删新 controller。
    if (_scrollControllers[sortId] == controller) {
      _scrollControllers.remove(sortId);
    }
  }

  // 滚动到顶部
  void scrollToTop() {
    final activeSortId = _activeSortId;
    if (activeSortId != null) {
      final controller = _scrollControllers[activeSortId];
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      // 同步该 tab 的快照
      _tabScrollOffsets[activeSortId] = 0.0;
      _tabScrollDirections[activeSortId] = ScrollDirection.idle;
    }

    // 重置滚动状态
    currentScrollOffset = 0.0;
    lastScrollDirection = ScrollDirection.idle;
    canScrollToTop.value = false;
    resetHeaderState();
  }
}
