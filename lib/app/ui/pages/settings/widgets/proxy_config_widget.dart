import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../utils/logger_utils.dart';
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
  BaseProxyWidgetState<ProxyConfigWidget> createState() => _ProxyConfigWidgetState();
}

class _ProxyConfigWidgetState extends BaseProxyWidgetState<ProxyConfigWidget> {
  String? _systemProxyCandidate; // 检测到的系统代理（host:port）
  bool _systemProxyChecked = false; // 标记已检测，避免重复显示

  @override
  void initState() {
    super.initState();

    // 组件初始化时尝试检测桌面端系统代理，仅在未启用代理且地址为空时提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isDesktop = GetPlatform.isDesktop;
      final bool isEnabled = isProxyEnabled.value;
      final String url = proxyController.text.trim();
      if (isDesktop && !isEnabled && url.isEmpty && !_systemProxyChecked) {
        _detectSystemProxyCandidate();
      }
    });
  }

  @override
  ConfigService get configService => widget.configService;

  void _detectSystemProxyCandidate() {
    _systemProxyChecked = true;
    try {
      final ProxySettings settings = ProxyUtil.getProxySettings();
      if (settings.enabled && (settings.server?.trim().isNotEmpty ?? false)) {
        final String? candidate = _extractPreferredProxy(settings.server!);
        if (candidate != null && candidate.isNotEmpty) {
          setState(() {
            _systemProxyCandidate = candidate;
          });
          LogUtils.i('检测到系统代理: $candidate', BaseProxyWidgetState.tag);
        }
      }
    } catch (e) {
      LogUtils.d('系统代理检测失败或不支持: $e', BaseProxyWidgetState.tag);
    }
  }

  String? _extractPreferredProxy(String rawServer) {
    final String trimmed = rawServer.trim();
    if (trimmed.isEmpty) return null;
    if (!trimmed.contains('=') && !trimmed.contains(';')) {
      return trimmed;
    }
    final parts = trimmed.split(';');
    String? httpPair = parts.firstWhere(
      (p) => p.toLowerCase().startsWith('http='),
      orElse: () => '',
    );
    if (httpPair.isNotEmpty) {
      final idx = httpPair.indexOf('=');
      if (idx > -1 && idx + 1 < httpPair.length) {
        return httpPair.substring(idx + 1).trim();
      }
    }
    for (final p in parts) {
      final idx = p.indexOf('=');
      final value = idx > -1 ? p.substring(idx + 1).trim() : p.trim();
      if (value.contains(':')) {
        return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          Text(
            t.settings.proxyConfig,
            style: TextStyle(
              fontSize: widget.compactMode ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_systemProxyCandidate != null) ...[
              Card(
                color: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.proxyHelper.systemProxyDetected,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _systemProxyCandidate!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          final text = _systemProxyCandidate ?? '';
                          if (text.isEmpty) return;
                          await Clipboard.setData(ClipboardData(text: text));
                          showToastWidget(
                            MDToastWidget(
                              message: t.proxyHelper.copied,
                              type: MDToastType.success,
                            ),
                            position: ToastPosition.top,
                          );
                        },
                        icon: Icon(Icons.copy, color: theme.colorScheme.onSecondaryContainer),
                        label: Text(t.proxyHelper.copy, style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (!widget.compactMode) ...[
              Card(
                color: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.settings.thisIsHttpProxyAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SettingItem(
              label: t.settings.proxyAddress,
              labelSuffix: buildProxyAddressInput(context),
              initialValue: proxyController.text,
              validator: (value) {
                if (value.isEmpty) {
                  return t.settings.proxyAddressCannotBeEmpty;
                }
                if (!isValidProxyAddress(value)) {
                  return t.settings
                      .invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort;
                }
                return null;
              },
              onValid: (value) {
                configService[ConfigKey.PROXY_URL] = value;
                LogUtils.d('保存代理地址: $value', BaseProxyWidgetState.tag);
                if (isProxyEnabled.value) {
                  setFlutterEngineProxy(value.trim());
                }
              },
              icon:
                  Icon(Icons.computer, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
              splitTwoLine: true,
              inputDecoration: InputDecoration(
                hintText: t.settings
                    .pleaseEnterTheUrlOfTheProxyServerForExample1270018080,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.compactMode
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.settings.enableProxy,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Obx(() => Switch(
                        value: isProxyEnabled.value,
                        onChanged: (value) {
                          LogUtils.d(
                              '启用代理: $value, 代理地址: ${configService[ConfigKey.PROXY_URL]}',
                              BaseProxyWidgetState.tag);
                          isProxyEnabled.value = value;
                          configService[ConfigKey.USE_PROXY] = value;
                          if (value) {
                            setFlutterEngineProxy(proxyController.text.trim());
                            LogUtils.i('代理已启用', BaseProxyWidgetState.tag);
                          } else {
                            setFlutterEngineProxy(proxyController.text.trim());
                            LogUtils.i(
                              '代理已禁用（重启后生效）',
                              BaseProxyWidgetState.tag,
                            );
                          }
                        },
                        activeThumbColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );

    final body = widget.wrapWithCard
        ? Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          )
        : content;

    return SingleChildScrollView(
      padding: widget.padding,
      child: body,
    );
  }
}
