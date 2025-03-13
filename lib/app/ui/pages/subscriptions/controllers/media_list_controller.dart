import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';

/// 媒体列表控制器：统一管理分页/瀑布流切换和数据加载逻辑
class MediaListController extends GetxController {
  // 分页模式状态
  final RxBool isPaginated = false.obs;
  
  // 用于强制刷新的状态键
  final RxInt rebuildKey = 0.obs;
  
  // 设置分页模式
  void setPaginatedMode(bool value) {
    if (isPaginated.value != value) {
      isPaginated.value = value;
      rebuildKey.value++; // 增加重建键值强制更新视图
    }
  }
  
  // 刷新列表
  void refreshList() {
    rebuildKey.value++;
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
  }
} 