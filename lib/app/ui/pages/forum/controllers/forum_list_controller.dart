import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/forum/controllers/thread_list_repository.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

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
  void refreshList() {
    rebuildKey.value++;
  }
  
  /// 加载数据
  Future<void> loadData(ThreadListRepository repository, bool isPaginated) async {
    try {
      if (isPaginated) {
        // 分页模式下加载首页数据
        await repository.loadPageData(0, 20);
      } else {
        // 瀑布流模式下刷新所有数据
        await repository.refresh(true);
      }
    } catch (e) {
      // 错误处理
      LogUtils.e('加载数据失败', error: e);
    }
  }
} 