import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:i_iwara/app/services/tag_dictionary_refresh.dart';
import 'package:i_iwara/app/utils/ai_model_id.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 一个模型**天生**会什么。
///
/// ⭐ 这几件事的权威归属是**模型**，不是供应商、也不是用户的开关。改造前它们是
/// 档案上的两个布尔（`reasoning` / `structuredOutput`），于是把 `deepseek-chat`
/// 换成 `deepseek-reasoner` 时开关还留着上一个模型的答案——不报错，只是从此
/// 每次都少发或多发一个参数。
enum AiModelCapability {
  /// 函数调用。AI 搜索的 `preview_search` 要它。
  functionCall,

  /// 推理 / thinking。推理模型通常也不接受自定义 temperature。
  reasoning,

  /// 原生结构化输出（`response_format: json_schema` 或等价的工具编排）。
  ///
  /// ⛔ 这只说**模型**支持。端点认不认是另一件事，见
  /// [AiCatalogProvider.structuredOutput]——一堆中转会**静默忽略** json_schema，
  /// 而它们服务的正是这些支持结构化输出的模型。
  structuredOutput,

  /// 看图。
  vision,

  /// 读文件。
  fileInput;

  /// 目录里的短码。
  static AiModelCapability? fromCode(String code) => switch (code) {
    'fc' => AiModelCapability.functionCall,
    'rs' => AiModelCapability.reasoning,
    'so' => AiModelCapability.structuredOutput,
    'vi' => AiModelCapability.vision,
    'fi' => AiModelCapability.fileInput,
    _ => null,
  };
}

/// 目录里的一家供应商。**只读**，是「出厂设定」那一层。
///
/// 用户改过的东西不在这里——那是另一层 delta，缺省即继承本条。
class AiCatalogProvider {
  const AiCatalogProvider({
    required this.id,
    required this.name,
    required this.kind,
    this.baseUrl = '',
    this.structuredOutput,
    this.needsApiKey = true,
    this.sendsTemperature = true,
    this.local = false,
    this.apiKeyUrl,
    this.docsUrl,
    this.homeUrl,
    this.suggestedModels = const [],
  });

  /// 目录里的稳定 id（`deepseek` / `silicon` / …）。用户档案按它指回来。
  final String id;

  final String name;

  /// 对应 `AiProviderKind` 的取值（`openai` / `anthropic` / …）。
  final String kind;

  /// 端点地址。空串＝这一家不需要（dartantic 的 anthropic / mistral / xai
  /// 构造函数压根不收 baseUrl）。
  ///
  /// ⭐ 目录里的地址**已经带好版本段**（多数是 `/v1`）：dartantic 把它原样当前缀，
  /// 少一个 `/v1` 就是 404。规范化在生成脚本里做，运行期不再猜。
  final String baseUrl;

  /// 这家端点**真的**认 json_schema 吗。null ＝ 还不知道。
  ///
  /// ⛔ 与 [AiModelCapability.structuredOutput] 是两件事：那个说模型支不支持，
  /// 这个说这条链路会不会把它静默丢掉。2026-09-20 实测：带 `strict:true` 的
  /// json_schema 发给某中转，HTTP 200、18 秒、626 个 completion token、回一整段
  /// 散文，一个字的 JSON 都没有，不报错不警告。换模型一样 → 是端点层面的。
  ///
  /// 未知时由接入向导那一步真发一次请求去探。
  final bool? structuredOutput;

  /// 要不要 API 密钥。本机跑的模型（Ollama / LM Studio）不要。
  final bool needsApiKey;

  /// 吃不吃得下 temperature。⛔ xAI 是**发了就抛**，不是忽略。
  final bool sendsTemperature;

  /// 跑在本机（回环地址）。⚠️ 套上用户配的代理反而不通。
  final bool local;

  /// 「去这里拿 key」。⛔ 生成脚本已剥掉上游的推广返利链接。
  final String? apiKeyUrl;
  final String? docsUrl;
  final String? homeUrl;

  /// 拉不到模型列表时摆出来的建议值。只有自家品牌的供应商有；
  /// 中转没有——而中转的 `/models` 本来就都拉得到。
  final List<String> suggestedModels;

  factory AiCatalogProvider.fromJson(String id, Map<String, dynamic> json) {
    final web = (json['w'] as Map?)?.cast<String, dynamic>();
    final so = json['so'];
    return AiCatalogProvider(
      id: id,
      name: (json['n'] as String?) ?? id,
      kind: (json['k'] as String?) ?? 'openai',
      baseUrl: (json['u'] as String?) ?? '',
      structuredOutput: so == null ? null : so == 1,
      needsApiKey: json['nk'] != 1,
      sendsTemperature: json['nt'] != 1,
      local: json['lo'] == 1,
      apiKeyUrl: web?['k'] as String?,
      docsUrl: web?['d'] as String?,
      homeUrl: web?['h'] as String?,
      suggestedModels: ((json['s'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }
}

/// 目录里的一个模型。**只读**。
class AiCatalogModel {
  const AiCatalogModel({
    required this.id,
    required this.name,
    this.capabilities = const {},
    this.contextWindow,
    this.maxOutputTokens,
  });

  /// 目录里的规范 id（不一定等于发给服务端的那个，见 [AiCatalogService.modelFor]）。
  final String id;

  final String name;
  final Set<AiModelCapability> capabilities;

  /// 上下文窗口。null ＝ 目录没记。
  final int? contextWindow;

  /// 输出上限。null ＝ 目录没记 —— ⛔ 这**不等于**「上限是零」，
  /// 拿它去填 maxTokens 的话要翻译成「不发这个参数」。
  final int? maxOutputTokens;

  bool has(AiModelCapability cap) => capabilities.contains(cap);

  factory AiCatalogModel.fromJson(String id, Map<String, dynamic> json) =>
      AiCatalogModel(
        id: id,
        name: (json['n'] as String?) ?? id,
        capabilities: {
          for (final code in ((json['c'] as List?) ?? const []))
            if (code is String && AiModelCapability.fromCode(code) != null)
              AiModelCapability.fromCode(code)!,
        },
        contextWindow: (json['w'] as num?)?.toInt(),
        maxOutputTokens: (json['o'] as num?)?.toInt(),
      );
}

/// AI 供应商与模型的**内置目录**。
///
/// # 它替掉了什么
///
/// 改造前是 `ai_provider.model.dart` 里 15 条写死的 `AiProviderPreset`，而且
/// `toProfile()` 是**快照**：baseUrl / structuredOutput 被拷进用户档案，之后我们
/// 更新预设，老用户永远拿不到。目录是**继承**的那一半——用户档案只存 delta，
/// 缺省即读这里，所以目录一更新就到位，不用迁移任何数据。
///
/// # 数据从哪儿来
///
/// 与标签词库同一套机制（[TagDictionaryFetcher] / [DictionarySnapshot]）：
/// 打包资源兜底 + jsDelivr 热更，取 `builtAt` 更新的那份。⭐ 于是「某家换了地址」
/// 「出了新模型」推到 master 就到位，**不用发版**。
///
/// 上游是 Cherry Studio 的 `@cherrystudio/provider-registry`（MIT），蒸馏脚本与
/// 许可说明见 `tool/data/ai_catalog/SOURCES.md`。
///
/// # ⛔ 查询必须是同步的
///
/// 调用方里有出现在 `build()` 里的（供应商列表、模型行的能力小标）。所以全部
/// 索引在 [init] 时一次建好，之后只读内存。
class AiCatalogService extends GetxService {
  static AiCatalogService get to => Get.find<AiCatalogService>();

  late final TagDictionaryFetcher _fetcher = TagDictionaryFetcher(
    url: CommonConstants.aiCatalogCdnUrl,
    cacheFileName: 'ai_catalog.min.json',
    logTag: 'AI目录',
  );

  final Map<String, AiCatalogProvider> _providers = {};
  final Map<String, AiCatalogModel> _models = {};

  /// 服务端模型名 → 规范 id 的三把钥匙，优先级从严到松。
  ///
  /// ⛔ 必须是三把而不是一把：只用最松的那把时，`gpt-oss:20b` 会和
  /// `gpt-oss-120b` 一起塌成同族名，抓到错的那条能力表。
  final Map<String, String> _aliases = {};
  final Map<String, String> _bySizedNorm = {};
  final Map<String, String> _byNorm = {};

  /// 当前这份目录的身份（版本 / 内容指纹 / 条目数），给设置页显示。
  final Rxn<DictionarySnapshot> snapshot = Rxn<DictionarySnapshot>();

  /// 每次目录重建后自增，供 `Obx` 监听重建。
  final RxInt dataVersion = 0.obs;

  bool _cdnRefreshScheduled = false;

  // ------------------------------------------------------------ 注册安全入口
  //
  // 目录是 unawaited 初始化的，而它的调用方（设置页、向导）可能更早构建。
  // 照 TagLocalizationService 的先例，静态入口在服务未就绪时**安静地降级**
  // 而不是抛——目录缺失只该让界面少几个能力小标，不该让设置页打不开。

  static AiCatalogProvider? providerOf(String catalogId) =>
      Get.isRegistered<AiCatalogService>() ? to.provider(catalogId) : null;

  static AiCatalogModel? modelOf(String wireModelId) =>
      Get.isRegistered<AiCatalogService>() ? to.modelFor(wireModelId) : null;

  static List<AiCatalogProvider> get allProviders =>
      Get.isRegistered<AiCatalogService>() ? to.providers : const [];

  // ---------------------------------------------------------------- 查询

  AiCatalogProvider? provider(String catalogId) => _providers[catalogId];

  /// 按「给人看的名字」排好序的全表。向导第一屏用它。
  List<AiCatalogProvider> get providers {
    final list = _providers.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// 查过的结果。⛔ 这不是洁癖：[modelFor] 被 `resolveAiModel` 调用，而那个出现在
  /// `build()` 里（供应商列表、模型行的能力小标、搜索页那枚 AI 钮的在场判定）。
  /// 查不到时要跑两趟 [normalizeModelId]，那里头是**若干条正则加一个不动点循环**
  /// ——每帧对每个模型跑一遍，和当年「每帧两次 jsonDecode」是同一种病。
  ///
  /// 目录在两次 [_rebuild] 之间是不变的，所以这张表只在重建时清。
  /// 查不到也要记（值为 null），否则「目录里没有的那几百个中转模型」永远命中不了缓存。
  final Map<String, AiCatalogModel?> _lookupCache = {};

  /// 拿**服务端报上来的那个模型名**去查目录。
  ///
  /// 四步，从严到松：精确 → 我们维护的真别名 → 保留参数规模的规范化 →
  /// 不保留规模的规范化。见 [normalizeModelId] 的文档表格。
  AiCatalogModel? modelFor(String wireModelId) {
    final raw = wireModelId.trim();
    if (raw.isEmpty) return null;
    if (_lookupCache.containsKey(raw)) return _lookupCache[raw];
    final found = _lookupUncached(raw);
    _lookupCache[raw] = found;
    return found;
  }

  AiCatalogModel? _lookupUncached(String raw) {
    final exact = _models[raw] ?? _models[raw.toLowerCase()];
    if (exact != null) return exact;

    final alias = _aliases[raw.toLowerCase()];
    if (alias != null && _models[alias] != null) return _models[alias];

    final sized = _bySizedNorm[normalizeModelId(raw, keepParameterSize: true)];
    if (sized != null) return _models[sized];

    final loose = _byNorm[normalizeModelId(raw)];
    return loose == null ? null : _models[loose];
  }

  // ---------------------------------------------------------------- 生命周期

  Future<AiCatalogService> init() async {
    final raw = await _fetcher.readFreshest(
      assetKey: CommonConstants.aiCatalogAsset,
      countEntries: _countEntries,
    );
    if (raw != null) _rebuild(raw);
    _scheduleCdnRefresh();
    return this;
  }

  void _scheduleCdnRefresh() {
    if (_cdnRefreshScheduled) return;
    _cdnRefreshScheduled = true;
    unawaited(refreshFromCdn());
  }

  /// 从 CDN 刷新目录。返回「这次真的换了内容」。
  Future<bool> refreshFromCdn() async {
    final content = await _fetcher.fetch();
    if (content == null) return false;

    // 先确认解得出条目，别把坏数据写进缓存。
    final incoming = peekSnapshot(content, _countEntries);
    if (incoming == null) return false;

    final stale = isStaleIncoming(snapshot.value, incoming);
    final changed = shouldRebuild(snapshot.value, incoming);
    if (changed) _rebuild(content);
    // 即使这次没重建也要落盘——下次冷启动会读到新的那份。
    if (!stale) await _fetcher.writeCache(content);
    return changed;
  }

  static int _countEntries(Map<String, dynamic> decoded) {
    final providers = (decoded['providers'] as Map?)?.length ?? 0;
    final models = (decoded['models'] as Map?)?.length ?? 0;
    return providers + models;
  }

  /// 解析并重建全部索引。
  ///
  /// ⛔ 解析失败**保留上一份**而不是清空：CDN 推坏了一次不该让 AI 设置页整个变空。
  void _rebuild(String raw) {
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final providersJson =
          (decoded['providers'] as Map?)?.cast<String, dynamic>() ?? const {};
      final modelsJson =
          (decoded['models'] as Map?)?.cast<String, dynamic>() ?? const {};
      if (providersJson.isEmpty && modelsJson.isEmpty) return;

      final providers = <String, AiCatalogProvider>{};
      providersJson.forEach((id, value) {
        if (value is Map) {
          providers[id] = AiCatalogProvider.fromJson(
            id,
            value.cast<String, dynamic>(),
          );
        }
      });

      final models = <String, AiCatalogModel>{};
      final bySized = <String, String>{};
      final byNorm = <String, String>{};
      modelsJson.forEach((id, value) {
        if (value is! Map) return;
        models[id] = AiCatalogModel.fromJson(id, value.cast<String, dynamic>());
        // ⛔ 用 putIfAbsent：多个规范 id 折到同一把钥匙时保留**先来的那条**。
        // 覆盖式赋值会让结果取决于 JSON 的键序，同一份目录两次构建可能不一样。
        bySized.putIfAbsent(
          normalizeModelId(id, keepParameterSize: true),
          () => id,
        );
        byNorm.putIfAbsent(normalizeModelId(id), () => id);
      });

      final aliases = <String, String>{};
      ((decoded['aliases'] as Map?) ?? const {}).forEach((key, value) {
        if (key is String && value is String) {
          aliases[key.toLowerCase()] = value;
        }
      });

      _providers
        ..clear()
        ..addAll(providers);
      _models
        ..clear()
        ..addAll(models);
      _bySizedNorm
        ..clear()
        ..addAll(bySized);
      _byNorm
        ..clear()
        ..addAll(byNorm);
      _aliases
        ..clear()
        ..addAll(aliases);
      // ⛔ 缓存的键是**服务端报的名字**，而它映到哪一条完全取决于这份目录。
      // 目录一换就必须清，否则 CDN 推了新模型进来，已经查过一次的那些
      // 仍然停在「查不到」。
      _lookupCache.clear();

      snapshot.value = peekSnapshot(raw, _countEntries);
      dataVersion.value++;
      LogUtils.i(
        'AI 目录已载入：${providers.length} 家供应商 / ${models.length} 个模型 '
            '(${snapshot.value})',
        'AI目录',
      );
    } catch (e) {
      LogUtils.w('解析 AI 目录失败，保留上一份：$e', 'AI目录');
    }
  }
}
