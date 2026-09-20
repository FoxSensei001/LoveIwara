import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/deeplx_language_mapper.dart';
import 'package:i_iwara/app/utils/ai_error_describe.dart';
import 'package:i_iwara/app/utils/translation_prompt.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

/// 翻译服务。
///
/// 这里只剩**翻译的策略**：三家怎么选、提示词怎么拼、目标语言怎么算、
/// Google 怎么分段、DeepLX 的协议长什么样。
///
/// ⭐ 「怎么调 AI」已经不在这儿了——供应商档案、Agent 构造、流式生命周期、
/// 失败降级、记账全部归 [AiService]。AI 不再是翻译的实现细节，翻译只是 AI
/// 的**一个用途**（[AiTask.translate]），与搜索、小尾巴并列。
///
/// 代理：应用在启动时设置了 `HttpOverrides.global`，进程级覆盖所有 `HttpClient`，
/// dartantic 底层的 package:http 默认客户端会自动走用户配置的代理。
class TranslationService extends GetxService {
  final ConfigService _configService = Get.find();
  final Dio dio = Dio();

  TranslationService() {
    dio.options.persistentConnection = false;
  }

  AiService get _ai => Get.find<AiService>();

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

  // 错误描述 ---------------------------
  //
  // 具体实现搬到了 `lib/app/utils/ai_error_describe.dart`：AI 那半边也要用同一套
  // 措辞，两边各写一份的话，同一个 401 在两处会长得不一样。

  /// 统一的失败文案：`失败原因前缀: 具体细节`
  String _failMessage(String prefix, Object error) =>
      failMessageWith(prefix, error);

  // AI 翻译 ---------------------------
  //
  // 这里只剩「翻译这件事怎么说给模型听」。怎么连、怎么流、怎么降级归 AiService。

  /// 当前目标语言对应的系统提示词。
  ///
  /// ⛔ 内置、不可配置，理由见 [TranslationPrompt]——这段话改坏了没有任何征兆，
  /// 直接表现为「AI 没按我要的语言翻译」。
  String _buildPrompt(String? targetLanguage) =>
      TranslationPrompt.build(_getCurrentLanguage(targetLanguage));

  /// 拿设置页上**还没保存**的那几项去覆盖当前档案。
  ///
  /// 「测试连接」和「拉模型列表」都要这个：用户刚改完地址还没点保存就想试一下，
  /// 拿已保存的配置去测等于测了个寂寞。
  AiProviderProfile _profileWithOverrides({
    String? baseUrl,
    String? model,
    String? apiKey,
  }) {
    final base =
        _ai.profileFor(AiTask.translate) ??
        const AiProviderProfile(id: 'adhoc', name: 'AI');
    return base.copyWith(baseUrl: baseUrl, model: model, apiKey: apiKey);
  }

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
      return ApiResult.fail(
        _failMessage(slang.t.translation.translationFailed, e),
        exception: e,
      );
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

  /// 一次 AI 翻译请求。流式与非流式共用，**错误措辞因此只有一份**。
  AiRequest _translateRequest(
    String text,
    String? targetLanguage, {
    Duration? timeout,
    String? timeoutMessage,
  }) => AiRequest(
    task: AiTask.translate,
    input: text,
    system: _buildPrompt(targetLanguage),
    timeout: timeout,
    timeoutMessage: timeoutMessage,
    // AiService 只回技术原因（它不知道自己在替谁干活），本域的措辞在这里贴。
    decorateError: (reason) =>
        '${slang.t.translation.aiTranslationFailed}: $reason${_aiConfigHint()}',
    streamErrorLabel: slang.t.translation.streamingTranslationFailed,
  );

  /// 使用AI服务进行翻译（非流式，经 [AiService]）
  Future<ApiResult<String>> _translateWithAI(
    String text, {
    String? targetLanguage,
  }) {
    LogUtils.i('开始 AI 翻译，文本长度: ${text.length}', 'TranslationService');
    return _ai.complete(_translateRequest(text, targetLanguage));
  }

  /// AI 翻译失败时附一句配置自查提示。
  ///
  /// 不做前置拦截：空模型名是「用服务端默认模型」的合法配置，
  /// 本地端点也可能不需要密钥，拦下来反而会挡掉本来能用的配置。
  String _aiConfigHint() {
    final missing = <String>[];
    if ((_getConfig<String>(ConfigKey.AI_TRANSLATION_API_KEY) ?? '')
        .trim()
        .isEmpty) {
      missing.add(slang.t.translation.apiKey);
    }
    if ((_getConfig<String>(ConfigKey.AI_TRANSLATION_MODEL) ?? '')
        .trim()
        .isEmpty) {
      missing.add(slang.t.translation.modelName);
    }
    if (missing.isEmpty) return '';
    return '\n(${slang.t.translation.notConfigured}: ${missing.join(' / ')})';
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
        return ApiResult.fail(
          '${slang.t.translation.deeplxTranslationFailed}: '
          '${slang.t.translation.pleaseFillInDeepLXServerAddress}',
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
        return ApiResult.fail(
          '${slang.t.translation.deeplxTranslationFailed}: '
                  'HTTP ${response.statusCode} ${stringifyResponseBody(response.data)}'
              .trim(),
          code: response.statusCode ?? 500,
        );
      }

      return _parseDeepLXResponse(response.data);
    } catch (e) {
      LogUtils.e(
        slang.t.translation.deeplxTranslationFailed,
        tag: 'TranslationService',
        error: e,
      );
      return ApiResult.fail(
        _failMessage(slang.t.translation.deeplxTranslationFailed, e),
        exception: e,
      );
    }
  }

  /// 解析DeepLX响应数据
  ApiResult<String> _parseDeepLXResponse(dynamic data) {
    final prefix = slang.t.translation.deeplxTranslationFailed;

    if (data is! Map<String, dynamic>) {
      return ApiResult.fail(
        '$prefix: ${slang.t.translation.invalidAPIResponseFormat} '
        '(${stringifyResponseBody(data)})',
      );
    }

    // 检查响应状态
    final code = data['code'] as int?;
    if (code != null && code != 200) {
      final serverMessage = data['message'] ?? data['msg'];
      return ApiResult.fail(
        '$prefix: code $code'
        '${serverMessage == null ? '' : ' - $serverMessage'}',
        code: code,
      );
    }

    // 获取翻译结果
    final translatedText = data['data'] as String?;
    if (translatedText == null || translatedText.isEmpty) {
      return ApiResult.fail(
        '$prefix: ${slang.t.translation.translationServiceReturnedError} '
        '(${stringifyResponseBody(data)})',
      );
    }

    return ApiResult.success(message: '', data: translatedText);
  }

  // 测试方法 ---------------------------

  /// 测试AI翻译连接（按当前档案 + 设置页上还没保存的那几项）
  Future<ApiResult<AITestResult>> testAITranslation(
    String baseUrl,
    String model,
    String apiKey, {
    String? targetLanguage,
  }) async {
    final result = await _ai.test(
      _profileWithOverrides(baseUrl: baseUrl, model: model, apiKey: apiKey),
      probe: 'Hello',
      system: _buildPrompt(targetLanguage),
    );
    final data = result.data;
    if (data == null) {
      return ApiResult.success(
        data: AITestResult(
          custMessage: slang.t.translation.connectionFailedForMessage(
            message: result.message,
          ),
          connectionValid: false,
        ),
      );
    }
    // 本域的措辞在这里贴：AiService 回的是英文技术原因。
    return ApiResult.success(
      data: AITestResult(
        rawResponse: data.rawResponse,
        translatedText: data.translatedText,
        connectionValid: data.connectionValid,
        custMessage: data.connectionValid
            ? slang.t.translation.testSuccess
            : slang.t.translation.connectionFailedForMessage(
                message: data.custMessage,
              ),
      ),
    );
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
            custMessage:
                'HTTP ${response.statusCode} ${stringifyResponseBody(response.data)}'
                    .trim(),
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
              '${slang.t.translation.connectionFailed}: ${describeRequestError(e)}',
          connectionValid: false,
        ),
      );
    }
  }

  /// 拉取服务端可用模型列表。
  /// 让用户从列表中选择模型，而不是手动猜测模型名。
  Future<ApiResult<List<String>>> fetchAvailableModels(
    String baseUrl,
    String apiKey,
  ) async {
    final result = await _ai.listModels(
      _profileWithOverrides(baseUrl: baseUrl, apiKey: apiKey),
    );
    if (result.isSuccess) return result;
    // 空列表是「这个端点没给出可用模型」，用本域既有的文案说这件事。
    return ApiResult.fail(
      result.message == AiService.emptyModelListMessage
          ? t.translation.invalidAPIResponse
          : result.message,
      exception: result.exception,
    );
  }

  // 流式翻译相关方法 ---------------------------

  /// 使用流式传输进行翻译，返回一个流。
  ///
  /// 返回 null ＝「这次不走流式」，调用方据此退回一次要完的那条路。三种情况：
  /// 用的不是 AI、用户关了流式、以及没有可用的 AI 档案。
  ///
  /// [onReasoning] 推理模型的思考过程增量回调（累计文本）；仅原生支持 thinking
  /// 的那几家会触发（见 [AiProviderKind.supportsThinking]）。
  /// [cancelToken] 兼容旧调用方而保留；AI 流式通过取消订阅来中断（取消返回的
  /// 这条 Stream 即可，[AiService] 会连底层订阅一起掐掉）。
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

    return _ai.stream(
      _translateRequest(
        text,
        targetLanguage,
        timeout: const Duration(seconds: _streamTranslationTimeoutSeconds),
        timeoutMessage: slang.t.translation.translationRequestTimeout,
      ),
      onReasoning: onReasoning,
    );
  }
}
