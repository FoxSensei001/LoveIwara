import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
class SignInHeatMap extends StatelessWidget {
  final Map<DateTime, bool> signInStatus;
  final int consecutiveSignIns;
  final DateTime startDate;
  final DateTime endDate;
  final Map<DateTime, String> failureReasons; // 新增破戒原因映射

  SignInHeatMap({
    super.key,
    required this.signInStatus,
    required this.consecutiveSignIns,
    required this.failureReasons, // 新增参数
    DateTime? startDate,
    DateTime? endDate,
  })  : startDate = startDate ?? DateTime.now().subtract(const Duration(days: 90)),
        endDate = endDate ?? DateTime.now();

  // 生成日期列表
  List<DateTime> _generateDateList() {
    List<DateTime> dates = [];
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime finalDate = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(finalDate) || currentDate.isAtSameMomentAs(finalDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  // 计算颜色基于连续签到天数
  Color _getColor(int streak) {
    if (streak <= 1) return Colors.green.shade200;
    if (streak <= 3) return Colors.green.shade400;
    if (streak <= 5) return Colors.green.shade600;
    if (streak <= 7) return Colors.green.shade800;
    return Colors.green.shade900;
  }

  // 获取当前日期的连续签到天数
  int _calculateStreak(DateTime day) {
    int streak = 0;
    DateTime currentDay = day;

    while (signInStatus[currentDay] == true) {
      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
      if (currentDay.isBefore(startDate)) break;
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> dateList = _generateDateList();
    final t = slang.Translations.of(context);

    // 计算最大连续签到天数以调整颜色渐变
    int maxStreak = 0;
    for (var day in dateList) {
      if (signInStatus[day] == true) {
        int streak = _calculateStreak(day);
        if (streak > maxStreak) {
          maxStreak = streak;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 显示连续签到天数
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${t.signIn.consecutiveSignIns}: $consecutiveSignIns',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        // 热点图网格
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 7; // 一周7天
            double spacing = 4.0;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dateList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                DateTime date = dateList[index];
                bool? isSuccess = signInStatus[DateTime(date.year, date.month, date.day)];
                Color bgColor;

                if (isSuccess == null) {
                  bgColor = Colors.grey.shade200; // 未签到
                } else if (isSuccess) {
                  int streak = _calculateStreak(date);
                  bgColor = _getColor(streak);
                } else {
                  bgColor = Colors.red.shade400; // 破戒
                }

                return GestureDetector(
                  onTap: () {
                    // 当有破戒原因时显示提示框
                    String? reason = failureReasons[date];
                    if (isSuccess == false && reason != null && reason.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(t.signIn.failureReason),
                          content: Text(reason),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(t.common.close),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSuccess == null ? Colors.grey.shade200 : bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSuccess == null ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
