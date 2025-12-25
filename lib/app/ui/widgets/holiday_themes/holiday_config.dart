import 'package:lunar/lunar.dart';

/// 节日主题模式
enum HolidayMode { none, christmas, lunarNewYear }

/// 节日定义
class HolidayDefinition {
  final HolidayMode mode;
  final bool Function(DateTime date) dateChecker;

  const HolidayDefinition({required this.mode, required this.dateChecker});
}

/// 强制节日主题（用于开发测试）
/// 设置为 null 则使用自动日期检测
/// 设置为具体模式则强制显示该主题，忽略日期
const HolidayMode? FORCED_HOLIDAY_THEME = null;
// 示例：
// const HolidayMode? FORCED_HOLIDAY_THEME = HolidayMode.lunarNewYear;
// const HolidayMode? FORCED_HOLIDAY_THEME = HolidayMode.christmas;

/// 节日配置管理列表
class HolidayConfig {
  /// 节日配置列表
  /// 可以通过修改此列表或者添加新的配置来扩展更多节日
  static final List<HolidayDefinition> _holidays = [
    // 圣诞节: 12月20日 - 1月5日
    HolidayDefinition(
      mode: HolidayMode.christmas,
      dateChecker: (date) {
        // 12月20日 到 1月5日
        if (date.month == 12 && date.day >= 20) return true;
        if (date.month == 1 && date.day <= 5) return true;
        return false;
      },
    ),

    // 农历新年（春节）: 动态计算春节日期，前后各7天
    HolidayDefinition(
      mode: HolidayMode.lunarNewYear,
      dateChecker: (date) {
        try {
          // 直接从农历日期转换：农历正月初一
          final lunarNewYear = Lunar.fromYmd(date.year, 1, 1);
          final springFestivalDate = lunarNewYear.getSolar().toYmd();

          // 解析春节日期
          final parts = springFestivalDate.split('-');
          final festivalYear = int.parse(parts[0]);
          final festivalMonth = int.parse(parts[1]);
          final festivalDay = int.parse(parts[2]);

          final festivalDateTime = DateTime(
            festivalYear,
            festivalMonth,
            festivalDay,
          );

          // 计算日期差
          final diff = date.difference(festivalDateTime).inDays;

          // 春节前后各7天
          return diff >= -7 && diff <= 7;
        } catch (e) {
          // 如果计算失败，使用简单的区间判断作为后备方案
          // 1月20日到2月15日
          if (date.month == 1 && date.day >= 20) return true;
          if (date.month == 2 && date.day <= 15) return true;
          return false;
        }
      },
    ),
  ];

  /// 根据日期获取对应的节日模式
  static HolidayMode getHolidayMode(DateTime date) {
    // 如果设置了强制主题，直接返回
    if (FORCED_HOLIDAY_THEME != null) {
      return FORCED_HOLIDAY_THEME!;
    }

    // 否则使用自动日期检测
    for (var holiday in _holidays) {
      if (holiday.dateChecker(date)) {
        return holiday.mode;
      }
    }
    return HolidayMode.none;
  }
}
