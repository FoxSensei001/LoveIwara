import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'dart:convert';
import 'package:waterfall_flow/waterfall_flow.dart';

class DeepLXTranslationSettingsWidget extends StatefulWidget {
  const DeepLXTranslationSettingsWidget({super.key});

  @override
  State<DeepLXTranslationSettingsWidget> createState() =>
      _DeepLXTranslationSettingsWidgetState();
}

class _DeepLXTranslationSettingsWidgetState
    extends State<DeepLXTranslationSettingsWidget> {
  final ConfigService configService = Get.find();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _dlSessionController = TextEditingController();
  final RxBool _isDeepLXEnabled = false.obs;
  final RxBool _isTesting = false.obs;
  final RxBool _isConnectionValid = false.obs;
  final RxBool _hasTested = false.obs;
  final TranslationService translationService = Get.find();
  final Rx<AITestResult?> _testResult = Rx<AITestResult?>(null);
  final GlobalKey<FormState> _formKey = GlobalKey();
  final RxString _selectedEndpointType = 'Free'.obs;

  // 端点类型选项
  final List<String> _endpointTypes = ['Free', 'Pro', 'Official'];

  @override
  void initState() {
    super.initState();
    _baseUrlController.text = configService[ConfigKey.DEEPLX_BASE_URL];
    _apiKeyController.text = configService[ConfigKey.DEEPLX_API_KEY];
    _dlSessionController.text = configService[ConfigKey.DEEPLX_DL_SESSION];

    // 确保端点类型值在有效选项中
    final endpointType = configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] as String;
    if (_endpointTypes.contains(endpointType)) {
      _selectedEndpointType.value = endpointType;
    } else {
      _selectedEndpointType.value = 'Free';
      configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = 'Free';
    }

    _isConnectionValid.value = false;
    _hasTested.value = false;
    _testResult.value = null;
    _isDeepLXEnabled.value =
        configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool? ?? false;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _dlSessionController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    _isTesting.value = true;

    final result = await translationService.testDeepLXTranslation(
      _baseUrlController.text.trim(),
      _selectedEndpointType.value,
      _apiKeyController.text.trim(),
      _dlSessionController.text.trim(),
    );
    _testResult.value = result.data;
    _isConnectionValid.value = result.data?.connectionValid ?? false;
    _hasTested.value = true;

    // 如果连接测试成功，更新配置
    if (_isConnectionValid.value) {
      configService[ConfigKey.DEEPLX_BASE_URL] = _baseUrlController.text.trim();
      configService[ConfigKey.DEEPLX_API_KEY] = _apiKeyController.text.trim();
      configService[ConfigKey.DEEPLX_DL_SESSION] = _dlSessionController.text.trim();
      configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = _selectedEndpointType.value;
    }

    _isTesting.value = false;
  }

  void _handleSwitchChange(bool value) {
    if (value) {
      if (_formKey.currentState?.validate() != true) {
        return;
      }
      if (!_isConnectionValid.value) {
        _showValidationDialog();
        return;
      }
      if (!_hasTested.value) {
        return;
      }
    }
    _isDeepLXEnabled.value = value;
    configService[ConfigKey.USE_DEEPLX_TRANSLATION] = value;
  }

  void _showValidationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(slang.t.translation.needVerification),
        content: Text(slang.t.translation.needVerificationContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(slang.t.translation.confirm),
          ),
        ],
      ),
    );
  }

  void _disableDeepLXTranslation({String? message}) {
    _isDeepLXEnabled.value = false;
    configService[ConfigKey.USE_DEEPLX_TRANSLATION] = false;
    if (message != null) {
      LogUtils.i(message, 'DeepLXTranslationSettings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.crossAxisExtent;
            final bool isWide = width >= 1000;
            final int crossCount = isWide ? 2 : 1;

            final List<Widget> cards = [
              Obx(() => _buildStatusCard(context)),
              _buildDisclaimerCard(context),
              _buildAPIConfigSection(context),
              _buildTestConnectionSection(context),
              _buildEnableSection(context),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isEnabled = _isDeepLXEnabled.value;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled ? [
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ] : [
              Colors.grey.withOpacity(0.1),
              Colors.grey.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/deepl.svg',
                width: 24,
                height: 24,
                colorFilter: isEnabled
                    ? null
                    : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slang.t.translation.deeplxTranslation,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? slang.t.translation.enabled : slang.t.translation.disabled,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isEnabled ? Colors.blue : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isEnabled ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isEnabled ? Colors.blue : Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    slang.t.translation.deeplxTranslationService,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                slang.t.translation.deeplxDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAPIConfigSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_applications,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      slang.t.translation.apiConfig,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  slang.t.translation.deepLXTranslationWillBeDisabled,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
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
                            label: slang.t.translation.serverAddress,
                            controller: _baseUrlController,
                            hintText: slang.t.translation.serverAddressHint,
                            configKey: ConfigKey.DEEPLX_BASE_URL,
                            icon: Icons.link,
                            helperText: slang.t.translation.serverAddressHelperText,
                          ),
                        ),
                        SizedBox(width: itemWidth, child: _buildEndpointTypeSelector(context)),
                        SizedBox(width: itemWidth, child: _buildApiKeyInputSection(context)),
                        Obx(() => _selectedEndpointType.value == 'Pro'
                            ? SizedBox(width: itemWidth, child: _buildDlSessionInputSection(context))
                            : const SizedBox.shrink()),
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

  Widget _buildEndpointTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.api,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.endpointType,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: _selectedEndpointType.value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _endpointTypes.map((type) {
            String description;
            switch (type) {
              case 'Free':
                description = slang.t.translation.freeEndpoint;
                break;
              case 'Pro':
                description = slang.t.translation.proEndpoint;
                break;
              case 'Official':
                description = slang.t.translation.officialEndpoint;
                break;
              default:
                description = type;
            }
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                description,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _selectedEndpointType.value = value;
              configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = value;
              _disableDeepLXTranslation(message: slang.t.translation.deepLXTranslationWillBeDisabled);
              _isConnectionValid.value = false;
              _hasTested.value = false;
              _testResult.value = null;
            }
          },
        )),
        const SizedBox(height: 8),
        Obx(() => _buildFinalUrlDisplay(context)),
      ],
    );
  }

  Widget _buildFinalUrlDisplay(BuildContext context) {
    final baseUrl = _baseUrlController.text.trim();
    if (baseUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // 构建最终URL
    String endpoint;
    switch (_selectedEndpointType.value) {
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

    final finalUrl = baseUrl.endsWith('/') ? '$baseUrl${endpoint.substring(1)}' : '$baseUrl$endpoint';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${slang.t.translation.finalRequestUrl}:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            finalUrl,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required ConfigKey configKey,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            helperText: helperText,
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (configKey == ConfigKey.DEEPLX_BASE_URL && (value == null || value.trim().isEmpty)) {
              return slang.t.translation.serverAddress.isEmpty ? slang.t.translation.thisFieldCannotBeEmpty : slang.t.translation.serverAddress;
            }
            return null;
          },
          onChanged: (value) {
            configService[configKey] = value;
            if (configKey == ConfigKey.DEEPLX_BASE_URL) {
              _disableDeepLXTranslation(message: slang.t.translation.deepLXTranslationWillBeDisabled);
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
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.apiKeyOptional,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
          controller: _apiKeyController,
          obscureText: obscureText.value,
          decoration: InputDecoration(
            hintText: slang.t.translation.apiKeyOptionalHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () => obscureText.value = !obscureText.value,
            ),
            helperText: slang.t.translation.apiKeyOptionalHelperText,
            helperMaxLines: 2,
          ),
                      onChanged: (value) {
              configService[ConfigKey.DEEPLX_API_KEY] = value;
              _disableDeepLXTranslation(message: slang.t.translation.deepLXTranslationWillBeDisabled);
              _isConnectionValid.value = false;
              _hasTested.value = false;
              _testResult.value = null;
            },
        )),
      ],
    );
  }

  Widget _buildDlSessionInputSection(BuildContext context) {
    final RxBool obscureText = true.obs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.vpn_key,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              slang.t.translation.dlSession,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => TextFormField(
          controller: _dlSessionController,
          obscureText: obscureText.value,
          decoration: InputDecoration(
            hintText: slang.t.translation.dlSessionHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () => obscureText.value = !obscureText.value,
            ),
            helperText: slang.t.translation.dlSessionHelperText,
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (_selectedEndpointType.value == 'Pro' && (value == null || value.trim().isEmpty)) {
              return slang.t.translation.proModeRequiresDlSession;
            }
            return null;
          },
                      onChanged: (value) {
              configService[ConfigKey.DEEPLX_DL_SESSION] = value;
              _disableDeepLXTranslation(message: slang.t.translation.deepLXTranslationWillBeDisabled);
              _isConnectionValid.value = false;
              _hasTested.value = false;
              _testResult.value = null;
            },
        )),
      ],
    );
  }

  Widget _buildTestConnectionSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_protected_setup,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  slang.t.translation.testConnection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => ElevatedButton.icon(
                  onPressed: _isTesting.value ? null : _testConnection,
                  icon: _isTesting.value
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 16),
                  label: Text(
                    _isTesting.value ? slang.t.translation.testing : slang.t.translation.testConnection,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 32),
                  ),
                )),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (_testResult.value == null) {
              return _buildInfoCard(
                context: context,
                child: Text(
                  slang.t.translation.clickTestButtonToVerifyDeepLXAPI,
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
              isValid ? slang.t.translation.success : slang.t.translation.failed,
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
            if (_testResult.value!.translatedText != null) ...[
              _buildStatusRow(
                slang.t.translation.translatedResult,
                _testResult.value!.translatedText!,
                true,
                successColor: colorScheme.onPrimaryContainer,
                errorColor: colorScheme.onErrorContainer,
              ),
            ],
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

  Widget _buildStatusRow(String label, String value, bool isSuccess, {
    required Color successColor,
    required Color errorColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          size: 16,
          color: isSuccess ? successColor : errorColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSuccess ? successColor : errorColor,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required Widget child,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      child: child,
    );
  }

  String _formatJson(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonData);
    } catch (e) {
      return jsonString;
    }
  }

  Widget _buildEnableSection(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Obx(
        () => SwitchListTile(
          title: Text(
            slang.t.translation.enableDeepLXTranslation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            _isDeepLXEnabled.value ? slang.t.translation.enabled : slang.t.translation.disabled,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          value: _isDeepLXEnabled.value,
          onChanged: _handleSwitchChange,
          secondary: Icon(
            Icons.translate,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
