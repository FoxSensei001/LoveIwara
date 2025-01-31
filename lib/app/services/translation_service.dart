import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'dart:convert';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class TranslationService extends GetxService {
  final ConfigService _configService = Get.find();
  final Dio dio = Dio();

  Future<ApiResult<String>> translate(String text,
      {String? targetLanguage}) async {
    final useAI =
        Get.find<ConfigService>()[ConfigService.USE_AI_TRANSLATION] as bool? ??
            false;

    return useAI
        ? _translateWithAI(text, targetLanguage: targetLanguage)
        : _translateWithGoogle(text, targetLanguage);
  }

  Future<ApiResult<String>> _translateWithGoogle(
      String text, String? targetLanguage) async {
    try {
      final response = await dio.get(
        "https://translate.googleapis.com/translate_a/t",
        queryParameters: {
          "client": "gtx",
          "sl": "auto",
          "tl": targetLanguage ?? _configService.currentTranslationLanguage,
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

  Future<ApiResult<String>> _translateWithAI(String text,
      {String? targetLanguage}) async {
    final config = Get.find<ConfigService>();
    String baseUrl = config[ConfigService.AI_TRANSLATION_BASE_URL];
    // 如果以 / 结尾，则去掉
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final model = config[ConfigService.AI_TRANSLATION_MODEL];
    final apiKey = config[ConfigService.AI_TRANSLATION_API_KEY];
    final maxTokens = config[ConfigService.AI_TRANSLATION_MAX_TOKENS] as int? ?? 500;
    final temperature = config[ConfigService.AI_TRANSLATION_TEMPERATURE] as double? ?? 0.3;

    try {
      final response = await dio.post("$baseUrl/chat/completions",
          data: {
            "model": model,
            "messages": [
              {
                "role": "system",
                "content":
                    "You are a translation expert. Translate from the input language to ${targetLanguage?? _configService.currentTranslationLanguage}. Provide the translation result directly without any explanation and keep the original format. Do not translate if the target language is the same as the source language. Additionally, if the content contains illegal or NSFW elements, sensitive words or sentences within it should be replaced."
              },
              {"role": "user", "content": text}
            ],
            "temperature": temperature,
            "max_tokens": maxTokens
          },
          options: Options(headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json'
          }));

      final result =
          response.data['choices'][0]['message']['content'] as String;
      return ApiResult.success(message: '', data: result);
    } catch (e) {
      LogUtils.e('AI翻译失败', tag: 'TranslationService', error: e);
      return ApiResult.fail(t.errors.failedToOperate);
    }
  }

  Future<ApiResult<AITestResult>> testAITranslation(
      String baseUrl, String model, String apiKey,
      {String? targetLanguage}) async {
    final config = Get.find<ConfigService>();
    final maxTokens = config[ConfigService.AI_TRANSLATION_MAX_TOKENS] as int? ?? 500;
    final temperature = config[ConfigService.AI_TRANSLATION_TEMPERATURE] as double? ?? 0.1;

    // 如果以 / 结尾，则去掉
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    try {
      const testText = "Hello";

      final messages = [
        {
          "role": "system",
          "content":
              "You are a translation expert. Translate from the input language to ${targetLanguage?? _configService.currentTranslationLanguage}. Provide the translation result directly without any explanation and keep the original format. Do not translate if the target language is the same as the source language. Additionally, if the content contains illegal or NSFW elements, sensitive words or sentences within it should be replaced."
        },
        {"role": "user", "content": testText}
      ];

      final testDio = Dio();
      final response = await testDio.post("$baseUrl/chat/completions",
          data: {
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": maxTokens
          },
          options: Options(
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json'
              },
              validateStatus: (status) => status! < 500));

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

  void resetProxy() {
    dio.httpClientAdapter = IOHttpClientAdapter();
  }
}
