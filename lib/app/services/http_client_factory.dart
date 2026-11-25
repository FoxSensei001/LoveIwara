import 'dart:io';

import '../../utils/logger_utils.dart';
import '../../utils/proxy/app_proxy_tunnel.dart';

/// 共享 HttpClient 工厂
///
/// HTTP 代理：HTTPS 的 CONNECT 隧道由 [AppProxyTunnel] 自建（dart:io 自带的隧道
/// 连接不复用），明文 HTTP 仍走 dart:io 原生代理。
///
/// 用法：
///   IOHttpClientAdapter(createHttpClient: HttpClientFactory.instance.createHttpClient)
class HttpClientFactory {
  static const String _tag = 'HttpClientFactory';
  static final HttpClientFactory instance = HttpClientFactory._();

  HttpClientFactory._();

  HttpClient? _httpClient;
  String? _proxyHost;
  int? _proxyPort;

  /// 设置代理地址。传 null 表示不使用代理。
  /// 格式: "host:port" 或 "http://host:port"
  void setProxy(String? proxyUrl) {
    if (proxyUrl == null || proxyUrl.isEmpty) {
      _proxyHost = null;
      _proxyPort = null;
      LogUtils.d('$_tag 代理已清除');
    } else {
      try {
        final parsed = _parseProxyUrl(proxyUrl);
        _proxyHost = parsed.$1;
        _proxyPort = parsed.$2;
        LogUtils.d('$_tag 代理设置: $_proxyHost:$_proxyPort');
      } catch (e, stackTrace) {
        // 代理配置异常时清空应用代理，避免启动阶段中断
        _proxyHost = null;
        _proxyPort = null;
        LogUtils.e(
          '$_tag 代理地址无效，已清空应用代理配置: $proxyUrl',
          tag: _tag,
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
    // 代理变更时重建 HttpClient
    reset();
  }

  /// 解析代理 URL: "host:port" 或 "http://host:port"
  (String, int) _parseProxyUrl(String url) => AppProxyTunnel.parseAddress(url);

  bool get hasProxy => _proxyHost != null && _proxyPort != null;

  /// 供 IOHttpClientAdapter(createHttpClient: ...) 使用的回调。
  HttpClient createHttpClient() {
    if (_httpClient != null) return _httpClient!;

    _httpClient = HttpClient();
    _httpClient!.idleTimeout = const Duration(seconds: 90);
    if (hasProxy) {
      // ⛔ 不能写 `findProxy = 'PROXY x; DIRECT'`：dart:io 经代理访问 HTTPS 永不
      // 复用连接，每个接口请求都重新握手。隧道改由 AppProxyTunnel 自己建，
      // 回环直连、代理不通改走直连的语义不变。详见该类注释。
      AppProxyTunnel(_proxyHost!, _proxyPort!).install(_httpClient!);
    }

    LogUtils.d(
      '$_tag 创建共享 HttpClient '
      '(idleTimeout: ${_httpClient!.idleTimeout}, '
      'proxy: ${hasProxy ? "$_proxyHost:$_proxyPort" : "none"})',
    );

    return _httpClient!;
  }

  /// 关闭当前共享 HttpClient，下次请求时自动创建新实例。
  /// 用于代理设置变更后重置连接。
  /// 注意：该 HttpClient 由 ApiService/AuthService/TokenManager/News 共享，
  /// 代理变更(reset)会影响连接池；`force:false` 会等待空闲连接，但变更瞬间
  /// 正在传输的请求可能报错。仅在设置页等低频场景调用(N5)。
  void reset({bool force = false}) {
    if (_httpClient != null) {
      LogUtils.d('$_tag 重置共享 HttpClient (force: $force)');
      _httpClient!.close(force: force);
      _httpClient = null;
    }
  }
}
