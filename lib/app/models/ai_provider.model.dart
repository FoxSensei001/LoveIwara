import 'dart:convert';

import 'package:i_iwara/app/services/ai_catalog_service.dart';

/// 一家 AI 供应商的**接入方式**——也就是「用 dartantic 的哪个 provider 去打」。
///
/// ⭐ 这个类只剩一件事：dartantic 的 `Provider` 接口**不声明任何能力**（没有 caps
/// 枚举），而各家在 `createChatModel` 里直接 `throw UnsupportedError`。不在调用前
/// 夹住，用户看到的就是一句英文异常。
///
/// ⛔ 它记的是「**这条 SDK 路子**吃不吃得下」，**不是**「这家服务商支不支持」，
/// 更不是「这个模型会不会」。三件事三个家：
///
/// | 事实 | 家 |
/// |---|---|
/// | SDK 路子吃不吃得下（xAI 传 temperature 就抛） | 本类 |
/// | 这家端点的脾气（静默忽略 json_schema / 要不要密钥） | [AiCatalogProvider] |
/// | 这个模型天生会什么（推理 / 函数调用 / 结构化输出） | [AiCatalogModel] |
///
/// 四张表的出处（dartantic_ai 3.4.2，读源码逐条核对过，不是推测）：
/// - `providers/openai_provider.dart:54` enableThinking → throw
/// - `providers/mistral_provider.dart:50` enableThinking → throw
/// - `providers/xai_provider.dart:45` **temperature 非空就 throw**
/// - `providers/anthropic_provider.dart:75`、`google_provider.dart:103`、
///   `ollama_provider.dart:61` 三家原样透传 enableThinking
/// - baseUrl：只有 openai / google / ollama 的构造函数收 `baseUrl`；
///   anthropic / mistral / xai 压根没这个参数，填了也是白填
abstract final class AiProviderKind {
  /// OpenAI 及**一切 OpenAI 兼容端点**（DeepSeek、硅基流动、智谱、各种中转、
  /// 自建网关）。绝大多数用户落在这一支。
  static const String openai = 'openai';

  static const String anthropic = 'anthropic';
  static const String google = 'google';

  /// 本机跑的模型。没有密钥这回事，也不该走代理。
  static const String ollama = 'ollama';

  static const String mistral = 'mistral';
  static const String xai = 'xai';

  static const List<String> all = [
    openai,
    anthropic,
    google,
    ollama,
    mistral,
    xai,
  ];

  /// 认不认识这个 kind。配置是可以被手改 / 被更高版本写过的，认不出来时
  /// 调用方应当按 [openai] 处理而不是崩——兼容端点是最宽的那一支。
  static bool isKnown(String kind) => all.contains(kind);

  static String normalize(String kind) {
    final k = kind.trim().toLowerCase();
    return isKnown(k) ? k : openai;
  }

  /// 给人看的名字。⛔ 不走 i18n：这些是产品名，不翻译。
  static String displayName(String kind) => switch (normalize(kind)) {
    anthropic => 'Anthropic',
    google => 'Google Gemini',
    ollama => 'Ollama',
    mistral => 'Mistral',
    xai => 'xAI',
    _ => 'OpenAI 兼容',
  };

  /// 这条 SDK 路子要不要密钥。Ollama 跑在本机，逼用户填一个假的密钥是没有意义
  /// 的刁难。⚠️ 更准的答案在目录上（LM Studio 也不要密钥，但它的 kind 是
  /// `openai`）——本表只是目录缺席时的地板。
  static bool needsApiKey(String kind) => normalize(kind) != ollama;

  /// 能不能开 thinking。开错了是 `UnsupportedError`，不是降级。
  static bool supportsThinking(String kind) => switch (normalize(kind)) {
    anthropic || google || ollama => true,
    _ => false,
  };

  /// 能不能下发 temperature。
  ///
  /// ⛔ xAI **任何非空 temperature 都会抛**（不是忽略）。所以这条必须在能力层
  /// 夹死，不能指望用户自己去关那个开关——否则选了 xAI 的人每一次调用都是
  /// UnsupportedError。
  static bool supportsTemperature(String kind) => normalize(kind) != xai;

  /// 能不能自定义端点地址。
  ///
  /// 填了却不生效是最难自查的一类配置错误（用户会以为是网络问题），所以
  /// UI 上对不支持的这几家要**把地址栏收起来**，而不是留着让人填。
  static bool supportsCustomBaseUrl(String kind) => switch (normalize(kind)) {
    openai || google || ollama => true,
    _ => false,
  };
}

/// 用户配置的**一条供应商连接**。
///
/// # ⭐ 它只存 delta
///
/// 可空字段 `null` ＝「跟目录走」，非空 ＝「用户明确改过」。所以：
///
/// - 目录更新（某家换了地址、发现某家其实认 json_schema）**自动到位**，
///   不用迁移任何数据；
/// - 用户改过的那几项继续赢，不会被目录悄悄改回去；
/// - UI 上「哪几项被我改过」是**可见的**（非空即改过），于是那枚「重置为默认」
///   的回转箭头才有得画。
///
/// ⛔ 改造前是反过来的：`AiProviderPreset.toProfile()` 把 baseUrl /
/// structuredOutput **拷进**用户档案。之后我们更新预设，老用户永远拿不到；而且
/// 分不出「用户特意填了这个地址」和「当年预设就是这个地址」，所以谁也不敢动那些
/// 兜底值。
///
/// # ⛔ [apiKey] 不进 JSON
///
/// 这个对象在内存里是完整的（带密钥），[toJson] 却**永远不写密钥**。密钥另存
/// `ConfigKey.AI_PROVIDER_KEYS`（`SecureFallbackCipher` 的 `enc1:` 信封）。
///
/// 为什么非要拆开：`config_backup_service.dart` 的 `_sensitiveConfigKeys` 是
/// **按 ConfigKey 整格剔除**的黑名单。密钥要是跟着档案列表存进同一格，备份就会把
/// **整张供应商列表**一起丢掉——用户看到的是「恢复备份后 AI 全没了」，而不只是
/// 要重填密钥。
class AiProvider {
  const AiProvider({
    required this.id,
    this.catalogId = '',
    this.name,
    this.kind,
    this.baseUrl,
    this.structuredOutput,
    this.streaming,
    this.headers = const {},
    this.enabled = true,
    this.apiKey = '',
  });

  /// 稳定标识。模型、用途绑定表、密钥存储都按它索引，**改名不该换 id**。
  final String id;

  /// 指向内置目录的哪一条（[AiCatalogProvider.id]）。空串 ＝ 完全自定义，
  /// 没有可继承的东西，下面那几项就必须自己填齐。
  final String catalogId;

  /// 以下全部「null ＝ 继承目录」。

  final String? name;
  final String? kind;
  final String? baseUrl;

  /// 这家端点**真的**认 `response_format: json_schema` 吗。
  ///
  /// 三层含义要分清（这是改造前那个孤立布尔的真正问题）：
  /// - `null` 且目录也没写 → **还不知道**，接入向导会真发一次去探；
  /// - `false` → 已知不认，直接走提示词契约那条路，别白等十几秒；
  /// - `true` → 已知认。
  final bool? structuredOutput;

  /// 允许流式。null ＝ 允许。
  final bool? streaming;

  /// 额外请求头（OpenRouter 的 `HTTP-Referer` / `X-Title` 一类）。
  final Map<String, String> headers;

  /// 关掉的供应商不出现在用途绑定的候选里，但配置留着。
  final bool enabled;

  /// ⛔ **不进 JSON**，见类文档。
  final String apiKey;

  AiProvider copyWith({
    String? id,
    String? catalogId,
    String? name,
    String? kind,
    String? baseUrl,
    bool? structuredOutput,
    bool? streaming,
    Map<String, String>? headers,
    bool? enabled,
    String? apiKey,
    // ⛔ 可空字段要能被改回 null（＝「不再覆盖，跟目录走」），而 `x ?? this.x`
    // 表达不出这件事。UI 上那枚「重置为默认」的回转箭头走的就是这几个开关。
    bool clearName = false,
    bool clearKind = false,
    bool clearBaseUrl = false,
    bool clearStructuredOutput = false,
    bool clearStreaming = false,
  }) => AiProvider(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    name: clearName ? null : (name ?? this.name),
    kind: clearKind ? null : (kind ?? this.kind),
    baseUrl: clearBaseUrl ? null : (baseUrl ?? this.baseUrl),
    structuredOutput: clearStructuredOutput
        ? null
        : (structuredOutput ?? this.structuredOutput),
    streaming: clearStreaming ? null : (streaming ?? this.streaming),
    headers: headers ?? this.headers,
    enabled: enabled ?? this.enabled,
    apiKey: apiKey ?? this.apiKey,
  );

  /// ⛔ 这里**没有 apiKey**，而且永远不要加回来。见类文档。
  ///
  /// 只写非空项：缺席就是「跟目录走」，写一堆 null 进去既占地方又容易被后来的人
  /// 当成「显式设成了空」。
  Map<String, dynamic> toJson() => {
    'id': id,
    if (catalogId.isNotEmpty) 'catalogId': catalogId,
    if (name != null) 'name': name,
    if (kind != null) 'kind': kind,
    if (baseUrl != null) 'baseUrl': baseUrl,
    if (structuredOutput != null) 'structuredOutput': structuredOutput,
    if (streaming != null) 'streaming': streaming,
    if (headers.isNotEmpty) 'headers': headers,
    if (!enabled) 'enabled': false,
  };

  /// 解出来的 [apiKey] 恒为空串——密钥由密钥存储单独补进来。
  factory AiProvider.fromJson(Map<String, dynamic> json) => AiProvider(
    id: (json['id'] as String?)?.trim() ?? '',
    catalogId: (json['catalogId'] as String?) ?? '',
    name: json['name'] as String?,
    kind: json['kind'] as String?,
    baseUrl: json['baseUrl'] as String?,
    structuredOutput: json['structuredOutput'] as bool?,
    streaming: json['streaming'] as bool?,
    headers: _headersFromJson(json['headers']),
    enabled: (json['enabled'] as bool?) ?? true,
  );

  static Map<String, String> _headersFromJson(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, String>{};
    raw.forEach((key, value) {
      if (key is String && value != null) out[key] = value.toString();
    });
    return out;
  }
}

/// 用户在某家供应商下**启用的一个模型**。同样只存 delta。
///
/// ⭐ 这一层是改造的核心：改造前「模型」只是档案上的一个字符串，于是
/// - 同一个 key 想跑两个模型 → 必须复制整份档案，密钥存两遍；
/// - `reasoning` / `structuredOutput` 挂在档案上 → 换模型时开关还留着上一个模型
///   的答案，不报错，只是从此每次都少发或多发一个参数。
class AiModel {
  const AiModel({
    required this.providerId,
    required this.modelId,
    this.name,
    this.temperature,
    this.sendTemperature,
    this.maxTokens,
    this.reasoning,
  });

  final String providerId;

  /// **发给服务端的那个名字**（不是目录里的规范 id）。
  /// 空串 ＝ 用服务端默认模型，这是合法配置（本地端点尤其常见），不要在调用前拦。
  final String modelId;

  /// 以下全部「null ＝ 继承」（目录 → 应用默认）。

  final String? name;
  final double? temperature;

  /// 要不要下发 temperature。null ＝ 自动（按模型能力与 SDK 路子决定）。
  ///
  /// ⛔ 这**不是**一张能力表，是**用户的选择**——有的端点会因为收到 temperature
  /// 而拒请求，而我们不可能穷举它们。所以留一个明确的「别发」给用户。
  /// （改造前它叫 `sendTemperature` 且默认 true，老配置迁过来时原样带着。）
  final bool? sendTemperature;

  /// 输出上限。null ＝ 继承；**0 ＝ 明确地不发这个参数**。
  ///
  /// ⛔ 两者不是一回事，别在读取时把 0 折成 null：用户特意清空那一栏的意思是
  /// 「让服务端用模型自己的上限」，而继承的意思是「照目录说的来」。
  final int? maxTokens;

  /// 用户想不想开 thinking。null ＝ 按模型能力自动（目录说它会推理就开）。
  final bool? reasoning;

  /// 这条模型在存储里的键，也是用途绑定表里存的值。
  String get key => '$providerId/$modelId';

  AiModel copyWith({
    String? providerId,
    String? modelId,
    String? name,
    double? temperature,
    bool? sendTemperature,
    int? maxTokens,
    bool? reasoning,
    bool clearName = false,
    bool clearTemperature = false,
    bool clearSendTemperature = false,
    bool clearMaxTokens = false,
    bool clearReasoning = false,
  }) => AiModel(
    providerId: providerId ?? this.providerId,
    modelId: modelId ?? this.modelId,
    name: clearName ? null : (name ?? this.name),
    temperature: clearTemperature ? null : (temperature ?? this.temperature),
    sendTemperature: clearSendTemperature
        ? null
        : (sendTemperature ?? this.sendTemperature),
    maxTokens: clearMaxTokens ? null : (maxTokens ?? this.maxTokens),
    reasoning: clearReasoning ? null : (reasoning ?? this.reasoning),
  );

  Map<String, dynamic> toJson() => {
    'providerId': providerId,
    'modelId': modelId,
    if (name != null) 'name': name,
    if (temperature != null) 'temperature': temperature,
    if (sendTemperature != null) 'sendTemperature': sendTemperature,
    if (maxTokens != null) 'maxTokens': maxTokens,
    if (reasoning != null) 'reasoning': reasoning,
  };

  factory AiModel.fromJson(Map<String, dynamic> json) => AiModel(
    providerId: (json['providerId'] as String?)?.trim() ?? '',
    modelId: (json['modelId'] as String?)?.trim() ?? '',
    name: json['name'] as String?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    sendTemperature: json['sendTemperature'] as bool?,
    maxTokens: (json['maxTokens'] as num?)?.toInt(),
    reasoning: json['reasoning'] as bool?,
  );
}

/// 合并过目录之后的**一份可以直接拿去发请求的配置**。
///
/// 读时合并，优先级 `用户 delta > 目录 > 应用默认`。请求构造（`AiService`）只看
/// 这个类，看不见 delta 也看不见目录——于是「继承规则」只有一处要改。
class AiResolvedModel {
  const AiResolvedModel({
    required this.providerId,
    required this.modelId,
    required this.providerName,
    required this.modelName,
    required this.kind,
    required this.baseUrl,
    required this.apiKey,
    required this.headers,
    required this.needsApiKey,
    required this.streaming,
    required this.structuredOutput,
    required this.capabilities,
    required this.temperature,
    required this.maxTokens,
    required this.reasoning,
    required this.contextWindow,
    required this.local,
  });

  final String providerId;
  final String modelId;
  final String providerName;
  final String modelName;
  final String kind;
  final String baseUrl;
  final String apiKey;
  final Map<String, String> headers;
  final bool needsApiKey;
  final bool streaming;

  /// 这条链路上能不能用原生结构化输出。**未知时为 false**——试一次的代价是白等
  /// 十几秒再降级，而降级那条路本来就走得通。
  final bool structuredOutput;

  /// 目录记的模型能力。目录查不到时是空集（不是「什么都不会」，是「不知道」，
  /// UI 上要按「未知」画而不是按「不支持」画）。
  final Set<AiModelCapability> capabilities;

  /// 要发出去的 temperature，null ＝ 不发。
  final double? temperature;

  /// 要发出去的输出上限，null ＝ 不发。
  final int? maxTokens;

  /// 要不要开 thinking。
  final bool reasoning;

  final int? contextWindow;

  /// 本机地址。⚠️ 不该走用户配的代理。
  final bool local;

  /// 密钥齐不齐。⛔ **不检查模型名**——空模型名是「用服务端默认」的合法配置。
  bool get isUsable => !needsApiKey || apiKey.trim().isNotEmpty;

  /// 只给「探一探」用：接入向导要强行开着 [structuredOutput] 发一次，看这家端点
  /// 是真认 json_schema 还是**静默忽略**它。
  ///
  /// ⛔ 别拿它去改别的字段：这是一份**合并好的结果**，改它等于绕过
  /// [resolveAiModel] 那三道闸门（SDK 路子 / 目录 / 用户 delta），而那正是
  /// 这次重构要收口的东西。要改配置请改 [AiProvider] / [AiModel]。
  AiResolvedModel copyWith({required bool structuredOutput}) => AiResolvedModel(
    providerId: providerId,
    modelId: modelId,
    providerName: providerName,
    modelName: modelName,
    kind: kind,
    baseUrl: baseUrl,
    apiKey: apiKey,
    headers: headers,
    needsApiKey: needsApiKey,
    streaming: streaming,
    structuredOutput: structuredOutput,
    capabilities: capabilities,
    temperature: temperature,
    maxTokens: maxTokens,
    reasoning: reasoning,
    contextWindow: contextWindow,
    local: local,
  );

  /// 端点地址解析成 Uri；空串或这一家不支持自定义地址时返回 null（＝用默认）。
  ///
  /// ⛔ 用 `hasScheme && hasAuthority` 判合法，不能只看 `Uri.parse` 抛不抛：
  /// `Uri.parse('api.openai.com')` 是**不抛**的（当相对 URI 解析成功），
  /// 照这么传下去请求会打到一个谁也想不到的地方。
  Uri? resolvedBaseUri() {
    if (!AiProviderKind.supportsCustomBaseUrl(kind)) return null;
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw FormatException('端点地址不合法：$baseUrl');
    }
    return uri;
  }
}

/// 应用层的默认值。目录和用户都没说时落到这儿。
abstract final class AiDefaults {
  /// 采样温度。⭐ 刻意**不**跟各家 API 的裸默认（1.0）走：这一层的主用途是翻译，
  /// 温度高了模型会开始「润色」原文——加词、改语气、把梗解释一遍。搜索那一路要
  /// 的是照着 schema 填表，同样不需要发散。
  static const double temperature = 0.3;

  /// ⭐ 输出上限的默认是**不发这个参数**（由服务端用该模型自己的上限）。
  ///
  /// ⛔ 之前写死 4096，那是上一代模型的上限：翻译一篇长帖会在半途**被硬截断**
  /// 且不报错，用户看到的是译文断在一句话中间，根本猜不到是这个数的问题。
  ///
  /// ⛔ 但也**不能换成另一个大常数**——「主流默认值」这种东西不存在：
  /// OpenAI / Google 不给就用模型自己的上限，Anthropic 的 `max_tokens` 却是
  /// **必填**；而各家上限差一个数量级，且每代都在涨。填大了有的服务端直接拒请求，
  /// 填小了静默截断。唯一不会过期、也不用猜的答案是**不填**。
  static const int maxTokens = 0;

  /// Anthropic 那条路的兜底：它的 `max_tokens` 必填，不给就是 400，
  /// [maxTokens] 的「不填」对它不成立。
  ///
  /// 取 64K 是因为它是**当前所有 Claude 模型都接受**的值——2026-09-21 查
  /// platform.claude.com 的 models/overview：Fable 5.1 / Opus 5 / Sonnet 5 的
  /// max output 都是 128K，最小的 Haiku 4.5 是 64K，取最小的那个才不会有模型
  /// 整个用不了。
  ///
  /// ⚠️ 这个数会过期。真正权威的来源是 Anthropic 的 Models API（`/v1/models`
  /// 的每条都带 `max_tokens`），dartantic 的 `listModels` 现在没透出来。
  /// 目录里记了 `maxOutputTokens` 的模型会优先用目录值，轮不到这个兜底。
  static const int anthropicFallbackMaxTokens = 65536;
}

/// 把一条 delta 配置合并成可以发请求的样子。
///
/// 做成**纯函数**（目录从参数进来，不从 `Get` 里摸）是为了能离线测：
/// 「用户没填 → 跟目录」「用户填了 → 用户赢」「目录也没有 → 应用默认」这三条
/// 正是最容易在重构里写反的地方。
AiResolvedModel resolveAiModel({
  required AiProvider provider,
  required AiModel model,
  AiCatalogProvider? providerCatalog,
  AiCatalogModel? modelCatalog,
}) {
  final kind = AiProviderKind.normalize(
    provider.kind ?? providerCatalog?.kind ?? AiProviderKind.openai,
  );
  final caps = modelCatalog?.capabilities ?? const <AiModelCapability>{};

  // ── thinking ─────────────────────────────────────────────────────────────
  // 三道闸叠加：这条 SDK 路子开得了吗、这个模型会吗、用户想不想。
  // ⛔ 用户没表态时**按模型能力自动**，而不是沿用某个档案上的旧布尔——
  // 「把 deepseek-chat 换成 deepseek-reasoner 后开关还是关着」就是那么来的。
  final wantsReasoning =
      model.reasoning ?? caps.contains(AiModelCapability.reasoning);
  final reasoning = wantsReasoning && AiProviderKind.supportsThinking(kind);

  // ── temperature ──────────────────────────────────────────────────────────
  // 推理模型通常不接受自定义 temperature；xAI 是发了就抛。
  final temperatureAllowed =
      AiProviderKind.supportsTemperature(kind) &&
      (providerCatalog?.sendsTemperature ?? true) &&
      (model.sendTemperature ?? true) &&
      !reasoning;
  final temperature = temperatureAllowed
      ? (model.temperature ?? AiDefaults.temperature)
      : null;

  // ── maxTokens ────────────────────────────────────────────────────────────
  // 0 ＝ 明确地不发。用户没说时先问目录，目录也没有才轮到 Anthropic 的兜底
  // （只有它的 max_tokens 是必填的）。
  final int? maxTokens;
  if (model.maxTokens != null) {
    maxTokens = model.maxTokens! > 0 ? model.maxTokens : null;
  } else if (modelCatalog?.maxOutputTokens != null) {
    maxTokens = modelCatalog!.maxOutputTokens;
  } else {
    maxTokens = kind == AiProviderKind.anthropic
        ? AiDefaults.anthropicFallbackMaxTokens
        : null;
  }

  // ── 结构化输出 ────────────────────────────────────────────────────────────
  // ⛔ 两件事都要成立：**端点**不把 json_schema 静默丢掉，**模型**也真支持。
  // 少问一边就是改造前那个孤立布尔的老毛病。
  // 目录没记过这个模型时不拿能力表当否决——中转上几百个模型目录多半没有，
  // 一律判成「不支持」会让所有人都走降级路。
  final endpointOk =
      provider.structuredOutput ?? providerCatalog?.structuredOutput;
  final modelOk =
      modelCatalog == null || caps.contains(AiModelCapability.structuredOutput);

  return AiResolvedModel(
    providerId: provider.id,
    modelId: model.modelId,
    providerName: provider.name ?? providerCatalog?.name ?? provider.id,
    modelName:
        model.name ??
        modelCatalog?.name ??
        (model.modelId.isEmpty ? '' : model.modelId),
    kind: kind,
    baseUrl: provider.baseUrl ?? providerCatalog?.baseUrl ?? '',
    apiKey: provider.apiKey,
    headers: provider.headers,
    needsApiKey:
        providerCatalog?.needsApiKey ?? AiProviderKind.needsApiKey(kind),
    streaming: provider.streaming ?? true,
    structuredOutput: (endpointOk ?? false) && modelOk,
    capabilities: caps,
    temperature: temperature,
    maxTokens: maxTokens,
    reasoning: reasoning,
    contextWindow: modelCatalog?.contextWindow,
    local: providerCatalog?.local ?? false,
  );
}

/// 整份 AI 配置：供应商列表 + 每家下面启用的模型。
///
/// 存成一格 JSON（`ConfigKey.AI_PROVIDER_PROFILES`），**不含密钥**。
class AiProviderConfig {
  const AiProviderConfig({this.providers = const [], this.models = const []});

  final List<AiProvider> providers;
  final List<AiModel> models;

  List<AiModel> modelsOf(String providerId) =>
      models.where((m) => m.providerId == providerId).toList();

  AiProvider? providerById(String id) {
    for (final p in providers) {
      if (p.id == id) return p;
    }
    return null;
  }

  AiModel? modelByKey(String key) {
    for (final m in models) {
      if (m.key == key) return m;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'providers': providers.map((e) => e.toJson()).toList(),
    'models': models.map((e) => e.toJson()).toList(),
  };

  /// 从配置里存的那串 JSON 解出来。
  ///
  /// 坏数据一律当成空配置：供应商配置坏掉不该让应用起不来，用户重新配一遍就是
  /// 了——但 id 为空的条目必须丢掉，它会让用途绑定表指向一个无主的东西；同理，
  /// 主人已经不在了的模型也要丢掉。
  static AiProviderConfig decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const AiProviderConfig();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AiProviderConfig();

      final providers = ((decoded['providers'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => AiProvider.fromJson(e.cast<String, dynamic>()))
          .where((e) => e.id.isNotEmpty)
          .toList();
      final ids = providers.map((e) => e.id).toSet();

      final models = ((decoded['models'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => AiModel.fromJson(e.cast<String, dynamic>()))
          .where((e) => ids.contains(e.providerId))
          .toList();

      return AiProviderConfig(providers: providers, models: models);
    } catch (_) {
      return const AiProviderConfig();
    }
  }

  static String encode(AiProviderConfig config) => jsonEncode(config.toJson());
}
