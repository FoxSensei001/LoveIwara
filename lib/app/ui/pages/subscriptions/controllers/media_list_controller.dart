import 'package:get/get.dart';
import 'package:flutter/rendering.dart'; // Required for ScrollDirection
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/common/constants.dart';

/// 媒体列表控制器：统一管理分页/瀑布流切换和数据加载逻辑
class MediaListController extends GetxController {
  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  
  // 用于强制刷新的状态键
  final RxInt rebuildKey = 0.obs;
  
  // 存储可能的滚动回调
  final List<Function()> _scrollToTopCallbacks = [];
  // 滚动监听回调集合 - 用于通知顶部组件滚动事件
  final List<void Function(double)> _listScrollCallbacks = [];

  final RxDouble currentScrollOffset = 0.0.obs;
  final Rx<ScrollDirection> lastScrollDirection = ScrollDirection.idle.obs;
  
  // 注册滚动到顶部的回调函数
  void registerScrollToTopCallback(Function() callback) {
    if (!_scrollToTopCallbacks.contains(callback)) {
      _scrollToTopCallbacks.add(callback);
    }
  }
  
  // 注销滚动到顶部的回调函数
  void unregisterScrollToTopCallback(Function() callback) {
    _scrollToTopCallbacks.remove(callback);
  }
  
  // 注册列表滚动回调 - 新增
  void registerListScrollCallback(void Function(double) callback) {
    _listScrollCallbacks.add(callback);
  }
  
  // 注销列表滚动回调 - 新增
  void unregisterListScrollCallback(void Function(double) callback) {
    _listScrollCallbacks.remove(callback);
  }
  
  void notifyListScroll(double offset, ScrollDirection direction) {
    currentScrollOffset.value = offset;
    lastScrollDirection.value = direction;
    for (final callback in _listScrollCallbacks) {
      callback(offset);
    }
  }
  
  // 执行所有滚动到顶部的回调
  void scrollToTop() {
    // First, reset scroll state immediately for header animation
    currentScrollOffset.value = 0.0;
    lastScrollDirection.value = ScrollDirection.idle;
    
    // Then execute scroll callbacks
    for (var callback in _scrollToTopCallbacks) {
      callback();
    }
  }
  
  // 设置分页模式
  void setPaginatedMode(bool value) {
    if (isPaginated.value != value) {
      isPaginated.value = value;
      CommonConstants.isPaginated = value;
      Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = value;
      rebuildKey.value++; // 增加重建键值强制更新视图
      
      // 切换模式时滚动到顶部
      scrollToTop();
    }
  }
  
  // 刷新列表
  void refreshList() {
    rebuildKey.value++;
    currentScrollOffset.value = 0.0;
    lastScrollDirection.value = ScrollDirection.idle;
  }
  
  // 刷新页面UI并滚动到顶部
  void refreshPageUI() {
    rebuildKey.value++;
    // 滚动到顶部
    scrollToTop();
  }
  
  // 加载数据 - 根据存储库类型和分页模式执行不同的加载逻辑
  Future<void> loadData(ExtendedLoadingMoreBase repository, bool isPaginated) async {
    if (isPaginated) {
      // 分页模式：加载第一页数据
      await repository.loadPageData(0, 20);
    } else {
      // 瀑布流模式：刷新所有数据
      await repository.refresh(true);
    }
    
    // 数据加载后滚动到顶部
    scrollToTop();
  }
} 