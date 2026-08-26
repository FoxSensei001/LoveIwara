import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/tag_dictionary_refresh.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 内存中保留的精简 Oreno3d 条目（仅当前语言译名 + 检索/排序所需的少量元数据）。
class _OrenoEntry {
  /// 当前语言译名。
  final String name;

  /// 日文原名（用于按原文检索 + 卡片字符串标签兜底）。
  final String ja;

  /// 作品数（用于热度排序）。
  final int workCount;

  /// 角色所属原作（日文原名，可空；用于角色列表副标题）。
  final String? origin;

  const _OrenoEntry(this.name, this.ja, this.workCount, this.origin);
}

/// 选择器/收藏用的公开条目。
class Oreno3dEntry {
  /// `origin` / `character` / `tag`。
  final String type;
  final String id;

  /// 当前语言译名。
  final String name;

  /// 日文原名。
  final String original;

  /// 作品数。
  final int workCount;

  /// 角色所属原作（已本地化，可空）。
  final String? origin;

  const Oreno3dEntry({
    required this.type,
    required this.id,
    required this.name,
    required this.original,
    required this.workCount,
    this.origin,
  });
}

/// Oreno3d 元数据（原作 / 角色 / 标签）本地化服务。
///
/// 数据来源（按优先级）：缓存的 CDN 快照 -> 打包兜底资源；启动后台从 jsDelivr CDN 刷新。
/// 词库结构：`{origins:{id:{n:{...},w,..}}, characters:{...,o}, tags:{...,g}}`。
///
/// 内存策略：只物化当前语言译名（+ 检索/排序所需的少量字段），切换语言时从数据源重建。
/// 运行时 Oreno3d 对象带数字 `id`，因此按 (类别, id) 精确映射；卡片上无 id 的字符串标签
/// 按「日文原名 -> 译名」兜底。
class Oreno3dLocalizationService extends GetxService {
  static Oreno3dLocalizationService get to =>
      Get.find<Oreno3dLocalizationService>();

  late final TagDictionaryFetcher _fetcher = TagDictionaryFetcher(
    url: CommonConstants.oreno3dTagsLocalizationCdnUrl,
    cacheFileName: 'oreno3d_tags.min.json',
    logTag: 'Oreno3d本地化',
  );

  final Map<String, _OrenoEntry> _origins = {};
  final Map<String, _OrenoEntry> _characters = {};
  final Map<String, _OrenoEntry> _tags = {};

  /// 日文原名 -> 当前语言译名（跨三类并集），用于无 id 的字符串标签兜底。
  final Map<String, String> _byJaName = {};

  final RxInt dataVersion = 0.obs;

  /// 当前内存里这份词库的身份（版本 / 内容指纹 / 条目数）。
  final Rxn<DictionarySnapshot> snapshot = Rxn<DictionarySnapshot>();

  /// 最近一次成功从 CDN 刷新的时间；从未成功过为 null。
  final Rxn<DateTime> lastRefreshedAt = Rxn<DateTime>();

  String? _loadedLocaleKey;
  bool _cdnRefreshScheduled = false;
  Worker? _localeWorker;

  static String currentLocaleKey() {
    final tag = slang.LocaleSettings.currentLocale.languageTag;
    switch (tag.toLowerCase()) {
      case 'zh-cn':
        return 'zh-CN';
      case 'zh-tw':
        return 'zh-TW';
      case 'ja':
        return 'ja';
      case 'en':
        return 'en';
      default:
        if (tag.toLowerCase().startsWith('zh')) return 'zh-CN';
        return 'en';
    }
  }

  /// 注册安全的展示名获取（按类别 + id，缺失时按日文原名兜底，再回退原名）。
  static String displayName({
    required String type,
    String? id,
    required String name,
  }) {
    if (!Get.isRegistered<Oreno3dLocalizationService>()) return name;
    return to.localize(type: type, id: id, name: name);
  }

  /// 注册安全的「按日文原名」展示（用于卡片上无 id 的字符串标签）。
  static String displayByName(String name) {
    if (!Get.isRegistered<Oreno3dLocalizationService>()) return name;
    return to.localizeByName(name);
  }

  Future<Oreno3dLocalizationService> init() async {
    await _loadForCurrentLocale();
    if (_loadedLocaleKey != null) {
      Get.forceAppUpdate();
    }
    final localeSetting =
        Get.find<ConfigService>().settings[ConfigKey.APPLICATION_LOCALE];
    if (localeSetting != null) {
      _localeWorker = ever(localeSetting, (_) => _onLocaleChanged());
    }
    _scheduleCdnRefresh();
    return this;
  }

  @override
  void onClose() {
    _localeWorker?.dispose();
    super.onClose();
  }

  Future<void> _onLocaleChanged() async {
    final target = currentLocaleKey();
    if (target == _loadedLocaleKey) return;
    await _loadForCurrentLocale();
    Get.forceAppUpdate();
  }

  Future<void> _loadForCurrentLocale() async {
    final raw = await _readSource();
    if (raw == null) return;
    _rebuild(raw, currentLocaleKey());
  }

  /// 读取词库原始 JSON 文本：缓存的 CDN 快照与打包资源之间取更新的那份。
  Future<String?> _readSource() => _fetcher.readFreshest(
        assetKey: CommonConstants.oreno3dTagsLocalizationAsset,
        countEntries: _countEntries,
      );

  void _scheduleCdnRefresh() {
    if (_cdnRefreshScheduled) return;
    _cdnRefreshScheduled = true;
    unawaited(_refreshFromCdn());
  }

  /// 从 CDN 刷新词库。判据与 iwara 侧共用（见 tag_dictionary_refresh.dart）：
  /// 有内容指纹按指纹判，没有则退回条目数——后者判不出「只改了译名」。
  Future<bool> _refreshFromCdn() async {
    final content = await _fetcher.fetch();
    if (content == null) return false;

    final incoming = peekSnapshot(content, _countEntries);
    if (incoming == null) return false;

    // CDN 那份确定更旧时（jsDelivr @master 缓存滞后），既不重建也不落盘。
    final stale = isStaleIncoming(snapshot.value, incoming);
    final changed = shouldRebuild(snapshot.value, incoming);
    if (changed) {
      _rebuild(content, currentLocaleKey());
      Get.forceAppUpdate();
    }
    if (!stale) await _fetcher.writeCache(content);
    lastRefreshedAt.value = DateTime.now();
    LogUtils.i(
      'Oreno3d 词库已从 CDN 刷新（$incoming，'
      '${stale ? '远端更旧，已忽略' : (changed ? '已应用' : '无变化')}）',
      'Oreno3d本地化',
    );
    return changed;
  }

  /// 用户主动检查词库更新。返回是否有变化。
  Future<bool> checkForUpdate() => _refreshFromCdn();

  static int _countEntries(Map<String, dynamic> decoded) {
    var total = 0;
    for (final key in const ['origins', 'characters', 'tags']) {
      total += (decoded[key] as Map?)?.length ?? 0;
    }
    return total;
  }



  void _rebuild(String content, String localeKey) {
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      snapshot.value = DictionarySnapshot(
        version: (decoded['version'] as num?)?.toInt() ?? 1,
        rev: decoded['rev'] as String?,
        count: _countEntries(decoded),
        builtAt: DateTime.tryParse('${decoded['builtAt'] ?? ''}')?.toUtc(),
      );

      void fill(String category, Map<String, _OrenoEntry> target) {
        target.clear();
        final m = decoded[category] as Map<String, dynamic>?;
        if (m == null) return;
        m.forEach((id, value) {
          final map = value as Map<String, dynamic>;
          final names = map['n'] as Map<String, dynamic>?;
          final name = _pick(names, localeKey);
          if (name.isEmpty) return;
          final ja = (names?['ja'] is String) ? names!['ja'] as String : name;
          final w = (map['w'] is int)
              ? map['w'] as int
              : int.tryParse('${map['w']}') ?? 0;
          final origin = map['o'] is String ? map['o'] as String : null;
          target[id] = _OrenoEntry(name, ja, w, origin);
          if (ja.isNotEmpty) _byJaName[ja] = name;
        });
      }

      _byJaName.clear();
      fill('origins', _origins);
      fill('characters', _characters);
      fill('tags', _tags);

      _loadedLocaleKey = localeKey;
      dataVersion.value++;
      LogUtils.i(
        'Oreno3d 词库已就绪（$localeKey，原作 ${_origins.length}/角色 ${_characters.length}/标签 ${_tags.length}）',
        'Oreno3d本地化',
      );
    } catch (e) {
      LogUtils.e('解析 Oreno3d 词库失败', tag: 'Oreno3d本地化', error: e);
    }
  }

  String _pick(Map<String, dynamic>? names, String localeKey) {
    if (names == null) return '';
    final localized = names[localeKey];
    if (localized is String && localized.isNotEmpty) return localized;
    final en = names['en'];
    if (en is String) return en;
    return '';
  }

  Map<String, _OrenoEntry>? _mapForType(String type) {
    switch (type) {
      case 'origin':
        return _origins;
      case 'character':
        return _characters;
      case 'tag':
        return _tags;
      default:
        return null;
    }
  }

  /// 注册安全的「原文（日文原名）」获取（按类别 + id，缺失回退 [fallback]）。
  static String originalDisplay({
    required String type,
    String? id,
    required String fallback,
  }) {
    if (!Get.isRegistered<Oreno3dLocalizationService>()) return fallback;
    return to.originalName(type: type, id: id, fallback: fallback);
  }

  /// 按 (类别, id) 取日文原名；缺失回退到 [fallback]。
  String originalName({
    required String type,
    String? id,
    required String fallback,
  }) {
    if (id != null && id.isNotEmpty) {
      final e = _mapForType(type)?[id];
      if (e != null && e.ja.isNotEmpty) return e.ja;
    }
    return fallback;
  }

  /// 按 (类别, id) 取译名；无 id 命中时按日文原名兜底；再回退到原名。
  String localize({required String type, String? id, required String name}) {
    if (id != null && id.isNotEmpty) {
      final byId = _mapForType(type)?[id];
      if (byId != null && byId.name.isNotEmpty) return byId.name;
    }
    final byName = _byJaName[name];
    if (byName != null && byName.isNotEmpty) return byName;
    return name;
  }

  /// 仅按日文原名取译名（用于无 id 的字符串标签）。
  String localizeByName(String name) => _byJaName[name] ?? name;

  Oreno3dEntry _toEntry(String type, String id, _OrenoEntry e) => Oreno3dEntry(
        type: type,
        id: id,
        name: e.name,
        original: e.ja,
        workCount: e.workCount,
        origin: e.origin == null ? null : (_byJaName[e.origin] ?? e.origin),
      );

  /// 在某一类别内检索（匹配当前语言译名 / 日文原名 / id）；
  /// 空查询返回按作品数降序的前 [limit] 条。
  List<Oreno3dEntry> search(String type, String query, {int limit = 50}) {
    final map = _mapForType(type);
    if (map == null) return const [];
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      final all = map.entries
          .map((e) => _toEntry(type, e.key, e.value))
          .toList()
        ..sort((a, b) => b.workCount.compareTo(a.workCount));
      return all.take(limit).toList();
    }

    final scored = <(int, Oreno3dEntry)>[];
    map.forEach((id, e) {
      final name = e.name.toLowerCase();
      final ja = e.ja.toLowerCase();
      int score = -1;
      if (id == q || name == q || ja == q) {
        score = 0;
      } else if (name.startsWith(q) || ja.startsWith(q)) {
        score = 1;
      } else if (name.contains(q) || ja.contains(q)) {
        score = 2;
      } else if (id.contains(q)) {
        score = 3;
      }
      if (score >= 0) scored.add((score, _toEntry(type, id, e)));
    });

    scored.sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      if (c != 0) return c;
      return b.$2.workCount.compareTo(a.$2.workCount);
    });
    return scored.take(limit).map((e) => e.$2).toList();
  }
}
