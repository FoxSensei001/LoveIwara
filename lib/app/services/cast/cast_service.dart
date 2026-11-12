import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

import 'cast_device.dart';
import 'chromecast/chromecast_controller.dart';
import 'chromecast/chromecast_discovery.dart';
import 'dlna/dlna_controller.dart';
import 'dlna/ssdp_discovery.dart';

export 'cast_device.dart';

const _tag = 'CastService';

/// 手动添加的结果。
enum ManualCastResult { found, notFound, invalid }

/// 投屏：DLNA + Google Cast 两种协议的发现、投放、停止。
///
/// 发现是一次「搜索窗口」：[startSearch] 后两路同时找 [searchWindow] 这么久，
/// 结束后关掉套接字/系统发现（省电），找到的设备留在 [devices] 里。
class CastService extends GetxService {
  CastService({
    DlnaTransport? dlnaTransport,
    ChromecastTransport? chromecastTransport,
  }) : _dlna = dlnaTransport ?? SoapDlnaTransport(),
       _chromecast = chromecastTransport ?? const CastV2ChromecastTransport();

  static CastService get instance => Get.find<CastService>();

  static const Duration searchWindow = Duration(seconds: 15);

  /// 记住的手动地址最多几个（每次搜索都会顺带探测一遍）。
  static const int _maxManualHosts = 8;

  final DlnaTransport _dlna;
  final ChromecastTransport _chromecast;

  final RxBool isSearching = false.obs;
  final RxList<CastDevice> devices = <CastDevice>[].obs;

  /// 有投屏/停止指令正在执行。
  final RxBool isCasting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString connectedDeviceName = ''.obs;
  final RxString connectedDeviceId = ''.obs;

  /// 手动添加正在探测。
  final RxBool isProbing = false.obs;

  SsdpDiscovery? _ssdp;
  ChromecastDiscovery? _chromecastDiscovery;
  Timer? _searchTimer;
  DateTime? _searchDeadline;
  int _searchGeneration = 0;

  CastDevice? _currentDevice;
  String? _chromecastSessionId;
  Future<void> _operationQueue = Future<void>.value();
  int _pendingOperationCount = 0;

  @override
  void onClose() {
    stopSearch();
    super.onClose();
  }

  // ── 发现 ────────────────────────────────────────────────────────────────

  /// [clearDevices] 为 false 时保留已找到的设备（手动添加时临时补开一轮用）。
  Future<void> startSearch({bool clearDevices = true}) async {
    if (isSearching.value) return;
    final generation = ++_searchGeneration;
    isSearching.value = true;
    if (clearDevices) devices.clear();

    final ssdp = SsdpDiscovery(onDevice: _addDevice);
    final chromecast = ChromecastDiscovery(onDevice: _addDevice);
    _ssdp = ssdp;
    _chromecastDiscovery = chromecast;

    var anyStarted = false;
    Object? lastError;
    try {
      await ssdp.start();
      anyStarted = true;
    } catch (e) {
      lastError = e;
      LogUtils.e('启动 DLNA 搜索失败', tag: _tag, error: e);
    }
    if (generation != _searchGeneration) return;
    try {
      await chromecast.start();
      anyStarted = true;
    } catch (e) {
      lastError ??= e;
      LogUtils.e('启动 Google Cast 搜索失败', tag: _tag, error: e);
    }
    if (generation != _searchGeneration) return;

    if (!anyStarted) {
      _stopDiscoveries();
      isSearching.value = false;
      showAppToast(
        slang.t.videoDetail.cast.unableToStartCastingSearch(
          error: lastError.toString(),
        ),
        type: AppToastType.error,
        position: AppToastPosition.top,
      );
      return;
    }

    for (final host in _savedManualHosts()) {
      unawaited(_probeHost(host, remember: false));
    }

    _armSearchTimer(searchWindow);
  }

  /// （重新）设定搜索窗口的结束时间。
  void _armSearchTimer(Duration duration) {
    final generation = _searchGeneration;
    _searchTimer?.cancel();
    _searchDeadline = DateTime.now().add(duration);
    _searchTimer = Timer(duration, () {
      if (generation != _searchGeneration) return;
      _stopDiscoveries();
      isSearching.value = false;
      LogUtils.i('投屏搜索窗口结束，共 ${devices.length} 台设备', _tag);
    });
  }

  /// 保证搜索至少还会再跑 [atLeast]：手动探测等应答期间窗口不许到期，
  /// 否则还在取的设备描述会被丢掉，误报「没找到」。
  void _extendSearchWindow(Duration atLeast) {
    if (_searchTimer == null) return;
    final deadline = _searchDeadline;
    final wanted = DateTime.now().add(atLeast);
    if (deadline != null && deadline.isAfter(wanted)) return;
    _armSearchTimer(atLeast);
  }

  void stopSearch() {
    _searchGeneration++;
    _stopDiscoveries();
    isSearching.value = false;
  }

  void _stopDiscoveries() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _searchDeadline = null;
    _ssdp?.stop();
    _ssdp = null;
    final chromecast = _chromecastDiscovery;
    _chromecastDiscovery = null;
    if (chromecast != null) unawaited(chromecast.stop());
  }

  void _addDevice(CastDevice device) {
    var index = devices.indexWhere((d) => d.id == device.id);
    // 同一台 Chromecast 可能既被 mDNS 找到、又被手动地址探测到，两边的 id 不同
    // （手动那条拿不到 TXT 里的 id）：按地址合并，保留自动发现的那条。
    if (index < 0 && device is ChromecastDevice) {
      index = devices.indexWhere(
        (d) =>
            d is ChromecastDevice &&
            d.address == device.address &&
            d.port == device.port,
      );
      if (index >= 0) {
        final old = devices[index] as ChromecastDevice;
        final keep = old.manual && !device.manual ? device : old;
        devices[index] = ChromecastDevice(
          id: keep.id,
          name: keep.name,
          model: keep.model ?? device.model,
          address: keep.address,
          port: keep.port,
          manual: old.manual || device.manual,
        );
        return;
      }
    }
    if (index < 0) {
      devices.add(device);
      LogUtils.d(
        '发现投屏设备: ${device.name} (${device.runtimeType}, ${device.host})',
        _tag,
      );
    } else {
      final old = devices[index];
      // 手动添加的标记不被自动发现覆盖掉。
      devices[index] = old.manual && device is DlnaCastDevice
          ? device.copyWith(manual: true)
          : device;
    }
  }

  // ── 手动添加 ────────────────────────────────────────────────────────────

  /// 用户输入的地址：IP、`IP:端口`，或完整的设备描述地址。
  Future<ManualCastResult> addManualHost(String input) async {
    final text = input.trim();
    if (text.isEmpty) return ManualCastResult.invalid;

    Uri? descriptionUrl;
    String host;
    if (text.contains('://')) {
      descriptionUrl = Uri.tryParse(text);
      if (descriptionUrl == null || descriptionUrl.host.isEmpty) {
        return ManualCastResult.invalid;
      }
      host = descriptionUrl.host;
    } else {
      host = text.split(':').first;
    }
    if (InternetAddress.tryParse(host)?.type != InternetAddressType.IPv4) {
      return ManualCastResult.invalid;
    }

    isProbing.value = true;
    try {
      final found = await _probeHost(
        host,
        remember: true,
        descriptionUrl: descriptionUrl,
      );
      return found ? ManualCastResult.found : ManualCastResult.notFound;
    } finally {
      isProbing.value = false;
    }
  }

  Future<bool> _probeHost(
    String host, {
    required bool remember,
    Uri? descriptionUrl,
  }) async {
    final address = InternetAddress(host);
    bool hasDeviceOnHost() => devices.any((d) => d.host == host);

    // DLNA 的应答要靠搜索套接字收：没在搜就先开一轮（不清掉已找到的设备）。
    if (_ssdp == null || !(_ssdp!.isRunning)) {
      await startSearch(clearDevices: false);
    }
    _extendSearchWindow(const Duration(seconds: 10));
    final ssdp = _ssdp;
    if (ssdp != null) {
      if (descriptionUrl != null) ssdp.fetchLocation(descriptionUrl);
      unawaited(ssdp.probeHost(address));
    }

    // Google Cast 探测与等 DLNA 应答并行。
    final chromecastProbe = ChromecastDiscovery.probe(host).then((device) {
      if (device != null) _addDevice(device);
    });
    for (var i = 0; i < 16 && !hasDeviceOnHost(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (!hasDeviceOnHost()) await chromecastProbe;
    final found = hasDeviceOnHost();
    if (found) {
      for (var i = 0; i < devices.length; i++) {
        final d = devices[i];
        if (d.host == host && d is DlnaCastDevice && !d.manual) {
          devices[i] = d.copyWith(manual: true);
        }
      }
      if (remember) await _rememberManualHost(host);
    }
    LogUtils.i('手动探测 $host：${found ? "找到设备" : "没有找到"}', _tag);
    return found;
  }

  List<String> _savedManualHosts() {
    try {
      final raw =
          Get.find<ConfigService>()[ConfigKey.CAST_MANUAL_HOSTS] as List?;
      return raw?.whereType<String>().toList() ?? const [];
    } catch (_) {
      return const [];
    }
  }

  Future<void> _rememberManualHost(String host) async {
    try {
      final hosts = _savedManualHosts().where((h) => h != host).toList()
        ..insert(0, host);
      if (hosts.length > _maxManualHosts) {
        hosts.removeRange(_maxManualHosts, hosts.length);
      }
      await Get.find<ConfigService>().setSetting(
        ConfigKey.CAST_MANUAL_HOSTS,
        hosts,
      );
    } catch (e) {
      LogUtils.w('保存手动投屏地址失败: $e', _tag);
    }
  }

  // ── 投放 / 停止 ─────────────────────────────────────────────────────────

  Future<bool> castToDevice(CastDevice device, String url, {String? title}) =>
      _runSerialized(() => _castToDevice(device, url, title));

  Future<bool> _castToDevice(
    CastDevice device,
    String url,
    String? title,
  ) async {
    try {
      final previous = _currentDevice;
      if (previous != null && previous.id != device.id) {
        await _bestEffortStop(previous);
      }

      switch (device) {
        case DlnaCastDevice():
          // 部分渲染器（尤其是 LG）在已有传输会话时会以 UPnP 701 拒绝替换 URI。
          // Stop 在空闲设备上也可能报错，因此只当作尽力而为的状态复位。
          await _bestEffortStop(device);
          await _dlna.setUrl(device, url, title: title);
          await _dlna.play(device);
          _chromecastSessionId = null;
        case ChromecastDevice():
          _chromecastSessionId = await _chromecast.load(
            device,
            url,
            title: title,
          );
      }

      _currentDevice = device;
      connectedDeviceId.value = device.id;
      connectedDeviceName.value = device.name;
      isConnected.value = true;
      showAppToast(
        slang.t.videoDetail.cast.startCastingTo(deviceName: device.name),
        type: AppToastType.success,
        position: AppToastPosition.top,
      );
      LogUtils.i('投屏成功: ${device.name} (${device.host})', _tag);
      return true;
    } catch (e) {
      LogUtils.e('投屏失败: ${device.name} (${device.host})', tag: _tag, error: e);
      showAppToast(
        slang.t.videoDetail.cast.castFailed(error: describeFailure(e)),
        type: AppToastType.error,
        position: AppToastPosition.top,
        duration: const Duration(seconds: 5),
      );
      _currentDevice = null;
      _chromecastSessionId = null;
      isConnected.value = false;
      connectedDeviceName.value = '';
      connectedDeviceId.value = '';
      return false;
    }
  }

  Future<void> _bestEffortStop(CastDevice device) async {
    try {
      switch (device) {
        case DlnaCastDevice():
          await _dlna.stop(device);
        case ChromecastDevice():
          await _chromecast.stop(device, _chromecastSessionId);
      }
    } catch (e) {
      LogUtils.d('停止设备失败（忽略）: ${device.name}: $e', _tag);
    }
  }

  Future<void> stopCast() => _runSerialized(_stopCast);

  Future<void> _stopCast() async {
    final device = _currentDevice;
    try {
      if (device != null) {
        switch (device) {
          case DlnaCastDevice():
            await _dlna.stop(device);
          case ChromecastDevice():
            await _chromecast.stop(device, _chromecastSessionId);
        }
      }
      showAppToast(
        slang.t.videoDetail.cast.castStopped,
        type: AppToastType.info,
        position: AppToastPosition.top,
      );
      LogUtils.d('停止投屏', _tag);
    } catch (e) {
      LogUtils.e('停止投屏失败', tag: _tag, error: e);
    } finally {
      // 停不掉（设备已关机/断网）也要让界面回到未连接，否则「停止」按钮永远在。
      if (identical(_currentDevice, device)) {
        _currentDevice = null;
        _chromecastSessionId = null;
        isConnected.value = false;
        connectedDeviceName.value = '';
        connectedDeviceId.value = '';
      }
    }
  }

  Future<T> _runSerialized<T>(Future<T> Function() operation) async {
    final predecessor = _operationQueue;
    final release = Completer<void>();
    _operationQueue = release.future;
    _pendingOperationCount++;
    isCasting.value = true;

    try {
      await predecessor;
      return await operation();
    } finally {
      release.complete();
      _pendingOperationCount--;
      isCasting.value = _pendingOperationCount > 0;
    }
  }

  /// 把异常翻成给用户看的一句话。
  static String describeFailure(Object error) {
    final f = slang.t.videoDetail.cast.dlnaCastSheet.failure;
    if (error is CastException) {
      return switch (error.kind) {
        CastFailure.unreachable => f.unreachable,
        CastFailure.timeout => f.timeout,
        CastFailure.mediaRejected => f.mediaRejected,
        CastFailure.deviceRejected => f.deviceRejected,
      };
    }
    if (error is IOException) return f.unreachable;
    if (error is TimeoutException) return f.timeout;
    return error.toString();
  }
}
