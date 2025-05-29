
/// 媒体布局工具类，提供共享的布局计算逻辑
class MediaLayoutUtils {
  /// 根据屏幕宽度计算瀑布流列数
  static int calculateCrossAxisCount(double screenWidth) {
    if (screenWidth <= 600) {
      return 2; // 窄屏设备，显示2列
    } else if (screenWidth <= 900) {
      return 3; // 中等屏幕，显示3列
    } else if (screenWidth <= 1200) {
      return 4; // 较大屏幕，显示4列
    } else if (screenWidth <= 1500) {
      return 5; // 大屏幕，显示5列
    } else {
      return 6; // 超大屏幕，显示6列
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