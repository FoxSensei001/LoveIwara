import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:i_iwara/utils/logger_utils.dart';

import '../cast_device.dart';
import '../lan_network.dart';
import 'upnp_description.dart';

const _tag = 'SsdpDiscovery';

/// SSDP（DLNA/UPnP）设备发现。
///
/// 和 dlna_dart 的区别，每条都对应一类「扫不到」：
///
/// 1. **逐网卡发 M-SEARCH**：每张私有网段网卡各绑一个 socket，并用
///    `IP_MULTICAST_IF` 钉住出口。dlna_dart 绑 `0.0.0.0`，开着 VPN 或有虚拟
///    网卡时，搜索包从默认路由（tun / vEthernet）出去，根本到不了电视。
///    ⚠️ 安卓的 VpnService 按 UID 做策略路由，绑源地址未必绕得过去；VPN 放行
///    局域网（多数代理软件默认「绕过私有网段」）时，下面的单播扫描仍然通。
/// 2. **单播扫网段兜底**：对本网卡所在 /24 的每个地址发单播 M-SEARCH
///    （UPnP 1.1 要求设备应答）。iOS 14+ 没有组播 entitlement 时组播发不出去，
///    VPN 把组播吞掉而放行局域网单播时，这条路仍然通。
/// 3. **1900 端口占不到不致命**：它只用来收设备主动发的 NOTIFY；Windows 的
///    SSDP 服务就占着它。dlna_dart 在这里抛错，整次搜索作废。
/// 4. **设备描述按 LOCATION 只取一次**，失败最多重试两次，原因写进日志。
///    dlna_dart 每收到一条应答就重取一次，失败只 `print`。
class SsdpDiscovery {
  SsdpDiscovery({required this.onDevice, HttpClient? httpClient})
    : _http = httpClient ?? createLanHttpClient();

  /// 每解析出一台渲染器回调一次（同一台可能回调多次，由调用方按 id 去重）。
  final void Function(DlnaCastDevice device) onDevice;

  final HttpClient _http;

  static final InternetAddress _group = InternetAddress('239.255.255.250');
  static const int _port = 1900;
  static const String _stRenderer =
      'urn:schemas-upnp-org:device:MediaRenderer:1';
  static const String _stAvTransport =
      'urn:schemas-upnp-org:service:AVTransport:1';
  static const String _stAll = 'ssdp:all';

  final List<_SearchSocket> _sockets = [];
  RawDatagramSocket? _notifyListener;
  StreamSubscription<RawSocketEvent>? _notifySub;
  Timer? _timer;
  int _round = 0;
  bool _running = false;

  /// LOCATION → 状态。已成功（不论有没有渲染器）的不再取。
  final Map<String, _LocationState> _locations = {};
  int _inFlight = 0;
  final List<_PendingFetch> _queue = [];

  /// 本次搜索的诊断摘要，停止时打一条日志。
  final _stats = _SsdpStats();

  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _round = 0;
    _stats.reset();
    // 每次搜索都重新取描述：上一轮的设备列表已经清空，不重取就不会再回调。
    _locations.clear();

    final interfaces = await listLanInterfaces();
    if (!_running) return;
    _stats.interfaces = interfaces.map((e) => e.toString()).toList();

    for (final nic in interfaces) {
      final socket = await _bindSearchSocket(nic);
      if (!_running) {
        socket?.close();
        return;
      }
      if (socket != null) _sockets.add(socket);
    }
    // 一张私有网卡都没找到（企业网用公网段、或网卡枚举失败）：退回系统默认出口，
    // 至少不比原来差。
    if (_sockets.isEmpty) {
      final fallback = await _bindSearchSocket(null);
      if (!_running) {
        fallback?.close();
        return;
      }
      if (fallback != null) _sockets.add(fallback);
    }
    if (_sockets.isEmpty) {
      _running = false;
      throw const SocketException('无法创建用于搜索设备的 UDP 套接字');
    }

    await _bindNotifyListener(interfaces);
    if (!_running) return;

    _searchRound();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _searchRound());
  }

  void stop() {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    _timer = null;
    for (final s in _sockets) {
      s.close();
    }
    _sockets.clear();
    _notifySub?.cancel();
    _notifySub = null;
    _notifyListener?.close();
    _notifyListener = null;
    _queue.clear();
    LogUtils.i('SSDP 搜索结束：$_stats', _tag);
  }

  /// 对一个手动输入的地址发几轮单播 M-SEARCH，应答照常进 [onDevice]。
  /// 必须在 [start] 之后调用（应答要靠搜索套接字收）。
  Future<void> probeHost(InternetAddress host) async {
    final hostHeader = '${host.address}:$_port';
    for (var i = 0; i < 3 && _running; i++) {
      for (final s in _sockets) {
        s.send(_mSearch(_stRenderer, host: hostHeader), host);
        s.send(_mSearch(_stAll, host: hostHeader), host);
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }

  /// 设备描述地址已知时直接取（手动添加时用户可能直接粘了描述地址）。
  void fetchLocation(Uri location) => _enqueueFetch(location, force: true);

  // ── 发包 ────────────────────────────────────────────────────────────────

  Future<_SearchSocket?> _bindSearchSocket(LanInterface? nic) async {
    try {
      final socket = await RawDatagramSocket.bind(
        nic?.address ?? InternetAddress.anyIPv4,
        0,
      );
      if (nic != null) {
        try {
          // 钉住组播出口。Linux/安卓上绑了源地址本来就会选对网卡，苹果和
          // Windows 不会，必须设这个选项。值是 in_addr（4 字节网络序）。
          socket.setRawOption(
            RawSocketOption(
              RawSocketOption.levelIPv4,
              RawSocketOption.IPv4MulticastInterface,
              Uint8List.fromList(nic.address.rawAddress),
            ),
          );
        } catch (e) {
          LogUtils.d('设置组播出口失败（$nic），沿用源地址选路: $e', _tag);
        }
      }
      try {
        socket.multicastHops = 4;
      } catch (_) {}
      final wrapped = _SearchSocket(socket, nic);
      _stats.boundSockets++;
      wrapped.subscription = socket.listen(
        (event) {
          if (event != RawSocketEvent.read) return;
          Datagram? d;
          while ((d = socket.receive()) != null) {
            _onDatagram(d!);
          }
        },
        // Windows 会把单播扫描碰到的 ICMP 端口不可达报成下一次接收的错误；
        // 记一笔就好，不能让它变成未捕获异常，也不能停掉这个套接字。
        onError: (Object e) => LogUtils.d('搜索套接字出错（忽略）: $e', _tag),
      );
      return wrapped;
    } catch (e) {
      LogUtils.w('绑定搜索套接字失败（${nic ?? "默认网卡"}）: $e', _tag);
      _stats.bindErrors.add('${nic ?? "any"}: $e');
      return null;
    }
  }

  Future<void> _bindNotifyListener(List<LanInterface> interfaces) async {
    // iOS 没有组播 entitlement 时加组必然失败，也收不到；省掉。
    if (Platform.isIOS) return;
    try {
      final socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _port,
        reuseAddress: true,
        // Windows 不支持 SO_REUSEPORT，传 true 会直接抛。
        reusePort: !Platform.isWindows,
      );
      final nics = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      final wanted = interfaces.map((e) => e.name).toSet();
      var joined = 0;
      for (final nic in nics) {
        if (!wanted.contains(nic.name)) continue;
        try {
          socket.joinMulticast(_group, nic);
          joined++;
        } catch (e) {
          LogUtils.d('加入组播组失败（${nic.name}）: $e', _tag);
        }
      }
      if (joined == 0) {
        try {
          socket.joinMulticast(_group);
          joined++;
        } catch (_) {}
      }
      // 绑定期间被 stop() 了：stop 那时还看不到这个套接字，得在这里关掉，
      // 否则 1900 端口会一直被这个丢弃的实例占着。
      if (!_running) {
        socket.close();
        return;
      }
      _notifyListener = socket;
      _stats.notifyListener = joined > 0 ? 'ok($joined)' : 'bound-no-group';
      _notifySub = socket.listen((event) {
        if (event != RawSocketEvent.read) return;
        Datagram? d;
        while ((d = socket.receive()) != null) {
          _onDatagram(d!);
        }
      }, onError: (Object e) => LogUtils.d('NOTIFY 套接字出错（忽略）: $e', _tag));
    } catch (e) {
      // 端口被占（Windows SSDP 服务、别的投屏 App）：只是收不到 NOTIFY，
      // 主动搜索的应答是单播回到搜索套接字的，不受影响。
      _stats.notifyListener = 'unavailable: $e';
      LogUtils.d('1900 端口不可用，跳过 NOTIFY 监听: $e', _tag);
    }
  }

  void _searchRound() {
    if (!_running) return;
    final round = _round++;
    final targets = switch (round % 3) {
      0 => [_stRenderer, _stAvTransport, _stAll],
      1 => [_stRenderer],
      _ => [_stAvTransport, _stAll],
    };
    for (final s in _sockets) {
      for (final st in targets) {
        final ok = s.send(
          _mSearch(st, host: '239.255.255.250:1900', mx: round == 0 ? 1 : 2),
          _group,
        );
        if (ok) {
          _stats.multicastSent++;
        } else {
          _stats.multicastFailed++;
        }
      }
    }
    // 单播扫网段：第 0 轮马上扫一遍，之后每 4 轮（约 12 秒）再补一遍。
    if (round % 4 == 0) {
      final st = (round ~/ 4).isEven ? _stRenderer : _stAll;
      for (final s in _sockets) {
        final nic = s.nic;
        if (nic != null) unawaited(_sweepSubnet(s, nic, st));
      }
    }
  }

  Future<void> _sweepSubnet(
    _SearchSocket s,
    LanInterface nic,
    String st,
  ) async {
    final self = nic.address.address;
    final prefix = nic.subnetPrefix;
    for (var i = 1; i <= 254; i++) {
      if (!_running || s.closed) return;
      final ip = '$prefix$i';
      if (ip == self) continue;
      final target = InternetAddress(ip);
      final packet = _mSearch(st, host: '$ip:$_port');
      // 发往还没 ARP 解析的地址时，包会在邻居队列里挂着占发送缓冲（约 3 秒），
      // 缓冲满了 send 返回 0。所以小步慢发（整轮约 1.5 秒），失败再等一下重试。
      var sent = s.send(packet, target);
      for (
        var retry = 0;
        !sent && retry < 3 && _running && !s.closed;
        retry++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
        sent = s.send(packet, target);
      }
      if (sent) {
        _stats.unicastSent++;
      } else {
        _stats.unicastDropped++;
      }
      if (i % 8 == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  static List<int> _mSearch(String st, {required String host, int? mx}) {
    final b = StringBuffer()
      ..write('M-SEARCH * HTTP/1.1\r\n')
      ..write('HOST: $host\r\n')
      ..write('MAN: "ssdp:discover"\r\n');
    if (mx != null) b.write('MX: $mx\r\n');
    b
      ..write('ST: $st\r\n')
      ..write(
        'USER-AGENT: ${Platform.operatingSystem}/1.0 UPnP/1.1 i_iwara/1.0\r\n',
      )
      ..write('\r\n');
    return ascii.encode(b.toString());
  }

  // ── 收包 ────────────────────────────────────────────────────────────────

  void _onDatagram(Datagram d) {
    if (!_running) return;
    final String text;
    try {
      text = latin1.decode(d.data);
    } catch (_) {
      return;
    }
    final lines = const LineSplitter().convert(text);
    if (lines.isEmpty) return;
    final first = lines.first.toUpperCase();
    final isResponse = first.startsWith('HTTP/1.') && first.contains(' 200');
    final isNotify = first.startsWith('NOTIFY ');
    if (!isResponse && !isNotify) return;

    final headers = <String, String>{};
    for (final line in lines.skip(1)) {
      final idx = line.indexOf(':');
      if (idx <= 0) continue;
      headers[line.substring(0, idx).trim().toUpperCase()] = line
          .substring(idx + 1)
          .trim();
    }
    if (isNotify && headers['NTS']?.toLowerCase() == 'ssdp:byebye') return;
    final location = headers['LOCATION'];
    if (location == null || location.isEmpty) return;
    final uri = Uri.tryParse(location);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return;
    }
    // 只取局域网内的描述：LOCATION 指向公网的应答一律不理（不让局域网里任意
    // 一个包就能让 App 去访问外网地址）。
    if (!isPrivateIPv4(uri.host) && uri.host != d.address.address) return;
    _stats.responses++;
    _enqueueFetch(uri);
  }

  // ── 取设备描述 ──────────────────────────────────────────────────────────

  void _enqueueFetch(Uri location, {bool force = false}) {
    final key = location.toString();
    final state = _locations[key];
    if (state != null) {
      if (state.inFlight) return;
      if (!force && (state.done || state.failures >= 3)) return;
    }
    final next = _locations.putIfAbsent(key, _LocationState.new)
      ..inFlight = true;
    if (force) next.failures = 0;
    _queue.add(_PendingFetch(key, location));
    _pump();
  }

  void _pump() {
    while (_inFlight < 6 && _queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      _inFlight++;
      unawaited(
        _fetch(job).whenComplete(() {
          _inFlight--;
          _pump();
        }),
      );
    }
  }

  Future<void> _fetch(_PendingFetch job) async {
    // 上一次搜索遗留的请求：表已被 start() 清掉，拿个临时状态兜住。
    final state = _locations[job.key] ?? _LocationState();
    try {
      final body = await _get(job.location);
      final renderers = parseUpnpRenderers(body, job.location);
      state.done = true;
      _stats.descriptionsOk++;
      if (renderers.isNotEmpty) _stats.renderers += renderers.length;
      if (!_running) return;
      for (final r in renderers) {
        onDevice(r);
      }
    } catch (e) {
      state.failures++;
      _stats.descriptionErrors['${job.location.host}:${job.location.port}'] = e
          .toString();
      LogUtils.d('取设备描述失败 ${job.location}（第 ${state.failures} 次）: $e', _tag);
    } finally {
      state.inFlight = false;
    }
  }

  Future<String> _get(Uri uri) async {
    final request = await _http.getUrl(uri).timeout(const Duration(seconds: 5));
    request.followRedirects = true;
    final response = await request.close().timeout(const Duration(seconds: 6));
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('HTTP ${response.statusCode}', uri: uri);
    }
    // 设备描述一般几 KB；限个上限，防止哪个设备吐个大文件出来。
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.timeout(const Duration(seconds: 6))) {
      bytes.add(chunk);
      if (bytes.length > 512 * 1024) {
        throw const FormatException('设备描述过大');
      }
    }
    return utf8.decode(bytes.takeBytes(), allowMalformed: true);
  }
}

class _SearchSocket {
  _SearchSocket(this.socket, this.nic);

  final RawDatagramSocket socket;
  final LanInterface? nic;
  StreamSubscription<RawSocketEvent>? subscription;
  bool closed = false;

  bool send(List<int> data, InternetAddress to) {
    if (closed) return false;
    try {
      return socket.send(data, to, SsdpDiscovery._port) > 0;
    } catch (_) {
      // iOS 无组播 entitlement 时发组播抛 EHOSTUNREACH；单播不受影响。
      return false;
    }
  }

  void close() {
    if (closed) return;
    closed = true;
    subscription?.cancel();
    socket.close();
  }
}

class _LocationState {
  bool done = false;
  bool inFlight = false;
  int failures = 0;
}

class _PendingFetch {
  _PendingFetch(this.key, this.location);
  final String key;
  final Uri location;
}

class _SsdpStats {
  List<String> interfaces = const [];
  int boundSockets = 0;
  List<String> bindErrors = [];
  String notifyListener = 'not-started';
  int multicastSent = 0;
  int multicastFailed = 0;
  int unicastSent = 0;
  int unicastDropped = 0;
  int responses = 0;
  int descriptionsOk = 0;
  int renderers = 0;
  Map<String, String> descriptionErrors = {};

  void reset() {
    interfaces = const [];
    boundSockets = 0;
    bindErrors = [];
    notifyListener = 'not-started';
    multicastSent = 0;
    multicastFailed = 0;
    unicastSent = 0;
    unicastDropped = 0;
    responses = 0;
    descriptionsOk = 0;
    renderers = 0;
    descriptionErrors = {};
  }

  @override
  String toString() =>
      '网卡=$interfaces 套接字=$boundSockets 绑定失败=$bindErrors '
      'NOTIFY监听=$notifyListener 组播发出=$multicastSent 组播失败=$multicastFailed '
      '单播发出=$unicastSent 单播丢弃=$unicastDropped 应答=$responses 描述成功=$descriptionsOk '
      '渲染器=$renderers 描述失败=$descriptionErrors';
}
