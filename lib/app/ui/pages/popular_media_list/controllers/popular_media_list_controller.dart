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

  // 滚动状态监听
  final Rx<double> currentScrollOffset = 0.0.obs;
  final Rx<ScrollDirection> lastScrollDirection = ScrollDirection.idle.obs;
  final RxBool showHeader = true.obs;

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

  // 更新滚动状态
  void updateScrollInfo(double offset, ScrollDirection direction) {
    currentScrollOffset.value = offset;
    lastScrollDirection.value = direction;
  }

  // 滚动控制器列表，用于实际控制滚动
  final Map<String, ScrollController> _scrollControllers = {};

  // 注册滚动控制器
  void registerScrollController(String key, ScrollController controller) {
    _scrollControllers[key] = controller;
  }

  // 移除滚动控制器
  void unregisterScrollController(String key) {
    _scrollControllers.remove(key);
  }

  // 滚动到顶部
  void scrollToTop() {
    // 滚动当前激活的 tab 到顶部
    for (var controller in _scrollControllers.values) {
      if (controller.hasClients) {
        controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    // 重置滚动状态
    currentScrollOffset.value = 0.0;
    lastScrollDirection.value = ScrollDirection.idle;
  }
}
