import 'package:flutter/material.dart' show Curves, ScrollController;
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

/// 流行媒体列表控制器：统一管理分页/瀑布流切换和数据加载逻辑
class PopularMediaListController extends GetxController {
  static const double _headerCollapseThreshold = 50.0;

  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;

  // 用于强制刷新的状态键
  final RxInt rebuildKey = 0.obs;

  // 当前激活 tab 的滚动状态（用于 UI 联动）
  final Rx<double> currentScrollOffset = 0.0.obs;
  final Rx<ScrollDirection> lastScrollDirection = ScrollDirection.idle.obs;
  final RxBool showHeader = true.obs;

  SortId? _activeSortId;

  // 每个 tab 的滚动快照（切换 tab 时同步 Header 折叠状态）
  final Map<SortId, double> _tabScrollOffsets = {};
  final Map<SortId, ScrollDirection> _tabScrollDirections = {};
  final Map<SortId, bool> _tabShowHeader = {};

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

    final offset = _tabScrollOffsets[sortId] ?? 0.0;
    final direction = _tabScrollDirections[sortId] ?? ScrollDirection.idle;
    final shouldShowHeader =
        _tabShowHeader[sortId] ?? (offset <= _headerCollapseThreshold);

    currentScrollOffset.value = offset;
    lastScrollDirection.value = direction;
    showHeader.value = shouldShowHeader;
  }

  bool _computeShowHeader({
    required bool currentShowHeader,
    required double offset,
    required ScrollDirection direction,
  }) {
    bool shouldShowHeader = currentShowHeader;

    // 向上滚动：需要滚动超过阈值才隐藏
    if (direction == ScrollDirection.reverse) {
      if (offset > _headerCollapseThreshold && shouldShowHeader) {
        shouldShowHeader = false;
      }
    } else if (direction == ScrollDirection.forward) {
      // 向下滚动：更灵敏地显示
      if (!shouldShowHeader) {
        shouldShowHeader = true;
      }
    }

    // 接近顶部时始终显示
    if (offset <= 5.0 && !shouldShowHeader) {
      shouldShowHeader = true;
    }

    // 切换标签或数据重置时显示
    if (offset == 0.0 &&
        direction == ScrollDirection.idle &&
        !shouldShowHeader) {
      shouldShowHeader = true;
    }

    return shouldShowHeader;
  }

  // 更新某个 tab 的滚动状态
  void updateScrollInfo({
    required SortId sortId,
    required double offset,
    required ScrollDirection direction,
  }) {
    _tabScrollOffsets[sortId] = offset;
    _tabScrollDirections[sortId] = direction;

    final bool prevShowHeader = _tabShowHeader[sortId] ?? true;
    final bool nextShowHeader = _computeShowHeader(
      currentShowHeader: prevShowHeader,
      offset: offset,
      direction: direction,
    );
    _tabShowHeader[sortId] = nextShowHeader;

    // 仅当前激活 tab 驱动 UI
    if (_activeSortId == sortId) {
      currentScrollOffset.value = offset;
      lastScrollDirection.value = direction;
      if (showHeader.value != nextShowHeader) {
        showHeader.value = nextShowHeader;
      }
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
      _tabShowHeader[activeSortId] = true;
    }

    // 重置滚动状态
    currentScrollOffset.value = 0.0;
    lastScrollDirection.value = ScrollDirection.idle;
    showHeader.value = true;
  }
}
