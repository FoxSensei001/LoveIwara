import 'package:get/get.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'dart:async';
import 'package:i_iwara/app/utils/markdown_formatter.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 用于控制Markdown翻译功能的控制器
///
/// 此控制器可以被外部组件使用，以触发CustomMarkdownBody的翻译功能，
/// 同时保持外部UI的独立性。
class MarkdownTranslationController {
  // 翻译状态
  final RxBool isTranslating = false.obs;
  final Rxn<String> translatedText = Rxn<String>();
  final Rxn<String> rawTranslatedText = Rxn<String>(); // 存储未格式化的翻译文本
  final RxBool isTranslationComplete = false.obs; // 标记翻译是否完成

  // 控制器使用的翻译服务和Markdown格式化工具
  final TranslationService _translationService = Get.find();
  final MarkdownFormatter _markdownFormatter = MarkdownFormatter();

  // 流式翻译订阅
  StreamSubscription<String>? _translationStreamSubscription;

  // 检查是否有翻译结果
  bool get hasTranslation => translatedText.value != null;

  // 检查是否正在流式翻译中
  bool get isStreamTranslating =>
      isTranslating.value && !isTranslationComplete.value;

  // 触发翻译
  Future<void> translate(
    String text, {
    String? targetLanguage,
    String? originalText,
  }) async {
    LogUtils.i('开始翻译，文本长度: ${text.length}', 'MarkdownTranslationController');

    if (isTranslating.value) {
      LogUtils.w('翻译正在进行中，忽略此次请求', 'MarkdownTranslationController');
      return;
    }

    isTranslating.value = true;
    isTranslationComplete.value = false;
    rawTranslatedText.value = null;
    translatedText.value = null;

    // 取消之前的流订阅
    await _translationStreamSubscription?.cancel();
    _translationStreamSubscription = null;

    // 使用原始文本进行翻译，如果没有提供则使用传入的文本
    final textToTranslate = originalText ?? text;
    LogUtils.d('待翻译文本: $textToTranslate', 'MarkdownTranslationController');

    // 尝试使用流式翻译
    final stream = _translationService.translateStream(
      textToTranslate,
      targetLanguage: targetLanguage,
    );
    if (stream != null) {
      LogUtils.i('使用流式翻译', 'MarkdownTranslationController');
      _translationStreamSubscription = stream.listen(
        (newText) {
          LogUtils.d(
            '收到流式翻译数据，长度: ${newText.length}',
            'MarkdownTranslationController',
          );
          // 在翻译过程中只更新原始文本，不进行格式化
          rawTranslatedText.value = newText;
          if (!isTranslationComplete.value) {
            translatedText.value = newText;
          }
        },
        onError: (error) {
          LogUtils.e(
            '流式翻译出错',
            tag: 'MarkdownTranslationController',
            error: error,
          );
          rawTranslatedText.value =
              slang.t.common.translateFailedPleaseTryAgainLater;
          translatedText.value = rawTranslatedText.value;
          isTranslating.value = false;
          isTranslationComplete.value = true;
        },
        onDone: () {
          LogUtils.i('流式翻译完成', 'MarkdownTranslationController');
          // 翻译完成后，进行格式化处理
          isTranslationComplete.value = true;
          _processTranslatedText();
        },
      );
      return;
    }

    // 如果流式翻译不可用或被禁用，使用普通翻译
    LogUtils.i('使用普通翻译', 'MarkdownTranslationController');
    final result = await _translationService.translate(
      textToTranslate,
      targetLanguage: targetLanguage,
    );
    LogUtils.i(
      '普通翻译结果: ${result.isSuccess ? "成功" : "失败"}, 数据长度: ${result.data?.length ?? 0}',
      'MarkdownTranslationController',
    );

    if (result.isSuccess) {
      rawTranslatedText.value = result.data;
      translatedText.value = rawTranslatedText.value;
      isTranslationComplete.value = true;
      // 翻译完成后，进行格式化处理
      _processTranslatedText();
    } else {
      LogUtils.e(
        '翻译失败: ${result.message}',
        tag: 'MarkdownTranslationController',
      );
      rawTranslatedText.value =
          slang.t.common.translateFailedPleaseTryAgainLater;
      translatedText.value = rawTranslatedText.value;
      isTranslating.value = false;
      isTranslationComplete.value = true;
    }
  }

  // 处理翻译文本的格式化
  Future<void> _processTranslatedText() async {
    if (rawTranslatedText.value == null ||
        rawTranslatedText.value ==
            slang.t.common.translateFailedPleaseTryAgainLater) {
      isTranslating.value = false;
      isTranslationComplete.value = true;
      return;
    }

    try {
      // 使用工具类处理翻译文本的格式化
      final processed = await _markdownFormatter.processTranslatedText(
        rawTranslatedText.value!,
      );

      translatedText.value = processed;
      isTranslating.value = false;
      isTranslationComplete.value = true;
    } catch (e) {
      LogUtils.e(
        '格式化翻译文本时发生错误',
        error: e,
        tag: 'MarkdownTranslationController',
      );
      translatedText.value = rawTranslatedText.value;
      isTranslating.value = false;
      isTranslationComplete.value = true;
    }
  }

  // 清除翻译结果
  void clearTranslation() {
    translatedText.value = null;
    rawTranslatedText.value = null;
    isTranslationComplete.value = false;
  }

  void dispose() {
    _translationStreamSubscription?.cancel();
  }
}
