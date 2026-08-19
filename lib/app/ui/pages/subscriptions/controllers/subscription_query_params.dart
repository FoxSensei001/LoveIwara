/// 订阅页列表（视频 / 图库）的查询参数拼装。
///
/// 参数支持情况按真实接口实测（api.iwara.tv `/videos`、`/images`）：
/// - `sort` / `date` / `tags` 在 `subscribed=true` 与 `user=<id>` 两种查询下都生效，
///   且能与订阅集合叠加（带筛选的订阅查询返回结果仍全部来自已关注作者）。
/// - `rating` 只在 `subscribed=true` 下生效；带 `user=` 时服务端会忽略它
///   （混合评级作者传 general / ecchi 返回完全相同的混合结果），所以这里不发。
/// - `tags` 是「同时含有」语义；传不存在的标签或非法日期（如 `2024-13`）
///   服务端返回 500，不是空结果，因此取值只能来自合法标签与年月选择。
Map<String, dynamic> buildSubscriptionQueryParams({
  required String userId,
  String sortId = '',
  List<String> searchTagIds = const [],
  String searchDate = '',
  String searchRating = '',
}) {
  final bool isSubscribedFeed = userId.isEmpty;
  return <String, dynamic>{
    if (!isSubscribedFeed) 'user': userId,
    if (isSubscribedFeed) 'subscribed': true,
    if (sortId.isNotEmpty) 'sort': sortId,
    if (searchTagIds.isNotEmpty) 'tags': searchTagIds.join(','),
    if (searchDate.isNotEmpty) 'date': searchDate,
    if (isSubscribedFeed && searchRating.isNotEmpty) 'rating': searchRating,
  };
}
