import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'search_repository.dart';

/// 视频搜索仓库
class VideoSearchRepository extends SearchRepository<Video> {
  final String? sortType;
  
  VideoSearchRepository({
    required super.query,
    this.sortType,
  }) : super(segment: SearchSegment.video.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchVideoByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortType,
    );
  }
}

/// 图片搜索仓库
class ImageSearchRepository extends SearchRepository<ImageModel> {
  final String? sortType;
  
  ImageSearchRepository({
    required super.query,
    this.sortType,
  }) : super(segment: SearchSegment.image.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchImageByQuery(
      page: page,
      limit: limit,
      query: keyword,
      sort: sortType,
    );
  }
}

/// 用户搜索仓库
class UserSearchRepository extends SearchRepository<User> {
  UserSearchRepository({required super.query})
      : super(segment: SearchSegment.user.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchUserByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 帖子搜索仓库
class PostSearchRepository extends SearchRepository<PostModel> {
  PostSearchRepository({required super.query})
      : super(segment: SearchSegment.post.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchPostByQuery(
      page: page,
      limit: limit,
      query: keyword,
    );
  }
}

/// 论坛搜索仓库
class ForumSearchRepository extends SearchRepository<ForumThreadModel> {
  ForumSearchRepository({required super.query})
      : super(segment: SearchSegment.forum.apiType);

  @override
  Future<ApiResult> fetchSearchResults(int page, int limit, String keyword) {
    return searchService.fetchForumByQuery(
      page: page,
      limit: limit,
      query: keyword,
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
    );
  }
}