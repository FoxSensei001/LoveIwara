import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../utils/logger_utils.dart';

/// 共享 HttpClient 工厂
///
/// 通过 findProxy 实现 HTTP 代理，使用 Dart 内置的 CONNECT 隧道机制。
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
  (String, int) _parseProxyUrl(String url) {
    var cleaned = url.trim();
    // 移除协议前缀
    if (cleaned.startsWith('http://')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('https://')) cleaned = cleaned.substring(8);
    // 移除尾部斜杠
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    String host;
    String portStr;
    if (cleaned.startsWith('[')) {
      // IPv6 字面量: [::1]:7890 —— 不能用 lastIndexOf(':') 切分
      final end = cleaned.indexOf(']');
      if (end == -1) throw ArgumentError('Invalid IPv6 proxy URL: $url');
      host = cleaned.substring(1, end);
      final rest = cleaned.substring(end + 1);
      if (!rest.startsWith(':')) {
        throw ArgumentError('Missing proxy port in URL: $url');
      }
      portStr = rest.substring(1);
    } else {
      final colonIdx = cleaned.lastIndexOf(':');
      if (colonIdx == -1) throw ArgumentError('Invalid proxy URL: $url');
      host = cleaned.substring(0, colonIdx);
      portStr = cleaned.substring(colonIdx + 1);
    }
    // 用 tryParse 兜底：端口非法时抛 ArgumentError（与本方法既有契约一致），
    // 而非 FormatException，便于调用方统一捕获；并校验端口范围。
    final port = int.tryParse(portStr.trim());
    if (port == null || port < 1 || port > 65535) {
      throw ArgumentError('Invalid proxy port in URL: $url');
    }
    return (host, port);
  }

  bool get hasProxy => _proxyHost != null && _proxyPort != null;

  String? _buildProxyRule() {
    if (hasProxy) {
      return 'PROXY $_proxyHost:$_proxyPort; DIRECT';
    }
    return null;
  }

  @visibleForTesting
  String? get currentProxyRule => _buildProxyRule();

  /// 供 IOHttpClientAdapter(createHttpClient: ...) 使用的回调。
  HttpClient createHttpClient() {
    if (_httpClient != null) return _httpClient!;

    _httpClient = HttpClient();
    _httpClient!.idleTimeout = const Duration(seconds: 90);
    final proxyRule = _buildProxyRule();
    if (proxyRule != null) {
      _httpClient!.findProxy = (uri) => proxyRule;
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
