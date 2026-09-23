import 'dart:convert';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:http/http.dart' as http;

/// OpenAI 兼容端点，外加把 `reasoning_content` 接出来。
///
/// # ⛔ 为什么非要自己包一层
///
/// DeepSeek / Qwen / GLM / Kimi 这些推理模型经 OpenAI 兼容接口回的思考过程在
/// `delta.reasoning_content`（OpenRouter 叫 `delta.reasoning`）。底下的
/// openai_dart 7 已经把它解析出来了，但 dartantic 3.4.2 的流式映射
/// （`messageFromOpenAIStreamDelta`）**只取 `delta.content`**，思考过程在这一层
/// 被整个丢掉；它的 `OpenAIProvider` 更是一开 `enableThinking` 就直接抛
/// `UnsupportedError`。而中转用户恰恰全走这一条——于是「AI 搜索只显示工具调用、
/// 看不到思考」对绝大多数人是必然的，与模型会不会想无关。
///
/// # 做法：在 HTTP 这一层旁听，不改 SDK
///
/// [OpenAIChatModel] 收一个 `http.Client`。这里塞一个旁听的 client：SSE 字节
/// **原样**往下传（SDK 的行为一个字节都不变），同时自己按行扫一遍，把思考增量
/// 经 [onThinking] 报出去。比起照抄一份 200 行的 ChatModel，这样跟 SDK 升级
/// 零耦合。
///
/// # ⚠️ 顺带：多轮工具调用时把思考原样送回去
///
/// DeepSeek 推理模式要求：同一轮里模型调了工具，下一次请求里那条 assistant 消息
/// 要带回它的 `reasoning_content`，否则可能直接 400。dartantic 不带（它根本
/// 没存）。于是这里按 tool_call id 记住「是哪次思考发出的这次调用」，下一次
/// 请求发出去之前补回那条消息上。只在端点**自己回过** `reasoning_content` 时
/// 才补，没回过的端点请求体一个字不动。
class ReasoningOpenAIProvider extends OpenAIProvider {
  ReasoningOpenAIProvider({
    super.apiKey,
    super.baseUrl,
    super.headers,
    required this.onThinking,
    http.Client Function()? httpClient,
  }) : _httpClient = httpClient ?? http.Client.new;

  /// 底下真正发请求的 client。只有测试会换（换成假端点）。
  final http.Client Function() _httpClient;

  /// 思考过程的**增量**。按网络 chunk 的频率来，⛔ 回调里不许做重活、不许打日志。
  final void Function(String delta) onThinking;

  @override
  ChatModel<OpenAIChatOptions> createChatModel({
    String? name,
    List<Tool>? tools,
    double? temperature,
    bool enableThinking = false,
    OpenAIChatOptions? options,
  }) {
    // ⛔ 不像父类那样对 enableThinking 抛异常：兼容接口上的推理模型是「天生就
    // 想」，没有一个开关参数可发。这里能做的只是**把它想的东西接出来**，这件事
    // 无论开关与否都做，对不推理的模型也没有代价。
    validateApiKeyPresence();
    return OpenAIChatModel(
      name: name ?? defaultModelNames[ModelKind.chat]!,
      tools: tools,
      temperature: temperature,
      apiKey: apiKey,
      baseUrl: baseUrl,
      headers: headers,
      client: _ReasoningTapClient(_httpClient(), onThinking),
      defaultOptions: OpenAIChatOptions(
        temperature: temperature ?? options?.temperature,
        topP: options?.topP,
        n: options?.n,
        maxTokens: options?.maxTokens,
        presencePenalty: options?.presencePenalty,
        frequencyPenalty: options?.frequencyPenalty,
        logitBias: options?.logitBias,
        stop: options?.stop,
        user: options?.user,
        responseFormat: options?.responseFormat,
        seed: options?.seed,
        parallelToolCalls: options?.parallelToolCalls,
        streamOptions:
            options?.streamOptions ?? const StreamOptions(includeUsage: true),
        serviceTier: options?.serviceTier,
      ),
    );
  }
}

class _ReasoningTapClient extends http.BaseClient {
  _ReasoningTapClient(this._inner, this._onThinking);

  final http.Client _inner;
  final void Function(String delta) _onThinking;

  /// tool_call id → 发出这次调用的那段思考全文，以及它来时的字段名（见类注释
  /// 「送回去」那节）。
  ///
  /// ⛔ 字段名要原样记着：OpenRouter / Groq 用的是 `reasoning`，给它们回一个
  /// `reasoning_content` 可能被严格校验的端点当未知字段 400 掉，而那会被上层当成
  /// 「端点不支持工具」、整个试搜功能静默消失。
  final Map<String, ({String key, String text})> _reasoningByToolCall = {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(_withEchoedReasoning(request));
    final type = response.headers['content-type'] ?? '';
    if (!type.contains('event-stream')) return response;
    return http.StreamedResponse(
      _tap(response.stream),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// 字节原样往下传，旁边按行扫。
  Stream<List<int>> _tap(Stream<List<int>> source) async* {
    final pending = <int>[];
    final reasoning = StringBuffer();
    final toolCallIds = <String>[];
    final reasoningKey = <String>[];

    await for (final chunk in source) {
      var start = 0;
      for (var i = 0; i < chunk.length; i++) {
        if (chunk[i] != 0x0A) continue;
        pending.addAll(chunk.sublist(start, i));
        _scanLine(
          utf8.decode(pending, allowMalformed: true),
          reasoning,
          toolCallIds,
          reasoningKey,
        );
        pending.clear();
        start = i + 1;
      }
      if (start < chunk.length) pending.addAll(chunk.sublist(start));
      yield chunk;
    }
  }

  /// [key] 是个至多一项的表：这次回复的思考走的是哪个字段名（见
  /// [_reasoningByToolCall]）。
  void _scanLine(
    String line,
    StringBuffer reasoning,
    List<String> ids,
    List<String> key,
  ) {
    if (!line.startsWith('data:')) return;
    final payload = line.substring(5).trim();
    // ⭐ 先按子串筛：绝大多数 chunk 只是一两个正文字，没必要每个都 jsonDecode。
    final hasReasoning = payload.contains('"reasoning');
    final hasToolCall = payload.contains('"tool_calls"');
    if (!hasReasoning && !hasToolCall) return;

    Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (_) {
      return;
    }
    if (decoded is! Map) return;
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return;
    final choice = choices.first;
    if (choice is! Map) return;
    final delta = choice['delta'];
    if (delta is! Map) return;

    for (final field in const ['reasoning_content', 'reasoning']) {
      final thought = delta[field];
      if (thought is! String || thought.isEmpty) continue;
      if (key.isEmpty) key.add(field);
      reasoning.write(thought);
      _onThinking(thought);
      break;
    }

    final calls = delta['tool_calls'];
    if (calls is List) {
      for (final call in calls) {
        if (call is Map && call['id'] is String && call['id'] != '') {
          ids.add(call['id'] as String);
        }
      }
    }

    // ⛔ 边扫边记，不等流结束再记：SDK 读到 `[DONE]` 就取消订阅，写在
    // `await for` 后面的收尾代码根本不会跑（测试里实锤过）。
    if (ids.isNotEmpty && reasoning.isNotEmpty && key.isNotEmpty) {
      final entry = (key: key.first, text: reasoning.toString());
      for (final id in ids) {
        _reasoningByToolCall[id] = entry;
      }
    }
  }

  http.BaseRequest _withEchoedReasoning(http.BaseRequest request) {
    if (_reasoningByToolCall.isEmpty || request is! http.Request) {
      return request;
    }
    Object? body;
    try {
      body = jsonDecode(request.body);
    } catch (_) {
      return request;
    }
    if (body is! Map || body['messages'] is! List) return request;

    var changed = false;
    for (final message in body['messages'] as List) {
      if (message is! Map ||
          message['role'] != 'assistant' ||
          message['reasoning_content'] != null ||
          message['reasoning'] != null ||
          message['tool_calls'] is! List) {
        continue;
      }
      for (final call in message['tool_calls'] as List) {
        final entry = call is Map ? _reasoningByToolCall[call['id']] : null;
        if (entry == null) continue;
        message[entry.key] = entry.text;
        changed = true;
        break;
      }
    }
    if (!changed) return request;

    return http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection
      ..body = jsonEncode(body);
  }

  @override
  void close() => _inner.close();
}
