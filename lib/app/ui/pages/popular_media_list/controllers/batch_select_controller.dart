import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/image.model.dart';

/// 批量选择控制器
/// 用于管理媒体列表的多选模式状态（支持视频和图库）
class BatchSelectController<T> extends GetxController {
  /// 是否处于多选模式
  final RxBool isMultiSelect = false.obs;

  /// 已选择的媒体ID集合
  final RxSet<String> selectedMediaIds = <String>{}.obs;

  /// 已选择的媒体详情缓存（用于构建下载任务）
  final RxMap<String, T> selectedMediaItems = <String, T>{}.obs;

  /// 当前列表模式（分页/瀑布流）
  final RxBool isPaginatedMode = false.obs;

  /// 切换多选模式
  void toggleMultiSelect() {
    isMultiSelect.value = !isMultiSelect.value;
    if (!isMultiSelect.value) {
      clearSelection();
    }
  }

  /// 进入多选模式
  void enterMultiSelect() {
    if (!isMultiSelect.value) {
      isMultiSelect.value = true;
    }
  }

  /// 退出多选模式
  void exitMultiSelect() {
    if (isMultiSelect.value) {
      isMultiSelect.value = false;
      clearSelection();
    }
  }

  /// 切换单个媒体选择状态
  void toggleSelection(T media) {
    String id;
    if (media is Video) {
      id = media.id;
    } else if (media is ImageModel) {
      id = media.id;
    } else {
      return;
    }

    if (selectedMediaIds.contains(id)) {
      selectedMediaIds.remove(id);
      selectedMediaItems.remove(id);
    } else {
      selectedMediaIds.add(id);
      selectedMediaItems[id] = media;
    }
  }

  /// 清空选择
  void clearSelection() {
    selectedMediaIds.clear();
    selectedMediaItems.clear();
  }

  /// 分页切换时重置选择（分页模式专用）
  void onPageChanged() {
    if (isPaginatedMode.value) {
      clearSelection();
    }
  }

  /// 设置分页模式
  void setPaginatedMode(bool isPaginated) {
    isPaginatedMode.value = isPaginated;
  }

  /// 获取选中数量
  int get selectedCount => selectedMediaIds.length;

  /// 检查媒体是否已选中
  bool isSelected(String mediaId) => selectedMediaIds.contains(mediaId);

  /// 获取选中的媒体列表
  List<T> get selectedMediaList => selectedMediaItems.values.toList();
}
