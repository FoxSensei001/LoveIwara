import 'package:flutter/material.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 按时间分组的列表（下载历史区、浏览历史）共用的组名：今天 / 昨天 / 本周 /
/// 本月，再往前按月（「2026年8月」）。越久远分得越粗。没有时间的返回 null（不分组）。
String? timelineGroupLabel(BuildContext context, DateTime? date, DateTime now) {
  if (date == null) return null;
  final t = slang.Translations.of(context).download.timeline;
  final local = date.toLocal();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  if (!day.isBefore(today)) return t.today;
  // 按日历字段减，别减 Duration：夏令时切换那天不是 24 小时。
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return t.yesterday;
  }
  final weekStart = DateTime(
    today.year,
    today.month,
    today.day - (now.weekday - 1),
  );
  if (!day.isBefore(weekStart)) return t.thisWeek;
  if (local.year == now.year && local.month == now.month) return t.thisMonth;
  return MaterialLocalizations.of(context).formatMonthYear(local);
}
