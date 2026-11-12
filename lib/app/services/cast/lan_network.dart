import 'dart:io';

/// 本机一张可用于局域网发现的 IPv4 网卡。
class LanInterface {
  const LanInterface({required this.name, required this.address});

  final String name;
  final InternetAddress address;

  /// 按 /24 猜的网段前缀（`192.168.1.`）。Dart 拿不到子网掩码，家用网络
  /// 绝大多数是 /24；更大的网段只扫到本机所在的那 254 个地址。
  String get subnetPrefix {
    final parts = address.address.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.';
  }

  @override
  String toString() => '$name(${address.address})';
}

/// 列出能用来找局域网设备的网卡：只要私有网段的 IPv4。
///
/// ⛔ 组播出口不能交给系统默认路由：开着 VPN 时默认路由是 tun 网卡，
/// 电脑上还有 Hyper-V / VMware 虚拟网卡，搜索包会全部发进这些地方。
/// 所以调用方要逐网卡绑地址发包，这里负责把「可能是局域网」的网卡挑出来。
Future<List<LanInterface>> listLanInterfaces() async {
  final List<NetworkInterface> interfaces;
  try {
    interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
  } catch (_) {
    return const [];
  }
  final result = <LanInterface>[];
  final seen = <String>{};
  for (final nic in interfaces) {
    if (_looksLikeTunnel(nic.name)) continue;
    for (final addr in nic.addresses) {
      if (addr.type != InternetAddressType.IPv4) continue;
      if (!isPrivateIPv4(addr.address)) continue;
      if (!seen.add(addr.address)) continue;
      result.add(LanInterface(name: nic.name, address: addr));
    }
  }
  return result;
}

/// VPN / 隧道网卡、蜂窝网卡：不在上面找电视。名字是各平台的惯例前缀
/// （运营商常给蜂窝分配 10.x，不排掉会去扫运营商的内网）。
bool _looksLikeTunnel(String name) {
  final n = name.toLowerCase();
  const prefixes = [
    'tun', 'utun', 'ppp', 'wg', 'ipsec', 'tap', 'gpd', 'zt', //
    'pdp_ip', 'rmnet', 'ccmni', 'v4-',
  ];
  return prefixes.any(n.startsWith);
}

/// RFC 1918 私有地址。
bool isPrivateIPv4(String address) {
  final parts = address.split('.');
  if (parts.length != 4) return false;
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  if (a == null || b == null) return false;
  if (a == 10) return true;
  if (a == 192 && b == 168) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  return false;
}

/// 访问局域网设备用的 HttpClient。
///
/// ⛔ 必须显式直连：应用在启动时设了 `HttpOverrides.global`，开了应用内代理后
/// 所有 `HttpClient()` 默认都走 `PROXY x; DIRECT`——代理是全局模式或在别的机器上
/// 时，发往 192.168.x.x 的请求会被代理吞掉，设备描述取不回、投屏指令发不出。
HttpClient createLanHttpClient() {
  final client = HttpClient()
    ..findProxy = ((_) => 'DIRECT')
    ..connectionTimeout = const Duration(seconds: 4)
    ..idleTimeout = const Duration(seconds: 5)
    ..userAgent = 'UPnP/1.0 DLNADOC/1.50 i_iwara';
  return client;
}
