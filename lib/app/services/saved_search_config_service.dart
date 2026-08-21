import 'package:get/get.dart';
import 'package:i_iwara/app/models/saved_search_config.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 管理热门视频/图库/订阅页共用的「已保存快速筛选配置」。
///
/// 所有页面共用 [sharedSegment] 一个池子；segment 参数保留是为了
/// 兼容按池存储的数据结构（`{ segment: [config, ...] }`，持久化在
/// [ConfigService] 的 [ConfigKey.POPULAR_SAVED_SEARCH_CONFIGS]），
/// 历史上按 `video` / `image` 分池的旧数据会在启动时迁移合并。
class SavedSearchConfigService extends GetxService {
  static const String _tag = 'SavedSearchConfigService';

  /// 全局共享的配置池：热门视频 / 热门图库 / 订阅页读写同一份配置。
  static const String sharedSegment = 'media';

  /// 历史版本按栏目分池的旧键，启动时合并进 [sharedSegment] 后删除。
  static const List<String> _legacySegments = ['video', 'image'];

  final ConfigService _configService = Get.find<ConfigService>();

  /// segment -> 响应式列表（懒加载并缓存）。
  final Map<String, RxList<SavedSearchConfig>> _cache = {};

  /// 获取指定 segment 的响应式配置列表。可在 `Obx` 中直接监听。
  RxList<SavedSearchConfig> listFor(String segment) {
    return _cache.putIfAbsent(segment, () => _load(segment).obs);
  }

  @override
  void onInit() {
    super.onInit();
    _migrateLegacySegments();
  }

  /// 把旧版 `video` / `image` 两个池子的配置合并进共享池。
  ///
  /// 同步部分（缓存合并 + 删旧键）在 onInit 里当场完成，之后各页
  /// `listFor` 读到的就是合并后的结果；持久化异步落盘。旧键删除后
  /// 本方法自然幂等。
  void _migrateLegacySegments() {
    final map = _rawMap();
    if (!_legacySegments.any(map.containsKey)) return;

    final merged = <SavedSearchConfig>[...listFor(sharedSegment)];
    for (final segment in _legacySegments) {
      merged.addAll(_load(segment));
    }
    _cache[sharedSegment] = merged.obs;

    map.removeWhere((key, _) => _legacySegments.contains(key));
    map[sharedSegment] = merged.map((e) => e.toJson()).toList();
    _configService.setSetting(ConfigKey.POPULAR_SAVED_SEARCH_CONFIGS, map);
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

  /// newIndex 已由 ReorderableList 的 onReorderItem 回调按「移除 oldIndex 后」修正，
  /// 此处不再手工 -1。
  Future<void> reorder(String segment, int oldIndex, int newIndex) async {
    final list = listFor(segment);
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
