import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';

/// 论坛列表控制器，管理分页/瀑布流状态
class ForumListController extends GetxController {
  // 是否使用分页模式
  final RxBool isPaginated = CommonConstants.isPaginated.obs;
  
  // 重建Key，用于强制刷新视图
  final RxInt rebuildKey = 0.obs;
  
  /// 设置分页模式
  void setPaginatedMode(bool isPaginated) {
    this.isPaginated.value = isPaginated;
    CommonConstants.isPaginated = isPaginated;
    Get.find<ConfigService>()[ConfigKey.DEFAULT_PAGINATION_MODE] = isPaginated;
    // 增加rebuildKey，强制刷新视图
    rebuildKey.value++;
  }
  
  /// 刷新列表
  void refreshPageUI() {
    rebuildKey.value++;
  }
  
} 