import 'dart:async';
import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/ai_profile_store.dart';
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
export 'package:dartantic_ai/dartantic_ai.dart' show S, Schema, Tool;

/// 模型调一次工具的过程，给界面画「它正在查什么」。
///
/// ⭐ 措辞由**调用方**给（[AiTool.describeCall] / [AiTool.describeResult]）：
/// 本服务只看得见一个工具名和一坨 JSON，说不出「正在试搜 "初音ミク" …找到 2143
/// 条」这种话，而用户要看的恰恰是后者。
class AiToolCall {
  const AiToolCall({required this.name, required this.call, this.result});

  /// 工具名，兜底显示用。
  final String name;

  /// 这一次调用在做什么（一行人话）。
  final String call;

  /// 结果（一行人话）。null ＝ 还在跑。
  final String? result;

  bool get running => result == null;

  AiToolCall done(String result) =>
      AiToolCall(name: name, call: call, result: result);
}

/// 一件给模型用的工具，外加「怎么把它的一次调用说成人话」。
///
/// ⛔ 不要直接往 [AiRequest] 里塞 dartantic 的 `Tool`：那样界面上只剩一个函数名
/// 在转圈，用户看不出它在查什么、查到了什么——而"能看见它在干什么"正是把工具
/// 接进来的理由之一。
class AiTool {
  const AiTool({
    required this.tool,
    required this.describeCall,
    required this.describeResult,
  });

  final Tool tool;

  /// 参数 → 一行人话。
  final String Function(Map<String, dynamic> args) describeCall;

  /// 返回值 → 一行人话。异常时收到的是那个异常。
  final String Function(Object? result) describeResult;
}

/// 结构化调用此刻走到哪一步。
///
/// ⭐ 存在的理由：[AiService.structured] 是"一次要完"的，调用方在它返回之前
/// 手上什么都没有，界面上只剩一个转圈。而这类请求动辄十几二十秒（还可能在
/// 重试、在降级），一个不动的转圈既说不清"是不是卡死了"，也说不清"它到底
/// 有没有听懂我的话"。
enum AiStage {
  /// 已经发出去，还没收到第一个字。
  waiting,

  /// 模型在推理（[AiProgress.reasoning] 有字）。
  reasoning,

  /// 模型在查东西（[AiProgress.toolCalls] 最后一条还在跑）。
  callingTool,

  /// 模型在写答案（[AiProgress.draft] 有字）。
  drafting,

  /// 上一次失败了，正在重来（[AiProgress.notice] 是失败原因）。
  ///
  /// ⛔ 这一档必须存在：本服务内部有**两层**自动重来（流式失败降级成一次要完、
  /// 带工具那次失败改成不带工具再跑一整轮），两层都只写日志。2026-09-21 用户
  /// 报障「出错了也一点反应没有」就是它——端点回了 500，界面上那行字一个标点
  /// 都没变，而后台正在闷头重试，最坏要静默 120+90+120+90 秒才吐出第一句话。
  retrying,

  /// 全文拿到了，正在解析 JSON。
  parsing,
}

/// 一次结构化调用的过程播报。两段文本都是**累计**的（与 [AiService.stream]
/// 一致），拿到就当完整内容渲染即可。
class AiProgress {
  const AiProgress({
    required this.stage,
    this.reasoning = '',
    this.draft = '',
    this.notice = '',
    this.toolCalls = const [],
  });

  final AiStage stage;

  /// 「刚才出了什么事」的技术原因，空串＝一切正常。
  ///
  /// ⭐ 与 [AiStage.retrying] 配套：光说「正在重试」用户判断不了该不该继续等
  /// （端点 500 值得等一下，密钥错了等到天亮也没用）。措辞由本服务给不了，
  /// 这里是**技术原因原文**，界面负责给它配一句人话的标签。
  final String notice;

  /// 这一轮已经发生过的工具调用，按时间先后。最后一条 [AiToolCall.running]
  /// 为真时就是「正在查」。
  final List<AiToolCall> toolCalls;

  /// 推理过程累计文本。只有原生推理模型（Anthropic / Google / Ollama）会有。
  final String reasoning;

  /// 正文累计文本——结构化调用里就是那份正在成形的 JSON。
  ///
  /// ⛔ **别把它当"思考过程"直接摆给用户看**。这里一度有个 `visibleText`
  /// 访问器（有推理就给推理，否则给 draft），界面照单全收的结果是一坨
  /// `{"segment":"video","query":"\"初音ミク\"…` 挂在「正在理解…」底下——既不
  /// 是思考也没人读得下去，而同一份 JSON 解析完本来就会在结果区里逐条摊开。
  /// 它的正确用法是**量**而不是**内容**：拿长度去说「正在写答案 · 已 128 字」。
  final String draft;
}

/// 一次 AI 调用要的全部东西。
///
/// ⛔ 注意这里**没有任何"翻译"的痕迹**：提示词由调用方给。这正是把 AI 从
/// `TranslationService` 里抽出来的意义——服务只管"怎么调"，"调来干嘛"归调用方。
class AiRequest {
  const AiRequest({
    required this.task,
    required this.input,
    this.system = '',
    this.model,
    this.timeout,
    this.timeoutMessage,
    this.decorateError,
    this.streamErrorLabel,
    this.tools = const [],
  });

  /// 模型可以自己调的工具。空表＝纯问答。
  ///
  /// ⚠️ 函数调用要端点真的支持。中转普遍支持它（聊天客户端都靠它），但不是
  /// 保证——所以带工具那次失败时，[AiService.structured] 会**不带工具再跑一次**
  /// 而不是直接报错。
  final List<AiTool> tools;

  /// 用哪个用途绑定的模型。[model] 非空时它只用于记账。
  final AiTask task;

  /// 用户内容。
  final String input;

  /// 系统提示词，空串＝不带。
  final String system;

  /// 指定模型（设置页的「测试」与接入向导走这条：拿**还没保存**的那份配置去试）。
  final AiResolvedModel? model;

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

/// 配置从哪儿来。
///
/// ⭐ 做成一个口子是为了让「存储」这件事只有一处要改，也为了本服务能在没有
/// sqlite 的情况下被测到（`AiService(store: 一份假的)`）。
abstract class AiProfileStore {
  /// 整份配置（供应商 + 模型，**不含密钥**）。
  AiProviderConfig get config;

  /// 某个用途实际该用哪一条（已合并目录、已贴上密钥）。没有可用的返回 null。
  AiResolvedModel? resolveFor(AiTask task);
}

/// 全 App **唯一**的 AI 调用入口。
///
/// # 它管什么
///
/// - 按 [AiResolvedModel] 造 dartantic 的 `Provider` / `Agent`，并在造之前把这条
///   SDK 路子的怪癖夹住（见 [AiProviderKind]）。⛔ 「发不发 temperature / 开不开
///   thinking / maxTokens 填多少」**不在这儿算**——那是 [resolveAiModel] 的活，
///   本服务只负责把算好的值塞进各家名字不同的那个字段；
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
      _injectedStore ?? ConfigProfileStore(_config);

  AiProfileStore get store => _store;

  /// 初始化底层档案存储（自动迁移与密钥解密）。
  Future<void> ready() async {
    if (_store is ConfigProfileStore) {
      await _store.ensureReady();
    }
  }

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
  final Map<String, void Function(List<AiToolCall> calls)> _toolCallbacks = {};

  /// 「这一次没走通，我在重来」的播报口。见 [AiStage.retrying]。
  final Map<String, void Function(String reason)> _noticeCallbacks = {};

  /// ⭐ 合流节拍：**每 [_streamPace] 才往外吐一次**，而不是底层给一个 token
  /// 就吐一次。
  ///
  /// 我们对外吐的是**累计文本**，消费方（[CustomMarkdownBody] /
  /// [MarkdownTranslationController] / 翻译弹窗）拿到就当完整内容重新解析
  /// markdown 并重建。中转一秒能给二三十个 token，于是一段 300 字的译文要把
  /// 越来越长的全文解析上百遍——累计文本让这件事还是 O(n²) 的。2026-09-21
  /// 用户报障「疯狂刷新 UI」就是它。
  ///
  /// 收口在这一层而不是各消费方自己加 Timer：三处消费方各写一份节流迟早漂移，
  /// 而且下一个接流的人照样会踩。120ms ≈ 8 次/秒，肉眼仍是连续出字。
  ///
  /// ⛔ 攒下的那一段**必须在关流之前落地**（见 [_cleanup] 开头），否则最后
  /// 不到一拍的内容会被整段吞掉——译文尾巴少几个字，还不报错。
  static const Duration _streamPace = Duration(milliseconds: 120);

  final Map<String, Timer> _pacers = {};

  /// 各请求的「立刻把攒着的吐出去」闭包，由 [_startStream] 注册（缓冲区是
  /// 它的局部变量）。[_cleanup] 靠它做最后一次落地。
  final Map<String, void Function()> _streamFlushers = {};

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
  /// 这个参数。夹在 [AiResolvedModel.resolvedBaseUri] 里，不在这儿重复判断。
  Provider buildProvider(AiResolvedModel profile) {
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
  ///
  /// ⛔ 「发多少 / 发不发」已经在 [resolveAiModel] 里算完了（用户 delta → 目录 →
  /// Anthropic 的必填兜底），这里只负责**塞进对的那个字段**。别在这儿再判一次，
  /// 两处各判一遍迟早分叉。
  ChatModelOptions _optionsFor(AiResolvedModel profile) {
    final maxTokens = profile.maxTokens;
    return switch (profile.kind) {
      AiProviderKind.anthropic => AnthropicChatOptions(maxTokens: maxTokens),
      AiProviderKind.google => GoogleChatModelOptions(
        maxOutputTokens: maxTokens,
      ),
      AiProviderKind.ollama => OllamaChatOptions(numPredict: maxTokens),
      AiProviderKind.mistral => MistralChatModelOptions(maxTokens: maxTokens),
      // xAI 走的是 OpenAI 那套 options（XAIProvider extends OpenAIProvider）
      _ => OpenAIChatOptions(maxTokens: maxTokens),
    };
  }

  Agent buildAgent(AiResolvedModel profile, {List<Tool>? tools}) =>
      Agent.forProvider(
        buildProvider(profile),
        chatModelName: profile.modelId.trim().isEmpty
            ? null
            : profile.modelId.trim(),
        temperature: profile.temperature,
        enableThinking: profile.reasoning,
        chatModelOptions: _optionsFor(profile),
        // ⛔ 空表也要给 null：有的端点收到空 `tools` 数组会 400。
        tools: (tools == null || tools.isEmpty) ? null : tools,
      );

  /// 把一件 [AiTool] 包成 dartantic 的 `Tool`，顺手把「开始调 / 调完了」播出去。
  ///
  /// ⭐ 播报做在**包装层**而不是工具自己身上：工具是调用方写的，让每个工具各自
  /// 记得上报，迟早有一个忘了（而忘了的症状就是界面上凭空卡住十几秒）。
  ///
  /// ⛔ 工具抛异常时也要落地成一条「失败了」，并且**把异常还给模型**而不是吞掉：
  /// 模型看到"这个标签查不到"才会改口，吞掉它只会让模型以为自己成功了。
  Tool _wrapTool(
    AiTool spec,
    List<AiToolCall> calls,
    void Function(List<AiToolCall> calls)? report,
  ) {
    return Tool<Map<String, dynamic>>(
      name: spec.tool.name,
      description: spec.tool.description,
      inputSchema: spec.tool.inputSchema,
      onCall: (args) async {
        final index = calls.length;
        calls.add(
          AiToolCall(name: spec.tool.name, call: spec.describeCall(args)),
        );
        report?.call(List.unmodifiable(calls));
        try {
          final result = await spec.tool.call(args);
          calls[index] = calls[index].done(spec.describeResult(result));
          report?.call(List.unmodifiable(calls));
          return result;
        } catch (e) {
          calls[index] = calls[index].done(spec.describeResult(e));
          report?.call(List.unmodifiable(calls));
          rethrow;
        }
      },
    );
  }

  // ------------------------------------------------------------------ 查询

  /// 这个用途实际会用哪一条（已合并目录、已贴密钥）。
  AiResolvedModel? modelFor(AiTask task) => _store.resolveFor(task);

  /// 整份配置（供应商 + 模型，不含密钥）。设置页读它。
  AiProviderConfig get config => _store.config;

  /// 这个用途现在能不能用（有可用的模型且密钥齐）。
  bool isAvailable(AiTask task) => modelFor(task)?.isUsable ?? false;

  AiResolvedModel? _resolve(AiRequest req) => req.model ?? modelFor(req.task);

  List<ChatMessage> _history(AiRequest req) =>
      req.system.trim().isEmpty ? const [] : [ChatMessage.system(req.system)];

  // -------------------------------------------------------------- 一次要完

  Future<ApiResult<String>> complete(AiRequest req) async {
    await ready();
    final profile = _resolve(req);
    if (profile == null) {
      return ApiResult.fail(req.decorate(_noProfileMessage()));
    }
    try {
      // 非流式这条路拿不到播报口（[complete] 不收 onProgress），工具照跑，
      // 只是界面上看不到它在查什么。
      final tools = [
        for (final spec in req.tools) _wrapTool(spec, <AiToolCall>[], null),
      ];
      final result = await buildAgent(profile, tools: tools)
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
  /// [onProgress] 是过程播报，给界面拿去画"思考中"那一块。⚠️ 它按
  /// [_streamPace]（120ms）的节拍来，**只有文本契约那条路有字**：原生结构化
  /// 输出是一次要完的，拿不到流，那条路只报得出阶段。
  Future<ApiResult<Map<String, dynamic>>> structured(
    AiRequest req, {
    required Schema schema,
    void Function(AiProgress progress)? onProgress,
  }) async {
    await ready();
    final profile = _resolve(req);
    if (profile == null) {
      return ApiResult.fail(req.decorate(_noProfileMessage()));
    }

    onProgress?.call(const AiProgress(stage: AiStage.waiting));

    if (profile.structuredOutput) {
      try {
        // ⛔ 这条路**不能直接带 [AiRequest.tools]**：Anthropic / Google 的原生
        // 结构化输出本身就是靠工具调用编排的，再塞一组自己的工具进去，两套
        // 编排会抢同一个出口。所以带工具时拆成两趟——先让它查，再让它填表。
        // 见 [_researchPass]。
        final input = req.tools.isEmpty
            ? req.input
            : await _researchPass(req, profile, onProgress);
        final result = await buildAgent(profile)
            .sendFor<Map<String, dynamic>>(
              input,
              outputSchema: schema,
              history: _history(req),
            )
            .timeout(req.timeout ?? defaultRequestTimeout);
        _account(req.task, tokens: result.usage);
        onProgress?.call(const AiProgress(stage: AiStage.parsing));
        return ApiResult.success(message: '', data: result.output);
      } catch (e) {
        // 不直接报错：端点很可能只是不认 json_schema，文本契约那条路还能走通。
        final reason = describeRequestError(e);
        LogUtils.w('原生结构化输出失败，退回提示词契约：$reason', 'AiService');
        onProgress?.call(AiProgress(stage: AiStage.retrying, notice: reason));
      }
    }

    return _structuredViaTextContract(req, schema, onProgress);
  }

  /// 查证那一趟：先带工具跑一轮**纯文本**，把模型查到的东西攒成一段，交给
  /// 结构化那一轮当上下文。
  ///
  /// ⭐ 为什么要拆两趟：原生结构化输出（`sendFor`）没法同时带自己的工具（两套
  /// 编排抢同一个出口），而工具恰恰是这类功能最值钱的部分——AI 搜索靠
  /// `preview_search` 去真端点验一遍「这么搜到底有没有结果」。不拆的话，端点
  /// 越正规（Anthropic / OpenAI 官方，[AiResolvedModel.structuredOutput] 为真）
  /// 功能反而越弱，走文本契约的中转用户倒有工具可用——能力是倒挂的。
  ///
  /// ⛔ 这一趟**失败不阻断**：查不成就当没查过，照原样去填表。它是增强，不是
  /// 前置条件，不该让整个功能陪着一起失败。
  ///
  /// ⚠️ 代价是系统提示词发两遍。`structuredOutput` 为真的恰恰是官方端点，那
  /// 几家都有 prompt caching，第二遍基本只付缓存价。
  Future<String> _researchPass(
    AiRequest req,
    AiResolvedModel profile,
    void Function(AiProgress progress)? onProgress,
  ) async {
    final researchReq = AiRequest(
      task: req.task,
      input: req.input,
      system: '${req.system}\n\n$_researchPassInstruction',
      model: req.model,
      timeout: req.timeout,
      timeoutMessage: req.timeoutMessage,
      decorateError: req.decorateError,
      tools: req.tools,
    );
    // 与文本契约那条一样：要播报、档案又开着流式就逐字跑，否则一次要完。
    final result = (onProgress != null && profile.streaming)
        ? await _completeStreaming(researchReq, onProgress)
        : await complete(researchReq);

    final findings = (result.data ?? '').trim();
    if (!result.isSuccess || findings.isEmpty) {
      LogUtils.w('查证那一趟没走通，直接去填表：${result.message}', 'AiService');
      return req.input;
    }

    // ⛔ 播一声「查完了，回去填表」：流式那条最后停在 drafting（写的是查证
    // 结论那几句散文），不播的话界面会一直显示「正在写答案」，而接下来
    // `sendFor` 那一整轮是完全静默的。
    //
    // 这里带的 toolCalls 是空表，靠界面「只在非空时覆盖」那条规则保住已经
    // 画出来的调用记录（见 ai_search_sheet 的 _toolCalls）。
    onProgress?.call(const AiProgress(stage: AiStage.waiting));
    return '${req.input}\n\n$_researchPassPreamble\n$findings';
  }

  /// 查证那一趟附加在提示词末尾的指令。
  ///
  /// ⛔ 必须明说「这一趟别回 JSON」：系统提示词里摆着整张表的规则，不拦的话
  /// 模型在这一趟就把表填了，而这一趟的产物只是**下一趟的上下文**——一份半成品
  /// JSON 混进去，只会让它在下一趟照抄而不是重新想。
  static const String _researchPassInstruction =
      'FIRST PASS — investigate only. Use the tools available to you to check '
      'your intended answer against reality, then write a few plain sentences '
      'saying what you verified and what you intend to answer. Do NOT output '
      'JSON in this pass — you will be asked for the structured answer next.';

  /// 把上一趟的结论接回用户原话时的引子。
  static const String _researchPassPreamble =
      'You already investigated this and found:';

  /// 文本契约：把 schema 写进提示词，再从自由文本里把 JSON 抠出来。
  Future<ApiResult<Map<String, dynamic>>> _structuredViaTextContract(
    AiRequest req,
    Schema schema,
    void Function(AiProgress progress)? onProgress,
  ) async {
    final contract = _jsonContractPrompt(req.system, schema);
    final profile = _resolve(req);

    Future<ApiResult<String>> run(List<AiTool> tools) {
      final contractReq = AiRequest(
        task: req.task,
        input: req.input,
        system: contract,
        model: req.model,
        timeout: req.timeout,
        timeoutMessage: req.timeoutMessage,
        decorateError: req.decorateError,
        tools: tools,
      );
      // 要播报过程、档案又开着流式，就逐字跑——用户能看见它在写什么，而不是
      // 对着一个不动的转圈猜是不是卡死了。其余情况老样子一次要完。
      return (onProgress != null && (profile?.streaming ?? false))
          ? _completeStreaming(contractReq, onProgress)
          : complete(contractReq);
    }

    var result = await run(req.tools);
    // ⛔ 端点不认函数调用时，带工具那次是直接失败的（400 / 干脆不回）。这时候
    // 不带工具再跑一次——工具是锦上添花，不该让整个功能在这类端点上没法用。
    if (!result.isSuccess && req.tools.isNotEmpty) {
      LogUtils.w('带工具那次失败，改成不带工具重试：${result.message}', 'AiService');
      // ⛔ 这是第二层静默重来：又是一整轮（流式 120s + 降级 90s）。不播的话，
      // 用户对着同一行字已经等了三分多钟，什么都不知道。
      onProgress?.call(
        AiProgress(stage: AiStage.retrying, notice: result.message),
      );
      result = await run(const []);
    }
    if (!result.isSuccess) return ApiResult.fail(result.message);
    onProgress?.call(
      AiProgress(stage: AiStage.parsing, draft: result.data ?? ''),
    );

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

  /// 逐字跑一次纯文本调用，边跑边播报，最后把**全文**还回来。
  ///
  /// ⭐ 走 [stream] 而不是自己订阅一遍：合流节流、超时闸门、流失败自动降级成
  /// [complete]（见 [_fallbackToComplete]）全在那一层，另起一份迟早漂。对调用
  /// 方来说这条路与 [complete] 的**结果完全一样**，只是中途多了字。
  ///
  /// ⛔ 流里抛出来的多数是 `String`（[_withStreamError] / 超时那两条加的就是
  /// 字符串），不是 Exception——照 `describeRequestError` 走会把一句已经措辞
  /// 好的话再包一层。
  Future<ApiResult<String>> _completeStreaming(
    AiRequest req,
    void Function(AiProgress progress) onProgress,
  ) async {
    var draft = '';
    var reasoning = '';
    var notice = '';
    var calls = const <AiToolCall>[];

    void emit(AiStage stage) => onProgress(
      AiProgress(
        stage: stage,
        reasoning: reasoning,
        draft: draft,
        notice: notice,
        toolCalls: calls,
      ),
    );

    final source = stream(
      req,
      onReasoning: (text) {
        reasoning = text;
        emit(AiStage.reasoning);
      },
      onNotice: (reason) {
        notice = reason;
        // ⛔ 顺手把攒了一半的草稿扔掉：降级那次是**重新生成**，留着上一轮的
        // 半截 JSON 在界面上，看起来像是还在接着写。
        draft = '';
        emit(AiStage.retrying);
      },
      onToolCalls: (list) {
        calls = list;
        // 最后一条还在跑＝正在查；查完了就是又回去想了，还没开始写答案。
        emit(
          list.isNotEmpty && list.last.running
              ? AiStage.callingTool
              : AiStage.waiting,
        );
      },
    );
    if (source == null) {
      return ApiResult.fail(req.decorate(_noProfileMessage()));
    }

    try {
      await for (final text in source) {
        draft = text;
        emit(AiStage.drafting);
      }
    } catch (e) {
      return ApiResult.fail(
        e is String ? e : req.decorate(describeRequestError(e)),
        exception: e is Exception ? e : null,
      );
    }
    return ApiResult.success(message: '', data: draft);
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
  ///
  /// [onNotice] 是「这一次没走通，我在重来」的播报（[_fallbackToComplete]）。
  /// ⛔ 不给它的话，降级那段就是**完全静默**的：流早就 500 了，调用方手上的
  /// 流却既不出字也不结束，最长能这样干等 90 秒。
  Stream<String>? stream(
    AiRequest req, {
    void Function(String reasoning)? onReasoning,
    void Function(List<AiToolCall> calls)? onToolCalls,
    void Function(String reason)? onNotice,
  }) {
    // 触发底层存储初始化，但不改变 stream 同步返回 Stream<String>? 的签名
    unawaited(ready());
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
    if (onToolCalls != null) {
      _toolCallbacks[requestId] = onToolCalls;
    }
    if (onNotice != null) {
      _noticeCallbacks[requestId] = onNotice;
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
    // ⛔ 先把攒着的那一段吐出去，再拆东西：此刻 controller 还开着、
    // reasoning 回调还在表里，晚一步就都没了（尾巴静默丢失）。
    _pacers.remove(requestId)?.cancel();
    _streamFlushers.remove(requestId)?.call();

    _timeouts.remove(requestId)?.cancel();
    // 中断底层订阅（关闭对话框 / 超时即断流）
    _subscriptions.remove(requestId)?.cancel();
    _reasoningCallbacks.remove(requestId);
    _toolCallbacks.remove(requestId);
    _noticeCallbacks.remove(requestId);

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
    AiResolvedModel profile,
    String requestId,
  ) async {
    // 确保发出真实流式请求前密钥已完成解密加载
    await ready();
    final controller = _activeStreams[requestId];
    if (controller == null) return;

    // 若调用方未显式指定模型，以 ready 解密完成后的最新那条为准
    final effectiveProfile = req.model ?? modelFor(req.task) ?? profile;

    final reasoningCallback = _reasoningCallbacks[requestId];
    // ⛔ 工具的调用记录挂在这一次请求上：流式失败降级重跑时是新的一轮，
    // 不该把上一轮查过的东西继续摆在界面上。
    final toolCalls = <AiToolCall>[];
    final tools = [
      for (final spec in req.tools)
        _wrapTool(spec, toolCalls, _toolCallbacks[requestId]),
    ];
    final answer = StringBuffer();
    final reasoning = StringBuffer();
    LanguageModelUsage? lastUsage;

    // 合流：chunk 只往缓冲区写并置脏，真正往外吐由节拍器 / [_cleanup] 负责。
    // 这样 `answer.toString()`（O(n) 的拷贝）也从「每 token 一次」降到
    // 「每一拍一次」。
    var answerDirty = false;
    var reasoningDirty = false;
    void flush() {
      if (answerDirty) {
        answerDirty = false;
        if (!controller.isClosed) controller.add(answer.toString());
      }
      if (reasoningDirty) {
        reasoningDirty = false;
        reasoningCallback?.call(reasoning.toString());
      }
    }

    _streamFlushers[requestId] = flush;
    _pacers[requestId] = Timer.periodic(_streamPace, (_) => flush());

    try {
      final sub = buildAgent(effectiveProfile, tools: tools)
          .sendStream(req.input, history: _history(req))
          .listen(
            (chunk) {
              if (controller.isClosed) return;
              if (chunk.output.isNotEmpty) {
                answer.write(chunk.output);
                answerDirty = true;
              }
              final thinking = chunk.thinking;
              if (thinking != null && thinking.isNotEmpty) {
                reasoning.write(thinking);
                reasoningDirty = true;
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
    // ⛔ 把攒着的半截流**丢掉**（cancel 但不 flush）：降级这条路马上会吐一份
    // 完整答案，而 [_cleanup] 的收尾 flush 排在它后面——不丢的话，用户看到的
    // 是完整答案被那半截流覆盖回去。
    _pacers.remove(requestId)?.cancel();
    _streamFlushers.remove(requestId);

    final controller = _activeStreams[requestId];
    if (controller == null || controller.isClosed) {
      _cleanup(requestId);
      return;
    }
    // ⛔ 先把「刚才炸了，我在重来」播出去再去 await：降级这一次最长要 90 秒，
    // 期间流既不出字也不结束，不播的话界面就是一动不动的转圈（用户会以为卡死
    // 了，而实际上是端点回了 500）。
    if (streamError != null) {
      _noticeCallbacks[requestId]?.call(describeRequestError(streamError));
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
    AiResolvedModel profile, {
    String probe = 'Hello',
    String system = '',
  }) async {
    await ready();
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
  Future<ApiResult<List<String>>> listModels(AiResolvedModel profile) async {
    await ready();
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
    // 整只服务要没了，攒着的那点字没人接——直接扔，不做收尾 flush。
    for (final pacer in _pacers.values) {
      pacer.cancel();
    }
    _pacers.clear();
    _streamFlushers.clear();

    for (final timer in _timeouts.values) {
      timer.cancel();
    }
    _timeouts.clear();

    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _reasoningCallbacks.clear();
    _toolCallbacks.clear();

    for (final controller in _activeStreams.values) {
      if (!controller.isClosed) controller.close();
    }
    _activeStreams.clear();

    super.onClose();
  }
}
