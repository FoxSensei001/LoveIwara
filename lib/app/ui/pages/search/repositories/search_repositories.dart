import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'search_repository.dart';

/// 某个排序值能不能给归并当尺子。
///
/// ⛔ `relevance`（以及不传 sort ＝ 服务端默认按相关度）下引擎**不返回分数**，
/// 几路结果之间没有共同的尺子，归并会按一个不存在的顺序乱插。日期/播放/点赞
/// 都是响应里带着的数值，可比。
bool _sortIsMergeable(String? sort) =>
    sort == 'date' || sort == 'views' || sort == 'likes';

/// 视频搜索仓库
class VideoSearchRepository extends SearchRepository<Video> {
  final String? sortKey;
  VideoSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.video.apiType);

  @override
  bool get supportsCrossLanguageMerge => _sortIsMergeable(sortKey);

  @override
  String? itemId(Video item) => item.id;

  @override
  num? itemSortKey(Video item) => switch (sortKey) {
    'views' => item.numViews ?? 0,
    'likes' => item.numLikes ?? 0,
    _ => item.createdAt?.millisecondsSinceEpoch,
  };

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchVideoByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// 图片搜索仓库
class ImageSearchRepository extends SearchRepository<ImageModel> {
  final String? sortKey;
  ImageSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.image.apiType);

  @override
  bool get supportsCrossLanguageMerge => _sortIsMergeable(sortKey);

  @override
  String? itemId(ImageModel item) => item.id;

  @override
  num? itemSortKey(ImageModel item) => switch (sortKey) {
    'views' => item.numViews,
    'likes' => item.numLikes,
    _ => item.createdAt?.millisecondsSinceEpoch,
  };

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchImageByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// 用户搜索仓库
class UserSearchRepository extends SearchRepository<User> {
  final String? sortKey;
  UserSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.user.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchUserByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// 帖子搜索仓库
class PostSearchRepository extends SearchRepository<PostModel> {
  final String? sortKey;
  PostSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.post.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchPostByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// 论坛搜索仓库
class ForumSearchRepository extends SearchRepository<ForumThreadModel> {
  final String? sortKey;
  ForumSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.forum.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchForumByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// 论坛帖子回复搜索仓库
class ForumPostsSearchRepository extends SearchRepository<ThreadCommentModel> {
  final String? sortKey;
  ForumPostsSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.forum_posts.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchForumPostsByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}

/// Oreno3d搜索仓库
class Oreno3dSearchRepository extends SearchRepository<Oreno3dVideo> {
  final String? sortType;
  final String? searchType; // 新增搜索类型参数
  final Map<String, dynamic>? extData; // 新增扩展数据参数

  Oreno3dSearchRepository({
    required super.query,
    this.sortType,
    this.searchType,
    this.extData,
  }) : super(segment: SearchSegment.oreno3d.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchOreno3dByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortType,
      searchType: searchType,
      extData: extData,
      cancelToken: cancelToken,
    );
  }
}

/// 播放列表搜索仓库
class PlaylistSearchRepository extends SearchRepository<PlaylistModel> {
  final String? sortKey;
  PlaylistSearchRepository({required super.query, this.sortKey})
    : super(segment: SearchSegment.playlist.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchPlaylistByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortKey,
      cancelToken: cancelToken,
    );
  }
}
