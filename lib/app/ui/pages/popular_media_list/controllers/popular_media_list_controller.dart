import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

/// 流行媒体列表控制器：统一管理分页/瀑布流切换和数据加载逻辑
class PopularMediaListController extends GetxController {
  // 分页模式状态
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  
  // 用于强制刷新的状态键
  final RxInt rebuildKey = 0.obs;
  
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
} 