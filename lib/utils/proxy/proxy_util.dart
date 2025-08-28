import 'package:i_iwara/utils/proxy/system_proxy_settings.dart';

import 'proxy_util_stub.dart'
    if (dart.library.io) 'proxy_util_io.dart';

/// 代理设置获取工具类
class ProxyUtil {
  /// 获取当前用户的代理设置
  static ProxySettings getProxySettings() {
    return getPlatformProxySettings();
  }

  static bool isSupportedPlatform() {
    return true;
  }
}
