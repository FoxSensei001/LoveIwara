import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class RefreshRateHelper {
  
  /// 设置刷新率
  /// [refreshRate] 目标刷新率，如果不指定则使用设备支持的最高刷新率
  static Future<bool> setRefreshRate([int? refreshRate]) async {
    try {
      if (refreshRate != null) {
        // 获取支持的显示模式
        final supportedModes = await FlutterDisplayMode.supported;
        
        // 查找目标刷新率的模式
        final targetMode = supportedModes
            .where((mode) => mode.refreshRate.toInt() == refreshRate)
            .firstOrNull;
            
        if (targetMode != null) {
          await FlutterDisplayMode.setPreferredMode(targetMode);
          LogUtils.d('刷新率设置到 ${refreshRate}Hz', '刷新率管理');
          return true;
        } else {
          LogUtils.w('未找到支持的 ${refreshRate}Hz 模式', '刷新率管理');
          return false;
        }
      } else {
        // 设置为最高刷新率
        await FlutterDisplayMode.setHighRefreshRate();
        LogUtils.d('刷新率设置为最高支持刷新率', '刷新率管理');
        return true;
      }
    } catch (e) {
      LogUtils.e('设置刷新率失败', tag: '刷新率管理', error: e);
      return false;
    }
  }
  
  /// 获取设备支持的最高刷新率
  static Future<int> getMaxRefreshRate() async {
    try {
      final supportedModes = await FlutterDisplayMode.supported;
      final maxRate = supportedModes
          .map((mode) => mode.refreshRate.toInt())
          .reduce((a, b) => a > b ? a : b);
      
      LogUtils.d('设备最高支持刷新率: ${maxRate}Hz', '刷新率管理');
      return maxRate;
    } catch (e) {
      LogUtils.e('获取最高刷新率失败', tag: '刷新率管理', error: e);
      return 60;
    }
  }
  
  /// 获取当前活动的刷新率
  static Future<int> getCurrentRefreshRate() async {
    try {
      final activeMode = await FlutterDisplayMode.active;
      final currentRate = activeMode.refreshRate.toInt();
      LogUtils.d('当前刷新率: ${currentRate}Hz', '刷新率管理');
      return currentRate;
    } catch (e) {
      LogUtils.e('获取当前刷新率失败', tag: '刷新率管理', error: e);
      return 60;
    }
  }
  
  /// 获取所有支持的显示模式
  static Future<List<DisplayMode>> getSupportedModes() async {
    try {
      final modes = await FlutterDisplayMode.supported;
      LogUtils.d('支持的显示模式数量: ${modes.length}', '刷新率管理');
      return modes;
    } catch (e) {
      LogUtils.e('获取支持的显示模式失败', tag: '刷新率管理', error: e);
      return [];
    }
  }
  
  /// 启用高刷新率模式
  static Future<bool> enableHighRefreshRate() async {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
      LogUtils.d('已启用高刷新率模式', '刷新率管理');
      return true;
    } catch (e) {
      LogUtils.e('启用高刷新率失败', tag: '刷新率管理', error: e);
      return false;
    }
  }
  
  /// 设置为 60Hz（省电模式）
  static Future<bool> enablePowerSavingMode() async {
    try {
      await FlutterDisplayMode.setLowRefreshRate();
      LogUtils.d('已启用省电模式（低刷新率）', '刷新率管理');
      return true;
    } catch (e) {
      LogUtils.e('启用省电模式失败', tag: '刷新率管理', error: e);
      return false;
    }
  }
  
  /// 设置自动模式（让系统决定刷新率）
  static Future<bool> setAutoMode() async {
    try {
      final supportedModes = await FlutterDisplayMode.supported;
      final autoMode = supportedModes.firstWhere(
        (mode) => mode.id == 0, // DisplayMode.auto 通常 id 为 0
        orElse: () => supportedModes.first,
      );
      
      await FlutterDisplayMode.setPreferredMode(autoMode);
      LogUtils.d('已设置自动刷新率模式', '刷新率管理');
      return true;
    } catch (e) {
      LogUtils.e('设置自动模式失败', tag: '刷新率管理', error: e);
      return false;
    }
  }
} 