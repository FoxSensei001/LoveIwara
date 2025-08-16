import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

/// 媒体布局工具类，提供共享的布局计算逻辑
class MediaLayoutUtils {
  /// 获取配置服务实例
  static ConfigService get _configService => Get.find<ConfigService>();

  /// 根据屏幕宽度计算瀑布流列数
  static int calculateCrossAxisCount(double screenWidth) {
    final layoutMode = _configService[ConfigKey.LAYOUT_MODE] as String;
    
    if (layoutMode == 'manual') {
      // 手动模式：使用用户设置的固定列数
      return _configService[ConfigKey.MANUAL_COLUMNS_COUNT] as int;
    } else {
      // 自动模式：根据断点配置计算
      final breakpointsRaw = _configService[ConfigKey.LAYOUT_BREAKPOINTS];
      
      // 类型安全检查，确保 breakpoints 是 Map<String, int> 类型
      Map<String, int> breakpoints;
      if (breakpointsRaw is Map<String, int>) {
        breakpoints = breakpointsRaw;
      } else if (breakpointsRaw is Map) {
        // 如果类型不匹配，尝试转换
        breakpoints = Map<String, int>.from(breakpointsRaw.map((key, value) => 
          MapEntry(key.toString(), value is int ? value : int.tryParse(value.toString()) ?? 6)));
      } else {
        // 如果获取失败，使用默认值
        breakpoints = <String, int>{
          '600': 2,
          '900': 3,
          '1200': 4,
          '1500': 5,
          '9999': 6,
        };
      }
      
      // 将字符串键转换为数字并排序
      final sortedBreakpoints = breakpoints.entries
          .map((e) => MapEntry(int.parse(e.key), e.value))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      // 根据屏幕宽度找到对应的列数
      for (final entry in sortedBreakpoints) {
        if (screenWidth <= entry.key) {
          return entry.value;
        }
      }
      
      // 如果没有找到匹配的断点，返回最后一个配置的列数
      return sortedBreakpoints.last.value;
    }
  }

  /// 根据屏幕宽度计算卡片宽度
  static double calculateCardWidth(double screenWidth) {
    final crossAxisCount = calculateCrossAxisCount(screenWidth);
    final spacing = 8.0; // 列间距
    return (screenWidth / crossAxisCount) - (spacing * (crossAxisCount - 1) / crossAxisCount);
  }

  /// 获取瀑布流布局的间距
  static double get crossAxisSpacing => 4.0;
  static double get mainAxisSpacing => 4.0;
} 