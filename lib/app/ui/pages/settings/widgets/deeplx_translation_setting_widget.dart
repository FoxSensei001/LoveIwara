import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'dart:convert';

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
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Obx(() => _buildStatusCard(context)),
            const SizedBox(height: 16),
            _buildDisclaimerCard(context),
            const SizedBox(height: 16),
            _buildAPIConfigSection(context),
            const SizedBox(height: 16),
            _buildTestConnectionSection(context),
            const SizedBox(height: 16),
            _buildEnableSection(context),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ]),
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
                      'DeepLX 翻译',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? '已启用' : '未启用',
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
                    'DeepLX 翻译服务',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'DeepLX 是 DeepL 翻译的开源实现，支持 Free、Pro 和 Official 三种端点模式。',
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
                      'API 配置',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '修改配置将自动关闭 DeepLX 翻译，需要重新测试连接',
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
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(
                  context: context,
                  label: '服务器地址',
                  controller: _baseUrlController,
                  hintText: 'https://api.deeplx.org',
                  configKey: ConfigKey.DEEPLX_BASE_URL,
                  icon: Icons.link,
                  helperText: "DeepLX 服务器的基础地址",
                ),
                _buildEndpointTypeSelector(context),
                _buildApiKeyInputSection(context),
                Obx(() => _selectedEndpointType.value == 'Pro' 
                    ? _buildDlSessionInputSection(context)
                    : const SizedBox.shrink()),
              ],
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
              '端点类型',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
          value: _selectedEndpointType.value,
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
                description = 'Free - 免费端点，可能有频率限制';
                break;
              case 'Pro':
                description = 'Pro - 需要 dl_session，更稳定';
                break;
              case 'Official':
                description = 'Official - 官方 API 格式';
                break;
              default:
                description = type;
            }
            return DropdownMenuItem<String>(
              value: type,
              child: Text(description),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _selectedEndpointType.value = value;
              configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = value;
              _disableDeepLXTranslation(message: 'DeepLX翻译将因配置更改而被禁用');
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
            '最终请求URL:',
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
              return '请输入服务器地址';
            }
            return null;
          },
          onChanged: (value) {
            configService[configKey] = value;
            if (configKey == ConfigKey.DEEPLX_BASE_URL) {
              _disableDeepLXTranslation(message: 'DeepLX翻译将因配置更改而被禁用');
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
              'API Key (可选)',
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
            hintText: '用于访问受保护的 DeepLX 服务',
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
            helperText: '某些 DeepLX 服务需要 API Key 进行身份验证',
            helperMaxLines: 2,
          ),
          onChanged: (value) {
            configService[ConfigKey.DEEPLX_API_KEY] = value;
            _disableDeepLXTranslation(message: 'DeepLX翻译将因配置更改而被禁用');
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
              'DL Session',
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
            hintText: 'Pro 模式需要的 dl_session 参数',
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
            helperText: 'Pro 端点必需的会话参数，从 DeepL Pro 账户获取',
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (_selectedEndpointType.value == 'Pro' && (value == null || value.trim().isEmpty)) {
              return 'Pro 模式需要填写 dl_session';
            }
            return null;
          },
          onChanged: (value) {
            configService[ConfigKey.DEEPLX_DL_SESSION] = value;
            _disableDeepLXTranslation(message: 'DeepLX翻译将因配置更改而被禁用');
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
                    _isTesting.value ? '测试中...' : slang.t.translation.testConnection,
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
                  '点击测试按钮验证 DeepLX API 连接',
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
              '连接状态',
              isValid ? '成功' : '失败',
              isValid,
              successColor: colorScheme.onPrimaryContainer,
              errorColor: colorScheme.onErrorContainer,
            ),
            _buildStatusRow(
              '信息',
              _testResult.value!.custMessage,
              _testResult.value!.custMessage.isNotEmpty,
              successColor: colorScheme.onPrimaryContainer,
              errorColor: colorScheme.onErrorContainer,
            ),
            if (_testResult.value!.translatedText != null) ...[
              _buildStatusRow(
                '翻译结果',
                _testResult.value!.translatedText!,
                true,
                successColor: colorScheme.onPrimaryContainer,
                errorColor: colorScheme.onErrorContainer,
              ),
            ],
            if (_testResult.value!.rawResponse != null) ...[
              ExpansionTile(
                title: Text(
                  '查看原始响应',
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
        color: color ?? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
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
            '启用 DeepLX 翻译',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            _isDeepLXEnabled.value ? '已启用' : '已禁用',
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
