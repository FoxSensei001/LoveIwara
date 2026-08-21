import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

abstract interface class DlnaDeviceTransport {
  Future<void> setUrl(DLNADevice device, String videoUrl);

  Future<void> play(DLNADevice device);

  Future<void> stop(DLNADevice device);
}

class PackageDlnaDeviceTransport implements DlnaDeviceTransport {
  const PackageDlnaDeviceTransport();

  @override
  Future<void> setUrl(DLNADevice device, String videoUrl) async {
    await device.setUrl(videoUrl);
  }

  @override
  Future<void> play(DLNADevice device) async {
    await device.play();
  }

  @override
  Future<void> stop(DLNADevice device) async {
    await device.stop();
  }
}

class DlnaCastService extends GetxService {
  DlnaCastService({DlnaDeviceTransport? transport})
    : _transport = transport ?? const PackageDlnaDeviceTransport();

  static DlnaCastService get instance => Get.find<DlnaCastService>();

  final DlnaDeviceTransport _transport;

  final RxBool isSearching = false.obs;
  final RxList<DLNADevice> devices = <DLNADevice>[].obs;
  final RxBool isCasting = false.obs;
  final RxBool isConnected = false.obs;
  final RxString connectedDeviceName = ''.obs;

  DLNAManager? _dlnaManager;
  StreamSubscription<Map<String, DLNADevice>>? _deviceSubscription;
  DLNADevice? _currentDevice;
  bool _isInitialized = false;
  Future<void> _operationQueue = Future<void>.value();
  int _pendingOperationCount = 0;

  @override
  Future<void> onInit() async {
    super.onInit();
    LogUtils.d('DLNA 投屏服务初始化', 'DlnaCastService');
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  /// 清理资源
  void _cleanup() {
    _deviceSubscription?.cancel();
    _dlnaManager?.stop();
    _isInitialized = false;
    isSearching.value = false;
    devices.clear();
    isCasting.value = false;
    isConnected.value = false;
    connectedDeviceName.value = '';
    _currentDevice = null;
    LogUtils.d('DLNA 投屏服务资源已清理', 'DlnaCastService');
  }

  /// 开始搜索 DLNA 设备
  Future<void> startSearch() async {
    try {
      // 如果已经在搜索中，直接返回
      if (isSearching.value) {
        LogUtils.d('DLNA 搜索已在进行中', 'DlnaCastService');
        return;
      }

      isSearching.value = true;
      devices.clear();

      // 如果已经初始化过，先清理
      if (_isInitialized) {
        _cleanup();
      }

      _dlnaManager = DLNAManager();
      final dlna = await _dlnaManager!.start();
      _isInitialized = true;

      _deviceSubscription = dlna.devices.stream.listen((deviceMap) {
        devices.assignAll(deviceMap.values.where(isCastCapableDevice));
        LogUtils.d('发现 DLNA 设备: ${devices.length} 个', 'DlnaCastService');
      });

      LogUtils.d('开始搜索 DLNA 设备', 'DlnaCastService');
    } catch (e) {
      LogUtils.e('启动 DLNA 搜索失败: $e', tag: 'DlnaCastService', error: e);
      showGlassToast(
        slang.t.videoDetail.cast.unableToStartCastingSearch(
          error: e.toString(),
        ),
        type: GlassToastType.error,
        position: GlassToastPosition.top,
      );
      isSearching.value = false;
      _isInitialized = false;
    }
  }

  /// 停止搜索
  void stopSearch() {
    _deviceSubscription?.cancel();
    _dlnaManager?.stop();
    isSearching.value = false;
    devices.clear();
    _isInitialized = false;
    LogUtils.d('停止 DLNA 搜索', 'DlnaCastService');
  }

  /// 连接到指定设备并投屏
  Future<bool> castToDevice(DLNADevice device, String videoUrl) {
    if (!isCastCapableDevice(device)) {
      LogUtils.w(
        '忽略不支持 AVTransport 的设备: ${device.info.friendlyName}',
        'DlnaCastService',
      );
      return Future<bool>.value(false);
    }

    return _runSerialized(() => _castToDevice(device, videoUrl));
  }

  Future<bool> _castToDevice(DLNADevice device, String videoUrl) async {
    try {
      final previousDevice = _currentDevice;
      if (previousDevice != null && !identical(previousDevice, device)) {
        await _stopDeviceBeforeCast(previousDevice);
      }

      // 部分渲染器（尤其是 LG）在已有传输会话时会以 UPnP 701 拒绝替换 URI。
      // Stop 在空闲设备上也可能报错，因此这里只把它当作尽力而为的状态复位。
      await _stopDeviceBeforeCast(device);
      await _transport.setUrl(device, videoUrl);
      await _transport.play(device);

      _currentDevice = device;
      connectedDeviceName.value = device.info.friendlyName;
      isConnected.value = true;

      showGlassToast(
        slang.t.videoDetail.cast.startCastingTo(
          deviceName: device.info.friendlyName,
        ),
        type: GlassToastType.success,
        position: GlassToastPosition.top,
      );

      LogUtils.d('成功投屏到设备: ${device.info.friendlyName}', 'DlnaCastService');
      return true;
    } catch (e) {
      LogUtils.e('投屏失败: $e', tag: 'DlnaCastService', error: e);
      showGlassToast(
        slang.t.videoDetail.cast.castFailed(error: e.toString()),
        type: GlassToastType.error,
        position: GlassToastPosition.top,
        duration: const Duration(seconds: 5),
      );
      _currentDevice = null;
      isConnected.value = false;
      connectedDeviceName.value = '';
      return false;
    }
  }

  Future<void> _stopDeviceBeforeCast(DLNADevice device) async {
    try {
      await _transport.stop(device);
    } catch (e) {
      LogUtils.d('投屏前停止设备失败，继续设置媒体地址: $e', 'DlnaCastService');
    }
  }

  /// 停止投屏
  Future<void> stopCast() => _runSerialized(_stopCast);

  Future<void> _stopCast() async {
    try {
      final device = _currentDevice;
      if (device != null) {
        await _transport.stop(device);
        if (identical(_currentDevice, device)) {
          _currentDevice = null;
          isConnected.value = false;
          connectedDeviceName.value = '';
        }
      }

      showGlassToast(
        slang.t.videoDetail.cast.castStopped,
        type: GlassToastType.info,
        position: GlassToastPosition.top,
      );

      LogUtils.d('停止投屏', 'DlnaCastService');
    } catch (e) {
      LogUtils.e('停止投屏失败: $e', tag: 'DlnaCastService', error: e);
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

  /// 发现服务会返回 ssdp:all 下的媒体服务器、路由器等设备；只有声明了
  /// AVTransport 控制端点的设备才可以接收 SetAVTransportURI/Play。
  @visibleForTesting
  static bool isCastCapableDevice(DLNADevice device) {
    return device.info.serviceList.any((service) {
      if (service is! Map) return false;
      final serviceId = service['serviceId']?.toString() ?? '';
      final controlUrl = service['controlURL']?.toString() ?? '';
      return controlUrl.isNotEmpty && serviceId.contains('AVTransport');
    });
  }

  /// 获取设备图标
  Icon getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'MediaRenderer':
        return const Icon(Icons.cast_connected);
      case 'MediaServer':
        return const Icon(Icons.cast_connected);
      case 'InternetGatewayDevice':
        return const Icon(Icons.router);
      case 'BasicDevice':
        return const Icon(Icons.device_hub);
      case 'DimmableLight':
        return const Icon(Icons.lightbulb);
      case 'WLANAccessPoint':
        return const Icon(Icons.lan);
      case 'WLANConnectionDevice':
        return const Icon(Icons.wifi_tethering);
      case 'Printer':
        return const Icon(Icons.print);
      case 'Scanner':
        return const Icon(Icons.scanner);
      case 'DigitalSecurityCamera':
        return const Icon(Icons.camera_enhance_outlined);
      default:
        return const Icon(Icons.question_mark);
    }
  }

  /// 获取设备类型显示名称
  String getDeviceTypeName(String deviceType) {
    switch (deviceType) {
      case 'MediaRenderer':
        return slang.t.videoDetail.cast.deviceTypes.mediaRenderer;
      case 'MediaServer':
        return slang.t.videoDetail.cast.deviceTypes.mediaServer;
      case 'InternetGatewayDevice':
        return slang.t.videoDetail.cast.deviceTypes.internetGatewayDevice;
      case 'BasicDevice':
        return slang.t.videoDetail.cast.deviceTypes.basicDevice;
      case 'DimmableLight':
        return slang.t.videoDetail.cast.deviceTypes.dimmableLight;
      case 'WLANAccessPoint':
        return slang.t.videoDetail.cast.deviceTypes.wlanAccessPoint;
      case 'WLANConnectionDevice':
        return slang.t.videoDetail.cast.deviceTypes.wlanConnectionDevice;
      case 'Printer':
        return slang.t.videoDetail.cast.deviceTypes.printer;
      case 'Scanner':
        return slang.t.videoDetail.cast.deviceTypes.scanner;
      case 'DigitalSecurityCamera':
        return slang.t.videoDetail.cast.deviceTypes.digitalSecurityCamera;
      default:
        return slang.t.videoDetail.cast.deviceTypes.unknownDevice;
    }
  }
}
