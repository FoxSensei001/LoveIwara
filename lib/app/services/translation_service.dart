import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'dart:convert';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'dart:async';
import 'dart:math';
import 'package:i_iwara/app/services/deeplx_language_mapper.dart';

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

  // URL处理方法 ---------------------------

  /// 根据基础URL获取最终的请求URL
  /// [baseUrl] 基础URL
  /// [keepHash] 是否保留URL末尾的#符号（用于展示）
  /// [forDisplay] 是否用于UI展示（如果为true且baseUrl为空，则返回"未配置"）
  String getFinalUrl(
    String baseUrl, {
    bool keepHash = false,
    bool forDisplay = false,
  }) {
    if (baseUrl.isEmpty && forDisplay) {
      return t.translation.notConfigured;
    }

    // 处理baseUrl，如果以 / 结尾且不以 # 结尾，则去掉末尾的 /
    if (baseUrl.endsWith('/') && !baseUrl.endsWith('#')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // 如果baseUrl以#结尾
    if (baseUrl.endsWith('#')) {
      return keepHash ? baseUrl : baseUrl.substring(0, baseUrl.length - 1);
    }

    // 否则添加/chat/completions
    return "$baseUrl/chat/completions";
  }

  // 翻译核心方法 ---------------------------

  /// 翻译文本，会根据配置选择谷歌翻译、AI翻译或DeepLX翻译
  Future<ApiResult<String>> translate(
    String text, {
    String? targetLanguage,
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

  /// 使用AI服务进行翻译
  Future<ApiResult<String>> _translateWithAI(
    String text, {
    String? targetLanguage,
  }) async {
    try {
      LogUtils.i('开始 AI 翻译，文本长度: ${text.length}', 'TranslationService');

      final stream =
          _getConfig<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ??
          false;
      LogUtils.d('流式翻译配置: $stream', 'TranslationService');

      final requestData = _buildAIRequestData(
        text,
        targetLanguage: targetLanguage,
        stream: stream,
      );
      final url = getFinalUrl(
        _getConfig<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '',
      );

      LogUtils.d('请求 URL: $url', 'TranslationService');
      LogUtils.d('请求数据: $requestData', 'TranslationService');

      final response = await dio.post(
        url,
        data: requestData,
        options: Options(headers: _getAuthHeaders()),
      );

      LogUtils.i('AI 翻译响应状态码: ${response.statusCode}', 'TranslationService');

      if (response.statusCode != 200) {
        LogUtils.e(
          'AI 翻译失败，状态码: ${response.statusCode}',
          tag: 'TranslationService',
        );
        return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
      }

      final result = _parseAIResponse(response.data);
      LogUtils.i(
        'AI 翻译解析结果: ${result.isSuccess ? "成功" : "失败"}',
        'TranslationService',
      );
      return result;
    } catch (e) {
      LogUtils.e(
        slang.t.translation.aiTranslationFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }
  }

  /// 构建AI请求的数据部分
  Map<String, dynamic> _buildAIRequestData(
    String text, {
    String? targetLanguage,
    bool stream = false,
  }) {
    final currentLanguage = _getCurrentLanguage(targetLanguage);
    final prompt =
        _getConfig<String>(ConfigKey.AI_TRANSLATION_PROMPT)?.replaceAll(
          CommonConstants.defaultLanguagePlaceholder,
          currentLanguage,
        ) ??
        '';

    final result = {
      "model": _getConfig<String>(ConfigKey.AI_TRANSLATION_MODEL) ?? '',
      "messages": [
        {"role": "system", "content": prompt},
        {"role": "user", "content": text},
      ],
      "temperature":
          _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.7,
      "max_tokens":
          _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 1000,
    };

    if (stream) {
      result["stream"] = true;
    }

    return result;
  }

  /// 获取认证请求头
  Map<String, String> _getAuthHeaders() {
    return {
      'Authorization':
          'Bearer ${_getConfig<String>(ConfigKey.AI_TRANSLATION_API_KEY) ?? ''}',
      'Content-Type': 'application/json',
    };
  }

  /// 解析AI响应数据
  ApiResult<String> _parseAIResponse(dynamic data) {
    if (data is! Map<String, dynamic> ||
        data['choices'] == null ||
        (data['choices'] as List).isEmpty ||
        data['choices'][0]['message'] == null) {
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }

    final content = data['choices'][0]['message']['content'] as String? ?? '';
    return ApiResult.success(message: '', data: content);
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

  /// 测试AI翻译连接
  Future<ApiResult<AITestResult>> testAITranslation(
    String baseUrl,
    String model,
    String apiKey, {
    String? targetLanguage,
  }) async {
    try {
      const testText = "Hello";

      final currentLanguage = _getCurrentLanguage(targetLanguage);
      final prompt =
          _getConfig<String>(ConfigKey.AI_TRANSLATION_PROMPT)?.replaceAll(
            CommonConstants.defaultLanguagePlaceholder,
            currentLanguage,
          ) ??
          '';

      final messages = [
        {"role": "system", "content": prompt},
        {"role": "user", "content": testText},
      ];

      final testDio = Dio()..options.persistentConnection = false;
      final url = getFinalUrl(baseUrl);
      final response = await testDio.post(
        url,
        data: {
          "model": model,
          "messages": messages,
          "temperature":
              _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.7,
          "max_tokens":
              _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 1000,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
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
      if (data is! Map<String, dynamic> ||
          data['choices'] == null ||
          (data['choices'] as List).isEmpty ||
          data['choices'][0]['message'] == null) {
        return ApiResult.success(
          data: AITestResult(
            custMessage: slang.t.translation.invalidAPIResponse,
            connectionValid: false,
          ),
        );
      }

      final content = data['choices'][0]['message']['content'] as String? ?? '';

      return ApiResult.success(
        data: AITestResult(
          rawResponse: jsonEncode(data),
          translatedText: content,
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

  /// 重置HTTP代理
  void resetProxy() {
    dio.httpClientAdapter = IOHttpClientAdapter();
  }

  // 流式翻译相关方法 ---------------------------

  /// 使用流式传输进行翻译，返回一个流
  Stream<String>? translateStream(String text, {String? targetLanguage}) {
    LogUtils.i(
      'translateStream 被调用，文本长度: ${text.length}',
      'TranslationService',
    );

    final useAI = _getConfig<bool>(ConfigKey.USE_AI_TRANSLATION) ?? false;
    final useDeepLX =
        _getConfig<bool>(ConfigKey.USE_DEEPLX_TRANSLATION) ?? false;

    LogUtils.d('useAI: $useAI, useDeepLX: $useDeepLX', 'TranslationService');

    // 如果使用DeepLX或不使用AI，返回null（DeepLX不支持流式翻译）
    if (useDeepLX || !useAI) {
      LogUtils.i(
        '不使用流式翻译（useDeepLX: $useDeepLX, useAI: $useAI）',
        'TranslationService',
      );
      return null;
    }

    // 检查用户是否启用了流式翻译
    final streamEnabled =
        _getConfig<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ?? true;
    LogUtils.d('流式翻译启用状态: $streamEnabled', 'TranslationService');

    if (!streamEnabled) {
      LogUtils.i('用户禁用了流式翻译', 'TranslationService');
      return null; // 如果用户禁用了流式翻译，直接返回null
    }

    // 为每个翻译请求创建一个唯一ID
    final translationId = DateTime.now().millisecondsSinceEpoch.toString();
    LogUtils.i('创建流式翻译，ID: $translationId', 'TranslationService');

    final streamController = StreamController<String>();
    _activeStreamTranslations[translationId] = streamController;

    // 设置超时计时器
    _setupTranslationTimeout(translationId);

    // 启动流式翻译
    _translateWithAIStream(text, translationId, targetLanguage: targetLanguage);

    // 当流被取消时，清理资源
    streamController.onCancel = () {
      LogUtils.i('流式翻译被取消，ID: $translationId', 'TranslationService');
      _cleanupTranslationResources(translationId);
    };

    return streamController.stream;
  }

  /// 设置翻译超时计时器
  void _setupTranslationTimeout(String translationId) {
    // 取消可能存在的之前的计时器
    _translationTimeouts[translationId]?.cancel();

    // 创建新的计时器
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

    // 关闭并移除流控制器
    final streamController = _activeStreamTranslations[translationId];
    if (streamController != null && !streamController.isClosed) {
      if (isTimeout) {
        // 如果是因为超时关闭的，添加错误信息
        streamController.addError(
          slang.t.translation.translationRequestTimeout,
        );
      }
      streamController.close();
    }
    _activeStreamTranslations.remove(translationId);
  }

  /// 使用流式传输进行AI翻译
  Future<void> _translateWithAIStream(
    String text,
    String translationId, {
    String? targetLanguage,
  }) async {
    // 获取流控制器，如果不存在则返回
    final streamController = _activeStreamTranslations[translationId];
    if (streamController == null) return;

    try {
      final requestData = _buildAIRequestData(
        text,
        targetLanguage: targetLanguage,
        stream: true,
      );
      final url = getFinalUrl(
        _getConfig<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '',
      );

      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: _getAuthHeaders(),
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // 处理流式响应
      String fullTranslation = '';

      // 获取响应流
      final responseStream = response.data.stream as Stream<List<int>>;

      // 创建活动监听标志
      bool isActive = true;

      // 设置数据接收超时
      Timer? inactivityTimer;
      void resetInactivityTimer() {
        inactivityTimer?.cancel();
        inactivityTimer = Timer(const Duration(seconds: 30), () {
          if (isActive) {
            LogUtils.w(
              slang.t.translation.streamingTranslationDataTimeout,
              'TranslationService',
            );
            isActive = false;
            streamController.addError(slang.t.translation.dataReceptionTimeout);
            _cleanupTranslationResources(translationId);
          }
        });
      }

      // 初始化超时计时器
      resetInactivityTimer();

      // 监听流数据
      await for (final chunk in responseStream) {
        // 收到数据，重置超时计时器
        resetInactivityTimer();

        // 如果流控制器已关闭或不再活动，停止处理
        if (streamController.isClosed || !isActive) break;

        // 将字节数据转换为字符串
        final chunkString = utf8.decode(chunk);

        // 处理SSE格式的数据
        final lines = chunkString
            .split('\n')
            .where(
              (line) => line.startsWith('data: ') && line != 'data: [DONE]',
            )
            .map((line) => line.substring(6));

        for (final line in lines) {
          try {
            final data = jsonDecode(line) as Map<String, dynamic>;
            if (data.containsKey('choices') &&
                (data['choices'] as List).isNotEmpty &&
                data['choices'][0].containsKey('delta') &&
                data['choices'][0]['delta'].containsKey('content')) {
              final content = data['choices'][0]['delta']['content'] as String;
              fullTranslation += content;

              // 将新内容发送到流
              streamController.add(fullTranslation);
            }
          } catch (e) {
            LogUtils.e(slang.t.translation.streamDataParseError, error: e);
          }
        }
      }

      // 取消数据接收超时计时器
      inactivityTimer?.cancel();

      // 完成翻译后关闭流
      if (!streamController.isClosed && isActive) {
        await streamController.close();
      }
    } catch (e) {
      LogUtils.e(slang.t.translation.streamingTranslationFailed, error: e);

      // 降级：使用普通翻译方式
      if (!streamController.isClosed) {
        try {
          // 使用普通翻译获取结果
          final result = await _translateWithAI(
            text,
            targetLanguage: targetLanguage,
          );
          if (result.isSuccess && result.data != null) {
            streamController.add(result.data!);
          } else {
            streamController.addError(result.message);
          }
        } catch (fallbackError) {
          LogUtils.e(
            slang.t.translation.fallbackTranslationFailed,
            error: fallbackError,
          );
          streamController.addError(fallbackError);
        } finally {
          // 关闭流
          await streamController.close();
        }
      }
    } finally {
      // 确保清理所有相关资源
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

    for (final controller in _activeStreamTranslations.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _activeStreamTranslations.clear();

    super.onClose();
  }
}
