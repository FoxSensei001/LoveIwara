import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/repositories/history_repository.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'history_list_repository.dart';

class HistoryListController extends GetxController {
  final HistoryRepository historyDatabaseRepository;
  late HistoryListRepository repository;

  final RxBool isMultiSelect = false.obs;
  final RxSet<int> selectedRecords = <int>{}.obs;
  final RxBool showBackToTop = false.obs;
  final RxString searchKeyword = ''.obs;
  final Rxn<DateTimeRange> selectedDateRange = Rxn<DateTimeRange>();
  // true: 按更新时间倒序；false: 按创建时间倒序
  final RxBool orderByUpdated = false.obs;
  final String itemType;

  HistoryListController({
    required HistoryRepository historyRepository,
    required this.itemType,
  }) : historyDatabaseRepository = historyRepository {
    repository = HistoryListRepository(
      historyRepository: historyRepository,
      itemType: itemType == 'all' ? null : itemType,
    );
  }

  Future<void> clearHistoryByType(String itemType) async {
    if (itemType == 'all') {
      await historyDatabaseRepository.clearHistory();
    } else {
      await historyDatabaseRepository.clearHistoryByType(itemType);
    }
    repository.refresh();
    showToastWidget(
      MDToastWidget(message: t.common.success, type: MDToastType.success),
    );
  }

  void toggleMultiSelect() {
    isMultiSelect.value = !isMultiSelect.value;
    if (!isMultiSelect.value) {
      selectedRecords.clear();
    }
  }

  void toggleSelection(int recordId) {
    if (selectedRecords.contains(recordId)) {
      selectedRecords.remove(recordId);
    } else {
      selectedRecords.add(recordId);
    }
    for (var tag in ['all', 'video', 'image', 'post', 'thread']) {
      final controller = Get.find<HistoryListController>(tag: tag);
      controller.selectedRecords.value = Set.from(selectedRecords);
    }
  }

  Future<void> deleteSelected() async {
    await historyDatabaseRepository.deleteRecords(selectedRecords.toList());
    selectedRecords.clear();
    for (var tag in ['all', 'video', 'image', 'post', 'thread']) {
      final controller = Get.find<HistoryListController>(tag: tag);
      controller.repository.refresh();
    }
    isMultiSelect.value = false;
    showToastWidget(
      MDToastWidget(message: t.common.success, type: MDToastType.success),
    );
  }

  void search(String keyword) {
    searchKeyword.value = keyword;
    repository.keyword = keyword;
    repository.refresh();
  }

  /// 当前筛选条件对应的时间区间结束边界（包含当天 23:59:59），与列表查询保持一致。
  DateTime? get _rangeEnd {
    final end = selectedDateRange.value?.end;
    if (end == null) return null;
    return DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  /// 统计当前所选时间范围内、当前类型的历史记录数量（删除前确认用）。
  /// 时间字段跟随当前「创建/更新时间」开关，与列表显示保持一致。
  Future<int> countRecordsInSelectedRange() async {
    final range = selectedDateRange.value;
    if (range == null) return 0;
    return historyDatabaseRepository.countRecordsByTimeRange(
      itemType: itemType,
      startDate: range.start,
      endDate: _rangeEnd,
      byUpdated: orderByUpdated.value,
    );
  }

  /// 删除当前所选时间范围内、当前类型的历史记录，并刷新所有标签页。
  Future<void> deleteRecordsInSelectedRange() async {
    final range = selectedDateRange.value;
    if (range == null) return;
    await historyDatabaseRepository.deleteRecordsByTimeRange(
      itemType: itemType,
      startDate: range.start,
      endDate: _rangeEnd,
      byUpdated: orderByUpdated.value,
    );
    // 删除会影响「全部」标签及对应类型标签，统一刷新
    for (var tag in ['all', 'video', 'image', 'post', 'thread']) {
      if (Get.isRegistered<HistoryListController>(tag: tag)) {
        Get.find<HistoryListController>(tag: tag).repository.refresh();
      }
    }
    showToastWidget(
      MDToastWidget(message: t.common.success, type: MDToastType.success),
    );
  }

  void setDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    repository.dateRange = range;
    repository.refresh();
  }

  void setOrderByUpdated(bool value) {
    orderByUpdated.value = value;
    repository.orderByUpdated = value;
    repository.refresh();
  }

  @override
  void onClose() {
    repository.dispose();
    super.onClose();
  }
}
