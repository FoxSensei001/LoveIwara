import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class AITranslationSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const AITranslationSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AITranslationSettingsWidget(isWideScreen: isWideScreen),
    );
  }
}

class AITranslationSettingsWidget extends StatefulWidget {
  final bool isWideScreen;

  const AITranslationSettingsWidget({super.key, this.isWideScreen = false});

  @override
  State<AITranslationSettingsWidget> createState() =>
      _AITranslationSettingsWidgetState();
}

class _AITranslationSettingsWidgetState
    extends State<AITranslationSettingsWidget> {
  final ConfigService configService = Get.find();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final RxBool _isAIEnabled = false.obs;
  final RxBool _isTesting = false.obs;
  final RxBool _isConnectionValid = false.obs;
  final RxBool _hasTested = false.obs;
  final RxBool _isFetchingModels = false.obs;
  final TranslationService translationService = Get.find();
  final Rx<AITestResult?> _testResult = Rx<AITestResult?>(null);
  final debounceDuration = const Duration(milliseconds: 500);
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _maxTokensController;
  late final TextEditingController _temperatureController;
  final TextEditingController _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _baseUrlController.text = configService[ConfigKey.AI_TRANSLATION_BASE_URL];
    _modelController.text = configService[ConfigKey.AI_TRANSLATION_MODEL];
    _apiKeyController.text = configService[ConfigKey.AI_TRANSLATION_API_KEY];
    _isConnectionValid.value = false;
    _hasTested.value = false;
    _testResult.value = null;
    _isAIEnabled.value =
        configService[ConfigKey.USE_AI_TRANSLATION] as bool? ?? false;
    _maxTokensController = TextEditingController(
      text: configService[ConfigKey.AI_TRANSLATION_MAX_TOKENS].toString(),
    );
    _temperatureController = TextEditingController(
      text: configService[ConfigKey.AI_TRANSLATION_TEMPERATURE].toStringAsFixed(
        1,
      ),
    );
    _promptController.text = configService[ConfigKey.AI_TRANSLATION_PROMPT];
  }

  @override
  void dispose() {
    // 释放全部 TextEditingController，避免每次进出设置页泄漏其内部 listener
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _maxTokensController.dispose();
    _temperatureController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    _isTesting.value = true;

    // 获取要测试的baseUrl，处理特殊情况
    String baseUrl = _baseUrlController.text.trim();

    final result = await translationService.testAITranslation(
      baseUrl,
      _modelController.text.trim(),
      _apiKeyController.text.trim(),
    );
    _testResult.value = result.data;
    _isConnectionValid.value = result.data?.connectionValid ?? false;
    _hasTested.value = true;

    // 如果连接测试成功，默认支持流式传输
    if (_isConnectionValid.value) {
      // 更新配置
      configService[ConfigKey.AI_TRANSLATION_BASE_URL] = baseUrl;
      configService[ConfigKey.AI_TRANSLATION_MODEL] = _modelController.text
          .trim();
      configService[ConfigKey.AI_TRANSLATION_API_KEY] = _apiKeyController.text
          .trim();
    }

    _isTesting.value = false;
  }

  void _showValidationDialog() {
    showAppDialog(
      AlertDialog(
        // title: Text('需要验证'),
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

  Future<void> _disableAITranslation({String? message}) async {
    final wasEnabled = configService[ConfigKey.USE_AI_TRANSLATION] as bool;
    if (wasEnabled) {
      // 显示提示
      showToastWidget(
        MDToastWidget(
          message: message ?? slang.t.translation.aiTranslationWillBeDisabled,
          type: MDToastType.warning,
        ),
        position: ToastPosition.bottom,
        duration: const Duration(seconds: 5),
      );
    }

    // 更新配置
    configService[ConfigKey.USE_AI_TRANSLATION] = false;
    _isAIEnabled.value = false;
  }

  @override
  Widget build(BuildContext context) {
    // 将 Form 提升到最外层
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.translation.translation,
            isWideScreen: widget.isWideScreen,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.crossAxisExtent;
                final bool isWide = width >= 1000;
                final int crossCount = isWide ? 2 : 1;

                final List<Widget> cards = [
                  Obx(() => _buildStatusCard(context)),
                  _buildDisclaimerCard(context),
                  _buildAPIConfigSection(context),
                  _buildModelCompatibilitySection(context),
                  _buildAdvancedConfigSection(context),
                  _buildPreviewSection(context),
                  _buildTestConnectionSection(context),
                  _buildEnableSection(context),
                  SizedBox(
                    height: computeBottomSafeInset(MediaQuery.of(context)) + 16,
                  ),
                ];

                return SliverWaterfallFlow(
                  gridDelegate:
                      SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                  delegate: SliverChildListDelegate(cards),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isEnabled = _isAIEnabled.value;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [
                    Colors.purple.withValues(alpha: 0.1),
                    Colors.purple.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.grey.withValues(alpha: 0.1),
                    Colors.grey.withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isEnabled
                      ? [const Color(0xFF6B8DE3), const Color(0xFF8B5CF6)]
                      : [Colors.grey, Colors.grey],
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slang.t.translation.aiTranslation,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled
                          ? slang.t.translation.enabled
                          : slang.t.translation.disabled,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isEnabled ? Colors.purple : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isEnabled ? Colors.purple : Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    slang.t.translation.disclaimer,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '${slang.t.translation.riskWarning}:\n',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text:
                        '• ${slang.t.translation.dureToRisk1}\n'
                        '• ${slang.t.translation.dureToRisk2}\n\n',
                  ),
                  TextSpan(
                    text: '${slang.t.translation.operationSuggestion}:\n',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text:
                        '${slang.t.translation.operationSuggestion1}\n'
                        '${slang.t.translation.operationSuggestion2}\n',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIConfigSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.translation.apiConfig,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slang.t.translation.modifyConfigWillAutoCloseAITranslation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slang.t.translation.multiProviderHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 900;
                const double gap = 16;
                final double itemWidth = isWide
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: gap,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _buildInputSection(
                            context: context,
                            label: slang.t.translation.apiAddress,
                            controller: _baseUrlController,
                            hintText: 'https://api.openai.com/v1',
                            configKey: ConfigKey.AI_TRANSLATION_BASE_URL,
                            icon: Icons.link,
                            helperText:
                                slang.t.translation.baseUrlOptionalHelperText,
                            allowEmpty: true,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputSection(
                                context: context,
                                label: slang.t.translation.modelName,
                                controller: _modelController,
                                hintText: slang.t.translation.modelNameHintText,
                                configKey: ConfigKey.AI_TRANSLATION_MODEL,
                                icon: Icons.model_training,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Obx(
                                  () => TextButton.icon(
                                    onPressed: _isFetchingModels.value
                                        ? null
                                        : _handleFetchModels,
                                    icon: _isFetchingModels.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.cloud_download, size: 18),
                                    label: Text(
                                      _isFetchingModels.value
                                          ? slang.t.translation.fetchingModels
                                          : slang.t.translation.fetchModelList,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildApiKeyInputSection(context),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildNumberInputSection(
                            context: context,
                            label: slang.t.translation.maxTokens,
                            configKey: ConfigKey.AI_TRANSLATION_MAX_TOKENS,
                            icon: Icons.numbers,
                            hintText: slang.t.translation.maxTokensHintText,
                            controller: _maxTokensController,
                            defaultValue:
                                configService[ConfigKey
                                    .AI_TRANSLATION_MAX_TOKENS],
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildTemperatureSlider(context),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCompatibilitySection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.translation.modelCompatibility,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slang.t.translation.modelCompatibilityDescription,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderDropdown(context),
                const SizedBox(height: 8),
                _buildProviderPresetDropdown(context),
                const SizedBox(height: 8),
                _buildCompatSwitch(
                  context: context,
                  icon: Icons.psychology_alt_outlined,
                  title: slang.t.translation.reasoningModel,
                  description: slang.t.translation.reasoningModelDescription,
                  configKey: ConfigKey.AI_TRANSLATION_REASONING_MODEL,
                ),
                _buildCompatSwitch(
                  context: context,
                  icon: Icons.thermostat,
                  title: slang.t.translation.sendTemperature,
                  description: slang.t.translation.sendTemperatureDescription,
                  configKey: ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE,
                ),
                _buildCompatSwitch(
                  context: context,
                  icon: Icons.visibility,
                  title: slang.t.translation.showReasoningProcess,
                  description:
                      slang.t.translation.showReasoningProcessDescription,
                  configKey: ConfigKey.AI_TRANSLATION_SHOW_REASONING,
                  // 仅影响 UI 展示，无需重新测试连接
                  disablesTranslation: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderDropdown(BuildContext context) {
    const providers = ['openai', 'anthropic', 'google'];
    String labelFor(String id) => switch (id) {
      'anthropic' => slang.t.translation.providerAnthropic,
      'google' => slang.t.translation.providerGoogle,
      _ => slang.t.translation.providerOpenAI,
    };
    return Obx(() {
      final current =
          configService[ConfigKey.AI_TRANSLATION_PROVIDER] as String? ??
          'openai';
      return Row(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            slang.t.translation.provider,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: providers.contains(current) ? current : 'openai',
              items: providers
                  .map(
                    (id) => DropdownMenuItem<String>(
                      value: id,
                      child: Text(labelFor(id), overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                configService[ConfigKey.AI_TRANSLATION_PROVIDER] = id;
                _disableAITranslation(
                  message: slang
                      .t
                      .translation
                      .aiTranslationWillBeDisabledDueToConfigChange,
                );
                _isConnectionValid.value = false;
                _hasTested.value = false;
                _testResult.value = null;
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProviderPresetDropdown(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.tune,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          slang.t.translation.providerPreset,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: null,
            hint: Text(slang.t.translation.selectProviderPreset),
            items: _providerPresets
                .map(
                  (p) => DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(
                      _localizedPresetName(p),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id == null) return;
              final preset = _providerPresets.firstWhere((p) => p.id == id);
              _applyProviderPreset(preset);
            },
          ),
        ),
      ],
    );
  }

  /// 解析预设的本地化展示名称；品牌名保留原样，仅描述性文案随语言切换。
  String _localizedPresetName(_ProviderPreset preset) {
    final names = slang.t.translation.presetNames;
    switch (preset.id) {
      case 'custom':
        return slang.t.translation.presetCustom;
      case 'openai':
        return names.openai;
      case 'openai_reasoning':
        return names.openaiReasoning;
      case 'anthropic':
        return names.anthropic;
      case 'anthropic_reasoning':
        return names.anthropicReasoning;
      case 'gemini':
        return names.gemini;
      case 'gemini_reasoning':
        return names.geminiReasoning;
      case 'deepseek':
        return names.deepseek;
      case 'deepseek_reasoner':
        return names.deepseekReasoner;
      case 'siliconflow':
        return names.siliconflow;
      case 'zhipu':
        return names.zhipu;
      default:
        return preset.name;
    }
  }

  void _applyProviderPreset(_ProviderPreset preset) {
    if (preset.id == 'custom') return;

    configService[ConfigKey.AI_TRANSLATION_PROVIDER] = preset.provider;
    // baseUrl: 有值则填入，null 表示用该服务商默认端点（清空）
    _baseUrlController.text = preset.baseUrl ?? '';
    configService[ConfigKey.AI_TRANSLATION_BASE_URL] = preset.baseUrl ?? '';
    configService[ConfigKey.AI_TRANSLATION_REASONING_MODEL] = preset.reasoning;
    configService[ConfigKey.AI_TRANSLATION_SEND_TEMPERATURE] =
        preset.sendTemperature;

    _disableAITranslation(
      message: slang.t.translation.aiTranslationWillBeDisabledDueToConfigChange,
    );
    _isConnectionValid.value = false;
    _hasTested.value = false;
    _testResult.value = null;

    showToastWidget(
      MDToastWidget(
        message: slang.t.translation.presetApplied(
          name: _localizedPresetName(preset),
        ),
        type: MDToastType.success,
      ),
      position: ToastPosition.bottom,
    );
  }

  Widget _buildCompatSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required ConfigKey configKey,
    bool disablesTranslation = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: configService[configKey] as bool? ?? false,
              onChanged: (value) {
                configService[configKey] = value;
                if (disablesTranslation) {
                  _disableAITranslation(
                    message: slang
                        .t
                        .translation
                        .aiTranslationWillBeDisabledDueToParamChange,
                  );
                  _isConnectionValid.value = false;
                  _hasTested.value = false;
                  _testResult.value = null;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFetchModels() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.translation.apiKeyCannotBeEmpty,
          type: MDToastType.warning,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    _isFetchingModels.value = true;
    final result = await translationService.fetchAvailableModels(
      baseUrl,
      apiKey,
    );
    _isFetchingModels.value = false;

    if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
      _showModelPickerDialog(result.data!);
    } else {
      showToastWidget(
        MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
    }
  }

  void _showModelPickerDialog(List<String> models) {
    final searchText = ''.obs;
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.translation.selectModel),
        content: SizedBox(
          width: 400,
          height: 480,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: slang.t.translation.searchModel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                onChanged: (v) => searchText.value = v.toLowerCase(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  final filtered = searchText.value.isEmpty
                      ? models
                      : models
                            .where(
                              (m) => m.toLowerCase().contains(searchText.value),
                            )
                            .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(slang.t.translation.noModelsFound),
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final model = filtered[index];
                      return ListTile(
                        dense: true,
                        title: Text(model),
                        onTap: () {
                          _modelController.text = model;
                          configService[ConfigKey.AI_TRANSLATION_MODEL] = model;
                          _disableAITranslation(
                            message: slang
                                .t
                                .translation
                                .aiTranslationWillBeDisabledDueToConfigChange,
                          );
                          _isConnectionValid.value = false;
                          _hasTested.value = false;
                          _testResult.value = null;
                          AppService.tryPop();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.translation.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedConfigSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.translation.advancedSettings,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                _buildPromptEditor(context),
                // ...其他高级设置
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit_note,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.translationPrompt,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _promptController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: slang.t.translation.promptHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            helperText: slang.t.translation.promptHelperText,
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return slang.t.translation.thisFieldCannotBeEmpty;
            }
            if (!value.contains(CommonConstants.defaultLanguagePlaceholder)) {
              return slang.t.translation.promptMustContainTargetLang;
            }
            return null;
          },
          onChanged: (value) {
            configService[ConfigKey.AI_TRANSLATION_PROMPT] = value;
            _disableAITranslation(
              message: slang
                  .t
                  .translation
                  .aiTranslationWillBeDisabledDueToPromptChange,
            );
            _isConnectionValid.value = false;
            _hasTested.value = false;
            _testResult.value = null;
          },
        ),
      ],
    );
  }

  Widget _buildTestConnectionSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  slang.t.translation.testConnection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTestButton(),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (_testResult.value == null) {
              return _buildInfoCard(
                context: context,
                child: Text(
                  slang.t.translation.clickTestButtonToVerifyAPIConnection,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }
            return _buildTestResultSection(context);
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.translation.requestPreview,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildRequestPreview(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(
        () => SwitchListTile(
          title: Text(
            slang.t.translation.enableAITranslation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            _isAIEnabled.value
                ? slang.t.translation.enabled
                : slang.t.translation.disabled,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: _isAIEnabled.value,
          onChanged: _handleSwitchChange,
          secondary: Icon(
            Icons.translate,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return Obx(
      () => ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _handleTestConnection,
        icon: _isTesting.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.bolt, size: 20),
        label: Text(
          _isTesting.value
              ? slang.t.translation.testing
              : slang.t.translation.testNow,
        ),
      ),
    );
  }

  Widget _buildTestResultSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isValid = _testResult.value!.connectionValid;
      return _buildInfoCard(
        color: isValid
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        context: context,
        child: Column(
          spacing: 16,
          children: [
            _buildStatusRow(
              slang.t.translation.connectionStatus,
              isValid
                  ? slang.t.translation.success
                  : slang.t.translation.failed,
              isValid,
              successColor: colorScheme.onPrimaryContainer,
              errorColor: colorScheme.onErrorContainer,
            ),
            _buildStatusRow(
              slang.t.translation.information,
              _testResult.value!.custMessage,
              _testResult.value!.custMessage.isNotEmpty,
              successColor: colorScheme.onPrimaryContainer,
              errorColor: colorScheme.onErrorContainer,
            ),
            if (_testResult.value!.rawResponse != null) ...[
              ExpansionTile(
                title: Text(
                  slang.t.translation.viewRawResponse,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        _formatJson(_testResult.value!.rawResponse!),
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatusRow(
    String label,
    String value,
    bool isSuccess, {
    Color? successColor,
    Color? errorColor,
  }) {
    final colorScheme = context.theme.colorScheme;
    final effectiveSuccessColor = successColor ?? colorScheme.primary;
    final effectiveErrorColor = errorColor ?? colorScheme.error;

    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? effectiveSuccessColor : effectiveErrorColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isSuccess
                      ? effectiveSuccessColor
                      : effectiveErrorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTestConnection() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.translation.pleaseCheckInputParametersFormat,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    // baseUrl 现在可选（留空用服务商默认端点），仅要求 model 与 apiKey
    if (_modelController.text.isEmpty || _apiKeyController.text.isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.translation.pleaseFillInAPIAddressModelNameAndKey,
          type: MDToastType.warning,
        ),
        position: ToastPosition.bottom,
      );
      return;
    }

    _testConnection();
  }

  void _handleSwitchChange(bool value) {
    final form = _formKey.currentState;
    if (value) {
      if (form == null || !form.validate()) {
        showToastWidget(
          // MDToastWidget(message: '请先填写有效的配置参数', type: MDToastType.error),
          MDToastWidget(
            message:
                slang.t.translation.pleaseFillInValidConfigurationParameters,
            type: MDToastType.error,
          ),
          position: ToastPosition.bottom,
        );
        return;
      }
      if (!_isConnectionValid.value) {
        _showValidationDialog();
        return;
      }
      if (!_hasTested.value) {
        showToastWidget(
          // MDToastWidget(message: '请先完成连接测试', type: MDToastType.warning),
          MDToastWidget(
            message: slang.t.translation.pleaseCompleteConnectionTest,
            type: MDToastType.warning,
          ),
          position: ToastPosition.bottom,
        );
        return;
      }
    }
    _isAIEnabled.value = value;
    configService[ConfigKey.USE_AI_TRANSLATION] = value;
  }

  Widget _buildRequestPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final baseUrl = configService[ConfigKey.AI_TRANSLATION_BASE_URL];
      final model = configService[ConfigKey.AI_TRANSLATION_MODEL];
      final apiKey = configService[ConfigKey.AI_TRANSLATION_API_KEY];
      final provider =
          configService[ConfigKey.AI_TRANSLATION_PROVIDER] as String? ??
          'openai';

      final maxTokens = configService[ConfigKey.AI_TRANSLATION_MAX_TOKENS];
      final temperature = configService[ConfigKey.AI_TRANSLATION_TEMPERATURE];

      // 获取流式传输支持状态
      final supportsStreaming =
          configService[ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING] as bool? ??
          false;

      final providerLabel = switch (provider) {
        'anthropic' => slang.t.translation.providerAnthropic,
        'google' => slang.t.translation.providerGoogle,
        _ => slang.t.translation.providerOpenAI,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConfigRow(
            icon: Icons.cloud_outlined,
            label: '${slang.t.translation.provider}:',
            value: providerLabel,
            context: context,
          ),
          _buildConfigRow(
            icon: Icons.link,
            label: '${slang.t.translation.apiEndpoint}:',
            value: (baseUrl as String).isNotEmpty
                ? baseUrl
                : slang.t.translation.defaultEndpoint,
            valueStyle: TextStyle(
              fontFamily: 'JetBrainsMono',
              color: colorScheme.onSurfaceVariant,
            ),
            context: context,
          ),
          _buildConfigRow(
            icon: Icons.model_training,
            label: '${slang.t.translation.modelName}:',
            value: model.isNotEmpty ? model : slang.t.translation.notConfigured,
            warning: model.isEmpty,
            context: context,
          ),
          _buildConfigRow(
            icon: Icons.key,
            label: '${slang.t.translation.authenticationStatus}:',
            value: apiKey.isNotEmpty
                ? slang.t.translation.configuredKey
                : slang.t.translation.notConfiguredKey,
            warning: apiKey.isEmpty,
            context: context,
          ),
          _buildConfigRow(
            icon: Icons.numbers,
            label: '${slang.t.translation.maxTokens}:',
            value: maxTokens.toString(),
            context: context,
          ),
          _buildConfigRow(
            icon: Icons.thermostat,
            label: '${slang.t.translation.temperature}:',
            value: temperature.toStringAsFixed(1),
            context: context,
          ),
          _buildSwitchConfigRow(
            icon: Icons.stream,
            label: '${slang.t.translation.streamingTranslation}:',
            description: slang.t.translation.streamingTranslationDescription,
            warningText: slang.t.translation.streamingTranslationWarning,
            value: supportsStreaming,
            onChanged: (value) {
              configService[ConfigKey.AI_TRANSLATION_SUPPORTS_STREAMING] =
                  value;
            },
            context: context,
          ),
        ],
      );
    });
  }

  Widget _buildConfigRow({
    required IconData icon,
    required String label,
    required String value,
    bool warning = false,
    bool success = false,
    TextStyle? valueStyle,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      valueStyle ??
                      TextStyle(
                        color: warning
                            ? colorScheme.error
                            : success
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontFamily: 'Roboto',
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchConfigRow({
    required IconData icon,
    required String label,
    required String description,
    String? warningText,
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (warningText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    warningText,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.error.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required ConfigKey configKey, // 改为ConfigKey类型
    required IconData icon,
    String? helperText,
    bool allowEmpty = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            helperText: helperText,
            helperMaxLines: 3,
          ),
          validator: (value) {
            if (!allowEmpty && (value == null || value.isEmpty)) {
              return slang.t.translation.thisFieldCannotBeEmpty;
            }
            return null;
          },
          onChanged: (value) {
            configService[configKey] = value;
            if (configKey == ConfigKey.AI_TRANSLATION_BASE_URL ||
                configKey == ConfigKey.AI_TRANSLATION_MODEL ||
                configKey == ConfigKey.AI_TRANSLATION_API_KEY) {
              _disableAITranslation(
                message: slang
                    .t
                    .translation
                    .aiTranslationWillBeDisabledDueToConfigChange,
              );
              _isConnectionValid.value = false;
              _hasTested.value = false;
              _testResult.value = null;
            }
          },
        ),
      ],
    );
  }

  Widget _buildApiKeyInputSection(BuildContext context) {
    final RxBool obscureText = true.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.key,
              size: 20,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.apiKey,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: _apiKeyController,
            obscureText: obscureText.value,
            decoration: InputDecoration(
              hintText: 'sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText.value ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => obscureText.toggle(),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return slang.t.translation.apiKeyCannotBeEmpty;
              }
              return null;
            },
            onChanged: (value) {
              configService[ConfigKey.AI_TRANSLATION_API_KEY] = value;
              _disableAITranslation(
                message: slang
                    .t
                    .translation
                    .aiTranslationWillBeDisabledDueToConfigChange,
              );
              _isConnectionValid.value = false;
              _hasTested.value = false;
              _testResult.value = null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputSection({
    required BuildContext context,
    required String label,
    required ConfigKey configKey, // 改为ConfigKey类型
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required num defaultValue,
    bool isDouble = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isDouble
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return slang.t.translation.thisFieldCannotBeEmpty;
            }
            if (isDouble) {
              final numValue = double.tryParse(value);
              if (numValue == null) {
                return slang.t.translation.pleaseEnterValidNumber;
              }
              // if (numValue < 0 || numValue > 2) return '范围0.0-2.0';
              if (numValue < 0 || numValue > 2) {
                return '${slang.t.translation.range}${slang.t.translation.temperatureHintText}';
              }
            } else {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                return slang.t.translation.pleaseEnterValidNumber;
              }
              if (intValue <= 0) {
                return '${slang.t.translation.mustBeGreaterThan}0';
              }
            }
            return null;
          },
          onChanged: (value) {
            if (value.isEmpty) return;

            final parsedValue = isDouble
                ? double.tryParse(value) ?? defaultValue.toDouble()
                : int.tryParse(value) ?? defaultValue.toInt();

            final clampedValue = isDouble
                ? parsedValue.clamp(0.0, 2.0)
                : parsedValue < 1
                ? 1
                : parsedValue;

            configService[configKey] = clampedValue;

            if (configKey == ConfigKey.AI_TRANSLATION_MAX_TOKENS ||
                configKey == ConfigKey.AI_TRANSLATION_TEMPERATURE) {
              _disableAITranslation(
                message: slang
                    .t
                    .translation
                    .aiTranslationWillBeDisabledDueToParamChange,
              );
            }

            if (isDouble && value.endsWith('.') && !value.contains('..')) {
              return;
            }
            controller.value = controller.value.copyWith(
              text: isDouble
                  ? clampedValue.toStringAsFixed(1)
                  : clampedValue.toString(),
              selection: TextSelection.collapsed(
                offset: clampedValue.toString().length,
              ),
            );
          },
          inputFormatters: [
            if (isDouble)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
            if (!isDouble) FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }

  Widget _buildTemperatureSlider(BuildContext context) {
    final RxDouble temperatureValue = RxDouble(
      configService[ConfigKey.AI_TRANSLATION_TEMPERATURE]?.toDouble() ?? 0.3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.thermostat,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.temperature,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: [
              Slider(
                value: temperatureValue.value,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                label: temperatureValue.value.toStringAsFixed(1),
                onChanged: (value) {
                  temperatureValue.value = value;
                  configService[ConfigKey.AI_TRANSLATION_TEMPERATURE] = value;
                  _temperatureController.text = value.toStringAsFixed(1);
                  _disableAITranslation(
                    message: slang
                        .t
                        .translation
                        .aiTranslationWillBeDisabledDueToParamChange,
                  );
                },
              ),
              Text(
                '${slang.t.translation.currentValue}: ${temperatureValue.value.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatJson(String jsonString) {
    try {
      final parsed = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (e) {
      return jsonString;
    }
  }

  Widget _buildInfoCard({
    Color? color,
    required BuildContext context,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colorScheme.onSurface),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// 服务商预设：一键带出 provider + baseUrl + 推理/温度等参数组合。
class _ProviderPreset {
  final String id;
  final String name;
  final String provider; // openai / anthropic / google
  final String? baseUrl; // null = 用该服务商默认端点
  final bool reasoning;
  final bool sendTemperature;

  const _ProviderPreset({
    required this.id,
    required this.name,
    this.provider = 'openai',
    this.baseUrl,
    this.reasoning = false,
    this.sendTemperature = true,
  });
}

const List<_ProviderPreset> _providerPresets = [
  _ProviderPreset(id: 'custom', name: 'Custom'),
  _ProviderPreset(
    id: 'openai',
    name: 'OpenAI (GPT-4o / GPT-4.1)',
    provider: 'openai',
    baseUrl: 'https://api.openai.com/v1',
  ),
  _ProviderPreset(
    id: 'openai_reasoning',
    name: 'OpenAI 推理 (o1 / o3 / o4)',
    provider: 'openai',
    baseUrl: 'https://api.openai.com/v1',
    reasoning: true,
    sendTemperature: false,
  ),
  _ProviderPreset(
    id: 'anthropic',
    name: 'Anthropic Claude',
    provider: 'anthropic',
  ),
  _ProviderPreset(
    id: 'anthropic_reasoning',
    name: 'Anthropic Claude 推理 (extended thinking)',
    provider: 'anthropic',
    reasoning: true,
    sendTemperature: false,
  ),
  _ProviderPreset(
    id: 'gemini',
    name: 'Google Gemini (原生)',
    provider: 'google',
  ),
  _ProviderPreset(
    id: 'gemini_reasoning',
    name: 'Google Gemini 推理 (thinking)',
    provider: 'google',
    reasoning: true,
  ),
  _ProviderPreset(
    id: 'deepseek',
    name: 'DeepSeek (deepseek-chat)',
    provider: 'openai',
    baseUrl: 'https://api.deepseek.com',
  ),
  _ProviderPreset(
    id: 'deepseek_reasoner',
    name: 'DeepSeek 推理 (deepseek-reasoner / R1)',
    provider: 'openai',
    baseUrl: 'https://api.deepseek.com',
    reasoning: true,
    sendTemperature: false,
  ),
  _ProviderPreset(
    id: 'siliconflow',
    name: 'SiliconFlow 硅基流动',
    provider: 'openai',
    baseUrl: 'https://api.siliconflow.cn/v1',
  ),
  _ProviderPreset(
    id: 'zhipu',
    name: '智谱 GLM',
    provider: 'openai',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
  ),
];
