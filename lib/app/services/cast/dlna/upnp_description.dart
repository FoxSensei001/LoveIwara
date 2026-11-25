import 'package:xml/xml.dart';

import '../cast_device.dart';

/// 把 UPnP 设备描述文档解析成可投屏的渲染器列表。
///
/// ⛔ 必须逐个 `<device>`（含 `deviceList` 里的子设备）看它**自己的**
/// `serviceList`：dlna_dart 只取文档里第一个 `serviceList`（根设备的），
/// 渲染器挂在子设备下的（Sonos、部分功放/机顶盒）会因为「找不到 AVTransport」
/// 被整台丢掉。
///
/// 一个文档里可能有多台渲染器（多房间音箱），每台按自己的 UDN 去重。
/// 解析失败抛 [FormatException]，调用方记日志。
List<DlnaCastDevice> parseUpnpRenderers(String xmlText, Uri location) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(xmlText);
  } on XmlException catch (e) {
    throw FormatException('设备描述不是合法 XML: ${e.message}');
  }
  final root = doc.rootElement;

  final urlBaseText = _childText(root, 'URLBase');
  final base = (urlBaseText != null && urlBaseText.isNotEmpty)
      ? (Uri.tryParse(urlBaseText) ?? location)
      : location;

  final rootDevice = _child(root, 'device');
  final rootName = rootDevice == null
      ? null
      : _childText(rootDevice, 'friendlyName');

  final result = <DlnaCastDevice>[];
  for (final device in root.descendantElements.where(
    (e) => e.name.local == 'device',
  )) {
    final serviceList = _child(device, 'serviceList');
    if (serviceList == null) continue;
    // 少数媒体服务器（NAS 的 DLNA 服务）也挂了 AVTransport，但投上去必然失败。
    final deviceType = _childText(device, 'deviceType') ?? '';
    if (deviceType.contains(':device:MediaServer:')) continue;
    for (final service in serviceList.childElements.where(
      (e) => e.name.local == 'service',
    )) {
      final serviceType = _childText(service, 'serviceType') ?? '';
      final serviceId = _childText(service, 'serviceId') ?? '';
      final controlUrl = _childText(service, 'controlURL') ?? '';
      if (controlUrl.isEmpty) continue;
      if (!isAvTransportService(serviceType, serviceId)) continue;

      final Uri resolvedControl;
      try {
        resolvedControl = base.resolve(controlUrl);
      } on FormatException {
        continue;
      }
      final udn = _childText(device, 'UDN');
      final friendlyName =
          _childText(device, 'friendlyName') ?? rootName ?? location.host;
      final model = _joinNonEmpty([
        _childText(device, 'manufacturer'),
        _childText(device, 'modelName'),
      ]);
      result.add(
        DlnaCastDevice(
          id: (udn != null && udn.isNotEmpty)
              ? udn
              : '${location.origin}|${resolvedControl.path}',
          name: friendlyName,
          model: model,
          location: location,
          avTransportControlUrl: resolvedControl,
          avTransportServiceType: serviceType.contains(':service:AVTransport:')
              ? serviceType
              : 'urn:schemas-upnp-org:service:AVTransport:1',
        ),
      );
      break;
    }
  }
  return result;
}

/// 这条服务是不是 AVTransport。认 serviceType（标准做法），
/// 也认只在 serviceId 里写了 AVTransport 的老设备。
bool isAvTransportService(String serviceType, String serviceId) {
  return serviceType.contains(':service:AVTransport:') ||
      serviceId.contains('AVTransport');
}

XmlElement? _child(XmlElement parent, String localName) {
  for (final e in parent.childElements) {
    if (e.name.local == localName) return e;
  }
  return null;
}

String? _childText(XmlElement parent, String localName) {
  final text = _child(parent, localName)?.innerText.trim();
  return (text == null || text.isEmpty) ? null : text;
}

String? _joinNonEmpty(List<String?> parts) {
  final kept = [
    for (final p in parts)
      if (p != null && p.isNotEmpty) p,
  ];
  if (kept.isEmpty) return null;
  // 「Samsung Samsung TV」这种重复的厂商前缀合并掉。
  if (kept.length == 2 &&
      kept[1].toLowerCase().startsWith(kept[0].toLowerCase())) {
    return kept[1];
  }
  return kept.join(' ');
}
