import 'dart:async';
import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/utils/ai_error_describe.dart';
import 'package:i_iwara/app/utils/ai_json_extract.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 结构化输出要用的 schema 构造器，**从这里转出去**。
///
/// ⭐ `AiService` 要是「全 App 唯一的 AI 调用入口」，调用方就不该为了写一个
/// schema 再去 import dartantic——那等于把 SDK 泄漏回每一个用它的地方，将来
/// 换 SDK 又是满仓库改 import。`S` / `Schema` 本身来自 `json_schema_builder`，
/// 已经在依赖树里（dartantic_interface 转出的），不是新增依赖。
export 'package:dartantic_ai/dartantic_ai.dart' show S, Schema;

/// 一次 AI 调用要的全部东西。
///
/// ⛔ 注意这里**没有任何"翻译"的痕迹**：提示词由调用方给。这正是把 AI 从
/// `TranslationService` 里抽出来的意义——服务只管"怎么调"，"调来干嘛"归调用方。
class AiRequest {
  const AiRequest({
    required this.task,
    required this.input,
    this.system = '',
    this.profile,
    this.timeout,
    this.timeoutMessage,
    this.decorateError,
    this.streamErrorLabel,
  });

  /// 用哪个用途的档案。[profile] 非空时它只用于记账。
  final AiTask task;

  /// 用户内容。
  final String input;

  /// 系统提示词，空串＝不带。
  final String system;

  /// 指定档案（设置页的"测试"走这条：拿**还没保存**的那份配置去试）。
  final AiProviderProfile? profile;

  final Duration? timeout;

  /// 超时时报给用户的那句话。
  ///
  /// ⛔ 本服务**不碰 i18n**：它不知道自己是在替翻译、搜索还是小尾巴干活，
  /// 拿不准该用哪一族文案。用户看得见的措辞一律由调用方给，服务只回技术原因。
  final String? timeoutMessage;

  /// 把技术原因包装成本域的措辞（"AI 翻译失败: <原因>(未配置: API密钥)"）。
  ///
  /// ⭐ 必须是个**回调**而不是一个前缀字符串：流式失败降级时，最终报出来的那
  /// 句话是在 [AiService] 内部拼的，调用方够不着。给字符串就只能拼前缀，
  /// "(未配置: …)" 这种要贴在**后面**的自查提示会整条丢掉——而那正是用户
  /// 最需要看到的一句。
  final String Function(String technicalReason)? decorateError;

  /// 降级也失败时，用来标注"最先出问题的是流式那一步"的措辞。
  final String? streamErrorLabel;

  String decorate(String technicalReason) =>
      decorateError?.call(technicalReason) ?? technicalReason;
}

/// 档案从哪儿来。
///
/// ⭐ 做成一个口子是为了让"存储"这件事只有一处要改：P0 的实现读的是历史遗留
/// 的 12 枚 `AI_TRANSLATION_*` 配置项（**行为与改造前完全一致**），P1 换成
/// 「档案列表 JSON + 安全存储里的密钥」时，只换这个类的实现。
///
/// ⛔ 为什么不在 P0 就把存储换掉：设置页那 1800 行现在仍然直接读写
/// `AI_TRANSLATION_*`。存储先换、UI 后换的话，中间会出现**两个事实源**——
/// 用户在设置页改的东西和服务实际用的东西不是同一份，而且没有任何征兆。
abstract class AiProfileStore {
  /// 全部档案（P0 下至多一条）。
  List<AiProviderProfile> get profiles;

  /// 某个用途实际该用哪一份。没有可用档案时返回 null。
  AiProviderProfile? profileFor(AiTask task);
}

/// P0 的档案来源：把历史遗留的 12 枚 `AI_TRANSLATION_*` 读成一份档案。
///
/// 所有用途共用这一份——在还没有绑定 UI 之前，这是唯一诚实的行为
/// （而不是让搜索/小尾巴"没有配置可用"）。
class LegacyConfigProfileStore implements AiProfileStore {
  LegacyConfigProfileStore(this._config);

  final ConfigService _config;

  /// 历史遗留档案的固定 id。P1 迁移时会以它作为第一条档案的 id，
  /// 这样用途绑定表在迁移前后指向同一个东西。
  static const String legacyProfileId = 'legacy';

  T? _get<T>(ConfigKey key) => _config[key] as T?;

  @override
  List<AiProviderProfile> get profiles {
    final profile = _readLegacy();
    return profile == null ? const [] : [profile];
  }

  @override
  AiProviderProfile? profileFor(AiTask task) => _readLegacy();

  AiProviderProfile? _readLegacy() {
    final kind = AiProviderKind.normalize(
      _get<String>(ConfigKey.AI_TRANSLATION_PROVIDER) ?? AiProviderKind.openai,
    );
    return AiProviderProfile(
      id: legacyProfileId,
      name: AiProviderKind.displayName(kind),
      kind: kind,
      baseUrl: _get<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '',
      model: _get<String>(ConfigKey.AI_TRANSLATION_MODEL) ?? '',
      apiKey: _get<String>(ConfigKey.AI_TRANSLATION_API_KEY) ?? '',
      reasoning: _get<bool>(ConfigKey.AI_TRANSLATION_REASONING_MODEL) ?? false,
      sendTemperature:
          _get<bool>(ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE) ?? true,
      streaming:
          _get<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ?? true,
      // 历史配置里没有这一项，保守给 false ＝「别试 json_schema，直接走提示词
      // 契约」。实测绝大多数中转会**静默忽略** json_schema（见 [AiService.structured]），
      // 先试一次只是白等十几秒、白烧几百个 token。
      structuredOutput: false,
      temperature: _get<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.3,
      maxTokens: _get<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 4096,
    );
  }
}

/// 全 App **唯一**的 AI 调用入口。
///
/// # 它管什么
///
/// - 按 [AiProviderProfile] 造 dartantic 的 `Provider` / `Agent`，并在造之前
///   把各家的怪癖夹住（见 [AiProviderKind]）；
/// - 三种调用形态：[complete]（一次要完）、[stream]（逐字）、[structured]
///   （吐 JSON，给 AI 搜索用）；
/// - 流式的生命周期：超时、中断、失败降级为非流式；
/// - 记账（[usageOf]）。
///
/// # 它不管什么
///
/// 提示词、目标语言、要不要用 AI、失败之后退回谁——那些是**用途**的事，
/// 归 `TranslationService` / 搜索 / `SignatureService` 各自管。
///
/// # 代理
///
/// 应用启动时设了 `HttpOverrides.global`，进程级覆盖所有 `HttpClient`，
/// dartantic 底层 package:http 的默认客户端会自动走用户配置的代理。
/// ⚠️ Ollama 是本机地址，走代理反而会不通——这一条 P1 接入本地端点时要验。
class AiService extends GetxService {
  AiService({AiProfileStore? store}) : _injectedStore = store;

  final AiProfileStore? _injectedStore;

  ConfigService get _config => Get.find<ConfigService>();

  /// 记账要用的配置服务，**拿不到就算了**。
  ///
  /// ⛔ 两个理由，都不是洁癖：
  /// - 用量统计写不进去**不该让一次 AI 调用失败**（记账是附带品，不是功能）；
  /// - 硬绑 `Get.find<ConfigService>()` 会让本服务离不开 sqlite，于是"拿真
  ///   端点验一次"这种事非得把整个应用启起来不可。
  ConfigService? get _configOrNull =>
      Get.isRegistered<ConfigService>() ? Get.find<ConfigService>() : null;

  late final AiProfileStore _store =
      _injectedStore ?? LegacyConfigProfileStore(_config);

  AiProfileStore get store => _store;

  /// 流式调用的默认超时。翻译一段长文本可能真的要这么久。
  static const Duration defaultStreamTimeout = Duration(seconds: 120);

  /// 非流式调用的默认超时。
  static const Duration defaultRequestTimeout = Duration(seconds: 90);

  // ------------------------------------------------------------- 流式状态表
  //
  // 这一套原样来自 TranslationService（改造前 :805-1009），只是键名从
  // translationId 改成 requestId——它本来就与"翻译"无关。

  final Map<String, StreamController<String>> _activeStreams = {};
  final Map<String, Timer> _timeouts = {};
  final Map<String, StreamSubscription<ChatResult<String>>> _subscriptions = {};
  final Map<String, void Function(String reasoning)> _reasoningCallbacks = {};

  int _requestSeq = 0;

  // ---------------------------------------------------------------- 记账

  /// ⛔ 懒加载而不是在 `init()` 里读：本服务在启动流程的**同步**那一段注册
  /// （`_registerFeatureServices` 是 `void`），给它加一个 async init 会逼着
  /// 整条注册链改成异步。用量表又不是启动必需品，第一次用到时再读就行。
  Map<AiTask, AiUsageStat>? _usageCache;

  Map<AiTask, AiUsageStat> get _usage => _usageCache ??= AiUsageStat.decodeMap(
    _configOrNull?[ConfigKey.AI_USAGE_STATS_KEY] as String?,
  );

  AiUsageStat usageOf(AiTask task) => _usage[task] ?? AiUsageStat.zero;

  Map<AiTask, AiUsageStat> get usage => Map.unmodifiable(_usage);

  Future<void> resetUsage() async {
    _usageCache = const {};
    await _configOrNull?.setSetting(ConfigKey.AI_USAGE_STATS_KEY, '');
  }

  void _account(
    AiTask task, {
    LanguageModelUsage? tokens,
    bool failed = false,
  }) {
    final next = Map<AiTask, AiUsageStat>.from(_usage);
    next[task] = (_usage[task] ?? AiUsageStat.zero).plus(
      calls: 1,
      promptTokens: tokens?.promptTokens ?? 0,
      responseTokens: tokens?.responseTokens ?? 0,
      failures: failed ? 1 : 0,
    );
    _usageCache = next;

    // 写盘失败不该影响调用本身，所以不 await、也不让异常冒出来。
    final config = _configOrNull;
    if (config == null) return;
    unawaited(
      config
          .setSetting(ConfigKey.AI_USAGE_STATS_KEY, AiUsageStat.encodeMap(next))
          .catchError((Object e) {
            LogUtils.w('AI 用量写入失败：$e', 'AiService');
          }),
    );
  }

  // ------------------------------------------------------------ Agent 构造

  /// 按 kind 造 dartantic 的 Provider。
  ///
  /// ⛔ baseUrl 只对 openai / google / ollama 生效——另外三家的构造函数**没有**
  /// 这个参数。夹在 [AiProviderProfile.resolvedBaseUri] 里，不在这儿重复判断。
  Provider buildProvider(AiProviderProfile profile) {
    final uri = profile.resolvedBaseUri();
    final key = profile.apiKey.trim();
    final headers = profile.headers;

    return switch (profile.kind) {
      AiProviderKind.anthropic => AnthropicProvider(
        apiKey: key,
        headers: headers,
      ),
      AiProviderKind.google => GoogleProvider(
        apiKey: key,
        baseUrl: uri,
        headers: headers,
      ),
      AiProviderKind.ollama => OllamaProvider(baseUrl: uri, headers: headers),
      AiProviderKind.mistral => MistralProvider(apiKey: key, headers: headers),
      AiProviderKind.xai => XAIProvider(apiKey: key, headers: headers),
      _ => OpenAIProvider(apiKey: key, baseUrl: uri, headers: headers),
    };
  }

  /// 各家 maxTokens 的字段名都不一样，且类型不同。
  ChatModelOptions _optionsFor(AiProviderProfile profile) =>
      switch (profile.kind) {
        AiProviderKind.anthropic => AnthropicChatOptions(
          maxTokens: profile.maxTokens,
        ),
        AiProviderKind.google => GoogleChatModelOptions(
          maxOutputTokens: profile.maxTokens,
        ),
        AiProviderKind.ollama => OllamaChatOptions(
          numPredict: profile.maxTokens,
        ),
        AiProviderKind.mistral => MistralChatModelOptions(
          maxTokens: profile.maxTokens,
        ),
        // xAI 走的是 OpenAI 那套 options（XAIProvider extends OpenAIProvider）
        _ => OpenAIChatOptions(maxTokens: profile.maxTokens),
      };

  Agent buildAgent(AiProviderProfile profile) => Agent.forProvider(
    buildProvider(profile),
    chatModelName: profile.model.trim().isEmpty ? null : profile.model.trim(),
    temperature: profile.effectiveTemperature,
    enableThinking: profile.effectiveThinking,
    chatModelOptions: _optionsFor(profile),
  );

  // ------------------------------------------------------------------ 查询

  AiProviderProfile? profileFor(AiTask task) => _store.profileFor(task);

  List<AiProviderProfile> get profiles => _store.profiles;

  /// 这个用途现在能不能用（有档案且密钥齐）。
  bool isAvailable(AiTask task) => profileFor(task)?.isUsable ?? false;

  AiProviderProfile? _resolve(AiRequest req) =>
      req.profile ?? profileFor(req.task);

  List<ChatMessage> _history(AiRequest req) =>
      req.system.trim().isEmpty ? const [] : [ChatMessage.system(req.system)];

  // -------------------------------------------------------------- 一次要完

  Future<ApiResult<String>> complete(AiRequest req) async {
    final profile = _resolve(req);
    if (profile == null) {
      return ApiResult.fail(req.decorate(_noProfileMessage()));
    }
    try {
      final result = await buildAgent(profile)
          .send(req.input, history: _history(req))
          .timeout(req.timeout ?? defaultRequestTimeout);
      _account(req.task, tokens: result.usage);
      return ApiResult.success(message: '', data: result.output);
    } catch (e) {
      _account(req.task, failed: true);
      LogUtils.e('AI 调用失败（${req.task.wireName}）', tag: 'AiService', error: e);
      return ApiResult.fail(
        req.decorate(describeRequestError(e)),
        exception: e,
      );
    }
  }

  // ---------------------------------------------------------------- 结构化

  /// 让模型吐一份 JSON。AI 搜索走这条。
  ///
  /// # ⛔ 为什么不是简单地把 [schema] 交给 SDK 就完了
  ///
  /// 2026-09-20 拿真中转实测：请求里带
  /// `response_format:{type:json_schema, strict:true}`，中转**静默忽略**——不报
  /// 错、不警告，HTTP 200，回一整段散文（18 秒、626 个 completion token）。换个
  /// 模型（deepseek）一模一样，所以是**中转层面**的。经 dartantic 走 `sendFor`
  /// 时，失败形态还不稳定：一次是 ` ```json ` 围栏撞上 `jsonDecode` 抛
  /// `FormatException`，一次是干等 45 秒超时。
  ///
  /// 而同一个问题改成「提示词里要求只回 JSON」的纯文本调用，当场就回了干净的
  /// `{...}`。所以这里有两条路：
  ///
  /// - [AiProviderProfile.structuredOutput] 为真 → 先试 SDK 的原生结构化输出
  ///   （Anthropic / Google 走工具调用编排，官方 OpenAI 走 response_format，
  ///   这几家是可靠的），**失败再退回文本契约**；
  /// - 为假 → 直接走文本契约。
  ///
  /// ⛔ 这个 flag 现在的含义是「端点真支持 json_schema」，**不是**「能不能用」。
  /// 早先版本在 flag 为假时直接拒绝，等于让绝大多数中转用户用不了 AI 搜索。
  Future<ApiResult<Map<String, dynamic>>> structured(
    AiRequest req, {
    required Schema schema,
  }) async {
    final profile = _resolve(req);
    if (profile == null) {
      return ApiResult.fail(req.decorate(_noProfileMessage()));
    }

    if (profile.structuredOutput) {
      try {
        final result = await buildAgent(profile)
            .sendFor<Map<String, dynamic>>(
              req.input,
              outputSchema: schema,
              history: _history(req),
            )
            .timeout(req.timeout ?? defaultRequestTimeout);
        _account(req.task, tokens: result.usage);
        return ApiResult.success(message: '', data: result.output);
      } catch (e) {
        // 不直接报错：端点很可能只是不认 json_schema，文本契约那条路还能走通。
        LogUtils.w('原生结构化输出失败，退回提示词契约：${describeRequestError(e)}', 'AiService');
      }
    }

    return _structuredViaTextContract(req, schema);
  }

  /// 文本契约：把 schema 写进提示词，再从自由文本里把 JSON 抠出来。
  Future<ApiResult<Map<String, dynamic>>> _structuredViaTextContract(
    AiRequest req,
    Schema schema,
  ) async {
    final contract = _jsonContractPrompt(req.system, schema);
    final result = await complete(
      AiRequest(
        task: req.task,
        input: req.input,
        system: contract,
        profile: req.profile,
        timeout: req.timeout,
        timeoutMessage: req.timeoutMessage,
        decorateError: req.decorateError,
      ),
    );
    if (!result.isSuccess) return ApiResult.fail(result.message);

    final parsed = extractJsonObject(result.data ?? '');
    if (parsed == null) {
      // ⛔ 把模型实际说了什么带上：这条错误的唯一用途就是让人看出
      // "它根本没在回 JSON"，只说一句"解析失败"等于什么都没说。
      return ApiResult.fail(
        req.decorate(
          '$_noJsonInReplyMessage: ${truncateForMessage(result.data ?? '', max: 200)}',
        ),
      );
    }
    return ApiResult.success(message: '', data: parsed);
  }

  /// 把 schema 摊成一段"只准回 JSON"的约定，接在调用方的提示词后面。
  String _jsonContractPrompt(String system, Schema schema) {
    final buffer = StringBuffer();
    if (system.trim().isNotEmpty) {
      buffer
        ..writeln(system.trim())
        ..writeln();
    }
    buffer
      ..writeln(
        'Reply with ONLY one JSON object conforming to this JSON Schema. '
        'No prose, no explanation, no markdown code fences.',
      )
      ..writeln(jsonEncode(schema.value));
    return buffer.toString();
  }

  // ------------------------------------------------------------------ 流式

  /// 逐字返回。**每次 add 的是累计文本**（不是增量），与改造前一致——
  /// 消费方直接拿去当完整内容渲染。
  ///
  /// 返回 null 表示「这个用途现在没有可用档案」，由调用方决定怎么退。
  ///
  /// [onReasoning] 是推理过程的累计文本回调，仅 Anthropic / Google / Ollama
  /// 原生推理时会触发。
  Stream<String>? stream(
    AiRequest req, {
    void Function(String reasoning)? onReasoning,
  }) {
    final profile = _resolve(req);
    if (profile == null) return null;

    final requestId =
        '${DateTime.now().millisecondsSinceEpoch}-${_requestSeq++}';
    LogUtils.i('创建 AI 流式调用，ID: $requestId', 'AiService');

    final controller = StreamController<String>();
    _activeStreams[requestId] = controller;
    if (onReasoning != null) {
      _reasoningCallbacks[requestId] = onReasoning;
    }

    _armTimeout(
      requestId,
      req.timeout ?? defaultStreamTimeout,
      req.timeoutMessage,
    );
    _startStream(req, profile, requestId);

    controller.onCancel = () {
      LogUtils.i('AI 流式调用被取消，ID: $requestId', 'AiService');
      _cleanup(requestId);
    };

    return controller.stream;
  }

  void _armTimeout(String requestId, Duration timeout, String? message) {
    _timeouts[requestId]?.cancel();
    _timeouts[requestId] = Timer(timeout, () {
      LogUtils.w('AI 流式调用超时，ID: $requestId', 'AiService');
      _cleanup(
        requestId,
        timeoutError:
            '${message ?? 'AI request timed out'} (${timeout.inSeconds}s)',
      );
    });
  }

  void _cleanup(String requestId, {String? timeoutError}) {
    _timeouts.remove(requestId)?.cancel();
    // 中断底层订阅（关闭对话框 / 超时即断流）
    _subscriptions.remove(requestId)?.cancel();
    _reasoningCallbacks.remove(requestId);

    final controller = _activeStreams.remove(requestId);
    if (controller != null && !controller.isClosed) {
      if (timeoutError != null) {
        controller.addError(timeoutError);
      }
      controller.close();
    }
  }

  Future<void> _startStream(
    AiRequest req,
    AiProviderProfile profile,
    String requestId,
  ) async {
    final controller = _activeStreams[requestId];
    if (controller == null) return;

    final reasoningCallback = _reasoningCallbacks[requestId];
    final answer = StringBuffer();
    final reasoning = StringBuffer();
    LanguageModelUsage? lastUsage;

    try {
      final sub = buildAgent(profile)
          .sendStream(req.input, history: _history(req))
          .listen(
            (chunk) {
              if (controller.isClosed) return;
              if (chunk.output.isNotEmpty) {
                answer.write(chunk.output);
                controller.add(answer.toString());
              }
              final thinking = chunk.thinking;
              if (thinking != null && thinking.isNotEmpty) {
                reasoning.write(thinking);
                reasoningCallback?.call(reasoning.toString());
              }
              // 只有最后一个 chunk 带 usage，中途多数是 null——覆盖式赋值会把
              // 已经收到的那份抹掉。
              if (chunk.usage != null) lastUsage = chunk.usage;
            },
            onError: (Object e, StackTrace st) {
              LogUtils.e('AI 流式调用出错', tag: 'AiService', error: e);
              _fallbackToComplete(req, requestId, streamError: e);
            },
            onDone: () {
              _account(req.task, tokens: lastUsage);
              _cleanup(requestId);
            },
            cancelOnError: true,
          );
      _subscriptions[requestId] = sub;
    } catch (e) {
      // 构造 Agent 阶段就失败（缺凭据、地址不合法、开了不支持的 thinking）：
      // 直接降级，别让调用方对着一个永远不出字的流干等。
      LogUtils.e('AI 流式调用启动失败', tag: 'AiService', error: e);
      await _fallbackToComplete(req, requestId, streamError: e);
    }
  }

  /// 流式失败时降级为一次要完。
  ///
  /// [streamError] 是流式阶段的原始异常：降级也失败时一并报出来，否则用户只
  /// 看到降级那次的报错，看不到最先出问题的地方。
  Future<void> _fallbackToComplete(
    AiRequest req,
    String requestId, {
    Object? streamError,
  }) async {
    final controller = _activeStreams[requestId];
    if (controller == null || controller.isClosed) {
      _cleanup(requestId);
      return;
    }
    try {
      final result = await complete(req);
      if (!controller.isClosed) {
        if (result.isSuccess && result.data != null) {
          controller.add(result.data!);
        } else {
          controller.addError(
            _withStreamError(req, result.message, streamError),
          );
        }
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(
          _withStreamError(
            req,
            req.decorate(describeRequestError(e)),
            streamError,
          ),
        );
      }
    } finally {
      _cleanup(requestId);
    }
  }

  /// 把流式阶段的原始异常附在降级失败信息后面。
  ///
  /// ⛔ 两个原因都要报：只报降级那次的话，用户看不到**最先**出问题的地方，
  /// 而那一个往往才是真原因（流式被中转掐掉 → 降级又撞上同一个 401）。
  String _withStreamError(AiRequest req, String message, Object? streamError) {
    if (streamError == null) return message;
    final label = req.streamErrorLabel;
    final detail = describeRequestError(streamError);
    return label == null
        ? '$message\n(stream: $detail)'
        : '$message\n$label: $detail';
  }

  // ------------------------------------------------------------------ 运维

  /// 拿一份**还没保存**的配置去试一次真实往返。
  ///
  /// ⛔ 成功与否走 [AITestResult.connectionValid]，而不是 `ApiResult.isFail`：
  /// "连不上"是测试的一种正常结局，调用方要拿到失败原因去展示，而不是吃一个异常。
  Future<ApiResult<AITestResult>> test(
    AiProviderProfile profile, {
    String probe = 'Hello',
    String system = '',
  }) async {
    try {
      final result = await buildAgent(profile)
          .send(
            probe,
            history: system.trim().isEmpty
                ? const []
                : [ChatMessage.system(system)],
          )
          .timeout(defaultRequestTimeout);
      return ApiResult.success(
        data: AITestResult(
          translatedText: result.output,
          connectionValid: true,
          custMessage: 'OK',
        ),
      );
    } catch (e) {
      LogUtils.e('AI 连接测试失败', tag: 'AiService', error: e);
      return ApiResult.success(
        data: AITestResult(
          custMessage: describeRequestError(e),
          connectionValid: false,
        ),
      );
    }
  }

  /// [listModels] 在"端点没给出任何可用模型"时回的那句话。
  ///
  /// 做成常量是因为调用方要按它换成自己的本地化文案——跨层比对字符串字面量
  /// 是那种改一处忘一处、而且编译器一声不吭的写法。
  static const String emptyModelListMessage = 'empty model list';

  /// 拉服务端的可用模型列表。让用户从列表里选，而不是手打模型名——
  /// 打错一个字的报错是 404，没人看得出那是模型名的问题。
  Future<ApiResult<List<String>>> listModels(AiProviderProfile profile) async {
    try {
      final models = <String>[];
      await for (final m in buildProvider(profile).listModels()) {
        if (m.kinds.contains(ModelKind.chat)) {
          models.add(m.name);
        }
      }
      models.sort();
      if (models.isEmpty) {
        return ApiResult.fail(emptyModelListMessage);
      }
      return ApiResult.success(data: models, message: '');
    } catch (e) {
      LogUtils.e('拉取模型列表失败', tag: 'AiService', error: e);
      return ApiResult.fail(describeRequestError(e), exception: e);
    }
  }

  String _noProfileMessage() => 'No AI provider configured';

  static const String _noJsonInReplyMessage = 'model did not reply with JSON';

  @override
  void onClose() {
    for (final timer in _timeouts.values) {
      timer.cancel();
    }
    _timeouts.clear();

    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _reasoningCallbacks.clear();

    for (final controller in _activeStreams.values) {
      if (!controller.isClosed) controller.close();
    }
    _activeStreams.clear();

    super.onClose();
  }
}
