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

class TranslationService extends GetxService {
  final ConfigService _configService = Get.find();
  final Dio dio = Dio();

  // 存储当前正在进行的流式翻译
  final Map<String, StreamController<String>> _activeStreamTranslations = {};

  // 用于管理超时的定时器
  final Map<String, Timer> _translationTimeouts = {};

  // 流式翻译的最大超时时间（秒）
  static const int _streamTranslationTimeoutSeconds = 120;

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
  String getFinalUrl(String baseUrl, {bool keepHash = false, bool forDisplay = false}) {
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

  /// 翻译文本，会根据配置选择谷歌翻译或AI翻译
  Future<ApiResult<String>> translate(String text, {String? targetLanguage}) async {
    final useAI = _getConfig<bool>(ConfigKey.USE_AI_TRANSLATION) ?? false;
    return useAI
        ? _translateWithAI(text, targetLanguage: targetLanguage)
        : _translateWithGoogle(text, targetLanguage);
  }

  /// 使用Google翻译服务
  Future<ApiResult<String>> _translateWithGoogle(String text, String? targetLanguage) async {
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
      );

      String res = response.data[0][0] as String;
      return ApiResult.success(message: '', data: res);
    } catch (e) {
      LogUtils.e('翻译失败', tag: 'TranslationService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  /// 使用AI服务进行翻译
  Future<ApiResult<String>> _translateWithAI(String text, {String? targetLanguage}) async {
    try {
      final stream = _getConfig<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ?? false;
      final requestData = _buildAIRequestData(text, targetLanguage: targetLanguage, stream: stream);
      final url = getFinalUrl(_getConfig<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '');

      final response = await dio.post(
          url,
          data: requestData,
          options: Options(headers: _getAuthHeaders())
      );

      if (response.statusCode != 200) {
        return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
      }

      return _parseAIResponse(response.data);
    } catch (e) {
      LogUtils.e('AI翻译失败', tag: 'TranslationService', error: e);
      return ApiResult.fail(t.errors.translationFailedPleaseTryAgainLater);
    }
  }

  /// 构建AI请求的数据部分
  Map<String, dynamic> _buildAIRequestData(String text, {String? targetLanguage, bool stream = false}) {
    final currentLanguage = _getCurrentLanguage(targetLanguage);
    final prompt = _getConfig<String>(ConfigKey.AI_TRANSLATION_PROMPT)
        ?.replaceAll(CommonConstants.defaultLanguagePlaceholder, currentLanguage) ?? '';

    final result = {
      "model": _getConfig<String>(ConfigKey.AI_TRANSLATION_MODEL) ?? '',
      "messages": [
        {"role": "system", "content": prompt},
        {"role": "user", "content": text}
      ],
      "temperature": _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.7,
      "max_tokens": _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 1000
    };

    if (stream) {
      result["stream"] = true;
    }

    return result;
  }

  /// 获取认证请求头
  Map<String, String> _getAuthHeaders() {
    return {
      'Authorization': 'Bearer ${_getConfig<String>(ConfigKey.AI_TRANSLATION_API_KEY) ?? ''}',
      'Content-Type': 'application/json'
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

  // 测试方法 ---------------------------

  /// 测试AI翻译连接
  Future<ApiResult<AITestResult>> testAITranslation(
      String baseUrl, String model, String apiKey,
      {String? targetLanguage}) async {
    try {
      const testText = "Hello";

      final currentLanguage = _getCurrentLanguage(targetLanguage);
      final prompt = _getConfig<String>(ConfigKey.AI_TRANSLATION_PROMPT)
          ?.replaceAll(CommonConstants.defaultLanguagePlaceholder, currentLanguage) ?? '';

      final messages = [
        {"role": "system", "content": prompt},
        {"role": "user", "content": testText}
      ];

      final testDio = Dio();
      final url = getFinalUrl(baseUrl);
      final response = await testDio.post(
          url,
          data: {
            "model": model,
            "messages": messages,
            "temperature": _getConfig<double>(ConfigKey.AI_TRANSLATION_TEMPERATURE) ?? 0.7,
            "max_tokens": _getConfig<int>(ConfigKey.AI_TRANSLATION_MAX_TOKENS) ?? 1000
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json'
              },
              validateStatus: (status) => status! < 500
          )
      );

      if (response.statusCode != 200) {
        return ApiResult.success(
            code: response.statusCode ?? 500,
            data: AITestResult(
                custMessage: 'HTTP ${response.statusCode}',
                connectionValid: false
            )
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
                connectionValid: false
            )
        );
      }

      final content = data['choices'][0]['message']['content'] as String? ?? '';

      return ApiResult.success(
          data: AITestResult(
              rawResponse: jsonEncode(data),
              translatedText: content,
              connectionValid: true,
              custMessage: '测试成功'
          )
      );
    } catch (e) {
      LogUtils.e('AI翻译测试失败', tag: 'TranslationService', error: e);
      return ApiResult.success(
          data: AITestResult(
              custMessage: slang.t.translation.connectionFailedForMessage(message: e.toString()),
              connectionValid: false
          )
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
    final useAI = _getConfig<bool>(ConfigKey.USE_AI_TRANSLATION) ?? false;

    // 如果不使用AI，返回null
    if (!useAI) {
      return null;
    }

    // 检查用户是否启用了流式翻译
    final streamEnabled = _getConfig<bool>(ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING) ?? true;
    if (!streamEnabled) {
      return null; // 如果用户禁用了流式翻译，直接返回null
    }

    // 为每个翻译请求创建一个唯一ID
    final translationId = DateTime.now().millisecondsSinceEpoch.toString();
    final streamController = StreamController<String>();
    _activeStreamTranslations[translationId] = streamController;

    // 设置超时计时器
    _setupTranslationTimeout(translationId);

    // 启动流式翻译
    _translateWithAIStream(text, translationId, targetLanguage: targetLanguage);

    // 当流被取消时，清理资源
    streamController.onCancel = () {
      _cleanupTranslationResources(translationId);
    };

    return streamController.stream;
  }

  /// 设置翻译超时计时器
  void _setupTranslationTimeout(String translationId) {
    // 取消可能存在的之前的计时器
    _translationTimeouts[translationId]?.cancel();

    // 创建新的计时器
    _translationTimeouts[translationId] = Timer(Duration(seconds: _streamTranslationTimeoutSeconds), () {
      LogUtils.w('流式翻译超时，强制关闭资源', 'TranslationService');
      _cleanupTranslationResources(translationId, isTimeout: true);
    });
  }

  /// 清理翻译相关资源
  void _cleanupTranslationResources(String translationId, {bool isTimeout = false}) {
    // 取消超时计时器
    _translationTimeouts[translationId]?.cancel();
    _translationTimeouts.remove(translationId);

    // 关闭并移除流控制器
    final streamController = _activeStreamTranslations[translationId];
    if (streamController != null && !streamController.isClosed) {
      if (isTimeout) {
        // 如果是因为超时关闭的，添加错误信息
        streamController.addError('翻译请求超时');
      }
      streamController.close();
    }
    _activeStreamTranslations.remove(translationId);
  }

  /// 使用流式传输进行AI翻译
  Future<void> _translateWithAIStream(String text, String translationId, {String? targetLanguage}) async {
    // 获取流控制器，如果不存在则返回
    final streamController = _activeStreamTranslations[translationId];
    if (streamController == null) return;

    try {
      final requestData = _buildAIRequestData(text, targetLanguage: targetLanguage, stream: true);
      final url = getFinalUrl(_getConfig<String>(ConfigKey.AI_TRANSLATION_BASE_URL) ?? '');

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
            LogUtils.w('流式翻译接收数据超时', 'TranslationService');
            isActive = false;
            streamController.addError('接收数据超时');
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
        final lines = chunkString.split('\n')
            .where((line) => line.startsWith('data: ') && line != 'data: [DONE]')
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
            LogUtils.e('解析流数据时出错', error: e);
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
      LogUtils.e('流式翻译失败', error: e);

      // 降级：使用普通翻译方式
      if (!streamController.isClosed) {
        try {
          // 使用普通翻译获取结果
          final result = await _translateWithAI(text, targetLanguage: targetLanguage);
          if (result.isSuccess && result.data != null) {
            streamController.add(result.data!);
          } else {
            streamController.addError(result.message);
          }
        } catch (fallbackError) {
          LogUtils.e('降级到普通翻译也失败', error: fallbackError);
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
