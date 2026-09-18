/// 这个主机名是不是本机回环地址。
///
/// 给自定义 `findProxy` 用：它们不会像 `HttpClient.findProxyFromEnvironment`
/// 那样自动放过 localhost，本机服务（NAS 网关）必须由调用方显式直连。
bool isLoopbackHost(String host) {
  final h = host.toLowerCase();
  return h == 'localhost' || h == '::1' || h == '[::1]' || h.startsWith('127.');
}
