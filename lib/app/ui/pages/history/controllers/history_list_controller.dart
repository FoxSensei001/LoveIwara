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

  bool get isAllSelected => selectedRecords.length == repository.length;


  Future<void> clearHistoryByType(String itemType) async {
    if (itemType == 'all') {
      await historyDatabaseRepository.clearHistory();
    } else {
      await historyDatabaseRepository.clearHistoryByType(itemType);
    }
    repository.refresh();
    showToastWidget(MDToastWidget(message: t.common.success, type: MDToastType.success));
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

  void selectAll() {
    if (selectedRecords.length == repository.length) {
      selectedRecords.clear();
    } else {
      selectedRecords.addAll(repository.map((record) => record.id));
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
    showToastWidget(MDToastWidget(message: t.common.success, type: MDToastType.success));
  }

  void search(String keyword) {
    searchKeyword.value = keyword;
    repository.keyword = keyword;
    repository.refresh();
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