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

  /// 长按某一项直接进入多选并选中它。
  ///
  /// 「先点右上角开多选、再回来点这一项」是两步，而长按是一步——原先只有
  /// 表情库支持这个手势，现在统一到所有列表。
  void enterMultiSelectWith(T media) {
    if (isMultiSelect.value) return;
    isMultiSelect.value = true;
    toggleSelection(media);
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

  /// 取媒体 id；不是受支持的类型时返回 null。
  static String? _idOf(Object? media) {
    if (media is Video) return media.id;
    if (media is ImageModel) return media.id;
    return null;
  }

  /// 当前可见的这批是否已被全选。
  ///
  /// 分页模式下 [items] 就是本页，所以「全选」的语义天然是**全选本页**——
  /// 翻页会清空选择（见 [onPageChanged]），跨页全选是够不着的东西，不给按钮。
  bool isAllSelected(List<T> items) {
    if (items.isEmpty) return false;
    for (final item in items) {
      final id = _idOf(item);
      if (id == null || !selectedMediaIds.contains(id)) return false;
    }
    return true;
  }

  /// 全选 [items]；已经全选时改为取消全选。
  void toggleSelectAll(List<T> items) {
    if (items.isEmpty) return;
    if (isAllSelected(items)) {
      for (final item in items) {
        final id = _idOf(item);
        if (id == null) continue;
        selectedMediaIds.remove(id);
        selectedMediaItems.remove(id);
      }
      return;
    }
    for (final item in items) {
      final id = _idOf(item);
      if (id == null) continue;
      selectedMediaIds.add(id);
      selectedMediaItems[id] = item;
    }
  }

  /// 分页切换时重置选择（分页模式专用）
  void onPageChanged() {
    if (isPaginatedMode.value) {
      clearSelection();
    }
  }

  /// 设置分页模式
  void setPaginatedMode(bool isPaginated) {
    if (isPaginatedMode.value != isPaginated) {
      isPaginatedMode.value = isPaginated;
      clearSelection();
    }
  }

  /// 获取选中数量
  int get selectedCount => selectedMediaIds.length;

  /// 检查媒体是否已选中
  bool isSelected(String mediaId) => selectedMediaIds.contains(mediaId);

  /// 获取选中的媒体列表
  List<T> get selectedMediaList => selectedMediaItems.values.toList();
}
