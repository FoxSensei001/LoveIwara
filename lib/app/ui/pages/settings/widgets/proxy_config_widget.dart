import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../../utils/proxy/http_proxy_address.dart';
import '../../../../../utils/proxy/proxy_util.dart';
import '../../../../../utils/proxy/system_proxy_settings.dart';
import '../../../../services/config_service.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'base_proxy_widget.dart';

class ProxyConfigWidget extends BaseProxyWidget {
  final ConfigService configService;
  final bool showTitle;
  final EdgeInsetsGeometry? padding;
  final bool compactMode;
  // 嵌入式显示：不包裹外层 Card，去掉多余的留白与投影，适合步骤向导等容器中使用
  final bool wrapWithCard;

  const ProxyConfigWidget({
    super.key,
    required this.configService,
    this.showTitle = true,
    this.padding = const EdgeInsets.all(16),
    this.compactMode = false,
    this.wrapWithCard = true,
  });

  @override
  BaseProxyWidgetState<ProxyConfigWidget> createState() =>
      _ProxyConfigWidgetState();
}

class _ProxyConfigWidgetState extends BaseProxyWidgetState<ProxyConfigWidget> {
  String? _systemProxyCandidate; // 检测到的系统代理（host:port）
  bool _systemProxyChecked = false; // 标记已检测，避免重复显示
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  bool _hostEditWasPaste = false;
  String? _hostError;
  String? _portError;

  @override
  String get proxyDraftAddress {
    final host = _hostController.text.trim();
    final port = _portController.text.trim();
    return host.isEmpty && port.isEmpty ? '' : '$host:$port';
  }

  void _fillEndpoint(String endpoint) {
    final separator = endpoint.lastIndexOf(':');
    final host = endpoint.substring(0, separator);
    _hostController.value = TextEditingValue(
      text: host,
      selection: TextSelection.collapsed(offset: host.length),
    );
    _portController.text = endpoint.substring(separator + 1);
  }

  String? _validateHost() {
    final copy = slang.Translations.of(context).settings.proxyEditor;
    final host = _hostController.text.trim();
    if (host.isEmpty) return copy.hostRequired;
    // Prefix HTTP ourselves so a URL, path or port in the host field cannot
    // accidentally be accepted as a bare hostname.
    if (normalizeHttpProxyAddress('http://$host:1') == null) {
      return copy.invalidHost;
    }
    return null;
  }

  String? _validatePort() {
    final copy = slang.Translations.of(context).settings.proxyEditor;
    final text = _portController.text.trim();
    if (text.isEmpty) return copy.portRequired;
    final port = int.tryParse(text);
    if (!RegExp(r'^[0-9]{1,5}$').hasMatch(text) ||
        port == null ||
        port < 1 ||
        port > 65535) {
      return copy.invalidPort;
    }
    return null;
  }

  bool _validateFields() {
    final hostError = _validateHost();
    final portError = _validatePort();
    setState(() {
      _hostError = hostError;
      _portError = portError;
    });
    return hostError == null && portError == null;
  }

  bool _needsRestart = false;
  bool _savedFeedback = false;

  bool get _hasDraftChanges {
    final draft = proxyDraftAddress;
    final saved = configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    final endpoint = _validateHost() == null && _validatePort() == null
        ? normalizeHttpProxyAddress(draft)
        : null;
    return (endpoint ?? draft) != saved;
  }

  bool get _isAddressSaved =>
      !_hasDraftChanges && _validateHost() == null && _validatePort() == null;

  bool _saveAddress() {
    if (!_validateFields()) return false;
    final endpoint = normalizeHttpProxyAddress(proxyDraftAddress)!;
    final changed = endpoint != configService[ConfigKey.PROXY_URL];
    configService[ConfigKey.PROXY_URL] = endpoint;
    _fillEndpoint(endpoint);
    setState(() {
      _savedFeedback = true;
      if (changed && isProxyEnabled.value) _needsRestart = true;
    });
    FocusScope.of(context).unfocus();
    return true;
  }

  void _toggleProxy(bool enabled) {
    if (enabled && !_saveAddress()) return;
    configService[ConfigKey.USE_PROXY] = enabled;
    setState(() {
      isProxyEnabled.value = enabled;
      _needsRestart = true;
    });
  }

  void _draftChanged() {
    setState(() {
      if (_hostError != null) _hostError = _validateHost();
      if (_portError != null) _portError = _validatePort();
      proxyCheckMessage = null;
      _savedFeedback = false;
    });
  }

  void _hostChanged(String value) {
    // Accept a copied URL as a convenience, then immediately show its two parts.
    final endpoint = _hostEditWasPaste
        ? normalizeHttpProxyAddress(value)
        : null;
    if (endpoint != null) _fillEndpoint(endpoint);
    _draftChanged();
  }

  void _useSystemProxy() {
    if (isChecking.value) return;
    final endpoint = _systemProxyCandidate;
    if (endpoint == null) return;
    _fillEndpoint(endpoint);
    _draftChanged();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final saved = configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    final endpoint = normalizeHttpProxyAddress(saved);
    if (endpoint != null) {
      _fillEndpoint(endpoint);
    } else {
      _hostController.text = saved;
    }

    // 组件初始化时尝试检测桌面端系统代理，仅在未启用代理且地址为空时提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool isDesktop = GetPlatform.isDesktop;
      final bool isEnabled = isProxyEnabled.value;
      final String url = proxyDraftAddress;
      if (isDesktop && !isEnabled && url.isEmpty && !_systemProxyChecked) {
        unawaited(_detectSystemProxyCandidate());
      }
    });
  }

  @override
  ConfigService get configService => widget.configService;

  Future<void> _detectSystemProxyCandidate() async {
    _systemProxyChecked = true;
    try {
      final ProxySettings settings = await ProxyUtil.getProxySettingsAsync();
      if (!mounted) {
        return;
      }
      if (settings.enabled && (settings.server?.trim().isNotEmpty ?? false)) {
        final String? candidate = preferredHttpProxyAddress(settings.server!);
        if (candidate != null && normalizeHttpProxyAddress(candidate) != null) {
          setState(() {
            _systemProxyCandidate = normalizeHttpProxyAddress(candidate);
          });
          LogUtils.i('检测到系统代理: $candidate', BaseProxyWidgetState.tag);
        }
      }
    } catch (e) {
      LogUtils.d('系统代理检测失败或不支持: $e', BaseProxyWidgetState.tag);
    }
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    String? error,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      errorText: error,
      errorMaxLines: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final copy = t.settings.proxyEditor;

    // Users enter the two actual values; URL composition stays in the app.
    // Labels also provide native accessibility names for each input.
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Text(
            t.settings.proxyConfig,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          copy.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final hostField = TextField(
              key: const ValueKey('proxy-host-input'),
              controller: _hostController,
              enabled: !isChecking.value,
              keyboardType: TextInputType.url,
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final selection = oldValue.selection;
                  final replacedLength =
                      selection.isValid && selection.end <= oldValue.text.length
                      ? selection.end - selection.start
                      : 0;
                  // Do not split a partially typed URL after its first port digit.
                  _hostEditWasPaste =
                      newValue.text.length -
                          oldValue.text.length +
                          replacedLength >
                      1;
                  return newValue;
                }),
              ],
              textInputAction: TextInputAction.next,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _hostChanged,
              decoration: _fieldDecoration(
                context,
                label: copy.hostLabel,
                hint: '127.0.0.1',
                icon: Icons.dns_outlined,
                error: _hostError,
              ),
            );
            final portField = TextField(
              key: const ValueKey('proxy-port-input'),
              controller: _portController,
              enabled: !isChecking.value,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onChanged: (_) => _draftChanged(),
              onSubmitted: (_) => _saveAddress(),
              decoration: _fieldDecoration(
                context,
                label: copy.portLabel,
                hint: '7890',
                icon: Icons.numbers_rounded,
                error: _portError,
              ),
            );
            // Long translated labels and larger text need their own full-width
            // rows. On wider screens the endpoint reads naturally left to right.
            if (constraints.maxWidth >= 480 &&
                MediaQuery.textScalerOf(context).scale(14) <= 18) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: hostField),
                  const SizedBox(width: 12),
                  Expanded(child: portField),
                ],
              );
            }
            return Column(
              children: [hostField, const SizedBox(height: 16), portField],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          copy.fieldsHelp,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        if (_systemProxyCandidate != null) ...[
          const SizedBox(height: 12),
          Text(
            t.proxyHelper.systemProxyDetected,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          TextButton.icon(
            onPressed: isChecking.value ? null : _useSystemProxy,
            icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
            label: Text(copy.useSystemProxy(address: _systemProxyCandidate!)),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: const ValueKey('proxy-save'),
              onPressed: isChecking.value || !_hasDraftChanges
                  ? null
                  : _saveAddress,
              icon: Icon(
                _isAddressSaved ? Icons.check_rounded : Icons.save_outlined,
                size: 18,
              ),
              label: Text(_isAddressSaved ? copy.saved : t.common.save),
            ),
            OutlinedButton.icon(
              onPressed: isChecking.value
                  ? null
                  : () {
                      if (_validateFields()) unawaited(checkProxy());
                    },
              icon: isChecking.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check_rounded, size: 18),
              label: Text(
                isChecking.value ? copy.testing : copy.testConnection,
              ),
            ),
          ],
        ),
        if (proxyCheckMessage != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              proxyCheckMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: proxyCheckSucceeded ? cs.primary : cs.error,
              ),
            ),
          ),
        ] else if (_savedFeedback) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              copy.saved,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.primary),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 4),
        Material(
          type: MaterialType.transparency,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(
              t.settings.enableProxy,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(isProxyEnabled.value ? copy.enabled : copy.disabled),
            value: isProxyEnabled.value,
            onChanged: isChecking.value ? null : _toggleProxy,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _needsRestart
                  ? Icons.restart_alt_rounded
                  : Icons.info_outline_rounded,
              size: 18,
              color: _needsRestart ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t.settings.needRestartToApply,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _needsRestart ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: widget.wrapWithCard
          ? GlassSettingSection(
              divided: false,
              children: [
                Padding(padding: const EdgeInsets.all(16), child: content),
              ],
            )
          : content,
    );
  }
}
