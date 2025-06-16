import 'package:flutter/services.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class RefreshRateHelper {
  static const MethodChannel _channel = MethodChannel('refresh_rate');
  
  /// 设置刷新率
  /// [refreshRate] 目标刷新率，如果不指定则使用设备支持的最高刷新率
  static Future<bool> setRefreshRate([int? refreshRate]) async {
    try {
      final result = await _channel.invokeMethod('setRefreshRate', refreshRate);
      LogUtils.d('刷新率设置${refreshRate != null ? '到 ${refreshRate}Hz' : '为最高支持刷新率'}', '刷新率管理');
      return result ?? false;
    } catch (e) {
      LogUtils.e('设置刷新率失败', tag: '刷新率管理', error: e);
      return false;
    }
  }
  
  /// 获取设备支持的最高刷新率
  static Future<int> getMaxRefreshRate() async {
    try {
      final result = await _channel.invokeMethod('getMaxRefreshRate');
      final maxRate = result ?? 60;
      LogUtils.d('设备最高支持刷新率: ${maxRate}Hz', '刷新率管理');
      return maxRate;
    } catch (e) {
      LogUtils.e('获取最高刷新率失败', tag: '刷新率管理', error: e);
      return 60;
    }
  }
  
  /// 启用高刷新率模式
  static Future<bool> enableHighRefreshRate() async {
    final maxRate = await getMaxRefreshRate();
    if (maxRate > 60) {
      return await setRefreshRate(maxRate);
    }
    return await setRefreshRate(60);
  }
  
  /// 设置为 60Hz（省电模式）
  static Future<bool> enablePowerSavingMode() async {
    return await setRefreshRate(60);
  }
} 