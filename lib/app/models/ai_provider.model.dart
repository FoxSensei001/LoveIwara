import 'dart:convert';

/// 一家 AI 供应商的**接入方式**。取值直接就是 dartantic 的 provider 名。
///
/// ⭐ 这个类存在的唯一理由是 [supportsThinking] / [supportsTemperature] /
/// [supportsCustomBaseUrl] / [needsApiKey] 这四张表：dartantic 的 `Provider`
/// 接口**不声明任何能力**（没有 caps 枚举），而各家在 `createChatModel` 里
/// 直接 `throw UnsupportedError`。不在调用前夹住，用户看到的就是一句英文异常。
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

  /// 要不要密钥。Ollama 跑在本机，逼用户填一个假的密钥是没有意义的刁难。
  static bool needsApiKey(String kind) => normalize(kind) != ollama;

  /// 能不能开 thinking。开错了是 `UnsupportedError`，不是降级。
  static bool supportsThinking(String kind) => switch (normalize(kind)) {
    anthropic || google || ollama => true,
    _ => false,
  };

  /// 能不能下发 temperature。
  ///
  /// ⛔ xAI **任何非空 temperature 都会抛**（不是忽略）。而档案的默认值是
  /// 「发 temperature」，所以这条必须在能力层夹死，不能指望用户自己去关那个
  /// 开关——否则选了 xAI 的人每一次调用都是 UnsupportedError。
  static bool supportsTemperature(String kind) => normalize(kind) != xai;

  /// 能不能自定义端点地址。
  ///
  /// 填了却不生效是最难自查的一类配置错误（用户会以为是网络问题），所以
  /// UI 上对不支持的这几家要**把地址栏收起来**，而不是留着让人填。
  static bool supportsCustomBaseUrl(String kind) => switch (normalize(kind)) {
    openai || google || ollama => true,
    _ => false,
  };

  /// 端点地址留空时实际会打到哪儿。只用来在 UI 上显示，不参与请求构造。
  static String? defaultBaseUrlHint(String kind) => switch (normalize(kind)) {
    openai => 'https://api.openai.com/v1',
    anthropic => 'https://api.anthropic.com/v1',
    google => 'https://generativelanguage.googleapis.com',
    ollama => 'http://localhost:11434',
    mistral => 'https://api.mistral.ai',
    xai => 'https://api.x.ai/v1',
    _ => null,
  };
}

/// 一份 AI 供应商配置。
///
/// ⭐ 与 `SignatureProvider`（小尾巴数据源）刻意同构：预置项只是「已经填好的
/// 一份档案」，选完之后它和用户手填的那份走同一条管线、在同一张列表里、用
/// 同样的方式被引用。用户只需要理解「供应商」这一个概念。
///
/// # ⛔ [apiKey] 不进 JSON
///
/// 这个对象在内存里是完整的（带密钥），[toJson] 却**永远不写密钥**。密钥另
/// 存 `StorageService` 的安全存储（健康设备走 Keychain/Keystore，坏设备走
/// `SecureFallbackCipher` 的 AES-GCM 兜底，两条路都不落明文）。
///
/// 为什么非要拆开：`config_backup_service.dart` 的 `_sensitiveConfigKeys` 是
/// **按 ConfigKey 整格剔除**的黑名单。密钥要是跟着档案列表存进同一格，备份
/// 就会把**整张供应商列表**一起丢掉——用户看到的是「恢复备份后 AI 全没了」，
/// 而不只是要重填密钥。
class AiProviderProfile {
  const AiProviderProfile({
    required this.id,
    required this.name,
    this.kind = AiProviderKind.openai,
    this.baseUrl = '',
    this.model = '',
    this.presetId = '',
    this.apiKey = '',
    this.reasoning = false,
    this.sendTemperature = true,
    this.streaming = true,
    this.structuredOutput = true,
    this.temperature = 0.3,
    this.maxTokens = 4096,
    this.headers = const {},
  });

  /// 稳定标识。用途绑定表与密钥存储都按它索引，**改名不该换 id**。
  final String id;

  /// 给人看的名字，用户可改。
  final String name;

  /// 见 [AiProviderKind]。
  final String kind;

  /// 自定义端点。空＝用这一家的默认地址。
  /// ⛔ 只有 [AiProviderKind.supportsCustomBaseUrl] 为真的几家吃得下。
  final String baseUrl;

  /// 模型名。空＝用服务端默认模型，这是合法配置（本地端点尤其常见），
  /// 不要在调用前拦。
  final String model;

  /// 从哪个预置项来的（[AiProviderPreset.id]），手填的是空串。
  final String presetId;

  /// ⛔ **不进 JSON**，见类文档。
  final String apiKey;

  /// 推理模型（thinking / 通常也不接受自定义 temperature）。
  final bool reasoning;

  /// 下发 temperature。能力层还会再夹一道（见 [effectiveTemperature]）。
  final bool sendTemperature;

  /// 允许流式。翻译对话框据此决定是逐字出还是一次性出。
  final bool streaming;

  /// 吃不吃得下 `outputSchema`（结构化输出）。
  ///
  /// ⭐ 做成开关而不是按 kind 推断：一批 OpenAI **兼容中转**并不支持
  /// `response_format: json_schema`，而它们的 kind 和官方 OpenAI 一模一样，
  /// 从 kind 上分不出来。AI 搜索要用到它，关掉就退回「这个供应商不能用于搜索」。
  final bool structuredOutput;

  final double temperature;
  final int maxTokens;

  /// 额外请求头（OpenRouter 的 `HTTP-Referer` / `X-Title` 一类）。
  final Map<String, String> headers;

  bool get needsApiKey => AiProviderKind.needsApiKey(kind);

  /// 密钥齐不齐。⛔ **不检查模型名**——空模型名是「用服务端默认」的合法配置。
  bool get isUsable => !needsApiKey || apiKey.trim().isNotEmpty;

  /// 实际要开的 thinking：用户想开 **且** 这一家吃得下。
  bool get effectiveThinking =>
      reasoning && AiProviderKind.supportsThinking(kind);

  /// 实际要下发的 temperature，null＝不发。
  ///
  /// 三道闸门叠加：这一家支不支持（xAI 发了就抛）、用户开没开、是不是推理模型
  /// （推理模型通常不接受自定义 temperature）。
  double? get effectiveTemperature {
    if (!AiProviderKind.supportsTemperature(kind)) return null;
    if (!sendTemperature) return null;
    if (reasoning) return null;
    return temperature;
  }

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

  AiProviderProfile copyWith({
    String? id,
    String? name,
    String? kind,
    String? baseUrl,
    String? model,
    String? presetId,
    String? apiKey,
    bool? reasoning,
    bool? sendTemperature,
    bool? streaming,
    bool? structuredOutput,
    double? temperature,
    int? maxTokens,
    Map<String, String>? headers,
  }) => AiProviderProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    presetId: presetId ?? this.presetId,
    apiKey: apiKey ?? this.apiKey,
    reasoning: reasoning ?? this.reasoning,
    sendTemperature: sendTemperature ?? this.sendTemperature,
    streaming: streaming ?? this.streaming,
    structuredOutput: structuredOutput ?? this.structuredOutput,
    temperature: temperature ?? this.temperature,
    maxTokens: maxTokens ?? this.maxTokens,
    headers: headers ?? this.headers,
  );

  /// ⛔ 这里**没有 apiKey**，而且永远不要加回来。见类文档。
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    if (baseUrl.isNotEmpty) 'baseUrl': baseUrl,
    if (model.isNotEmpty) 'model': model,
    if (presetId.isNotEmpty) 'presetId': presetId,
    'reasoning': reasoning,
    'sendTemperature': sendTemperature,
    'streaming': streaming,
    'structuredOutput': structuredOutput,
    'temperature': temperature,
    'maxTokens': maxTokens,
    if (headers.isNotEmpty) 'headers': headers,
  };

  /// 解出来的档案 [apiKey] 恒为空串——密钥由密钥存储单独补进来。
  factory AiProviderProfile.fromJson(Map<String, dynamic> json) =>
      AiProviderProfile(
        id: (json['id'] as String?)?.trim() ?? '',
        name: (json['name'] as String?) ?? '',
        kind: AiProviderKind.normalize((json['kind'] as String?) ?? ''),
        baseUrl: (json['baseUrl'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        presetId: (json['presetId'] as String?) ?? '',
        reasoning: (json['reasoning'] as bool?) ?? false,
        sendTemperature: (json['sendTemperature'] as bool?) ?? true,
        streaming: (json['streaming'] as bool?) ?? true,
        structuredOutput: (json['structuredOutput'] as bool?) ?? true,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.3,
        maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 4096,
        headers: _headersFromJson(json['headers']),
      );

  static Map<String, String> _headersFromJson(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, String>{};
    raw.forEach((key, value) {
      if (key is String && value != null) out[key] = value.toString();
    });
    return out;
  }

  /// 从配置里存的那串 JSON 解出列表。
  ///
  /// 坏数据一律当成空列表：供应商配置坏掉不该让应用起不来，用户重新配一遍
  /// 就是了——但 [id] 为空的条目必须丢掉，它会让用途绑定表指向一个无主的档案。
  static List<AiProviderProfile> decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => AiProviderProfile.fromJson(e.cast<String, dynamic>()))
          .where((e) => e.id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<AiProviderProfile> profiles) =>
      jsonEncode(profiles.map((e) => e.toJson()).toList());
}

/// 一个「已经填好的供应商」。用户在向导第一屏点的就是它。
///
/// ⛔ 第一屏不是空白表单：用户想要的是「一个能用的 AI」，让他从 baseUrl
/// 开始填是把我们的实现细节当成了他的任务。[custom] 那一条排在**最后**。
class AiProviderPreset {
  const AiProviderPreset({
    required this.id,
    required this.name,
    this.kind = AiProviderKind.openai,
    this.baseUrl,
    this.suggestedModel,
    this.reasoning = false,
    this.structuredOutput = true,
    this.custom = false,
  });

  final String id;
  final String name;
  final String kind;

  /// null＝用这一家的默认端点。
  final String? baseUrl;

  /// 拉不到模型列表时摆出来的建议值。⛔ 只是建议，不写死。
  final String? suggestedModel;

  final bool reasoning;

  /// 见 [AiProviderProfile.structuredOutput]。中转端点一律保守地给 false。
  final bool structuredOutput;

  /// 「自己填端点」那一条。
  final bool custom;

  /// 摊成一份可用的档案。[id] 由调用方给（要保证唯一）。
  AiProviderProfile toProfile({required String id, String? name}) =>
      AiProviderProfile(
        id: id,
        name: name ?? this.name,
        kind: kind,
        baseUrl: baseUrl ?? '',
        model: suggestedModel ?? '',
        presetId: this.id,
        reasoning: reasoning,
        // 推理模型通常不接受自定义 temperature；xAI 则是发了就抛，
        // 由 AiProviderProfile.effectiveTemperature 再兜一道。
        sendTemperature: !reasoning,
        structuredOutput: structuredOutput,
      );
}

/// 预置的供应商。
///
/// 来历：原先是 `ai_translation_setting_widget.dart` 里的私有 `_providerPresets`
/// （11 条），只有翻译设置页看得见。AI 不再只服务翻译之后它必须是公开的。
const List<AiProviderPreset> kAiProviderPresets = [
  AiProviderPreset(
    id: 'openai',
    name: 'OpenAI',
    kind: AiProviderKind.openai,
    baseUrl: 'https://api.openai.com/v1',
    suggestedModel: 'gpt-4o-mini',
  ),
  AiProviderPreset(
    id: 'openai_reasoning',
    name: 'OpenAI 推理 (o1 / o3 / o4)',
    kind: AiProviderKind.openai,
    baseUrl: 'https://api.openai.com/v1',
    reasoning: true,
  ),
  AiProviderPreset(
    id: 'anthropic',
    name: 'Anthropic Claude',
    kind: AiProviderKind.anthropic,
  ),
  AiProviderPreset(
    id: 'anthropic_reasoning',
    name: 'Anthropic Claude 推理 (extended thinking)',
    kind: AiProviderKind.anthropic,
    reasoning: true,
  ),
  AiProviderPreset(
    id: 'gemini',
    name: 'Google Gemini',
    kind: AiProviderKind.google,
  ),
  AiProviderPreset(
    id: 'gemini_reasoning',
    name: 'Google Gemini 推理 (thinking)',
    kind: AiProviderKind.google,
    reasoning: true,
  ),
  // 本机模型：不要密钥、不花钱、不出网。对这个 App 的用户群价值很高。
  AiProviderPreset(
    id: 'ollama',
    name: 'Ollama (本机)',
    kind: AiProviderKind.ollama,
    baseUrl: 'http://localhost:11434',
    // 本地模型对 json_schema 的支持参差，保守关掉，用户可自行打开。
    structuredOutput: false,
  ),
  AiProviderPreset(
    id: 'mistral',
    name: 'Mistral',
    kind: AiProviderKind.mistral,
  ),
  AiProviderPreset(id: 'xai', name: 'xAI Grok', kind: AiProviderKind.xai),
  AiProviderPreset(
    id: 'deepseek',
    name: 'DeepSeek',
    kind: AiProviderKind.openai,
    baseUrl: 'https://api.deepseek.com',
    suggestedModel: 'deepseek-chat',
  ),
  AiProviderPreset(
    id: 'deepseek_reasoner',
    name: 'DeepSeek 推理 (R1)',
    kind: AiProviderKind.openai,
    baseUrl: 'https://api.deepseek.com',
    suggestedModel: 'deepseek-reasoner',
    reasoning: true,
  ),
  AiProviderPreset(
    id: 'openrouter',
    name: 'OpenRouter',
    kind: AiProviderKind.openai,
    baseUrl: 'https://openrouter.ai/api/v1',
  ),
  AiProviderPreset(
    id: 'siliconflow',
    name: 'SiliconFlow 硅基流动',
    kind: AiProviderKind.openai,
    baseUrl: 'https://api.siliconflow.cn/v1',
    structuredOutput: false,
  ),
  AiProviderPreset(
    id: 'zhipu',
    name: '智谱 GLM',
    kind: AiProviderKind.openai,
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    structuredOutput: false,
  ),
  // ⛔ 永远排最后。
  AiProviderPreset(
    id: 'custom',
    name: '自定义 (OpenAI 兼容端点)',
    kind: AiProviderKind.openai,
    structuredOutput: false,
    custom: true,
  ),
];

AiProviderPreset? aiPresetById(String id) {
  for (final preset in kAiProviderPresets) {
    if (preset.id == id) return preset;
  }
  return null;
}
