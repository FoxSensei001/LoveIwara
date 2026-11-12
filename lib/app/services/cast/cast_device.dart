/// 投屏失败的类别。界面按类别给本地化提示，[CastException.detail] 只进日志。
enum CastFailure {
  /// 连不上设备（不在同一网络、设备关机、被防火墙/VPN 挡住）。
  unreachable,

  /// 连上了但设备不回话。
  timeout,

  /// 设备说这个视频放不了（格式、地址打不开）。
  mediaRejected,

  /// 设备拒绝了指令（其他错误码）。
  deviceRejected,
}

class CastException implements Exception {
  CastException(this.kind, this.detail);

  final CastFailure kind;
  final String detail;

  @override
  String toString() => '${kind.name}: $detail';
}

/// 投屏目标设备。
///
/// 两种协议各一个子类：DLNA（UPnP AVTransport）和 Google Cast（Chromecast /
/// 内置 Chromecast 的电视）。列表、去重、投屏入口都只认 [id]。
sealed class CastDevice {
  const CastDevice({
    required this.id,
    required this.name,
    this.model,
    this.manual = false,
  });

  /// 跨次搜索稳定的标识：DLNA 用 UDN，Google Cast 用 TXT 里的 id（取不到退回地址）。
  final String id;

  /// 给人看的名字（电视上设置的那个）。
  final String name;

  /// 型号 / 厂商，可空。
  final String? model;

  /// 是不是用户手动输入地址找到的。
  final bool manual;

  /// 设备所在主机（IP），手动添加记忆与日志用。
  String get host;
}

/// 带 AVTransport 控制端点的 UPnP 渲染器。
final class DlnaCastDevice extends CastDevice {
  const DlnaCastDevice({
    required super.id,
    required super.name,
    super.model,
    super.manual,
    required this.location,
    required this.avTransportControlUrl,
    required this.avTransportServiceType,
  });

  /// 设备描述文档地址（SSDP 的 LOCATION）。
  final Uri location;

  /// 已按 URLBase / LOCATION 解析成绝对地址的 AVTransport controlURL。
  final Uri avTransportControlUrl;

  /// 设备声明的服务类型，如 `urn:schemas-upnp-org:service:AVTransport:1`。
  /// SOAPAction 与报文命名空间都用它，不写死 `:1`。
  final String avTransportServiceType;

  @override
  String get host => location.host;

  DlnaCastDevice copyWith({bool? manual}) => DlnaCastDevice(
    id: id,
    name: name,
    model: model,
    manual: manual ?? this.manual,
    location: location,
    avTransportControlUrl: avTransportControlUrl,
    avTransportServiceType: avTransportServiceType,
  );
}

/// Google Cast 接收端（Chromecast、Google TV、内置 Chromecast 的电视/音箱）。
final class ChromecastDevice extends CastDevice {
  const ChromecastDevice({
    required super.id,
    required super.name,
    super.model,
    super.manual,
    required this.address,
    this.port = 8009,
  });

  /// 已解析的 IP（不是 `.local` 主机名：安卓的系统解析器不认 mDNS 名）。
  final String address;

  final int port;

  @override
  String get host => address;

  /// 只有画面的设备才值得列出来：纯音箱（Nest Mini / 音箱组）放不了视频。
  /// TXT 的 `ca` 是能力位掩码，bit0 = 视频输出。取不到时不过滤。
  static bool supportsVideo(Map<String, String> txt) {
    final raw = txt['ca'];
    if (raw == null) return true;
    final caps = int.tryParse(raw);
    if (caps == null) return true;
    return caps & 0x01 != 0;
  }
}
