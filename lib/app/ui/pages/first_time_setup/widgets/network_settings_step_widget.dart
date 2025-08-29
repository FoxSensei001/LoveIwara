import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

class NetworkSettingsStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const NetworkSettingsStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<NetworkSettingsStepWidget> createState() => _NetworkSettingsStepWidgetState();
}

class _NetworkSettingsStepWidgetState extends State<NetworkSettingsStepWidget> {
  late ConfigService configService;
  
  // 本地状态
  late bool useProxy;
  late String proxyUrl;
  late TextEditingController proxyController;

  @override
  void initState() {
    super.initState();
    configService = Get.find<ConfigService>();
    _loadSettings();
  }

  @override
  void dispose() {
    proxyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    useProxy = configService[ConfigKey.USE_PROXY];
    proxyUrl = configService[ConfigKey.PROXY_URL];
    proxyController = TextEditingController(text: proxyUrl);
    
    // 监听代理URL变化
    proxyController.addListener(() {
      _updateProxyUrl(proxyController.text);
    });
  }

  Future<void> _updateUseProxy(bool value) async {
    setState(() {
      useProxy = value;
    });
    await configService.setSetting(ConfigKey.USE_PROXY, value);
  }

  Future<void> _updateProxyUrl(String value) async {
    setState(() {
      proxyUrl = value;
    });
    await configService.setSetting(ConfigKey.PROXY_URL, value);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isNarrow = screenWidth < 400;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isNarrow ? 16 : (isDesktop ? 48 : 24)),
      child: isDesktop 
          ? _buildDesktopLayout(context, theme) 
          : _buildMobileLayout(context, theme, isNarrow),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subtitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: useProxy && proxyUrl.isEmpty
                      ? theme.colorScheme.errorContainer
                      : theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      useProxy && proxyUrl.isEmpty ? Icons.warning : Icons.wifi,
                      color: useProxy && proxyUrl.isEmpty
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onSecondaryContainer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        useProxy && proxyUrl.isEmpty
                            ? '请填写代理服务器地址'
                            : '网络设置将影响应用连接稳定性',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: useProxy && proxyUrl.isEmpty
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Row(
                          children: [
                            Icon(
                              Icons.network_check,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text('使用代理服务器'),
                          ],
                        ),
                        subtitle: const Text('配置网络代理服务器以访问受限内容'),
                        value: useProxy,
                        onChanged: _updateUseProxy,
                        contentPadding: EdgeInsets.zero,
                      ),
                      useProxy ? Column(
                        children: [
                          const SizedBox(height: 20),
                          TextField(
                            controller: proxyController,
                            textAlignVertical: TextAlignVertical.top,
                            minLines: 1,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: '代理地址',
                              hintText: '例如: 127.0.0.1:8080 或 socks5://127.0.0.1:1080',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.link),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              constraints: const BoxConstraints(minHeight: 56),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '支持 HTTP、HTTPS、SOCKS5 代理格式',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeData theme, bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: isNarrow ? 16 : 24),
        Text(
          widget.subtitle,
          style: (isNarrow ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isNarrow ? 20 : 32),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isNarrow ? 16 : 20),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Row(
                        children: [
                          Icon(
                            Icons.network_check,
                            color: theme.colorScheme.primary,
                            size: isNarrow ? 20 : 24,
                          ),
                          SizedBox(width: isNarrow ? 8 : 12),
                          Text(
                            '使用代理服务器',
                            style: (isNarrow ? theme.textTheme.titleSmall : theme.textTheme.titleMedium),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '配置网络代理服务器以访问受限内容',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      value: useProxy,
                      onChanged: _updateUseProxy,
                      contentPadding: EdgeInsets.zero,
                      dense: isNarrow,
                    ),
                    useProxy ? Column(
                      children: [
                        SizedBox(height: isNarrow ? 12 : 16),
                        TextField(
                          controller: proxyController,
                          textAlignVertical: TextAlignVertical.top,
                          minLines: 1,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: '代理地址',
                            hintText: isNarrow ? '127.0.0.1:8080' : '例如: 127.0.0.1:8080 或 socks5://127.0.0.1:1080',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isNarrow ? 8 : 12),
                            ),
                            prefixIcon: const Icon(Icons.link),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 12 : 16,
                              vertical: 16,
                            ),
                            constraints: BoxConstraints(minHeight: isNarrow ? 48 : 56),
                          ),
                          style: isNarrow ? theme.textTheme.bodySmall : null,
                        ),
                        SizedBox(height: isNarrow ? 6 : 8),
                        Text(
                          '支持 HTTP、HTTPS、SOCKS5 代理格式',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ) : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isNarrow ? 16 : 20),
        Container(
          padding: EdgeInsets.all(isNarrow ? 12 : 16),
          decoration: BoxDecoration(
            color: useProxy && proxyUrl.isEmpty
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(isNarrow ? 12 : 16),
          ),
          child: Row(
            children: [
              Icon(
                useProxy && proxyUrl.isEmpty ? Icons.warning : Icons.wifi,
                color: useProxy && proxyUrl.isEmpty
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSecondaryContainer,
                size: isNarrow ? 16 : 20,
              ),
              SizedBox(width: isNarrow ? 8 : 12),
              Expanded(
                child: Text(
                  useProxy && proxyUrl.isEmpty
                      ? '请填写代理服务器地址'
                      : '网络设置将影响应用连接稳定性',
                  style: (isNarrow ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                    color: useProxy && proxyUrl.isEmpty
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
