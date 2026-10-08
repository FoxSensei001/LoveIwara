import 'package:dio/dio.dart';
import 'package:i_iwara/utils/proxy/system_proxy_settings.dart';

Dio createPlatformProxyTestClient(String address) {
  throw UnsupportedError('Proxy testing is not supported on this platform');
}

ProxySettings getPlatformProxySettings() {
  throw UnsupportedError('啊哦～这个平台不支持代理设置');
}

Future<ProxySettings> getPlatformProxySettingsAsync() async {
  return getPlatformProxySettings();
}
