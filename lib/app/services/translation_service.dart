import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/deeplx_language_mapper.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 翻译服务。
///
/// - AI 翻译经由 [dartantic_ai] 统一接入 OpenAI（含一切 OpenAI 兼容端点）、
///   Anthropic 原生、Google 原生三家，由 SDK 处理各家协议、流式与推理(thinking)。
/// - Google 翻译与 DeepLX 仍走本服务自带的 dio。
///
/// 代理：应用在启动时设置了 `HttpOverrides.global`，进程级覆盖所有 `HttpClient`，
/// dartantic 底层的 package:http 默认客户端会自动走用户配置的代理。
class TranslationService extends GetxService {
  final ConfigService _configService = Get.find();
  final Dio dio = Dio();

  TranslationService() {
    dio.options.persistentConnection = false;
  }

  // 存储当前正在进行的流式翻译
  final Map<String, StreamController<String>> _activeStreamTranslations = {};

  // 用于管理超时的定时器
  final Map<String, Timer> _translationTimeouts = {};

  // 每个流式翻译对应的 dartantic 订阅，用于在流被关闭/超时时立即中断
  final Map<String, StreamSubscription<ChatResult<String>>> _aiSubscriptions =
      {};

  // 推理过程(reasoning)回调，按翻译 ID 暂存
  final Map<String, void Function(String reasoning)> _reasoningCallbacks = {};

  // 流式翻译的最大超时时间（秒）
  static const int _streamTranslationTimeoutSeconds = 120;

  // Google 翻译分段与并发参数
  static const int _googleMaxChunkChars = 4500; // 单段最大字符数，留余量避免请求过大
  static const int _googleMaxConcurrency = 3; // 适量并发数，平衡速度与稳定性

  // 配置相关方法 ---------------------------

  /// 从配置服务获取指定配置项
  T? _getConfig<T>(ConfigKey key) {
    return _configService[key] as T?;
  }

  /// 获取当前翻译语言
  String _getCurrentLanguage(String? targetLanguage) {
    return targetLanguage ?? _configService.currentTranslationLanguage;
  }

  // AI 适配层（dartantic_ai）---------------------------

  /// 把 `[TL]` 占位替换为目标语言，得到最终系统提示词。
  ///
  /// 用标准语言名称（英文名 + 本地自称）替换，而非 `zh-CN` 这种简写，
  /// 避免模型拿不准要翻译成什么语言。
  String _buildPrompt(String? targetLanguage) {
    final code = _getCurrentLanguage(targetLanguage);
    final langName = CommonConstants.translationLanguageName(code);
    return (_getConfig<String>(ConfigKey.AI_TRANSLATION_PROMPT) ?? '')
        .replaceAll(CommonConstants.defaultLanguagePlaceholder, langName);
  }

  /// 依据 providerId + 凭据构造 dartantic Provider。
  /// - openai：覆盖 OpenAI 及一切 OpenAI 兼容端点（DeepSeek、中转、本地等），支持自定义 baseUrl
  /// - anthropic：原生 `/v1/messages`（本版本 SDK 不支持自定义 baseUrl）
  /// - google：原生 Gemini，支持自定义 baseUrl
  Provider _buildProvider(String providerId, String apiKey, String baseUrl) {
    final trimmed = baseUrl.trim();
    final uri = trimmed.isEmpty ? null : Uri.parse(trimmed);
    switch (providerId) {
      case 'anthropic':
        return AnthropicProvider(apiKey: apiKey);
      case 'google':
        return GoogleProvider(apiKey: apiKey, baseUrl: uri);
      default:
        return OpenAIProvider(apiKey: apiKey, baseUrl: uri);
    }
  }

  /// 构造用于翻译的 Agent。
  Agent _buildAgentFrom({
    required String providerId,
    required String apiKey,
    required String baseUrl,
    required String model,
    required bool reasoning,
    required bool sendTemperature,
    required int maxTokens,
    required double temperature,
  }) {
    final provider = _buildProvider(providerId, apiKey, baseUrl);

    // 仅 anthropic / google 支持 dartantic 的 thinking；openai(兼容) 端点开启会抛错
    final supportsThinking = providerId == 'anthropic' || providerId == 'google';
    final enableThinking = reasoning && supportsThinking;

    // 推理模型通常不接受自定义 temperature
    final double? temp = (sendTemperature && !reasoning) ? temperature : null;

    // 各家有各自的 options（maxTokens 字段名不同）；OpenAI 会自动映射到 max_completion_tokens
    final ChatModelOptions options = switch (providerId) {
      'anthropic' => AnthropicChatOptions(maxTokens: maxTokens),
      'google' => GoogleChatModelOptions(maxOutputTokens: maxTokens),
      _ => OpenAIChatOptions(maxTokens: maxTokens),
    };

    return Agent.forProvider(
      provider,
      chatModelName: model.trim().isEmpty ? null : model.trim(),
      temperature: temp,
      enableThinking: enableThinking,
      chatModelOptions: options,
    );
  }

  /// 基于当前配置构造 Agent
  Agent _buildAgent() => _buildAgentFrom(
    providerId: _getConfig<String>(ConfigKey.AI_TRANSLATION_PROVIDER) ?? 'openai',
    apiKey: _getConfig<String>(ConfigKey.AI_TRANSLATION_API_KEY) ?? '',
    baseUrl: _getConfig<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '',
    model: _getConfig<String>(ConfigKey.AI_TRANSLATION_MODEL) ?? '',
    reasoning: _getConfig<bool>(ConfigKey.AI_TRANSLATION_REASONING_MODEL) ?? false,
    sendTemperature:
        _getConfig<bool>(ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE) ?? true,
    maxTokens: _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 4096,
    temperature: _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.3,
  );

  // 翻译核心方法 ---------------------------

  /// 翻译文本，会根据配置选择谷歌翻译、AI翻译或DeepLX翻译
  Future<ApiResult<String>> translate(
    String text, {
    String? targetLanguage,
    CancelToken? cancelToken,
  }) async {
    final useAI = _getConfig<bool>(ConfigKey.USE_AI_TRANSLATION) ?? false;
    final useDeepLX =
        _getConfig<bool>(ConfigKey.USE_DEEPLX_TRANSLATION) ?? false;

    if (useDeepLX) {
      return _translateWithDeepLX(text, targetLanguage: targetLanguage);
    } else if (useAI) {
      return _translateWithAI(text, targetLanguage: targetLanguage);
    } else {
      return _translateWithGoogle(text, targetLanguage);
    }
  }

  /// 使用Google翻译服务（分段 + 适量并发）
  Future<ApiResult<String>> _translateWithGoogle(
    String text,
    String? targetLanguage,
  ) async {
    try {
      if (text.trim().isEmpty) {
        return ApiResult.success(message: '', data: '');
      }

      final chunks = _splitTextForGoogle(
        text,
        maxChunkChars: _googleMaxChunkChars,
      );

      // 单段直接调用
      if (chunks.length == 1) {
        final translated = await _googleTranslateSingle(
          chunks.first,
          targetLanguage,
        );
        return ApiResult.success(message: '', data: translated);
      }

      // 分段并发翻译（按批次控制并发度，保证顺序拼接）
      final buffer = StringBuffer();
      for (int i = 0; i < chunks.length; i += _googleMaxConcurrency) {
        final end = min(i + _googleMaxConcurrency, chunks.length);
        final batch = chunks.sublist(i, end);
        final futures = batch
            .map((seg) => _googleTranslateSingle(seg, targetLanguage))
            .toList();
        final results = await Future.wait(futures);
        for (final r in results) {
          buffer.write(r);
        }
      }

      return ApiResult.success(message: '', data: buffer.toString());
    } catch (e) {
      LogUtils.e(
        slang.t.translation.translationFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  // 将文本切分为适合 Google 翻译的片段，尽量在自然边界处断开
  List<String> _splitTextForGoogle(String text, {int maxChunkChars = 4500}) {
    if (text.length <= maxChunkChars) {
      return [text];
    }

    const boundaries = {
      '\n',
      '\r',
      '。',
      '！',
      '？',
      '；',
      '，',
      '、',
      '.',
      '!',
      '?',
      ';',
      ':',
      ' ',
    };

    final chunks = <String>[];
    int index = 0;

    while (index < text.length) {
      final remaining = text.length - index;
      int take = remaining <= maxChunkChars ? remaining : maxChunkChars;

      String slice = text.substring(index, index + take);
      if (remaining > maxChunkChars) {
        int cut = -1;
        for (int i = slice.length - 1; i >= 0; i--) {
          final ch = slice[i];
          if (boundaries.contains(ch)) {
            cut = i + 1; // 包含边界字符
            break;
          }
        }
        if (cut <= 0) {
          // 找不到自然边界，硬切
          cut = slice.length;
        }
        slice = slice.substring(0, cut);
        take = slice.length;
      }

      chunks.add(slice);
      index += take;
    }

    return chunks;
  }

  // 单段 Google 翻译，带重试与超时
  Future<String> _googleTranslateSingle(
    String text,
    String? targetLanguage,
  ) async {
    const int maxRetries = 2;
    int attempt = 0;

    while (true) {
      try {
        final response = await dio.get(
          "https://translate.googleapis.com/translate_a/t",
          queryParameters: {
            "client": "gtx",
            "sl": "auto",
            "tl": _getCurrentLanguage(targetLanguage),
            "dt": "t",
            "q": text,
          },
          options: Options(receiveTimeout: const Duration(seconds: 20)),
        );

        final res = _parseGoogleResponse(response.data);
        if (res.isEmpty) {
          throw Exception('Empty google translation response');
        }
        return res;
      } catch (e) {
        attempt++;
        if (attempt > maxRetries) {
          rethrow;
        }
        // 线性退避
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
  }

  // 兼容不同返回格式的解析
  String _parseGoogleResponse(dynamic data) {
    try {
      if (data is List && data.isNotEmpty) {
        final first = data[0];

        // 典型结构：[[["译文","原文", ...], ["片段2", ...], ...], ...]
        if (first is List) {
          final buffer = StringBuffer();
          for (final item in first) {
            if (item is List && item.isNotEmpty && item[0] is String) {
              buffer.write(item[0] as String);
            }
          }
          final text = buffer.toString();
          if (text.isNotEmpty) {
            return text;
          }
        }

        // 退化结构：data[0][0] 直接是字符串
        if (data[0] is List &&
            (data[0] as List).isNotEmpty &&
            data[0][0] is String) {
          return data[0][0] as String;
        }
      }
    } catch (_) {
      // ignore
    }
    return '';
  }

  /// 使用AI服务进行翻译（非流式，经 dartantic_ai）
  Future<ApiResult<String>> _translateWithAI(
    String text, {
    String? targetLanguage,
  }) async {
    try {
      LogUtils.i('开始 AI 翻译，文本长度: ${text.length}', 'TranslationService');
      final agent = _buildAgent();
      final result = await agent.send(
        text,
        history: [ChatMessage.system(_buildPrompt(targetLanguage))],
      );
      return ApiResult.success(message: '', data: result.output);
    } catch (e) {
      LogUtils.e(
        slang.t.translation.aiTranslationFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }
  }

  /// 使用DeepLX服务进行翻译
  Future<ApiResult<String>> _translateWithDeepLX(
    String text, {
    String? targetLanguage,
  }) async {
    try {
      if (text.trim().isEmpty) {
        return ApiResult.success(message: '', data: '');
      }

      final baseUrl = _getConfig<String>(ConfigKey.DEEPLX_BASE_URL) ?? '';
      final endpointType =
          _getConfig<String>(ConfigKey.DEEPLX_ENDPOINT_TYPE) ?? 'Free';
      final apiKey = _getConfig<String>(ConfigKey.DEEPLX_API_KEY) ?? '';
      final dlSession = _getConfig<String>(ConfigKey.DEEPLX_DL_SESSION) ?? '';

      if (baseUrl.isEmpty) {
        return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
      }

      // 构建请求URL
      String endpoint;
      switch (endpointType) {
        case 'Pro':
          endpoint = '/v1/translate';
          break;
        case 'Official':
          endpoint = '/v2/translate';
          break;
        default: // Free
          endpoint = '/translate';
          break;
      }

      final url = baseUrl.endsWith('/')
          ? '$baseUrl${endpoint.substring(1)}'
          : '$baseUrl$endpoint';

      // 转换语言代码
      final currentLanguage = _getCurrentLanguage(targetLanguage);
      final targetLangCode = DeepLXLanguageMapper.appToDeepLX(currentLanguage);

      // 构建请求数据
      final requestData = <String, dynamic>{
        'text': text,
        'target_lang': targetLangCode,
      };

      // 添加可选参数
      if (endpointType == 'Pro' && dlSession.isNotEmpty) {
        requestData['dl_session'] = dlSession;
      }

      // 构建请求头
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (endpointType == 'Official' && apiKey.isNotEmpty) {
        headers['Authorization'] = 'DeepL-Auth-Key $apiKey';
      } else if ((endpointType == 'Free' || endpointType == 'Pro') &&
          apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
      }

      return _parseDeepLXResponse(response.data);
    } catch (e) {
      LogUtils.e(
        slang.t.translation.deeplxTranslationFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }
  }

  /// 解析DeepLX响应数据
  ApiResult<String> _parseDeepLXResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }

    // 检查响应状态
    final code = data['code'] as int?;
    if (code != null && code != 200) {
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }

    // 获取翻译结果
    final translatedText = data['data'] as String?;
    if (translatedText == null || translatedText.isEmpty) {
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }

    return ApiResult.success(message: '', data: translatedText);
  }

  // 测试方法 ---------------------------

  /// 测试AI翻译连接（经 dartantic_ai，按当前 provider 配置 + 传入凭据）
  Future<ApiResult<AITestResult>> testAITranslation(
    String baseUrl,
    String model,
    String apiKey, {
    String? targetLanguage,
  }) async {
    try {
      final agent = _buildAgentFrom(
        providerId:
            _getConfig<String>(ConfigKey.AI_TRANSLATION_PROVIDER) ?? 'openai',
        apiKey: apiKey,
        baseUrl: baseUrl,
        model: model,
        reasoning:
            _getConfig<bool>(ConfigKey.AI_TRANSLATION_REASONING_MODEL) ?? false,
        sendTemperature:
            _getConfig<bool>(ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE) ?? true,
        maxTokens: _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 4096,
        temperature:
            _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.3,
      );

      final result = await agent.send(
        "Hello",
        history: [ChatMessage.system(_buildPrompt(targetLanguage))],
      );

      return ApiResult.success(
        data: AITestResult(
          translatedText: result.output,
          connectionValid: true,
          custMessage: slang.t.translation.testSuccess,
        ),
      );
    } catch (e) {
      LogUtils.e(
        slang.t.translation.aiTranslationTestFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.success(
        data: AITestResult(
          custMessage: slang.t.translation.connectionFailedForMessage(
            message: e.toString(),
          ),
          connectionValid: false,
        ),
      );
    }
  }

  /// 测试DeepLX翻译连接
  Future<ApiResult<AITestResult>> testDeepLXTranslation(
    String baseUrl,
    String endpointType,
    String apiKey,
    String dlSession, {
    String? targetLanguage,
  }) async {
    try {
      const testText = "Hello";

      if (baseUrl.isEmpty) {
        return ApiResult.success(
          data: AITestResult(
            custMessage: slang.t.translation.pleaseFillInDeepLXServerAddress,
            connectionValid: false,
          ),
        );
      }

      // 构建请求URL
      String endpoint;
      switch (endpointType) {
        case 'Pro':
          endpoint = '/v1/translate';
          break;
        case 'Official':
          endpoint = '/v2/translate';
          break;
        default: // Free
          endpoint = '/translate';
          break;
      }

      final url = baseUrl.endsWith('/')
          ? '$baseUrl${endpoint.substring(1)}'
          : '$baseUrl$endpoint';

      // 转换语言代码
      final currentLanguage = _getCurrentLanguage(targetLanguage);
      final targetLangCode = DeepLXLanguageMapper.appToDeepLX(currentLanguage);

      // 构建请求数据
      final requestData = <String, dynamic>{
        'text': testText,
        'target_lang': targetLangCode,
      };

      // 添加可选参数
      if (endpointType == 'Pro' && dlSession.isNotEmpty) {
        requestData['dl_session'] = dlSession;
      }

      // 构建请求头
      final headers = <String, String>{'Content-Type': 'application/json'};

      if (endpointType == 'Official' && apiKey.isNotEmpty) {
        headers['Authorization'] = 'DeepL-Auth-Key $apiKey';
      } else if ((endpointType == 'Free' || endpointType == 'Pro') &&
          apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final testDio = Dio()..options.persistentConnection = false;
      final response = await testDio.post(
        url,
        data: requestData,
        options: Options(
          headers: headers,
          validateStatus: (status) => status! < 500,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        return ApiResult.success(
          code: response.statusCode ?? 500,
          data: AITestResult(
            custMessage: 'HTTP ${response.statusCode}',
            connectionValid: false,
          ),
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return ApiResult.success(
          data: AITestResult(
            custMessage: slang.t.translation.invalidAPIResponseFormat,
            connectionValid: false,
          ),
        );
      }

      // 检查DeepLX响应格式
      final code = data['code'] as int?;
      final translatedText = data['data'] as String?;

      if (code != 200 || translatedText == null || translatedText.isEmpty) {
        return ApiResult.success(
          data: AITestResult(
            custMessage: slang.t.translation.translationServiceReturnedError,
            connectionValid: false,
            rawResponse: jsonEncode(data),
          ),
        );
      }

      return ApiResult.success(
        data: AITestResult(
          rawResponse: jsonEncode(data),
          translatedText: translatedText,
          connectionValid: true,
          custMessage: slang.t.translation.testSuccess,
        ),
      );
    } catch (e) {
      LogUtils.e(
        slang.t.translation.deeplxTranslationTestFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.success(
        data: AITestResult(
          custMessage:
              '${slang.t.translation.connectionFailed}: ${e.toString()}',
          connectionValid: false,
        ),
      );
    }
  }

  /// 拉取服务端可用模型列表（经 dartantic provider，对三家均有效）。
  /// 让用户从列表中选择模型，而不是手动猜测模型名。
  Future<ApiResult<List<String>>> fetchAvailableModels(
    String baseUrl,
    String apiKey,
  ) async {
    try {
      final provider = _buildProvider(
        _getConfig<String>(ConfigKey.AI_TRANSLATION_PROVIDER) ?? 'openai',
        apiKey,
        baseUrl,
      );

      final models = <String>[];
      await for (final m in provider.listModels()) {
        if (m.kinds.contains(ModelKind.chat)) {
          models.add(m.name);
        }
      }
      models.sort();

      if (models.isEmpty) {
        return ApiResult.fail(t.translation.invalidAPIResponse);
      }
      return ApiResult.success(data: models, message: '');
    } catch (e) {
      LogUtils.e('fetch models failed', tag: 'TranslationService', error: e);
      return ApiResult.fail(e.toString());
    }
  }

  // 流式翻译相关方法 ---------------------------

  /// 使用流式传输进行翻译，返回一个流
  ///
  /// [onReasoning] 推理模型的思考过程增量回调（累计文本）；仅 Anthropic/Google
  /// 原生推理时会触发（OpenAI 兼容端点的推理不经此回调）。
  /// [cancelToken] 兼容旧调用方而保留；AI 流式通过取消内部订阅来中断。
  Stream<String>? translateStream(
    String text, {
    String? targetLanguage,
    void Function(String reasoning)? onReasoning,
    CancelToken? cancelToken,
  }) {
    final useAI = _getConfig<bool>(ConfigKey.USE_AI_TRANSLATION) ?? false;
    final useDeepLX =
        _getConfig<bool>(ConfigKey.USE_DEEPLX_TRANSLATION) ?? false;

    // 如果使用DeepLX或不使用AI，返回null（DeepLX不支持流式翻译）
    if (useDeepLX || !useAI) {
      return null;
    }

    // 检查用户是否启用了流式翻译
    final streamEnabled =
        _getConfig<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ?? true;
    if (!streamEnabled) {
      return null; // 如果用户禁用了流式翻译，直接返回null
    }

    // 为每个翻译请求创建一个唯一ID
    final translationId = DateTime.now().millisecondsSinceEpoch.toString();
    LogUtils.i('创建流式翻译，ID: $translationId', 'TranslationService');

    final streamController = StreamController<String>();
    _activeStreamTranslations[translationId] = streamController;
    if (onReasoning != null) {
      _reasoningCallbacks[translationId] = onReasoning;
    }

    // 设置超时计时器
    _setupTranslationTimeout(translationId);

    // 启动流式翻译
    _translateWithAIStream(text, translationId, targetLanguage: targetLanguage);

    // 当流被取消时，清理资源（含取消底层订阅）
    streamController.onCancel = () {
      LogUtils.i('流式翻译被取消，ID: $translationId', 'TranslationService');
      _cleanupTranslationResources(translationId);
    };

    return streamController.stream;
  }

  /// 设置翻译超时计时器
  void _setupTranslationTimeout(String translationId) {
    _translationTimeouts[translationId]?.cancel();
    _translationTimeouts[translationId] = Timer(
      Duration(seconds: _streamTranslationTimeoutSeconds),
      () {
        LogUtils.w(
          slang.t.translation.streamingTranslationTimeout,
          'TranslationService',
        );
        _cleanupTranslationResources(translationId, isTimeout: true);
      },
    );
  }

  /// 清理翻译相关资源
  void _cleanupTranslationResources(
    String translationId, {
    bool isTimeout = false,
  }) {
    // 取消超时计时器
    _translationTimeouts[translationId]?.cancel();
    _translationTimeouts.remove(translationId);

    // 中断底层订阅（关闭对话框 / 超时即断流）
    _aiSubscriptions.remove(translationId)?.cancel();
    _reasoningCallbacks.remove(translationId);

    // 关闭并移除流控制器
    final streamController = _activeStreamTranslations[translationId];
    if (streamController != null && !streamController.isClosed) {
      if (isTimeout) {
        streamController.addError(
          slang.t.translation.translationRequestTimeout,
        );
      }
      streamController.close();
    }
    _activeStreamTranslations.remove(translationId);
  }

  /// 使用流式传输进行AI翻译（经 dartantic_ai）
  Future<void> _translateWithAIStream(
    String text,
    String translationId, {
    String? targetLanguage,
  }) async {
    final streamController = _activeStreamTranslations[translationId];
    if (streamController == null) return;

    final reasoningCallback = _reasoningCallbacks[translationId];
    final answer = StringBuffer();
    final reasoning = StringBuffer();

    try {
      final agent = _buildAgent();

      final sub = agent
          .sendStream(
            text,
            history: [ChatMessage.system(_buildPrompt(targetLanguage))],
          )
          .listen(
            (chunk) {
              if (streamController.isClosed) return;
              if (chunk.output.isNotEmpty) {
                answer.write(chunk.output);
                streamController.add(answer.toString());
              }
              final th = chunk.thinking;
              if (th != null && th.isNotEmpty) {
                reasoning.write(th);
                reasoningCallback?.call(reasoning.toString());
              }
            },
            onError: (Object e, StackTrace st) {
              LogUtils.e(
                slang.t.translation.streamingTranslationFailed,
                error: e,
              );
              _fallbackToNonStream(text, translationId, targetLanguage);
            },
            onDone: () {
              // 正常结束：关闭流并清理（cleanup 不会重复关闭）
              _cleanupTranslationResources(translationId);
            },
            cancelOnError: true,
          );
      _aiSubscriptions[translationId] = sub;
    } catch (e) {
      // 构造 Agent 阶段就失败（如缺少凭据）：直接降级
      LogUtils.e(slang.t.translation.streamingTranslationFailed, error: e);
      await _fallbackToNonStream(text, translationId, targetLanguage);
    }
  }

  /// 流式失败时降级为普通翻译
  Future<void> _fallbackToNonStream(
    String text,
    String translationId,
    String? targetLanguage,
  ) async {
    final streamController = _activeStreamTranslations[translationId];
    if (streamController == null || streamController.isClosed) {
      _cleanupTranslationResources(translationId);
      return;
    }
    try {
      final result = await _translateWithAI(text, targetLanguage: targetLanguage);
      if (!streamController.isClosed) {
        if (result.isSuccess && result.data != null) {
          streamController.add(result.data!);
        } else {
          streamController.addError(result.message);
        }
      }
    } catch (e) {
      LogUtils.e(slang.t.translation.fallbackTranslationFailed, error: e);
      if (!streamController.isClosed) {
        streamController.addError(e);
      }
    } finally {
      _cleanupTranslationResources(translationId);
    }
  }

  @override
  void onClose() {
    // 服务销毁时清理所有活动的翻译资源
    for (final timer in _translationTimeouts.values) {
      timer.cancel();
    }
    _translationTimeouts.clear();

    for (final sub in _aiSubscriptions.values) {
      sub.cancel();
    }
    _aiSubscriptions.clear();
    _reasoningCallbacks.clear();

    for (final controller in _activeStreamTranslations.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _activeStreamTranslations.clear();

    super.onClose();
  }
}
