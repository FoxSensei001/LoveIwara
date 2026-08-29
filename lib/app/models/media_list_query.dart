import 'package:flutter/foundation.dart';
import 'package:i_iwara/app/models/inner_playlist.model.dart';

/// 一份**能被重放的列表查询**：接口 + 参数。
///
/// # 为什么需要它
///
/// 「接着看」的「来源」池原本只是一份**快照**（[InnerPlaylistContext]）：进详情
/// 页那一刻列表里已经加载出来的那些条目，上限 100，超了还要随机抽样。用户从
/// 一个带筛选的热门列表 / 图库列表 / 订阅页点进去，抽屉里就只有那么几十条，
/// 翻到底了也接不下去——而那份列表本身在接口上是能无限翻的。
///
/// 所以列表页除了交出快照，还交出**它自己是怎么查的**：`sort`/`tags`/`date`/
/// `rating`/`subscribed`/`user`… 这些参数原样发给同一个接口，池就能接着往下翻
/// （见 `RemoteListPlaybackQueue`）。
///
/// # ⛔ 参数必须是列表页**真正发出去的那一份**
///
/// 不是"看起来差不多的一份"。Iwara 的这些参数彼此有约束（带 `user=` 时 `rating`
/// 被服务端忽略、非法 tag / 日期直接返 500……见
/// `subscription_query_params.dart` 里的实测记录），凭印象重拼一份的结果是池里
/// 的顺序与用户刚才看的列表对不上，"接着看"接的就不是他看的那条线了。
@immutable
class MediaListQuery {
  const MediaListQuery({
    required this.mediaType,
    required this.params,
    this.search,
    this.searchSort,
  });

  /// 视频走 `/videos`、图库走 `/images`。也决定条目落到哪个详情页。
  final PlaybackMediaType mediaType;

  /// 搜索关键词。非 null 时这份查询走的是 `/search` 而不是 `/videos`、
  /// `/images`（两条接口的入参完全不同，见 `SearchService`），[params] 那时不用。
  final String? search;

  /// 搜索的排序键（`SearchService` 的 `sort`）。
  final String? searchSort;

  /// 原样发给接口的查询参数。空值调用方自己剔掉（发一个 `date=` 空串会让服务端
  /// 按非法日期处理）。
  final Map<String, dynamic> params;

  /// 池身份用的稳定串。
  ///
  /// ⛔ 必须**按键排序**：`{sort, tags}` 与 `{tags, sort}` 是同一次查询，拼出两
  /// 个不同的 id 会让同一份列表在 `PlaybackQueueService` 里注册成两个池——各自
  /// 从第 0 页翻起，游标也对不上。
  String get signature {
    final buffer = StringBuffer(mediaType.isGallery ? 'gallery' : 'video');
    if (search != null) {
      buffer.write('|search=$search');
      if (searchSort != null) buffer.write('|searchSort=$searchSort');
      return buffer.toString();
    }
    final keys = params.keys.toList()..sort();
    for (final key in keys) {
      final value = params[key];
      if (value == null) continue;
      buffer.write('|$key=$value');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is MediaListQuery && other.signature == signature;

  @override
  int get hashCode => signature.hashCode;

  @override
  String toString() => 'MediaListQuery($signature)';

  /// 订阅动态（已关注作者的全部作品）。
  ///
  /// `subscribed=true` 是**未登录时会被服务端静默忽略**的参数（忽略之后返回的
  /// 是全站内容），所以调用点必须先确认已登录——这条在
  /// `PlaybackQueueService.openSubscriptions` 里把关。
  static MediaListQuery subscriptions({
    PlaybackMediaType mediaType = PlaybackMediaType.video,
  }) => MediaListQuery(
    mediaType: mediaType,
    params: const <String, dynamic>{'subscribed': true, 'sort': 'date'},
  );

  /// 搜索结果列表。
  static MediaListQuery searchResults({
    required PlaybackMediaType mediaType,
    required String keyword,
    String? sort,
  }) => MediaListQuery(
    mediaType: mediaType,
    params: const <String, dynamic>{},
    search: keyword,
    searchSort: sort,
  );

  /// 剔掉空值之后再建。列表页那几份参数里空串代表"这一档没选"，原样发出去会被
  /// 服务端当成非法值。
  factory MediaListQuery.pruned({
    required PlaybackMediaType mediaType,
    required Map<String, dynamic> params,
  }) {
    final pruned = <String, dynamic>{};
    params.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is Iterable && value.isEmpty) return;
      pruned[key] = value;
    });
    return MediaListQuery(mediaType: mediaType, params: pruned);
  }
}
