import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import 'package:i_iwara/app/models/tag.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/tag_dictionary_refresh.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 内存中保留的精简标签条目。
///
/// 为降低内存占用，**只物化「当前语言环境的译名」**（[name]）而不保留其它
/// 三种语言；评级仅用两个 bool 表示，避免重复存储 type 字符串。
/// 切换语言时由 [TagLocalizationService] 从数据源（缓存/打包资源）重建这张表。
class _SlimTag {
  /// 当前语言的译名（缺失时为空字符串，展示侧回退到原始 key）。
  final String name;

  /// 评级是否为 R18（ecchi）。
  final bool ecchi;

  /// 是否敏感。
  final bool sensitive;

  const _SlimTag(this.name, this.ecchi, this.sensitive);
}

/// Iwara 标签本地化服务。
///
/// 数据来源（按优先级）：
/// 1. 上次从 CDN 下载并缓存到应用目录的快照；
/// 2. 打包进 App 的兜底资源（[CommonConstants.iwaraTagsLocalizationAsset]）。
///
/// 启动后会在后台静默从 jsDelivr CDN 拉取最新词库并刷新缓存，因此无需发版也能更新译名。
///
/// 内存策略：内存里只保留「当前语言译名 + 原始 key + 评级位」这一份精简映射，
/// 不保留全部四种语言；切换语言时从数据源重建。
///
/// 提供两类能力：
/// - 展示：[localize] 把 `tag.id` 转为「当前语言环境」的译名；
/// - 搜索：[searchLocal] 支持用「当前语言译名 / 原始 key」匹配标签。
class TagLocalizationService extends GetxService {
  static TagLocalizationService get to => Get.find<TagLocalizationService>();

  late final TagDictionaryFetcher _fetcher = TagDictionaryFetcher(
    url: CommonConstants.iwaraTagsLocalizationCdnUrl,
    cacheFileName: 'iwara_tags.min.json',
    logTag: '标签本地化',
  );

  /// id -> 精简条目（仅当前语言）。
  final Map<String, _SlimTag> _entries = {};

  /// 数据版本号；每次词库加载/刷新/换语言后自增，便于 `Obx` 监听重建。
  final RxInt dataVersion = 0.obs;

  /// 当前内存里这份词库的身份（版本 / 内容指纹 / 条目数）。
  /// 供设置页展示，也是判断「远端那份要不要顶掉它」的依据。
  final Rxn<DictionarySnapshot> snapshot = Rxn<DictionarySnapshot>();

  /// 最近一次成功从 CDN 刷新的时间；从未成功过为 null。
  final Rxn<DateTime> lastRefreshedAt = Rxn<DateTime>();

  /// 当前 [_entries] 对应的语言 key，用于判断是否需要重建。
  String? _loadedLocaleKey;

  bool _cdnRefreshScheduled = false;
  Worker? _localeWorker;

  /// 当前语言环境对应的词库 key（`zh-CN` / `zh-TW` / `ja` / `en`）。
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
        // zh 其它地区回退到简中，其余回退英文。
        if (tag.toLowerCase().startsWith('zh')) return 'zh-CN';
        return 'en';
    }
  }

  /// 把原始 key 美化为可读文本：`3d_custom_girl` -> `3d custom girl`。
  static String prettifyId(String id) => id.replaceAll('_', ' ');

  /// 注册安全的展示名获取：服务尚未就绪时回退到美化后的原始 key。
  static String displayName(String tagId) {
    if (!Get.isRegistered<TagLocalizationService>()) return prettifyId(tagId);
    return to.localize(tagId);
  }

  /// 注册安全的「译名 + 原始 key」展示（如 `母亲 (mother)`），用于搜索结果列表。
  static String displayNameWithId(String tagId) {
    if (!Get.isRegistered<TagLocalizationService>()) return prettifyId(tagId);
    return to.localizeWithId(tagId);
  }

  /// 注册安全的本地搜索：服务未就绪时返回空列表。
  static List<Tag> search(String query, {int limit = 30}) {
    if (!Get.isRegistered<TagLocalizationService>()) return const [];
    return to.searchLocal(query, limit: limit);
  }

  /// 注册安全的本地优先合并：服务未就绪时原样返回 API 结果。
  static List<Tag> mergeLocal(
    String query,
    List<Tag> apiResults, {
    int localLimit = 30,
  }) {
    if (!Get.isRegistered<TagLocalizationService>()) return apiResults;
    return to.mergeLocalFirst(query, apiResults, localLimit: localLimit);
  }

  Future<TagLocalizationService> init() async {
    await _loadForCurrentLocale();
    // init() 是 unawaited 的，词库可能在首屏标签控件构建之后才就绪；
    // 多数展示控件是普通 StatelessWidget,只同步读 displayName 而不监听 dataVersion,
    // 若不主动刷新会一直停留在回退名。这里在首次加载完成后强制刷新一次。
    if (_loadedLocaleKey != null) {
      Get.forceAppUpdate();
    }
    // 监听语言切换：换语言后从数据源重建精简映射并刷新界面。
    final localeSetting =
        Get.find<ConfigService>().settings[ConfigKey.APPLICATION_LOCALE];
    if (localeSetting != null) {
      _localeWorker = ever(localeSetting, (_) => _onLocaleChanged());
    }
    // 词库就绪后再后台刷新，避免与首屏争抢资源。
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
    // 切换语言后，标签展示控件多为普通 StatelessWidget，统一强制刷新一次。
    Get.forceAppUpdate();
  }

  /// 从数据源（缓存 -> 打包资源）读取原始 JSON，并只为当前语言重建精简映射。
  Future<void> _loadForCurrentLocale() async {
    final raw = await _readSource();
    if (raw == null) return;
    _rebuild(raw, currentLocaleKey());
  }

  /// 读取词库原始 JSON 文本：缓存的 CDN 快照与打包资源之间取更新的那份。
  Future<String?> _readSource() => _fetcher.readFreshest(
        assetKey: CommonConstants.iwaraTagsLocalizationAsset,
        countEntries: _countTags,
      );

  void _scheduleCdnRefresh() {
    if (_cdnRefreshScheduled) return;
    _cdnRefreshScheduled = true;
    unawaited(_refreshFromCdn());
  }

  /// 从 CDN 刷新词库。
  ///
  /// [manual] 为 true 时是用户主动触发（设置页的「检查更新」），
  /// 会返回是否真的发生了变化，供界面给出反馈。
  Future<bool> _refreshFromCdn({bool manual = false}) async {
    final content = await _fetcher.fetch();
    if (content == null) return false;

    // 先校验能否解析出条目，避免把坏数据写入缓存。
    final incoming = peekSnapshot(content, _countTags);
    if (incoming == null) return false;

    final changed = shouldRebuild(snapshot.value, incoming);
    if (changed) {
      _rebuild(content, currentLocaleKey());
      // 词库变了但多数展示控件不监听 dataVersion，主动刷一次界面。
      Get.forceAppUpdate();
    }
    // 即使本次没重建也要写缓存——下次冷启动会读到新的那份。
    await _fetcher.writeCache(content);
    lastRefreshedAt.value = DateTime.now();
    LogUtils.i(
      '标签词库已从 CDN 刷新（$incoming，${changed ? '已应用' : '无变化'}）',
      '标签本地化',
    );
    return changed;
  }

  /// 用户主动检查词库更新。返回是否有变化。
  Future<bool> checkForUpdate() => _refreshFromCdn(manual: true);

  static int _countTags(Map<String, dynamic> decoded) =>
      (decoded['tags'] as Map?)?.length ?? 0;


  /// 解析原始 JSON，只为 [localeKey] 物化译名，重建精简映射。
  void _rebuild(String content, String localeKey) {
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final tags = decoded['tags'] as Map<String, dynamic>?;
      if (tags == null || tags.isEmpty) return;
      snapshot.value = DictionarySnapshot(
        version: (decoded['version'] as num?)?.toInt() ?? 1,
        rev: decoded['rev'] as String?,
        count: tags.length,
        builtAt: DateTime.tryParse('${decoded['builtAt'] ?? ''}')?.toUtc(),
      );

      final next = <String, _SlimTag>{};
      tags.forEach((id, value) {
        final map = value as Map<String, dynamic>;
        final names = (map['n'] as Map<String, dynamic>?);
        // 只取当前语言；缺失时回退英文，便于展示，仍只存一份字符串。
        String name = '';
        if (names != null) {
          final localized = names[localeKey];
          if (localized is String && localized.isNotEmpty) {
            name = localized;
          } else {
            final en = names['en'];
            if (en is String) name = en;
          }
        }
        final ecchi = (map['y'] as String?) == MediaRating.ECCHI.value;
        final sensitive = (map['s'] == 1 || map['s'] == true);
        next[id] = _SlimTag(name, ecchi, sensitive);
      });

      _entries
        ..clear()
        ..addAll(next);
      _loadedLocaleKey = localeKey;
      dataVersion.value++;
      LogUtils.i('标签词库已就绪（$localeKey，${_entries.length} 条）', '标签本地化');
    } catch (e) {
      LogUtils.e('解析标签词库失败', tag: '标签本地化', error: e);
    }
  }

  /// 是否已经收录该标签。
  bool contains(String tagId) => _entries.containsKey(tagId);

  /// 取标签在当前语言环境下的展示名；未收录或译名缺失则返回美化后的原始 key。
  String localize(String tagId) {
    final entry = _entries[tagId];
    if (entry == null || entry.name.isEmpty) return prettifyId(tagId);
    return entry.name;
  }

  /// 同 [localize]，但展示名与原始 key 不同时附带原始 key，便于辨识。
  /// 例如：`母亲 (mother)`。
  String localizeWithId(String tagId) {
    final localized = localize(tagId);
    if (localized.toLowerCase() == tagId.toLowerCase() ||
        localized == prettifyId(tagId)) {
      return localized;
    }
    return '$localized ($tagId)';
  }

  /// 还原为 API 通用的 [Tag]（带正确的 type / sensitive）。
  Tag _toTag(String id, _SlimTag e) => Tag(
        id: id,
        type: e.ecchi ? MediaRating.ECCHI.value : MediaRating.GENERAL.value,
        sensitive: e.sensitive,
      );

  /// 本地词库搜索：用「当前语言译名 / 原始 key」匹配，返回真实 [Tag]。
  ///
  /// 排序优先级：原始 key 完全相等 > 原始 key 前缀 > 当前语言译名前缀 >
  /// 当前语言译名包含 > 原始 key 包含。
  List<Tag> searchLocal(String query, {int limit = 30}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final scored = <_ScoredTag>[];
    _entries.forEach((id, e) {
      final lid = id.toLowerCase();
      final lname = e.name.toLowerCase();

      int score = -1;
      if (lid == q || lname == q) {
        score = 0;
      } else if (lid.startsWith(q)) {
        score = 1;
      } else if (lname.isNotEmpty && lname.startsWith(q)) {
        score = 2;
      } else if (lname.contains(q)) {
        score = 3;
      } else if (lid.contains(q)) {
        score = 4;
      }

      if (score >= 0) {
        scored.add(_ScoredTag(_toTag(id, e), score, id));
      }
    });

    scored.sort((a, b) {
      final c = a.score.compareTo(b.score);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

    return scored.take(limit).map((e) => e.tag).toList();
  }

  /// 将本地搜索结果合并到 API 结果之前，并按 id 去重（本地优先）。
  List<Tag> mergeLocalFirst(
    String query,
    List<Tag> apiResults, {
    int localLimit = 30,
  }) {
    final local = searchLocal(query, limit: localLimit);
    if (local.isEmpty) return apiResults;
    final seen = local.map((t) => t.id).toSet();
    final merged = <Tag>[...local];
    for (final tag in apiResults) {
      if (seen.add(tag.id)) merged.add(tag);
    }
    return merged;
  }
}

class _ScoredTag {
  final Tag tag;
  final int score;
  final String id;
  const _ScoredTag(this.tag, this.score, this.id);
}
