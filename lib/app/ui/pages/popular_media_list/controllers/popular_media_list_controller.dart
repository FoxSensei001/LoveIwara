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
  final Rx<double> currentScrollOffset = 0.0.obs;
  final Rx<ScrollDirection> lastScrollDirection = ScrollDirection.idle.obs;
  final RxDouble headerOffset = 0.0.obs;
  final RxBool showHeader = true.obs;

  SortId? _activeSortId;
  double _maxHeaderOffset = 0.0;

  // 每个 tab 的滚动快照（切换 tab 时同步 Header 折叠状态）
  final Map<SortId, double> _tabScrollOffsets = {};
  final Map<SortId, ScrollDirection> _tabScrollDirections = {};

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

    final offset = _tabScrollOffsets[sortId] ?? 0.0;
    final direction = _tabScrollDirections[sortId] ?? ScrollDirection.idle;

    currentScrollOffset.value = offset;
    lastScrollDirection.value = direction;
    _syncShowHeader();
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
      currentScrollOffset.value = offset;
      lastScrollDirection.value = direction;
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
    currentScrollOffset.value = 0.0;
    lastScrollDirection.value = ScrollDirection.idle;
    resetHeaderState();
  }
}
