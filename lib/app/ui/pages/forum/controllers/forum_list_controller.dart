import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

/// 论坛列表控制器，管理分页/瀑布流状态
class ForumListController extends GetxController {
  // 是否使用分页模式
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  
  // 重建Key，用于强制刷新视图
  final RxInt rebuildKey = 0.obs;
  
  // 存储滚动回调
  final List<Function()> _scrollToTopCallbacks = [];
  
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
  
  // 执行所有滚动到顶部的回调
  void scrollToTop() {
    for (var callback in _scrollToTopCallbacks) {
      callback();
    }
  }
  
  /// 设置分页模式
  void setPaginatedMode(bool isPaginated) {
    this.isPaginated.value = isPaginated;
    CommonConstants.isPaginated = isPaginated;
    Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = isPaginated;
    // 增加rebuildKey，强制刷新视图
    rebuildKey.value++;
    // 切换模式后滚动到顶部
    scrollToTop();
  }
  
  /// 刷新列表UI
  void refreshPageUI() {
    rebuildKey.value++;
    // 刷新后滚动到顶部
    scrollToTop();
  }
} 