import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import '../cast_device.dart';
import '../lan_network.dart';
import 'cast_channel.dart';

const _tag = 'ChromecastDiscovery';

/// 用系统的 mDNS/Bonjour 服务找 `_googlecast._tcp`。
///
/// 走系统服务而不是自己发组播：安卓的 NsdManager、苹果的 dns_sd 都不受
/// 「App 没有组播 entitlement」限制（iOS 14+ 自己发组播必须有它，侧载签名拿不到），
/// 也会在所有网卡上找，不怕 VPN 占默认路由。
/// iOS/macOS 需要在 Info.plist 的 NSBonjourServices 里声明 `_googlecast._tcp`。
class ChromecastDiscovery {
  ChromecastDiscovery({required this.onDevice});

  final void Function(ChromecastDevice device) onDevice;

  static const String serviceType = '_googlecast._tcp';

  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;
  int _found = 0;
  int _resolved = 0;

  /// 已经补过一次解析的服务名（只补一次）。
  final Set<String> _reResolved = {};

  Future<void> start() async {
    await stop();
    _found = 0;
    _resolved = 0;
    _reResolved.clear();
    final discovery = BonsoirDiscovery(type: serviceType, printLogs: false);
    _discovery = discovery;
    await discovery.initialize();
    if (!identical(_discovery, discovery)) return;
    _subscription = discovery.eventStream?.listen((event) {
      switch (event) {
        case BonsoirDiscoveryServiceFoundEvent():
          _found++;
          unawaited(_resolve(discovery, event.service));
        case BonsoirDiscoveryServiceResolvedEvent():
          _resolved++;
          if (!_emit(event.service) && _reResolved.add(event.service.name)) {
            // 苹果端拿到第一批地址就停止解析：第一批只有 IPv6 链路本地地址时
            // 这台会被跳过。过一会儿再解析一次，通常能拿到 IPv4。
            Future<void>.delayed(const Duration(seconds: 1), () {
              if (identical(_discovery, discovery)) {
                unawaited(_resolve(discovery, event.service));
              }
            });
          }
        case BonsoirDiscoveryServiceUpdatedEvent():
          _emit(event.service);
        default:
          break;
      }
    }, onError: (Object e) => LogUtils.w('Chromecast 发现出错: $e', _tag));
    await discovery.start();
    // start() 期间被 stop() 了：那次 stop 发生在系统发现真正跑起来之前，补停一次。
    if (!identical(_discovery, discovery)) {
      try {
        await discovery.stop();
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    final discovery = _discovery;
    _discovery = null;
    await _subscription?.cancel();
    _subscription = null;
    if (discovery != null) {
      LogUtils.i('Chromecast 搜索结束：发现 $_found 个服务，解析 $_resolved 个', _tag);
      try {
        await discovery.stop();
      } catch (e) {
        LogUtils.d('停止 Chromecast 发现失败: $e', _tag);
      }
    }
  }

  Future<void> _resolve(
    BonsoirDiscovery discovery,
    BonsoirService service,
  ) async {
    try {
      await service.resolve(discovery.serviceResolver);
    } catch (e) {
      LogUtils.d('解析 Chromecast 服务失败 ${service.name}: $e', _tag);
    }
  }

  /// 返回是否拿到了可用地址（没拿到时调用方可以补一次解析）。
  bool _emit(BonsoirService service) {
    final address = _pickAddress(service.hostAddresses);
    if (address == null) return false;
    final txt = service.attributes;
    if (!ChromecastDevice.supportsVideo(txt)) {
      LogUtils.d('跳过无画面的 Cast 设备: ${txt['fn'] ?? service.name}', _tag);
      return true;
    }
    final id = txt['id'];
    onDevice(
      ChromecastDevice(
        id: 'cast:${(id != null && id.isNotEmpty) ? id : service.name}',
        name: _nonEmpty(txt['fn']) ?? service.name,
        model: _nonEmpty(txt['md']),
        address: address,
        port: service.port == 0 ? 8009 : service.port,
      ),
    );
    return true;
  }

  /// 优先局域网 IPv4；IPv6 链路本地地址没有 scope id 连不上，不要。
  static String? _pickAddress(List<String> addresses) {
    String? fallback;
    for (final a in addresses) {
      final parsed = InternetAddress.tryParse(a);
      if (parsed == null) continue;
      if (parsed.type == InternetAddressType.IPv4) {
        if (isPrivateIPv4(a)) return a;
        fallback ??= a;
      } else if (!parsed.isLinkLocal) {
        fallback ??= a;
      }
    }
    return fallback;
  }

  /// 手动输入地址时探测：能在 8009 上握手 TLS 就当它是 Cast 设备。
  /// 名字从 8008 的 eureka_info 取（较新的固件可能不给，退回地址）。
  static Future<ChromecastDevice?> probe(String host) async {
    try {
      final channel = await CastChannel.connect(
        host,
        8009,
        timeout: const Duration(seconds: 3),
      );
      await channel.close();
    } catch (_) {
      return null;
    }
    final info = await _eurekaInfo(host);
    final name = _nonEmpty(info?['name'] as String?);
    final deviceInfo = info?['device_info'];
    final model = deviceInfo is Map
        ? _nonEmpty(deviceInfo['model_name'] as String?)
        : null;
    return ChromecastDevice(
      id: 'cast:manual:$host',
      name: name ?? 'Google Cast ($host)',
      model: model,
      address: host,
      manual: true,
    );
  }

  static Future<Map<String, dynamic>?> _eurekaInfo(String host) async {
    final client = createLanHttpClient();
    try {
      final uri = Uri(
        scheme: 'http',
        host: host,
        port: 8008,
        path: '/setup/eureka_info',
        queryParameters: {'params': 'name,device_info'},
      );
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 3));
      final response = await request.close().timeout(
        const Duration(seconds: 3),
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        return null;
      }
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 3));
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  static String? _nonEmpty(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();
}
