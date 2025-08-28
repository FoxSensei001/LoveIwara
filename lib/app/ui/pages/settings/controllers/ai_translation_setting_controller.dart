import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';

class AITranslationSettingsController extends GetxController {
  final ConfigService configService = Get.find();
  final TranslationService translationService = Get.find();

  // Text Editing Controllers
  late final TextEditingController baseUrlController;
  late final TextEditingController modelController;
  late final TextEditingController apiKeyController;
  late final TextEditingController maxTokensController;
  late final TextEditingController temperatureController;
  late final TextEditingController promptController;

  // Reactive State
  final isAIEnabled = false.obs;
  final isTesting = false.obs;
  final isConnectionValid = false.obs;
  final hasTested = false.obs;
  final testResult = Rx<AITestResult?>(null);
  final obscureApiKey = true.obs;

  // Form Key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadInitialState();
  }

  void _initializeControllers() {
    baseUrlController =
        TextEditingController(text: configService[ConfigKey.AI_TRANSLATION_BASE_URL]);
    modelController =
        TextEditingController(text: configService[ConfigKey.AI_TRANSLATION_MODEL]);
    apiKeyController =
        TextEditingController(text: configService[ConfigKey.AI_TRANSLATION_API_KEY]);
    maxTokensController = TextEditingController(
      text: configService[ConfigKey.AI_TRANSLATION_MAX_TOKENS].toString(),
    );
    temperatureController = TextEditingController(
      text: configService[ConfigKey.AI_TRANSLATION_TEMPERATURE].toStringAsFixed(1),
    );
    promptController =
        TextEditingController(text: configService[ConfigKey.AI_TRANSLATION_PROMPT]);
  }

  void _loadInitialState() {
    isAIEnabled.value = configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;
    resetTestState();
  }

  void onConfigChanged(ConfigKey key, String value) {
    configService[key] = value;
    if (key == ConfigKey.AI_TRANSLATION_BASE_URL ||
        key == ConfigKey.AI_TRANSLATION_MODEL ||
        key == ConfigKey.AI_TRANSLATION_API_KEY) {
      _disableAITranslation(
        message: slang.t.translation.aiTranslationWillBeDisabledDueToConfigChange,
      );
      resetTestState();
    }
  }
  
  void onPromptChanged(String value) {
    configService[ConfigKey.AI_TRANSLATION_PROMPT] = value;
    _disableAITranslation(
      message: slang.t.translation.aiTranslationWillBeDisabledDueToPromptChange,
    );
    resetTestState();
  }

  void onNumericConfigChanged(ConfigKey key, String value, {bool isDouble = false}) {
    if (value.isEmpty) return;

    final defaultValue = configService[key];
    final parsedValue = isDouble
        ? double.tryParse(value) ?? defaultValue
        : int.tryParse(value) ?? defaultValue;

    final clampedValue = isDouble
        ? (parsedValue as double).clamp(0.0, 2.0)
        : (parsedValue as int) < 1
            ? 1
            : parsedValue;

    configService[key] = clampedValue;

    if (key == ConfigKey.AI_TRANSLATION_MAX_TOKENS ||
        key == ConfigKey.AI_TRANSLATION_TEMPERATURE) {
      _disableAITranslation(
        message: slang.t.translation.aiTranslationWillBeDisabledDueToParamChange,
      );
    }

    final controller = isDouble ? temperatureController : maxTokensController;
    if (isDouble && value.endsWith('.') && !value.contains('..')) {
      return;
    }
    controller.value = controller.value.copyWith(
      text: isDouble ? clampedValue.toStringAsFixed(1) : clampedValue.toString(),
      selection: TextSelection.collapsed(
        offset: clampedValue.toString().length,
      ),
    );
  }
  
  void onTemperatureSliderChanged(double value) {
    temperatureController.text = value.toStringAsFixed(1);
    configService[ConfigKey.AI_TRANSLATION_TEMPERATURE] = value;
    _disableAITranslation(
      message: slang.t.translation.aiTranslationWillBeDisabledDueToParamChange,
    );
  }

  Future<void> testConnection() async {
    if (formKey.currentState?.validate() != true) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.translation.pleaseCheckInputParametersFormat,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    if (baseUrlController.text.isEmpty ||
        modelController.text.isEmpty ||
        apiKeyController.text.isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.translation.pleaseFillInAPIAddressModelNameAndKey,
          type: MDToastType.warning,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    isTesting.value = true;
    final result = await translationService.testAITranslation(
      baseUrlController.text.trim(),
      modelController.text.trim(),
      apiKeyController.text.trim(),
    );
    testResult.value = result.data;
    isConnectionValid.value = result.data?.connectionValid ?? false;
    hasTested.value = true;

    if (isConnectionValid.value) {
      configService[ConfigKey.AI_TRANSLATION_BASE_URL] = baseUrlController.text.trim();
      configService[ConfigKey.AI_TRANSLATION_MODEL] = modelController.text.trim();
      configService[ConfigKey.AI_TRANSLATION_API_KEY] = apiKeyController.text.trim();
    }

    isTesting.value = false;
  }

  void handleEnableSwitch(bool value) {
    if (value) {
      if (formKey.currentState?.validate() != true) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.translation.pleaseFillInValidConfigurationParameters,
            type: MDToastType.error,
          ),
          position: ToastPosition.bottom,
        );
        return;
      }
      if (!isConnectionValid.value) {
        _showValidationDialog();
        return;
      }
      if (!hasTested.value) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.translation.pleaseCompleteConnectionTest,
            type: MDToastType.warning,
          ),
          position: ToastPosition.bottom,
        );
        return;
      }
    }
    isAIEnabled.value = value;
    configService[ConfigKey.USE_AI_TRANSLATION] = value;
  }

  void _showValidationDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(slang.t.translation.needVerification),
        content: Text(slang.t.translation.needVerificationContent),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.translation.confirm),
          ),
        ],
      ),
    );
  }

  void _disableAITranslation({String? message}) {
    final wasEnabled = configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;
    if (wasEnabled) {
      showToastWidget(
        MDToastWidget(
          message: message ?? slang.t.translation.aiTranslationWillBeDisabled,
          type: MDToastType.warning,
        ),
        position: ToastPosition.bottom,
        duration: const Duration(seconds: 5),
      );
    }
    configService[ConfigKey.USE_AI_TRANSLATION] = false;
    isAIEnabled.value = false;
  }

  void resetTestState() {
    isConnectionValid.value = false;
    hasTested.value = false;
    testResult.value = null;
  }

  String formatJson(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return jsonString;
    }
  }

  @override
  void onClose() {
    baseUrlController.dispose();
    modelController.dispose();
    apiKeyController.dispose();
    maxTokensController.dispose();
    temperatureController.dispose();
    promptController.dispose();
    super.onClose();
  }
}