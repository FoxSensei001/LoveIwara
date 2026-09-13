import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

/// 媒体布局工具类，提供共享的布局计算逻辑
class MediaLayoutUtils {
  /// Prevent automatic grids from producing unreadably narrow cards inside a
  /// narrow shell or a desktop split view.
  static const double minAutomaticCardWidth = 144.0;

  /// 获取配置服务实例
  static ConfigService? get _configServiceOrNull =>
      Get.isRegistered<ConfigService>() ? Get.find<ConfigService>() : null;

  /// 根据可用宽度计算瀑布流列数
  static int calculateCrossAxisCount(double availableWidth) {
    // 安全检查：确保宽度有效
    if (!availableWidth.isFinite || availableWidth <= 0) {
      return 2; // 默认列数
    }

    final configService = _configServiceOrNull;
    final layoutMode =
        configService?[ConfigKey.LAYOUT_MODE] as String? ??
        ConfigKey.LAYOUT_MODE.defaultValue as String;

    if (layoutMode == 'manual') {
      // 手动模式：使用用户设置的固定列数
      final count =
          configService?[ConfigKey.MANUAL_COLUMNS_COUNT] as int? ??
          ConfigKey.MANUAL_COLUMNS_COUNT.defaultValue as int;
      return count < 1 ? 1 : count; // 确保至少1列
    } else {
      // 自动模式：根据断点配置计算
      final breakpointsRaw = configService?[ConfigKey.LAYOUT_BREAKPOINTS];

      // 类型安全检查，确保 breakpoints 是 Map<String, int> 类型
      Map<String, int> breakpoints;
      if (breakpointsRaw is Map<String, int>) {
        breakpoints = breakpointsRaw;
      } else if (breakpointsRaw is Map) {
        // 如果类型不匹配，尝试转换
        breakpoints = Map<String, int>.from(
          breakpointsRaw.map(
            (key, value) => MapEntry(
              key.toString(),
              value is int ? value : int.tryParse(value.toString()) ?? 6,
            ),
          ),
        );
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
      final sortedBreakpoints =
          breakpoints.entries
              .map((e) => MapEntry(int.parse(e.key), e.value))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

      int fitAutomaticCount(int configuredCount) {
        final safeConfiguredCount = configuredCount < 1 ? 1 : configuredCount;
        final maximumCount =
            ((availableWidth + crossAxisSpacing) /
                    (minAutomaticCardWidth + crossAxisSpacing))
                .floor()
                .clamp(1, safeConfiguredCount);
        return maximumCount < safeConfiguredCount
            ? maximumCount
            : safeConfiguredCount;
      }

      // 根据可用宽度找到对应的列数
      for (final entry in sortedBreakpoints) {
        if (availableWidth <= entry.key) {
          return fitAutomaticCount(entry.value);
        }
      }

      // 如果没有找到匹配的断点，返回最后一个配置的列数
      final lastValue = sortedBreakpoints.isNotEmpty
          ? sortedBreakpoints.last.value
          : 2;
      return fitAutomaticCount(lastValue);
    }
  }

  /// 根据可用宽度计算卡片宽度
  static double calculateCardWidth(double availableWidth) {
    if (!availableWidth.isFinite || availableWidth <= 0) {
      return 0;
    }

    final crossAxisCount = calculateCrossAxisCount(availableWidth);
    final totalSpacing = (crossAxisCount - 1) * crossAxisSpacing;
    final usableWidth = availableWidth - totalSpacing;
    final cardWidth = usableWidth / crossAxisCount;

    if (!cardWidth.isFinite || cardWidth <= 0) {
      return availableWidth;
    }

    return cardWidth;
  }

  /// 瀑布流里一张卡实际占的宽度。
  ///
  /// ⛔ 必须与 `SliverWaterfallFlowDelegateWithMaxCrossAxisExtent` 的
  /// `getChildUsableCrossAxisExtent` 逐字一致：
  ///
  /// ```
  /// count = ceil(sliverCrossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
  /// width = (sliverCrossAxisExtent - crossAxisSpacing * (count - 1)) / count
  /// ```
  ///
  /// 算错一个像素，卡片就会比它所在的格子宽或窄——那是肉眼直接可见的版式错位，
  /// 而且只在特定宽度下才暴露。所以这里只复刻 delegate 的算式，不做任何自己的
  /// 「顺手优化」。
  ///
  /// [sliverCrossAxisExtent] 是**扣掉列表左右内边距之后**的宽度：瀑布流拿到的
  /// 是扣过 `SliverPadding` 的那份约束，不是整页宽度。
  static double resolveWaterfallChildWidth({
    required double sliverCrossAxisExtent,
    required double maxCrossAxisExtent,
    required double crossAxisSpacing,
  }) {
    if (!sliverCrossAxisExtent.isFinite || sliverCrossAxisExtent <= 0) return 0;
    if (!maxCrossAxisExtent.isFinite || maxCrossAxisExtent <= 0) {
      return sliverCrossAxisExtent;
    }
    final int count =
        (sliverCrossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing)).ceil();
    if (count <= 0) return sliverCrossAxisExtent;
    final double width =
        (sliverCrossAxisExtent - crossAxisSpacing * (count - 1)) / count;
    return width.isFinite && width > 0 ? width : sliverCrossAxisExtent;
  }

  /// 获取瀑布流布局的间距
  static double get crossAxisSpacing => 4.0;
  static double get mainAxisSpacing => 4.0;
}
