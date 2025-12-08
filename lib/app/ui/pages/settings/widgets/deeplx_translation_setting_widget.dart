import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/translation_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'dart:convert';
import 'package:waterfall_flow/waterfall_flow.dart';

class DeepLXTranslationSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const DeepLXTranslationSettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DeepLXTranslationSettingsWidget(isWideScreen: isWideScreen),
    );
  }
}

class DeepLXTranslationSettingsWidget extends StatefulWidget {
  final bool isWideScreen;

  const DeepLXTranslationSettingsWidget({super.key, this.isWideScreen = false});

  @override
  State<DeepLXTranslationSettingsWidget> createState() =>
      _DeepLXTranslationSettingsWidgetState();
}

class _DeepLXTranslationSettingsWidgetState
    extends State<DeepLXTranslationSettingsWidget> {
  // Services
  final ConfigService configService = Get.find();
  final TranslationService translationService = Get.find();

  // Controllers
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _dlSessionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  // State variables (instead of .obs)
  bool _isDeepLXEnabled = false;
  bool _isTesting = false;
  bool _isConnectionValid = false;
  bool _hasTested = false;
  AITestResult? _testResult;
  String _selectedEndpointType = 'Free';
  bool _obscureApiKey = true;
  bool _obscureDlSession = true;

  // Constants
  final List<String> _endpointTypes = ['Free', 'Pro', 'Official'];

  @override
  void initState() {
    super.initState();
    // Initialize state from ConfigService
    _baseUrlController.text = configService[ConfigKey.DEEPLX_BASE_URL];
    _apiKeyController.text = configService[ConfigKey.DEEPLX_API_KEY];
    _dlSessionController.text = configService[ConfigKey.DEEPLX_DL_SESSION];
    _isDeepLXEnabled =
        configService[ConfigKey.USE_DEEPLX_TRANSLATION] as bool? ?? false;

    final endpointType =
        configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] as String;
    if (_endpointTypes.contains(endpointType)) {
      _selectedEndpointType = endpointType;
    } else {
      _selectedEndpointType = 'Free'; // Default value
      configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = 'Free';
    }
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _dlSessionController.dispose();
    super.dispose();
  }

  // Resets connection status when settings change
  void _onSettingsChanged() {
    setState(() {
      _isConnectionValid = false;
      _hasTested = false;
      _testResult = null;
      _disableDeepLXTranslation(
        message: slang.t.translation.deepLXTranslationWillBeDisabled,
      );
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
    });

    final result = await translationService.testDeepLXTranslation(
      _baseUrlController.text.trim(),
      _selectedEndpointType,
      _apiKeyController.text.trim(),
      _dlSessionController.text.trim(),
    );

    // Update state based on test result
    setState(() {
      _testResult = result.data;
      _isConnectionValid = result.data?.connectionValid ?? false;
      _hasTested = true;
      _isTesting = false;
    });

    // If connection test is successful, save the configuration
    if (_isConnectionValid) {
      configService[ConfigKey.DEEPLX_BASE_URL] = _baseUrlController.text.trim();
      configService[ConfigKey.DEEPLX_API_KEY] = _apiKeyController.text.trim();
      configService[ConfigKey.DEEPLX_DL_SESSION] = _dlSessionController.text
          .trim();
      configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = _selectedEndpointType;
    }
  }

  void _handleSwitchChange(bool value) {
    if (value) {
      // Prevent enabling if form is invalid or connection hasn't been tested successfully
      if (_formKey.currentState?.validate() != true) return;
      if (!_isConnectionValid) {
        _showValidationDialog();
        return;
      }
      if (!_hasTested) return;
    }

    setState(() {
      _isDeepLXEnabled = value;
    });
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
    setState(() {
      _isDeepLXEnabled = false;
    });
    configService[ConfigKey.USE_DEEPLX_TRANSLATION] = false;
    if (message != null) {
      LogUtils.i(message, 'DeepLXTranslationSettings');
    }
  }

  // The main build method remains largely the same, but without Obx wrappers
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.translation.deeplxTranslation,
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
                  _buildStatusCard(context),
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
        ],
      ),
    );
  }

  // Helper build methods are now standard methods, not wrapped in Obx
  // They directly use state variables like _isDeepLXEnabled instead of _isDeepLXEnabled.value

  Widget _buildStatusCard(BuildContext context) {
    final isEnabled = _isDeepLXEnabled; // Direct access

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isEnabled
                ? [
                    Colors.blue.withAlpha(25), // Simplified withAlpha
                    Colors.blue.withAlpha(12),
                  ]
                : [Colors.grey.withAlpha(25), Colors.grey.withAlpha(12)],
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
                    : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
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
                      isEnabled
                          ? slang.t.translation.enabled
                          : slang.t.translation.disabled,
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
    // This widget had no reactive elements, so it remains the same.
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
              Theme.of(context).colorScheme.secondaryContainer.withAlpha(77),
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
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(77),
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
                            helperText:
                                slang.t.translation.serverAddressHelperText,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildEndpointTypeSelector(context),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildApiKeyInputSection(context),
                        ),
                        // Conditionally show DlSession input without Obx
                        if (_selectedEndpointType == 'Pro')
                          SizedBox(
                            width: itemWidth,
                            child: _buildDlSessionInputSection(context),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedEndpointType,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
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
              // Use setState to rebuild UI and trigger other logic
              setState(() {
                _selectedEndpointType = value;
                configService[ConfigKey.DEEPLX_ENDPOINT_TYPE] = value;
                _onSettingsChanged(); // Reset status
              });
            }
          },
        ),
        const SizedBox(height: 8),
        // Conditional URL display without Obx
        () {
          final baseUrl = _baseUrlController.text.trim();
          if (baseUrl.isEmpty) {
            return const SizedBox.shrink();
          }
          String endpoint;
          switch (_selectedEndpointType) {
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
          final finalUrl = baseUrl.endsWith('/')
              ? '$baseUrl${endpoint.substring(1)}'
              : '$baseUrl$endpoint';

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainer.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(77),
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
        }(),
      ],
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            helperText: helperText,
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (configKey == ConfigKey.DEEPLX_BASE_URL &&
                (value == null || value.trim().isEmpty)) {
              return slang.t.translation.serverAddress.isEmpty
                  ? slang.t.translation.thisFieldCannotBeEmpty
                  : slang.t.translation.serverAddress;
            }
            return null;
          },
          onChanged: (value) {
            configService[configKey] = value;
            if (configKey == ConfigKey.DEEPLX_BASE_URL) {
              _onSettingsChanged(); // Reset status
            }
          },
        ),
      ],
    );
  }

  Widget _buildApiKeyInputSection(BuildContext context) {
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          decoration: InputDecoration(
            hintText: slang.t.translation.apiKeyOptionalHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
            ),
            helperText: slang.t.translation.apiKeyOptionalHelperText,
            helperMaxLines: 2,
          ),
          onChanged: (value) {
            configService[ConfigKey.DEEPLX_API_KEY] = value;
            _onSettingsChanged();
          },
        ),
      ],
    );
  }

  Widget _buildDlSessionInputSection(BuildContext context) {
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dlSessionController,
          obscureText: _obscureDlSession,
          decoration: InputDecoration(
            hintText: slang.t.translation.dlSessionHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureDlSession ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureDlSession = !_obscureDlSession),
            ),
            helperText: slang.t.translation.dlSessionHelperText,
            helperMaxLines: 2,
          ),
          validator: (value) {
            if (_selectedEndpointType == 'Pro' &&
                (value == null || value.trim().isEmpty)) {
              return slang.t.translation.proModeRequiresDlSession;
            }
            return null;
          },
          onChanged: (value) {
            configService[ConfigKey.DEEPLX_DL_SESSION] = value;
            _onSettingsChanged();
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
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(77),
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
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _testConnection,
                  icon: _isTesting
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
                    _isTesting
                        ? slang.t.translation.testing
                        : slang.t.translation.testConnection,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Logic for displaying test results without Obx
          if (_testResult == null)
            _buildInfoCard(
              context: context,
              child: Text(
                slang.t.translation.clickTestButtonToVerifyDeepLXAPI,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            _buildTestResultContent(context),
        ],
      ),
    );
  }

  // The rest of the build helpers follow the same pattern:
  // no Obx, direct state variable access, and using setState in callbacks.

  Widget _buildTestResultContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isValid = _testResult!.connectionValid;
    return _buildInfoCard(
      color: isValid
          ? colorScheme.primaryContainer
          : colorScheme.errorContainer,
      context: context,
      child: Column(
        children: [
          _buildStatusRow(
            slang.t.translation.connectionStatus,
            isValid ? slang.t.translation.success : slang.t.translation.failed,
            isValid,
            successColor: colorScheme.onPrimaryContainer,
            errorColor: colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 16),
          _buildStatusRow(
            slang.t.translation.information,
            _testResult!.custMessage,
            _testResult!.custMessage.isNotEmpty,
            successColor: colorScheme.onPrimaryContainer,
            errorColor: colorScheme.onErrorContainer,
          ),
          if (_testResult!.translatedText != null) ...[
            const SizedBox(height: 16),
            _buildStatusRow(
              slang.t.translation.translatedResult,
              _testResult!.translatedText!,
              true,
              successColor: colorScheme.onPrimaryContainer,
              errorColor: colorScheme.onErrorContainer,
            ),
          ],
          if (_testResult!.rawResponse != null) ...[
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
                      _formatJson(_testResult!.rawResponse!),
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
  }

  Widget _buildStatusRow(
    String label,
    String value,
    bool isSuccess, {
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
        color:
            color ??
            Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
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
      child: SwitchListTile(
        title: Text(
          slang.t.translation.enableDeepLXTranslation,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          _isDeepLXEnabled
              ? slang.t.translation.enabled
              : slang.t.translation.disabled,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: _isDeepLXEnabled,
        onChanged: _handleSwitchChange,
        secondary: Icon(
          Icons.translate,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
