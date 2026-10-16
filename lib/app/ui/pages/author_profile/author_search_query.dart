import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/search/iwara_search_syntax.dart';

/// 作者页「在这位作者的作品里搜」。
///
/// ⭐ 走的是 iwara 的 `/search` 加 `{author:<username>}`，而不是在作者列表接口
/// 已加载的那几页里本地过滤：
/// - 作者列表（`/videos?user=`）的 `count` 是「已加载 + 1」的哨兵值，拿不到
///   真实总数，「扫完整个列表」既估不了进度、也判不准什么时候扫完；
/// - `/search` 一次就覆盖这位作者的全部作品，而且直接复用搜索页那套多路归并
///   （引号短语、按标签补路、跨语言标题补路）——词怎么搜，与搜索页一模一样。
///
/// ⛔ `author` 只认精确的 @username（大小写不敏感），显示名、UUID 都是 0 条。
/// ⛔ 自由文本必须排在花括号**前面**，否则会被引擎静默丢掉（见
/// [composeQuery]）；这里只负责拼筛选串，文本在前由 [composeQuery] 保证。
String authorSearchQuery({
  required String keyword,
  required String username,
  List<String> tagIds = const [],
  String date = '',
  bool? exactMatch,
}) {
  final quote =
      exactMatch ??
      (!Get.isRegistered<ConfigService>() ||
          Get.find<ConfigService>()[ConfigKey.SEARCH_EXACT_MATCH] != false);
  final text = quote ? autoQuoteKeyword(keyword) : keyword.trim();
  final filters = <String>[
    '{author:${username.trim()}}',
    // 作者列表的 `tags=a,b` 是「同时含有」；搜索里 `{tags:[a,b]}` 是「任一」，
    // 所以每个标签各占一对花括号（花括号之间是 AND）。
    for (final id in tagIds)
      if (id.isNotEmpty) '{tags:[$id]}',
    ..._dateFilters(date),
  ];
  return composeQuery(text, filters.join(' '));
}

/// 作者列表的排序在搜索里怎么排。
///
/// 搜索只认 date / views / likes / relevance。「热门」「趋势」在搜索里没有对应，
/// 退成按相关度（传 null ＝不带 sort ＝ relevance）。
String? authorSearchSort(String listSort) => switch (listSort) {
  'date' || 'views' || 'likes' => listSort,
  _ => null,
};

/// `YYYY` / `YYYY-MM` → `{date>=起} {date<止}`（UNIX 秒，UTC）。认不出就不筛，
/// 宁可多给也别因为一个拼错的日期把结果筛成 0。
List<String> _dateFilters(String date) {
  final match = RegExp(r'^(\d{4})(?:-(\d{1,2}))?$').firstMatch(date.trim());
  if (match == null) return const [];
  final year = int.parse(match.group(1)!);
  final month = match.group(2) == null ? null : int.parse(match.group(2)!);
  if (month != null && (month < 1 || month > 12)) return const [];
  final start = DateTime.utc(year, month ?? 1);
  final end = month == null
      ? DateTime.utc(year + 1)
      : DateTime.utc(year, month + 1);
  int seconds(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
  return ['{date>=${seconds(start)}}', '{date<${seconds(end)}}'];
}
