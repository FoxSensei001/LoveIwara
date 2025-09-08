import 'dart:async';

import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class DlnaCastService extends GetxService {
  static DlnaCastService get instance => Get.find<DlnaCastService>();
  
  final RxBool isSearching = false.obs;
  final RxList<DLNADevice> devices = <DLNADevice>[].obs;
  final RxBool isConnected = false.obs;
  final RxString connectedDeviceName = ''.obs;
  
  DLNAManager? _dlnaManager;
  StreamSubscription<Map<String, DLNADevice>>? _deviceSubscription;
  DLNADevice? _currentDevice;
  bool _isInitialized = false;

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
        devices.clear();
        deviceMap.forEach((key, device) {
          devices.add(device);
        });
        LogUtils.d('发现 DLNA 设备: ${devices.length} 个', 'DlnaCastService');
      });
      
      LogUtils.d('开始搜索 DLNA 设备', 'DlnaCastService');
    } catch (e) {
      LogUtils.e('启动 DLNA 搜索失败: $e', tag: 'DlnaCastService', error: e);
      showToastWidget(
        MDToastWidget(
          message: slang.t.videoDetail.cast.unableToStartCastingSearch(error: e.toString()),
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
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
  Future<void> castToDevice(DLNADevice device, String videoUrl) async {
    try {
      _currentDevice = device;
      connectedDeviceName.value = device.info.friendlyName;
      isConnected.value = true;
      
      // 设置视频 URL 并播放
      await device.setUrl(videoUrl);
      await device.play();
      
      showToastWidget(
        MDToastWidget(
          message: slang.t.videoDetail.cast.startCastingTo(deviceName: device.info.friendlyName),
          type: MDToastType.success,
        ),
        position: ToastPosition.top,
      );
      
      LogUtils.d('成功投屏到设备: ${device.info.friendlyName}', 'DlnaCastService');
    } catch (e) {
      LogUtils.e('投屏失败: $e', tag: 'DlnaCastService', error: e);
      showToastWidget(
        MDToastWidget(
          message: slang.t.videoDetail.cast.castFailed(error: e.toString()),
          type: MDToastType.error,
        ),
        position: ToastPosition.top,
        duration: const Duration(seconds: 5),
      );
      isConnected.value = false;
      connectedDeviceName.value = '';
    }
  }

  /// 停止投屏
  Future<void> stopCast() async {
    try {
      if (_currentDevice != null) {
        _currentDevice!.stop();
        _currentDevice = null;
      }
      isConnected.value = false;
      connectedDeviceName.value = '';
      
      showToastWidget(
        MDToastWidget(
          message: slang.t.videoDetail.cast.castStopped,
          type: MDToastType.info,
        ),
        position: ToastPosition.top,
      );
      
      LogUtils.d('停止投屏', 'DlnaCastService');
    } catch (e) {
      LogUtils.e('停止投屏失败: $e', tag: 'DlnaCastService', error: e);
    }
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
