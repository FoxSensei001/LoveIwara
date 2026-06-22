import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 管理搜索结果页的「已保存搜索」。
///
/// 维护一份可响应式的列表，持久化到 [ConfigService] 的
/// [ConfigKey.SEARCH_SAVED_QUERIES]（结构为 `[savedSearch, ...]`）。
/// 每条已保存搜索自带分类信息，因此不按 segment 分桶，整体一个列表。
class SavedSearchService extends GetxService {
  static const String _tag = 'SavedSearchService';

  final ConfigService _configService = Get.find<ConfigService>();

  /// 响应式列表（懒加载并缓存）。可在 `Obx` 中直接监听。
  RxList<SavedSearch>? _cache;

  RxList<SavedSearch> get list => _cache ??= _load().obs;

  List<SavedSearch> _load() {
    try {
      final raw = _configService[ConfigKey.SEARCH_SAVED_QUERIES];
      if (raw is List) {
        return raw
            .map(
              (e) => SavedSearch.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
    } catch (e) {
      LogUtils.e('加载已保存搜索失败', tag: _tag, error: e);
    }
    return <SavedSearch>[];
  }

  Future<void> _persist() async {
    try {
      await _configService.setSetting(
        ConfigKey.SEARCH_SAVED_QUERIES,
        list.map((e) => e.toJson()).toList(),
      );
    } catch (e) {
      LogUtils.e('保存已保存搜索失败', tag: _tag, error: e);
    }
  }

  Future<void> add(SavedSearch search) async {
    list.add(search);
    await _persist();
  }

  Future<void> remove(String id) async {
    list.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> rename(String id, String name) async {
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(name: name);
      await _persist();
    }
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 ||
        oldIndex >= list.length ||
        newIndex < 0 ||
        newIndex >= list.length) {
      return;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _persist();
  }
}
