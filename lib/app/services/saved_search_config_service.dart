import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 管理热门视频/图库的「已保存快速筛选配置」。
///
/// 按 segment（`video` / `image`）分别维护一份可响应式的列表，
/// 持久化到 [ConfigService] 的 [ConfigKey.POPULAR_SAVED_SEARCH_CONFIGS]
/// （结构为 `{ segment: [config, ...] }`）。
class SavedSearchConfigService extends GetxService {
  static const String _tag = 'SavedSearchConfigService';

  final ConfigService _configService = Get.find<ConfigService>();

  /// segment -> 响应式列表（懒加载并缓存）。
  final Map<String, RxList<SavedSearchConfig>> _cache = {};

  /// 获取指定 segment 的响应式配置列表。可在 `Obx` 中直接监听。
  RxList<SavedSearchConfig> listFor(String segment) {
    return _cache.putIfAbsent(segment, () => _load(segment).obs);
  }

  Map<String, dynamic> _rawMap() {
    final raw = _configService[ConfigKey.POPULAR_SAVED_SEARCH_CONFIGS];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  List<SavedSearchConfig> _load(String segment) {
    try {
      final segList = _rawMap()[segment];
      if (segList is List) {
        return segList
            .map(
              (e) =>
                  SavedSearchConfig.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
    } catch (e) {
      LogUtils.e('加载已保存筛选配置失败', tag: _tag, error: e);
    }
    return <SavedSearchConfig>[];
  }

  Future<void> _persist(String segment) async {
    try {
      final map = _rawMap();
      map[segment] = listFor(segment).map((e) => e.toJson()).toList();
      await _configService.setSetting(
        ConfigKey.POPULAR_SAVED_SEARCH_CONFIGS,
        map,
      );
    } catch (e) {
      LogUtils.e('保存筛选配置失败', tag: _tag, error: e);
    }
  }

  Future<void> add(String segment, SavedSearchConfig config) async {
    listFor(segment).add(config);
    await _persist(segment);
  }

  Future<void> remove(String segment, String id) async {
    listFor(segment).removeWhere((e) => e.id == id);
    await _persist(segment);
  }

  Future<void> rename(String segment, String id, String name) async {
    final list = listFor(segment);
    final idx = list.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(name: name);
      await _persist(segment);
    }
  }

  Future<void> reorder(String segment, int oldIndex, int newIndex) async {
    final list = listFor(segment);
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 ||
        oldIndex >= list.length ||
        newIndex < 0 ||
        newIndex >= list.length) {
      return;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    await _persist(segment);
  }
}
