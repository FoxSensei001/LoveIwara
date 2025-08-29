import 'dart:io';
import 'package:i_iwara/utils/proxy/system_proxy_settings.dart';
import 'package:win32/win32.dart';

import '../platforms/microsoft_windows_registry_utils.dart';

ProxySettings getPlatformProxySettings() {
  if (Platform.isWindows) {
    return getWindowsProxySettings();
  }
  if (Platform.isMacOS) {
    return getMacProxySettings();
  }
  if (Platform.isLinux) {
    return getLinuxProxySettings();
  }
  return ProxySettings(enabled: false);
}

ProxySettings getWindowsProxySettings() {
  final hKey = RegistryUtil.openKey(HKEY_CURRENT_USER, internetSettingsKey);

  try {
    final proxyEnable = RegistryUtil.queryValue(hKey, 'ProxyEnable') as int?;
    final proxyServer = RegistryUtil.queryValue(hKey, 'ProxyServer') as String?;
    final autoConfigUrl =
        RegistryUtil.queryValue(hKey, 'AutoConfigURL') as String?;
    final proxyOverride =
        RegistryUtil.queryValue(hKey, 'ProxyOverride') as String?;

    return ProxySettings(
      enabled: proxyEnable == 1,
      server: proxyServer,
      autoConfigUrl: autoConfigUrl,
      proxyOverride: proxyOverride,
    );
  } finally {
    RegistryUtil.closeKey(hKey);
  }
}

ProxySettings getMacProxySettings() {
  // 首选通过 scutil --proxy 获取系统代理
  try {
    final result = Process.runSync('scutil', ['--proxy']);
    if (result.exitCode == 0) {
      final String stdoutStr = result.stdout?.toString() ?? '';
      final Map<String, String> map = _parseKeyValue(stdoutStr);
      final bool httpEnabled = map['HTTPEnable'] == '1';
      final bool httpsEnabled = map['HTTPSEnable'] == '1';
      final String? httpHost = map['HTTPProxy'];
      final String? httpPort = map['HTTPPort'];
      final String? httpsHost = map['HTTPSProxy'];
      final String? httpsPort = map['HTTPSPort'];
      final String? pacUrl = map['ProxyAutoConfigURLString'];
      final String? exceptions = map['ExceptionsList'];

      String? server;
      if (httpEnabled && (httpHost?.isNotEmpty ?? false) && (httpPort?.isNotEmpty ?? false)) {
        server = '$httpHost:$httpPort';
      } else if (httpsEnabled && (httpsHost?.isNotEmpty ?? false) && (httpsPort?.isNotEmpty ?? false)) {
        server = '$httpsHost:$httpsPort';
      }

      return ProxySettings(
        enabled: (httpEnabled || httpsEnabled) || (pacUrl?.isNotEmpty ?? false),
        server: server,
        autoConfigUrl: pacUrl,
        proxyOverride: exceptions,
      );
    }
  } catch (_) {}

  // 退化到环境变量读取
  return _getProxyFromEnv();
}

ProxySettings getLinuxProxySettings() {
  // 优先读取环境变量
  final envSettings = _getProxyFromEnv();
  if (envSettings.enabled && (envSettings.server?.isNotEmpty ?? false)) {
    return envSettings;
  }

  // 尝试从 GNOME 设置读取
  try {
    final modeRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy', 'mode']);
    if (modeRes.exitCode == 0) {
      final mode = (modeRes.stdout?.toString() ?? '').trim().replaceAll("'", '');
      if (mode == 'manual') {
        final hostRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy.http', 'host']);
        final portRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy.http', 'port']);
        final httpsHostRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy.https', 'host']);
        final httpsPortRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy.https', 'port']);
        final ignoreRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy', 'ignore-hosts']);
        String? httpHost = (hostRes.stdout?.toString() ?? '').trim().replaceAll("'", '');
        String? httpPort = (portRes.stdout?.toString() ?? '').trim();
        String? httpsHost = (httpsHostRes.stdout?.toString() ?? '').trim().replaceAll("'", '');
        String? httpsPort = (httpsPortRes.stdout?.toString() ?? '').trim();
        String? ignore = (ignoreRes.stdout?.toString() ?? '').trim();

        String? server;
        if (httpHost.isNotEmpty && httpPort.isNotEmpty && httpPort != '0') {
          server = '$httpHost:$httpPort';
        } else if (httpsHost.isNotEmpty && httpsPort.isNotEmpty && httpsPort != '0') {
          server = '$httpsHost:$httpsPort';
        }

        return ProxySettings(
          enabled: server != null,
          server: server,
          autoConfigUrl: null,
          proxyOverride: ignore,
        );
      } else if (mode == 'auto') {
        final pacRes = Process.runSync('gsettings', ['get', 'org.gnome.system.proxy', 'autoconfig-url']);
        final pac = (pacRes.stdout?.toString() ?? '').trim().replaceAll("'", '');
        return ProxySettings(
          enabled: pac.isNotEmpty,
          server: null,
          autoConfigUrl: pac.isNotEmpty ? pac : null,
          proxyOverride: null,
        );
      }
    }
  } catch (_) {}

  return ProxySettings(enabled: false);
}

ProxySettings _getProxyFromEnv() {
  final String? httpProxy = _firstNonEmpty([
    Platform.environment['http_proxy'],
    Platform.environment['HTTP_PROXY'],
  ]);
  final String? httpsProxy = _firstNonEmpty([
    Platform.environment['https_proxy'],
    Platform.environment['HTTPS_PROXY'],
  ]);
  final String? allProxy = _firstNonEmpty([
    Platform.environment['all_proxy'],
    Platform.environment['ALL_PROXY'],
  ]);
  final String? noProxy = _firstNonEmpty([
    Platform.environment['no_proxy'],
    Platform.environment['NO_PROXY'],
  ]);

  String? pickUrl = httpProxy ?? httpsProxy ?? allProxy;
  String? hostPort;
  if (pickUrl != null && pickUrl.isNotEmpty) {
    try {
      final uri = Uri.parse(pickUrl);
      if (uri.hasAuthority) {
        hostPort = uri.port > 0 ? '${uri.host}:${uri.port}' : uri.host;
      } else {
        // 可能是 host:port 形式
        hostPort = pickUrl.replaceFirst(RegExp(r'^https?://'), '').trim();
      }
    } catch (_) {
      hostPort = pickUrl;
    }
  }

  return ProxySettings(
    enabled: (hostPort?.isNotEmpty ?? false),
    server: hostPort,
    autoConfigUrl: null,
    proxyOverride: noProxy,
  );
}

Map<String, String> _parseKeyValue(String text) {
  final Map<String, String> map = {};
  for (final line in text.split('\n')) {
    final idx = line.indexOf(':');
    if (idx > -1) {
      final key = line.substring(0, idx).trim();
      final value = line.substring(idx + 1).trim();
      map[key] = value;
    }
  }
  return map;
}

String? _firstNonEmpty(List<String?> items) {
  for (final s in items) {
    if (s != null && s.trim().isNotEmpty) return s.trim();
  }
  return null;
}
